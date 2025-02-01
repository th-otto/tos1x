/***************************    JDISPA.S    ******************************
 *
 * =======================================================================
 * $Author: mui $ 	$Date: 89/04/26 18:28:27 $
 * =======================================================================
 *
 * Revision 2.3  89/04/26  18:28:27  mui
 * TT - also fixed a typo in comments before _switchto
 *
 * Revision 2.2  89/04/19  14:43:14  kbad
 * 680x0 support, pseudo-TAS excised, changed interface to _disp, and
 * now CPU type is checked before kludgeing up an exception stack frame.
 *
 * Revision 2.1  89/02/22  05:30:35  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.3  88/10/12  13:58:24  mui
 * added comments
 *
 * Revision 1.2  88/09/21  14:29:05  mui
 * Add comment
 *
 * Revision 1.1  88/06/02  12:35:40  lozben
 * Initial revision
 *
 *************************************************************************
 *	DISPA.S		late 83			Jason Loveman
 *	for crystal	9/15/84 - 12/27/84	Lowell Webster
 * 	for gemdos	1/31/85 - 05/22/85
 *	Clean up	02/03/88		D.Mui
 *	Use MAC to assemble	6/28/90		D.Mui
 * assemble with MAS 900801 kbad
 */
#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"


/*****************************************************************
 * BSS for this module                                           *
 *****************************************************************/
	bss
	even

/* for savestate */
#if TOSVERSION >= 0x106
	xdef savea0
	comm savea0,4
#endif
/* _cli and _sti */
	xdef srsave
	comm srsave,2
	xdef savsr
	comm savsr,2
/* for psetup */
	xdef psetsr
	comm psetsr,2
	xdef dspstk
	comm dspstk,161*4

	text

longframe	equ $59e			; BIOS system variable...


/*****************************************************************
 * Utility routines						 *
 *****************************************************************/

#if TOSVERSION <= 0x104
/*****************************************************************
 *                                                               *
 * _dsptch, called from lots of places to do context switching.  *
 * We want to return to super from switchto (see below) by using *
 * an rte.  Return is already on stack, just push current sr...  *
 * OR fix stack frame then push the sr if CPU uses long frames.  *
 *                                                               *
 *****************************************************************/
/* 104de: 00fdce42 */
/* 100de: 00fe2bf2 */
	xdef	_dsptch
_dsptch: ds.b 0
	xdef	dsptch
dsptch: ds.b 0
	tst.b	_indisp			; be atomic
	beq.b	dsp1			; if clear, enter with _indisp set
	rts				; else just forget the whole thing

dsp1:
dsp2:
	move	sr,-(sp)		; and finish the stack frame with sr
	move.l	a0,-(a7)
	jmp		_disp
#endif

/*
 * disable interrupts and save state
 */
/* 306de: 00e2588a */
/* 104de: 00fdce56 */
/* 106de: 00e1e436 */
/* 100de: 00fe2c06 */
	xdef	_cli
_cli: ds.b 0
	xdef	cli
cli: ds.b 0
	move	sr,savsr		; save it
	ori	#$700,sr
	rts

/*
 * enable interrupts and restore state
 */
/* 306de: 00e25896 */
/* 104de: 00fdce62 */
/* 106de: 00e1e442 */
/* 100de: 00fe2c12 */
	xdef	_sti
_sti: ds.b 0
	xdef	sti
sti: ds.b 0
	move	savsr,sr
	rts

/*
 * "hard" disable interrupts, no save
 */
/* 306de: 00e2589e */
/* 104de: 00fdce6a */
/* 106de: 00e1e44a */
/* 100de: 00fe2c1a */
	xdef	_hcli
_hcli:
	ori	#$700,sr
	rts

/*
 * "hard" enable interrupts
 */
/* 306de: 00e258a4 */
/* 104de: 00fdce70 */
/* 106de: 00e1e450 */
/* 100de: 00fe2c20 */
	xdef	_hsti
_hsti:
	andi	#$f8ff,sr
	rts




