/*
 *************************************************************************
 *                      Revision Control System
 * =======================================================================
 *  $Author: mui $      $Date: 89/04/26 18:22:52 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:22:52  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:26:14  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.3  89/01/24  15:09:54  mui
 * Fix the find_obj, check current object before incrementing to next
 * 
 * Revision 1.2  89/01/24  05:15:44  kbad
 * optimize eralert
 * 
 * Revision 1.1  88/06/02  12:33:44  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*      GEMFMLIB.C      03/15/84 - 02/08/85     Gregg Morris            */
/*      to 68k          03/12/85 - 05/24/85     Lowell Webster          */
/*      Trying 1.2      10/11/85 - 10/21/85     Derek Mui               */
/*      Removed error 16        2/6/86          Derek Mui               */
/*      repaired get_par to new bind 01/03/87   Mike Schmal             */
/*      Modify rsc constants    11/25/87        D.Mui                   */
/*      Crunch out fm_inifld    03/25/88        D.Mui                   */
/*      Change at fm_do         04/10/88        D.Mui                   */


#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gemrsc.h"
#include "dos.h"

#define FORWARD 0
#define BACKWARD 1
#define DEFLT 2
#define BELL 0x07						/* bell         */

#undef LEFT
#undef RIGHT

#define BACKSPACE 0x0E08				/* backspace        */
#define SPACE 0x3920					/* ASCII <space>    */
#define UP 0x4800						/* up arrow     */
#define DOWN 0x5000						/* down arrow       */
#define LEFT 0x4B00						/* left arrow       */
#define RIGHT 0x4D00					/* right arrow      */
#define DELETE 0x5300					/* keypad delete    */
#define TAB 0x0F09						/* tab          */
#define BACKTAB 0x0F00					/* backtab      */
#define RETURN 0x1C0D					/* carriage return  */

#define ENTER 0x720D					/* enter key on keypad  */


static int16_t const ml_alrt[] = {
	ALRT00CRT,
	ALRT01CRT,
	ALRT02CRT,
	ALRT03CRT,
	ALRT04CRT,
	ALRT05CRT,
	ALRTDSWAP
};
static int16_t const ml_pwlv[] = { 0x0102, 0x0102, 0x0102, 0x0101, 0x0002, 0x0001, 0x0101 };

int16_t find_obj PROTO((LPTREE tree, int16_t start_obj, int16_t which));

LPTREE ml_mnhold;
GRECT ml_ctrl;
PD *ml_pmown;
PD *ml_pkown;




/*	0 = end mouse control	*/
/*	1 = mouse control	*/

/* 306de: 00e1b846 */
/* 106de: 00e1f9c2 */
VOID take_ownership(P(BOOLEAN) beg_ownit)
PP(BOOLEAN beg_ownit;)
{
	if (beg_ownit)
	{
		wm_update(BEG_UPDATE);
		if (ml_ocnt == 0)
		{
			ml_mnhold = gl_mntree;		/* save the current menu   */
			gl_mntree = 0;				/* no menu         */
			/* save the control rect */
			get_ctrl(&ml_ctrl);
			/* save the mouse owner    */
			get_mown(&ml_pmown, &ml_pkown);

			ct_chgown(rlr, &gl_rscreen);	/* change mouse ownership  */
		}								/* and the control rect    */
		ml_ocnt++;
	} else
	{
		ml_ocnt--;
		if (ml_ocnt == 0)
		{
			ct_chgown(ml_pkown, &ml_ctrl);	/* restore mouse owner     */ /* BUG: ml_pkown is keyboard owner, not mouse */
			gl_mntree = ml_mnhold;		/* restore menu tree       */
		}
		wm_update(END_UPDATE);
	}
}


