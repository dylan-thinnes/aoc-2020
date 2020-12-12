#!/usr/bin/env perl
@inp = <>;
@inp = sort {$a <=> $b} @inp;

%x = (1 => 0, 3 => 1);
$b=0;
foreach $a (@inp) {
    $x{$a-$b} += 1;
    $b=$a;
};

print $x{1} * $x{3};
