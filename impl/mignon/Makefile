# GNU Makefile for mignon.
# $Id: Makefile 658 2010-07-21 17:33:26Z cpressey $

PROG=mignon
CC?=gcc
STRIP?=strip
O?=.o
EXE?=

WARNS=	-Werror -W -Wall -Wstrict-prototypes -Wmissing-prototypes \
	-Wpointer-arith	-Wno-uninitialized -Wreturn-type -Wcast-qual \
	-Wwrite-strings -Wswitch -Wshadow -Wcast-align -Wchar-subscripts \
	-Winline -Wnested-externs -Wredundant-decls

ifdef ANSI
  CFLAGS+= -ansi -pedantic
else
  CFLAGS+= -std=c99 -D_POSIX_C_SOURCE=200112L
endif

CFLAGS+= ${WARNS} ${EXTRA_CFLAGS}

ifdef DEBUG
  CFLAGS+= -g
endif

OBJS=	sexp${O} parse${O} eval${O} main${O}

all: ${PROG}${EXE}

${PROG}${EXE}: $(OBJS)
	$(CC) $(OBJS) -o ${PROG} $(LIBS)

parse${O}: parse.c parse.h sexp.h
	$(CC) $(CFLAGS) -c parse.c -o parse${O}

sexp${O}: sexp.c sexp.h
	$(CC) $(CFLAGS) -c sexp.c -o sexp${O}

eval${O}: eval.c eval.h
	$(CC) $(CFLAGS) -c eval.c -o eval${O}

main${O}: main.c parse.h sexp.h eval.h
	$(CC) $(CFLAGS) -c main.c -o main${O}

clean:
	rm -f *.o *.core *.exe ${PROG}${EXE}
