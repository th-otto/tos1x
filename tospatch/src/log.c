#include "tospatch.h"
#include <stdarg.h>

bool logflg;
static char const logname[] = "tos.log";
static bool dolog;
static FILE *loghdl;

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

/*
 * check for keypress after each line printed
 */
void prline(void)
{
	int c;
	
	if (!keypressed())
		return;
	
	fflush(stdout);
	c = readkey();
	if (c != 0x1b)
	{
		/* pause and wait for character */
		c = readkey();
	}
	if (c == 0x1b)
	{
		/* abort */
		fputs(translate_msg(abort_text), stderr);
		mainexit(1);
	}
}

/*** ---------------------------------------------------------------------- ***/

void logline(const char *str)
{
	if (dolog && loghdl)
		fputs(str, loghdl);
}

/*** ---------------------------------------------------------------------- ***/

/*
 * print_line: output a zero-terminated string
 */
static void print_str_va(const char *str, va_list args)
{
	char buf[1024];

	vsprintf(buf, str, args);
	if (!quiet)
		fputs(buf, stdout);
	logline(buf);
	prline();
}

void print_str(const char *str, ...)
{
	va_list args;
	
	va_start(args, str);
	print_str_va(str, args);
	va_end(args);
}

void print_line(const char *str, ...)
{
	va_list args;
	
	va_start(args, str);
	print_str_va(translate_msg(str), args);
	va_end(args);
}

/*** ---------------------------------------------------------------------- ***/

void openlog(void)
{
	if (logflg)
	{
		print_line(logopen_text);
		print_str(space_text);
		print_str(logname);
		loghdl = fopen(logname, "w");
		if (loghdl == NULL)
		{
			logflg = false;
			print_line(error_text);
			mainexit(10);
		} else
		{
			print_line(ok_text);
		}
	}
}

/*** ---------------------------------------------------------------------- ***/

void closelog(void)
{
	dolog = false;
	if (logflg && loghdl != NULL)
	{
		print_line(logclose_text);
		print_str(space_text);
		print_str(logname);
		if (fclose(loghdl) != 0)
		{
			print_line(error_text);
		} else
		{
			print_line(ok_text);
		}
		loghdl = NULL;
	}
}

/*** ---------------------------------------------------------------------- ***/

void setlog(void)
{
	dolog = logflg;
}

/*** ---------------------------------------------------------------------- ***/

void print_point(void)
{
	print_str(".");
}
