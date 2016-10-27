open Ast
exception RuntimeError of string

let store = Hashtbl.create 10

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

let rec lookup x env = match env with
  | [] -> (try Int' (Hashtbl.find store x)
          with Not_found -> raise (RuntimeError ("RuntimeError: '" ^ x ^ "' has no value assigned to it")))
  | (y,z)::ys -> if y = x then Int' z else lookup x ys

let rec create_env ids args = match ids,args with
  | [],[]       -> []
  | x::xs,y::ys -> (x,y) :: create_env xs ys
  | _           -> raise (RuntimeError "RuntimeError: argument/values length mismatch for a function application")

let rec eval_exp env = function
  | Const i -> Int' i
  | Seq (e1,e2) ->
    let _ = eval_exp env e1 in
    let v2 = eval_exp env e2 in v2
  | While (e1,e2) ->
    if (eval_exp env e1 = Bool' true)
      then let _ = eval_exp env e2 in eval_exp env (While(e1, e2))
      else eval_exp env e1
  | If (e1,e2,e3) ->
    if (value_to_bool(eval_exp env e1))
      then eval_exp env e2
      else eval_exp env e3
  | Asg (e1,e2) ->
    (* x has to be a value of Id' and v a value of Int' *)
    let x = value_to_string(eval_exp env e1) in
    let v2 = eval_exp env e2 in
    let i = value_to_int(v2) in
    Hashtbl.add store x i; v2
  | Deref (e1) ->
    let v1 = eval_exp env e1 in
    let x = value_to_string v1 in
    lookup x env;
  | Operator (op,e1,e2) -> eval_opcode op env e1 e2
  | Negate (op,e1) -> (match op with
    | Not ->
      let v1 = eval_exp env e1 in
      let b1 = value_to_bool v1 in
      if (b1) then Bool' false else Bool' true
    | _ -> raise (RuntimeError ("RuntimeError: '" ^ string_of_opcode op ^ "' is not a unary operator")))
  | New (x, e1, e2) ->
    let v1 = eval_exp env e1 in
    let i = value_to_int(v1) in
    let _ = Hashtbl.add store x i in
    eval_exp env e2;
  | Let (x, e1, e2) ->
    let v1 = value_to_int(eval_exp env e1) in
    eval_exp ((x,v1)::env) e2
  | Application (e1, e2) ->
    let x = value_to_string(eval_exp env e1) in
    let args = eval_args env e2 in
    let funrecord1 =
      (try Hashtbl.find func_store x
      with Not_found -> raise (RuntimeError ("RuntimeError: function \"" ^ x ^ "\" not defined")))
    in eval_fun (x, funrecord1.params, funrecord1.exp) args
  | Identifier x -> Id' x
  | Empty -> Nothing'
  | Readint ->
    (try print_string "Please enter a number: "; let i = read_int() in Int' i
    with int_of_string -> raise (RuntimeError ("RuntimeError: input is not a valid int")))
  | Printint (e1) ->
    let v1 = value_to_int(eval_exp env e1) in
    print_string ((string_of_int v1) ^ "\n"); Nothing'
  | e -> raise (RuntimeError ("RuntimeError: evaluating: '" ^ string_of_exp e ^ "' is not implemented"))

and eval_opcode op env e1 e2 = match op with
  | Plus   -> Int' (value_to_int (eval_exp env e1) + value_to_int (eval_exp env e2))
  | Minus  -> Int' (value_to_int (eval_exp env e1) - value_to_int (eval_exp env e2))
  | Divide -> (try Int' (value_to_int (eval_exp env e1) / value_to_int (eval_exp env e2))
              with Division_by_zero -> raise (RuntimeError ("RuntimeError: division by zero")))
  | Leq    -> if value_to_int (eval_exp env e1) <= value_to_int (eval_exp env e2)
              then Bool' true else Bool' false
  | Geq    -> if value_to_int (eval_exp env e1) >= value_to_int (eval_exp env e2)
              then Bool' true else Bool' false
              | Times  -> Int' (value_to_int (eval_exp env e1) * value_to_int (eval_exp env e2))
  | Equal  -> Bool' (value_to_int (eval_exp env e1) = value_to_int (eval_exp env e2))
    | Noteq  -> if value_to_int (eval_exp env e1) <> value_to_int (eval_exp env e2)
              then Bool' true else Bool' false
  | And    -> if (value_to_bool (eval_exp env e1) && value_to_bool (eval_exp env e2))
              then Bool' true else Bool' false
  | Or     -> if (value_to_bool (eval_exp env e1) || value_to_bool (eval_exp env e2))
              then Bool' true else Bool' false
  | _ -> raise (RuntimeError ("RuntimeError: '" ^ string_of_opcode op ^ "' is not a binary operator"))

and eval_args env = function
  | Empty -> []
  | Seq(e1, e2) -> value_to_int(eval_exp env e1) :: eval_args env e2
  | e -> value_to_int(eval_exp env e) :: []

and eval_fun fundef args = match fundef with
  | (main,[],exp) -> eval_exp [] exp
  | ("main",params,exp) -> raise (RuntimeError "RuntimeError: function main takes no arguments")
  | (name,params,exp) -> eval_exp (create_env params args) exp

let rec eval_prog = function
  | [] -> let entry_point =
            (try Hashtbl.find func_store "main"
            with Not_found -> raise (RuntimeError ("RuntimeError: function \"main\" not defined")))
          in eval_fun("main", entry_point.params, entry_point.exp) []
  | (name,params,exp)::xs -> let _ = Hashtbl.add func_store name {params; exp} in eval_prog xs
