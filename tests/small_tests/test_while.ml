open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { while (x >= 6) {x=x+1} }" =
  "[(main, [], While (Operator (Geq, Deref (Identifier \"x\"), Const 6), Asg (Identifier \"x\", Operator (Plus, Deref (Identifier \"x\"), Const 1))))]"
  then printf "pass\n" else printf "fail\n" (* While *)
