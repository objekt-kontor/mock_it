use utf8;

package Ok::MockIt::Executor::SimpleReturnTest;
#TEST_TYPE:Unit

use base 'Test::Unit::TestCase';

use Ok::MockIt::Executor::SimpleReturn;

sub test_new__accepts_any_arguments_and_maps_them_to_arguments_property {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(1, 2, 3);
  
  $self->assert_deep_equals([1, 2, 3], $executor->arguments);
}

sub test_execute__returns_all_contructor_arguments {
  my  $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(1, 2, 3);
  
  $self->assert_deep_equals([1, 2, 3], [$executor->execute]);
}

sub test_execute__returns_single_argument_in_non_scalar_context {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(qw(a b c ));
  
  $self->assert_str_equals('a', $executor->execute);
}

1;