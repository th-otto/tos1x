/*
 ***************************   GEMDISP.C    ******************************
 *
 * =======================================================================
 * $Author: mui $       $Date: 89/04/26 18:21:59 $
 * =======================================================================
 *
 * Revision 2.3  89/04/26  18:21:59  mui
 * TT
 * 
 * Revision 2.2  89/04/19  14:42:26  kbad
 * 680x0 support: removed savestate() and switchto() (now in jdispa.s)
 * 
 * Revision 2.1  89/02/22  05:25:37  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.2  88/12/05  16:50:41  mui
 * make the forkq return TRUE or FALSE
 * 
 * Revision 1.1  88/06/02  12:31:33  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*      GEMDISP.C       1/27/84 - 02/03/85      Lee Jay Lorenzen        */
/*      Reg Opt         03/09/85                Derek Mui               */
/*      1.1             03/21/85                Lowell Webster          */
/*      Change chkbd    07/22/85                Derek Mui               */
/*      Change disp_act 07/12/85                Derek Mui               */
/*      Reorganize the chkkbd   08/14/85        Derek Mui               */
/*      Trying 1.2      10/16/85                Derek Mui               */
/*      Fix the forker  3/10/86                 Derek Mui               */
/*      Fix the KEYSTOP 3/21/86                 Derek Mui               */
/*      Inlined code of schedule and mwait_act  4/9/88                  */
/*      Fix the accessory wait problem  7/13/90 D.Mui                   */
/*      Block process when in critical error    8/1/90  D.Mui           */

/*
 *      -------------------------------------------------------------
 *      GEM Application Environment Services              Version 1.1
 *      Serial No.  XXXX-0000-654321              All Rights Reserved
 *      Copyright (C) 1985                      Digital Research Inc.
 *      -------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "gsxdefs.h"


#define KEYSTOP 0x00002b1cL				/* control backslash    */

#if AESVERSION >= 0x200
PD *dpd;								/* critical error process   */
PD *slr;
#endif

/* 306de: 00e1b8ea */
/* 104de: 00fde286 */
/* 106de: 00e1fa66 */
/* 100de: 00fe3f94 */
asm("  .globl forkq");
asm("forkq: .text");
VOID forkq(P(FCODE) fcode, P(int32_t) fdata)
PP(FCODE fcode;)
PP(int32_t fdata;)
{
	register FPD *f;

	/* q a fork process, enter with ints OFF */
	if (fpcnt < NFORKS)
	{
		f = &D.g_fpdx[fpt++];
		/* wrap pointer around  */
		if (fpt == NFORKS)
			fpt = 0;

		f->f_code = fcode;
		f->f_data = fdata;

		fpcnt++;
		xforkq = TRUE;
	}
}


/* 306de: 00e1b94a */
/* 104de: 00fde2de */
/* 106de: 00e1fac6 */
/* 100de: 00fe3fee */
VOID disp_act(P(PD *) p)
PP(register PD *p;)
{
	register PD *pq, *q;

	/* process is ready, so put him on RLR */
#if AESVERSION >= 0x200
	p->p_stat &= ~PS_MWAIT;
	p->p_stat |= PS_RUN;
#else
	p->p_stat = 0;
#endif
	/* find the end */
	for (pq = (q = (PD *) & rlr)->p_link; pq; pq = (q = pq)->p_link)
		;
	/* link him in */
	p->p_link = pq;
	q->p_link = p;
}

/****************************************************************/

#if AESVERSION >= 0x200
/*
 * Suspend the process
 */
/* 306de: 00e1b982 */
VOID suspend_act(P(PD *) p)
PP(register PD *p;)
{
	register PD *q;

	UNUSED(q);
	p->p_stat = PS_SUSPENDED;
	p->p_link = slr;
	slr = p;
}
#endif


/* 100de: 00fe4016 */
LINEF_STATIC VOID mwait_act(P(PD *) p)
PP(register PD *p;)
{       
    /* sleep on nrl if */
	/* event flags are not set */
	if (p->p_evwait & p->p_evflg)
	{
		disp_act(p);
	} else
	{ 
		p->p_link = nrl;		/* good night, Mrs. */
		nrl = p;				/* Calabash, wherever   */
	}
}



