Dialects of Pixley
==================

As is probably inevitable with a project like this, several minor
variations on Pixley exist.  This document aims to descibe the
significant ones, and their relationships with each other.

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

Pifxlety
--------

*Pifxlety* is a language trivially related to Pifxley.  The only
difference between the two is that Pifxlety does not have Scheme's
`let*` form.  Instead, it has Scheme's `let` form.

No Pifxlety self-interpreter has yet been written as part of the
Pixley project, but I will hazard that it would not be significantly
smaller than the Pifxley self-interpreter, for two reasons:

1. Some places in the Pifxley interpreter do rely on the fact that
   previous bindings in a `let*` are visible in subsequent bindings.
   These occurrences would have to be rewritten to use nested `let`s.
2. Implementing `let` is not significantly easier than implementing
   `let*`; it is mainly a matter of retrieving the bindings visible
   to the current binding from an expression which is unchanging over
   the whole form, rather than "folded in" after each binding.

Of course, I may be wrong; I won't know until I implement it.

Pifxlety is neither a strict subset of Pifxley nor of Pixley, and
neither is either of those two languages a strict subset of it.
But Pifxlety is a strict subset of Scheme.

For completeness, there must also be a Pixlety: a language just like
Pixley except with `let` instead of `let*`.  It is not a particularly
interesting variation to me, so I won't get into it, except to say
that it, too, is not a subset of any of these other languages, except
of course Scheme.

Pixl_y
------

Now it is of course possible to remove `let` or `let*` _altogether_
from the language.  The remaining language, which I'll call *Pixl_y*,
does not suffer in computational power, only expressivity.

Because expressions in Pixley do not have side-effects, there is no
semantic difference between binding an expression to an identifier
and then using the identifier twice, and just using the expression
twice.  So `let*` is completely unnecessary.

Even in the absence of `let*`, you're not forced to repeat yourself;
you can use `lambda` as a way to bind expressions to identifiers.
For instance,

    (let* ((a (cons b c))) (cons a a))

can be rewritten

    ((lambda (a) (cons a a)) (cons b c))

Pixl_y is a strict subset of Pixley, and of Pixlety.  It is not a
subset of Pifxley, but of course there could be a Pifxl_y if you like.

P_xl_y
------

If you remove `cond` from Pixl_y you get *P_xl_y*.

Without decision-making, you might think P_xl_y isn't Turing-complete;
but you do still have `lambda`, and you can thus write expressions
directly in the (eager) lambda calculus.  It's just that you'll have
to come up with your own representations for truth-values -- one common
way is to make truth-values functions which take two arguments, with
the true truth-value returning the first argument, and false returning
the second.  And, of course, none of the existing machinery (`equal?`
and so forth) supports this, so you'll have to roll your own.

P_xl_y *is* a strict subset of every language listed so far -- Pixl_y,
Pifxl_y, Pifxley, Pifxlety, Pixlety, Pixley, and Scheme.

You could of course continue down this road, removing other stuff
from the language (and letters from the name) until you just had one-
argument `lambda` and symbols remaining -- and I guess, to match the
lambda calculus, you could just call this language *l*.

Crabwell
--------

Unlike the previous languages, *Crabwell* is a version of Pixley with
one extra feature.  In Crabwell, an arbitrary S-expression may occur
instead of a symbol as the identifier in a binding in a `let*`
expression.  In addition, the form `(symbol x)`, where _x_ is any
S-expression, evaluates to whatever _x_ is currently bound to in the
environment.  This allows arbitrary S-expressions to be used as
identifiers.

This variation was invented to overcome a limitation of Pixley,
namely, that it lacks any way to create new symbols.  This is a
significant limitation for implementing program transformations which
create new `let*` bindings, such as A-normalization.

Crabwell is not a subset of Scheme, and therefore not a subset of
Pixley either.  However, Pixley is a subset of Crabwell, and there is
a trivial mapping between (finite) Crabwell programs and (finite)
Pixley programs -- simply rename each S-expression-based identifier
to a symbol-based identifier not used elsewhere in the scope in which
it resides.  Again, Pixley per se cannot do this, because it cannot
create new symbols, but a program in a language which can generate a
program source text character-by-character could do so.

And, I should note, it's not really necessary to translate Crabwell
to Pixley, or even to evaluate Crabwell, to reap some benefits from
it in the realm of static analysis.  If a program translates a Pixley
program to an equivalent Crabwell program, perhaps with new bindings
generated in it, then proves some property of the Crabwell program,
we know that property is true of the original Pixley program as well.

`crabwell.pix` is a Crabwell interpreter written in Pixley.
