all: build

build:
	ocamlbuild -use-menhir ast.ml exp_lex.mll exp_par.mly

clean:
	rm -r _build/*

test:
	ocamlbuild -Is tests/small_tests,tests/large_tests,tests -use-menhir -use-ocamlfind exp_test.native && ./exp_test.native
