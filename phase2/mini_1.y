%{
#include <stdio.h>
#include <string.h>

  int yyerror(char* s);
  int yylex(void);
%}

%union {
  int int_val;
  string* op_val;
}


%token id "IDENT"
%token num "NUMBER"

%token func "FUNCTION"
%token beginp "BEGIN_PARAMS"
%token endp "END_PARAMS"
%token beginl "BEGIN_LOCALS"
%token endl "END_LOCALS"
%token beginb "BEGIN_BODY"
%token endb "END_BODY"
%token int "INTEGER"
%token array "ARRAY"
%token of "OF"
%token myif "IF"
%token then "THEN"
%token endif "ENDIF"
%token myelse "ELSE"
%token mywhile "WHILE"
%token mydo "DO"
%token foreach "FOREACH"
%token in "IN"
%token beginloop "BEGINLOOP"
%token endloop "ENDLOOP"
%token cont "CONTINUE"
%token read "READ"
%token write "WRITE"
%token and "AND"
%token or "OR"
%token not "NOT"
%token true "TRUE"
%token false "FALSE"
%token myreturn "RETURN"
	    

%token lparen "L_PAREN"
%token rparen "R_PAREN"
%token lsquare "L_SQUARE_BRACKET"
%token rsquare "R_SQUARE_BRACKET"
%token colon "COLON"
%token semicolon "SEMICOLON"
%token comma "COMMA"
%token assign "ASSIGN"




%start Input

%%  /*  Grammar rules and actions follow  */

Input:           %empty
                 | Function Input
;

Function:        func id semicolon beginp Declaration endp beginl Declaration endl beginb Statement endb
;

Declaration:     %empty
                 | Declaration1 colon Declaration2 int semicolon Declaration
;
Declaration1:    id
                 | id comma Declaration1 
;
Declaration2:    %empty
                 | array lsquare num rsquare of
;

Statement:       %empty
;
Statement1:      Var assign Expression
                 | myif BoolExp then Statement Statement3 endif

;
Statement2:      %empty
;
Statement3:      %empty
;

Var:             %empty
;

Expression:      %empty
;

BoolExp:         %empty
;
%%

int yyerror(string s) {
  extern int yylineno;
  extern int char* yytext;

  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, yylineno);
  exit(1);
}

int yyerror(char* s) {
  return yyerror(string(s));
}

 
