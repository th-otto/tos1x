#include "tospatch.h"

char const var_date[] = "DATE";
char const var_day[] = "DAY";
char const var_month[] = "MONTH";
char const var_year[] = "YEAR";
char const var_crc[] = "CRC";
char const var_base[] = "BASE";
char const var_length[] = "LENGTH";
char const var_reloc[] = "RELOCADR";
char const var_width[] = "WIDTH";

static VAR *variables;

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

VAR *search_var(const char *name)
{
	int i;
	int c;
	char namebuf[MAX_VAR_LENGTH + 1];
	VAR *var;
	
	for (i = 0; i < MAX_VAR_LENGTH && *name; i++)
	{
		c = getvc(*name);
		if (c < 0)
			break;
		namebuf[i] = c;
		name++;
	}
	namebuf[i] = '\0';
	
	for (var = variables; var; var = var->next)
	{
		if (strcmp(namebuf, var->name) == 0)
			return var;
	}
	return NULL;
}

/*** ---------------------------------------------------------------------- ***/

VAR *new_var(const char *name)
{
	VAR *var;
	
	var = (VAR *)xmalloc(sizeof(*var));
	var->next = variables;
	variables = var;
	strcpy(var->name, name);
	var->value = 0;
	return var;
}

/*** ---------------------------------------------------------------------- ***/

void del_var(const char *name)
{
	VAR **prev, *var;
	
	prev = &variables;
	while (*prev != NULL)
	{
		var = *prev;
		if (strcmp(name, var->name) == 0)
		{
			*prev = var->next;
			xfree(var);
			return;
		}
		prev = &var->next;
	}
}

/*** ---------------------------------------------------------------------- ***/

void write_var(const char *name, long value)
{
	VAR *var;
	char namebuf[MAX_VAR_LENGTH + 1];
	int i;
	int c;
	
	for (i = 0; i < MAX_VAR_LENGTH && *name; i++)
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
	var = search_var(namebuf);
	if (var == NULL)
		var = new_var(namebuf);
	var->value = value;
}

/*** ---------------------------------------------------------------------- ***/

/* routines to read system vairables */

long get_length(void)
{
	VAR *var;

	var = search_var(var_length);
	if (var == NULL)
	{
		error_handler(ERR_NOLINENO, missing_var_err);
		return 0;
	}
	return var->value;
}

/*** ---------------------------------------------------------------------- ***/

memaddr get_base(void)
{
	VAR *var;
	
	var = search_var(var_base);
	if (var == NULL)
	{
		error_handler(ERR_NOLINENO, missing_var_err);
		return 0;
	}
	return var->value;
}

/*** ---------------------------------------------------------------------- ***/

memaddr get_reloc_addr(void)
{
	VAR *var;

	var = search_var(var_reloc);
	if (var == NULL)
		return 0;
	return var->value;
}

/*** ---------------------------------------------------------------------- ***/

long get_width(void)
{
	VAR *var;
	long value;
	
	var = search_var(var_width);
	if (var == NULL)
	{
		error_handler(ERR_NOLINENO, missing_var_err);
		return 0;
	}
	value = var->value;
	if (value != 8 && value != 16 && value != 32 && value != 64)
		error_handler(ERR_NOLINENO, illegal_width_err);
	return value;
}

/*** ---------------------------------------------------------------------- ***/

long get_crc(void)
{
	VAR *var;

	var = search_var(var_crc);
	if (var == NULL)
		return 0;
	return var->value;
}
