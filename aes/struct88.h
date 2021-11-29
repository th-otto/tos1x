/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:30:56 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:30:56  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:32:26  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:36:26  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	STRUCT88.H	1/28/84 - 01/18/85	Lee Jay Lorenzen	*/
/*	for atari	03/20/85 - 5/08/85	Lowell Webster		*/
/*	Document EVB	02/19/88		D.Mui			*/
/*	More PD definitions	07/13/90	D.Mui			*/
/*	Increase number of NFORKS	8/17/92	D.Mui			*/

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.
 *                 2002-2016 The EmuTOS development team
 *
 *       This software is licenced under the GNU Public License.
 *       Please see LICENSE.TXT for further information.
 *
 *                  Historical Copyright
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#ifndef STRUCT88_H
#define STRUCT88_H

#define PD struct pd            /* process descriptor       */
#define UDA struct uda          /* user stack data area     */
#define UDA2 struct uda2		/* user stack data area		*/
#define UDA3 struct uda3		/* user stack data area		*/
#define CDA struct cdastr       /* console data area structure */
#define QPB struct qpb          /* queue parameter block    */
#define EVB struct evb          /* event block              */
#define CQUEUE struct cqueue    /* console kbd queue        */
#define MFORM struct mform      /* mouse form               */
#define SPB struct spb          /* sync parameter block     */
#define FPD struct fpd          /* fork process descriptor  */

typedef uint16_t	EVSPEC;


CQUEUE
{
	/*  0 */	int16_t	c_buff[KBD_SIZE];
	/* 16 */	int16_t	c_front;
	/* 18 */	int16_t	c_rear;
	/* 20 */	int16_t	c_cnt;
	/* 22 */
};


MFORM
{
	int16_t	mf_xhot;
	int16_t	mf_yhot;
	int16_t	mf_nplanes;
	int16_t	mf_fg;
	int16_t	mf_bg;
	int16_t	mf_mask[16];
	int16_t	mf_data[16];
};


#define C_KOWNER 0x0001
#define C_MOWNER 0x0002

CDA
{
	/*  0 */	uint16_t	c_flags;
	/*  2 */	EVB	*c_iiowait;	/* Waiting for Input		*/
	/*  6 */	EVB	*c_msleep;	/* wait for mouse rect		*/
	/* 10 */	EVB	*c_bsleep;	/* wait for button		*/
	/* 14 */	CQUEUE c_q;		/* input queue 			*/
	/* 36 */
};


#if I8086
typedef struct uda
{
	/*    0 */	int16_t		u_insuper;		/* in supervisor flag		*/ 
	/*    2 */	int16_t	   *u_spsuper;		/* supervisor stack offset	*/
	/*    4 */	uint16_t	u_sssuper;		/* supervisor stack segment	*/
	/*    6 */	int16_t	   *u_spuser;		/* user stack offset		*/
	/*    8 */	uint16_t	u_ssuser;		/* user stack segment		*/
	/*   10 */	uint16_t	u_regs[9];		/* ds,es,ax,bx,cx,dx,si,di,bp	*/
	/*   28 */	int16_t		u_super[STACK_SIZE];
	/*  924 */	int16_t		u_supstk;
	/*  926 */	
} UDA;
#endif

#if MC68K

UDA
{
	/*    0 */	int16_t		u_insuper;		/* in supervisor flag	*/ 
	/*    2 */	uint32_t	u_regs[15];		/* d0-d7, a0-a6			*/
	/*   62 */	uint32_t	*u_spsuper;		/* supervisor stack 	*/
	/*   66 */	uint32_t	*u_spuser;		/* user stack 			*/
	/*   70 */	uint32_t u_super[STACK_SIZE];
	/* 1862/2070 */	uint32_t	u_supstk;
	/* 1866/2074 */
};

UDA2
{
	int16_t		u_insuper;		/* in supervisor flag		*/ 
	uint32_t	u_regs[15];		/* d0-d7, a0-a6			*/
	uint32_t	*u_spsuper;		/* supervisor stack 		*/
	uint32_t	*u_spuser;		/* user stack 			*/
	uint32_t	u_super[STACK2_SIZE];
	uint32_t	u_supstk;
};

UDA3
{
	int16_t		u_insuper;		/* in supervisor flag		*/ 
	uint32_t	u_regs[15];		/* d0-d7, a0-a6			*/
	uint32_t	*u_spsuper;		/* supervisor stack 		*/
	uint32_t	*u_spuser;		/* user stack 			*/
	uint32_t	u_super[STACK3_SIZE];
	uint32_t	u_supstk;
};

#endif

#define NOCANCEL 0x0001		/* event is occuring 	*/
#define COMPLETE 0x0002		/* event completed 	*/
#define EVDELAY  0x0004		/* event is delay event */
#define EVMOUT   0x0008		/* event flag for mouse wait outside of rect*/

