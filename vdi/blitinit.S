*********************************  blitinit.s  ********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/02/01 15:29:25 $
* =============================================================================
*
* Revision 3.1  91/02/01  15:29:25  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:06:21  lozben
* New generation VDI
*
* Revision 2.3  90/03/01  11:33:51  lozben
* Did conditional assembly for hardblit vectors.
*
* Revision 2.2  89/04/13  19:32:37  lozben
* Got rid of conditional assembly which forced hard
* text blit, it was not needed.
*
* Revision 2.1  89/02/21  17:18:31  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "asmdefs.h"
#include "tosvars.inc"

#include "lineaequ.inc"


*******************************************************************************
*									      *
*	Set the BLASTER primitive vector list then call initialize routine.   *
*									      *
* in:		d0	blit mode word				              *
*									      *
*		bit0	0:soft			1:hard			      *
*		bit1	0:no hardware assist    1:hardware assist	      *
*									      *
*		other bits currently undefined				      *
*									      *
*******************************************************************************

/* 306de: 00e07f20 */
/* 206de: 00e073ac */
/* 104de: 00fcb604 */
		xdef _SETBLT
_SETBLT:
        move.w    d0,PIXLV(BLT_MODE,a1)
        movea.l   PIXLV(LA_SOFTROUTINES,a1),a0
        btst      #0,d0
        beq.s     setblt0
        movea.l   PIXLV(LA_HARDROUTINES,a1),a0
setblt0:
        lea.l     PIXLV(LA_ROUTINES,a1),a1
        moveq.l   #10-1,d0
rCopyLoop:
        move.l    (a0)+,(a1)+
        dbf       d0,rCopyLoop
		rts


*******************************************************************************
*									      *
*	Get the current BiT BLiT mode					      *
*									      *
* out:	d0	bit blit mode word					      *
*									      *
*******************************************************************************

/* 306de: 00e07f48 */
/* 206de: 00e073d4 */
/* 104de: 00fcb62c */
		xdef _GETBLT
_GETBLT:
        move.w    PIXLV(BLT_MODE,a0),d0
		rts
