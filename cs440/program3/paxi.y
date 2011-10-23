%{
#define YYDEBUG 1
#include <stdio.h>
#include "hash.h"

// This is defined in paxi.l but used when an error occurs
// to provide some more information about where stuff went
// down hill.
extern int global_line_count;

struct symbol** symtable;

int yywrap() {
  return 1;
}

void yyerror(const char * str) {
  printf("Error: %s\n", str);
  printf("Died on line: %d\n", global_line_count);
}

%}

%union {
  int val;
  char *str;
  struct symbol *sym;
}

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

program: globals_list procedure_list ;

globals_list: /* epsilon */
	| 	globals_list globals_decl
	;
 
globals_decl:	global_var_decl
	| 	array_decl
	;

global_var_decl: tVAR global_var_list tSEMI
		;

global_var_list: global_var_list tCOMMA tID
	| 	tID
		{ printf("Create a symbol"); }
	;

array_decl: tARRAY array_list tSEMI
	;

array_list:	array_list tCOMMA  single_array 
	| 	single_array
	;

single_array:	tINT tID 
		{ printf("Allocate array\n"); }
	;

procedure_list: /* nothing */
	| 	procedure_list procedure_decl
	;

/* proc main() ... endproc */
procedure_decl: tPROC tID
		{ printf("Procedure named %s.\n", $<str>2); }
                '(' formal_parameters ')' locals_list statement_list tENDPROC
		{ printf("Procedure declared.\n"); }
	;

formal_parameters: /* nothing */
	| 	formal_list
	;

formal_list: formal_list tCOMMA tID                  
	| 	tID
	;

locals_list:/* 	nothing */ 
	| 	locals_list local_decl
	;

local_decl:	tVAR local_var_list tSEMI
	;

local_var_list:	local_var_list tCOMMA tID
	| 	tID
	;

statement_list: /* nothing */
	| 	statement_list statement tSEMI
	;
 
statement:	assignment 
	| 	conditional 
	| 	loop 
	| 	io 
	| 	call 
	| 	return_value
	;

assignment:	variable '=' arithmetic_expression
	;

conditional:	tIF boolean_expression statement_list else_clause tENDIF
	;

else_clause:	/* nothing */
	| 	tELSE statement_list
	;

loop:		while_loop | do_loop
	;

while_loop:	tWHILE boolean_expression statement_list tENDWHILE
	;

do_loop:	tDO statement_list tENDO tWHILE boolean_expression
	;

io:		read_statement 
	| 	write_statement 
	| 	line_statement
	;

call:		tID '(' actual_parameters ')'
	;

return_value:	tRETVAL arithmetic_expression
	;

actual_parameters:		/* nothing */
	|	parameter_list
	;

parameter_list:	parameter_list tCOMMA arithmetic_expression
	|	arithmetic_expression
	;

quantity:	variable 
	| 	tINT
	|	call
	|	tCHAR
	;

variable:	tID
	|	tID '[' arithmetic_expression ']'
	;

read_statement:	tREAD '(' variable ')'
	|	tREADSTR '(' tID ')'
	;

write_statement:
		tWRITE '(' arithmetic_expression ')'
	|	tWRITESTR '(' tSTRING ')'
	|	tWRITESTR '(' tID ')'
	;

line_statement:	tLINE
	;

arithmetic_expression:
		arithmetic_expression add_operator arithmetic_term
	|	arithmetic_term
	;

arithmetic_term:
		arithmetic_term mult_operator arithmetic_factor
	|	arithmetic_factor
	;

arithmetic_factor:
		quantity
	|	'(' arithmetic_expression ')'
	;

add_operator:	'+' 
	|       '-'
	;

mult_operator:	'*' 
	|	'/'
	;

boolean_expression:
		boolean_expression tOR boolean_term
	|	boolean_term
	;

boolean_term:	boolean_term tAND boolean_factor
	|	boolean_factor
	;

boolean_factor:	tNOT boolean_atom
	|	boolean_atom
	;

boolean_atom:	'(' arithmetic_expression relational_operator arithmetic_expression ')'
	|	'(' boolean_expression ')'
	;

relational_operator: '='
	|	'<'
	|	'>'
	|	'#'
	|	tGTE
	|	tLTE
	;

%%

int main() {
  symtable = setupSymbolTable();
  yydebug = 0;
  yyparse();
  return 0;
}
