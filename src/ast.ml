type opcode =
  | Plus | Minus | Times | Divide
  | Leq | Geq | Equal | Noteq
  | And | Or | Not

type expression =
  | Seq of expression * expression (* e; e *)
  | While of expression * expression (* while (e) {e} *)
  | If of expression * expression * expression (* if (e) {e} else {e} *)
  | Asg of expression * expression (* e = e *)
  | Deref of expression (* *e *)
  | Operator of opcode * expression * expression (* e + e *)
  | Negate of opcode * expression (* !e *)
  | Application of expression * expression (* e(e) *)
  | Const of int (* 7 *)
  | Readint (* readInt() *)
  | Printint of expression (* printInt (e) *)
  | Identifier of string (* x *)
  | Let of string * expression * expression (* int x = e; e *)
  | New of string * expression * expression (* final int x = e; e *)
  | Arg of expression * expression
  | Empty

type fundef = string * string list * expression
type program = fundef list

let string_of_opcode op = match op with
 | Plus -> "Plus"
 | Minus -> "Minus"
 | Times -> "Times"
 | Divide -> "Divide"
 | Leq -> "Leq"
 | Geq -> "Geq"
 | Equal -> "Equal"
 | Noteq -> "Noteq"
 | And -> "And"
 | Or -> "Or"
 | Not -> "Not"

let rec string_of_exp exp = match exp with
  | Seq(e,f) -> "Seq(" ^ string_of_exp  e ^ "," ^ string_of_exp  f ^ ")"
  | While (e,f) -> "While (" ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ")"
  | If (e,f,g) -> "If (" ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ", " ^ string_of_exp  g ^ ")"
  | Asg(e,f) -> "Asg (" ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ")"
  | Deref (e) -> "Deref (" ^ string_of_exp  e ^ ")"
  | Operator (o,e,f) -> "Operator (" ^ string_of_opcode o ^ ", " ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ")"
  | Negate (o,e) -> "Negate (" ^ string_of_exp  e ^ ")"
  | Application (e,f) -> "Application (" ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ")"
  | Const(i) -> "Const " ^ string_of_int i
  | Readint -> "Readint"
  | Printint(e) -> "Printint (" ^ string_of_exp  e ^ ")"
  | Identifier(x) -> "Identifier " ^ "\"" ^ x ^ "\""
  | Let(x,e,f) -> "Let (\"" ^ x ^ "\", " ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ")"
  | New(x,e,f) -> "New (\"" ^ x ^ "\", " ^ string_of_exp  e ^ ", " ^ string_of_exp  f ^ ")"
  | Arg(e,f) -> "Arg(" ^ string_of_exp  e ^ "," ^ string_of_exp  f ^ ")"
  | Empty -> "Empty"

let string_of_fundef fundef = match fundef with
  | (str, strlist, exp) -> str ^ ", [" ^ String.concat ", " strlist ^ "], " ^ string_of_exp exp

let rec string_of_program2 prog = match prog with
  | []    -> "]"
  | x::[] -> "(" ^ string_of_fundef x ^ ")]"
  | x::xs -> "(" ^ string_of_fundef x ^ ")," ^ string_of_program2 xs

(* Generates a parse tree from a prgroam*)
let string_of_program prog = "[" ^ string_of_program2 prog;;
