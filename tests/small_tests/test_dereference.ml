open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { x=x+3; return x }" =
  "[(main, [], Seq(Asg (Identifier \"x\", Operator (Plus, Deref (Identifier \"x\"), Const 3)),Deref (Identifier \"x\")))]"
  then printf "pass\n" else printf "fail\n"
