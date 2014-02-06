package Ok::MockIt::MockedMethodCall;

use vars qw(@ISA @EXPORT $VERSION $DEBUG %been_there);
use Carp;
use Scalar::Util;
use Data::Compare;

use Moose;

my %handler;

has object  => (is => 'ro', isa => 'Ok::MockIt::Mock');
has method  => (is => 'ro', isa => 'Str');
has args    => (is => 'ro', isa => 'ArrayRef');

no Moose;
sub simple_key {
  my $self = shift;
  
  return Scalar::Util::refaddr($self->object) . "::" . $self->method;
}

sub equals($) {
  my ($self, $other_call) = @_;
  
  return 0 unless UNIVERSAL::isa($other_call, 'Ok::MockIt::MockedMethodCall');
  return 0 unless Scalar::Util::refaddr($other_call->object) == Scalar::Util::refaddr($self->object);
  return 0 unless $self->method eq $other_call->method;
  return 1 if !defined($self->args) && !defined($other_call->args);
  return Compare($self->args, $other_call->args); 
}


__PACKAGE__->meta->make_immutable;