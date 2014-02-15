use utf8;

package Ok::MockIt::MockedMethodCall;

use vars qw(@ISA @EXPORT $VERSION $DEBUG %been_there);
use Carp;
use Scalar::Util;
use Data::Compare;

my %handler;

sub new {
  my $class = shift;
  
  my $args = shift;
  
  my $self = bless {
    object => exists($args->{object}) && ref($args->{object}) && $args->{object}->isa('Ok::MockIt::Mock') ? $args->{object} : undef,
    method => $args->{method},
    args   => $args->{args}
  }, $class;
}

sub object { shift->{object} } 
sub method { shift->{method} }
sub args   { shift->{args} }

sub simple_key {
  my $self = shift;
  
  return Scalar::Util::refaddr($self->object) . "::" . $self->method;
}

sub equals($) {
  my ($self, $other_call) = @_;
  
  return 0 unless ref($other_call) && $other_call->isa('Ok::MockIt::MockedMethodCall');
  return 0 unless Scalar::Util::refaddr($other_call->object) == Scalar::Util::refaddr($self->object);
  return 0 unless $self->method eq $other_call->method;
  return 1 if !defined($self->args) && !defined($other_call->args);
  return Compare($self->args, $other_call->args); 
}


1;