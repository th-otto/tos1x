/* console system for GEMDOS */

#include "tos.h"
#include "fs.h"
#include "bios.h"

/* *************************** typeahead buffer ************************* */
/* The following data structures are used for the typeahead buffer:	  */
/* The 3 elements are prn,aux,con */
int32_t glbkbchar[3][KBBUFSZ];				/* The actual typeahead buffer    */
int32_t *buptr[3];
int32_t *beptr[3];
int glbcolumn[3];
char fill[3];


VOID conbrk PROTO((FH h, int flag));
VOID conadd PROTO((FH h, int32_t ch));
VOID buflush PROTO((FH h));
VOID conout PROTO((FH h, int ch));
VOID cookdout PROTO((FH h, int ch));
int32_t getch PROTO((FH h));
VOID prt_line PROTO((FH h, const char *p));
VOID newline PROTO((FH h, int startcol));
int backsp PROTO((FH h, const char *cbuf, int retlen, int col));



#define UBWORD(x) (((int) x) & 0x00ff)

#define   ctrlc  0x03
#define   ctrle  0x05
#define   ctrlq  0x11
#define   ctrlr  0x12
#define   ctrls  0x13
#define   ctrlu  0x15
#define   ctrlx  0x18

#define   cr      0x0d
#define   lf      0x0a
#define   tab     0x09
#define   rub     0x7f
#define   bs      0x08
#define   space   0x20

#define warmboot() xterm(-32)

/*****************************************************************************
 *
 * constat -
 *
 *****************************************************************************
 */

/* 306de: 00e138b2 */
/* 306us: 00e13858 */
/* 104de: 00fc4388 */
int32_t constat(P(FH) h)
PP(FH h;)
{
	if (fill[h])
		return -1;
	if (h != BFHPRN)
		return Bconstat(h);
	return 0;
}

/*****************************************************************************
 *
 * xconstat - 
 *	Function 0x0B - Cconis - Console input status
 *
 *	Last modified	SCC	11 Aug 85
 *
 *****************************************************************************
 */

/* 306de: 00e138e8 */
/* 306us: 00e1388e */
/* 104de: 00fc43be */
int32_t xconstat(NOTHING)
{
	return constat(HXFORM(run->p_uft[0]));
}

/*****************************************************************************
 *
 * xconostat -
 *	Function 0x10 - Cconos - console output status
 *
 *	Last Modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13902 */
/* 306us: 00e138a8 */
/* 104de: 00fc43d8 */
int32_t xconostat(NOTHING)
{
	return Bcostat(HXFORM(run->p_uft[1]));
}

/*****************************************************************************
 *
 * xprtostat -
 *	Function 0x11 - Cprnos - Printer output status
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13926 */
/* 306us: 00e138cc */
/* 104de: 00fc43fc */
int32_t xprtostat(NOTHING)
{
	return Bcostat(HXFORM(run->p_uft[3]));
}

/*****************************************************************************
 *
 * xauxistat -
 *	Function 0x12 - Cauxis - Auxiliary input status
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e1394a */
/* 306us: 00e138f0 */
/* 104de: 00fc4420 */
int32_t xauxistat(NOTHING)
{
	return constat(HXFORM(run->p_uft[2]));
}

/*****************************************************************************
 *
 * xauxostat -
 *	Function 0x13 - Cauxos - Auxiliary output status
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13966 */
/* 306us: 00e1390c */
/* 104de: 00fc443c */
int32_t xauxostat(NOTHING)
{
	return Bcostat(HXFORM(run->p_uft[2]));
}


