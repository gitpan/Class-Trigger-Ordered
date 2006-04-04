package Class::Trigger::Ordered;

use strict;
use warnings;
use Carp ();
use base qw/Class::Trigger/;

our $VERSION = '0.01';

{
    no strict 'refs';
    my @methods = qw(
        call_trigger
        __fetch_triggers
        __update_triggers
        __validate_triggerpoint
    );
    *{$_} = \&{"Class::Trigger::$_"} for @methods
}

sub import {
    my $class = shift;
    my $pkg = caller(0);
    unless ($pkg->can('mk_classdata')) {
        no strict 'refs';
        push @{"$pkg\::ISA"}, 'Class::Data::Inheritable'
    }
    $pkg->mk_classdata('__triggers');
    $pkg->mk_classdata('__triggerpoints');
    $pkg->mk_classdata('__ordered_backyard');
    $pkg->__triggerpoints({ map { $_ => 1 } @_ }) if @_;
    no strict 'refs';
    my @methods = qw/add_trigger call_trigger add_triggerpoints/;
    *{"$pkg\::$_"} = \&{$_} for @methods
}

sub add_triggerpoints {
    my $proto = shift;
    my $points = $proto->__triggerpoints || {};
    @{$points}{@_} = map { 1 } @_;
    $proto->__triggerpoints($points)
}

sub add_trigger {
    my $proto = shift;
    my $fetch = __fetch_backyard($proto) || {};
    my $backyard = __deep_copy($fetch);
    while (my ($when, $code) = splice @_, 0, 2) {
        local $2  = q{};
        my $save  = $when;
        my $order = ($when =~ s/\:(\d{1,2})?(.*)//xms) ? $1 : 100;
        $2 and Carp::croak("$save is invalid name for ".(ref $proto || $proto));
        __validate_triggerpoint($proto, $when);
        (ref $code ne 'CODE') and Carp::croak('add_trigger() needs coderef');
        __insert_backyard($backyard, $when, $order, $code)
    }
    __update_backyard($proto, $backyard);
    __update_triggers($proto, __create_triggers($backyard))
}

sub __fetch_backyard {
    my $proto = shift;
    (ref $proto and $proto->{__ordered_backyard}) || $proto->__ordered_backyard
}

sub __insert_backyard {
    my ($backyard, $when, $order, $code) = @_;
    ($backyard->{$when}->{__order} ||= {})->{$order} = 1;
    push @{$backyard->{$when}->{$order}}, $code
}

sub __update_backyard {
    my ($proto, $backyard) = @_;
    if (ref $proto) {
        $proto->{__ordered_backyard} = $backyard
    }
    else {
        $proto->__ordered_backyard($backyard)
    }
}

sub __create_triggers {
    my $backyard = shift;
    my %triggers;
    for my $key (keys %{$backyard}) {
        $triggers{$key} = [
            map  { @{$backyard->{$key}->{$_}} }
            sort { $a <=> $b } keys %{$backyard->{$key}->{__order}}
        ]
    }
    \%triggers
}

sub __deep_copy {
    my $backyard = shift;
    my %copy;
    for my $key (keys %{$backyard}) {
        my $ref = $copy{$key} = { %{$backyard->{$key}} };
        for my $rec (keys %{$ref}) {
            $ref->{$rec} =
                  ref $ref->{$rec} eq 'HASH'  ? { %{$ref->{$rec}} }
                : ref $ref->{$rec} eq 'ARRAY' ? [ @{$ref->{$rec}} ]
                : undef
        }
    }
    \%copy
}

1;
__END__

=head1 NAME

Class::Trigger::Ordered - A little flexibility was added to Class::Trigger

=head1 VERSION

Version 0.01

=head1 DESCRIPTION

In the beginning: Refer to L<Class::Trigger>.

Class::Trigger::Ordered enables the operation of the order by which
the trigger is called by installing priority when the trigger point is set.

=head1 SYNOPSIS

    package Foo;
    use Class::Trigger::Ordered qw(INIT_HOOK FINAL_HOOK);

    sub new { bless, {}, shift }

    sub run {
        my $self = shift;
        $self->call_trigger('INIT_HOOK');
        # Some codes
        $self->call_trigger('FINAL_HOOK');
    }

    package Bar;
    use base qw(Foo);

    __PACKAGE__->add_trigger('INIT_HOOK:50'  => \&sub1);
    __PACKAGE__->add_trigger('FINAL_HOOK:50' => \&sub2);

    package Baz;
    use base qw(Bar);

    __PACKAGE__->add_trigger('INIT_HOOK:20' => \&sub0);

    package main;

    Bar->run;       # called in order of sub1, sub2

    Baz->run;       # called in order of sub0, sub1, and sub2
    
    my $baz = Baz->new;

    $baz->add_trigger('FINAL_HOOK:20' => \&sub1_5);

    $baz->run;      # called in order of sub0, sub1, sub1_5, and sub2

=head1 FUNCTIONS

=head2 add_trigger

=head2 call_trigger

See also L<Class::Trigger>::call_trigger.

=head2 add_triggerpoints

=head1 SEE ALSO

L<Class::Trigger>, L<Class::Data::Inheritable>.

And, this module was made referring to one entry of famous certain blog :

L<http://blog.bulknews.net/mt/archives/001859.html>

Special thanks

    Tatsuhiko Miyagawa

=head1 BUGS

Please send the patch at any time when there are a bug and an improvement!

=head1 AUTHOR

Satoshi Ohkubo C<< <s.ohkubo at gmail.com> >>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
