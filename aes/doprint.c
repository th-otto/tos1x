/*
	Copyright 1982
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca.  92121
*/

/**
 **	formated print
 **/

#include "../alcyon/libsrc/lib.h"
#include <string.h>
#include <stdint.h>


long ulrem(P(long) al1, P(long) al2)
PP(long al1;)
PP(long al2;)
{
	return al1 - lmul(uldiv(al1, al2), al2);
}


long lrem(P(long) al1, P(long) al2)
PP(long al1;)
PP(long al2;)
{
	return al1 - lmul(ldiv(al1, al2), al2);
}


long uldiv(P(long) al1, P(long) al2)
PP(long al1;)
PP(long al2;)
{
#ifdef __ALCYON__
	asm("move.l	d2,a0");
	asm("move.l	12(a6),d1");	/* d1 = divisor */
	asm("move.l	8(a6),d0");	/* d0 = dividend */

	asm("cmp.l	#$10000,d1"); /* divisor >= 2 ^ 16 ?   */
	asm("bcc	L3003");		/* then try next algorithm */
	asm("move.l	d0,d2");
	asm("clr.w	d2");
	asm("swap	d2");
	asm("divu	d1,d2");          /* high quotient in lower word */
	asm("move.w	d2,d0");		/* save high quotient */
	asm("swap	d0");
	asm("move.w	10(a6),d2");	/* get low dividend + high rest */
	asm("divu	d1,d2");		/* low quotient */
	asm("move.w	d2,d0");
	asm("bra	L3006");

asm("L3003:");
	asm("move.l	d1,d2");		/* use d2 as divisor backup */
asm("L3004:");
	asm("lsr.l	#1,d1");	/* shift divisor */
	asm("lsr.l	#1,d0");	/* shift dividend */
	asm("cmp.l	#$10000,d1"); /* still divisor >= 2 ^ 16 ?  */
	asm("bcc	L3004");
	asm("divu	d1,d0");		/* now we have 16-bit divisor */
	asm("and.l	#$ffff,d0"); /* mask out divisor, ignore remainder */

/* Multiply the 16-bit tentative quotient with the 32-bit divisor.  Because of
   the operand ranges, this might give a 33-bit product.  If this product is
   greater than the dividend, the tentative quotient was too large. */
	asm("move.l	d2,d1");
	asm("mulu	d0,d1");		/* low part, 32 bits */
	asm("swap	d2");
	asm("mulu	d0,d2");		/* high part, at most 17 bits */
	asm("swap	d2");		/* align high part with low part */
	asm("tst.w	d2");		/* high part 17 bits? */
	asm("bne	L3005");		/* if 17 bits, quotient was too large */
	asm("add.l	d2,d1");		/* add parts */
	asm("bcs	L3005");		/* if sum is 33 bits, quotient was too large */
	asm("cmp.l	8(a6),d1");	/* compare the sum with the dividend */
	asm("bls	L3006");		/* if sum > dividend, quotient was too large */
asm("L3005:");
	asm("subq.l	#1,d0");	/* adjust quotient */

asm("L3006:");
	asm("move.l	a0,d2");
#else
	(void) al1;
	(void) al2;
	__builtin_unreachable();
#endif
}


char *__prtld(P(register long) n, P(char **) pbuf, P(int) base, P(int) issigned, P(char *) digs)
PP(register long n;)
PP(char **pbuf;)
PP(int base;)
PP(int issigned;)
PP(char *digs;)
{
	register long b;
	register char *p;
	register int i;

	p = digs;
	b = base;
	if (base == 16)
	{									/* special because of negatives */
		i = 8;
		while (n && i)
		{
			*p++ = n & 0xf;
			n >>= 4;
			i--;
		}
	} else if (base == 8)
	{
		i = 11;
		while (n && i)
		{
			*p++ = n & 7;
			n >>= 3;
			i--;
		}
		if (i == 0)
		{
			*(p - 1) &= 3;				/* only 2 bits in upper octal digit */
		}
	} else
	{
		if (issigned && n < 0)
		{
			*(*pbuf)++ = '-';
			n = -n;
		}
		while (n)
		{
			*p++ = ulrem(n, b);
			n = uldiv(n, b);
		}
	}
	return p;
}


char *__prtint(P(long) n, P(char *) buf, P(int) base, P(int) issigned, P(printfunc) f, P(int) upper)
PP(long n;)
PP(char *buf;)
PP(int base;)
PP(int issigned;)
PP(printfunc f;)
PP(int upper;)
{
	char digs[15];
	register char *dp;
	register int k;
	register char *p;

	dp = (*f) (n, &buf, base, issigned, digs);

	if (dp == digs)
		*dp++ = 0;
	p = buf;
	while (dp != digs)
	{
		k = *--dp;
		if (k < 10)
			k += '0';
		else
			k += upper ? 'A' - 10 : 'a' - 10;
		*p++ = k;
	}
	*p = 0;
	return p;
}


char *__prtshort(P(register long) n, P(char **) pbuf, P(int) base, P(int) issigned, P(char *) digs)
PP(long n;)
PP(char **pbuf;)
PP(int base;)
PP(int issigned;)
PP(char *digs;)
{
	register char *p;
	register long b;

	p = digs;
	b = base;
	if (issigned && n < 0)
	{
		n = -n;
		*(*pbuf)++ = '-';
	} else
	{
		n &= 0xffffL;					/* clear upper half */
	}
	
	while (n != 0)
	{
		*p++ = lrem(n, b);
		n /= b;
	}
	return p;
}


