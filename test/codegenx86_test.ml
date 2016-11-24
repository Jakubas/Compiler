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
    | (file_path, expected_value)::xs ->
        let result = codegenx86_test file_path in
        let _ = printf "%s\n%s\n" file_path result in
        let file = file_path ^ ".s" in
        let _ = printf "%s\n" ("cc " ^ file ^ " && ./a.out") in
        let _ = printf "expected: %d\n" expected_value in
        let _ = flush_all() in
        let _ = Sys.command ("cc " ^ file_path ^ ".s" ^ " && ./a.out\n") in
        let _ = print_string "\n" in
        batch_test xs

(* tuples of (file_path, expected value) *)
let test_files = [
    ("test/small_tests/week2_eval/assignments.jk", 2);
    ("test/small_tests/week2_eval/bool_fun.jk", 1);
    ("test/small_tests/week2_eval/bools.jk", 1);
    ("test/small_tests/week2_eval/int_fun.jk", 100);
    ("test/small_tests/week2_eval/nested_ifs.jk", 3);
    ("test/small_tests/week2_eval/nested_whiles.jk", 1003772);
    ("test/small_tests/week2_eval/operation_seqs.jk", (-4));
    ("test/small_tests/week2_eval/two_functions.jk", 1);
    ("test/small_tests/week2_eval/while_ifs.jk", 17);
    (* Large test cases *)
    ("test/large_tests/week2_eval/fibonacci.jk", 610);
    (* Tests For Week 3 Eval *)
    (* Small tests cases *)
    ("test/small_tests/week3/assign_to_function.jk", 10);
    ("test/small_tests/week3/functions_as_arguments.jk", 105);
    ("test/small_tests/week3/functions_no_args.jk", 8);
    ("test/small_tests/week3/functions_with_args.jk", (-88));
    ("test/small_tests/week3/let.jk", 12);
    ("test/small_tests/week3/main_at_bottom.jk", 1001);
    ("test/small_tests/week3/main_at_top.jk", 1001);
    ("test/small_tests/week3/new.jk", 1);
    ("test/small_tests/week3/recursion.jk", 102);
    ("test/small_tests/week3/recursive_powers.jk", 1024);

    ("test/small_tests/week4/constant_folding_and_propagation.jk", 12);
    ("test/small_tests/week4/constant_folding.jk", 42);
    ("test/small_tests/week4/constant_folding2.jk", 1000);
    ("test/small_tests/week4/constant_propagation.jk", 5);
    ("test/small_tests/week4/constant_propagation2.jk", 60);
    ("test/small_tests/week4/constant_propagation3.jk", 150);
    ("test/small_tests/week4/if_branch.jk", 4);
    ("test/small_tests/week4/if_branch2.jk", 100);
    ("test/small_tests/week4/loop_unrolling.jk", 101);
    ("test/small_tests/week4/loop_unrolling2.jk", 255);
    (* Week 5 Test Cases *)
    ("test/small_tests/week5/lets_and_news.jk", 462);
    ("test/small_tests/week5/sample.jk", 310);
    ("src/test.jk", 5);
];;

batch_test test_files;
