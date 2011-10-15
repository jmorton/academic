%{
#include <stdio.h>

int yywrap() {
  return 1;
}

void yyerror(const char * str) {
  printf("Error: %s\n", str);
}

%}

%union {
  char *str;
  int val;
}

%token tVAR
%token tAND       // and
%token tOR        // or
%token tNOT       // not
%token tVAR       // var
%token tARRAY     // array
%token tDO        // do
%token tELSE      // else
%token tENDO      // endo
%token tENDIF     // endif
%token tENDPROC   // endproc
%token tENDWHILE  // endwhile
%token tIF        // if
%token tLINE      // line
%token tPROC      // proc
%token tREAD      // read
%token tREADSTR   // readstr
%token tRETVAL    // retval
%token tWHILE     // while
%token tWRITESTR  // writestr
%token tWRITE     // write
%token tGTE       // >=
%token tLTE       // <=
%token tTBD       // #
%token tPO        // (
%token tPC        // )
%token tBO        // [
%token tBC        // ]
%token tCOMMA     // ,
%token tSEMI      // ;
%token tDQUOTE    // "
%token tSQUOTE    // '
%token tID
%token tINT
%token tSTRING
%token tCHAR
%token tNEWLINE
%token tCOMMENT

%%

program: globals_list | ;

globals_list : /* epsilon */
             | globals_list globals_decl
;
 
globals_decl: global_var_decl
            | array_decl
;
 

global_var_decl: tVAR global_var_list tSEMI
;

global_var_list: global_var_list tCOMMA tID   { printf("allocate global variable '%s'\n", $<str>3); }
               | tID                          { printf("allocate global variable '%s'\n", $<str>1); }
;

array_decl: tARRAY array_list tSEMI
;

array_list: array_list tCOMMA  single_array 
          | single_array
;

single_array: tINT tID  { printf("allocate global array '%s' of size '%d'\n", $<str>2, $<val>1) }
; 

%%

int main() {
  yyparse();
  return 0;
}
