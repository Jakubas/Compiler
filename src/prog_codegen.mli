open Hashtbl
open Ast
exception CodegenError of string

val codegen_prog : program -> unit
