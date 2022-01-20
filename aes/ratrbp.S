/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:30:21 $
 * =======================================================================
 *
 * Revision 2.3  89/04/26  18:30:21  mui
 * TT
 *
 * Revision 2.2  89/04/06  17:57:38  kbad
 * added absolute tick timer "TICKS" and _delay call to use it.
 *
 * Revision 2.1  89/02/22  05:32:12  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.4  88/12/05  16:51:00  mui
 * Change at tikcod to check if the timer event is being recorded in the forkq
 *
 * Revision 1.3  88/10/30  00:29:17  kbad
 * Got rid of a weird line comment error.  Sheesh.
 *
 * Revision 1.2  88/10/26  19:25:11  kbad
 * Saved a few bytes on rts's from drawrat,tikcod
 *
 * Revision 1.1  87/11/20  14:18:21  lozben
 * Initial revision
 *
 *************************************************************************
 *	RATRBP.S	11/06/84 - 03/27/85		Lowell Webster
 *	Use MAC to assemble	6/28/90			Derek Mui
 * assemble with MAS 900801 kbad
 *
 *	interface for rats to gsx on 68	K
 */

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

	text

/*
 *
 *	far_bchange
 *
 *	  called far with d0 = button state
 *	  interrupts should be off and in supervisor mode
 *	  calls b_click in geminput.c
 */
/* 206de: 00e2271c */
/* 306de: 00e26182 */
/* 104de: 00fe639c */
/* 106de: 00e28ace */
	xdef	_far_bchange
_far_bchange:
	move.l	a7,gstksave		; save stack, paranoid code
	lea.l	gstack+23*4,a7
	movem.l	d0-d2/a0-a2,-(sp)	; save regs that c will crunch

#if 0
	move.w	d0,-(sp)		; pass button state, only if tick in gsx
	jsr	_b_click

/*
 * b_click( state )
 * state in D0
 */
#endif

_b_click:
#if AESVERSION >= 0x330
	move.w	d0,_gl_button
#endif
	cmp.w	_gl_btrue,d0		; if state != gl_btrue
	beq	bout1			; no change and exit
	tst.w	_gl_bdelay		; do we have to wait
	beq	bout2
	cmp.w	_gl_bdesired,d0		; state == gl_bdesired
	bne	bout3
	addq.w	#1,_gl_bclick		; gl_bclick++
	addq.w	#3,_gl_bdelay		; gl_bdelay += 3
	bra	bout3

bout2:
#if !TP_48 /* ARROWFIX */
	tst.w	_gl_bpend		; if ( gl_bpend && state )
	beq	bout4
#endif
	tst.w	d0
	beq	bout4
	move.w	#1,_gl_bclick		; gl_bclick = 1
	move.w	d0,_gl_bdesired		; gl_bdesired = state
	move.w	_gl_dclick,_gl_bdelay	;
	bra	bout3

bout4:
	move.w	d0,-(sp)		; save the d0
	move.w	#1,-(sp)
	move.w	d0,-(sp)
	pea	_bchange
	jsr	forkq
	add.l	#8,sp
	move.w	(sp)+,d0		; restore d0

bout3:
	move.w	d0,_gl_btrue		; gl_btrue = state

bout1:
	movem.l (sp)+,d0-d2/a0-a2
	movea.l	gstksave,a7
	rts

/*
 *
 *	far_mchange
 *
 *	  called far with interrupts off
 *	  d0 = xposition, d1 = yposition in absolute pixels
 */
/* 306de: 00e26208 */
/* 104de: 00fe6422 */
/* 106de: 00e28b54 */
	xdef	_far_mchange
_far_mchange:
	move.l	a7,gstksave		; save stack
	lea.l 	gstack+23*4,a7
	movem.l d0-d2/a0-a2,-(sp)	; save regs that C will crunch

	move.w	d1,-(sp)		; delta y
	move.w	d0,-(sp)		; delta x
	move.l	#_mchange,-(sp)
	jsr	forkq			; call forkq
	addq.l	#8,sp

	movem.l (sp)+,d0-d2/a0-a2
	move.l	gstksave,a7
	rts

