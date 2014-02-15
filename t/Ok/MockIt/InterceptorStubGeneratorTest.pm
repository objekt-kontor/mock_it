package Ok::MockIt::InterceptorStubGeneratorTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert ':assert';

use Ok::MockIt::InterceptorStubGenerator;
use Ok::MockIt::Executor::SimpleReturn;
use Ok::MockIt::MethodCallRegistrar;
use Ok::MockIt::Class;

ensure_module_loaded('Ok::MockIt::Mock');

sub set_up {
  my $self = shift;
  
  $self->{executor}   = Ok::MockIt::Executor::SimpleReturn->new('TEST');
  $self->{registrar}  = Ok::MockIt::MethodCallRegistrar->new;
}

sub construction_with_arguments_works : Test('new') {
  my $self = shift;
  
  my $generator = Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}, registrar => $self->{registrar}});
  
  assert_isa('Ok::MockIt::InterceptorStubGenerator', $generator);
}

sub dies_when_no_executor_provided : Test('new') {
  my $self = shift;
  
  assert_raises("Executor must be provided when instanciating InterceptorStub",  sub { Ok::MockIt::InterceptorStubGenerator->new({registrar => $self->{registrar}}) });
}

sub dies_when_no_registrar_provided : Test('new') {
  my $self = shift;
  
  assert_raises("MethodCallRegistrar must be provided when instanciating InterceptorStub", sub {Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}});} );
}

sub generated_stub_class_registers_new_method_interceptor : Test('when') {
  my $self = shift;
  
  my $registrar = Fake::Registrar->new();
  
  my $generator = Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}, registrar => $registrar });
  my $object = bless {}, 'InterceptorTestClass';
  
  $generator->when($object)->test_method('test_arg');
  
  my $registered_interceptor = $registrar->{registered_interceptor};
  
  assert_isa('Ok::MockIt::MethodInterceptor', $registered_interceptor);
  assert_equals('test_method', $registered_interceptor->mocked_method_call->method);
  assert_deep_equals(['test_arg'], $registered_interceptor->mocked_method_call->args);
}


###################################################################################################################################################################################################
package Fake::Registrar;

use base 'Ok::MockIt::MethodCallRegistrar';

sub register_interceptor { $_[0]->{registered_interceptor} = $_[1]; } 
###################################################################################################################################################################################################
package InterceptorTestClass;

our @ISA = qw(Ok::MockIt::Mock);

sub test_method {}

1;