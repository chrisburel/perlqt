package GeneralTab;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub NEW {
    my ( $class, $fileInfo, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $fileNameLabel = Qt4::Label(this->tr('File Name:'));
    my $fileNameEdit = Qt4::LineEdit($fileInfo->fileName());

    my $pathLabel = Qt4::Label(this->tr('Path:'));
    my $pathValueLabel = Qt4::Label($fileInfo->absoluteFilePath());
    $pathValueLabel->setFrameStyle(Qt4::Frame::Panel() | Qt4::Frame::Sunken());

    my $sizeLabel = Qt4::Label(this->tr('Size:'));
    my $size = $fileInfo->size()/1024;
    my $sizeValueLabel = Qt4::Label(this->tr(sprintf '%d K', $size));
    $sizeValueLabel->setFrameStyle(Qt4::Frame::Panel() | Qt4::Frame::Sunken());

    my $lastReadLabel = Qt4::Label(this->tr('Last Read:'));
    my $lastReadValueLabel = Qt4::Label($fileInfo->lastRead()->toString());
    $lastReadValueLabel->setFrameStyle(Qt4::Frame::Panel() | Qt4::Frame::Sunken());

    my $lastModLabel = Qt4::Label(this->tr('Last Modified:'));
    my $lastModValueLabel = Qt4::Label($fileInfo->lastModified()->toString());
    $lastModValueLabel->setFrameStyle(Qt4::Frame::Panel() | Qt4::Frame::Sunken());

    my $mainLayout = Qt4::VBoxLayout;
    $mainLayout->addWidget($fileNameLabel);
    $mainLayout->addWidget($fileNameEdit);
    $mainLayout->addWidget($pathLabel);
    $mainLayout->addWidget($pathValueLabel);
    $mainLayout->addWidget($sizeLabel);
    $mainLayout->addWidget($sizeValueLabel);
    $mainLayout->addWidget($lastReadLabel);
    $mainLayout->addWidget($lastReadValueLabel);
    $mainLayout->addWidget($lastModLabel);
    $mainLayout->addWidget($lastModValueLabel);
    $mainLayout->addStretch(1);
    this->setLayout($mainLayout);
}

package PermissionsTab;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub NEW {
    my ( $class, $fileInfo, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $permissionsGroup = Qt4::GroupBox(this->tr('Permissions'));

    my $readable = Qt4::CheckBox(this->tr('Readable'));
    $readable->setChecked(1) if ($fileInfo->isReadable());
        
    my $writable = Qt4::CheckBox(this->tr('Writable'));
    $writable->setChecked(1) if ( $fileInfo->isWritable() );

    my $executable = Qt4::CheckBox(this->tr('Executable'));
    $executable->setChecked(1) if ( $fileInfo->isExecutable() );

    my $ownerGroup = Qt4::GroupBox(this->tr('Ownership'));

    my $ownerLabel = Qt4::Label(this->tr('Owner'));
    my $ownerValueLabel = Qt4::Label($fileInfo->owner());
    $ownerValueLabel->setFrameStyle(Qt4::Frame::Panel() | Qt4::Frame::Sunken());

    my $groupLabel = Qt4::Label(this->tr('Group'));
    my $groupValueLabel = Qt4::Label($fileInfo->group());
    $groupValueLabel->setFrameStyle(Qt4::Frame::Panel() | Qt4::Frame::Sunken());

    my $permissionsLayout = Qt4::VBoxLayout();
    $permissionsLayout->addWidget($readable);
    $permissionsLayout->addWidget($writable);
    $permissionsLayout->addWidget($executable);
    $permissionsGroup->setLayout($permissionsLayout);

    my $ownerLayout = Qt4::VBoxLayout();
    $ownerLayout->addWidget($ownerLabel);
    $ownerLayout->addWidget($ownerValueLabel);
    $ownerLayout->addWidget($groupLabel);
    $ownerLayout->addWidget($groupValueLabel);
    $ownerGroup->setLayout($ownerLayout);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($permissionsGroup);
    $mainLayout->addWidget($ownerGroup);
    $mainLayout->addStretch(1);
    this->setLayout($mainLayout);
}

package ApplicationsTab;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub NEW {
    my ( $class, $fileInfo, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $topLabel = Qt4::Label(this->tr('Open with:'));

    my $applicationsListBox = Qt4::ListWidget();
    my @applications = map{ "Application $_" } ( 0..30 );

    $applicationsListBox->insertItems(0, \@applications);

    my $alwaysCheckBox;

    if (!$fileInfo->suffix()) {
        $alwaysCheckBox = Qt4::CheckBox(this->tr('Always use this application to ' .
            'open this type of file'));
    }
    else {
        $alwaysCheckBox = Qt4::CheckBox(this->tr('Always use this application to ' .
            'open files with the extension \'' . $fileInfo->suffix() . '\''));
    }

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget($topLabel);
    $layout->addWidget($applicationsListBox);
    $layout->addWidget($alwaysCheckBox);
    this->setLayout($layout);
}

package TabDialog;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Dialog );
use GeneralTab;
use PermissionsTab;
use ApplicationsTab;

sub NEW {
    my ( $class, $fileName, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $fileInfo = Qt4::FileInfo($fileName);

    my $tabWidget = Qt4::TabWidget();
    this->{tabWidget} = $tabWidget;
    $tabWidget->addTab(GeneralTab($fileInfo), this->tr('General'));
    $tabWidget->addTab(PermissionsTab($fileInfo), this->tr('Permissions'));
    $tabWidget->addTab(ApplicationsTab($fileInfo), this->tr('Applications'));

    my $buttonBox = Qt4::DialogButtonBox(Qt4::DialogButtonBox::Ok()
                                      | Qt4::DialogButtonBox::Cancel());
    this->{buttonBox} = $buttonBox;

    this->connect($buttonBox, SIGNAL 'accepted()', this, SLOT 'accept()');
    this->connect($buttonBox, SIGNAL 'rejected()', this, SLOT 'reject()');

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($tabWidget);
    $mainLayout->addWidget($buttonBox);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Tab Dialog'));
}

1;
