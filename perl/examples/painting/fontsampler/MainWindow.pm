package MainWindow;

use strict;
use warnings;
use Qt4;
use Ui_MainWindowBase;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    on_clearAction_triggered => [],
    on_markAction_triggered => [],
    on_printAction_triggered => [],
    on_printPreviewAction_triggered => [],
    on_unmarkAction_triggered => [],
    printDocument => ['QPrinter *'],
    printPage => ['int', 'QPainter *', 'QPrinter *'],
    showFont => ['QTreeWidgetItem *'],
    updateStyles => ['QTreeWidgetItem *', 'int'];
use List::Util qw(min max);

sub sampleSizes() {
    return this->{sampleSizes};
}

sub pageMap() {
    return this->{pageMap};
}

sub markedCount() {
    return this->{markedCount};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{ui} = Ui_MainWindowBase->setupUi(this);

    this->{sampleSizes} = [qw( 32 24 16 14 12 8 4 2 1 )];
    this->{markedCount} = 0;
    this->setupFontTree();

    this->connect(this->{ui}->quitAction, SIGNAL 'triggered()', qApp, SLOT 'quit()');
    this->connect(this->{ui}->fontTree, SIGNAL 'currentItemChanged(QTreeWidgetItem *, QTreeWidgetItem *)',
            this, SLOT 'showFont(QTreeWidgetItem *)');
    this->connect(this->{ui}->fontTree, SIGNAL 'itemChanged(QTreeWidgetItem *, int)',
            this, SLOT 'updateStyles(QTreeWidgetItem *, int)');

    this->{ui}->fontTree->setItemSelected(this->{ui}->fontTree->topLevelItem(0), 1);
    this->showFont(this->{ui}->fontTree->topLevelItem(0));
}

sub setupFontTree
{
    my $database = Qt4::FontDatabase();
    this->{ui}->fontTree->setColumnCount(1);
    this->{ui}->fontTree->setHeaderLabels([this->tr('Font')]);

    foreach my $family ( @{$database->families()} ) {
        my $styles = $database->styles($family);
        if (!$styles or ref $styles ne 'ARRAY') {
            next;
        }

        my $familyItem = Qt4::TreeWidgetItem(this->{ui}->fontTree);
        $familyItem->setText(0, $family);
        $familyItem->setCheckState(0, Qt4::Unchecked());

        foreach my $style (@{$styles}) {
            my $styleItem = Qt4::TreeWidgetItem($familyItem);
            $styleItem->setText(0, $style);
            $styleItem->setCheckState(0, Qt4::Unchecked());
            $styleItem->setData(0, Qt4::UserRole(),
                Qt4::Variant(Qt4::Int($database->weight($family, $style))));
            $styleItem->setData(0, Qt4::UserRole() + 1,
                Qt4::Variant(Qt4::Bool($database->italic($family, $style)?1:0)));
        }
    }
}

sub on_clearAction_triggered
{
    my $currentItem = this->{ui}->fontTree->currentItem();
    foreach my $item (@{this->{ui}->fontTree->selectedItems()}) {
        this->{ui}->fontTree->setItemSelected($item, 0);
    }
    this->{ui}->fontTree->setItemSelected($currentItem, 1);
}

sub on_markAction_triggered
{
    this->markUnmarkFonts(Qt4::Checked());
}

sub on_unmarkAction_triggered
{
    this->markUnmarkFonts(Qt4::Unchecked());
}

sub markUnmarkFonts
{
    my ($state) = @_;
    my $items = this->{ui}->fontTree->selectedItems();
    foreach my $item (@{$items}) {
        if ($item->checkState(0) != $state) {
            $item->setCheckState(0, $state);
        }
    }
}

