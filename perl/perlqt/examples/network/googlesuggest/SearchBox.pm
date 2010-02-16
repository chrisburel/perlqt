package SearchBox;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::LineEdit );
use Qt4::slots
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
    Qt4::DesktopServices::openUrl(Qt4::Url($url));
}

1;
