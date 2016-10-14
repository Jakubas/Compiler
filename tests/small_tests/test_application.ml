open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { x(6) }" =
  "[(main, [], Application (Identifier \"x\", Const 6))]"
  then printf "pass\n" else printf "fail\n";
