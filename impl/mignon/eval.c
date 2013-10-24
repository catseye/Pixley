#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "sexp.h"
#include "eval.h"

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

#ifdef DEBUG
static void dump_env(struct env *env)
{
    printf("env: {\n");
    while (env != NULL) {
        printf("  %s = ", env->name->string);
        dump(env->value);
        printf(";\n");
        env = env->next;
    }
    printf("}\n");
}

static void debug(const char *msg)
{
    printf("%s\n", msg);
    msg = msg;
}
#else
#define debug(x)
#endif

struct value *eval(struct value *sexp, struct env *env)
{
    struct value *cadr = atom("cadr");
    struct value *car = atom("car");
    struct value *cdr = atom("cdr");
    struct value *cond = atom("cond");
    struct value *cons_ = atom("cons");
    struct value *else_ = atom("else");
    struct value *equalp = atom("equal?");
    struct value *lambda_ = atom("lambda");
    struct value *let = atom("let*");
    struct value *listp = atom("list?");
    struct value *nullp = atom("null?");
    struct value *quote = atom("quote");
    struct value *truth = atom("#t");
    struct value *falsehood = atom("#f");

    int done = 0;
    while (!done) {
        done = 1;
        switch (sexp->type) {
            case V_ATOM:
            {
                struct atom *name = (struct atom *)sexp;
                struct value *value = lookup(env, name);
                if (value == NULL) {
                    printf("Atom ");
                    dump(sexp);
                    printf(" has no meaning\n");
                    exit(1);
                }
                return value;
            }
            case V_CONS:
            {
                struct value *h = head(sexp);
                struct value *t = tail(sexp);
                struct value *bound = lookup(env, (struct atom *)h);
                debug("V_CONS");
                if (bound != NULL) {
                    debug("*(bound)");
                    debug(((struct atom *)h)->string);
                    sexp = cons(bound, t); /* pair of a lambda and a list */
                    done = 0; /* "tail call" */
                } else if (h == cadr) {
                    struct value *k = eval(head(t), env);
                    debug("*cadr");
                    return head(tail(k));
                } else if (h == car) {
                    struct value *k = eval(head(t), env);
                    debug("*car");
                    return head(k);
                } else if (h == cdr) {
                    struct value *k = eval(head(t), env);
                    debug("*cdr");
                    return tail(k);
                } else if (h == cond) {
                    struct value *branch = head(t);
                    debug("*cond");
                    /* this will error out with car(nil) if no 'else' in cond */
                    while (done) {
                        struct value *test = head(branch);
                        struct value *expr = head(tail(branch));
                        if (test == else_) {
                            sexp = expr;
                            done = 0; /* "tail call" */
                        } else {
                            test = eval(test, env);
                            if (test != falsehood) {
                                sexp = expr;
                                done = 0; /* "tail call" */
                            } else {
                                t = tail(t);
                                branch = head(t);
                            }
                        }
                    }
                } else if (h == cons_) {
                    struct value *j = eval(head(t), env);
                    struct value *k = eval(head(tail(t)), env);
                    debug("*cons");
                    return cons(j, k);
                } else if (h == equalp) {
                    struct value *j = eval(head(t), env);
                    struct value *k = eval(head(tail(t)), env);
                    debug("*equalp");
                    if (equal(j, k)) {
                        return truth;
                    } else {
                        return falsehood;
                    }
                } else if (h == lambda_) {
                    debug("*lambda");
                    return lambda(env, head(t), head(tail(t)));
                } else if (h == let) {
                    struct value *pairs = head(t);
                    struct value *body = head(tail(t));
                    debug("*let*");
                    while (pairs != nil) {
                        struct value *pair = head(pairs);
                        struct value *name = head(pair);
                        struct value *value = eval(head(tail(pair)), env);
                        /* TODO: check that head(pair) is an atom! */
                        debug("binding");
                        debug(((struct atom *)name)->string);
                        env = bind(env, (struct atom *)name, value);
                        pairs = tail(pairs);
                    }
#ifdef DEBUG
                    dump_env(env);
#endif
                    sexp = body;
                    done = 0; /* "tail call" */
                } else if (h == listp) {
                    struct value *k = eval(head(t), env);
                    debug("*list?");
                    while (k->type == V_CONS) {
                        k = tail(k);
                    }
                    if (k == nil) {
                        return truth;
                    } else {
                        return falsehood;
                    }
                } else if (h == nullp) {
                    struct value *k = eval(head(t), env);
                    debug("*null?");
                    if (k == nil) {
                        return truth;
                    } else {
                        return falsehood;
                    }
                } else if (h == quote) {
                    debug("*quote");
                    if (t == nil)
                        return t;
                    return head(t);
                } else if (h->type == V_LAMBDA) {
                    struct lambda *l = (struct lambda *)h;
                    struct value *formals = l->formals;
                    struct env *l_env = l->env;
                    debug("*(lambda)");
                    while (t->type == V_CONS) {
                        struct value *formal = head(formals);
                        struct value *value = eval(head(t), env);
                        l_env = bind(l_env, (struct atom *)formal, value);
                        formals = tail(formals);
                        t = tail(t);
                    }
                    env = l_env;
                    sexp = l->body;
                    done = 0; /* "tail call" */       
                } else {
                    struct value *k = eval(h, env);
                    struct value *m = cons(eval(k, env), t);
                    debug("*(inner sexp)*");
                    return eval(m, env);
                }
                break;
            }
            case V_LAMBDA:
            {
                debug("V_LAMBDA\n");
                return sexp;
            }
        }
    }
    return sexp;
}
