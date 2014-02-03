package Ok::Test::Runner;

use strict;
use warnings;

use Attribute::Handlers;

my $TEST_HASH = {};
 
sub UNIVERSAL::Test : ATTR(CODE) {
  my ($package, $symbol, $referent, $attr, $method_under_test, $phase) = @_;
  
  my $method_name = *{$symbol}{NAME};
  $TEST_HASH->{$package . "::" . $method_name} = { p => $package, m => $method_name };

}

1;