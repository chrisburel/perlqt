package Clock;
#/***************************************************************************
# *   Copyright 2007 by Aaron Seigo <aseigo@kde.org>                        *
# *   Copyright 2007 by Riccardo Iaconelli <riccardo@kde.org>               *
# *   Perl translation by Chris Burel <chrisburel@gmail.com>                *
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# *   This program is distributed in the hope that it will be useful,       *
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *   GNU General Public License for more details.                          *
# *                                                                         *
# *   You should have received a copy of the GNU General Public License     *
# *   along with this program; if not, write to the                         *
# *   Free Software Foundation, Inc.,                                       *
# *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
# ***************************************************************************/

use strict;
use warnings;

use lib '/home/cburel/perlqtinstall/';
use lib '/home/cburel/perlqtinstall/auto/';

use QtCore4;
use KDEUi4;
use Plasma4;
use QtCore4::isa qw( ClockApplet );
use KDECore4 qw( i18n );
use List::Util qw( min max );

use ClockApplet;
use Ui_ClockConfig;

use QtCore4::slots
    dataUpdated => ['const QString &', 'const Plasma::DataEngine::Data &'],
    clockConfigAccepted => [],
    clockConfigChanged => [],
    repaintNeeded => [],
    moveSecondHand => [];

use constant {
    RepaintNone => 1,
    RepaintAll => 2,
    RepaintHands => 3
};

my $keepme;

sub NEW {
    my ($class, $parent, $args) = @_;
    $args = [map{ Qt::Variant( Qt::String($_) ) } @$args];
    $class->SUPER::NEW( $parent, $args );
    $keepme->{please} = this;
    
    this->{m_showSecondHand} = 0;
    this->{m_showTimezoneString} = 0;
    this->{m_showingTimezone} = 0;
    this->{m_tzFrame} = 0;
    this->{m_repaintCache} = RepaintAll;
    this->{m_faceCache} = Qt::Pixmap();
    this->{m_handsCache} = Qt::Pixmap();
    this->{m_glassCache} = Qt::Pixmap();
    this->{m_secondHandUpdateTimer} = 0;
    this->{m_animateSeconds} = 0;
    KDE::Global::locale()->insertCatalog('libplasmaclock');
    # this catalog is only used once on the first start of the clock to translate the timezone in the configuration file
    KDE::Global::locale()->insertCatalog('timezones4');
    this->setHasConfigurationInterface(1);
    this->resize(256, 256);
    this->setAspectRatioMode(Plasma::Square());
    this->setBackgroundHints(Plasma::Applet::NoBackground());

    this->{m_theme} = Plasma::Svg(this);
    this->{m_theme}->setImagePath('widgets/clock');
    this->{m_theme}->setContainsMultipleImages(1);
    this->{m_theme}->resize(size());

    this->{m_animationStart} = 0;
    this->{m_showingTimezone} = 0;
    this->{m_showTimezoneString} = 0;

    this->connect(this->{m_theme}, SIGNAL 'repaintNeeded()', this, SLOT 'repaintNeeded()');
}

sub init
{
    this->SUPER::init();
    this->{m_oldTimezone} = this->currentTimezone();
    this->configChanged();
}

sub connectToEngine
{
    this->{m_lastTimeSeen} = Qt::Time();

    my $timeEngine = this->dataEngine('time');
    $timeEngine->disconnectSource(this->{m_oldTimezone}, this);
    this->{m_oldTimezone} = currentTimezone();

    if (this->{m_showSecondHand}) {
        $timeEngine->connectSource(currentTimezone(), this, 500);
    } else {
        $timeEngine->connectSource(currentTimezone(), this, 6000, Plasma::AlignToMinute());
    }
}

