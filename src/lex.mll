{
open Par
exception SyntaxError of string
}

let int = ['0'-'9']+
let white = ' ' | '\t'
let newline = '\r' | '\n' | "\r\n"
let identifier = ['a'-'z' 'A'-'Z' '0'-'9']+
let comment = "/*" _* "*/"
let comment = "/*" ([^'*'] | '*'[^'/'])* "*/"
let closingBracket = ';' white* '}' white* ';' | '}' white* ';' | ';' white* '}' | '}'

rule read =
 parse
 | white { read lexbuf }
 | newline { read lexbuf }
 | comment { read lexbuf }
 | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
 | '+' { PLUS }
 | '-' { MINUS }
 | '*' { ASTERIX }
 | '/' { DIVIDE }
 | "<=" { LEQ }
 | ">=" { GEQ }
 | "==" { EQUAL }
 | "!=" { NOTEQ }
 | '&' { AND }
 | '|' { OR }
 | '!' { NOT }
 | ';' { SEMICOLON }
 | ',' { COMMA }
 | "while" { WHILE }
 | "if" { IF }
 | "else" { ELSE }
 | "=" { ASG }
 | "readInt" { READINT }
 | "printInt" { PRINTINT }
 | "let" { LET }
 | "int" { NEWINT }
 | '{' { LBRACKET }
 | closingBracket { RBRACKET }
 | '(' { LPAREN }
 | ')' { RPAREN }
 | identifier { ID (Lexing.lexeme lexbuf) }
 | eof { EOF }
 | _ { raise (SyntaxError ("Unexpected char: " ^
 				Lexing.lexeme lexbuf)) }
