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
    //printf("%s\n", msg);
    msg = msg;
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
                debug("V_ATOM");
                debug(((struct atom *)sexp)->string);
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
                debug("V_CONS");
                struct value *h = head(sexp);
                struct value *t = tail(sexp);
                struct value *bound = lookup(env, (struct atom *)h);
                if (bound != NULL) {
                    debug("*(bound)");
                    debug(((struct atom *)h)->string);
                    sexp = cons(bound, t); /* pair of a lambda and a list */
                    done = 0; /* "tail call" */
                } else if (h == cadr) {
                    debug("*cadr");
                    struct value *k = eval(head(t), env);
                    return head(tail(k));
                } else if (h == car) {
                    debug("*car");
                    struct value *k = eval(head(t), env);
                    return head(k);
                } else if (h == cdr) {
                    debug("*cdr");
                    struct value *k = eval(head(t), env);
                    return tail(k);
                } else if (h == cond) {
                    debug("*cond");
                    struct value *branch = head(t);
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
                    debug("*cons");
                    struct value *j = eval(head(t), env);
                    struct value *k = eval(head(tail(t)), env);
                    return cons(j, k);
                } else if (h == equalp) {
                    debug("*equalp");
                    struct value *j = eval(head(t), env);
                    struct value *k = eval(head(tail(t)), env);
                    if (equal(j, k)) {
                        return truth;
                    } else {
                        return falsehood;
                    }
                } else if (h == lambda_) {
                    debug("*lambda");
                    return lambda(env, head(t), head(tail(t)));
                } else if (h == let) {
                    debug("*let*");
                    struct value *pairs = head(t);
                    struct value *body = head(tail(t));

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
                    /* TODO: garbage collection plz */
                    /* return eval(body, env); */
                    /* XXX do we have to save env?? */
                    sexp = body;
                    done = 0; /* "tail call" */
                } else if (h == listp) {
                    debug("*list?");
                    struct value *k = eval(head(t), env);
                    while (k->type == V_CONS) {
                        k = tail(k);
                    }
                    if (k == nil) {
                        return truth;
                    } else {
                        return falsehood;
                    }
                } else if (h == nullp) {
                    debug("*null?");
                    struct value *k = eval(head(t), env);
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
                    debug("*(lambda)");
                    struct lambda *l = (struct lambda *)h;
                    struct value *formals = l->formals;
                    env = l->env; /* WHAAA? */
                    while (t->type == V_CONS) {
                        struct value *formal = head(formals);
                        struct value *value = eval(head(t), env);
                        env = bind(env, (struct atom *)formal, value);
                        formals = tail(formals);
                        t = tail(t);
                    }
                    /* XXX do we have to save env?? */
                    /* return eval(l->body, env); */
                    sexp = l->body;
                    done = 0; /* "tail call" */       
                } else {
                    debug("*(inner sexp)*");
                    struct value *k = eval(h, env);
                    struct value *m = cons(eval(k, env), t);
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

struct estate *push_estate(struct estate *parent, struct env *env, struct value *sexp)
{
    struct estate *estate = malloc(sizeof *estate);
    estate->status = E_START;
    estate->env = env;
    estate->sexp = sexp;
    estate->parent = parent;
    estate->aux = NULL;
    estate->result = NULL;
    printf("pushed. new estate sexp now: ");
    dump(estate->sexp);
    printf("\n");
    return estate;
}

struct estate *pop_estate(struct estate *estate)
{
    struct estate *parent = estate->parent;
    parent->result = estate->result;
    parent->env = estate->env; /* ? */
    free(estate);
    printf("popped. parent result now: ");
    dump(parent->result);
    printf("\n");
    return parent;
}

struct estate *eval_resumable(struct estate *estate)
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

    while (1) {
        switch (estate->status) {
            case E_START:
            {
                printf("start.  working on: ");
                dump(estate->sexp);
                printf("\n");
                switch (estate->sexp->type) {
                    case V_ATOM:
                    {
                        struct atom *name = (struct atom *)estate->sexp;
                        struct value *value = lookup(estate->env, name);
                        printf("lookuped!\n");
                        if (value == NULL) {
                            printf("Atom ");
                            dump(estate->sexp);
                            printf(" has no meaning\n");
                            exit(1);
                        }
                        printf("bound to value: ");
                        dump(value);
                        printf("\n");
                        estate->result = value;
                        estate->status = E_DONE;
                        break;
                    }
                    case V_CONS:
                    {
                        struct value *h = head(estate->sexp);
                        struct value *t = tail(estate->sexp);
                        struct value *bound = lookup(estate->env, (struct atom *)h);
                        if (bound != NULL) {
                            estate->sexp = cons(bound, t);
                            /* estate->status = E_START; */
                        } else if (h == cadr) {
                            estate->status = E_CADR;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == car) {
                            estate->status = E_CAR;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == cdr) {
                            estate->status = E_CDR;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == cond) {
                            struct value *branch = head(t);
                            struct value *test = head(branch);
                            struct value *expr = head(tail(branch));
                            if (test == else_) {
                                estate->sexp = expr;
                                /* estate->status = E_START; */
                            } else {
                                estate->status = E_COND;
                                estate->sexp = t; /* we will use sexp as a cursor here */
                                estate = push_estate(estate, estate->env, test);
                            }
                        } else if (h == cons_) {
                            estate->status = E_CONS_L;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == equalp) {
                            estate->status = E_EQUALP_L;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == lambda_) {
                            estate->result = lambda(estate->env, head(t), head(tail(t)));
                            estate->status = E_DONE;
                        } else if (h == let) {
                            struct value *pairs = head(t);
                            struct value *pair = head(pairs);
                            estate->status = E_LET;
                            estate->aux = head(tail(t)); /* stash body in aux */
                            estate->sexp = pairs; /* we use sexp as cursor over pairs */
                            estate = push_estate(estate, estate->env, head(tail(pair)));
                        } else if (h == listp) {
                            estate->status = E_LISTP;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == nullp) {
                            estate->status = E_NULLP;
                            estate = push_estate(estate, estate->env, head(t));
                        } else if (h == quote) {
                            estate->result = head(t);
                            estate->status = E_DONE;
                        } else if (h->type == V_LAMBDA) {
                            struct lambda *l = (struct lambda *)h;
                            estate->aux = l->body; /* stash lambda body in aux */
                            estate->formals = l->formals; /* stash formals in... formals */
                            estate->build = NULL;
                            if (t->type == V_CONS) {
                                estate->sexp = t; /* sexp is a cursor on actuals */
                                estate->status = E_LAMBDA;
                                estate = push_estate(estate, estate->env, head(t));
                            } else {
                                /* you just said "((lambda ...) . foo)" ! */
                                estate->result = nil;
                                estate->status = E_DONE;
                            }
                        } else {
                            printf("Cannot evaluate ");
                            dump(h);
                            printf("\n");
                            exit(1);
                        }
                        break;
                    }
                    case V_LAMBDA:
                    {
                        estate->status = E_DONE;
                        break;
                    }
                }
                break;
            }
            case E_CADR:
                estate->result = head(tail(estate->result));
                estate->status = E_DONE;
                break;
            case E_CAR:
                estate->result = head(estate->result);
                estate->status = E_DONE;
                break;
            case E_CDR:
                estate->result = tail(estate->result);
                estate->status = E_DONE;
                break;
            case E_COND:
            {
                if (estate->result != falsehood) {
                    estate->sexp = head(tail(head(estate->sexp)));
                    estate->status = E_START;
                } else {
                    struct value *branch, *test, *expr;
                    estate->sexp = tail(estate->sexp);
                    branch = head(estate->sexp);
                    test = head(branch);
                    expr = head(tail(branch));
                    if (test == else_) {
                        estate->sexp = expr;
                        estate->status = E_START;
                    } else {
                        estate->status = E_COND;
                        estate = push_estate(estate, estate->env, test);
                    }
                }
                break;
            }
            case E_CONS_L:
                /* estate->sexp will be the original (cons a b) sexp still */
                printf("e_cons_l. my sexp is: ");
                dump(estate->sexp);
                printf("\n");
                estate->aux = estate->result;
                estate->status = E_CONS_R;
                estate = push_estate(estate, estate->env, head(tail(tail(estate->sexp))));
                estate->status = E_START;
                break;
            case E_CONS_R:
                printf("e_cons_r. my sexp is: ");
                dump(estate->sexp);
                printf("\n");
                estate->result = cons(estate->aux, estate->result);
                estate->status = E_DONE;
                break;
            case E_EQUALP_L:
                /* estate->sexp will be the original (cons a b) sexp still */
                printf("e_equalp_l. my sexp is: ");
                dump(estate->sexp);
                printf("\n");
                estate->aux = estate->result;
                estate->status = E_EQUALP_R;
                estate = push_estate(estate, estate->env, head(tail(tail(estate->sexp))));
                estate->status = E_START;
                break;
            case E_EQUALP_R:
                printf("e_equalp_r. my sexp is: ");
                dump(estate->sexp);
                printf("\n");
                if (equal(estate->aux, estate->result)) {
                    estate->result = truth;
                } else {
                    estate->result = falsehood;
                }
                estate->status = E_DONE;
                break;
            case E_LAMBDA:
            {
                estate->build = bind(estate->build,
                                     (struct atom *)head(estate->formals),
                                     estate->result);
                estate->formals = tail(estate->formals);
                estate->sexp = tail(estate->sexp);
                if (estate->formals != nil) {
                    estate = push_estate(estate, estate->env, head(estate->sexp));
                } else {
                    estate->sexp = estate->aux; /* lambda body */
                    estate->env = estate->build;
                    estate->status = E_START;
                }
                break;
            }
            case E_LET:
                /* name is head(head(sexp)) */
                printf("e_let. my sexp is: ");
                dump(estate->sexp);
                printf("\n");
                estate->env = bind(estate->env,
                                   (struct atom *)head(head(estate->sexp)),
                                   estate->result);
                dump_env(estate->env);
                estate->sexp = tail(estate->sexp);
                printf("now my sexp is: ");
                dump(estate->sexp);
                printf("\n");
                if (estate->sexp != nil) {
                    struct value *pair = head(estate->sexp);
                    estate = push_estate(estate, estate->env, head(tail(pair)));
                } else {
                    estate->sexp = estate->aux;
                    estate->status = E_START;
                }
                break;
            case E_LISTP:
                if (estate->result == nil || estate->result->type == V_CONS) {
                    estate->result = truth;
                } else {
                    estate->result = falsehood;
                }
                estate->status = E_DONE;
                break;
            case E_NULLP:
                if (estate->result == nil) {
                    estate->result = truth;
                } else {
                    estate->result = falsehood;
                }
                estate->status = E_DONE;
                break;

            /* ... */
            case E_DONE:
                printf("done.  result was: ");
                dump(estate->result);
                printf("\n");
                if (estate->parent == NULL)
                    return estate;
                printf("popping...\n");
                estate = pop_estate(estate);
                break;
            default:
                /* ugh catchall for now */
                break;
        }
    }
    return estate;
}
