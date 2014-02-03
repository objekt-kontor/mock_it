use utf8;

use strict;
use warnings;

package Ok::MockIt::MethodCallRegistrarTest;
#TEST_TYPE:Unit

use base qw(Test::Unit::TestCase);

use Ok::MockIt::MethodCallRegistrar;
use Ok::MockIt::MockedMethodCall;
use Ok::MockIt::Executor::SimpleReturn;
use Ok::MockIt::MethodInterceptor;

sub _get_method_call {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method_name = 'test';
  
  return Ok::MockIt::MockedMethodCall->new({object => $object, method => $method_name});

}

sub test_register_call__saves_call_correctly {
  my $self = shift;
  
  my $method_call = $self->_get_method_call;
  my $history = Ok::MockIt::MethodCallRegistrar->new();
  
  $history->register_call($method_call);
  
  my $call = $history->matches($method_call);
  
  $self->assert($call);

}

sub test_register_interceptor__adds_new_interceptor {
  my $self = shift;
  
  my $registrar = Ok::MockIt::MethodCallRegistrar->new;
  my $interceptor = $self->_get_interceptor;
  
  $registrar->register_interceptor($interceptor);
  
  my $found = $registrar->find_interceptor($interceptor->mocked_method_call);
  
  $self->assert_equals($interceptor, $found);
}

sub _get_interceptor {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(100);
  my $object = bless {}, 'RegistrarTest';
  my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $object, method => 'test_method'});
  
  return Ok::MockIt::MethodInterceptor->new({executor => $executor, mocked_method_call => $mocked_method_call});
}

package RegistrarTest;

use Ok::MockIt::Utils;

ensure_module_loaded('Ok::MockIt::Mock');

our @ISA = qw(Ok::MockIt::Mock);

sub test_method{};
1;