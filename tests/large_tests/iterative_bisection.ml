open Tree_parse
open Printf

let test = if
  parse_tree_of_string "
  bisect (f; a; b; tol) {
    int c = 0;
    int root = 0;
    while (b-a >= tol) {
      c = a+b;
      if (f(c) == 0) {
      	c = c/2;
      	root = c
      } else {
        if (f(c) <= -1 & f(a) <= -1 | f(c) >= 0 & f(a) >= 0) {
          a = c
        } else {
          b = c
        }
      }
    };
    root = c
  }
  " =
  "[(bisect, [f, a, b, tol], New (\"c\", Const 0, Seq(While (Operator (Geq, Operator (Minus, Deref (Identifier \"b\"), Deref (Identifier \"a\")), Deref (Identifier \"tol\")), Seq(Asg (Identifier \"c\", Operator (Plus, Deref (Identifier \"a\"), Deref (Identifier \"b\"))),If (Operator (Equal, Application (Identifier \"f\", Deref (Identifier \"c\")), Const 0), Seq(Asg (Identifier \"c\", Operator (Divide, Deref (Identifier \"c\"), Const 2)),Deref (Identifier \"c\")), If (Operator (Or, Operator (And, Operator (Leq, Application (Identifier \"f\", Deref (Identifier \"c\")), Const -1), Operator (Leq, Application (Identifier \"f\", Deref (Identifier \"a\")), Const -1)), Operator (And, Operator (Geq, Application (Identifier \"f\", Deref (Identifier \"c\")), Const 0), Operator (Geq, Application (Identifier \"f\", Deref (Identifier \"a\")), Const 0))), Asg (Identifier \"a\", Deref (Identifier \"c\")), Asg (Identifier \"b\", Deref (Identifier \"c\")))))),Deref (Identifier \"c\"))))]"
  then printf "iterative bisection: pass\n" else printf "iterative bisection: fail\n";
