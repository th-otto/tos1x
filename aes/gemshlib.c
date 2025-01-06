/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: kbad $	$Date: 89/06/15 15:29:51 $
 * =======================================================================
 *
 * Revision 2.4  89/06/15  15:29:51  kbad
 * fix sh_name so that it doesn't overshoot the string it's looking at.
 * 
 * Revision 2.3  89/04/26  18:26:59  mui
 * TT
 * 
 * Revision 2.2  89/04/01  03:07:32  kbad
 * changed sh_find to look first in the directory from which the
 * current application was launched, then cwd, then down search paths.
 * 
 * Revision 2.1  89/02/22  05:29:31  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.9  89/02/16  10:46:45  mui
 * Fix dclicks: initialize gl_bpend to 0 sh_main for dclick
 * 
 * Revision 1.8  88/12/05  17:00:54  kbad
 * Change to cart_exec only filename (rather than full pathname from
 * shel_write... since cart_exec checks for the right file, and only
 * the filenames are stored in the cart).
 * 
 * Revision 1.7  88/10/21  16:28:46  kbad
 * Major change to sh_main.  No longer change directory to prg being launched.
 * 
 * Revision 1.6  88/10/03  12:03:01  kbad
 * opt sh_draw, sh_name, sh_path
 * 
 * Revision 1.5  88/09/08  17:57:40  kbad
 * restore old sh_path, make shel_envrn use the env, while keeping
 * compatible with old path
 * 
 * Revision 1.3  88/07/01  16:22:05  mui
 * Reg opt
 * 
 * Revision 1.1  88/06/02  12:35:11  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMSHLIB.C	4/18/84 - 01/07/85	Lee Lorenzen		*/
/*	68k		2/18/85 - 05/28/85	Lowell Webster		*/
/*	remove sh_parse	06/10/85		Mike Schmal		*/
/*	International 	07/19/85		Derek Mui		*/
/*	french		08/08/85		Mike Schmal		*/
/*	Fix at sh_main	08/09/85		Derek Mui		*/
/*	Fix at sh_main	08/13/85		Derek Mui		*/
/*	Increase buffer size to 16 at sh_envrn	Derek Mui		*/
/*	Fix at sh_find	08/22/85		Derek Mui		*/
/*	Fix at sh_write 09/26/85		Derek Mui		*/
/*	Update Germany	09/27/85		Derek Mui		*/
/*	Trying 1.2	10/22/85		Derek Mui		*/
/*	Fix at sh_find to look for file at root dir 10/25/85	D.Mui	*/
/*	Check error after dos_exec only for PRG file 10/29/85	D.Mui	*/
/*	Change to solid background for low medium res 11/08/85  D.Mui	*/
/*	Kludge at sh_envrn	11/12/85	Nobody			*/
/*	Update solid background	at sh_main	2/3/86	Derek Mui	*/
/*	change mouse form before showing the mouse sh_tographic		*/
/*						2/7/86	Derek Mui	*/
/*	Set the button semaphore when leaving desktop	2/27/86 D.Mui	*/
/*	Fix at the sh_main to fix the cart exect problem 3/18/86 D.Mui  */
/*	Added sh_rom for reading rom only once 	3/19/86			*/
/*	Fix the shel_write problem 		4/01/86	Derek Mui	*/
/*	Take out sh_fixtail so it won't upper case the tail 4/2/86 D.Mui*/
/*	Fix at sh_main for no solid background in high res  4/7/86 D.Mui*/
/*	Fix the sh_rom, read the rom cart once	7/1/86	Derek Mui	*/
/*	Added sh_iscart for cart program 	7/1/86	Derek Mui	*/
/*	Fix at cart entry point			7/2/86	Derek Mui	*/
/*	Take out sh_rom				7/2/86	Derek Mui	*/
/*	Italian			07/30/86	John Feagans		*/
/*	Spanish -updated source file for spain  12/25/86 M Schmal	*/
/*	Removed string to deskinf.c		02/03/87 Derek Mui	*/
/*	Add more defines CMD_ ... 	11/23/87	D.Mui		*/
/*	Modify rsc constants		11/25/87	D.Mui		*/
/*	Update			12/10/87 - 12/17/87	D.Mui		*/
/*	Auto boot application	12/22/87 - 12/23/87	D.Mui		*/
/*	Change shstr1 to ad_shstr1	1/7/88		D.Mui		*/
/*	Take out init_dsktop and clean_dsktop	1/8/88	D.Mui		*/
/*	Rewrite sh_main	1/12/88 - 1/14/88		D.Mui		*/
/*	Take out ad_shstr1		1/21/88		D.Mui		*/
/*	Change at sh_start	1/26/88 - 1/27/88	D.Mui		*/
/*	Take out sh_special	1/27/88			D.Mui		*/
/*	Rewrite sh_find, sh_envrn, sh_path				*/
/*	1/28/88 - 1/29/88				D.Mui		*/
/*	Added sh_spath	2/2/88				D.Mui		*/
/*	Change sh_main	2/10/88				D.Mui		*/
/*	Do window clean up	3/10/88			D.Mui		*/
/*	Change at sh_path	4/14/88			D.Mui		*/
/*	Change the set path befor dos_exec 4/29/88	D.Mui		*/
/*	Change at sh_main 	5/2/88 - 5/4/88		D.Mui		*/
/*	Clean up the process name when it is finished	06/16/88	*/
/*	Change RES4 to RES5		6/27/90		D.Mui		*/
/*	Set mouse owner after existing application 7/13/90  D.Mui	*/
/*	Fixed the background pattern at TT high	11/14/90	D.Mui	*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gsxdefs.h"
#include "dos.h"
#include "gemrsc.h"


/* if TRUE then do an an exec on the current command else exit and return to DOS  */
int16_t sh_doexec;

