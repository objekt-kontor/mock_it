package Ok::MockIt::Executor::Die;

use strict;
use warnings;


use base qw(Ok::MockIt::Executor);


sub new {
  my ($class, $to_throw) = @_;
  
  return bless {to_throw => $to_throw}, $class;  
}

sub to_throw { shift->{to_throw} }

sub execute {
  my $self = shift;
  
  die $self->to_throw;
}

1