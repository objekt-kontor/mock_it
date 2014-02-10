package Ok::MockIt::Reporter;

use Ok::MockIt;
use Ok::MockIt::MockedMethodCall;

sub new { bless {}, shift; }

sub method_calls {
  my ($self, $object, $method) = @_;
  
  my $calls = Ok::MockIt::method_calls($object, $method);
  
  my $header_str = $self->_method_calls_header_str($method, $calls);
  return $header_str unless $calls;
  
  my $return_str = $header_str . "\n";
  
  $return_str .= $self->_method_call_description($_) for(@$calls);
  return $return_str;
}

sub _method_calls_header_str {
  my ($self, $method, $calls) = @_;
  
  my $call_count = $calls ? scalar(@$calls) : 0;
  return "Method $method called $call_count times.";
}

sub _method_call_description {
  my ($self, $call) = @_;
  
  my $args = $call->args;
  
  return " " . $call->method . "(" . join(', ', @{$args}) . ")\n" if $args;
  return " " . $call->method . "()\n";
}

1;