/********************/
/* check for ctrl/s */
/* used internally  */
/********************/
/* 306de: 00e1398a */
/* 306us: 00e13930 */
/* 104de: 00fc4460 */
VOID conbrk(P(FH) h, P(int) flag)
PP(register FH h;)
PP(register int flag;)
{
	register int32_t ch;
	register int stop, c;
	int retry;
	
	UNUSED(retry);
	stop = 0;
#if (GEMDOS >= 0x0018)
		while ((flag && fill[h] == 0) || (h != BFHPRN && Bconstat(h) != 0))
#else
	do
	{
		retry = 0;
		while ((retry++ < 16 && h != BFHPRN && Bconstat(h) != 0))
#endif
		{
			do
			{
				c = (ch = Bconin(h)) & 0xFF;
				if (c == ctrlc)
				{
					buflush(h);				/* flush BDOS & BIOS buffers */
					warmboot();
					unreachable();
				}
		
				if (c == ctrls)
				{
					stop = 1;
				} else if (c == ctrlq)
				{
					stop = 0;
				} else if (c == ctrlx)
				{
					buflush(h);
					conadd(h, ch);
				} else
				{
					conadd(h, ch);
				}
			} while (stop);
		}
#if (GEMDOS < 0x0018)
	} while (flag && fill[h] == 0);
#endif
}


/* 306de: 00e13a3a */
/* 306us: 00e139e0 */
/* 104de: 00fc4526 */
VOID buflush(P(FH) h)
PP(FH h;)
{
	/* flush BDOS type-ahead buffer */

	fill[h] = 0;
	buptr[h] = beptr[h] = glbkbchar[h];
}


/* 306de: 00e13a7e */
/* 306us: 00e13a24 */
/* 104de: 00fc456a */
VOID conadd(P(FH) h, P(int32_t) ch)
PP(register FH h;)
PP(int32_t ch;)
{
	register FH hh;
	
	hh = h;
	if (fill[hh] < KBBUFSZ)
	{
		*(beptr[hh])++ = ch;
		if (beptr[hh] == &glbkbchar[hh][KBBUFSZ])
			beptr[hh] = glbkbchar[hh];
		fill[hh]++;
	} else
	{
		Bconout(hh, 7);
	}
}

/******************/
/* console output */
/* used internally*/
/******************/

/* 306de: 00e13b32 */
/* 306us: 00e13ad8 */
/* 104de: 00fc461e */
VOID conout(P(FH) h, P(int) ch)
PP(register FH h;)
PP(register int ch;)
{
	conbrk(h, FALSE);					/* check for control-s break */
	Bconout(h, ch);						/* output character to console */
	if (ch >= ' ')
		glbcolumn[h]++;					/* keep track of screen column */
	else if (ch == cr)
		glbcolumn[h] = 0;
	else if (ch == bs)
		glbcolumn[h]--;
}

/*****************************************************************************
 *
 * xtabout -
 *	Function 0x02 - Cconout - console output with tab expansion
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13bbc */
/* 306us: 00e13b62 */
/* 104de: 00fc46a8 */
VOID xtabout(P(int16_t) ch)
PP(int16_t ch;)
{
	tabout(HXFORM(run->p_uft[1]), ch & 0xff);
}

/*****************************************************************************
 *
 * tabout -
 *
 *****************************************************************************
 */

/* 306de: 00e13be0 */
/* 306us: 00e13b86 */
/* 104de: 00fc46cc */
VOID tabout(P(FH) h, P(int) ch)
PP(register FH h;)
PP(register int ch;)									/* character to output to console   */
{
	ch &= 0xff;
	if (ch == tab)
	{
		do
			conout(h, ' ');
		while (glbcolumn[h] & 7);
	} else
	{
		conout(h, ch);
	}
}

/*******************************/
/* console output with tab and */
/* control character expansion */
/*******************************/

/* 306de: 00e13c30 */
/* 306us: 00e13bd6 */
/* 104de: 00fc471c */
VOID cookdout(P(FH) h, P(int) ch)
PP(register FH h;)
PP(register int ch;)									/* character to output to console   */
{
	ch &= 0xff;
	if (ch == tab)
	{
		tabout(h, ch);					/* if tab, expand it   */
	} else
	{
		if (ch < ' ')
		{
			conout(h, '^');
			ch |= 0x40;
		}
		conout(h, ch);					/* output the character */
	}
}

