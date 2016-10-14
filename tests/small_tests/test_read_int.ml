open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { readInt() }" =
  "[(main, [], Readint)]"
then printf "pass\n" else printf "fail\n" (* Readint *)
