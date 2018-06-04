use warnings;
use strict;
use feature 'say';

use RPi::GPIOExpander::MCP23017;

my $addr = 0x20;

my $o = RPi::GPIOExpander::MCP23017->new($addr);


$o->mode(0, 0);
$o->mode(1, 0);
$o->mode(15, 0);
$o->write(15, 1);

say $o->read(15);

#say $o->reg(0x01);

for (0..21){
    printf("$_:\t 0b%b\n", $o->reg($_));
}

