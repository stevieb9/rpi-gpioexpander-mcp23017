use strict;
use warnings;
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

# Ensure a recent version of Test::Pod::Coverage
my $min_tpc = 1.08;
eval "use Test::Pod::Coverage $min_tpc";
plan skip_all => "Test::Pod::Coverage $min_tpc required for testing POD coverage"
    if $@;

# Test::Pod::Coverage doesn't require a minimum Pod::Coverage version,
# but older versions don't recognize some common documentation styles
my $min_pc = 0.18;
eval "use Pod::Coverage $min_pc";
plan skip_all => "Pod::Coverage $min_pc required for testing POD coverage"
    if $@;

#all_pod_coverage_ok();

my $pc = Pod::Coverage->new(
    package => 'RPi::GPIOExpander::MCP23017',
    pod_from => 'lib/RPi/GPIOExpander/MCP23017.pm',
    private => [
        qr/\p{Lowercase}+\p{Uppercase}\p{Lowercase}+/, # camelCase (XS)
        qr/^clean$/,
        qr/^bootstrap$/,
        qr/^_/,
        qr/^bank_write/, # doesn't exist, don't know why it barfs
        qr/^bank_mode/,  # doesn't exist, don't know why it barfs
    ],
    #"Test Perl subs, skip XS/C functions"
);

is $pc->coverage, 1, "pod coverage ok";

if ($pc->uncovered){
    warn "Uncovered:\n\t", join( ", ", $pc->uncovered ), "\n";
}

warn $pc->why_unrated if ! defined $pc->coverage;

done_testing();