open Hashtbl
open Ast
exception InterpretError of string

val interpret_prog : program -> int
