open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { printInt(6+6) }" =
  "[(main, [], Printint (Operator (Plus, Const 6, Const 6)))]"
then printf "pass\n" else printf "fail\n" (* Printint *)
