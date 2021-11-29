#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <osbind.h>

const char *norm_name = "keytblnorm";
const char *shift_name = "keytblshift";
const char *caps_name = "keytblcaps";

FILE *out;


static void print_table(const char *table, const char *name)
{
	int i, j;
	uint8_t c;
	
	fprintf(out, "/* %08lx */\n", (unsigned long)table);
	fprintf(out, "uint8_t const %s[128] = {\n", name);
	for (i = 0; i < 16; i++)
	{
		fprintf(out, "    ");
		for (j = 0; j < 8; j++)
		{
			c = table[i * 8 + j] & 0xff;
			if (c == 0)
				fprintf(out, "   0");
			else if (c == '\'')
				fprintf(out, "'\\''");
			else if (c == '\\')
				fprintf(out, "'\\\\'");
			else if (c < 0x20 || c >= 0x7f)
				fprintf(out, "0x%02x", c);
			else
				fprintf(out, " '%c'", c);
			fprintf(out, "%s", j == 7 ? (i == 15 ? "" : ",") : ", ");
		}
		fprintf(out, "\n");
	}
	fprintf(out, "};\n\n");
}


int main(void)
{
	register _KEYTAB *curtable;
	
	out = stdout;
	curtable = Keytbl((void *)-1L, (void *)-1L, (void *)-1L);
	print_table(curtable->unshift, norm_name);
	print_table(curtable->shift, shift_name);
	print_table(curtable->caps, caps_name);
	
	return 0;
}
