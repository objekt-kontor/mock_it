use Cwd 'abs_path';
BEGIN {
  my $abs_path = abs_path(__FILE__);

  my ($test_path) = $abs_path =~ /^(.*\/test\/site_perl)\/.*/; 
  my ($base_path) = $abs_path =~ /^(.*)\/test\/site_perl\/.*/;

  push(@INC, $test_path, "$base_path/site_perl");
}

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
    } or do {
      my $error = $@;
      print $test_name . " could not be loaded: " . $error; 
    };
    
  } 
  #print join("\n", @return_tests); 
  return @return_tests;
}

