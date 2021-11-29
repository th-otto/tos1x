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

fail_ret:
#if TOSVERSION < 0x400
		movea.l   (a7)+,a5
#endif
		moveq	#0,d0		; exit if not byte bnd or clip required
		rts			; 0 indicates failure

*  Entry point here..
/* 306de: 00e0c050 */
/* 206de: 00e0c2e2 */
/* 104de: 00fd0542 */
	xdef	_MONO8XHT
_MONO8XHT:
#if TOSVERSION < 0x400
		move.l    a5,-(a7)
	    lea lineavars+DESTX,a5
		move.w	(a5)+,d0		; d0 <- dst X
		move.w	d0,d2			; d2 <- dst X
		and.w	#$0007,d2		; this routine is only for
		bne	fail_ret		; byte alligned characters

on_bounds:
		move.w	(a5),d1		; d1 <- dst Y
		move.w	(DELY)-DESTY(a5),d3		; d3 <- dY

		move.l	(CONTRL)-DESTY(a5),a0		; a0 -> CONTRL array
		move.w	  6(a0),d2		; d2 <- # chars in string

		lea (CLIP)-DESTY(a5),a5
		tst.w	(a5)+
		beq	no_clip			; skip clip test if disabled

		move.w	(a5)+,d5	;8	d5 <- Xmin clip
		move.w	(a5)+,d6	;8	d6 <- Ymin clip
		move.w	(a5)+,d7	;8	d7 <- Xmax clip

		cmp.w	d6,d1			/* str can't extend above Ymin */
		blt	fail_ret		;

		move.w	d1,d4			;4	d4 <- dst Y
		add.w	d3,d4			;4	d4 <- bottom Y +1
		cmp.w	(a5),d4	/* str can't descend below Ymax */
		bge	fail_ret		;8/10

		cmp.w	d5,d0			/* str can't extend left of Xmin */
		blt	fail_ret		;8/10

		move.w	d2,d4			; d4 <- number of characters
		lsl.w	#3,d4			; d4 <- width of str in pixels
		add.w	d0,d4			; d4 <- rightmost X +1
		cmp.w	d7,d4			/* str can't extend right of Xmax */
		bge	fail_ret		;8/10

*  no clipping to worry about
*
*   d0.w = DESTX
*   d1.w = DESTY
*   d2.w = # of characters
*   d3.w = DELY

no_clip:
		lea.l	lineavars+FBASE,a5	; a5 -> font form
		move.l	(USERDEVINIT)+(V_MONO)-FBASE(a5),a4		; a4 -> version of mono
		jmp	(a4)

#else

	    PIXLA(a1)
		move.w	PIXLV(DESTX,a1),d0		; d0 <- dst X
		move.w	d0,d2			; d2 <- dst X
		and.w	#$0007,d2		; this routine is only for
		bne	fail_ret		; byte alligned characters

on_bounds:
		move.w	PIXLV(DESTY,a1),d1		; d1 <- dst Y
		move.w	PIXLV(DELY,a1),d3		; d3 <- dY

		move.l	PIXLV(CONTRL,a1),a0		; a0 -> CONTRL array
		move.w	  6(a0),d2		; d2 <- # chars in string

		tst.w	PIXLV(CLIP,a1)
		beq	no_clip			; skip clip test if disabled

		move.w	PIXLV(XMN_CLIP,a1),d5	;8	d5 <- Xmin clip
		move.w	PIXLV(YMN_CLIP,a1),d6	;8	d6 <- Ymin clip
		move.w	PIXLV(XMX_CLIP,a1),d7	;8	d7 <- Xmax clip

		cmp.w	d6,d1			/* str can't extend above Ymin */
		blt	fail_ret		;

		move.w	d1,d4			;4	d4 <- dst Y
		add.w	d3,d4			;4	d4 <- bottom Y +1
		cmp.w	PIXLV(YMX_CLIP,a1),d4	/* str can't descend below Ymax */
		bge	fail_ret		;8/10

		cmp.w	d5,d0			/* str can't extend left of Xmin */
		blt	fail_ret		;8/10

		move.w	d2,d4			; d4 <- number of characters
		lsl.w	#3,d4			; d4 <- width of str in pixels
		add.w	d0,d4			; d4 <- rightmost X +1
		cmp.w	d7,d4			/* str can't extend right of Xmax */
		bge	fail_ret		;8/10

*  no clipping to worry about
*
*   d0.w = DESTX
*   d1.w = DESTY
*   d2.w = # of characters
*   d3.w = DELY

no_clip:
		move.l	LA_ROUTINES(a1),a0	; a1 -> routines vector list
		move.l	V_MONO(a0),a0		; a1 -> version of mono
		jmp	(a0)

#endif


