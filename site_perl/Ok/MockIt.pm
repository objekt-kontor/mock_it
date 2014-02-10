use utf8;

package Ok::MockIt;

use strict;
use warnings;

use Ok::MockIt::Utils;
use Ok::MockIt::MockedMethodCall;
use Ok::MockIt::MethodCallRegistrar;
use Ok::MockIt::StubClassGenerator;
use Ok::MockIt::VerifierGenerator;
use Ok::MockIt::MockInstanceProperty;
use Ok::MockIt::InterceptorStubGenerator;
use Ok::MockIt::Executor::SimpleReturn;
use Ok::MockIt::Executor::Die;

use Exporter qw(import);

our @EXPORT_OK = qw(mock_it fake_it do_return do_die verify method_calls);
	
my $REGISTRAR;

ensure_module_loaded('Ok::MockIt::Mock');

sub mock_it($$) {
  my ($property_name, $class_to_mock) = @_;
  
  my $caller = caller(0);
 
  my $stub_class = make_stub($class_to_mock);

  _generate_caller_property($caller, $property_name, $stub_class);
}

sub fake_it {
  my ($property_name, @methods) = @_;
  
  my $caller = caller(0);
  
  my $stub_class = make_stub(generate_fake_class(@methods));

  _generate_caller_property($caller, $property_name, $stub_class); 
}

sub _generate_caller_property($$$) {
  my ($caller, $property_name, $stub_class) = @_;
  
  Ok::MockIt::MockInstanceProperty->new({property_package => $caller, property_name => $property_name, instance_package => $stub_class})->generate_property;
}

sub make_stub($) {
  my $class_to_mock = shift;
  
  my $r = _get_or_create_registrar();
  die 'registrar was not created' unless $REGISTRAR;
  my $stubgen = Ok::MockIt::StubClassGenerator->new($r);
  $stubgen->generate_stubclass($class_to_mock);
}

sub _get_or_create_registrar {
  
  $REGISTRAR = Ok::MockIt::MethodCallRegistrar->new() unless $REGISTRAR;
  return $REGISTRAR;
}

sub do_return {
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(@_);
  return Ok::MockIt::InterceptorStubGenerator->new({executor => $executor, registrar => _get_or_create_registrar()});
}

sub do_die {
  
  my $executor = Ok::MockIt::Executor::Die->new(@_);
  return Ok::MockIt::InterceptorStubGenerator->new({executor => $executor, registrar => _get_or_create_registrar()});
}

sub verify {
  my ($mock_object, $count) = @_;
  
  my $args = {call_registrar => _get_or_create_registrar(), object => $mock_object};
  $args->{expected_calls} = $count if defined $count;
  
  return Ok::MockIt::VerifierGenerator->new($args)->create_verifier();
}

sub method_calls {
  my ($mock_object, $method) = @_;
  
  my $r = $REGISTRAR; 
  $r->all_calls_for_method(Ok::MockIt::MockedMethodCall->new({object => $mock_object, method => $method}));
}
1