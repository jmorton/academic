%{
  #include <stdlib.h>
  #include "paxi.tab.h"  
  int global_line_count = 1;
  char linebuf[500];
  char *strings[512];
  int string_count = 0;
%}

ws           [ \t]+
comment      \/\/.+
newline      [\n]
identifier   [a-zA-Z_][a-zA-Z0-9_]*
integer      -?[0-9]+
character    \'[^\']\'
string       \"[^"\\]*(\\.[^"\\]*)*\"

%%

{ws}         { /* ignore */ }
{character}  { character();               return(tCHAR);    }
"and"        return(tAND);
"not"        return(tNOT);
"or"         return(tOR); 
var          return(tVAR); 
array        return(tARRAY); 
do           return(tDO); 
else         return(tELSE); 
endo         return(tENDO); 
endif        return(tENDIF); 
endproc      return(tENDPROC); 
endwhile     return(tENDWHILE); 
"if"         return(tIF); 
line         return(tLINE); 
proc         return(tPROC); 
read         return(tREAD); 
readstr      return(tREADSTR); 
retval       return(tRETVAL); 
while        return(tWHILE); 
writestr     return(tWRITESTR); 
write        return(tWRITE); 
"+"          return('+'); 
"-"          return('-'); 
"*"          return('*'); 
"/"          return('/'); 
"="          return('=');
"<="         return(tLTE); 
">="         return(tGTE); 
"<"          return(tLT); 
">"          return(tGT); 
"#"          return(tNE); 
"("          return('('); 
")"          return(')'); 
"["          return('['); 
"]"          return(']'); 
","          return(tCOMMA); 
";"          return(tSEMI); 
"\""         return(tDQUOTE); 
"'"          return(tSQUOTE); 
{comment}    {} // return(tCOMMENT);
{identifier} { identifier();              return(tID);      }
{integer}    { integer();                 return(tINT);     }
{string}     { string();                  return(tSTRING);  }
\n.*         { increment_newline();
               strncpy(linebuf, yytext+1, sizeof(linebuf));
               yyless(1);
             }
.            { printf("Fatal Lexing Error on %d", global_line_count); return 0;      }

%%

int identifier() {
  // Add to symbol table, return symbol table entry.
  yylval.str = (char *)strdup(yytext);
  return 0;
}

int integer() {
  yylval.val = atoi(yytext);
  return 0;
}

int string() {
  char *substring = (char*) calloc(yyleng-1, sizeof(char));
  strncpy(substring, yytext+1, yyleng-2);
  strings[string_count++] = substring;
  yylval.str = substring;
  return 0;
}

int character() {
  char *substring = (char*) calloc(2, sizeof(char));
  strncpy(substring, yytext+1, 1);
  strings[string_count++] = substring;
  yylval.val = yytext[1];
  return 0;
}

int comment() {
  printf("\[cmt:%s] ", yytext);
  return 0;
}

int increment_newline() {
  ++global_line_count;
  return 0;
}
