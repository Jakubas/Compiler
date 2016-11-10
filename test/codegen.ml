open Prog_codegen
open Lexing
open Lex
open Test
open Compiler_functions

let print_codegen filepath =
    let file_str = read_file filepath in
    let lexbuf = Lexing.from_string file_str in
    try
        let parsed = Test.parse_with_error lexbuf in
        codegen_prog parsed
    with
        | SyntaxError msg -> print_string ("\x1b[31m" ^ msg ^ ": " ^ position lexbuf ^ "\x1b[0m")
        | Par.Error ->   print_string ("\x1b[31m" ^ "Parse error: " ^ position lexbuf ^ "\x1b[0m")
        | CodegenError msg -> print_string ("\x1b[31m" ^ msg ^ "\x1b[0m")
        | Stack_overflow -> print_string ("\x1b[31mstack overflow" ^ "\x1b[0m")

let () =
    if Array.length Sys.argv >= 2 then
        print_codegen Sys.argv.(1)
    else
        print_string "Usage: codegen.native <filepath>\n"
