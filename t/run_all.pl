use Cwd 'abs_path';
use Test::More tests => 34;


BEGIN {
  my $abs_path = abs_path(__FILE__);

  my ($test_path) = $abs_path =~ /^(.*\/t\/).*/; 
  my ($base_path) = $abs_path =~ /^(.*)\/t\/.*/;

  push(@INC, $test_path, "$test_path/Ok", "$base_path/lib");
}

use Test::Unit::TestRunner;

my $runner = OkTestRunner->new;
$runner->do_run(Test::Unit::TestSuite->new('OkTests'), 0);

package OkTestRunner;

use base 'Test::Unit::TestRunner';

use Test::More;
sub add_error { ok(0, 'Error: '. shift->{test_name});}
sub add_failure { ok(0, 'Failure: ' . shift->{test_name});}
sub add_pass { ok(1, shift->{test_name});}
sub start_test {
    my $self = shift;
    my ($test) = @_;
    
   $self->{test_name} = ref($test) . "::" . $test->name . "\n";
   #$self->_print($self->{test_name} . "\n");
}
sub print_result {}

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

