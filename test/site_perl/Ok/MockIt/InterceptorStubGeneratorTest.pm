use utf8;

package Ok::MockIt::InterceptorStubGeneratorTest;

use base 'Test::Unit::TestCase';

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

sub test_new {
  my $self = shift;
  
  my $generator = Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}, registrar => $self->{registrar}});
  
  $self->assert($generator->isa('Ok::MockIt::InterceptorStubGenerator'));
}

sub test_when__generated_stub_class_registers_new_method_interceptor {
  my $self = shift;
  
  
  my $registrar = Fake::Registrar->new();
  
  my $generator = Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}, registrar => $registrar });
  my $object = bless {}, 'InterceptorTestClass';
  
  $generator->when($object)->test_method('test_arg');
  
  my $registered_interceptor = $registrar->{registered_interceptor};
  
  $self->assert($registered_interceptor->isa('Ok::MockIt::MethodInterceptor'));
  $self->assert_equals('test_method', $registered_interceptor->mocked_method_call->method);
  $self->assert_deep_equals(['test_arg'], $registered_interceptor->mocked_method_call->args);
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