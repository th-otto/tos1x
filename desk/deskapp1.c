/*       DESKAPP.C      06/11/84 - 07/11/85             Lee Lorenzen    */
/*      for 3.0         3/6/86   - 5/6/86               MDF             */
/*      for 2.3         9/25/87                         mdf             */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 2.3
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1987                      Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "desktop.h"


char const infdata[] = "DESKTOP.INF";
char infpath[LEN_ZFPATH];
int16_t infdrv;


LINEF_STATIC VOID set_infpath PROTO((NOTHING));
LINEF_STATIC VOID rest_infpath PROTO((NOTHING));



/* 104de: 00fd4cb0 */
/* 106de: 00e150e2 */
APP *app_alloc(P(BOOLEAN) atend)
PP(register BOOLEAN atend;)
{
	register APP *app;
	register APP *p;
	register THEDSK *d;
	
	d = thedesk;
	app = d->appfree;
	if (app)
	{
		d->appfree = app->a_next;
		if (atend || d->applist == NULL)
		{
			app->a_next = d->applist;
			d->applist = app;
		} else
		{
			p = d->applist;
			while (p->a_next != NULL)
				p = p->a_next;
			p->a_next = app;
			app->a_next = NULL;
		}
		return app;
	} else
	{
		return NULL;
	}
}


/*
 * Free an application node
 */
/* 104de: 00fd4cfc */
VOID app_free(P(APP *) app)
PP(register APP *app;)
{
	register APP *p;
	register THEDSK *d;
	
	d = thedesk;
	if (app == d->applist)
	{
		d->applist = app->a_next;
	} else
	{
		p = d->applist;
		while (p != NULL && p->a_next != app)
			p = p->a_next;
		if (p != NULL)
			p->a_next = app->a_next;
	}
	app->a_next = d->appfree;
	d->appfree = app;
}


/*
 *	Convert a single hex ASCII digit to a number
 */
/* 306de: 00e2c064 */
/* 104de: 00fd4d3a */
LINEF_STATIC int16_t hex_dig(P(char) achar)
PP(register char achar;)
{
	if (achar >= '0' && achar <= '9')
		return achar - '0';

	if (achar >= 'A' && achar <= 'F')
		return achar - 'A' + 10;

	return 0;
}


/*
 * Reverse of hex_dig()
 */
/* 306de: 00e2b5b4 */
/* 104de: 00fd4d76 */
LINEF_STATIC char uhex_dig(P(int16_t) wd)
PP(register int16_t wd;)
{
	if (wd >= 0 && wd <= 9)
		return wd + '0';

	if (wd >= 0x0a && wd <= 0x0f)
		return wd + 'A' - 0x0a;

	return ' ';
}


/*
 * Scan off and convert the next two hex digits and return with
 * pcurr pointing one space past the end of the four hex digits
 */
/* 306de: 00e2b62a */
/* 104de: 00fd4dac */
char *scan_2(P(const char *) pcurr, P(int16_t *) pwd)
PP(register const char *pcurr;)
PP(register int16_t *pwd;)
{
	register uint16_t temp;

	temp = 0x0;
	temp |= hex_dig(*pcurr++) << 4;
	temp |= hex_dig(*pcurr++);
	if (temp == 0x00ff)
		temp = -1;
	*pwd = temp;
	pcurr++;
	return NO_CONST(pcurr);
}


/*
 * Reverse of scan_2()
 */
/* 306de: 00e2b66e */
/* 104de: 00fd4de4 */
char *save_2(P(char *) pcurr, P(uint16_t) wd)
PP(char *pcurr;)
PP(uint16_t wd;)
{
	*pcurr++ = uhex_dig((wd >> 4) & 0x000f);
	*pcurr++ = uhex_dig(wd & 0x000f);
	*pcurr++ = ' ';
	return pcurr;
}


/* 306de: 00e2b5f2 */
/* 104de: 00fd4e14 */
char *escan_str(P(const char *)pcurr, P(char **)ppstr)
PP(register const char *pcurr;)
PP(register char **ppstr;)
{
	register THEDSK *d;
	
	d = thedesk;
	while (*pcurr == ' ')
		pcurr++;

	*ppstr = d->g_pbuff;
	while (*pcurr != '@')
		*(d->g_pbuff)++ = *pcurr++;

	*d->g_pbuff++ = '\0';
	pcurr++;
	return NO_CONST(pcurr);
}


