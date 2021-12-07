/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:22:19 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:22:19  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:25:53  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:31:43  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMEVLIB.C	1/28/84 - 02/02/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	1.1		03/21/85 - 04/10/85	Lowell Webster		*/
/*	Change the double click 0 to 64 tick  2/20/86	Derek Mui	*/
/*	Change at ev_ret for tbutton	10/29/86	Derek Mui	*/
/*	Change at ev_multi for tbutton	10/30/86	Derek Mui	*/
/*	Change at ev_multi	10/31/86		Derek Mui	*/
/*	Change the click speed  12/15/86		Derek Mui	*/
/*	Fix multiple button	12/16/86		Derek Mui	*/
/*	Unfix double click speed 12/16/86		Derek Mui	*/
/*	Fix at ev_multi and mesag for smooth scrolling 3/11/87 Derek Mui*/


/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"


int16_t const gl_dcrates[5] = { 450, 330, 275, 220, 165 };

int16_t gl_dcindex;
/* # of ticks to wait to see if a second click will occur   */
int16_t gl_dclick;
int16_t gl_ticktime;



/*
 *	Stuff the return array with the mouse x, y, button, and keyboard
 *	state.
 */
/* 306de: 00e1bcb6 */
VOID ev_rets(P(int16_t *) lrets)
PP(int16_t *lrets;)
{
	if (mtrans)
	{
		lrets[0] = pr_xrat;
		lrets[1] = pr_yrat;
	} else
	{
		lrets[0] = xrat;
		lrets[1] = yrat;
	}

	lrets[2] = tbutton;
	lrets[3] = kstate;
	mtrans = 0;
}


/*
 *	Routine to block for a certain async event and return a
 *	single return code.
 */
/* 306de: 00e1bd12 */
int16_t ev_block(P(int16_t) code, P(intptr_t) lvalue)
PP(int16_t code;)
PP(intptr_t lvalue;)
{
	EVSPEC msk;

	mwait(msk = iasync(code, lvalue));
	return aret(msk);
}



/*
 * AES #20 - evnt_keybd - Wait for a keyboard event
 *
 *	Wait for a key to be ready at the keyboard and return it. 
 */
/* 306de: 00e1bd40 */
uint16_t ev_keybd(NOTHING)
{
	return ev_block(AKBIN, 0x0L);
}


/*
 * AES #21 - evnt_button - Wait for a mouse button event.
 *
 *	Wait for the mouse buttons to reach the state where:
 *		((bmask & (bstate ^ button)) == 0) != bflag
 *	Clicks is how many times to wait for it to reach the state, but
 *	the routine should return how many times it actually reached the
 *	state before some time interval.
 */
/* 306de: 00e1bd52 */
uint16_t ev_button(P(int16_t) bflgclks, P(uint16_t) bmask, P(uint16_t) bstate, P(int16_t *) lrets)
PP(int16_t bflgclks;)
PP(uint16_t bmask;)
PP(uint16_t bstate;)
PP(int16_t *lrets;)
{
	int16_t ret;
	int32_t parm;

	parm = HW(bflgclks) | LW((bmask << 8) | bstate);
	ret = ev_block(ABUTTON, parm);
	ev_rets(lrets);
	return ret;
}


/*
 * AES #22 - evnt_mouse - Wait for the mouse pointer to enter or leave a specified area of the screen.
 *
 *	Wait for the mouse to leave or enter a specified rectangle.
 */
/* 306de: 00e1bd96 */
uint16_t ev_mouse(P(MOBLK *)pmo, P(int16_t *) lrets)
PP(MOBLK *pmo;)
PP(int16_t *lrets;)
{
	int16_t ret;

	ret = ev_block(AMOUSE, (intptr_t)ADDR(pmo));
	ev_rets(lrets);
	lrets[2] = button;
	return ret;
}


/*
 * AES #23 - evnt_mesag - Wait for an AES message.
 *
 *	Wait for a message to be received in applications message pipe.
 *	Then read it into pbuff.
 */
/* 206de: 00e18362 */
/* 306de: 00e1bdc8 */
int16_t ev_mesag(P(int16_t *) pbuff)
PP(int16_t *pbuff;)
{
	{
		if (!rd_mymsg(pbuff))
			return ap_rdwr(AQRD, rlr->p_pid, 16, pbuff);
	}

	return TRUE;
}


/*
 * AES #24 - evnt_timer - Wait for a given time interval. 
 *
 *	Wait the specified time to be completed.
 */
/* 306de: 00e1be00 */
int16_t ev_timer(P(int32_t) count)
PP(int32_t count;)
{
	return ev_block(ADELAY, count / gl_ticktime);
}


/*
 *	Used by ev_multi() to check on mouse rectangle events
 */
/* 306de: 00e1be2a */
/* 206de: 00e183c4 */
int16_t ev_mchk(P(MOBLK *) pmo)
PP(register MOBLK *pmo;)
{
	if ((rlr == gl_mowner) && (pmo->m_out != inside(xrat, yrat, (GRECT *)&pmo->m_x)))
		return TRUE;
	else
		return FALSE;
}


/*
 * AES #25 - evnt_multi - Wait for an arbitrary event.
 *
 *	Do a multi-wait on the specified events.
 */
