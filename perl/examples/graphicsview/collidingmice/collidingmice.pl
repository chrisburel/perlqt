#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Mouse;

my $MouseCount = 7;

# [0]
sub main
{
    my $app = Qt4::Application( \@ARGV );
    srand(Qt4::Time(0,0,0)->secsTo(Qt4::Time::currentTime()));
# [0]

# [1]
    my $scene = Qt4::GraphicsScene();
    $scene->setSceneRect(-300, -300, 600, 600);
# [1] //! [2]
    $scene->setItemIndexMethod(Qt4::GraphicsScene::NoIndex());
# [2]

# [3]
    for (my $i = 0; $i < $MouseCount; ++$i) {
        my $mouse = Mouse();
        $mouse->setPos(sin(($i * 6.28) / $MouseCount) * 200,
                       cos(($i * 6.28) / $MouseCount) * 200);
        $scene->addItem($mouse->graphicsItem);
    }
# [3]

# [4]
    my $view = Qt4::GraphicsView($scene);
    $view->setRenderHint(Qt4::Painter::Antialiasing());
    $view->setBackgroundBrush(Qt4::Pixmap('images/cheese.jpg'));
# [4] //! [5]
    $view->setCacheMode(Qt4::GraphicsView::CacheBackground());
    $view->setViewportUpdateMode(Qt4::GraphicsView::BoundingRectViewportUpdate());
    $view->setDragMode(Qt4::GraphicsView::ScrollHandDrag());
# [5] //! [6]
    $view->setWindowTitle(Qt4::GraphicsView::tr('Colliding Mice'));
    $view->resize(400, 300);
    $view->show();

    return $app->exec();
}
# [6]

exit main();
