package Qt4::base;

use strict;
use warnings;

sub new {
    # Any direct calls to the 'NEW' function will bypass this code.  It's
    # called that way in subclass constructors, thus setting the 'this' value
    # for that package.

    # Store whatever current 'this' value we've got
    my $packageThis = Qt4::this();
    # Create the object, overwriting the 'this' value
    shift->NEW(@_);
    # Get the return value
    my $ret = Qt4::this();
    # Restore package's this
    Qt4::_internal::setThis($packageThis);
    # Give back the new value
    return $ret;
}

# This subroutine is used to set the context for translation correctly for any
# perl subclasses.  Without it, the context would always be set to the base Qt4
# class.
sub tr {
    if( !Qt4::qApp() ) {
        die 'You must create a Qt4::Application object before calling tr.';
    }
    my $context = ref Qt4::this();
    $context =~ s/^ *//;
    if( !$context ) {
        ($context) = $Qt4::AutoLoad::AUTOLOAD =~ m/(.*).:tr$/;
    }
    return Qt4::qApp()->translate( $context, @_ );
}

package Qt4::base::_overload;
use strict;

no strict 'refs';
use overload
    'fallback' => 1,
    '==' => 'Qt4::base::_overload::op_equal',
    '!=' => 'Qt4::base::_overload::op_not_equal',
    '+=' => 'Qt4::base::_overload::op_plus_equal',
    '-=' => 'Qt4::base::_overload::op_minus_equal',
    '*=' => 'Qt4::base::_overload::op_mul_equal',
    '/=' => 'Qt4::base::_overload::op_div_equal',
    '>>' => 'Qt4::base::_overload::op_shift_right',
    '<<' => 'Qt4::base::_overload::op_shift_left',
    '<=' => 'Qt4::base::_overload::op_lesser_equal',
    '>=' => 'Qt4::base::_overload::op_greater_equal',
    '^=' => 'Qt4::base::_overload::op_xor_equal',
    '|=' => 'Qt4::base::_overload::op_or_equal',
    '>'  => 'Qt4::base::_overload::op_greater',
    '<'  => 'Qt4::base::_overload::op_lesser',
    '+'  => 'Qt4::base::_overload::op_plus',
    '-'  => 'Qt4::base::_overload::op_minus',
    '*'  => 'Qt4::base::_overload::op_mul',
    '/'  => 'Qt4::base::_overload::op_div',
    '^'  => 'Qt4::base::_overload::op_xor',
    '|'  => 'Qt4::base::_overload::op_or',
    '--' => 'Qt4::base::_overload::op_decrement',
    '++' => 'Qt4::base::_overload::op_increment',
    'neg'=> 'Qt4::base::_overload::op_negate',
    'eq' => 'Qt4::base::_overload::op_ref_equal';

sub op_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator==';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator==';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    return $ret;
}

sub op_not_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator!=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator!=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    return $ret;
}

sub op_plus_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator+=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator+=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    return $ret;
}

sub op_minus_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator-=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator-=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_mul_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator*=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator*=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_div_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator/=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator/=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_shift_right {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator>>';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator>>';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_shift_left {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator<<';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator<<';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    return $ret;
}

sub op_lesser_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator<=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator<=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_greater_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator>=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator>=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_xor_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator^=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator^=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_or_equal {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator|=';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return ($_[2] ? $_[1] : $_[0]) unless $err = $@;
    my $ret;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator|=';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@; 
    return $ret;
}

sub op_greater {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator>';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator>';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_lesser {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator<';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator<';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_plus {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator+';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator+';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_minus {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator-';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator-';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_mul {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator*';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator*';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret     
}

sub op_div {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator/';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator/';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret     
}

sub op_negate {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator-';
    my $autoload = ref($_[0])."::AUTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->($_[0]) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator-';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload($_[0]) };
    die $err.$@ if $@;
    return $ret;
}

sub op_xor {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator^';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator^';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_or {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator|';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my ($ret, $err);
    eval { local $SIG{'__DIE__'}; $ret = $autoload->(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    return $ret unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator|';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; $ret = &$autoload(($_[2] ? (@_)[1,0] : (@_)[0,1])) };
    die $err.$@ if $@;
    $ret    
}

sub op_increment {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator++';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->($_[0]) };
    return $_[0] unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator++';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; &$autoload($_[0]) };
    die $err.$@ if $@; 
    $_[0]
}

sub op_decrement {
    $Qt4::AutoLoad::AUTOLOAD = ref($_[0]).'::operator--';
    my $autoload = ref($_[0])."::_UTOLOAD";
    my $err;
    eval { local $SIG{'__DIE__'}; $autoload->($_[0]) };
    return $_[0] unless $err = $@;
    $Qt4::AutoLoad::AUTOLOAD = 'Qt4::GlobalSpace::operator--';
    $autoload = "Qt4::GlobalSpace::_UTOLOAD";
    eval { local $SIG{'__DIE__'}; &$autoload($_[0]) };
    die $err.$@ if $@;
    $_[0]
}

sub op_ref_equal {
    return Qt4::_internal::sv_to_ptr( $_[0] ) == Qt4::_internal::sv_to_ptr( $_[1] );
}

package Qt4::enum::_overload;

use strict;

no strict 'refs';

use overload
    'fallback' => 1,
    '==' => 'Qt4::enum::_overload::op_equal',
    '!=' => 'Qt4::enum::_overload::op_not_equal',
    '+=' => 'Qt4::enum::_overload::op_plus_equal',
    '-=' => 'Qt4::enum::_overload::op_minus_equal',
    '*=' => 'Qt4::enum::_overload::op_mul_equal',
    '/=' => 'Qt4::enum::_overload::op_div_equal',
    '>>' => 'Qt4::enum::_overload::op_shift_right',
    '<<' => 'Qt4::enum::_overload::op_shift_left',
    '<=' => 'Qt4::enum::_overload::op_lesser_equal',
    '>=' => 'Qt4::enum::_overload::op_greater_equal',
    '^=' => 'Qt4::enum::_overload::op_xor_equal',
    '|=' => 'Qt4::enum::_overload::op_or_equal',
    '&=' => 'Qt4::enum::_overload::op_and_equal',
    '>'  => 'Qt4::enum::_overload::op_greater',
    '<'  => 'Qt4::enum::_overload::op_lesser',
    '+'  => 'Qt4::enum::_overload::op_plus',
    '-'  => 'Qt4::enum::_overload::op_minus',
    '*'  => 'Qt4::enum::_overload::op_mul',
    '/'  => 'Qt4::enum::_overload::op_div',
    '^'  => 'Qt4::enum::_overload::op_xor',
    '|'  => 'Qt4::enum::_overload::op_or',
    '&'  => 'Qt4::enum::_overload::op_and',
    '--' => 'Qt4::enum::_overload::op_decrement',
    '++' => 'Qt4::enum::_overload::op_increment',
    'neg'=> 'Qt4::enum::_overload::op_negate';

sub op_equal {
    if( ref $_[0] ) {
        if( ref $_[1] ) {
            return 1 if ${$_[0]} == ${$_[1]};
            return 0;
        }
        else {
            return 1 if ${$_[0]} == $_[1];
            return 0;
        }
    }
    else {
        return 1 if $_[0] == ${$_[1]};
        return 0;
    }
    # Never have to check for both not being references.  If neither is a ref,
    # this function will never be called.
}

sub op_not_equal {
    if( ref $_[0] ) {
        if( ref $_[1] ) {
            return 1 if ${$_[0]} != ${$_[1]};
            return 0;
        }
        else {
            return 1 if ${$_[0]} != $_[1];
            return 0;
        }
    }
    else {
        return 1 if $_[0] != ${$_[1]};
        return 0;
    }
    # Never have to check for both not being references.  If neither is a ref,
    # this function will never be called.
}

sub op_plus_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} += ${$_[1]};
    }
    else {
        return ${$_[0]} += $_[1];
    }
}

sub op_minus_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} -= ${$_[1]};
    }
    else {
        return ${$_[0]} -= $_[1];
    }
}

sub op_mul_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} *= ${$_[1]};
    }
    else {
        return ${$_[0]} *= $_[1];
    }
}

