#/***************************************************************************
#*   Copyright (C) 2007-2008 by Riccardo Iaconelli <riccardo@kde.org>      *
#*   Copyright (C) 2007-2008 by Sebastian Kuegler <sebas@kde.org>          *
#*   Copyright (C) 2009 by John Layt <john@layt.net>                       *
#*   Perl translation by Chris Burel <chrisburel@gmail.com>                *
#*                                                                         *
#*   This program is free software; you can redistribute it and/or modify  *
#*   it under the terms of the GNU General Public License as published by  *
#*   the Free Software Foundation; either version 2 of the License, or     *
#*   (at your option) any later version.                                   *
#*                                                                         *
#*   This program is distributed in the hope that it will be useful,       *
#*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
#*   GNU General Public License for more details.                          *
#*                                                                         *
#*   You should have received a copy of the GNU General Public License     *
#*   along with this program; if not, write to the                         *
#*   Free Software Foundation, Inc.,                                       *
#*   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
#***************************************************************************/

package ClockApplet::Private;

use strict;
use warnings;

use KDEUi4;
use Plasma4;
use Ui_GeneralConfig;
use Ui_TimezonesConfig;
use Qt4::GlobalSpace qw( i18n );

sub new {
    my ( $class, $clockapplet ) = @_;
    my $self = bless {
        q => $clockapplet,
        timezone => ClockApplet::localTimezoneUntranslated(),
        clipboardMenu => 0,
        adjustSystemTimeAction => 0,
        label => 0,
        calendarWidget => 0,
        forceTzDisplay => 0,
    }, $class;
    return $self;
}

=begin

    ClockApplet *q;
    Ui::timezonesConfig ui;
    Ui::generalConfig generalUi;
    Qt4::String timezone;
    Qt4::String defaultTimezone;
    Qt4::Point clicked;
    Qt4::StringList selectedTimezones;
    KDE::Menu *clipboardMenu;
    Qt4::Action *adjustSystemTimeAction;
    Qt4::String prettyTimezone;
    Plasma::Label *label;
    Plasma::Calendar *calendarWidget;
    int announceInterval;
    int prevHour;
    int prevMinute;
    bool forceTzDisplay : 1;

=cut

sub addTzToTipText
{
    my ($self, $subText, $tz) = @_;
    my $data = $self->{q}->dataEngine('time')->query($$tz);

    if ($$tz eq 'UTC')  {
        $$subText .= '<br><b>UTC</b>&nbsp;';
    } else {
        my $tzCity = $data->{'Timezone City'}->toString();
        $tzCity =~ s/_/&nbsp;/g;
        $$subText .= '<br><b>' .
            $tzCity .
            '</b> ';
    }

    my $formatTime = KDE::Global::locale()->formatTime($data->{'Time'}->toTime(), 0);
    $formatTime =~ s/ /&nbsp;/g;
    #my $formatDate = $self->{q}->calendar()->formatDate($data->{'Date'}->toDate());
    #$formatDate =~ s/ /&nbsp;/g;
    $$subText .= $formatTime .
           ',&nbsp;';
           #$formatDate;
}

sub createCalendarExtender
{
    my ($self) = @_;
    #if (!$self->{q}->extender()->hasItem('calendar')) {
        #my $eItem = Plasma::ExtenderItem($self->{q}->extender());
        #$eItem->setName('calendar');
        #$self->{q}->initExtenderItem($eItem);
    #}
}

sub createToday
{
    my ($self) = @_;
    #my $tmpStr = 'isHoliday:' . $self->{calendarWidget}->holidaysRegion() . ':' . Qt4::Date::currentDate().toString(Qt4::ISODate());
    #my $isHoliday = $self->{q}->dataEngine('calendar')->query($tmpStr)->value($tmpStr)->toBool();
#
    #my $todayExtender = $self->{q}->extender()->item('today');
#
    #if (!$todayExtender && $isHoliday) {
        #my $eItem = Plasma::ExtenderItem($self->{q}->extender());
        #$eItem->setName('today');
        #$self->{q}->initExtenderItem($eItem);

    #} elsif ($todayExtender && !$isHoliday) {
        #$todayExtender->destroy();
    #}
}

