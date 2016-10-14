open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { int x = 2; x + 2 }" =
  "[(main, [], New (\"x\", Const 2, Operator (Plus, Deref (Identifier \"x\"), Const 2)))]"
then printf "pass\n" else printf "fail\n"
