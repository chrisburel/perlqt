#!/usr/bin/perl

package MainWindowsMDITest;

use strict;
use warnings;

use QtCore4;
use QtGui4;
use QtTest4;
use MainWindow;
use QtCore4::isa qw(Qt::Object);
use QtCore4::slots
    initTestCase => [],
    testSave => [],
    testFocus => [];
use Test::More;

sub NEW {
    my ($class, $parent) = @_;
    $class->SUPER::NEW();
}

sub testSave {
    my $mainWin = this->{mainWin};
    $mainWin->newFile();
    my $activeWindow = $mainWin->activeMdiChild();
    my $text = 'Hello, World!';
    Qt::Test::keyClicks($activeWindow, $text, Qt::NoModifier(), 10);

    my $filename = 'MdiTestFile';
    $activeWindow->saveFile($filename);

    open my $fh, '<', $filename;
    my $result = <$fh>;
    close $fh;

    #Qt::Test::qVerify($text eq $result,
        #(caller(0))[0],
        #'File not written successfully',
        #(caller(0))[1],
        #(caller(0))[2]);
    is( $result, $text, 'File write contents' );

    unlink $filename;
    $activeWindow->parent->close();
}

sub testFocus {
    my $mainWin = this->{mainWin};
    $mainWin->newFile();
    my $child1 = $mainWin->activeMdiChild();
    $mainWin->newFile();
    my $child2 = $mainWin->activeMdiChild();

    my ($windowMenu) = grep{ $_->title && $_->title eq '&Window' }
        @{ $mainWin->menuBar->findChildren('Qt::Menu') };

    Qt::Test::qWaitForWindowShown($child2);

    foreach my $winId ( 1, 2, 1, 2 ) {
        Qt::Test::keyClicks($mainWin, 'w', Qt::ALT());
        Qt::Test::qWaitForWindowShown($windowMenu);
        Qt::Test::keyClicks($windowMenu, $winId);
        Qt::Test::qWait(100);

        my $child;
        if ( $winId == 1 ) {
            $child = $child1;
        }
        else {
            $child = $child2;
        }

        #Qt::Test::qVerify($mainWin->activeMdiChild() eq $child,
            #(caller(0))[0],
            #'Focus is incorrect',
            #(caller(0))[1],
            #(caller(0))[2]);
        ok( $mainWin->activeMdiChild() eq $child, 'Widget focus' );
        Qt::Test::qWait(200);
    }
    $child1->parent()->close();
    $child2->parent()->close();
}

sub initTestCase {
    my $mainWin = MainWindow();
    $mainWin->show();
    this->{mainWin} = $mainWin;
}

package main;

use strict;
use warnings;

use QtCore4;
use QtGui4;
use QtTest4;
use MainWindowsMDITest;
use Test::More tests=>5;

sub main {
    unshift @ARGV, $0;
    my $app = Qt::Application(\@ARGV);
    my $test = MainWindowsMDITest();
    return Qt::Test::qExec($test,scalar @ARGV, \@ARGV);
}

exit main();
