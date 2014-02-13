package Ok::MockIt::MethodCallRegistrar;

use Ok::MockIt::MethodCallHistory;

sub new {
  my $class = shift;
  
  return bless {
    _registered_calls         => {},
    _registered_interceptors  => {}
  }, $class;
}


sub _registered_calls { shift->{_registered_calls} }

sub _get_method_history { 
  my ($self, $method_key) = @_;
  
  return unless exists $self->_registered_calls->{$method_key};
  return $self->_registered_calls->{$method_key};
}

sub _has_method_history { 
  my ($self, $method_key) = @_; 
  
  exists $self->_registered_calls->{$method_key}; 
} 

sub _register_call {
  my ($self, $method_key, $method_call_history) = @_;
  
  return unless ref($method_call_history) && $method_call_history->isa('Ok::MockIt::MethodCallHistory');

  $self->_registered_calls->{$method_key} = $method_call_history;
};
      
sub _registered_interceptors { shift->{_registered_interceptors} }

sub _register_interceptor_container {
  my ($self, $method_key, $container) = @_;
  
  return unless ref($container) && $container->isa('Ok::MockIt::MethodInterceptorContainer');
  $self->_registered_interceptors->{$method_key} = $container;
}

sub _has_interceptors {
   my ($self, $method_key) = @_;
   
   exists $self->_registered_interceptors->{$method_key};
}

sub _get_interceptors  {
  my ($self, $method_key) = @_;
  
  return unless $self->_has_interceptors($method_key);
  return $self->_registered_interceptors->{$method_key};
}

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


package Ok::MockIt::MethodInterceptorContainer;

sub new {
  bless { _interceptors => [] }, $class;
}

sub interceptors { my @ints = @{shift->_interceptors}; return @ints;}

sub _interceptors { shift->{_interceptors} }

sub _matches {
  my ($self, $to_match) = @_;
  
  grep { $to_match->($_) } $self->interceptors; 
}

sub _set {
  my ($self, $index, $interceptor) = @_;
  
  $self->_interceptors->[$index] = $interceptor;
} 
  
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
  
1
