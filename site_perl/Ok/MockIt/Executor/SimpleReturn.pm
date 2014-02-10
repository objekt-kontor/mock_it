package Ok::MockIt::Executor::SimpleReturn;
use strict;
use warnings;

use base qw(Ok::MockIt::Executor);


sub new {
  my $class = shift;
  
  return bless {arguments => [@_]}, $class; 
}

sub arguments { [@{shift->{arguments}}] }

sub args { @{shift->{arguments}} }

sub execute {
  my $self = shift;
  
  my @values = $self->args;
  return wantarray ? @values : shift @values;
}

1