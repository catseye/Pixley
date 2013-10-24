#include <stdio.h>
#include <stdlib.h>

#include "sexp.h"
#include "parse.h"
#include "eval.h"

int main(int argc, char **argv)
{
    struct pstate *state = initial_pstate(argv[1]);
    struct env *env = NULL;
    int done = 0;
    int argn = 1;

    nil = (struct value *)atom("()");

    while (!done) {
        state = parse_resumable(state);
#ifdef DEBUG
        dump_pstate(state);
#endif
        if (state->status == P_DONE) {
#ifdef DEBUG
            printf("Program: ");
            dump(state->result);
            printf("\n");
#endif
            dump(eval(state->result, env));
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
