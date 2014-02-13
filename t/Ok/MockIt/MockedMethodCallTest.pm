use utf8;

package Ok::MockIt::MockedMethodCallTest;
#TEST_TYPE:Unit

use base qw(Test::Unit::TestCase);

use Ok::MockIt::MockedMethodCall;

sub test_new {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  
  $self->assert($call->isa('Ok::MockIt::MockedMethodCall'));
}

sub test_equals__is_true_when_self_is_compared {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  
  $self->assert($call->equals($call));
}

sub test_equals__is_true_when_objects_and_methods_are_equal_and_args_are_undef {
  my $self = shift;
  
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method });
  
  $self->assert($call->equals($call2));
}

sub test_equals__is_false_when_methods_are_different {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method1 = 'test_method1';
  my $method2 = 'test_method2';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method1});
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method2 });
  
  $self->assert(!$call->equals($call2));
}

sub test_equals__is_false_when_object_instances_are_not_the_same {
  my $self = shift;
  
  my $object1 = bless {}, 'Ok::MockIt::Mock';
  my $object2 = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object1, method => $method });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object2, method => $method });
  
  $self->assert(!$call->equals($call2));
}

sub test_equals__is_true_when_args_are_same {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my @args = ('a', 'b', 5);
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  
  $self->assert($call->equals($call2));
}

sub test_equals__is_false_when_args_are_different {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my @args = ('a', 'b', 5);
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args, 3] });
  
  $self->assert(!$call->equals($call2));
}

sub test_equals__is_false_when_args_in_one_object_are_undef {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method = 'test_method';
  
  my @args = ('a', 'b', 5);
  
  my $call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method, args => [@args] });
  my $call2 = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method});
  
  $self->assert(!$call->equals($call2));
}



1;