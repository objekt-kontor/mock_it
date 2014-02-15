package Ok::MockIt::MethodInterceptorTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert 'assert_isa';

use Ok::MockIt::MethodInterceptor;
use Ok::MockIt::Executor::SimpleReturn;
use Ok::MockIt::MockedMethodCall;

sub constructor_parameters_set_correctly : Test('new') {
  my $self = shift;
  
  my $executor            = Ok::MockIt::Executor::SimpleReturn->new(1);
  my $object = bless {}, 'Test::MockedClass';
  
  my $mocked_method_name  = Ok::MockIt::MockedMethodCall->new({object => $object, method => 'test_something'});
  my $interceptor = Ok::MockIt::MethodInterceptor->new({executor => $executor, mocked_method_call => $mocked_method_name});
  
  assert_isa('Ok::MockIt::MethodInterceptor', $interceptor);
}


package Test::MockedClass; 

use Ok::MockIt::Class;
ensure_module_loaded('Ok::MockIt::Mock');
use Ok::MockIt::Mock;
our @ISA = qw(Ok::MockIt::Mock);

sub test_something {die 'test_something should not have been called' }

1;