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
	xdef savea0
	comm savea0,654

/* for savestate */
#define srsave savea0+4
/* _cli and _si */
#define savsr  savea0+6
/* for psetup */
#define psetsr savea0+8
#define dspstk savea0+10+160*4

	text

longframe	equ $59e			; BIOS system variable...


/*****************************************************************
 * Utility routines						 *
 *****************************************************************/

/*****************************************************************
 *                                                               *
 * _dsptch, called from lots of places to do context switching.  *
 * We want to return to super from switchto (see below) by using *
 * an rte.  Return is already on stack, just push current sr...  *
 * OR fix stack frame then push the sr if CPU uses long frames.  *
 *                                                               *
 *****************************************************************/
/* 306de: 00e258aa */
	xdef	_dsptch
_dsptch:
	tst.b	_indisp			; be atomic
	beq.b	dsp1			; if clear, enter with _indisp set
	rts				; else just forget the whole thing
 
dsp1:
dsp2:
	move	sr,-(sp)		; and finish the stack frame with sr
		move.l    a0,-(a7)
		jmp       _disp

/*
 * disable interrupts and save state
 */
/* 306de: e2588a */
	xdef	_cli
_cli:
	move	sr,savsr		; save it
	ori	#$700,sr
	rts

/*
 * enable interrupts and restore state
 */
/* 306de: 00e25896 */
	xdef	_sti
_sti:
	move	savsr,sr
	rts

/*
 * "hard" disable interrupts, no save
 */
/* 306de: 00e2589e */
	xdef	_hcli
_hcli:
	ori	#$700,sr
	rts

/*
 * "hard" enable interrupts
 */
/* 306de: 00e258a4 */
	xdef	_hsti
_hsti:
	andi	#$f8ff,sr
	rts




 
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

	lea	dspstk,sp		; Load a dispatcher stack
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
/* 104de: 00fdcef6 */
	xdef	_switchto
_switchto:
	move	sr,srsave
	ori	#$700,sr		; no interrupts while on bogus stack!
	addq.l    #4,a7
	
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

/*****************************************************************
 * _gotopgm:                                                     *
 *       Run an accessory and not giving him the basepage        *
 *****************************************************************/
/* 306de: 00e25934 */
	xdef	_gotopgm
_gotopgm:
	move	sr,savsr		; save sr
	ori	#$700,SR		; turn interrupts off
	movea.l	_rlr,a0			; get pd
	move.l	24(a0),a0		; pd->ldaddr is base page of program
	move.l	8(a0),-(sp)		; get beg of text on our sp
	move	savsr,-(sp)		; get current irq's.
	eor	#$2000,(sp)		; run him in user mode (SR = 0, IPL0)
	rte

/*****************************************************************
 *               VOID                                            *
 *       psetup(p, codevalue)                                    *
 *               PD              *p;                             *
 *               CODE            *codevalue;                     *
 *                                                               *
 *       Set up a process' stack frame in preparation            *
 *       for an RTE that will start this process executing.      *
 *****************************************************************/
	xdef	_psetup
_psetup:
	move	sr,psetsr		; save interrupts
	ori	#$700,sr		; turn them off
	move.l	4(sp),a0		; *pd
	move.l	8(sp),d0		; val
	move.l	8(a0),a1		; a1 = pd->uda
	move.l	62(a1),a2		; a2 = uda->SUPSTK
	move.l	d0,-(a2)		; predecrement and store val on stack
	move.w	#$2000,-(a2)		; predecrement and store status word
	move.l	a2,62(a1)		; restore stack ptr
	move	psetsr,sr		; restore interrupts
	rts
