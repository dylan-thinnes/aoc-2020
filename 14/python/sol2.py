#!/usr/bin/env python3
import sys
import re

mem = {}

def apply_mask (v, mask):
    return v & mask[0] | mask[1]

def to_masks (s):
    masks = [(0xfffffffff, int(s.replace('X', '0'), 2))]
    indices = [len(s) - i - 1 for i, c in enumerate(s) if c == 'X']

    for i in indices:
        masks = [
            new
                for mask0, mask1 in masks
                for new in
                    [ (mask0 & ~(1 << i), mask1)
                    , (mask0, mask1 | (1 << i))
                    ]
        ]

    return masks

regex = r"(?P<head>mem|mask)(\[(?P<loc>\d+)\] = (?P<val>\d+)| = (?P<mask>[X10]+))"
for line in sys.stdin:
    match = re.search(regex, line)

    if match['head'] == 'mask':
        s = match['mask']
        curr_masks = to_masks(s)
    else:
        init_loc = int(match['loc'])
        val = int(match['val'])
        for curr_mask in curr_masks:
            loc = apply_mask(init_loc, curr_mask)
            mem[loc] = val

print(sum(mem.values()))
