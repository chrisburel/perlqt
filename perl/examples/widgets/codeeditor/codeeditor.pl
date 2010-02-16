#!/usr/bin/perl

use strict;
use warnings;

use Qt;
use CodeEditor;

sub main {
    my $app = Qt::Application( \@ARGV );

    my $editor = CodeEditor();
    $editor->setWindowTitle(Qt::Object::tr('Code Editor Example'));
    $editor->show();

    exit $app->exec();
}

main();
