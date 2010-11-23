#
#   Copyright 2008,2010 Davide Bettio <davide.bettio@kdemail.net>
#   Copyright 2009 John Layt <john@layt.net>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU Library General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details
#
#   You should have received a copy of the GNU Library General Public
#   License along with this program; if not, write to the
#   Free Software Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
package CalendarTable;

use constant DISPLAYED_WEEKS => 6;

package CalendarCellBorder;

use strict;
use warnings;

sub new
{
    my ($class, $c, $w, $d, $t, $dt) = @_;
    return bless {
        cell => $c,
        week => $w,
        weekDay => $d,
        type => $t,
        date => $dt
    }, $class;
}

sub cell() {
    return shift->{cell};
}

sub week() {
    return shift->{week};
}

sub weekDay() {
    return shift->{weekDay};
}

sub type() {
    return shift->{type};
}

sub date() {
    return shift->{date};
}

package CalendarTablePrivate;

use strict;
use warnings;

use QtCore4;

use List::MoreUtils qw(any);

sub new
{
    my $initialDate = Qt::Date::currentDate();
    my ($class, $calTable);
    if ( scalar @_ == 2 ) {
        ($class, $calTable) = @_;
    }
    else {
        ($class, $calTable, $initialDate) = @_;
    }

    my $self = bless {
        q => $calTable,
        calendarType => 'locale',
        calendar => KDE::Global::locale()->calendar(),
        displayEvents => 1,
        displayHolidays => 1,
        dataEngine => undef,
        automaticUpdates => 1,
        opacity => 0.5,
        holidaysRegion => undef,
        hoverWeekRow => -1,
        hoverWeekdayColumn => -1,
        currentDate => $initialDate,
        selectedDate => Qt::Date(),
    }, $class;
    $self->{svg} = Plasma::Svg();
    $self->svg->setImagePath('widgets/calendar');
    $self->svg->setContainsMultipleImages(1);

    $self->setDate($initialDate);
    return $self;
}

sub setCalendar
{
    my ($self, $newCalendar) = @_;
    # Old calendar will get deleted for us when it's ref count goes to 0

    $self->{calendar} = $newCalendar;

    # Test for equality by comparing pointers, using overloaded 'eq' operator
    if ($self->calendar eq KDE::Global::locale()->calendar()) {
        $self->{calendarType} = 'locale';
    } else {
        $self->{calendarType} = $self->calendar->calendarType();
    }

    # Force date update to refresh cached date componants then update display
    $self->setDate($self->selectedDate);
    $self->updateHoveredPainting(Qt::PointF());
    $self->q->populateHolidays();
    $self->q->populateEvents();
    $self->q->update();
}

sub setDate
{
    my ($self, $setDate) = @_;
    $self->{selectedDate} = $setDate;
    $self->{selectedMonth} = $self->calendar->month($setDate);
    $self->{selectedYear} = $self->calendar->year($setDate);
    $self->{weekDayFirstOfSelectedMonth} = $self->weekDayFirstOfMonth($setDate);
    $self->{daysInWeek} = $self->calendar->daysInWeek($setDate);
    $self->{daysInSelectedMonth} = $self->calendar->daysInMonth($setDate);
    $self->{daysShownInPrevMonth} = ($self->weekDayFirstOfSelectedMonth - $self->calendar->weekStartDay() + $self->daysInWeek) % $self->daysInWeek;
    # make sure at least one day of the previous month is visible.
    # 1 = minimum number of days to show, increase if more days should be forced visible:
    if ($self->daysShownInPrevMonth < 1) {
        $self->{daysShownInPrevMonth} += $self->daysInWeek;
    }
    $self->{viewStartDate} = $self->dateFromRowColumn(0, 0);
    $self->{viewEndDate} = $self->dateFromRowColumn(CalendarTable::DISPLAYED_WEEKS - 1, $self->daysInWeek - 1);
}

#Returns the x co-ordinate of a given column to LTR order, column is 0 to (daysInWeek-1)
#This version does not adjust for RTL, so should not be used directly for drawing
sub columnToX
{
    my ($self, $column) = @_;
    return sprintf '%d', $self->q->boundingRect()->x() +
           $self->centeringSpace +
           $self->weekBarSpace +
           $self->cellW +
           (($self->cellW + $self->cellSpace) * $column);
}

#Returns the y co-ordinate for given row, row is 0 to (CalendarTable::DISPLAYED_WEEKS - 1)
sub rowToY
{
    my ($self, $row) = @_;
    return sprintf '%d', $self->q->boundingRect()->y() +
                 $self->headerHeight +
                 $self->headerSpace +
                 (($self->cellH + $self->cellSpace) * $row);
}

#Returns the absolute LTR column for a given x co-ordinate, -1 if outside table
sub xToColumn
{
    my ($self, $x) = @_;
    if ($x >= $self->columnToX(0) && $x < $self->columnToX($self->daysInWeek)) {
        return sprintf '%d', (($x - $self->centeringSpace) / ($self->cellW + $self->cellSpace)) - 1;
    }
    return -1;
}

