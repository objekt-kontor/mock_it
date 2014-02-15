package Ok::MockIt::InterceptorRegistrarTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert ':assert';

use Ok::MockIt::InterceptorRegistrar;
use Ok::MockIt::Executor::SimpleReturn;
use Ok::MockIt::MethodCallRegistrar;
use Ok::MockIt::Class;

ensure_module_loaded('Ok::MockIt::Mock');

sub set_up {
  my $self = shift;
  
  $self->{mocked_method_call} = Ok::MockIt::MockedMethodCall->new({object => bless({}, 'Ok::MockIt::Mock'), method => 'meth'});
  $self->{registrar}  = Ok::MockIt::MethodCallRegistrar->new;
}

sub construction_with_arguments_works : Test('new') {
  my $self = shift;
  
  my $generator = Ok::MockIt::InterceptorRegistrar->new({mocked_method_call => $self->{mocked_method_call}, registrar => $self->{registrar}});
  
  assert_isa('Ok::MockIt::InterceptorRegistrar', $generator);
}

sub dies_when_no_mock_method_call_provided : Test('new') {
  my $self = shift;
  
  assert_raises("MockedMethodCall must be provided when instanciating InterceptorRegistrar",  sub { Ok::MockIt::InterceptorRegistrar->new({registrar => $self->{registrar}}) });
}

sub dies_when_no_registrar_provided : Test('new') {
  my $self = shift;
  
  assert_raises("MethodCallRegistrar must be provided when instanciating InterceptorRegistrar", sub {Ok::MockIt::InterceptorRegistrar->new({mocked_method_call => $self->{mocked_method_call}});} );
}

sub generated_stub_class_registers_new_method_interceptor : Test('when') {
  my $self = shift;
  
  my $registrar = Fake::Registrar->new();
  
  my $generator = Ok::MockIt::InterceptorRegistrar->new({mocked_method_call => $self->{mocked_method_call}, registrar => $registrar });
  my $object = bless {}, 'InterceptorTestClass';
  
  $generator->do_return('test_arg');
  
  my $registered_interceptor = $registrar->{registered_interceptor};
  
  assert_isa('Ok::MockIt::MethodInterceptor', $registered_interceptor);
  assert_equals($self->{mocked_method_call}, $registered_interceptor->mocked_method_call);
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