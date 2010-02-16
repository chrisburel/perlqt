
use strict;
use warnings;
use ExtUtils::MakeMaker;

my $perl = $ARGV[0];

my $mm = ExtUtils::MakeMaker->new( {
    NAME => 'PerlQt',
    NEEDS_LINKING => 1,
} );

my $perl_include_path = $mm->{PERL_INC};
my @xsubinfo = split "\n", $mm->tool_xsubpp();

my $xsubppdir = (map{ my $foo = $_; $foo =~ s/XSUBPPDIR = //; $foo } grep{ m/^XSUBPPDIR =/ } @xsubinfo)[0];
my $xsubpp = "$xsubppdir/xsubpp";

my $xsubppargs = (map{ my $foo = $_; $foo =~ s/XSUBPPARGS = //; $foo } grep{ m/^XSUBPPARGS =/ } @xsubinfo)[0];

my $cmd = "$perl $xsubpp $xsubppargs Qt.xs > Qt.c";
print "cmd is $cmd\n";
system $cmd;
