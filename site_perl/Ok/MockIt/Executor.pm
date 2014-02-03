use utf8;

package Ok::MockIt::Executor;

use Moose;

has arguments => ( is => 'ro', required => 1, isa => 'ArrayRef', default => sub {[]}, traits => ['Array'], handles => { args => 'elements' } );

no Moose;

sub execute { die 'Execute must be implemented in ' . ref($_) } 
__PACKAGE__->meta->make_immutable;