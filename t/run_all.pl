use Cwd 'abs_path';
use Test::More tests => 34;

use Test::Unit::TestRunner;

my $runner = OkTestRunner->new;
$runner->do_run(Test::Unit::TestSuite->new('OkTests'), 0);

#ok(1, $_) for (@{$runner->{passes}});
#ok(0, $_) for (@{$runner->{fails}});

#Test::Unit::TestRunner->run('OkTests');
print "\nblah\n";
package OkTestRunner;

use base 'Test::Unit::TestRunner';

use Test::More;
sub add_error { ok(0, 'error'); my $self = shift; $self->{errors} = [] unless exists $self->{errors}; push @{$self->{fails}}, 'bummer'; }
sub add_failure { ok(0, 'failure'); my $self = shift; $self->{fails} = [] unless exists $self->{fails}; push @{$self->{fails}}, 'boo'; }
sub add_pass { ok(1, 'yay'); my $self = shift; $self->{passes} = [] unless exists $self->{passes}; push @{$self->{passes}}, 'yay'; }
sub start_test {
    my $self = shift;
    my ($test) = @_;
    #print ref($test) . "::" . $test->name . "\n";
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

