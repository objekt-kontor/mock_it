package Ok::MockIt::StubClassGenerator;

use strict; 
use warnings;

use Ok::MockIt::Class;

sub new {
  my ($class, $call_registrar) = @_;
  
  $call_registrar = $call_registrar->{call_registrar} if ref($call_registrar) eq 'HASH';
  
  bless {call_registrar => $call_registrar}, $class;
}



sub call_registrar { shift->{call_registrar} } 

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


1