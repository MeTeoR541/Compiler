%{
#include "main.h"
#include "yacc.tab.h"
#include <string.h>
string string_buf;
void extract_index(char *s, int* index);
%}

%x single_line_comment
%x multi_line_comment
%x string_state

%%
\/\*    {BEGIN multi_line_comment;}
<multi_line_comment>\*\/  {BEGIN 0;}
<multi_line_comment>[^(\*\/)]*  {;}
\/\/    {BEGIN single_line_comment;}
<single_line_comment>[^\n]* {;}
<single_line_comment>\n {BEGIN 0;}
fun         { return FUN; }
println     { return PRINTLN; }
print       { return PRINT; }
var         { return VAR; }
int(\[[1-9][0-9]*\])+   { extract_index(yytext, &yylval.dim_index); return INT_VECTOR; }
int         { return INT_TOKEN; }
real(\[[1-9][0-9]*\])+   { extract_index(yytext, &yylval.dim_index); return REAL_VECTOR; }
real        { return REAL_TOKEN; }
[0-9]+      { yylval.intNum = atoi(yytext); return INTRGER; }
[0-9]+\.[0-9]+  { yylval.floatNum = atof(yytext); return REAL; }
[A-Za-z][A-za-z0-9\_]*  { strcpy(yylval.charNum, yytext); return IDENTIFIER; }
\"                          { string_buf = ""; BEGIN string_state; }
<string_state>\"            { strcpy(yylval.charNum, string_buf.c_str()); BEGIN 0; return STRING;}
<string_state>\\n           { string_buf += yytext; }
<string_state>.             { string_buf += yytext; }
=           { return yytext[0]; }
[+-]        { return yytext[0]; }
\*          { return yytext[0]; }
\/          { return yytext[0]; }
\(          { return yytext[0]; }
\)          { return yytext[0]; }
\{          { return yytext[0]; }
\}          { return yytext[0]; }
,           { return yytext[0]; }
:           { return yytext[0]; }
;           { return yytext[0]; }
[ \t\n]     {;}

%%

void extract_index(char *s, int* index) {
    int i = 1;
    char *token_ptr = strtok(s, "\[");
    token_ptr = strtok(NULL, "\]");
    *index = atoi(token_ptr);
    
}

int yywrap(void) {
    return 1;
}
