use warnings;
use strict;
use feature 'say';

use RPi::Const qw(:all);
use RPi::GPIOExpander::MCP23017;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

$o->cleanup;

say $o->register(MCP23017_GPIOA);

for (0x00..0x15){
    printf("0x%x: 0b%b\n", $_, $o->register($_));
}

