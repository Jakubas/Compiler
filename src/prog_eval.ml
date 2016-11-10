open Ast
open Printf
exception RuntimeError of string

type funrecord = {
  params : string list;
  exp : expression;
}

let func_store = Hashtbl.create 10

type value =
  | Int' of int
  | Id' of string
  | Bool' of bool
  | Nothing'

let string_of_value = function
  | Int' i  -> string_of_int i
  | Id' x   -> "'" ^ x ^ "'"
  | Bool' b -> if (b) then "true" else "false"
  | Nothing' -> "Nothing"

let value_to_int = function
  | Int' i -> i
  | Id' str -> raise (RuntimeError ("RuntimeError: expected value of type Int', actual value is Id' " ^ str))
  | Bool' b -> raise (RuntimeError ("RuntimeError: expected value of type Int', actual value is Bool' " ^ string_of_value (Bool' b)))
  | Nothing' -> raise (RuntimeError ("RuntimeError: expected value of type Int', actual value is Nothing'"))

let value_to_string = function
  | Int' i  -> raise (RuntimeError ("RuntimeError: expected value of type Id', actual value is Int' " ^ (string_of_int i)))
  | Id' str -> str
  | Bool' b -> raise (RuntimeError ("RuntimeError: expected value of type Id', actual value is Bool' " ^ string_of_value (Bool' b)))
  | Nothing' -> raise (RuntimeError ("RuntimeError: expected value of type Int', actual value is Nothing'"))

let value_to_bool = function
  | Int' i  -> raise (RuntimeError ("RuntimeError: expected value of type Id', actual value is Int' " ^ (string_of_int i)))
  | Id' str -> raise (RuntimeError ("RuntimeError: expected value of type Bool', actual value is Id' " ^ str))
  | Bool' b -> b
  | Nothing' -> raise (RuntimeError ("RuntimeError: expected value of type Int', actual value is Nothing'"))

let lookupStore id store = try Int' (Hashtbl.find store id)
                       with Not_found -> raise (RuntimeError ("RuntimeError: '" ^ id ^ "' has no value assigned to it"))

let rec lookup id env = match env with
  | [] -> Id' id(*raise (RuntimeError ("RuntimeError: constant '" ^ id ^ "' has no value assigned to it"))*)
  | (id2,value)::xs -> if id = id2 then Int' value else lookup id xs

let add_mutable id value store =
  let _ = Hashtbl.add store id value in store (*in
  let env2 = (id, 0)::env in
  env2*)

let rec fill_store ids values store = match ids, values with
  | [],[]       -> store
  | id::xs,value::ys -> let _ = add_mutable id value store in fill_store xs ys store
  | _           -> raise (RuntimeError "RuntimeError: argument/values length mismatch for a function application")

