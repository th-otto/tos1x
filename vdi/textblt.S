***********************************  txtblt.s  ********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/02/12 17:03:43 $
* =============================================================================
*
* Revision 3.2  91/02/12  17:03:43  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.1  91/01/28  18:24:01  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:19:45  lozben
* New generation VDI
*
* Revision 2.3  90/03/09  12:48:01  lozben
* Made _scrtsiz 666 word to accomodate the 16x32 system font.
*
* Revision 2.2  89/04/14  15:37:19  lozben
* Moved hb_text() into another file. The idea is to have all
* the hard blit code in independent files.
*
* Revision 2.1  89/02/21  17:28:44  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"


#if MULTI_LINEA
#define V_FUNC(func,la,r) \
	move.l	LV(LA_ROUTINES,la),r \
	move.l	func(r),r
#else
#define V_FUNC(func,la,r) \
	move.l	(lineavars+USERDEVINIT)+func,r
#endif

#define V_CALL(func,la,r) \
		V_FUNC(func,la,r) \
		jsr (r)
#define V_JUMP(func,la,r) \
		V_FUNC(func,la,r) \
		jmp (r)


	xdef _scrtsiz
#if TOSVERSION >= 0x300
_scrtsiz:	dc.w	666	; WUT THE FUT ??$*&@!??
#else
_scrtsiz:	dc.w	204	; WUT THE FUT ??$*&@!??
#endif

*  entry point for textblt & scaling routine
*
	xdef	_TEXT_BLT
	xdef	_ACT_SIZ

	text

*******************************************************************************
*
*  calculate DDA
*
*  entry:
*     4(sp) = actual size
*     6(sp) = requested size
*  exit:
*     d0    = DDA_INC
*
*******************************************************************************

/* 306de: 00e0bfb4 */
/* 206de: 00e0b74a */
/* 104de: 00fcf9aa */
	xdef	_CLC_DDA
_CLC_DDA:
	PIXLA(a0)
	move.w	6(sp),d0		;d0 = requested size (dx)
	move.w	4(sp),d1		;d1 = actual size    (bx)
	cmp.w	d1,d0			;if actual =< requested
	ble	clc_smal		;  then scale down

	move.w	#1,PIXLV(T_SCLSTS,a0)	;set enlarge indicator
	sub.w	d1,d0
	cmp.w	d1,d0			;larger than 2x?
	blt	smal_ok			;br if not
clc_big:
	moveq	#-1,d0			;put $FFFF in d0 (max value, 2x)
	rts

clc_smal:
	clr.w	PIXLV(T_SCLSTS,a0)		;clear enlarge indicator (scale down)
	tst.w	d0			;check requested size
	bne	smal_ok			;br if non-zero
	moveq	#1,d0			;if 0 then make it 1 (minimum value)
smal_ok:
	swap	d0			;requested size to high word
	clr.w	d0			;clear lo word
	divu	d1,d0			;d0 = requested/actual
	rts


*******************************************************************************
*
*  Actual sizer routine
*
*  entry:
*	DDA_INC  = dda increment value
*	T_SCLSTS = scaling up or down flag (0 if down, 1 if up)
*
*    4(sp) = pixel size to be scaled
*
*  exit:
*    d0    = actual size after scaling
*	destroyed: d0.w,d1.w
*
*******************************************************************************

/* 306de: 00e0bfe6 */
/* 206de: 00e0b77c */
/* 104de: 00fcf9dc */
_ACT_SIZ:

	PIXLA(a0)
	move.w	4(sp),d1		;get last stacked word to d1 (cx)
	movem.l	d2-d3,-(sp)		; save c regs
	move.w	#32767,d2		;d2 = accumulator = 1/2      (bx)
	move.w	PIXLV(DDA_INC,a0),d3		;d3 = dda_inc		     (dx)
	cmp.w	#$FFFF,d3
	beq	siz_doub

	moveq	#0,d0			;d0 = new count
	subq.w	#1,d1			;zero adjust DELY count
	bmi	siz_0			;if it was 0, just exit

	btst.b	#0,PIXLV((T_SCLSTS)+1,a0)	;check for shrink
	beq	sz_sm_lp		;br if so

sz_lp:	add.w	d3,d2			;else, enlarge
	bcc	siz_tim1

	addq.w	#1,d0

siz_tim1:

	addq.w	#1,d0
	dbra	d1,sz_lp

siz_0:	bra	act_exit

siz_doub:

	move.w	d1,d0
	add.w	d0,d0			; d0 = size * 2
	bra	act_exit

sz_sm_lp:

	add.w	d3,d2
	bcc	sz_sm_1

	addq.w	#1,d0

sz_sm_1:

	dbra	d1,sz_sm_lp

	tst.w	d0			;if d0 = 0, then make = 1
	bne	sz_sm_2

	addq.w	#1,d0

act_exit:
sz_sm_2:

	movem.l	(sp)+,d2-d3
	rts


*****************************************
*					*
*  Text Blt code entry point here...	*
*					*
*****************************************

/* 306de: 00e0c038 */
/* 206de: 00e0b7ce */
/* 104de: 00fcfa2e */
_TEXT_BLT:
	movem.l	a5-a6,-(sp)
	LA(a6)
	V_JUMP(V_TEXT,a6,a4)
