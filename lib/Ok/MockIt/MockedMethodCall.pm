use utf8;

package Ok::MockIt::MockedMethodCall;

use vars qw(@ISA @EXPORT $VERSION $DEBUG %been_there);
use Carp;
use Scalar::Util;
use Data::Compare;

sub new {
  my ($class, $args) = @_;
  
  my $self = bless {
    object        => $class->_get_object($args->{object}),
    package_name  => $class->_get_package_name($args->{object}),
    method        => $args->{method},
    args          => $args->{args}
  }, $class;
}

sub object { shift->{object} } 
sub package_name   { shift->{package_name} }
sub method { shift->{method} }
sub args   { shift->{args} }
sub full_method_name { my $self = shift; ($self->package_name ? $self->package_name . "::" : "") . $self->method; }
sub is_static_method { my $self = shift; !$self->object &&  $self->package_name }


sub _get_object {
  my ($self, $obj) = @_;
  
  return undef unless $obj;
  return undef unless ref($obj);
  die "Object passed to MockedMethodCall is not a mock object" unless $obj->isa('Ok::MockIt::Mock');
  
  return $obj; 
}

sub _get_package_name {
  my ($self, $package) = @_;
  
  return undef unless $package;
  return undef if ref $package;
  return $package;
}

sub simple_key {
  my $self = shift;
  
  return Scalar::Util::refaddr($self->object) . "::" . $self->method;
}

sub equals($) {
  my ($self, $other_call) = @_;
  
  return 0 unless ref($other_call) && $other_call->isa('Ok::MockIt::MockedMethodCall');
  return 0 unless $self->_objects_are_equal($other_call->object);
  return 0 unless $self->_package_names_are_equal($other_call->package_name);
  return 0 unless $self->method eq $other_call->method;
  return 1 if !defined($self->args) && !defined($other_call->args);
  return Compare($self->args, $other_call->args); 
}

sub _objects_are_equal {
  my ($self, $other_object) = @_;
  
  return 0 if $other_object && !$self->object;
  return 1 if !$self->object;
  return Scalar::Util::refaddr($other_object) == Scalar::Util::refaddr($self->object);
}

sub _package_names_are_equal {
  my ($self, $other_package_name) = @_;
  
  return 0 if $other_package_name && !$self->package_name;
  return 1 if !$self->package_name;
  return $other_package_name eq $self->package_name; 
}




1;