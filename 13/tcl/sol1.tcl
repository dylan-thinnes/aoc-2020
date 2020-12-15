#!/usr/bin/env tclsh
set target [gets stdin]
set raw [gets stdin]
set buses [split $raw ","]

set bestbus 0
set shortest [expr $target + 1]
foreach bus [lsearch -all -not -inline $buses {x}] {
    set wait [expr $bus - $target % $bus]
    if [expr $wait < $shortest] {
        puts "Bestbus change: $bestbus $shortest $bus $wait"
        set bestbus $bus
        set shortest $wait
    }
}

puts [expr $bestbus * $shortest]
