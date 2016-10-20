open Lex
open Prog_eval
open Lexing
open Printf

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

let print_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  eprintf "Pos %d:%d:%d\n" pos.pos_lnum pos.pos_bol pos.pos_cnum

let position lexbuf =
  let pos = lexbuf.lex_curr_p in
  sprintf "Pos %d:%d:%d" pos.pos_lnum pos.pos_bol pos.pos_cnum

let parse_with_error lexbuf =
  try Par.top Lex.read lexbuf with
  | SyntaxError msg -> prerr_string (msg ^ ": ");
                       print_position lexbuf;
                       exit (-1)
  | Par.Error ->   prerr_string "Parse error: ";
                       print_position lexbuf;
                       exit (-1)

let parse lexbuf = Par.top Lex.read lexbuf

let string_of_value = function
  | Int' i  -> string_of_int i
  | Id' x   -> "'" ^ x ^ "'"
  | Bool' b -> if (b) then "true" else "false"
