package SvgView;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::GraphicsView );
use Qt4::slots
    setHighQualityAntialiasing => ['bool'],
    setViewBackground => ['bool'],
    setViewOutline => ['bool'];

use constant {
    Native => 0,
    OpenGL => 1,
    Image => 2
};

sub m_renderer() {
    return this->{m_renderer};
}

sub m_svgItem() {
    return this->{m_svgItem};
}

sub m_backgroundItem() {
    return this->{m_backgroundItem};
}

sub m_outlineItem() {
    return this->{m_outlineItem};
}

sub m_image() {
    return this->{m_image};
}

sub NEW
{
    my ($class, $parent) = @_;
    if ( $parent ) {
        $class->SUPER::NEW($parent);
    }
    else {
        $class->SUPER::NEW();
    }
    this->{m_renderer} = Native;
    this->{svgItem} = 0;
    this->{backgroundItem} = 0;
    this->{outlineItem} = 0;
    this->{m_image} = Qt4::Image();

    this->setScene(Qt4::GraphicsScene(this));
    this->setTransformationAnchor(Qt4::GraphicsView::AnchorUnderMouse());
    this->setDragMode(Qt4::GraphicsView::ScrollHandDrag());

    # Prepare background check-board pattern
    my $tilePixmap = Qt4::Pixmap(64, 64);
    $tilePixmap->fill(Qt4::Color(Qt4::white()));
    my $tilePainter = Qt4::Painter($tilePixmap);
    my $color = Qt4::Color(220, 220, 220);
    $tilePainter->fillRect(0, 0, 32, 32, Qt4::Brush($color));
    $tilePainter->fillRect(32, 32, 32, 32, Qt4::Brush($color));
    $tilePainter->end();

    this->setBackgroundBrush(Qt4::Brush($tilePixmap));
}

sub drawBackground
{
    my ($p) = @_;
    $p->save();
    $p->resetTransform();
    $p->drawTiledPixmap(this->viewport()->rect(), this->backgroundBrush()->texture());
    $p->restore();
}

sub openFile
{
    my ($file) = @_;
    if (!$file->exists()) {
        return;
    }

    my $s = this->scene();

    my $drawBackground = (this->m_backgroundItem ? this->m_backgroundItem->isVisible() : 0);
    my $drawOutline = (this->m_outlineItem ? this->m_outlineItem->isVisible() : 1);

    $s->clear();
    this->resetTransform();

    this->{m_svgItem} = Qt4::GraphicsSvgItem($file->fileName());
    this->m_svgItem->setFlags(Qt4::GraphicsItem::ItemClipsToShape());
    this->m_svgItem->setCacheMode(Qt4::GraphicsItem::NoCache());
    this->m_svgItem->setZValue(0);

    this->{m_backgroundItem} = Qt4::GraphicsRectItem(this->m_svgItem->boundingRect());
    this->m_backgroundItem->setBrush(Qt4::Brush(Qt4::white()));
    this->m_backgroundItem->setPen(Qt4::Pen(Qt4::NoPen()));
    this->m_backgroundItem->setVisible($drawBackground);
    this->m_backgroundItem->setZValue(-1);

    this->{m_outlineItem} = Qt4::GraphicsRectItem(this->m_svgItem->boundingRect());
    my $outline = Qt4::Pen(Qt4::Brush(Qt4::black()), 2, Qt4::DashLine());
    $outline->setCosmetic(1);
    this->m_outlineItem->setPen($outline);
    # FIXME This should work with the 1 argument form.  But that has been cached
    # already as calling the QBrush(Qt4::GlobalColor) constructor.
    this->m_outlineItem->setBrush(Qt4::Brush(Qt4::white(), Qt4::NoBrush()));
    this->m_outlineItem->setVisible($drawOutline);
    this->m_outlineItem->setZValue(1);

    $s->addItem(this->m_backgroundItem);
    $s->addItem(this->m_svgItem);
    $s->addItem(this->m_outlineItem);

    $s->setSceneRect(this->m_outlineItem->boundingRect()->adjusted(-10, -10, 10, 10));
}

sub setRenderer
{
    my ($type) = @_;
    this->{m_renderer} = $type;

    if (this->m_renderer == OpenGL) {
#ifndef QT_NO_OPENGL
        this->setViewport(Qt4::GLWidget(Qt4::GLFormat(Qt4::GL::SampleBuffers())));
#endif
    } else {
        this->setViewport(Qt4::Widget());
    }
}

sub setHighQualityAntialiasing
{
    my ($highQualityAntialiasing) = @_;
#ifndef QT_NO_OPENGL
    this->setRenderHint(Qt4::Painter::HighQualityAntialiasing(), $highQualityAntialiasing);
#endif
}

sub setViewBackground
{
    my ($enable) = @_;
    if (!this->m_backgroundItem) {
          return;
    }

    this->m_backgroundItem->setVisible($enable);
}

sub setViewOutline
{
    my ($enable) = @_;
    if (!this->m_outlineItem) {
        return;
    }

    this->m_outlineItem->setVisible($enable);
}

sub paintEvent
{
    my ($event) = @_;
    if (this->m_renderer == Image) {
        if (this->m_image->size() != this->viewport()->size()) {
            this->{m_image} = Qt4::Image(this->viewport()->size(), Qt4::Image::Format_ARGB32_Premultiplied());
        }

        my $imagePainter = Qt4::Painter(this->m_image);
        this->SUPER::render($imagePainter);
        $imagePainter->end();

        my $p = Qt4::Painter(this->viewport());
        $p->drawImage(0, 0, this->m_image);
        $p->end();

    } else {
        this->SUPER::paintEvent($event);
    }
}

sub wheelEvent
{
    my ($event) = @_;
    my $factor = 1.2 ** ($event->delta() / 240.0);
    this->scale($factor, $factor);
    $event->accept();
}

1;