#Returns the absolute row for a given y co-ordinate, -1 if outside table
sub yToRow
{
    my ($self, $y) = @_;
    if ($y >= $self->rowToY(0) && $y < $self->rowToY(CalendarTable::DISPLAYED_WEEKS)) {
        return sprintf '%d', ($y - $self->headerHeight - $self->headerSpace) / ($self->cellH + $self->cellSpace);
    }
    return -1;
}

#Convert between column and weekdayColumn depending on LTR or RTL mode
#Note the same calculation used in both directions
sub adjustColumn
{
    my ($self, $column) = @_;
    if ($column >= 0 && $column < $self->daysInWeek) {
        if ($self->q->layoutDirection() == Qt::RightToLeft()) {
            return $self->daysInWeek - $column - 1;
        } else {
            return $column;
        }
    }
    return -1;
}

#Given an x y point in the table return the cell date.
#Note can be an invalid date in the calendar system
sub dateFromPoint
{
    my ($self, $point) = @_;
    if ($point->isNull()) {
        return Qt::Date();
    }

    my $column = $self->xToColumn($point->x());
    my $row = $self->yToRow($point->y());

    if ($column < 0 || $column >= $self->daysInWeek || $row < 0 || $row >= CalendarTable::DISPLAYED_WEEKS) {
        return Qt::Date();
    }

    return $self->dateFromRowColumn($row, $self->adjustColumn($column));
}

#Given a date in the currently selected month, return the position in the table as a
#row and column. Note no direction is assumed
sub rowColumnFromDate
{
    my ($self, $cellDate, $weekRow, $weekdayColumn) = @_;
    my $offset = $self->calendar->day($cellDate) + $self->daysShownInPrevMonth - 1;
    ${$weekRow} = $offset / $self->daysInWeek;
    ${$weekdayColumn} = $offset % $self->daysInWeek;
}

#Given a position in the table as a 0-indexed row and column, return the cell date.  Makes
#no assumption about direction.  Date returned can be an invalid date in the calendar
#system, or simply invalid.
sub dateFromRowColumn
{
    my ($self, $weekRow, $weekdayColumn) = @_;
    my $cellDate = Qt::Date();

    #starting from the first of the month, which is known to always be valid, add/subtract
    #number of days to get to the required cell
    if ($self->calendar->setYMD($cellDate, $self->selectedYear, $self->selectedMonth, 1)) {
        $cellDate = $self->calendar->addDays($cellDate, ($weekRow * $self->daysInWeek) + $weekdayColumn - $self->daysShownInPrevMonth);
    }

    return $cellDate;
}

sub updateHoveredPainting
{
    my ($self, $hoverPoint) = @_;
    my $oldHoverRect;
    if ( defined $self->hoverRect() ) {
        $oldHoverRect = Qt::RectF($self->hoverRect());
    }
    $self->{hoverRect} = Qt::RectF();
    $self->{hoverWeekdayColumn} = -1;
    $self->{hoverWeekRow} = -1;

    if ($hoverPoint && !$hoverPoint->isNull()) {
        my $column = $self->xToColumn($hoverPoint->x());
        my $row = $self->yToRow($hoverPoint->y());

        if ($column >= 0 && $column < $self->daysInWeek && $row >= 0 && $row < CalendarTable::DISPLAYED_WEEKS) {
            $self->{hoverRect} = Qt::RectF($self->columnToX($column) - $self->glowRadius,
                               $self->rowToY($row) - $self->glowRadius,
                               $self->cellW + $self->glowRadius * 2,
                               $self->cellH + $self->glowRadius * 2)->adjusted(-2,-2,2,2);
            $self->{hoverWeekdayColumn} = $self->adjustColumn($column);
            $self->{hoverWeekRow} = $row;
        }
    }

    # now update what is needed, and only what is needed!
    if ($oldHoverRect && $self->hoverRect != $oldHoverRect) {
        #FIXME: update only of a piece seems to paint over the old stuff
        #/*if (oldHoverRect.isValid()) {
            #q->update(oldHoverRect);
        #}
        #if (hoverRect.isValid()) {
            #q->update(hoverRect);
        #}*/
        emit $self->q->dateHovered($self->dateFromRowColumn($self->hoverWeekRow, $self->hoverWeekdayColumn));
        $self->q->update();
    }
}

# calculate weekday number of first day of this month, this is the anchor for all calculations
sub weekDayFirstOfMonth
{
    my ($self) = @_;
    my $firstDayOfMonth = Qt::Date();
    my $weekday = -1;
    if ( $self->calendar->setYMD($firstDayOfMonth, $self->selectedYear, $self->selectedMonth, 1)) {
        $weekday = $self->calendar->dayOfWeek($firstDayOfMonth);
    }
    return $weekday;
}

sub defaultHolidaysRegion
{
    my ($self) = @_;
    return $self->dataEngine->query('holidaysDefaultRegion')->{holidaysDefaultRegion}->toString();
}

sub insertPimOccurence
{
    my ($self, $type, $date, $occurrence) = @_;
    if ($date >= $self->viewStartDate && $date <= $self->viewEndDate) {
        my $julian = $date->toJulianDay();
        if ($type eq 'Event' && defined $self->{events}{$julian} && !(any{ $_ == $occurrence }, @{$self->{events}{$julian}})) {
            push @{$self->{events}{$julian}}, $occurrence;
        } elsif ($type eq 'Todo' && defined $self->{todos}{$julian} && !(any{ $_ == $occurrence }, @{$self->{todos}{$julian}})) {
            push @{$self->{todos}->{$julian}}, $occurrence;
        } elsif ($type eq 'Journal' && defined $self->{journals}{$julian} && !(any{ $_ == $occurrence }, @{$self->{journals}{$julian}})) {
            push @{$self->{journals}->{$julian}}, $occurrence;
        }
    }
}

