use strict;
use Test::More tests => 6;

use IO::Scalar;

use lib qw(t/lib);
use Foo;
use Foo::Bar;

ok(
    Foo->add_trigger('MAIN:50' => sub { print "-main-\n" }),
    'add_trigger in Foo',
);

my @stdout = qw(
    [app_0] [app_1] -main- [app_2] [app_3] [app_4]
);

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    Foo->app;
    is $out, join("\n", @stdout) . "\n";
}

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    Foo::Bar->app;
    is $out, join("\n", $stdout[0], "-init:30\@Foo::Bar-", @stdout[1, 3..5]) . "\n";
}

my $bar = Foo::Bar->new;

ok(
    $bar->add_trigger('INIT:10' => sub { print "-init:10\@main-\n" }),
    'add_trigger in $bar',
);

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    $bar->app;
    is $out, join("\n", $stdout[0], '-init:10@main-', '-init:30@Foo::Bar-', @stdout[1, 3..5]) . "\n";
}

{
    my $out;
    tie *STDOUT, 'IO::Scalar', \$out;
    Foo->app;
    is $out, join("\n", @stdout) . "\n";
}