sub showFont
{
    my ($item) = @_;
    if (!$item) {
        return;
    }

    my $family;
    my $style;
    my $weight;
    my $italic;

    if ($item->parent()) {
        $family = $item->parent()->text(0);
        $style = $item->text(0);
        $weight = $item->data(0, Qt4::UserRole())->toInt();
        $italic = $item->data(0, Qt4::UserRole() + 1)->toBool();
    } else {
        $family = $item->text(0);
        $style = $item->child(0)->text(0);
        $weight = $item->child(0)->data(0, Qt4::UserRole())->toInt();
        $italic = $item->child(0)->data(0, Qt4::UserRole() + 1)->toBool();
    }

    my $oldText = this->{ui}->textEdit->toPlainText();
    $oldText =~ s/[\s]+$//g;
    my $modified = this->{ui}->textEdit->document()->isModified();
    this->{ui}->textEdit->clear();
    this->{ui}->textEdit->document()->setDefaultFont(Qt4::Font($family, 32, $weight, $italic));

    my $cursor = this->{ui}->textEdit->textCursor();
    my $blockFormat = Qt4::TextBlockFormat();
    $blockFormat->setAlignment(Qt4::AlignCenter());
    $cursor->insertBlock($blockFormat);

    if ($modified) {
        $cursor->insertText($oldText);
    }
    else {
        $cursor->insertText("$family $style");
    }

    this->{ui}->textEdit->document()->setModified($modified);
}

sub updateStyles
{
    my ($item, $column) = @_;
    if (!$item || $column != 0) {
        return;
    }

    my $state = $item->checkState(0);
    my $parent = $item->parent();

    if ($parent) {

        # Only count style items.
        if ($state == Qt4::Checked()) {
            ++(this->{markedCount});
        }
        else {
            --(this->{markedCount});
        }

        if ($state == Qt4::Checked() &&
            $parent->checkState(0) == Qt4::Unchecked()) {
            # Mark parent items when child items are checked.
            $parent->setCheckState(0, Qt4::Checked());

        } elsif ($state == Qt4::Unchecked() &&
                 $parent->checkState(0) == Qt4::Checked()) {

            my $marked = 0;
            for (my $row = 0; $row < $parent->childCount(); ++$row) {
                if ($parent->child($row)->checkState(0) == Qt4::Checked()) {
                    $marked = 1;
                    last;
                }
            }
            # Unmark parent items when all child items are unchecked.
            if (!$marked) {
                $parent->setCheckState(0, Qt4::Unchecked());
            }
        }
    } else {
        my $row;
        my $number = 0;
        for ($row = 0; $row < $item->childCount(); ++$row) {
            if ($item->child($row)->checkState(0) == Qt4::Checked()) {
                ++$number;
            }
        }

        # Mark/unmark all child items when marking/unmarking top-level
        # items.
        if ($state == Qt4::Checked() && $number == 0) {
            for ($row = 0; $row < $item->childCount(); ++$row) {
                if ($item->child($row)->checkState(0) == Qt4::Unchecked()) {
                    $item->child($row)->setCheckState(0, Qt4::Checked());
                }
            }
        } elsif ($state == Qt4::Unchecked() && $number > 0) {
            for ($row = 0; $row < $item->childCount(); ++$row) {
                if ($item->child($row)->checkState(0) == Qt4::Checked()) {
                    $item->child($row)->setCheckState(0, Qt4::Unchecked());
                }
            }
        }
    }

    this->{ui}->printAction->setEnabled(this->markedCount > 0);
    this->{ui}->printPreviewAction->setEnabled(this->markedCount > 0);
}

sub on_printAction_triggered
{
    this->{pageMap} = this->currentPageMap();

    if (scalar keys %{this->pageMap} == 0) {
        return;
    }

    my $printer = Qt4::Printer(Qt4::Printer::HighResolution());
    my $dialog = Qt4::PrintDialog($printer, this);
    if ($dialog->exec() != Qt4::Dialog::Accepted()) {
        return;
    }

    my $from = $printer->fromPage();
    my $to = $printer->toPage();
    if ($from <= 0 && $to <= 0) {
        $printer->setFromTo(1, scalar keys %{this->pageMap});
    }

    this->printDocument($printer);
}

sub printDocument
{
    my ($printer) = @_;
    $printer->setFromTo(1, scalar keys %{this->pageMap});

    my $progress = Qt4::ProgressDialog(this->tr('Preparing font samples...'), this->tr('&Cancel'),
                             0, scalar keys %{this->pageMap}, this);
    $progress->setWindowModality(Qt4::ApplicationModal());
    $progress->setWindowTitle(this->tr('Font Sampler'));
    $progress->setMinimum($printer->fromPage() - 1);
    $progress->setMaximum($printer->toPage());

    my $painter = Qt4::Painter();
    $painter->begin($printer);
    my $firstPage = 1;

    for (my $page = $printer->fromPage(); $page <= $printer->toPage(); ++$page) {

        if (!$firstPage) {
            $printer->newPage();
        }

        qApp->processEvents();
        if ($progress->wasCanceled()) {
            last;
        }

        this->printPage($page - 1, $painter, $printer);
        $progress->setValue($page);
        $firstPage = 0;
    }

    $painter->end();
}

