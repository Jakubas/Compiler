let prefix =
".LC0:
.string	\"%d\\n\"
.text
.globl	print
.type	print, @function
print:
.LFB2:
.cfi_startproc
pushq	%rbp
.cfi_def_cfa_offset 16
.cfi_offset 6, -16
movq	%rsp, %rbp
.cfi_def_cfa_register 6
subq	$16, %rsp
movl	%edi, -4(%rbp)
movl	-4(%rbp), %eax
movl	%eax, %esi
movl	$.LC0, %edi
movl	$0, %eax
call	printf
movl	$0, %edi
call	exit
.cfi_endproc
"

let main_prefix = "
.LFE2:
.size	print, .-print
.globl	main
.type	main, @function\n
main:
.LFB3:
.cfi_startproc
pushq	%rbp
.cfi_def_cfa_offset 16
.cfi_offset 6, -16
movq	%rsp, %rbp
.cfi_def_cfa_register 6
subq	$16, %rsp
movl	$260, -4(%rbp)
movl	-4(%rbp), %eax
movl	%eax, %edi\n"

let suffix =
"call	print
movl	$1, %eax
leave
.cfi_def_cfa 7, 8
ret
.cfi_endproc
.LFE3:
.size	main, .-main
.ident	\"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609\"
.section	.note.GNU-stack,\"\",@progbits\n"

open Hashtbl
open Ast
exception Codegenx86Error of string

(* Configuration *)
let sp = ref 0
let lblcounter =
  let count = ref (0) in
  fun do_incr -> if do_incr then begin incr count end; !count
let func_store = Hashtbl.create 10

(* get operation instruction *)
let string_of_op = function
    | Plus   -> "addq  "
    | Minus  -> "subq  "
    | Times  -> "imulq "
    | _ -> raise (Codegenx86Error ("SipError: op not implemented"))

(* get operation instruction *)
let string_of_bool_op = function
    | Leq   -> "jle   "
    | Geq   -> "jge   "
    | Equal -> "je    "
    | Noteq -> "jne   "
    (*| And   -> "and   "
    | Or    -> "or    "*)
    | _ -> raise (Codegenx86Error ("SipError: op not implemented"))

let code = Buffer.create 1000

(* Instruction Set *)
let codegenx86_op op =
    "popq  %rax\n" ^
    "popq  %rbx\n" ^
    (string_of_op op) ^ "%rax, %rbx\n" ^
    "pushq %rbx\n"
    |> Buffer.add_string code

let codegenx86_bool_op op =
    let label = "lbltrue" ^ (string_of_int(lblcounter true)) in
    let endlabel = "end" ^ (string_of_int(lblcounter false)) in
    "popq  %rax\n" ^
    "popq  %rbx\n" ^
    "cmpq  %rax, %rbx\n" ^
    string_of_bool_op op ^ label ^ "\n" ^
    "pushq $0\n" ^
    "jmp   " ^ endlabel ^ "\n" ^
    label ^ ":\n" ^
    "pushq $1\n" ^
    endlabel ^ ":\n"
    |> Buffer.add_string code

let codegenx86_if label =
    "popq  %rax\n" ^
    "movq  $0, %rbx\n" ^
    "cmpq  %rax, %rbx\n" ^
    "jne   " ^ label ^ "\n"
    |> Buffer.add_string code

let codegenx86_while label =
    "popq  %rax\n" ^
    "movq  $0, %rbx\n" ^
    "cmpq  %rax, %rbx\n" ^
    "je   " ^ label ^ "\n"
    |> Buffer.add_string code

let codegenx86_div _ =
    "popq  %rbx\n" ^
    "popq  %rax\n" ^
    "cqto\n" ^
    "idivq %rbx\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

let codegenx86_id addr =
    "//offset " ^ (string_of_int addr) ^ " lookup\n" ^
    "movq  " ^ (-16 - 8 * addr |> string_of_int) ^  "(%rbp), %rax\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

let codegenx86_asg addr =
    "//offset " ^ (string_of_int addr) ^ " asg\n" ^
    "popq  %rax\n" ^
    "movq  %rax, " ^ (-16 - 8 * addr |> string_of_int) ^  "(%rbp)\n"
    |> Buffer.add_string code

let codegenx86_st n =
    "pushq $" ^ (string_of_int n) ^ "\n"
    |> Buffer.add_string code

let codegenx86_let _ =
    "popq  %rax\n" ^
    "popq  %rbx\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

let codegenx86_jmp label =
    "jmp   " ^ label ^ "\n"
    |> Buffer.add_string code

let codegenx86_label label =
    label ^ ":\n"
    |> Buffer.add_string code

let codegenx86_stackframe _ =
    "pushq %rbp\n" ^
    "movq  %rsp, %rbp\n"
    |> Buffer.add_string code

let codegenx86_call label =
    "call  " ^ label ^ "\n" ^
    "movq  %rbp, %rsp\n" ^
    "popq  %rbp\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

(* Symbol Table Functions *)
let insert symbol addr symt = ((symbol, addr) :: symt)
let rec lookup symbol symt = match symt with
  | [] -> raise (Codegenx86Error ("SipError: immutable symbol '" ^ symbol ^ "' has no value assigned to it"))
  | (symbol2,addr)::xs -> if symbol = symbol2 then addr else lookup symbol xs

let insert_mutable symbol addr symt = (("_"^symbol, addr) :: symt)
let rec lookup_mutable symbol symt = match symt with
| [] -> raise (Codegenx86Error ("SipError: mutable symbol '" ^ symbol ^ "' has no value assigned to it"))
| (symbol2,addr)::xs -> if ("_"^symbol) = symbol2 then addr else lookup_mutable symbol xs