/* used to signal if the curren tly running appl is a GEM app */
int16_t sh_isgem;

/* same as above for previously running DOS app.     */
int16_t sh_gem;

char *ad_envrn;

char *ad_shcmd;

char *ad_shtail;

/* cart program */
BOOLEAN sh_iscart;

char *ad_path;

char *ad_pfile; /* unused */

char temp[50]; /* WTF, unused */


VOID sh_show PROTO((char *lcmd));
BOOLEAN sh_path PROTO((int16_t whichone, char *dp, char *pname));
int16_t sh_search PROTO((SHFIND_PROC routine));

#define Getrez() trp14(4)




/*
 * AES #120 - shel_read - Read command line parameters of the application.
 *
 * Application reads in the command that invokes it
 */
/* 306de: 00e20b62 */
/* 104de: 00fe3fc6 */
/* 106de: 00e26330 */
int16_t sh_read(P(char *) pcmd, P(char *) ptail)
PP(char *pcmd;)
PP(char *ptail;)
{
	LBCOPY(pcmd, ad_shcmd, CMDLEN);
	LBCOPY(ptail, ad_shtail, CMDLEN);
	return TRUE;
}


/*
 * AES #121 - shel_write - Launch another application
 *
 * Routine to set the next application to run
 *
 *   doexec = 0 exits and return to desktop
 *   doexec = 1 runs another application
 *
 *   isgem = 0   then run in character mode
 *   isgem = 1   them run in graphic mode
 *
 *           isover is useless
 *   isover = 0  then run above DESKTOP
 *   isover = 1  then run over DESKTOP
 *   isover = 2  then run over AES and DESKTOP
 */
/* 306de: 00e20b98 */
/* 104de: 00fe3ff2 */
/* 106de: 00e26366 */
int16_t sh_write(P(int16_t) doex, P(int16_t) isgem, P(int16_t) isover, P(const char *) pcmd, P(const char *) ptail)
PP(int16_t doex;)
PP(int16_t isgem;)
PP(int16_t isover;)
PP(const char *pcmd;)
PP(const char *ptail;)
{
#if AESVERSION >= 0x330
	if (doex > 1)
		return FALSE;
#endif

	LBCOPY(ad_shcmd, pcmd, CMDLEN);
	LBCOPY(ad_shtail, ptail, CMDLEN);

	sh_doexec = doex;
	sh_isgem = (isgem) ? TRUE : FALSE;	/* isgem may not = 1    */

	return TRUE;						/* for the future   */
}


