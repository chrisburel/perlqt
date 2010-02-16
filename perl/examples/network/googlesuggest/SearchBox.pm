package SearchBox;

use strict;
use warnings;
use Qt;
use Qt::isa qw( Qt::LineEdit );
use Qt::slots
    doSearch => [];

sub completer() {
    return this->{completer};
}

use GSuggestCompletion;

use constant GSEARCH_URL => 'http://www.google.com/search?q=%s';

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{completer} = GSuggestCompletion(this);

    this->connect(this, SIGNAL 'returnPressed()', SLOT 'doSearch()');

    this->setWindowTitle('Search with Google');

    this->adjustSize();
    this->resize(400, this->height());
    this->setFocus();
}

sub doSearch
{
    this->completer->preventSuggest();
    my $url = sprintf GSEARCH_URL, this->text();
    Qt::DesktopServices::openUrl(Qt::Url($url));
}

1;
