#include <stdio.h>
#include <string.h>
#include <stdlib.h>
extern char *removerng(char*, char, char);
int main(int argc, char **argv){
	if(argc < 4)
		return 1;
	char *word = malloc(strlen(argv[1]) + 1);
	strcpy(word, argv[1]);
	char lowerBound = *argv[2];
	char upperBound = *argv[3];
	printf("input: %s\n", word);
	removerng(word, lowerBound, upperBound);
	printf("result: %s\n", word);
	return 0;
}