/* 306de: 00e1b9aa */
/* 104de: 00fde306 */
/* 106de: 00e1faf6 */
/* 100de: 00fe4040 */
VOID forker(NOTHING)
{
	register FPD *f;
	register PD *oldrl;
	register int32_t amt;

	infork = 1;
	oldrl = rlr;
	rlr = (PD *) -1;
	while (fpcnt)
	{
		fpcnt--;
		f = &D.g_fpdx[fph++];
		if (fph == NFORKS)
			fph = 0;
		/* see if recording */
		if (gl_recd)
		{
			/* check for stop key */
			if ((f->f_code == kchange) && ((f->f_data & 0xffffL) == KEYSTOP))
				gl_recd = FALSE;
			/* if still recording then handle event */
			if (gl_recd)
			{
				/*
				 * if its a time event & previously recorded
				 * was a time event then coalesce them 
				 * else record the event
				 * BUG: may access memory before gl_rbuf if first recorded event is time event
				 */
#if (AESVERSION >= 0x140) | !BINEXACT
				if ((f->f_code == tchange) && (LLGET(gl_rbuf - sizeof(FPD)) == (intptr_t)tchange))
#else
				/* BUG: comparing only word, and also generates buggy code */
				if ((f->f_code == tchange) && ((*((uint16_t *)(gl_rbuf - sizeof(FPD)))) == tchange))
#endif
				{
					amt = f->f_data + LLGET(gl_rbuf - sizeof(int32_t));
					LLSET(gl_rbuf - sizeof(int32_t), amt);
				} else
				{
					LBCOPY((VOIDPTR)gl_rbuf, ADDR(f), sizeof(FPD));
					gl_rbuf += sizeof(FPD);
					gl_rlen--;
					gl_recd = gl_rlen;
				}
			}
		}
#ifdef __ALCYON__
		(*f->f_code) (f->f_data);
#else
		(*f->f_code) (LHIWD(f->f_data), LLOWD(f->f_data));
#endif
	}
	rlr = oldrl;
	infork = 0;
}


/* 306de: 00e1bac6 */
/* 104de: 00fde416 */
/* 106de: 00e1fc12 */
/* 100de: 00fe4152 */
VOID chkkbd(NOTHING)
{
	register int16_t achar, kstat;
	register int16_t *pintin;
	register int16_t *pintout;
	int unused[3];
	
	UNUSED(unused);
	gsx_ncode(KEY_SHST, 0, 0);
	kstat = intout[0];

	if (gl_kowner->p_cda->c_q.c_cnt < KBD_SIZE)
	{
		pintin = &intin[0];
		pintout = &intout[0];

		pintin[0] = 4;
		pintin[1] = 2;
		gsx_ncode(SET_INPUT_MODE, 0, 2);

		pintin[0] = -1;
		pintin[1] = FALSE;				/* no echo */
		gsx_ncode(STRING_INPUT, FALSE, 2);
		if (contrl[4])
			achar = pintout[0];
		else
			achar = 0;
	} else
	{
		achar = 0;
	}

	if ((achar) || (kstat != kstate))
	{
#ifdef __ALCYON__
		forkq(kchange, achar, kstat);
#else
		forkq(kchange, HW(achar) | LW(kstat));
#endif
	}
}


/****************************************************************
 *                                                              *
 *   dispatcher maintains all flags/regs so it looks like       *
 *   an RTE to the caller.                                      *
 *   dsptch() = rte                                             *
 *   rlr -> p_stat determines the action to perform on the      *
 *          process that was in context                         *
 *   rlr -> p_uda -> dparam is used by the action routines      *
 *                                                              *
 ****************************************************************/

/* 
 * schedule();
 *
 * run through lists until someone is on the rlr or the fork list
 */
/* 100de: 00fe41e6 */
LINEF_STATIC VOID schedule(NOTHING)
{
	register PD *p;

	do
	{
		/* poll the keyboard */
		chkkbd();
		/* now move drl processes to rlr */

		while (drl)
		{
			drl = (p = drl)->p_link;
			disp_act(p);
		}
		/* check if there is something to run */
#ifdef THROTTLE_CPU
		if (rlr || fpcnt)
			break;
		idle(); /* Tell multitasking OS we're idle */
#endif
	} while (!rlr && !fpcnt);
}

/****************************************************************
 * Machine state is saved before this routine is entered!       *
 ****************************************************************/

/* 306de: 00e1bb66 */
/* 104de: 00fde4a0 */
/* 106de: 00e1fcb2 */
/* 100de: 00fe4220 */
VOID disp(NOTHING)
{
	register PD *p;
	int unused[2];
	
	UNUSED(unused);
#if TOSVERSION <= 0x104
	savestate(rlr->p_uda);
#endif
	rlr = (p = rlr)->p_link;
	/* based on the state of the process p do something */
	switch (p->p_stat)
	{
	case 0:
		disp_act(p);
		break;
	case PS_MWAIT:
		mwait_act(p);
		/* break; */
	}

	/* run through and execute all the fork processes */
	do
	{
		forker();
		schedule();
	} while (fpcnt);

	/*
	 * switch to the context of the appropriate process
	 */
	cda = rlr->p_cda;
#if TOSVERSION <= 0x104
	switchto(rlr->p_uda);
#endif
}

/****************************************************************
 * Actual context switch happens after we fall out of disp().	*
 ****************************************************************/
/* switchto() is a machine dependent routine which:
 *	1) restores machine state
 *	2) clear "indisp" semaphore
 *	3) returns to appropriate address
 *		so we'll never return from this
 */
