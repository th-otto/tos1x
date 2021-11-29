#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

unsigned char inbuf[4096];
unsigned char outbuf[4096];

int main(int argc, char **argv)
{
	const char *infilename;
	const char *outfilename;
	FILE *fp;
	int i, j;
	
	if (argc != 3)
		return 1;
	infilename = argv[1];
	outfilename = argv[2];
	fp = fopen(infilename, "rb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", infilename, strerror(errno));
		return 1;
	}
	if (fread(inbuf, sizeof(inbuf), 1, fp) != 1)
	{
		fclose(fp);
		fprintf(stderr, "%s: wrong filesize\n", infilename);
		return 1;
	}
	fclose(fp);
	
	for (i = 0; i < 256; i++)
	{
		for (j = 0; j < 16; j++)
		{
			outbuf[j * 256 + i] = inbuf[i * 16 + j];
		}
	}
	
	fp = fopen(outfilename, "wb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", outfilename, strerror(errno));
		return 1;
	}
	if (fwrite(outbuf, sizeof(outbuf), 1, fp) != 1)
	{
		fclose(fp);
		fprintf(stderr, "%s: write error\n", infilename);
		return 1;
	}
	fclose(fp);
	
	return 0;
}