/*
 * Reverse of scan_str
 */
/* 306de: 00e2b6ac */
/* 104de: 00fd4e5a */
char *save_sstr(P(char *)pcurr, P(const char *)pstr)
PP(register char *pcurr;)
PP(register const char *pstr;)
{
	while (*pstr)
		*pcurr++ = *pstr++;
	*pcurr++ = '@';
	*pcurr++ = ' ';
	return pcurr;
}


/*
 * Scan the desktop icon
 */
/* 306de: 00e2b6dc */
/* 104de: 00fd4e82 */
LINEF_STATIC const char *inf_xdesk(P(const char *)pcurr, P(APP *) app)
PP(register const char *pcurr;)
PP(register APP *app;)
{
	switch (*pcurr)
	{
	case 'T':							/* trashcan */
		app->a_type = AT_ISTRSH;
		app->a_apptype = DISK;
		break;
	case 'M':							/* disk drive   */
		app->a_type = AT_ISDISK;
		app->a_apptype = DISK;
		break;
	case 'C':							/* cartridge    */
		app->a_type = AT_ISCART;
		app->a_apptype = DISK;
		break;
	case 'G':
		app->a_type = AT_ISFILE;
		app->a_apptype = PRG;
		break;
	case 'F':
		app->a_type = AT_ISFILE;
		app->a_apptype = TOS;
		break;
	case 'P':
		app->a_type = AT_ISFILE;
		app->a_apptype = TTP;
		break;
	case 'D':
		app->a_type = AT_ISFOLD;
		/* break; */
	}

	pcurr += 2;
	if (app->a_apptype & AF_ISDESK)
	{
		pcurr = scan_2(pcurr, &app->a_x);
		pcurr = scan_2(pcurr, &app->a_y);
	}

	pcurr = scan_2(pcurr, &app->a_aicon);			/* get the icon id  */
	pcurr = scan_2(pcurr, &app->a_dicon);
	
	app->a_char = *pcurr == ' ' ? 0 : *pcurr;
	pcurr += 2;
	
	pcurr = escan_str(pcurr, &app->a_pappl);
	pcurr = escan_str(pcurr, &app->a_pdata);
	
	return pcurr;
}


VOID app_tran(P(int16_t) bi_num)
PP(int16_t bi_num;)
{
	BITBLK *lpbi;
	BITBLK lb;

	rsrc_gaddr(R_BITBLK, bi_num, (VOIDPTR *)&lpbi);

	LBCOPY(ADDR(&lb), (VOIDPTR) lpbi, sizeof(BITBLK));
	gsx_trans(lb.bi_pdata, lb.bi_wb, lb.bi_pdata, lb.bi_wb, lb.bi_hl);
}


int16_t app_getfh(P(BOOLEAN) openit, P(char *) pname, P(int16_t) attr)
PP(BOOLEAN openit;)
PP(register char *pname;)
PP(register int16_t attr;)
{
	register int handle;
	register THEDSK *d;
	register LPBYTE lp;

	d = thedesk;
	handle = 0;
	strcpy(d->g_srcpth, pname);
	lp = (LPBYTE)ADDR(&d->g_srcpth[0]);
	if (openit)
		handle = dos_open((char *)lp, RMODE_RW);
	else
		handle = dos_create((char *)lp, attr);
	if (DOS_ERR)
	{
		handle = 0;
	}
	return handle;
}


