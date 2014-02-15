package Ok::MockIt::MethodInterceptorContainer;

use strict;
use warnings;

sub new {
  bless { _interceptors => [] }, shift;
}

sub interceptors { my @ints = @{shift->_interceptors}; return @ints;}

sub _interceptors { shift->{_interceptors} }

sub _matches {
  my ($self, $to_match) = @_;
  
  grep { $to_match->($_) } $self->interceptors; 
}

sub _set {
  my ($self, $index, $interceptor) = @_;
  
  $self->_interceptors->[$index] = $interceptor;
} 
  
sub register_interceptor {
   my ($self, $interceptor) = @_;
   
  my @interceptors = $self->interceptors;
  my $x = 0;
  for my $m ($self->interceptors) {
    last if $self->_method_calls_match($m->mocked_method_call, $interceptor->mocked_method_call);
    $x++;
  }
  $self->_set($x, $interceptor);
}

sub find_interceptor {
  my ($self, $mocked_method_call) = @_;
  
  my @matches = $self->_matches( sub { $self->_method_calls_match($_->mocked_method_call, $mocked_method_call) } );
  return shift @matches if scalar(@matches);
  return;
}

sub _method_calls_match {
  my ($self, $m1, $m2) = @_;
  
  return $m1->equals($m2);
}

1