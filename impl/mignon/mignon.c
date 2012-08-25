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
};

struct cons {
    enum vtype type; /* = V_CONS */
    struct value *head;
    struct value *tail;
};

struct atom {
    enum vtype type; /* = V_ATOM */
    char *string;
    struct atom *next;
};

struct lambda {
    enum vtype type; /* = V_LAMBDA */
    struct env *env;
    struct value *formals;
    struct value *body;
};

extern struct value *nil;

struct value *cons(struct value *, struct value *);
struct value *head(struct value *);
struct value *tail(struct value *);
struct value *atom(const char *);
int equal(struct value *, struct value *);
void dump(struct value *);

#endif /* !SEXP_H_ */
#ifndef EVAL_H_
#define EVAL_H_


struct env {
    struct atom *name;
    struct value *value;
    struct env *next;
};

struct value *lookup(struct env *, struct atom *);
struct env *bind(struct env *, struct atom *, struct value *);

struct value *eval(struct value *, struct env *);

#endif /* !EVAL_H_ */
#ifndef PARSE_H_
#define PARSE_H_


enum pstatus {
    P_START,  /* before we know if we have an atom or a list */
    P_ATOM,
    P_LIST,
    P_DONE
};

struct pstate { /* like ptarmigan, psychic, pshrimp... */
    /* where we are in the string */
    const char *ptr;
    /* for list: head of the list we are currently constructing */
    struct cons *head;
    /* for list: tail of the list we are currently constructing */
    struct cons *tail;
    /* for list: previous tail of the list (for linking up) */
    struct cons *prev;
    /* result of parsing so far in this level */
    struct value *result;
    /* result of what any child pstate parsed */
    struct value *child_result;
    /* where we are in the PDA's finite control, basically */
    enum pstatus status;
    /* to encode recursion */
    struct pstate *parent;
};

struct pstate *initial_pstate(const char *);
void dump_pstate(struct pstate *);
void parse(struct pstate *);
void parse_list(struct pstate *);
struct pstate *parse_resumable(struct pstate *);

#endif /* !PARSE_H_ */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* for interning */
struct atom *atom_list;

struct value *nil;

struct value *cons(struct value *h, struct value *t)
{
    struct cons *c = malloc(sizeof *c);
    c->type = V_CONS;
    c->head = h;
    c->tail = t;
    return (struct value *)c;
}

struct value *head(struct value *v)
{
    if (v->type != V_CONS) {
        printf("Cannot get the head of non-cons cell ");
        dump(v);
        printf("\n");
        exit(1);
    }
    return ((struct cons *)v)->head;
}

struct value *tail(struct value *v)
{
    if (v->type != V_CONS) {
        printf("Cannot get the tail of non-cons cell ");
        dump(v);
        printf("\n");
        exit(1);
    }
    return ((struct cons *)v)->tail;
}

struct value *atom(const char *s)
{
    struct atom *a;
    for (a = atom_list; a != NULL; a = a->next) {
        if (strcmp(a->string, s) == 0)
            break;
    }
    if (a == NULL) {
        a = malloc(sizeof *a);
        a->type = V_ATOM;
        a->string = malloc(strlen(s) + 1);
        strcpy(a->string, s);
        a->next = atom_list;
        atom_list = a;
    }
    return (struct value *)a;
}

int equal(struct value *a, struct value *b)
{
    if (a->type != b->type) {
        return 0;
    } else switch (a->type) {
        case V_ATOM:
            return a == b;
        case V_CONS:
            while (a->type == V_CONS && b->type == V_CONS) {
                if (!equal(head(a), head(b))) {
                    return 0;
                } else {
                    a = tail(a);
                    b = tail(b);
                }
            }
            return a == b;
        case V_LAMBDA:
            return 0;
    }
    return 0;
}

void dump(struct value *v)
{
    switch (v->type) {
        case V_CONS:
            printf("(");
            dump(((struct cons *)v)->head);
            printf(".");
            dump(((struct cons *)v)->tail);
            printf(")");
            break;
        case V_ATOM:
            printf("%s", ((struct atom *)v)->string);
            break;
        case V_LAMBDA:
            printf("(lambda ");
            dump(((struct lambda *)v)->formals);
            printf(" ");
            dump(((struct lambda *)v)->body);
            printf(")");
            break;
    }
}
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>


struct value *lookup(struct env *env, struct atom *name)
{
    for (; env != NULL; env = env->next) {
        if (env->name == name) {
            return env->value;
        }
    }
    return NULL;
}

