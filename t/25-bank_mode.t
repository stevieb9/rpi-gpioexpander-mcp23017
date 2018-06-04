use warnings;
use strict;
use feature 'say';

use RPi::GPIOExpander::MCP23017;
use Test::More;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

{ # set on bank A (0)

    $o->clean;

    is $o->register(0x00, 255), 255, "IODIR pins in bank A are INPUT ok";
    is $o->register(0x01, 255), 255, "IODIR pins in bank B are INPUT ok";

    $o->bank_mode(0, 0);
    is $o->register(0x00), 0, "pins in bank 0 are OUTPUT ok";

    $o->bank_mode(1, 1);
    is $o->register(0x01), 255, "pins in bank 1 are INPUT ok";

    for (0..7){
        my ($pin_a, $pin_b) = ($_, $_ + 8);
        $o->write($pin_a, 1);
        is
            $o->read($pin_b),
            1,
            "reading bank A pin $pin_a from bank B $pin_b is HIGH ok";

        $o->write($pin_a, 0);
        is
            $o->read($pin_b),
            0,
            "reading bank A pin $pin_a from bank B $pin_b is LOW ok";
    }
}

{ # set on bank B (1)
    $o->clean;

    is $o->register(0x00, 255), 255, "IODIR pins in bank A are INPUT ok";
    is $o->register(0x01, 255), 255, "IODIR pins in bank B are INPUT ok";

    $o->bank_mode(1, 0);
    is $o->register(0x01), 0, "pins in bank 1(B) are OUTPUT ok";

    $o->bank_mode(0, 1);
    is $o->register(0x00), 255, "pins in bank 0(A) are INPUT ok";

    for (0..7){
        my ($pin_a, $pin_b) = ($_, $_ + 8);
        $o->write($pin_b, 1);
        is
            $o->read($pin_a),
            1,
            "reading bank B pin $pin_b from bank A $pin_a is HIGH ok";

        $o->write($pin_b, 0);
        is
            $o->read($pin_a),
            0,
            "reading bank B pin $pin_b from bank A $pin_a is LOW ok";
    }

    $o->clean;
}


done_testing();