sub clockConfigChanged
{
    my $cg = this->config();
    this->{m_showSecondHand} = $cg->readEntry(Qt::String('showSecondHand'), Qt::String('0'));
    this->{m_showTimezoneString} = $cg->readEntry(Qt::String('showTimezoneString'), Qt::String('0'));
    this->{m_showingTimezone} = this->{m_showTimezoneString};
    this->{m_fancyHands} = $cg->readEntry(Qt::String('fancyHands'), Qt::String('0'));
    this->setCurrentTimezone($cg->readEntry(Qt::String('timezone'), Qt::String(this->localTimezone())));

    if (this->{m_showSecondHand}) {
        #We don't need to cache the applet if it update every seconds
        this->setCacheMode(Qt::GraphicsItem::NoCache());
    } else {
        this->setCacheMode(Qt::GraphicsItem::DeviceCoordinateCache());
    }

    this->connectToEngine();
    this->invalidateCache();
}

sub constraintsEvent
{
    my ($constraints) = @_;

    # There's a semi bug with using this->SUPER, when the super class is a perl
    # class.  Doing so causes the wrong number of arguments to be passed to the
    # called subroutine (because 'this' gets placed on the front of @_, which
    # is not how PerlQt is designed to work).
    ClockApplet::constraintsEvent($constraints);

    if ($constraints & Plasma::SizeConstraint()) {
        this->invalidateCache();
    }

    if ($constraints & Plasma::FormFactorConstraint()) {
        if (this->formFactor() == Plasma::Planar() || this->formFactor() == Plasma::MediaCenter()) {
            this->setPreferredSize(256, 256);
        } else {
            this->setPreferredSize(-1, -1);
        }
    }
}

sub shape
{
    if (this->{m_theme}->hasElement('hint-square-clock')) {
        return Plasma::Applet::shape();
    }

    my $path = Qt::PainterPath();
    # we adjust by 2px all around to allow for smoothing the jaggies
    # if the ellipse is too small, we'll get a nastily jagged edge around the clock
    $path->addEllipse(this->boundingRect()->adjusted(-2, -2, 2, 2));
    return $path;
}

sub dataUpdated
{
    my ($source, $data) = @_;
    this->{m_time} = $data->{'Time'}->toTime();

    if (this->{m_time}->minute() == this->{m_lastTimeSeen}->minute() &&
        this->{m_time}->second() == this->{m_lastTimeSeen}->second()) {
        # avoid unnecessary repaints
        return;
    }

    if (this->{m_time}->minute() != this->{m_lastTimeSeen}->minute()) {
        this->{m_repaintCache} = RepaintHands;
    }

    if (Plasma::ToolTipManager::self()->isVisible(this)) {
        this->updateTipContent();
    }
    updateClockApplet();

    if (this->{m_secondHandUpdateTimer}) {
        this->{m_secondHandUpdateTimer}->stop();
    }

    this->{m_animateSeconds} = 1;
    this->{m_lastTimeSeen} = this->{m_time};
    this->update();

    this->speakTime(this->{m_time});
}

sub createClockConfigurationInterface
{
    my ($parent) = @_;
    #TODO: Make the size settable
    my $widget = Qt::Widget();
    this->{ui} = Ui_ClockConfig->setupUi($widget);
    $parent->addPage($widget, i18n('Appearance'), 'view-media-visualization');

    this->{ui}->showSecondHandCheckBox->setChecked(this->{m_showSecondHand});
    this->{ui}->showTimezoneStringCheckBox->setChecked(this->{m_showTimezoneString});
}

sub clockConfigAccepted
{
    my $cg = this->config();
    this->{m_showTimezoneString} = this->{ui}->showTimezoneStringCheckBox->isChecked();
    this->{m_showingTimezone} = this->{m_showTimezoneString} || this->shouldDisplayTimezone();
    this->{m_showSecondHand} = this->{ui}->showSecondHandCheckBox->isChecked();

    if (this->{m_showSecondHand}) {
        #We don't need to cache the applet if it update every seconds
        this->setCacheMode(Qt::GraphicsItem::NoCache());
    } else {
        this->setCacheMode(Qt::GraphicsItem::DeviceCoordinateCache());
    }

    $cg->writeEntry(Qt::String('showSecondHand'), Qt::String(this->{m_showSecondHand}));
    $cg->writeEntry(Qt::String('showTimezoneString'), Qt::String(this->{m_showTimezoneString}));
    this->update();

    this->dataEngine('time')->disconnectSource(this->currentTimezone(), this);
    this->connectToEngine();

    this->constraintsEvent(Plasma::AllConstraints());
    emit this->configNeedsSaving();
}

