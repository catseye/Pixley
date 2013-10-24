#ifndef EVAL_H_
#define EVAL_H_

#include "sexp.h"

struct env {
    struct atom *name;
    struct value *value;
    struct env *next;
};

struct value *lookup(struct env *, struct atom *);
struct env *bind(struct env *, struct atom *, struct value *);
struct value *eval(struct value *, struct env *);

#endif /* !EVAL_H_ */