/*
 * AES #122 - shel_get - Read from the GEM environment buffer. 
 *
 *	Used by the DESKTOP to recall 1024 bytes worth of previously
 *	'put' desktop-context information.
 */
/* 206de: 00e1d182 */
/* 306de: 00e20be8 */
/* 104de: 00fe4038 */
/* 106de: 00e263b6 */
int16_t sh_get(P(char *) pbuffer, P(uint16_t) len)
PP(char *pbuffer;)
PP(uint16_t len;)
{
	LBCOPY(pbuffer, D.s_save, len);
	return TRUE;
}


/*
 * AES #123 - shel_put - Writes to the GEM environment buffer.
 *
 *	Used by the DESKTOP to save away 1024 bytes worth of desktop-
 *	context information.
 */
/* 206de: 00e1d1a2 */
/* 306de: 00e20c08 */
/* 104de: 00fe4052 */
/* 106de: 00e263d6 */
int16_t sh_put(P(const char *) pdata, P(int16_t) len)
PP(char *pdata;)
PP(int16_t len;)
{
	LBCOPY(D.s_save, pdata, len);
	return TRUE;
}


/*
 *	Convert the screen to graphics-mode in preparation for the 
 *	running of a GEM-based graphic application.
 */
/* 306de: 00e20c28 */
/* 104de: 00fe406c */
/* 106de: 00e263f6 */
BOOLEAN sh_tographic(NOTHING)
{
	cli();
	retake();							/* retake the gem trap  */
	sti();								/* and error trap   */

	gsx_graphic(TRUE);					/* convert to graphic   */
	gsx_sclip(&gl_rscreen);				/* set initial clip rect */
	gsx_malloc();						/* allocate screen space BUG: not checked */
	ratinit();							/* start up the mouse   */
	gsx_mfset(ad_hgmice);				/* put mouse to hourglass */

	return TRUE;
}


/*
 *	Convert the screen and system back to alpha-mode in preparation
 *	for the running of a DOS-based character application.
 */
/* 306de: 00e20c72 */
/* 104de: 00fe4094 */
/* 106de: 00e26440 */
BOOLEAN sh_toalpha(NOTHING)
{
	gsx_mfset(ad_armice);				/* put mouse to arrow   */

	cli();
	giveerr();							/* give up gem and  */
	sti();								/* error trap       */

	ratexit();							/* turn off the mouse   */
	gsx_mfree();						/* free the blt buffer  */
	gsx_graphic(FALSE);					/* close workstation    */

	return TRUE;
}


/*
 *	Routine called everytime dos_find has another path to search
 */
/* 306de: 00e20cae */
/* 104de: 00fe40b2 */
/* 106de: 00e2647c */
VOID sh_draw(P(char *) lcmd, P(int16_t) start, P(int16_t) depth)
PP(char *lcmd;)
PP(int16_t start;)
PP(int16_t depth;)
{
	register LPTREE tree;

	if (sh_gem)
	{
		tree = ad_stdesk;
		gsx_sclip(&gl_rscreen);
		LLSET(LLGET(OB_SPEC(TITLE)), lcmd);
		ob_draw(tree, start, depth);
	}
}


/*
 * Routine called everytime dos_find has another path to search
 */
/* 306de: 00e20d0c */
/* 104de: 00fe40fc */
/* 106de: 00e264da */
VOID sh_show(P(char *) lcmd)
PP(char *lcmd;)
{
	register int16_t i;

	for (i = 1; i < 3; i++)
		sh_draw(lcmd, i, 0);
}


/*
 *	Routine to take a full path, and scan back from the end to 
 *	find the starting byte of the particular filename
 */
