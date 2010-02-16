#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

# [1] //! [2]
sub main
# [1] //! [3] //! [4]
{
    my $app = Qt4::Application(\@ARGV);
# [3]

# [5]
    my $translator = Qt4::Translator();
# [5] //! [6]
    $translator->load('hellotr_la');
# [6] //! [7]
    $app->installTranslator($translator);
# [4] //! [7]

# [8]
    my $hello = Qt4::PushButton(Qt4::PushButton::tr("Hello world!"));
# [8]
    $hello->resize(100, 30);

    $hello->show();
    return $app->exec();
}
# [2]

exit main();