BOOLEAN app_rdicon(NOTHING)
{
	register THEDSK *d;
	intptr_t temp;
	intptr_t stmp;
	intptr_t dtmp;
	int16_t handle;
	int16_t length;
	int16_t nread;
	register int16_t num_icons;
	register int16_t last_icon;
	register int i;
	int16_t iwb;
	int16_t ih;
	int16_t num_wds;
	int16_t num_bytes;
	int16_t num_masks;
	uint16_t msk_bytes;
	register int16_t tmp;
	uint16_t stlength;
	
	UNUSED(handle);
	d = thedesk;
	/* how much to read? */
	length = NUM_IBLKS * (int)sizeof(ICONBLK);
	/* read it */
	nread = rom_ram(2, (intptr_t)d->iconaddr, length);
	movs(length, d->iconaddr, d->g_iblist);
	/* find no. of icons actually used */
	num_icons = last_icon = 0;
	/* BUG: range not checked; that makes the last icon structure unusable */
	while (d->iconaddr[last_icon].ib_pmask != (VOIDPTR) -1L)
	{
		/* Note: the ib_pmask and ib_pdata are indices, not pointers */
		tmp = max(LLOWD((intptr_t)d->iconaddr[last_icon].ib_pmask), LLOWD((intptr_t)d->iconaddr[last_icon].ib_pdata));
		num_icons = max(num_icons, tmp);
		last_icon++;
	}
	num_icons++;
	/* how many words of data to read? */
	/* assume all icons are same w,h as first */
	num_wds = (d->iconaddr[0].ib_wicon * d->iconaddr[0].ib_hicon) / 16;
	num_bytes = num_wds * 2;
	/* allocate some memory in bytes */
	stlength = num_icons * num_bytes;
	d->icondata = (intptr_t)dos_alloc((long)stlength); /* BUG: no malloc check */
	/* read it */
	nread = rom_ram(4, d->icondata, length);
	UNUSED(nread);
	/* fix up str ptrs */
	
	/* figure out which are mask & which data */
	for (i = 0; i < last_icon; i++)
	{
		d->g_ismask[(int16_t)(intptr_t)d->iconaddr[i].ib_pmask] = TRUE;
		d->g_ismask[(int16_t)(intptr_t)d->iconaddr[i].ib_pdata] = FALSE;
	}

	/* fix up mask ptrs */
	num_masks = 0;
	for (i = 0; i < num_icons; i++)
	{
		if (d->g_ismask[i])
		{
			d->g_ismask[i] = num_masks;
			num_masks++;
		} else
		{
			d->g_ismask[i] = -1;
		}
	}

	/* allocate memory for transformed mask forms */
	msk_bytes = num_masks * num_bytes;
	d->a_buffstart = (intptr_t)dos_alloc((long) msk_bytes);
	
	/* fix up icon pointers */
	for (i = 0; i < last_icon; i++)
	{
		/* first the mask */
		temp = (d->g_ismask[(int16_t)(intptr_t)d->iconaddr[i].ib_pmask] * (long) num_bytes);
		d->g_iblist[i].ib_pmask = (VOIDPTR) (d->a_buffstart + LW(temp));
		temp = ((intptr_t) d->iconaddr[i].ib_pmask * (long) num_bytes);
		d->iconaddr[i].ib_pmask = (VOIDPTR) (d->icondata + LW(temp));
		/* now the data */
		temp = ((intptr_t) d->iconaddr[i].ib_pdata * (long) num_bytes);
		d->g_iblist[i].ib_pdata = d->iconaddr[i].ib_pdata = (VOIDPTR) (d->icondata + LW(temp));
#if 0
		/* now the text ptrs */
		d->iconaddr[i].ib_ytext = d->g_iblist[i].ib_ytext = d->iconaddr[0].ib_hicon;
		d->iconaddr[i].ib_wtext = d->g_iblist[i].ib_wtext = 12 * gl_wschar;
		d->iconaddr[i].ib_htext = d->g_iblist[i].ib_htext = gl_hschar + 2;
#endif
	}

	/* transform forms  */
	iwb = d->iconaddr[0].ib_wicon / 8;
	ih = d->iconaddr[0].ib_hicon;

	for (i = 0; i < num_icons; i++)
	{
		if (d->g_ismask[i] != -1)
		{
			/* preserve standard form of masks */
			stmp = d->icondata + i * num_bytes;
			dtmp = d->a_buffstart + d->g_ismask[i] * num_bytes;
			LWCOPY((VOIDPTR)dtmp, (VOIDPTR)stmp, num_wds);
		} else
		{
			/* transform over std. form of datas */
			dtmp = d->icondata + (i * num_bytes);
		}
		gsx_trans((VOIDPTR)dtmp, iwb, (VOIDPTR)dtmp, iwb, ih);
	}

	/* initialize bit images */	
#if NUM_BB == 1
	app_tran(0);
#else
	for (i = 0; i < NUM_BB; i++)
		app_tran(i);
#endif

	return TRUE;
}


