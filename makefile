all: build

build:
	ocamlbuild -Is src,test -use-menhir ast.ml compiler_functions.ml lex.mll par.mly prog_eval.ml prog_optimise.ml prog_interpret.ml prog_codegen.ml

clean:
	rm -rf _build/* && rm -f *.native && cd test && find . -type f -name '*.s' -delete

tests:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind test_all.native && ./test_all.native

tests2:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind optimise_test.native eval_test.native parse_test.native optimise.native codegen.native

testinterpret:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind interpret_test.native && ./interpret_test.native

testcompiler:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind codegenx86_test.native && ./codegenx86_test.native

testcodegen:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind codegen_test.native && ./codegen_test.native

testoptimise:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind optimise_test.native && ./optimise_test.native

testeval:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind eval_test.native && ./eval_test.native

testparser:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind parse_test.native && ./parse_test.native

docker: clean
	docker build -t compiler .

run:
	docker run -it compiler /bin/bash
