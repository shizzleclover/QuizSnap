 
use strict;
use warnings;

 

 
sub factorial {
    my ($n) = @_;
    return 1 if $n < 2;
    return $n * factorial($n - 1);
}

my $result = factorial(5);
print "5! = $result\n";
