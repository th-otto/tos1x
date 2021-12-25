/*      DESKINF.C       09/03/84 - 05/29/85     Gregg Morris            */
/*      for 3.0 & 2.1   5/5/86                  MDF                     */
/*      merge source    5/27/87  - 5/28/87      mdf                     */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 2.3
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1985 - 1987               Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "desktop.h"
#include "toserrno.h"
#include "taddr.h"


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
#if (OS_COUNTRY == CTRY_UK) | (OS_COUNTRY == CTRY_PL) | (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_ES) | (OS_COUNTRY == CTRY_IT) | (OS_COUNTRY == CTRY_SF) | (OS_COUNTRY == CTRY_NL)
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

	LBCOPY((char *)&buf.d_att, (VOIDPTR)dir, sizeof(DIR) - 1);
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
PP(register intptr_t parm;)
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
		bldstring(pb->pb_parm, thedesk->g_tmppth);
		gsx_fattr(TRUE, MD_REPLACE, BLACK);
		len = LBWMOV(ad_intin, thedesk->g_tmppth);
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
	
	UNUSED(unused);
	d = thedesk;
	fm_draw((LPTREE)tree);
	ret = form_do(tree, which) & 0x7FFF;
	do_finish(tree);
	pdummy = &dummy;
	
	do
	{
		events = evnt_multi(MU_MESAG | MU_TIMER,
#ifdef __ALCYON__
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



/*
 *	Routine to get number of files and folders and stuff them in
 *	a dialog box.
 */
/* 104de: 00fd8164 */
/* 106de: 00e18bd0 */
LINEF_STATIC BOOLEAN inf_fifo(P(OBJECT *) tree, P(int16_t) foldersidx, P(int16_t) filesidx, P(char *) ppath)
PP(OBJECT *tree;)
PP(int16_t foldersidx;)
PP(int16_t filesidx;)
PP(char *ppath;)
{
	register THEDSK *d;
	uint16_t dummy;
	char folderstr[6];
	char filesstr[6];
	BOOLEAN more;
	
	d = thedesk;
	d->g_nfiles = 0;
	d->g_ndirs = 0;
	d->g_size = 0;
	desk_wait(TRUE);
	more = d_doop(OP_COUNT, NULL, ppath, ppath, &dummy, &dummy);
	desk_wait(FALSE);
	if (more == FALSE)
		return FALSE;
	d->g_ndirs--;
	inf_setsize(&d->g_nfiles, folderstr, tree, foldersidx, FALSE);
	inf_setsize(&d->g_ndirs, filesstr, tree, filesidx, FALSE);
	return TRUE;
}


/* 104de: 00fd81e8 */
/* 106de: 00e18c68 */
VOID inf_setsize(P(const VOIDPTR) p1, P(char *) buf, P(OBJECT *) tree, P(int16_t) obj, P(BOOLEAN) flag)
PP(const VOIDPTR p1;)
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
		fmt_str(p1, buf);
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


/* 104de: 00fd8284 */
/* 106de: 00e18d20 */
LINEF_STATIC VOID inf_dttmsz(P(OBJECT *) tree, P(FNODE *) info, P(int16_t) dateidx, P(int16_t) timeidx, P(int16_t) sizeidx, P(int32_t *) size)
PP(OBJECT *tree;)
PP(register FNODE *info;)
PP(int16_t dateidx;)
PP(int16_t timeidx;)
PP(int16_t sizeidx;)
PP(register int32_t *size;)
{
	char sizestr[10];
	char timestr[8];
	char datestr[8];
	
	fmt_date(info->f_date, datestr);
	inf_sset(tree, dateidx, datestr);
	fmt_time(info->f_time, timestr);
	inf_sset(tree, timeidx, timestr);
	inf_setsize(size, sizestr, tree, sizeidx, FALSE);
}


/************************************************************************/
/* i n f _ f i l e                                                      */
/************************************************************************/
/* 104de: 00fd82e8 */
/* 106de: 00e18d9a */
BOOLEAN inf_file(P(char *) ppath, P(FNODE *) info, P(BOOLEAN) isdir)
PP(char *ppath;)
PP(register FNODE *info;)
PP(BOOLEAN isdir;)
{
	register char *a4;
	register THEDSK *d;
	register LPTREE tree;
	register int attr;
	register BOOLEAN more;
	register int nmidx;
	char poname[LEN_ZFNAME + 1];
	char pnname[LEN_ZFNAME + 1];
	char *title;
	short unused;
	int16_t strid;
	
	UNUSED(a4);
	UNUSED(unused);
	d = thedesk;
	tree = (LPTREE)d->g_atree[ADFILEIN];
	strcpy(d->g_srcpth, ppath);
	strcpy(d->g_dstpth, ppath);
	for (nmidx = 0; d->g_srcpth[nmidx] != '*'; nmidx++)
		;
	if (isdir == FALSE)
	{
		inf_fldset(tree, FIRONLY, info->f_attr, FA_RDONLY, SELECTED, NORMAL);
		inf_fldset(tree, FIRWRITE, info->f_attr, FA_RDONLY, NORMAL, SELECTED);
		inf_sset((OBJECT *)tree, FINFILES, "     ");
		inf_sset((OBJECT *)tree, FINFOLDS, "     ");
		strid = STFILEINFO;
		d->g_size = info->f_size;
	} else
	{
		LWSET(OB_STATE(FIRONLY), DISABLED);
		LWSET(OB_STATE(FIRWRITE), DISABLED);
		add_path(d->g_srcpth, info->f_name);
		strid = STFOLDINFO;
		if (inf_fifo((OBJECT *)tree, FINFILES, FINFOLDS, d->g_srcpth) == FALSE)
#ifdef __ALCYON__
			return; /* hmpf */
#else
			return FALSE;
#endif
	}
	
	rsrc_gaddr(R_STRING, strid, (VOIDPTR *) &title);
	((TEDINFO *)LLGET(OB_SPEC(INFTITLE)))->te_ptext = title;
	
	inf_dttmsz((OBJECT *)tree, info, FIDATE, FITIME, FISIZE, &d->g_size);
	inf_setsize(info->f_name, poname, (OBJECT *)tree, FINAME, TRUE);
	
	more = FALSE;
	if (xform_do((OBJECT *)tree, ROOT) == FIOK)
	{
		desk_wait(TRUE);
		fs_sget(tree, FINAME, pnname);
		/* unformat the strings     */
		unfmt_str(poname, &d->g_srcpth[nmidx]);
		unfmt_str(pnname, &d->g_dstpth[nmidx]);
		if (!streq(&d->g_srcpth[nmidx], &d->g_dstpth[nmidx]))
		{
			dos_rename(d->g_srcpth, d->g_dstpth);
			if (DOS_AX == E_ACCDN)
			{
				form_error(~E_ACCDN - 30);
			} else
			{
				if ((more = dos_error()))
					strcpy(info->f_name, &d->g_dstpth[nmidx]);
			}
		}
		
		/* update the attributes */
		attr = info->f_attr;
		if (LWGET(OB_STATE(FIRONLY)) & SELECTED)
			attr |= FA_RDONLY;
		else
			attr &= ~FA_RDONLY;
		if (!isdir && (char) attr != info->f_attr)
		{
			dos_chmod(d->g_dstpth, TRUE, attr);
			if ((more = dos_error()))
				info->f_attr = attr;
		}
		desk_wait(FALSE);
		return more;
	} else
	{
		return FALSE;
	}
}


/************************************************************************/
/* i n f _ d i s k                                                      */
/************************************************************************/
/* 104de: 00fd8538 */
/* 106de: 00e1904a */
BOOLEAN inf_disk(P(char) drv_id)
PP(char drv_id;)
{
	register THEDSK *d;
	register LPTREE tree;
	int32_t total;
	int32_t avail;
	BOOLEAN more;
	char puse_str[12];
	char pav_str[10];
	char tmp_str[12];
	char drive[2];
	char plab_str[12];
	
	UNUSED(more);
	d = thedesk;
	tree = (LPTREE)d->g_atree[ADDISKIN];
	drive[0] = drv_id;
	drive[1] = '\0';
	d->g_srcpth[0] = drive[0];
	strcpy(&d->g_srcpth[1], ":\\*.*");
	if (inf_fifo((OBJECT *)tree, DINFILES, DINFOLDS, d->g_srcpth))
	{
		desk_wait(TRUE);
		dos_space(drv_id - 'A' + 1, &total, &avail);
		tmp_str[0] = '\0';
		dos_label(drv_id - 'A' + 1, tmp_str);
		fmt_str(tmp_str, plab_str);
		inf_sset((OBJECT *)tree, DIDRIVE, drive);
		inf_sset((OBJECT *)tree, DIVOLUME, plab_str);
		inf_setsize(&d->g_size, puse_str, (OBJECT *)tree, DIUSED, FALSE);
		inf_setsize(&avail, pav_str, (OBJECT *)tree, DIAVAIL, FALSE);
		desk_wait(FALSE);
		fmdodraw((OBJECT *)tree, DIOK);
	}
	return TRUE;
}
