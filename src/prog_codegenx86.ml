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
    | And   -> "and   "
    | Or    -> "or    "
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

let codegenx86_and_or_op op =
    let label = "lbltrue" ^ (string_of_int(lblcounter true)) in
    let endlabel = "end" ^ (string_of_int(lblcounter false)) in
    "popq  %rax\n" ^
    "popq  %rbx\n" ^
    string_of_bool_op op ^ "%rax, %rbx\n" ^
    "cmpq  $0, %rbx\n" ^
    "jne   " ^ label ^ "\n" ^
    "pushq $0\n" ^
    "jmp   " ^ endlabel ^ "\n" ^
    label ^ ":\n" ^
    "pushq $1\n" ^
    endlabel ^ ":\n"
    |> Buffer.add_string code

let codegenx86_negate _ =
    let label = "lbltrue" ^ (string_of_int(lblcounter true)) in
    let endlabel = "end" ^ (string_of_int(lblcounter false)) in
    "popq  %rax\n" ^
    "cmpq  $0, %rax\n" ^
    "jne   " ^ label ^ "\n" ^
    "pushq $1\n" ^
    "jmp   " ^ endlabel ^ "\n" ^
    label ^ ":\n" ^
    "pushq $0\n" ^
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

let codegenx86_mutable addr =
    "//offset " ^ (string_of_int addr) ^ " mutable lookup\n" ^
    "movq  $" ^ (-16 - 8 * addr |> string_of_int) ^  ", %rax\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

let codegenx86_deref _ =
    "popq  %rax\n" ^
    "movq  %rbp, %rbx\n" ^
    "addq  %rax, %rbx\n" ^
    "movq  -0(%rbx), %rax\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

let codegenx86_asg _ =
    (*top of stack is stack offset
      2nd is value to be assigned*)
    "//asg\n" ^
    "popq  %rax\n" ^
    "movq  %rbp, %rbx\n" ^
    "addq  %rax, %rbx\n" ^
    "popq  %rax\n" ^
    "movq  %rax, -0(%rbx)\n"
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

let codegenx86_stackframe size_args =
    "pushq %rbp\n" ^
    "movq  %rsp, %rbp\n"
    |> Buffer.add_string code;
    let size = ref size_args in
    while !size > 0 do
        "movq  " ^ (8 * !size |> string_of_int) ^  "(%rbp), %rax\n" ^
        "pushq %rax\n"
        |> Buffer.add_string code;
        size := !size - 1;
    done

let codegenx86_call label =
    "call  " ^ label ^ "\n" ^
    "movq  %rbp, %rsp\n" ^
    "popq  %rbp\n" ^
    "pushq %rax\n"
    |> Buffer.add_string code

(* Symbol Table Functions *)
(* (symbolName, (memoryAddress, isMutable)) *)
let insert symbol addr symt = ((symbol, (addr, false)) :: symt)
let insert_mutable symbol addr symt = ((symbol, (addr, true)) :: symt)
let rec lookup symbol symt = match symt with
    | [] -> raise (Codegenx86Error ("Codegenx86Error: symbol '" ^ symbol ^ "' has no value assigned to it"))
    | (symbol2, vals)::xs -> if symbol = symbol2 then vals else lookup symbol xs
let rec lookup_mutable symbol symt = match symt with
    | [] -> raise (Codegenx86Error ("Codegenx86Error: mutable symbol '" ^ symbol ^ "' has no value assigned to it"))
    | (symbol2,(addr, true))::xs -> if symbol = symbol2 then addr else lookup_mutable symbol xs
    | (symbol2,(addr, false))::xs -> lookup_mutable symbol xs

let rec fill_symt acc = function
    | []    -> acc
    | x::xs ->
        let acc' = (x, (!sp, true)) :: acc in
        let _ = sp := !sp + 1 in
        fill_symt acc' xs

