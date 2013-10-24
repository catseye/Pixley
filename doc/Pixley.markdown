The Pixley Programming Language
===============================

Language version 2.0, distribution revision 2013.1025-pre

Introduction
------------

*Pixley* is a strict and purely functional subset of R5RS Scheme.
All Pixley programs are also therefore Scheme programs.

Pixley was designed for "bootstrappability".  I aimed to encompass a
minimal subset of Scheme that was still expressive enough to
permit writing a Pixley interpreter without too much pain.

Semantics
---------

Pixley implements the following functions and forms from Scheme
(listed in alphabetical order):

* `car`
* `cdr`
* `cond` / `else`
* `cons`
* `equal?`
* `lambda`
* `let*`
* `list?`
* `quote`

For the precise meanings of each of these forms, please refer to the
Revised^5^ Report on the Algorithmic Language Scheme.

Pixley only understands the Scheme datatypes of lists, symbols, function
values (lambdas), and booleans.  Pixley's behaviour regarding any attempt
to produce a value of any other type is undefined.  Neither is its
behaviour defined for s-expressions which result in errors when evaluated
as Scheme programs.

Syntax
------

Pixley's syntax is a strict subset of Scheme's.  The meanings of
syntactical constructs which are valid in Scheme but not defined in Pixley
(such as numbers, strings, comments, quasiquoting, or hygienic macros) are
undefined.

Of literal values, only those of list type can be directly introduced
through syntactical elements.  Like Scheme, a literal null list can be
denoted by `(quote ())`.  (However, `()` by itself is considered to be an
illegal, empty application.)  Literal symbols may be introduced through
the `quote` form, literal function values can be produced through the
`lambda` form, and the two boolean values can be produced through the use
of trivial tests such as `(equal? (quote ()) (quote ()))` and
`(equal? (quote a) (quote b))`.  (Note however that Pixley's test suite
does generally require a Pixley implementation to be able to *depict*
truth and falsehood in the output as `#t` and `#f`, respectively.)

Reference Implementation
------------------------

The reference implementation of Pixley, `pixley.pix`, is written in 124
lines of Pixley (or, if you prefer, 124 lines of Scheme; and if you prefer
more Scheme-ly metrics, it consists of 413 instances of 54 unique symbols
in 684 cons cells.)

`pixley.pix` does not include a lexical processor: the Pixley program to
be interpreted must be made available to the interpreter as a native
s-expression.  Since Pixley does not implement `define`, this is usually
achieved by applying a textual copy of `pixley.pix` (a `lambda` expression)
to the s-expression to be interpreted as a Pixley program.

Because `pixley.pix` is written in Pixley, multiple copies can be applied
successively with equivalent semantics.  For example, having `pixley.pix`
interpret some program `foo.pix` should produce the same observable
behaviour (modulo performance) as having `pixley.pix` interpret `pixley.pix`
interpreting `foo.pix`, or having `pixley.pix` interpret `pixley.pix`
interpret `pixley.pix` interpreting `foo.pix`, etc. etc. ad infinitum.
The test suite for the Pixley reference interpreter does just that,
running through the set of tests at successively higher "degrees".
This is an example of a *computational automorphism* and is a property of
any bootstrapped universal computer (or rather, of the Turing-complete
language of that computer.)

The Pixley reference interpreter is highly meta-circular, implementing
e.g. Pixley's `car` simply in terms of the underlying Pixley (or Scheme)
`car`.  The datatypes of Pixley are likewise directly represented by the
corresponding datatypes in the underlying language.

Environments are represented as lists similar to association lists,
except containing two-element sublists instead of pairs, because Pixley
can't directly represent pairs.  Each sublist's first element is a symbol
naming the identifier, and the second is the value to which it is bound.

History
-------

### Pixley 1.0 ###

Pixley 1.0 was released on May 1st, 2009, from Cupertino, California.

In addition to the 10 Scheme symbols listed above, Pixley 1.x also
implemented the Scheme functions `cadr` and `null?`.  However, it was
found that the interpreter was actually shorter if those functions were
defined only locally within the interpreter.  They were thus removed from
the Pixley language in version 2.0.  It is easy enough to apply the same
technique to any Pixley 1.x program to convert it to Pixley 2.0; simply
wrap it in the following:

    (let* ((cadr (lambda (alist)
             (car (cdr alist))))
           (null? (lambda (expr)
             (equal? expr (quote ())))))
      ...)

### Pixley v1.1 ###

Pixley 1.1 was released on November 5th, 2010, from Evanston, Illinois.

