use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Class::Trigger::Ordered',
    AUTHOR              => 'Satoshi Ohkubo <s.ohkubo@gmail.com>',
    VERSION_FROM        => 'lib/Class/Trigger/Ordered.pm',
    ABSTRACT_FROM       => 'lib/Class/Trigger/Ordered.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'     => 0.62,
        'Class::Trigger' => 0.10,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Class-Trigger-Ordered-*' },
);
