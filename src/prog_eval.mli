open Ast
exception RuntimeError of string

  type value =
    | Int' of int
    | Id' of string
    | Bool' of bool
    | Nothing'
    
val store : (string, int) Hashtbl.t

type funrecord = {
  params : string list;
  exp : expression;
}

val func_store : (string, funrecord) Hashtbl.t

val eval_prog : program -> value

val string_of_value : value -> string
