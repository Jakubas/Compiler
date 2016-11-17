FROM ocaml/opam:ubuntu
USER root
RUN opam install menhir
ADD . /home/opam/compiler
CMD cd /home/opam/compiler && make testcompiler && cc -s templ.s && ./a.out