/*****************************************************************************
 *
 * xauxout -
 *	Function 0x04 - Cauxout - auxiliary output
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13c7e */
/* 306us: 00e13c24 */
/* 104de: 00fc476a */
int16_t xauxout(P(int16_t) ch)
PP(int16_t ch;)
{
	return Bconout(HXFORM(run->p_uft[2]), ch);
}

/*****************************************************************************
 *
 * xprtout -
 *	Function 0x05 - Cprnout - printer output
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13ca6 */
/* 306us: 00e13c4c */
/* 104de: 00fc4792 */
int32_t xprtout(P(int16_t) ch)
PP(int16_t ch;)
{
	return Bconout(HXFORM(run->p_uft[3]), ch);
}


/* 306de: 00e13cce */
/* 306us: 00e13c74 */
/* 104de: 00fc47ba */
int32_t getch(P(FH) h)
PP(register FH h;)
{
	register int32_t temp;

	if (fill[h])
	{
		temp = *(buptr[h])++;
		fill[h]--;
		if (buptr[h] == &glbkbchar[h][KBBUFSZ])
			buptr[h] = glbkbchar[h];
		return temp;
	} else
	{
		return Bconin(h);
	}
}

/*****************************************************************************
 *
 * x7in -
 *	Function 0x07 - Crawcin - Direct console input without echo
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13d7c */
/* 306us: 00e13d22 */
/* 104de: 00fc4868 */
int32_t x7in(NOTHING)
{
	return getch(HXFORM(run->p_uft[0]));
}


/* 306de: 00e13d98 */
/* 306us: 00e13d3e */
/* 104de: 00fc4884 */
int32_t conin(P(FH) h)							/* BDOS console input function */
PP(register FH h;)
{
	register long ch;

	conbrk(h, TRUE);
	conout(h, (int) (ch = getch(h)));
	return ch;
}

/*****************************************************************************
 *
 * xconin -
 *	Function 0x01 - Cconin - console input
 *
 *	Last modified	SCC	16 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13dd0 */
/* 306us: 00e13d76 */
/* 104de: 00fc48bc */
int32_t xconin(NOTHING)
{
	return conin(HXFORM(run->p_uft[0]));
}

/*****************************************************************************
 *
 * x8in -
 *	Function 0x08 - Cnecin - Console input without echo
 *
 *	Last modified	SCC	24 Sep 85
 *****************************************************************************
 */

/* 306de: 00e13dea */
/* 306us: 00e13d90 */
/* 104de: 00fc48d6 */
int32_t x8in(NOTHING)
{
	register FH h;
	register long ch;

	h = HXFORM(run->p_uft[0]);
	conbrk(h, TRUE);
	ch = getch(h);
	return ch;
}

/*****************************************************************************
 *
 * xauxin -
 *	Function 0x03 - Cauxin - Auxiliary input
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13e22 */
/* 306us: 00e13dc8 */
/* 104de: 00fc490e */
int32_t xauxin(NOTHING)
{
	return Bconin(HXFORM(run->p_uft[2]));
}

/*****************************************************************************
 *
 * rawconio -
 *	Function 0x06 - Crawio - Raw console I/O
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13e46 */
/* 306us: 00e13dec */
/* 104de: 00fc4932 */
int32_t rawconio(P(int16_t) parm)
PP(int16_t parm;)
{
	register FH i;

	if (parm == 0xFF)
	{
		i = HXFORM(run->p_uft[0]);
		return constat(i) ? getch(i) : 0L;
	}
	return Bconout(HXFORM(run->p_uft[1]), parm);
}

/*****************************************************************************
 *
 * xprt_line -
 *	Function 0x09 - Cconws - Print line up to nul with tab expansion
 *
 *	Last modified	SCC	11 Aug 85
 *****************************************************************************
 */

