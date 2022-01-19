#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>


static void copymask(char *dst, char *src)
{
	int x, y;
	
	src += 128;
	for (y = 0; y < 32; y++)
	{
		src -= 4;
		for (x = 0; x < 4; x++)
			dst[x] = ~src[x];
		dst += 4;
	}
}


int main(int argc, char **argv)
{
	char *filename;
	char inbuf[256];
	char outbuf[256];
	FILE *fp;
	int count;
	
	if (argc != 3)
		return 1;
	filename = argv[1];
	fp = fopen(filename, "rb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		return 1;
	}
	count = (int)fread(inbuf, 1, 256, fp);
	if (count == 128)
	{
		copymask(outbuf, inbuf);
	} else if (count == 256)
	{
		copymask(outbuf + 128, inbuf);
		copymask(outbuf, inbuf + 128);
	} else
	{
		fprintf(stderr, "%s: wrong size\n", filename);
		return 1;
	}
	filename = argv[2];
	fp = fopen(filename, "wb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		return 1;
	}
	fwrite(outbuf, 1, count, fp);
	fclose(fp);
	return 0;
}
