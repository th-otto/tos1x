/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: kbad $	$Date: 89/07/28 13:04:59 $
 * =======================================================================
 *
 * Revision 2.4  89/07/28  13:04:59  kbad
 * Added accs_init(), but there are still some strange interactions with
 * the critical error handler, so it is bracketed by #ifdef ACC_DELAY.
 * Also changed the desktop backdrop pattern to solid in color modes here,
 * before gemshlib:sh_main() so that the autoboot application gets the
 * right pattern drawn.  It still gets set in sh_main as well.
 * 
 * Revision 2.3  89/07/27  03:21:49  kbad
 * gsx_malloc: min gl_mlen for TT = 0xc800L
 * 
 * Revision 2.2  89/04/26  18:24:25  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:27:35  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.15  89/01/24  07:18:57  kbad
 * Change to directory of autoboot app
 * 
 * Revision 1.14  88/10/24  12:27:53  mui
 * Save 1/4 of the screen memory - added gsx_malloc
 * 
 * Revision 1.12  88/10/17  13:36:55  kbad
 * Yanked fs_start to fix fs_input growing clip rect problem
 * 
 * Revision 1.11  88/09/22  04:49:42  kbad
 * Moved rsrc_gaddr of desktop to before wm_start
 * 
 * Revision 1.10  88/09/08  18:57:55  kbad
 * added <flavor.h> for DOWARNING flag
 * 
 * Revision 1.9  88/08/08  18:56:56  mui
 * zero out the dispatcher list before bringing up system alert
 * 
 * Revision 1.8  88/08/08  12:32:38  mui
 * don't wait for accessories to finish, they only get one chance to run
 * 
 * Revision 1.7  88/08/05  16:38:52  mui
 * add escape button
 * 
 * Revision 1.6  88/08/04  19:29:19  mui
 * at autoboot, wait until all the acc finish their work before we go
 * into the auto boot sequence
 * 
 * Revision 1.4  88/08/02  13:03:15  kbad
 * changed dowarning box to match build date of 1.04d 8/1/88
 * 
 * Revision 1.3  88/07/28  17:29:06  mui
 * Nothing
 * 
 * Revision 1.2  88/07/15  16:08:31  mui
 * add warning message
 * 
 * Revision 1.1  88/06/02  12:34:14  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*      GEMINIT.C       4/23/84 - 02/08/85      Lee Lorenzen            */
/*      to 68k          2/23/75 - 05/03/85      Lowell Webster          */
/*      Ram based                 05/15/85      Derek Mui               */
/*      Fix the main              07/11/85      Derek Mui               */
/*      08/28/85  Fix when no disk attached             Derek Mui       */
/*      10/23/85  Fix at pred_inf to read inf file from root  D.Mui     */
/*      05/22/85  Initialize in dispatch semaphore      M Schmal        */
/*      Fix at pred_dinf for bit on     2/12/87         Derek Mui       */
/*      Change at main to get mouse add 11/30/87        D.Mui           */
/*      Update          12/10/87                        D.Mui           */
/*      Change at ini_dlong     12/17/87                D.Mui           */
/*      Added ad_out1, ad_out2  1/7/88                  D.Mui           */
/*      Added er_num, no_aes    1/8/88                  D.Mui           */
/*      Move drawstk from deskglob to here at main 1/15/88      D.Mui   */
/*      Add ad_fsel             1/21/88                 D.Mui           */
/*      Take out ad_out1 and ad_out2    1/27/88         D.Mui           */
/*      Change pred_dinf                1/28/88         D.Mui           */
/*      Take out ad_envrn               1/28/88         D.Mui           */
/*      Add autoexec                    2/11/88         D.Mui           */
/*      Add g_autoboot  2/11/88                         D.Mui           */
/*      Change the resolution masking   2/23/88         D.Mui           */
/*      Check to turn bit on when autoboot      3/10/88 D.Mui           */
/*      In line coded of ini_dlongs     3/24/88         D.Mui           */
/*      Fix at pred_dinf for scan_2     5/2/88          D.Mui           */
/*      Change at pref_dinf for gl_restype 4/25/89      D.Mui           */
/*      Change at gsx_malloc for new size  7/26/89      D.Mui           */
/*      Turn on the cache in pred_dinf          6/25/90 D.Mui           */
/*      Make sure the scan_2 for cache checking doesn't reset temp      */
/*      Look for newdesk.inf then desktop.inf in pred_dinf 6/26/90      */
/*      Change RES4 to RES5 for solid pattern   6/27/90 D.Mui           */
/*      Changed wm_start to wm_init             900628 kbad             */
/*      Moved all_run to gemcli.c               07/16/90        D.Mui   */
/*      Fix at gsx_malloc to save 1/2 of the screen     7/19/90 D.Mui   */
/*      Added initialization of crt_error semaphore     900731  D.Mui   */
/*      Removed #include flavor.h: DOWARNING now here 900801 kbad       */
/*      Also removed TT conditional.  If it's longframe, it's TT        */
/*      Fixed the background pattern in TT high 11/14/90        D.Mui   */
/*      Init the current mouse form             5/8/91          D.Mui   */
/*      Check control key for nodisk system at main 8/13/91     D.Mui   */
/*      Exit graphic mode before closing work station 12/20/91          */
/*      Change at gsx_malloc for saving 25 columns of screen 7/7/92 Mui */
/*      Add 3D stuff                            7/7/92          D.Mui   */
/*      Add code to do sparrow res change       7/17/92         D.Mui   */
/*      Add new variables                       8/1/92          D.Mui   */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright
 *      -------------------------------------------------------------
 *      GEM Application Environment Services              Version 1.0
 *      Serial No.  XXXX-0000-654321              All Rights Reserved
 *      Copyright (C) 1985                      Digital Research Inc.
 *      -------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gsxdefs.h"