/* 306de: 00e20d36 */
/* 104de: 00fe411e */
/* 106de: 00e26504 */
/* 162de: 00e265f0 */
#if ((OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_CZ)) & (TOSVERSION < 0x162) & BINEXACT
	/* swedish/czech versions have the TOSFIX patch applied (from tos14fix.prg) */
	asm("xdef _sh_name");
	asm("_sh_name:");
	asm("   movea.l    4(a7),a1");
	asm("	movea.l    a1,a2");
	asm("sh_name1:");
	asm("	tst.b      (a1)+");
	asm("	bne.s      sh_name1");
	asm("sh_name2:");
	asm("	move.b     -(a1),d0");
	asm("	cmpa.l     a2,a1");
	asm("	bcs.s      sh_name3");
	asm("	cmp.b      #0x5C,d0");
	asm("	beq.s      sh_name3");
	asm("	cmp.b      #':',d0");
	asm("	bne.s      sh_name2");
	asm("sh_name3:");
	asm("	addq.l     #1,a1");
	asm("	move.l     a1,d0");
	asm("	rts");
	asm("	nop");
	asm("	nop");
	asm("	nop");
	asm("	nop");
	asm("	nop");
#if TOSVERSION >= 0x106
	/*
	 * original routine in 1.06 is 6 bytes longer than 1.04,
	 * because 1.04 uses linef opcodes
	 */
	asm("	nop");
	asm("	nop");
	asm("	nop");
#endif
#else
char *sh_name(P(char *) ppath)
PP(char *ppath;)
{
	register char *pname;

	pname = ppath;
	while (*pname++)
		;

#if (TOSVERSION >= 0x106) | TP_73
	do
	{
		--pname;
	} while (pname >= ppath && *pname != '\\' && *pname != ':');
#else
	while (pname >= ppath && *pname != '\\' && *pname != ':')
		--pname;
#endif

	return ++pname;
}
#endif


/*
 * AES #125 - shel_envrn - Obtains value of environmental variables
 *
 *	Search for a particular string in the DOS environment and return
 *	a long pointer to the character after the string if it is found. 
 *	*psrch includes the '=' character.
 *	Otherwise, return a NULL in ppath.
 */
/* 306de: 00e20d68 */
/* 104de: 00fe414a */
/* 106de: 00e26536 */
int16_t sh_envrn(P(char **) ppath, P(const char *) psrch)
PP(register char **ppath;)						/* output pointer   */
PP(const char *psrch;)
{
	register char *chrptr;
	register const char *byteptr;

	chrptr = ad_envrn;
	/* double nulls to end  */
	while ((*chrptr) || (*(chrptr + 1)))
	{
		byteptr = psrch;				/* set the start    */
		/* compare      */
		while ((*byteptr) && (*byteptr++ == *chrptr++))
			;
		if (!(*byteptr))				/* end of search string */
		{
			*ppath = chrptr;
#ifdef __ALCYON__
			return; /* BUG: should return TRUE */
#else
			return TRUE;
#endif
		} else
		{
			while (*chrptr++)			/* skip to the end of   */
				;						/* this key     */
		}
	}

	*ppath = NULL;						/* failed, return null  */
#ifdef __ALCYON__
	return; /* BUG: should return FALSE */
#else
	return FALSE;
#endif
}


/*
 *	Search first, search next style routine to pick up each path
 *	in the PATH= portion of the DOS environment.  It returns the
 *	next higher number to look for until there are no more
 *	paths to find.
 *
 *	gemjstrt.s sets the path to PATH=0C:\000 if drive C exists,
 *	otherwise it's the default  PATH=0A:\000
 *	(unless munged by HINSTALL or an auto folder program)
 */
