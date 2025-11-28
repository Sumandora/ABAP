#!/usr/bin/env -S dune exec abap
REPORT functions.

FUNCTION say_hello.
	WRITE 'HELLO'.
ENDFUNCTION.

CALL FUNCTION say_hello.