/*
 *
 *	drawrat
 *
 *	  call gsx with absolute x and y to draw cursor
 */
	xdef	_drawrat
_drawrat:
	move.w	4(a7),d0		; xrat
	move.w	6(a7),d1		; yrat
	move.l	_drwaddr,-(sp)
	rts

	xdef	_justretf
_justretf:
	rts


/*
 *	do tick
 *	called far with interrupts disabled
 *	 do not need to save registers
 */
/* 306de: 00e26248 */
/* 104de: 00fe6462 */
	xdef	_tikcod
_tikcod:
	move.l	a7,tstksave		; save stack
	lea.l 	tstack+23*4,a7
	addq.l	#1,_TICKS		; bump up the absolute clock
	tst.l	_CMP_TICK		; are we timing now?
	beq	tpollmb			; nope, go away
	addq.l	#1,_NUM_TICK		; yes, we're timing
	subq.l	#1,_CMP_TICK
	bne	tpollmb

/*
 * we need to establish a forkq that will
 * pick us up
 */
	move.l	_NUM_TICK,-(a7)
	move.l	#_tchange,-(a7)
	jsr	forkq
	addq.l	#8,a7
	tst.w	d0		; event recorded ?
	bne	tpollmb		; Yes
	addq.l	#1,_CMP_TICK	; No, so reset the counter

tpollmb:
	move.w	#1,-(a7)
	bsr	b_delay
	addq.l	#2,a7
/*
 * --- Interrupt processed, restore everything and return -----
 */
	move.l	tstksave,a7
/*
 * --- Chain to next guy who wants to get ticked -----
 */
	move.l	_tiksav,-(a7)		; Go through some other vector.
	rts



/*	b_delay( amnt ) */
/* 306de: 00e262a4 */
/* 104de: 00fe64be */
	xdef	_b_delay
_b_delay:
b_delay:
	move.w	4(sp),d0		; get the amnt
	tst.w	_gl_bdelay
	beq	bdout1

	sub.w	d0,_gl_bdelay		; gl_bdelay -= amnt
	bne	bdout1
	move.w	_gl_bclick,-(sp)
	move.w	_gl_bdesired,-(sp)
	pea	_bchange
	jsr	forkq
	add.l	#8,sp
	move.w	_gl_btrue,d0
	cmp.w	_gl_bdesired,d0
	beq	bdout1
	move.w	#1,-(sp)
	move.w	_gl_btrue,-(sp)
	pea	_bchange
	jsr	forkq
	add.l	#8,sp

bdout1:
	rts

/*
 *	delay( ticks )
 *	ULONG ticks;
 * Busy-wait the specified number of system timer ticks, then return.
 * No dispatching here!
 */
/* 206de: 00e22894 */
/* 306de: 00e262fa */
/* 104de: 00fe6514 */
/* 106de: 00e28c46 */
	xdef	_delay
_delay:
#if TP_48 /* ARROWFIX */
/*
 * Only place where this functions was used is in hctl_window().
 * The ARROWFIX removes that code.
 * In the original patch, this routine was overwritten
 * with the code to handle the extended modes of ev_dclick().
 */
#else
	move.l	4(sp),d0
	beq.b	xdelay
	add.l	_TICKS,d0
delay:
	cmp.l	_TICKS,d0		; updated by system timer interrupt
	bcc.b	delay			; busy-wait...
xdelay:
	rts
#endif


	bss
	even

/* addr in gsx in rat draw routine */

	xdef _drwaddr
	comm _drwaddr,4		; initialized to _justretf
	xdef _tikaddr
	comm _tikaddr,4		; initialized to _tikcod
	xdef gstksave
	comm gstksave,4
	xdef tstksave
	comm tstksave,4
	xdef _tiksav
	comm _tiksav,4		; addr in gsx driver of tick service
	xdef _NUM_TICK
	comm _NUM_TICK,4
	xdef _CMP_TICK
	comm _CMP_TICK,4
	xdef _TICKS
	comm _TICKS,4		; absolute number of ticks NOT GLOBAL!

	xdef gstack
	comm gstack,96		; gsx stack for mouse

	xdef tstack
	comm tstack,96		; tick stack
