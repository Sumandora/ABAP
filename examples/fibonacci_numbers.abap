#!/usr/bin/env -S dune exec abap
REPORT fibonacci_numbers.

DATA a TYPE i VALUE 0.
DATA b TYPE i VALUE 1.
DATA c TYPE i VALUE 0.

WHILE c < 1000.
	WRITE c.
	c = a + b.
	b = a.
	a = c.
ENDWHILE.
