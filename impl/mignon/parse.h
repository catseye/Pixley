#ifndef PARSE_H_
#define PARSE_H_

#include "sexp.h"

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
