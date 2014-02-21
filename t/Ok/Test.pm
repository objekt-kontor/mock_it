package Ok::Test;

use strict;
use warnings;
our $VERSION = '0.01';
use Attribute::Handlers;

my @TESTS     = ();

sub UNIVERSAL::Test:ATTR(CODE) {
  my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;
  my $method = '';
  

  $method = *{$symbol}{NAME} if ref($symbol);
  my $full_name = $package . "::" . $method;

  push(@TESTS, Ok::Test::Meta->new({
    has_new                => $package->can('new') ? 1 : 0,
    has_set_up             => $package->can('set_up') ? 1 : 0,
    has_tear_down          => $package->can('set_up') ? 1 : 0,
    package_name           => $package, 
    method                 => $method,
    cannonical_method_name => $full_name,
    filename               => $filename,
    arguments              => $data,
    line                   => $linenum
  }));
}

sub get_loaded_tests {
  my  @tests = @TESTS;
  return @tests;
}

package Ok::Test::Meta;

use strict;
use warnings;

sub new {
  my ($class, $args) = @_;
  $args->{has_run} = 0;
  bless $args, shift;
}

sub has_new { shift->{has_new}; }
sub has_set_up { shift->{has_set_up} }
sub has_tear_down { shift->{has_tear_down} }
sub package_name { shift->{package_name} }
sub method { shift->{method} }
sub cannonical_method_name { shift->{cannonical_method_name} }
sub filename { shift->{filename} }
sub has_run { shift->{has_run} }
sub result { shift->{result} }
sub error { shift->{error} }
sub arguments { shift->{arguments} }
sub line { shift->{line} }

sub set_result {
  my ($self, $result) = @_;
  
  $self->{result} = $result;
  $self->{has_run} = 1;  
}

sub set_error {
  my ($self, $error) = @_;
  
  $self->{error} = $error;
}

package Ok::Test::Runner;

use strict;
use warnings;

our $VERSION = '0.01';

use sigtrap;
use File::Find;
use Exporter qw(import);

our @EXPORT_OK = qw(load_tests);

sub new {
  my ($class, $args) = @_;
  
  my $self = bless {listeners => [], filter => undef}, shift;
  
  my $listeners = $args->{listeners};
  if($listeners) {
    $self->_add_listener($_) for (@$listeners);
  } 
  
  $self->_add_listener($args->{listener});    
  $self->_add_filter($args->{filter});
  return $self;
}

sub _add_listener {
  my ($self, $listener) = @_;
  
  return unless $listener;
  
  push(@{$self->{listeners}}, $listener);
}

sub _listeners { @{shift->{listeners}} } 

sub _add_filter {
  my ($self, $filter) = @_;
  
  $self->{filter} = $filter; 
}

sub _filter { shift->{filter} }

sub _run_test {
  my ($self, $test_data) = @_;
  
  return if $test_data->has_run;
  for my $l ($self->_listeners) {
    $l->on_before($test_data) if $l->can('on_before');
  } 

  my $obj = $self->_construct_test_object($test_data);
  return unless $obj;
  
  if ($self->_do_set_up($obj, $test_data)) {
    $self->_execute_test($obj, $test_data);
  }
  $self->_do_tear_down($obj, $test_data);
}

sub _construct_test_object {
  my ($self, $test_data) = @_;
  
  my $package = $test_data->package_name;
  if( $test_data->has_new) { 
    my $obj = eval { $package->new };
    my $error = $@;
    return $obj if $obj;
    
    $self->_handle_constructor_error($test_data, $error) ;
    return;
  }
  return bless {}, $package;
}

sub _handle_constructor_error {
  my ($self, $test_data, $error) = @_;
  
  $error = "Nothing returned from constructor.\n" unless $error;
  $test_data->set_error(Ok::Test::Error->new($error, Ok::Test::ErrorType->CONSTRUCTOR));
  $test_data->set_result(Ok::Test::Result->ERROR);

  for my $l ($self->_listeners) {
    $l->on_error($test_data) if $l->can('on_error');
  }
}

sub _do_set_up {
  my ($self, $test_obj, $test_data) = @_;
  
  return 1 unless $test_data->has_set_up;
  
  eval { $test_obj->set_up() };
  my $error = $@;
  
  return 1 unless $error;
  
  $self->_handle_set_up_error($test_data, $error);
}

sub _handle_set_up_error {
  my ($self, $test_data, $error) = @_;
  
  $test_data->set_error(Ok::Test::Error->new($error, Ok::Test::ErrorType->SET_UP));
  $test_data->set_result(Ok::Test::Result->ERROR);
  
  for my $l ($self->_listeners) {
    $l->on_error($test_data) if $l->can('on_error');
  }
}

