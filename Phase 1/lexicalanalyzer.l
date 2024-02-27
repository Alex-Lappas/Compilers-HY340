%{
#include <stdlib.h>
#include <string.h>

#define YY_DECL int alpha_yylex(void * yylval)
#define MAX_STR_LEN 1000000

void add_alpha_token_t(unsigned int numline, unsigned int numToken, char *content, char *type); 

int count = 0;
char commend[50] ="NESTED COMMENT END";
char commstart[50] = "NESTED COMMENT START";
char nestednum[sizeof(int)*8+1];
int comment_depth;
char string_buffer[MAX_STR_LEN];
int string_buffer_index = 0;
void add_to_string(char c);
void clear_string_buffer();

%}

%option outfile = "./lexicalanalyzer.c"
%option noyywrap
%option yylineno

SPACE           [\r\n \t\v]
INTEGER         ([0-9])*
FLOAT           ([0-9])*\.([0-9])*
IDENTIFIER      [a-zA-Z]([a-zA-Z0-9_])*
COMMENTSINGLE   "//".*

%x COMMENT 
%x STRING

%%

"if"            {add_alpha_token_t(yylineno, ++count,"if", "KEYWORD IF");}
"else"          {add_alpha_token_t(yylineno, ++count,"else", "KEYWORD ELSE"); }
"while"         {add_alpha_token_t(yylineno, ++count,"while", "KEYWORD WHILE");}
"for"           {add_alpha_token_t(yylineno, ++count,"for", "KEYWORD FOR"); }
"function"      {add_alpha_token_t(yylineno, ++count,"function", "KEYWORD FUNCTION");}
"return"        {add_alpha_token_t(yylineno, ++count,"return", "KEYWORD RETURN"); }
"break"         {add_alpha_token_t(yylineno, ++count,"break", "KEYWORD BREAK");}
"continue"      {add_alpha_token_t(yylineno, ++count,"continue", "KEYWORD CONTINUE");}
"and"           {add_alpha_token_t(yylineno, ++count,"and", "KEYWORD AND"); }
"not"           {add_alpha_token_t(yylineno, ++count,"not", "KEYWORD NOT"); }
"or"            {add_alpha_token_t(yylineno, ++count,"or", "KEYWORD OR"); }
"local"         {add_alpha_token_t(yylineno, ++count,"local", "KEYWORD LOCAL"); }
"true"          {add_alpha_token_t(yylineno, ++count,"true", "KEYWORD TRUE"); }
"false"         {add_alpha_token_t(yylineno, ++count,"false", "KEYWORD FALSE"); }
"nil"           {add_alpha_token_t(yylineno, ++count,"nil", "KEYWORD NIL"); }
"="             {add_alpha_token_t(yylineno, ++count,"=", "OPERATOR ASSIGN"); }
"+"             {add_alpha_token_t(yylineno, ++count,"+", "OPERATOR PLUS"); }
"-"             {add_alpha_token_t(yylineno, ++count,"-", "OPERATOR MINUS"); }
"*"             {add_alpha_token_t(yylineno, ++count,"*", "OPERATOR MULTIPLY");}
"/"             {add_alpha_token_t(yylineno, ++count,"/", "OPERATOR DIVIDE");}
"%"             {add_alpha_token_t(yylineno, ++count,"%", "OPERATOR MODULO"); }
"=="            {add_alpha_token_t(yylineno, ++count,"==", "OPERATOR EQUAL"); }
"!="            {add_alpha_token_t(yylineno, ++count,"!=", "OPERATOR NOT EQUAL");}
"++"            {add_alpha_token_t(yylineno, ++count,"++", "OPERATOR PLUS PLUS");}
"--"            {add_alpha_token_t(yylineno, ++count,"--", "OPERATOR MINUS MINUS"); }
">"             {add_alpha_token_t(yylineno, ++count,">", "OPERATOR GREATER"); }
"<"             {add_alpha_token_t(yylineno, ++count,"<", "OPERATOR LESS"); }
">="            {add_alpha_token_t(yylineno, ++count,">=", "OPERATOR GREATER EQUAL"); }
"<="            {add_alpha_token_t(yylineno, ++count,"<=", "OPERATOR LESS EQUAL");}
"{"             {add_alpha_token_t(yylineno, ++count,"{", "PUNCTUATION LEFT CURLY BRACKET");}
"}"             {add_alpha_token_t(yylineno, ++count,"}", "PUNCTUATION RIGHT CURLY BRACKET");}
"["             {add_alpha_token_t(yylineno, ++count,"[", "PUNCTUATION LEFT SQUARE BRACKET");}
"]"             {add_alpha_token_t(yylineno, ++count,"]", "PUNCTUATION RIGHT SQUARE BRACKET");}
"("             {add_alpha_token_t(yylineno, ++count,"(", "PUNCTUATION LEFT PARENTHESIS");}
")"             {add_alpha_token_t(yylineno, ++count,")", "PUNCTUATION RIGHT PARENTHESIS");}
";"             {add_alpha_token_t(yylineno, ++count,";", "PUNCTUATION SEMICOLON");}
","             {add_alpha_token_t(yylineno, ++count,",", "PUNCTUATION COMMA");}
":"             {add_alpha_token_t(yylineno, ++count,":", "PUNCTUATION COLON");}
"::"            {add_alpha_token_t(yylineno, ++count,"::", "PUNCTUATION DOUBLE COLON");}
"."             {add_alpha_token_t(yylineno, ++count,".", "PUNCTUATION DOT");}
".."            {add_alpha_token_t(yylineno, ++count,"..", "PUNCTUATION DOUBLE DOT");}

