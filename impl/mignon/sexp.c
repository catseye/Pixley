#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sexp.h"

/* for interning */
struct atom *atom_list;

struct value *nil;

/* for gc */
struct value *chain = NULL;

struct value *cons(struct value *h, struct value *t)
{
    struct cons *c = malloc(sizeof *c);
    c->type = V_CONS;
    c->chain = chain;
    c->head = h;
    c->tail = t;
    chain = (struct value *)c;
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
        a->chain = NULL; /* atoms are not GC'ed */
        a->string = malloc(strlen(s) + 1);
        strcpy(a->string, s);
        a->next = atom_list;
        atom_list = a;
    }
    return (struct value *)a;
}

struct value *lambda(struct env *env, struct value *formals, struct value *body)
{
    struct lambda *l = malloc(sizeof *l);
    l->type = V_LAMBDA;
    l->chain = chain;
    l->env = env;
    l->formals = formals;
    l->body = body;
    chain = (struct value *)l;
    return (struct value *)l;
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
            while (v->type == V_CONS) {
                struct value *h = ((struct cons *)v)->head;
                struct value *t = ((struct cons *)v)->tail;
                dump(h);
                v = t;
                if (v->type == V_CONS) {
                    printf(" ");
                }
            }
            if (v != nil) {
                printf(" . ");
                dump(v);
            }
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
