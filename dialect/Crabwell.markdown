Test suite for Crabwell.
Chris Pressey, Cat's Eye Technologies.

    -> Tests for functionality "Interpret Crabwell Program"

    | (let* (((a b) (quote c))) (symbol (a b)))
    = c

    | (let* (((a b) (lambda (x) (cons x (quote ()))))) ((symbol (a b)) (quote r)))
    = (r)