sub q() {
    return shift->{q};
}

sub calendarType() {
    return shift->{calendarType};
}

sub calendar() {
    return shift->{calendar};
}

sub selectedDate() {
    return shift->{selectedDate};
}

sub currentDate() {
    return shift->{currentDate};
}

sub selectedMonth() {
    return shift->{selectedMonth};
}

sub selectedYear() {
    return shift->{selectedYear};
}

sub weekDayFirstOfSelectedMonth() {
    return shift->{weekDayFirstOfSelectedMonth};
}

sub daysInWeek() {
    return shift->{daysInWeek};
}

sub daysInSelectedMonth() {
    return shift->{daysInSelectedMonth};
}

sub daysShownInPrevMonth() {
    return shift->{daysShownInPrevMonth};
}

sub viewStartDate() {
    return shift->{viewStartDate};
}

sub viewEndDate() {
    return shift->{viewEndDate};
}

sub displayEvents() {
    return shift->{displayEvents};
}

sub displayHolidays() {
    return shift->{displayHolidays};
}

sub holidaysRegion() {
    return shift->{holidaysRegion};
}

sub dataEngine() {
    return shift->{dataEngine};
}

sub holidays() {
    return shift->{holidays};
}

sub events() {
    return shift->{events};
}

sub todos() {
    return shift->{todos};
}

sub journals() {
    return shift->{journals};
}

sub pimEvents() {
    return shift->{pimEvents};
}

sub eventsQuery() {
    return shift->{eventsQuery};
}

sub automaticUpdates() {
    return shift->{automaticUpdates};
}

sub lastSeenMousePos() {
    return shift->{lastSeenMousePos};
}

sub calendarConfigUi() {
    return shift->{calendarConfigUi};
}

sub svg() {
    return shift->{svg};
}

sub opacity() {
    return shift->{opacity};
}

sub hoverRect() {
    return shift->{hoverRect};
}

sub hoverWeekRow() {
    return shift->{hoverWeekRow};
}

sub hoverWeekdayColumn() {
    return shift->{hoverWeekdayColumn};
}

sub centeringSpace() {
    return shift->{centeringSpace};
}

sub cellW() {
    return shift->{cellW};
}

sub cellH() {
    return shift->{cellH};
}

sub cellSpace() {
    return shift->{cellSpace};
}

sub headerHeight() {
    return shift->{headerHeight};
}

sub headerSpace() {
    return shift->{headerSpace};
}

sub weekBarSpace() {
    return shift->{weekBarSpace};
}

sub glowRadius() {
    return shift->{glowRadius};
}

package CalendarTable;

use strict;
use warnings;
use QtCore4;
use QtGui4;
use KDECore4;
use KDEUi4;
use Plasma4;
use QtCore4::isa qw( Qt::GraphicsWidget );
use Qt::GlobalSpace qw( i18n );

use Ui_CalendarConfig;

use POSIX qw( floor );

use List::Util qw( min max );
use List::MoreUtils qw(any);

use constant {
    NoType => 0,
    Today => 1,
    Selected => 2,
    Hovered => 4,
    Holiday => 8,
    NotInCurrentMonth => 16,
    InvalidDate => 32,
    Event => 64,
    PublicHoliday => 128 };

use QtCore4::signals
    dateChanged => ['const QDate &', 'const QDate &'],
    dateChanged => ['const QDate &'],
    dateSelected => ['const QDate &'],
    dateHovered => ['const QDate &'],
    tableClicked => [];

use QtCore4::slots
    dataUpdated => ['const QString &', 'const Plasma::DataEngine::Data &'];

sub d() {
    return this->{d};
}

#Q_DECLARE_OPERATORS_FOR_FLAGS(Plasma::CalendarTable::CellTypes)

sub NEW
{
    my ($class, $date, $parent) = @_;
    if ( !defined $parent ) {
        $parent = $date;
        $date = undef;
    }
    $class->SUPER::NEW($parent);


    if ( defined $date ) {
        this->{d} = CalendarTablePrivate->new(this, $date);
    }
    else {
        this->{d} = CalendarTablePrivate->new(this);
    }
    this->setAcceptHoverEvents(1);
    this->setCacheMode(Qt::GraphicsItem::DeviceCoordinateCache());
}

sub setCalendar
{
    my ($newCalendarType) = @_;
    if ( ref $newCalendarType ) {
        my $newCalendar = $newCalendarType;
        if ($newCalendar == d->calendar) {
            return;
        }

        d->setCalendar($newCalendar);
    }
    else {
        if ($newCalendarType eq d->calendarType) {
            return;
        }

        if ($newCalendarType eq 'locale') {
            d->setCalendar(KDE::Global::locale()->calendar());
        } else {
            d->setCalendar(KDE::CalendarSystem::create($newCalendarType));
        }
    }

    # Signal out date change so any dependents will update as well
    emit dateChanged(date(), date());
    emit dateChanged(date());
}