struct env *bind(struct env *env, struct atom *name, struct value *value)
{
    struct env *e = malloc(sizeof *e);
    e->name = name;
    e->value = value;
    e->next = env;
    return e;
}

struct value *eval(struct value *sexp, struct env *env)
{
    struct value *cadr = atom("cadr");
    struct value *car = atom("car");
    struct value *cdr = atom("cdr");
    struct value *cond = atom("cond");
    struct value *cons_ = atom("cons");
    struct value *else_ = atom("else");
    struct value *equalp = atom("equal?");
    struct value *lambda = atom("lambda");
    struct value *let = atom("let*");
    struct value *listp = atom("list?");
    struct value *nullp = atom("null?");
    struct value *quote = atom("quote");
    struct value *truth = atom("#t");
    struct value *falsehood = atom("#f");

    if (sexp->type == V_ATOM) {
        struct atom *name = (struct atom *)sexp;
        struct value *value = lookup(env, name);
        if (value == NULL) {
            printf("Atom ");
            dump(sexp);
            printf(" has no meaning\n");
            exit(1);
        }
        return value;
    } else /* sexp->type == V_CONS) */ {
        struct value *h = head(sexp);
        struct value *t = tail(sexp);
        struct value *bound = lookup(env, (struct atom *)h);
        if (bound != NULL) {
            /* this could be SO much more efficient */
            struct value *newprog = cons(bound, t);
            return eval(newprog, env);
        } else if (h == cadr) {
            struct value *k = eval(head(t), env);
            return head(tail(k));
        } else if (h == car) {
            struct value *k = eval(head(t), env);
            return head(k);
        } else if (h == cdr) {
            struct value *k = eval(head(t), env);
            return tail(k);
        } else if (h == cond) {
            struct value *branch = head(t);
            /* this will error out with car(nil) if no 'else' in cond */
            while (1) {
                struct value *test = head(branch);
                struct value *expr = head(tail(branch));
                /*
                printf("branch: ");
                dump(branch);
                printf("\n");
                */                
                if (test == else_) {
                    return eval(expr, env);
                } else {
                    test = eval(test, env);
                    if (test != falsehood) {
                        return eval(expr, env);
                    }
                }
                t = tail(t);
                branch = head(t);
            }
            return nil;
        } else if (h == cons_) {
            struct value *j = eval(head(t), env);
            struct value *k = eval(head(tail(t)), env);
            return cons(j, k);
        } else if (h == equalp) {
            struct value *j = eval(head(t), env);
            struct value *k = eval(head(tail(t)), env);
            if (equal(j, k)) {
                return truth;
            } else {
                return falsehood;
            }
        } else if (h == lambda) {
            /* (lambda (a b c) (let ...)) */
            struct lambda *l = malloc(sizeof *l);
            l->type = V_LAMBDA;
            l->env = env;
            l->formals = head(t);
            l->body = head(tail(t));
            return (struct value *)l;
        } else if (h == let) {
            /* (let* ((a b) (c d)) body) */
            /* t = ( ((a b) (c d)) body) */
            /* head(t) = ((a b) (c d)) */
            /* tail(t) = (body) */
            struct value *pairs = head(t);
            struct value *body = head(tail(t));

            while (pairs != nil) {
                struct value *pair = head(pairs);
                struct value *name = head(pair);
                struct value *value = eval(head(tail(pair)), env);
                /*
                printf("let ");
                dump(name);
                printf(" = ");
                dump(value);
                printf("\n");
                */
                /* TODO: check that head(pair) is an atom! */
                env = bind(env, (struct atom *)name, value);
                pairs = tail(pairs);
            }
            /* TODO: free the no-longer-used parts of env */
            return eval(body, env);
        } else if (h == listp) {
            struct value *k = eval(head(t), env);
            if (k == nil || k->type == V_CONS) {
                return truth;
            } else {
                return falsehood;
            }
        } else if (h == nullp) {
            struct value *k = eval(head(t), env);
            if (k == nil) {
                return truth;
            } else {
                return falsehood;
            }
        } else if (h == quote) {
            return head(t);
        } else if (h->type == V_LAMBDA) {
            struct lambda *l = (struct lambda *)h;
            struct value *formals = l->formals;
            env = l->env;
            while (t->type == V_CONS) {
                struct value *formal = head(formals);
                struct value *value = eval(head(t), env);
                env = bind(env, (struct atom *)formal, value);
                formals = tail(formals);
                t = tail(t);
            }
            return eval(l->body, env);
            
            /*
                           (arg-vals    (interpret-args interpret-args args env))
                           (arg-env     (expand-args expand-args l->formals arg-vals))
                           (new-env     (concat-envs concat-envs arg-env l->closure-env)))
                      (interpret interpret body new-env)))
            */
            return head(t);
        } else {
            printf("Cannot evaluate ");
            dump(h);
            printf("\n");
            exit(1);
        }
    }
}
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>


