open Tree_parse
open Printf

let test = if
  parse_tree_of_string "main (a;b;c) { a*b-c }" =
  "[(main, [a, b, c], Operator (Minus, Operator (Times, Deref (Identifier \"a\"), Deref (Identifier \"b\")), Deref (Identifier \"c\")))]"
  && parse_tree_of_string "main (a;b) { a = a+1 } main2 (c) { -5--6 }" =
  "[(main, [a, b], Asg (Identifier \"a\", Operator (Plus, Deref (Identifier \"a\"), Const 1))),(main2, [c], Operator (Minus, Const -5, Const -6))]"
  then printf "pass\n" else printf "fail\n" (* Two functions *)
