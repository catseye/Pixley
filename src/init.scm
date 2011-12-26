; Mini-Scheme harness for our Meta-circular Pixley interpreter.
; November 2010, Chris Pressey, Cat's Eye Technologies.

; This is based on the init.scm that ships with Mini-Scheme; since
; the Mini-Scheme interpreter takes no command line arguments,
; this is the simplest way to start a Pixley environment in Mini-Scheme.
; Just start Mini-Scheme in the directory in which this file resides.

; This is a init file for Mini-Scheme.

;;;;; following part is written by a.k

;;;;    equal?
(define (equal? x y)
  (if (pair? x)
    (and (pair? y)
         (equal? (car x) (car y))
         (equal? (cdr x) (cdr y)))
    (and (not (pair? y))
         (eqv? x y))))

;;;;; following part is written by c.p.

(define (list? x) (or (eq? x '()) (pair? x)))

(define pixley-interpreter-sexp (quote
;----- Pixley interpreter begins -----
(lambda (interpret program env)
  (let*  ((cadr (lambda (alist)
            (car (cdr alist))))
          (null? (lambda (expr)
            (equal? expr (quote ()))))
          (find (lambda (self elem alist)
            (cond
              ((null? alist)
                (quote nothing))
              (else
                (let* ((entry (car alist))
                       (key   (car entry))
                       (rest  (cdr alist)))
                  (cond
                    ((equal? elem key)
                      entry)
                    (else
                      (self self elem rest))))))))
          (interpret-args (lambda (interpret-args args env)
            (cond
              ((null? args)
                args)
              (else
                (let* ((arg  (car args))
                       (rest (cdr args)))
                  (cons (interpret interpret arg env) (interpret-args interpret-args rest env)))))))
          (expand-args (lambda (expand-args formals argvals)
            (cond
              ((null? formals)
                formals)
              (else
                (let* ((formal       (car formals))
                       (rest-formals (cdr formals))
                       (argval       (car argvals))
                       (rest-argvals (cdr argvals)))
                  (cons (cons formal (cons argval (quote ()))) (expand-args expand-args rest-formals rest-argvals)))))))
          (concat-envs (lambda (concat-envs new-env old-env)
            (cond
              ((null? new-env)
                old-env)
              (else
                (let* ((entry (car new-env))
                       (rest  (cdr new-env)))
                  (cons entry (concat-envs concat-envs rest old-env)))))))
           (call-lambda (lambda (func args env)
             (let* ((arg-vals (interpret-args interpret-args args env)))
               (func arg-vals)))))
    (cond
      ((null? program)
        program)
      ((list? program)
        (let* ((tag   (car program))
               (args  (cdr program))
               (entry (find find tag env)))
          (cond
            ((list? entry)
              (call-lambda (cadr entry) args env))
            ((equal? tag (quote lambda))
              (let* ((formals (car args))
                     (body    (cadr args)))
                (lambda (arg-vals)
                  (let* ((arg-env   (expand-args expand-args formals arg-vals))
                         (new-env   (concat-envs concat-envs arg-env env)))
                    (interpret interpret body new-env)))))
            ((equal? tag (quote cond))
              (cond
                ((null? args)
                  args)
                (else
                  (let* ((branch   (car args))
                         (test     (car branch))
                         (expr     (cadr branch)))
                    (cond
                      ((equal? test (quote else))
                        (interpret interpret expr env))
                      (else
                        (cond
                          ((interpret interpret test env)
                            (interpret interpret expr env))
                          (else
                            (let* ((branches (cdr args))
                                   (newprog (cons (quote cond) branches)))
                              (interpret interpret newprog env))))))))))
            ((equal? tag (quote let*))
              (let* ((bindings (car args))
                     (body     (cadr args)))
                (cond
                  ((null? bindings)
                    (interpret interpret body env))
                  (else
                    (let* ((binding  (car bindings))
                           (rest     (cdr bindings))
                           (ident    (car binding))
                           (expr     (cadr binding))
                           (value    (interpret interpret expr env))
                           (new-bi   (cons ident (cons value (quote ()))))
                           (new-env  (cons new-bi env))
                           (newprog  (cons (quote let*) (cons rest (cons body (quote ()))))))
                      (interpret interpret newprog new-env))))))
            ((equal? tag (quote list?))
              (list? (interpret interpret (car args) env)))
            ((equal? tag (quote quote))
              (car args))
            ((equal? tag (quote car))
              (car (interpret interpret (car args) env)))
            ((equal? tag (quote cdr))
              (cdr (interpret interpret (car args) env)))
            ((equal? tag (quote cons))
              (cons (interpret interpret (car args) env) (interpret interpret (cadr args) env)))
            ((equal? tag (quote equal?))
              (equal? (interpret interpret (car args) env) (interpret interpret (cadr args) env)))
            ((null? tag)
              tag)
            ((list? tag)
              (call-lambda (interpret interpret tag env) args env))
            (else
              (call-lambda tag args env)))))
      (else
        (let* ((entry (find find program env)))
          (cond
            ((list? entry)
              (cadr entry))
            (else
              (quote illegal-program-error))))))))
;----- Pixley interpreter ends -----
))
(define interpret (eval pixley-interpreter-sexp))

(define subst
  (lambda (sexp src dest)
    (cond
      ((equal? sexp src)
        dest)
      ((null? sexp)
        '())
      ((list? sexp)
        (cons (subst (car sexp) src dest) (subst (cdr sexp) src dest)))
      (else
        sexp))))

(define wrap
  (lambda (interpreter program)
    (let* ((wrapper (quote
                      (let* ((interpreter 1)
                             (program (quote 2)))
                        (interpreter interpreter program '()))))
           (wrapper2 (subst wrapper 1 interpreter))
           (wrapper3 (subst wrapper2 2 program)))
      wrapper3)))

(define (pixley p)
  (interpret interpret p '()))

(define (pixley2 p)
  (interpret interpret (wrap pixley-interpreter-sexp p) '()))

(define (pixley3 p)
  (interpret interpret
    (wrap pixley-interpreter-sexp (wrap pixley-interpreter-sexp p)) '()))

(define (pixley4 p)
  (interpret interpret
    (wrap pixley-interpreter-sexp (wrap pixley-interpreter-sexp (wrap pixley-interpreter-sexp p))) '()))
