{ input }:

with (import <nixpkgs> {}).lib;
with builtins;

let
  # Utilities
  split = regex: str: filter isString (builtins.split regex str);

  # Parsers
  parseRule = line:
    let firstSplit = split ": " line;
        id = strings.toInt (elemAt firstSplit 0);
        secondSplits = split " \\| " (elemAt firstSplit 1);
        matches = map parseMatch secondSplits;
    in
    { inherit id matches; };

  parseMatch = str:
    let firstChar = head (stringToCharacters str);
        type = if firstChar == "\"" then "base" else "rec";
        value =
          if type == "base"
          then substring 1 (stringLength str - 2) str
          else map strings.toInt (split " " str);
    in
    { inherit type value; };

  # Inputs
  lines = split "\n" input;
  empty-line-index =
    let f = n:
            if stringLength (elemAt lines n) == 0
            then n
            else f (n + 1);
    in
    f 0;

  rules = sort (a: b: a.id < b.id) (map parseRule (take empty-line-index lines));
  inputs = drop (empty-line-index + 1) lines;

  # Check rules
  bind = x: g: concatMap g x;
  passes-rule-0 = inp: any (res: stringLength res == 0) (check-rule 0 inp);
  check-rule = index: rem:
    let rule = elemAt rules index;
    in
    bind rule.matches (match:
      if match.type == "base"
      then
        if strings.hasPrefix match.value rem
        then [(substring (stringLength match.value) (stringLength rem) rem)]
        else []
      else
        let f =
          prevRemainders: id:
            bind prevRemainders (check-rule id);
        in
        lists.foldl f [rem] match.value
      );
in

{
  inherit lines rules inputs;
  result = length (filter passes-rule-0 inputs);
}