#include "gemrsc.h"


#define CACHE_ON	0x00003919L
#define CACHE_OFF	0x00000808L
#define LONGFRAME	*(int16_t *)(0x59eL)


STATIC EVB evx;						/* used only to get elinkoff offset */
intptr_t ad_sysglo;
VOIDPTR ad_armice;
VOIDPTR ad_hgmice;
LPTREE ad_stdesk;
char *ad_fsel;
intptr_t drawstk;
int16_t er_num;						/* for output.s */
int16_t no_aes;						/* gembind.s    */
BOOLEAN sh_up;						/* is the sh_start being ran yet ? */ /* unused */
BOOLEAN autoexec;					/* autoexec a file ?    */
STATIC char g_autoboot[CMDLEN];
STATIC int16_t g_flag;


#define Getrez() trp14(4)
#define Blitmode(on) trp14(64, on)
#define VcheckMode(mode) trp14(95, mode)

#define Cconws(x) trap(9, x)

STATIC char aautopath[CMDLEN];

#if DOWARNING
BOOLEAN dowarn;
#endif

#define Kbshift(a) bios(11, a)

#ifdef ACC_DELAY

VOID accs_init PROTO((NOTHING));

/* The AES startup code should wait for all accessories to finish initializing
 * before it starts the first main process running.  To determine that all
 * accessories have initialized, we will wait until every accessory is blocked
 * waiting for a message event.
 *
 * A process with a message block can be identified by walking the PD's EVB
 * list, and finding an EVB that is not an EVDELAY and is not pointed to
 * by anything in the PD's CDA.  This EVB is a message EVB by process of
 * elimination.
 *
 * Thus, we can loop until all accessories have a blocked waiting for a
 * message event with the following code:
 */
VOID accs_init(NOTHING)
{
	PD *pd;
	register EVB *e, *ce;
	register CDA *c;
	BOOLEAN notdone;
	register int16_t pid;

	sh_tographic();
	do
	{
		/* initialize to DONE, change if we find one with no message block */
		notdone = FALSE;
		/* let everybody run */
		all_run();

		/* look at all accessory EVB lists (ctlmgr==0, screenmgr==1) */
		pid = 2;
		pd = fpdnm(NULL, pid);
		while (pd)
		{
			c = pd->p_cda;
			/* walk through EVB list looking for CDA matches */
			for (ce = -1L, e = pd->p_evlist; ce && e; e = e->e_nextp)
			{
				/* timer wait? */
				if (e->e_flag & EVDELAY)
					continue;
				/* input block? */
				for (ce = c->c_iiowait; ce && ce != e; ce = ce->e_link) ;
				if (ce == e)
					continue;
				/* mouse rect? */
				for (ce = c->c_msleep; ce && ce != e; ce = ce->e_link) ;
				if (ce == e)
					continue;
				/* button wait? */
				for (ce = c->c_bsleep; ce && ce != e; ce = ce->e_link) ;
				/* if ce is null here, we found a message EVB */
			}
			if (ce)
			{
				/* found one w/ no message blocks, or w/ NO event blocks */
				/* fall out and let 'em run */
				notdone = TRUE;
				pd = NULL;
			} else
			{
				/* this guy had a message block, try the next pd */
				pd = fpdnm(NULL, ++pid);
			}
		}

	} while (notdone);
}
#endif	/* ACC_DELAY */


