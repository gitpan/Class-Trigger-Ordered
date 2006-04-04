use strict;
use Test::More qw(no_plan);

use IO::Scalar;

use lib qw(t/lib);
use Foo;

ok(
    Foo->add_trigger(INIT => sub { print "-init-\n" }),
    'add_trigger in Foo',
);

ok(
    Foo->add_trigger(FINAL => sub { print "-final-\n" }),
    'add_trigger in Foo',
);

my @stdout = qw(
    [app_0] -init- [app_1] [app_2] -final- [app_3] [app_4]
);

my $foo = Foo->new;

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    $foo->app;
    is $out, join("\n", @stdout) . "\n";
}

ok(
    $foo->add_trigger(MAIN => sub { print "-main-\n" }),
    'add_trigger in $foo',
);

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    $foo->app;
    is $out, join("\n", @stdout[0..2], '-main-', @stdout[3..6]) . "\n";
}

ok(
    Foo->add_trigger(INIT => sub { print "-init2-\n" }),
    'add_trigger in Foo',
);

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    Foo->app;
    is $out, join("\n", @stdout[0..1], '-init2-', @stdout[2..6]) . "\n";
}

