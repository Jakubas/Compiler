open Hashtbl
open Ast
exception Codegenx86Error of string

val codegenx86_prog : program -> unit