/*
 * Give everyone a chance to run, at least once
 */
/* 104de: 00fd3ce6 */
VOID all_run(NOTHING)
{
	int16_t i;

	for (i = 0; i < NUM_ACCS; i++)
		dsptch();
	/* then get in the wait line */
	wm_update(BEG_UPDATE);
	wm_update(END_UPDATE);
}


/* 306de: 00e1dca8 */
/* 104de: 00fd3d0a */
/* 106de: 00e13f48 */
/* 404: 00e24a90 */
VOID gem_main(NOTHING)
{
	register int16_t i;
	VOIDPTR tmpadbi;
	LPTREE tree;
	register THEGLO *DGLO;
	PD *lslr;
	register char *apath;
	DGLO = &D;

	UNUSED(lslr);
	
	er_num = ALRT04CRT;					/* output.s */ /* but not used there... */
	no_aes = ALRTNOFUNC;				/* for gembind.s */ /* but not used there... */
	
	/****************************************/
	/*      ini_dlongs();                   */
	/****************************************/

	ad_shcmd = &DGLO->s_cmd[0];
	ad_shtail = &DGLO->s_tail[0];
	ad_path = &DGLO->g_dir[0];

	/* init. long pointer to global array   */
	/* which is used by resource calls  */

	ad_sysglo = (intptr_t)&DGLO->g_sysglo[0];
	ad_windspb = &wind_spb;

	/****************************************/

	/*
	 * no check for allocation failure here...
	 * why not allocate that static? its never changed
	 */
	drawstk = (intptr_t)dos_alloc(0x00000400L);	/* draw stack is 1K */
	drawstk += 0x00000400L;			/* init to top */

	/* no ticks during init */
	hcli();

	/* take the 0efh int. ...erm trap #2  */
	takecpm();

	/* init event recorder  */
	gl_recd = FALSE;
	gl_rlen = 0;
	gl_rbuf = 0;

	/* initialize pointers to heads of event list and thread list       */
	elinkoff = (intptr_t)(char *) &evx.e_link - (intptr_t)(char *) &evx; /* offsetof(EVB, e_link) */

	/* link up all the evb's to the event unused list */
	eul = 0;
	for (i = 0; i < NUM_EVBS; i++)
	{
		DGLO->g_evb[i].e_nextp = eul;
		eul = &DGLO->g_evb[i];
	}
	/* initialize list and unused lists   */

	drl = 0;
	nrl = 0;
	zlr = 0;
	dlr = 0;
	fpcnt = 0;
	fpt = 0;
	fph = 0;
	infork = 0;

	/* initialize sync blocks */
	wind_spb.sy_tas = 0;
	wind_spb.sy_owner = 0;
	wind_spb.sy_wait = 0;

	gl_btrue = 0x0;
	gl_bdesired = 0x0;
	gl_bdelay = 0x0;
	gl_bclick = 0x0;

	/* init initial process */
	for (i = 0; i < NUM_PDS; i++)
		pinit(&DGLO->g_pd[i], &DGLO->g_cda[i]);

	DGLO->g_pd[0].p_uda = &DGLO->g_uda;
	DGLO->g_pd[1].p_uda = (UDA *)&DGLO->g_2uda;
	DGLO->g_pd[2].p_uda = (UDA *)&DGLO->g_3uda;
	
	/* if not rlr then initialize his stack pointer */
	DGLO->g_2uda.u_spsuper = &DGLO->g_2uda.u_supstk;
	DGLO->g_3uda.u_spsuper = &DGLO->g_3uda.u_supstk;

	curpid = 0;

	rlr = &DGLO->g_pd[curpid];
	rlr->p_pid = curpid++;
	rlr->p_link = 0;
	rlr->p_stat = 0;
	cda = rlr->p_cda;

	/* restart the tick */
	hsti();

	/* 
	 * screen manager process init.
	 * This process starts out owning the mouse
	 * and the keyboard. it has a pid == 1
	 */
	gl_mowner = gl_kowner = ctl_pd = ictlmgr(rlr->p_pid);

	rsc_read();							/* read in resource */

	ldaccs();							/* load in accessories  */

	pred_dinf();						/* pre read the inf */

	/* get the resolution and the auto boot name         */

	/* load gem resource and fix it up before we go   */

	/* load all desk acc's  */

	/* init button stuff    */
	set_defdrv();						/* set default drive    */

	/* do gsx open work station */
	gsx_init();

	rom_ram(0, ad_sysglo);

	rs_gaddr(ad_sysglo, R_BIPDATA, MICE0, &ad_armice);
	ad_armice = (VOIDPTR)LLGET((intptr_t)ad_armice);
	rs_gaddr(ad_sysglo, R_BIPDATA, MICE2, &ad_hgmice);
	ad_hgmice = (VOIDPTR)LLGET((intptr_t)ad_hgmice);

	/* fix up icons */
	for (i = 0; i < 3; i++)
	{
#if !BINEXACT
		BITBLK bi;
#endif
		rs_gaddr(ad_sysglo, R_BITBLK, i, &tmpadbi);
		LBCOPY(ADDR(&bi), tmpadbi, sizeof(BITBLK));
		gsx_trans(bi.bi_pdata, bi.bi_wb, bi.bi_pdata, bi.bi_wb, bi.bi_hl);
	}
	
	/* take the critical err handler int. */
	cli();
	takeerr();
	sti();

	sh_tographic();						/* go into graphic mode */
	sh_gem = TRUE;

	/* take the tick int. */
	cli();
	gl_ticktime = gsx_tick(tikaddr, &tiksav);
	sti();

	/* set init. click rate */
	ev_dclick(3, TRUE);

	/* get st_desk ptr */
	rs_gaddr(ad_sysglo, R_TREE, SCREEN, (VOIDPTR *)&ad_stdesk);
	tree = ad_stdesk;

	wm_start();

	/* startup gem libs */
	/* fs_start(); */

	for (i = 0; i < 3; i++)
		LWSET(OB_WIDTH(i), (gl_wchar * gl_ncols));

	LWSET(OB_HEIGHT(0), (gl_hchar * gl_nrows));
	LWSET(OB_HEIGHT(1), (gl_hchar + 2));
	LWSET(OB_HEIGHT(2), (gl_hchar + 3));

	rs_gaddr(ad_sysglo, R_STRING, FSTRING, (VOIDPTR *)&ad_fsel);

	indisp = FALSE;						/* init in dispatch semaphore to not indisp        */

#if DOWARNING
	if (!dowarn)
	{
		lslr = drl;						/* save the dispatcher list     */
		drl = NULL;						/* Don't allow anybody to run   */
		fm_alert(0, "[1][\
 \016\017 Developer Release \016\017 |\
    08/08/88  TOS 1.4 |\
 |\
 WARNING: This OS release |\
         is NOT supported. ]\
[Launch TOS]");
		dowarn = TRUE;

		drl = lslr;						/* restore it       */
	}
#endif

	/* off we go !!! */
	dsptch();

#ifdef ACC_DELAY
	accs_init();
#else
	/* let them run */
	all_run();
#endif


	if (g_autoboot[0])					/* if there is a auto boot program */
	{
#ifndef ACC_DELAY
		for (i = 0; i < 6; i++)			/* let the acc's have a chance  */
			all_run();
#endif
		/* change to dir of autoboot */
		apath = &aautopath[0];
		strcpy(apath, g_autoboot);
		*(sh_name(apath)) = 0;			/* change path\filename to path */
		do_cdir(apath[0] - 'A', apath);

		sh_write(1, g_flag - 0, 0, g_autoboot, "");
	}

	sh_main();

	rsc_free();							/* free up resource */

	drawstk -= 0x00000400L;				/* reset to bottom  */
	dos_free((VOIDPTR)drawstk);

	gsx_mfree();

	cli();
	giveerr();
	sti();

	/* free up the acc's */
	free_accs();
	
	/* free up special glue */
	
	/* give back the tick */
	cli();
	gl_ticktime = gsx_tick(tiksav, &tiksav);
	sti();

#if BINEXACT
	/* close workstation */
	gsx_wsclose();
	/* BUG: vdi function called after v_clswk */
	gsx_escapes(2);						/* exit alpha mode */
#else
	gsx_escapes(2);						/* exit alpha mode */

	/* close workstation */
	gsx_wsclose();
#endif

	/* return GEM's 0xEF int */
	cli();
	givecpm();
	sti();
}