sub on_printPreviewAction_triggered
{
    this->{pageMap} = this->currentPageMap();

    if (scalar keys %{this->pageMap} == 0) {
        return;
    }

    my $printer = Qt4::Printer(Qt4::Printer::HighResolution());
    my $preview = Qt4::PrintPreviewDialog($printer, this);
    this->connect($preview, SIGNAL 'paintRequested(QPrinter *)',
            this, SLOT 'printDocument(QPrinter *)');
    $preview->exec();
}

sub currentPageMap
{
    my %pageMap;

    for (my $row = 0; $row < this->{ui}->fontTree->topLevelItemCount(); ++$row) {
        my $familyItem = this->{ui}->fontTree->topLevelItem($row);
        my $family;

        if ($familyItem->checkState(0) == Qt4::Checked()) {
            $family = $familyItem->text(0);
            $pageMap{$family} = [];
        }

        for (my $childRow = 0; $childRow < $familyItem->childCount(); ++$childRow) {
            my $styleItem = $familyItem->child($childRow);
            if ($styleItem->checkState(0) == Qt4::Checked()) {
                push @{$pageMap{$family}}, $styleItem;
            }
        }
    }

    return \%pageMap;
}

sub printPage
{
    my ($index, $painter, $printer) = @_;
    my $family = (keys %{this->pageMap})[$index];
    my @items = @{this->pageMap->{$family}};

    # Find the dimensions of the text on each page.
    my $width = 0.0;
    my $height = 0.0;
    foreach my $item (@items) {
        my $style = $item->text(0);
        my $weight = $item->data(0, Qt4::UserRole())->toInt();
        my $italic = $item->data(0, Qt4::UserRole() + 1)->toBool();

        # Calculate the maximum width and total height of the text.
        foreach my $size ( @{this->sampleSizes} ) {
            my $font = Qt4::Font($family, $size, $weight, $italic);
            $font = Qt4::Font($font, $painter->device());
            my $fontMetrics = Qt4::FontMetricsF($font);
            my $rect = $fontMetrics->boundingRect( "$family $style" );
            $width = max($rect->width(), $width);
            $height += $rect->height();
        }
    }

    my $xScale = $printer->pageRect()->width() / $width;
    my $yScale = $printer->pageRect()->height() / $height;
    my $scale = min($xScale, $yScale);

    my $remainingHeight = $printer->pageRect()->height()/$scale - $height;
    my $spaceHeight = ($remainingHeight/4.0) / scalar @items + 1;
    my $interLineHeight = ($remainingHeight/4.0) / (scalar @{this->sampleSizes} * scalar @items);

    $painter->save();
    $painter->translate($printer->pageRect()->width()/2.0, $printer->pageRect()->height()/2.0);
    $painter->scale($scale, $scale);
    $painter->setBrush(Qt4::Brush(Qt4::black()));

    my $x = -$width/2.0;
    my $y = -$height/2.0 - $remainingHeight/4.0 + $spaceHeight;

    foreach my $item (@items) {
        my $style = $item->text(0);
        my $weight = $item->data(0, Qt4::UserRole())->toInt();
        my $italic = $item->data(0, Qt4::UserRole() + 1)->toBool();

        # Draw each line of text.
        foreach my $size (@{this->sampleSizes}) {
            my $font = Qt4::Font($family, $size, $weight, $italic);
            $font = Qt4::Font($font, $painter->device());
            my $fontMetrics = Qt4::FontMetricsF($font);
            my $rect = $fontMetrics->boundingRect( "$family $style" );
            $y += $rect->height();
            $painter->setFont($font);
            $painter->drawText(Qt4::PointF($x, $y),
                             "$family $style");
            $y += $interLineHeight;
        }
        $y += $spaceHeight;
    }

    $painter->restore();
}

1;
