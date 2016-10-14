open Tree_parse
open Printf

let test = if
parse_tree_of_string "main () { if (x == 5) {5} else {3} }" =
"[(main, [], If (Operator (Equal, Deref (Identifier \"x\"), Const 5), Const 5, Const 3))]"
then printf "pass\n" else printf "fail\n"