/*
 * Transform mouse position into icon position
 */
/* 306de: 00e2c8b6 */
/* 104de: 00fd4f6e */
VOID app_mtoi(P(int16_t) newx, P(int16_t) newy, P(int16_t *)px, P(int16_t *)py)
PP(int16_t newx;)
PP(int16_t newy;)
PP(register int16_t *px;)
PP(register int16_t *py;)
{
	register THEDSK *d;
	register int16_t x, y, w, h;
	int16_t xm, ym;

	d = thedesk;

	w = d->g_icw;
	x = newx / w;
	xm = newx % w;
	if (xm > (w / 2))
		*px = (x + 1) * w;
	else
		*px = x * w;
	*px = min(*px, gl_width - w);
	if (*px > (gl_width / 2))
		*px += gl_width % w;
	
	newy -= d->g_desk.g_y;
	h = d->g_ich;
	y = newy / h;
	ym = newy % h;
	
	if (ym > (h / 2))
		*py = (y + 1) * h;
	else
		*py = y * h;
	*py = min(*py, d->g_desk.g_h - h);
	if (*py > (d->g_desk.g_h / 2))
		*py += d->g_desk.g_h % h;
	*py += d->g_desk.g_y;
}


/*
 *	Initialize the application list by reading in the DESKTOP.APP
 *	file, either from memory or from the disk if the shel_get
 *	indicates no message is there.
 */

