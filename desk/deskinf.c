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





/* 104de: 00fd4cb0 */
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
LINEF_STATIC char *escani_str(P(const char *)pcurr, P(char **)ppstr)
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
		app->a_type = TRASHCAN;
		app->a_apptype = DISK;
		break;
	case 'M':							/* disk drive   */
		app->a_type = DRIVE;
		app->a_apptype = DISK;
		break;
	case 'C':							/* cartridge    */
		app->a_type = CARTICON;
		app->a_apptype = DISK;
		break;
	case 'G':
		app->a_type = PROGRAM;
		app->a_apptype = PRG;
		break;
	case 'F':
		app->a_type = PROGRAM;
		app->a_apptype = TOS;
		break;
	case 'P':
		app->a_type = PROGRAM;
		app->a_apptype = TTP;
		break;
	case 'D':
		app->a_type = FOLDER;
		break;
	}

	pcurr += 2;
	if (app->a_apptype & 4)
	{
		pcurr = scan_2(pcurr, &app->a_x);
		pcurr = scan_2(pcurr, &app->a_y);
	}

	pcurr = scan_2(pcurr, &app->a_icon);			/* get the icon id  */
	pcurr = scan_2(pcurr, &app->a_flags);
	
	app->a_char = *pcurr == ' ' ? 0 : *pcurr;
	pcurr += 2;
	
	pcurr = escani_str(pcurr, &app->a_path);
	pcurr = escani_str(pcurr, &app->a_name);
	
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

	w = d->r_dicon.g_w;
	x = newx / w;
	xm = newx % w;
	if (xm > (w / 2))
		*px = (x + 1) * w;
	else
		*px = x * w;
	*px = min(*px, gl_width - w);
	if (*px > (gl_width / 2))
		*px += gl_width % w;
	
	newy -= d->full.g_y;
	h = d->r_dicon.g_h;
	y = newy / h;
	ym = newy % h;
	
	if (ym > (h / 2))
		*py = (y + 1) * h;
	else
		*py = y * h;
	*py = min(*py, d->full.g_h - h);
	if (*py > (d->full.g_h / 2))
		*py += d->full.g_h % h;
	*py += d->full.g_y;
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
	register DESKWIN *pws;
	register char *pcurr;
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
	
	d = thedesk;
	
	d->appnode = d->appbuf;
	ptr = d->appbuf;
	
	/* set up linked array */
	for (i = NUM_ANODE - 1; i >= 0; i--)
	{
		d->app[i].a_next = &d->app[i + 1];
		d->app[i].a_path = ptr;
		ptr += PATH_LEN;
		d->app[i].a_name = ptr;
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
			pws = &d->winpd[i++];
			/* horizontal slide bar */
			pcurr = scan_2(pcurr, &pws->w_coli);
			/* vertical slide bar */
			pcurr = scan_2(pcurr, &pws->w_rowi);

			/* window's x position */
			pcurr = scan_2(pcurr, &pws->w_sizes.g_x);
			if (pws->w_sizes.g_x >= gl_ncols)
				pws->w_sizes.g_x /= 2;

			pws->w_sizes.g_x *= gl_wchar;

			/* window's y position */
			pcurr = scan_2(pcurr, &pws->w_sizes.g_y);

			pws->w_sizes.g_y *= gl_hchar;

			/* window's width */
			pcurr = scan_2(pcurr, &pws->w_sizes.g_w);
			if (pws->w_sizes.g_w > gl_ncols)
				pws->w_sizes.g_w /= 2;
			pws->w_sizes.g_w *= gl_wchar;
			if (pws->w_sizes.g_w < (7 * gl_wbox))
				pws->w_sizes.g_w = 7 * gl_wbox;

			/* window's height  */
			pcurr = scan_2(pcurr, &pws->w_sizes.g_h);
			pws->w_sizes.g_h *= gl_hchar;
			if (pws->w_sizes.g_h < (7 * gl_hbox))
				pws->w_sizes.g_h = 7 * gl_hbox;

			pcurr = scan_2(pcurr, &pws->w_icon);

			ptr = pws->w_path;
			while (*pcurr != '@')
			{
				*ptr++ = *pcurr++;
			}
			*ptr = 0;				/* take out the @ */

			break;

		case 'E':					/* environment string   */
			pcurr += 2;

			pcurr = scan_2(pcurr, &envr);
			d->s_view = (envr & 0x80) != 0;
			d->s_sort = (envr & 0x60) >> 5;
			d->cdele_save = (envr & 0x10) != 0;
			d->ccopy_save = (envr & 0x08) != 0;
			d->write_save = envr & 0x01;
			pcurr = scan_2(pcurr, &envr);
			d->cbit_save = (envr & 0xf0) >> 4;
			d->pref_save = gl_restype - 1;
			break;
		}
	}
