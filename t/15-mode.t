use warnings;
use strict;
use feature 'say';

use RPi::GPIOExpander::MCP23017;
use Test::More;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

for my $reg (0x00..0x01){
    is $o->register($reg, 255), 255, "pins in bank $reg are INPUT ok";

    if ($reg == 0x00) {
        for my $pin (0 .. 7) {
            $o->mode($pin, 0);
            is $o->register_bit($reg, $pin), 0, "pin $pin is now in OUTPUT ok";
        }
        is $o->register($reg, 255), 255, "pins in bank $reg back to INPUT ok";
    }


    if ($reg == 0x01) {
        for my $pin (8..15) {
            $o->mode($pin, 0);
            is $o->register_bit($reg, $pin), 0, "pin $pin is now in OUTPUT ok";
        }
        is $o->register($reg, 255), 255, "pins in bank $reg back to INPUT ok";
    }
}

done_testing();

