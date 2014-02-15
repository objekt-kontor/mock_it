package Ok::MockIt::MethodInterceptor;

use Exporter qw(import);

use Ok::MockIt::Class;
use Ok::MockIt::MockedMethodCall;

my $MOCKED_CALLS = {};

sub new {
  my ( $class, $args ) = @_;
  
  die 'No executor provieded.' unless exists $args->{executor} && $args->{executor}->isa('Ok::MockIt::Executor');
  die 'No method call provieded.' unless exists $args->{mocked_method_call} && $args->{mocked_method_call}->isa('Ok::MockIt::MockedMethodCall');
  
  bless  $args, $class;
}
sub executor { shift->{executor} }            #=> (is => 'ro', isa => 'Ok::MockIt::Executor', required => 1);
sub mocked_method_call  { shift->{mocked_method_call} } #=> (is => 'ro', isa => 'Ok::MockIt::MockedMethodCall', required => 1);

sub execute {
  shift->executor->execute;
}

sub simple_key {
  shift->mocked_method_call->simple_key;
}

#sub compares {
#  my $class       = shift;
#  my $method_name = shift;
#  my $object      = shift;
#   
#  my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method_name, args => [@_]});
#  
#  #my $compares = $mocked_method_call->equals($self->_mocked_method_call);
#  #return $mocked_method_call->equals($self->_mocked_method_call);
#}
#sub _find_interceptor {
#  my $method_name = shift;
#  my $object      = shift;
#  
#  my $mocked_method_call = Ok::MockIt::MockedMethodCall->new({object => $object, method => $method_name, args => [@_]});
#  
#    
#  my $obj_key = _obj_key($object);
#  return undef unless exists $MOCKED_CALLS->{$obj_key};
#  return undef unless exists $MOCKED_CALLS->{$obj_key}->{$method_name};
#    
#  my ($interceptor) = grep { $_->mocked_method_call->equals($mocked_method_call) } @{$MOCKED_CALLS->{$obj_key}->{$method_name}};
#  return $interceptor; 
#}
#
#sub _find_interceptor_index {
#  my $mocked_method_call = shift;
#  
#  my $obj_key = _obj_key($mocked_method_call->object);
#  return undef unless exists $MOCKED_CALLS->{$obj_key};
#  my $method_name = $mocked_method_call->method;
#  return undef unless exists $MOCKED_CALLS->{$obj_key}->{$method_name};
#  
#  my @interceptors = @{$MOCKED_CALLS->{$obj_key}->{$method_name}};
#  for(my $x = 0; $x < scalar(@interceptors); $x++) {
#    return $x if $interceptors[$x]->mocked_method_call->equals($mocked_method_call);
#  }
#  return undef;
#}
#
#
#
#sub _obj_key {  Scalar::Util::refaddr(shift) }
#
#sub _register_interceptor {
#  my $interceptor = shift;
#  
#  my $index = _find_interceptor_index($interceptor->mocked_method_call);
#  
#  my $obj_key = _obj_key($interceptor->mock_object);
#  my $method_name = $interceptor->mocked_method_call->method;
#   
#  $MOCKED_CALLS->{$obj_key} = {} unless exists $MOCKED_CALLS->{$obj_key};
#  $MOCKED_CALLS->{$obj_key}->{$method_name} = [] unless exists $MOCKED_CALLS->{$obj_key}->{$method_name};
#  
#  my $new_interception = !defined $index;
#  
#  $index = scalar(@{$MOCKED_CALLS->{$obj_key}->{$method_name}}) unless defined $index;
#  
#  $MOCKED_CALLS->{$obj_key}->{$method_name}->[$index] = $interceptor;
#  
#  return $new_interception;
#}
#
#sub when {
#  my ($self, $mock_object) = @_;
#  
#  $self->_mock_object($mock_object);
#  
#  return bless {}, $self->_generate_registrar_stubclass(ref($mock_object));
#}
#
#sub register_call {
#  my ($self, $method_name, @args) = @_;
#  
#  $self->mocked_method_call(Ok::MockIt::MockedMethodCall->new({object => $self->mock_object, method => $method_name, args => [@args]}));
#  
#  my $is_new_interceptor = _register_interceptor($self);
#
#  return unless $is_new_interceptor;
#    
#  my $stub_class = ref($self->mock_object); 
#  my $full_method_name = "${stub_class}::${method_name}";
#  
#  
#  {
#    no strict 'refs';
#    no warnings qw(redefine prototype);
#    my $old_method = *{$full_method_name}{CODE};
#    *{ $full_method_name } = sub { 
#        @args = @_;
#        $old_method->(@_); 
#        my $interceptor = _find_interceptor($method_name, @args);
#        return unless $interceptor;
#        my @values = $interceptor->returns;
#        return wantarray ? @values : shift @values;
#    };
#  }
#}
#
#sub _generate_registrar_stubclass {
#  my ($self, $super_class) = @_;
#  
#  my @methods = list_module_functions($super_class);
#  my $stub_class = get_unique_classname($super_class);
#  for my $m (@methods) {
#    next if $m eq 'DESTROY';
#    {
#      no strict 'refs';
#      *{ "${stub_class}::${m}" } = sub {shift; $self->register_call($m, @_);};
#    }
#  }
#  {
#    no strict 'refs';
#    @{ "${stub_class}::ISA" } = ($super_class, 'Ok::MockIt::MethodInterceptor::CallRegistrar');
#  } 
#  
#  return $stub_class;
#}
#
#__PACKAGE__->meta->make_immutable;
#
#package Ok::MockIt::MethodInterceptor::CallRegistrar;
#
#1;