Funny story!  So I was writing writing stuff in C to compile with DICE C
under AmigaOS 1.3, right?  And I was looking for something to write, and I
decided to implement Pixley in C.  And that was going pretty well; as I was
implementing each command, I was making up ad-hoc test cases for it, and I
was thinking "Hey, I should record these somewhere and make a test suite for
the Pixley reference distribution!"  Of course, I never did record those
cases, but in the following weeks I started doing various other things with
the Pixley project, and at one point, decided anew that it would be a good
idea to bulk up the test cases.

So I started writing more test cases, right?  And I got to testing `list?`.
Well, `(list? (lambda (x) x))` should be *false*, right?  Sure.  Except it
wasn't.

Well, I went to the docs and saw that there was an easy explanation for this.
This was for Pixley 1.0, mind you, and they've changed since then, but they
told me that:

> Some places where the underlying and interpreted representations must
> differ are in the data types, namely lists and lambda functions.

> Each interpreted list is represented as a two-element underlying list.
> The first element is the atom `__list__` and the second element is the
> (interpreted) list itself.

> Each interpreted lambda function is represented by an underlying list
> of four elements: the atom `__lambda__`, a representation of the enclosing
> environment, a list of the formal arguments of the function, and the
> (interpreted) body of the function.

In other words, in the reference interpreter, both lists and function values
are represented with lists; you tell them apart by looking at the first
element, which is `__lambda__` for a function value and `__list__` for a list.
And `list?` was probably just looking at the representation list and not
checking the first element, right?  Sure.  Except, no, it was much more.

It turns out that while function values were in fact represented by lists
with `__lambda__` as the first element, lists were just represented by lists.
Which means that there was an overlap between the types: a function value was,
at the Pixley level, a kind of list, and could be treated just like one, for
example with `car` and `cdr`.  This is clearly not kosher R5RS, which has
a whole *section* titled "Disjointness of types".  (Of course, neither "list"
nor "function value" is mentioned in that section, but I'd say the spirit of
the law is pretty clear there or whatever.)

