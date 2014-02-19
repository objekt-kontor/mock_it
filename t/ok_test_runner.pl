use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/../lib";

use Ok::Test;

Ok::Test::Runner::load_tests($FindBin::Bin);

use Test::More;
plan tests => scalar(Ok::Test::get_loaded_tests) ;

my $runner = Ok::Test::Runner->new({listener => Ok::Test::TAPReporter->new});

$runner->run;