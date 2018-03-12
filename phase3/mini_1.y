%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string.h>
  void yyerror(const char* s);
  int yylex();
  std::string newTemp();
  std::string newLabel();

  char empty[1] = "";

 std::map<std::string, int> variables;
 std::map<std::string, int> functions;


%}


%union{
  char* ident_val;
  int num_val;
  struct E {
    char* place;
    char* code;
    bool array;
  } expr;

  struct S {
    char* code;
    char* begin;
    char* after;
  } stat;
 }

%error-verbose
%start Program

%token <ident_val> IDENT
%token <num_val> NUMBER

%type <expr> Ident
%type <expr> Declarations Declaration Identifiers
%type <stat> Statements Statement
%type <expr> Var Expression MultExp Term BoolExp

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
%right UMI
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

Program:         %empty
{

}
| Function Program
{

};

Function:        FUNCTION Ident SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY
{
  if (functions.find($2.place) != functions.end()) {
    char temp[128];
    snprintf(temp, 128, "Redeclaration of function %s", $2.place);
    yyerror(temp);
  }
  else {
    functions.insert(std::pair<std::string,int>($2.place,0));
  }

  std::string temp = "func ";
  temp.append($2.place);
  temp.append("\n");
  temp.append($2.code);
  temp.append($5.code);
  temp.append($8.code);
  temp.append($11.begin);
  temp.append($11.code);
  temp.append($11.after);
  
  printf("%s", temp.c_str());
};


Declaration:     Identifiers COLON INTEGER
{
  std::string vars($1.place);
  std::string temp;

  // Build list of declarations base on list of identifiers
  // identifiers use "|" as delimeter
  size_t oldpos = 0;
  size_t pos = 0;
  while (true) {
    pos = vars.find("|", oldpos);
    if (pos == std::string::npos) {
      temp.append(". ");
      temp.append(vars.substr(oldpos, pos));
      temp.append("\n");
      break;
    }
    else {
      size_t len = pos - oldpos;
      temp.append(". ");
      temp.append(vars.substr(oldpos, len));
      temp.append("\n");
    }
    oldpos = pos + 1;
  }
  
  $$.code = strdup(temp.c_str());
  $$.place = strdup(empty);	      
}
| Identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
{
  std::string vars($1.place);
  std::string temp;

  // Build list of declarations base on list of identifiers
  // identifiers use "|" as delimeter
  size_t oldpos = 0;
  size_t pos = 0;
  while (true) {
    pos = vars.find("|", oldpos);
    if (pos == std::string::npos) {
      temp.append(".[] ");
      temp.append(vars.substr(oldpos, pos));
      temp.append(", ");
      temp.append(std::to_string($5));
      temp.append("\n");
      break;
    }
    else {
      size_t len = pos - oldpos;
      temp.append(".[] ");
      temp.append(vars.substr(oldpos, len));
      temp.append(", ");
      temp.append(std::to_string($5));
      temp.append("\n");
    }
    oldpos = pos + 1;
  }
  
  $$.code = strdup(temp.c_str());
  $$.place = strdup(empty);	      
}
;

Declarations:    %empty
{
  $$.code = strdup(empty);
  $$.place = strdup(empty);
}
| Declaration SEMICOLON Declarations
{
  std::string temp;
  temp.append($1.code);
  temp.append($3.code);
  
  $$.code = strdup(temp.c_str());
  $$.place = strdup(empty);
}
;

/* Identifiers is only used by declaration; so it idents in it are
 * declarations
 */
Identifiers:     Ident
{
  // Check for redeclaraion
  if (variables.find($1.place) != variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Redeclaration of variable %s", $1.place);
    yyerror(temp);
  }
  else {
    variables.insert(std::pair<std::string,int>($1.place,0));
  }

  $$.place = strdup($1.place);
  $$.code = strdup(empty);
}
| Ident COMMA Identifiers
{
  // Check for redeclaration
  if (variables.find($1.place) != variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Redeclaration of variable %s", $1.place);
    yyerror(temp);
  }
  else {
    variables.insert(std::pair<std::string,int>($1.place,0));
  }

  // use "|" as delimeter
  std::string temp;
  temp.append($1.place);
  temp.append("|");
  temp.append($3.place);
  
  $$.place = strdup(temp.c_str());
  $$.code = strdup(empty);
}

Statements:      Statement SEMICOLON Statements
{
  std::string temp;
  temp.append($1.begin);
  temp.append($1.code);
  temp.append($1.after);
  temp.append($3.begin);
  temp.append($3.code);
  temp.append($3.after);

  $$.begin = strdup(empty);
  $$.after = strdup(empty);
  $$.code = strdup(temp.c_str());
}
| Statement SEMICOLON
{
  std::string temp;
  temp.append($1.begin);
  temp.append($1.code);
  temp.append($1.after);

  $$.begin = strdup(empty);
  $$.after = strdup(empty);
  $$.code = strdup(temp.c_str());
}
;

