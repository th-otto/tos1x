/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:20:44 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:20:44  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:24:16  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.2  89/02/16  10:48:04  mui
 * In acancel, clean up any outstanding d click event
 *
 * Revision 1.1  88/06/02  12:30:50  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMASYNC.C	1/27/84 - 02/05/85	Lee Jay Lorenzen	*/
/*	to 68k		03/09/85 - 04/05/85	Derek Mui		*/
/*	remove bit_num	06/10/85		Mike Schmal		*/
/*	Change at aret for tbutton 10/29/86	Derek Mui		*/
/*	Change at mwait for acc wait	7/13/90	D.Mui			*/
/*	No check of mowner() at iasync	4/15/91	D.Mui			*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"

int16_t tbutton;
#if AESVERSION >= 0x200
int16_t wwait;
#endif


/* 306de: 00e19db6 */
/* 106de: 00e1ebcc */
VOID evinsert(P(EVB *) e, P(EVB **) root)
PP(register EVB *e;)
PP(EVB **root;)
{
	register EVB *p, *q;

	/* insert event block on list */
	q = (EVB *)((char *) root - elinkoff);
	p = *root;
	e->e_pred = q;
	q->e_link = e;
	e->e_link = p;
	if (p)
		p->e_pred = e;
}


/* 306de: 00e19df0 */
/* 106de: 00e1ebd6 */
VOID takeoff(P(EVB *) p)
PP(register EVB *p;)
{
	register int32_t c;

	/* take event p off */
	/* e_link list, must    */
	/* be NODISP        */
	p->e_pred->e_link = p->e_link;
	if (p->e_link)
	{
		p->e_link->e_pred = p->e_pred;
		if (p->e_flag & EVDELAY)
		{
			c = p->e_link->e_parm;
			c += p->e_parm;
			p->e_link->e_parm = c;
		}
	}
	p->e_nextp = eul;
	eul = p;
}


/* 306de: */
/* 106de: 00e1ec2e */
EVSPEC mwait(P(EVSPEC) mask)
PP(EVSPEC mask;)
{
	rlr->p_evwait = mask;
	if (!(mask & rlr->p_evflg))
	{
#if AESVERSION >= 0x200
		rlr->p_stat &= ~PS_RUN;
		rlr->p_stat |= PS_MWAIT;
		wwait = TRUE;
#else
		rlr->p_stat = PS_MWAIT;
#endif
		dsptch();
	}
	return rlr->p_evflg;
}


/* 306de: 00e19e9c */
/* 206de: 00e16436 */
/* 106de: 00e1ec6e */
EVSPEC iasync(P(int16_t) afunc, P(intptr_t) aparm)
PP(int16_t afunc;)
PP(register intptr_t aparm;)
{
	register EVB *e;
	register EVB *p, *q;

	/* e = get_evb();   */
	if ((e = eul) != NULL)
	{
		eul = eul->e_nextp;
		bfill(sizeof(EVB), 0, e);
	}

	e->e_nextp = rlr->p_evlist;			/* link the EVB to the  */
	rlr->p_evlist = e;					/* PD evlist        */
	e->e_pd = rlr;
#if BINEXACT
	e->e_flag = (int)(intptr_t)(e->e_pred = 0);
#else
	e->e_flag = 0;
	e->e_pred = NULL;
#endif
	/* find a free bit in in the mask */
	for (e->e_mask = 1; rlr->p_evbits & e->e_mask; e->e_mask <<= 1)
		;

	rlr->p_evbits |= e->e_mask;

	switch (afunc)
	{
	case AQRD:
		aqueue(FALSE, e, aparm);
		break;
	case AQWRT:
		aqueue(TRUE, e, aparm);
		break;
	case ADELAY:						/* link to the CDA also */
		adelay(e, aparm);
		break;
	case AMUTEX:						/* link to the CDA also */
		amutex(e, (SPB *)aparm);
		break;
	case AKBIN:							/* link to the CDA also */
		akbin(e, aparm);
		break;
	case AMOUSE:						/* link to the CDA also */
		amouse(e, aparm);
		break;
	case ABUTTON:						/* link to the CDA also */
		abutton(e, aparm);
		break;
	}

	return e->e_mask;
}


/* 306de: 00e1a14a */
/* 106de: 00e1ef1c */
uint16_t aret(P(EVSPEC) mask)
PP(register EVSPEC mask;)
{
	register EVB *p, *q, *pz;
	uint16_t erret;

	/* first find the event on the process list */
	for (p = (q = (EVB *) & rlr->p_evlist)->e_nextp; p; p = (q = p)->e_nextp)
	{
		if (p->e_mask == mask)
			break;
	}

	if (!p)
		return NOT_FOUND;
	/* if this event has occured, it is on the zombie list */
	for (pz = zlr; (pz != p) && pz; pz = pz->e_link)
		;

	if (!pz)							/* otherwise it is not completed */
		return NOT_COMPLETE;
	/* found the event, remove it from the zombie list */
	pz->e_pred->e_link = pz->e_link;
	if (pz->e_link)
		pz->e_link->e_pred = pz->e_pred;
	q->e_nextp = p->e_nextp;
	rlr->p_evbits &= ~mask;
	rlr->p_evwait &= ~mask;
	rlr->p_evflg &= ~mask;

	erret = LLOWD(p->e_return);
	p->e_nextp = eul;
	eul = p;
	tbutton = LHIWD(p->e_return);
	return erret;
}


/* 306de: 00e1a210 */
/* 106de: 00e1efe2 */
EVSPEC acancel(P(EVSPEC) m)
PP(EVSPEC m;)
{
	register EVSPEC m1;						/* mask of items not cancelled      */
	register int16_t f;
	register EVB *p, *q;

	for (p = rlr->p_cda->c_bsleep; p; p = p->e_nextp)
	{
		if (p->e_mask & m)
		{
			if ((LHIWD(p->e_parm) & 0x00ffL) > 1)
			{
				if (gl_bpend)
					gl_bpend--;
			}
		}
	}

	m1 = 0;
	for (p = (q = (EVB *) &rlr->p_evlist)->e_nextp; p; p = (q = p)->e_nextp)
	{
		if (p->e_mask & m)
		{
			/* if this is the one then check its status */
			/* aret() will take out completed EVB */
			f = p->e_flag;
			if ((f & NOCANCEL) || (f & COMPLETE))
			{
				m1 |= p->e_mask;
			} else
			{
				/* Take it off if not completed or still in progress */
				q->e_nextp = p->e_nextp;
				takeoff(p);
				rlr->p_evbits &= ~p->e_mask;
				rlr->p_evwait &= ~p->e_mask;
				p = q;					/* contine traversal    */
			}
		}
	}
	return m1;
}
