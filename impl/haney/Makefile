# GNU Makefile for haney.

PROG=haney
GHC?=ghc
STRIP?=strip
O?=.o
EXE?=

MODULES=Main.hs Pixley.lhs

all: haney

haney: $(MODULES)
	$(GHC) --make Main.hs -o $(PROG)
	$(STRIP) ./$(PROG)

clean:
	rm -f *.o *.hi *.exe ${PROG}${EXE}