static VOID __putch(P(FILE *) stream, P(int) mode, P(char) c)
PP(FILE *stream;)
PP(int mode;)
PP(char c;)
{
	char **str;
	
	str = (char **)stream;
	*(*str)++ = c;
}


int __doprint(P(FILE *) stream, P(const char *) fmt, P(int) mode, P(va_list) args)
PP(FILE *stream;)
PP(register const char *fmt;)
PP(int mode;)
PP(va_list args;)
{
	register char c;
	char buf[BUFSIZ];
	int width, prec;
	int left, longf, prepend;
	char padchar;
	const char *s;
	long n;
	double d;
	int total;
	char *(*fn) PROTO((long n, char **pbuf, int base, int signed, char *digs));
	int len;

	total = 0;
	while ((c = *fmt++) != 0)
	{
		if (c != '%')
		{
			__putch(stream, mode, c);
			total++;
			continue;
		}
		prepend = left = 0;
		if ((c = *fmt++) == '-')
		{
			c = *fmt++;
			left++;
		}
		if (c == '#')
		{
			c = *fmt++;
			prepend++;
		}
		padchar = ' ';
		if (c == '0')
		{
			padchar = c;
			c = *fmt++;
		}
		width = -1;
		while (c >= '0' && c <= '9')
		{
			if (width < 0)
				width = 0;
			width = width * 10 + (c - '0');
			c = *fmt++;
		}
		if (c == '*')
		{
			c = *fmt++;
			width = va_arg(args, int);
		}
		prec = -1;
		if (c == '.')
		{
			prec = 0;
			c = *fmt++;
		}
		while (c >= '0' && c <= '9')
		{
			prec = prec * 10 + (c - '0');
			c = *fmt++;
		}
		if (c == '*')
		{
			c = *fmt++;
			prec = va_arg(args, int);
		}
		longf = 0;
		if (c == 'l' || c == 'L' || c == 'j' || c == 't' || c == 'q')
		{
			longf++;
			c = *fmt++;
		}
		if (c == 'l' || c == 'h' || c == 'z')
		{
			/* just ignore for now */
			c = *fmt++;
		}
		/*
		 * we now have all the prelims out of the way;
		 *  let's see what we want to print
		 */
		s = buf;
		switch (c)
		{
		case 'd':						/* decimal signed */
		case 'i':
			if (longf)
			{
				n = va_arg(args, long);
				fn = __prtld;
			} else
			{
				n = va_arg(args, int);
				fn = __prtshort;
			}
			__prtint(n, buf, 10, 1, fn, 0);
			break;

		case 'u':						/* decimal unsigned */
		case 'U':
#if SIZE_MAX == UINT16_MAX
		case 'z':
#endif
			if (longf)
			{
				n = va_arg(args, long);
				fn = __prtld;
			} else
			{
				n = va_arg(args, int);
				fn = __prtshort;
			}
			__prtint(n, buf, 10, 0, fn, 0);
			break;

#if SIZE_MAX != UINT16_MAX
		case 'z':
			if (longf)
			{
				n = va_arg(args, long);
				fn = __prtld;
			} else
			{
				n = va_arg(args, size_t);
				fn = __prtshort;
			}
			__prtint(n, buf, 10, 0, fn, 0);
			break;
#endif

		case 'o':						/* octal unsigned */
		case 'O':
			if (longf)
			{
				n = va_arg(args, long);
				fn = __prtld;
			} else
			{
				n = va_arg(args, int);
				fn = __prtshort;
			}
			if (prepend && n != 0)
			{
				__putch(stream, mode, '0');
				total++;
			}
			__prtint(n, buf, 8, 0, fn, 0);
			break;

		case 'x':						/* hexadecimal unsigned */
		case 'X':
			if (longf)
			{
				n = va_arg(args, long);
				fn = __prtld;
			} else
			{
				n = va_arg(args, int);
				fn = __prtshort;
			}
			if (prepend && n != 0)
			{
				__putch(stream, mode, '0');
				__putch(stream, mode, 'x');
				total += 2;
			}
			__prtint(n, buf, 16, 0, fn, c == 'X');
			break;

		case 'p':						/* pointer */
			n = va_arg(args, long);
			if (n == 0L)
			{
				s = "(nil)";
				padchar = ' ';
			} else
			{
				fn = __prtld;
				if (prepend)
				{
					__putch(stream, mode, '0');
					__putch(stream, mode, 'x');
					total += 2;
				}
				__prtint(n, buf, 16, 0, fn, 0);
			}
			break;

		case 's':						/* string */
		case 'S':
			s = va_arg(args, char *);
			if (s == NULL)
			{
				s = "(null)";
				padchar = ' ';
			}
			break;

		case 'c':						/* character */
		case 'C':
			n = va_arg(args, int);
			buf[0] = n;
			buf[1] = '\0';
			break;

		default:						/* just print the character */
			__putch(stream, mode, c);
			total++;
			continue;
		}
		len = strlen(s);
		if (prec < len && prec >= 0)
			len = prec;
		n = width - len;
		if (!left)
		{
			if (padchar != ' ' && *s == '-')
			{
				len--;
				__putch(stream, mode, *s);
				total++;
				s++;
			}
			while (n-- > 0)
			{
				__putch(stream, mode, padchar);
				total++;
			}
		}
		while (len--)
		{
			__putch(stream, mode, *s);
			total++;
			s++;
		}
		while (n-- > 0)
		{
			__putch(stream, mode, padchar);
			total++;
		}
	}
	
	return total;
}
