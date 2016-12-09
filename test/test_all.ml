open Parse_test
open Eval_test
open Optimise_test
open Codegenx86_test
open Prog_eval

(*
//parser
//evaluator
//optimiser
//codegenx86
*)

(* (file path, expected value, expected value as an int) *)
let test_files = [

  ("test/small_tests/week1_parsing/test_application.jk", Int' 5, 5);
  ("test/small_tests/week1_parsing/test_assignment.jk", Int' 6, 6);
  ("test/small_tests/week1_parsing/test_const.jk", Int' 5, 5);
  ("test/small_tests/week1_parsing/test_fun_args.jk", Int' (-1), -1);
  ("test/small_tests/week1_parsing/test_dereference.jk", Int' 2, 2);
  ("test/small_tests/week1_parsing/test_identifier.jk", Int' 5, 5);
  ("test/small_tests/week1_parsing/test_if_else.jk", Int' 8, 8);
  ("test/small_tests/week1_parsing/test_let.jk", Int' 5, 5);
  ("test/small_tests/week1_parsing/test_multiple_functions.jk", Int' (-8), -8);
  ("test/small_tests/week1_parsing/test_negate.jk", Bool' false, 0);
  ("test/small_tests/week1_parsing/test_new.jk", Int' 4, 4);
  ("test/small_tests/week1_parsing/test_operator.jk", Bool' true, 1);
  ("test/small_tests/week1_parsing/test_sequence.jk", Int' (-3), -3);
  ("test/small_tests/week1_parsing/test_while.jk", Int' 7, 7);

  ("test/small_tests/week2_eval/assignments.jk", Int' 2, 2);
  ("test/small_tests/week2_eval/bool_fun.jk", Bool' true, 1);
  ("test/small_tests/week2_eval/bools.jk", Bool' true, 1);
  ("test/small_tests/week2_eval/int_fun.jk", Int' 100, 100);
  ("test/small_tests/week2_eval/nested_ifs.jk", Int' 3, 3);
  ("test/small_tests/week2_eval/nested_whiles.jk", Int' 1003772, 1003772);
  ("test/small_tests/week2_eval/operation_seqs.jk", Int' (-4), -4);
  ("test/small_tests/week2_eval/two_functions.jk", Int' 1, 1);
  ("test/small_tests/week2_eval/while_ifs.jk", Int' 17, 17);
  ("test/large_tests/week2_eval/fibonacci.jk", Int' 610, 610);

  ("test/small_tests/week3/assign_to_function.jk", Int' 10, 10);
  ("test/small_tests/week3/functions_as_arguments.jk", Int' 105, 105);
  ("test/small_tests/week3/functions_no_args.jk", Int' 8, 8);
  ("test/small_tests/week3/functions_with_args.jk", Int' (-88), -88);
  ("test/small_tests/week3/let.jk", Int' 12, 12);
  ("test/small_tests/week3/main_at_bottom.jk", Int' 1001, 1001);
  ("test/small_tests/week3/main_at_top.jk", Int' 1001, 1001);
  ("test/small_tests/week3/new.jk", Bool' true, 1);
  ("test/small_tests/week3/recursion.jk", Int' 102, 102);
  ("test/small_tests/week3/recursive_powers.jk", Int' 16, 16);

  ("test/small_tests/week4/constant_folding_and_propagation.jk", Int' 12, 12);
  ("test/small_tests/week4/constant_folding.jk", Int' 42, 42);
  ("test/small_tests/week4/constant_folding2.jk", Int' 1000, 1000);
  ("test/small_tests/week4/constant_propagation.jk", Int' 5, 5);
  ("test/small_tests/week4/constant_propagation2.jk", Int' 60, 60);
  ("test/small_tests/week4/constant_propagation3.jk", Int' 150, 150);
  ("test/small_tests/week4/if_branch.jk", Int' 4, 4);
  ("test/small_tests/week4/if_branch2.jk", Int' 100, 100);
  ("test/small_tests/week4/loop_unrolling.jk", Int' 101, 101);
  ("test/small_tests/week4/loop_unrolling2.jk", Int' 255, 255);

  ("test/small_tests/week5/lets_and_news.jk", Int' 462, 462);
  ("test/small_tests/week5/sample.jk", Int' 310, 310);

  ("test/small_tests/week6/test.jk", Int' 1500, 1500);
  ("test/small_tests/week6/recursion.jk", Int' 0, 0);
  ("test/small_tests/week6/convolution.jk", Int' 11, 11);
  ("test/small_tests/week6/fizzbuzz.jk", Int' 101, 101);
];;

print_string "\n\nParsing test\n\n";
Parse_test.batch_test test_files "";
print_string "\n\nEval test\n\n";
Eval_test.batch_test test_files;
print_string "\n\nOptimiser test\n\n";
Optimise_test.batch_test test_files;
print_string "\n\nCodegenx86 test\n\n";
Codegenx86_test.batch_test test_files;