{FLOAT}         {add_alpha_token_t(yylineno, ++count, yytext, "FLOAT");}
{INTEGER}       {add_alpha_token_t(yylineno, ++count, yytext , "INTEGER");}
{IDENTIFIER}    {add_alpha_token_t(yylineno, ++count, yytext , "IDENTIFIER");}
{COMMENTSINGLE} {add_alpha_token_t(yylineno, ++count, "//", "SINGLE LINE COMMENT");}
{SPACE}         {}

"/*" {
    BEGIN(COMMENT);
    comment_depth = 1; // Initialize or increment a counter for nested comments
    add_alpha_token_t(yylineno, ++count, "/*" , "MULTILINE COMMENT START");
}

<COMMENT>"/*" {
    comment_depth++; // Increment for nested comment
    //itoa(comment_depth,nestednum,10);
    //strcat(commstart, nestednum);
    add_alpha_token_t(yylineno, ++count, "/*" , commstart);
}

<COMMENT>"*/" {
    //itoa(comment_depth,nestednum,10);
    comment_depth--;
    if(comment_depth == 0) {
        add_alpha_token_t(yylineno, ++count, "*/" , "MULTILINE COMMENT END");
        BEGIN(INITIAL); //reset to initial state
    } else {
        //strcat(commend, nestednum); //HERE HERE IF NOT CLEAR 
        add_alpha_token_t(yylineno, ++count, "*/" , commend);
    }
}

<COMMENT>.|\n { /* Ignore everything inside comments */ }

<COMMENT><<EOF>> { //if we reach EOF and we are in COMMENT state then unclosed comments exist.
     if(comment_depth > 0) {
        fprintf(stderr, "Error : Unclosed comments exist!\n"); exit(1);
    }
}

\" { 
    clear_string_buffer(); // Reset the buffer for a new string
    BEGIN(STRING); 
}

<STRING>\\n { add_to_string('\n'); }
<STRING>\\t { add_to_string('\t'); }
<STRING>\\\" { add_to_string('\"'); }
<STRING>\\\\ { add_to_string('\\'); }

<STRING>\\[^\n\t\"\\] {
    fprintf(stderr, "Warning: Invalid escape sequence \\%c in string at line %d\n", yytext[1], yylineno);
    add_to_string(yytext[1]);
}

<STRING>\" {
    add_alpha_token_t(yylineno, ++count, string_buffer, "STRING");
    BEGIN(INITIAL);
}

<STRING>.|\n { add_to_string(yytext[0]); } //add normal characters

<STRING><<EOF>> {
    fprintf(stderr, "Error: Unclosed string detected at end of file on line %d.\n", yylineno);
    exit(1);
}

. { fprintf(stderr, "undefined input %s in line %d\n", yytext, yylineno); exit(1);}


%%

//helper function to reset buffer for strings and its index
void clear_string_buffer() {
    memset(string_buffer, 0, MAX_STR_LEN); // Clear the buffer
    string_buffer_index = 0; // Reset the buffer index
}

// helper function to add a character to the buffer
void add_to_string(char c) {
    if (string_buffer_index < MAX_STR_LEN - 1) {
        string_buffer[string_buffer_index++] = c;
        string_buffer[string_buffer_index] = '\0'; // Ensure null-termination
    } else {
        fprintf(stderr, "String buffer overflow at line %d.\n", yylineno);
        exit(1);
    }
}