open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { 1+1/3*5 }" =
  "[(main, [], Operator (Plus, Const 1, Operator (Times, Operator (Divide, Const 1, Const 3), Const 5)))]"
  then printf "pass\n" else printf "fail\n"(* Operator *)
