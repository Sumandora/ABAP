%token <int> INT
%token <string> STR
%token <string> WORD
%token PERIOD
%token EOF
%token IF
%token ENDIF
%token EQUALS
%token IS_EQUALS
%token LESS_THAN
%token NEGATION

%token PLUS MINUS TIMES DIV MOD
%token LPAREN RPAREN

%left PLUS MINUS        /* lowest precedence */
%left TIMES DIV MOD     /* medium precedence */
%nonassoc UMINUS        /* highest precedence */

%start main
%type <Ast.program> main
%type <Ast.sentence> sentence
%type <Ast.expr> expr

%%

main:
    basic_block EOF    {$1}
;
basic_block     : {[]}
                | sentence basic_block    {[$1] @ $2}
;
sentence  : WORD PERIOD {Old ($1, [])}
          | WORD exprs PERIOD {Old ($1, $2)}
          | WORD EQUALS expr PERIOD {New ($1,$3)}
;
exprs   : expr exprs {[$1] @ $2}
        | expr {[$1]}

expr    : LPAREN expr RPAREN      { $2 }
        | expr PLUS expr          { Add_expr ($1, $3) }
        | expr MINUS expr         { Sub_expr ($1, $3) }
        | expr TIMES expr         { Mul_expr ($1, $3) }
        | expr DIV expr           { Div_expr ($1, $3) }
        | expr IS_EQUALS expr     { Equal_expr ($1, $3) }
        | expr LESS_THAN expr     { LessThan_expr ($1, $3) }
        | expr MOD expr           { Mod_expr ($1, $3) }
        | MINUS expr %prec UMINUS { Sub_expr (Int_expr 0, $2) }
        | NEGATION expr           { Negation_expr $2 }
        | STR {String_expr $1}
        | INT {Int_expr $1}
        | WORD {Word $1}

%%
