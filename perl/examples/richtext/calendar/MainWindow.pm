package MainWindow;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    setFontSize => ['int'],
    setMonth => ['int'],
    setYear => ['QDate'];

sub fontSize() {
    return this->{fontSize};
}

sub selectedDate() {
    return this->{selectedDate};
}

sub editor() {
    return this->{editor};
}

# [0]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->{selectedDate} = Qt4::Date::currentDate();
    this->{fontSize} = 10;

    my $centralWidget = Qt4::Widget();
# [0]

# [1]
    my $dateLabel = Qt4::Label(this->tr('Date:'));
    my $monthCombo = Qt4::ComboBox();

    for (my $month = 1; $month <= 12; ++$month) {
        $monthCombo->addItem(Qt4::Date::longMonthName($month));
    }

    my $yearEdit = Qt4::DateTimeEdit();
    $yearEdit->setDisplayFormat('yyyy');
    $yearEdit->setDateRange(Qt4::Date(1753, 1, 1), Qt4::Date(8000, 1, 1));
# [1]

    $monthCombo->setCurrentIndex(this->selectedDate->month() - 1);
    $yearEdit->setDate(this->selectedDate);

# [2]
    my $fontSizeLabel = Qt4::Label(this->tr('Font size:'));
    my $fontSizeSpinBox = Qt4::SpinBox();
    $fontSizeSpinBox->setRange(1, 64);
    $fontSizeSpinBox->setValue(10);

    this->{editor} = Qt4::TextBrowser();
    this->insertCalendar();
# [2]

# [3]
    this->connect($monthCombo, SIGNAL 'activated(int)', this, SLOT 'setMonth(int)');
    this->connect($yearEdit, SIGNAL 'dateChanged(QDate)', this, SLOT 'setYear(QDate)');
    this->connect($fontSizeSpinBox, SIGNAL 'valueChanged(int)',
            this, SLOT 'setFontSize(int)');
# [3]

# [4]
    my $controlsLayout = Qt4::HBoxLayout();
    $controlsLayout->addWidget($dateLabel);
    $controlsLayout->addWidget($monthCombo);
    $controlsLayout->addWidget($yearEdit);
    $controlsLayout->addSpacing(24);
    $controlsLayout->addWidget($fontSizeLabel);
    $controlsLayout->addWidget($fontSizeSpinBox);
    $controlsLayout->addStretch(1);

    my $centralLayout = Qt4::VBoxLayout();
    $centralLayout->addLayout($controlsLayout);
    $centralLayout->addWidget(this->editor, 1);
    $centralWidget->setLayout($centralLayout);

    this->setCentralWidget($centralWidget);
# [4]
}

# [5]
sub insertCalendar
{
    this->editor->clear();
    my $cursor = this->editor->textCursor();
    $cursor->beginEditBlock();

    my $date = Qt4::Date(this->selectedDate->year(), this->selectedDate->month(), 1);
# [5]

# [6]
    my $tableFormat = Qt4::TextTableFormat();
    $tableFormat->setAlignment(Qt4::AlignHCenter());
    $tableFormat->setBackground(Qt4::Brush(Qt4::Color(Qt4::String('#e0e0e0'))));
    $tableFormat->setCellPadding(2);
    $tableFormat->setCellSpacing(4);
# [6] //! [7]
    my @constraints = (
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
        Qt4::TextLength(Qt4::TextLength::PercentageLength(), 14),
    );
    $tableFormat->setColumnWidthConstraints(\@constraints);
# [7]

# [8]
    my $table = $cursor->insertTable(1, 7, $tableFormat);
# [8]

# [9]
    my $frame = $cursor->currentFrame();
    my $frameFormat = $frame->frameFormat();
    $frameFormat->setBorder(1);
    $frame->setFrameFormat($frameFormat);
# [9]

# [10]
    my $format = $cursor->charFormat();
    $format->setFontPointSize(this->fontSize);

    my $boldFormat = Qt4::TextCharFormat($format);
    $boldFormat->setFontWeight(Qt4::Font::Bold());

    my $highlightedFormat = Qt4::TextCharFormat($boldFormat);
    $highlightedFormat->setBackground(Qt4::yellow());
# [10]

# [11]
    for (my $weekDay = 1; $weekDay <= 7; ++$weekDay) {
        my $cell = $table->cellAt(0, $weekDay-1);
# [11] //! [12]
        my $cellCursor = $cell->firstCursorPosition();
        $cellCursor->insertText( '\'' . Qt4::Date::longDayName($weekDay) . '\'',
                              $boldFormat);
    }
# [12]

# [13]
    $table->insertRows($table->rows(), 1);
# [13]

    while ($date->month() == this->selectedDate->month()) {
        my $weekDay = $date->dayOfWeek();
        my $cell = $table->cellAt($table->rows()-1, $weekDay-1);
        my $cellCursor = $cell->firstCursorPosition();

        if ($date == Qt4::Date::currentDate()) {
            $cellCursor->insertText( '\''.$date->day().'\'', $highlightedFormat);
        }
        else {
            $cellCursor->insertText('\''.$date->day().'\'', $format);
        }

        $date = $date->addDays(1);
        if ($weekDay == 7 && $date->month() == this->selectedDate->month()) {
            $table->insertRows($table->rows(), 1);
        }
    }

    $cursor->endEditBlock();
# [14]
    this->setWindowTitle(sprintf this->tr('Calendar for %s %s'),
        Qt4::Date::longMonthName(this->selectedDate->month()),
        this->selectedDate->year());
}
# [14]

# [15]
sub setFontSize
{
    my ($size) = @_;
    this->{fontSize} = $size;
    this->insertCalendar();
}
# [15]

# [16]
sub setMonth
{
    my ($month) = @_;
    this->{selectedDate} = Qt4::Date(this->selectedDate->year(), $month + 1, this->selectedDate->day());
    this->insertCalendar();
}
# [16]

# [17]
sub setYear
{
    my ($date) = @_;
    this->{selectedDate} = Qt4::Date($date->year(), this->selectedDate->month(), this->selectedDate->day());
    this->insertCalendar();
}
# [17]

1;
