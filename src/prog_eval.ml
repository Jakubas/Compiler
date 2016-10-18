open Ast

let store = Hashtbl.create 10;;

(*type exp_val =
  | Const of int
  | Identifier of Ast.expression;;*)

(* gets the identifier from an expression *)
let rec eval_id_exp = function
  | Identifier x -> x
  | Seq (e1,e2) ->
    let _ = eval_exp e1 in
    let id = eval_id_exp e2 in id
  | While (e1,e2) ->
    if (eval_exp e1 = 1)
      then let _ = eval_exp e2 in eval_id_exp (While(e1, e2))
      else eval_id_exp e1
  | If (e1,e2,e3) ->
    if (eval_exp e1 = 1)
      then eval_id_exp e2
      else eval_id_exp e3
  | Asg (e1,e2) ->
    let x = eval_id_exp e1 in
    let v = eval_exp e2 in
    Hashtbl.add store x v; x
  | Const i -> failwith ("Illegal Assignment: Can't assign value to an int (int " ^ string_of_int i ^ ")")
  | e -> failwith (string_of_exp e ^ " is not implemented in eval_id_exp")

and eval_exp = function
  | Const i -> i
  | Seq (e1,e2) ->
    let _ = eval_exp e1 in
    let v = eval_exp e2 in v
  | While (e1,e2) ->
    if (eval_exp e1 = 1)
      then let _ = eval_exp e2 in eval_exp (While(e1, e2))
      else eval_exp e1
  | If (e1,e2,e3) ->
    if (eval_exp e1 = 1)
      then eval_exp e2
      else eval_exp e3
  | Asg (e1,e2) ->
    let x = eval_id_exp e1 in
    let v = eval_exp e2 in
    Hashtbl.add store x v; v
  | Deref (e1) -> let x = eval_id_exp e1 in Hashtbl.find store x
  | Operator (o,e1,e2) -> eval_opcode o e1 e2
  | Negate (o,e1) -> (match o with
    | Not ->
      let v1 = eval_exp e1 in
      if v1 = 1 then 0 else
      if v1 = 0 then 1 else v1
    | _ -> failwith (string_of_opcode o ^ " is not a unary opcode"))
  (*| Identifier x -> Identifier x*)
  | e -> failwith (string_of_exp e ^ " is not implemented in eval_exp")

and eval_opcode opcode e1 e2 = match opcode with
  | Plus   -> eval_exp e1 + eval_exp e2
  | Minus  -> eval_exp e1 - eval_exp e2
  | Times  -> eval_exp e1 * eval_exp e2
  | Divide -> eval_exp e1 / eval_exp e2
  | Leq    -> if (eval_exp e1) <= (eval_exp e2) then 1 else 0
  | Geq    -> if (eval_exp e1) >= (eval_exp e2) then 1 else 0
  | Equal  -> if (eval_exp e1) = (eval_exp e2) then 1 else 0
  | Noteq  -> if (eval_exp e1) <> (eval_exp e2) then 1 else 0
  | And    -> if ((eval_exp e1) = 1 && (eval_exp e2) = 1) then 1 else 0
  | Or     -> if ((eval_exp e1) = 1 || (eval_exp e2) = 1) then 1 else 0
  | Not    -> failwith "Not is not a binary operator"

let eval_fun = function
  | (name, [], exp) -> eval_exp exp
  | (name, x::xs, exp) -> eval_exp exp

let rec eval_prog = function
  | [] -> failwith "no functions defined"
  | x::[] -> eval_fun x
  | x::xs -> eval_fun x + eval_prog xs
