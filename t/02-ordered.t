use strict;
use Test::More tests => 5;

use IO::Scalar;

use lib qw(t/lib);
use Foo;

ok(
    Foo->add_trigger('MAIN:50' => sub { print "-main-\n" }),
    'add_trigger in Foo',
);

my $foo = Foo->new;

my @stdout = qw(
    [app_0] [app_1] -main- [app_2] [app_3] [app_4]
);

ok(
    $foo->add_trigger('MAIN:20' => sub { print "-main0.5-\n" }),
    'add_trigger in $foo',
);

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    $foo->app;
    is $out, join("\n", @stdout[0..1], '-main0.5-', @stdout[2..5]) . "\n";
}

ok(
    $foo->add_trigger('MAIN:40' => sub { shift->{finished} = 1 }),
    'add_trigger in $foo',
);

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    $foo->app;
    is $out, join("\n", @stdout[0..1], '-main0.5-', @stdout[2, 5]) . "\n";
}

