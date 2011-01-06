#!/usr/bin/perl

use strict;
use warnings;

use KDEUi4;
use Qt::GlobalSpace qw( i18n ki18n );

sub main
{
    my $aboutData = KDE::AboutData(
                         # The program name used internally.
                         Qt::ByteArray( 'tutorial1' ),
                         # The message catalog name
                         # If null, program name is used instead.
                         Qt::ByteArray(),
                         # A displayable program name string.
                         ki18n('Tutorial 1'),
                         # The program version string.
                         Qt::ByteArray( '1.0' ),
                         # Short description of what the app does.
                         ki18n('Displays a KMessageBox popup'),
                         # The license this code is released under
                         KDE::AboutData::License_GPL(),
                         # Copyright Statement
                         ki18n('(c) 2007'),
                         # Optional text shown in the About box.
                         # Can contain any information desired.
                         ki18n('Some text...'),
                         # The program homepage string.
                         Qt::ByteArray( 'http://tutorial.com/' ),
                         # The bug report email address
                         Qt::ByteArray( 'submit@bugs.kde.org' ) );
 
    
    KDE::CmdLineArgs::init( scalar @ARGV, \@ARGV, $aboutData );
    my $app = KDE::Application();
    my $yesButton = KDE::GuiItem( i18n( 'Hello' ), '',
                        i18n( 'This is a tooltip' ),
                        i18n( 'This is a WhatsThis help text.' ) );
    KDE::MessageBox::questionYesNo( undef, i18n( 'Hello World' ),
                                i18n( 'Hello' ), $yesButton );
    return 0;
}

exit main();
