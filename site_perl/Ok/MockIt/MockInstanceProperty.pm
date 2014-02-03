use utf8;

package Ok::MockIt::MockInstanceProperty;

use Moose;

has [qw(property_package property_name instance_package)] => ( is => 'ro', isa => 'Str');

no Moose;

sub generate_property {
  my $self = shift;
  {
    no strict 'refs';
    no warnings qw(redefine prototype);
    my ($package, $property) = ($self->property_package, $self->property_name);
    *{ "${package}::${property}" } = sub { my $s = shift; $s->{$property} = bless {}, $self->instance_package unless exists $s->{$property}; return $s->{$property}; };
  }
}

sub getter_setter {
  my $self = shift;
  $self->{property} = bless {}, 'package' unless $self->{property};
}
__PACKAGE__->meta->make_immutable;