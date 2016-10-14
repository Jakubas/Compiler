open Exp_lex
open Lexing
open Printf

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

let parse_tree_of_string str =
  str
  |> Lexing.from_string
  |> parse_with_error
  |> Ast.string_of_program;;

  let print_parse_tree_of_string str =
    str
    |> Lexing.from_string
    |> parse_with_error
    |> Ast.string_of_program
    |> print_endline;;
