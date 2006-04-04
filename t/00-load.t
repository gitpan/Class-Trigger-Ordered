#!perl -T

use strict;
use Test::More tests => 1;

BEGIN { use_ok('Class::Trigger::Ordered') }

diag("Testing Class::Trigger::Ordered $Class::Trigger::Ordered::VERSION, Perl $], $^X");
