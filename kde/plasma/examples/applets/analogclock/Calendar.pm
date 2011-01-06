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

package CalendarPrivate;

use strict;
use warnings;
use QtCore4;
use QtGui4;
use KDECore4;
use KDEUi4;
use Plasma4;

sub new {
    my ($class) = @_;
    my $self = bless {
        back => undef,
        spacer0 => undef,
        month => undef,
        yearSpinBox => undef,
        year => undef,
        spacer1 => undef,
        forward => undef,
        calendarTable => undef,
        dateText => undef,
        jumpToday => undef,
        monthMenu => undef,
        weekSpinBox => undef
    };

    return $self;
}

sub back() {
    return shift->{back};
}

sub spacer0() {
    return shift->{spacer0};
}

sub month() {
    return shift->{month};
}

sub yearSpinBox() {
    return shift->{yearSpinBox};
}

sub year() {
    return shift->{year};
}

sub spacer1() {
    return shift->{spacer1};
}

sub forward() {
    return shift->{forward};
}

sub calendarTable() {
    return shift->{calendarTable};
}

sub dateText() {
    return shift->{dateText};
}

sub jumpToday() {
    return shift->{jumpToday};
}

sub monthMenu() {
    return shift->{monthMenu};
}

sub weekSpinBox() {
    return shift->{weekSpinBox};
}

package Calendar;

use strict;
use warnings;
use QtCore4;
use QtGui4;
use KDECore4;
use KDEUi4;
use Plasma4;

use CalendarTable;

use QtCore4::isa qw( Qt::GraphicsWidget );
use QtCore4::signals
    dateChanged => ['const QDate &', 'const QDate &'],
    dateChanged => ['const QDate &'],
    dateHovered => ['const QDate &'];

use QtCore4::slots
    prevMonth => [],
    nextMonth => [],
    prevYear => [],
    nextYear => [],
    dateUpdated => ['const QDate &'],
    showTip => ['const QDate &'],
    goToToday => [],
    goToWeek => ['int'],
    manualDateChange => [],
    monthsPopup => [],
    monthTriggered => [],
    showYearSpinBox => [],
    hideYearSpinBox => [];

sub d() {
    return this->{d};
}

#include <kephal/screens.h>

use WheelyToolButton;

my $s_yearWidgetIndex = 3;

sub NEW
{
    my ($class, $dateCalendarTable, $parent) = @_;
    my ($date, $calendarTable);
    if (!defined $parent) {
        $parent = $dateCalendarTable;
        $dateCalendarTable = undef;
        $class->SUPER::NEW($parent);
        this->{d} = CalendarPrivate->new();
        this->init(CalendarTable($date, this));
        this->setCacheMode(Qt::GraphicsItem::DeviceCoordinateCache());
    }
    elsif ($dateCalendarTable->isa('Qt::Date')) {
        $date = $dateCalendarTable;
        $dateCalendarTable = undef;
        $class->SUPER::NEW($parent);
        this->{d} = CalendarPrivate->new();
        this->init(CalendarTable(this));
        this->setCacheMode(Qt::GraphicsItem::DeviceCoordinateCache());
    }
    elsif ($dateCalendarTable->isa('CalendarTable')) {
        $calendarTable = $dateCalendarTable;
        $dateCalendarTable = undef;
        $class->SUPER::NEW($parent);
        this->{d} = CalendarPrivate->new();
        this->init($calendarTable ? $calendarTable : CalendarTable(this));
    }
}

