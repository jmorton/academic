/* Jon Morton
   CS440
   Program 3
 */
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
int paxi_last_addr = 0;
char *paxi_current_scope;

// Declarations for paxi related functions that take actions
// based on parsing.
char* mangle_var_name();
int   allocate(int);
void  handle_global(void);
void  handle_array(char*, int);
void  handle_procedure(void);
void  handle_parameter(void);
void  handle_local_variable(void);
int   handle_arithmetic(char*, int, int);
void  handle_line(void);
void  handle_write(int);
void  handle_writestr(int);
void  enter_procedure(void);
void  duplicate_symbol_error(void);
void  generate(int a, int b, int c, char*);
struct symbol* reference(char*, int);

// Here's where generated code is stored.
int store(int, int, int);
int retrieve(int);
int paxi_code[4096];
static int paxi_code_length = 0;

// Yep, it's a symbol table alright.
struct symbol** symtable;

// Adds three integers to the code store array.
int store(int a, int b, int c) {
  paxi_code[paxi_code_length++] = a;
  paxi_code[paxi_code_length++] = b;
  paxi_code[paxi_code_length++] = c;
}

// Retrieves one integer from the code store array.
int retrieve(int index) {
  return paxi_code[index];
}

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
%token tEQ

%type<val> single_array tINT

%%

program: globals_list procedure_list ;

globals_list: /* epsilon */
  |   globals_list globals_decl
  ;
 
globals_decl: global_var_decl
  |   array_decl
  ;

global_var_decl: tVAR global_var_list tSEMI
    ;

global_var_list: global_var_list tCOMMA tID { handle_global(); }
  |   tID { handle_global(); }
  ;

array_decl: tARRAY array_list tSEMI
  ;

array_list: array_list tCOMMA  single_array 
  |   single_array
  ;

single_array: tINT tID { handle_array(yylval.str, $<val>1); };

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

locals_list: /*    nothing */ 
  |   locals_list local_decl
  ;

local_decl: tVAR local_var_list tSEMI
  ;

local_var_list: local_var_list tCOMMA tID
  |   tID { handle_local_variable(); }
;

statement_list: /* nothing */
  |   statement_list statement tSEMI
  ;
 
statement: assignment
  |   conditional 
  |   loop 
  |   io 
  |   call 
  |   return_value
  ;

assignment: variable '=' arithmetic_expression {
              $<val>$ = $<val>1;
              generate(2, $<val>1, $<val>3, "mvi");
            }
  ;

conditional: tIF boolean_expression statement_list else_clause tENDIF
  ;

else_clause:  /* nothing */
  |   tELSE statement_list
  ;

loop: while_loop | do_loop
  ;

while_loop: tWHILE boolean_expression statement_list tENDWHILE
  ;

do_loop: tDO statement_list tENDO tWHILE boolean_expression
  ;

io: read_statement 
  | write_statement 
  | line_statement
  ;

call: tID '(' actual_parameters ')'
  ;

return_value: tRETVAL arithmetic_expression
  ;

actual_parameters: /* nothing */
  |   parameter_list
  ;

parameter_list: parameter_list tCOMMA arithmetic_expression
  |   arithmetic_expression
  ;

/* Stack Policy: leaves a VALUE */
quantity: variable {
            generate( 27, 500,   0 , "popd"  ); // pop address 
            generate(  1, 500, 501 , "mov"   ); // get value at address
            generate( 24, 501,   0 , "pushd" ); // push value onto stack
          }
  |       tINT { /* push value in $1 */
            generate( 26, $<val>1, 0, "pushi" );
          }
  |       call { /* nothing yet */ 
          }
  |       tCHAR {
            generate( 26, $<val>1, 0, "pushi" );
          }
  ;


/* Set $$ to the location of the variable or array at index */
/* Stack Policy: leaves an ADDRESS */
variable: tID {
            $<val>$=(reference($<str>1, variable_type)->location);
            generate( 26, $<val>$, 0, "pushi" );
          }
          // Use the ADDRESS left on the stack by arithmetic_expression.
          // Move arithmetic_expression to temp
          // Move tID address to temp
  |       tID '[' arithmetic_expression ']' {
            $<val>$=((reference($<str>1, array_type)->location)+$<val>3);
            generate( 27, 500,   0, "popd" );   // move arithmetic_expr into temp
            generate( 27, 501,   0, "popd" );   // move tID address to temp
            generate(  9, 500, 501, "add"  );   // calculate the new address
            generate( 24, 500,   0, "pushd" );   // leave calculated addr on stack
          }
  ;

