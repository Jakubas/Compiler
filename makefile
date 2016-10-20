all: build

build:
	ocamlbuild -Is src,test -use-menhir ast.ml lex.mll par.mly prog_eval.ml

clean:
	rm -r _build/*

testeval:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind eval_test.native && ./eval_test.native

testparser:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind parse_test.native && ./parse_test.native
