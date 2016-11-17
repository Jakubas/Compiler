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
    | file_path::xs ->
        let result = codegenx86_test file_path in
        let _ = printf "%s\n%s\n" file_path result in
        batch_test xs

(* tuples of (file_path, expected value) *)
let test_files = [
    (* Some Test Cases From Week2 *)
    ("test/small_tests/week2_eval/assignments.jk");
    ("test/small_tests/week2_eval/int_fun.jk");
    ("test/small_tests/week2_eval/operation_seqs.jk");
    ("test/small_tests/week2_eval/two_functions.jk");
    (* Week 5 Test Cases *)
    ("test/small_tests/week5/lets_and_news.jk");
    ("test/small_tests/week5/sample.jk");
];;

batch_test test_files;
