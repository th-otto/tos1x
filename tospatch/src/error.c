#include "tospatch.h"

/*** ---------------------------------------------------------------------- ***/

static void quit(int exitcode)
{
	closelog();
	exit(exitcode);
}

/*** ---------------------------------------------------------------------- ***/

void mainexit(int exitcode)
{
	if (!quiet && wait_key_at_end)
	{
		fputs(translate_msg(key_text), stdout);
		fflush(stdout);
		(void) readkey();
	}
	quit(exitcode);
}

/*** ---------------------------------------------------------------------- ***/

void error_handler(int code, const char *str)
{
	int c;

	print_str(lf_text);
	print_line(str);
	if (!(code & ERR_NOLINENO))
	{
		print_line(line_text, lineno);
		if (filenr != 0)
			print_line(batch_text, filenr);
		print_point();
	}
	print_str(lf_text);
	if (!(code & ERR_CONTINUE))
		mainexit(1);
	if ((code & ERR_QUEST) && !allyes)
	{
		if (!quiet)
		{
			print_line(key2_text);
			c = readkey();
			if (c == 0x1b)
				quit(1);
		} else
		{
			quit(1);
		}
	}
}	

/*** ---------------------------------------------------------------------- ***/

void user_error(const char *str)
{
	error_handler(0, str);
}

/*** ---------------------------------------------------------------------- ***/

void unexpected_eof(void)
{
	error_handler(0, unexpected_eof_err);
}

/*** ---------------------------------------------------------------------- ***/

void illegal_delimiter(void)
{
	error_handler(0, illegal_delimiter_err);
}

/*** ---------------------------------------------------------------------- ***/

void illegal_offset(void)
{
	error_handler(0, illegal_offset_err);
}

/*** ---------------------------------------------------------------------- ***/

void overflow(void)
{
	error_handler(ERR_CONTINUE, overflow_err);
}
