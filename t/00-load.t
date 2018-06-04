use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'RPi::GPIOExpander::MCP23017' ) || print "Bail out!\n";
}

diag( "Testing RPi::GPIOExpander::MCP23017 $RPi::GPIOExpander::MCP23017::VERSION, Perl $], $^X" );
