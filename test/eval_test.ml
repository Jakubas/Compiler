open Lex
open Prog_eval
open Test
open Lexing
open Printf

let eval_test str expected_value =
  let lexbuf = Lexing.from_string str in
 try
    let parsed = parse lexbuf in
    let value = eval_prog parsed in
    if value = expected_value
      then "\x1b[32mpass, evaluated to: " ^ (string_of_value value)
      else "\x1b[31mfail, evaluated to: " ^ (string_of_value value) ^ ", should evaluate to: " ^ (string_of_value expected_value)
  with
  | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf
  | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf
  | RuntimeError msg -> "\x1b[31m" ^ msg
  | Stack_overflow -> "\x1b[31mstack overflow"

let rec batch_test files acc = match files with
  | [] -> print_string acc
  | (file_path, expected_value)::xs ->
    let result = eval_test (read_file file_path) expected_value in
    let str = sprintf "\x1b[37m%s\n%s\n" file_path result in batch_test xs (acc ^ str)

(* tuples of (file_path, expected value) *)
let test_files = [
  (* Small test cases 1 *)
  ("test/small_tests/week1_parsing/test_assignment.jk", Int' 6);
  ("test/small_tests/week1_parsing/test_const.jk", Int' 5);
  ("test/small_tests/week1_parsing/test_dereference.jk", Int' 2);
  ("test/small_tests/week1_parsing/test_identifier.jk", Id' "x");
  ("test/small_tests/week1_parsing/test_if_else.jk", Int' 8);
  ("test/small_tests/week1_parsing/test_negate.jk", Bool' false);
  ("test/small_tests/week1_parsing/test_operator.jk", Bool' true);
  ("test/small_tests/week1_parsing/test_sequence.jk", Int' (-3));
  ("test/small_tests/week1_parsing/test_while.jk", Int' 7);
  (* Small test cases 2 *)
  ("test/small_tests/week2_eval/assignments.jk", Int' 2);
  ("test/small_tests/week2_eval/bool_fun.jk", Bool' true);
  ("test/small_tests/week2_eval/bools.jk", Bool' true);
  ("test/small_tests/week2_eval/id_fun.jk", Id' "y");
  ("test/small_tests/week2_eval/int_fun.jk", Int' 100);
  ("test/small_tests/week2_eval/nested_ifs.jk", Int' 3);
  ("test/small_tests/week2_eval/nested_whiles.jk", Int' 1003772);
  ("test/small_tests/week2_eval/operation_seqs.jk", Int' (-4));
  ("test/small_tests/week2_eval/two_functions.jk", Int' 1);
  ("test/small_tests/week2_eval/while_ifs.jk", Int' 17);
  (* Large test cases *)
  ("test/large_tests/week2_eval/fibonacci.jk", Int' 610);
  (* These tests should fail *)
  ("test/small_tests/week2_eval/fail_stackoverflow.jk", Int' 1);
  ("test/small_tests/week2_eval/fail_division_by_zero.jk", Int' 1);
  ("test/small_tests/week2_eval/fail_value_type.jk", Bool' true);
];;


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
