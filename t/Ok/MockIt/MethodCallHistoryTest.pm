use utf8;

package Ok::MockIt::MethodCallHistoryTest;
#TEST_TYPE:Unit

use base qw(Test::Unit::TestCase);

use Ok::MockIt::MethodCallHistory;
use Ok::MockIt::MockedMethodCall;

sub test_new {
  my $self = shift;
  
  my $test_method_name = 'test';
  my $history = Ok::MockIt::MethodCallHistory->new({method => $test_method_name});
  
  $self->assert($history->isa('Ok::MockIt::MethodCallHistory'));
}

sub test_new__accepts_hash_as_argument {
  my $self = shift;
  
  my $test_method_name = 'test';
  my $history = Ok::MockIt::MethodCallHistory->new({method => $test_method_name});
  
  $self->assert_str_equals($test_method_name, $history->method);
}

sub test_new__accepts_single_method_name_argument {
  my $self = shift;
  
  my $test_method_name = 'test';
  my $history = Ok::MockIt::MethodCallHistory->new($test_method_name);
  
  $self->assert_str_equals($test_method_name, $history->method);
}

sub test_matches__returns_undef_when_method_names_do_not_match {
  my $self = shift;
  
  my $test_method_name1 = 'test1';
  my $test_method_name2 = 'test2';
  
  my $history = Ok::MockIt::MethodCallHistory->new({method => $test_method_name1});
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method_call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $test_method_name2});
  
  $self->assert_null($history->matches($method_call));
}

sub test_matches__compares_against_each_element_in_the_object_callhistory {
  my $self = shift;
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method_name = 'test';
  
  my $equals_calls = {};
  
  
  my $mocked_method_call1 = Ok::MockIt::MockedMethodCall->new({object => $object,  method => $method_name, args => [1]});
  my $mocked_method_call2 = Ok::MockIt::MockedMethodCall->new({object => $object,  method => $method_name, args => [2]});
  my $mocked_method_call3 = Ok::MockIt::MockedMethodCall->new({object => $object,  method => $method_name, args => [3]});
  my $mocked_method_call4 = Ok::MockIt::MockedMethodCall->new({object => $object,  method => $method_name, args => [1]});
  
  my $history = Ok::MockIt::MethodCallHistory->new({method => $method_name});
  
  $history->register_call($mocked_method_call1);
  $history->register_call($mocked_method_call2);
  $history->register_call($mocked_method_call3);
  $history->register_call($mocked_method_call4);
  
  my @result = $history->matches($mocked_method_call1);
  
  $self->assert_equals(2, scalar(@result));
  
}

1;