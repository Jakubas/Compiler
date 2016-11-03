open Ast
open Printf

let add_mutable id value env store =
  let _ = Hashtbl.add store id value in
  let env2 = ("_"^id, 0)::env in
  env2

let rec fill_store ids values env store = match ids, values with
  | [],[]       -> env
  | id::xs,value::ys -> let env2 = add_mutable id value env store in (fill_store xs ys env2 store)
  | _           -> env

let lookup' id store = try Const (Hashtbl.find store id)
                       with Not_found -> Empty

let rec lookup id env store = match env with
  | [] -> Empty
  | (id2,value)::xs -> (match (String.get id2 0), (String.sub id2 1 ((String.length id2)-1)) with
    (* mutable variable *)
    | '_', id3 -> if id = id3 then lookup' id3 store else lookup id xs store
    (* nonmutable variable *)
    | _, _ -> if id = id2 then Const value else lookup id xs store
    )

let rec remove_from_env env id = match env with
  | [] -> []
  | (id2,value)::xs -> if id = id2 then xs else (id2,value) :: (remove_from_env xs id)

let isConst = function
  | Const _ -> true
  | _ -> false

let optim_int_operation op e1 e2 = match op, e1, e2 with
  | Plus,   Const i1, Const i2 -> Const (i1 + i2);
  | Minus,  Const i1, Const i2 -> Const (i1 - i2);
  | Divide, Const i1, Const i2 -> (try Const (i1 / i2)
                                   with Division_by_zero -> Operator(op, e1, e2))
  | Times,  Const i1, Const i2 -> Const (i1 * i2);
  | _ -> Operator(op, e1, e2)

let rec optim_exp env store = function
  | Operator (op, Const i1, Const i2) -> optim_int_operation op (Const i1) (Const i2)
  | If (Operator(op, e1, e2), e3, e4) ->
    let _ = Hashtbl.reset store in
    let v1 = optim_exp env store e1 in
    let v2 = optim_exp env store e2 in
    let v3 = optim_exp env store e3 in
    let v4 = optim_exp env store e4 in
    let v5 = optim_bool_operation env store op v1 v2 in
    if v5 = Const 1 then v3 else
    if v5 = Const 0 then v4 else If(Operator(op, v1, v2), v3, v4)
  | Let (x, Const i, e1) ->
    let env2 = (x,i)::env in
    let v1 = optim_exp env2 store e1 in
    Let(x, Const i, v1)
  | New (x, Const i, e1) ->
    let env2 = add_mutable x i env store in
    let v1 = optim_exp env2 store e1 in
    let _ = Hashtbl.remove store x in
    New(x, Const i, v1)
  | Deref (Identifier x) ->
    let v1 = lookup x env store in
    if v1 = Empty
      then Deref(Identifier x)
      else v1
  | Asg (Identifier x, Const i) ->
    if Hashtbl.mem store x
    then
      let _ = Hashtbl.add store x i in
      Asg(Identifier x, Const i)
    else
      Asg(Identifier x, Const i)
  | Seq (e1, e2) ->
    let v1 = optim_exp env store e1 in
    let v2 = optim_exp env store e2 in
    Seq(v1, v2)
  | While (e1, e2) ->
    let _ = Hashtbl.reset store in
    While (e1, e2)
  | If (e1, e2, e3) ->
    let _ = Hashtbl.reset store in
    let v1 = optim_exp env store e1 in
    let v2 = optim_exp env store e2 in
    let v3 = optim_exp env store e3 in
    If(v1, v2, v3)
  | Asg (e1, e2) ->
    let v1 = optim_exp env store e1 in
    let v2 = optim_exp env store e2 in
    let _ = Hashtbl.reset store in
    Asg(v1, v2)
  | Deref (e1) ->
    let v1 = optim_exp env store e1 in
    Deref(v1)
  | Operator (op,e1,e2) ->
    let v1 = optim_exp env store e1 in
    let v2 = optim_exp env store e2 in
    Operator(op, v1, v2)
  | Negate (op,e1) ->
    let v1 = optim_exp env store e1 in
    Negate(op, v1)
  | New (x, e1, e2) ->
    let v1 = optim_exp env store e1 in
    let env2 = remove_from_env env x in
    let env3 = remove_from_env env2 ("_"^x) in
    let v2 = optim_exp env3 store e2 in
    New(x, v1, v2)
  | Let (x, e1, e2) ->
    let v1 = optim_exp env store e1 in
    let env2 = remove_from_env env x in
    let env3 = remove_from_env env2 ("_"^x) in
    let v2 = optim_exp env3 store e2 in
    Let(x, v1, v2)
  | Application (e1, e2) ->
    let v1 = optim_exp env store e1 in
    let v2 = optim_exp env store e2 in
    Application(v1, v2)
  | Printint (e1) ->
    let v1 = optim_exp env store e1 in
    Printint(v1)
  | e -> e

and optim_bool_operation env store op e1 e2 = match op, e1, e2 with
  | Leq,   Const i1, Const i2  -> if (i1 <= i2) then Const 1 else Const 0
  | Geq,   Const i1, Const i2  -> if (i1 >= i2) then Const 1 else Const 0
  | Equal, Const i1, Const i2  -> if (i1 = i2)  then Const 1 else Const 0
  | Noteq, Const i1, Const i2  -> if (i1 <> i2) then Const 1 else Const 0
  | And, Operator(op1, e1, e2), Operator(op2, e3, e4) ->
    let v1 = optim_bool_operation env store op1 (optim_exp env store e1) (optim_exp env store e2) in
    let v2 = optim_bool_operation env store op2 (optim_exp env store e3) (optim_exp env store e4) in
    if v1 = (Const 1) && v2 = (Const 1)
      then Const 1
      else
        if isConst v1 && isConst v2
          then Const 0
          else Operator(And, Operator(op1, (optim_exp env store e1), (optim_exp env store e2)), Operator(op2, (optim_exp env store e3), (optim_exp env store e4)))
  | Or, Operator(op1, e1, e2), Operator(op2, e3, e4)  ->
    let v1 = optim_bool_operation env store op1 (optim_exp env store e1) (optim_exp env store e2) in
    let v2 = optim_bool_operation env store op2 (optim_exp env store e3) (optim_exp env store e4) in
    if v1 = (Const 1) || v2 = (Const 1)
      then Const 1
      else
        if isConst v1 && isConst v2
          then Const 0
          else Operator(Or, Operator(op1, (optim_exp env store e1), (optim_exp env store e2)), Operator(op2, (optim_exp env store e3), (optim_exp env store e4)))
  | op, e1, e2 -> Operator(op, e1, e2)

let rec unroll i max = function
  | While(e1, e2) ->
    if i < max then
      Seq(If(e1, e2, Empty), (unroll (i+1) max (While(e1,e2))))
    else
      While(e1, e2)
  | e -> e

let rec unroll_loops = function
  | Seq (e1, e2) -> Seq(unroll_loops e1, unroll_loops e2)
  | While (e1, e2) -> unroll 0 10 (While(e1, e2))
  | New (x, e1, e2) -> New(x, e1, unroll_loops e2)
  | Let (x, e1, e2) -> Let(x, e1, unroll_loops e2)
  | e -> e

let rec optim_func = function
  | (name, params, exp) ->
    let optimised = optim_exp [] (Hashtbl.create 10) exp in
    if exp <> optimised
      then optim_func (name, params, optimised)
      else (name, params, optimised)

let rec optim_prog = function
  | [] -> []
  | (name, params, exp)::xs -> (optim_func (name, params, unroll_loops exp)) :: (optim_prog xs)
