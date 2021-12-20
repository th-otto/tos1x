/*      DESKINF.C               05/04/89 - 09/18/89     D.Mui           */
/*      Read in different setting of color and pattern depends on the   */
/*      color                   6/28/90                 D.Mui           */
/*      Put in default values of color and pattern      7/2/90  D.Mui   */
/*      Changed default color   7/20/90                 D.Mui           */
/*      Save_inf returns status and move the up_allwin 8/14/91  D.Mui   */
/*      Added another 0x00 to mkeys[] for VIDITEM obj  07/07/92 C.Gee   */
/*      Change all the iconblk to ciconblk      7/11/92 D.Mui           */
/*      The #E will save 10 fields instead of 4 7/17/92 D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"


char const infdata[] = "DESKTOP.INF";




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
PP(register char *pcurr;)
PP(uint16_t wd;)
{
	*pcurr++ = uhex_dig((wd >> 4) & 0x000f);
	*pcurr++ = uhex_dig(wd & 0x000f);
	*pcurr++ = ' ';
	return pcurr;
}


/* 306de: 00e2b5f2 */
/* 104de: 00fd4e14 */
char *escan_str(P(const char *)pcurr, P(char *)ppstr)
PP(register const char *pcurr;)
PP(register char *ppstr;)
{
	while (*pcurr == ' ')
		pcurr++;

	while (*pcurr != '@')
		*ppstr++ = *pcurr++;

	*ppstr = 0;
	pcurr++;
	return NO_CONST(pcurr);
}