let rec codegenx86 symt frame = function
    | Seq (e1, e2) ->
        codegenx86 symt frame e1;
        codegenx86 symt frame e2
    | Operator (Divide, e1, e2) ->
        codegenx86 symt frame e1;
        codegenx86 symt frame e2;
        codegenx86_div();
        sp := !sp - 1
    | Operator ((And|Or) as oper, e1, e2) ->
        codegenx86 symt frame e1;
        codegenx86 symt frame e2;
        codegenx86_and_or_op oper;
        sp := !sp - 1
    | Operator ((Leq|Geq|Equal|Noteq) as oper, e1, e2) ->
        codegenx86 symt frame e1;
        codegenx86 symt frame e2;
        codegenx86_bool_op oper;
        sp := !sp - 1
    | Operator (oper, e1, e2) ->
        codegenx86 symt frame e1;
        codegenx86 symt frame e2;
        codegenx86_op oper;
        sp := !sp - 1
    | Const n ->
        codegenx86_st n;
        sp := !sp + 1;
    | Identifier x ->
        let vals = lookup x symt in
        let addr = fst vals in
        let isMutable = snd vals in
        if isMutable then
            match frame with
                | [] -> raise (Codegenx86Error ("Codegenx86Error: undefined behaviour for variable '" ^ x ^ "'"))
                | _  ->
                    codegenx86_mutable addr;
                    sp := !sp + 1
        else
            (match frame with
                | [] ->
                    codegenx86_id addr;
                    sp := !sp + 1
                | _  -> raise (Codegenx86Error ("Codegenx86Error: undefined behaviour for variable '" ^ x ^ "'")))

    | Let (x, e1, e2) ->
        codegenx86 symt frame e1;
        let symt' = insert x (!sp) symt in
        codegenx86 symt' frame e2;
        codegenx86_let();
        sp := !sp - 1
    | New (x, e1, e2) ->
        codegenx86 symt frame e1;
        let symt' = insert_mutable x (!sp) symt in
        codegenx86 symt' frame e2;
        codegenx86_let();
        sp := !sp - 1
    | Deref (e1) ->
        codegenx86 symt (Deref (e1) :: frame) e1;
        codegenx86_deref()
    | Asg (e1, e2) ->
        codegenx86 symt frame e2;
        codegenx86 symt (Asg (e1, e2) :: frame) e1;
        codegenx86_asg();
        sp := !sp - 2
    | If (e1, e2, e3) ->
        codegenx86 symt frame e1;
        let label = "label" ^ (string_of_int (lblcounter true)) in
        let endlabel = "endlabel" ^ (string_of_int (lblcounter false)) in
        let _ = codegenx86_if label in
        let _ = codegenx86 symt frame e3 in
        let _ = codegenx86_jmp endlabel in
        let _ = codegenx86_label label in
        let _ = codegenx86 symt frame e2 in
        codegenx86_label endlabel;
        sp := !sp - 1
    | While (e1, e2) ->
        let label = "whilestart" ^ (string_of_int (lblcounter true)) in
        let endlabel = "whileend" ^ (string_of_int (lblcounter false)) in
        let _ = codegenx86_label label in
        let _ = codegenx86 symt frame e1 in
        let _ = codegenx86_while endlabel in
        let _ = codegenx86 symt frame e2 in
        let _ = codegenx86_jmp label in
        codegenx86_label endlabel;
        sp := !sp - 1
    | Application (Identifier name, args) ->
        let size_args = codegen_args symt 0 args in
        let prev_sp = !sp in
        let _ = sp := -1 in
        let _ = codegenx86_stackframe size_args in
        let _ = codegenx86_call name in
        sp := prev_sp;
        (* needs testing *)
        sp := !sp + 1
    | Negate (op, e1) ->
        codegenx86 symt frame e1;
        codegenx86_negate()
    | Printint _ -> ()
    | Readint -> ()
    | x -> raise (Codegenx86Error ((string_of_exp x) ^ " not implemented"))

and codegen_args symt size_args = function
  | Empty -> size_args
  | Arg(e1, e2) ->
    codegenx86 symt [] e1;
    codegen_args symt (size_args+1) e2
  | e -> codegenx86 symt [] e; (size_args+1)

let rec codegenx86_prog = function
    | [] -> raise (Codegenx86Error ("no main function defined"))
    | (name, args, exp)::xs ->
        if name = "main" then
            let _ = Buffer.reset code in
            let _ = Buffer.add_string code prefix in
            let _ = codegenx86 [] [] exp in
            let _ = Buffer.add_string code "popq  %rdi\n" in
            let _ = Buffer.add_string code suffix in
            let chan = open_out "templ.s" in
            Buffer.output_buffer chan code
        else
            codegenx86_prog xs

let rec codegenx86_prog'' main_frame = function
    | [] -> (match main_frame with
        | ("main", [], exp) ->
            let _ = sp := 0 in
            let _ = Buffer.add_string code main_prefix in
            let _ = codegenx86 [] [] exp in
            let _ = Buffer.add_string code "popq  %rdi\n" in
            Buffer.add_string code suffix
        | _ -> raise (Codegenx86Error ("no main function defined")))
    | ("main", [], exp) as main::xs ->
        codegenx86_prog'' main xs
    | (name, params, exp)::xs ->
        let _ = sp := -1 in
        let symt = fill_symt [] params in
        let _ = Hashtbl.add func_store name params in
        let _ = Buffer.add_string code "\n" in
        let _ = codegenx86_label name in
        let _ = codegenx86 symt [] exp in
        let _ = Buffer.add_string code "popq  %rax\nret\n" in
        codegenx86_prog'' main_frame xs

let rec codegenx86_prog' filename prog =
    let _ = Buffer.reset code in
    let _ = Hashtbl.reset func_store in
    let _ = sp := 0 in
    let _ = Buffer.add_string code prefix in
    let _ = codegenx86_prog'' ("", [], Empty) prog in
    let chan = open_out (filename ^ ".s") in
    Buffer.output_buffer chan code;;
