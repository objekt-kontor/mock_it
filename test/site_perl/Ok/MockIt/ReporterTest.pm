package Ok::MockIt::ReporterTest;

use base qw(Test::Unit::TestCase);
use Ok::MockIt::Reporter;
use Ok::MockIt;

sub test_method_calls__lists_all_calls {
  my $self = shift;
  
  my $mock = bless {}, Ok::MockIt::make_stub('RepTest');

  $mock->meth();
  $mock->meth(1);
  $mock->meth(2);
  $mock->meth(3);
  
  my $reporter = Ok::MockIt::Reporter->new;
  
  my $report = $reporter->method_calls($mock, 'meth');
  
  $self->assert_str_equals("Method meth called 4 times.\n meth()\n meth(1)\n meth(2)\n meth(3)\n", $report); 
}

sub test_method_calls__return_notice_when_no_calls_made_on_mock {
  my $self = shift;
  
  my $mock = bless {}, Ok::MockIt::make_stub('RepTest');
  
  my $reporter = Ok::MockIt::Reporter->new;
  
  my $report = $reporter->method_calls($mock, 'meth');
  
  $self->assert_str_equals("Method meth called 0 times.", $report);
}

package RepTest;

sub meth{}

1;