*******************************  blastman.s  **********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/02/13 17:51:35 $
* =============================================================================
*
* Revision 3.3  91/02/13  17:51:35  lozben
* Entered line "xdef KG_BLT" at the top of the file.
*
* Revision 3.2  91/02/12  16:00:06  lozben
* Forgot to include the file "lineaequ.s".
*
* Revision 3.1  91/01/23  12:36:15  lozben
* All the linea vars are now referenced off a linea struct pointer.
*
* Revision 3.0  91/01/03  15:06:17  lozben
* New generation VDI
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
	move.l	PIXLV((USERDEVINIT)+func,la),r
#endif

#define V_CALL(func,la,r) \
		V_FUNC(func,la,r) \
		jsr (r)
#define V_JUMP(func,la,r) \
		V_FUNC(func,la,r) \
		jmp (r)


#include "sbframe.inc"

	text

/* 306de: 00e0cc46 */
/* 206de: 00e0d004 */
/* 104de: 00fd1264 */
*  in:
*	a6.l	points to 76 byte parameter block
	xdef	KG_BLT
KG_BLT:

	add.w	#FRAME_LEN,a6		; a6 -> top of frame

	move.w	S_XMIN(a6),d0		; d0 <- X min SRC
	move.w	S_YMIN(a6),d5		; d5 <- future home of Y max SRC
	move.w	D_XMIN(a6),d2		; d2 <- X min DST
	move.w	D_YMIN(a6),d7		; d7 <- future home of Y max DST
	move.w	d0,d4			; d4 <- future home of X max SRC
	move.w	d2,d6			; d6 <- future home of X max DST

	move.w	B_HT(a6),d1
	subq.w	#1,d1

	add.w	d1,d5			; d5 <- Y max source
	add.w	d1,d7			; d7 <- Y max destination

	move.w	B_WD(a6),d1
	subq.w	#1,d1

	add.w	d1,d4			; d4 <- X max source
	add.w	d1,d6			; d6 <- X max destination

	move.w	d4,S_XMAX(a6)
	move.w	d5,S_YMAX(a6)
	move.w	d6,D_XMAX(a6)
	move.w	d7,D_YMAX(a6)

    PIXLA(a5)
	V_JUMP(V_BLAST,a5,a5)		; a5 -> desired version of blast_man

#if TOSVERSION < 0x300
	dc.b 'JIM LOVES JENEANE',0
#endif
