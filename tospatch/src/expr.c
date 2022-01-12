#include "tospatch.h"

struct prio {
	char opname[8];
	short prio;
};

#define OP_LESS         1
#define OP_LESSEQUAL    2
#define OP_NOTEQUAL     3
#define OP_GREATER      4
#define OP_GREATEREQUAL 5
#define OP_EQUAL        6
#define OP_XOR          7
#define OP_OR           8
#define OP_AND          9
#define OP_ADD         10
#define OP_SUB         11
#define OP_MUL         12
#define OP_DIV         13
#define OP_POT         14
#define OP_IN          15
#define OP_PUSH        16
#define OP_UMINUS      17
#define OP_NOT         18
#define OP_ERROR       19
#define OP_BOOLNOT     20
#define OP_MOD         21

static struct prio const upriority[] = {
	{ "(", (127 << 8) | OP_PUSH },
	{ "-", (82 << 8) | OP_UMINUS },
	{ "|", (32 << 8) | OP_NOT },
	{ "!NOT!", (35 << 8) | OP_BOOLNOT },
	{ "!N!", (35 << 8) | OP_BOOLNOT },
	{ "[", -256 | 0 },
};

static struct prio const priority[] = {
	{ ")", (1 << 8) | OP_ERROR },
	{ "<>", (16 << 8) | OP_NOTEQUAL },
	{ "!<>!", (16 << 8) | OP_NOTEQUAL },
	{ "<=", (16 << 8) | OP_LESSEQUAL },
	{ "!<=!", (16 << 8) | OP_LESSEQUAL },
	{ "<", (16 << 8) | OP_LESS },
	{ "!<!", (16 << 8) | OP_LESS },
	{ ">=", (16 << 8) | OP_GREATEREQUAL },
	{ "!>=!", (16 << 8) | OP_GREATEREQUAL },
	{ ">", (16 << 8) | OP_GREATER },
	{ "!>!", (16 << 8) | OP_GREATER },
	{ "=", (16 << 8) | OP_EQUAL },
	{ "!=!", (16 << 8) | OP_EQUAL },
	{ "!XOR!", (32 << 8) | OP_XOR },
	{ "!X!", (32 << 8) | OP_XOR },
	{ "!OR!", (33 << 8) | OP_OR },
	{ "!O!", (33 << 8) | OP_OR },
	{ "!AND!", (34 << 8) | OP_AND },
	{ "!A!", (34 << 8) | OP_AND },
	{ "+", (64 << 8) | OP_ADD },
	{ "-", (64 << 8) | OP_SUB },
	{ "*", (82 << 8) | OP_MUL },
	{ "/", (81 << 8) | OP_DIV },
	{ "!MOD!", (80 << 8) | OP_MOD },
	{ "!M!", (80 << 8) | OP_MOD },
	{ "^", (82 << 8) | OP_POT },
	{ "!IN!", (48 << 8) | 0x80 | OP_IN },
};

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

/* parse a binary value */
static bool get_binbyte(char **batchptr, long *value)
{
	bool ok = false;
	int c;
	long val = 0;
	
	if (*(*batchptr)++ == '.')
	{
		for (;;)
		{
			c = *(*batchptr)++;
			if (c == '0' || c == '1')
			{
				ok = true;
				c = c - '0';
			} else
			{
				break;
			}
			/* TODO: check for overflow */
			val = (val << 1) + c;
		}
	}
	*value = val;
	--(*batchptr);
	return ok;
}

/*** ---------------------------------------------------------------------- ***/

/* parse a decimal value */
static bool get_dezbyte(char **batchptr, long *value)
{
	bool ok = false;
	int c;
	long val = 0;
	
	if (*(*batchptr)++ == '.')
	{
		for (;;)
		{
			c = *(*batchptr)++;
			if (ISDIGIT(c))
			{
				/* TODO: check for overflow */
				c = c - '0';
				ok = true;
			} else
			{
				break;
			}
			/* TODO: check for overflow */
			val = (val * 10) + c;
		}
	}
	*value = val;
	--(*batchptr);
	return ok;
}

/*** ---------------------------------------------------------------------- ***/

/* parse a hexadecimal value */
static bool get_hexbyte(char **batchptr, long *value)
{
	bool ok = false;
	int c;
	long val = 0;
	
	for (;;)
	{
		c = *(*batchptr)++;
		if (ISLOWER(c))
			c = TOUPPER(c);
		if (ISDIGIT(c))
		{
			c = c - '0';
			ok = true;
		} else if (c >= 'A' && c <= 'F')
		{
			c = c - 'A' + 10;
			ok = true;
		} else
		{
			break;
		}
		/* TODO: check for overflow */
		val = (val << 4) | c;
	}
	*value = val;
	--(*batchptr);
	return ok;
}

