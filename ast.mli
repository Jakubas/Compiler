type opcode =
    Plus
  | Minus
  | Times
  | Divide
  | Leq
  | Geq
  | Equal
  | Noteq
  | And
  | Or
  | Not
type expression =
    Seq of expression * expression
  | While of expression * expression
  | If of expression * expression * expression
  | Asg of expression * expression
  | Deref of expression
  | Operator of opcode * expression * expression
  | Application of expression * expression
  | Const of int
  | Readint
  | Printint of expression
  | Identifier of string
  | Let of string * expression * expression
  | New of string * expression * expression
type fundef = string * string list * expression
type program = fundef list
val string_of_opcode : opcode -> string
val string_of_exp : expression -> string
val string_of_fundef : fundef -> string
val string_of_program2 : program -> string
val string_of_program : program -> string
