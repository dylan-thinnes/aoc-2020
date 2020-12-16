#!/usr/bin/env python3
import sys
import re

mem = {}

mask = (0xfffffffff, 0)

regex = r"(?P<head>mem|mask)(\[(?P<loc>\d+)\] = (?P<val>\d+)| = (?P<mask>[X10]+))"
for line in sys.stdin:
    match = re.search(regex, line)

    if match['head'] == 'mask':
        s = match['mask']
        mask = (int(s.replace('X', '1'), 2), int(s.replace('X', '0'), 2))
    else:
        loc = match['loc']
        val = int(match['val']) & mask[0] | mask[1]
        mem[loc] = val

print(sum(mem.values()))
