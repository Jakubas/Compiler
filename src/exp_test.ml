open Exp_lex
open Lexing
open Printf
open Tree_parse

let get_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  sprintf "Pos %d:%d:%d\n" pos.pos_lnum pos.pos_bol pos.pos_cnum

let test_parse_with_error lexbuf =
  try
    let _ = Exp_par.top Exp_lex.read lexbuf in "pass\n"
  with
    | SyntaxError msg -> msg ^ ": " ^ get_position lexbuf
    | Exp_par.Error ->   "Parse error: " ^ get_position lexbuf
    | _ -> "Unhandled error\n"

let parse_test str =
  let lex = Lexing.from_string str in
  test_parse_with_error lex

let read_file filename =
  let lines = ref [] in
  let chan = open_in filename in
  try
    while true; do
      lines := input_line chan :: !lines
    done; String.concat "" !lines
  with End_of_file ->
    close_in chan;
    String.concat "" (List.rev !lines);;

let test_files = [
(*Small test cases *)
"tests/small_tests/test_application.jk";
"tests/small_tests/test_assignment.jk";
"tests/small_tests/test_const.jk";
"tests/small_tests/test_dereference.jk";
"tests/small_tests/test_fun_args.jk";
"tests/small_tests/test_identifier.jk";
"tests/small_tests/test_if_else.jk";
"tests/small_tests/test_let.jk";
"tests/small_tests/test_multiple_functions.jk";
"tests/small_tests/test_negate.jk";
"tests/small_tests/test_new.jk";
"tests/small_tests/test_operator.jk";
"tests/small_tests/test_print_int.jk";
"tests/small_tests/test_read_int.jk";
"tests/small_tests/test_sequence.jk";
"tests/small_tests/test_while.jk";
(* Large test cases *)
"tests/large_tests/iterative_bisection.jk";
"tests/large_tests/recursive_bisection.jk";
(* These tests should fail *)
"tests/small_tests/test_fail_if.jk";
"tests/small_tests/test_fail_operation.jk";
"tests/small_tests/test_fail_sequence.jk";
];;

let rec batch_test files = match files with
  | []    -> ""
  | x::xs -> (x) ^ ": " ^ parse_test (read_file x) ^ batch_test xs;;

print_string (batch_test test_files);
