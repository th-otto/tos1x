/*
 *************************************************************************
 *                      Revision Control System
 * =======================================================================
 *  $Author: mui $      $Date: 89/04/26 18:20:23 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:20:23  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:24:03  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:30:40  lozben
 * Initial revision
 *
 *************************************************************************
 */
/*      GEMAINTS.C      1/27/84 - 01/18/85      Lee Jay Lorenzen        */
/*      Reg Opt         03/09/95                Derek Mui               */
/*      Changed at signal for acc wait  7/13/90 D.Mui                   */


/*
 *      -------------------------------------------------------------
 *      GEM Application Environment Services              Version 1.0
 *      Serial No.  XXXX-0000-654321              All Rights Reserved
 *      Copyright (C) 1985                      Digital Research Inc.
 *      -------------------------------------------------------------
 */

#include "aes.h"
#include "taddr.h"
#include "gemlib.h"


/* 306de: 00e19944 */
/* 104de: 00fdd4ee */
/* 106de: 00e1eae6 */
/* 100de: 00fe34c6 */
VOID signal(P(EVB *) e)
PP(EVB *e;)
{
	register PD *p, *p1, *q1;

	p = e->e_pd;
	p->p_evflg |= e->e_mask;
	/* off the not-ready list */
	for (p1 = (q1 = (PD *) &nrl)->p_link; (p1 != p) && (p1); p1 = (q1 = p1)->p_link)
		;
	if (p != rlr)
	{
		if (p->p_evflg & p->p_evwait)
		{
			if (p1)
			{
#if AESVERSION >= 0x200
				p1->p_stat |= PS_RUN;
#else
				p1->p_stat = 0;
#endif
				/* onto the drl */
				q1->p_link = p1->p_link;
				p1->p_link = drl;
				drl = p1;
			}
		}
	}
}


/* 306de: 00e199aa */
/* 106de: 00e199aa */
/* 100de: 00fe3522 */
VOID zombie(P(EVB *) e)
PP(register EVB *e;)
{
	/* must be called with dispatching off */
	e->e_link = zlr;
	if (zlr)
		zlr->e_pred = e;
	e->e_pred = (EVB *)((char *)&zlr - elinkoff);
	zlr = e;
	e->e_flag = COMPLETE;
	signal(e);
}


/* 100de: 00fe356a */
EVB *get_evb(NOTHING)
{
	register EVB *e;
	
	if ((e = eul) != NULL)
	{
		eul = eul->e_nextp;
		bfill(sizeof(EVB), 0, e);
	}
	return e;
}
