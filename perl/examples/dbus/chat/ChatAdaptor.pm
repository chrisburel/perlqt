package ChatAdaptor;

use strict;
use warnings;
use Qt;
use Qt::isa qw( Qt::DBusAbstractAdaptor );
use Qt::classinfo
    'D-Bus Interface' => 'com.trolltech.chat',
    'D-Bus Introspection' => '' .
"  <interface name=\'com.trolltech.chat\' >\n" .
"    <signal name=\'message\' >\n" .
"      <arg direction=\'out\' type=\'s\' name=\'nickname\' />\n" .
"      <arg direction=\'out\' type=\'s\' name=\'text\' />\n" .
"    </signal>\n" .
"    <signal name=\'action\' >\n" .
"      <arg direction=\'out\' type=\'s\' name=\'nickname\' />\n" .
"      <arg direction=\'out\' type=\'s\' name=\'text\' />\n" .
"    </signal>\n" .
"  </interface>\n" .
        '';
use Qt::signals
    action => ['const QString &', 'const QString &'],
    message => ['const QString &', 'const QString &'];

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->setAutoRelaySignals(1);
}

1;
