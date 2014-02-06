use Test::Unit::TestRunner;

my $runner = Test::Unit::TestRunner->new()->run('OkTests');

package OkTests;

use base 'Test::Unit::TestSuite';

use Module::Find;

sub include_tests {
  my @tests = grep { /Test$/} findallmod 'Ok';
  my @return_tests = ();
  for my $test_name (@tests) {
    eval{
      (my $file = $test_name) =~ s|::|/|g;
      $file .= '.pm';
      require $file;
      $test_name->import();
      push @return_tests, $test_name if $test_name->isa('Test::Unit::TestCase');
      1;
    };
  } 
  #print join("\n", @return_tests); 
  return @return_tests;
}

