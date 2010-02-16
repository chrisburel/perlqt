package GSuggestCompletion;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Object );
use Qt4::slots
    doneCompletion => [],
    preventSuggest => [],
    autoSuggest => [],
    handleNetworkData => ['QNetworkReply *'];
use List::Util qw(min);

sub editor() {
    return this->{editor};
}

sub popup() {
    return this->{popup};
}

sub timer() {
    return this->{timer};
}

sub networkManager() {
    return this->{networkManager};
}

use constant GSUGGEST_URL => 'http://google.com/complete/search?output=toolbar&q=%s';

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{networkManager} = Qt4::NetworkAccessManager();
    this->{editor} = $parent;
    this->{popup} = Qt4::TreeWidget();
    this->popup->setColumnCount(2);
    this->popup->setUniformRowHeights(1);
    this->popup->setRootIsDecorated(0);
    this->popup->setEditTriggers(Qt4::TreeWidget::NoEditTriggers());
    this->popup->setSelectionBehavior(Qt4::TreeWidget::SelectRows());
    this->popup->setFrameStyle(Qt4::Frame::Box() | Qt4::Frame::Plain());
    this->popup->setHorizontalScrollBarPolicy(Qt4::ScrollBarAlwaysOff());

    this->popup->header()->hide();
    this->popup->installEventFilter(this);
    this->popup->setMouseTracking(1);

    this->connect(this->popup, SIGNAL 'itemClicked(QTreeWidgetItem*, int)',
            SLOT 'doneCompletion()');

    this->popup->setWindowFlags(Qt4::Popup());
    this->popup->setFocusPolicy(Qt4::NoFocus());
    this->popup->setFocusProxy($parent);

    this->{timer} = Qt4::Timer(this);
    this->timer->setSingleShot(1);
    this->timer->setInterval(500);
    this->connect(this->timer, SIGNAL 'timeout()', SLOT 'autoSuggest()');
    this->connect(this->editor, SIGNAL 'textEdited(QString)', timer, SLOT 'start()');

    this->connect(this->networkManager, SIGNAL 'finished(QNetworkReply*)',
            this, SLOT 'handleNetworkData(QNetworkReply*)');

}

sub eventFilter
{
    my ($obj, $ev) = @_;
    if (!($obj eq this->popup)) {
        return 0;
    }

    if ($ev->type() == Qt4::Event::MouseButtonPress()) {
        this->popup->hide();
        this->editor->setFocus();
        return 1;
    }

    if ($ev->type() == Qt4::Event::KeyPress()) {

        my $consumed = 0;
        my $key = $ev->key();
        if ( $key == Qt4::Key_Enter() || $key == Qt4::Key_Return() ) {
            this->doneCompletion();
            $consumed = 1;
        }

        if ( $key == Qt4::Key_Escape() ) {
            this->editor->setFocus();
            this->popup->hide();
            $consumed = 1;
        }

        if ( $key == Qt4::Key_Up() ||
             $key == Qt4::Key_Down() ||
             $key == Qt4::Key_Home() ||
             $key == Qt4::Key_End() ||
             $key == Qt4::Key_PageUp() ||
             $key == Qt4::Key_PageDown() ) {
        }
        else {
            this->editor->setFocus();
            this->editor->event($ev);
            this->popup->hide();
        }

        return $consumed;
    }

    return 0;
}

sub showCompletion
{
    my ($choices, $hits) = @_;
    #my (const Qt4::StringList &choices, const Qt4::StringList &hits)

    if (!defined $choices || !(ref $choices eq 'ARRAY') || scalar @{$choices} != scalar @{$hits}) {
        return;
    }

    my $pal = this->editor->palette();
    my $color = $pal->color(Qt4::Palette::Disabled(), Qt4::Palette::WindowText());

    this->popup->setUpdatesEnabled(0);
    this->popup->clear();
    for (my $i = 0; $i < scalar @{$choices}; ++$i) {
        my $item = Qt4::TreeWidgetItem(this->popup);
        $item->setText(0, $choices->[$i]);
        $item->setText(1, $hits->[$i]);
        $item->setTextAlignment(1, Qt4::AlignRight());
        $item->setTextColor(1, $color);
    }
    this->popup->setCurrentItem(this->popup->topLevelItem(0));
    this->popup->resizeColumnToContents(0);
    this->popup->resizeColumnToContents(1);
    this->popup->adjustSize();
    this->popup->setUpdatesEnabled(1);

    my $h = this->popup->sizeHintForRow(0) * min(7, scalar @{$choices}) + 3;
    this->popup->resize(this->popup->width(), $h);

    this->popup->move(this->editor->mapToGlobal(Qt4::Point(0, this->editor->height())));
    this->popup->setFocus();
    this->popup->show();
}

sub doneCompletion
{
    this->timer->stop();
    this->popup->hide();
    this->editor->setFocus();
    my $item = this->popup->currentItem();
    if ($item) {
        this->editor->setText($item->text(0));
        my $e = Qt4::KeyEvent(Qt4::Event::KeyPress(), Qt4::Key_Enter(), Qt4::NoModifier());
        Qt4::Application::postEvent(this->editor, $e);
        $e = Qt4::KeyEvent(Qt4::Event::KeyRelease(), Qt4::Key_Enter(), Qt4::NoModifier());
        Qt4::Application::postEvent(this->editor, $e);
    }
}

sub preventSuggest
{
    this->timer->stop();
}

sub autoSuggest
{
    my $str = this->editor->text();
    my $url = sprintf GSUGGEST_URL, $str;
    this->networkManager->get(Qt4::NetworkRequest(Qt4::Url($url)));
}

sub handleNetworkData
{
    my ($networkReply) = @_;
    my $url = $networkReply->url();
    if ($networkReply->error() == Qt4::NetworkReply::NoError()) {
        my @choices;
        my @hits;

        my $response = $networkReply->readAll();
        # Eventually the code should do the following.  But Smoke is missing
        # XmlStreamReader.
        #my $xml = Qt4::XmlStreamReader($response);
        #while (!$xml->atEnd()) {
            #$xml->readNext();
            #if ($xml->tokenType() == Qt4::XmlStreamReader::StartElement()) {
                #if ($xml->name() eq 'suggestion') {
                    #my $str = $xml->attributes()->value('data');
                    #push @choices, $str->toString();
                #}
            #}
            #if ($xml->tokenType() == Qt4::XmlStreamReader::StartElement()) {
                #if ($xml->name() eq 'num_queries') {
                    #my $str = $xml->attributes()->value('int');
                    #push @hits, $str->toString();
                #}
            #}
        #}
        my @xml = split "\n", $response->data();
        @xml = grep{ $_ =~ m/CompleteSuggestion/ } @xml;
        foreach my $line ( @xml ) {
            my ($choice, $hits) = $line =~ m/.*suggestion data="(.*)"\/><num_queries int="(.*)"\/>/;
            push @choices, $choice;
            push @hits, $hits;
        }

        this->showCompletion(\@choices, \@hits);
    }

    $networkReply->deleteLater();
}

1;