/*
 * process init
 */
/* 306de: 00e1e226 */
/* 104de: 00fd413a */
VOID pinit(P(PD *) ppd, P(CDA *) pcda)
PP(register PD *ppd;)
PP(CDA *pcda;)
{
	ppd->p_cda = pcda;
	ppd->p_qaddr = ppd->p_queue;
	ppd->p_qindex = 0;
	bfill(8, ' ', ppd->p_name);
}


/*
 *	pre read the desktop.inf file and get the resolution set
 *	accordingly. If there are no disks or a desktop.inf does
 *	not exist or the resolutions match then return FALSE.
 *
 * ++ERS 1/14/93: also read the preferred desktop backgrounds
 */
/* 306de: 00e1e27e */
/* 206de: 00e1a818 */
/* 104de: 00fd4168 */
int16_t pred_dinf(NOTHING)
{
	int16_t res;
	register int16_t bsize, fh, change, cont;
	char *pbuf;
	register char *temp;
	int16_t defdrv;
	char *chrptr;

	UNUSED(chrptr);
	
	g_autoboot[0] = 0;
	pbuf = dos_alloc((int32_t) SIZE_AFILE);
	change = FALSE;
	/*
	 * unneeded call; buffer will be overwritten
	 * by builtin version below
	 */
	sh_get(pbuf, SIZE_AFILE);

#if BINEXACT
	/* BUG: extra parameter here */
	rom_ram(3, (intptr_t)pbuf, 0);			/* res is default from ROM  */
#else
	rom_ram(3, (intptr_t)pbuf);				/* res is default from ROM  */
#endif

	if (isdrive() && diskin)			/* there is a disk  */
	{
		defdrv = dos_gdrv();			/* save default drive   */
		dos_chdir("\\");				/* open newdesk.inf */
		{								/* try desktop.inf  */
			fh = dos_open(infdata, RMODE_RD);
			if (DOS_ERR)				/* no file      */
			{
				if (isdrive() & 0x04)	/* try the hard disk    */
				{
					do_cdir(2, "\\");
					fh = dos_open(infdata, RMODE_RD);
				} else
				{
					DOS_ERR = TRUE;
				}
			}
		}

		if (!DOS_ERR)					/* if no error then */
		{								/* read inf file    */
			bsize = dos_read(fh, SIZE_AFILE, pbuf);
			dos_close(fh);
			change = TRUE;
			dos_sdrv(defdrv);			/* set it back to default   */
		}
	}
	/* if we read it from disk, reschange may have changed. */
	if (change)
	{
		temp = pbuf;
		temp[bsize] = '\0';
		cont = TRUE;
		while (*temp && cont)
		{
			if (*temp != '#')
			{
				temp++;
			} else
			{
				temp++;					/* get the auto boot file   */
				if ((*temp == 'Z') && (autoexec))
				{
					temp += 2;			/* get the flag     */
					temp = scan_2(temp, &g_flag);
					temp = escan_str(temp, &g_autoboot[0]);
				} else if (*temp == 'E')
				{
					temp += 5;
					scan_2(temp, &res);
					{					/* turn on the bit ?        */
#if BINEXACT /* sigh... */
						trp14(((res & 0xF0) >> 4) ? 0x00400001L : 0x00400000L);
#else
						Blitmode(((res & 0xF0) >> 4) ? 1 : 0);
#endif
					}

					{
						if (gl_rschange)	/* if we've been here before    */
						{
							save_2(temp, (res & 0xF0) | (gl_restype - 1));
						} else
						{
							res &= 0xF;
							res += 1;
							gl_rschange = FALSE;
							if (!app_reschange(res))
								change = FALSE;	/* NO no res change     */
						}
					}

				}
			}
		}
	}
	
	/* put in common area for special desk accessories */
	autoexec = FALSE;
	sh_put(pbuf, SIZE_AFILE);
	dos_free(pbuf);
	return change;
}


