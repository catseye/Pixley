Dialects of Pixley
==================

As is probably inevitable with a project like this, several minor
variations on Pixley exist.

Pixley 1.x
----------

*Pixley 1.x* was the original version of Pixley.  It supported two
extra forms from Scheme that the current version (2.0) of Pixley does
not support: `null?` and `cadr`.

P-Normal Pixley
---------------

*P-Normal Pixley* is a subset of Pixley where each `cond` can have
only one test branch before the `else`, and where each `let*` can
only bind one value to one identifier.

P-Normal Pixley is a strict subset of Pixley.  All P-Normal Pixley
programs are Pixley programs; all P-Normal Pixley programs are also
Scheme programs.

Pifxley
-------

*Pifxley* is a language trivially related to Pixley.  The only
difference between the two is that Pifxley does not have Scheme's
`cond` form.  Instead, it has Scheme's `if` form.

Like Pixley, Pifxley is a strict subset of Scheme.  Pifxley is
not a subset of Pixley, nor is Pixley a subset of Pifxley (hello,
lattice theory!)

`pifxley.pifx` is the Pifxley reference interpreter; it is written
in Pifxley.  It consists of 386 instances of 52 unique symbols in
615 cons cells.  This is actually somewhat smaller than the Pixley
self-interpreter, which means that if I was going for purely small
size in the self-interpreter, `if` would have made a better choice,
as a langauge form to support, than `cond`.  However, I find `cond`
expressions generally easier to write, and the self-interpreter
has one big `cond` expression in the evaluation dispatching section.
In the Pifxley interpreter, this section is more awkwardly written
and a litte harder to follow (you have to pay more attention to
how many close parentheses there are.)

`pixley.pifx` is a Pixley interpreter written in Pifxley.
