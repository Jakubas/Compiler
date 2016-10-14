open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { x=5 }" =
  "[(main, [], Asg (Identifier \"x\", Const 5))]"
  then printf "pass\n" else printf "fail\n"
