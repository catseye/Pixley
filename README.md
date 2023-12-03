Pixley
======

_Try it online_ [@ catseye.tc](https://catseye.tc/installation/Pixley)
| _See also:_ [Pail](https://codeberg.org/catseye/Pail#pail)
∘ [Robin](https://codeberg.org/catseye/Robin#robin)

- - - -

Pixley is a strict subset of R5RS Scheme (or, if you prefer, R4RS Scheme),
supporting four datatypes (boolean, cons cell, function, and symbol) and
a dozen built-in symbols.  The reference implementation of Pixley
is written in 124 lines of Pixley (or, if you prefer, 124 lines of Scheme;
and if you prefer more Scheme-ly metrics, it consists of 413 instances of
54 unique symbols in 684 cons cells.)

This distribution also contains (non-reference) implementations of Pixley
in C (`mignon`) and Haskell (`haney`), as well as ancillary support for
running Pixley under four different implementations of Scheme (Racket's
`plt-r5rs`, Husk Scheme, Mini-Scheme v0.85p1, and Tinyscheme,) as well as
several minor dialects of the Pixley language (Pifxley, P-Normal Pixley,
and Crabwell.)

Except where noted as being in the public domain, the source code files
in the Pixley project are distributed under a BSD license.

The latest released version of the Pixley language is 2.0.  For more
information on the language, reference implementation, and project, please
refer to [The Pixley Programming Language](doc/Pixley.markdown) document.

Development
-----------

Official release distfiles are available on the
[Pixley project page](http://catseye.tc/node/Pixley) at
[Cat's Eye Technologies](http://catseye.tc/).

The git repository for the reference distribution is
[available on Codeberg](https://codeberg.org/catseye/Pixley).

For a release history of the reference distribution, see
[HISTORY.md](HISTORY.md).
