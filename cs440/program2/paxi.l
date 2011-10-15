%{
  #include "tokens.h"
  int global_line_count = 1;
%}

ws           [ \t]+
comment      \/\/.+
newline      [\n]
identifier   [a-zA-Z_][a-zA-Z0-9_]*
integer      [0-9]+
character    '[a-zA-Z0-9]'
string       \"[^"\\]*(\\.[^"\\]*)*\"

%%

{ws}         { /* ignore */ }
and          { return(tAND); }
or           { return(tOR); }
not          { return(tNOT); }
var          { return(tVAR); }
array        { return(tARRAY); }
do           { return(tDO); }
else         { return(tELSE); }
endo         { return(tENDO); }
endif        { return(tENDIF); }
endproc      { return(tENDPROC); }
endwhile     { return(tENDWHILE); }
if           { return(tIF); }
line         { return(tLINE); }
proc         { return(tPROC); }
read         { return(tREAD); }
readstr      { return(tREADSTR); }
retval       { return(tRETVAL); }
while        { return(tWHILE); }
writestr     { return(tWRITESTR); }
write        { return(tWRITE); }
"+"          { return(tPLUS); }
"-"          { return(tMINUS); }
"*"          { return(tMULTIPLY); }
"/"          { return(tDIVIDE); }
"="          { return(tEQUAL); }
"<"          { return(tLT); }
"<="         { return(tLE); }
">="         { return(tGE); }
">"          { return(tGT); }
"#"          { return(tTBD); }
"("          { return(tPO); }
")"          { return(tPC); }
"["          { return(tBO); }
"]"          { return(tBC); }
","          { return(tCOMMA); }
";"          { return(tSEMI); }
"\""         { return(tDQUOTE); }
"'"          { return(tSQUOTE); }
{comment}    { return(tCOMMENT); }
{identifier} { identifier();              return(tID); }
{integer}    { integer();                 return(tINT); }
{string}     { string();                  return(tSTRING); }
{character}  { character();               return(tCHAR); }
{newline}    { increment_newline();       return(tNEWLINE); }
.            { printf("error!!!");        return 0; }

%%

static char *strings[512];
static int string_count = 0;

int main(void) {

  printf("SCANNER:\n");
  printf("LINE %3d\t", 1);

  int last;
  while ( last = yylex() ) {
    printf("[%d] ", last);
  }

  printf("\nSTRINGS:\n");
  // Display all the strings we recognized.
  int i;
  for ( i = 0 ; i < string_count ; i++ ) {
    printf("%s\n", strings[i]);
  }

}

int identifier() {
  printf("[id:%s] ", yytext);
  return 0;
}

int integer() {
  printf("[num:%s] ", yytext);
  return 0;
}

int string() {
  char *substring = (char*) malloc(sizeof(char)*yyleng-1);
  strncpy(substring, yytext+1, yyleng-2);
  strings[string_count++] = substring;
  printf("[str:'%s'] ", substring);
  return 0;
}

int character() {
  printf("[chr:%s] ", yytext);
  return 0;
}

int comment() {
  printf("\[cmt:%s] ", yytext);
  return 0;
}

int increment_newline() {
  printf("\nLINE %3d\t", ++global_line_count);
  return 0;
}
