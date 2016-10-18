open Exp_lex
open Lexing
open Printf
open Tree_parse
open Prog_eval
open Exp_test

let eval_test str =
  str
  |> Lexing.from_string
  |> parse_with_error
  |> eval_prog

(* tuples of (file_path, expected value) *)
let test_files = [
  (*Small test cases *)
  ("tests/small_tests/test_assignment.jk", 6);
  ("tests/small_tests/test_const.jk", 5);
  ("tests/small_tests/test_dereference.jk", 2);
  ("tests/small_tests/test_identifier.jk", 5);
  ("tests/small_tests/test_if_else.jk", 8);
  ("tests/small_tests/test_negate.jk", 0);
  ("tests/small_tests/test_operator.jk", 0);
  ("tests/small_tests/test_sequence.jk", -3);
  ("tests/small_tests/test_while.jk", 7);
  (* Large test cases *)
  (* These tests should fail *)
  ]

  let rec batch_test files acc = match files with
    | [] -> print_string acc
    | (file_path, expected_val)::xs ->
      let value = eval_test (read_file file_path) in
      let result = if value = expected_val
        then "passed"
        else "fail with value: " ^ (string_of_int value) ^ ", value should be: " ^ (string_of_int expected_val) in
      let str = file_path ^ ": " ^ result ^ "\n" in batch_test xs (acc ^ str);;


batch_test test_files "";

(*
print_string ((string_of_int (eval_test "main () {x = 5; *x * *x}"))^"\n");

print_string ((string_of_int (eval_test "
main () {
  x = 0;
  while (*x <= 5) {
    x = *x + 1
  *x
}
}"))^"\n");

print_string ((string_of_int (eval_test  "
main () {
  x = 1;
  y = 1;
  if (*x <= 5) { if (*x == *y) {5; 6 >=1; *y; x} else {y} } else {y} = 42; while (*x <= 200) { x= *x + 1 } *x
  }"))^"\n");
*)
