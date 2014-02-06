package Ok::MockIt::Executor::Die;

use Moose;
extends 'Ok::MockIt::Executor';

has to_throw => (is => 'ro', default => undef);

around BUILDARGS => sub {
  my ($original_method, $class, $to_throw) = @_;
  
  return $class->$original_method({to_throw => $to_throw});
};

no Moose;

sub execute {
  my $self = shift;
  
  die $self->to_throw;
}
__PACKAGE__->meta->make_immutable;