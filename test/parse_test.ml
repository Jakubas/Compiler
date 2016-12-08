open Lex
open Test
open Lexing
open Printf

let parse_with_error_as_string lexbuf =
  try
    let _ = Par.top Lex.read lexbuf in "\x1b[32mpass" ^  "\x1b[0m"
  with
    | SyntaxError msg -> "\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^  "\x1b[0m"
    | Par.Error ->   "\x1b[31m" ^ "Parse error: " ^ position lexbuf ^  "\x1b[0m"
    | _ -> "\x1b[31m" ^ "Unhandled error" ^  "\x1b[0m"

let parse_test str =
  let lex = Lexing.from_string str in
  parse_with_error_as_string lex

let rec batch_test files acc = match files with
  | []    -> print_string acc
  | (file_path, _, _)::xs ->
    let str =
    sprintf "%s\n%s\n" file_path (parse_test (read_file file_path)) in batch_test xs (acc ^ str)
