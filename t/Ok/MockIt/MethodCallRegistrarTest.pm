package Ok::MockIt::MethodCallRegistrarTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert ':assert';

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

sub saves_call_correctly : Test('register_call') {
  my $self = shift;
  
  my $method_call = $self->_get_method_call;
  my $history = Ok::MockIt::MethodCallRegistrar->new();
  
  $history->register_call($method_call);
  
  my $call = $history->matches($method_call);
  
  assert_true($call);

}

sub adds_new_interceptor : Test('register_interceptor') {
  my $self = shift;
  
  my $registrar = Ok::MockIt::MethodCallRegistrar->new;
  my $interceptor = $self->_get_interceptor;
  
  $registrar->register_interceptor($interceptor);
  
  my $found = $registrar->find_interceptor($interceptor->mocked_method_call);
  
  assert_equals($interceptor, $found);
}

sub _get_interceptor {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(100);
  my $object = bless {}, 'RegistrarTest';
  my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $object, method => 'test_method'});
  
  return Ok::MockIt::MethodInterceptor->new({executor => $executor, mocked_method_call => $mocked_method_call});
}

package RegistrarTest;

use Ok::MockIt::Class;

ensure_module_loaded('Ok::MockIt::Mock');

our @ISA = qw(Ok::MockIt::Mock);

sub test_method{};
1;