/*      DESKMISC.C              3/16/89 - 9/13/89       Derek Mui       */
/*      Change chk_par          9/25/89                 D.Mui           */
/*      Fix at fill_string to take out control character        7/9/91  */
/*      Add get_fstring         7/7/92                  D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"
#include "toserrno.h"
#include "taddr.h"

char *g_buffer;						/* merge string buffer  */


/* 306de: 00e2fe54 */
/* 104de: 00fd7d6e */
/* 106de: 00e18748 */
VOID my_itoa(P(uint16_t) number, P(char *)pnumstr)
PP(uint16_t number;)
PP(register char *pnumstr;)
{
	register int16_t ii;

	for (ii = 0; ii < 2; pnumstr[ii++] = '0')
		;
	pnumstr[2] = '\0';
	merge_str(number > 9 ? pnumstr : pnumstr + 1, "%W", &number);
}


/*
 *	Routine to format DOS style time.
 *
 *	15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
 *	<     hh     > <    mm    > <   xx  >
 *	hh = binary 0-23
 *	mm = binary 0-59
 *	xx = binary seconds \ 2 
 * 
 *	put into this form 12:45 pm
 *
 *	IF(EUROTIME)THEN Military Time Format 
 */
/* 206de: 00e2c440 */
/* 306de: 00e2fea6 */
/* 306us: 00e2fe4c */
/* 104de: 00fd7db6 */
/* 104us: 00fd7d5c */
/* 106de: 00e1879c */
VOID fmt_time(P(uint16_t) time, P(char *)ptime)
PP(register uint16_t time;)
PP(register char *ptime;)
{
	register BOOLEAN pm;
	register int16_t val;

	val = ((time & 0xf800) >> 11) & 0x001f;

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_ES) | (OS_COUNTRY == CTRY_IT) | (OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_SF) | (OS_COUNTRY == CTRY_SG) | (OS_COUNTRY == CTRY_TR) | (OS_COUNTRY == CTRY_FI) | (OS_COUNTRY == CTRY_NO) | (OS_COUNTRY == CTRY_PL) | (OS_COUNTRY == CTRY_CZ)
	my_itoa(val, &ptime[0]);
	my_itoa(((time & 0x07e0) >> 5) & 0x003f, &ptime[2]);
	strcpy(&ptime[4], "  ");
	UNUSED(pm);
#else
	if (val >= 12)
	{
		if (val > 12)
			val -= 12;
		pm = TRUE;
	} else
	{
		if (val == 0)
			val = 12;
		pm = FALSE;
	}

	my_itoa(val, &ptime[0]);
	my_itoa(((time & 0x07e0) >> 5) & 0x003f, &ptime[2]);
	strcpy(&ptime[4], pm ? "pm" : "am");
#endif
}


/*
 *	Routine to format DOS style date.
 *	
 *	15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
 *	<     yy          > < mm  > <  dd   >
 *	yy = 0 - 99 (1980 - 2079)
 *	mm = 1 - 12
 *	dd = 1 - 31
 *
 *	IF(EURODATE)THEN Swap Day and Month thusly: dd/mm/yy
 *	IF(SWEDDATE)THEN Swap Day and Month thusly: yy/mm/dd
 *	Changed 7/20/92 To put in st_dchar as separator
 */
/* 206de: 00e2c49c */
/* 306de: 00e2ff02 */
/* 306us: 00e2fed2 */
/* 104de: 00fd7e02 */
/* 104us: 00fd7dd0 */
/* 106de: 00e187f6 */
VOID fmt_date(P(uint16_t) date, P(char *)pdate)
PP(uint16_t date;)
PP(register char *pdate;)
{
#if (OS_COUNTRY == CTRY_US)
#define st_date 0
#define st_dchar '-' /* BUG: should actually be '/' */
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG) | (OS_COUNTRY == CTRY_TR) | (OS_COUNTRY == CTRY_CZ)
#define st_date 1
#define st_dchar '-' /* BUG: should actually be '.' */
#endif

/* BUG: UK should be date format 0 */
#if (OS_COUNTRY == CTRY_UK) | (OS_COUNTRY == CTRY_PL) | (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_ES) | (OS_COUNTRY == CTRY_IT) | (OS_COUNTRY == CTRY_SF)
#define st_date 1
#define st_dchar '-' /* BUG: should actually be '/' */
#endif

#if (OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_FI) | (OS_COUNTRY == CTRY_NO)
#define st_date 2
#define st_dchar '-'
#endif

