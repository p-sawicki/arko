#include <stdlib.h>
#include <stdio.h>
extern void reduce_contrast(void *, unsigned int);
int main(int argc, char **argv){
	if(argc < 3)
		return 1;
	FILE *f = fopen(argv[1], "r+b");
	fseek(f, 0, SEEK_END);
	unsigned int size = ftell(f);
	rewind(f);
	char *d = malloc(size);
	fread(d, 1, size, f);
	rewind(f);
	unsigned int rfactor = atoi(argv[2]);
	reduce_contrast(d, rfactor);
	fwrite(d, 1, size, f);
	return 0;
}
