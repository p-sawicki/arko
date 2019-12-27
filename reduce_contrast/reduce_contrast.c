#include <stdlib.h>
#include <stdio.h>
int main(int argc, char **argv){
	if(argc < 3)
		return 1;
	FILE *f = fopen(argv[1], "r+b");
	double rfactor = atoi(argv[2]);
	fseek(f, 10, SEEK_SET);
	unsigned int pixelDataOffset;
	fread(&pixelDataOffset, 4, 1, f);
	fseek(f, 4, SEEK_CUR);
	unsigned int imageWidth, imageHeight;
	fread(&imageWidth, 4, 1, f);
	fread(&imageHeight, 4, 1, f);
	fseek(f, pixelDataOffset, SEEK_SET);
	int pixs = 3 * imageHeight * (imageWidth + imageWidth % 4);
	rfactor /= 128;
	rfactor = 1 - rfactor;
	unsigned int j = 0;
	do{
		fseek(f, pixelDataOffset + j, SEEK_SET);
		unsigned char pixels[256];
		unsigned int toRead = pixs < 256 ? pixs : 256;
		fread(pixels, 1, toRead, f);
		unsigned int i = 0;
		for(; i < toRead; ++i)
			pixels[i] = rfactor * (pixels[i] - 128) + 128;
		fseek(f, pixelDataOffset + j, SEEK_SET);
		fwrite(pixels, 1, toRead, f);
		pixs -= toRead;
		j += toRead;
	}while(pixs > 0);
	fclose(f);
	return 0;
}
