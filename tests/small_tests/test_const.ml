open Tree_parse
open Printf

let test = if
parse_tree_of_string "main () { 5 }" =
"[(main, [], Const 5)]"
then printf "pass\n" else printf "fail\n"
