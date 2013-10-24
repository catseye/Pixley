`mignon`
========

`mignon` is an implementation of Pixley in C.  It compiles under `gcc`
with the `-ansi -pedantic` flags.  The executable on my system (32-bit
Linux), after stripping, is a mere 9,680 bytes.

`mignon` takes its input directly from the command line, rather than
reading a file.  In practice, to make it read a file, you can say in your
shell:

    % mignon `cat file.pix`

`mignon`'s parser is resumable (meaning, it uses what are basically
continuations, or alternately what is basically a push-down automaton,
instead of being built in the manner of recursive descent).  One "nice"
end result of this is that you can split up your Pixley program amongst
the command-line parameters however you like:
    
    % mignon '(cons (quote a) (cons (quote b) (quote ())))'
    (a b)
    % mignon '(cons (quote a)' '(cons (quote b) (quote ())))'
    (a b)

`mignon` does not have a garbage collector.  Since it is not really
intended to be a long-running process (one s-expression goes in,
another s-expression comes out,) this is not generally a problem in
practice.  It might become an issue if you try to build a *really*
large tower of Pixley interpreters, however.
