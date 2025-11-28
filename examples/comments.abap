#!/usr/bin/env -S dune exec abap
REPORT comments.

"This is a comment.
"This means, there is no way,
"that any of the following code will be executed
"WRITE 'hello'.

"But this
WRITE 'goodbye'.
"will execute, because it has no double-quote.
