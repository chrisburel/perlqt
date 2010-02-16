package ComTrolltechChatInterface;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::DBusAbstractInterface );

sub staticInterfaceName {
    return 'com.trolltech.chat';
}

use Qt4::signals
    action => ['const QString &', 'const QString &' ],
    message => ['const QString &', 'const QString &' ];

sub NEW
{
    my ($class, $service, $path, $connection, $parent) = @_;
    $class->SUPER::NEW($service, $path, staticInterfaceName(), $connection, $parent);
}

1;