EVB		/* event block structure */
{
	/*  0 */ EVB *e_nextp;		/* link to next EVB on PD event list */
	/*  4 */ EVB *e_link;		/* link to next EVB on CDA event chain */
	/*  8 */ EVB *e_pred;		/* link to prev EVB on CDA event chain */
	/* 12 */ PD *e_pd;			/* owner PD (data for fork) */
	/* 16 */ int32_t e_parm;	/* parameter for request event */
	/* 20 */ int16_t e_flag;	/* look to above defines */
	/* 22 */ EVSPEC e_mask;		/* mask for event notification e_mask correspond to p_evbits */
	/* 24 */ int32_t e_return;	/* e_return return number of click, character or button state */
	/* 28 */
};
/* in the case of mouse rectangle, e_parm and e_return has the MBLOK */



/* pd defines */

/* p_name */
#define AP_NAMELEN  8           /* architectural */

#define		PS_RUN			1	/* p_stat */
#define		PS_MWAIT		2
#define		PS_TRYSUSPEND	4
#define		PS_TOSUSPEND	8
#define		PS_SUSPENDED	16

PD 
{
	/*  0 */	PD	*p_link;			/* link to other process	*/
	/*  4 */	PD	*p_thread;			/* I don't think it is used	*/
	/*  8 */	UDA	*p_uda;				/* store the machine's status */

	/* ^^^ variables above are accessed from assembler code */
	
	/* 12 */	char	p_name[AP_NAMELEN];		/* processor name (not NUL terminated) */

	/* 20 */	CDA	*p_cda;				/* Tells what we are waiting 	*/
	/* 24 */	intptr_t p_ldaddr;		/* long address of load		*/
	/* 28 */	int16_t p_pid;			/* process id number		*/
	/* 30 */	int16_t	p_stat;			/* PS_RUN or PS_MWAIT		*/

	/* 32 */	EVSPEC	p_evbits;		/* event bits in use 8 max EVB	*/
	/* 34 */	EVSPEC	p_evwait;		/* event wait mask 		*/
	/* 36 */	EVSPEC	p_evflg;		/* EVB that satisfied		*/
#if AESVERSION >= 0x200
	/* 38 */	BOOLEAN	p_msgtosend;
	/* 40 */	int16_t	p_message[9];
#endif
#if AESVERSION >= 0x320
	/* 58 */	MFORM	p_mouse;		/* saved mouseform for M_SAVE/M_RESTORE */
#endif
	/*58/132 */	EVB	*p_evlist;			/* link to EVB			*/
	/*62/136 */	EVB	*p_qdq;
	/*66/140 */	EVB	*p_qnq;
	/*70/144 */	char *p_qaddr;			/* message queue pointer	*/
	/*64/148 */	int16_t	p_qindex;		/* message queue index		*/
	/*76/150 */	char p_queue[QUEUE_SIZE];
	/*<320=204/320=278/>=330=406 */
};



QPB
{
	int16_t	qpb_pid;				/* owners process id */
	int16_t	qpb_cnt;
	VOIDPTR qpb_buf;
};


SPB				/* AMUTEX control block	*/
{
	/*  0 */	int16_t	sy_tas;		/* semaphore				*/
	/*  2 */	PD	*sy_owner;		/* owner's PD address			*/
	/*  6 */	EVB	*sy_wait;		/* EVB that is waiting for the screen	*/
	/* 10 */
};


/* pointer to function used by forkq() */
typedef VOID (*FCODE) PROTO((int16_t p1, int16_t p2));

FPD
{
	FCODE f_code;
	int32_t	f_data;
};


#define ACCPD struct accpd
ACCPD
{
	PD	ac_pd;
	UDA	ac_uda;
	CDA	ac_cda;
	EVB	ac_evb[EVB_PROC];	/* 5 evb's per process		*/
};


/*
 * GEM memory usage parameter block
 * (for reference, only accessed by asm code)
 */
#if 0
#define GEM_MUPB_MAGIC 0x87654321L

typedef struct
{
    int32_t gm_magic;                  /* Magical value, has to be GEM_MUPB_MAGIC */
    VOIDPTR gm_end;                    /* End of the memory required by GEM */
    VOID  (*gm_init) PROTO((NOTHING)); /* Start address of GEM */
} GEM_MUPB;
#endif

#define NOT_FOUND 100	 /* try to return from event not on PD list */
#define NOT_COMPLETE 101 /* try to ret from event which has not occured */

/* async bdos calls */
#define AQRD 1
#define AQWRT 2
#define ADELAY 3
#define AMUTEX 4
#define AKBIN 5
#define AMOUSE 6
#define ABUTTON 7

#endif /* STRUCT88_H */
