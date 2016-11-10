(* Configuration *)
open Hashtbl
open Ast
exception CodegenError of string

(* Configuration *)
let ram = Hashtbl.create 100
let acc = ref 0
let addr_base = ref 0

(* get operation instruction *)
let string_of_op = function
    | Plus -> "add"
    | Minus -> "sub"
    | Times -> "mul"
    | Divide -> "div"
    | _ -> raise (CodegenError ("SipError: not implemented"))

(* Instruction Set *)
let code = Buffer.create 100
let codegen_op (op, addr1, addr2) =
    (string_of_op op)
    ^ " r" ^ (string_of_int addr1)
    ^ ", r" ^ (string_of_int addr2)
    ^ "\n" |> Buffer.add_string code
let codegen_st addr =
    "st  r" ^ (string_of_int addr)
    ^ "\n" |> Buffer.add_string code
    (*replace ram addr !a*)
let codegen_ldc n =
    "ld  " ^ (string_of_int n)
    ^ "\n" |> Buffer.add_string code
    (*acc := n*)
let codegen_mv addr1 addr2 =
    "mv "
    ^ " r" ^ (string_of_int addr1)
    ^ ", r" ^ (string_of_int addr2)
    ^ "\n" |> Buffer.add_string code
    (*let v1 = find ram addr1 in
    replace ram addr2 v1*)

(* Symbol Table Functions *)
let insert symbol addr symt = ((symbol, addr) :: symt)
let rec lookup symbol symt = match symt with
  | [] -> raise (CodegenError ("SipError: immutable symbol '" ^ symbol ^ "' has no value assigned to it"))
  | (symbol2,addr)::xs -> if symbol = symbol2 then (*let _ = print_string("immutable:" ^ (string_of_int(find ram addr)) ^ "\n") in*) addr else lookup symbol xs
let insert_mutable symbol addr symt = (("_"^symbol, addr) :: symt)
let rec lookup_mutable symbol symt = match symt with
| [] -> raise (CodegenError ("SipError: mutable symbol '" ^ symbol ^ "' has no value assigned to it"))
| (symbol2,addr)::xs -> if ("_"^symbol) = symbol2 then (*let _ = print_string("Mutable:" ^ (string_of_int(find ram addr)) ^ "\n") in*) addr else lookup_mutable symbol xs

let new_addr = let i = addr_base in (fun () -> incr i; !i)

let rec codegen symt = function
    | Seq (e1, e2) ->
        let addr1 = codegen symt e1 in
        let addr2 = codegen symt e2 in
        addr_base := addr1;
        codegen_st addr1;
        addr1
    | Operator (oper, e1, e2) ->
        let addr1 = codegen symt e1 in
        let addr2 = codegen symt e2 in
        codegen_op (oper, addr1, addr2);
        addr_base := addr1;
        codegen_st addr1;
        addr1
    | Const n ->
        let addr = new_addr() in
        codegen_ldc n;
        codegen_st addr;
        addr
    | Identifier x ->
        let addr = lookup x symt in
        let addr' = new_addr() in
        codegen_mv addr addr';
        addr'
    | Let (x, e1, e2) ->
        let addr1 = codegen symt e1 in
        let symt' = insert x addr1 symt in
        let addr2 = codegen symt' e2 in
        codegen_mv addr2 addr1;
        addr_base := addr1;
        addr1
    | New (x, e1, e2) ->
        let addr1 = codegen symt e1 in
        let symt' = insert_mutable x addr1 symt in
        let addr2 = codegen symt' e2 in
        codegen_mv addr2 addr1;
        addr_base := addr1;
        addr1
    | Deref (Identifier x) ->
        let addr = lookup_mutable x symt in
        let addr' = new_addr() in
        codegen_mv addr addr';
        addr'
    | Asg (Identifier x, e2) ->
        let addr1 = lookup_mutable x symt in
        let addr2 = codegen symt e2 in
        codegen_mv addr2 addr1;
        (*addr_base := addr1;*)
        addr1
    | _ -> raise (CodegenError "not implemented")

let rec codegen_prog = function
    | [] -> raise (CodegenError ("no main function defined"))
    | (name, _, exp)::xs ->
        if name = "main" then
            let _ = Buffer.reset code in
            (*let _ = Hashtbl.reset ram in*)
            let _ = addr_base := 0 in
            let addr = codegen [] exp in
            Buffer.output_buffer stdout code;
            "ld  r" ^ (string_of_int addr) |> print_endline
        else
            codegen_prog xs;;
