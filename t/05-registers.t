use warnings;
use strict;
use feature 'say';

use Test::More;

BEGIN {
    if (!$ENV{RPI_MCP23017}) {
        plan(skip_all => "RPI_MCP23017 environment variable not set");
    }

    if (!$ENV{RPI_SUBMODULE_TESTING}) {
        plan(skip_all => "RPI_SUBMODULE_TESTING environment variable not set");
    }
}

use RPi::Const qw(:all);
use RPi::GPIOExpander::MCP23017;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

# writable registers

for my $reg (0x00..0x09, 0x0C..0x0D, 0x14..0x15){
    for my $data (0..255){
        my $ret = $o->register($reg, $data);
        is $ret, $data, "register $reg set to $data ok";
    }
}

# reset the interrupt capture registers

$o->register(MCP23017_INTCAPA);
$o->register(MCP23017_INTCAPB);

{ # INTF/INTCAP (0x0E-0x11) are hardware read-only

    local $SIG{__WARN__} = sub {};

    for my $reg (0x0E .. 0x11) {
        is eval {
                $o->register($reg, 0xFF);
                1;
            }, undef, "writing to read-only reg $reg croaks ok";
    }
}

{ # IOCON (0x0A/0x0B) is writable except its BANK bit (bit 7)

    local $SIG{__WARN__} = sub {};

    # A non-BANK value goes through and reads back
    is $o->register(0x0A, 0x40), 0x40, "IOCON MIRROR (0x40) write ok";
    $o->register(0x0A, 0x00); # Restore IOCON to power-on defaults

    # Setting the BANK bit (0x80) is refused on either mirror address
    for my $reg (0x0A, 0x0B) {
        is eval {
                $o->register($reg, 0x80);
                1;
            }, undef, "setting IOCON.BANK on reg $reg croaks ok";
    }
}
done_testing();

