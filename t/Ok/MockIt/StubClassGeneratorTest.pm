package Ok::MockIt::StubClassGeneratorTest;


use base 'Test::Unit::TestCase';

use Ok::MockIt::StubClassGenerator;
use Ok::MockIt::MethodCallRegistrar;


sub test_isa_is_overwritten_for_mocks_without_a_superclass {
  my $self = shift;
  
  my $gen = Ok::MockIt::StubClassGenerator->new(Ok::MockIt::MethodCallRegistrar->new);
  
  my $class = $gen->generate_stubclass();
  
  my $obj = bless {}, $class;
  
  $self->assert($obj->isa('Anything'));
}

sub test_can_is_overwritten_for_mocks_without_a_superclass {
  my $self = shift;
  
  my $class = Ok::MockIt::StubClassGenerator->new(Ok::MockIt::MethodCallRegistrar->new)->generate_stubclass;
  my $obj = bless {}, $class;
  
  $self->assert($obj->can('anything'));
}

1;