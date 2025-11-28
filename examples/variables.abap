#!/usr/bin/env -S dune exec abap
REPORT variables.

DATA test TYPE string VALUE 'Hey'.

WRITE test.

test = 'Bye'.

WRITE test.
