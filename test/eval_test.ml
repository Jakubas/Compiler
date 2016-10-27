open Lex
open Prog_eval
open Test
open Lexing
open Printf
open Hashtbl

let stdin_eval_test str =
  let lexbuf = Lexing.from_string str in
 try
    let parsed = parse lexbuf in
    (* Clear the hashtbls after each program run, since these are single file programs*)
    let _ = reset Prog_eval.func_store in
    let _ = reset Prog_eval.store in
    let value = eval_prog parsed in
    "\x1b[32mpass, evaluated to: " ^ (string_of_value value) ^ "\x1b[0m"
  with
  | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m"
  | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m"
  | RuntimeError msg -> "\x1b[31m" ^ msg ^ "\x1b[0m"
  | Stack_overflow -> "\x1b[31mstack overflow" ^ "\x1b[0m"

let stdin_test filePath = match filePath with
  | ""  -> "\x1b[31mfail, no file given" ^ "\x1b[0m"
  | fp ->
    let result = stdin_eval_test (read_file fp) in
    let _ = printf "%s\n%s\n" fp result in
    ""


let eval_test str expected_value =
  let lexbuf = Lexing.from_string str in
 try
    let parsed = parse lexbuf in
    (* Clear the hashtbls after each program run, since these are single file programs*)
    let _ = reset Prog_eval.func_store in
    let _ = reset Prog_eval.store in
    let value = eval_prog parsed in
    if value = expected_value
      then "\x1b[32mpass, evaluated to: " ^ (string_of_value value) ^ "\x1b[0m"
      else "\x1b[31mfail, evaluated to: " ^ (string_of_value value) ^ ", should evaluate to: " ^ (string_of_value expected_value) ^ "\x1b[0m"
  with
  | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m"
  | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m"
  | RuntimeError msg -> "\x1b[31m" ^ msg ^ "\x1b[0m"
  | Stack_overflow -> "\x1b[31mstack overflow" ^ "\x1b[0m"

let rec batch_test files = match files with
  | [] -> print_string ""
  | (file_path, expected_value)::xs ->
    let result = eval_test (read_file file_path) expected_value in
    let _ = printf "%s\n%s\n" file_path result in
    batch_test xs

(* tuples of (file_path, expected value) *)
let test_files = [
  (* Tests For Week 2 Eval *)
  (* Small test cases *)
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
  (* Tests For Week 3 Eval *)
  (* Small tests cases *)
  ("test/small_tests/week3/assign_to_function.jk", Int' 10);
  ("test/small_tests/week3/functions_as_arguments.jk", Int' 105);
  ("test/small_tests/week3/functions_no_args.jk", Int' 8);
  ("test/small_tests/week3/functions_with_args.jk", Int' (-88));
  ("test/small_tests/week3/let.jk", Int' 12);
  ("test/small_tests/week3/main_at_bottom.jk", Int' 1001);
  ("test/small_tests/week3/main_at_top.jk", Int' 1001);
  ("test/small_tests/week3/new.jk", Bool' true);
  ("test/small_tests/week3/recursion.jk", Int' 102);
  ("test/small_tests/week3/recursive_powers.jk", Int' 1024);
];;


batch_test test_files;

stdin_test "test/small_tests/week3/add_read_ints.jk";
