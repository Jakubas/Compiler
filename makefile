all: build

build:
	ocamlbuild -Is src,test -use-menhir ast.ml exp_lex.mll exp_par.mly prog_eval.ml

testeval:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind eval_test.native && ./eval_test.native

clean:
	rm -r _build/*

buildparser:
	ocamlbuild -Is src,test -use-menhir ast.ml exp_lex.mll exp_par.mly

testparser:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind exp_test.native && ./exp_test.native