/* 306de: 00e1be72 */
int16_t ev_multi(P(int16_t) flags, P(MOBLK *) pmo1, P(MOBLK *) pmo2, P(int32_t) tmcount, P(intptr_t) buparm, P(int16_t *) mebuff, P(int16_t *) prets)
PP(register int16_t flags;)
PP(register MOBLK *pmo1;)
PP(MOBLK *pmo2;)
PP(int32_t tmcount;)
PP(intptr_t buparm;)
PP(int16_t *mebuff;)
PP(int16_t *prets;)
{
	QPB m;
	EVSPEC wmask, kbmsk, bumsk, m1msk, m2msk, qrmsk, tmmsk;
	register EVSPEC which;
	register int16_t what;
	register CQUEUE *pc;

	/* say nothing has happened yet   */
	what = wmask = kbmsk = bumsk = m1msk = m2msk = qrmsk = tmmsk = 0;
	/* do a pre-check for a keystroke & then clear out the forkq */
	chkkbd();
	forker();

	/*   a keystroke    */
	if (flags & MU_KEYBD)
	{
		/* if a character is ready then get it  */
		pc = &rlr->p_cda->c_q;
		if (pc->c_cnt)
		{
			prets[4] = dq(pc);
			what |= MU_KEYBD;
		}
	}
	/* quick check button   */
	if (flags & MU_BUTTON)
	{
		if (rlr == gl_mowner)
		{
			if ((mtrans > 1) && (downorup(pr_button, buparm)))
			{
				tbutton = pr_button;	/* changed */
				what |= MU_BUTTON;
				prets[5] = pr_mclick;
			} else
			{
				if (downorup(button, buparm))
				{
					tbutton = button;	/* changed */
					what |= MU_BUTTON;
					prets[5] = mclick;
				}
			}

#if AESVERSION >= 0x200
			if (mowner(tbutton) != rlr)
				what &= ~MU_BUTTON;
#endif
		}
	}
	/* quick check mouse rec */
	if (flags & MU_M1)
	{
		if (ev_mchk(pmo1))
			what |= MU_M1;
	}
	/* quick check mouse rec */
	if (flags & MU_M2)
	{
		if (ev_mchk(pmo2))
			what |= MU_M2;
	}
	/* quick check timer */
	if (flags & MU_TIMER)
	{
		if (wmask == 0 && tmcount == 0)
		{
			what |= MU_TIMER;
		}
	}
	/* quick check message  */
	if (flags & MU_MESAG)
	{
		if (rlr->p_qindex > 0)
		{
			ev_mesag(mebuff);
			what |= MU_MESAG;
		} else
		{
			if (rd_mymsg(mebuff))
				what |= MU_MESAG;
		}
	}

	/* check for quick out if something has already happened */
#if !BINEXACT
	which = 0; /* quiet compiler */
#endif
	if (what == 0x0)
	{
		if (flags & MU_KEYBD)
			wmask |= kbmsk = iasync(AKBIN, 0x0L);
		/* wait for a button    */
		if (flags & MU_BUTTON)
			wmask |= bumsk = iasync(ABUTTON, buparm);
		/* wait for mouse rect. */
		if (flags & MU_M1)
			wmask |= m1msk = iasync(AMOUSE, (intptr_t)ADDR(pmo1));
		/* wait for mouse rect. */
		if (flags & MU_M2)
			wmask |= m2msk = iasync(AMOUSE, (intptr_t)ADDR(pmo2));
		/* wait for message */
		if (flags & MU_MESAG)
		{
			m.qpb_pid = rlr->p_pid;
			m.qpb_cnt = 16;
			m.qpb_buf = mebuff;
			wmask |= qrmsk = iasync(AQRD, (intptr_t)ADDR(&m));
		}
		/* wait for timer   */
		if (flags & MU_TIMER)
			wmask |= tmmsk = iasync(ADELAY, tmcount / gl_ticktime);
		/* wait for events  */
		which = mwait(wmask);
		/* cancel outstanding   */
		/*   events     */
		which |= acancel(wmask);
	}
	
	/* get the returns  */
	ev_rets(&prets[0]);
	if (!(flags & MU_BUTTON))
		prets[2] = button;

	/* do arets() if    */
	/*   something hasn't   */
	/*   already happened   */
	if (what == 0x0)
	{
		if (which & kbmsk)
		{
			prets[4] = (uint16_t) aret(kbmsk);
			what |= MU_KEYBD;
		}
		if (which & bumsk)
		{
			prets[5] = (uint16_t) aret(bumsk);
			prets[2] = tbutton;
			what |= MU_BUTTON;
		}
		if (which & m1msk)
		{
			aret(m1msk);
			what |= MU_M1;
		}
		if (which & m2msk)
		{
			aret(m2msk);
			what |= MU_M2;
		}
		if (which & qrmsk)
		{
			aret(qrmsk);
			what |= MU_MESAG;
		}
		if (which & tmmsk)
		{
			aret(tmmsk);
			what |= MU_TIMER;
		}
	}

	/* return what happened */
	return what;
}


/*
 * AES #26 - evnt_dclick - Obtain or set the time delay between the two clicks of a double-elick.
 */
/* 206de: 00e18752 */
/* 306de: 00e1c1b8 */
int16_t ev_dclick(P(int16_t) rate, P(int16_t) setit)
PP(int16_t rate;)
PP(int16_t setit;)
{
	if (setit)
	{
		gl_dcindex = rate;
		gl_dclick = gl_dcrates[gl_dcindex] / gl_ticktime;
	}

	return gl_dcindex;
}
