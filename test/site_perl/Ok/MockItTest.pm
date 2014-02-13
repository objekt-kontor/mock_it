use utf8;

package Ok::MockItTest;
#TEST_TYPE:Unit

use strict;
use warnings;

use base qw(Test::Unit::TestCase);

import TestPackage;

use Ok::MockIt;

sub test_mock_it__returns_mock_subclass_instance {
  my $self = shift;
  
  
  my $mock = Ok::MockIt::mock_it('MockPackage2');
  
  $self->assert($mock->isa('MockPackage2'));
  $self->assert(ref($mock) ne 'MockPackage2');
  
  $self->assert($mock->can('method_that_dies') ? 1 : 0);
  $self->assert($mock->can('test_exported_function') ? 1 : 0);
  
}

sub test_mock_as_property__overwrites_all_methods_of_the_wanted_package_in_mocked_instance {
  my $self = shift;
  
  my $fake = TestPackage->new;
  
  my $mocked_object = $fake->test_property;  
  
  eval {
    
    $mocked_object->method_that_dies;
    $mocked_object->method_that_dies2;
  };
  my $error = $@;
  $self->assert(!$error, $error);
}

sub test_list_module_functions__includes_mocked_class_methods {
  my $self = shift;
  
  my @methods = Ok::MockIt::list_module_functions('MockPackage2');
  my $m1 = grep { /^method_that_dies2$/ } @methods;
  $self->assert($m1);
}

sub test_list_module_functions__includes_superclass_methods {
  my $self = shift;
  
  my @methods = Ok::MockIt::list_module_functions('MockPackage2');
  my $m1 = grep { /^method_that_dies$/ } @methods;
  $self->assert($m1);
}

sub test_list_module_functions__includes_imported_functions {
  my $self = shift;
  
  my @methods = Ok::MockIt::list_module_functions('MockPackage2');
  
  my $m1 = grep { /^test_exported_function$/ } @methods;
    
  $self->assert($m1);
  
  my $mock;
}

sub test_do_return__returns_specified_return_value_only_when_arguments_are_correct {
  my $self = shift;
  
  my $argument1 = "should_find";
  my $argument2 = "should not find"; 
  
  my $mocked_object = TestPackage->new->test_property;
  Ok::MockIt::do_return(50)->when($mocked_object)->method_that_dies($argument1);
  
  $self->assert_null($mocked_object->method_that_dies($argument2));
  $self->assert_equals(50, $mocked_object->method_that_dies($argument1));
}

sub test_do_return__sets_return_value_for_mock_object_method {
  my $self = shift;
 
  my $mocked_object = TestPackage->new->test_property;
  
  Ok::MockIt::do_return(100)->when($mocked_object)->method_that_dies;
  
  my $value = $mocked_object->method_that_dies;
  
  $self->assert_num_equals(100, $value);
}

sub test_verify__does_not_thow_error_when_tested_method_has_been_called {
  my $self = shift;
  
  my $mocked_object = TestPackage->new->test_property;
  
  $mocked_object->method_that_dies;
  
  $self->assert(1);
}

sub test_verify__false_when_the_method_has_not_been_called_the_expected_number_of_times {
  my $self = shift;
  
  my $mocked_object = Ok::MockIt::mock_it 'MockPackage2';
  
  $mocked_object->method_that_dies;
  
  Ok::MockIt::was_called($mocked_object, 2)->method_that_dies;
  $self->assert(not(Ok::MockIt::was_called($mocked_object, 2)->method_that_dies));
}

sub test_verify__false_when_when_method_is_not_called_with_exactly_expected_arguments {
  my $self = shift;
  
  my $test_value = 1;
  my $some_other_value = 2;
  
  my $mocked_object = Ok::MockIt::mock_it 'MockPackage2';
  
  $mocked_object->method_that_dies($some_other_value);
  
  $self->assert(not(Ok::MockIt::was_called($mocked_object)->method_that_dies($test_value)));
}

sub test_was_called__can_compare_objects {
  my $self = shift;
  
  my $test_object   = TestPackage->new;
  my $mocked_object = $test_object->test_property;
  
  $mocked_object->method_that_dies($test_object);
  
  Ok::MockIt::was_called($mocked_object)->method_that_dies($test_object);
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