/*****************************************************************
 *                                                               *
 * _dsptch, called from lots of places to do context switching.  *
 * We want to return to super from switchto (see below) by using *
 * an rte.  Return is already on stack, just push current sr...  *
 * OR fix stack frame then push the sr if CPU uses long frames.  *
 *                                                               *
 *****************************************************************/
#if TOSVERSION >= 0x106
/* 306de: 00e258aa */
/* 106de: 00e1e456 */
	xdef	_dsptch
_dsptch: ds.b 0
	xdef	dsptch
dsptch: ds.b 0
	tas	_indisp			; be atomic
	beq.b	dsp1			; if clear, enter with _indisp set
	rts				; else just forget the whole thing

dsp1: ds.b 0
#if BINEXACT
	tst.w	(longframe).l		; check what mode what are in
#else
	tst.w	(longframe).w		; check what mode what are in
#endif
	beq.b	dsp2			; 68000 mode !

	subq	#2,sp			; bump up the stack pointer
	move.l	2(sp),(sp)		; move up the return address
	clr	4(sp)			; fake a stack frame format word

dsp2:	move	sr,-(sp)		; and finish the stack frame with sr

/*
 * Now save the context of the machine
 */
	xdef	_savestate
_savestate:
	move	sr,srsave		; save interrupts
	ori	#$700,sr		; turn them off

	move.l	a0,savea0

	move.l	_rlr,a0			; Get the current PD
	move.l	8(a0),a0		; Get the UDA from PD

	lea	66(a0),a0		; Save the USP
	movem.l	d0-d7/a0-a7,-(a0)	; save everything

	move.l	usp,a1
	move.l	a1,64(a0)		/* save USP to u_spuser */
	move.l	savea0,32(a0)

	lea	dspstk+160*4,sp		; Load a dispatcher stack
	move	srsave,sr		; Restore interrupts
	jsr	_disp			; Go to the Sub dispatcher

/*
 * ================================================================
 * gemdisp.c:disp() determines who to run next, makes him rlr,
 * then comes back to us to do the actual context switch
 * ================================================================
 */

#if 0
	For reference purposes
	UDA
	{
		WORD	u_insuper;		/* in supervisor flag	*/
		ULONG	u_regs[15];		/* d0-d7,a0-a6		*/
		ULONG	*u_spsuper;		/* supervisor stack	*/
		ULONG	*u_spuser;		/* user stack		*/
		ULONG	u_super[STACK_SIZE];
		ULONG	u_supstk;
	};
#endif




/* 306de: 00e25908 */
	xdef	_switchto
_switchto:
	move	sr,srsave
	ori	#$700,sr		; no interrupts while on bogus stack!

	move.l	_rlr,sp
	move.l	8(sp),sp		; Get the UDA
	lea	2(sp),sp			; Points the D0 area
	move.l	64(sp),a0		; Get the USP from u_spuser
	move.l	a0,usp
	movem.l	(sp)+,d0-d7/a0-a6	; Pull regs from uda
	move.l	(sp),sp				/* restore sp from u_spsuper */
	clr.b	_indisp				; Can enter dispatcher now
	rte

#endif



/*****************************************************************
 * _gotopgm:                                                     *
 *       Run an accessory and not giving him the basepage        *
 *****************************************************************/
/* 306de: 00e25934 */
/* 104de: 00fdce76 */
/* 106de: 00e1e4e2 */
/* 100de: 00fe2c26 */
	xdef	_gotopgm
_gotopgm:
	move	sr,savsr		; save sr
	ori	#$700,SR		; turn interrupts off
	movea.l	_rlr,a0			; get pd
	move.l	24(a0),a0		; pd->ldaddr is base page of program
#if TOSVERSION >= 0x106
#if BINEXACT
	tst.w	(longframe).l		; if not on longframe CPU
#else
	tst.w	(longframe).w		; if not on longframe CPU
#endif
	beq.b	g_1			; do not need a format word
	clr	-(sp)			; otherwise fake a format word
