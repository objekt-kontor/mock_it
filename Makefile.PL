package main;

require 5.008000;

use strict;
use warnings;
use ExtUtils::MakeMaker qw(WriteMakefile);

my $params = {
    NAME             => 'Ok::MockIt',
    AUTHOR           => q{Craig Buchanan <mockit@objekt-kontor.de>},
    VERSION_FROM     => 'lib/Ok/MockIt.pm',
    ABSTRACT_FROM    => 'lib/Ok/MockIt.pm',
    MIN_PERL_VERSION => 5.006,
    PREREQ_PM => {
        'Carp'                      => 0,
        'Class::Inspector'          => 0,
        'Data::Compare'             => 0,
        'Exporter'                  => 0,
        'Module::Load::Conditional' => 0,
        'Scalar::Util'              => 0,
    },
    TEST_REQUIRES => {
      'FindBin'                   => 0,
      'File::Find'                => 0,
      'Test::Assert'              => 0,
      'Test::More'                => 0,      
    },
    dist             => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean            => { FILES => 'Ok-MockIt-*' },
    test             => { TESTS => "t/*.t" }
};

$params->{MIN_PERL_VERSION} = 5.008 if ($ExtUtils::MakeMaker::VERSION ge '6.47_02'); 

WriteMakefile(%$params);
    
1;
