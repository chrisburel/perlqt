#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use AddressBook;

# [main function]
sub main
{
    my $app = Qt4::Application(\@ARGV);

    my $addressBook = AddressBook();
    $addressBook->show();

    return $app->exec();
}
# [main function]

exit main();