Statement:      Var ASSIGN Expression
{
  std::string temp;
  temp.append($1.code);
  temp.append($3.code);
  if ($1.array && $3.array) {
    // TODO error
  }
  else if ($1.array) {
    temp.append("[]= ");
  }
  else if ($3.array) {
    temp.append("=[] ");
  }
  else {
    temp.append("= ");
  }
  temp.append($1.place);
  temp.append(", ");
  temp.append($3.place);
  temp.append("\n");

  $$.code = strdup(temp.c_str());
  $$.begin = strdup(empty);
  $$.after = strdup(empty);
}
| IF BoolExp THEN Statements ElseStatement ENDIF
{
  std::string b = newLabel();
  std::string a = newLabel();
  std::string temp;
  temp.append(b);
  temp.append(":\n");
  temp.append($2.code);

  temp.append("?:= ");
  temp.append($4.begin);
  temp.append(", ");
  temp.append($2.place);
}		 
| WHILE BoolExp BEGINLOOP Statements ENDLOOP
{

}
| DO BEGINLOOP Statements ENDLOOP WHILE BoolExp
{
  std::string temp;
  std::string beginLoop = newLabel();
  std::string beginWhile = newLabel();
  temp.append(beginLoop);
  temp.append($3.begin);
  temp.append("\n");
  temp.append($3.code);
  temp.append($3.after);
  	
  char temp2[1] = "";
  $$.begin = strdup(temp2);
  $$.after = strdup(temp2);
  $$.code = strdup(temp.c_str());
  
  temp.append(beginWhile);

  temp.append("\n");
  temp.append($6.code);
  temp.append("?:= ");
  temp.append(beginLoop);
  temp.append(", ");
  temp.append($6.place);
  temp.append("\n");
  
  char temp3[1] = "";
  $$.begin = strdup(temp3);
  $$.after = strdup(temp3);
  $$.code = strdup(temp.c_str());

}
| FOREACH Ident IN Ident BEGINLOOP Statements ENDLOOP
{

}
| READ Vars
{

}
| WRITE Vars
{

}
| CONTINUE
{

}
| RETURN Expression
{

};


ElseStatement:   %empty
{

}
| ELSE Statements
{

};

Var:             Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
{
  // Check for use of undeclared variable
  if (variables.find($1.place) == variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Use of undeclared variable %s", $1.place);
    yyerror(temp);
  }
  else {
    // TODO
    //    variables.insert(std::pair<std::string,int>($1,0));
  }

  std::string temp;
  temp.append($1.place);
  temp.append(", ");
  temp.append($3.place);

  char temp2[1] = "";
  $$.code = strdup(temp2);
  $$.place = strdup(temp.c_str());
  $$.array = true;
}
| Ident
{
  if (variables.find($1.place) == variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Use of undeclared variable %s", $1.place);
    yyerror(temp);
  }
  else {
    // TODO
    //    variables.insert(std::pair<std::string,int>($1,0));
  }

  $$.code = $1.code;
  $$.place = $1.place;
  $$.array = false;
};

Vars:            Var
{

}
| Var COMMA Vars
{

};



Expression:      MultExp
{
  $$.code = $1.code;
  $$.place = $1.place;
}
| MultExp ADD Expression
{
}
| MultExp SUB Expression
{
};

Expressions:     %empty
{
}
| Expression COMMA Expressions
{
}
| Expression
{
};


MultExp:         Term
{
  $$.code = $1.code;
  $$.place = $1.place;
}
| Term MULT MultExp
{
  $$.place = strdup(newTemp().c_str());
  
  std::string temp;
  temp.append(". ");
  temp.append($$.place);
  temp.append("\n");
  temp.append($1.code);
  temp.append($3.code);
  temp.append("* ");
  temp.append($$.place);
  temp.append(", ");
  temp.append($1.place);
  temp.append(", ");
  temp.append($3.place);
  temp.append("\n");

  $$.code = strdup(temp.c_str());
}
| Term DIV MultExp
{
}
| Term MOD MultExp
{
};


Term:            Var
{
}
| SUB Var
{

}
| NUMBER
{
  char temp2[1] = "";
  $$.code = strdup(temp2);
  $$.place = strdup(std::to_string($1).c_str());
}
| SUB NUMBER
{
}
| L_PAREN Expression R_PAREN
{
}
| SUB L_PAREN Expression R_PAREN
{
}
| Ident L_PAREN Expressions R_PAREN
{
   // Check for use of undeclared function
  if (functions.find($1.place) == functions.end()) {
    char temp[128];
    snprintf(temp, 128, "Use of undeclared function %s", $1.place);
    yyerror(temp);
  }
  else {
    // TODO
  }
}
;

BoolExp:         RAExp 
{
}
| RAExp OR BoolExp
{
};

RAExp:           RExp
{

}
| RExp AND RAExp
{

};

RExp:            NOT RExp1 
{

}
| RExp1
{

};

RExp1:           Expression Comp Expression
{

}
| TRUE
{

}
| FALSE
{

}
| L_PAREN BoolExp R_PAREN
{

};

Comp:            EQ
{

}
| NEQ
{

}
| LT
{

}
| GT
{

}
| LTE
{

}
| GTE
{

};


Ident:      IDENT
{
  char temp[1] = "";
  $$.place = strdup($1);
  $$.code = strdup(temp);;
}
%%

		 
void yyerror(const char* s) {
  extern int lineNum;
  extern char* yytext;

  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, lineNum);
}

std::string newTemp() {
  static int num = 0;
  std::string temp = "_t" + std::to_string(num++);
  return temp;
}

std::string newLabel() {
  static int num = 0;
  std::string temp = 'L' + std::to_string(num++);
  return temp;
}
		 

 
