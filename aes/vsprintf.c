#include "../alcyon/libsrc/lib.h"

char __pname[] = "";					/* Program name         */
char *_break;					/* -> Program break location */
FILE _iob[3];

int vsprintf(P(char *) str, P(const char *) fmt, P(va_list) args)
PP(char *str;)
PP(const char *fmt;)
PP(va_list args;)
{
	register int ret;
	FILE *stream;

	stream = (FILE *)&str;
	ret = __doprint(stream, fmt, 1, args);
	*str = '\0';
	return ret;
}