sub createDateExtender
{
    my ($self, $date) = @_;
    my $eItem = Plasma::ExtenderItem($self->{q}->extender());
    $eItem->setName('dateExtender-' . $date->toString(Qt4::ISODate()));
    $self->{q}->initExtenderItem($eItem);
}

sub destroyDateExtenders
{
    my ($self) = @_;
    my $extenders = $self->{q}->extender()->items();
    foreach my $eItem ( @{$extenders} ) {
        if ( $eItem->name() =~ m/^dateExtender-/ && !$eItem->isDetached()){
            $eItem->destroy();
        }
    }
}

sub setPrettyTimezone
{
    my ($self) = @_;
    my $timezonetranslated = i18n($self->{timezone});
    my $prettyTimezone;
    if ($self->{timezone} eq 'UTC')  {
        $prettyTimezone = $timezonetranslated;
    } elsif (!$self->{q}->isLocalTimezone()) {
        my @tzParts = split /\//, $timezonetranslated;
        if (scalar @tzParts == 1) {
            $prettyTimezone = $timezonetranslated;
        } else {
            $prettyTimezone = $tzParts[-1];
        }
    } else {
        $prettyTimezone = $self->{q}->localTimezone();
    }

    $prettyTimezone =~ s/_/ /g;
    $self->{prettyTimezone} = $prettyTimezone; 
}

package ClockApplet;

use strict;
use warnings;

use QtCore4;
use KDEUi4;
use Plasma4;
use Qt4::isa qw( Plasma::PopupApplet );
use Qt4::GlobalSpace qw( i18n i18nc );

use Qt4::slots
    toolTipAboutToShow => [],
    toolTipHidden => [],
    setCurrentTimezone => ['const Qt4::String &'],
    configAccepted => [],
    updateClockDefaultsTo => [],
    dateChanged => ['const Qt4::Date &'],
    speakTime => ['const Qt4::Time &'],
    launchTimeControlPanel => [],
    updateClipboardMenu => [],
    copyToClipboard => ['Qt4::Action*'],
    createCalendarExtender => [],
    createToday => [];

sub NEW {
    my ( $class, $parent, $args ) = @_;
    $class->SUPER::NEW( $parent, $args );
    this->{d} = ClockApplet::Private->new(this);
    this->setPopupIcon(Qt4::Icon());
    this->setPassivePopup(1);
}

#ClockApplet::~ClockApplet()
#{
    #delete d->clipboardMenu;
    #delete d;
#}

sub speakTime
{
    my ($time) = @_;
    print "SpeakTime function not implemented\n";
    return;

=begin

    if (!d->announceInterval) {
        return;
    }

    if (time.minute() != d->prevMinute && (time.minute() % d->announceInterval) == 0) {
        d->prevHour = time.hour();
        d->prevMinute = time.minute();

        # If KDE::TTSD not running, start it.
        if (!Qt4::DBusConnection::sessionBus().interface()->isServiceRegistered('org.kde.kttsd')) {
            Qt4::String error;
            if (KDE::ToolInvocation::startServiceByDesktopName('kttsd', Qt4::StringList(), &error)) {
                KDE::MessageBox::error(0, i18n( 'Starting KDE::TTSD Failed'), error );
                return;
            }
        }

        Qt4::DBusInterface ktts('org.kde.kttsd', '/KDE::Speech', 'org.kde.KDE::Speech');
        ktts.asyncCall('setApplicationName', 'plasmaclock');
        Qt4::String text;
        if (time.minute() == 0) {
            if (KDE::Global::locale()->use12Clock()) {
                if (time.hour() < 12) {
                    text = i18ncp('Text sent to the text to speech service '
                                     'when minutes==0 and it is AM',
                                 'It is 1 o clock a m',
                                 'It is %1 o clock a m',
                                 time.hour());
                } else {
                    text = i18ncp('Text sent to the text to speech service '
                                     'when minutes==0 and it is PM',
                                 'It is 1 o clock p m',
                                 'It is %1 o clock p m',
                                 time.hour()-12);
                }
            } else {
                text = i18ncp('Text sent to the text to speech service '
                                 'when minutes==0 and it is the 24 hour clock',
                                 'It is 1 o clock',
                                 'It is %1 o clock',
                                 time.hour());
            }
        } else {
            if (KDE::Global::locale()->use12Clock()) {
                if (time.hour() < 12) {
                    text = i18nc('Text sent to the text to speech service for AM',
                                'It is %1:%2 a m',
                                time.hour(),
                                time.minute());
                } else {
                    text = i18nc('Text sent to the text to speech service for PM',
                                'It is %1:%2 p m',
                                time.hour()-12,
                                time.minute());
                }
            } else {
                text = i18nc('Text sent to the text to speech service for the 24 hour clock',
                                'It is %1:%2',
                                time.hour(),
                                time.minute());
            }
        }
        ktts.asyncCall('say', text, 0);
    }

=cut

}

