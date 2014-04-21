#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "parse.h"
#include "sexp.h"

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
#ifdef DEBUG
        dump_pstate(state);
#endif
        switch (state->status) {
            case P_START:
            {
                while (isspace((int)*(state->ptr))) {
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
                break;
            }
            case P_ATOM:
            {
                char sym[128];
                int i = 0;
                while (isalpha((int)*(state->ptr)) ||
                       isdigit((int)*(state->ptr)) ||
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
                while (isspace((int)*(state->ptr))) {
                    state->ptr++;
                }
                if (*(state->ptr) == (char)0) {
                    return state;
                }
                if (*(state->ptr) == ')') {
                    state->ptr++;
                    if (state->head == NULL) {
                        state->result = nil;
                    } else {
                        state->result = (struct value *)state->head;
                    }
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