g_1:
#endif
	move.l	8(a0),-(sp)		; get beg of text on our sp
	move	savsr,-(sp)		; get current irqs.
	eor	#$2000,(sp)		; run him in user mode (SR = 0, IPL0)
	rte




/*
 * Now save the context of the machine
 */
#if TOSVERSION <= 0x104
/* 100de: 00fe2c4a */
	xdef	_savestate
_savestate:
	move	sr,srsave		; save interrupts
	ori	#$700,sr		; turn them off

	tst.b      _indisp
	beq.s      savest1
	unlk       a6
	movea.l    (a7)+,a0
	rte
savest1:

	link       a6,#0
	addq.b     #1,_indisp

	movea.l    8(a6),a6		; Get the UDA from PD

	lea        58(a6),a6
	movem.l    d0-d7/a0-a5,-(a6)	; save almost everything
	movea.l    (a7),a5
	move.l     (a5),56(a6)      ; save A6
	move.l     4(a5),32(a6)     ; save A0
	lea.l      8(a5),a5
	move.l     a5,60(a6)        ; save SSP to u_spsuper

	move.l     usp,a5
	move.l     a5,64(a6)		/* save USP to u_spuser */

	movea.l    a7,a6
	unlk       a6
	movea.l    (a7),a0

	lea	dspstk+160*4,sp		; Load a dispatcher stack
	move	srsave,sr		; Restore interrupts
	jmp (a0)			; Go to the Sub dispatcher


/* 306de: 00e25908 */
/* 104de: 00fdcef6 */
/* 100de: 00fe2ca6 */
	xdef	_switchto
_switchto:
	move	sr,srsave
	ori     #$700,sr		; no interrupts while on bogus stack!
	addq.l  #4,a7
	move.l	(a7),sp			; get the UDA
	addq.l  #2,a7			; Points the D0 area
	movem.l	(sp)+,d0-d7/a0-a5	; Pull regs from uda
	move.l	8(sp),a6		; Get the USP from u_spuser
	move.l	a6,usp
	move.l  (a7)+,a6        ; Pull a6 from uda
	move.l	(sp),sp			; restore sp from u_spsuper
	clr.b	_indisp			; Can enter dispatcher now
	move.w  srsave,(a7)
	rte

#if TOSVERSION < 0x104
/* unused */
	movea.l    4(a7),a0
	bset       #7,(a0)
	beq.s      sw1
	move.w     #$00FF,d0
	rts
sw1:
	clr.w      d0
	rts

	/* 100de: 00fe2ce2 */
	xdef _setdsss
_setdsss:
	movea.l    4(a7),a1
	move.w     #1,(a1)
	rts

#endif

#endif


/*****************************************************************
 *               VOID                                            *
 *       psetup(p, codevalue)                                    *
 *               PD              *p;                             *
 *               CODE            *codevalue;                     *
 *                                                               *
 *       Set up a process' stack frame in preparation            *
 *       for an RTE that will start this process executing.      *
 *****************************************************************/
/* 104de: 00fdcf22 */
/* 106de: 00e1e510 */
/* 100de: 00fe2cf0 */
	xdef	_psetup
_psetup:
	move	sr,psetsr		; save interrupts
	ori	#$700,sr		; turn them off
	move.l	4(sp),a0		; *pd
	move.l	8(sp),d0		; val
	move.l	8(a0),a1		; a1 = pd->uda
	move.l	62(a1),a2		; a2 = uda->SUPSTK
#if TOSVERSION >= 0x106
#if BINEXACT
	tst.w	(longframe).l		; if not on longframe CPU
#else
	tst.w	(longframe).w		; if it is not a longframe CPU
#endif
	beq.b	p_1			; do not need a format word
	clr	-(a2)			; otherwise, fake a format word
p_1:
#endif
	move.l	d0,-(a2)		; predecrement and store val on stack
	move.w	#$2000,-(a2)		; predecrement and store status word
	move.l	a2,62(a1)		; restore stack ptr
	move	psetsr,sr		; restore interrupts
	rts
