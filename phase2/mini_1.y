%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>

%}

%union {
  char* ident_val;
  int number_val;
}

%token <ident_val> IDENT
%token NUMBER

%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token FOREACH
%token IN
%token BEGINLOOP
%token ENDLOOP
%token CONTINUE
%token READ
%token WRITE
%left AND
%left OR
%right NOT

%token TRUE
%token FALSE
%token RETURN

%left SUB
%left ADD
%left MULT
%left DIV
%left MOD
%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE

%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token COLON
%token SEMICOLON
%token COMMA
%left ASSIGN

%start Function

%%  /*  Grammar rules and actions follow  */

Function:        FUNCTION IDENT SEMICOLON BEGIN_PARAMS Declaration END_PARAMS
BEGIN_LOCALS Declaration END_LOCALS BEGIN_BODY  Statement END_BODY
{printf("Function -> FUNCTION IDENT SEMICOLON BEGINPARAMS Declaration ENDPARAMS BEGINLOCALS Declaration ENDLOCALS BEGINBODY Statement ENDBODY\n"); }
;

Declaration:     %empty
{printf("Declaration -> epsilon\n");}
                 | Declaration1 COLON Declaration2 INTEGER SEMICOLON Declaration
		 {printf("Declaration -> Declaration1 COLON Declaration2 INTEGER SEMICOLON Declaration\n");}
;
Declaration1:    IDENT
{printf("Declaration1 -> IDENT\n");}
                 | IDENT COMMA Declaration1
		 {printf("Declaration1 -> IDENT COMMA Declaration1\n");}
;
Declaration2:    %empty
{printf("Declaration2 -> epsilon\n");}
                 | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
		 {printf("Declaration2 -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF\n");}
;

Statement:       Statement1 SEMICOLON Statement
{printf("Statement -> Statement1 SEMICOLON Statement\n");}
                 | Statement1 SEMICOLON
;
Statement1:      Var ASSIGN Expression
{printf("Statement1 -> Var assign Expression\n");}
                 | IF BoolExp THEN Statement Statement2 ENDIF
                 | WHILE BoolExp BEGINLOOP Statement ENDLOOP
| DO BEGINLOOP Statement ENDLOOP WHILE BoolExp
{printf("Statement1 -> do beginloop Statement endloop while Bool-Expr\n");}
                 | FOREACH IDENT IN IDENT BEGINLOOP Statement ENDLOOP
                 | READ Var1
                 | WRITE Var1
                 | CONTINUE
                 | RETURN Expression
;
Statement2:      %empty
                 | ELSE Statement
;

Var:             IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
{printf("Var -> ident l_square_bracket Expression r_square_bracket\n");}
                 | IDENT
		 {printf("Var -> ident\n");}
;
Var1:            Var
{printf("Var1 -> Var\n");}
                 | Var COMMA Var1
		 {printf("Var1 -> Var comma Var1\n");}
;

Expression:      MultExp Expression1
;
Expression1:     %empty
                 | ADD MultExp Expression1
                 | SUB MultExp Expression1

MultExp:         Term MultExp1
;
MultExp1:        %empty
                 | MULT Term MultExp1
                 | DIV Term MultExp1
                 | MOD Term MultExp1

Term:            Term1
                 | Term2
;
Term1:           Term11 Term12
;
Term11:          %empty
                 | SUB
;
Term12:          Var
                 | NUMBER
                 | L_PAREN Expression R_PAREN
;
Term2:           IDENT L_PAREN Term21 R_PAREN
;
Term21:          %empty
                 | Expression COMMA Term21

BoolExp:         RAExp BoolExp1
;
BoolExp1:        %empty
                 | OR RAExp BoolExp1

RAExp:           RExp RAExp1
;
RAExp1:          %empty
                 | AND RExp RAExp1
;

RExp:            RExp1 RExp2
;
RExp1:           %empty
                 | NOT
;
RExp2:           Expression Comp Expression
                 | TRUE
                 | FALSE
                 | L_PAREN BoolExp R_PAREN
;

Comp:            EQ
                 | NEQ
                 | LT
                 | GT
                 | LTE
                 | GTE
;
%%

		 
int yyerror(char* s) {
  extern int lineNum;
  extern char* yytext;

  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, lineNum);
  exit(1);
}
		 

 
