{
open Exp_par
exception SyntaxError of string
}

let int = ['0'-'9']+
let white = ' ' | '\t'
let newline = '\r' | '\n' | "\r\n"
let identifier = ['a'-'z' 'A'-'Z' '0'-'9']+

rule read =
 parse
 | white { read lexbuf }
 | newline { read lexbuf }
 | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
 | '+' { PLUS }
 | '-' { MINUS }
 | '*' { TIMES }
 | '/' { DIVIDE }
 | "<=" { LEQ }
 | ">=" { GEQ }
 | "==" { EQUAL }
 | "!=" { NOTEQ }
 | '&' { AND }
 | '|' { OR }
 | '!' { NOT }
 | ';' { SEMICOLON }
 | "while" { WHILE }
 | "if" { IF }
 | "else" { ELSE }
 | "=" { ASG }
 | "readInt" { READINT }
 | "printInt" { PRINTINT }
 | "final" { FINAL }
 | "int" { NEWINT }
 | '{' { LBRACKET }
 | '}' { RBRACKET }
 | '(' { LPAREN }
 | ')' { RPAREN }
 | identifier { ID (Lexing.lexeme lexbuf) }
 | eof { EOF }
 | _ { raise (SyntaxError ("Unexpected char: " ^
 				Lexing.lexeme lexbuf)) }