So this meant I had to fix the Pixley interpreter! But first, I had to make a
decision: how to represent lists?  Well, there were two general paths here:
more meta-circular, or less.  I could make the implementation conform to the
documentation, making it less meta-circular, but then I'd have to be changing
everything that built (or touched) a list to build (or check for) a list with
`__list__` at its head.  Doable, but kind of distasteful.  Alternatively, I
could make it more meta-circular: keep lists represented as lists, and
go one further by representing function values as function values.  This is a
little unilluminating, as it no longer lays bare how function values work;
but this is made up for by the fact that most of the mechanics have to
continue to exist in the implementation (just in different places) and there
is a modest savings of space (because we can fall back on the implementing
language's semantics for cases like trying to execute a non-function.)
So that's what I did.

Now, this technically changed the semantics of the language, because gosh
you *could* have been relying on the fact that `(car (lambda (x) x))`
evaluates to `__lambda__`, in your Pixley programs, and we can't have that,
can we?  So the language version was bumped up to 1.1.

#### Goodies ####

The Pixley 1.1 distribution also included the following supplementary
material:

* An enlarged test suite (previously mentioned).
* A REPL (read-eval-print loop, or "interactive mode" interpreter), written
  in Scheme.
* A statistics generator, written in Scheme, which counts the cons cells,
  symbol instances, and unique symbols present in a given s-expression.
  This was to measure the complexity of the Pixley interpreter.
* A Mini-Scheme driver.  During my adventures in getting programs to run
  under AmigaOS 1.3, I compiled Mini-Scheme thereunder, and got Pixley to
  run under it by including the Pixley interpreter in Mini-Scheme's
  `init.scm` file and invoking it therein.  From this I conclude that,
  although I have not confirmed this is in a solid way by looking at the
  spec or anything, Pixley is also a strict subset of R4RS Scheme.

### Pixley 2.0 ###

As previously mentioned, Pixley 2.0 removes the `cadr` and `null?`
functions from the language.

#### Goodies ####

The Pixley 2.0 distribution also includes the following supplementary
material:

* Bourne Shell scripts to run Pixley programs which are stored in individual
  files.  `pixley.sh` runs either a self-contained Pixley program from a
  single file, or evaluates a Pixley file to a function value and applies it
  to an S-expression stored in a second file.  `scheme.sh` does the same
  thing, but with Scheme, as a sanity-check.  By default these scripts use
  `plt-r5rs` for the Scheme interpreter, but that can be changed with an
  environment variable.
* A P-Normalizer written in Pixley, probably the first non-trivial Pixley
  program to be written, aside from the Pixley interpreter itself.  P-Normal
  Pixley is a simplified version of Pixley where `let*` can only bind one
  identifer to one value and `cond` can only make one test, like Scheme's
  `if`.  This form is described more fully in the [Falderal literate test
  suite for the P-Normalizer](../dialect/P-Normal.markdown).
* Test suites, written in Falderal, for both Pixley and the P-Normalizer.
  The original test suite written in Scheme, which runs successively deeper
  nested copies of the Pixley interpreter, is still included in the
  distribution.
* A few other standalone Pixley examples, including `reverse.pix`,
  which reverses the given list.

### Pixley 2.0 revision 2012.0219 ###

While there were no changes to the language in revision 2012.0219, this is
a fairly major revision to the Pixley distribution, so let's list what's
new in it here.

* The Bourne shell scripts `pixley.sh` and `scheme.sh` were replaced by a
  single script `tower.sh`.  The idea behind this script is that it lets
  you constuct a "tower of interpreters" from a sequence of text files
  which contain S-expressions.  The first such S-expression is interpreted
  as Scheme, and may evaluate to a function value; the second such will be
  interpreted by that function, and may evaluate to another function value,
  and so forth, until there is an S-expression that evaluates to something
  besides a function value (and that result will be printed to standard
  output and `tower.sh` will terminate.)

* `tower.sh` officially supports three implementations of Scheme that can
  be used as the base interpreter: `plt-r5rs` from the Racket distribution,
  `tinyscheme`, and `miniscm` version 0.85p1 (from our fork of the project
  on GitHub.)  Support for Scheme implementations is (more or less)
  capability-based, so adding support for other implementations should not
  be difficult (especially if they are similar to the three already
  supported.)

* The test suite was put into Falderal 0.6 format and now uses `tower.sh`
  to run each test case.  By default, it uses `plt-r5rs`, but can be told
  to use any of the Scheme implementations that `tower.sh` supports.
  (Note: there is currently a failure when running one of the tests on a
  Pixley interpreter on a Pixley interpreter on `miniscm` that I have yet
  to track down.)

* To match the expectations of `tower.sh`, the Pixley self-interpreter was
  refactored to evaluate to a function value of one argument.  It was also
  simplified slightly, removing an unnecessary nested `cond`.

* Various dialects of Pixley have been defined and described, and collected
  in the `dialect` directory of the distribution.  The dialects include
  Pifxley, which supports an `if` construct instead of `cond`; there is a
  Pixley interpreter written in Pifxley, and a Pifxley self-interpreter.
  There is also a dialect called Crabwell which allows values to be bound
  to, not just symbols, but arbitrary S-expressions.

* A bug (a missing case) was fixed in the P-Normalizer.

* The main Pixley documentation (what you're reading now) was converted
  to Markdown format.

* Source code in the Pixley distribution was placed under a BSD-style
  license.

### Pixley 2.0 revision 2013.1025 ###

While there were no changes to the language in revision 2013.1025, some
interesting stuff was added to the Pixley distribution, so let's list what's
new in it here.

* Funny story!  Remember when I said I was writing writing stuff in C to
  compile with DICE C under AmigaOS 1.3, and that what I decided to write
  was a Pixley interpreter in C?  Well, that implementation of Pixley,
  called `mignon`, has finally been included in the Pixley distribution.

* Another implementation of Pixley, this time in Haskell and called `haney`,
  has also been included in the Pixley distribution.

* The `tower.sh` script has been refactored, since honestly it was kind of
  grody.  The abstraction layer which tries to make different implementations
  of Scheme behave the same has been split off into `scheme-adapter.sh`,
  while the responsibility of `tower.sh` itself is only to build and run the
  tower of interpreters.  In addition to `plt-r5rs`, Mini-Scheme, and
  Tinyscheme, `scheme-adapter.sh` also supports the Husk Scheme interpreter.
  Finally, `scheme-adapter.sh` supports `mignon` and `haney` as well; even
  though they're not proper Scheme interpreters, they can be used as the
  base interpreter for a tower of Pixley interpreters.

* The test suite has been modernized (for whatever "modern" means for
  Falderal) and enriched to handle testing these extra implementations.

Conclusion
----------

The last main division of a discourse, usually containing a summing up of
the points and a statement of opinion or decisions reached.

Keep Smiling!  (I could never stand those "Home Sweet Home" folks.)  
Chris Pressey  
February 19th, 2012  
Evanston, Illinois
