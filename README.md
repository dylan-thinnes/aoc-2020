My solutions to Advent of Code, 2020.

Ground rules:

1. Must do all days in different languages, except those days which continue
   from other days' solutions (e.g. IntCode computer, 2019)
2. If I do a day in multiple different languages, I can "pick" the language for
   that day, as long as the resulting picks adhere to rule 1.
3. If I wish to use a language that I have already used, I can go back and redo
   the day that language was done in, using a different language, thus freeing
   it up for the new day.
4. Languages cannot be too similar, keeping in spirit of the rules (e.g.
   bash/zsh, typescript/javascript, haskell/purescript [controversial, I know])
5. I may write preprocessors to transform the input into something palatable to
   the language (e.g. Day 3 for J)

Language summary, generated by the `summarize` script:

```
                          |1|1|1|1|1|1|1|1|1|1|
        |1|2|3|4|5|6|7|8|9|0|1|2|3|4|5|6|7|8|9|
awk     | | | |X| | | | | | | | | | | | | | | |
bash    | | | |X|X| | | | |X| | | | | | | | | |
c       | | | | |X| | | | | | | | | | | | | | |
dc      | | | | | | | | |X| | | | | | | | | | |
dhall   | | | | | | | | | | | |X| | | | | | | |
go      | | | | | |X| | | | | | | | | | | | | |
haskell |X|X|X| | | | |X| | | | | | | | | | |X|
j       |X| |X| | | | | | | | | | | | | | | | |
java    | | | | | | | | | | | | | | |X| | | | |
jq      |X| | | | | | | | | | | | | | | | | | |
julia   | | |X| | | | | | | | | | | | |X| | | |
mips    | |X| | | | | | | | | | | | | | | | | |
nix     | | | | | | | | | | | | | | | | | | |X|
octave  | | | | | | | | | | |X| | | | | | | | |
perl    | | | | | | | | | |X| | | | | | | | | |
python  | | | | | | | | | | | | | |X| | | | | |
r       | | | | | | | | | | | | | | | | |X| | |
ruby    | | | | | | |X| | | | | | | | | | | | |
rust    | | | |X| | | | | | | | | | | | | | | |
tcl     | | | | | | | | | | | | |X| | | | | | |
zig     | | | | | | | | | | | | | | | | | |X| |
```
