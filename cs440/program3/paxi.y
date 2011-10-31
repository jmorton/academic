/* Jon Morton
   CS440
   Program 3

   The major pieces of this parser (aside from the usual grammar, etc...):
   - Symbol table: contains the names and locations of arrays variables
     and procedures.
   - Code store: contains instruction triples (opcode and two arguments).
    
   The parser relies on stack conventions to perform runtime calculation of array
   addresses and arithmetic.  This convention is documented along with the part
   of the grammar where they are implemented.  It is important to consider these conventions when modifying this parser.

   Fundamental constants and widely used functions of interest are outlined
   here:

   - allocate: used to allocate memory statically.  used by variable, array,
     and procedure related clauses of the grammar.

   - generate: add opcodes to the code store.

   - reference: retrieve a symbol table entry of the specified type(s).  It
     is up to the caller to get what they'd like, typically the location.

   - mangle: used to generate scoped symbol names so that local variables
     can shadow global ones.

 */
%{
#define YYDEBUG 1
#include <stdio.h>
#include "hash.h"
#include "opcodes.h"

// This is defined in paxi.l but used when an error occurs
// to provide some more information about where stuff went
// down hill.
extern int global_line_count;

/* Values shared by the paxi parser to generate code. Names explain
   purpose.  These should only be modified by one funcion although
   reading them anywhere is considered safe.  4096 is enough for now
   but will be changed later to a dynamic collection.
*/
int paxi_code_length = 0; // tracks code store length, should be a 
int paxi_code[4096*3];    // multiple of three since each opcode is
                          // exactly three int

struct symbol** symtable;

char *paxi_current_scope;
int paxi_procedure_arity = 0;
int paxi_procedure_variable_count = 0;
int paxi_static_memory_index = 510;
int paxi_last_addr = 0;

/* Functions help us write a more expressive grammar.  It is
   possible to inline some of these when performance becomes
   a point of interest.
 */
char* mangle_var_name();
int   allocate(int);
void  handle_global(void);
void  handle_array(char*, int);
void  handle_parameter(void);
void  handle_local_variable(void);
void  duplicate_symbol_error(void);
void  generate(int, int, int);
int   retrieve(int);
struct symbol* reference(char*, int);

/* Addresses for temporary memory.  Used by opcodes to derefence memory
   and perform arithmetic.  These should never be modified during runtime
   so are declared const */
const static int TEMP0 = 500, TEMP1 = 501, TEMP2 = 502, TEMP3 = 503, TEMP4 = 504,
                 TEMP5 = 505, TEMP6 = 506, TEMP7 = 507, TEMP8 = 508, TEMP9 = 509;

/* These make type information smaller to store and faster to check
   (rather than using a string). By using powers of two, we can use
   bit masks to indicate that a referenced symbol can be any of a set
   of types.
*/
enum types
{
  variable_type  =  1,
  array_type     =  2,
  local_type     =  4,
  parameter_type =  8, 
  procedure_type = 16
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
    {
      if (!lookup(symtable, yylval.str))
        {
          int result = insert(symtable, paxi_current_scope, procedure_type, paxi_procedure_arity, 0);
        }
      else
        {
          duplicate_symbol_error();
        }
    }
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

/* Stack Policy: Leave nothing. */
assignment: variable '=' arithmetic_expression {
              $<val>$ = $<val>1;
              generate(POPD_OP, TEMP1,     0); // arithmetic expression value
              generate(POPD_OP, TEMP2,     0); // variable address
              generate(MIT_OP,  TEMP2, TEMP1); // move value into address
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

quantity: variable { /* replace address with value */
            $<val>$ = $<val>1;
            generate( POPD_OP,  TEMP1,     0); // get the address
            generate( MIF_OP,   TEMP2, TEMP1); // dereference
            generate( PUSHD_OP, TEMP2,     0); // store the value
          }
  |       tINT { /* push value in $1 */
            $<val>$ = $<val>1;
            generate( PUSHI_OP, $<val>1, 0);
          }
  |       call { /* nothing yet */ 
          }
  |       tCHAR {
            $<val>$ = $<val>1;
            generate( PUSHI_OP, $<val>1, 0);
          }
  ;


/* Set $$ to the location of the variable or array at index */
/* Stack Policy: leaves an ADDRESS */
variable: tID {
            $<val>$ = (reference($<str>1, variable_type | local_type | parameter_type)->location);
            generate( PUSHI_OP, $<val>$, 0);
          }
  |       tID '[' arithmetic_expression ']' {
            $<val>$ = (reference($<str>1, array_type)->location);
            generate( PUSHI_OP, $<val>$,    0);     // move array address onto stack
            generate( POPD_OP,  TEMP1,      0);     // move tID address to temp
            generate( POPD_OP,  TEMP2,      0);     // move arithmetic_expr into temp
            generate( ADD_OP,   TEMP1,  TEMP2);     // calculate the offset
            generate( PUSHD_OP, TEMP1,      0);     // leave calculated addr on stack
          }
  ;

/* Leave nothing */
read_statement: tREAD '(' variable ')' { generate(GETS_OP, $<val>3, 0); }
  |   tREADSTR '(' tID ')'
  ;

/* Leave nothing */
write_statement: tWRITE '(' arithmetic_expression ')' {
                   generate(POPD_OP, TEMP2,     0);
                   generate( MOV_OP, TEMP1, TEMP2);
                   generate(PUTI_OP, TEMP1,     0);
                 }
  |              tWRITESTR '(' tSTRING ')' { }
  |              tWRITESTR '(' tID ')' {
                   $<val>$ = (reference($<str>3, variable_type)->location);
                   generate(PUTS_OP, $<val>$, 0);
                 }
  ;

line_statement: tLINE { generate(LINE_OP, 0, 0); }
  ;

/* Stack Policy: leaves a VALUE */
arithmetic_expression:
      arithmetic_expression add_operator arithmetic_term {
        generate( POPD_OP,  TEMP2,     0);     // move term into addr (order?)
        generate( POPD_OP,  TEMP1,     0);     // move expr into addr (order?)
        generate( $<val>2,  TEMP1, TEMP2);     // calculate the sum
        generate( PUSHD_OP, TEMP1,     0);     // move the result onto the stack
        $<val>$ = TEMP1;
      }
  |   arithmetic_term
  ;

/* Stack Policy: leaves a VALUE */
arithmetic_term:
      arithmetic_term mult_operator arithmetic_factor {
        generate( POPD_OP,  TEMP2,     0);     // move term into addr (order?)
        generate( POPD_OP,  TEMP1,     0);     // move expr into addr (order?)
        generate( $<val>2,  TEMP1, TEMP2);   // calculate the sum
        generate( PUSHD_OP, TEMP1,     0);     // move the result onto the stack
        $<val>$ = TEMP1;
      }
  |   arithmetic_factor
  ;

/* Stack Policy: do nothing */
arithmetic_factor: quantity                   
  |   '(' arithmetic_expression ')' {
         $<val>$ = $<val>2;
       }

/* Returning the op saves logical checks */
add_operator: '+' { $<val>$ = ADD_OP; }
  |           '-' { $<val>$ = SUB_OP; }
  ;

/* Returning the op saves logical checks */
mult_operator: '*' { $<val>$ = MUL_OP; }
  |            '/' { $<val>$ = DIV_OP; }
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
      int type = variable_type;
      int size = 1;
      int location = allocate(size);
      int result = insert(symtable, name, type, size, location);
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
    }
  else
    {
      duplicate_symbol_error();
    }
}

/* Reserves space for global variables and arrays. */ 
int allocate(int size) 
{
  // We need to keep track of the beginning of the memory being
  // allocated.  Then, we increase the index to 'consume' the
  // space.
  int location = paxi_static_memory_index;
  paxi_static_memory_index += size;
  return location;
}

/* Adds the opcode, arg1, and arg2 to the code store.  This is used to
   build up the PVM instructions during parsing.
*/
void generate(int opcode, int arg1, int arg2) {
  paxi_code[paxi_code_length++] = opcode;
  paxi_code[paxi_code_length++] = arg1;
  paxi_code[paxi_code_length++] = arg2;
}

/* Retrieves one integer from the code store array.
   Used to emit the resulting PVM instructions to a file.
*/
int retrieve(int index) {
  return paxi_code[index];
}

/* Returns the symbol table entry corresponding to the name.  It is
   possible to specify the type using a bitwise operation if a range
   of symbol table entries is allowed.
   
   For example:
   reference("whatever", variable_type | local_type);
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
      printf("Symbol not found.");
      return NULL;
    }
  // if something was found, but it wasn't the specified type, bail out.
  // by using a bitwise operation, we can specify multiple acceptable types
  // instead of repeatedly invoking reference with different types.
  else if ((sym->type & type) == 0)
    {
      printf("Symbol %s was wrong type. Want %d, Got %d, %d\n", name, type, sym->type, (sym->type & type));
      return sym;
    }
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

/* Reported when a syntax error exists. */
void duplicate_symbol_error(void)
{
  printf("%-20s  **Identifer already in use**\n", yylval.str);
}

/* Writes the generated code store to stdout. */
void emit(void) {
  int i;
  for (i = 0; i < paxi_code_length; i++) {
    printf("%d\t", retrieve(i));
    if ((i-2) % 3 == 0) { printf("\n"); }
  }
}

int main() {
  symtable = setupSymbolTable();
  yydebug = 0;
  yyparse();
  emit();
  return 0;
}