sub op_div_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} /= ${$_[1]};
    }
    else {
        return ${$_[0]} /= $_[1];
    }
}

sub op_shift_right {
    if ( ref $_[1] ) {
        return ${$_[0]} >> ${$_[1]};
    }
    else {
        return ${$_[0]} >> $_[1];
    }
}

sub op_shift_left {
    if ( ref $_[1] ) {
        return ${$_[0]} << ${$_[1]};
    }
    else {
        return ${$_[0]} << $_[1];
    }
}

sub op_lesser_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} <= ${$_[1]};
    }
    else {
        return ${$_[0]} <= $_[1];
    }
}

sub op_greater_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} >= ${$_[1]};
    }
    else {
        return ${$_[0]} >= $_[1];
    }
}

sub op_xor_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} ^= ${$_[1]};
    }
    else {
        return ${$_[0]} ^= $_[1];
    }
}

sub op_or_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} |= ${$_[1]};
    }
    else {
        return ${$_[0]} |= $_[1];
    }
}

sub op_and_equal {
    if ( ref $_[1] ) {
        return ${$_[0]} &= ${$_[1]};
    }
    else {
        return ${$_[0]} &= $_[1];
    }
}

sub op_greater {
    if ( ref $_[1] ) {
        return ${$_[0]} > ${$_[1]};
    }
    else {
        return ${$_[0]} > $_[1];
    }
}

sub op_lesser {
    if ( ref $_[1] ) {
        return ${$_[0]} < ${$_[1]};
    }
    else {
        return ${$_[0]} < $_[1];
    }
}

sub op_plus {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} + ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} + $_[1]), ref $_[0] );
    }
}

sub op_minus {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} - ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} - $_[1]), ref $_[0] );
    }
}

sub op_mul {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} * ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} * $_[1]), ref $_[0] );
    }
}

sub op_div {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} / ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} / $_[1]), ref $_[0] );
    }
}

sub op_xor {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} ^ ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} ^ $_[1]), ref $_[0] );
    }
}

sub op_or {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} | ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} | $_[1]), ref $_[0] );
    }
}

sub op_and {
    if ( ref $_[1] ) {
        return bless( \(${$_[0]} & ${$_[1]}), ref $_[0] );
    }
    else {
        return bless( \(${$_[0]} & $_[1]), ref $_[0] );
    }
}

sub op_decrement {
    return --${$_[0]};
}

sub op_increment {
    return ++${$_[0]};
}

sub op_negate {
    return -${$_[0]};
}

package Qt4::DBusReply;

use strict;
use warnings;

sub new {
    my ( $class, $reply ) = @_;
    my $this = bless {}, $class;

    my $error = Qt4::DBusError($reply);
    $this->{error} = $error;
    if ( $error->isValid() ) {
        $this->{data} = Qt4::Variant();
        return $this;
    }

    my $arguments = $reply->arguments();
    if ( ref $arguments eq 'ARRAY' && scalar @{$arguments} >= 1 ) {
        $this->{data} = $arguments->[0];
        return $this;
    }

    # This only gets called if the 2 previous ifs weren't
    $this->{error} = Qt4::DBusError( Qt4::DBusError::InvalidSignature(),
                                     'Unexpected reply signature' );
    $this->{data} = Qt4::Variant();
    return $this;
}

sub isValid {
    my ( $this ) = @_;
    return !$this->{error}->isValid();
}

sub value() {
    my ( $this ) = @_;
    return $this->{data}->value();
}

sub error() {
    my ( $this ) = @_;
    return $this->{error};
}

# Create the Qt4::DBusReply() constructor
Qt4::_internal::installSub('Qt4::DBusReply', sub { Qt4::DBusReply->new(@_) });

1;

package Qt4::DBusVariant;

use strict;
use warnings;

sub NEW {
    my ( $class, $value ) = @_;
    if ( ref $value eq ' Qt4::Variant' ) {
        $class->SUPER::NEW( $value );
    }
    else {
        $class->SUPER::NEW( $value );
    }
}

1;

package Qt4::GlobalSpace;

use strict;
use warnings;

our @EXPORT_OK;

unless(exists $::INC{'Qt4/GlobalSpace.pm'}) {
    $::INC{'Qt4/GlobalSpace.pm'} = $::INC{'Qt4.pm'};
}