/************************************************************************/
/* f i n d _ o b j                                                      */
/************************************************************************/
/* 306de: 00e1c8ac */
/* 104de: 00fe04fe */
/* 106de: 00e2216e */
int16_t find_obj(P(LPTREE) tree, P(int16_t) start_obj, P(int16_t) which)
PP(register LPTREE tree;)
PP(int16_t start_obj;)
PP(int16_t which;)
{
	register int16_t obj, flag, theflag, inc;
	int16_t last_obj;

	UNUSED(last_obj);
	
	obj = 0;
	flag = EDITABLE;
	inc = 1;

	switch (which)
	{
	case BACKWARD:
		inc = -1;
		/* fallthrough */

	case FORWARD:						/* check if it is LASTOB before inc */
		obj = start_obj + inc;
		break;

	case DEFLT:
		flag = DEFAULT;
		/* break; */
	}

	while (obj >= 0)
	{
		theflag = LWGET(OB_FLAGS(obj));

		if (theflag & flag)
			return obj;

		if (theflag & LASTOB)
			obj = -1;
		else
			obj += inc;
	}

	return start_obj;
}



LINEF_STATIC int16_t fm_inifld(P(LPTREE) tree, P(int16_t) start_fld)
PP(LPTREE tree;)
PP(int16_t start_fld;)
{
	/* position cursor on the starting field */
	if (start_fld == 0)
		start_fld = find_obj(tree, 0, FORWARD);
	return start_fld;
}



/*
 * AES #55 - form_keybd - Process keyboard input in a dialog box form.
 */
/* 306de: 00e1c93e */
/* 104de: 00fe0588 */
/* 106de: 00e22200 */
int16_t fm_keybd(P(LPTREE) tree, P(int16_t) obj, P(int16_t *) pchar, P(int16_t *) pnew_obj)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(int16_t *pchar;)
PP(int16_t *pnew_obj;)
{
	int16_t direction;

	/* handle character */
	direction = -1;

	switch (*pchar)
	{
	case RETURN:
	case ENTER:
		obj = 0;
		direction = DEFLT;
		break;
	case BACKTAB:
	case UP:
		direction = BACKWARD;
		break;
	case TAB:
	case DOWN:
		direction = FORWARD;
	}

	if (direction != -1)
	{
		*pchar = 0x0;
		*pnew_obj = find_obj(tree, obj, direction);
		if (direction == DEFLT && *pnew_obj != 0)
		{
			ob_change(tree, *pnew_obj, LWGET(OB_STATE(*pnew_obj)) | SELECTED, TRUE);
			return FALSE;
		}
	}

	return TRUE;
}


/*
 * AES #56 - form_button - Simulate the clicking on an object.
 */
/* 306de: 00e1c9ea */
/* 104de: 00fe0626 */
/* 106de: 00e222ac */
int16_t fm_button(P(LPTREE) tree, P(int16_t) new_obj, P(int16_t) clks, P(int16_t *) pnew_obj)
PP(register LPTREE tree;)
PP(register int16_t new_obj;)
PP(int16_t clks;)
PP(int16_t *pnew_obj;)
{
	register int16_t tobj;
	int16_t orword;
	int16_t parent, state, flags;
	int16_t cont, junk, tstate, tflags;
	int16_t lrets[6];

	cont = TRUE;
	orword = 0x0;

	state = ob_fs(tree, new_obj, &flags);
	/* handle touchexit case; if double click, then set high bit */
	if (flags & TOUCHEXIT)
	{
		if (clks == 2)
			orword = 0x8000;
		cont = FALSE;
	}

	/* handle selectable case */
	if ((flags & SELECTABLE) && !(state & DISABLED))
	{
		/* if its a radio button */
		if (flags & RBUTTON)
		{
			/* check siblings to find and turn off the old RBUTTON */
			parent = get_par(tree, new_obj, &junk);
			tobj = LWGET(OB_HEAD(parent));
			while (tobj != parent)
			{
				tstate = ob_fs(tree, tobj, &tflags);
				if ((tflags & RBUTTON) && ((tstate & SELECTED) || tobj == new_obj))
				{
					if (tobj == new_obj)
						state = tstate |= SELECTED;
					else
						tstate &= ~SELECTED;

					ob_change(tree, tobj, tstate, TRUE);
				}
				tobj = LWGET(OB_NEXT(tobj));
			}
		} else
		{
			/* turn on new object   */
			if (gr_watchbox((OBJECT *)tree, new_obj, state ^ SELECTED, state))
				state ^= SELECTED;
		}
		/* if not touchexit then wait for button up */
		if ((cont) && (flags & (SELECTABLE | EDITABLE)))
			ev_button(1, 0x0001, 0000, lrets);
	}
	/* see if this selection gets us out */
	if ((state & SELECTED) && (flags & EXIT))
		cont = FALSE;
	/* handle click on another editable field */
	if (cont && !(flags & EDITABLE))
		new_obj = 0;

	*pnew_obj = new_obj | orword;
	return cont;
}