sub init
{
    my ($calendarTable) = @_;
    my $layout = Qt::GraphicsLinearLayout(Qt::Vertical(), this);
    my $hLayout = Qt::GraphicsLinearLayout($layout);
    my $layoutTools = Qt::GraphicsLinearLayout($layout);

    d->{calendarTable} = $calendarTable;
    d->calendarTable->setSizePolicy(Qt::SizePolicy::Expanding(), Qt::SizePolicy::Expanding());
    this->connect(d->calendarTable, SIGNAL 'dateChanged(const QDate &)', this, SLOT 'dateUpdated(const QDate &)');
    this->connect(d->calendarTable, SIGNAL 'dateHovered(const QDate &)', this, SIGNAL 'dateHovered(const QDate &)');
    this->connect(d->calendarTable, SIGNAL 'dateSelected(const QDate &)', this, SLOT 'showTip(const QDate &)');
    this->connect(this, SIGNAL 'dateHovered(const QDate &)', this, SLOT 'showTip(const QDate &)');

    d->{back} = Plasma::ToolButton(this);
    d->back->setText('<');
    d->back->setSizePolicy(Qt::SizePolicy::Fixed(), Qt::SizePolicy::Fixed());
    this->connect(d->back, SIGNAL 'clicked()', this, SLOT 'prevMonth()');
    $hLayout->addItem(d->back);

    $hLayout->addStretch();

    d->{month} = WheelyToolButton(this);
    d->month->setText(calendar()->monthName(calendar()->month(date()), calendar()->year(date())));
    d->month->setSizePolicy(Qt::SizePolicy::MinimumExpanding(), Qt::SizePolicy::Fixed());
    d->{monthMenu} = Qt::Menu();
    d->month->nativeWidget()->setMenu(d->monthMenu);
    this->connect(d->month, SIGNAL 'clicked()', this, SLOT 'monthsPopup()');
    this->connect(d->month, SIGNAL 'wheelUp()', this, SLOT 'prevMonth()');
    this->connect(d->month, SIGNAL 'wheelDown()', this, SLOT 'nextMonth()');
    $hLayout->addItem(d->month);

    d->{year} = WheelyToolButton(this);
    d->year->setText(calendar()->yearString(date()));
    d->year->setSizePolicy(Qt::SizePolicy::Fixed(), Qt::SizePolicy::Fixed());
    this->connect(d->year, SIGNAL 'wheelUp()', this, SLOT 'prevYear()');
    this->connect(d->year, SIGNAL 'wheelDown()', this, SLOT 'nextYear()');
    this->connect(d->year, SIGNAL 'clicked()', this, SLOT 'showYearSpinBox()');
    $hLayout->addItem(d->year);

    d->{yearSpinBox} = Plasma::SpinBox(this);
    d->yearSpinBox->setRange(calendar()->year(calendar()->earliestValidDate()), calendar()->year(calendar()->latestValidDate()));
    d->yearSpinBox->setValue(calendar()->year(date()));
    d->yearSpinBox->hide();
    this->connect(d->yearSpinBox->nativeWidget(), SIGNAL 'editingFinished()', this, SLOT 'hideYearSpinBox()');

    $hLayout->addStretch();

    d->{forward} = Plasma::ToolButton(this);
    d->forward->setText('>');
    d->forward->setSizePolicy(Qt::SizePolicy::Fixed(), Qt::SizePolicy::Fixed());
    this->connect(d->forward, SIGNAL 'clicked()', this, SLOT 'nextMonth()');
    $hLayout->addItem(d->forward);

    d->{jumpToday} = Plasma::ToolButton(this);
    d->jumpToday->nativeWidget()->setIcon(KDE::Icon('go-jump-today'));
    d->jumpToday->nativeWidget()->setMinimumWidth(25);
    this->connect(d->jumpToday, SIGNAL 'clicked()', this, SLOT 'goToToday()');
    $layoutTools->addItem(d->jumpToday);
    $layoutTools->addStretch();

    d->{dateText} = Plasma::LineEdit(this);
    d->dateText->setText(calendar()->formatDate(date(),  KDE::Locale::ShortDate()));
    this->connect(d->dateText->nativeWidget(), SIGNAL 'returnPressed()', this, SLOT 'manualDateChange()');
    $layoutTools->addItem(d->dateText);
    $layoutTools->addStretch();

    d->{weekSpinBox} = Plasma::SpinBox(this);
    d->weekSpinBox->setMinimum(1);
    d->weekSpinBox->setMaximum(calendar()->weeksInYear(date()));
    this->connect(d->weekSpinBox, SIGNAL 'valueChanged(int)', this, SLOT 'goToWeek(int)');
    $layoutTools->addItem(d->weekSpinBox);

    $layout->addItem($hLayout);
    $layout->addItem(d->calendarTable);
    $layout->addItem($layoutTools);

    dateUpdated(date());
}

