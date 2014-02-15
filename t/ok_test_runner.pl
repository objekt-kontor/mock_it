use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../../ok_test/lib";

use Ok::Test::Runner 'load_tests';
use Ok::Test::StdOutReporter;

load_tests($FindBin::Bin);

use Test::More;
plan tests => scalar(Ok::Test::get_loaded_tests) ;

my $runner = new Ok::Test::Runner({listener => Ok::Test::StdOutReporter->new});

$runner->run;