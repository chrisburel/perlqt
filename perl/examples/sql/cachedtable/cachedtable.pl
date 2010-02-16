#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use Connection;
use TableEditor;

# [0]
sub main
{
    my $app = Qt4::Application(\@ARGV);
    if (!Connection::createConnection()) {
        return 1;
    }

    my $editor = TableEditor('person');
    $editor->show();
    return $editor->exec();
}
# [0]

exit main();