sub _execute_test {
  my ($self, $test_obj, $test_data) = @_;
  
  my $method = $test_data->method;
  eval { $test_obj->$method(); };
  my $error = $@;
  
  return $self->_handle_pass($test_data) unless $error;
  return $self->_handle_fail($test_data, $error) if ref($error) && $error->isa('Exception::Assertion');
  return $self->_handle_execution_error($test_data, $error);
    
}

sub _handle_pass {
  my ($self, $test_data) = @_;
  
  $test_data->set_result(Ok::Test::Result->PASS);
  for my $l ($self->_listeners) {
    $l->on_pass($test_data) if $l->can('on_pass');
  }
}

sub _handle_fail {
  my ($self, $test_data, $exception) = @_;
  
  $test_data->set_error($exception);
  $test_data->set_result(Ok::Test::Result->FAIL);
  
  for my $l ($self->_listeners) {
    $l->on_fail($test_data) if $l->can('on_fail');
  }
}

sub _handle_execution_error {
  my ($self, $test_data, $error) = @_;
  
  $test_data->set_error(Ok::Test::Error->new($error, Ok::Test::ErrorType->EXECUTION));
  $test_data->set_result(Ok::Test::Result->ERROR);
  
  for my $l ($self->_listeners) {
    $l->on_error($test_data) if $l->can('on_error');
  }
}

sub _do_tear_down {
  my ($self, $test_obj, $test_data) = @_;
  
  return unless $test_data->has_tear_down;
  eval { $test_obj->tear_down }
}

sub run {
  my $self = shift;
  sigtrap->import( qw/die normal-signals/ );
  sigtrap->import( qw/die error-signals/ );
    
  my @tests = $self->_get_runnable_tests();
  $self->_run_test($_) for (@tests);
  
  for my $l ($self->_listeners) {
    $l->on_after([@tests]) if $l->can('on_after');
  }
}

sub load_tests {

  find( sub {
    if ($_ =~ /\.pm/) {
      eval "require '" . $File::Find::name . "'" if $File::Find::name ne __FILE__;
    }  
  }, shift);
}

sub _get_runnable_tests {
  my $self = shift;
  
  my @test_meta = Ok::Test::get_loaded_tests();
  my @return_list = ();
  for my $test_data (@test_meta) {
    if($test_data->method eq '') {
      my $package = $test_data->package_name;
      my @keys = eval "keys( %${package}::)";
      for my $k (@keys) { 
        {
          no strict 'refs';
          require B;
          my $gv = B::svref_2object(\*{"${package}::${k}" });
          next unless $gv->FILE eq $test_data->filename;
          next unless $gv->LINE == $test_data->line;
          $test_data->{method} = $gv->NAME;
          $test_data->{cannonical_method_name} = $package . "::" . $gv->NAME;
        }
      } 
    }
    push(@return_list, $test_data) unless $test_data->has_run;
  }
  if( $self->{filter} ) {
    my @tmp_list = grep { $self->_filter->should_run($_) } @return_list;
    @return_list = @tmp_list;
  }
  return @return_list;
}


package Ok::Test::Error;

use strict;
use warnings;

sub new { 
  my ($class, $origin_exception, $type) = @_;
  
  bless { origin => $origin_exception, type => $type }, $class;
}

sub origin_exception { shift->{origin} }

sub type { shift->{type} }

package Ok::Test::ErrorType;

use strict;
use warnings;

my $TYPES = {
  constructor => bless ({name => 'constructor'}, __PACKAGE__),
  set_up      => bless ({name => 'set_up'}, __PACKAGE__),
  execution   => bless ({name => 'execution'}, __PACKAGE__),
};

sub CONSTRUCTOR { $TYPES->{constructor} }

sub SET_UP { $TYPES->{set_up}; }

sub EXECUTION { $TYPES->{execution}; }

sub name { shift->{name} }

package Ok::Test::Result;

use strict;
use warnings;

use Scalar::Util qw(refaddr);

my $RESULTS = {
  PASS  => bless ({name => 'PASS'}, __PACKAGE__),
  FAIL  => bless ({name => 'FAIL'}, __PACKAGE__),
  ERROR => bless ({name => 'ERROR'}, __PACKAGE__)
};

sub PASS {$RESULTS->{PASS}}
sub FAIL {$RESULTS->{FAIL}}
sub ERROR {$RESULTS->{ERROR}}

sub name { shift->{name} }

sub cmp {
  my ($self, $other) = @_;
  
  return 0 unless defined $other;
  return 0 unless ref($other);
  return refaddr($self) == refaddr($other); 
}
use overload 
  '==' => \&cmp,
  'eq' => \&cmp;
  
package Ok::Test::TAPReporter;
use Test::More;

sub new { bless {}, shift }

sub on_pass {
  ok(1, $_[1]->cannonical_method_name);
}

sub on_fail {
  ok(0, $_[1]->cannonical_method_name . "\n" . $_[1]->error);
}

sub on_error {
  ok(0, $_[1]->cannonical_method_name . "\n" . $_[1]->error->origin_exception);
}

1