/* 104de: 00fd4e40 */
char *escani_str(P(const char *)pcurr, P(char **)ppstr)
PP(register const char *pcurr;)
PP(char **ppstr;)
{
	return escan_str(pcurr, *ppstr);
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
	while (*pstr && pstr) /* BUG: && pstr useless when first acessing it */
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
		break;
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
	
	pcurr = escani_str(pcurr, &app->a_pappl);
	pcurr = escani_str(pcurr, &app->a_pdata);
	
	return pcurr;
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
	ICONBLK *icons;
	int16_t temp;
	
	UNUSED(tmp);
	UNUSED(j);

	d = thedesk;
	
	d->appnode = (APP *)d->appbuf;
	ptr = d->appbuf;
	
	/* set up linked array */
	for (i = NUM_ANODES - 1; i >= 0; i--)
	{
		d->app[i].a_next = &d->app[i + 1];
		d->app[i].a_pappl = ptr;
		ptr += PATH_LEN;
		d->app[i].a_pdata = ptr;
		ptr += EXTENSION;
	}
	d->applist = NULL;
	d->appfree = d->app;
	d->app[NUM_ANODES - 1].a_next = NULL;
	
	shel_get(d->afile, SIZE_AFILE);

	if (d->afile[0] != '#')
	{
		if (isdrive())
		{
			handle = dos_open(infdata, RMODE_RW);  /* WTF? why read/write? */
			if (handle > 0)
			{
				d->size_afile = dos_read(handle, SIZE_AFILE, d->afile);
				dos_close(handle);
			} else
			{
				goto re_1;
			}
		} else
		{
		re_1:
#if BINEXACT
			d->size_afile = rom_ram(3, (intptr_t)d->afile, 0); /* BUG: extra parameter */
#else
			d->size_afile = rom_ram(3, (intptr_t)d->afile);
#endif
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
			continue;
		}

		pcurr++;
		switch (*pcurr)
		{
		case 'Z':					/* auto boot file */
			pcurr += 2;
			pcurr = escan_str(pcurr, d->autofile);
			break;

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
			if ((app = app_alloc(TRUE)) != NULL)
			{
				pcurr = inf_xdesk(pcurr, app);
			} else
			{
				goto eof;
			}
			break;

		case 'W':					/* Window       */
			pcurr += 2;

			/* BUG: no check for overflow here */
			pws = &d->win_save[i++];
			/* horizontal slide bar */
			pcurr = scan_2(pcurr, &pws->hsl_save);
			/* vertical slide bar */
			pcurr = scan_2(pcurr, &pws->vsl_save);

			/* window's x position */
			pcurr = scan_2(pcurr, &pws->x_save);
			if (pws->x_save >= gl_ncols)
				pws->x_save /= 2;

			pws->x_save *= gl_wchar;

			/* window's y position */
			pcurr = scan_2(pcurr, &pws->y_save);

			pws->y_save *= gl_hchar;

			/* window's width */
			pcurr = scan_2(pcurr, &pws->w_save);
			if (pws->w_save > gl_ncols)
				pws->w_save /= 2;
			pws->w_save *= gl_wchar;
			if (pws->w_save < (7 * gl_wbox))
				pws->w_save = 7 * gl_wbox;

			/* window's height  */
			pcurr = scan_2(pcurr, &pws->h_save);
			pws->h_save *= gl_hchar;
			if (pws->h_save < (7 * gl_hbox))
				pws->h_save = 7 * gl_hbox;

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
			d->vitem_save = (envr & 0x80) != 0;
			d->sitem_save = (envr & 0x60) >> 5;
			d->cdele_save = (envr & 0x10) != 0;
			d->ccopy_save = (envr & 0x08) != 0;
			d->covwr_save = envr & 0x01;
			pcurr = scan_2(pcurr, &envr);
			d->cbit_save = (envr & 0xf0) >> 4;
			d->pref_save = gl_restype - 1;
			break;
		}
	}
eof:;
	temp = (NUM_IB + 1) * sizeof(ICONBLK); /* BUG: there are only 5 icons */
	rsrc_gaddr(R_ICONBLK, 0, (VOIDPTR *)&icons);
	LBCOPY(d->iconaddr, icons, temp);
	LBCOPY(d->g_iblist, icons, temp);
	d->iconaddr[0].ib_xchar = 5;
	d->iconaddr[0].ib_ychar = 14;
	d->g_iblist[0].ib_xchar = 5;
	d->g_iblist[0].ib_ychar = 14;
	d->g_wicon = (d->iconaddr[0].ib_xtext << 1) + d->iconaddr[0].ib_wtext;
	d->g_hicon = d->iconaddr[0].ib_hicon + d->iconaddr[0].ib_htext + 2;
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
	d->g_xyicon[2] = d->g_xyicon[0];
	d->g_xyicon[3] = d->g_hicon - gl_wschar - 2;
	d->g_xyicon[5] = d->g_xyicon[3];
	d->g_xyicon[7] = d->g_hicon;
	d->g_xyicon[8] = d->g_wicon;
	d->g_xyicon[9] = d->g_hicon;
	d->g_xyicon[10] = d->g_wicon;
	d->g_xyicon[11] = d->g_hicon - gl_wschar - 2;
	d->g_xyicon[12] = gl_wschar << 3;
	d->g_xyicon[13] = d->g_xyicon[11];
	d->g_xyicon[14] = gl_wschar << 3;
	d->g_xyicon[16] = d->g_xyicon[0];
	memset(d->g_xytext, 0, 5 * sizeof(d->g_xytext[0])); /* BUG */
	d->g_xytext[2] = gl_wchar * 12;
	d->g_xytext[4] = d->g_xytext[2];
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
		return FALSE;

	gl_restype = res;
	gl_rschange = TRUE;
	return TRUE;
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
VOID save_inf(P(BOOLEAN) todisk)
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
	char *buf;
	int16_t size;
	OBJECT *obj;
	char infname[16];

	UNUSED(obj);
	UNUSED(buf);
	UNUSED(buf1);
	UNUSED(j);

	d = thedesk;
	pcurr = d->afile + SAVE_ATARI;
	memset(pcurr, 0, SIZE_AFILE - SAVE_ATARI);
	
	if (d->autofile[0])
	{
		*pcurr++ = '#';
		*pcurr++ = 'Z';
		*pcurr++ = ' ';
		pcurr = save_sstr(pcurr, d->autofile);
		*pcurr++ = 0x0d;
		*pcurr++ = 0x0a;
	}

	/* save evironment */
	*pcurr++ = '#';
	*pcurr++ = 'E';
	*pcurr++ = ' ';
	envr = 0x0;
	envr |= d->covwr_save;
	envr |= d->vitem_save ? 0x80 : 0x00;
	envr |= (d->sitem_save << 5) & 0x60;
	envr |= d->cdele_save ? 0x10 : 0x00;
	envr |= d->ccopy_save ? 0x08 : 0x00;
	pcurr = save_2(pcurr, envr);

	envr = 0x0;							/* set resolution prefence  */
	envr |= d->pref_save;
	envr |= (d->cbit_save << 4);			/* High order bit       */
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
	
		win = &d->win_save[i];
		pcurr = save_2(pcurr, win->hsl_save);	/* horizontal slide bar  */
		pcurr = save_2(pcurr, win->vsl_save);
		pcurr = save_2(pcurr, win->x_save / gl_wchar);
		pcurr = save_2(pcurr, win->y_save / gl_hchar);
		pcurr = save_2(pcurr, win->w_save / gl_wchar);
		pcurr = save_2(pcurr, win->h_save / gl_hchar);
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
			break;
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
		infname[0] = isdrive() & 4 ? 'C' : 'A';
		infname[1] = ':';
		infname[2] = '\\';
		strcpy(&infname[3], infdata);
		handle = dos_create(infname, 0x0);

		if (handle <= 0)
		{
			dos_error();
		} else
		{
			size = dos_write(handle, d->size_afile, d->afile);
			dos_close(handle);
			/* check for full disk */
			if (size < d->size_afile)
			{
				fun_alert(1, STDISKFULL, NULL);
				dos_delete(infname);
			}
			up_allwin(infname, FALSE);	/* rebuild any window on the INF drive */
		}
	}

#if 0
	if (todisk)
		up_allwin(infname, FALSE);		/* rebuild any window on the INF drive */

	desk_wait(FALSE);
#endif
}


/*
 * return TRUE if HARD DISK
 * Doesn't NEED to return anything -- 881109 kbad
 */
/* 306de: 00e1e556 */
/* 104de: 00fd598e */
VOID set_defdrv(NOTHING)
{
	/* This fugly statement gets drvbits, masks drive C,
	 *  and does a GEMDOS Setdrive to drive A (0) if C doesn't exist,
	 *  or to C (2) if it does exist.  Don't ask.  It had to be shrunk.
	 */
	dos_sdrv((isdrive() & 0x04) >> 1);
}
