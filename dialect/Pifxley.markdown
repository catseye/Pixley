Test suite for the interpreter for Pifxley.
Chris Pressey, Cat's Eye Technologies.

    -> Tests for functionality "Interpret Pifxley Program"

Note: this file is just a copy of `src/tests.markdown` with the
tests for `cond` replaced with tests for `if`.  I should probably
do something better than that someday (and that applies to the whole
test system in the Pixley distribution.)

Constructing and Manipulating Data
----------------------------------

`quote` evaluates to literally what is in the head of the tail of
the cons cell whose head is `quote`.

    | (quote hello)
    = hello

    | (quote (foo bar))
    = (foo bar)

`cons` lets you create a list from some thing and another list.

    | (cons (quote thing) (quote (rest)))
    = (thing rest)

`car` extracts the head of a list.

    | (car (quote (foo bar)))
    = foo

`cdr` extracts the tail of a list.

    | (cdr (quote (foo bar)))
    = (bar)

Predicates and Types
--------------------

Because booleans don't actually have a defined representation in
Pixley, the next few tests are cheating a bit, relying on Scheme's
defined representation for booleans instead.  This would be easy
to fix up, but a bit tedious: just wrap each of these in

    (cond (... (quote true)) (else (quote false)))

`equal?` works on symbols.

    | (equal? (quote a) (quote a))
    = #t

    | (equal? (quote a) (quote b))
    = #f

`equal?` works on lists.

    | (equal? (quote (one (two three)))
    |         (cons (quote one) (quote ((two three)))))
    = #t

A symbol is not a list.

    | (list? (quote a))
    = #f

A list whose final cons cell's tail contains a null, is a list.

    | (list? (cons (quote a) (quote ())))
    = #t

    | (list? (quote (a b c d e f)))
    = #t

A pair is not a list.

Actually, pairs aren't defined at all in Pixley, so I wouldn't
blame an implementation for just freaking out at this one.

    | (list? (cons (quote a) (quote b)))
    = #f

Booleans are not lists.

    | (list? (equal? (quote a) (quote b)))
    = #f

Lambda functions are not lists.

    | (list? (lambda (x y) (y x)))
    = #f

But the empty list is a list.

    | (list? (quote ()))
    = #t

    | (list? (cdr (quote (foo))))
    = #t

The empty list can be expressed as `(quote ())`.

    | (equal? (cdr (quote (foo))) (quote ()))
    = #t

Binding to Names
----------------

`let*` lets you bind identifiers to values.  An identifier can be bound
to a symbol.

    | (let* ((a (quote hello))) a)
    = hello

`let*` can appear in the binding expression in a `let*`.

    | (let* ((a (let* ((b (quote c))) b))) a)
    = c

`let*` can bind a symbol to a function value.

    | (let* ((a (lambda (x y) (cons x y))))
    |       (a (quote foo) (quote ())))
    = (foo)

Bindings established in a binding in a `let*` can be seen in
subsequent bindings in the same `let*`.

    | (let* ((a (quote hello)) (b (cons a (quote ())))) b)
    = (hello)

Shadowing happens.

    | (let* ((a (quote hello))) (let* ((a (quote goodbye))) a))
    = goodbye

`let*` can have an empty list of bindings.

    | (let* () (quote hi))
    = hi

Decision-making
---------------

`if` works.

    | (let* ((true (equal? (quote a) (quote a))))
    |   (if true (quote hi) (quote lo)))
    = hi

    | (let* ((false (equal? (quote a) (quote b))))
    |   (if false (quote hi) (quote lo)))
    = lo

Functions
---------

You can define functions with `lambda`.  They can be anonymous.

    | ((lambda (a) a) (quote whee))
    = whee

Bindings in force when a function is defined will still be in force
when the function is applied, even if they are not lexically in scope.

    | ((let*
    |    ((a (quote (hi)))
    |     (f (lambda (x) (cons x a)))) f) (quote oh))
    = (oh hi)

Functions can take functions.

    | (let*
    |   ((apply (lambda (x) (x (quote a)))))
    |   (apply (lambda (r) (cons r (quote ()))))) 
    = (a)

Functions can return functions.

    | (let*
    |   ((mk (lambda (x) (lambda (y) (cons y x))))
    |    (mk2 (mk (quote (vindaloo)))))
    |   (mk2 (quote chicken)))
    = (chicken vindaloo)
