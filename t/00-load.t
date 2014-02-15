#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Ok::MockIt' ) || print "Bail out!\n";
}

diag( "Testing Ok::MockIt $Ok::MockIt::VERSION, Perl $], $^X" );
