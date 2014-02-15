package Ok::MockIt::MethodCallHistoryTest;

use strict;
use warnings;

use Ok::Test;
use Test::Assert ':assert';

use Ok::MockIt::MethodCallHistory;
use Ok::MockIt::MockedMethodCall;

sub instanciation_works : Test('new') {
  my $self = shift;
  
  my $test_method_name = 'test';
  my $history = Ok::MockIt::MethodCallHistory->new({method => $test_method_name});
  
  assert_true($history->isa('Ok::MockIt::MethodCallHistory'));
}

sub accepts_hash_as_argument : Test('new') {
  my $self = shift;
  
  my $test_method_name = 'test';
  my $history = Ok::MockIt::MethodCallHistory->new({method => $test_method_name});
  
  assert_str_equals($test_method_name, $history->method);
}

sub accepts_single_method_name_argument : Test('new') {
  my $self = shift;
  
  my $test_method_name = 'test';
  my $history = Ok::MockIt::MethodCallHistory->new($test_method_name);
  
  assert_str_equals($test_method_name, $history->method);
}

sub returns_undef_when_method_names_do_not_match : Test('matches') {
  my $self = shift;
  
  my $test_method_name1 = 'test1';
  my $test_method_name2 = 'test2';
  
  my $history = Ok::MockIt::MethodCallHistory->new({method => $test_method_name1});
  
  my $object = bless {}, 'Ok::MockIt::Mock';
  my $method_call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $test_method_name2});
  
  assert_null($history->matches($method_call));
}

sub compares_against_each_element_in_the_object_callhistory : Test('matches') {
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
  
  assert_equals(2, scalar(@result));
  
}

1;