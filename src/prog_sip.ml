(* Configuration *)
open Hashtbl
open Ast
exception SipError of string

(* Configuration *)
let ram = Hashtbl.create 100
let acc = ref 0
let addr_base = ref 0

(* Instruction Set *)
let op (op, addr1, addr2) =
    acc := op (find ram addr1) (find ram addr2)
let st addr = replace ram addr !acc
let ldc n = acc := n

(* put value from addr1 to addr2 *)
let mv addr1 addr2 =
    let v1 = find ram addr1 in
    replace ram addr2 v1

let add x y = x + y
let sub x y = x - y
let mul x y = x * y
let div x y = x / y

(* get operation instruction *)
let fun_of_op = function
    | Plus -> add
    | Minus -> sub
    | Times -> mul
    | Divide -> div
    | _ -> raise (SipError ("SipError: not implemented"))

(* Symbol Table Functions *)
let insert symbol addr symt = ((symbol, addr) :: symt)
let rec lookup symbol symt = match symt with
  | [] -> raise (SipError ("SipError: immutable symbol '" ^ symbol ^ "' has no value assigned to it")) (*Id' id*)
  | (symbol2,addr)::xs -> if symbol = symbol2 then (*let _ = print_string("immutable:" ^ (string_of_int(find ram addr)) ^ "\n") in*) addr else lookup symbol xs
let insert_mutable symbol addr symt = (("_"^symbol, addr) :: symt)
let rec lookup_mutable symbol symt = match symt with
| [] -> raise (SipError ("SipError: mutable symbol '" ^ symbol ^ "' has no value assigned to it")) (*Id' id*)
| (symbol2,addr)::xs -> if ("_"^symbol) = symbol2 then (*let _ = print_string("Mutable:" ^ (string_of_int(find ram addr)) ^ "\n") in*) addr else lookup_mutable symbol xs

let new_addr = let i = addr_base in (fun () -> incr i; !i)

let rec interpret symt = function
    | Seq (e1, e2) ->
        let addr1 = interpret symt e1 in
        let addr2 = interpret symt e2 in
        addr_base := addr1;
        st addr1;
        addr1
    | Operator (oper, e1, e2) ->
        let addr1 = interpret symt e1 in
        let addr2 = interpret symt e2 in
        op (fun_of_op oper, addr1, addr2);
        addr_base := addr1;
        st addr1;
        addr1
    | Const n ->
        let addr = new_addr() in
        ldc n;
        st addr;
        addr
    | Identifier x ->
        let addr = lookup x symt in
        let addr' = new_addr() in
        mv addr addr';
        addr'
    | Let (x, e1, e2) ->
        let addr1 = interpret symt e1 in
        let symt' = insert x addr1 symt in
        let addr2 = interpret symt' e2 in
        mv addr2 addr1;
        addr_base := addr1;
        addr1
    | New (x, e1, e2) ->
        let addr1 = interpret symt e1 in
        let symt' = insert_mutable x addr1 symt in
        let addr2 = interpret symt' e2 in
        mv addr2 addr1;
        addr_base := addr1;
        addr1
    | Deref (Identifier x) ->
        let addr = lookup_mutable x symt in
        let addr' = new_addr() in
        mv addr addr';
        addr'
    | Asg (Identifier x, e2) ->
        let addr1 = lookup_mutable x symt in
        let addr2 = interpret symt e2 in
        mv addr2 addr1;
        (*addr_base := addr1;*)
        addr1

    | _ -> raise (SipError "not implemented")

let rec interpret_prog = function
    | [] -> raise (SipError ("no main function defined"))
    | (name, _, exp)::xs ->
        if name = "main" then
            find ram (interpret [] exp)
        else
            interpret_prog xs;;

(*interpret_prog (parse_string
"
main() {
    let int x = 5;
    let int y = 10;
    x + y;
}
");*)
        (*
        | Seq of expression * expression (* e; e *)
        | Operator of opcode * expression * expression (* e + e *)
        | Negate of opcode * expression (* !e *)
        | Const of int (* 7 *)
        | Identifier of string (* x *)
        | Let of string * expression * expression (* int x = e; e *)
        *)

        (* Required *)
        (*| New of string * expression * expression (* final int x = e; e *)*)
        (*| Deref of expression (* *e *)*)
        (*| Asg of expression * expression (* e = e *)*)

        (* Optional *)
        (*| While of expression * expression (* while (e) {e} *)*)
        (*| If of expression * expression * expression (* if (e) {e} else {e} *)*)

        (*| Application of expression * expression (* e(e) *)*)
        (*| Empty*)
        (*| Readint (* readInt() *)*)
        (*| Printint of expression (* printInt (e) *)*)
        (*| Arg of expression * expression*)

(*
(*let rec interpret symt = function
    | Seq (e1, e2) ->
        let addr1 = interpret symt e1 in
        let addr2 = interpret symt e2 in
        addr_base := addr1;
        (*st addr1;*)
        addr1
    | Operator (oper, e1, e2) ->
        let addr1 = interpret symt e1 in
        let addr2 = interpret symt e2 in
        op (fun_of_op oper, addr1, addr2);
        let addr3 =  new_addr() in
        st addr3;
        addr3
    (*| Negate (oper, e1) ->
        let addr1 = interpret symt e1 in*)
    | Const n ->
        let addr = new_addr() in
        ldc n;
        st addr;
        addr
    | Identifier x -> lookup x symt
        (*let addr = lookup x symt in
        let addr' = new_addr() in
        mv addr addr';
        addr'*)
    | Let (x, e1, e2) ->
        let addr1 = interpret symt e1 in
        let symt' = insert x addr1 symt in
        let addr2 = interpret symt' e2 in
        addr2
        (*mv addr2 addr1;
        addr_base := addr1;
        addr1*)
    | New (x, e1, e2) ->
        let addr1 = interpret symt e1 in
        let symt' = insert_mutable x addr1 symt in
        let addr2 = interpret symt' e2 in
        addr2
        (*mv addr2 addr1;
        addr_base := addr1;
        Printf.printf "NewId:  %s\n" x;
        Printf.printf "NewAddr:%d\n" addr1;
        Printf.printf "NewVal: %d\n" (find ram addr1);
        addr1*)
    | Deref (Identifier x) -> lookup_mutable x symt
        (*let addr = lookup_mutable x symt in
        let addr' = new_addr() in
        mv addr addr';
        addr'*)
    (*| Asg (Identifier x, e2) ->
        let addr1 = lookup_mutable x symt in
        let addr2 = interpret symt e2 in
        mv addr2 addr1;
        addr_base := addr1;
        addr1*)

    | _ -> raise (SipError "not implemented")*)
    *)
