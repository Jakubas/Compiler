open Ast
exception RuntimeError of string

(*type exp_val =
  | Const of int
  | Identifier of Ast.expression;;*)

  type value =
    | Int' of int
    | Id' of string
    | Bool' of bool

val eval_prog : program -> value