/*** ---------------------------------------------------------------------- ***/

/*
 * parse a primary number
 */
static int get_unsigned(char **batchptr, long *value)
{
	int c;
	char *start;
	bool isnew;

	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return 0;
	}
	switch (c)
	{
	case '~':
		++(*batchptr);
		*value = current_addr;
		break;
	case '%':
		if (get_binbyte(batchptr, value) == false)
			return -1;
		break;
	case '.':
		if (ISDIGIT((*batchptr)[1]))
		{
			if (get_dezbyte(batchptr, value) == false)
				return -1;
		} else
		{
			start = *batchptr + 1;
			get_vname(batchptr);
			*value = read_var(start, &isnew);
			if (isnew)
				error_handler(0, undefined_variable_err);
		}
		break;
	default:
		if (get_hexbyte(batchptr, value) == false)
			return -1;
		break;
	}
	return 0;
}

/*** ---------------------------------------------------------------------- ***/

static int get_number(char **batchptr, long *value)
{
	int i;
	const char *src;
	char *ptr;
	int c;
	int c2;
	int len;

	if (skip_space(batchptr) != 0)
	{
		for (i = 0; i < (int)ARRAY_SIZE(upriority); i++)
		{
			src = upriority[i].opname;
			ptr = *batchptr;
			len = 8;
			for (;;)
			{
				c = *ptr++;
				if (c == '\0')
				{
					i = (int)ARRAY_SIZE(upriority);
					break;
				}
				if (ISLOWER(c))
					c = TOUPPER(c);
				c2 = *src++;
				if (c2 == 0)
				{
					*batchptr = --ptr;
					*value = 0;
					return upriority[i].prio;
				}
				if (c != c2)
					break;
				if (--len == 0)
				{
					i = (int)ARRAY_SIZE(upriority);
					break;
				}
			}
		}
	}
	if (get_unsigned(batchptr, value) != 0)
	{
		error_handler(0, missing_value_err);
	}
	return 0;
}

/*** ---------------------------------------------------------------------- ***/

/* get an operator and its priority */
static int get_operator(char **batchptr)
{
	int i;
	const char *src;
	char *ptr;
	int c;
	int c2;
	int len;

	if (skip_space(batchptr) != 0)
	{
		for (i = 0; i < (int)ARRAY_SIZE(priority); i++)
		{
			src = priority[i].opname;
			ptr = *batchptr;
			len = 8;
			for (;;)
			{
				c = *ptr++;
				if (c == '\0')
				{
					i = (int)ARRAY_SIZE(priority);
					break;
				}
				if (ISLOWER(c))
					c = TOUPPER(c);
				c2 = *src++;
				if (c2 == 0)
				{
					*batchptr = --ptr;
					return priority[i].prio;
				}
				if (c != c2)
					break;
				if (--len == 0)
				{
					i = (int)ARRAY_SIZE(priority);
					break;
				}
			}
		}
	}
	return 0;
}

/*** ---------------------------------------------------------------------- ***/

static long do_pot(long value, long value2)
{
	long result;
	
	if (value2 == 0)
		return 1;
	if (value2 == 1)
		return value;
	result = 1;
	/* TODO: check for overflow */
	do
		result *= value;
	while (--value2 != 0);
	return result;
}

/*** ---------------------------------------------------------------------- ***/

/*
 * evaluate an expression
 */
