use utf8;

package Ok::MockIt::VerifierGenerator;

use Moose;

has call_registrar  => (is => 'ro', isa => 'Ok::MockIt::MethodCallRegistrar', required => 1);
has object          => (is => 'ro', isa => 'Ok::MockIt::Mock', required => 1);
has expected_calls  => (is => 'ro', isa => 'Maybe[Int]');

no Moose;
use Ok::MockIt::Utils;
use YAML;

sub generate_class {
  my ($self) = shift; 
  
  my $mocked_object_class = ref($self->object);
  my @methods             = list_module_functions($mocked_object_class);
  my $stub_class          = get_unique_classname("${mocked_object_class}::Verifier");
  my $expected_calls      = defined $self->expected_calls ? $self->expected_calls : 1;
  
  for my $m (@methods) {
    next if $m eq 'DESTROY';
    {
      no strict 'refs';
      *{ "${stub_class}::${m}" } = sub { 
          my $s = shift;
          my @args = @_;
          my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $self->object, method => $m, args => [@args]});
          my @calls = $self->call_registrar->matches($mocked_method_call);
          my $calls_count = scalar(@calls);
          return $calls_count == $expected_calls;
      }
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


__PACKAGE__->meta->make_immutable;

package MockObjectVerifier;
1;