sub toolTipAboutToShow
{
    this->updateTipContent();
}

sub toolTipHidden
{
    Plasma::ToolTipManager::self()->clearContent(this);
}

sub updateTipContent
{
    my $tipData = Plasma::ToolTipContent();

    # the main text contains the current timezone's time and date
    my $data = this->dataEngine('time')->query(this->currentTimezone());
    my $mainText = this->{d}->{prettyTimezone} . ' ';
    $mainText .= KDE::Global::locale()->formatTime($data->{'Time'}->toTime(), 0) . '<br>';
    my $tipDate = $data->{'Date'}->toDate();
    #$mainText .= this->calendar()->formatDate($tipDate);
    $tipData->setMainText($mainText);

    my $subText;
    if (!this->isLocalTimezone()) {
        this->{d}->addTzToTipText($subText, \this->localTimezone());
    }

    foreach my $tz ( @{this->getSelectedTimezones()} ) {
        if ($tz eq this->currentTimezone()) {
            next;
        }

        this->{d}->addTzToTipText($subText, \$tz);
    }

    #my $property = this->{d}->{calendarWidget}->dateProperty($tipDate);
    #if ($property) {
        #my $countryString = KDE::Global::locale()->countryCodeToName(this->{d}->{calendarWidget}->holidaysRegion());
        #if (!$countryString) {
            #$subText .= '<br>' . $property;
        #} else {
            #$subText .= '<br><b>' . $countryString . '</b> ' . $property;
        #}
    #}

    $tipData->setSubText($subText);

    # query for custom content
    my $customContent = this->toolTipContent();
    if ($customContent->image()->isNull()) {
        #$tipData->setImage(KDE::Icon(this->icon())->pixmap(IconSize(KDE::IconLoader::Desktop)));
        $tipData->setImage(KDE::Icon(this->icon())->pixmap(KDE::IconLoader::Desktop()));
    } else {
        $tipData->setImage($customContent->image());
    }

    if ($customContent->mainText()) {
        # add their main text
        $tipData->setMainText($customContent->mainText() . '<br>' . $tipData->mainText());
    }

    if ($customContent->subText()) {
        # add their sub text
        $tipData->setSubText($customContent->subText() . '<br>' . $tipData->subText());
    }

    $tipData->setAutohide(0);
    Plasma::ToolTipManager::self()->setContent(this, $tipData);
}

sub toolTipContent
{
    return Plasma::ToolTipContent();
}

