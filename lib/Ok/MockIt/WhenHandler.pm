package Ok::MockIt::WhenHandler;

use strict;
use warnings;

use Ok::MockIt::InterceptorRegistrar;
use Ok::MockIt::MockedMethodCall;

sub new {
    my ($class, $args) = @_;
    
    my $self = bless $args, $class;
    return $self;
}

sub object { shift->{object} }
sub registrar { shift->{registrar} }

sub AUTOLOAD {
    my $self = shift;
    my ($p,$m) = our $AUTOLOAD =~ /(.*)::(.*)/;
    
    my $method_call = Ok::MockIt::MockedMethodCall->new({object => $self->object, method => $m, args => [@_]});
    my $registrar = Ok::MockIt::InterceptorRegistrar->new({mocked_method_call => $method_call, registrar => $self->registrar});
    
}

1;
