package PlasmaAppletPerlHelloPlasmoid;

use strict;
use warnings;

use lib '/home/cburel/perlqtinstall/';
use lib '/home/cburel/perlqtinstall/auto/';

use KDEUi4;
use Plasma4;
use QtCore4::isa qw( Plasma::Applet );

my $foo;

sub NEW {
    my ( $class, $parent, $args ) = @_;
    $args = [map{ Qt::Variant( $_ ) } @$args]; 
    $class->SUPER::NEW( $parent, $args );
    $foo->{bar} = this;

    this->{m_svg} = Plasma::Svg(this);
    this->{m_icon} = KDE::Icon('document');

    this->{m_svg}->setImagePath('widgets/background');
    this->setBackgroundHints(Plasma::Applet::DefaultBackground());
    this->resize(200,200);
}

sub paintInterface {
    my ( $p, $option, $contentsRect ) = @_;
    $p->setRenderHint(Qt::Painter::SmoothPixmapTransform());
    $p->setRenderHint(Qt::Painter::Antialiasing());
 
    # Now we draw the applet, starting with our svg
    this->{m_svg}->resize($contentsRect->width(), $contentsRect->height());
    this->{m_svg}->paint($p, $contentsRect->left(), $contentsRect->top());
 
    # We place the icon and text
    $p->drawPixmap(7, 0, this->{m_icon}->pixmap($contentsRect->width(),$contentsRect->width()-14));
    $p->save();
    $p->setPen(Qt::white());
    $p->drawText($contentsRect,
                Qt::AlignBottom() | Qt::AlignHCenter(),
                "Hello Plasmoid!");
    $p->restore();

}

1;
