How to compile:
1. To generate the .h and .c files you need to run the command: flex --header-file=lexicalanalyzer.h -o lexicalanalyzer.c lexicalanalyzer.l
2. gcc al.c lexicalanalyzer.c
3. ./a.out (file for analysis) (optional file for output)   -If output file isn't provided output is directed to stdout

Extra information:
Max size for strings is 100000
When error exists we do not provide lexical analysis (wasn't specified in pdf)

Team Members:

Alexander-Ilias Lappas csd4488
Theodora Symeonidou csd4748
Panagiotis Georgitseas csd4609
