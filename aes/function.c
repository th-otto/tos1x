/*	Functions.c				7/14/92		D.Mui		*/

#include "aes.h"
#include "taddr.h"
#include "obdefs.h"


#if !MC68K /* MC68K has optimized versions of this in optimize.S */

/* 	Returns a byte pointer pointing to the matched byte or
 *	the end of the string.
 */
const char *scasb(P(const char *) p, P(char) b)
PP(register const char *p;)
PP(register char b;)
{
	for (; *p && *p != b; p++)
		;
	return p;
}



/* 	Routine to set the variables x,y,w,h to the values found
 *	in an x,y,w,h block (grect)
 */
VOID r_get(P(const GRECT *) gr, P(int16_t *) px, P(int16_t *) py, P(int16_t *) pw, P(int16_t *) ph)
PP(const GRECT *gr;)
PP(int16_t *px;)
PP(int16_t *py;)
PP(int16_t *pw;)
PP(int16_t *ph;)
{
	*px = gr->g_x;
	*py = gr->g_y;
	*pw = gr->g_w;
	*ph = gr->g_h;
}


/* 	Routine to set a x,y,w,h block to the x,y,w,h  
 *	values passed in.
 */
VOID r_set(P(GRECT *) gr, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(register int16_t *gr;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	gr->g_x = x;
	gr->g_y = y;
	gr->g_w = w;
	gr->g_h = h;
}


/*
 * Copy src xywh block to dest xywh block.
 */
VOID rc_copy(P(const GRECT *) src, P(GRECT *) dst)
PP(register const GRECT *src;)
PP(register GRECT *dst;)
{
	*dst = *src;
}


/*
 * Return true if the x,y position is within the grect.
 */
BOOLEAN inside(P(int16_t) x, P(int16_t) y, P(const GRECT *) pt)
PP(register int16_t x;)
PP(register int16_t y;)
PP(register const GRECT *pt;)
{
	if ((x >= pt->g_x) && (y >= pt->g_y) && (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h))
		return TRUE;
	return FALSE;
}


/*
 * Returns true if the two grects are equal.
 */
BOOLEAN rc_equal(P(const GRECT *) prc1, P(const GRECT *) prc2)
PP(const int16_t *prc1;)
PP(const int16_t *prc2;)
{
	const int16_t *p1 = &prc1->g_x;
	const int16_t *p2 = &prc2->g_x;
	register int count = 4;
	
	while (--count >= 0)
	{
		if (*p1++ != *p2++)
			return FALSE;
	}
	return TRUE;
}


/* 	Returns the intersection of two rectangles in ptr2.
 *	Returns true if there was an intersection where the width
 *	is greater than x and the height is greater than y.
 */
BOOLEAN rc_intersect(P(const GRECT *) p1, P(GRECT *) p2)
PP(register const GRECT *p1;)
PP(register GRECT *p2;)
{
	register int16_t tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return (tw > tx) && (th > ty);
}


/*
 * Returns the union of two rectangles in ptr2.
 *	Don't pass in 0s in x,y,w,h
 */
VOID rc_union(P(const GRECT *) p1, P(GRECT *) p2)
PP(register const GRECT *p1;)
PP(register GRECT *p2;)
{
	register int16_t tx, ty, tw, th;

	tw = max(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
	th = max(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
	tx = min(p1->g_x, p2->g_x);
	ty = min(p1->g_y, p2->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
}


/* 	Routine to constrain a box within another box.  This is done by
 *	seting the x,y of the inner box to remain within the
 *	constraining box.
 */
VOID rc_constrain(P(const GRECT *) pc, P(GRECT *) pt)
PP(register const GRECT *pc;)
PP(register GRECT *pt;)
{
	if (pt->g_x < pc->g_x)
		pt->g_x = pc->g_x;
	if (pt->g_y < pc->g_y)
		pt->g_y = pc->g_y;
	if ((pt->g_x + pt->g_w) > (pc->g_x + pc->g_w))
		pt->g_x = (pc->g_x + pc->g_w) - pt->g_w;
	if ((pt->g_y + pt->g_h) > (pc->g_y + pc->g_h))
		pt->g_y = (pc->g_y + pc->g_h) - pt->g_h;
}




/*
 * move bytes from source to dest for a count of N
 */
VOID movs(P(int16_t) num, P(const char *) ps, P(char *) pd)
PP(register int16_t num;)
PP(register const char *ps;)
PP(register char *pd;)
{
	do
		*pd++ = *ps++;
	while (--num);
}


/*
 * Returns minimum value of two words
 */
int16_t min(P(int16_t) a, P(int16_t) b)
PP(int16_t a;)
PP(int16_t b;)
{
	return a < b ? a : b;
}


/*
 * Returns maximum value of two words
 */
int16_t max(P(int16_t) a, P(int16_t) b)
PP(int16_t a;)
PP(int16_t b;)
{
	return a > b ? a : b;
}



/*
 * Copy the byte passed in to the dest pointer for a count of N
 */
VOID bfill(P(int16_t) num, P(char) bval, P(VOIDPTR) addr)
PP(register int16_t num;)
PP(register char bval;)
PP(VOIDPTR addr;)
{
	register char *p = addr;
	while (num)
	{
		*p++ = bval;
		num--;
	}
}


/*
 * Return upper case value.
 */
int toupper(P(int) ch)
PP(register char ch;)
{
	if ((ch >= 'a') && (ch <= 'z'))
		return ch - 32;
	return ch;
}


/*
 * Length of a string
 */
size_t strlen(P(const char *) p1)
PP(register const char *p1;)
{
	register int16_t len;

	len = 0;
	while (*p1++)
		len++;

	return len;
}


BOOLEAN streq(P(const char *) p1, P(const char *) p2)
PP(register const char *p1;)
PP(register const char *p2;)
{
	while (*p1)
	{
		if (*p1++ != *p2++)
			return FALSE;
	}
	if (*p2)
		return FALSE;
	return TRUE;
}



char *xstrpcpy(P(const char *) ps, P(char *) pd)
PP(register const char *ps;)
PP(register char *pd;)
{
	while ((*pd++ = *ps++) != '\0')
		;
	return pd;
}


/* 	copy the src to destination until we are out of characters
 *	or we get a char match.
 */
char *strscn(P(const char *) ps, P(char *) pd, P(char) stop)
PP(register const char *ps;)
PP(register char *pd;)
PP(register char stop;)
{
	while ((*ps) && (*ps != stop))
		*pd++ = *ps++;
	return pd;
}


char *xstrpcat(P(const char *) ps, P(char *) pd)
PP(register const char *ps;)
PP(register char *pd;)
{
	while (*pd)
		pd++;
	while ((*pd++ = *ps++) != '\0')
		;
	return (pd);
}


/* 	This is the true version of strcmp. Shall we remove the
 *	other -we shall see!!!
 *	Returns	- <0 if(str1<str2), 0 if(str1=str2), >0 if(str1>str2)
 */
int16_t strchk(P(const char *) s, P(const char *) t)
PP(register const char *s;)
PP(register const char *t;)
{
	register int16_t i;

	i = 0;
	while (s[i] == t[i])
		if (s[i++] == 0)
			return 0;
	return (s[i] - t[i]);
}



/*
 *	Strip out period and turn into raw data.
 */
VOID fmt_str(P(const char *) in_str, P(char *) out_str)
PP(register const char *in_str;)
PP(register char *out_str;)
{
	int16_t i;

	for (i = 0; i < 8; i++)
	{
		if ((*in_str) && (*in_str != '.'))
			*out_str++ = *in_str++;
		else
		{
			if (*in_str)
				*out_str++ = ' ';
			else
				break;
		}
	}

	if (*in_str)							/* must be a dot    */
		in_str++;

	while (*in_str)
		*out_str++ = *in_str++;

	*out_str = '\0';
}


/*
 *	Insert in period and make into true data.
 */
VOID unfmt_str(P(const char *) in_str, P(char *) out_str)
PP(register const char *in_str;)
PP(register char *out_str;)
{
	int16_t i;
	char temp;

	for (i = 0; i < 8; i++)
	{
		temp = *in_str++;

		if ((temp) && (temp != ' '))
			*out_str++ = temp;
		else
		{
			if (!temp)					/* at the end ? */
				goto u_1;
		}
	}

	if (*in_str)							/* any extension ? */
	{
		*out_str++ = '.';
		while (*in_str)
			*out_str++ = *in_str++;
	}
  u_1:
	*out_str = '\0';
}


/* 	Copy the long in the ob_spec field to the callers variable
 *	ptext.  Next copy the string located at the ob_spec long to the
 *	callers pstr.  Finally copy the length of the tedinfo string
 *	to the callers ptxtlen.
 *  obj must reference a TEDINFO object.
 */
VOID fs_sset(P(LPTREE) tree, P(int16_t) obj, P(char *) pstr, P(char **) ptext, P(int16_t *) ptxtlen)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(char *pstr;)
PP(register char **ptext;)
PP(int16_t *ptxtlen;)
{
	register intptr_t spec;

	*ptext = (char *)LLGET(spec = LLGET(OB_SPEC(obj)));
	LSTCPY(*ptext, pstr);
	*ptxtlen = LWGET(spec + 24);
}


VOID inf_sset(P(OBJECT *) tree, P(int16_t) obj, P(const char *) pstr)
PP(OBJECT *tree;)
PP(int16_t obj;)
PP(const char *pstr;)
{
	char *text;
	int16_t txtlen;

	fs_sset(tree, obj, ADDR(pstr), &text, &txtlen);
}


/* 	fs_sget
 * 	This routine copies the tedinfo string to the dst pointer.
 *	The function inf_sget was the same as fs_sget.
 */
VOID fs_sget(P(OBJECT *) tree, P(int16_t) obj, P(char *) pstr)
PP(OBJECT *tree;)
PP(int16_t obj;)
PP(char *pstr;)
{
	char *ptext;

	ptext = (char *)LLGET(LLGET(OB_SPEC(obj)));
	LSTCPY(pstr, ptext);
}



/* 	This routine is used to set an objects flags based on 
 *	the outcome of a 'and' operation.  The word is set to
 *	the 'truestate' if the operation is true else set to
 *	'falsestate'
 */
VOID inf_fldset(P(LPTREE) tree, P(int16_t) obj, P(uint16_t) testfld, P(uint16_t) testbit, P(uint16_t) truestate, P(uint16_t) falsestate)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(uint16_t testfld;)
PP(uint16_t testbit;)
PP(uint16_t truestate;)
PP(uint16_t falsestate;)
{
	LWSET(OB_STATE(obj), (testfld & testbit) ? truestate : falsestate);
}


/* inf_gindex	for each object from baseobj for N objects return the object
 *		that is selected or -1 if no objects are selected.
 */
int16_t inf_gindex(P(OBJECT *) tree, P(int16_t) baseobj, P(int16_t) numobj)
PP(OBJECT *tree;)
PP(int16_t baseobj;)
PP(int16_t numobj;)
{
	int16_t retobj;

	for (retobj = 0; retobj < numobj; retobj++)
	{
		if (tree[baseobj + retobj].ob_state & SELECTED)
			return retobj;
	}
	return NIL;
}


/*
 *	Return 0 if cancel was selected, 1 if okay was selected, -1 if
 *	nothing was selected.
 */
int16_t inf_what(P(OBJECT *) tree, P(int16_t) ok, P(int16_t) cncl)
PP(register OBJECT *tree;)
PP(register int16_t ok;)
PP(register int16_t cncl;)
{
	register int16_t field;

	field = inf_gindex(tree, ok, 2);

	if (field != -1)
	{
		tree[ok + field].ob_state = NORMAL;
		field = field == 0;
	}
	return field;
}



VOID merge_str(P(char *) pdst, P(const char *) ptmp, P(VOIDPTR) parms)
PP(register char *pdst;)
PP(register const char *ptmp;)
PP(VOIDPTR parms;)
{
	register int16_t num;
	int16_t do_value;
	char lholder[12];
	register char *pnum;
	char *psrc;
	register int32_t lvalue, divten;
	int16_t digit;

	num = 0;
	while (*ptmp)
	{
		if (*ptmp != '%')
			*pdst++ = *ptmp++;
		else
		{
			ptmp++;
			do_value = FALSE;
			switch (*ptmp++)
			{
			case '%':
				*pdst++ = '%';
				break;
			case 'L':
				lvalue = *((int32_t *) & parms[num]);
				num += 2;
				do_value = TRUE;
				break;
			case 'W':
				lvalue = parms[num];
				num += 2;
				do_value = TRUE;
				break;
			case 'S':
				psrc = (char *) (HW(parms[num]) | LW(parms[num+1]));
				num += 2;
				while (*psrc)
					*pdst++ = *psrc++;
				break;
			}
			if (do_value)
			{
				pnum = &lholder[0];
				while (lvalue)
				{
					divten = lvalue / 10;
					digit = (int16_t) lvalue - (divten * 10);
					*pnum++ = '0' + digit;
					lvalue = divten;
				}
				if (pnum == &lholder[0])
					*pdst++ = '0';
				else
				{
					while (pnum != &lholder[0])
						*pdst++ = *--pnum;
				}
			}
		}
	}
	*pdst = '\0';
}



int16_t wildcmp(P(const char *) pwild, P(const char *) ptest)
PP(register const char *pwild;)
PP(register const char *ptest;)
{
	while ((*ptest) && (*pwild))
	{
		if (*pwild == '?')
		{
			pwild++;
			if (*ptest != '.')
				ptest++;
		} else
		{
			if (*pwild == '*')
			{
				if (*ptest != '.')
					ptest++;
				else
					pwild++;
			} else
			{
				if (*ptest == *pwild)
				{
					pwild++;
					ptest++;
				} else
					return (FALSE);
			}
		}
	}
	/* eat up remaining wildcard chars */
	while ((*pwild == '*') || (*pwild == '?') || (*pwild == '.'))
		pwild++;
	/* if any part of wildcard or test is left then no match */
	if ((*pwild) || (*ptest))
		return FALSE;
	return TRUE;
}

#endif


#ifdef __GNUC__
#include <string.h>
void *memcpy(void *s1, const void *s2, size_t n)
{
	register char *ts1 = (char *)s1;
	register const char *ts2 = (const char *)s2;

	while (n--)
		*ts1++ = *ts2++;
	return s1;
}
#endif