sub import {
    my $class = shift;
    my $caller = (caller)[0];
    $caller .= '::';

    foreach my $subname ( @_ ) {
        next unless grep( $subname, @EXPORT_OK );
        Qt4::_internal::installSub( $caller.$subname, sub {
            $Qt4::AutoLoad::AUTOLOAD = "Qt4::GlobalSpace::$subname";
            my $autoload = 'Qt4::GlobalSpace::_UTOLOAD';
            no strict 'refs';
            return &$autoload(@_);
        } );
    }
}

package Qt4::_internal;

use strict;
use warnings;
use Scalar::Util qw( blessed );

# These 2 hashes provide lookups from a perl package name to a smoke
# classid, and vice versa
our %package2classId;
our %classId2package;

# This hash stores integer pointer address->perl SV association.  Used for
# overriding virtual functions, where all you have as an input is a void* to
# the object who's method is being called.  Made visible here for debugging
# purposes.
our %pointer_map;

my %customClasses = (
    'Qt4::DBusVariant' => 'Qt4::Variant',
);

our $ambiguousSignature = undef;

my %arrayTypes = (
    'const QList<QVariant>&' => {
        value => [ 'QVariant' ]
    },
    'const QStringList&' => {
        value => [ 's', 'Qt4::String' ],
    },
);

my %hashTypes = (
    'const QHash<QString, QVariant>&' => {
        value1 => [ 's', 'Qt4::String' ],
        value2 => [ 'QVariant' ]
    },
    'const QMap<QString, QVariant>&' => {
        value1 => [ 's', 'Qt4::String' ],
        value2 => [ 'QVariant' ]
    },
);

sub arrayByName {
    my $name = shift;
    no strict 'refs';
    return \@{$name};
}

sub hashByName {
    my $name = shift;
    no strict 'refs';
    return \%{$name};
}

sub installSub {
    my ($subname, $subref) = @_;
    no strict 'refs';
    *{$subname} = $subref unless defined &{$subname};
    return;
}

sub unique {
    my %uniq;          # Use keys of this hash to track unique values
    @uniq{@_} = ();    # use the args as those keys
    return keys %uniq; # Return unique values
}