let rec eval_exp env store = function
  | Const i -> Int' i
  | Seq (e1,e2) ->
    let _ = eval_exp env store e1 in
    let v2 = eval_exp env store e2 in v2
  | While (e1,e2) ->
    if (eval_exp env store e1 = Bool' true)
      then let _ = eval_exp env store e2 in eval_exp env store (While(e1, e2))
      else eval_exp env store e1
  | If (e1,e2,e3) ->
    if (value_to_bool(eval_exp env store e1))
      then eval_exp env store e2
      else eval_exp env store e3
  | Asg (e1,e2) ->
    (* x has to be a value of Id' and v a value of Int' *)
    let x = value_to_string(eval_exp env store e1) in
    let v2 = eval_exp env store e2 in
    let i = value_to_int(v2) in
    if Hashtbl.mem store x
      then let _ = Hashtbl.add store x i in v2
      else (raise (RuntimeError ("RuntimeError: variable '" ^ x ^ "' is not defined")))
  | Deref (Identifier x) -> lookupStore x store;
  | Deref (e1) ->
    let v1 = eval_exp env store e1 in
    let x = value_to_string v1 in
    lookupStore x store;
  | Operator (op,e1,e2) -> eval_opcode op env store e1 e2
  | Negate (op,e1) -> (match op with
    | Not ->
      let v1 = eval_exp env store e1 in
      let b1 = value_to_bool v1 in
      if (b1) then Bool' false else Bool' true
    | _ -> raise (RuntimeError ("RuntimeError: '" ^ string_of_opcode op ^ "' is not a unary operator")))
  | New (x, e1, e2) ->
    let v1 = eval_exp env store e1 in
    let i = value_to_int(v1) in
    let _ = add_mutable x i store in
    let v2 = eval_exp env store e2 in
    Hashtbl.remove store x; v2
  | Let (x, e1, e2) ->
    let v1 = value_to_int(eval_exp env store e1) in
    eval_exp ((x,v1)::env) store e2
  | Application (e1, e2) ->
    let x = value_to_string(eval_exp env store e1) in
    let args = eval_args env store e2 in
    let funrecord1 =
      (try Hashtbl.find func_store x
      with Not_found -> raise (RuntimeError ("RuntimeError: function \"" ^ x ^ "\" not defined")))
    in eval_fun (x, funrecord1.params, funrecord1.exp) args
  | Identifier x -> lookup x env;
  | Arg _ -> raise (RuntimeError ("RuntimeError: unexpected comma, commas can only be used for function arguments/parameters"))
  | Empty -> Nothing'
  | Readint ->
    (try print_string "Please enter a number: "; let i = read_int() in Int' i
    with int_of_string -> raise (RuntimeError ("RuntimeError: input is not a valid int")))
  | Printint (e1) ->
    let v1 = value_to_int(eval_exp env store e1) in
    print_string ((string_of_int v1) ^ "\n"); Nothing'

and eval_opcode op env store e1 e2 = match op with
  | Plus   -> Int' (value_to_int (eval_exp env store e1) + value_to_int (eval_exp env store e2))
  | Minus  -> Int' (value_to_int (eval_exp env store e1) - value_to_int (eval_exp env store e2))
  | Divide -> (try Int' (value_to_int (eval_exp env store e1) / value_to_int (eval_exp env store e2))
              with Division_by_zero -> raise (RuntimeError ("RuntimeError: division by zero")))
  | Times  -> Int' (value_to_int (eval_exp env store e1) * value_to_int (eval_exp env store e2))
  | Leq    -> if value_to_int (eval_exp env store e1) <= value_to_int (eval_exp env store e2)
              then Bool' true else Bool' false
  | Geq    -> if value_to_int (eval_exp env store e1) >= value_to_int (eval_exp env store e2)
              then Bool' true else Bool' false
  | Equal  -> Bool' (value_to_int (eval_exp env store e1) = value_to_int (eval_exp env store e2))
  | Noteq  -> if value_to_int (eval_exp env store e1) <> value_to_int (eval_exp env store e2)
              then Bool' true else Bool' false
  | And    -> if (value_to_bool (eval_exp env store e1) && value_to_bool (eval_exp env store e2))
              then Bool' true else Bool' false
  | Or     -> if (value_to_bool (eval_exp env store e1) || value_to_bool (eval_exp env store e2))
              then Bool' true else Bool' false
  | _ -> raise (RuntimeError ("RuntimeError: '" ^ string_of_opcode op ^ "' is not a binary operator"))

and eval_args env store = function
  | Empty -> []
  | Arg(e1, e2) -> value_to_int(eval_exp env store e1) :: eval_args env store e2
  | e -> value_to_int(eval_exp env store e) :: []

and eval_fun fundef args = match fundef with
  | (main,[],exp) -> eval_exp [] (Hashtbl.create 10) exp
  | ("main",params,exp) -> raise (RuntimeError "RuntimeError: function main takes no arguments")
  | (name,params,exp) -> let store = Hashtbl.create 10 in
    let _ = fill_store params args store in
    eval_exp [] store exp

let rec eval_prog = function
  | [] -> let entry_point =
            (try Hashtbl.find func_store "main"
            with Not_found -> raise (RuntimeError ("RuntimeError: function \"main\" not defined")))
          in let v1 = eval_fun("main", entry_point.params, entry_point.exp) []
          in let _ = Hashtbl.reset func_store
          in v1;
  | (name,params,exp)::xs -> let _ = Hashtbl.add func_store name {params; exp} in eval_prog xs
