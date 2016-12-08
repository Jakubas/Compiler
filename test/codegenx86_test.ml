open Ast
open Prog_codegenx86
open Lexing
open Lex
open Test
open Printf
open Compiler_functions

let codegenx86_test file_path =
    let str = read_file file_path in
    let lexbuf = Lexing.from_string str in
    try
        let parsed = Test.parse_with_error lexbuf in
        let _ = codegenx86_prog' file_path parsed in
        "Generated assembly stored in: " ^ file_path ^ ".s"
    with
        | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m"
        | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m"
        | Codegenx86Error msg -> "\x1b[31m" ^ msg ^ "\x1b[0m"
        | Stack_overflow -> "\x1b[31mstack overflow" ^ "\x1b[0m"

let rec batch_test files = match files with
    | [] -> print_string ""
    | (file_path, _, expected_value)::xs ->
        let result = codegenx86_test file_path in
        let _ = printf "%s\n%s\n" file_path result in
        let file = file_path ^ ".s" in
        let _ = printf "%s\n" ("cc " ^ file ^ " && ./a.out") in
        let _ = printf "expected: %d\n" expected_value in
        let _ = flush_all() in
        let _ = Sys.command ("cc " ^ file_path ^ ".s" ^ " && ./a.out\n") in
        let _ = print_string "\n" in
        batch_test xs
