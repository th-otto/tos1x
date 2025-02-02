/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:26:19 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:26:19  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:29:09  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:34:55  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMQUEUE.C	1/27/84 - 01/07/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Modify doq for acc wait	7/13/90		D.Mui			*/


/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"


LINEF_STATIC VOID doq PROTO((int16_t donq, PD *p, QPB *m));


/* 100de: 00fe4926 */
VOID akbin(P(EVB *)e, P(int32_t) aparm)
PP(register EVB *e;)
PP(int32_t aparm;)
{
	/* find vcb to input, point c at it */
	if (cda->c_q.c_cnt)
	{
		/* another satisfied customer */
		e->e_return = dq(&cda->c_q);
		zombie(e);
	} else							/* time to zzzzz... */
	{
		evinsert(e, &cda->c_iiowait);
	}
}


/* 100de: 00fe496c */
VOID adelay(P(EVB *)e, P(int32_t) aparm)
PP(register EVB *e;)
PP(register int32_t aparm;)
{
	register EVB *p, *q;

	if (aparm == 0x0L)				/* # of ticks to wait   */
		aparm = 0x1L;

	cli();
	if (CMP_TICK)
	{
		/*
		 * if already counting down then reset
		 * CMP_TICK to the lower number but let NUM_TICK grow
		 * from its accumulated value
		 */
		if (aparm <= CMP_TICK)
			CMP_TICK = aparm;
	} else
	{
		/*
		 * if we aren't currently counting down for
		 * someone else then start ticking
		 */
		CMP_TICK = aparm;
		/* start NUM_TICK out at zero */
		NUM_TICK = 0;
	}


	e->e_flag |= EVDELAY;
	q = (EVB *)((char *) &dlr - elinkoff);

	for (p = dlr; p; p = (q = p)->e_link)
	{
		if (aparm <= p->e_parm)
			break;
		aparm -= p->e_parm;
	}

	e->e_pred = q;
	q->e_link = e;
	e->e_parm = aparm;
	e->e_link = p;

	if (p)
	{
		aparm = p->e_parm - aparm;
		p->e_pred = e;
		p->e_parm = aparm;
	}
	sti();
}


/* 100de: 00fe49fe */
VOID abutton(P(EVB *)e, P(int32_t) aparm)
PP(register EVB *e;)
PP(register int32_t aparm;)
{
	register int16_t bclicks;
	
	if (downorup(button, aparm)
#if TP_48 /* ARROWFIX */
		&& rlr == gl_mowner
#endif
		)
	{								/* changed */
		e->e_return = 1;
		zombie(e);					/* 'nuff said       */
	} else
	{
		/* increment counting semaphore to show someone cares about multiple clicks */
#if 0
	mui:
#endif
		bclicks = (LHIWD(aparm) & 0x000000ffL);
		if (bclicks > 1)
			gl_bpend++;

		e->e_parm = aparm;
		evinsert(e, &cda->c_bsleep);
	}
}


/* 100de: 00fe4a64 */
VOID amouse(P(EVB *)e, P(int32_t) aparm)
PP(register EVB *e;)
PP(int32_t aparm;)
{
	MOBLK mob;

	LBCOPY(&mob, (VOIDPTR)aparm, sizeof(MOBLK));
	/* if already in (or out) signal immediately */
#if TP_48 /* ARROWFIX */
	if (ev_mchk(&mob))
#else
	if (mob.m_out != inside(xrat, yrat, (GRECT *)&mob.m_x))
#endif
	{
		zombie(e);
	} else
	{
		if (mob.m_out)
			e->e_flag |= EVMOUT;
		else
			e->e_flag &= ~EVMOUT;
		e->e_parm = HW(mob.m_x) + mob.m_y;
		e->e_return = HW(mob.m_w) + mob.m_h;
		evinsert(e, &cda->c_msleep);
	}
}


/* 306de: 00e1fe68 */
/* 104de: 00fdeaba */
/* 106de: 00e20380 */
/* 100de: 00fe4af4 */
LINEF_STATIC BOOLEAN fapd(P(const char *) pname, P(int16_t) pid, P(PD *) ppd)
PP(const char *pname;)
PP(int16_t pid;)
PP(register PD *ppd;)
{
	register BOOLEAN ret;
	char temp[9];

	ret = FALSE;
	temp[8] = 0;
	if (pname != NULL)
	{
		movs(8, ppd->p_name, temp);
		ret = streq(pname, temp);
	} else
	{
		ret = (ppd->p_pid == pid);
	}
	return ret;
}


/* 306de: 00e1fec8 */
/* 104de: 00fdeb0a */
/* 106de: 00e203e0 */
/* 100de: 00fe4b4e */
PD *fpdnm(P(const char *) pname, P(uint16_t) pid)
PP(const char *pname;)
PP(uint16_t pid;)
{
	register int16_t i;
	PD *ppd;

	UNUSED(ppd);
	for (i = 0; i < NUM_PDS; i++)
	{
		if (fapd(pname, pid, &D.g_pd[i]))
			return &D.g_pd[i];
	}
	for (i = 0; i < gl_naccs; i++)
	{
		if (fapd(pname, pid, &gl_pacc[i]->ac_pd))
			return &gl_pacc[i]->ac_pd;
	}
	return NULL;
}


