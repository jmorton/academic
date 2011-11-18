/* Jon Morton
   CS440
   Program 4

   The major pieces of this parser (aside from the usual grammar, etc...):
   - Symbol table: contains the names and locations of arrays variables
     and procedures.
   - Code store: contains instruction triples (opcode and two arguments).
    
   The parser relies on stack conventions to perform runtime calculation of array
   addresses and arithmetic.  This convention is documented along with the part
   of the grammar where they are implemented.  It is important to consider these
   conventions when modifying this parser.

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
extern char linebuf[500];


/* Values shared by the paxi parser to generate code. Names explain
   purpose.  These should only be modified by one funcion although
   reading them anywhere is considered safe.  4096 is enough for now
   but will be changed later to a dynamic collection.
*/
int paxi_code_length = 0; // tracks code store length, should be a 
int paxi_code[40960*3];    // multiple of three since each opcode is
                          // exactly three int

/* For now, the compiler can handle 4k of string literals.  Obviously, this
   can be increased by using a dynamic array.  As string literals are parsed
   paxi_str_length is incremented by the string's length plus one for the null
   character.
*/
int paxi_str_offset = 0; // where the strings begin
int paxi_str_length = 0; // the total size used by strings
int paxi_str[8096];      // a buffer added to during compilation by literal()
                         // and output by emit()

/* Used by emit(), not set yet. */
int paxi_entry_point = 0;

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
void  backpatch(int, int, int, int);
int   literal(char*);
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