sub createConfigurationInterface
{
    my ($parent) = @_;
    this->createClockConfigurationInterface($parent);

    my $generalWidget = Qt4::Widget();
    this->{d}->{generalUi} = Ui_GeneralConfig->setupUi($generalWidget);
    $parent->addPage($generalWidget, i18nc('General configuration page', 'General'), Plasma::Applet::icon());
    this->{d}->{generalUi}->interval->setValue(this->{d}->{announceInterval});

    #this->{d}->{calendarWidget}->createConfigurationInterface($parent);

    my $widget = Qt4::Widget();
    this->{d}->{ui} = Ui_TimezonesConfig->setupUi($widget);
    this->{d}->{ui}->searchLine->addTreeWidget(this->{d}->{ui}->timeZones);

    $parent->addPage($widget, i18n('Time Zones'), 'preferences-desktop-locale');

    foreach my $tz ( @{this->{d}->{selectedTimezones}} ) {
        this->{d}->{ui}->timeZones->setSelected($tz, 1);
    }

    this->updateClockDefaultsTo();
    my $defaultSelection = this->{d}->{ui}->clockDefaultsTo->findData(Qt4::Variant(this->{d}->{defaultTimezone}));
    if ($defaultSelection < 0) {
        $defaultSelection = 0; #if it's something unexpected default to local
        #kDebug() << this->{d}->defaultTimezone << 'not in list!?';
    }
    this->{d}->{ui}->clockDefaultsTo->setCurrentIndex($defaultSelection);

    $parent->setButtons( ${KDE::Dialog::Ok()} | ${KDE::Dialog::Cancel()} | ${KDE::Dialog::Apply()} );
    this->connect($parent, SIGNAL 'applyClicked()', this, SLOT 'configAccepted()');
    this->connect($parent, SIGNAL 'okClicked()', this, SLOT 'configAccepted()');
    this->connect(this->{d}->{ui}->timeZones, SIGNAL 'itemChanged(QTreeWidgetItem*,int)', this, SLOT 'updateClockDefaultsTo()');
}

sub createClockConfigurationInterface
{
    my ($parent) = @_;
}

sub clockConfigAccepted
{

}

sub configAccepted
{
    my $cg = this->config();

    this->{d}->{selectedTimezones} = this->{d}->{ui}->timeZones->selection();
    $cg->writeEntry('timeZones', this->{d}->{selectedTimezones});

    if (this->{d}->{ui}->clockDefaultsTo->currentIndex() == 0) {
        #The first position in {ui}->clockDefaultsTo is 'Local'
        this->{d}->{defaultTimezone} = this->localTimezoneUntranslated();
    } else {
        this->{d}->{defaultTimezone} = this->{d}->{ui}->clockDefaultsTo->itemData(this->{d}->{ui}->clockDefaultsTo->currentIndex());
    }

    $cg->writeEntry('defaultTimezone', this->{d}->{defaultTimezone});
    my $cur = this->currentTimezone();
    this->setCurrentTimezone(this->{d}->{defaultTimezone});
    this->changeEngineTimezone($cur, this->{d}->{defaultTimezone});

    #this->{d}->{calendarWidget}->configAccepted($cg);

    this->{d}->{announceInterval} = this->{d}->{generalUi}->interval->value();
    $cg->writeEntry('announceInterval', this->{d}->{announceInterval});

    this->clockConfigAccepted();
    this->constraintsEvent(Plasma::SizeConstraint());
    this->update();

    emit this->configNeedsSaving();
}

sub updateClockDefaultsTo
{
    my $oldSelection = this->{d}->{ui}->clockDefaultsTo->currentText();
    this->{d}->{ui}->clockDefaultsTo->clear();
    this->{d}->{ui}->clockDefaultsTo->addItem(this->localTimezone(), Qt4::Variant(this->localTimezone()));
    foreach my $tz ( @{this->{d}->{ui}->timeZones->selection()} ) {
        this->{d}->{ui}->clockDefaultsTo->addItem(KDE::TimeZoneWidget::displayName(KDE::TimeZone($tz)), Qt4::Variant($tz));
    }
    my $newPosition = this->{d}->{ui}->clockDefaultsTo->findText($oldSelection);
    if ($newPosition >= 0) {
        this->{d}->{ui}->clockDefaultsTo->setCurrentIndex($newPosition);
    }
    if (this->{d}->{ui}->clockDefaultsTo->count() > 1) {
        this->{d}->{ui}->clockDefaultsTo->setEnabled(1);
    } else {
        # Only 'Local' in {ui}->clockDefaultsTo
        this->{d}->{ui}->clockDefaultsTo->setEnabled(0);
    }
}

