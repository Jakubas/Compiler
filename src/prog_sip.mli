open Hashtbl
open Ast
exception SipError of string

val interpret_prog : program -> int