sub changeEngineTimezone
{
    my ($oldTimezone, $newTimezone) = @_;
    this->dataEngine('time')->disconnectSource($oldTimezone, this);
    my $timeEngine = this->dataEngine('time');

    if (this->{m_showSecondHand}) {
        $timeEngine->connectSource($newTimezone, this, 500);
    } else {
        $timeEngine->connectSource($newTimezone, this, 6000, Plasma::AlignToMinute());
    }

    if (this->{m_showingTimezone} ne (this->{m_showTimezoneString} || this->shouldDisplayTimezone())) {
        this->{m_showingTimezone} = !(this->{m_showingTimezone});
        this->constraintsEvent(Plasma::SizeConstraint());
    }
    this->{m_repaintCache} = RepaintAll;
}

sub repaintNeeded
{
    this->{m_repaintCache} = RepaintAll;
    this->update();
}

sub moveSecondHand
{
    #kDebug() << 'moving second hand';
    this->update();
}

sub drawHand
{
    my ($p, $rect, $verticalTranslation, $rotation, $handName) = @_;
    # this code assumes the following conventions in the svg file:
    # - the _vertical_ position of the hands should be set with respect to the center of the face
    # - the _horizontal_ position of the hands does not matter
    # - the _shadow_ elements should have the same vertical position as their _hand_ element counterpart

    my $elementRect = Qt::RectF();
    my $name = $handName . 'HandShadow';
    if (this->{m_theme}->hasElement($name)) {
        $p->save();

        $elementRect = this->{m_theme}->elementRect($name);
        if( $rect->height() < ${KDE::IconLoader::SizeEnormous()} ) {
            $elementRect->setWidth( $elementRect->width() * 2.5 );
        }
        my $offset = Qt::Point(2, 3);

        $p->translate($rect->x() + ($rect->width() / 2) + $offset->x(), $rect->y() + ($rect->height() / 2) + $offset->y());
        $p->rotate($rotation);
        $p->translate(-$elementRect->width()/2, $elementRect->y()-$verticalTranslation);
        this->{m_theme}->paint($p, Qt::RectF(Qt::PointF(0, 0), $elementRect->size()), $name);

        $p->restore();
    }

    $p->save();

    $name = $handName . 'Hand';
    $elementRect = this->{m_theme}->elementRect($name);
    if ($rect->height() < ${KDE::IconLoader::SizeEnormous()}) {
        $elementRect->setWidth($elementRect->width() * 2.5);
    }

    $p->translate($rect->x() + $rect->width()/2, $rect->y() + $rect->height()/2);
    $p->rotate($rotation);
    $p->translate(-$elementRect->width()/2, $elementRect->y()-$verticalTranslation);
    this->{m_theme}->paint($p, Qt::RectF(Qt::PointF(0, 0), $elementRect->size()), $name);

    $p->restore();
}

