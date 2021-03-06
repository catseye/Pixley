The Pixley Programming Language
===============================

Language version 2.0

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

Note that this is only the history of the programming language itself; for
history of its reference distribution, see [HISTORY.md](../HISTORY.md).

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

### Pixley 2.0 ###

As previously mentioned, Pixley 2.0 removes the `cadr` and `null?`
functions from the language.

Conclusion
----------

The last main division of a discourse, usually containing a summing up of
the points and a statement of opinion or decisions reached.

Keep Smiling!  (I could never stand those "Home Sweet Home" folks.)  
Chris Pressey  
February 19th, 2012  
Evanston, Illinois
