open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main () { a;b }" =
  "[(main, [], Seq(Deref (Identifier \"a\"),Deref (Identifier \"b\")))]"
  then printf "pass\n" else printf "fail\n"
