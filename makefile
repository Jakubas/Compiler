all: build

build:
	ocamlbuild -Is src,test -use-menhir ast.ml compiler_functions.ml lex.mll par.mly prog_eval.ml prog_optimise.ml

clean:
	rm -r _build/*

tests:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind optimise_test.native eval_test.native parse_test.native optimise.native

testoptimise:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind optimise_test.native && ./optimise_test.native

testeval:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind eval_test.native && ./eval_test.native

testparser:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind parse_test.native && ./parse_test.native
