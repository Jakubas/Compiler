all: build

build:
	ocamlbuild -I src -use-menhir ast.ml exp_lex.mll exp_par.mly

clean:
	rm -r _build/*

test:
	ocamlbuild -I src -use-menhir -use-ocamlfind exp_test.native && ./exp_test.native