/* 306de: 00e20dac */
/* 104de: 00fe4186 */
/* 106de: 00e2657a */
BOOLEAN sh_path(P(int16_t) whichone, P(char *) dp, P(char *) pname)
PP(int16_t whichone;)
PP(register char *dp;)
PP(register char *pname;)
{
	register char last;
	register char *lp;
	register int16_t i;
	char *ltemp;
	int16_t oldpath = FALSE;

	/* find PATH= in the environment which is a double null-terminated string */
	sh_envrn(&ltemp, "PATH=");

	if (!ltemp)
		return FALSE;

	lp = ltemp;

	/* This kludge, er, section of code maintains compatibility with
	 *	the old style PATH=\0<path>\0, to support folks who run an auto-
	 *	folder environment-setter, and use the old-style PATH environment.
	 * (880825 kbad)
	 */
	if (!*lp)							/* look for old type env */
	{									/* by looking for key   */
		while (*(++lp))					/* after PATH=\0    */
		{
			if (*lp == '=')				/* key found =: path is */
				return FALSE;			/* really null, so punt */
		}
		oldpath = TRUE;					/* it really is a path  */
		lp = ltemp;						/* so munge the null    */
		*lp = ';';
	}
	/* end compatibility code ----------------				*/

	/* if found count in to appropriate path   */

	last = *lp;
	for (i = whichone; i > 0; i--)
		while ((last = *lp++) && (last != ';') && (last != ','))
			;							/* added commas (8808 kbad) */

	if (!last)
	{
		/* restore the null */
		if (oldpath)
			*ltemp = '\0';		/* (for compatibility)  */
		return FALSE;
	}

	/* copy over path   */
	while ((*lp) && (*lp != ';') && (*lp != ','))
	{									/* added commas (8808 kbad) */
		last = *lp++;
		*dp++ = last;
	}
	/* NOTE: this next test means that null pathnames in the PATH env. var
	 * 	will be treated as ROOT rather than CURRENT directory.  Current
	 *	diretory in the path must be denoted by an explicit '.' e.g.:
	 *	PATH=.;A:\000 (880825 kbad)
	 */
	/* see if extra slash is needed */
	if ((last != '\\') && (last != ':'))
		*dp++ = '\\';
	/* append file name */
	LSTCPY(dp, pname);

	/* restore the null */
	if (oldpath)
		*ltemp = '\0';			/* (for compatibility)  */

	/* make whichone refer to next path */
	return whichone + 1;
}


/* 306de: 00e20e86 */
/* 104de: 00fe4254 */
/* 106de: 00e26654 */
int16_t sh_search(P(SHFIND_PROC) routine)
PP(register SHFIND_PROC routine;)
{
	if (routine)
		(*routine) (ad_path);

	return dos_sfirst(ad_path, F_RDONLY | F_HIDDEN | F_SYSTEM);
}


/*
 * AES #124 - shel_find - Find a file. 
 *
 *	Routine to verify that a file is present.  It first looks in the
 *	current directory and then looks down the search path.  Before
 *	it looks at each point it firsts call the passed-in routine with
 *	the filespec that is looking for.
 */
/* 306de: 00e20eba */
/* 104de: 00fe427c */
/* 106de: 00e26688 */
int16_t sh_find(P(char *) pspec, P(SHFIND_PROC) routine)
PP(register intptr_t pspec;) /* should be char * */
PP(register SHFIND_PROC routine;)
{
	register int16_t path;
	register BOOLEAN found = FALSE;
	register char *pname;
	char tmpname[14];
	intptr_t savedta;

	savedta = trap(0x2F);				/* Fgetdta()        */
	dos_sdta(&D.g_loc1[0]);				/* use this     */

	pname = sh_name(pspec);				/* get the file name    */
	strcpy(tmpname, pname);			/* copy it      */

	pname = sh_name(ad_shcmd);			/* first look in program's dir  */
	path = (int16_t) ((intptr_t)pname - (intptr_t)ad_shcmd);
	pname = &tmpname[0];
	if (path)
	{									/* if a path exists */
		LBCOPY(ad_path, ad_shcmd, path);	/* copy the path    */
		LSTCPY((ad_path + path), pname);	/* add the name     */
		found = sh_search(routine);		/* look for it      */
	}
	if (!found)
	{									/* if not found there, look cwd */
		path = 0;
		strcpy(ad_path, pspec);
		do
		{
			found = sh_search(routine);
			if (!found)
				path = sh_path(path, ad_path, pname);
		} while (path && !found);		/* then in env paths        */
	}

	if (found)							/* if file found    */
		strcpy(pspec, ad_path);			/* return full filespec */

	dos_sdta((VOIDPTR)savedta);					/* restore DTA      */
	return found;
}


