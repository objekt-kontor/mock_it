package Ok::MockIt::MockInstanceProperty;


sub new {
  my ($class, $args) = @_;
  
  bless {
    property_package => $args->{property_package},
    property_name    => $args->{property_name},
    instance_package => $args->{instance_package}
  }, $class;
}

sub property_package {shift->{property_package} }
sub property_name { shift->{property_name} }
sub instance_package { shift->{instance_package} }

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

1