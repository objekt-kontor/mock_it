package Ok::MockIt;

=head1 NAME

Ok::MockIt - The great new Ok::MockIt!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

use strict;
use warnings;

use Ok::MockIt::Class;
use Ok::MockIt::MockedMethodCall;
use Ok::MockIt::MethodCallRegistrar;
use Ok::MockIt::StubClassGenerator;
use Ok::MockIt::VerifierGenerator;
use Ok::MockIt::MockInstanceProperty;
use Ok::MockIt::WhenHandler;

use Exporter qw(import);

our @EXPORT_OK = qw(mock_it do_return do_die was_called);

my $REGISTRAR;

ensure_module_loaded('Ok::MockIt::Mock');

sub mock_it {
  my $class_to_mock = shift;
  
  my $stub_class = Ok::MockIt::StubClassGenerator->new(_get_or_create_registrar())->generate_stubclass($class_to_mock);
 
  return bless {}, $stub_class;
}

sub mock_as_property {
  
  my ($property_name, $class_to_mock) = @_;
  
  my $caller = caller(0);
 
  my $stub_class = make_stub($class_to_mock, @_);
  _generate_caller_property($caller, $property_name, $stub_class);
}

sub _generate_caller_property($$$) {
  my ($caller, $property_name, $stub_class) = @_;
  
  Ok::MockIt::MockInstanceProperty->new({property_package => $caller, property_name => $property_name, instance_package => $stub_class})->generate_property;
}

sub _get_or_create_registrar {
  
  $REGISTRAR = Ok::MockIt::MethodCallRegistrar->new() unless $REGISTRAR;
  return $REGISTRAR;
}

sub when {
  my $mock_object = shift;
  
  return Ok::MockIt::WhenHandler->new({object => $mock_object, registrar => _get_or_create_registrar()});
}

sub was_called {
  my ($mock_object, $count) = @_;
  
  my $args = {call_registrar => _get_or_create_registrar(), object => $mock_object};
  $args->{expected_calls} = $count if defined $count;
  
  return Ok::MockIt::VerifierGenerator->new($args)->create_verifier();
}

1