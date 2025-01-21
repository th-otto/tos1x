**********************************  mono.s  ***********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:12:48 $
* =============================================================================
*
* Revision 3.2  91/07/30  12:12:48  lozben
* Cleaned up the code.
*
* Revision 3.1  91/01/28  17:26:40  lozben
* Adjusted the code to work with the muultiple linea variable structure.
*
* Revision 3.0  91/01/03  15:12:36  lozben
* New generation VDI
*
* Revision 2.2  89/04/14  14:42:57  lozben
* Moved hb_mono() into another file. The idea is to have
* all the hard blit code in independent files.
*
* Revision 2.1  89/02/21  17:23:41  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

*   Mono-spaced text blt

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"

*  Mono spaced text blt...

	text

*  Entry point here..
/* 306de: 00e0c050 */
/* 206de: 00e0c2e2 */
/* 104de: 00fd0542 */
/* 106de: 00e10766 */
	xdef	_MONO8XHT
_MONO8XHT:
		move.w	LV(DESTX,a5),d0		; d0 <- dst X
		move.w	LV(DESTY,a5),d1		; d0 <- dst X
		move.w	LV(DELY,a5),d3		; d3 <- dY
		move.w	d0,d2			; d2 <- dst X
		andi.w	#$0007,d2		; this routine is only for
		beq	on_bounds		; byte alligned characters
fail_ret:
		moveq	#0,d0		; exit if not byte bnd or clip required
		rts			; 0 indicates failure

on_bounds:
		move.l	LV(CONTRL,a5),a0		; a0 -> CONTRL array
		move.w	  6(a0),d2		; d2 <- # chars in string

		tst.w	LV(CLIP,a5)
		beq	no_clip			; skip clip test if disabled

		cmp.w	LV(YMN_CLIP,a5),d1			/* str can't extend above Ymin */
		blt	fail_ret

		move.w	d1,d4			;4	d4 <- dst Y
		add.w	d3,d4			;4	d4 <- bottom Y +1
		cmp.w	LV(YMX_CLIP,a5),d4	/* str can't descend below Ymax */
		bge	fail_ret		;8/10

		cmp.w	LV(XMN_CLIP,a5),d0			/* str can't extend left of Xmin */
		blt	fail_ret
		move.w	d2,d4			; d4 <- number of characters
		lsl.w	#3,d4			; d4 <- width of str in pixels
		add.w	d0,d4			; d4 <- rightmost X +1
		cmp.w	LV(XMX_CLIP,a5),d4			/* str can't extend right of Xmax */
		bge	fail_ret
		
		
*  no clipping to worry about
*
*   d0.w = DESTX
*   d1.w = DESTY
*   d2.w = # of characters
*   d3.w = DELY

no_clip: ds.b 0

#if BLITTER_SUPPORT
		lea.l	lineavars+FBASE,a5	; a5 -> font form
		move.l	(LA_ROUTINES)+(V_MONO)-FBASE(a5),a4		; a4 -> version of mono
		jmp	(a4)
#else

#include "sbmono.S"

#endif

