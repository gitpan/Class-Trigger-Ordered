package Foo;

use strict;
use Class::Trigger::Ordered qw(INIT MAIN FINAL);

sub new { bless { finished => undef }, shift }

sub app {
    my $self = shift;
    $self = $self->new unless (ref $self);
    print "[app_0]\n";
    for (1) {
        $self->{finished} ? last : $self->call_trigger('INIT');
        $self->{finished} ? last : print "[app_1]\n";
        $self->{finished} ? last : $self->call_trigger('MAIN');
        $self->{finished} ? last : print "[app_2]\n";
        $self->{finished} ? last : $self->call_trigger('FINAL');
        $self->{finished} ? last : print "[app_3]\n";
    }
    print "[app_4]\n";
}

1;
