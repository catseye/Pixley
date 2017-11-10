examplePrograms = [
    [
        "cons-test.pix", 
        "(cons (quote a) (cons (quote b) (quote ())))\n"
    ], 
    [
        "equality-test.pix", 
        "(equal? (quote foo) (quote foo))\n"
    ], 
    [
        "list-test.pix", 
        "(list? (quote foo))\n"
    ], 
    [
        "binding-test-1.pix", 
        "(let* ((a (quote b)) (c (quote d))) (cons a (cons c ())))\n"
    ], 
    [
        "binding-test-2.pix", 
        "(let* ((a (let* ((b (quote c))) b))) a)\n"
    ], 
    [
        "binding-test-3.pix", 
        "(let* ((a (lambda (x y) (cons x (cons y ()))))) (a (quote foo) (quote bar)))\n"
    ], 
    [
        "cond-test-1.pix", 
        "(cond\n  ((equal? (quote b) (quote r)) (quote foo))\n  (else (quote bar)))\n"
    ], 
    [
        "cond-test-2.pix", 
        "(cond\n  ((equal? (quote b) (quote r)) (quote foo))\n  ((equal? (quote b) (quote b)) (quote blah))\n  (else (quote bar)))\n"
    ], 
    [
        "lambda-test.pix", 
        "(let*\n  ((pair (lambda (x) (cons x (cons x ())))))\n    (pair (quote (hi there))))\n"
    ]
];