void yyerror(char *s)
  {
    fprintf(stderr, "line %d: %s:\n%s\n", global_line_count, s, linebuf);
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
%token tGT        // >=
%token tLT        // <=
%token tNE        // #
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

conditional: tIF boolean_expression {
                   generate(POPD_OP, TEMP1, 0);
                   // If expression is true, jump over statetement_list.
                   // Once we know where this is, we'll update the jump
                   // with that location.
                   $<val>1 = paxi_code_length;
                   generate( -1, -1, -1 );
                 }
                 statement_list {
                   // Once the statement list length is known, the first
                   // branch can be back patched.  However, we also need
                   // to jump over the else block using backpatching.
                   $<val>3 = paxi_code_length;
                   generate( -1, -1, -1 );
                   backpatch($<val>1, BEQ_OP, paxi_code_length, TEMP1);  // patch $1
                   // 
                 } else_clause {
                   // patch $3, the if block should jump over the else
                   // block statements.
                   backpatch($<val>3, B_OP, paxi_code_length, 0);
                 }
                 tENDIF
  ;

else_clause:  /* nothing */
  |   tELSE statement_list
  ;

loop: while_loop | do_loop
  ;


while_loop: tWHILE {
              // In order to evaluate the boolean expression we need to
              // jump back to it.
              $<val>1 = paxi_code_length;
            }
            boolean_expression {
              generate( POPD_OP, TEMP1, 0 );
              // If the boolean expression results in not zero it is true
              // so we must jump over the next instruction since it will
              // eventually contain a branch for the false condition over
              // the body of the while loop.
              generate( BNE_OP, paxi_code_length+6, TEMP1 );
              $<val>2 = paxi_code_length;
              generate( -1, -1, -1 );
            }
            statement_list {
              // Return to the beginning of the while loop
              generate(B_OP, ($<val>1), TEMP1);
              // Set branch operation when the statement is false
              backpatch($<val>2, B_OP, paxi_code_length, 0);
            }
            tENDWHILE
  ;

do_loop: tDO {
           // If the boolean expression evaluates to true, the instruction
           // will jump back here.
           $<val>1 = paxi_code_length;
         } statement_list tENDO tWHILE boolean_expression {
           generate( POPD_OP, TEMP1, 0 );
           // If the stack top is zero, it's false so we shouldn't branch
           // back to the beginning of the do block.  If it is true, one,
           // then branch back to the beginning of the 
           generate( BNE_OP, $<val>1, TEMP1 );
         }
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
read_statement: tREAD '(' variable ')' { generate(GETI_OP, $<val>3, 0); }
  |   tREADSTR '(' tID ')'
  ;

/* Leave nothing */
write_statement: tWRITE '(' arithmetic_expression ')' {
                   generate(POPD_OP, TEMP2,     0);
                   generate( MOV_OP, TEMP1, TEMP2);
                   generate(PUTI_OP, TEMP1,     0);
                 }
  |              tWRITESTR '(' tSTRING ')' {
                   // order matters, the string begins wherever the current
                   // string length actually is now.  After adding the literal
                   // the paxi_str_length would point to the end of the string.
                   generate( PUTS_OP, paxi_static_memory_index + paxi_str_length, 0 );
                   literal($<str>3);
                 }
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
        generate( $<val>2,  TEMP1, TEMP2);     // calculate the sum
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

/* Stack Policy: Take two, leave one */
boolean_expression: boolean_expression tOR boolean_term {
                      generate( POPD_OP,  TEMP2,      0 );    // 0. prep RHS
                      generate( POPD_OP,  TEMP1,      0 );    // 1. prep LHS
                      generate(   OR_OP,  TEMP1,  TEMP2 );    // 2. perform OR
                      generate(PUSHD_OP,  TEMP1,      0 );    // 3. push result
                    }
  |                 boolean_term {}
  ;

/* Stack Policy: Take two, leave one */
boolean_term: boolean_term tAND boolean_factor {
                generate( POPD_OP,  TEMP2,      0 );    // 0. prep RHS
                generate( POPD_OP,  TEMP1,      0 );    // 1. prep LHS
                generate(  AND_OP,  TEMP1,  TEMP2 );    // 2. perform AND
                generate(PUSHD_OP,  TEMP1,      0 );    // 3. push result
              }
  |   boolean_factor
  ;

/* Stack Policy: Take one, leave one */
boolean_factor: tNOT boolean_atom {
                  generate( POPD_OP,  TEMP1,      0 );
                  generate(  NOT_OP,  TEMP1,      0 );
                  generate(PUSHD_OP,  TEMP1,      0 );
                }
  |   boolean_atom
  ;

/* Stack Policy: Take two and leave one (0 or 1) */
/* TODO: Check correctness of jump addresses */
boolean_atom: '(' arithmetic_expression relational_operator arithmetic_expression ')' {
                /* Calculate locations in advance to keep generate statements
                   clear of clutter. ( op size * location size )
                 */
                int addr1 = paxi_code_length + (3 * 6); // address of true ops
                int addr2 = paxi_code_length + (3 * 7); // address after true ops

                generate( POPD_OP,  TEMP2,      0 );    // 0. prep LHS?
                generate( POPD_OP,  TEMP1,      0 );    // 1. prep RHS?
                generate(  SUB_OP,  TEMP1,  TEMP2 );    // 2. compare
                generate( $<val>3,  addr1,  TEMP1 );    // 3. jump over false ops
                generate(PUSHI_OP,      0,      0 );    // 4. save false value
                generate(    B_OP,  addr2,      0 );    // 5. jump over true ops
                generate(PUSHI_OP,      1,      0 );    // 6. save true value
                                                        // 7. some other operation
              }
  |   '(' boolean_expression ')'
  ;

relational_operator:
      '='  { $<val>$ = BEQ_OP; }
  |   tNE  { $<val>$ = BNE_OP; }
  |   tLT  { $<val>$ = BLT_OP; }
  |   tGT  { $<val>$ = BGT_OP; }
  |   tGTE { $<val>$ = BGE_OP; }
  |   tLTE { $<val>$ = BLE_OP; }
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

void backpatch(int location, int opcode, int arg1, int arg2) {
  paxi_code[location] = opcode;
  paxi_code[location+1] = arg1;
  paxi_code[location+2] = arg2;
}

/* Stores a copy of the string. */
int literal(char *str) {
  int i; // index of character for copied string
  int len = paxi_str_length + strlen(str);

  // Copy each character into the string literal array.
  for ( i = 0; paxi_str_length <= len; paxi_str_length++)
    {
      paxi_str[paxi_str_length] = str[i++];
    }

  return 0;
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
      fprintf(stderr,"Symbol %s was wrong type. Want %d, Got %d, %d\n", name, type, sym->type, (sym->type & type));
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
  fprintf(stderr, "%-20s  **Identifer already in use**\n", yylval.str);
}

/* Writes the header, code store, and string literals to stdout. */
void emit(void)
{
  // Header
  printf("%d %d %d %d ", paxi_code_length, paxi_static_memory_index, paxi_str_length, paxi_entry_point);
  // Code store
  int i;
  for (i = 0; i < paxi_code_length; i++) {
    printf("%d ", retrieve(i));
    // if ((i-2) % 3 == 0) { printf("\n"); }
  }
  // String literals
  for (i = 0; i < paxi_str_length; i++) {
    printf("%d ", paxi_str[i]);
  }  
}

int main() {
  symtable = setupSymbolTable();
  yydebug = 0;
  yyparse();
  emit();
  return 0;
}