/* 306de: 00e13ea6 */
/* 306us: 00e13e4c */
/* 104de: 00fc4992 */
VOID xprt_line(P(const char *) p)
PP(const char *p;)
{
	prt_line(HXFORM(run->p_uft[1]), p);
}


/* 306de: 00e13ec6 */
/* 306us: 00e13e6c */
/* 104de: 00fc49b2 */
VOID prt_line(P(FH) h, P(const char *) p)
PP(register FH h;)
PP(register const char *p;)
{
	while (*p)
		tabout(h, *p++);
}


/**********************************************/
/* read line with editing and bounds checking */
/**********************************************/

/* Two subroutines first */

/* 306de: 00e13ef4 */
/* 306us: 00e13e9a */
/* 104de: 00fc49e0 */
VOID newline(P(FH) h, P(int) startcol)
PP(register int startcol;)
PP(register FH h;)
{
	conout(h, cr);						/* go to new line */
	conout(h, lf);
	while (startcol)
	{
		conout(h, ' ');
		startcol -= 1;					/* start output at starting column */
	}
}


/* backspace one character position */
/* 306de: 00e13f3a */
/* 306us: 00e13ee0 */
/* 104de: 00fc4a26 */
int backsp(P(FH) h, P(const char *) cbuf, P(int) retlen, P(int) col)
PP(FH h;)
PP(const char *cbuf;)
PP(int retlen;)
PP(int col;)								/* starting console column  */
{
	register char ch;					/* current character        */
	register int i;
	register const char *p;					/* character pointer        */

	if (retlen)
		--retlen;
	/* if buffer non-empty, decrease it by 1 */
	i = retlen;
	p = cbuf;
	while (i--)							/* calculate column position    */
	{									/*  across entire char buffer   */
		ch = *p++;						/* get next char        */
		if (ch == tab)
		{
			col += 8;
			col &= ~7;					/* for tab, go to multiple of 8 */
		} else if ((ch & ~0x1f) == 0)
		{
			/* control chars put out 2 printable chars */
			col += 2;
		} else
		{
			col += 1;
		}
	}
	while (glbcolumn[h] > col)
	{
		conout(h, bs);					/* backspace until we get to proper column */
		conout(h, ' ');
		conout(h, bs);
	}
	return retlen;
}

/*****************************************************************************
 *
 * readline -
 *	Function 0x0A - Cconrs - Read console string into buffer
 *****************************************************************************
 */

/* 306de: 00e13fd6 */
/* 306us: 00e13f7c */
/* 104de: 00fc4ac2 */
VOID readline(P(char *) p)
PP(register char *p;)								/* max length, return length, buffer space */
{
	p[1] = cgets(HXFORM(run->p_uft[0]), (((int) p[0]) & 0xFF), &p[2]);
}


/* 306de: 00e14012 */
/* 306us: 00e13fb8 */
/* 104de: 00fc4afe */
int cgets(P(FH) h, P(int) maxlen, P(char *) buf)
PP(register FH h;)									/* h is special handle denoting device number */
PP(int maxlen;)
PP(char *buf;)
{
	char ch;
	int i;
	register int stcol, retlen;

	stcol = glbcolumn[h];				/* set up starting column */
	for (retlen = 0; retlen < maxlen;)
	{
		conbrk(h, TRUE);
		switch (ch = getch(h))
		{
		case cr:
		case lf:
			conout(h, cr);
			goto getout;
		case bs:
		case rub:
			retlen = backsp(h, buf, retlen, stcol);
			break;
		case ctrlx:
			do
				retlen = backsp(h, buf, retlen, stcol);
			while (retlen);
			break;
		case ctrlu:
			conout(h, '#');
			newline(h, stcol);
			retlen = 0;
			break;
		case ctrlr:
			conout(h, '#');
			newline(h, stcol);
			for (i = 0; i < retlen; i++)
				cookdout(h, buf[i]);
			break;
		default:
			cookdout(h, buf[retlen++] = ch);
		}
	}
getout:
	return retlen;
}
