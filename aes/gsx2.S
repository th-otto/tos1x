/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:27:45 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:27:45  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:30:14  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:25  lozben
 * Initial revision
 * 
 *************************************************************************
 *******************************************************************************
 *
 *	GSX2.S - GSX entry to GIOS and support for GSXBIND.C
 *
 * Author:
 *	Steve Cavender
 *
 * Date:
 *	1 October 1984
 *
 * Last Modified:
 *	03 Oct 84
 *	01 Nov 84 lkw
 *	19 Jan 87 jde
 *	
 *
 *******************************************************************************
 *	Use MAC to assemble			6/28/90		D.Mui
 * assemble with MAS 900801 kbad
 */
#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

	bss


	xdef pblock
	comm pblock,20
#define iioff pblock+4
#define pioff pblock+8
#define iooff pblock+12
#define pooff pblock+16

	text

/* 306de: 00e254f8 */
/* 404: 00e343a8 */
/* 104de: 00fe5bba */
/* 106de: 00e282cc */
	xdef	_gsx2
_gsx2:
	lea	pblock,a0	; a0 -> pblock
	move.l	#_contrl,(a0)	; set up control array pointer
	move.l	a0,d1		; d1 -> pblock
	moveq.l	#115,d0	; d0 <- VDI opcode
	trap	#2
	rts


/*  in:
 *	sp+04	m1
 *	sp+06	m2
 *	sp+08	d1
 */
	xdef	_mul_div
_mul_div:
	move.w	6(sp),d0	;	 m2
	add.w	d0,d0		;      2*m2
	muls	4(sp),d0	;   m1*2*m2
	divs	8(sp),d0	;  (m1*2*m2)/d1
	bmi	md_1

	addq.w	#1,d0		;  ((m1*2*m2)/d1)+1
	asr.w	#1,d0		; (((m1*2*m2)/d1)+1)/2
	rts

md_1:	subq.w	#1,d0		;  ((m1*2*m2)/d1)-1
	asr.w	#1,d0		; (((m1*2*m2)/d1)-1)/2
	rts


#if 0
	xdef	_umul_div
_umul_div:

	move.w	6(sp),d0	;         m2
	add.w	d0,d0		;       2*m2
	mulu	4(sp),d0	;    m1*2*m2
	divu	8(sp),d0	;   (m1*2*m2)/d1
	addq.w	#1,d0		;  ((m1*2*m2)/d1)+1
	asr.w	#1,d0		; (((m1*2*m2)/d1)+1)/2
	rts
#endif

	xdef	_i_ptsin
_i_ptsin: ds.b 0

	move.l	4(sp),pioff
	rts


	xdef	_i_intin
_i_intin: ds.b 0

	move.l	4(sp),iioff
	rts


	xdef	_i_ptsout
_i_ptsout: ds.b 0

	move.l	4(sp),pooff
	rts


	xdef	_i_intout
_i_intout: ds.b 0

	move.l	4(sp),iooff
	rts


	xdef	_i_lptr1
_i_lptr1: ds.b 0

	move.l	4(sp),_contrl+14
	rts


	xdef	_i_ptr2
_i_ptr2: ds.b 0

	move.l	4(sp),_contrl+18
	rts


/* 00e34414 */
	xdef	_m_lptr2
_m_lptr2: ds.b 0

	move.l	4(sp),a0
	move.l	_contrl+18,(a0)
	rts
