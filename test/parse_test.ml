open Lex
open Test
open Lexing
open Printf
open Tree_parse
let parse_with_error_as_string lexbuf =
  try
    let _ = Par.top Lex.read lexbuf in "\x1b[32mpass" ^  "\x1b[0m"
  with
    | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^  "\x1b[0m"
    | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^  "\x1b[0m"
    | _ -> "\x1b[31m" ^ "Unhandled error" ^  "\x1b[0m"

let parse_test str =
  let lex = Lexing.from_string str in
  parse_with_error_as_string lex

let rec batch_test files acc = match files with
  | []    -> print_string acc
  | x::xs ->
    let str =
    sprintf "%s\n%s\n" x (parse_test (read_file x)) in batch_test xs (acc ^ str)

let test_files = [
  (*Small test cases *)
  "test/small_tests/week1_parsing/test_application.jk";
  "test/small_tests/week1_parsing/test_assignment.jk";
  "test/small_tests/week1_parsing/test_const.jk";
  "test/small_tests/week1_parsing/test_dereference.jk";
  "test/small_tests/week1_parsing/test_fun_args.jk";
  "test/small_tests/week1_parsing/test_identifier.jk";
  "test/small_tests/week1_parsing/test_if_else.jk";
  "test/small_tests/week1_parsing/test_let.jk";
  "test/small_tests/week1_parsing/test_multiple_functions.jk";
  "test/small_tests/week1_parsing/test_negate.jk";
  "test/small_tests/week1_parsing/test_new.jk";
  "test/small_tests/week1_parsing/test_operator.jk";
  "test/small_tests/week1_parsing/test_print_int.jk";
  "test/small_tests/week1_parsing/test_read_int.jk";
  "test/small_tests/week1_parsing/test_sequence.jk";
  "test/small_tests/week1_parsing/test_while.jk";
  (* Large test cases *)
  "test/large_tests/week1_parsing/iterative_bisection.jk";
  "test/large_tests/week1_parsing/recursive_bisection.jk";
  (* These tests should fail *)
  "test/small_tests/week1_parsing/test_fail_if.jk";
  "test/small_tests/week1_parsing/test_fail_operation.jk";
  "test/small_tests/week1_parsing/test_fail_sequence.jk";
];;

batch_test test_files "";

print_parse_tree_of_string (read_file "test/large_tests/week1_parsing/iterative_bisection.jk");
