%{
#include "tokens.h"
int global_line_count = 1;
%}

ws           [ \t]+
newline      [\n]
identifier   [a-zA-Z_][a-zA-Z0-9_]*
integer      [0-9]+
character    '[a-zA-Z0-9]'
string       \"[^"\\]*(\\.[^"\\]*)*\"
comment      [#].+

%%

{ws}         { /* ignore */ }

and          { return(tAND); } 
or	     { return(tOR); } 
not	     { return(tNOT); } 
var	     { return(tVAR); } 
array	     { return(tARRAY); } 
do	     { return(tDO); } 
else	     { return(tELSE); } 
endo	     { return(tENDO); } 
endif	     { return(tENDIF); } 
endproc      { return(tENDPROC); } 
endwhile     { return(tENDWHILE); } 
if	     { return(tIF); } 
line	     { return(tLINE); } 
proc	     { return(tPROC); } 
read	     { return(tREAD); } 
readstr      { return(tREADSTR); } 
retval	     { return(tRETVAL); } 
while	     { return(tWHILE); } 
writestr     { return(tWRITESTR); } 
write	     { return(tWRITE); } 
"+"	     { return(tPLUS); } 
"-"	     { return(tMINUS); } 
"*"	     { return(tMULTIPLY); } 
"/"	     { return(tDIVIDE); } 
"="	     { return(tEQUAL); } 
"<"	     { return(tLT); } 
"<="	     { return(tLE); } 
">="	     { return(tGE); } 
">"	     { return(tGT); }
";"          { return(tSEMI); }

{identifier} { identifier();        return(tID); }
{integer}    { integer();           return(tINT); }
{string}     { string();            return(tSTRING); }
{character}  { character();         return(tCHAR); }
{newline}    { increment_newline(); return(tNEWLINE); }
{comment}    { comment();           return(tCOMMENT); }

%%

int identifier() {
    printf("\tid:  %20s\n", yytext);
    return 0;
}

int integer() {
    printf("\tint: %20s\n", yytext);
    return 0;
}

int string() {
    printf("\tstr: %20s\n", yytext);
    return 0;
}

int character() {
  printf("\tchr: %20s\n", yytext);
  return 0;
}

int comment() {
  printf("\tcmt: %20s\n", yytext);
  return 0;
}

int increment_newline() {
  ++global_line_count;  
  printf("\nLINE %3d\n", global_line_count);
  return 0;
}