/*
 * AES #50 - form_do - Process the dialog with input from the user.
 *
 *	ForM DO routine to allow the user to interactively fill out a 
 *	form.  The cursor is placed at the starting field.  This routine
 *	returns the object that caused the exit to occur
 */
/* 306de: 00e1cb68 */
/* 104de: 00fe0784 */
/* 106de: 00e2242a */
int16_t fm_do(P(LPTREE) tree, P(int16_t) start_fld)
PP(register LPTREE tree;)
PP(int16_t start_fld;)
{
	register int16_t edit_obj;
	int16_t next_obj;
	int16_t which;
	int16_t cont;
	int16_t idx;
	int16_t lrets[6];

	/* grab ownership of screen and mouse */
	take_ownership(TRUE);
	/* flush keyboard   */
	fq();
	/* set clip so we can draw chars, and invert buttons */
	gsx_sclip(&gl_rfull);
	/* determine which is the starting field to edit */


	/* position cursor on the starting field */
	next_obj = fm_inifld(tree, start_fld);

	edit_obj = 0;
	/* interact with user   */
	cont = TRUE;

	while (cont)
	{
		/* position cursor on the selected editting field */
		if (next_obj != 0 && edit_obj != next_obj)
		{
			edit_obj = next_obj;
			next_obj = 0;
			ob_edit(tree, edit_obj, 0, &idx, EDINIT);
		}
		/* wait for mouse or key */
		which = ev_multi(MU_KEYBD | MU_BUTTON, NULL, NULL, 0x0L, 0x0002ff01L, 0x0L, lrets);
		/* handle keyboard event */
		if (which & MU_KEYBD)
		{
			cont = fm_keybd(tree, edit_obj, &lrets[4], &next_obj);
			if (lrets[4])
				ob_edit(tree, edit_obj, lrets[4], &idx, EDCHAR);
		}
		/* handle button event  */
		if (which & MU_BUTTON)
		{
			next_obj = ob_find(tree, ROOT, MAX_DEPTH, lrets[0], lrets[1]);
			if (next_obj == NIL)
			{
				bellout();
				next_obj = 0;
			} else
			{
				cont = fm_button(tree, next_obj, lrets[5], &next_obj);
			}
		}
		/* handle end of field  */
		/*   clean up       */
		if (!cont || (next_obj != 0 && next_obj != edit_obj))
		{
			ob_edit(tree, edit_obj, 0, &idx, EDEND);
		}
	}
	/* give up mouse and screen ownership */
	take_ownership(FALSE);
	/* return exit object   */
	return next_obj;
}



/*
 * AES #51 - form_dial - Reserve or release memory for a dialog object.
 *
 *	Form DIALogue routine to handle visual effects of drawing and
 *	undrawing a dialogue
 */
