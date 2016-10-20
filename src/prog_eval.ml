open Ast
exception RuntimeError of string

let store = Hashtbl.create 10;;

type value =
  | Int' of int
  | Id' of string
  | Bool' of bool

let value_to_int = function
  | Int' i -> i
  | _      -> raise (RuntimeError "RuntimeError: value/type mismatch")

let value_to_string = function
  | Id' str -> str
  | _      -> raise (RuntimeError "RuntimeError: value/type mismatch")

let value_to_bool = function
  | Bool' b -> b
  | _      -> raise (RuntimeError "RuntimeError: value/type mismatch")

let rec eval_exp = function
  | Const i -> Int' i
  | Seq (e1,e2) ->
    let _ = eval_exp e1 in
    let v2 = eval_exp e2 in v2
  | While (e1,e2) ->
    if (eval_exp e1 = Bool' true)
      then let _ = eval_exp e2 in eval_exp (While(e1, e2))
      else eval_exp e1
  | If (e1,e2,e3) ->
    if (value_to_bool(eval_exp e1))
      then eval_exp e2
      else eval_exp e3
  | Asg (e1,e2) ->
    (* x has to be a value of Id' and v a value of Int' *)
    let x = value_to_string(eval_exp e1) in
    let v2 = eval_exp e2 in
    let i = value_to_int(v2) in
    Hashtbl.add store x i; v2
  | Deref (e1) ->
    let v1 = eval_exp e1 in
    let x = value_to_string v1 in
    (try Int' (Hashtbl.find store x)
    with Not_found -> raise (RuntimeError ("RuntimeError: '" ^ x ^ "' has no value assigned to it")))
  | Operator (op,e1,e2) -> eval_opcode op e1 e2
  | Negate (op,e1) -> (match op with
    | Not ->
      let v1 = eval_exp e1 in
      let b1 = value_to_bool v1 in
      if (b1) then Bool' false else Bool' true
    | _ -> raise (RuntimeError ("RuntimeError: '" ^ string_of_opcode op ^ "' is not a unary operator")))
  | Identifier x -> Id' x
  | e -> raise (RuntimeError ("RuntimeError: evaluating: '" ^ string_of_exp e ^ "' is not implemented"))

and eval_opcode op e1 e2 = match op with
  | Plus   -> Int' (value_to_int (eval_exp e1) + value_to_int (eval_exp e2))
  | Minus  -> Int' (value_to_int (eval_exp e1) - value_to_int (eval_exp e2))
  | Divide -> (try Int' (value_to_int (eval_exp e1) / value_to_int (eval_exp e2))
              with Division_by_zero -> raise (RuntimeError ("RuntimeError: division by zero")))
  | Leq    -> if value_to_int (eval_exp e1) <= value_to_int (eval_exp e2)
              then Bool' true else Bool' false
  | Geq    -> if value_to_int (eval_exp e1) >= value_to_int (eval_exp e2)
              then Bool' true else Bool' false
              | Times  -> Int' (value_to_int (eval_exp e1) * value_to_int (eval_exp e2))
  | Equal  -> if value_to_int (eval_exp e1) = value_to_int (eval_exp e2)
              then Bool' true else Bool' false
  | Noteq  -> if value_to_int (eval_exp e1) <> value_to_int (eval_exp e2)
              then Bool' true else Bool' false
  | And    -> if (value_to_bool (eval_exp e1) && value_to_bool (eval_exp e2))
              then Bool' true else Bool' false
  | Or     -> if (value_to_bool (eval_exp e1) || value_to_bool (eval_exp e2))
              then Bool' true else Bool' false
  | _ -> raise (RuntimeError ("RuntimeError: '" ^ string_of_opcode op ^ "' is not a binary operator"))

let eval_fun = function
  | (name,_, exp) -> eval_exp exp

let rec eval_prog = function
  | [] -> raise (RuntimeError "RuntimeError: no main function defined")
  | ("main",_, exp) as x::xs -> eval_fun x
  | x::xs -> eval_prog xs