sub calendar
{
    return d->calendar;
}

sub setDate
{
    my ($newDate) = @_;
    # New date must be valid in the current calendar system
    if (!calendar()->isValid($newDate)) {
        return;
    }

    # If new date is the same as old date don't actually need to do anything
    if ($newDate == date()) {
        return;
    }

    my $oldYear = d->selectedYear;
    my $oldMonth = d->selectedMonth;
    my $oldDate = date();

    # now change the date
    d->setDate($newDate);

    d->updateHoveredPainting(d->lastSeenMousePos);
    update(); #FIXME: we shouldn't need this update here, but something in Qt is broken (but with plasmoidviewer everything work)
    
    if ($oldYear != d->selectedYear || $oldMonth != d->selectedMonth) {
        populateHolidays();
        populateEvents();
        update();
    } else {
        # only update the old and the new areas
        my ($row, $column);
        d->rowColumnFromDate($oldDate, \$row, \$column);
        update(cellX($column) - d->glowRadius, cellY($row) - d->glowRadius,
               d->cellW + d->glowRadius * 2, d->cellH + d->glowRadius * 2);

        d->rowColumnFromDate($newDate, \$row, \$column);
        update(cellX($column) - d->glowRadius, cellY($row) - d->glowRadius,
               d->cellW + d->glowRadius * 2, d->cellH + d->glowRadius * 2);
    }

    emit dateChanged($newDate, $oldDate);
    emit dateChanged($newDate);
}

sub date
{
    return d->selectedDate;
}

sub setDataEngine
{
    my ($dataEngine) = @_;
    # JPL What happens to the old data engine, who cleans it up, do we need to delete first?
    if (!d->dataEngine || d->dataEngine != $dataEngine) {
        d->{dataEngine} = $dataEngine;
        populateHolidays();
        populateEvents();
    }
}

sub dataEngine
{
    return d->dataEngine;
}

sub setDisplayHolidays
{
    my ($showHolidays) = @_;
    if ($showHolidays) {
        if (!dataEngine()) {
            clearHolidays();
            return;
        }

        if (!holidaysRegion()) {
            setHolidaysRegion(d->defaultHolidaysRegion());
        }

        my $queryString = 'holidaysIsValidRegion:' . holidaysRegion();
        if (!dataEngine()->query($queryString)->{$queryString}->toBool()) {
            return;
        }
    }

    if (d->displayHolidays != $showHolidays) {
        d->{displayHolidays} = $showHolidays;
        populateHolidays();
    }
}

sub displayHolidays
{
    return d->displayHolidays && defined holidaysRegion() && holidaysRegion() ne '';
}

sub displayEvents
{
    return d->displayEvents;
}

sub setDisplayEvents
{
    my ($display) = @_;
    if (d->displayEvents == $display) {
        return;
    }

    d->{displayEvents} = $display;
    if ($display) {
        populateEvents();
    } else {
        if (d->dataEngine) {
            d->dataEngine->disconnectSource(d->eventsQuery, this);
        }
        d->{events} = {};
        d->{todos} = {};
        d->{journals} = {};
        d->{pimEvents} = {};
    }
}

sub setHolidaysRegion
{
    my ($region) = @_;
    my $queryString = 'holidaysIsValidRegion:' . $region;
    if (!dataEngine()->query($queryString)->{$queryString}->toBool()) {
        return;
    }

    if (!d->holidaysRegion || d->holidaysRegion ne $region) {
        d->{holidaysRegion} = $region;
        populateHolidays();
    }
}

sub holidaysRegion
{
    return d->holidaysRegion;
}

sub clearHolidays
{
    d->{holidays} = {};
}

sub addHoliday
{
    my ($date, $holidayData) = @_;
    push @{d->{holidays}{$date->toJulianDay()}}, $holidayData;
}

sub dateHasDetails
{
    my ($date) = @_;
    my $julian = $date->toJulianDay();
    return (any{ $_ == $julian } keys(%{d->holidays})) ? 1 :
           (any{ $_ == $julian } keys(%{d->events})) ? 1 :
           (any{ $_ == $julian } keys(%{d->todos})) ? 1 :
           (any{ $_ == $julian } keys(%{d->journals})) ? 1 : 0;
}