sub argmatch {
    my ( $methodIds, $args, $argNum ) = @_;
    my %match;

    my $argType = getSVt( $args->[$argNum] );

    my $explicitType = 0;
               #index into methodId array
    foreach my $methodIdIdx ( 0..$#{$methodIds} ) {
        my $moduleId = $methodIds->[$methodIdIdx];
        my $smokeId = $moduleId->[0];
        my $methodId = $moduleId->[1];
        my $typeName = getTypeNameOfArg( $smokeId, $methodId, $argNum );
        #ints and bools
        if ( $argType eq 'i' ) {
            if( $typeName =~ m/^(?:bool|(?:(?:un)?signed )?(?:int|long)|uint)[*&]?$/ ) {
                $match{$methodIdIdx} = [0,[$smokeId,$methodId]];
            }
        }
        # floats and doubles
        elsif ( $argType eq 'n' ) {
            if( $typeName =~ m/^(?:float|double)$/ ) {
                $match{$methodIdIdx} = [0,[$smokeId,$methodId]];
            }
        }
        # enums
        elsif ( $argType eq 'e' ) {
            my $refName = ref $args->[$argNum];
            if( $typeName =~ m/^$refName[s]?$/ ) {
                $match{$methodIdIdx} = [0,[$smokeId,$methodId]];
            }
        }
        # strings
        elsif ( $argType eq 's' ) {
            if( $typeName =~ m/^(?:(?:const )?u?char\*|(?:const )?(?:(QString)|QByteArray)[\*&]?)$/ ) {
                $match{$methodIdIdx} = [0,[$smokeId,$methodId]];
            }
        }
        # arrays
        elsif ( $argType eq 'a' ) {
            next unless defined $arrayTypes{$typeName};
            my @subArgTypes = unique( map{ getSVt( $_ ) } @{$args->[$argNum]} );
            my @validTypes = @{$arrayTypes{$typeName}->{value}};
            my $good = 1;
            foreach my $subArgType ( @subArgTypes ) {
                if ( !grep{ $_ eq $subArgType } @validTypes ) {
                    $good = 0;
                    last;
                }
            }
            if( $good ) {
                $match{$methodIdIdx} = [0,[$smokeId,$methodId]];
            }
        }
        elsif ( $argType eq 'r' or $argType eq 'U' ) {
            $match{$methodIdIdx} = [0,[$smokeId,$methodId]];
        }
        elsif ( $argType eq 'Qt4::String' ) {
            # This type exists only to resolve ambiguous method calls, so we
            # can return here.
            if( $typeName =~m/^(?:const )?QString[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::CString' ) {
            # This type exists only to resolve ambiguous method calls, so we
            # can return here.
            if( $typeName =~m/^(?:const )?char ?\*[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::Int' ) {
            # This type exists only to resolve ambiguous method calls, so we
            # can return here.
            if( $typeName =~ m/^int[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::Uint' ) {
            # This type exists only to resolve ambiguous method calls, so we
            # can return here.
            if( $typeName =~ m/^unsigned int[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::Bool' ) {
            # This type exists only to resolve ambiguous method calls, so we
            # can return here.
            if( $typeName eq 'bool' ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::Short' ) {
            if( $typeName =~ m/^short[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::Ushort' ) {
            if( $typeName =~ m/^unsigned short[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        elsif ( $argType eq 'Qt4::Uchar' ) {
            if( $typeName =~ m/^u(?:nsigned )?char[\*&]?$/ ) {
                return [$smokeId,$methodId];
            }
            else {
                $explicitType = 1;
            }
        }
        # objects
        else {
            # Optional const, some words, optional & or *.  Note ?: does not
            # make a backreference, (\w*) is the only thing actually captured.
            $typeName =~ s/^(?:const\s+)?(\w*)[&*]?$/$1/g;
            my $isa = classIsa( $argType, $typeName );
            if ( $isa != -1 ) {
                $match{$methodIdIdx} = [-$isa, [$smokeId,$methodId]];
            }
        }
    }

    if ( !%match && $explicitType ) {
        return [undef,-1];
    }

    return map{ $match{$_}->[1] }
        sort { $match{$b}[0] <=> $match{$a}[0] or $match{$a}[1] <=> $match{$b}[1] } keys %match;
}

sub dumpArgs {
    return join ', ', map{
        my $refName = ref $_;
        $refName =~ s/^ *//;
        if($refName) {
            $refName;
        }
        else {
            $_;
        }
    } @_;
}

sub dumpCandidates {
    my ( $classname, $methodname, $moduleIds ) = @_;
    my @methods;
    foreach my $moduleId ( @{$moduleIds} ) {

        my $smokeId = $moduleId->[0];
        my $methodId = $moduleId->[1];

        my $numArgs = getNumArgs( $smokeId, $methodId );
        my $method = "$classname\::$methodname( ";
        $method .= join ', ', map{ getTypeNameOfArg( $smokeId, $methodId, $_ ) } ( 0..$numArgs-1 );
        $method .= " )";
        push @methods, $method;
    }
    return @methods;
}


# Args: @_: the args to the method being called
#       $classname: the c++ class being called
#       $methodname: the c++ method name being called
#       $classId: the smoke class Id of $classname
# Returns: A disambiguated method id
# Desc: Examines the arguments of the method call to build a method signature.
#       From that signature, it determines the appropriate method id.
sub getSmokeMethodId {
    my $classname = pop;
    my $methodname = pop;
    my $classId = pop;
    my $smokeId = $classId->[0];

    # Loop over the arguments to determine the type of args
    my @mungedMethods = ( $methodname );
    foreach my $arg ( @_ ) {
        if (!defined $arg) {
            # An undefined value requires a search for each type of argument
            @mungedMethods = map { $_ . '#', $_ . '?', $_ . '$' } @mungedMethods;
        } elsif(isObject($arg)) {
            @mungedMethods = map { $_ . '#' } @mungedMethods;
        } elsif((ref $arg) =~ m/HASH|ARRAY/) {
            @mungedMethods = map { $_ . '?' } @mungedMethods;
        } else {
            @mungedMethods = map { $_ . '$' } @mungedMethods;
        }
    }
    my @methodIds = map { findMethod( $classname, $_ ) } @mungedMethods;

    my $cacheLookup = 1;

    # If we got more than 1 method id, resolve it
    if (@methodIds > 1) {
        foreach my $argNum (0..$#_) {
            my @matching = argmatch( \@methodIds, \@_, $argNum );
            if (@matching) {
                if ($matching[0]->[1] == -1) {
                    @methodIds = ();
                }
                else {
                    @methodIds = @matching;
                }
            }
        }

        # Look for the user-defined signature
        if ( @methodIds > 1 && defined $ambiguousSignature ) {
            foreach my $methodId ( @methodIds ) {
                my ($signature) = dumpCandidates( $classname, $methodname, [$methodId] );
                if ( $signature eq $ambiguousSignature ) {
                    @methodIds = ($methodId);
                    $ambiguousSignature = undef;
                    last;
                }
            }
        }

        # If we still have more than 1 match, use the first one.
        if ( @methodIds > 1 ) {
            # Keep in sync with debug.pm's $channel{ambiguous} value
            if ( debug() & 0x01 ) {
                # A constructor call will be 4 levels deep on the stack, everything
                # else will be 2
                my $stackDepth = ( $methodname eq $classname ) ? 4 : 2;
                my @caller = caller($stackDepth);
                while ( $caller[1] =~ m/Qt4\.pm$/ || $caller[1] =~ m/Qt4\/isa\.pm/ ) {
                    ++$stackDepth;
                    @caller = caller($stackDepth);
                }
                my $msg = "--- Ambiguous method ${classname}::$methodname" .
                    ' called at ' . $caller[1] .
                    ' line ' . $caller[2] . "\n";
                $msg .= "Candidates are:\n\t";
                $msg .= join "\n\t", dumpCandidates( $classname, $methodname, \@methodIds );
                $msg .= "\nChoosing first one...\n";
                warn $msg;
            }
            @methodIds = $methodIds[0];

            # Since a call to this same method with different args may resolve
            # differently, don't cache this lookup
            $cacheLookup = 0;
        }
    }
    elsif ( @methodIds == 1 and @_ ) {
        # We have one match and arguments.  We need to make sure our input
        # arguments match what the method is expecting.  Clear methodIds if
        # args don't match
        if (!objmatch( $methodIds[0], \@_)) {
            my $stackDepth = ( $methodname eq $classname ) ? 4 : 2;
            my @caller = caller($stackDepth);
            while ( $caller[1] =~ m/Qt4\.pm$/ || $caller[1] =~ m/Qt4\/isa\.pm/ ) {
                ++$stackDepth;
                @caller = caller($stackDepth);
            }
            my $errStr = '--- Arguments for method call ' .
                "$classname\::$methodname did not match C++ method ".
                "signature," .
                ' called at ' . $caller[1] .
                ' line ' . $caller[2] . "\n";
            $errStr .= "Method call was:\n\t";
            $errStr .= "$classname\::$methodname( " . dumpArgs(@_) . " )\n";
            $errStr .= "C++ signature is:\n\t";
            $errStr .= (dumpCandidates( $classname, $methodname, \@methodIds ))[0] . "\n";
            @methodIds = ();
            print STDERR $errStr and die;
        }
    }

    if ( !@methodIds ) {
        if ( debug() & 0x01 ) {
            # The findAnyPossibleMethod is expensive, only do it if debugging is on.
            my $smokeId = $classId->[0];
            @methodIds = findAnyPossibleMethod( $classname, $methodname, @_ );
            if( @methodIds ) {
                die reportAlternativeMethods( $classname, $methodname, \@methodIds, @_ );
            }
            else {
                die reportNoMethodFound( $classname, $methodname, @_ );
            }
        }
        else {
            my $noMethodFound = reportNoMethodFound( $classname, $methodname, @_ );
            $noMethodFound .= "'use Qt4::debug qw(ambiguous)' for more information.";
            die $noMethodFound;
        }
    }

    return @{$methodIds[0]}, $cacheLookup;
}

sub getMetaObject {
    my $class = shift;

    my $meta = hashByName($class . '::META');

    # If no signals/slots/properties have been added since the last time this
    # was asked for, return the saved one.
    return $meta->{object} if $meta->{object} and !$meta->{changed};

    # If this is a native Qt4 class, call metaObject() on that class directly
    if ( $package2classId{$class} ) {
        my $moduleId = $package2classId{$class};
        my $classId = $moduleId->[1];
        my $cxxClass = classFromId( $classId );
        my ( $smokeId, $methodId ) = getSmokeMethodId( $moduleId, 'metaObject', $cxxClass );
        return $meta->{object} = getNativeMetaObject( $smokeId, $methodId );
    }

    # Get the super class's meta object for sig/slot inheritance
    # Look up through ISA to find it
    my $parentMeta = undef;
    my $parentModuleId;

    # This seems wrong, it won't work with multiple inheritance
    my $parentClass = arrayByName($class."::ISA")->[0]; 

    if ( !$parentClass ) {
        die "Request for metaObject for class $class, which has no base class";
    }

    if( !$package2classId{$parentClass} ) {
        # The parent class is a custom Perl class whose metaObject was
        # constructed at runtime, so we can get it's metaObject from here.
        $parentMeta = getMetaObject( $parentClass );
    }
    else {
        $parentModuleId = $package2classId{$parentClass};
    }

    # Generate data to create the meta object
    my( $stringdata, $data ) = makeMetaData( $class );
    $meta->{object} = Qt4::_internal::make_metaObject(
        $parentModuleId,
        $parentMeta,
        $stringdata,
        $data );

    $meta->{changed} = 0;
    return $meta->{object};
}

# Does the method exist, but the user just gave bad args?
sub findAnyPossibleMethod {
    my $classname = shift;
    my $methodname = shift;

    my @last = '';
    my @mungedMethods = ( $methodname );
    # 14 is the max number of args, but that's way too many permutations.
    # Keep it short.
    foreach ( 0..7 ) { 
        @last = permateMungedMethods( ['$', '?', '#'], @last );
        push @mungedMethods, map{ $methodname . $_ } @last;
    }

    return map { findMethod( $classname, $_ ) } @mungedMethods;
}

sub init_class {
    my ($class, $cxxClassName) = @_;

    my $perlClassName = $class->normalize_classname($cxxClassName);
    my ($classId, $smokeId) = findClass($cxxClassName);
    my $moduleId = [$smokeId, $classId];

    my @isa;
    if ( $classId ) {
        # Save the association between this perl package and the cxx classId.
        $package2classId{$perlClassName} = $moduleId;
        my $moduleIdBitwise = ($classId<<8)+$smokeId;
        $classId2package{$moduleIdBitwise} = $perlClassName;

        # Define the inheritance array for this class.
        @isa = getIsa($moduleId);
    }

    @isa = $customClasses{$perlClassName}
        if defined $customClasses{$perlClassName};

    # We want the isa array to be the names of perl packages, not c++ class
    # names
    foreach my $super ( @isa ) {
        $super = $class->normalize_classname($super);
    }

    # The root of the tree will be Qt4::base, so a call to
    # $className::new() redirects there.
    @isa = ('Qt4::base') unless @isa;
    @{arrayByName($perlClassName.'::ISA')} = @isa;

    # Define overloaded operators
    @{arrayByName(" $perlClassName\::ISA")} = ('Qt4::base::_overload');

    foreach my $sp ('', ' ') {
        my $where = $sp . $perlClassName;
        installautoload($where);
        # Putting this in one package gives XS_AUTOLOAD one spot to look for
        # the autoload variable
        package Qt4::AutoLoad;
        my $autosub = \&{$where . '::_UTOLOAD'};
        Qt4::_internal::installSub( $where.'::AUTOLOAD', sub{&$autosub} );
    }

    installSub("$perlClassName\::NEW", sub {
        # Removes $perlClassName from the front of @_
        my $perlClassName = shift;

        # If we have a cxx classname that's in some other namespace, like
        # QTextEdit::ExtraSelection, remove the first bit.
        $cxxClassName =~ s/.*://;
        $Qt4::AutoLoad::AUTOLOAD = "$perlClassName\::$cxxClassName";
        my $_utoload = \&{"$perlClassName\::_UTOLOAD"};
        setThis( bless &$_utoload, " $perlClassName" );
    }) unless(defined &{"$perlClassName\::NEW"});

    # Make the constructor subroutine
    installSub($perlClassName, sub {
        # Adds $perlClassName to the front of @_
        $perlClassName->new(@_);
    }) unless(defined &{$perlClassName});
}

sub permateMungedMethods {
    my $sigils = shift;
    my @output;
    while( defined( my $input = shift ) ) {
        push @output, map{ $input . $_ } @{$sigils};
    }
    return @output;
}

sub reportAlternativeMethods {
    my $classname = shift;
    my $methodname = shift;
    my $methodIds = shift;
    # @_ now equals the original argument array of the method call
    my $stackDepth = ( $methodname eq $classname ) ? 5 : 3;
    my $errStr = '--- Arguments for method call ' .
        "$classname\::$methodname did not match any known C++ method ".
        "signature," .
        ' called at ' . (caller($stackDepth))[1] .
        ' line ' . (caller($stackDepth))[2] . "\n";
    $errStr .= "Method call was:\n\t";
    $errStr .= "$classname\::$methodname( " . dumpArgs(@_) . " )\n";
    $errStr .= "Possible candidates:\n\t";
    $errStr .= join( "\n\t", dumpCandidates( $classname, $methodname, $methodIds ) ) . "\n";
    return $errStr;
}

sub reportNoMethodFound {
    my $classname = shift;
    my $methodname = shift;
    # @_ now equals the original argument array of the method call

    my $stackDepth = ( $methodname eq $classname ) ? 5 : 3;

    # Look up the stack to find who called us.  We don't care if it was
    # called from Qt4.pm or isa.pm
    my @caller = caller($stackDepth);
    while ( $caller[1] =~ m/Qt4\.pm$/ || $caller[1] =~ m/Qt4\/isa\.pm/ ) {
        ++$stackDepth;
        @caller = caller($stackDepth);
    }
    my $errStr = '--- Error: Method does not exist or not provided by this ' .
        "binding:\n";
    $errStr .= "$classname\::$methodname(),\n";
    $errStr .= 'called at ' . $caller[1] . ' line ' . $caller[2] . "\n";
    return $errStr;
}

# Args: none
# Returns: none
# Desc: sets up each class
sub init {
    my $classes = getClassList();
    Qt4::_internal->init_class($_) for(@$classes);

    my $enums = getEnumList();
    foreach my $enumName (@$enums) {
        $enumName =~ s/^const //;
        if(@{arrayByName("${enumName}::ISA")}) {
            @{arrayByName("${enumName}Enum::ISA")} = ('Qt4::enum::_overload');
        }
        else {
            @{arrayByName("${enumName}::ISA")} = ('Qt4::enum::_overload');
        }
    }

}

sub makeMetaData {
    my ( $classname ) = @_;

    my $meta = hashByName($classname . '::META');

    my $classinfos = $meta->{classinfos};
    my $dbus = $meta->{dbus};
    my $signals = $meta->{signals};
    my $slots = $meta->{slots};

    @{$classinfos} = () if !defined @{$classinfos};
    @{$signals} = () if !defined @{$signals};
    @{$slots} = () if !defined @{$slots};

    # Each entry in 'stringdata' corresponds to a string in the
    # qt_meta_stringdata_<classname> structure.

    #
    # From the enum MethodFlags in qt-copy/src/tools/moc/generator.cpp
    #
    my $AccessPrivate = 0x00;
    my $AccessProtected = 0x01;
    my $AccessPublic = 0x02;
    my $MethodMethod = 0x00;
    my $MethodSignal = 0x04;
    my $MethodSlot = 0x08;
    my $MethodCompatibility = 0x10;
    my $MethodCloned = 0x20;
    my $MethodScriptable = 0x40;

    my $numClassInfos = scalar @{$classinfos};
    my $numSignals = scalar @{$signals};
    my $numSlots = scalar @{$slots};

    my $data = [
        1,                           #revision
        0,                           #str index of classname
        $numClassInfos,              #number of classinfos
        $numClassInfos > 0 ? 10 : 0, #have classinfo?
        $numSignals + $numSlots,     #number of sig/slots
        10 + (2*$numClassInfos),     #have methods?
        0, 0,                        #no properties
        0, 0,                        #no enums/sets
    ];

    my $stringdata = "$classname\0";
    my $nullposition = length( $stringdata ) - 1;

    # Build the stringdata string, storing the indexes in data
    foreach my $classinfo ( @{$classinfos} ) {
        foreach my $keyval ( %{$classinfo} ) {
            my $curPosition = length $stringdata;
            push @{$data}, $curPosition;
            $stringdata .= $keyval . "\0";
        }
    }

    foreach my $signal ( @$signals ) {
        my $curPosition = length $stringdata;

        # Add this signal to the stringdata
        $stringdata .= $signal->{signature} . "\0" ;

        push @$data, $curPosition; #signature
        push @$data, $nullposition; #parameter names
        push @$data, $nullposition; #return type, void
        push @$data, $nullposition; #tag
        if ( $dbus ) {
            push @$data, $MethodScriptable | $MethodSignal | $AccessPublic; # flags
        }
        else {
            push @$data, $MethodSignal | $AccessProtected; # flags
        }
    }

    foreach my $slot ( @$slots ) {
        my $curPosition = length $stringdata;

        # Add this slot to the stringdata
        $stringdata .= $slot->{signature} . "\0";
        push @$data, $curPosition; #signature

        push @$data, $nullposition; #parameter names

        if ( defined $slot->{returnType} ) {
            $curPosition = length $stringdata;
            $stringdata .= $slot->{returnType} . "\0";
            push @$data, $curPosition; #return type
        }
        else {
            push @$data, $nullposition; #return type, void
        }
        push @$data, $nullposition; #tag
        push @$data, $MethodSlot | $AccessPublic; # flags
    }

    push @$data, 0; #eod

    return ($stringdata, $data);
}

# Args: $cxxClassName: the name of a Qt4 class
# Returns: The name of the associated perl package
# Desc: Given a c++ class name, determine the perl package name
sub normalize_classname {
    my $cxxClassName = $_[1];

    # Call the 'Qt' class 'Qt4';
    return 'Qt4' if $cxxClassName eq 'Qt';

    my $perlClassName = $cxxClassName;

    if ($cxxClassName =~ m/^Q3/) {
        # Prepend Qt3:: if this is a Qt3 support class
        $perlClassName =~ s/^Q3(?=[A-Z])/Qt3::/;
    }
    elsif ($cxxClassName =~ m/^Q/) {
        # Only prepend Qt4:: if the name starts with Q and is followed by
        # an uppercase letter
        $perlClassName =~ s/^Q(?=[A-Z])/Qt4::/;
    }

    return $perlClassName;
}

sub objmatch {
    my ( $moduleId, $args ) = @_;
    my $smokeId = $moduleId->[0];
    my $methodId = $moduleId->[1];
    foreach my $i ( 0..$#$args ) {
        # Compare our actual args to what the method expects
        my $argtype = getSVt($args->[$i]);

        # argtype will be only 1 char if it is not an object. If that's the
        # case, don't do any checks.
        next if length $argtype == 1;

        my $typename = getTypeNameOfArg( $smokeId, $methodId, $i );

        # We don't care about const or [&*]
        $typename =~ s/^const\s+//;
        $typename =~ s/(?<=\w)[&*]$//g;

        return 0 if classIsa( $argtype, $typename) == -1;
    }
    return 1;
}

sub Qt4::CoreApplication::NEW {
    my $class = shift;
    my $argv = shift;
    unshift @$argv, $0;
    my $count = scalar @$argv;
    my $retval = Qt4::CoreApplication::QCoreApplication( $count, $argv );
    bless( $retval, " $class" );
    setThis( $retval );
    setQApp( $retval );
    shift @$argv;
}

sub Qt4::Application::NEW {
    my $class = shift;
    my $argv = shift;
    unshift @$argv, $0;
    my $count = scalar @$argv;
    my $retval = Qt4::Application::QApplication( $count, $argv );
    bless( $retval, " $class" );
    setThis( $retval );
    setQApp( $retval );
    shift @$argv;
}

sub isa {
    my ( $class, $baseClass ) = @_;
    if ( blessed( $class ) ) {
        $class = ref $class;
        $class =~ s/^ //;
    }
    return $class->isa( $baseClass );
}

package QtCore4;

use 5.008006;
use strict;
use warnings;

require Exporter;
require XSLoader;

our $VERSION = '0.60';

our @EXPORT = qw( SIGNAL SLOT emit CAST qApp );

XSLoader::load('QtCore4', $VERSION);

Qt4::_internal::init();

sub SIGNAL ($) { '2' . $_[0] }
sub SLOT ($) { '1' . $_[0] }
sub emit (@) { return pop @_ }
sub CAST ($$) {
    my( $var, $class ) = @_;
    if( ref $var ) {
        if ( $class->isa( 'Qt4::base' ) ) {
            $class = " $class";
        }
        return bless( $var, $class );
    }
    else {
        return bless( \$var, $class );
    }
}

sub import { goto &Exporter::import }

package Qt4;

use strict;
use warnings;

sub setSignature {
    $Qt4::_internal::ambiguousSignature = shift;
}

# Called in the DESTROY method for all QObjects to see if they still have a
# parent, and avoid deleting them if they do.
sub Qt4::Object::ON_DESTROY {
    package Qt4::_internal;
    my $parent = Qt4::this()->parent;
    if( defined $parent ) {
        my $ptr = sv_to_ptr(Qt4::this());
        ${ $parent->{'hidden children'} }{ $ptr } = Qt4::this();
        Qt4::this()->{'has been hidden'} = 1;
        return 1;
    }
    return 0;
}

# Never save a QApplication from destruction
sub Qt4::Application::ON_DESTROY {
    return 0;
}

Qt4::_internal::installSub(' Qt4::Variant::value', sub {
    my $this = shift;

    my $type = $this->type();
    if( $type == Qt4::Variant::Invalid() ) {
        return;
    }
    elsif( $type == Qt4::Variant::Bitmap() ) {
    }
    elsif( $type == Qt4::Variant::Bool() ) {
        return $this->toBool();
    }
    elsif( $type == Qt4::Variant::Brush() ) {
        return Qt4::qVariantValue($this, 'Qt4::Brush');
    }
    elsif( $type == Qt4::Variant::ByteArray() ) {
        return $this->toByteArray();
    }
    elsif( $type == Qt4::Variant::Char() ) {
        return Qt4::qVariantValue($this, 'Qt4::Char');
    }
    elsif( $type == Qt4::Variant::Color() ) {
        return Qt4::qVariantValue($this, 'Qt4::Color');
    }
    elsif( $type == Qt4::Variant::Cursor() ) {
        return Qt4::qVariantValue($this, 'Qt4::Cursor');
    }
    elsif( $type == Qt4::Variant::Date() ) {
        return $this->toDate();
    }
    elsif( $type == Qt4::Variant::DateTime() ) {
        return $this->toDateTime();
    }
    elsif( $type == Qt4::Variant::Double() ) {
        return $this->toDouble();
    }
    elsif( $type == Qt4::Variant::Font() ) {
        return Qt4::qVariantValue($this, 'Qt4::Font');
    }
    elsif( $type == Qt4::Variant::Icon() ) {
        return Qt4::qVariantValue($this, 'Qt4::Icon');
    }
    elsif( $type == Qt4::Variant::Image() ) {
        return Qt4::qVariantValue($this, 'Qt4::Image');
    }
    elsif( $type == Qt4::Variant::Int() ) {
        return $this->toInt();
    }
    elsif( $type == Qt4::Variant::KeySequence() ) {
        return Qt4::qVariantValue($this, 'Qt4::KeySequence');
    }
    elsif( $type == Qt4::Variant::Line() ) {
        return $this->toLine();
    }
    elsif( $type == Qt4::Variant::LineF() ) {
        return $this->toLineF();
    }
    elsif( $type == Qt4::Variant::List() ) {
        return $this->toList();
    }
    elsif( $type == Qt4::Variant::Locale() ) {
        return Qt4::qVariantValue($this, 'Qt4::Locale');
    }
    elsif( $type == Qt4::Variant::LongLong() ) {
        return $this->toLongLong();
    }
    elsif( $type == Qt4::Variant::Map() ) {
        return $this->toMap();
    }
    elsif( $type == Qt4::Variant::Palette() ) {
        return Qt4::qVariantValue($this, 'Qt4::Palette');
    }
    elsif( $type == Qt4::Variant::Pen() ) {
        return Qt4::qVariantValue($this, 'Qt4::Pen');
    }
    elsif( $type == Qt4::Variant::Pixmap() ) {
        return Qt4::qVariantValue($this, 'Qt4::Pixmap');
    }
    elsif( $type == Qt4::Variant::Point() ) {
        return $this->toPoint();
    }
    elsif( $type == Qt4::Variant::PointF() ) {
        return $this->toPointF();
    }
    elsif( $type == Qt4::Variant::Polygon() ) {
        return Qt4::qVariantValue($this, 'Qt4::Polygon');
    }
    elsif( $type == Qt4::Variant::Rect() ) {
        return $this->toRect();
    }
    elsif( $type == Qt4::Variant::RectF() ) {
        return $this->toRectF();
    }
    elsif( $type == Qt4::Variant::RegExp() ) {
        return $this->toRegExp();
    }
    elsif( $type == Qt4::Variant::Region() ) {
        return Qt4::qVariantValue($this, 'Qt4::Region');
    }
    elsif( $type == Qt4::Variant::Size() ) {
        return $this->toSize();
    }
    elsif( $type == Qt4::Variant::SizeF() ) {
        return $this->toSizeF();
    }
    elsif( $type == Qt4::Variant::SizePolicy() ) {
        return $this->toSizePolicy();
    }
    elsif( $type == Qt4::Variant::String() ) {
        return $this->toString();
    }
    elsif( $type == Qt4::Variant::StringList() ) {
        return $this->toStringList();
    }
    elsif( $type == Qt4::Variant::TextFormat() ) {
        return Qt4::qVariantValue($this, 'Qt4::TextFormat');
    }
    elsif( $type == Qt4::Variant::TextLength() ) {
        return Qt4::qVariantValue($this, 'Qt4::TextLength');
    }
    elsif( $type == Qt4::Variant::Time() ) {
        return $this->toTime();
    }
    elsif( $type == Qt4::Variant::UInt() ) {
        return $this->toUInt();
    }
    elsif( $type == Qt4::Variant::ULongLong() ) {
        return $this->toULongLong();
    }
    elsif( $type == Qt4::Variant::Url() ) {
        return $this->toUrl();
    }
    else {
        return Qt4::qVariantValue($this);
    }
});

sub String {
    return bless \shift, 'Qt4::String';
}

sub CString {
    return bless \shift, 'Qt4::CString';
}

sub Int {
    return bless \shift, 'Qt4::Int';
}

sub Uint {
    return bless \shift, 'Qt4::Uint';
}

sub Bool {
    return bless \shift, 'Qt4::Bool';
}

sub Short {
    return bless \shift, 'Qt4::Short';
}

sub Ushort {
    return bless \shift, 'Qt4::Ushort';
}

sub Uchar {
    return bless \shift, 'Qt4::Uchar';
}

1;

=pod

=head1 NAME

Qt4 - Perl bindings for the Qt version 4 library

=head1 SYNOPSIS

  use Qt4;
  my $app = Qt4::Application(\@ARGV);
  my $button = Qt4::PushButton( 'Hello, World!', undef);
  $button->show();
  exit $app->exit();

=head1 DESCRIPTION

This module provides a Perl interface to the Qt version 4 library.

=head2 EXPORTS

=over

Each of the exported subroutines is prototyped.

=over

=item qApp

Returns a reference to the Qt4::CoreApplication/Qt4::Application object.  This
mimics Qt's global qApp variable.

=item SIGNAL, SLOT

Used to format arguments to be passed to Qt4::Object::connect().

=item emit

This subroutine is actually syntactic sugar.  It is used to signify that the
following subroutine call is activating a signal.

=item CAST REF,CLASSNAME

Serves a similar function to bless(), but takes care of Qt4's specific quirks.

=back

=back

=head2 INTRODUCTION

This module provides bindings to a large part of the Qt library from Perl.
This includes the QtCore, QtGui, QtNetwork, QtDBus, QtSql, and QtSvg modules.

The module has been designed to work like writing Qt applications in C++.
However, a few things have been renamed.  Everything is in the Qt4::namespace.
This means that the first 'Q' in the Qt class name has been replaced with
Qt4::.  So QWidget becomes Qt4::Widget, QListView becomes Qt4::ListView, etc.
Also, for classes that use public data members, like QStyleOption and its
subclasses, a set<PropertyName> method is defined to assign to those variables.
For instance, QStyleOption has a 'version' property.  To assign to it, call
$option->setVersion( $value );

=head2 CONSTRUCTOR SYNTAX

A Qt object is constructed by calling a function called Qt4::<ClassName>(), not
Qt4::<ClassName>->new().  For instance, to make a QApplication, call
Qt4::Application( \@ARGV );

=head2 SUBCLASSING

To create a subclass of a Qt class, declare a package, and then declare that
package's base class by using Qt4::isa and passing it an argument.  Multiple
inheritance is not supported.  This package must implement a subroutine called
NEW.  The NEW method is the constructor for that class.  The first argument to
this method will be the name of the class being constructed, followed by the
arguments passed to the constructor (just like in normal object-oriented Perl).
The first thing that this method should do is call $class->SUPER::NEW().  This
call constructs that parent's base class, and also sets the special this()
value.  You don't need to return anything from NEW(), PerlQt will return the
value of this() to the caller, regardless of what is returned from NEW().  Any
package that wants to use your subclass should explicitly 'use' it, even if the
two packages are defined in the same file.

This is a stub of a class called 'MyWidget', that subclasses Qt4::Widget:
    package MyWidget;
    use Qt4;
    use Qt4::isa qw( Qt4::Widget );

    sub NEW {
        my ( $class, $parent ) = @_;
        $class->SUPER::NEW( $parent );
    }

    package main;
    use Qt4;
    use MyWidget;

    my $app = Qt4::Application(\@ARGV);
    my $widget = MyWidget();
    $widget->show();
    exit $app->exec();

=head2 THE this() VALUE

In a subclass, you don't get a reference to $self.  Instead, you use 'this'.
Not '$this', just 'this'.  In reality, it is a prototyped subroutine that
returns a hash reference, but you should use it any place you would use $self.
Since it is a hash reference, you can create hash keys and assign to them just
like you would any other hashref.

=head2 REIMPLEMENTING C++ FUNCTIONS

To reimplement a C++ function in Perl, just declare a subroutine with the same
name.  Since that instance of the class can already get a reference to itself
by calling 'this', it is not passed in as the first argument.  If the C++
function takes 2 arguments, @_ will contain 2 items.

=head2 PERL-SPECIFIC DOCUMENTATION

The following is a list of Perl-specific implementation details, broken up by
class.

=over

=item Qt4::Variant

According to the Qt4 documentation:

    Because QVariant is part of the Qt4Core library, it cannot provide
    conversion functions to data types defined in Qt4Gui, such as QColor,
    QImage, and QPixmap.  In other words, there is no toColor() function.
    Instead, you can use the QVariant::value() or the qVariantValue() template
    function.

PerlQt4 implements this functionality by supplying 2 functions,
Qt4::qVariantValue() and Qt4::qVariantFromValue().  These two functions, in
addition to handling the Qt4Gui types, can also handle Perl hash references and
array references.  To accomplish this, 2 metatypes have been declared, called
'HV*' and 'AV*'.

=over

=item Qt4::qVariantValue()

Returns:
An object of type $typename, or undef if the conversion cannot be made.

Args:
$variant: A Qt4::Variant object.
$typename: The name of the type of data you want out of the Qt4::Variant.  This
parameter is optional if the variant contains a Perl hash or array ref.

Description:
Equivalent to Qt4's qVariantValue() function.

=item Qt4::qVariantFromValue()

Returns:
A Qt4::Variant object containing a copy of the given value on success, undef on
failure.

Args:
$value: The value to place into the Qt4::Variant.

Description:
Equivalent to Qt4's qVariantFromValue() function.  If $value is a hash or array
ref, the resulting Qt4::Variant will have it's typeName set to 'HV*' or 'AV*',
respectively.

=back

=back

=head1 EXAMPLES

This module ships with a large number of examples.  These examples have been
directly translated to Perl from the C++ examples that ship with the Qt
library.  They can be accessed in the examples/ directory in the source tree.

=head1 SEE ALSO

The existing Qt4 documentation is very complete.  Use it for your reference.

Get the project's current version at http://code.google.com/p/perlqt4/

=head1 AUTHOR

Chris Burel, E<lt>chrisburel@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008-2009 by Chris Burel

Based on PerlQt3,
Copyright (C) 2002, Ashley Winters <jahqueel@yahoo.com>
Copyright (C) 2003, Germain Garand <germain@ebooksfrance.org>

Also based on QtRuby,
Copyright (C) 2003-2004, Richard Dale

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

# vim:ts=4:sw=4:et:sta
