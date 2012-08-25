#ifndef SEXP_H_
#define SEXP_H_

enum vtype {
    V_CONS,
    V_ATOM,
    V_LAMBDA
};

/*
 * Cast this to struct cons or struct atom after examining type.
 */
struct value {
    enum vtype type;
    struct value *chain; /* for garbage collection */
};

struct cons {
    enum vtype type; /* = V_CONS */
    struct value *chain; /* for garbage collection */
    struct value *head;
    struct value *tail;
};

struct atom {
    enum vtype type; /* = V_ATOM */
    struct value *chain; /* for garbage collection */
    char *string;
    struct atom *next;
};

struct lambda {
    enum vtype type; /* = V_LAMBDA */
    struct value *chain; /* for garbage collection */
    struct env *env;
    struct value *formals;
    struct value *body;
};

extern struct value *nil;

struct value *cons(struct value *, struct value *);
struct value *head(struct value *);
struct value *tail(struct value *);
struct value *atom(const char *);
struct value *lambda(struct env *, struct value *, struct value *);
int equal(struct value *, struct value *);
void dump(struct value *);

#endif /* !SEXP_H_ */