/* 306de: 00e1ff64 */
/* 104de: 00fdeb9a */
/* 106de: 00e2047c */
/* 100de: 00fe4bde */
LINEF_STATIC PD *getpd(NOTHING)
{
	PD *p;

	if (curpid < NUM_PDS)				/* get a new PD     */
	{
		p = &D.g_pd[curpid];
		p->p_pid = curpid++;
	} else								/* otherwise get it     */
	{									/* accessory's PD list  */
		p = &gl_pacc[gl_naccs]->ac_pd;
		p->p_pid = NUM_PDS + gl_naccs++;
	}
	/* initialize his DS&SS registers so stproc works   */
#if TOSVERSION < 0x104
	setdsss(p->p_uda);
/*	setdsss(puda)
*		UDA	*puda;
*
*	set "segment " into u_ssuper and u_ssuser
*	and set u_insuper to TRUE
*
*	in 68k u_ssuper and u_ssuser do not exist
*/
#else
	p->p_uda->u_insuper = 1;
#endif
	/* return the pd we got */
	return p;
}


/* 306de: 00e1ffde */
/* 104de: 00fdec12 */
/* 106de: 00e204f6 */
/* 100de: 00fe4c54 */
VOID p_nameit(P(PD *) p, P(const char *) pname)
PP(PD *p;)
PP(const char *pname;)
{
	bfill(8, ' ', p->p_name);
	strscn(pname, p->p_name, '.');
}


/* 306de: 00e20018 */
/* 104de: 00fdec42 */
/* 106de: 00e20530 */
/* 100de: 00fe4c86 */
PD *pstart(P(VOIDPTR) pcode, P(const char *) pfilespec, P(intptr_t) ldaddr)
PP(VOIDPTR pcode;)
PP(const char *pfilespec;)
PP(intptr_t ldaddr;)
{
	register PD *px;

	/* create process to execute it */
	px = getpd();
	px->p_ldaddr = ldaddr;
	/* copy in name of file */
	p_nameit(px, pfilespec);
	/* cs, ip, use 0 flags  */
	psetup(px, pcode);
	/* link him up */
#if AESVERSION >= 0x200
	px->p_stat = PS_RUN;
#else
	px->p_stat = 0;
#endif
	px->p_link = drl;
	drl = px;

	return px;
}


/* 306de: 00e20062 */
/* 104de: 00fdec7c */
/* 106de: 00e20578 */
/* 100de: 00fe4cc0 */
LINEF_STATIC VOID doq(P(int16_t) donq, P(PD *) p, P(QPB *) m)
PP(int16_t donq;)
PP(register PD *p;)
PP(QPB *m;)
{
	register int16_t n, index;
	register int16_t *om, *nm;

	n = m->qpb_cnt;
	if (donq)
	{
		LBCOPY(p->p_qindex + p->p_qaddr, m->qpb_buf, n);
		/* if its a redraw msg try to find a matching msg and union the redraw rects together */
		nm = (int16_t *) &p->p_queue[p->p_qindex];

#if AESVERSION >= 0x200
		if (nm[0] == AC_CLOSE)
			p->p_stat |= PS_TRYSUSPEND;
#endif

		if (nm[0] == WM_REDRAW)
		{
			index = 0;
			while ((index < p->p_qindex) && n)
			{
				om = (int16_t *) &p->p_queue[index];
				if (om[0] == WM_REDRAW && nm[3] == om[3])
				{
					rc_union((GRECT *)&nm[4], (GRECT *)&om[4]);
					n = 0;
				} else
				{
					index += (om[2] + 16);
				}
			}
		}
		p->p_qindex += n;
	} else
	{
		LBCOPY(m->qpb_buf, p->p_qaddr, n);
		p->p_qindex -= n;
		if (p->p_qindex)
			LBCOPY(p->p_qaddr, p->p_qaddr + n, p->p_qindex);
	}
}


/* 306de: 00e2014e */
/* 104de: 00fded44 */
/* 106de: 00e20658 */
/* 100de: 00fe4d88 */
VOID aqueue(P(BOOLEAN) isqwrite, P(EVB *) e, P(intptr_t) lm)
PP(BOOLEAN isqwrite;)
PP(register EVB *e;)
PP(intptr_t lm;)
{
	register PD *p;
	register QPB *m;
	EVB **ppe;
	int16_t qready;

	m = (QPB *) lm;

	p = fpdnm(NULL, m->qpb_pid);

	if (isqwrite)
		qready = (m->qpb_cnt <= (QUEUE_SIZE - p->p_qindex));
	else
		qready = (p->p_qindex > 0);

	ppe = (isqwrite ^ qready) ? &p->p_qnq : &p->p_qdq;
	/* room for message */
	/*  or messages in q    */
	if (qready)
	{
		doq(isqwrite, p, m);
		zombie(e);
		if ((e = *ppe))
		{
			e->e_flag |= NOCANCEL;
			*ppe = e->e_link;

			if (e->e_link)
				e->e_link->e_pred = e->e_pred;

			doq(!isqwrite, p, (QPB *) e->e_parm);
			zombie(e);
		}
	} else								/* "block" the event    */
	{
		e->e_parm = lm;
		evinsert(e, ppe);
	}
}


