#!/usr/bin/env -S dune exec abap
REPORT conditionals.

IF FALSE.
	WRITE 'BAD'.
ELSE.
	WRITE 'GOOD'.
ENDIF.

IF TRUE.
	WRITE 'GOOD'.
ELSE.
	WRITE 'BAD'.
ENDIF.
