package Ok::MockIt::InterceptorStubGenerator;

use Ok::MockIt::Class;
use Ok::MockIt::MockedMethodCall;
use Ok::MockIt::MethodInterceptor;


sub new {
  my ($class, $args) = @_;
  
  die 'MethodCallRegistrar must be provided when instanciating InterceptorStub' unless exists($args->{registrar}) && ref($args->{registrar}) && $args->{registrar}->isa('Ok::MockIt::MethodCallRegistrar');
  die 'Executor must be provided when instanciating InterceptorStub' unless exists($args->{executor}) && ref($args->{executor}) && $args->{executor}->isa('Ok::MockIt::Executor');
  die 'Object for InterceptorStub must be a Mock' if exists($args->{object}) && !(ref($args->{object}) && $args->{object}->isa('Ok::MockIt::Mock'));
  
  return bless $args, $class;   
}

sub registrar { shift->{registrar} }
sub executor { shift->{executor} }
sub object { shift->{object} }
sub _object { my ($s, $obj) = @_; shift->{object} = $obj } 

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
  
  my $stub_class = get_unique_classname($super_class);

  {
    no strict 'refs';
    *{ "${stub_class}::AUTOLOAD" } = sub {
        my ($p, $m) = our $AUTOLOAD =~ /(.*)::(.*)/;
        shift; $self->register_call($m, @_);
    };
    *{ "${stub_class}::DESTROY" } = sub {};
    @{ "${stub_class}::ISA" } = ('Ok::MockIt::InterceptorStub');
  }
  
  return $stub_class;
}

package Ok::MockIt::InterceptorStub;
1