/* 104de: 00fd5062 */
/* 106de: 00e15508 */
BOOLEAN read_inf(NOTHING)
{
	register int16_t i, tmp;
	register WSAVE *pws;
	register const char *pcurr;
	register THEDSK *d;
	APP *app;
	int16_t j;
	char *ptr;
	int16_t handle;
	int16_t envr;
	int16_t w;
	int16_t h;
	
	UNUSED(tmp);
	UNUSED(j);

	d = thedesk;
	
	d->g_pbuff = d->appbuf;
	
	/* set up linked array */
	for (i = NUM_ANODES - 2; i >= 0; i--)
	{
		d->app[i].a_next = &d->app[i + 1];
	}
	d->applist = NULL;
	d->appfree = d->app;
	d->app[NUM_ANODES - 1].a_next = NULL;
	
	shel_get(d->afile, SIZE_AFILE);

	if (d->afile[0] != '#')
	{
		if (isdrive())
		{
			handle = app_getfh(TRUE, "DESKTOP.INF", 0);
			if (handle == 0)
			{
				d->size_afile = rom_ram(3, (intptr_t)d->afile, 0);
			} else
			{
				d->size_afile = dos_read(handle, SIZE_AFILE, d->afile); /* BUG: size passed as int */
				dos_close(handle);
			}
		} else
		{
			d->size_afile = rom_ram(3, (intptr_t)d->afile, 0);
		}

		d->afile[d->size_afile] = 0; /* BUG: may write beyond end-of-buffer */
	}

	i = 0;								/* for window index */
	pcurr = d->afile;
	
	while (*pcurr)						/* 0 is marked as end of buffer */
	{
		if (*pcurr != '#')
		{
			pcurr++;
		} else
		{
			pcurr++;
			switch (*pcurr)
			{
#if TOSVERSION >= 0x104
			case 'Z':					/* auto boot file */
				pcurr += 2;
				pcurr = escan_str(pcurr, (char **)d->autofile);
				break;
#endif
	
			case 'C':
				if (cart_init())
					goto xdesk;
				break;
	
			case 'M':
			case 'T':
				if (!(tmp = isdrive()))
					break;
				if (pcurr[14] == 'C' && !(tmp & 0x04))
					break;
				/* fall through */
			case 'D':
			case 'F':
			case 'G':
			case 'P':
			xdesk:
				app = app_alloc(TRUE);
				/* BUG: no check */
				pcurr = inf_xdesk(pcurr, app);
				break;
	
			case 'W':					/* Window       */
				pcurr += 2;
	
				/* BUG: no check for overflow here */
				pws = &d->g_cnxsave.win_save[i++];
				/* horizontal slide bar */
				pcurr = scan_2(pcurr, &pws->hsl_save);
				/* vertical slide bar */
				pcurr = scan_2(pcurr, &pws->vsl_save);
	
				/* window's x position */
				pcurr = scan_2(pcurr, &pws->gr_save.g_x);
				if (pws->gr_save.g_x > gl_ncols)
					pws->gr_save.g_x /= 2;
	
				pws->gr_save.g_x *= gl_wchar;
	
				/* window's y position */
				pcurr = scan_2(pcurr, &pws->gr_save.g_y);
	
				pws->gr_save.g_y *= gl_hchar;
	
				/* window's width */
				pcurr = scan_2(pcurr, &pws->gr_save.g_w);
				if (pws->gr_save.g_w > gl_ncols)
					pws->gr_save.g_w /= 2;
				pws->gr_save.g_w *= gl_wchar;
				if (pws->gr_save.g_w < (7 * gl_wbox))
					pws->gr_save.g_w = 7 * gl_wbox;
	
				/* window's height  */
				pcurr = scan_2(pcurr, &pws->gr_save.g_h);
				pws->gr_save.g_h *= gl_hchar;
				if (pws->gr_save.g_h < (7 * gl_hbox))
					pws->gr_save.g_h = 7 * gl_hbox;
	
				pcurr = scan_2(pcurr, &pws->obid_save);
	
				ptr = pws->pth_save;
				while (*pcurr != '@')
				{
					*ptr++ = *pcurr++;
				}
				*ptr = 0;				/* take out the @ */
	
				break;
	
			case 'E':					/* environment string   */
				pcurr += 2;
	
				pcurr = scan_2(pcurr, &envr);
				d->g_cnxsave.vitem_save = (envr & 0x80) != 0;
				d->g_cnxsave.sitem_save = (envr & 0x60) >> 5;
				d->g_cnxsave.cdele_save = (envr & 0x10) != 0;
				d->g_cnxsave.ccopy_save = (envr & 0x08) != 0;
#if TOSVERSION >= 0x104
				d->g_cnxsave.covwr_save = envr & 0x01;
#else
				d->g_cnxsave.cdclk_save = envr & 0x07;
#endif
				pcurr = scan_2(pcurr, &envr);
#if TOSVERSION >= 0x104
				d->g_cnxsave.cbit_save = (envr & 0xf0) >> 4;
#endif
				envr = envr & 3;
				envr++;
				d->g_cnxsave.pref_save = gl_restype - 1;
				/* break; */
			}
		}
	}
	if (!app_rdicon())
		return FALSE;

	d->g_wicon = (d->iconaddr[0].ib_xtext << 1) + d->iconaddr[0].ib_wtext;
	d->g_hicon = d->iconaddr[0].ib_hicon + d->iconaddr[0].ib_htext /* + 2 */;
	d->g_icw = gl_height <= 300 ? 0 : 8;
	d->g_icw += d->g_wicon;
	w = gl_width / d->g_icw;
	d->g_icw += (gl_width % d->g_icw) / w;
	d->g_ich = d->g_hicon + 2;
	h = (gl_height - gl_hbox) / d->g_ich;
	d->g_ich += ((gl_height - gl_hbox) % d->g_ich) / h;

	for (app = d->applist; app; app = app->a_next)
	{
		app_mtoi(app->a_x * d->g_icw, app->a_y * d->g_ich + d->g_desk.g_y, &app->a_x, &app->a_y);
	}

	d->g_nmicon = 9;
	d->g_nmtext = 5;
	memset(d->g_xyicon, 0, 9 * sizeof(d->g_xyicon[0])); /* BUG */
	d->g_xyicon[0] = gl_wschar << 2;
	d->g_xyicon[2] = gl_wschar << 2;
	d->g_xyicon[3] = d->g_hicon - gl_wschar - 2;
	d->g_xyicon[5] = d->g_hicon - gl_wschar - 2;
	d->g_xyicon[7] = d->g_hicon;
	d->g_xyicon[8] = d->g_wicon;
	d->g_xyicon[9] = d->g_hicon;
	d->g_xyicon[10] = d->g_wicon;
	d->g_xyicon[11] = d->g_hicon - gl_wschar - 2;
	d->g_xyicon[12] = gl_wschar << 3;
	d->g_xyicon[13] = d->g_hicon - gl_wschar - 2;
	d->g_xyicon[14] = gl_wschar << 3;
	d->g_xyicon[16] = gl_wschar << 2;
	memset(d->g_xytext, 0, 5 * sizeof(d->g_xytext[0])); /* BUG */
	d->g_xytext[2] = gl_wchar * 12;
	d->g_xytext[4] = gl_wchar * 12;
	d->g_xytext[5] = gl_hchar;
	d->g_xytext[7] = gl_hchar;
	return TRUE;
}


