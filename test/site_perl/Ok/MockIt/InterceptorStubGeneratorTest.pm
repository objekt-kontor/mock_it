use utf8;

package Ok::MockIt::InterceptorStubGeneratorTest;

use base 'Test::Unit::TestCase';

use Ok::MockIt::InterceptorStubGenerator;
use Ok::MockIt::Executor::SimpleReturn;
use Ok::MockIt::MethodCallRegistrar;
use Ok::MockIt::Class;
use Test::Assert ':assert';

ensure_module_loaded('Ok::MockIt::Mock');

sub set_up {
  my $self = shift;
  
  $self->{executor}   = Ok::MockIt::Executor::SimpleReturn->new('TEST');
  $self->{registrar}  = Ok::MockIt::MethodCallRegistrar->new;
}

sub test_new {
  my $self = shift;
  
  my $generator = Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}, registrar => $self->{registrar}});
  
  assert_true($generator->isa('Ok::MockIt::InterceptorStubGenerator'));
}

sub test_new__dies_when_no_executor_provided {
  my $self = shift;
  
  assert_raises("Executor must be provided when instanciating InterceptorStub",  sub { Ok::MockIt::InterceptorStubGenerator->new({registrar => $self->{registrar}}) });
}

sub test_new__dies_when_no_registrar_provided {
  my $self = shift;
  
  assert_raises("MethodCallRegistrar must be provided when instanciating InterceptorStub", sub {Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}});} );
}

sub _test_when__generated_stub_class_registers_new_method_interceptor {
  my $self = shift;
  
  my $registrar = Fake::Registrar->new();
  
  my $generator = Ok::MockIt::InterceptorStubGenerator->new({executor => $self->{executor}, registrar => $registrar });
  my $object = bless {}, 'InterceptorTestClass';
  
  $generator->when($object)->test_method('test_arg');
  
  my $registered_interceptor = $registrar->{registered_interceptor};
  
  assert_true($registered_interceptor->isa('Ok::MockIt::MethodInterceptor'));
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