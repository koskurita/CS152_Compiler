/* main.cc */
#define YY_NO_UNPUT

#include <iostream>
#include <stdio.h>
#include <string>
#include <stdlib.h>

using namespace std;

// prototype of bison-generated parser function
int yyparse();

int main(int argc, char* argv[]) {
  /*
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

  }
  */

  yyparse();

  
  return 0;
}
