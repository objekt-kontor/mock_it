package Ok::MockItTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert ':assert';

use Ok::MockIt;

import TestPackage;

sub returns_mock_subclass_instance : Test('mock_it') {
  my $self = shift;
  
  
  my $mock = Ok::MockIt::mock_it('MockPackage2');
  
  assert_true($mock->isa('MockPackage2'));
  assert_true(ref($mock) ne 'MockPackage2');
  
  assert_true($mock->can('method_that_dies') ? 1 : 0);
  assert_true($mock->can('test_exported_function') ? 1 : 0);
  
}

sub overwrites_all_methods_of_the_wanted_package_in_mocked_instance : Test('mock_as_property'){
  my $self = shift;
  
  my $fake = TestPackage->new;
  
  my $mocked_object = $fake->test_property;  
  
  eval {
    
    $mocked_object->method_that_dies;
    $mocked_object->method_that_dies2;
  };
  my $error = $@;
  assert_true(!$error, $error);
}

sub verify_does_not_thow_error_when_tested_method_has_been_called : Test('verify') {
  my $self = shift;
  
  my $mocked_object = TestPackage->new->test_property;
  
  $mocked_object->method_that_dies;
  
  assert_true(1);
}

sub verify_false_when_the_method_has_not_been_called_the_expected_number_of_times : Test('verify') {
  my $self = shift;
  
  my $mocked_object = Ok::MockIt::mock_it 'MockPackage2';
  
  $mocked_object->method_that_dies;
  
  Ok::MockIt::was_called($mocked_object, 2)->method_that_dies;
  assert_true(not(Ok::MockIt::was_called($mocked_object, 2)->method_that_dies));
}

sub verify_false_when_when_method_is_not_called_with_exactly_expected_arguments : Test('verify') {
  my $self = shift;
  
  my $test_value = 1;
  my $some_other_value = 2;
  
  my $mocked_object = Ok::MockIt::mock_it 'MockPackage2';
  
  $mocked_object->method_that_dies($some_other_value);
  
  assert_true(not(Ok::MockIt::was_called($mocked_object)->method_that_dies($test_value)));
}

sub was_called_can_compare_objects : Test('was_called') {
  my $self = shift;
  
  my $test_object   = TestPackage->new;
  my $mocked_object = $test_object->test_property;
  
  $mocked_object->method_that_dies($test_object);
  
  Ok::MockIt::was_called($mocked_object)->method_that_dies($test_object);
}

sub when_and_do_return_correctly_return_value : Test('-', 'Acceptance'){
  my $self = shift;
  
  my $mock = Ok::MockIt::mock_it();
  
  Ok::MockIt::when($mock)->sample_method(1)->do_return(5);
  
  assert_num_equals(5, $mock->sample_method(1));
}

sub when_and_do_return_correctly_track_method_call : Test('-', 'Acceptance'){
  my $self = shift;
  
  my $mock = Ok::MockIt::mock_it();
  
  Ok::MockIt::when($mock)->sample_method(1)->do_return(5);
  $mock->sample_method(1);
  assert_true(Ok::MockIt::was_called($mock)->sample_method(1));
}

sub when_and_do_return_can_overwrite_existing_static_method : Test('-', 'Acceptance') {
  my $self = shift;
  
  my $expected_return_value = "EXPECTED_RETURN";
  
  Ok::MockIt::when('MockPackage1')->method_that_returns_5()->do_return($expected_return_value);
  
  assert_str_equals($expected_return_value, MockPackage1->method_that_returns_5);
}

sub when_and_do_return_call_overwritten_static_method_when_arguments_do_not_match : Test('-', 'Acceptance') {
  my $self = shift;
  
  Ok::MockIt::when('MockPackage1')->method_that_returns_5(1)->do_return(3);
  
  assert_equals(3, MockPackage1->method_that_returns_5(1)); 
  assert_equals(5, MockPackage1->method_that_returns_5(3)); 
}

sub when_and_do_return_respond_correctly_when_function_called_statically : Test('-','Acceptance') {
  my $self = shift;
  
  Ok::MockIt::when('MockPackage1')->method_that_returns_5(2)->do_return(3);
  
  assert_equals(3, MockPackage1::method_that_returns_5(2));
}


sub reset_mocks_returns_class_methods_to_their_orignal_state : Test('-', 'Acceptance') {
  my $self = shift;
  
  Ok::MockIt::when('MockPackage1')->method_that_returns_5(2)->do_return(2);
  
  
  assert_num_equals(2, MockPackage1->method_that_returns_5(2));
  Ok::MockIt::reset_mocks();
  
  assert_num_equals(5, MockPackage1->method_that_returns_5(2));
  
}

sub tear_down {
  Ok::MockIt::Class::reset_mocks();
} 

###########################################
package ModuleWithExportedFunction;

use Exporter qw(import);
our @EXPORT = qw(test_exported_function);

sub test_exported_function {
  die 'test_exported function called';
}



###########################################
package MockPackage1;

sub method_that_dies {
  die 'arrgghhhh method that dies 1';
}

sub method_that_returns_5 {
  return 5;
}

###########################################
package MockPackage2;

import ModuleWithExportedFunction;
use base 'MockPackage1';

sub method_that_dies2 {
  die 'arrgghhhh method that dies 2';
}

###########################################
package TestPackage;

use Ok::MockIt qw(mock_it);

sub test_property { my $self = shift; $self->{mock} = mock_it 'MockPackage2' unless exists $self->{mock}; return $self->{mock} }

sub new { bless {}, shift }

###########################################

1;