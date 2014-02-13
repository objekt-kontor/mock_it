use Cwd 'abs_path';
BEGIN {
  my $abs_path = abs_path(__FILE__);

  my ($test_path) = $abs_path =~ /^(.*\/test\/site_perl)\/.*/; 
  my ($base_path) = $abs_path =~ /^(.*)\/test\/site_perl\/.*/;

  push(@INC, $test_path, "$base_path/site_perl");
}

use Test::Unit::TestRunner;

use Ok::MockItTest;

#Ok::MockIt::MethodCallRegistrarTest->new->test_register_interceptor__adds_new_interceptor;
#for my $m (qw(
#  test_mock_it__returns_mock_subclass_instance
#  test_mock_as_property__overwrites_all_methods_of_the_wanted_package_in_mocked_instance
#  test_list_module_functions__includes_mocked_class_methods
#  test_list_module_functions__includes_superclass_methods
#  test_list_module_functions__includes_imported_functions
#  test_do_return__returns_specified_return_value_only_when_arguments_are_correct
#  test_do_return__sets_return_value_for_mock_object_method
#  test_verify__does_not_thow_error_when_tested_method_has_been_called
#  test_verify__false_when_the_method_has_not_been_called_the_expected_number_of_times
#)) {
# my $test = Ok::MockItTest->new;
# print "testing $m\n";
# $test->$m();  
#}
my $runner = Test::Unit::TestRunner->new()->run('OkTests');

package OkTests;

use base 'Test::Unit::TestSuite';

use Module::Find;

sub include_tests {
  
  
my @tests = qw( 
  Ok::MockIt::InterceptorStubGeneratorTest
  Ok::MockIt::MethodCallHistoryTest
  Ok::MockIt::MethodCallRegistrarTest
  Ok::MockIt::MethodInterceptorTest
  Ok::MockIt::MockedMethodCallTest
  Ok::MockIt::StubClassGeneratorTest
  Ok::MockItTest
);
return @tests;
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

