package Ok::MockIt::Class;

use Module::Load::Conditional;
use Class::Inspector;

use Exporter qw(import);
our @EXPORT = qw(get_unique_classname ensure_module_loaded list_module_functions);

my $OVERWRITTEN_NAMESPACES = {};

sub get_unique_classname {
  my $wuerzel = shift;
  
  my @chars = ("A".."Z", "a".."z");
  my $string = "";
  
  $wuerzel = $wuerzel ? "${wuerzel}::" : "";
  while(1) {
    $string .= $chars[rand @chars] for 1..8;
    my $mod = $wuerzel . ${string};
    return $mod unless Module::Load::Conditional::check_install( module => $mod );
  }
}

sub ensure_module_loaded {
  my ($module) = shift;
  
  eval {
    (my $file = $module) =~ s|::|/|g;
    require $file . '.pm';
  };
  $module->import();
}

sub list_module_functions {
  my $module = shift;
  
  ensure_module_loaded($module) unless Class::Inspector->loaded($module);
  my %functions = map { $_ => $_ } @{Class::Inspector->functions($module)}, @{Class::Inspector->methods($module)};
  return keys(%functions);
}

sub overwrite_function {
  my ($full_method_name, $new_method) = @_;
  
  
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
  my ($full_method_name, @args) = @_;
  
  return unless exists $OVERWRITTEN_NAMESPACES->{$full_method_name};
  return $OVERWRITTEN_NAMESPACES->{$full_method_name}->(@args);
}

sub reset_mocks {
  
  for my $full_method_name (keys(%$OVERWRITTEN_NAMESPACES)) {
    *{$full_method_name} = $OVERWRITTEN_NAMESPACES->{$full_method_name};
    delete $OVERWRITTEN_NAMESPACES->{$full_method_name};
  }
}

1;