/* 306de: 00e1cce0 */
/* 104de: 00fe08c6 */
/* 106de: 00e225a2 */
VOID fm_dial(P(int16_t) fmd_type, P(GRECT *) pi, P(GRECT *) pt)
PP(register int16_t fmd_type;)
PP(register GRECT *pi;)
PP(register GRECT *pt;)
{
	/* adjust tree position */
	gsx_sclip(&gl_rscreen);
	switch (fmd_type)
	{
	case FMD_START:
		/* grab screen sync or some other mutual exclusion method */
		break;
	case FMD_GROW:
		/* growing box */
		gr_growbox(pi, pt);
		break;
	case FMD_SHRINK:
		/* shrinking box */
		gr_shrinkbox(pi, pt);
		break;
	case FMD_FINISH:
		/* update certain portion of the screen */
		w_drawdesk(pt);
        w_update(DESK, pt, DESK, FALSE);
		/* break; */
	}
}


/* 306de: 00e1cd56 */
/* 104de: 00fe0920 */
/* 106de: 00e22618 */
int16_t fm_show(P(int16_t) string, P(VOIDPTR) pwd, P(int16_t) level)
PP(int16_t string;)
PP(VOIDPTR pwd;)
PP(int16_t level;)
{
	int16_t ret;
	char *alert;
	char *ad_alert;
	
	UNUSED(ret);
	ad_alert = alert = rs_str(string);
	if (pwd)
	{
		merge_str(&D.g_loc2[0], alert, pwd);
		ad_alert = &D.g_loc2[0];
	}
	return fm_alert(level, ad_alert);
}


/* TRO 9/20/84  - entered from dosif when a DOS error occurs      */
/* 306de: 00e1cda8 */
/* 104de: 00fe095e */
/* 106de: 00e2266a */
int16_t eralert(P(int16_t) n, P(int16_t) d)
PP(int16_t n;)									/* n = alert #, 0-5     */
PP(int16_t d;)									/* d = drive code, 0=A  */
{
	int16_t ret;
	int16_t level;
	char *pdrive_let;
	VOIDPTR pwd;
	char drive_let[2];

	drive_let[0] = d + 'A';						/* make it a 2 char string */
	drive_let[1] = '\0';
	pdrive_let = drive_let;

	/* which alert */
	level = ml_pwlv[n] & 0x00ff;
	pwd = (ml_pwlv[n] & 0xff00) ? (VOIDPTR)&pdrive_let : NULL;
	ret = fm_show(ml_alrt[n], pwd, level);
	return ret != 1;
}


/*
 * AES #53 - form_error - Display an alert box form for TOS errors. 
 */
/* 306de: 00e1ce1a */
/* 104de: 00fe09cc */
/* 106de: 00e226dc */
BOOLEAN fm_error(P(int16_t) n)
PP(int16_t n;)									/* n = dos error number */
{
	register int16_t ret;
	register int16_t string;

	if (n > 63)							/* nothing for xtal errors */
		return FALSE;

	switch (n)
	{
	case E_FILENOTFND:				/* file not found   */
	case E_NOFILES:					/* no more files    */
	case E_PATHNOTFND:				/* path not found   */
		string = ALRT18ERR;
		break;
	case E_NOHANDLES:				/* too many open files  */
		string = ALRT04ERR;
		break;
	case E_NOACCESS:				/* access denied    */
		string = ALRT05ERR;
		break;
	case E_NOMEMORY:				/* insufficient memory  */
	case E_BADENVIR:				/* invalid environment  */
	case E_BADFORMAT:				/* invalid format   */
		string = ALRT08ERR;
		break;
	case E_BADDRIVE:				/* invalid drive    */
		string = ALRT15ERR;
		break;
#if OS_COUNTRY == CTRY_US
	case E_NODELDIR:
		string = ALRT16ERR;
		break;
#endif
	default:
		string = ALRTXXERR;
	}

	ret = fm_show(string, string == ALRTXXERR ? (VOIDPTR)&n : NULL, 1);
	return ret != 1;
}
