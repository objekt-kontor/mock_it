use utf8;

package Ok::MockIt::MethodCallHistory;

use Moose;

has method => (is => 'ro', isa => 'Str', required => 1);
has calls  => (is => 'ro', isa => 'ArrayRef[Ok::MockIt::MockedMethodCall]', default => sub {[]}, traits => ['Array'], handles => {_register_call => 'push', grep_calls => 'grep', all_calls => 'elements'});

around BUILDARGS => sub {
  my ($original_method, $class) = (shift, shift);
  
  my $args = shift;
  return $class->$original_method($args) if ref($args) eq 'HASH';
  
  return $class->$original_method({method => $args});
};

no Moose;
sub matches($) {
  my ($self, $mocked_method_call) = @_;
  
  return () unless $mocked_method_call->method eq $self->method;
  return $self->grep_calls(sub {$_->equals($mocked_method_call) } );
}

sub register_call($) {
  my ($self, $mocked_method_call) = @_;
  
  return unless $self->method eq $mocked_method_call->method;
  $self->_register_call($mocked_method_call);
}
__PACKAGE__->meta->make_immutable;