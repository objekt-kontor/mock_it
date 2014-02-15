package Ok::MockIt::Executor::SimpleReturnTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert ':assert';


use Ok::MockIt::Executor::SimpleReturn;

sub accepts_any_arguments_and_maps_them_to_arguments_property : Test('new') {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(1, 2, 3);
  
  my $args = $executor->arguments;
  assert_deep_equals([1, 2, 3], $executor->arguments);
}

sub returns_all_contructor_arguments : Test('execute') {
  my  $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(1, 2, 3);
  
  assert_deep_equals([1, 2, 3], [$executor->execute]);
}

sub returns_single_argument_in_non_scalar_context : Test('execute') {
  my $self = shift;
  
  my $executor = Ok::MockIt::Executor::SimpleReturn->new(qw(a b c ));
  
  assert_str_equals('a', $executor->execute);
}

1;