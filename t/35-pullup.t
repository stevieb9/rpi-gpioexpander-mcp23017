use warnings;
use strict;
use feature 'say';

use RPi::Const qw(:all);
use RPi::GPIOExpander::MCP23017;
use Test::More;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

for my $reg (MCP23017_GPPUA .. MCP23017_GPPUB){
    is $o->register($reg, 0x00), 0x00, "pullups in bank $reg are off ok";

    if ($reg == MCP23017_GPPUA){
        for my $pin (0 .. 7) {
            $o->pullup($pin, HIGH);
            is
                $o->register_bit($reg, $pin),
                HIGH,
                "pin $pin pullup is now on";

            $o->pullup($pin, LOW);
            is
                $o->register_bit($reg, $pin),
                LOW,
                "pin $pin pullup is now off";
        }
        is $o->register($reg, 0x00), 0x00, "pullups in bank $reg to off ok";
    }


    if ($reg == MCP23017_GPPUB){
        for my $pin (8..15) {
            $o->pullup($pin, HIGH);
            is
                $o->register_bit($reg, $pin),
                HIGH,
                "$pin pullup is now on ok";

            $o->pullup($pin, LOW);
            is
                $o->register_bit($reg, $pin),
                LOW,
                "pin $pin pullup is now off";
        }
        is $o->register($reg, 0x00), 0x00, "pullups in bank $reg to off ok";
    }
}

{ # get

    $o->cleanup;

    for (0..15){
        is $o->pullup($_), LOW, "pin $_ pullup off ok";

        $o->pullup($_, HIGH);
        is $o->pullup($_), HIGH, "pin $_ pullup on ok";

        $o->pullup($_, LOW);
        is $o->pullup($_), LOW, "pin $_ pullup back to off ok";
    }

#    $o->cleanup;
}
done_testing();

