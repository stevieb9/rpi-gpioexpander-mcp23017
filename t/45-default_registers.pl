use warnings;
use strict;
use feature 'say';

use RPi::Const qw(:all);
use RPi::GPIOExpander::MCP23017;
use Test::More;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

for (0x00..0x15){
    if ($_ == MCP23017_IODIRA || $_ == MCP23017_IODIRB){
        is $o->register($_), 0xFF, "register $_ back to 0xFF ok";
    }
    else {
        is $o->register($_), 0x00, "register $_ back to 0x00 ok";
    }
}

done_testing();

