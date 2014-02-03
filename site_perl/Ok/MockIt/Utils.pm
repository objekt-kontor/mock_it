use utf8;

package Ok::MockIt::Utils;

use Module::Load::Conditional;
use Class::Inspector;

use Exporter qw(import);

our @EXPORT = qw(get_unique_classname ensure_module_loaded list_module_functions generate_fake_class);

sub get_unique_classname {
  my $wuerzel = shift;
  
  my @chars = ("A".."Z", "a".."z");
  my $string = "";
  while(1) {
    $string .= $chars[rand @chars] for 1..8;
    my $mod = "${wuerzel}::${string}";
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

sub generate_fake_class {
  my @method_names = @_;
  
  my $class_name = get_unique_classname('FAKE');
  {
    no strict 'refs';
    for my $m (@method_names) {
      $full_name = "${class_name}::${m}";
      *{$full_name} = sub {};
    }
  }
  return $class_name;
}
1;