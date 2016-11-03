open Printf
open Ast
open Compiler_functions
open Lex
open Par
open Test

(* only optimise of flag is set *)
let optimise_check optimise_flag parsed = if optimise_flag
  then optimise parsed
  else parsed

let print_optimised_ast optimise_flag file_path =
  let file_str = read_file file_path in
  let lexbuf = Lexing.from_string file_str in
  try
    let parsed = Test.parse_with_error lexbuf in
    let optimised = optimise_check optimise_flag parsed in
    let value_to_print = (if optimise_flag
      then string_of_program optimised
      else "Optimisation flag is not set, run with argument -o") in
    printf "\n%s\nPre-optimised:\n%s\nOptimised:\n%s\n" file_path (string_of_program parsed) value_to_print
  with
    | SyntaxError msg -> print_string ("\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m")
    | Par.Error ->   print_string ("\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m")

let () =
  (if Array.length Sys.argv >= 3
    then
    (if Sys.argv.(1) = "-o"
      then print_optimised_ast true Sys.argv.(2)
      else print_optimised_ast false Sys.argv.(1))
    else print_optimised_ast false Sys.argv.(1))
