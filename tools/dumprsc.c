/*
 * Quick hack to dump the glued resource data out of the ROMs
 */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include "../common/ctrycode.h"

#define FILESIZE (192 * 1024L)
#define TOSADDR 0xfc0000L

static uint32_t rsc_read;
static uint32_t tosrsc;
static uint16_t rscsize;
static uint16_t offsets[5];
const char *langext;

static uint8_t buffer[FILESIZE];

static uint16_t getbe16(uint32_t addr)
{
	addr -= TOSADDR;
	return (buffer[addr] << 8) | buffer[addr + 1];
}


static uint32_t getbe32(uint32_t addr)
{
	return ((uint32_t)getbe16(addr) << 16) | (uint32_t)getbe16(addr + 2);
}


static int write_file(const char *name, uint32_t addr, uint32_t size)
{
	char filename[20];
	FILE *fp;
	
	sprintf(filename, name, langext);
	fp = fopen(filename, "wb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		return 0;
	}
	if (fwrite(buffer + addr - TOSADDR, 1, size, fp) != size)
	{
		fprintf(stderr, "%s: %s\n", filename, "write error");
		return 0;
	}
	fclose(fp);
	printf("wrote %s\n", filename);
	return 1;
}


int main(int argc, char **argv)
{
	int i;
	const char *filename;
	FILE *fp;
	uint16_t lang;
	uint16_t tosversion;
	
	if (argc != 2)
	{
		fprintf(stderr, "missing filename\n");
		return EXIT_FAILURE;
	}

	filename = argv[1];
	fp = fopen(filename, "rb");
	if (fp == NULL)
	{
		fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		return EXIT_FAILURE;
	}
	if (fread(buffer, 1, FILESIZE, fp) != FILESIZE)
	{
		fprintf(stderr, "%s: %s\n", filename, "read error");
		return EXIT_FAILURE;
	}
	fclose(fp);
	lang = getbe16(TOSADDR + 28) >> 1;
	tosversion = getbe16(TOSADDR + 2);
	if (tosversion == 0x100)
	{
		switch (lang)
		{
		case CTRY_FR:
			rsc_read = 0xfee79c;
			langext = "fr";
			break;
		case CTRY_DE:
			rsc_read = 0xfee4b0;
			langext = "de";
			break;
		case CTRY_US:
			rsc_read = 0xfee800;
			langext = "us";
			break;
		default:
			fprintf(stderr, "%s: %s %d\n", filename, "unsupported tos language", lang);
			return EXIT_FAILURE;
		}
	} else if (tosversion == 0x102)
	{
		switch (lang)
		{
		default:
			fprintf(stderr, "%s: %s %d\n", filename, "unsupported tos language", lang);
			return EXIT_FAILURE;
		}
	} else
	{
		fprintf(stderr, "%s: %s\n", filename, "wrong TOS version");
		return EXIT_FAILURE;
	}
	
	rscsize = getbe16(rsc_read + 20);
	tosrsc = getbe32(rsc_read + 24);
	
	for (i = 0; i < 5; i++)
	{
		offsets[i] = getbe16(tosrsc + i * 2);
		printf("%d: %08x\n", i, tosrsc + (offsets[i] & -2));
	}
	printf("end: %08x\n", tosrsc + rscsize);
	
	write_file("gem%s.rsc", tosrsc + 10, offsets[0] - 10);
	write_file("desk%s.rsc", tosrsc + (offsets[0] & -2), offsets[1] - offsets[0]);
	write_file("icon%s.dat", tosrsc + (offsets[1] & -2), offsets[2] - offsets[1]);
	write_file("desk%s.inf", tosrsc + (offsets[2] & -2), offsets[3] - offsets[2]);
	write_file("fmt%s.rsc", tosrsc + (offsets[3] & -2), offsets[4] - offsets[3]);
	write_file("garb%s.dat", tosrsc + (offsets[4] & -2), rscsize - offsets[4]);
	
	return EXIT_SUCCESS;
}