eof:;
	temp = (NUM_IB + 1) * sizeof(ICONBLK); /* BUG: there are only 5 icons */
	rsrc_gaddr(R_ICONBLK, 0, &icons);
	LBCOPY(d->iconaddr, icons, temp);
	LBCOPY(d->icona2, icons, temp);
	d->iconaddr[0].ib_xchar = 5;
	d->iconaddr[0].ib_ychar = 14;
	d->icona2[0].ib_xchar = 5;
	d->icona2[0].ib_ychar = 14;
	d->dicon.g_w = (d->iconaddr[0].ib_xtext << 1) + d->iconaddr[0].ib_wtext;
	d->dicon.g_h = d->iconaddr[0].ib_hicon + d->iconaddr[0].ib_htext + 2;
	d->r_dicon.g_w = gl_height <= 300 ? 0 : 8;
	d->r_dicon.g_w += d->dicon.g_w;
	w = gl_width / d->r_dicon.g_w;
	d->r_dicon.g_w += (gl_width % d->r_dicon.g_w) / w;
	d->r_dicon.g_h = d->dicon.g_h + 2;
	h = (gl_height - gl_hbox) / d->r_dicon.g_h;
	d->r_dicon.g_h += ((gl_height - gl_hbox) % d->r_dicon.g_h) / h;

	for (app = d->applist; app; app = app->a_next)
	{
		app_mtoi(app->a_x * d->r_dicon.g_w, app->a_y * d->r_dicon.g_h + d->full.g_y, &app->a_x, &app->a_y);
	}

	d->o13744 = 9;
	d->o13746 = 5;
	memset(d->o13748, 0, sizeof(d->o13748));
	d->o13748[0] = gl_wschar << 2;
	d->o13748[2] = d->o13748[0];
	d->o13748[3] = d->dicon.g_h - gl_wschar - 2;
	d->o13748[5] = d->o13748[3];
	d->o13748[7] = d->dicon.g_h;
	d->o13748[8] = d->dicon.g_w;
	d->o13766[0] = d->dicon.g_h;
	d->o13766[1] = d->dicon.g_w;
	d->o13766[2] = d->dicon.g_h - gl_wschar - 2;
	d->o13766[3] = gl_wschar << 3;
	d->o13766[4] = d->o13766[2];
	d->o13766[5] = gl_wschar << 3;
	d->o13766[7] = d->o13748[0];
	memset(d->o13784, 0, sizeof(d->o13784));
	d->o13784[2] = gl_wchar * 12;
	d->o13784[4] = d->o13784[2];
	d->o13794 = gl_hchar;
	d->o13798 = gl_hchar;
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
	register DESKWIN *win;
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
	envr |= d->write_save;
	envr |= d->s_view ? 0x80 : 0x00;
	envr |= (d->s_sort << 5) & 0x60;
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
	for (i = 0; i < MAXWIN; i++)
	{
		*pcurr++ = '#';
		*pcurr++ = 'W';
		*pcurr++ = ' ';
	
		win = &d->winpd[i];
		pcurr = save_2(pcurr, win->w_coli);	/* horizontal slide bar  */
		pcurr = save_2(pcurr, win->w_rowi);
		pcurr = save_2(pcurr, win->w_sizes.g_x / gl_wchar);
		pcurr = save_2(pcurr, win->w_sizes.g_y / gl_hchar);
		pcurr = save_2(pcurr, win->w_sizes.g_w / gl_wchar);
		pcurr = save_2(pcurr, win->w_sizes.g_h / gl_hchar);
		pcurr = save_2(pcurr, win->w_icon);
	
		ptmp = win->w_path;
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
		case TRASHCAN:
			*pcurr++ = 'T';
			break;
		case DRIVE:
			*pcurr++ = 'M';
			break;
		case CARTICON:
			*pcurr++ = 'C';
			break;
		case PROGRAM:
			if ((app->a_apptype & 0x01) && (app->a_apptype & 0x02))
				*pcurr++ = 'G';
			else
				*pcurr++ = app->a_apptype & 0x08 ? 'P' : 'F';
			break;
		case FOLDER:
			*pcurr++ = 'D';
			break;
		}

		*pcurr++ = ' ';

		if (app->a_apptype & 4)
		{
			pcurr = save_2(pcurr, app->a_x / d->r_dicon.g_w);
			pcurr = save_2(pcurr, (app->a_y - d->full.g_y) / d->r_dicon.g_h);
		}
		pcurr = save_2(pcurr, app->a_icon);
		pcurr = save_2(pcurr, app->a_flags);
		*pcurr++ = app->a_char == 0 ? ' ' : app->a_char;
		*pcurr++ = ' ';
		pcurr = save_sstr(pcurr, app->a_path);
		pcurr = save_sstr(pcurr, app->a_name);
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
				fill_string(1, STDISKFULL, NULL);
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
