
/* Include Stuff */
%{
  #include "mini_1.tab.h"
  
  int lineNum = 1, lineCol = 0;
  static const char* reservedWords[] = {
    "function", "beginparams", "endparams", "beginlocals", "endlocals",
    "beginbody", "endbody", "integer", "array", "of", "if", "then", "endif", 
    "else", "while", "do", "foreach", "in", "beginloop", "endloop", "continue",
    "read", "write", "and", "or", "not", "true", "false", "return" };

  static const char* reservedWordsMap[] = {
    "FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS",
    "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF",
    "ELSE", "WHILE", "DO", "FOREACH", "IN", "BEGINLOOP", "ENDLOOP", "CONTINUE",
    "READ", "WRITE", "AND", "OR", "NOT", "TRUE", "FALSE", "RETURN"};
  
  const int numReservedWords = sizeof(reservedWords) / sizeof(reservedWords[0]);
%}

/* Define Patterns */
DIGIT [0-9]
DIGIT_UNDERSCORE [0-9_]
LETTER [a-zA-Z]
LETTER_UNDERSCORE [a-zA-Z_]
CHAR [0-9a-zA-Z_]
ALPHANUMER [0-9a-zA-Z]
WHITESPACE [\t ]
NEWLINE [\n]

/* Define Rules */
%%

"-"       return SUB; ++lineCol;
"+"       return ADD; ++lineCol;
"*"       return MULT; ++lineCol;
"/"       return DIV; ++lineCol;
"%"       return MOD; ++lineCol;

"=="      return EQ; lineCol += 2;
"<>"      return NEQ; lineCol += 2;
"<"       return LT; ++lineCol;
">"       return GT; ++lineCol;
"<="      return LTE; lineCol += 2;
">="      return GTE; lineCol += 2;

{LETTER}({CHAR}*{ALPHANUMER}+)? {
  char reserved = 0;
  int i = 0;
  if (strcmp(yytext, "function") == 0) {
    return FUNCTION;
  } else if (strcmp(yytext, "beginparams") == 0) {
    return BEGIN_PARAMS;
  }
  else {
    return ID;
  }
  lineCol += yyleng;
	}

{DIGIT}+ {
  return NUMBER;
  lineCol += yyleng;
       }

({DIGIT}+{LETTER_UNDERSCORE}{CHAR}*)|("_"{CHAR}+) {
  printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter.\n",
	 lineNum, lineCol, yytext);
  exit(1);
		       }

{LETTER}({CHAR}*{ALPHANUMER}+)?"_" {
  printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore.\n",\
	 lineNum, lineCol, yytext);
  exit(1);
			   }

";"       return SEMICOLON; ++lineCol;
":"       return COLON; ++lineCol;
","       return COMMA; ++lineCol;
"("       return L_PAREN; ++lineCol;
")"       return R_PAREN; ++lineCol;
"["       return L_SQUARE_BRACKET; ++lineCol;
"]"       return R_SQUARE_BRACKET; ++lineCol;
":="      return ASSIGN; lineCol += 2;

"##".*{NEWLINE} lineCol = 0; ++lineNum;

{WHITESPACE}+   lineCol += yyleng;
{NEWLINE}+      lineNum += yyleng; lineCol = 0;

. {
  printf("Error at line %d, column %d: unrecognized symbol \"%s\" \n",
	   lineNum, lineCol, yytext);
  exit(1);
}

%%
int yyparse();

int main(int argc, char* argv[]) {
  if (argc == 2) {
    yyin = fopen(argv[1], "r");
    if (yyin == 0) {
      printf("Error opening file: %s\n", argv[1]);
      exit(1);
    }
  }
  else {
    yyin = stdin;
  }

  // Check that the table is even
  if (numReservedWords != sizeof(reservedWordsMap) / sizeof(reservedWordsMap[0])) {
    printf("Unaligned reserved words table!\n");
    exit(1);
  }

  //yylex();
  yyparse();
  
  return 0;
}
