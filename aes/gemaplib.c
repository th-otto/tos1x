/*
 *************************************************************************
 *                       Revision Control System
 * =======================================================================
 *  $Author: mui $       $Date: 89/04/26 18:20:33 $
 * =======================================================================
 * 
 * Revision 2.2  89/04/26  18:20:33  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:24:07  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:30:46  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*      Fix the ap_tplay, so after it finished, it stay where it is     */
/*      4/17/86                 Derek Mui                               */
/*      Fix at ap_tplay 4/8/86                  Derek Mui               */
/*      Kludge at ap_tplay 3/11/86 - 3/12/86    Derek Mui               */
/*      Fix the ap_trec 03/10/86                Derek Mui               */
/*      1.1             03/20/85                Lowell Webster          */
/*      Reg Opt         03/09/85                Derek Mui               */
/*      GEMAPLIB.C      03/15/84 - 02/09/85     Lee Lorenzen            */
/*      Fix at ap_trecd to fix the length  4/5/90       D.Mui           */
/*      Add ap_init, ap_exit and rd_mymsg       4/3/91          D.Mui   */
/*      Fix at rd_mymsg for set setting the buffer clear flag 4/15/91   */
/*      New version number                      7/7/92          D.Mui   */

/*
 *       -------------------------------------------------------------
 *       GEM Application Environment Services              Version 1.1
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1985                      Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "gsxdefs.h"


#define TCHNG 0
#define BCHNG 1
#define MCHNG 2
#define KCHNG 3

int16_t gl_bvdisk;
int16_t gl_bvhard;
int16_t gl_recd;
int16_t gl_rlen;
intptr_t gl_rbuf;
#if TOSVERSION >= 0x104
int16_t gl_play;				/* 3/11/86  */
VOIDPTR gl_store;				/* 3/11/86  */
int16_t gl_mx;					/* 3/12/86  */
int16_t gl_my;					/* 3/12/86  */
#endif


/*
 * AES #10 - appl_init - Registers the application under AES. 
 *
 * Application Init
 */
/* 306de: 00e199fc */
/* 104de: 00fd7988 (in deskif.S) */
#if AESVERSION >= 0x200
int16_t ap_init(P(intptr_t) pglobal)
PP(intptr_t pglobal;)
{
	LLSET(pglobal, (((long)AESVERSION) << 16) | 1);
	LWSET(pglobal + 4, rlr->p_pid);
	LWSET(pglobal + 20, gl_nplanes);
	LLSET(pglobal + 22, &D);
	LWSET(pglobal + 26, gl_bvdisk);
	LWSET(pglobal + 28, gl_bvhard);
	rlr->p_msgtosend = FALSE;
	return rlr->p_pid;
}
#endif


/*
 * AES #16 - appl_bvset - Set the available logical drives for the file-selector. 
 */
/* 104de: 00fd79cc (in deskif.S) */
#if 0
int16_t ap_bvset(P(int16_t) bvdisk, P(int16_t) bvhard)
PP(int16_t bvdisk;)
PP(int16_t bvhard;)
{
	gl_bvdisk = bvdisk;
	gl_bvhard = bvhard;
	return TRUE;
}
#endif


/*
 * AES #19 - appl_exit - Deregister an application from the AES.
 *
 * Application Exit
 */
/* 306de: 00e19a72 */
/* 104de: 00fd79e0 (in deskif.S) */
/* 106de: inlined in gembind */
#if AESVERSION >= 0x200
int16_t ap_exit(NOTHING)
{
	mn_clsda();
	if (rlr->p_qindex)
		ap_rdwr(AQRD, rlr->p_pid, rlr->p_qindex, (int16_t *) D.g_valstr);

	all_run();
	return TRUE;
}
#endif


#if AESVERSION >= 0x200
/*
 * Read the internal process message
 */
/* 306de: 00e19abc */
int16_t rd_mymsg(P(VOIDPTR) buffer)
PP(VOIDPTR buffer;)
{
	if (rlr->p_msgtosend)				/* there is a message   */
	{
		LBCOPY(buffer, rlr->p_message, 16);
		rlr->p_msgtosend = FALSE;		/* message is sent  */
		return TRUE;
	} else
		return FALSE;
}
#endif


/*
 * AES #11 - appl_read - Receives a message from another application. 
 * AES #12 - appl_write - Send AES message to another application. 
 *
 *	APplication READ or WRITE
 */
/* 306de: 00e19afe */
/* 104de: 00fdf958 */
/* 106de: 00e2140e */
int16_t ap_rdwr(P(int16_t) code, P(int16_t) id, P(int16_t) length, P(int16_t *) pbuff)
PP(int16_t code;)
PP(int16_t id;)
PP(int16_t length;)
PP(int16_t *pbuff;)
{
#ifdef __ALCYON__
	/* use id,len,pbuff on stack as a QPB  */ /* WTF */
	return ev_block(code, (intptr_t)ADDR(&id));
	/*
	 * BUG: should return TRUE/FALSE, not the return value from ev_block()
	 */
#else
	QPB m;
	
	m.qpb_pid = id;
	m.qpb_cnt = length;
	m.qpb_buf = pbuff;
	return ev_block(code, (intptr_t)ADDR(&m));
#endif
}



/*
 * AES #13 - appl_find - Obtain the application ID number of an AES application. 
 *
 *	APplication FIND
 */
