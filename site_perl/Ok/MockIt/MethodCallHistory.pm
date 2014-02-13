package Ok::MockIt::MethodCallHistory;

sub new {
  my ($class, $method) = @_;
  
  $method = $method->{method} if ref($method) eq 'HASH';
  bless {method => $method, calls => []}, $class; 
}

sub method { shift->{method} }

sub calls {  [@{shift->{calls}}] }

sub _register_call {
  my ($self, $method_call) = @_;
  
  return unless ref($method_call) && $method_call->isa('Ok::MockIt::MockedMethodCall');
  push(@{$self->{calls}}, $method_call);
}
sub _grep_calls {
  my ($self, $grep) = @_;
  
  grep { $grep->($_) } $self->all_calls;
}

sub  all_calls { @{shift->calls} }

sub matches($) {
  my ($self, $mocked_method_call) = @_;
  
  return () unless $mocked_method_call->method eq $self->method;
  return $self->_grep_calls(sub {$_->equals($mocked_method_call) } );
}

sub register_call($) {
  my ($self, $mocked_method_call) = @_;
  
  return unless $self->method eq $mocked_method_call->method;
  $self->_register_call($mocked_method_call);
}

1