/*
 * AES's Shell
 */
/* 306de: 00e20fb4 */
/* 104de: 00fe4344 */
/* 106de: 00e26782 */
VOID sh_main(NOTHING)
{
	register int16_t ret;
	int16_t i, reschange;
	register int32_t tree;
	register THEGLO *DGLO;
	char *fname;
	register char *chrptr;
	char tempchr;
	PD *temprlr;

	UNUSED(tempchr);
	UNUSED(chrptr);
	
	DGLO = &D;
	tree = ad_stdesk;					/* sh draw box              */
	UNUSED(tree);
	reschange = FALSE;					/* no resolution change     */

	do
	{
		gl_bpend = 0;					/* reset the d click flag   */

		if (gl_rschange)				/* change the resolution */
			break;

		if (sh_gem != sh_isgem)			/* users request different  */
		{								/* modes    ?       */
			if (sh_gem)					/* currently running GEM    */
				sh_toalpha();
			else
				sh_tographic();
		}

		sh_gem = sh_isgem;

		if (sh_gem)						/* if GEM app then restart */
		{								/* window and mouse stuff  */
			wm_start();
			ratinit();
		}
#if CARTRIDGE
		if (sh_iscart)
		{
			DGLO->s_tail[0] = strlen(&DGLO->s_tail[1]);
			sh_draw(ad_shcmd, ROOT, 1);
			sh_doexec = FALSE;			/* always go back to desktop */
			sh_isgem = TRUE;
			cart_exec(sh_name(ad_shcmd), ad_shtail);	/* only filename!  */
			DGLO->s_tail[0] = '\0';
			sh_iscart = FALSE;
			continue;
		}
#endif

		if (!sh_doexec)					/* goto to desktop  */
		{
			ret = deskmain();
#if AESVERSION < 0x330
			i = Getrez();
#if AESVERSION < 0x200
			if (i != 2 && i != 4)
				LLSET(ad_stdesk + 12, 0x00001173L);
#else
			if (i != 2 && i != 6)
				LLSET(ad_stdesk + 12, 0x00001173L);
			else
				LLSET(ad_stdesk + 12, 0x00001143L);
#endif
#else
			/*
			 * ++ ERS 1/14/93: use gl_nplanes to determine resolution, and set
			 *	the desktop background and color from the values we read from
			 *	desktop.inf
			 */
			if (gl_nplanes == 1)
				i = 0;
			else if (gl_nplanes == 2)
				i = 1;
			else
				i = 2;
#if (AESVERSION >= 0x330) | !BINEXACT
			LLSET(ad_stdesk + 12, 0x00001100L | adeskp[i]);
#endif
#endif

			if (!ret)
			{
				reschange = TRUE;		/* resolution change    */
				sh_write(0, 1, 0, "", "");
				sh_toalpha();			/* release the screen   */
			}							/* because geminit will */
		} /* turn on graphic  */
		else
		{								/* run application  */
			/*	As of 10/21/88, sh_main no longer uses sh_find to find the	*/
			/*	program to launch.  Instead the full pathname is written to the	*/
			/*	global command string by desksupp:do_aopen().  Also, we do	*/
			/*	not change directory to the dir. of the app being launched.	*/

			fname = sh_name(ad_shcmd);
			sh_draw(fname, ROOT, 1);
			sh_doexec = FALSE;			/* go back to desktop   */
			sh_isgem = TRUE;			/* it is a gem      */

			p_nameit(rlr, fname);
			temprlr = rlr;				/* save the process addr  */

			dos_exec(ad_shcmd, 0, ad_shtail);
			/* clean the name   */
			p_nameit(temprlr, ".");
			/* mn_free( temprlr->p_pid ); */

			if (sh_gem)
			{
#if AESVERSION >= 0x140
				wm_new();
#endif
				if (DOS_ERR && (DOS_AX < -32))
					fm_error((~DOS_AX) - 30);
			}

#if AESVERSION >= 0x200
			gl_kowner = gl_cowner = gl_mowner = temprlr;
#endif
		}
	} while (!reschange);				/* resolution change    */
}
