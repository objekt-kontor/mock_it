use utf8;

package Ok::MockIt::Executor::SimpleReturn;

use Moose;
extends 'Ok::MockIt::Executor';

around BUILDARGS => sub {
  my ($original_method, $class) = (shift, shift);
  
  my $args = [@_];
  
  return $class->$original_method({arguments => $args});
};

no Moose;

sub execute {
  my $self = shift;
  
  my @values = $self->args;
  return wantarray ? @values : shift @values;
}

__PACKAGE__->meta->make_immutable;