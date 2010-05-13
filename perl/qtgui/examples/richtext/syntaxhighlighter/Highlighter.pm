package HighlightingRule;

sub new {
    my ( $class, $pattern, $format ) = @_;
    return bless { pattern => $pattern, format => $format }, $class;
}

sub pattern {
    return shift->{pattern};
}

sub format {
    return shift->{format};
}

package Highlighter;

use strict;
use warnings;
use Qt4;

# [0]
use Qt4::isa qw( Qt4::SyntaxHighlighter );

# [0]
sub NEW
{
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW($parent);

    this->{keywordFormat} = Qt4::TextCharFormat();
    this->{classFormat} = Qt4::TextCharFormat();
    this->{singleLineCommentFormat} = Qt4::TextCharFormat();
    this->{multiLineCommentFormat} = Qt4::TextCharFormat();
    this->{quotationFormat} = Qt4::TextCharFormat();
    this->{functionFormat} = Qt4::TextCharFormat();

    this->{keywordFormat}->setForeground(Qt4::Brush(Qt4::darkBlue()));
    this->{keywordFormat}->setFontWeight(Qt4::Font::Bold());
    my @keywordPatterns = (
                    "\\bchar\\b", "\\bclass\\b", "\\bconst\\b",
                    "\\bdouble\\b", "\\benum\\b", "\\bexplicit\\b",
                    "\\bfriend\\b", "\\binline\\b", "\\bint\\b",
                    "\\blong\\b", "\\bnamespace\\b", "\\boperator\\b",
                    "\\bprivate\\b", "\\bprotected\\b", "\\bpublic\\b",
                    "\\bshort\\b", "\\bsignals\\b", "\\bsigned\\b",
                    "\\bslots\\b", "\\bstatic\\b", "\\bstruct\\b",
                    "\\btemplate\\b", "\\btypedef\\b", "\\btypename\\b",
                    "\\bunion\\b", "\\bunsigned\\b", "\\bvirtual\\b",
                    "\\bvoid\\b", "\\bvolatile\\b" );
    foreach my $pattern (@keywordPatterns) {
        my $rule = HighlightingRule->new(
            Qt4::RegExp($pattern),
            this->{keywordFormat}
        );
        push @{this->{highlightingRules}}, $rule;
# [0] //! [1]
    }
# [1]

# [2]
    this->{classFormat}->setFontWeight(Qt4::Font::Bold());
    this->{classFormat}->setForeground(Qt4::Brush(Qt4::darkMagenta()));
    push @{this->{highlightingRules}},
        HighlightingRule->new(
            Qt4::RegExp("\\bQ[A-Za-z]+\\b"),
            this->{classFormat}
        );
# [2]

# [3]
    this->{singleLineCommentFormat}->setForeground(Qt4::Brush(Qt4::red()));
    
    push @{this->{highlightingRules}},
        HighlightingRule->new(
            Qt4::RegExp("//[^\n]*"),
            this->{singleLineCommentFormat}
        );

    this->{multiLineCommentFormat}->setForeground(Qt4::Brush(Qt4::red()));
# [3]

# [4]
    this->{quotationFormat}->setForeground(Qt4::Brush(Qt4::darkGreen()));
    push @{this->{highlightingRules}},
        HighlightingRule->new(
            Qt4::RegExp("\'.*\'"),
            this->{quotationFormat}
        );
# [4]

# [5]
    this->{functionFormat}->setFontItalic(1);
    this->{functionFormat}->setForeground(Qt4::Brush(Qt4::blue()));
    push @{this->{highlightingRules}},
        HighlightingRule->new(
            Qt4::RegExp("\\b[A-Za-z0-9_]+(?=\\()"),
            this->{functionFormat}
        );
# [5]

# [6]
    this->{commentStartExpression} = Qt4::RegExp("/\\*");
    this->{commentEndExpression} = Qt4::RegExp("\\*/");
}
# [6]

# [7]
sub highlightBlock
{
    my ($text) = @_;
    foreach my $rule ( @{this->{highlightingRules}} ) {
        my $expression = Qt4::RegExp($rule->pattern());
        my $index = $expression->indexIn($text);
        while ($index >= 0) {
            my $length = $expression->matchedLength();
            this->setFormat($index, $length, $rule->format());
            $index = $expression->indexIn($text, $index + $length);
        }
    }
# [7] //! [8]
    this->setCurrentBlockState(0);
# [8]

# [9]
    my $startIndex = 0;
    if (this->previousBlockState() != 1) {
        $startIndex = this->{commentStartExpression}->indexIn($text);
    }

# [9] //! [10]
    while ($startIndex >= 0) {
# [10] //! [11]
        my $endIndex = this->{commentEndExpression}->indexIn($text, $startIndex);
        my $commentLength;
        if ($endIndex == -1) {
            this->setCurrentBlockState(1);
            $commentLength = length( $text ) - $startIndex;
        } else {
            $commentLength = $endIndex - $startIndex
                            + this->{commentEndExpression}->matchedLength();
        }
        this->setFormat($startIndex, $commentLength, this->{multiLineCommentFormat});
        $startIndex = this->{commentStartExpression}->indexIn($text, $startIndex + $commentLength);
    }
}
# [11]

1;
