#!/bin/sh

cat sexp.h eval.h parse.h sexp.c eval.c parse.c main.c | grep -v '^\#include "' > mignon.c