sub dateDetails
{
    my ($date) = @_;
    my $details;
    my $julian = $date->toJulianDay();

    if (any{ $_ == $julian } keys %{d->{holidays}}) {
        $details .= '<br>';

        foreach my $holidayData ( @{d->{holidays}{$julian}} ) {
            if ($holidayData->{'observanceType'}->toString() eq 'PublicHoliday') {
                $details .= ${Qt::String(i18n('<i>Holiday</i>: %1'))->arg($holidayData->{'name'}->toString())};
                $details .= '<br>';
            }
        }

        foreach my $holidayData ( @{d->{holidays}{$julian}} ) {
            if ($holidayData->{'observanceType'}->toString() eq 'Other') {
                #TODO add a type when strings not frozen
                $details .= $holidayData->{'name'}->toString();
                $details .= '<br>';
            }
        }
    }

    if (any{ $_ == $julian } keys %{d->{events}}) {
        $details .= '<br>';

        foreach my $occurrence ( @{d->{events}{$julian}} ) {
            my $eventUid = $occurrence->{'OccurrenceUid'}->toString();
            my $occStartDate = $occurrence->{'OccurrenceStartDate'}->value();
            my $occEndDate = $occurrence->{'OccurrenceEndDate'}->value();
            my $eventData = d->pimEvents->{$eventUid};

            #TODO translate this layout once strings not frozen
            my $description;
            if ($eventData->{'AllDay'}->toBool()) {
                $description = ${Qt::String('<br>%1')->arg($eventData->{'Summary'}->toString())};
            } elsif (!$occEndDate->isValid() || $occStartDate == $occEndDate) {
                $description = ${Qt::String('%1<br>%2')->arg(KDE::Global::locale()->formatTime($occStartDate->time()))
                                                 ->arg($eventData->{'Summary'}->toString())};
            } else {
                $description = ${Qt::String('%1 - %2<br>%3')->arg(KDE::Global::locale()->formatTime($occStartDate->time()))
                                                      ->arg(KDE::Global::locale()->formatTime($occEndDate->time()))
                                                      ->arg($eventData->{'Summary'}->toString())};
            }
            $details .= ${Qt::String(i18n('<i>Event</i>: %1<br>'))->arg($description)};
        }
    }

    if (any{ $_ == $julian } keys %{d->{todos}}) {
        $details .= '<br>';

        foreach my $occurrence ( @{d->{todos}{$julian}} ) {
            my $todoUid = $occurrence->{'OccurrenceUid'}->toString();
            my $occStartDate = $occurrence->{'OccurrenceStartDate'}->value();
            my $occEndDate = $occurrence->{'OccurrenceEndDate'}->value();
            my $todoData = d->pimEvents->{$todoUid};

            #TODO translate this layout once strings not frozen
            my $description;
            if ($todoData->{'AllDay'}->toBool()) {
                $description = ${Qt::String('<br>%1')->arg($todoData->{'Summary'}->toString())};
            } elsif (!$occEndDate->isValid() || $occStartDate == $occEndDate) {
                $description = ${Qt::String('%1<br>%2')->arg(KDE::Global::locale()->formatTime($occStartDate->time()))
                                                 ->arg($todoData->{'Summary'}->toString())};
            } else {
                $description = ${Qt::String('%1 - %2<br>%3')->arg(KDE::Global::locale()->formatTime($occStartDate->time()))
                                                      ->arg(KDE::Global::locale()->formatTime($occEndDate->time()))
                                                      ->arg($todoData->{'Summary'}->toString())};
            }
            #TODO add Status and Percentage Complete when strings not frozen
            $details .= ${Qt::String(i18n('<i>Todo</i>: %1<br>'))->arg($description)};
        }
    }

    return $details;
}

sub setAutomaticUpdateEnabled
{
    my ($enabled) = @_;
    d->{automaticUpdates} = $enabled;
}

sub isAutomaticUpdateEnabled
{
    return d->automaticUpdates;
}
    
sub setCurrentDate
{
    my ($date) = @_;
    d->{currentDate} = $date; 
}

sub currentDate
{
    return d->currentDate;
}

sub populateHolidays
{
    clearHolidays();

    if (!displayHolidays() || !dataEngine() || !holidaysRegion()) {
        return;
    }

    # Just fetch the days displayed in the grid
    my $queryString = 'holidays:' . holidaysRegion() . ':' . d->viewStartDate->toString(Qt::ISODate())
                          . ':' . d->viewEndDate->toString(Qt::ISODate());
    my $holidays = d->dataEngine->query($queryString)->{$queryString}->toList();

    foreach my $i ( @{$holidays} ) {
        my $holidayData = $i->toHash();
        my $holidayDate = Qt::Date::fromString($holidayData->{date}->toString(), Qt::ISODate());
        addHoliday($holidayDate, $holidayData);
    }
}

sub populateEvents
{
    d->{events} = {};
    d->{todos} = {};
    d->{journals} = {};
    d->{pimEvents} = {};

    if (!d->displayEvents || !d->dataEngine) {
        return;
    }

    # Just fetch the days displayed in the grid
    d->dataEngine->disconnectSource(d->eventsQuery, this);
    d->{eventsQuery} = 'events:' . d->viewStartDate->toString(Qt::ISODate()) . ':' . d->viewEndDate->toString(Qt::ISODate());
    d->dataEngine->connectSource(d->eventsQuery, this);
}

sub dataUpdated
{
    my ($source, $data) = @_;
    d->{events} = {};
    d->{todos} = {};
    d->{journals} = {};
    d->{pimEvents} = {};
    foreach my $v ( @{$data} ) {
        my $pimData = $v->toHash();
        my $type = $pimData->{'Type'}->toString();
        my $uid = $pimData->{'UID'}->toString();
        my $startDate = $pimData->{'StartDate'}->value()->date();

        push @{d->pimEvents->{$uid}}, $pimData;

        my $occurrenceList = $pimData->{'Occurrences'}->toList();
        foreach my $occurrence ( @{$occurrenceList} ) {
            my $occStartDate = $occurrence->toHash()->{'OccurrenceStartDate'}->value()->date();
            if ($pimData->{'EventMultiDay'}->toBool() == 1) {
                my $occEndDate = $occurrence->toHash()->{'OccurrenceEndDate'}->value()->date();
                my $multiDate = $occStartDate;
                while ($multiDate <= $occEndDate) {
                    d->insertPimOccurence($type, $multiDate, $occurrence->toHash());
                    $multiDate = $multiDate->addDays(1);
                }
            } else {
                d->insertPimOccurence($type, $occStartDate, $occurrence->toHash());
            }
        }
    }
    update();
}

