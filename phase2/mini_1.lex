
/* Include Stuff */
%{
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

"-"       printf("SUB\n"); ++lineCol;
"+"       printf("ADD\n"); ++lineCol;
"*"       printf("MULT\n"); ++lineCol;
"/"       printf("DIV\n"); ++lineCol;
"%"       printf("MOD\n"); ++lineCol;

"=="      printf("EQ\n"); lineCol += 2;
"<>"      printf("NEQ\n"); lineCol += 2;
"<"       printf("LT\n"); ++lineCol;
">"       printf("GT\n"); ++lineCol;
"<="      printf("LTE\n"); lineCol += 2;
">="      printf("GTE\n"); lineCol += 2;

{LETTER}({CHAR}*{ALPHANUMER}+)? {
  char reserved = 0;
  int i = 0;
  for (; i < numReservedWords; ++i) {
    if (strcmp(yytext, reservedWords[i]) == 0) {
      printf("%s\n", reservedWordsMap[i]);
      reserved = 1;
    }
  }
  if (reserved == 0) {
    printf("IDENT %s\n", yytext);
  }
  lineCol += yyleng;
	}

{DIGIT}+ {
  printf("NUMBER %s\n", yytext);
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

";"       printf("SEMICOLON\n"); ++lineCol;
":"       printf("COLON\n"); ++lineCol;
","       printf("COMMA\n"); ++lineCol;
"("       printf("L_PAREN\n"); ++lineCol;
")"       printf("R_PAREN\n"); ++lineCol;
"["       printf("L_SQUARE_BRACKET\n"); ++lineCol;
"]"       printf("R_SQUARE_BRACKET\n"); ++lineCol;
":="      printf("ASSIGN\n"); lineCol += 2;

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