/* 306de: 00e27d68 */
/* 104de: 00fd5596 */
BOOLEAN app_reschange(P(int16_t) res)
PP(int16_t res;)
{
	if (res == gl_restype)
	{
		return FALSE;
	} else
	{
		gl_restype = res;
		gl_rschange = TRUE;
		return TRUE;
	}
}


/*
 * Reverse list when we write so that we can read it in naturally
 */
/* 104de: 00fd55be */
LINEF_STATIC VOID app_reverse(NOTHING)
{
	register APP *app;
	register APP *next;
	register THEDSK *d;
	
	d = thedesk;
	app = d->applist;
	d->applist = NULL;
	while (app)
	{
		next = app->a_next;
		app->a_next = d->applist;
		d->applist = app;
		app = next;
	}
}


/*
 * Save a desktop.inf file
 */
/* 206de: 00e28720 */
/* 306de: 00e2c186 */
/* 104de: 00fd55e8 */
/* 106de: 00e15aee */
BOOLEAN save_inf(P(BOOLEAN) todisk)
PP(BOOLEAN todisk;)
{
	register char *pcurr;
	register WSAVE *win;
	register THEDSK *d;
	int16_t envr;
	register int16_t i;
	char buf1[2];
	char *ptmp;
	register int16_t handle;
	register int16_t j;
	APP *app;
	DESKWIN *top;

	UNUSED(buf1);
	UNUSED(j);

	d = thedesk;
	pcurr = d->afile + SAVE_ATARI;
	memset(pcurr, 0, SIZE_AFILE - SAVE_ATARI);
	
#if TOSVERSION >= 0x104
	if (d->autofile[0])
	{
		*pcurr++ = '#';
		*pcurr++ = 'Z';
		*pcurr++ = ' ';
		pcurr = save_sstr(pcurr, d->autofile);
		*pcurr++ = 0x0d;
		*pcurr++ = 0x0a;
	}
#endif

	/* save evironment */
	*pcurr++ = '#';
	*pcurr++ = 'E';
	*pcurr++ = ' ';
	envr = 0x0;
#if TOSVERSION >= 0x104
	envr |= d->g_cnxsave.covwr_save;
#endif
	envr |= d->g_cnxsave.vitem_save ? 0x80 : 0x00;
	envr |= (d->g_cnxsave.sitem_save << 5) & 0x60;
	envr |= d->g_cnxsave.cdele_save ? 0x10 : 0x00;
	envr |= d->g_cnxsave.ccopy_save ? 0x08 : 0x00;
#if TOSVERSION < 0x104
	envr |= d->g_cnxsave.cdclk_save;
#endif
	pcurr = save_2(pcurr, envr);

	envr = 0x0;							/* set resolution prefence  */
	envr |= d->g_cnxsave.pref_save;
#if TOSVERSION >= 0x104
	envr |= (d->g_cnxsave.cbit_save << 4);			/* High order bit       */
#endif
	pcurr = save_2(pcurr, envr);

	*pcurr++ = 0x0d;
	*pcurr++ = 0x0a;

	/********* save the opened window first	************/

	/* save windows */
	for (i = 0; i < NUM_WNODES; i++)
	{
		*pcurr++ = '#';
		*pcurr++ = 'W';
		*pcurr++ = ' ';
	
		win = &d->g_cnxsave.win_save[i];
		pcurr = save_2(pcurr, win->hsl_save);	/* horizontal slide bar  */
		pcurr = save_2(pcurr, win->vsl_save);
		pcurr = save_2(pcurr, win->gr_save.g_x / gl_wchar);
		pcurr = save_2(pcurr, win->gr_save.g_y / gl_hchar);
		pcurr = save_2(pcurr, win->gr_save.g_w / gl_wchar);
		pcurr = save_2(pcurr, win->gr_save.g_h / gl_hchar);
		pcurr = save_2(pcurr, win->obid_save);
	
		ptmp = win->pth_save;
		while (*ptmp)
			*pcurr++ = *ptmp++;
	
		*pcurr++ = '@';
		*pcurr++ = 0x0d;
		*pcurr++ = 0x0a;
	}

	/*******************************************************/
	app_reverse();
	for (app = d->applist; app; app = app->a_next)
	{
		if (((intptr_t)pcurr - (intptr_t)d->afile) >= (SIZE_AFILE - 35))
			break;
		
		*pcurr++ = '#';

		switch (app->a_type)
		{
		case AT_ISTRSH:
			*pcurr++ = 'T';
			break;
		case AT_ISDISK:
			*pcurr++ = 'M';
			break;
		case AT_ISCART:
			*pcurr++ = 'C';
			break;
		case AT_ISFILE:
			if ((app->a_apptype & AF_ISCRYS) && (app->a_apptype & AF_ISGRAF))
				*pcurr++ = 'G';
			else
				*pcurr++ = app->a_apptype & AF_ISPARM ? 'P' : 'F';
			break;
		case AT_ISFOLD:
			*pcurr++ = 'D';
			/* break; */
		}

		*pcurr++ = ' ';

		if (app->a_apptype & AF_ISDESK)
		{
			pcurr = save_2(pcurr, app->a_x / d->g_icw);
			pcurr = save_2(pcurr, (app->a_y - d->g_desk.g_y) / d->g_ich);
		}
		pcurr = save_2(pcurr, app->a_aicon);
		pcurr = save_2(pcurr, app->a_dicon);
		*pcurr++ = app->a_char == 0 ? ' ' : app->a_char;
		*pcurr++ = ' ';
		pcurr = save_sstr(pcurr, app->a_pappl);
		pcurr = save_sstr(pcurr, app->a_pdata);
		*pcurr++ = 0x0d;
		*pcurr++ = 0x0a;
	}

	*pcurr++ = 0x1a; /* Ctrl-Z */
	*pcurr++ = 0;

	app_reverse();
	
	/* Note: counts also trail zero */
	d->size_afile = (intptr_t)pcurr - (intptr_t)d->afile;

	shel_get(d->afile, SAVE_ATARI);
	shel_put(d->afile, SIZE_AFILE);
		
	if (todisk)
	{
		--d->size_afile; /* strip trailing zero */
		set_infpath();
		handle = app_getfh(FALSE, "DESKTOP.INF", 0);

		if (handle == 0)
		{
			dos_error();
			rest_infpath();
			return TRUE;
		}
		d->size_afile = dos_write(handle, d->size_afile, d->afile);
		dos_close(handle);
		rest_infpath();
		/* rebuild any window on the INF drive */
		top = win_ontop();
		if (top)
			up_1win(top);
	}

#if !BINEXACT
	/* BUG: no return value */
	return FALSE;
#endif
}