sub applyConfiguration
{
    my ($cg) = @_;
    setCalendar($cg->readEntry(Qt::String('calendarType'), Qt::String('locale')));
    setHolidaysRegion($cg->readEntry(Qt::String('holidaysRegion'), Qt::String(d->defaultHolidaysRegion())));
    setDisplayHolidays($cg->readEntry(Qt::String('displayHolidays'), Qt::String('1')));
}

sub writeConfiguration
{
    my ($cg) = @_;
    $cg->writeEntry(Qt::String('calendarType'), Qt::String(d->calendarType));
    $cg->writeEntry(Qt::String('holidaysRegion'), Qt::String(d->holidaysRegion));
    $cg->writeEntry(Qt::String('displayHolidays'), Qt::String(d->displayHolidays ? '1' : '0'));
}

sub createConfigurationInterface
{
    my ($parent) = @_;
    my $calendarConfigWidget = Qt::Widget();
    d->{calendarConfigUi} = Ui_CalendarConfig->setupUi($calendarConfigWidget);
    $parent->addPage($calendarConfigWidget, i18n('Calendar'), 'view-pim-calendar');

    my $calendars = KDE::CalendarSystem::calendarSystems();
    d->calendarConfigUi->calendarComboBox->addItem( i18n('Local'), Qt::Variant( Qt::String('locale') ) );
    foreach my $cal ( sort {$a cmp $b} @{$calendars} ) {
        d->calendarConfigUi->calendarComboBox->addItem( KDE::CalendarSystem::calendarLabel( $cal ), Qt::Variant( Qt::String($cal) ) );
    }
    d->calendarConfigUi->calendarComboBox->setCurrentIndex( d->calendarConfigUi->calendarComboBox->findData( Qt::Variant( Qt::String(d->calendarType) ) ) );

    my $regions = dataEngine()->query('holidaysRegions');
    #Qt::Map<Qt::String, Qt::String> regionsMap;
    my $regionsMap = {};
    foreach my $i (keys %{$regions}) {
        my $regionData = $regions->{$i}->toHash();
        my $name = $regionData->{'name'}->toString();
        my $languageName = KDE::Global::locale()->languageCodeToName($regionData->{'languageCode'}->toString());
        my $label;
        if (!$languageName) {
            $label = $name;
        } else {
            # Need to get permission to break string freeze, in the meantime don't translate!
            #label = i18nc('Holday region, region language', '%1 (%2)', name, languageName);
            $label = ${Qt::String('%1 (%2)')->arg($name)->arg($languageName)};
        }
        $regionsMap->{$label} = $i;
    }

    d->calendarConfigUi->regionComboBox->addItem(i18n('Do not show holidays'), Qt::Variant(Qt::String('0')));
    foreach my $j (keys %{$regionsMap}) {
        d->calendarConfigUi->regionComboBox->addItem($j, Qt::Variant(Qt::String($regionsMap->{$j})));
    }
    d->calendarConfigUi->regionComboBox->setCurrentIndex( d->calendarConfigUi->regionComboBox->findData( Qt::Variant( Qt::String(d->holidaysRegion) ) ) );
}

sub applyConfigurationInterface
{
    setCalendar(d->calendarConfigUi->calendarComboBox->itemData(d->calendarConfigUi->calendarComboBox->currentIndex())->toString());
    setDisplayHolidays(d->calendarConfigUi->regionComboBox->itemData(d->calendarConfigUi->regionComboBox->currentIndex())->toString() ? 1 : 0);
    setHolidaysRegion(d->calendarConfigUi->regionComboBox->itemData(d->calendarConfigUi->regionComboBox->currentIndex())->toString());
}

sub configAccepted
{
    my ($cg) = @_;
    applyConfigurationInterface();
    writeConfiguration($cg);
}

#Returns the x co-ordinate for drawing the day cell on the widget given the weekday column
#Note weekdayColumn is 0 to (daysInWeek -1) and is not a real weekDay number (i->e-> NOT Monday=1)->
#Adjusts automatically for RTL mode, so don't use to calculate absolute positions
sub cellX
{
    my ($weekdayColumn) = @_;
    return d->columnToX(d->adjustColumn($weekdayColumn));
}

#Returns the y co-ordinate for drawing the day cell on the widget given the weekRow
#weekRow is 0 to ($DISPLAYED_WEEKS - 1)
sub cellY
{
    my ($weekRow) = @_;
    return d->rowToY($weekRow);
}

sub wheelEvent
{
    my ($event) = @_;
    if ($event->delta() < 0) {
        setDate(calendar()->addMonths(date(), 1));
    } elsif ($event->delta() > 0) {
        setDate(calendar()->addMonths(date(), -1));
    }
}

sub mousePressEvent
{
    my ($event) = @_;
    d->{lastSeenMousePos} = $event->pos();

    $event->accept();
    my $date = d->dateFromPoint($event->pos());
    setDate($date);
    emit dateSelected($date);
}