#if st_date == 0 /* MM-DD-YY */
		my_itoa((date & 0x01e0) >> 5, &pdate[0]);
		my_itoa(date & 0x001f, &pdate[2]);
		my_itoa(((80 + ((date >> 9) & 0x007f)) % 100), &pdate[4]);
#endif

#if st_date == 1 /* DD-MM-YY */
		my_itoa(date & 0x001f, &pdate[0]);
		my_itoa((date & 0x01e0) >> 5, &pdate[2]);
		my_itoa(((80 + ((date >> 9) & 0x007f)) % 100), &pdate[4]);
#endif

#if st_date == 2 /* YY-MM-DD */
		my_itoa(((80 + ((date >> 9) & 0x007f)) % 100), &pdate[0]);
		my_itoa((date & 0x01e0) >> 5, &pdate[2]);
		my_itoa(date & 0x001f, &pdate[4]);
#endif

#if st_date == 3 /* YY-DD-MM */
		my_itoa(((80 + ((date >> 9) & 0x007f)) % 100), &pdate[0]);
		my_itoa(date & 0x001f, &pdate[2]);
		my_itoa((date & 0x01e0) >> 5, &pdate[4]);
#endif
}


/*
 * Build string
 */
/* 206de: 00e2c504 */
/* 306de: 00e2ff6a */
/* 104de: 00fd7e58 */
/* 106de: 00e1885a */
long bldstring(P(intptr_t)dir, P(char *)dst)
PP(register intptr_t dir;)
PP(register char *dst;)
{
	register char *ptr;
	DIR buf;
	char datebuf[8];
	char timebuf[8];
	char tmp[10];
	register int i;
	int16_t len;
	register char *src;

	LBCOPY((char *)&buf.d_att + 1, dir, sizeof(DIR) - 1);
	ptr = dst;
	src = buf.d_name;
	
	if (gl_width != 320)
		*ptr++ = ' ';
	
	*ptr++ = (buf.d_att & FA_DIREC) ? 0x07 : ' ';

	if (gl_width != 320)
		*ptr++ = ' ';
	
	while (*src && *src != '.')
		*ptr++ = *src++;

	len = gl_width == 320 ? 10 : 12;
	
	while ((int)((intptr_t)ptr - (intptr_t)dst) < len)
		*ptr++ = ' ';

	if (*src != '\0')
		src++;

	while (*src)
		*ptr++ = *src++;

	len = gl_width == 320 ? 13 : 16;
	while ((int)((intptr_t)ptr - (intptr_t)dst) < len)
		*ptr++ = ' ';

	src = tmp;
	
	if (buf.d_att & FA_DIREC)
	{
		*src = '\0';
	} else
	{
		merge_str(tmp, "%L", &buf.d_size);
	}
	
	i = 8;
	i -= (int)strlen(src);
	while (i-- != 0)
		*ptr++ = ' ';
	while (*src != '\0')
		*ptr++ = *src++;
	
	*ptr++ = ' ';
	if (gl_width != 320)
		*ptr++ = ' ';

	fmt_date(buf.d_date, datebuf);
	src = datebuf;
	for (i = 3; i-- != 0; )
	{
		*ptr++ = *src++;
		*ptr++ = *src++;
		if (i != 0)
			*ptr++ = st_dchar;
	}
	
	*ptr++ = ' ';
	if (gl_width != 320)
		*ptr++ = ' ';

	fmt_time(buf.d_time, timebuf);
	src = timebuf;
	for (i = 2; i-- != 0; )
	{
		*ptr++ = *src++;
		*ptr++ = *src++;
		if (i != 0)
			*ptr++ = ':';
	}

	if (gl_width != 320)
		*ptr++ = ' ';
	
	strcpy(ptr, &timebuf[4]);

	ptr += 3;
	return (intptr_t)ptr - (intptr_t)dst;
}


/* 104de: 00fd7fe6 */
/* 106de: 00e18a04 */
int16_t dr_code(P(PARMBLK *) parm)
PP(register intptr_t parm);
{
	register PARMBLK *pb;
	PARMBLK tmp;
	GRECT clipsave;
	int16_t len;
	
	pb = &tmp;
	LBCOPY(pb, parm, sizeof(*pb));
	gsx_fgclip(&clipsave);
	gsx_sclip((GRECT *)&pb->pb_xc);
	if ((pb->pb_prevstate ^ pb->pb_currstate) & SELECTED)
	{
		bb_fill(MD_XOR, FIS_SOLID, IP_SOLID, pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h);
	} else
	{
		bldstring(pb->pb_parm, thedesk->strbuf);
		gsx_fattr(TRUE, MD_REPLACE, BLACK);
		len = LBWMOV(ad_intin, thedesk->strbuf);
		gsx_ftblt(IBM, pb->pb_x, pb->pb_y, len);
		gsx_fattr(FALSE, MD_XOR, BLACK);
	}
	gsx_sclip(&clipsave);
	return pb->pb_currstate;
}


