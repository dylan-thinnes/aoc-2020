#!/usr/bin/env tclsh
proc euclid {a b} {
    set div [expr $a / $b]
    set mod [expr $a % $b]

    if {$mod == 0} {
        return [list 0 1]
    } else {
        set res [euclid $b $mod]
        set par [lindex $res 0]
        set sel [lindex $res 1]

        return [list [expr $sel] [expr $sel * -1 * $div + $par]]
    }
}

gets stdin ;# Discard first line
set raw [gets stdin]
set xbuses [split $raw ","]

set buses {}
set offsets {}
set prod 1

set i -1
foreach xbus $xbuses {
    incr i
    if [string equal x $xbus] {[continue]}
    lappend buses $xbus
    lappend offsets [expr ($xbus - $i) % $xbus]
    set prod [expr $prod * $xbus]
}

#set buses [list 27 20]
#set offsets [list 15 16]
#set prod [expr 27 * 20]

puts $buses
puts $offsets
puts $prod

set total 0
lmap bus $buses offset $offsets {
    set ab [euclid $bus [expr $prod / $bus]]

    set res [expr $offset * [lindex $ab 1] * $prod / $bus]
    puts [list $offset * [lindex $ab 1] * $prod / $bus = $res]
    set total [expr $total + $res]
}

puts [expr $total % $prod]
