package Ok::MockIt::InterceptorRegistrar;

use Ok::MockIt::MethodInterceptor;
use Ok::MockIt::Executor::Die;
use Ok::MockIt::Executor::SimpleReturn;


sub new {
  my ($class, $args) = @_;
  
  my ($r, $meth) = ($args->{registrar}, $args->{mocked_method_call});
  die 'MethodCallRegistrar must be provided when instanciating InterceptorRegistrar' unless $r && ref($r) && $r->isa('Ok::MockIt::MethodCallRegistrar');
  die 'MockedMethodCall must be provided when instanciating InterceptorRegistrar' unless $meth && ref($meth) && $meth->isa('Ok::MockIt::MockedMethodCall');
  
  return bless $args, $class;   
}

sub registrar { shift->{registrar} }
sub mocked_method_call { shift->{mocked_method_call} }

sub register_call {
  my ($self, $executor) = @_;
  
  my $interceptor = Ok::MockIt::MethodInterceptor->new({executor => $executor, mocked_method_call => $self->mocked_method_call});
  
  $self->registrar->register_interceptor($interceptor);
}

sub do_return {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(@_);
  $self->register_call($executor);
}

sub do_die {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::Die->new(@_);
  $self->register_call($executor);
}
1