/* 306de: 00e2fb5a */
/* 104de: 00fd80aa */
/* 106de: 00e18af6 */
int16_t xform_do(P(OBJECT *)tree, P(int16_t) which)
PP(OBJECT *tree;)
PP(int16_t which;)
{
	short unused[4];
	int16_t events;
	int16_t dummy;
	int16_t ret;
	register int16_t *pdummy;
	THEDSK *d;
	
	d = thedesk;
	fm_draw(tree);
	ret = form_do(tree, which) & 0x7FFF;
	do_finish(tree);
	pdummy = &dummy;
	
	do
	{
		events = evnt_multi(MU_MESAG | MU_TIMER,
#if BINEXACT
			0L, 0L,
			0L, 0L,
			0L, 0L, 0,
#else
			0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
#endif
			d->p_msgbuf,
			0, 0,
			pdummy, pdummy, pdummy, pdummy, pdummy, pdummy);
		if (events & MU_MESAG)
			hd_msg();
	} while (events & MU_MESAG);
	LWSET(OB_STATE(ret), NORMAL);
	
	return ret;
}


/*
 * Form_do and draw
 */
/* 306de: 00e2fb90 */
/* 104de: 00fd813e */
/* 106de: 00e18ba6 */
VOID fmdodraw(P(OBJECT *) tree, P(int16_t) item)
PP(OBJECT *tree;)
PP(int16_t item;)
{
	xform_do(tree, 0);
	LWSET(OB_STATE(item), NORMAL);
}



BOOLEAN xfd8164(P(OBJECT *) tree, P(int16_t) foldersidx, P(int16_t) filesidx, P(char *) buf)
PP(OBJECT *tree;)
PP(int16_t foldersidx;)
PP(int16_t filesidx;)
PP(char *buf;)
{
	register THEDSK *d;
	int16_t dummy;
	char folderstr[6];
	char filesstr[6];
	BOOLEAN o16;
	
	d = thedesk;
	d->o12970 = 0;
	d->o12974 = 0;
	d->o12978 = 0;
	desk_wait(TRUE);
	o16 = xfd6e40(0, 0L, buf, buf, &dummy, &dummy);
	desk_wait(FALSE);
	if (o16 == FALSE)
		return FALSE;
	d->o12974--;
	xfd81e8(&d->o12970, folderstr, tree, foldersidx, FALSE);
	xfd81e8(&d->o12974, filesstr, tree, filesidx, FALSE);
	return TRUE;
}


VOID xfd81e8(P(int32_t *) p1, P(char *) buf, P(OBJECT *) tree, P(int16_t) obj, P(BOOLEAN) flag)
PP(int32_t *p1;)
PP(char *buf;)
PP(OBJECT *tree;)
PP(int16_t obj;)
PP(BOOLEAN flag;)
{
	char *str;
	int16_t len;
	int16_t buflen;
	TEDINFO *ted;

	if (flag)
	{
		fmt_str((char *) p1, buf);
		inf_sset(tree, obj, buf);
	} else
	{
		merge_str(buf, "%L", p1);
		ted = (TEDINFO *) LLGET(OB_SPEC(obj));
		str = ted->te_ptext;
		len = ted->te_txtlen - 1;
		bfill(len, ' ', str);
		buflen = (int)strlen(buf);
		strcpy(str + (len - buflen), buf);
	}
}


VOID xfd8284(P(OBJECT *) tree, P(FILEINFO *) info, P(int16_t) dateidx, P(int16_t) timeidx, P(int16_t) sizeidx, P(int32_t *) size)
PP(OBJECT *tree;)
PP(register FILEINFO *info;)
PP(int16_t dateidx;)
PP(int16_t timeidx;)
PP(int16_t sizeidx;)
PP(register int32_t *size;)
{
	char sizestr[10];
	char timestr[8];
	char datestr[8];
	
	fmt_date(info->i_date, datestr);
	inf_sset(tree, dateidx, datestr);
	fmt_time(info->i_time, timestr);
	inf_sset(tree, timeidx, timestr);
	xfd81e8(size, sizestr, tree, sizeidx, FALSE);
}
