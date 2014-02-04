use utf8;

package Ok::MockIt::StubClassGenerator;
use Ok::MockIt::Utils;

use Moose;

has call_registrar => (is => 'ro', isa => 'Ok::MockIt::MethodCallRegistrar', required => 1);


around BUILDARGS => sub {
  my ($original_method, $class) = (shift, shift);
  
  my $arg = shift;
  return $class->$original_method($arg) if ref $arg eq 'HASH';
  return $class->$original_method({call_registrar => $arg});  
};
no Moose;

sub generate_stubclass {
  my ($self, $super_class, @fake_methods) = @_;
  
  $super_class = "" if $super_class eq "*";
  my @methods = list_module_functions($super_class) if $super_class;
  my $stub_class = get_unique_classname($super_class);
  {
    no strict 'refs';
    @{ "${stub_class}::ISA" } = ($super_class, 'Ok::MockIt::Mock');
    *{ "${stub_class}::DESTROY" } = sub {};
  }
  for my $m (@methods, @fake_methods) {
    next if $m eq 'isa';
    next if $m eq 'DESTROY';
    {
      no strict 'refs';
      *{ "${stub_class}::${m}" } = sub {
        my $call = Ok::MockIt::MockedMethodCall->new({object => shift, method => $m, args => [@_]});
        $self->call_registrar->register_call($call);
        my $interceptor = $self->call_registrar->find_interceptor($call);
        
        return unless $interceptor;
        $interceptor->execute;
      };
    }
  }
  
  return $stub_class;
}


__PACKAGE__->meta->make_immutable;