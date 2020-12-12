#!/usr/bin/jq -Mf
[.] | { a: .[], b: .[], c: .[] } | select(.a + .b + .c == 2020) | .a * .b * .c