sub mouseMoveEvent
{
    my ($event) = @_;
    mousePressEvent($event);
}

sub mouseReleaseEvent
{
    my ($event) = @_;

    d->{lastSeenMousePos} = $event->pos();

    emit tableClicked();
}

sub hoverMoveEvent
{
    my ($event) = @_;
    d->{lastSeenMousePos} = $event->pos();

    d->updateHoveredPainting($event->pos());
}

sub resizeEvent
{
    my ($event) = @_;

    my $r = contentsRect();
    my $numCols = d->daysInWeek + 1;
    my $rectSizeH = sprintf '%d', ($r->height() / (DISPLAYED_WEEKS + 1));
    my $rectSizeW = sprintf '%d', ($r->width() / $numCols);

    #Using integers to help to keep things aligned to the grid
    #kDebug() << r->width() << rectSize;
    d->{cellSpace} = max(1, min(4, min($rectSizeH, $rectSizeW) / 20));
    d->{headerSpace} = d->cellSpace * 2;
    d->{weekBarSpace} = d->cellSpace * 2 + 1;
    d->{cellH} = $rectSizeH - d->cellSpace;
    d->{cellW} = $rectSizeW - d->cellSpace;
    d->{glowRadius} = d->cellW * .1;
    d->{headerHeight} = sprintf '%d', (d->cellH / 1.5);
    d->{centeringSpace} = max(0, int(($r->width() - ($rectSizeW * $numCols) - (d->cellSpace * ($numCols -1))) / 2));
}

sub paintCell
{
    my ($p, $cell, $weekRow, $weekdayColumn, $type, $cellDate) = @_;

    my $cellSuffix = $type & NotInCurrentMonth ? 'inactive' : 'active';
    my $cellArea = Qt::RectF(cellX($weekdayColumn), cellY($weekRow), d->cellW, d->cellH);

    d->svg->paint($p, $cellArea, $cellSuffix); # draw background

    my $numberColor = Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor());
    if ($type & NotInCurrentMonth || $type & InvalidDate) {
        $p->setOpacity(d->opacity);
    }

    $p->setPen(Qt::Pen($numberColor));
    my $font = Plasma::Theme::defaultTheme()->font(Plasma::Theme::DefaultFont());
    if ($type & Event) {
        $font->setBold(1);
    }
    $font->setPixelSize($cellArea->height() * 0.7);
    $p->setFont($font);
    if (!($type & InvalidDate)) {
        $p->drawText($cellArea, Qt::AlignCenter(), calendar()->dayString($cellDate, KDE::CalendarSystem::ShortFormat()), $cellArea); #draw number
    }
    $p->setOpacity(1.0);
}

sub paintBorder
{
    my ($p, $cell, $weekRow, $weekdayColumn, $type, $cellDate) = @_;

    if ($type & Hovered) {
        d->svg->paint($p, Qt::RectF(cellX($weekdayColumn), cellY($weekRow), d->cellW, d->cellH), 'hoverHighlight');
    }

    my $elementId;

    if ($type & Today) {
        $elementId = 'today';
    } elsif ($type & Selected) {
        $elementId = 'selected';
    } elsif ($type & PublicHoliday) {
        $elementId = 'red';
    } elsif ($type & Holiday) {
        $elementId = 'green';
    } else {
        return;
    }

    d->svg->paint($p, Qt::RectF(cellX($weekdayColumn) - 1, cellY($weekRow) - 1, d->cellW + 1, d->cellH + 2), $elementId);
}

