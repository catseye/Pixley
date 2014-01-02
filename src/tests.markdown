Test suite for our R5RS Pixley interpreter.
Chris Pressey, Cat's Eye Technologies.

    -> Tests for functionality "Interpret Pixley Program"

Constructing and Manipulating Data
----------------------------------

`quote` evaluates to literally what is in the head of the tail of
the cons cell whose head is `quote`.

    | (quote hello)
    = hello

    | (quote (quote quote))
    = (quote quote)

Atomic symbols may contain letters, `*`s, `?`s, and `-`s.

    | (quote abcdef-ghijklm*nopqrst?uvwxyz)
    = abcdef-ghijklm*nopqrst?uvwxyz

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

`equal?` works on symbols.

    | (cond (
    | (equal? (quote a) (quote a))
    |   (quote true)) (else (quote false)))
    = true

    | (cond (
    | (equal? (quote a) (quote b))
    |   (quote true)) (else (quote false)))
    = false

`equal?` works on lists.

    | (cond (
    | (equal? (quote (one (two three)))
    |         (cons (quote one) (quote ((two three)))))
    |   (quote true)) (else (quote false)))
    = true

A symbol is not a list.

    | (cond (
    | (list? (quote a))
    |   (quote true)) (else (quote false)))
    = false

A list whose final cons cell's tail contains a null, is a list.

    | (cond (
    | (list? (cons (quote a) (quote ())))
    |   (quote true)) (else (quote false)))
    = true

    | (cond (
    | (list? (quote (a b c d e f)))
    |   (quote true)) (else (quote false)))
    = true

A pair is not a list.

Actually, pairs aren't defined at all in Pixley, so I wouldn't
blame an implementation for just freaking out at this one.

    | (cond (
    | (list? (cons (quote a) (quote b)))
    |   (quote true)) (else (quote false)))
    = false

Booleans are not lists.

    | (cond (
    | (list? (equal? (quote a) (quote b)))
    |   (quote true)) (else (quote false)))
    = false

Lambda functions are not lists.

    | (cond (
    | (list? (lambda (x y) (y x)))
    |   (quote true)) (else (quote false)))
    = false

But the empty list is a list.

    | (cond (
    | (list? (quote ()))
    |   (quote true)) (else (quote false)))
    = true

    | (cond (
    | (list? (cdr (quote (foo))))
    |   (quote true)) (else (quote false)))
    = true

The empty list can be expressed as `(quote ())`.

    | (cond (
    | (equal? (cdr (quote (foo))) (quote ()))
    |   (quote true)) (else (quote false)))
    = true

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

`cond` works.

    | (let* ((true (equal? (quote a) (quote a))))
    |   (cond (true (quote hi)) (else (quote lo))))
    = hi

    | (let* ((true (equal? (quote a) (quote a)))
    |        (false (equal? (quote a) (quote b))))
    |   (cond (false (quote hi)) (true (quote med)) (else (quote lo))))
    = med

    | (let* ((true (equal? (quote a) (quote a)))
    |        (false (equal? (quote a) (quote b))))
    |   (cond (false (quote hi)) (false (quote med)) (else (quote lo))))
    = lo

`cond` can have zero tests before the `else`.

    | (cond (else (quote woo)))
    = woo

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

You can call a function with a bound name as its argument.

    | (let* ((interpret
    |         (lambda (program)
    |           (let* ((interpreter (quote z)))
    |             (cons interpreter program))))
    |        (sexp (quote (cdr (quote (one two three))))))
    |   (interpret sexp))
    = (z cdr (quote (one two three)))

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
