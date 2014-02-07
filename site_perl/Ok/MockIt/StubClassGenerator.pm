package Ok::MockIt::StubClassGenerator;
use Ok::MockIt::Class;

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
  my ($self, $super_class) = @_;
  
  return $self->_generate_blind_stub unless $super_class;
  return $self->_generate_subclass_stub($super_class);
  
}

sub _generate_subclass_stub {
  my ($self, $super_class) = @_; 
  
  my @methods = list_module_functions($super_class);
  my $stub_class = get_unique_classname($super_class);
  {
    no strict 'refs';
    @{ "${stub_class}::ISA" } = ($super_class, 'Ok::MockIt::Mock');
    *{ "${stub_class}::DESTROY" } = sub {};
    
  }
  for my $m (@methods) {
   
    next if $m eq 'isa';
    next if $m eq 'DESTROY';
    {
      no strict 'refs';
      *{ "${stub_class}::${m}" } = sub {
  
        my $call = Ok::MockIt::MockedMethodCall->new({object => shift, method => $m, args => [@_]});
        return $self->_register_call_and_execute_interceptor($call);
      };
    }
  }
  
  return $stub_class;
}

sub _generate_blind_stub {
  my $self = shift;
  
  my $stub_class = get_unique_classname;
  {
    no strict 'refs';
    *{ "${stub_class}::isa" }       = sub { 1 }; 
    *{ "${stub_class}::can" }       = sub { 1 }; 
    *{ "${stub_class}::AUTOLOAD" }  = sub {
      my ($p, $m) = our $AUTOLOAD =~ /(.*)::(.*)/;
      return if $m eq 'DESTROY';
      my $call = Ok::MockIt::MockedMethodCall->new({object => shift, method => $m, args => [@_]});
      
      return $self->_register_call_and_execute_interceptor($call);
    };
  }
  return $stub_class;
}

sub _register_call_and_execute_interceptor {
  my ($self, $call) = @_;
  
  $self->call_registrar->register_call($call);
  my $interceptor = $self->call_registrar->find_interceptor($call);
      
  return unless $interceptor;
  return $interceptor->execute;
}


__PACKAGE__->meta->make_immutable;