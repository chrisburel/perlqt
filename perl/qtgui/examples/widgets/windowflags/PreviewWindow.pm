package PreviewWindow;

use strict;
use warnings;
use Qt4;

# FIXME
use constant {
    Window=>0x00000001
};

use constant {
    Dialog=>0x00000002 | Window,
    SplashScreen=>0x0000000e | Window,
    ToolTip=>0x0000000c | Window
};


# [0]
use Qt4::isa qw( Qt4::Widget );
sub textEdit() {
    return this->{textEdit};
}

sub closeButton() {
    return this->{closeButton};
}
# [0]

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    my $textEdit = this->{textEdit} = Qt4::TextEdit();
    $textEdit->setReadOnly(1);
    $textEdit->setLineWrapMode(Qt4::TextEdit::NoWrap());

    my $closeButton = this->{closeButton} = Qt4::PushButton(this->tr('&Close'));
    this->connect($closeButton, SIGNAL 'clicked()', this, SLOT 'close()');

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget($textEdit);
    $layout->addWidget($closeButton);
    this->setLayout($layout);

    this->setWindowTitle(this->tr('Preview'));
}
# [0]

# [1]
sub setWindowFlags {
    my ($flags) = @_;
    this->SUPER::setWindowFlags($flags);

    my $text;

    my $type = ($flags & Qt4::WindowType_Mask());
    if ($type == Qt4::Window()) {
        $text = 'Qt4::Window';
    } elsif ($type == Dialog) {
        $text = 'Qt4::Dialog';
    } elsif ($type == Qt4::Sheet()) {
        $text = 'Qt4::Sheet';
    } elsif ($type == Qt4::Drawer()) {
        $text = 'Qt4::Drawer';
    } elsif ($type == Qt4::Popup()) {
        $text = 'Qt4::Popup';
    } elsif ($type == Qt4::Tool()) {
        $text = 'Qt4::Tool';
    } elsif ($type == ToolTip) {
        $text = 'Qt4::ToolTip';
    } elsif ($type == SplashScreen) {
        $text = 'Qt4::SplashScreen';
    }

    if (${$flags & Qt4::MSWindowsFixedSizeDialogHint()}) {
        $text .= "\n| Qt4::MSWindowsFixedSizeDialogHint";
    }
    if (${$flags & Qt4::X11BypassWindowManagerHint()}) {
        $text .= "\n| Qt4::X11BypassWindowManagerHint";
    }
    if (${$flags & Qt4::FramelessWindowHint()}) {
        $text .= "\n| Qt4::FramelessWindowHint";
    }
    if (${$flags & Qt4::WindowTitleHint()}) {
        $text .= "\n| Qt4::WindowTitleHint";
    }
    if (${$flags & Qt4::WindowSystemMenuHint()}) {
        $text .= "\n| Qt4::WindowSystemMenuHint";
    }
    if (${$flags & Qt4::WindowMinimizeButtonHint()}) {
        $text .= "\n| Qt4::WindowMinimizeButtonHint";
    }
    if (${$flags & Qt4::WindowMaximizeButtonHint()}) {
        $text .= "\n| Qt4::WindowMaximizeButtonHint";
    }
    if (${$flags & Qt4::WindowCloseButtonHint()}) {
        $text .= "\n| Qt4::WindowCloseButtonHint";
    }
    if (${$flags & Qt4::WindowContextHelpButtonHint()}) {
        $text .= "\n| Qt4::WindowContextHelpButtonHint";
    }
    if (${$flags & Qt4::WindowShadeButtonHint()}) {
        $text .= "\n| Qt4::WindowShadeButtonHint";
    }
    if (${$flags & Qt4::WindowStaysOnTopHint()}) {
        $text .= "\n| Qt4::WindowStaysOnTopHint";
    }
    if (${$flags & Qt4::CustomizeWindowHint()}) {
        $text .= "\n| Qt4::CustomizeWindowHint";
    }

    this->textEdit->setPlainText($text);
}
# [1]

1;
