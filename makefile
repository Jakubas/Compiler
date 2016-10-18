all: build

build:
	ocamlbuild -I src -use-menhir ast.ml exp_lex.mll exp_par.mly prog_eval.ml

test:
	ocamlbuild -I src -use-menhir -use-ocamlfind eval_test.native && ./eval_test.native

clean:
	rm -r _build/*

buildparser:
	ocamlbuild -I src -use-menhir ast.ml exp_lex.mll exp_par.mly

testparser:
	ocamlbuild -I src -use-menhir -use-ocamlfind exp_test.native && ./exp_test.native
