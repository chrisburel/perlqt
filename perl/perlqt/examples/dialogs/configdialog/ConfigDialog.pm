package ConfigDialog;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    changePage => ['QListWidgetItem *', 'QListWidgetItem *'];

use Pages;
use ConfigurationPage;
use UpdatePage;
use QueryPage;

sub NEW {
    shift->SUPER::NEW();
    my $contentsWidget = Qt4::ListWidget();
    this->{contentsWidget} = $contentsWidget;
    $contentsWidget->setViewMode(Qt4::ListView::IconMode());
    $contentsWidget->setIconSize(Qt4::Size(96, 84));
    $contentsWidget->setMovement(Qt4::ListView::Static());
    $contentsWidget->setMaximumWidth(128);
    $contentsWidget->setSpacing(12);

    my $pagesWidget = Qt4::StackedWidget();
    this->{pagesWidget} = $pagesWidget;
    $pagesWidget->addWidget(ConfigurationPage());
    $pagesWidget->addWidget(UpdatePage());
    $pagesWidget->addWidget(QueryPage());

    my $closeButton = Qt4::PushButton(this->tr('Close'));

    createIcons();
    $contentsWidget->setCurrentRow(0);

    this->connect($closeButton, SIGNAL 'clicked()', this, SLOT 'close()');

    my $horizontalLayout = Qt4::HBoxLayout();
    $horizontalLayout->addWidget($contentsWidget);
    $horizontalLayout->addWidget($pagesWidget, 1);

    my $buttonsLayout = Qt4::HBoxLayout();
    $buttonsLayout->addStretch(1);
    $buttonsLayout->addWidget($closeButton);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addLayout($horizontalLayout);
    $mainLayout->addStretch(1);
    $mainLayout->addSpacing(12);
    $mainLayout->addLayout($buttonsLayout);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Config Dialog'));
}

sub createIcons {
    my $contentsWidget = this->{contentsWidget};

    my $configButton = Qt4::ListWidgetItem($contentsWidget);
    $configButton->setIcon(Qt4::Icon('images/config.png'));
    $configButton->setText(this->tr('Configuration'));
    $configButton->setTextAlignment(Qt4::AlignHCenter());
    $configButton->setFlags(Qt4::ItemIsSelectable() | Qt4::ItemIsEnabled());

    my $updateButton = Qt4::ListWidgetItem($contentsWidget);
    $updateButton->setIcon(Qt4::Icon('images/update.png'));
    $updateButton->setText(this->tr('Update'));
    $updateButton->setTextAlignment(Qt4::AlignHCenter());
    $updateButton->setFlags(Qt4::ItemIsSelectable() | Qt4::ItemIsEnabled());

    my $queryButton = Qt4::ListWidgetItem($contentsWidget);
    $queryButton->setIcon(Qt4::Icon('images/query.png'));
    $queryButton->setText(this->tr('Query'));
    $queryButton->setTextAlignment(Qt4::AlignHCenter());
    $queryButton->setFlags(Qt4::ItemIsSelectable() | Qt4::ItemIsEnabled());

    this->connect($contentsWidget,
            SIGNAL 'currentItemChanged(QListWidgetItem *, QListWidgetItem *)',
            this, SLOT 'changePage(QListWidgetItem *, QListWidgetItem*)');
}

sub changePage {
    my ($current, $previous) = @_;
    if (!$current) {
        $current = $previous;
    }

    this->{pagesWidget}->setCurrentIndex(this->{contentsWidget}->row($current));
}

1;
