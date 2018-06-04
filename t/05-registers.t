use warnings;
use strict;
use feature 'say';

use RPi::GPIOExpander::MCP23017;
use Test::More;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

# writable registers

for my $reg (0x00..0x09, 0x0C..0x0D, 0x14..0x15){
    for my $data (0..255){
        my $ret = $o->reg($reg, $data);
        is $ret, $data, "register $reg set to $data ok";
    }
}

{ # non writable: 0x0A-0x0B, 0x0E-0x11

    local $SIG{__WARN__} = sub {};

    for my $reg (0x0A .. 0x0B, 0x0E .. 0x11) {
        is eval {
                $o->reg($reg, 0xFF);
                1;
            }, undef, "writing to reg $reg croaks ok";
    }
}
done_testing();