sub paintInterface
{
    my ($p, $option, $rect) = @_;
    $rect = Qt::RectF( $rect );

    # compute hand angles
    my $minutes = 6.0 * this->{m_time}->minute() - 180;
    my $hours = 30.0 * this->{m_time}->hour() - 180 +
                        ((this->{m_time}->minute() / 59.0) * 30.0);
    my $seconds = 0;
    if (this->{m_showSecondHand}) {
        my $anglePerSec = 6;
        $seconds = $anglePerSec * this->{m_time}->second() - 180;

        if (this->{m_fancyHands}) {
            if (!defined this->{m_secondHandUpdateTimer}) {
                this->{m_secondHandUpdateTimer} = Qt::Timer(this);
                this->connect(this->{m_secondHandUpdateTimer}, SIGNAL 'timeout()', this, SLOT 'moveSecondHand()');
            }

            if (this->{m_animateSeconds} && !this->{m_secondHandUpdateTimer}->isActive()) {
                #kDebug() << 'starting second hand movement';
                this->{m_secondHandUpdateTimer}->start(50);
                this->{m_animationStart} = Qt::Time::currentTime()->msec();
            } else {
                my $runTime = 500;
                my $m = 1; # Mass
                my $b = 1; # Drag coefficient
                my $k = 1.5; # Spring constant
                my $PI = 3.141592653589793; # the universe is irrational
                my $gamma = $b / (2 * $m); # Dampening constant
                my $omega0 = sqrt($k / $m);
                my $omega1 = sqrt($omega0 * $omega0 - $gamma * $gamma);
                my $elapsed = Qt::Time::currentTime()->msec() - this->{m_animationStart};
                my $t = (4 * $PI) * ($elapsed / $runTime);
                my $val = 1 + exp(-$gamma * $t) * -cos($omega1 * $t);

                if ($elapsed > $runTime) {
                    this->{m_secondHandUpdateTimer}->stop();
                    this->{m_animateSeconds} = 0;
                } else {
                    $seconds += -$anglePerSec + ($anglePerSec * $val);
                }
            }
        } else {
            if (!this->{m_secondHandUpdateTimer}) {
                this->{m_secondHandUpdateTimer} = Qt::Timer(this);
                this->connect(this->{m_secondHandUpdateTimer}, SIGNAL 'timeout()', this, SLOT 'moveSecondHand()');
            }

            if (this->{m_animationStart} != $seconds && !this->{m_secondHandUpdateTimer}->isActive()) {
                this->{m_secondHandUpdateTimer}->start(50);
                this->{m_animationStart} = $seconds; #we don't want to have a second animation if there is a external update (wallpaper etc).
                $seconds += 1;
            } else {
                this->{m_secondHandUpdateTimer}->stop();
            }
        }
    }

    if (this->contentsRect()->size()->toSize() != this->{m_theme}->size()) {
        this->invalidateCache();
    }

    # paint face and glass cache
    my $faceRect = Qt::RectF(this->{m_faceCache}->rect());
    if (this->{m_repaintCache} == RepaintAll) {
        this->{m_faceCache}->fill(Qt::Color(Qt::transparent()));
        this->{m_glassCache}->fill(Qt::Color(Qt::transparent()));

        my $facePainter = Qt::Painter(this->{m_faceCache});
        my $glassPainter = Qt::Painter(this->{m_glassCache});
        $facePainter->setRenderHint(Qt::Painter::SmoothPixmapTransform());
        $glassPainter->setRenderHint(Qt::Painter::SmoothPixmapTransform());

        this->{m_theme}->paint($facePainter, $faceRect, 'ClockFace');

        $glassPainter->save();
        my $elementRect = Qt::RectF(Qt::PointF(0, 0), Qt::SizeF(this->{m_theme}->elementSize('HandCenterScrew')));
        $glassPainter->translate($faceRect->width() / 2 - $elementRect->width() / 2, $faceRect->height() / 2 - $elementRect->height() / 2);
        this->{m_theme}->paint($glassPainter, $elementRect, 'HandCenterScrew');
        $glassPainter->restore();

        this->{m_theme}->paint($glassPainter, $faceRect, 'Glass');

        # get vertical translation, see drawHand() for more details
        this->{m_verticalTranslation} = this->{m_theme}->elementRect('ClockFace')->center()->y();
        $facePainter->end();
        $glassPainter->end();
    }

    # paint hour and minute hands cache
    if (this->{m_repaintCache} == RepaintHands || this->{m_repaintCache} == RepaintAll) {
        this->{m_handsCache}->fill(Qt::Color(Qt::transparent()));

        my $handsPainter = Qt::Painter(this->{m_handsCache});
        $handsPainter->drawPixmap($faceRect, this->{m_faceCache}, $faceRect);
        $handsPainter->setRenderHint(Qt::Painter::SmoothPixmapTransform());

        this->drawHand($handsPainter, $faceRect, this->{m_verticalTranslation}, $hours, 'Hour');
        this->drawHand($handsPainter, $faceRect, this->{m_verticalTranslation}, $minutes, 'Minute');
        $handsPainter->end();
    }

    # reset repaint cache flag
    this->{m_repaintCache} = RepaintNone;

    # paint caches and second hand
    # We're going to modify this copy of the rect, so make a copy of it.  Just
    # saying $targetRect = $faceRect won't copy it.
    my $targetRect = Qt::RectF( $faceRect );
    if ($targetRect->width() < $rect->width()) {
        $targetRect->moveLeft(($rect->width() - $targetRect->width()) / 2);
    }
    $targetRect->translate($rect->topLeft());

    $p->drawPixmap($targetRect, this->{m_handsCache}, $faceRect);
    if (this->{m_showSecondHand}) {
        $p->setRenderHint(Qt::Painter::SmoothPixmapTransform());
        this->drawHand($p, $targetRect, this->{m_verticalTranslation}, $seconds, 'Second');
    }
    $p->drawPixmap($targetRect, this->{m_glassCache}, $faceRect);

    # optionally paint the time string
    if (this->{m_showingTimezone}) {
        my $time = this->prettyTimezone();

        if ($time) {
            my $textRect = this->tzRect($time);
            this->tzFrame()->paintFrame($p, Qt::RectF($textRect), Qt::RectF(Qt::Point(0, 0), Qt::SizeF($textRect->size())));

            my ($left, $top, $right, $bottom);
            this->tzFrame()->getMargins($left, $top, $right, $bottom);

            $p->setPen(Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor()));
            $p->setFont(Plasma::Theme::defaultTheme()->font(Plasma::Theme::DefaultFont()));
            $p->drawText($textRect->adjusted($left, 0, -$right, 0), Qt::AlignCenter(), $time);
        }
    }
}

