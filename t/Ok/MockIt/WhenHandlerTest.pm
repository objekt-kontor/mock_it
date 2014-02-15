package Ok::MockIt::WhenHandlerTest;

use Ok::Test;
use Test::Assert ':assert';

use Ok::MockIt::WhenHandler;

sub registrar {
  my $self = shift;
  
  $self->{registrar} = Ok::MockIt::MethodCallRegistrar->new unless exists $self->{registrar};
  return $self->{registrar};
}

sub mock_instance {
  my $self = shift;
  
  $self->{mock_instance} = bless ({}, 'Ok::MockIt::Mock') unless exists $self->{mock_instance};
  return $self->{mock_instance};
}

sub constructor_works_with_mock_instance : Test('new') {
  my $self = shift;
  
  my $when_handler = Ok::MockIt::WhenHandler->new({registrar => $self->registrar, object => $self->mock_instance});
  assert_isa('Ok::MockIt::WhenHandler', $when_handler);
}

1