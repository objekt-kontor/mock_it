use Ok::Test::Runner;
use Ok::Test::StandardListener;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Module::Find qw(useall setmoduledirs);

setmoduledirs("$FindBin::Bin");

useall('Ok');

my $runner = new Ok::Test::Runner({listener => TestReporter->new});

$runner->run;

package TestReporter;

use base qw(Ok::Test::StandardListener);

sub on_after { 
  my ($self, $test_list) = @_;
  
  my @passes  = grep { $_->result == Ok::Test::Result->PASS } @$test_list;
  my @fails   = grep { $_->result == Ok::Test::Result->FAIL } @$test_list;
  my @errors  = grep { $_->result == Ok::Test::Result->ERROR } @$test_list;
 
  my ($test_count, $pass_count, $fail_count, $error_count) = (scalar(@$test_list), scalar(@passes), scalar(@fails), scalar(@errors));
  
  print STDOUT "\nPassed $pass_count of $test_count tests\n";
  print STDOUT "\nThere were $fail_count failures.\n" if $fail_count > 1;
  print STDOUT "\nThere was 1 failure.\n" if $fail_count == 1;
  for(my $i = 0; $i < $fail_count; $i++) {
    my $e = $fails[$i]->error;
    my $p = $fails[$i]->package_name;
    $p =~ s/Test$//;
    print STDOUT ($i+1) . ") Testing method: '" . $p . "::" . $fails[$i]->arguments->[0] . "'\n\t"  . $fails[$i]->cannonical_method_name . "\n";
    print STDOUT "\t'" . ($e->message or $e->reason) . "' at " . $e->file . " line " . $e->line . ".";
  }
  print STDOUT "\n\nThere were $error_count errors.\n" if $error_count > 1;
  print STDOUT "There was 1 error.\n" if $error_count == 1; 
  for(my $i = 0; $i < $error_count; $i++) {
    my $p = $errors[$i]->package_name;
    $p =~ s/Test$//;
    my $msg = $errors[$i]->error->origin_exception . "";
    $msg =~ s/(\S)\s*$/$1.\n/ unless $msg =~ /\.$/;
    my $str =  ($i+1) . ") Testing method: '" . $p . "::" . $errors[$i]->arguments->[0] . "'\n\t" . $errors[$i]->cannonical_method_name . " (" . $errors[$i]->error->type->name . " error)\n\t$msg\n";
   print STDOUT $str;
  }
  
} 