/*
 * Save 25 columns and full height of the screen memory
 */
/* 306de: 00e1e4e6 */
/* 104de: 00fd430c */
BOOLEAN gsx_malloc(NOTHING)
{
#if BINEXACT /* sigh... */
	gsx_fix(&gl_tmp, NULL, 0L);
#else
	gsx_fix(&gl_tmp, NULL, 0, 0);
#endif
	/*
	 * This buggy multiplication actually works, because it is compiled into a muls,
	 * then the long result is stored without further sign-extension.
	 * It thus make use of one the many bugs in the Alcyon compiler,
	 * and has been fixed above for TOS 4.x
	 */
	gl_mlen = (int32_t)((gl_ws.ws_yres + 1) * (gl_ws.ws_xres + 1));
	gl_mlen = (gl_nplanes * gl_mlen) / 32;
	if (gl_mlen < 13312)
		gl_mlen = 13312;

	gl_tmp.fd_addr = dos_alloc(gl_mlen);
#if !BINEXACT
	/* BUG: no return here, which will return the value of gl_tmp.fd_addr casted to int... */
	return TRUE;
#endif
}


#if AESVERSION >= 0x320
/* 306de: 00e1e572 */
VOID gsx_xmfset(P(MFORM *) pmfnew)
PP(MFORM *pmfnew;)
{
	gsx_moff();
	LWCOPY(ad_intin, pmfnew, sizeof(MFORM) / 2);
	gsx_ncode(ST_CUR_FORM, 0, sizeof(MFORM) / 2);
	gsx_mon();
}
#endif