sub changeEngineTimezone
{
    my ($oldTimezone, $newTimezone) = @_;
    # reimplemented by subclasses to get the new data
}

sub shouldDisplayTimezone
{
    return this->{d}->{forceTzDisplay};
}

sub contextualActions
{
    if (!this->{d}->{clipboardMenu}) {
        this->{d}->{clipboardMenu} = KDE::Menu(i18n('C&opy to Clipboard'));
        this->{d}->{clipboardMenu}->setIcon(KDE::Icon('edit-copy'));
        this->connect(this->{d}->{clipboardMenu}, SIGNAL 'aboutToShow()', this, SLOT 'updateClipboardMenu()');
        this->connect(this->{d}->{clipboardMenu}, SIGNAL 'triggered(QAction*)', this, SLOT 'copyToClipboard(QAction*)');

        my $offers = KDE::ServiceTypeTrader::self()->query('KDE::CModule', 'Library == \'kcm_clock\'');
        if ($offers && this->hasAuthorization('LaunchApp')) {
            this->{d}->{adjustSystemTimeAction} = Qt4::Action(this);
            this->{d}->{adjustSystemTimeAction}->setText(i18n('Adjust Date and Time'));
            this->{d}->{adjustSystemTimeAction}->setIcon(KDE::Icon('preferences-system-time'));
            this->connect(this->{d}->{adjustSystemTimeAction}, SIGNAL 'triggered()', this, SLOT 'launchTimeControlPanel()');
        }
    }

    my $contextualActions = [this->{d}->{clipboardMenu}->menuAction()];

    if (this->{d}->{adjustSystemTimeAction}) {
        push @{$contextualActions},  this->{d}->{adjustSystemTimeAction};
    }
    return $contextualActions;
}

sub launchTimeControlPanel
{
    my $offers = KDE::ServiceTypeTrader::self()->query('KDE::CModule', 'Library == \'kcm_clock\'');
    if (!$offers) {
        #kDebug() << 'fail';
        return;
    }

    my $urls = KDE::Url::List();
    my $service = $offers->[0];
    KDE::Run::run($service, $urls, 0);
}

