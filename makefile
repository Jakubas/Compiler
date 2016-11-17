all: build

build:
	ocamlbuild -Is src,test -use-menhir ast.ml compiler_functions.ml lex.mll par.mly prog_eval.ml prog_optimise.ml prog_interpret.ml prog_codegen.ml

clean:
	rm -rf _build/* && rm -f *.native

tests:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind optimise_test.native eval_test.native parse_test.native optimise.native codegen.native

testinterpret:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind interpret_test.native && ./interpret_test.native

testcompiler:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind prog_codegenx86.native #&& ./prog_codegenx86.native

testcodegen:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind codegen_test.native && ./codegen_test.native

testoptimise:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind optimise_test.native && ./optimise_test.native

testeval:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind eval_test.native && ./eval_test.native

testparser:
	ocamlbuild -Is src,test -use-menhir -use-ocamlfind parse_test.native && ./parse_test.native

container:
	docker build -t compiler .

run:
	docker run compiler
#sudo docker run -v /home/daniel/Compiler:/home/opam/compiler -i -t ocaml/opam:ubuntu /bin/bash
