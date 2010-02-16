#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use CodeEditor;

sub main {
    my $app = Qt4::Application( \@ARGV );

    my $editor = CodeEditor();
    $editor->setWindowTitle(Qt4::Object::tr('Code Editor Example'));
    $editor->show();

    exit $app->exec();
}

main();
