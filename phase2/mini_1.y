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
%token ret "RETURN"

%token sub "SUB"
%token add "ADD"
%token mult "MULT"
%token div "DIV"
%token mod "MOD"
%token eq "EQ"
%token neq "NEQ"
%token lt "LT"
%token gt "GT"
%token lte "LTE"
%token gte "GTE"

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

Statement:       Statement1 semicolon Statement
                 | Statement1 semicolon
;
Statement1:      Var assign Expression
                 | myif BoolExp then Statement Statement2 endif
                 | mywhile BoolExp beginloop Statement endloop
                 | mydo beginloop Statement endloop mywhile BoolExp
                 | foreach id in id beginloop Statement endloop
                 | read Var1
                 | write Var1
                 | cont
                 | ret Expression
;
Statement2:      %empty
                 | myelse Statement
;

Var:             id
                 | id lsquare Expression rsquare
;
Var1:            Var
                 | Var comma Var1
;

Expression:      MultExp Expression1
;
Expression1:     %empty
                 | add MultExp Expression1
                 | sub MultExp Expression1

MultExp:         Term MultExp1
;
MultExp1:        %empty
                 | mult Term MultExp1
                 | div Term MultExp1
                 | mod Term MultExp1

Term:            Term1
                 | Term2
;
Term1:           Term11 Term12
;
Term11:          %empty
                 | sub
;
Term12:          Var
                 | num
                 | lparen Expression rparen
;
Term2:           id lparen Term21 rparen
;
Term21:          %empty
                 | Expression comma Term21

BoolExp:         RAExp BoolExp1
;
BoolExp1:        %empty
                 | or RAExp BoolExp1

RAExp:           RExp RAExp1
;
RAExp1:          %empty
                 | and RExp RAExp1
;

RExp:            RExp1 RExp2
;
RExp1:           %empty
                 | not
;
RExp2:           Expression Comp Expression
                 | true
                 | false
                 | lparen BoolExp rparen
;

Comp:            eq
                 | neq
                 | lt
                 | gt
                 | lte
                 | gte
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

 
