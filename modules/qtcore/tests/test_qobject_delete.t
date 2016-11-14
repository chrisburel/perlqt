use strict;
use warnings;
use PerlQt5::QtCore;
use SmokePerl;
use Test::More tests => 7;

sub makeObjectWithChild {
    my $parent = PerlQt5::QtCore::QObject->new();
    my $child = PerlQt5::QtCore::QObject->new($parent);
    my $grandchild = PerlQt5::QtCore::QObject->new($child);
    return (
        $parent,
        SmokePerl::getCppPointer($child),
        SmokePerl::getCppPointer($grandchild),
    );
}

sub main {
    my ($parent, $childPointer, $grandchildPointer) = makeObjectWithChild();

    # The child and grandchild should still be in the object map, because we
    # still have a reference to the parent
    ok($childPointer, 'Child pointer retrieved');
    ok(SmokePerl::getInstance($childPointer), 'Child still exists');

    ok($grandchildPointer, 'Grandchild pointer retrieved');
    ok(SmokePerl::getInstance($grandchildPointer), 'Grandchild still exists');

    return (
        SmokePerl::getCppPointer($parent),
        $childPointer,
        $grandchildPointer,
    );
}

my ($parentPointer, $childPointer, $grandchildPointer) = main();
# The objects should no longer be in the object map
foreach my $ptr ($parentPointer, $childPointer, $grandchildPointer) {
    ok(!SmokePerl::getInstance($ptr));
}
