use Ok::MockIt qw(mock_it);

my $mock = mock_it([qw(meth1 meth2)]);

my $can  = $mock->can('meth1') ? 1 : 0;
print $can ? "Mock method is included" : "Desired methods are not included";