sub tzRect
{
    my ($text) = @_;
    my $rect = this->contentsRect()->toRect();

    my $font = Plasma::Theme::defaultTheme()->font(Plasma::Theme::DefaultFont());
    my $fontMetrics = Qt::FontMetrics($font);

    my ( $left, $top, $right, $bottom ) = (0, 0, 0, 0);
    this->tzFrame()->getMargins($left, $top, $right, $bottom);

    my $width = $left + $right + $fontMetrics->width($text) + $fontMetrics->averageCharWidth() * 2;
    my $height = $top + $bottom + $fontMetrics->height();
    $width = min($width, $rect->width());
    $height = min($height, $rect->height());

    return Qt::Rect(($rect->width() - $width) / 2, $rect->bottom() - $height, $width, $height);
}

sub tzFrame
{
    if (!this->{m_tzFrame}) {
        this->{m_tzFrame} = Plasma::FrameSvg(this);
        this->{m_tzFrame}->setImagePath('widgets/background');
    }

    return this->{m_tzFrame};
}

sub invalidateCache
{
    this->{m_repaintCache} = RepaintAll;

    my $pixmapSize = this->contentsRect()->size()->toSize();

    if (this->{m_showingTimezone}) {
        my $tzArea = this->tzRect(this->prettyTimezone());
        $pixmapSize->setHeight(max(10, $pixmapSize->height() - $tzArea->height()));
        this->tzFrame()->resizeFrame(Qt::SizeF($tzArea->size()));
    }

    $pixmapSize->setWidth($pixmapSize->height());
    this->{m_faceCache} = Qt::Pixmap($pixmapSize);
    this->{m_handsCache} = Qt::Pixmap($pixmapSize);
    this->{m_glassCache} = Qt::Pixmap($pixmapSize);

    this->{m_faceCache}->fill(Qt::Color(Qt::transparent()));
    this->{m_glassCache}->fill(Qt::Color(Qt::transparent()));
    this->{m_handsCache}->fill(Qt::Color(Qt::transparent()));

    this->{m_theme}->resize(Qt::SizeF($pixmapSize));
}

1;
