%{
  // include section

%}

HEXDIGIT [0-9a-fA-F]

%%
{HEXDIGIT}{1,8}  printf("You entered a 32-bit hex number %s\n", yytext);
  
%%

main()
{
  yylex();
}

