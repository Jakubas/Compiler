### How to Build
You need ocamlbuild, menhir, and make installed to build the compiler.
<br />To build the compiler use the command:
<br />make

### How to Test
The test script code is contained in exp_test.ml. The tests are in the /tests subdirectory.
<br />To compile and run the test suite run the command:
<br />make test

## Language Syntax

### Cheat Sheet
| Syntax      | Meaning    |
| ------------|:-------------:|
| + | addition|
| - | subtraction|
| * | multiplication|
| / | division |
| <=| lesser than or equal|
| >=| greater than or equal|
| ==| equal|
| !=| not equal|
| &| logical and|
| &#124; | logical or|
| ! | logical not |
| \*x | dereferencing of identifier 'x' |
| x  | identifer 'x' |
| 1 / 2 | opcode application |
| x = \*x + 1; 4 + 4 | sequence of expressions |
| while (\*i >= 0) { i = \*i - 1 } | while loop |
| if (\*x == \*y) {x = \*x + 1} else {y = \*y + 1} | if else statement |
| val = 5 | assignment of '5' to identifier 'val' |
| square(a;b) | function application |
| 6 | constant of int |
| readInt() | read int from input |
| printInt(3) | print '3' to output |
| x = \*x + 1 | assign right side of assignment to identifier 'x' |
| final int x = 6; | create a non-mutable 'x' |
| int i = 0; | create a mutable 'i' |

Each syntax construct is documented in the following way:
<br />Concrete Syntax: the syntax of the construct
<br />Abstract Syntax: The corresponding syntax from the abstract syntax tree
<br />Example(s): One or more code snippets of the syntax

### Opcodes
The concrete syntax in this section is derived from the opcode type in the abstract syntax tree.

Concrete Syntax: +
<br /> Abstract Syntax: Plus
<br /> Example(s): 1 + 1

Concrete Syntax: -
<br /> Abstract Syntax: Minus
<br /> Example(s): 2 - 5

Concrete Syntax: \*
<br /> Abstract Syntax: Times
<br /> Example(s): -1 \* 5

Concrete Syntax: /
<br /> Abstract Syntax: Divide
<br /> Example(s): 6 / \*y

Concrete Syntax: <=
<br /> Abstract Syntax: Leq
<br /> Example(s): \*x <= 5

Concrete Syntax: >=
<br /> Abstract Syntax: Geq
<br /> Example(s): \*y >= \*k

Concrete Syntax: ==
<br /> Abstract Syntax: Equal
<br /> Example(s): 6 == 5

Concrete Syntax: !=
<br /> Abstract Syntax: Noteq
<br /> Example(s): 5 != \*x

Concrete Syntax: &
<br /> Abstract Syntax: And
<br /> Example(s): \*x >= 5 & \*y <= 6

Concrete Syntax: |
<br /> Abstract Syntax: Or
<br /> Example(s): \*x >= 2 | \*y <= 3

Concrete Syntax: !e
<br /> Abstract Syntax: Not
<br /> Example(s): !\*x == 5

### Expressions
The concrete syntax in this section is derived from the expression type in the abstract syntax tree.
<br /> e is shorthand for expression
<br /> op is shorthand for opcode
<br /> i is shorthand for int
<br /> str is shorthand for string

Concrete Syntax: e;e
<br /> Abstract Syntax: Seq(e,e)
<br /> Example(s): x = \*x + 1; \*x + 6

Concrete Syntax: while (e) {e}
<br /> Abstract Syntax: While(e,e)
<br /> Example(s): while (\*i >= 0) { i = \*i - 1 }

Concrete Syntax: if (e) {e} else {e}
<br /> Abstract Syntax: If(e,e,e)
<br /> Example(s): if (\*x >= \*y) {x = \*x + 1} else {y = \*y + 1}

Concrete Syntax: e = e
<br /> Abstract Syntax: Asg(e,e)
<br /> Example(s): val = 6

Concrete Syntax: \*e
<br /> Abstract Syntax: Deref(e)
<br /> Example(s): \*x

Concrete Syntax: e op e
<br /> Abstract Syntax: Operator(op,e,e)
<br /> Example(s): 1 + 3; -6 \* 5; \*x >= -6

Concrete Syntax: op e
<br /> Abstract Syntax: Negate(op,e)
<br /> Example(s): !x; !m

Concrete Syntax: e(e)
<br /> Abstract Syntax: Application(e,e)
<br /> Example(s): square(a;b)

Concrete Syntax: 6
<br /> Abstract Syntax: Const(i)
<br /> Example(s): 5; 105; -542

Concrete Syntax: readInt()
<br /> Abstract Syntax: ReadInt
<br /> Example(s): readInt()

Concrete Syntax: printInt(e)
<br /> Abstract Syntax: Printint(e)
<br /> Example(s): printInt(5)

Concrete Syntax: x
<br /> Abstract Syntax: Identifier(string)
<br /> Example(s): cal; num;

Concrete Syntax: final int e = e;
<br /> Abstract Syntax: Let(str,e,e)
<br /> Example(s): final int x = 6 + 6;

Concrete Syntax: int e = e;
<br /> Abstract Syntax: New(str,e,e)
<br /> Example(s): int i = 0;

### Fundef

Concrete Syntax: funName (stringArg1;stringArg2) {e}
<br /> Abstract Syntax: string * string list * expression
<br /> Example(s): add(a;b;c;d) { \*a + \*b + \*c + \*d }

### Program
Concrete Syntax: fundef list
<br /> Abstract Syntax: fundef list
<br /> Example(s): main() { 1 } main2(c) { \*c + -6 }
