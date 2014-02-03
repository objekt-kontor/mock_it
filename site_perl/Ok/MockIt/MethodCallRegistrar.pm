use utf8;

package Ok::MockIt::MethodCallRegistrar;

use Moose;
use Ok::MockIt::MethodCallHistory;


has _registered_calls         => (
  is => 'ro',
  isa => 'HashRef[Ok::MockIt::MethodCallHistory]', 
  init_arg => undef, 
  default => sub{{}}, 
  traits => ['Hash'], 
  handles => { 
      _get_method_history   => 'get', 
      _has_method_history   => 'exists', 
      _register_call        => 'set', 
      _clear_method_history => 'delete' 
  }
);
      
has _registered_interceptors  => (
  is      => 'ro', 
  isa     => 'HashRef[Ok::MockIt::MethodInterceptorContainer]', 
  default => sub {{}},
  traits  => ['Hash'],
  handles => {
    _register_interceptor_container => 'set',
    _has_interceptors               => 'exists',
    _get_interceptors               => 'get',
  } 
);

sub register_call($) {
  my ($self, $mocked_method_call) = @_;
  
  $self->_get_or_create_method_call_history($mocked_method_call)->register_call($mocked_method_call);
}

sub matches($) {
  my ($self, $mocked_method_call) = @_;
  
  return () unless $self->_has_method_history($mocked_method_call->simple_key);
  return $self->_get_method_history($mocked_method_call->simple_key)->matches($mocked_method_call);
}

sub all_calls_for_method {
  my ($self, $mocked_method_call) = @_;
  
  my $object_history = $self->_get_method_history($mocked_method_call->simple_key);
  return undef unless $object_history;
  return [$object_history->all_calls];
}

sub register_interceptor($) {
  my ($self, $method_interceptor) = @_;
  
  my $container = $self->_get_or_create_interceptor_container($method_interceptor->mocked_method_call);
  $container->register_interceptor($method_interceptor);
}

sub find_interceptor($) {
  my ($self, $mocked_method_call) = @_;
  
  my $interceptors = $self->_get_interceptors($mocked_method_call->simple_key);
  return undef unless $interceptors;
  return $interceptors->find_interceptor($mocked_method_call)
}

sub _get_or_create_method_call_history {
  my ($self, $mocked_method_call) = @_;
  
  $self->_register_call($mocked_method_call->simple_key, Ok::MockIt::MethodCallHistory->new($mocked_method_call->method)) 
    unless $self->_has_method_history($mocked_method_call->simple_key);
  
  return $self->_get_method_history($mocked_method_call->simple_key);
}

sub _get_or_create_interceptor_container {
  my ($self, $mocked_method_call) = @_;
  
  $self->_register_interceptor_container($mocked_method_call->simple_key, Ok::MockIt::MethodInterceptorContainer->new())
    unless $self->_has_interceptors($mocked_method_call->simple_key);
  
  return $self->_get_interceptors($mocked_method_call->simple_key);
}


no Moose;
__PACKAGE__->meta->make_immutable;

package Ok::MockIt::MethodInterceptorContainer;

use Moose;

has _interceptors =>  (is => 'ro', isa => 'ArrayRef[Ok::MockIt::MethodInterceptor]', default => sub {[]}, init_arg => undef, traits => ['Array'], 
  handles => { _matches => 'grep',  interceptors => 'elements', _set => 'set'} );
  
sub register_interceptor {
   my ($self, $interceptor) = @_;
   
  my @interceptors = $self->interceptors;
  my $x = 0;
  for my $m ($self->interceptors) {
    last if $self->_method_calls_match($m->mocked_method_call, $interceptor->mocked_method_call);
    $x++;
  }
  $self->_set($x, $interceptor);
}

sub find_interceptor {
  my ($self, $mocked_method_call) = @_;
  
  my @matches = $self->_matches( sub { $self->_method_calls_match($_->mocked_method_call, $mocked_method_call) } );
  return shift @matches if scalar(@matches);
  return;
}

sub _method_calls_match {
  my ($self, $m1, $m2) = @_;
  
  return $m1->equals($m2);
}
  
no Moose;

__PACKAGE__->meta->make_immutable;

