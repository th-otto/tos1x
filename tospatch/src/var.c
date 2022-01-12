#include "tospatch.h"

#define MAX_VAR_LENGTH 16
#define MAX_VARS 1024

char const var_date[] = "DATE";
char const var_day[] = "DAY";
char const var_month[] = "MONTH";
char const var_year[] = "YEAR";
char const var_crc[] = "CRC";
char const var_base[] = "BASE";
char const var_length[] = "LENGTH";
char const var_reloc[] = "RELOCADR";
char const var_width[] = "WIDTH";

VAR variables[MAX_VARS];

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

static int getvc(char c)
{
	if (c == '_')
		return c;
	if (ISDIGIT(c))
		return c;
	if (ISUPPER(c))
		return c;
	if (ISLOWER(c))
		return TOUPPER(c);
	return -1;
}

/*** ---------------------------------------------------------------------- ***/

void get_vname(char **batchptr)
{
	int c;
	char *ptr = *batchptr;
	
	c = *ptr++;
	if (c != '.' || (c = getvc(*ptr)) < 0 || ISDIGIT(c))
		error_handler(0, illegal_name_err);
	*ptr++ = c;
	while ((c = getvc(*ptr)) >= 0)
		*ptr++ = c;
	*batchptr = ptr;
}

/*** ---------------------------------------------------------------------- ***/

VAR *search_var(const char *name, bool *isnew)
{
	VAR *found;
	int i;
	int c;
	char namebuf[MAX_VAR_LENGTH];

	for (i = 0; i < MAX_VAR_LENGTH - 1 && *name; i++)
	{
		c = getvc(*name);
		if (c < 0)
			break;
		namebuf[i] = c;
		name++;
	}
	namebuf[i] = '\0';
	
	found = NULL;
	if (isnew)
		*isnew = false;
	for (i = 0; i < MAX_VARS; i++)
	{
		if (variables[i].name[0] == '\0')
		{
			found = &variables[i];
			if (variables[i].name[1] == '\0')
				break;
			/*
			 * this is a variable which was undef'd.
			 * Reuse that slot.
			 */
		} else
		{
			if (strcmp(namebuf, variables[i].name) == 0)
				return &variables[i];
		}
	}
	if (found == NULL)
		error_handler(0, toomany_variables_err);
	if (isnew)
		*isnew = true;
	return found;
}

/*** ---------------------------------------------------------------------- ***/

void write_var(const char *name, long value)
{
	VAR *var;
	char namebuf[MAX_VAR_LENGTH];
	bool isnew;
	int i;
	int c;
	
	for (i = 0; i < MAX_VAR_LENGTH - 1 && *name; i++)
	{
		c = getvc(*name);
		if (c < 0)
			break;
		namebuf[i] = c;
		name++;
	}
	namebuf[i] = '\0';
	if (i == 0 || ISDIGIT(namebuf[0]))
		error_handler(0, illegal_name_err);
	var = search_var(namebuf, &isnew);
	strcpy(var->name, namebuf);
	var->value = value;
}

/*** ---------------------------------------------------------------------- ***/

long read_var(const char *name, bool *isnew)
{
	return search_var(name, isnew)->value;
}

/*** ---------------------------------------------------------------------- ***/

/* routines to read system vairables */

long get_length(void)
{
	bool isnew;
	long value;
	
	value = read_var(var_length, &isnew);
	if (isnew)
		error_handler(ERR_NOLINENO, missing_var_err);
	return value;
}

/*** ---------------------------------------------------------------------- ***/

memaddr get_base(void)
{
	bool isnew;
	long value;
	
	value = read_var(var_base, &isnew);
	if (isnew)
		error_handler(ERR_NOLINENO, missing_var_err);
	return value;
}

/*** ---------------------------------------------------------------------- ***/

memaddr get_reloc_addr(void)
{
	return read_var(var_reloc, NULL);
}

/*** ---------------------------------------------------------------------- ***/

long get_width(void)
{
	bool isnew;
	long value;
	
	value = read_var(var_width, &isnew);
	if (isnew)
		error_handler(ERR_NOLINENO, missing_var_err);
	if (value != 8 && value != 16 && value != 32 && value != 64)
		error_handler(ERR_NOLINENO, illegal_width_err);
	return value;
}

/*** ---------------------------------------------------------------------- ***/

long get_crc(void)
{
	return read_var(var_crc, NULL);
}

