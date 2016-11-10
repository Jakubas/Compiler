open Ast
open Prog_interpret
open Lexing
open Lex
open Test
open Printf
open Compiler_functions

let interpret_test str expected_value =
  let lexbuf = Lexing.from_string str in
 try
    let parsed = Test.parse_with_error lexbuf in
    let value = interpret_prog parsed in
    if value = expected_value
      then "\x1b[32mpass, evaluated to: " ^ (string_of_int value) ^ "\x1b[0m"
      else "\x1b[31mfail, evaluated to: " ^ (string_of_int value) ^ ", should evaluate to: " ^ (string_of_int expected_value) ^ "\x1b[0m"
  with
  | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m"
  | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m"
  | InterpretError msg -> "\x1b[31m" ^ msg ^ "\x1b[0m"
  | Stack_overflow -> "\x1b[31mstack overflow" ^ "\x1b[0m"

let rec batch_test files = match files with
  | [] -> print_string ""
  | (file_path, expected_value)::xs ->
    let result = interpret_test (read_file file_path) expected_value in
    let _ = printf "%s\n%s\n" file_path result in
    batch_test xs

(* tuples of (file_path, expected value) *)
let test_files = [
  (* Some Test Cases From Week2 *)
  ("test/small_tests/week2_eval/assignments.jk", 2);
  ("test/small_tests/week2_eval/int_fun.jk", 100);
  ("test/small_tests/week2_eval/operation_seqs.jk", (-4));
  ("test/small_tests/week2_eval/two_functions.jk", 1);
  (* Week 5 Test Cases *)
  ("test/small_tests/week5/lets_and_news.jk", 462);
  ("test/small_tests/week5/sample.jk", 310);
];;

batch_test test_files;
