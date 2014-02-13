package Ok::MockIt::VerifierGenerator;

sub new {
  my ( $class, $args ) = @_;
  
  bless $args, $class;
}

sub call_registrar  { shift->{call_registrar} }
sub object          { shift->{object} } 
sub expected_calls  { shift->{expected_calls} } 

use Ok::MockIt::Class;

sub generate_class {
  my ($self) = shift; 
  
  my $mocked_object_class = ref($self->object);
  my @methods             = list_module_functions($mocked_object_class);
  my $stub_class          = get_unique_classname("${mocked_object_class}::Verifier");
  my $expected_calls      = defined $self->expected_calls ? $self->expected_calls : 1;
  
  {
    no strict 'refs';
    *{ "${stub_class}::AUTOLOAD" } = sub {
        my $s = shift;

        my ( $package, $m ) = our $AUTOLOAD =~ /(.*)::(.*)/;
        return if $m eq 'DESTROY';
        
        my @args = @_;
        my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $self->object, method => $m, args => [@args]});
        my @calls = $self->call_registrar->matches($mocked_method_call);
        my $calls_count = scalar(@calls);
        return $calls_count == $expected_calls;
    }
  }
  {
    no strict 'refs';
    @{ "${stub_class}::ISA" } = 'MockObjectVerifier';
    *{ "${stub_class}::DESTROY" } = sub {};
  }
  
  return $stub_class;
}

sub create_verifier {
  my $self = shift;
  
  bless {}, $self->generate_class;
}


package MockObjectVerifier;
1;