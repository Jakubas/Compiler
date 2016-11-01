open Ast
exception RuntimeError of string

  type value =
    | Int' of int
    | Id' of string
    | Bool' of bool
    | Nothing'

type funrecord = {
  params : string list;
  exp : expression;
}

val eval_prog : program -> value

val string_of_value : value -> string
