open Printf
open Lexing
open Par
open Lex
open Prog_eval
open Prog_optimise

(* WIP *)

(* Reads the program into a string *)
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

(* Prints lexing position for debugging *)
let print_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  eprintf "Pos %d:%d:%d\n" pos.pos_lnum pos.pos_bol pos.pos_cnum

(* parse a string into an AST *)
let parse file_path =
  let file_str = (read_file file_path) in
  let lexbuf = Lexing.from_string file_str in
  try
    Par.top Lex.read lexbuf
  with
    | SyntaxError msg -> raise (SyntaxError msg)
    | Par.Error -> raise (Par.Error)

(* Optimise AST if flag is set *)
let optimise parsed = optim_prog parsed

(* Evaluate an AST *)
let eval ast =
  try
    eval_prog ast
  with
    | RuntimeError msg -> raise (RuntimeError msg)
    | Stack_overflow -> raise Stack_overflow