sub calendarTable
{
    return d->calendarTable;
}

sub setCalendar
{
    my ($newCalendarType) = @_;
    calendarTable()->setCalendar($newCalendarType);
    d->weekSpinBox->setMaximum(calendar()->weeksInYear(date()));
    d->yearSpinBox->setRange(calendar()->year(calendar()->earliestValidDate()),
                             calendar()->year(calendar()->latestValidDate()));
    refreshWidgets();
}

sub calendar
{
    return calendarTable()->calendar();
}

sub setDate
{
    my ($toDate) = @_;
    d->calendarTable->setDate($toDate);

    # If set date failed force refresh of nav widgets to reset any user entry
    # If set date successful refresh will be triggered through signal/slot
    if (d->calendarTable->date() != $toDate) {
        refreshWidgets();
    }

    d->weekSpinBox->setMaximum(calendar()->weeksInYear(date()));
}

sub date
{
    return calendarTable()->date();
}

sub setDataEngine
{
    my ($dataEngine) = @_;
    calendarTable()->setDataEngine($dataEngine);
}

sub dataEngine
{
    return calendarTable()->dataEngine();
}

sub setDisplayHolidays
{
    my ($showHolidays) = @_;
    calendarTable()->setDisplayHolidays($showHolidays);
}

sub displayHolidays
{
    return calendarTable()->displayHolidays();
}

sub setHolidaysRegion
{
    my ($region) = @_;
    calendarTable()->setHolidaysRegion($region);
}

sub holidaysRegion
{
    return calendarTable()->holidaysRegion();
}

sub dateHasDetails
{
    my ($date) = @_;
    return calendarTable()->dateHasDetails($date);
}

sub dateDetails
{
    my ($date) = @_;
    return calendarTable()->dateDetails($date);
}

sub setAutomaticUpdateEnabled
{
    my ($automatic) = @_;
    calendarTable()->setAutomaticUpdateEnabled($automatic);
}

sub isAutomaticUpdateEnabled
{
    return calendarTable()->isAutomaticUpdateEnabled();
}

sub setCurrentDate
{
    my ($date) = @_;
    calendarTable()->setCurrentDate($date);  
}

sub currentDate
{
    return calendarTable()->currentDate();
}

sub applyConfiguration
{
    my ($cg) = @_;
    calendarTable()->applyConfiguration($cg);
}

sub writeConfiguration
{
    my ($cg) = @_;
    calendarTable()->writeConfiguration($cg);
}

sub createConfigurationInterface
{
    my ($parent) = @_;
    calendarTable()->createConfigurationInterface($parent);
}

sub applyConfigurationInterface
{
    calendarTable()->applyConfigurationInterface();
}

sub configAccepted
{
    my ($cg) = @_;
    calendarTable()->configAccepted($cg);
}

sub manualDateChange
{
    setDate(calendar()->readDate(sender()->text()));
}

sub goToToday
{
    setDate(Qt::Date::currentDate());
}

sub dateUpdated
{
    #  Ignore the date passed in, only ever show the date to match the CalendarTable
    refreshWidgets();
    emit dateChanged(date());
}

sub showTip
{
    my ($date) = @_;
    my $item = parentWidget();
    if (!$item) {
        $item = this;
    }

    if (dateHasDetails($date)) {
        my $details = dateDetails($date);
        my $content = Plasma::ToolTipContent(calendar()->formatDate($date),
                                       $details,
                                       KDE::Icon('view-pim-calendar'));
        $content->setAutohide(0);
        Plasma::ToolTipManager::self()->setContent($item, $content);
        Plasma::ToolTipManager::self()->show($item);
    } else {
        if (Plasma::ToolTipManager::self()->isVisible($item)) {
            Plasma::ToolTipManager::self()->hide($item);
        }
        Plasma::ToolTipManager::self()->setContent($item, Plasma::ToolTipContent());
    }
}