LINEF_STATIC VOID set_infpath(NOTHING)
{
	char root[4];
	
	infdrv = dos_gdrv();
	dos_gdir(infdrv + 1, infpath);
	root[0] = 'A';
	root[1] = ':';
	root[2] = '\\';
	root[3] = '\0';
	if (set_defdrv())
		root[0] = 'C';
	dos_chdir(root);
}


LINEF_STATIC VOID rest_infpath(NOTHING)
{
	dos_sdrv(infdrv);
	dos_chdir(infpath);
}


/*
 * return TRUE if HARD DISK
 * Doesn't NEED to return anything -- 881109 kbad
 */
/* 306de: 00e1e556 */
/* 104de: 00fd598e */
BOOLEAN set_defdrv(NOTHING)
{
#if 0
	/* This fugly statement gets drvbits, masks drive C,
	 *  and does a GEMDOS Setdrive to drive A (0) if C doesn't exist,
	 *  or to C (2) if it does exist.  Don't ask.  It had to be shrunk.
	 */
	dos_sdrv((isdrive() & 0x04) >> 1);
#else
	int unused;
	
	UNUSED(unused);
	if (isdrive() & 0x04)
	{
		dos_sdrv(2);
		return TRUE;
	} else
	{
		dos_sdrv(0);
		return FALSE;
	}
#endif
}
