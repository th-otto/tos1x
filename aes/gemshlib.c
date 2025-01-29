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
#include "../desk/deskstr.h"
#include "../desk/desksupp.h"


/* if TRUE then do an an exec on the current command else exit and return to DOS  */
int16_t sh_doexec;
int16_t sh_dodef;

/* used to signal if the curren tly running appl is a GEM app */
int16_t sh_isgem;

/* same as above for previously running DOS app.     */
int16_t sh_gem;

char *ad_envrn;

char *ad_shcmd;

char *ad_shtail;

/* cart program */
char *ad_path;

char *ad_pfile;

char temp[50]; /* WTF, unused */

STATIC int16_t sh_9fc0; /* ZZZ */
STATIC BOOLEAN xa0ba;

LINEF_STATIC VOID sh_show PROTO((const char *lcmd));
BOOLEAN sh_path PROTO((int16_t whichone, char *dp, char *pname));

#undef Getrez
#define Getrez() trp14(4)

LINEF_STATIC VOID sh_fixtail PROTO((NOTHING));
LINEF_STATIC BOOLEAN sh_rom PROTO((NOTHING));



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

	if (isover)
	{
		sh_doexec = doex;
		sh_9fc0 = FALSE;
		sh_dodef = FALSE;
		sh_isgem = !isgem ? FALSE : TRUE;	/* isgem may not = 1    */
	} else
	{
		sh_fixtail();
		if (sh_find(ad_shcmd, NULL))
		{
			sh_draw(ad_shcmd, ROOT, 1);
			dos_exec(ad_shcmd, 0, ad_shtail);
		} else
		{
			return FALSE;
		}
	}

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
VOID sh_draw(P(const char *) lcmd, P(int16_t) start, P(int16_t) depth)
PP(const char *lcmd;)
PP(int16_t start;)
PP(int16_t depth;)
{
	LPTREE tree;

	if (sh_gem && !sh_dodef)
	{
		tree = ad_stdesk;
		gsx_sclip(&gl_rscreen);
		LLSET(ad_pfile, lcmd);
		ob_draw(tree, start, depth);
	}
}


/*
 * Routine called everytime dos_find has another path to search
 */
