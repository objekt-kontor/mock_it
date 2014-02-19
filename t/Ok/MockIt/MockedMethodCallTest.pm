package Ok::MockIt::MockedMethodCallTest;

use Ok::Test;
use Test::Assert ':assert';

use Ok::MockIt::MockedMethodCall;

sub constructs_instance : Test('new') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  
  assert_true($call->isa('Ok::MockIt::MockedMethodCall'));
}

sub equals_is_true_when_self_is_compared : Test('equals') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  assert_true($call->equals($call));
}

sub equals_is_true_when_objects_and_methods_are_equal_and_args_are_undef : Test('equals') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  
  assert_true($call->equals($call2));
}

sub equals_is_false_when_methods_are_different : Test('equals') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method1 = 'test_method1';
  my $method2 = 'test_method2';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method1});
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method2 });
  
  assert_false($call->equals($call2));
}

sub equals_is_false_when_object_instances_are_not_the_same : Test('equals') {
  my $self = shift;
  
  my $object1 = bless {}, 'Ok::MockIt::Mock';
  my $object2 = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object1, method => $method });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object2, method => $method });
  
  assert_false($call->equals($call2));
}

sub equals_is_true_when_args_are_same : Test('equals') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my @args = ('a', 'b', 5);
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  
  assert_true($call->equals($call2));
}

sub equals_is_false_when_args_are_different : Test('equals') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my @args = ('a', 'b', 5);
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args, 3] });
  
  assert_true(!$call->equals($call2));
}

sub equals_is_false_when_args_in_one_object_are_undef : Test('equals') {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my @args = ('a', 'b', 5);
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method});
  
  assert_true(!$call->equals($call2));
}


1;