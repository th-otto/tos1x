/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:22:40 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:22:40  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:26:06  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:33:39  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMFMALT.C		09/01/84 - 01/07/85	Lee Lorenzen	*/
/*	CHANGED			02/19/85 - 02/23/85	Derek Mui	*/
/*	Reg Opt			03/08/85		Derek Mui	*/
/*	1.1			03/21/85 - 05/11/85	Lowell Webster	*/
/*	Modify fm_build to handle 6 resolutions	2/6/86	Derek Mui	*/
/*	Change the mouse logic at fm_alert	3/5/86	Derek Mui	*/
/*	Fix at fm_strbrk	3/16/87	- 3/17/87	Derek Mui	*/
/*	Fix at fm_strbrk to allow 31 characters  4/8/87	Derek Mui	*/
/*	Fix at fm_alert		4/9/87			Derek Mui	*/
/*	Add more defines	11/23/87		D.Mui		*/
/*	New rsc update		12/9/87			D.Mui		*/
/*	Changed fm_build and fm_alert to build 3d buttons 7/16/92 D.Mui	*/

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
#include "gemrsc.h"

#define LORES	320

#define MAX_MSGS     5
#define MAX_BTNS     3
#define MSG_OFF      2
#define BUT_OFF      7
#define NUM_ALOBJS   10
#define NUM_ALSTRS   8
#define MAX_MSGLEN   30					/* changed  */
STATIC int INTER_WSPACE;
STATIC int INTER_HSPACE;
STATIC int ADD_WIDTH;
STATIC int ADD_HEIGHT;

static int16_t const gl_nils[3] = { -1, -1, -1 };



/*
 *	Routine to break a string into smaller strings.  Breaks occur
 *	whenever an | or a ] is encountered.
 */
/* 306de: 00e1c322 */
/* 104de: 00fe0020 */
/* 106de: 00e21be4 */
VOID fm_strbrk(P(LPTREE) tree, P(const char *) palstr, P(int16_t) stroff, P(int16_t *) pcurr_id, P(int16_t *) pnitem, P(int16_t *) pmaxlen)
PP(LPTREE tree;)
PP(intptr_t palstr;) /* should be const char * */
PP(int16_t stroff;)
PP(int16_t *pcurr_id;)
PP(int16_t *pnitem;)
PP(int16_t *pmaxlen;)
{
	register int16_t nitem, curr_id;
	register int16_t len, maxlen;
	register char tmp;
	int32_t pstr;
	int16_t nxttmp;

	nitem = maxlen = 0;
	curr_id = *pcurr_id;
	tmp = 0;

	while (tmp != ']')
	{
		pstr = LLGET(OB_SPEC(stroff + nitem));
		len = 0;

		do
		{
			tmp = LBGET(palstr + curr_id);

#if AESVERSION >= 0x140
			if (len >= 31)
			{
				LBSET(pstr + len, 0);
				tmp = 0;
				while (TRUE)
				{
					tmp = LBGET(palstr + curr_id);
					if (tmp != ']' && tmp != '|')
					{
						curr_id++;
						continue;
					} else
						break;
				}
			}
#endif

			curr_id++;
			nxttmp = LBGET(palstr + curr_id);

			if (tmp == ']' || tmp == '|')
			{
				if (tmp == nxttmp)
				{
#if AESVERSION >= 0x140
					if (len < 31)
						curr_id++;
					else
						tmp = 0;
#else
					curr_id++;
#endif
				} else
				{
					nxttmp = tmp;
					tmp = 0;
				}
			}

			LBSET(pstr + len, tmp);
			len++;
		} while (tmp != 0);

		tmp = nxttmp;
		maxlen = max(len - 1, maxlen);
		nitem++;
	}
	*pcurr_id = curr_id;
	*pnitem = nitem;
	*pmaxlen = maxlen;
}


/*
 *	Routine to parse a string into an icon #, multiple message
 *	strings, and multiple button strings.  For example,
 *
 *		[0][This is some text|for the screen.][Ok|Cancel]
 *		0123456
 *
 *	becomes:
 *		icon# = 0;
 *		1st msg line = This is some text
 *		2nd msg line = for the screen.
 *		1st button = Ok
 *		2nd button = Cancel
 */
/* 306de: 00e1c41a */
/* 104de: 00fe010c */
/* 104de: 00e21cdc */
VOID fm_parse(P(LPTREE) tree, P(const char *) palstr, P(int16_t *) picnum, P(int16_t *) pnummsg, P(int16_t *) plenmsg, P(int16_t *) pnumbut, P(int16_t *) plenbut)
PP(register LPTREE tree;)
PP(intptr_t palstr;) /* should be const char */
PP(int16_t *picnum;)
PP(int16_t *pnummsg;)
PP(int16_t *plenmsg;)
PP(int16_t *pnumbut;)
PP(int16_t *plenbut;)
{
	int16_t curr_id;

	*picnum = LBGET(palstr + 1) - '0';
	curr_id = 4;
	fm_strbrk(tree, palstr, MSG_OFF, &curr_id, pnummsg, plenmsg);
	curr_id++;
	fm_strbrk(tree, palstr, BUT_OFF, &curr_id, pnumbut, plenbut);
	*plenbut += 1;
}


/*
 *	Routine to build the alert
 *
 *	Inputs are:
 *		tree			the alert dialog
 *		haveicon		boolean, 1 if icon specified
 *		nummsg			number of message lines
 *		mlenmsg 		length of longest line
 *		numbut			number of buttons
 *		mlenbut 		length of biggest button
 */
