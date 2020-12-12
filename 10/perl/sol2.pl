#!/usr/bin/env perl
use strict;

my %memo = (0 => 1, 1 => 1, 2 => 2, 3 => 4);
sub trib {
    my $i = $_[0];
    if ($memo{$i} != undef) {
        return $memo{$i};
    } else {
        my $result = trib($i-3) + trib($i-2) + trib($i-1);
        $memo{$i} = $result;
        return $result;
    };
};

my @inp = <>;
@inp = sort {$a <=> $b} @inp;

my $total = 1;
my $run_length = 0;
my $b = 0;

foreach $a (@inp) {
    if ($a - $b == 3) {
        $total *= trib($run_length);
        print $run_length, "\n";
        $run_length = 0;
    } else {
        $run_length += 1;
    }

    $b=$a;
}

$total *= trib($run_length);
print $run_length, "\n";
print "$total\n"
