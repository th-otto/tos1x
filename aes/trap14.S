/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:31:22 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:31:22  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:32:36  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.6  89/02/12  01:05:14  kbad
 * Added zeropage references in _mediach, to save a few bytes from as68 idiocy
 * 
 * Revision 1.5  89/01/24  07:21:02  kbad
 * Optimize get/putmouse, and make maddr available as a flag. (clear on exit
 * from _putmouse
 * 
 * Revision 1.4  88/07/27  10:32:47  mui
 * fix mediach
 * 
 * Revision 1.3  88/07/01  16:25:55  mui
 * Nothing
 * 
 * Revision 1.2  88/07/01  16:22:56  mui
 * add mediach code
 * 
 * Revision 1.1  88/06/02  12:36:33  lozben
 * Initial revision
 * 
 *************************************************************************
 *	trap14.s	02/28/85 - 05/21/85		Derek Mui	
 *	combine trap14 trap13 with trp14 and trp13	3/4/86	D.Mui
 *	Added save mouse form function	1/6/87	- 1/7/87Derek Mui
 *	Take out s68	2/9/88				D.Mui
 *	Rename maddr to _maddr		6/25/90		D.Mui
 *	Use MAC to assemble		6/28/90		D.Mui
 * assemble with MAS 900801 kbad (removed zeropage a0 from mediach)
 *	Fix mediach at dooldr 		12/11/90	D.Mui
 *	Fix at mediach at remove extra slash at the beginning 4/5/91 D.Mui
 */

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"
#include "tosvars.inc"

	bss
	even
	
	xdef trp13aret
	comm trp13aret,4
	xdef trp14aret
	comm trp14aret,4

#if OLD_SFCODE | (OS_COUNTRY != CTRY_FR)
/*
 * entry points only used by older code from showfile()
 */
	bss

	xdef xbiosaret
	comm xbiosaret,4
	xdef biosaret
	comm biosaret,4

	text

/* 100us: 00fee782 */
	xdef _xbios
_xbios: ds.b 0
	move.l	(sp)+,xbiosaret
	trap	#14
	move.l  d0,-(a7)
	move.l  #0,-(a7)
	move.w  #2,-(a7) /* HOURGLASS */
	/* jsr     _graf_mouse */
	dc.w    $4eb9 /* not replaced by LineF opcode */
	dc.l    _graf_mouse
	addq.w  #6,a7
	move.l  (a7)+,d0
	move.l	xbiosaret,-(sp)
	rts

/* 100us: fee7a8 */
	xdef _bios
_bios: ds.b 0
	move.l	(sp)+,biosaret
	trap	#13
	move.l  d0,-(a7)
	move.l  #0,-(a7)
	move.w  #2,-(a7) /* HOURGLASS */
	/* jsr     _graf_mouse */
	dc.w    $4eb9 /* not replaced by LineF opcode */
	dc.l    _graf_mouse
	addq.w  #6,a7
	move.l  (a7)+,d0
	move.l	biosaret,-(sp)
	rts

#endif

	text

/* void fc_swp68(uint16_t *val); */
/* same as swp68() in bdos */
/* 100fr: 00fee76a */
	xdef _fc_swp68
_fc_swp68:
	link       a6,#0
	movea.l    8(a6),a0
	move.w     (a0),d0
	ror.w      #8,d0
	move.w     d0,(a0)
	unlk       a6
	rts

/*
 * entry points used both by AES & DESKTOP
 */
/* 404: 00e3576c */
/* 104de: 00fe7582 */
/* 106de: 00e29e74 */
#if !(OLD_SFCODE | (OS_COUNTRY != CTRY_FR))
	xdef _bios
_bios: ds.b 0
#endif
	xdef _trp13
_trp13: ds.b 0
	move.l	(sp)+,trp13aret
	trap	#13
	move.l	trp13aret,-(sp)
	rts


#if !(OLD_SFCODE | (OS_COUNTRY != CTRY_FR))
	xdef _xbios
_xbios: ds.b 0
#endif
	xdef _trp14
_trp14: ds.b 0
	move.l	(sp)+,trp14aret
	trap	#14
	move.l	trp14aret,-(sp)
	rts