/* 306de: 00e20d0c */
/* 104de: 00fe40fc */
/* 106de: 00e264da */
VOID sh_show(P(const char *) lcmd)
PP(const char *lcmd;)
{
	int16_t i;

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
char *sh_name(P(char *) ppath)
PP(register char *ppath;)
{
	register char *pname;

#if (TOSVERSION >= 0x106) | TP_73
	pname = ppath;
	while (*pname++)
		;
	do
	{
		--pname;
	} while (pname >= ppath && *pname != '\\' && *pname != ':');
#else
	pname = &ppath[(int)strlen(ppath)];

	while (pname >= ppath && *pname != '\\' && *pname != ':')
		--pname;
#endif

	return ++pname;
}


extern uint8_t gl_dta[]; /* WTF: this is from desktop */

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
VOID sh_envrn(P(char **) ppath, P(const char *) psrch)
PP(intptr_t ppath;)						/* output pointer   */
PP(register intptr_t psrch;)
{
	char *lp;
	char *ad_loc1;
	int16_t len;
	int16_t findend;
	char tmp;
	char loc1[16];
	char loc2[16];

	len = LSTCPY(ADDR(&loc2[0]), psrch);
	len--;

	ad_loc1 = ADDR(&loc1[0]);
	UNUSED(ad_loc1);
	loc1[len] = '\0';

	/* WTF? */
	LBCOPY(gl_dta, ad_envrn, 50);
	gl_dta[5] = ';';
	lp = (char *)gl_dta;
	findend = FALSE;
	do
	{
		tmp = LBGET(lp);
		lp++;
		if (findend && tmp == '\0')
		{
			findend = FALSE;
			tmp = 0xFF;
		} else
		{
			if (tmp == loc2[0])
			{
				LBCOPY(ADDR(&loc1[0]), lp, len);
				if (streq(&loc1[0], &loc2[1]))
				{
					lp += len;
					break;
				}
			} else
			{
				findend = TRUE;
			}
		}
	} while (tmp);
	if (!tmp)
		lp = NULL;

	LLSET(ppath, lp);
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
PP(char *dp;)
PP(register char *pname;)
{
	register char tmp;
	register char last;
	char *lp;
	register int16_t i;

	/* find PATH= in the    */
	/*   command tail which */
	/*   is a double null-  */
	/*   terminated string  */
	sh_envrn(ADDR(&lp), ADDR(rs_str(STPATH)));
	if (!lp)
		return FALSE;

	/* if found count in to */
	/*   appropriate path   */
	i = whichone;
	tmp = ';';
	while (i)
	{
		while ((tmp = LBGET(lp)) != 0)
		{
			lp++;
			if (tmp == ';')
				break;
		}
		i--;
	}
	if (!tmp)
		return FALSE;
	/* copy over path   */
#if !BINEXACT
	last = 0; /* BUG: not initialized */
#endif
	while ((tmp = LBGET(lp)) != 0)
	{
		if (tmp != ';')
		{
			LBSET(dp++, tmp);
			last = tmp;
			lp++;
		} else
			break;
	}
	/* see if extra slash is needed */
	if (last != '\\' && last != ':')
		LBSET(dp++, '\\');
	/* append file name */
	LSTCPY(dp, ADDR(pname));
	/* make whichone refer to next path */
	return whichone + 1;
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
PP(intptr_t pspec;) /* should be char * */
PP(SHFIND_PROC routine;)
{
	int16_t path;
	BOOLEAN gotdir;
	char *pname;
	char tmpname[14];

	/* BUG: does not save old dta -> will change the DTA of running program */
	dos_sdta(&D.g_loc1[0]);				/* use this     */

	LSTCPY(ad_path, (char *) pspec);
	pname = sh_name(D.g_dir);				/* get the file name    */
	strcpy(tmpname, pname);  /* copy to local buffer */

	path = 0;
	gotdir = TRUE;
	do
	{
		dos_sfirst(ad_path, F_RDONLY | F_SYSTEM);
		if (DOS_ERR && (DOS_AX == E_FILENOTFND || DOS_AX == E_NOFILES || DOS_AX == E_PATHNOTFND))
		{
			if (gotdir)
			{
				gl_dta[0] = '\\';
				gl_dta[1] = '\0';
				strcat((char *)gl_dta, ad_path);
				LSTCPY(ad_path, (char *)gl_dta);
				gotdir = FALSE;
				path = 1;
			} else
			{
				path = sh_path(path, ad_path, tmpname);
				DOS_ERR = TRUE;
			}
		} else
		{
			path = 0;
		}
	} while (DOS_ERR && path);		/* then in env paths        */

	if (!DOS_ERR)
	{
		LSTCPY(pspec, ad_path);
		if (routine)
			(*routine)(ad_path);
	}
	
	return !DOS_ERR;
}


LINEF_STATIC VOID sh_fixtail(NOTHING)
{
	register THEGLO *DGLO;
	register int len;
	
	DGLO = &D;
	len = DGLO->s_tail[0];
	while (len > 0)
	{
		DGLO->s_tail[len] = toupper(DGLO->s_tail[len]);
		len--;
	}
}


/*
 * AES's Shell
 */
/* 306de: 00e20fb4 */
/* 104de: 00fe4344 */
/* 106de: 00e26782 */
VOID sh_main(NOTHING)
{
	BOOLEAN retry;
	BOOLEAN badtry;
	int16_t ret;
	int16_t doserr;
	register LPTREE tree;
	register THEGLO *DGLO;

	UNUSED(retry);
	DGLO = &D;
	tree = ad_stdesk;					/* sh draw box              */
	ad_pfile = (char *)LLGET(OB_SPEC(TITLE));
	sh_gem = sh_isgem = TRUE;
	sh_doexec = sh_9fc0 = TRUE;
	sh_dodef = TRUE;
	doserr = 0;

	do
	{
		xa0ba = FALSE;
		if (sh_9fc0)
		{
			xa0ba = sh_isgem = TRUE;
		}
		sh_9fc0 = TRUE;
		
		if (sh_isgem != sh_gem)			/* users request different  */
		{								/* modes    ?       */
			sh_gem = sh_isgem;
			if (sh_gem)					/* currently running GEM    */
				sh_tographic();
			else
				sh_toalpha();
		}

		if (sh_gem)						/* if GEM app then restart */
		{								/* window and mouse stuff  */
			wm_start();
			ratinit();
		}
#if CARTRIDGE
		if (DGLO->s_tail[0] == 0xff)
		{
			DGLO->s_tail[0] = strlen(&DGLO->s_tail[1]);
			sh_draw(ad_shcmd, ROOT, 1);
			cart_exec(ad_shcmd, ad_shtail);	/* only filename!  */
			DGLO->s_tail[0] = '\0';
			sh_dodef = TRUE;
		}
#endif
		sh_fixtail();

		if (sh_dodef)					/* goto to desktop  */
		{
			desk_alloc();
			ret = deskmain();
			desk_free();
			if (Getrez() != 2)
				LLSET(ad_stdesk + 12, 0x00001173L);
			
			if (ret)
				sh_dodef = FALSE;
			else
				sh_doexec = FALSE;
		} else
		{
			/* run application  */
			if (sh_rom())
			{
				sh_dodef = TRUE;
			} else
			{
				/*	As of 10/21/88, sh_main no longer uses sh_find to find the	*/
				/*	program to launch.  Instead the full pathname is written to the	*/
				/*	global command string by desksupp:do_aopen().  Also, we do	*/
				/*	not change directory to the dir. of the app being launched.	*/
	
				sh_draw(ad_shcmd, ROOT, 1);
				sh_dodef = TRUE;
				do
				{
					if (doserr)
					{
						ret = fm_error(doserr);
						doserr = 0;
					} else
					{
						badtry = FALSE;
						if (sh_find(ad_shcmd, sh_show))
						{
							p_nameit(rlr, sh_name(DGLO->s_cmd));
							dos_exec(ad_shcmd, 0, ad_shtail);
							if (sh_gem && DOS_ERR && DOS_AX < -32)
								doserr = ~DOS_AX - 30;
						} else
						{
							doserr = E_FILENOTFND;
						}
					}
				} while (badtry || doserr);
			}
		}
	} while (sh_doexec);
}


BOOLEAN sh_rom(NOTHING)
{
	BOOLEAN ret;
	register char *tail;
	
	ret = TRUE;
	tail = &D.s_tail[1];
	switch (D.s_tail[0] & 0xff)
	{
	case CMD_TYPE:
		sh_type(tail);
		break;
	case CMD_PRINT:
		strcpy(ad_shcmd, S_PRINT);
		strcat(ad_shcmd, tail);
		sh_draw(ad_shcmd, ROOT, 1);
		sh_print(tail);
		break;
	case CMD_FORMAT:
		sh_draw(ad_shcmd, ROOT, 1);
		sh_format(tail, ad_shcmd);
		break;
	case CMD_COPY:
		sh_draw(ad_shcmd, ROOT, 1);
		sh_copy(tail, ad_shcmd);
		break;
	default:
		ret = FALSE;
		/* break; */
	}
	return ret;
}
