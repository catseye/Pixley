#ifndef EVAL_H_
#define EVAL_H_

#include "sexp.h"

struct env {
    struct atom *name;
    struct value *value;
    struct env *next;
};

enum estatus {
    E_START,
    E_CADR,
    E_CAR,
    E_CDR,
    E_COND,
    E_CONS_L,
    E_CONS_R,
    E_EQUALP_L,
    E_EQUALP_R,
    E_LET,
    E_LISTP,
    E_NULLP,
    E_LAMBDA,
    E_DONE
};

struct estate {
    enum estatus status;
    struct value *sexp;   /* the sexp we were working on */
    struct env *env;      /* the env we were working in */
    struct value *result; /* result we got from our child */
    struct value *aux;    /* an auxilliary value for 2-arg things */
    struct value *formals; /* for evaluating args to lambda */
    struct env *build;     /* for building env to evaluate lambda */
    struct estate *parent;
};

struct value *lookup(struct env *, struct atom *);
struct env *bind(struct env *, struct atom *, struct value *);

struct value *eval(struct value *, struct env *);
struct estate *eval_resumable(struct estate *);
struct estate *push_estate(struct estate *, struct env *, struct value *);
struct estate *pop_estate(struct estate *);

#endif /* !EVAL_H_ */
