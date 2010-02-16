package Dialog;

use strict;
use warnings;
use Qt4;

use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    revert => [],
    submit => [];

our $uniqueAlbumId;
our $uniqueArtistId;

sub NEW
{
    my ($class, $albums, $details, $output, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{model} = $albums;
    this->{albumDetails} = $details;
    this->{outputFile} = $output;

    my $inputWidgetBox = this->createInputWidgets();
    my $buttonBox = this->createButtons();

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget($inputWidgetBox);
    $layout->addWidget($buttonBox);
    this->setLayout($layout);

    this->setWindowTitle(this->tr('Add Album'));
}

sub submit
{
    my $artist = this->{artistEditor}->text();
    my $title = this->{titleEditor}->text();

    if (!$artist && !$title) {
        my $message = (this->tr('Please provide both the name of the artist ' .
                           'and the title of the album.'));
        Qt4::MessageBox::information(this, this->tr('Add Album'), $message);
    } else {
        my $artistId = this->findArtistId($artist);
        my $albumId = this->addNewAlbum($title, $artistId);

        my @tracks = split ',', this->{tracksEditor}->text();
        this->addTracks($albumId, \@tracks);

        this->increaseAlbumCount(this->indexOfArtist($artist));
        this->accept();
    }
}

sub findArtistId
{
    my ($artist) = @_;
    my $artistModel = this->{model}->relationModel(2);
    my $row = 0;

    while ($row < $artistModel->rowCount()) {
        my $record = $artistModel->record($row);
        if ($record->value('artist')->toString() eq $artist) {
            return $record->value('id')->toInt();
        }
        else {
            $row++;
        }
    }
    return this->addNewArtist($artist);
}


sub addNewArtist
{
    my ($name) = @_;
    my $artistModel = this->{model}->relationModel(2);
    my $record = Qt4::SqlRecord();

    my $id = this->generateArtistId();

    my $f1 = Qt4::SqlField('id', Qt4::Variant::Int());
    my $f2 = Qt4::SqlField('artist', Qt4::Variant::String());
    my $f3 = Qt4::SqlField('albumcount', Qt4::Variant::Int());

    $f1->setValue(Qt4::Variant(Qt4::Int($id)));
    $f2->setValue(Qt4::Variant(Qt4::String($name)));
    $f3->setValue(Qt4::Variant(Qt4::Int(0)));
    $record->append($f1);
    $record->append($f2);
    $record->append($f3);

    $artistModel->insertRecord(-1, $record);
    return $id;
}

sub addNewAlbum
{
    my ($title, $artistId) = @_;
    my $id = this->generateAlbumId();
    my $record = Qt4::SqlRecord();

    my $f1 = Qt4::SqlField('albumid', Qt4::Variant::Int());
    my $f2 = Qt4::SqlField('title', Qt4::Variant::String());
    my $f3 = Qt4::SqlField('artistid', Qt4::Variant::Int());
    my $f4 = Qt4::SqlField('year', Qt4::Variant::Int());

    $f1->setValue(Qt4::Variant(Qt4::Int($id)));
    $f2->setValue(Qt4::Variant(Qt4::String($title)));
    $f3->setValue(Qt4::Variant(Qt4::Int($artistId)));
    $f4->setValue(Qt4::Variant(Qt4::Int(this->{yearEditor}->value())));
    $record->append($f1);
    $record->append($f2);
    $record->append($f3);
    $record->append($f4);

    this->{model}->insertRecord(-1, $record);
    return $id;
}

sub addTracks
{
    my ($albumId, $tracks) = @_;
    my $albumNode = this->{albumDetails}->createElement('album');
    $albumNode->setAttribute('id', Qt4::Int($albumId));

    foreach my $i (0..$#{$tracks}) {
        my $trackNumber = $i;
        if ($i < 10) {
            $trackNumber = '0' . $i;
        }

        my $textNode = this->{albumDetails}->createTextNode($tracks->[$i]);

        my $trackNode = this->{albumDetails}->createElement('track');
        $trackNode->setAttribute('number', $trackNumber);
        $trackNode->appendChild($textNode);

        $albumNode->appendChild($trackNode);
    }

    my $archive = this->{albumDetails}->elementsByTagName('archive');
    $archive->item(0)->appendChild($albumNode);

    #The following code is commented out since the example uses an in
    #memory database, i.e., altering the XML file will bring the data
    #out of sync.

    #if (!this->{outputFile}->open(Qt4::IODevice::WriteOnly)) {
        #return;
    #} else {
        #Qt4::TextStream stream(this->{outputFile});
        #archive.item(0).save(stream, 4);
        #this->{outputFile}->close();
    #}
}

sub increaseAlbumCount
{
    my ($artistIndex) = @_;
    my $artistModel = this->{model}->relationModel(2);

    my $albumCountIndex = $artistIndex->sibling($artistIndex->row(), 2);

    my $albumCount = $albumCountIndex->data()->toInt();
    $artistModel->setData($albumCountIndex, Qt4::Variant(Qt4::Int($albumCount + 1)));
}


sub revert
{
    this->{artistEditor}->clear();
    this->{titleEditor}->clear();
    this->{yearEditor}->setValue(Qt4::Date::currentDate()->year());
    this->{tracksEditor}->clear();
}

sub createInputWidgets
{
    my $box = Qt4::GroupBox(this->tr('Add Album'));

    my $artistLabel = Qt4::Label(this->tr('Artist:'));
    my $titleLabel = Qt4::Label(this->tr('Title:'));
    my $yearLabel = Qt4::Label(this->tr('Year:'));
    my $tracksLabel = Qt4::Label(this->tr('Tracks (separated by comma):'));

    this->{artistEditor} = Qt4::LineEdit();
    this->{titleEditor} = Qt4::LineEdit();

    this->{yearEditor} = Qt4::SpinBox();
    this->{yearEditor}->setMinimum(1900);
    this->{yearEditor}->setMaximum(Qt4::Date::currentDate()->year());
    this->{yearEditor}->setValue(this->{yearEditor}->maximum());
    this->{yearEditor}->setReadOnly(0);

    this->{tracksEditor} = Qt4::LineEdit();

    my $layout = Qt4::GridLayout();
    $layout->addWidget($artistLabel, 0, 0);
    $layout->addWidget(this->{artistEditor}, 0, 1);
    $layout->addWidget($titleLabel, 1, 0);
    $layout->addWidget(this->{titleEditor}, 1, 1);
    $layout->addWidget($yearLabel, 2, 0);
    $layout->addWidget(this->{yearEditor}, 2, 1);
    $layout->addWidget($tracksLabel, 3, 0, 1, 2);
    $layout->addWidget(this->{tracksEditor}, 4, 0, 1, 2);
    $box->setLayout($layout);

    return $box;
}

sub createButtons
{
    my $closeButton = Qt4::PushButton(this->tr('&Close'));
    my $revertButton = Qt4::PushButton(this->tr('&Revert'));
    my $submitButton = Qt4::PushButton(this->tr('&Submit'));

    $closeButton->setDefault(1);

    this->connect($closeButton, SIGNAL 'clicked()', this, SLOT 'close()');
    this->connect($revertButton, SIGNAL 'clicked()', this, SLOT 'revert()');
    this->connect($submitButton, SIGNAL 'clicked()', this, SLOT 'submit()');

    my $buttonBox = Qt4::DialogButtonBox();
    $buttonBox->addButton($submitButton, Qt4::DialogButtonBox::ResetRole());
    $buttonBox->addButton($revertButton, Qt4::DialogButtonBox::ResetRole());
    $buttonBox->addButton($closeButton, Qt4::DialogButtonBox::RejectRole());

    return $buttonBox;
}

sub indexOfArtist
{
    my ($artist) = @_;
    my $artistModel = this->{model}->relationModel(2);

    foreach my $i (0..$artistModel->rowCount()-1) {
        my $record = $artistModel->record($i);
        if ($record->value('artist') eq $artist) {
            return $artistModel->index($i, 1);
        }
    }

    return Qt4::ModelIndex();
}

sub generateArtistId
{
    $uniqueArtistId += 1;
    return $uniqueArtistId;
}

sub generateAlbumId
{
    $uniqueAlbumId += 1;
    return $uniqueAlbumId;
}

1;
