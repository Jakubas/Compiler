open Exp_lex
open Test
open Lexing
open Printf

let parse_with_error_as_string lexbuf =
  try
    let _ = Exp_par.top Exp_lex.read lexbuf in "pass\n"
  with
    | SyntaxError msg -> msg ^ ": " ^ position lexbuf
    | Exp_par.Error ->   "Parse error: " ^ position lexbuf
    | _ -> "Unhandled error\n"

let parse_test str =
  let lex = Lexing.from_string str in
  parse_with_error_as_string lex

let rec batch_test files acc = match files with
  | []    -> print_string acc
  | x::xs ->
    let str = x ^ ": " ^ parse_test (read_file x) in batch_test xs (acc ^ str)

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