struct pstate *initial_pstate(const char *string)
{
    struct pstate *state;
    state = malloc(sizeof(struct pstate));
    state->ptr = string;
    state->result = NULL;
    state->child_result = NULL;
    state->status = P_START;
    state->parent = NULL;
    return state;
}

static struct pstate *stack_pstate(struct pstate *parent)
{
    struct pstate *state;
    state = malloc(sizeof(struct pstate));
    state->ptr = parent->ptr;
    state->result = NULL;
    state->child_result = NULL;
    state->status = P_START;
    state->parent = parent;
    return state;
}

static struct pstate *unstack_pstate(struct pstate *state)
{
    struct pstate *parent = state->parent;
    parent->ptr = state->ptr;
    parent->child_result = state->result;
    free(state);
    return parent;
}

void dump_pstate(struct pstate *state)
{
    while (state != NULL) {
        fprintf(stderr, "{%s,%d}", state->ptr, state->status);
        state = state->parent;
    }
    fprintf(stderr, "!\n");
}

struct pstate *parse_resumable(struct pstate *state)
{
    int done = 0;
    while (!done) {
        /* dump_pstate(state); */
        switch (state->status) {
        case P_START:
          {
            while (isspace(*(state->ptr))) {
                state->ptr++;
            }
            if (*(state->ptr) == (char)0) {
                return state;
            }
            if (*(state->ptr) == '(') {
                state->ptr++;
                state->status = P_LIST;
                state->head = NULL;
                state->tail = NULL;
                state->prev = NULL;
            } else {
                state->status = P_ATOM;
            }
          }
          break;
        case P_ATOM:
          {
            char sym[128];
            int i = 0;
            while (isalpha(*(state->ptr)) ||
                   *(state->ptr) == '*' ||
                   *(state->ptr) == '-' ||
                   *(state->ptr) == '_' ||
                   *(state->ptr) == '?') {
                sym[i] = *(state->ptr);
                state->ptr++;
                i++;
            }
            sym[i] = 0;
            state->result = atom(sym);
            state->status = P_DONE;
            break;
          }
        case P_LIST:
          {
            /* if we just parsed a child of this list... */
            if (state->child_result != NULL) {
                state->tail = (struct cons *)cons(nil, nil);
                if (state->prev != NULL) {
                    state->prev->tail = (struct value *)state->tail;
                }
                if (state->head == NULL) {
                    state->head = state->tail;
                }
                state->tail->head = state->child_result;
                state->child_result = NULL;
                state->prev = state->tail;
            }
            while (isspace(*(state->ptr))) {
                state->ptr++;
            }
            if (*(state->ptr) == (char)0) {
                return state;
            }
            if (*(state->ptr) == ')') {
                state->ptr++;
                state->result = (struct value *)state->head;
                state->status = P_DONE;
                break;
            } else {
                /* create a new level in P_START. */
                state = stack_pstate(state);
            }
            break;
          }
        case P_DONE:
            if (state->parent != NULL) {
                state = unstack_pstate(state);
            } else {
                done = 1;
            }
            break;
        }
    }
    return state;
}
#include <stdio.h>
#include <stdlib.h>


int main(int argc, char **argv)
{
    struct pstate *state = initial_pstate(argv[1]);
    struct value *result;
    struct env *env = NULL;
    int done = 0;
    int argn = 1;

    nil = (struct value *)atom("nil");

    while (!done) {
        state = parse_resumable(state);
        /*dump_pstate(state);*/
        if (state->status == P_DONE) {
            printf("Program: ");
            dump(state->result);
            printf("\n");
            result = eval(state->result, env);
            printf("Result: ");
            dump(result);
            printf("\n");
            done = 1;
        } else {
            argn++;
            state->ptr = argv[argn];
        }
    }
    free(state);
    argc = argc;
    exit(0);
}
