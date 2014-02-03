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
          unless( $calls_count == $expected_calls ) {
            
            my $args_msg = scalar(@args) ? "(\n" . YAML::Dump(@args) . "\n)" : "()";
            my $calls_made = $self->call_registrar->all_calls_for_method($mocked_method_call);
            my $method_call_log = "There were no calls made to the method " . $mocked_method_call->method();
            if($calls_made) { 
              my $method_calls = scalar(@$method_call_log);
              $method_call_log = "There were " . scalar(@$calls_made) . " calls made";
              
              for my $call (@$calls_made) {
                $method_call_log .= "\n\n(" . YAML::Dump(@{$call->args}) . "\n)\n";
              }
            } 
            die "method '$m" . $args_msg . "' called " . $calls_count . ' times but expected: ' . $expected_calls . "\n\n$method_call_log";
          }
        };
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