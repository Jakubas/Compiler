open Exp_lex
open Lexing
open Printf
open Tree_parse

let print_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  eprintf "Pos %d:%d:%d\n" pos.pos_lnum pos.pos_bol pos.pos_cnum

let parse_with_error lexbuf =
  try Exp_par.top Exp_lex.read lexbuf with
  | SyntaxError msg -> prerr_string (msg ^ ": ");
                       print_position lexbuf;
                       exit (-1)
  | Exp_par.Error ->   prerr_string "Parse error: ";
                       print_position lexbuf;
                       exit (-1)

let parse_test str =
  let lex = Lexing.from_string str in
  let _ = parse_with_error lex in print_string "pass\n"

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

(*Small test cases *)
parse_test (read_file "tests/small_tests/test_application.jk");
parse_test (read_file "tests/small_tests/test_assignment.jk");
parse_test (read_file "tests/small_tests/test_const.jk");
parse_test (read_file "tests/small_tests/test_dereference.jk");
parse_test (read_file "tests/small_tests/test_identifier.jk");
parse_test (read_file "tests/small_tests/test_if_else.jk");
parse_test (read_file "tests/small_tests/test_let.jk");
parse_test (read_file "tests/small_tests/test_new.jk");
parse_test (read_file "tests/small_tests/test_operator.jk");
parse_test (read_file "tests/small_tests/test_negate.jk");
parse_test (read_file "tests/small_tests/test_print_int.jk");
parse_test (read_file "tests/small_tests/test_read_int.jk");
parse_test (read_file "tests/small_tests/test_sequence.jk");
parse_test (read_file "tests/small_tests/test_while.jk");

(*Large test cases *)
parse_test (read_file "tests/large_tests/iterative_bisection.jk");
parse_test (read_file "tests/large_tests/recursive_bisection.jk");
