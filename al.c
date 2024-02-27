#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexicalanalyzer.h"

int alpha_yylex(void * yylval);

struct alpha_token_t {
    unsigned int numline;
    unsigned int numToken;
    char *content;
    char *type;
    struct alpha_token_t *alpha_yylex;
};

struct alpha_token_t *head = NULL;
struct alpha_token_t *tail = NULL;

void add_alpha_token_t(unsigned int numline, unsigned int numToken, char *content, char *type) {
    struct alpha_token_t *node = malloc(sizeof(struct alpha_token_t));
    if (!node) {
        perror("Failed to allocate memory for a new token");
        exit(EXIT_FAILURE);
    }

    node->numline = numline;
    node->numToken = numToken;
    node->content = strdup(content);
    node->type = strdup(type); //strdup makes sure the value of the string is null terminated

    /*IF STRDUP IS NOT AVAILABLE UNCOMMENT THE FOLLOWING*/ 

    /*
    node->content = malloc((strlen(content) + 1) * sizeof(char)); //+1 for the null terminating byte 
	strcpy(node->content, content);
	node->type=malloc((strlen(type) + 1) * sizeof(char));
	strcpy(node->type, type);
    */
    
    node->alpha_yylex = NULL;

    if (tail) {
        tail->alpha_yylex = node;
    } else {
        head = node;
    }
    tail = node;
}


void print_tokens(FILE *fptr) {
    struct alpha_token_t *tmp = head;

    fprintf(fptr, "--------------------        Lexical Analysis        --------------------\n");

    while (tmp) {
        const char *tokenType = (!strcmp(tmp->type, "STRING") || !strcmp(tmp->type, "IDENTIFIER")) ? "char*" :
                                (!strcmp(tmp->type, "INTEGER")) ? "integer" :
                                (!strcmp(tmp->type, "FLOAT")) ? "float" : "enumerated";

        fprintf(fptr, "%d:\t#%d \"%s\"\t%s\t<-%s\n", tmp->numline, tmp->numToken, tmp->content, tmp->type, tokenType);

        tmp = tmp->alpha_yylex;
    }
}

void free_tokens() {
    struct alpha_token_t *current = head;
    while (current) {
        struct alpha_token_t *alpha_yylex = current->alpha_yylex;
        free(current->content);
        free(current->type);
        free(current);
        current = alpha_yylex;
    }
    head = tail = NULL;
}

int main(int argc, char** argv) {

    // Open input file or use stdin
    yyin = (argc > 1) ? fopen(argv[1], "r") : stdin;
    if (!yyin) {
        fprintf(stderr, "Cannot read file: %s\n",argv[1]);
        return 1;
    }

    // Call the lexer function
    alpha_yylex(head);

    // Determine output destination based on arguments
    FILE *fptr = stdout; // Default to stdout
    if (argc == 3) {
        fptr = fopen(argv[2], "w");
        if (!fptr) {
            fprintf(stderr, "Cannot write to file: %s\n", argv[2]);
            return 1;
        }
    }

    // Print tokens to the chosen destination
    print_tokens(fptr); // Assuming print_tokens now takes a FILE* as argument

    // Close files if necessary
    if (yyin != stdin) fclose(yyin);
    if (fptr != stdout) fclose(fptr);

    return 0;
}