#!/usr/bin/jq -Mf
[.] | { a: .[], b: .[] } | select(.a + .b == 2020) | .a * .b
