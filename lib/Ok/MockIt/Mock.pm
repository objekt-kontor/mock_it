package Ok::MockIt::Mock;

use strict;
use warnings;

my $OVERWRITTEN_NAMESPACES = {};

sub overwrite_function {
  my ($package, $full_method_name, $new_method) = @_;
  
  
  my ($package_name, $method_name) = $full_method_name =~ /(.*)::(.*)/;
  eval "require $package_name;";
  
  {
    no strict 'refs';
    no warnings 'redefine';
    $OVERWRITTEN_NAMESPACES->{ $full_method_name } = *{ $full_method_name }{CODE} unless exists $OVERWRITTEN_NAMESPACES->{$full_method_name};
    *{$full_method_name} = $new_method;
  }
}

sub execute_function {
  my ($package, $full_method_name, @args) = @_;
  
  return unless exists $OVERWRITTEN_NAMESPACES->{$full_method_name};
  return $OVERWRITTEN_NAMESPACES->{$full_method_name}->(@args);
}

sub reset {
  
  for my $full_method_name (keys(%$OVERWRITTEN_NAMESPACES)) {
    *{$full_method_name} = $OVERWRITTEN_NAMESPACES->{$full_method_name};
    delete $OVERWRITTEN_NAMESPACES->{$full_method_name};
  }
}

1;