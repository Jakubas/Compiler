%{
open Ast
%}

/* Operators */
%token PLUS
%token MINUS
%token TIMES
%token DIVIDE
%token LEQ
%token GEQ
%token EQUAL
%token NOTEQ
%token AND
%token OR
%token NOT

/* Expressions */
%token <int> INT
%token <string> ID
%token SEQ
%token WHILE
%token IF
%token ELSE
%token ASG
%token READINT
%token PRINTINT
%token FINAL
%token NEWINT

/* Other */
%token LBRACKET
%token RBRACKET
%token LPAREN
%token RPAREN
%token RETURN
%token COMMA
%token EOF

%nonassoc RETURN
%right SEQ
%right ASG

%left OR
%left AND
%left EQUAL
%left NOTEQ
%left LEQ
%left GEQ
%left PLUS
%left MINUS
%left TIMES
%left DIVIDE
%right NOT

%start <Ast.program> top
%%

top:
  | a = funct; EOF { [a] }
  | a = funct; b = funct; { [a;b] }

funct:
  | x = ID; LPAREN; args = fun_args RPAREN; LBRACKET; e = exp; RBRACKET { (x,args,e) }

fun_args: args = separated_list(COMMA, ID) { args } ;

exp:
  | i = INT { Const(i) }
  | MINUS; i = INT { Const(-i) }
  | e = exp; o = op; f = exp { Operator(o,e,f) }

  | x = ID; { Deref(Identifier(x)) }
  | RETURN; e = exp; { e }

  | x = ID; ASG; f = exp { Asg(Identifier(x),f) }
  | x = ID; LPAREN; f = exp; RPAREN { Application(Identifier(x),f) }
  | e = exp; SEQ; f = exp { Seq(e,f) }

  | WHILE; LPAREN; e = exp; RPAREN; LBRACKET; f = exp; RBRACKET { While(e,f) }
  | IF LPAREN; e = exp; RPAREN; LBRACKET f = exp; RBRACKET;
    ELSE; LBRACKET; g = exp; RBRACKET { If(e,f,g) }

  | PRINTINT; LPAREN; e = exp; RPAREN { Printint(e) }
  | READINT; LPAREN; RPAREN { Readint }

  | FINAL; NEWINT; x = ID; ASG; e = exp; SEQ; f = exp { Let(x,e,f) }
  | NEWINT; x = ID; ASG; e = exp; SEQ; f = exp { New(x,e,f) }

%inline op:
  | PLUS { Plus }
  | MINUS { Minus }
  | TIMES { Times }
  | DIVIDE { Divide }
  | LEQ { Leq }
  | GEQ { Geq }
  | NOTEQ { Noteq }
  | EQUAL  { Equal }
  | AND  { And }
  | OR  { Or }
  | NOT  { Not }