let rec fill_symt acc = function
    | []    -> acc
    | x::xs ->
        let acc' = ("_"^x, !sp) :: acc in
        let _ = sp := !sp + 1 in
        fill_symt acc' xs

let rec codegenx86 symt = function
    | Seq (e1, e2) ->
        codegenx86 symt e1;
        codegenx86 symt e2
    | Operator (Divide, e1, e2) ->
        codegenx86 symt e1;
        codegenx86 symt e2;
        codegenx86_div();
        sp := !sp - 1
    | Operator ((Leq|Geq|Equal|Noteq) as oper, e1, e2) ->
        codegenx86 symt e1;
        codegenx86 symt e2;
        codegenx86_bool_op oper;
        sp := !sp - 1
    | Operator (oper, e1, e2) ->
        codegenx86 symt e1;
        codegenx86 symt e2;
        codegenx86_op oper;
        sp := !sp - 1
    | Const n ->
        codegenx86_st n;
        sp := !sp + 1;
    | Identifier x ->
        let addr = lookup x symt in
        codegenx86_id addr;
        sp := !sp + 1
    | Let (x, e1, e2) ->
        codegenx86 symt e1;
        let symt' = insert x (!sp) symt in
        codegenx86 symt' e2;
        codegenx86_let();
        sp := !sp - 1
    | New (x, e1, e2) ->
        codegenx86 symt e1;
        let symt' = insert_mutable x (!sp) symt in
        codegenx86 symt' e2;
        codegenx86_let();
        sp := !sp - 1
    | Deref (Identifier x) ->
        let addr = lookup_mutable x symt in
        codegenx86_id addr;
        sp := !sp + 1
    | Asg (Identifier x, e1) ->
        let _ = codegenx86 symt e1 in
        let addr = lookup_mutable x symt in
        codegenx86_asg addr;
        sp := !sp - 1
    | If (e1, e2, e3) ->
        codegenx86 symt e1;
        let label = "label" ^ (string_of_int (lblcounter true)) in
        let endlabel = "endlabel" ^ (string_of_int (lblcounter false)) in
        let _ = codegenx86_if label in
        let _ = codegenx86 symt e3 in
        let _ = codegenx86_jmp endlabel in
        let _ = codegenx86_label label in
        let _ = codegenx86 symt e2 in
        codegenx86_label endlabel;
        sp := !sp - 1
    | While (e1, e2) ->
        let label = "whilestart" ^ (string_of_int (lblcounter true)) in
        let endlabel = "whileend" ^ (string_of_int (lblcounter false)) in
        let _ = codegenx86_label label in
        let _ = codegenx86 symt e1 in
        let _ = codegenx86_while endlabel in
        let _ = codegenx86 symt e2 in
        let _ = codegenx86_jmp label in
        codegenx86_label endlabel;
        sp := !sp - 1
    | Application (Identifier name, args) ->
        codegenx86_stackframe();
        let prev_sp = !sp in
        let _ = sp := -1 in
        let _ = codegen_args symt args in
        let _ = codegenx86_call name in
        sp := prev_sp;
        (* needs testing *)
        sp := !sp + 1
    | x -> raise (Codegenx86Error ((string_of_exp x) ^ " not implemented"))

and codegen_args symt = function
  | Empty -> ()
  | Arg(e1, e2) ->
    codegenx86 symt e1;
    codegen_args symt e2
  | e -> codegenx86 symt e

let rec codegenx86_prog = function
    | [] -> raise (Codegenx86Error ("no main function defined"))
    | (name, args, exp)::xs ->
        if name = "main" then
            let _ = Buffer.reset code in
            let _ = Buffer.add_string code prefix in
            let _ = codegenx86 [] exp in
            let _ = Buffer.add_string code "popq  %rdi\n" in
            let _ = Buffer.add_string code suffix in
            let chan = open_out "templ.s" in
            Buffer.output_buffer chan code
        else
            codegenx86_prog xs

let rec codegenx86_prog'' = function
    | [] -> raise (Codegenx86Error ("no main function defined"))
    | ("main", [], exp)::xs ->
        let _ = sp := 0 in
        let _ = Buffer.add_string code main_prefix in
        let _ = codegenx86 [] exp in
        let _ = Buffer.add_string code "popq  %rdi\n" in
        Buffer.add_string code suffix
    | (name, params, exp)::xs ->
            let _ = sp := -1 in
            let symt = fill_symt [] params in
            let _ = Hashtbl.add func_store name params in
            let _ = Buffer.add_string code "\n" in
            let _ = codegenx86_label name in
            let _ = codegenx86 symt exp in
            let _ = Buffer.add_string code "popq  %rax\nret\n" in
            codegenx86_prog'' xs

let rec codegenx86_prog' filename prog =
    let _ = Buffer.reset code in
    let _ = Hashtbl.reset func_store in
    let _ = sp := 0 in
    let _ = Buffer.add_string code prefix in
    let _ = codegenx86_prog'' prog in
    let chan = open_out (filename ^ ".s") in
    Buffer.output_buffer chan code;;

(*
let rec codegenx86_prog' filename = function
    | [] -> raise (Codegenx86Error ("no main function defined"))
    | (name, _, exp)::xs ->
        if name = "main" then
            let _ = Buffer.reset code in
            let _ = sp := 0 in
            let _ = Buffer.add_string code prefix in
            let _ = Buffer.add_string code main_prefix in
            let _ = codegenx86 [] exp in
            let _ = Buffer.add_string code "popq  %rdi\n" in
            let _ = Buffer.add_string code suffix in
            let chan = open_out (filename ^ ".s") in
            Buffer.output_buffer chan code
        else
            codegenx86_prog' filename xs;;
*)
