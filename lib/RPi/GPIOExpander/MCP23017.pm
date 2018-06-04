package RPi::GPIOExpander::MCP23017;

use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('RPi::GPIOExpander::MCP23017', $VERSION);

use constant {
    IODIRA          => 0x00,
    IODIRB          => 0x01,

    GPIOA           => 0x12,
    GPIOB           => 0x13,
};

sub register_bit {
    my ($self, $reg, $bit) = @_;

    my $regval = getRegisterBit($self->_fd, $reg, $bit);
    return $regval;
}

sub register {
    my ($self, $reg, $data) = @_;

    if (defined $data){
        setRegister($self->_fd, $reg, $data, 'test');
    }
    my $regval = getRegister($self->_fd, $reg);
    return $regval;
}
sub new {
    my ($class, $addr) = @_;
    my $self = bless {}, $class;
    $self->_fd(getFd($addr));
    return $self;
}
sub bank_mode {
    my ($self, $bank, $mode) = @_;
    my $reg = $bank == 0 ? IODIRA : IODIRB;
    $mode = 255 if $mode == 1;
    setRegister($self->_fd, $reg, $mode, "bank_mode");
}
sub bank_write {
    my ($self, $bank, $state) = @_;
    my $reg = $bank == 0 ? GPIOA : GPIOB;
    $state = 255 if $state == 1;
    setRegister($self->_fd, $reg, $state, "bank_write");
}
sub mode {
    my ($self, $pin, $mode) = @_;
    pinMode($self->_fd, $pin, $mode);
}
sub read {
    my ($self, $pin) = @_;
    return readPin($self->_fd, $pin);
}

sub write {
    my ($self, $pin, $state) = @_;
    return writePin($self->_fd, $pin, $state);
}
sub clean {
    cleanup($_[0]->_fd);
}
sub _fd {
    my ($self, $fd) = @_;
    $self->{fd} = $fd if defined $fd;
    return $self->{fd};
}

1;
__END__

=head1 NAME

RPi::GPIOExpander::MCP23017 - The great new RPi::GPIOExpander::MCP23017!


=head1 SYNOPSIS


=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of RPi::GPIOExpander::MCP23017