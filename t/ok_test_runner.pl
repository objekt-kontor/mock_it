use Ok::Test::Runner 'load_tests';

use Ok::Test::StdOutReporter;

use FindBin;
use lib "$FindBin::Bin/../lib";

load_tests($FindBin::Bin);

my $runner = new Ok::Test::Runner({listener => Ok::Test::StdOutReporter->new});

$runner->run;