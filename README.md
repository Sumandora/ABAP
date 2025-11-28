# ABAP Interpreter

An interpreter for the ABAP programming language, the language mainly used for programming SAP systems.

This was made as a joke, when me and a few friends wanted to make a casino in ABAP and realized, that it lacks the fundamental I/O capabilities to make games.

To get around this, I made an ABAP-Dialect, that supports a subset of ABAP in order to then use Raylib to make the game.

It shouldn't be too hard to add new features to this and make it closer to ABAP itself, but the language fulfilled its one and only purpose, so I won't continue working on it.

## Language extensions

Apart from supporting only a tiny bit of what actual ABAP does, it has several differences from the real thing.

### Boolean literals

One can write `TRUE` and `FALSE`, they will decay to integers when needed.

```abap
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
```

### FFI

The new `CALL EXTERN`-directive allows one to call predefined functions from Raylib, as defined in `./lib/extern_fun.ml`.
In tandem, `EXT_`-variables have been added and are defined in `./lib/extern_var.ml`.

### Comments

The only type of comment supported is the double-quote, asterisks may not be used.

### Whitespace

Unlike actual ABAP, this dialect is completely whitespace-insensitive, whitespaces are ignored on the lexer level.

### Shebang

Regular ABAP does not run in a terminal from what I gather, so they have no reason to implement this, but this dialect allows one to use a shebang to create executable abap files.

Take a look at any of the examples, they all have a shebang.

## Design choices

OCaml is used as the programming language of choice for implementing all of this, I didn't have any immediate thought put into it, it was just a language that wasn't annoying me.

Lexing and Parsing is handled by `ocamllex` and `ocamlyacc`, which I discovered during writing this.

Functions are not parsed into a separate AST and they are part of basic blocks, this is perhaps the biggest flaw in design, as this is considered valid:

```abap
FUNCTION func_a.
	WRITE 'A'.
	IF FALSE.
		ENDFUNCTION.

		FUNCTION func_b.
	ENDIF.
	WRITE 'B'.
ENDFUNCTION.
```