read_statement: tREAD '(' variable ')' { generate(33, reference($<str>1, array_type)->location, 0, "tgets"); }
  |   tREADSTR '(' tID ')'
  ;

write_statement: tWRITE '(' arithmetic_expression ')' { handle_write($<val>3); }
  |              tWRITESTR '(' tSTRING ')' { }
  |              tWRITESTR '(' tID ')' { handle_writestr(reference($<str>3, array_type)->location); }
  ;

line_statement: tLINE { handle_line(); }
  ;

/* Stack Policy: leaves a VALUE */
arithmetic_expression:
      arithmetic_expression add_operator arithmetic_term {
        generate( 27, 500,   0, "popd" );   // move term into addr (order?)
        generate( 27, 501,   0, "popd" );   // move expr into addr (order?)
        generate(  9, 500, 501, "add"  );   // calculate the sum
        generate( 24, 500,   0, "pushd" );   // move the result onto the stack
      }
  |   arithmetic_term
  ;

/* Stack Policy: leaves a VALUE */
arithmetic_term:
      arithmetic_term mult_operator arithmetic_factor {
        generate( 27, 500,   0, "popd" );   // move term into addr (order?)
        generate( 27, 501,   0, "popd" );   // move expr into addr (order?)
        generate( 12, 500, 501, "mul"  );   // calculate the sum
        generate( 24, 500,   0, "pushd" );   // move the result onto the stack
      }
  |   arithmetic_factor
  ;

/* ??? Stack Policy: leaves a VALUE ??? */
arithmetic_factor: quantity { }
  |   '(' arithmetic_expression ')' {
         $<val>$ = $<val>2;
       }
  ;

add_operator: '+' { $<str>$ = "+"; }
  |           '-' { $<str>$ = "-"; }
  ;

mult_operator: '*' { $<str>$ = "*"; }
  |            '/' { $<str>$ = "/"; }
  ;

boolean_expression: boolean_expression tOR boolean_term
  |                 boolean_term
  ;

boolean_term: boolean_term tAND boolean_factor
  |   boolean_factor
  ;

boolean_factor: tNOT boolean_atom
  |   boolean_atom
  ;

boolean_atom: '(' arithmetic_expression relational_operator arithmetic_expression ')'
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
      // printf(INFO_FORMAT, name, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }   
}

void handle_procedure(void)
{
  if (! lookup(symtable, yylval.str))
    {     
      int type = procedure_type;
      int size = paxi_procedure_arity;
      int location = 0; // what is the location??
      int result = insert(symtable, paxi_current_scope, type, size, location);
      // printf(INFO_FORMAT, paxi_current_scope, size, location, type);
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
      // printf(INFO_FORMAT, name, size, location, type);
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
      // printf(INFO_FORMAT, name, size, location, type);
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
      // printf(INFO_FORMAT, name, size, location, type);
    }
  else
    {
      duplicate_symbol_error();
    }
}

int handle_array_reference(char* variable, int index)
{
  struct symbol *s = reference(variable, array_type);
  if (s)
    {
      printf("array %s found, %d\n", variable, index);
      return index;
    }
  else
    {
      printf("\n%s missing\n",variable);
    }
}

void handle_line() {
  generate(31, 0, 0, "tline");
}

void handle_write(int location) {
  generate(29, location, 0, "tputi");
}

void handle_writestr(int location) {
  generate(30, location, 0, "tputs");
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
struct symbol* reference(char *name, int type)
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
  // else if (sym && (sym->type != type))
  //  {
  //    return NULL;
  //  } 
  // otherwise provide the location to the caller.
  else
    {
      return sym;
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

int get_used() {
  return paxi_code_length++;
}

void generate(int a, int b, int c, char* description) {
  store(a,b,c);  
  // printf("%d\t%d\t%d\t%s\n",a,b,c,description);
}

int main() {
  // printf(INFO_TOP, "Sym. Table Name", "Size", "Location", "Type");
  symtable = setupSymbolTable();
  yydebug = 0;
  yyparse();
  int i;
  for (i = 0; i < paxi_code_length; i++) {
    printf("%d\t", retrieve(i));
    if ((i-2) % 3 == 0) { printf("\n"); }
  }
  return 0;
}
