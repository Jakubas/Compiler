open Lex
open Prog_eval
open Test
open Lexing
open Printf
open Hashtbl
open Compiler_functions

(*
let stdin_eval_test str =
  let lexbuf = Lexing.from_string str in
 try
    let parsed = Test.parse lexbuf in
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
*)

let eval_test str expected_value =
  let lexbuf = Lexing.from_string str in
 try
    let parsed = Test.parse_with_error lexbuf in
    let optimised = parsed in
    let value = eval optimised in
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
  | (file_path, expected_value, _)::xs ->
    let result = eval_test (read_file file_path) expected_value in
    let _ = printf "%s\n%s\n" file_path result in
    batch_test xs
