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
%token AND
%token OR
%token NOT

%token TRUE
%token FALSE
%token RETURN

%token SUB
%token ADD
%token MULT
%token DIV
%token MOD
%token EQ
%token NEQ
%token LT
%token GT
%token LTE
%token GTE

%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token COLON
%token SEMICOLON
%token COMMA
%token ASSIGN

%start Input

%%  /*  Grammar rules and actions follow  */
Input:           Function { printf("Input -> Function Input\n"); }
;

Function:        FUNCTION IDENT SEMICOLON BEGIN_PARAMS Declaration END_PARAMS
BEGIN_LOCALS Declaration END_LOCALS BEGIN_BODY  Statement END_BODY
{ printf("Function -> Function ident; beginparams Declaration endparams beginlocals Declaration endlocals beginbody Statement endbody\n"); }
;

Declaration:     %empty
                 | Declaration1 COLON Declaration2 INTEGER SEMICOLON Declaration
;
Declaration1:    IDENT
                 | IDENT COMMA Declaration1 
;
Declaration2:    %empty
                 | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
;

Statement:       Statement1 SEMICOLON Statement
                 | Statement1 SEMICOLON
;
Statement1:      Var ASSIGN Expression
                 | IF BoolExp THEN Statement Statement2 ENDIF
                 | WHILE BoolExp BEGINLOOP Statement ENDLOOP
                 | DO BEGINLOOP Statement ENDLOOP WHILE BoolExp
                 | FOREACH IDENT IN IDENT BEGINLOOP Statement ENDLOOP
                 | READ Var1
                 | WRITE Var1
                 | CONTINUE
                 | RETURN Expression
;
Statement2:      %empty
                 | ELSE Statement
;

Var:             IDENT
                 | IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
;
Var1:            Var
                 | Var COMMA Var1
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
		 

 
