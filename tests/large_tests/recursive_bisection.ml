
open Tree_parse
open Printf

let test = if
  parse_tree_of_string "
  bisect (f; a; b; tol) {
    int c = 0;
    int root = 0;
    if (b-a >= tol) {
      c = a+b;
      c = c/2;
      if (f(c) == 0) {
        root = c
      } else {
        if (f(c) <= -1 & f(a) <= -1 | f(c) >= 1 & f(a) >= 1) {
          a = c
        } else {
          b = c
        };
        root = bisect(f;a;b;tol)
      }
    } else {
      root = c
    }
  }
  " =
  "[(bisect, [f, a, b, tol], New (\"c\", Const 0, If (Operator (Geq, Operator (Minus, Deref (Identifier \"b\"), Deref (Identifier \"a\")), Deref (Identifier \"tol\")), Seq(Asg (Identifier \"c\", Operator (Plus, Deref (Identifier \"a\"), Deref (Identifier \"b\"))),Seq(Asg (Identifier \"c\", Operator (Divide, Deref (Identifier \"c\"), Const 2)),If (Operator (Equal, Application (Identifier \"f\", Deref (Identifier \"c\")), Const 0), Deref (Identifier \"c\"), Seq(If (Operator (Or, Operator (And, Operator (Leq, Application (Identifier \"f\", Deref (Identifier \"c\")), Const -1), Operator (Leq, Application (Identifier \"f\", Deref (Identifier \"a\")), Const -1)), Operator (And, Operator (Geq, Application (Identifier \"f\", Deref (Identifier \"c\")), Const 1), Operator (Geq, Application (Identifier \"f\", Deref (Identifier \"a\")), Const 1))), Asg (Identifier \"a\", Deref (Identifier \"c\")), Asg (Identifier \"b\", Deref (Identifier \"c\"))),Application (Identifier \"bisect\", Seq(Deref (Identifier \"f\"),Seq(Deref (Identifier \"a\"),Seq(Deref (Identifier \"b\"),Deref (Identifier \"tol\"))))))))), Deref (Identifier \"c\"))))]"
  then printf "recursive bisection: pass\n" else printf "recursive bisection: fail\n";