long get_term(char **batchptr)
{
	long value;
	long value2;
	int prio;
	int prio2;
	struct {
		long value;
		unsigned char prio;
		signed char op;
	} stack[128];
	int level = 0;
	int c;
	
	prio2 = 0; /* shut up compiler */
	value2 = 0;
	
	/* get first value */
	prio = get_number(batchptr, &value);
	if (prio < 0)
	{
		error_handler(0, set_not_first_argument_err);
		return 0;
	}
	if (prio == 0)
	{
		/* get first operand */
		if (get_operator(batchptr) == 0)
			return value;
	}
	/* save it on stack */
	stack[0].value = value;
	stack[0].prio = prio >> 8;
	stack[0].op = prio & 0xff;
	for (;;)
	{
		for (;;)
		{
			++level;
			/* get next value */
			prio = get_number(batchptr, &value);
			if (prio != 0)
			{
				if (prio < 0)
				{
					if (stack[level - 1].op < 0)
						break;
					error_handler(0, no_set_operation_err);
					return 0;
				}
			} else
			{
				prio = get_operator(batchptr);
			}
			if (level >= 128)
			{
				error_handler(0, expression_too_complex_err);
				return 0;
			}
			stack[level].value = value;
			stack[level].prio = prio >> 8;
			stack[level].op = prio & 0xff;
		pop:
			if (stack[level - 1].prio >= stack[level].prio)
			{
				value2 = stack[level].value;
				prio2 = stack[level].prio;
				break;
			}
		}
		value = stack[level - 1].value;
		prio = stack[level - 1].prio;
		switch (prio & 0x7f)
		{
		case OP_LESS:
			value = value < value2;
			break;
		case OP_LESSEQUAL:
			value = value <= value2;
			break;
		case OP_NOTEQUAL:
			value = value != value2;
			break;
		case OP_GREATER:
			value = value > value2;
			break;
		case OP_GREATEREQUAL:
			value = value >= value2;
			break;
		case OP_EQUAL:
			value = value == value2;
			break;
		case OP_XOR:
			value = value ^ value2;
			break;
		case OP_OR:
			value = value | value2;
			break;
		case OP_AND:
			value = value & value2;
			break;
		case OP_ADD:
			value = value + value2;
			break;
		case OP_SUB:
			value = value - value2;
			break;
		case OP_MUL:
			/* TODO: check for overflow */
			value = value * value2;
			break;
		case OP_DIV:
			if (value2 == 0)
			{
				error_handler(0, div_by_zero_err);
				return 0;
			}
			value = value / value2;
			break;
		case OP_MOD:
			if (value2 == 0)
			{
				error_handler(0, div_by_zero_err);
				return 0;
			}
			value = value % value2;
			break;
		case OP_POT:
			value = do_pot(value, value2);
			break;
		case OP_IN:
			value2 = value;
			for (;;)
			{
				value = get_term(batchptr);
				if (value == value2)
				{
					for (;;)
					{
						if (skip_space(batchptr) == 0)
						{
							unexpected_eof();
							return 0;
						}
						c = *(*batchptr)++;
						if (c != ',')
						{
							if (c != ']')
								error_handler(0, set_not_terminated_err);
							break;
						}
						value = get_term(batchptr);
					}
					value = true;
					break;
				}
				if (skip_space(batchptr) == 0)
				{
					unexpected_eof();
					return 0;
				}
				c = *(*batchptr)++;
				if (c != ',')
				{
					if (c != ']')
						error_handler(0, set_not_terminated_err);
					value = false;
					break;
				}
			}
			prio2 = get_operator(batchptr);
			break;
		case OP_PUSH:
			if ((prio2 & 0xff00) == 0x100)
			{
				value = value2;
				prio2 = get_operator(batchptr);
			} else
			{
				stack[level - 1].value = value;
				stack[level - 1].prio = prio >> 8;
				stack[level - 1].op = prio & 0xff;
				stack[level].value = value2;
				stack[level].prio = prio2 >> 8;
				stack[level].op = prio2 & 0xff;
				continue;
			}
			break;
		case OP_UMINUS:
			value = -value2;
			break;
		case OP_NOT:
			value = ~value2;
			break;
		case OP_BOOLNOT:
			if (value2 == 0)
			{
				value = true;
			} else if (value2 == 1)
			{
				value = false;
			} else
			{
				error_handler(0, no_bool_err);
				value = false;
			}
			break;
		case OP_ERROR:
			error_handler(0, missing_paren_err);
			return 0;
		default:
			error_handler(0, illegal_name_err);
			return 0;
		}
		/* put result and 2nd prio on stack again */
		--level;
		stack[level].value = value;
		stack[level].prio = prio2 >> 8;
		stack[level].op = prio2 & 0xff;
		if (level != 0)
			goto pop;
		if (stack[level].prio == 0)
			break;
	}
	
	return stack[0].value;
}

/*** ---------------------------------------------------------------------- ***/

/* get the extension of an expression */
long get_extension(char **batchptr)
{
	int c;
	long ext;
	
	ext = 1;
	if (skip_space(batchptr) == '.')
	{
		(*batchptr)++;
		c = *(*batchptr)++;
		if (ISLOWER(c))
			c = TOUPPER(c);
		switch (c)
		{
		case 'B':
			ext = 1;
			break;
		case 'W':
			ext = 2;
			break;
		case 'L':
			ext = 4;
			break;
		default:
			error_handler(0, bad_extension_err);
			break;
		}
	}
	return ext;
}
