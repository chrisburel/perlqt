package HelpBrowser;

use strict;
use warnings;
use Qt4;

use Qt4::isa qw( Qt4::TextBrowser );

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);

    my $collectionFile = Qt4::LibraryInfo::location(Qt4::LibraryInfo::ExamplesPath())
        . '/help/contextsensitivehelp/doc/wateringmachine.qhc';

    this->{m_helpEngine} = Qt4::HelpEngineCore($collectionFile, this);
    if (!this->{m_helpEngine}->setupData()) {
        this->{m_helpEngine} = 0;
    }
}

sub showHelpForKeyword
{
    my ($id) = @_;
    if (this->{m_helpEngine}) {
        #Qt4::Map<Qt4::String, Qt4::Url> links = this->{m_helpEngine}->linksForIdentifier(id);
        my $links = this->{m_helpEngine}->linksForIdentifier($id);
        if ($links && ref $links eq 'ARRAY') {
            this->setSource($links->[0]->value());
        }
    }
}

sub loadResource
{
    my ($type, $name) = @_;
    my $ba = Qt4::ByteArray();
    if ($type < 4 && this->{m_helpEngine}) {
        my $url = Qt4::Url($name);
        if ($name->isRelative()) {
            $url = this->source()->resolved($url);
        }
        $ba = this->{m_helpEngine}->fileData($url);
    }
    return Qt::Variant($ba);
}

1;
