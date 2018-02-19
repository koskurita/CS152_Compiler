%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>

%}

%union{
  char* ident_val;
  int num_val;
 }

%start Program

%token IDENT
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


%%  /*  Grammar rules and actions follow  */

Program:         Function
;

Function:        FUNCTION IDENT SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY

;

Declaration:     Identifiers COLON INTEGER
                 | Identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
;
Declarations:    %empty
                 | Declaration SEMICOLON Declarations
;

Identifiers:     IDENT
                 | IDENT COMMA Identifiers

Statements:       Statement SEMICOLON Statements
                 | Statement SEMICOLON
;
Statement:      Var ASSIGN Expression
                 | IF BoolExp THEN Statements ElseStatement ENDIF
                 | WHILE BoolExp BEGINLOOP Statements ENDLOOP
                 | DO BEGINLOOP Statements ENDLOOP WHILE BoolExp
                 | FOREACH IDENT IN IDENT BEGINLOOP Statements ENDLOOP
                 | READ Vars
                 | WRITE Vars
                 | CONTINUE
                 | RETURN Expression
;
ElseStatement:   %empty
                 | ELSE Statements
;

Var:             IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
                 | IDENT
;
Vars:            Var
                 | Var COMMA Vars
;

Expression:      MultExp
                 | MultExp ADD Expression
                 | MultExp SUB Expression
;
Expressions:     %empty
                 | Expression COMMA Expressions
                 | Expression
;

MultExp:         Term
                 | Term MULT MultExp
                 | Term DIV MultExp
                 | Term MOD MultExp
;

Term:            Var
                 | SUB Var
                 | NUMBER
                 | SUB NUMBER
                 | L_PAREN Expression R_PAREN
                 | SUB L_PAREN Expression R_PAREN
                 | IDENT L_PAREN Expressions R_PAREN
;

BoolExp:         RAExp 
{printf("bool_exp -> relation_exp\n");}
                 | RAExp OR BoolExp
                 {printf("bool_exp -> relation_and_exp OR bool_exp\n");}
;

RAExp:           RExp
{printf("relation_and_exp -> relation_exp\n");}
                 | RExp AND RAExp
                 {printf("relation_and_exp -> relation_exp AND relation_and_exp\n");}
;

RExp:            NOT RExp1 
{printf("relation_exp -> NOT relation_exp1\n");}
                 | RExp1
                 {printf("relation_exp -> relation_exp1\n");}

;
RExp1:           Expression Comp Expression
{printf("relation_exp -> Expression Comp Expression\n");
                 | TRUE
                 {printf("relation_exp -> TRUE\n");
                 | FALSE
                 {printf("relation_exp -> FALSE\n");
                 | L_PAREN BoolExp R_PAREN
                 {printf("relation_exp -> L_PAREN BoolExp R_PAREN\n");
;

Comp:            EQ
{printf("comp -> EQ\n");}
                 | NEQ
                 {printf("comp -> NEQ\n");}
                 | LT
                 {printf("comp -> LT\n");}
                 | GT
                 {printf("comp -> GT\n");}
                 | LTE
                 {printf("comp -> LTE\n");}
                 | GTE
                 {printf("comp -> GTE\n");}
;

%%

		 
int yyerror(char* s) {
  extern int lineNum;
  extern char* yytext;

  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, lineNum);
  exit(1);
}
		 

 