sub wheelEvent
{
    my ($event) = @_;
    if ( scalar @{this->{d}->{selectedTimezones}} < 1) {
        return;
    }

    my $newTimezone;

    if (this->isLocalTimezone()) {
        if ($event->delta() > 0) {
            $newTimezone = this->{d}->{selectedTimezones}->[-1];
        } else {
            $newTimezone = this->{d}->{selectedTimezones}->[0];
        }
    } else {
        #my $current = this->{d}->{selectedTimezones}->indexOf(currentTimezone());
        my @selectedTimezones = @{this->{d}->{selectedTimezones}};
        my $current = grep{ $selectedTimezones[$_] eq this->currentTimezone() } ( 0..$#selectedTimezones );

        if ($event->delta() > 0) {
            my $previous = $current - 1;
            if ($previous < 0) {
                $newTimezone = this->localTimezoneUntranslated();
            } else {
                $newTimezone = this->{d}->{selectedTimezones}->[$previous];
            }
        } else {
            my $next = $current + 1;
            if ($next > @{this->{d}->{selectedTimezones}} - 1) {
                $newTimezone = this->localTimezoneUntranslated();
            } else {
                $newTimezone = this->{d}->{selectedTimezones}->[$next];
            }
        }
    }

    my $cur = this->currentTimezone();
    this->setCurrentTimezone($newTimezone);
    this->changeEngineTimezone($cur, $newTimezone);
    this->update();
}

sub initExtenderItem
{
    my ($item) = @_;
    if ($item->name() == 'calendar') {
        $item->setTitle(i18n('Calendar'));
        $item->setIcon('view-pim-calendar');
        #$item->setWidget(this->{d}->{calendarWidget});
    } elsif ($item->name() eq 'today') {
        $item->setTitle(i18n('Today'));
        $item->setIcon('view-pim-calendar');
        this->{d}->{label} = Plasma::Label();
        $item->setWidget(this->{d}->{label});
    } elsif ($item->name() =~ m/^dateExtender/) {
        $item->setIcon('view-pim-calendar');
        $item->showCloseButton();
        my $date = Qt4::Date::fromString(substr( $item->name(), 13), Qt4::ISODate());
        my $widget;

        #$item->setTitle(this->calendar()->formatDate($date));
        #$widget = DateExtenderWidget(this->{d}->{calendarWidget}->dateProperty($date));

        $item->setWidget($widget);
    }
}

sub init
{
    my $cg = this->config();
    # Make it call the QStringList copy of readEntry() by making an array ref
    # of an empty QString.
    this->{d}->{selectedTimezones} = $cg->readEntry(Qt4::String('timeZones'), [Qt4::String('')]);
    this->{d}->{timezone} = $cg->readEntry(Qt4::String('timezone'), Qt4::String(this->{d}->{timezone}));
    this->{d}->{defaultTimezone} = $cg->readEntry(Qt4::String('defaultTimezone'), Qt4::String(this->{d}->{timezone}));
    this->{d}->{forceTzDisplay} = this->{d}->{timezone} ne this->{d}->{defaultTimezone};

    this->{d}->setPrettyTimezone();

    this->{d}->{announceInterval} = $cg->readEntry(Qt4::String('announceInterval'), Qt4::String(''));

    Plasma::ToolTipManager::self()->registerWidget(this);

    #this->{d}->{calendarWidget} = Plasma::Calendar();
    #this->{d}->{calendarWidget}->setMinimumSize(Qt4::Size(230, 220));
    #this->{d}->{calendarWidget}->setDataEngine(this->dataEngine('calendar'));
    #this->connect(this->{d}->{calendarWidget}, SIGNAL 'dateChanged(const QDate &)', this, SLOT 'dateChanged(const QDate &)');
    #this->{d}->{calendarWidget}->applyConfiguration($cg);
    my $data = this->dataEngine('time')->query(this->currentTimezone());
    #this->{d}->{calendarWidget}->setDate($data->{'Date'}->toDate());
    #this->{d}->createCalendarExtender();

    this->extender();
    Qt4::Timer::singleShot(0, this, SLOT 'createToday()');
}

sub popupEvent
{
    my ($show) = @_;
    if (!$show) {
        return;
    }

    my $data = this->dataEngine('time')->query(this->currentTimezone());
    #this->{d}->{calendarWidget}->setDate($data->{'Date'}->toDate());

    this->{d}->destroyDateExtenders();
}

sub constraintsEvent
{
    my ($constraints) = @_;
    if ($constraints & Plasma::FormFactorConstraint()) {
        this->setPassivePopup(this->formFactor() == Plasma::Horizontal() || this->formFactor() == Plasma::Vertical());
    }
}

sub setCurrentTimezone
{
    my ($tz) = @_;
    if (this->{d}->{timezone} eq $tz) {
        return;
    }

    if ($tz eq this->localTimezone()) {
        # catch people accidentally passing in the translation of 'Local'
        this->{d}->{timezone} = this->localTimezoneUntranslated();
    } else {
        this->{d}->{timezone} = $tz;
    }

    this->{d}->{forceTzDisplay} = this->{d}->{timezone} ne this->{d}->{defaultTimezone};
    this->{d}->setPrettyTimezone();

    my $cg = this->config();
    $cg->writeEntry('timezone', this->{d}->{timezone});
    emit this->configNeedsSaving();
}

sub currentTimezone
{
    return this->{d}->{timezone};
}

sub prettyTimezone
{
    return this->{d}->{prettyTimezone};
}

sub getSelectedTimezones
{
    return this->{d}->{selectedTimezones};
}

sub isLocalTimezone
{
    return this->{d}->{timezone} eq this->localTimezoneUntranslated();
}

sub localTimezone
{
    return i18nc('Local time zone', 'Local');
}

sub localTimezoneUntranslated
{
    return 'Local';
}

sub dateChanged
{
    my ($date) = @_;
    this->{d}->destroyDateExtenders();

    #if (this->{d}->{calendarWidget}->dateProperty($date)) {
        #this->{d}->createDateExtender($date);
    #}
}

sub updateClipboardMenu
{
    this->{d}->{clipboardMenu}->clear();
    my $actions;
    my $data = this->dataEngine('time')->query(this->currentTimezone());
    my $dateTime = Qt4::DateTime($data->{'Date'}->toDate(), $data->{'Time'}->toTime());

    #this->{d}->{clipboardMenu}->addAction(this->calendar()->formatDate($dateTime->date(), KDE::Locale::LongDate()));
    #this->{d}->{clipboardMenu}->addAction(this->calendar()->formatDate($dateTime->date(), KDE::Locale::ShortDate()));
    # Display ISO Date format if not already displayed
    if (KDE::Global::locale()->dateFormatShort() ne '%Y-%m-%d') {
        #this->{d}->{clipboardMenu}->addAction(this->calendar()->formatDate($dateTime->date(), '%Y-%m-%d'));
    }

    my $sep0 = Qt4::Action(this);
    $sep0->setSeparator(1);
    this->{d}->{clipboardMenu}->addAction($sep0);

    this->{d}->{clipboardMenu}->addAction(KDE::Global::locale()->formatTime($dateTime->time(), 0));
    this->{d}->{clipboardMenu}->addAction(KDE::Global::locale()->formatTime($dateTime->time(), 1));

    my $sep1 = Qt4::Action(this);
    $sep1->setSeparator(1);
    this->{d}->{clipboardMenu}->addAction($sep1);

    my $tempLocale = KDE::Locale(KDE::Global::locale());
    #$tempLocale->setCalendar(this->calendar()->calendarType());
    #this->{d}->{clipboardMenu}->addAction($tempLocale->formatDateTime($dateTime, KDE::Locale::LongDate()));
    #this->{d}->{clipboardMenu}->addAction($tempLocale->formatDateTime($dateTime, KDE::Locale::LongDate(), 1));
    #this->{d}->{clipboardMenu}->addAction($tempLocale->formatDateTime($dateTime, KDE::Locale::ShortDate()));
    #this->{d}->{clipboardMenu}->addAction($tempLocale->formatDateTime($dateTime, KDE::Locale::ShortDate(), 1));
    # Display ISO DateTime format if not already displayed
    #if ($tempLocale->dateFormatShort() ne '%Y-%m-%d') {
        #$tempLocale->setDateFormatShort('%Y-%m-%d');
        #this->{d}->{clipboardMenu}->addAction($tempLocale->formatDateTime($dateTime, KDE::Locale::ShortDate(), 1));
    #}

    my $sep2 = Qt4::Action(this);
    $sep2->setSeparator(1);
    this->{d}->{clipboardMenu}->addAction($sep2);

    #my $calendars = KDE::CalendarSystem::calendarSystems();
    #foreach my $cal ( @{$calendars} ) {
        #if ($cal ne this->calendar()->calendarType()) {
            #my $tempCal = KDE::CalendarSystem::create($cal);
            #my $text = $tempCal->formatDate($dateTime->date(), KDE::Locale::LongDate()) . ' (' . KDE::CalendarSystem::calendarLabel($cal) . ')';
            #this->{d}->{clipboardMenu}->addAction($text);
            #$text = $tempCal->formatDate($dateTime->date(), KDE::Locale::ShortDate()) . ' (' . KDE::CalendarSystem::calendarLabel($cal) . ')';
            #this->{d}->{clipboardMenu}->addAction($text);
        #}
    #}
}

sub copyToClipboard
{
    my ($action) = @_;
    my $text = $action->text();
    $text =~ s/&//g;

    Qt4::Application::clipboard()->setText($text);
}

sub calendar
{
    #return this->{d}->{calendarWidget}->calendar();
}

1;
