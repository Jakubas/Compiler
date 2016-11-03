open Printf
open Ast
open Compiler_functions
open Lex
open Par
open Prog_eval
open Test

let optim_test file_path expected_value =
  let file_str = read_file file_path in
  let lexbuf = Lexing.from_string file_str in
  try
    let parsed = Test.parse_with_error lexbuf in
    let optimised = optimise parsed in
    let value = eval parsed in
    let value2 = eval optimised in
    if value = value2 && value2 = expected_value
      then "\x1b[32mpass, evaluated: \npre-optimised: " ^ (string_of_value value) ^
           "\npost-optimised: " ^ (string_of_value value2) ^ "\x1b[0m"
      else "\x1b[31mfail, evaluated: \npre-optimised: " ^ (string_of_value value) ^
           "\npost-optimised: " ^ (string_of_value value2) ^
           "\nactual value: " ^ (string_of_value expected_value) ^ "\x1b[0m"
  with
    | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m"
    | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m"
    | RuntimeError msg -> "\x1b[31m" ^ msg ^ "\x1b[0m"
    | Stack_overflow -> "\x1b[31mstack overflow" ^ "\x1b[0m"

let rec batch_test files = match files with
  | [] -> print_string ""
  | (file_path, expected_value)::xs ->
    let result = optim_test file_path expected_value in
    let _ = printf "%s\n%s\n" file_path result in
    batch_test xs

(* tuples of (file_path, expected value) *)
let test_files = [
  ("test/small_tests/week4/constant_folding_and_propagation.jk", Int' 12);
  ("test/small_tests/week4/constant_folding.jk", Int' 42);
  ("test/small_tests/week4/constant_folding2.jk", Int' 1000);
  ("test/small_tests/week4/constant_propagation.jk", Int' 5);
  ("test/small_tests/week4/constant_propagation2.jk", Int' 60);
  ("test/small_tests/week4/constant_propagation3.jk", Int' 150);
  ("test/small_tests/week4/if_branch.jk", Int' 4);
  ("test/small_tests/week4/if_branch2.jk", Int' 100);
  ("test/small_tests/week4/loop_unrolling.jk", Int' 101);
  ("test/small_tests/week4/loop_unrolling2.jk", Int' 255);
];;

batch_test test_files;
