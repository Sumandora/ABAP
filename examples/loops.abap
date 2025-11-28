#!/usr/bin/env -S dune exec abap
REPORT loops.

DATA x TYPE i VALUE 0.

WHILE x < 10.
	WRITE x.
	x = x + 1.
ENDWHILE.