#  Update the nav widgets to show the current date in the CalendarTable
sub refreshWidgets()
{
    d->month->setText(calendar()->monthName(calendar()->month(date()), calendar()->year(date())));
    d->month->setMinimumSize(Qt::SizeF(d->month->widget()->sizeHint()));
    d->year->setText(calendar()->yearString(date()));
    d->dateText->setText(calendar()->formatDate(date(),  KDE::Locale::ShortDate()));

    #  Block the signals to prevent changing the date again
    d->weekSpinBox->blockSignals(1);
    d->weekSpinBox->setValue(calendar()->weekNumber(date()));
    d->weekSpinBox->blockSignals(0);
}

sub prevMonth
{
    setDate(calendar()->addMonths(date(), -1));
}

sub nextMonth
{
    setDate(calendar()->addMonths(date(), 1));
}

sub prevYear
{
    setDate(calendar()->addYears(date(), -1));
}

sub nextYear
{
    setDate(calendar()->addYears(date(), 1));
}

sub monthsPopup
{
    d->monthMenu->clear();
    my $year = calendar()->year(date());
    my $monthsInYear = calendar()->monthsInYear(date());

    for (my $i = 1; $i <= $monthsInYear; $i++){
        my $tmpAction = Qt::Action(calendar()->monthName($i, $year), d->monthMenu);
        $tmpAction->setProperty('month', Qt::Variant(Qt::Int($i)));
        this->connect($tmpAction, SIGNAL 'triggered()', this, SLOT 'monthTriggered()');
        d->monthMenu->addAction($tmpAction);
    }

    my $view = Plasma::viewFor(d->month);
    if ($view) {
        d->monthMenu->adjustSize();
        my $x = d->month->sceneBoundingRect()->center()->x() - d->monthMenu->width() / 2;
        my $pos = Qt::PointF($x, d->month->sceneBoundingRect()->bottom());
        $pos = $view->mapToGlobal($view->mapFromScene($pos));
        # XXX
        #my $r = Kephal::ScreenUtils::screenGeometry(Kephal::ScreenUtils::screenId(view->geometry().center()));
        #if (pos.y() + d->monthMenu->height() > r.bottom()) {
            #pos = Qt::Point(x, d->month->sceneBoundingRect().top() - d->monthMenu->height());
            #pos = view->mapToGlobal(view->mapFromScene(pos));
        #}
        d->monthMenu->popup($pos);
    } else {
        d->monthMenu->popup(Qt::Cursor::pos());
    }
}

sub monthTriggered
{
    my $action = sender();

    if ($action->isa('Qt::Action') && $action->property('month')->type() == Qt::Variant::Int()) {
        my $newMonth = $action->property('month')->toInt();
        my $currMonth = calendar()->month(date());
        setDate(calendar()->addMonths(date(), $newMonth - $currMonth));
    }
}

sub goToWeek
{
    my ($newWeek) = @_;
    my $currWeek = calendar()->weekNumber(date());
    my $daysInWeek = calendar()->daysInWeek(date());

    setDate(calendar()->addDays(date(), ($newWeek - $currWeek) * $daysInWeek));
}

sub showYearSpinBox
{
    my $hLayout = d->year->parentLayoutItem();
    CAST $hLayout, 'Qt::GraphicsLinearLayout';

    d->year->hide();
    $hLayout->removeItem(d->year);
    d->yearSpinBox->setValue(calendar()->year(date()));
    d->yearSpinBox->setMinimumWidth(d->yearSpinBox->preferredSize()->width());
    $hLayout->insertItem($s_yearWidgetIndex, d->yearSpinBox);
    $hLayout->activate();
    d->yearSpinBox->show();
    d->yearSpinBox->nativeWidget()->setFocus(Qt::MouseFocusReason());
}

sub hideYearSpinBox
{
    my $hLayout = d->yearSpinBox->parentLayoutItem();
    CAST $hLayout, 'Qt::GraphicsLinearLayout';
    $hLayout->removeItem(d->yearSpinBox);
    $hLayout->insertItem($s_yearWidgetIndex, d->year);
    d->yearSpinBox->hide();

    my $newYear = d->yearSpinBox->value();
    my $currYear = calendar()->year(date());
    setDate(calendar()->addYears(date(), $newYear - $currYear));
    d->year->show();
}

1;