/* 306de: 00e19b16 */
/* 104de: 00fdf96a */
/* 106de: 00e2142a */
int16_t ap_find(P(const char *) pname)
PP(const char *pname;)
{
	register PD *p;
	char temp[9];

	/* dangerous; should better have used p_nameit here */
	LSTCPY(ADDR(temp), pname);

	p = fpdnm(temp, 0x0);
	return p ? p->p_pid : -1;
}




/*
 * AES #14 - appl_tplay - Play back AES events. 
 *
 *	Application Tape Player
 */
/* 306de: 00e19b54 */
/* 104de: 00fdf998 */
/* 106de: 00e21486 */
VOID ap_tplay(P(intptr_t) pbuff, P(int16_t) length, P(int16_t) scale)
PP(register intptr_t pbuff;)
PP(int16_t length;)
PP(int16_t scale;)
{
	register int16_t i;
	FPD f;
	FPD *ad_f;

	ad_f = &f;							/* old x86 relict */
#if AESVERSION >= 0x140
	dsptch();							/* dispatch everybody   */
	gl_play = FALSE;
	gl_mx = xrat;
	gl_my = yrat;
#endif

	for (i = 0; i < length; i++)
	{
		/* get an event to play */
		LBCOPY(ad_f, (VOIDPTR)pbuff, sizeof(FPD));
		pbuff += sizeof(FPD);
		/* convert it to machine specific form */

		switch (((int16_t)(intptr_t)(f.f_code)))
		{
		case TCHNG:
			ev_timer((f.f_data * 100L) / scale);
			f.f_code = 0;
			break;
		case MCHNG:
#if TOSVERSION >= 0x104
			if (!gl_play)
			{
				/* disconnect the cursor from VDI until the playing is done */
				i_lptr1(justretf, 0x0);
#ifdef __ALCYON__
				gsx_ncode(CUR_VECX, 0L); /* sigh */
#else
				gsx_ncode(CUR_VECX, 0, 0);
#endif
				m_lptr2(&drwaddr);
				i_lptr1(justretf, 0x0);	/* not interrupt of mouse movement */
#ifdef __ALCYON__
				gsx_ncode(MOT_VECX, 0L); /* sigh */
#else
				gsx_ncode(MOT_VECX, 0, 0);
#endif
				m_lptr2(&gl_store);
			}
			f.f_code = mchange;
			gl_play = TRUE;
#else
			f.f_code = mchange;
#endif
			break;
		case BCHNG:
			f.f_code = bchange;
			break;
		case KCHNG:
			f.f_code = kchange;
			/* break; */
		}
		/* play it      */
		if (f.f_code)
			forkq(f.f_code, f.f_data);

		/* let someone else hear it and respond */
		dsptch();
	}

#if TOSVERSION >= 0x104
	if (gl_play)						/* connect back the mouse */
	{
		i_lptr1(drwaddr);
#ifdef __ALCYON__
		gsx_ncode(CUR_VECX, 0L); /* sigh */
		i_lptr1(gl_store, 0x0);
		gsx_ncode(MOT_VECX, 0L); /* sigh */
#else
		gsx_ncode(CUR_VECX, 0, 0);
		i_lptr1(gl_store, 0x0);
		gsx_ncode(MOT_VECX, 0, 0);
#endif

		gl_play = FALSE;
	}
#endif
}


/*
 * AES #15 - appl_trecord - Record AES events. 
 *
 *	APplication Tape RECorDer
 */
/* 306de: 00e19cf0 */
/* 104de: 00fdfaee */
/* 106de: 00e21604 */
int16_t ap_trecd(P(intptr_t) pbuff, P(int16_t) length)
PP(register intptr_t pbuff;)
PP(register int16_t length;)
{
	register int16_t i;
#if OS_COUNTRY == CTRY_US
	/* US version had even more buggy code */
	register short code;
#define CCAST
#else
	register intptr_t code;
#define CCAST (intptr_t) /* in newer version they thought it could be fixed by a cast ROFL */
#endif

	/* start recording in forker()       */
	cli();
	gl_recd = TRUE;
	gl_rlen = length;
	gl_rbuf = pbuff;
	sti();
	/* 1/10 of a second sample rate */
	while (gl_recd)
		ev_timer(100L);
	/* done recording so figure out length  */
	cli();
	gl_recd = FALSE;
#if AESVERSION >= 0x200
	length = length - gl_rlen;			/* Fixed 4/5/90     */
#endif
	gl_rlen = 0;
#if AESVERSION < 0x200
	length = ((int16_t)(gl_rbuf - pbuff)) / sizeof(FPD);
#endif
	gl_rbuf = 0;
	sti();
	/* convert to machine independent recording */
	for (i = 0; i < length; i++)
	{
		code = LWGET(pbuff); /* BUG: comparing only word */
		if (code == CCAST tchange)
		{
			code = TCHNG;				/*    int16_t is changed to int32_t   */
#if AESVERSION < 0x140
			LLSET(pbuff+sizeof(int32_t *), LLGET(pbuff+sizeof(int32_t *)) * gl_ticktime);
#endif
		}
		if (code == CCAST mchange)
			code = MCHNG;
		if (code == CCAST kchange)
			code = KCHNG;
		if (code == CCAST bchange)
			code = BCHNG;
		LWSET(pbuff, code); /* BUG: see above */
		pbuff += sizeof(FPD);
	}
	return length;
}
