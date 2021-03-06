P-Normal Pixley
===============

P-Normalization is a technique for simplifying Pixley programs.  It is
related to [A-Normalization](http://matt.might.net/articles/a-normalization/),
but quite a bit simpler.

A Pixley program is in P-Normal form if and only if:

* All `let*` forms bind a single expression to a single symbol; and
* All `cond` forms have a single test branch and a single `else` branch.

The Pixley 2.0 distribution contains a P-Normalizer, written in Pixley.
It converts arbitrary Pixley programs into P-Normal form.

Motivation
----------

There are several reasons why I wrote the P-Normalizer.

One was simply to write a non-trivial program in Pixley besides the Pixley
interpreter itself.

Another is that an implementer might find it easier to write an interpreter
or compiler for P-Normal Pixley; this gives them the option of P-Normalizing
the Pixley source before input.  Certainly, when I was implementing Pixley
in C (for AmigaOS 1.3), I would have found the continuation code easier to
formulate if the input program was in P-Normal form.

Yet another is to effectively criticize the design choice of putting `let*`
and `cond` in Pixley, instead of `let` and `if`.  My belief is that, if only
these simpler forms were included in Pixley, the Pixley interpreter would be
larger.  P-Normalizing the interpreter, then (as a trivial second step),
converting the P-Normal `let*`s and `cond`s to `let`s and `if`s, would allow
one to check this belief -- however, I have not gotten so far as to actually
do that, yet.

And the last reason I will mention here is that it is a step towards true
A-Normalization of Pixley programs.  This would be useful for my purposes,
as one of my long-held goals for Pixley was to write a totality checker for
Pixley programs, in Pixley, much as I have done in the past with Scheme.

However, useful A-Normalization requires that non-trivial expressions
(such as calls to defined functions) occur let-bound in other expressions.
For example, the first element of a list which represents a function
application must be a symbol which is bound to the lambda being applied,
rather than a literal lambda.  Pixley is not really capable of converting
expressions to such a form, because it lacks the ability to create new
symbols.

There are a couple of ways around this, but they each have drawbacks.

The normalizer could be supplied with a list of symbols to be used during
bound-conversion, but the user would need to provide a sufficient supply
of symbols, and ensure that they don't clash with symbols in the program.

Or, a creative bending of the language could allow expressions to be bound
to, not just symbols, but entire S-expressions, which we could generate in
an infinite supply.  While the resulting program could, e.g., be statically
analyzed for totality, it would not be a Pixley program (because Scheme
doesn't allow that kind of binding.)

Or, instead of converting to normal form, the program could simply check
the input Pixley program and evaluate to a boolean indicating whether the
program is in normal form or not.  However, this would offload the work of
doing the actual conversion to programmer, which is less than ideal.

Or, the normalizer could be written in some language besides Pixley, but
given Pixley's "bootstrappability" roots, I'm not even going to consider
that unless all else fails.

The thing is, I haven't decided how to approach the problem yet, so I will
save "P-Normalization 2.0" for a later date.  (Although, now that I've
wriiten them all out, option #2 seems most appealing.)

Tests for the P-Normalizer
--------------------------

    -> Tests for functionality "P-Normalize Pixley Program"

    -> Functionality "P-Normalize Pixley Program" is implemented by
    -> shell command "script/tower.sh src/pixley.pix dialect/p-normal.pix %(test-body-file)"

`let*` gets expanded into a series of nested, one-binding, `let*`s.

    | (let* ((a (quote a)) (b (quote b))) (cons a b))
    = (let* ((a (quote a))) (let* ((b (quote b))) (cons a b)))

`cond` gets expanded into a series of nested, one-test, `cond`s.

    | (cond ((equal? a b) a) ((equal? b c) b) (else c))
    = (cond ((equal? a b) a) (else (cond ((equal? b c) b) (else c))))

Expressions in a `let*` binding get P-Normalized.

    | (let* ((g (let* ((a (quote a)) (b (quote b))) (cons a b)))) g)
    = (let* ((g (let* ((a (quote a))) (let* ((b (quote b))) (cons a b))))) g)

Expressions in a `let*` body get P-Normalized.

    | (let* ((c (quote c)))
    |        (car (let* ((a (quote a)) (b (quote b))) (cons a b))))
    = (let* ((c (quote c))) (car (let* ((a (quote a))) (let* ((b (quote b))) (cons a b)))))

Expressions in a `cond` test get P-Normalized.

    | (cond
    |   ((eq? (let* ((a (quote a)) (b (quote b))) a) (quote a))
    |    (quote yes))
    |   (else
    |    (quote no)))
    = (cond ((eq? (let* ((a (quote a))) (let* ((b (quote b))) a)) (quote a)) (quote yes)) (else (quote no)))

Expressions in a `cond` branch get P-Normalized.

    | (cond
    |   ((eq? (quote a) (quote a))
    |    (let* ((a (quote a)) (yes (quote b))) yes))
    |   (else
    |    (quote no)))
    = (cond ((eq? (quote a) (quote a)) (let* ((a (quote a))) (let* ((yes (quote b))) yes))) (else (quote no)))

Expressions in a `cons` get P-Normalized.

    | (cons (quote x) (let* ((a (quote a)) (b (quote b))) (cons a b)))
    = (cons (quote x) (let* ((a (quote a))) (let* ((b (quote b))) (cons a b))))

Expressions in a `car` get P-Normalized.

    | (car (let* ((a (quote a)) (b (quote b))) (cons a b)))
    = (car (let* ((a (quote a))) (let* ((b (quote b))) (cons a b))))

Expressions in a `cdr` get P-Normalized.

    | (cdr (let* ((a (quote a)) (b (quote b))) (cons a b)))
    = (cdr (let* ((a (quote a))) (let* ((b (quote b))) (cons a b))))

Expressions in a `list?` get P-Normalized.

    | (list? (let* ((a (quote a)) (b (quote b))) (cons a b)))
    = (list? (let* ((a (quote a))) (let* ((b (quote b))) (cons a b))))

Expressions in a `quote` do *not* get P-Normalized.

    | (quote (let* ((a (quote a)) (b (quote b))) (cons a b)))
    = (quote (let* ((a (quote a)) (b (quote b))) (cons a b)))

Expressions in a `lambda` body get P-Normalized.

    | (let* ((a (lambda (x) (let* ((r (quote r)) (p (quote p))) x))))
    |   (a (quote d)))
    = (let* ((a (lambda (x) (let* ((r (quote r))) (let* ((p (quote p))) x))))) (a (quote d)))

Arguments of a function application get P-Normalized.

    | (let* ((f (lambda (x) x)))
    |        (f (let* ((a (quote a)) (b (quote b))) (cons a b))))
    = (let* ((f (lambda (x) x))) (f (let* ((a (quote a))) (let* ((b (quote b))) (cons a b)))))