sub paint
{
    my ($p, $option, $widget) = @_;

    # Draw weeks numbers column and day header
    my $r = boundingRect();
    d->svg->paint($p, Qt::RectF($r->x() + d->centeringSpace, cellY(0), d->cellW,
                  cellY(DISPLAYED_WEEKS) - cellY(0) - d->cellSpace),  'weeksColumn');
    d->svg->paint($p, Qt::RectF($r->x() + d->centeringSpace, $r->y(),
                  cellX(d->daysInWeek) - $r->x() - d->cellSpace - d->centeringSpace, d->headerHeight), 'weekDayHeader');

    my @borders;
    my @hovers;
    if (d->automaticUpdates){
        d->{currentDate} = Qt::Date::currentDate();
    }

    #weekRow and weekDaycolumn of table are 0 indexed and are not equivalent to weekday or week
    #numbers->  In LTR mode we count/paint row and column from top-left corner, in RTL mode we
    #count/paint from top-right corner, but we don't need to know as cellX() calculates the actual
    #painting position for us depending on the mode->
    for (my $weekRow = 0; $weekRow < DISPLAYED_WEEKS; $weekRow++) {
        for (my $weekdayColumn = 0; $weekdayColumn < d->daysInWeek; $weekdayColumn++) {

            my $x = cellX($weekdayColumn);
            my $y = cellY($weekRow);

            my $cellRect = Qt::RectF($x, $y, d->cellW, d->cellH);
            if (!$cellRect->intersects($option->exposedRect)) {
                next;
            }

            my $cellDate = d->dateFromRowColumn($weekRow, $weekdayColumn);
            my $type = CalendarTable::NoType;
            # get cell info
            my $cellDay = calendar()->day($cellDate);
            my $julian = $cellDate->toJulianDay();

            # check what kind of cell we are
            if (calendar()->month($cellDate) != d->selectedMonth) {
                $type |= CalendarTable::NotInCurrentMonth;
            }

            if (!calendar()->isValid($cellDate)) {
                $type |= CalendarTable::InvalidDate;
            }

            if ($cellDate == d->currentDate) {
                $type |= CalendarTable::Today;
            }

            if ($cellDate == date()) {
                $type |= CalendarTable::Selected;
            }

            foreach my $holidayData ( @{d->holidays->{$julian}} ) {
                if ($holidayData->{'observanceType'}->toString() eq 'PublicHoliday') {
                    $type |= CalendarTable::PublicHoliday();
                } else {
                    $type |= CalendarTable::Holiday();
                }
            }

            if ( any{ $_ == $julian } ( keys %{d->{events}} ) ? 1 :
                any{ $_ == $julian } ( keys %{d->{todos}} ) ? 1 : 0 ) {
                $type |= CalendarTable::Event;
            }

            if ($type != CalendarTable::NoType && $type != CalendarTable::NotInCurrentMonth) {
                push @borders, CalendarCellBorder->new($cellDay, $weekRow, $weekdayColumn, $type, $cellDate);
            }

            if ($weekRow == d->hoverWeekRow && $weekdayColumn == d->hoverWeekdayColumn) {
                $type |= CalendarTable::Hovered;
                push @hovers, CalendarCellBorder->new($cellDay, $weekRow, $weekdayColumn, $type, $cellDate);
            }

            paintCell($p, $cellDay, $weekRow, $weekdayColumn, $type, $cellDate);

            # FIXME: modify svg to allow for a wider week number cell
            # a temporary workaround is to paint only one week number (weekString) when the cell is small
            # and both week numbers (accurateWeekString) when there is enough room
            if ($weekdayColumn == 0) {
                my $cellRect = Qt::RectF($r->x() + d->centeringSpace, $y, d->cellW, d->cellH);
                $p->setPen(Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor()));
                my $font = Plasma::Theme::defaultTheme()->font(Plasma::Theme::DefaultFont());
                $font->setPixelSize($cellRect->height() * 0.7);
                $p->setFont($font);
                $p->setOpacity(d->opacity);
                my $weekString;
                my $accurateWeekString;
                if (calendar()->isValid($cellDate)) {
                    $weekString = calendar()->weekNumberString($cellDate);
                    $accurateWeekString = $weekString;
                    if (calendar()->dayOfWeek($cellDate) != Qt::Monday()) {
                        my $nextWeekDate = calendar()->addDays($cellDate, d->daysInWeek);
                        if (calendar()->isValid($nextWeekDate)) {
                            if (layoutDirection() == Qt::RightToLeft()) {
                                $accurateWeekString = calendar()->weekNumberString($nextWeekDate) . '/' . $accurateWeekString;
                            } else {
                                $accurateWeekString .= '/' . calendar()->weekNumberString($nextWeekDate);
                            }
                        }
                        # ensure that weekString is the week number that has the most amout of days in the row
                        my $middleWeekDate = calendar()->addDays($cellDate, floor(d->daysInWeek / 2));
                        if (calendar()->isValid($middleWeekDate)) {
                            my $middleWeekString = calendar()->weekNumberString($middleWeekDate);
                            if ($weekString ne $middleWeekString) {
                                $weekString = $middleWeekString;
                            }
                        }
                    }
                }
                my $fontMetrics = Qt::FontMetrics($font);
                if ($fontMetrics->width($accurateWeekString) > d->cellW) {
                    $p->drawText($cellRect, Qt::AlignCenter(), $weekString); #draw number
                } else {
                    $p->drawText($cellRect, Qt::AlignCenter(), $accurateWeekString); #draw number
                }
                $p->setOpacity(1.0);
            }
        }
    }

    # Draw days
    if ($option->exposedRect->intersects(Qt::RectF($r->x(), $r->y(), $r->width(), d->headerHeight))) {
        $p->setPen(Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor()));
        my $weekStartDay = calendar()->weekStartDay();
        for (my $i = 0; $i < d->daysInWeek; $i++){
            my $weekDay = (($i + $weekStartDay - 1) % d->daysInWeek) + 1;
            my $dayName = calendar()->weekDayName($weekDay, KDE::CalendarSystem::ShortDayName());
            my $font = Plasma::Theme::defaultTheme()->font(Plasma::Theme::DefaultFont());
            $font->setPixelSize(d->headerHeight * 0.9);
            $p->setFont($font);
            $p->drawText(Qt::RectF(cellX($i), $r->y(), d->cellW, d->headerHeight),
                        Qt::AlignCenter() | Qt::AlignVCenter(), $dayName);
        }
    }

    # Draw hovers
    foreach my $border ( @hovers ) {
        $p->save();
        paintBorder($p, $border->cell, $border->week, $border->weekDay, $border->type, $border->date);
        $p->restore();
    }

    # Draw borders
    foreach my $border ( @borders ) {
        $p->save();
        paintBorder($p, $border->cell, $border->week, $border->weekDay, $border->type, $border->date);
        $p->restore();
    }
}

1;
