package Ok::MockIt::Executor;

use strict;
use warnings;

sub execute { die 'Execute must be implemented in ' . ref($_) } 

1