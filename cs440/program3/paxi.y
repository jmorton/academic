%{
#define YYDEBUG 1
#include <stdio.h>
#include "hash.h"

#define INFO_TOP    "%-20s\t%4s \t %4s \t %4s\n"
#define INFO_FORMAT "%-20s\t%4d \t %4d \t %4d\n"

// This is defined in paxi.l but used when an error occurs
// to provide some more information about where stuff went
// down hill.
extern int global_line_count;

// Used to keep track of the number of parameters for each
// procedure.  Reset at the beginning of a procedure and
// incremented as each parameter is parsed.
int paxi_procedure_arity = 0;
int paxi_procedure_variable_count = 0;
int paxi_static_memory_index = 510;
char *paxi_current_scope;

// Declarations for paxi related functions that take actions
// based on parsing.
char* mangle_var_name();
int allocate(int);
void handle_global(void);
void handle_array(char*, int);
void handle_procedure(void);
void handle_parameter(void);
void handle_local_variable(void);
void enter_procedure(void);
void duplicate_symbol_error(void);
int  reference(char*, int);

// Yep, it's a symbol table alright.
struct symbol** symtable;

// Here's where generated code is stored.


// These make type information smaller to store and faster to check
// (rather than using a string).
enum types
{
  variable_type, array_type, procedure_type, parameter_type, local_type
}; 
 
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

%type<val> single_array tINT

%%

program: globals_list procedure_list ;

/* production-1 */
globals_list: /* epsilon */
  |   globals_list globals_decl
  ;
 
/* production-2 */
globals_decl:   global_var_decl
  |   array_decl
  ;

/* production-3 */
global_var_decl: tVAR global_var_list tSEMI
    ;

/* production-4 */
global_var_list: global_var_list tCOMMA tID { handle_global(); }
  |   tID { handle_global(); }
  ;

array_decl: tARRAY array_list tSEMI
  ;

array_list:   array_list tCOMMA  single_array 
  |   single_array
  ;

single_array:   tINT tID { handle_array(yylval.str, $<val>1); };

procedure_list: /* nothing */
  |   procedure_list procedure_decl
  ;

/* proc main() ... endproc */
procedure_decl: tPROC tID
    {
        paxi_current_scope = (char*)malloc(sizeof(char)*yylen);
        paxi_current_scope = strcpy(paxi_current_scope, $<str>2);
        paxi_procedure_arity = 0;
        paxi_procedure_variable_count = 0;
    }
  '(' formal_parameters ')' locals_list statement_list tENDPROC
    { handle_procedure(); }
  ;

formal_parameters: /* nothing */
  |   formal_list
  ;

formal_list: formal_list tCOMMA tID { handle_parameter(); }
  |  tID { handle_parameter(); }
  ;

locals_list:/*    nothing */ 
  |   locals_list local_decl
  ;

local_decl:   tVAR local_var_list tSEMI
  ;

local_var_list:   local_var_list tCOMMA tID
  |   tID { handle_local_variable(); }
;

statement_list: /* nothing */
  |   statement_list statement tSEMI
  ;
 
statement:  assignment 
  |   conditional 
  |   loop 
  |   io 
  |   call 
  |   return_value
  ;

assignment:   variable '=' arithmetic_expression
  ;

conditional:  tIF boolean_expression statement_list else_clause tENDIF
  ;

else_clause:  /* nothing */
  |   tELSE statement_list
  ;

loop:     while_loop | do_loop
  ;

while_loop:   tWHILE boolean_expression statement_list tENDWHILE
  ;

do_loop:  tDO statement_list tENDO tWHILE boolean_expression
  ;

io:     read_statement 
  |   write_statement 
  |   line_statement
  ;

call:     tID '(' actual_parameters ')'
  ;

return_value:   tRETVAL arithmetic_expression
  ;

actual_parameters:    /* nothing */
  |   parameter_list
  ;

parameter_list:   parameter_list tCOMMA arithmetic_expression
  |   arithmetic_expression
  ;

quantity:   variable 
  |   tINT
  |   call
  |   tCHAR
  ;

variable:   tID
  |   tID '[' arithmetic_expression ']'
  ;

read_statement:   tREAD '(' variable ')'
  |   tREADSTR '(' tID ')'
  ;

write_statement:
    tWRITE '(' arithmetic_expression ')'
  |   tWRITESTR '(' tSTRING ')'
  |   tWRITESTR '(' tID ')'
  ;

line_statement:   tLINE
  ;

arithmetic_expression:
    arithmetic_expression add_operator arithmetic_term
  |   arithmetic_term
  ;

arithmetic_term:
    arithmetic_term mult_operator arithmetic_factor
  |   arithmetic_factor
  ;

arithmetic_factor:
    quantity
  |   '(' arithmetic_expression ')'
  ;

add_operator:   '+' 
  |       '-'
  ;

mult_operator:  '*' 
  |   '/'
  ;

boolean_expression:
    boolean_expression tOR boolean_term
  |   boolean_term
  ;

boolean_term:   boolean_term tAND boolean_factor
  |   boolean_factor
  ;

boolean_factor:   tNOT boolean_atom
  |   boolean_atom
  ;

boolean_atom:   '(' arithmetic_expression relational_operator arithmetic_expression ')'
  |   '(' boolean_expression ')'
  ;

relational_operator: '='
  |   '<'
  |   '>'
  |   '#'
  |   tGTE
  |   tLTE
  ;

%%

void handle_global(void)
{
  // It is possible that the global has already been allocated.  Since
  // the symbol table is not (and should not) be capable of allocating
  // memory, we need to check for the existence of the global variable
  // before allocating space for it.
  if (! lookup(symtable, yylval.str))
    {     
      char *name = (char*)malloc(strlen(yylval.str));
      name = strcpy(name, yylval.str);
      int type = parameter_type;
      int size = 1;
      int location = allocate(size);
      int result = insert(symtable, name, type, size, location);
      printf(INFO_FORMAT, name, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }   
}

/* Reset variables used by other functions that assume
   a "fresh start" within the scope of a procedure.
*/
void enter_procedure(void) 
{
//  printf("Procedure named %s.\n", $<str>2);
}

void handle_procedure(void)
{
  if (! lookup(symtable, yylval.str))
    {     
      int type = procedure_type;
      int size = paxi_procedure_arity;
      int location = 0; // what is the location??
      int result = insert(symtable, paxi_current_scope, type, size, location);
      printf(INFO_FORMAT, paxi_current_scope, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }
}

void handle_array(char *str, int size)
{
  if (! lookup(symtable, yylval.str))
    {     
      char *name = (char*)malloc(strlen(str));
      name = strcpy(name, yylval.str);
      int type = array_type;
      int location = allocate(size);
      int result = insert(symtable, name, type, size, location);
      printf(INFO_FORMAT, name, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }
}

void handle_parameter(void)
{
  char *name = mangle_var_name();
  if (! lookup(symtable, name))
    {
      paxi_procedure_arity++;
      int type = parameter_type;
      int size = 1;
      int location = paxi_procedure_arity;
      int result = insert(symtable, name, type, size, location);
      printf(INFO_FORMAT, name, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }
}

void handle_local_variable(void)
{
  char *name = mangle_var_name();
  if (! lookup(symtable, name))
    {
      paxi_procedure_variable_count += 1;
      int type = local_type;
      int size = 1;
      int location = paxi_procedure_variable_count;
      int result = insert(symtable, name, type, size, location);
      printf(INFO_FORMAT, name, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }
}

/* Reserves space for global variables and arrays. */ 
int allocate(int space) 
{
  // TODO: add check for when space runs out!
  int location = paxi_static_memory_index;
  paxi_static_memory_index += space;
  return location;
}

/* Returns the location the symbol references.  Performs a check
   to make sure the symbol referenced is semantically correct.
*/
int reference(char *name, int type)
{
  char *mangled_name = mangle_var_name();
	struct symbol *sym = lookup(symtable, mangled_name);
  free(mangled_name); // or else we leak memory...
  
  // If nothing was found, try finding the global variable.
	if (sym == NULL)
		{
		  sym = lookup(symtable, name);
		}

  // if still nothing was found, return NULL to indicate nothing found.
	if (sym == NULL)
    {
      return NULL;
    }
  // if something was found, but it wasn't the specified type, bail out.
  else if (sym->type != type)
    {
      return NULL;
    } 
  // otherwise provide the location to the caller.
  else
    {
      return sym->location;
    }
}

/* Turns whatever is in yylval.str into a mangled representation.
   Allocates memory for the mangled string too since it has to
   calculate the amount of space need given the current procedure
   name.  Behavior isn't defined when yylval isn't a string and when
   we aren't in the scope of a procedure.

   Used during initialization *AND* reading of variables.
*/
char* mangle_var_name(void)
{
  char *name = (char*)malloc( strlen(yylval.str)+strlen(paxi_current_scope) );
  strcpy(name, yylval.str);
  strcat(name, "@");
  strcat(name, paxi_current_scope);
  return name;
}

void duplicate_symbol_error(void)
{
  printf("%-20s  **Identifer already in use**\n", yylval.str);
}

int main() {
  printf(INFO_TOP, "Sym. Table Name", "Size", "Location", "Type");
  symtable = setupSymbolTable();
  yydebug = 0;
  yyparse();
	printf("triple: %d\n", reference("triple",1));
	printf("z1@foo: %d\n", reference("z1@foo",3));
	printf("main: %d\n", reference("main",2));
  return 0;
}
