FROM ocaml/opam:ubuntu

USER root

RUN opam install menhir

ADD . /home/opam/compiler

CMD cd /home/opam/compiler && make testcompiler && printf "\ntest/small_tests/week5/lets_and_news.jk\n" && cc -s test/small_tests/week5/lets_and_news.jk.s && ./a.out && printf "test/small_tests/week5/sample.jk\n" &&cc -s test/small_tests/week5/sample.jk.s && ./a.out
