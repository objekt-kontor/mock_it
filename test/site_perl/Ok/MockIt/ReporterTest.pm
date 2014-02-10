package Ok::MockIt::ReporterTest;

use base qw(Test::Unit::TestCase);
use Ok::MockIt::Reporter;
use Ok::MockIt;

sub test_method_calls__lists_all_calls {
  my $self = shift;
  
  my $mock = Ok::MockIt::mock_it;
  
  $mock->meth();
  $mock->meth(1);
  $mock->meth(2);
  $mock->meth(3);
  
  my $reporter = Ok::MockIt::Reporter->new;
  
  my $report = $reporter->method_calls($mock, 'call');
  
  $self->assert_str_equals("Method call called 4 times.\n call()\n call(1)\n call(2)\n call(3)\n", $report); 
}

sub test_method_calls__return_notice_when_no_calls_made_on_mock {
  my $self = shift;
  
  my mock = Ok::MockIt::mock;
  
  my $reporter = Ok::MockIt::Reporter->new;
  
  my $report = $reporter->method_calls($mock, 'meth');
  
  $self->assert_str_equals("Method meth called 0 times.");
}

1;