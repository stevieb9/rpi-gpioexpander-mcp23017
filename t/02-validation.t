use strict;
use warnings;

use Test::More;

use RPi::GPIOExpander::MCP23017;

my $mod = 'RPi::GPIOExpander::MCP23017';

# HW-free unit coverage: the _check_* validators are plain package subs, and
# _pinBit (XS, GPIO_ prefix stripped) is a pure pin->bank-bit map with no fd -
# so none of this needs a chip. Runs ungated.

# --- _pinBit: pin -> register bit (bank A 0-7; bank B 8-15 wraps to 0-7) ---

is RPi::GPIOExpander::MCP23017::_pinBit(0),  0, "_pinBit(0) = 0";
is RPi::GPIOExpander::MCP23017::_pinBit(7),  7, "_pinBit(7) = 7";
is RPi::GPIOExpander::MCP23017::_pinBit(8),  0, "_pinBit(8) = 0 (bank B wraps)";
is RPi::GPIOExpander::MCP23017::_pinBit(15), 7, "_pinBit(15) = 7";

for my $bad (-1, 16, 99) {
    eval { RPi::GPIOExpander::MCP23017::_pinBit($bad) };
    like $@, qr/pin '$bad' is out of bounds/, "_pinBit($bad) croaks naming the pin (F2)";
}

# --- _check_bank / _check_mode / _check_pullup: accept 0/1, reject everything else ---

for my $check (qw(_check_bank _check_mode _check_pullup)) {
    my $fn = $mod->can($check);
    eval { $fn->(0) }; is $@, '', "$check(0) accepted";
    eval { $fn->(1) }; is $@, '', "$check(1) accepted";
    # Numeric out-of-range values; the checks use numeric != so a non-numeric
    # string would numify to 0 and (intentionally) pass.
    for my $bad (2, -1, 3) {
        eval { $fn->($bad) };
        like $@, qr/must be either 0 or 1/, "$check($bad) croaks";
    }
}

# --- _check_write: requires a defined 0/1 state ---

eval { RPi::GPIOExpander::MCP23017::_check_write(undef) };
like $@, qr/requires the state to be sent in/, "_check_write(undef) croaks";

eval { RPi::GPIOExpander::MCP23017::_check_write(2) };
like $@, qr/must be either 0 or 1/, "_check_write(2) croaks";

for my $ok (0, 1) {
    eval { RPi::GPIOExpander::MCP23017::_check_write($ok) };
    is $@, '', "_check_write($ok) accepted";
}

done_testing();