#if AESVERSION >= 0x200
/* 306de: 00e1e5ae */
VOID gsx_mfset(P(MFORM *) pmfnew)
PP(MFORM *pmfnew;)
{
	gsx_moff();
#if AESVERSION >= 0x320
	gl_omform = gl_cmform;
#endif
	LWCOPY(ad_intin, pmfnew, sizeof(MFORM) / 2);
	gsx_ncode(ST_CUR_FORM, 0, sizeof(MFORM) / 2);
#if AESVERSION >= 0x320
	gl_cmform = *pmfnew;
#endif
	gsx_mon();
}
#endif


#if AESVERSION >= 0x200
/*
 * AES #78 - graf_mouse - Change the appearance of the mouse pointer.
 *
 * Graf mouse
 */
/* 306de: 00e1e610 */
VOID gr_mouse(P(int16_t) mkind, P(MFORM *) grmaddr)
PP(register int16_t mkind;)
PP(MFORM *grmaddr;)
{
	VOIDPTR maddr;
	MFORM omform;

	if (mkind > USER_DEF)
	{
		switch (mkind)
		{
		case M_OFF:
			gsx_moff();
			break;

		case M_ON:
			gsx_mon();
			break;

#if AESVERSION >= 0x320
		case M_SAVE:						/* save mouse form  */
			rlr->p_mouse = gl_cmform;
			break;

		case M_RESTORE:						/* restore saved mouse form */
			omform = rlr->p_mouse;
			gsx_mfset(&omform);
			break;

		case M_PREV:						/* restore previous mouse form  */
			omform = gl_omform;
			gsx_mfset(&omform);
			break;
#endif
		}
	} else
	{
		if (mkind != USER_DEF)			/* set new mouse form   */
		{
			/* BUG: gsx_mfset will crash if this fails because number is out of range... */
			rs_gaddr(ad_sysglo, R_BIPDATA, MICE0 + mkind, &maddr);
			grmaddr = (MFORM *)LLGET((intptr_t)maddr);
		}

		gsx_mfset(grmaddr);
	}
}
#endif
