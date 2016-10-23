%{
open Ast
%}

/* Operators */
%token PLUS
%token MINUS
%token ASTERIX
%token DIVIDE
%token LEQ
%token GEQ
%token AND
%token EQUAL
%token NOTEQ
%token OR
%token NOT

/* Expressions */
%token <int> INT
%token <string> ID
%token SEMICOLON
%token WHILE
%token IF
%token ELSE
%token ASG
%token READINT
%token PRINTINT
%token LET
%token NEWINT

/* Other */
%token LBRACKET
%token RBRACKET
%token LPAREN
%token RPAREN
%token EOF

%right SEMICOLON
%nonassoc RBRACKET
%nonassoc ASG

%right NOT
%left OR
%left AND

%left EQUAL, NOTEQ
%left LEQ, GEQ

%left PLUS, MINUS
%left ASTERIX, DIVIDE
%nonassoc LPAREN

%start <Ast.program> top
%%

top:
  | a = funct; EOF { [a] }
  | a = funct; b = funct; { [a;b] }

funct:
  | x = ID; LPAREN; args = fun_args RPAREN; LBRACKET; e = exp; RBRACKET { (x,args,e) }

fun_args: args = separated_list(SEMICOLON, ID) { args } ;

exp:
  | i = INT { Const(i) }
  | MINUS; i = INT { Const(-i) }
  | x = ID; {(Identifier(x))}
  | ASTERIX; e = exp; {Deref(e)}
  | e = exp; o = op; f = exp { Operator(o,e,f) }
  | e = exp; ASG; f = exp { Asg(e,f) }
  | e = exp; LPAREN; f = exp; RPAREN { Application(e,f) }
  | e = exp; SEMICOLON; f = exp { Seq(e,f) }
  | WHILE; LPAREN; e = exp; RPAREN; LBRACKET; f = exp; RBRACKET { While(e,f) }
  | WHILE; LPAREN; e = exp; RPAREN; LBRACKET; f = exp; RBRACKET;
    g = exp { Seq(While(e,f),g) }
  | IF LPAREN; e = exp; RPAREN; LBRACKET f = exp; RBRACKET;
    ELSE; LBRACKET; g = exp; RBRACKET { If(e,f,g) }
  | IF LPAREN; e = exp; RPAREN; LBRACKET f = exp; RBRACKET;
    ELSE; LBRACKET; g = exp; RBRACKET; h = exp { Seq(If(e,f,g),h) }
  | PRINTINT; LPAREN; e = exp; RPAREN { Printint(e) }
  | READINT; LPAREN; RPAREN { Readint }
  | LET; NEWINT; x = ID; ASG; e = exp; SEMICOLON; f = exp { Let(x,e,f) }
  | NEWINT; x = ID; ASG; e = exp; SEMICOLON; f = exp { New(x,e,f) }
  | NOT; f = exp; {Negate(Ast.Not,f)}

%inline op:
  | PLUS { Plus }
  | MINUS { Minus }
  | ASTERIX { Times }
  | DIVIDE { Divide }
  | LEQ { Leq }
  | GEQ { Geq }
  | NOTEQ { Noteq }
  | EQUAL  { Equal }
  | AND  { And }
  | OR  { Or }
  | NOT { Not }
