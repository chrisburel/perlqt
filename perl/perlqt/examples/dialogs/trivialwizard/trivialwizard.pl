#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

# [0] //! [1]
sub createIntroPage {
    my $page = Qt4::WizardPage();
    $page->setTitle('Introduction');

    my $label = Qt4::Label('This wizard will help you register your copy ' .
                               'of Super Product Two.');
    $label->setWordWrap(1);

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget($label);
    $page->setLayout($layout);

    return $page;
}
# [0]

# [2]
sub createRegistrationPage {
# [1] //! [3]
# [3]
    my $page = Qt4::WizardPage();
    $page->setTitle('Registration');
    $page->setSubTitle('Please fill both fields.');

    my $nameLabel = Qt4::Label('Name:');
    my $nameLineEdit = Qt4::LineEdit();

    my $emailLabel = Qt4::Label('Email address:');
    my $emailLineEdit = Qt4::LineEdit();

    my $layout = Qt4::GridLayout();
    $layout->addWidget($nameLabel, 0, 0);
    $layout->addWidget($nameLineEdit, 0, 1);
    $layout->addWidget($emailLabel, 1, 0);
    $layout->addWidget($emailLineEdit, 1, 1);
    $page->setLayout($layout);

    return $page;
# [4]
}
# [2] //! [4]

# [5] //! [6]
sub createConclusionPage {
# [5] //! [7]
# [7]
    my $page = Qt4::WizardPage();
    $page->setTitle('Conclusion');

    my $label = Qt4::Label('You are now successfully registered. Have a ' .
                               'nice day!');
    $label->setWordWrap(1);

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget($label);
    $page->setLayout($layout);

    return $page;
# [8]
}
# [6] //! [8]

# [9] //! [10]
sub main {
# [9] //! [11]
    my $app = Qt4::Application( \@ARGV );

    my $translatorFileName = 'qt_';
    $translatorFileName .= Qt4::Locale::system()->name();
    my $translator = Qt4::Translator($app);
    if ($translator->load($translatorFileName, Qt4::LibraryInfo::location(Qt4::LibraryInfo::TranslationsPath()))) {
        $app->installTranslator($translator);
    }

    my $wizard = Qt4::Wizard();
    $wizard->addPage(createIntroPage());
    $wizard->addPage(createRegistrationPage());
    $wizard->addPage(createConclusionPage());

    $wizard->setWindowTitle('Trivial Wizard');
    $wizard->show();

    exit $app->exec();
}
# [10] //! [11]

main();
