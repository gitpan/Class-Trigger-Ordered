package Foo::Bar;

use strict;
use base qw(Foo);

__PACKAGE__->add_trigger(
    'INIT:30' => sub { print "-init:30\@Foo::Bar-\n" }
);

1;
