use warnings;
use strict;

use RPi::GPIOExpander::MCP23017;

my $mod = 'RPi::GPIOExpander::MCP23017';

my $o = $mod->new(0x20);

my @pins = qw(0 15);

printf("IODIRA: 0b%b\n", $o->register(0x00));
printf("IODIRB: 0b%b\n", $o->register(0x01));

for my $pin (@pins){
    $o->mode($pin, 0);
    $o->write($pin, 1);
}
printf("IODIRA: 0b%b\n", $o->register(0x00));
printf("IODIRB: 0b%b\n", $o->register(0x01));

sleep 5;

for my $pin (@pins){
    $o->write($pin, 0);
    $o->mode($pin, 1);
}

printf("IODIRA: 0b%b\n", $o->register(0x00));
printf("IODIRB: 0b%b\n", $o->register(0x01));
