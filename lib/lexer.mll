{
open Parser
exception No_such_symbol

let remove_quotes s = String.sub s 1 @@ String.length s - 2
}

rule token = parse
	[' ' '\t' '\n'] { token lexbuf }

	| '"'[^'\n']*'\n' { token lexbuf }

	| ['0'-'9']+ as lxm { INT (int_of_string lxm) }
	| '\''[^'\'']*'\'' as str { STR (remove_quotes str) }
	| ['a'-'z' 'A'-'Z' '0'-'9' '_']['a'-'z' 'A'-'Z' '0'-'9' '_' '-']* as str { WORD str }

	| '.' { PERIOD }
	| '+' { PLUS }
	| '-' { MINUS }
	| '*' { TIMES }
	| '/' { DIV }
	| '%' { MOD }
	| '(' { LPAREN }
	| ')' { RPAREN }
	| "==" { IS_EQUALS }
	| '=' { EQUALS }
	| '<' { LESS_THAN }
	| '!' { NEGATION }
	| eof { EOF }
	| _ { raise @@ No_such_symbol }
