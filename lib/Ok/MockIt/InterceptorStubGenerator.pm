use utf8;

package Ok::MockIt::InterceptorStubGenerator;

use Moose;

use Ok::MockIt::Utils;
use Ok::MockIt::MockedMethodCall;
use Ok::MockIt::MethodInterceptor;


has registrar => (is => 'ro', isa => 'Ok::MockIt::MethodCallRegistrar', required => 1);
has executor  => (is => 'ro', isa => 'Ok::MockIt::Executor', required => 1);
has object    => (is => 'ro', isa => 'Ok::MockIt::Mock', writer => '_object');
 
sub when {
  my ($self, $mock_object) = @_;
  
  $self->_object($mock_object);
  my $class = $self->_generate_registrar_stubclass(ref($mock_object));
  
  return bless {}, $class;
}

sub register_call {
  my ($self, $method, @args) = @_;
  
  my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $self->object, method => $method, args => [@args]});
  
  my $interceptor = Ok::MockIt::MethodInterceptor->new({executor => $self->executor, mocked_method_call => $mocked_method_call});
  
  $self->registrar->register_interceptor($interceptor);
}

sub _generate_registrar_stubclass {
  my ($self, $super_class) = @_;
  
  my @methods = list_module_functions($super_class);
  my $stub_class = get_unique_classname($super_class);
  for my $m (@methods) {
    next if $m eq 'DESTROY';
    {
      no strict 'refs';
      *{ "${stub_class}::${m}" } = sub {shift; $self->register_call($m, @_);};
    }
  }
  {
    no strict 'refs';
    @{ "${stub_class}::ISA" } = ($super_class, 'Ok::MockIt::InterceptorStub');
  } 
  
  return $stub_class;
}

no Moose;

__PACKAGE__->meta->make_immutable;

package Ok::MockIt::InterceptorStub;
1