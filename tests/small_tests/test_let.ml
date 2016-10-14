open Tree_parse
open Printf

let test = if
parse_tree_of_string "main () { final int x = 5; 5 + x }" =
"[(main, [], Let (\"x\", Const 5, Operator (Plus, Const 5, Deref (Identifier \"x\"))))]"
then printf "pass\n" else printf "fail\n";