/* 306de: 00e1c492 */
/* 104de: 00fe0178 */
/* 106de: 00e21d54 */
VOID fm_build(P(LPTREE) tree, P(int16_t) haveicon, P(int16_t) nummsg, P(int16_t) mlenmsg, P(int16_t) numbut, P(int16_t) mlenbut)
PP(register LPTREE tree;)
PP(int16_t haveicon;)
PP(int16_t nummsg;)
PP(int16_t mlenmsg;)
PP(int16_t numbut;)
PP(int16_t mlenbut;)
{
	register int16_t i;
	GRECT al, ic;
	GRECT bt, ms;

	r_set(&al, 0, 0, 1 + INTER_WSPACE, 1);			/* this is the alert box    */
	/* this is the message object   */
	r_set(&ms, 3, INTER_HSPACE, mlenmsg, 1);

	if (haveicon)
	{
		r_set(&ic, INTER_WSPACE, 1, 4, 4);
		al.g_w += ic.g_w + INTER_WSPACE;
		al.g_h = ic.g_h + 1;
		ms.g_x = ic.g_x + ic.g_w + INTER_WSPACE;
	}

	al.g_w += ms.g_w + ADD_WIDTH;
	al.g_h = max(al.g_h + INTER_HSPACE, nummsg + INTER_HSPACE);
	
	i = (al.g_w - (numbut * mlenbut) - ((numbut - 1) * 2)) / 2;

	/* set the button */
	r_set(&bt, i, al.g_h | ADD_HEIGHT, mlenbut, 1);

	/* now make the al.g_h smaller  */

	al.g_h += 1;
	al.g_h |= ADD_HEIGHT * 2 + INTER_HSPACE;

	ob_setxywh(tree, ROOT, &al);

	for (i = 0; i < NUM_ALOBJS; i++)
		LBCOPY((VOIDPTR)OB_NEXT(i), gl_nils, 6);

	/* add icon object  */
	if (haveicon)
	{
		ob_setxywh(tree, 1, &ic);
		ob_add(tree, ROOT, 1);
	}
	/* add msg objects  */
	for (i = 0; i < nummsg; i++)
	{
		ob_setxywh(tree, MSG_OFF + i, &ms);
		ms.g_y += 1;
		ob_add(tree, ROOT, MSG_OFF + i);
	}

	/* add button objects   */

	for (i = 0; i < numbut; i++)
	{
		LWSET(OB_FLAGS(BUT_OFF + i), SELECTABLE | EXIT);
		LWSET(OB_STATE(BUT_OFF + i), NORMAL);
		ob_setxywh(tree, BUT_OFF + i, &bt);
		bt.g_x += mlenbut + 2;
		ob_add(tree, ROOT, BUT_OFF + i);
	}
	al.g_w = max(bt.g_x, al.g_w); /* useless */
	/* set last object flag */
	LWSET(OB_FLAGS(BUT_OFF + numbut - 1), SELECTABLE | EXIT | LASTOB);
}


/*
 * AES #52 - form_alert - Display an alert box.
 */
/* 306de: 00e1c6c8 */
/* 104de: 00fe036a */
/* 106de: 00e21f8a */
int16_t fm_alert(P(int16_t) defbut, P(const char *) palstr)
PP(int16_t defbut;)
PP(const char *palstr;)
{
	register int16_t i;
	int16_t inm, nummsg, mlenmsg, numbut, mlenbut;
	LPTREE tree;
	VOIDPTR plong;
	GRECT d, t;
	int16_t tmpmon;
	
	/* init tree pointer */
	rs_gaddr(ad_sysglo, R_TREE, ALERT, (VOIDPTR *)&tree);

	gsx_mfset(ad_armice);
	if (gl_moff)
	{
		tmpmon = TRUE;
		gsx_mon();
	} else
	{
		tmpmon = FALSE;
	}
	
	ADD_HEIGHT = gl_hchar / 2;
	ADD_HEIGHT = ADD_HEIGHT << 8;
	if (gl_width != 320)
	{
		INTER_WSPACE = 2;
		ADD_WIDTH = 2;
		INTER_HSPACE = 1;
		LWSET(OB_STATE(ROOT), OUTLINED);
	} else
	{
		INTER_WSPACE = (gl_wchar / 2);
		INTER_WSPACE = INTER_WSPACE << 8;
		ADD_WIDTH = 0;
		INTER_HSPACE = 1 << 8;
		LWSET(OB_STATE(ROOT), NORMAL);
	}
	
	fm_parse(tree, palstr, &inm, &nummsg, &mlenmsg, &numbut, &mlenbut);
	fm_build(tree, (inm != 0), nummsg, mlenmsg, numbut, mlenbut);

	if (defbut)
	{
		plong = (VOIDPTR)OB_FLAGS(BUT_OFF + defbut - 1);
		LWSET(plong, LWGET(plong) | DEFAULT);
	}

	if (inm != 0)
	{
		rs_gaddr(ad_sysglo, R_BITBLK, inm - 1, &plong);
		LLSET(OB_SPEC(1), plong);
	}
	/* convert to pixels */
	for (i = 0; i < NUM_ALOBJS; i++)
		rs_obfix(tree, i);

	LWSET(OB_WIDTH(1), 32);
	LWSET(OB_HEIGHT(1), 32);

	/* center tree on screen */
	ob_center(tree, &d);
	
	/* save screen underneath the alert */
	wm_update(BEG_UPDATE);
	gsx_gclip(&t);
	bb_save(&d);

	/* draw the alert   */
	gsx_sclip(&d);
	ob_draw(tree, ROOT, MAX_DEPTH);
	/* let user pick button */
	i = fm_do(tree, 0) /* & 0x7FFF */;

	/* restore saved screen */
	gsx_sclip(&d);
	bb_restore(&d);
	gsx_sclip(&t);
	wm_update(END_UPDATE);

	if (tmpmon)
		gsx_moff();

	/* return selection */
	return i - BUT_OFF + 1;
}
