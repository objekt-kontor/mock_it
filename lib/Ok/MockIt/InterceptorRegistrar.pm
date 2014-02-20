package Ok::MockIt::InterceptorRegistrar;

use Ok::MockIt::Mock;
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
  
  $self->_overwrite_static_method if $self->mocked_method_call->is_static_method;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(@_);
  $self->register_call($executor);
}

sub do_die {
  my $self = shift;
  
  $self->_overwrite_static_method if $self->mocked_method_call->is_static_method;
  
  my $executor = Ok::MockIt::Executor::Die->new(@_);
  $self->register_call($executor);
}

sub _overwrite_static_method {
  my $self = shift;
  
  return unless $self->mocked_method_call->is_static_method;
  
  my $mocked_method = sub {
    my @args = @_;
    
    my $object = $self->_is_function_call($args[0]) ? $self->mocked_method_call->package_name : shift(@args);
    
    my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $self->mocked_method_call->method, args => [@args]});
    
    
    $self->registrar->register_call($call);
    my $interceptor = $self->registrar->find_interceptor($call);
    
    return Ok::MockIt::Class::execute_function($self->mocked_method_call->full_method_name, @_) unless $interceptor;
    return $interceptor->execute;
  };
  Ok::MockIt::Class::overwrite_function($self->mocked_method_call->full_method_name, $mocked_method);
}

sub _is_function_call {
  my ($self, $first_arg) = @_;
  
  return 1 unless $first_arg;
  return 0 if $self->mocked_method_call->object;
  return 1 if ref($first_arg);
  return $first_arg ne $self->mocked_method_call->package_name;
}
1