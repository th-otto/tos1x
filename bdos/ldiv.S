#include "config.h"

#ifndef __GNUC__
	xref _ldivr
	comm _ldivr,4
	globl bdosldiv
	text
bdosldiv:
	link a6,#-2
	movem.l d2-d7,-(sp)
	clr d3
	clr.l d5
	move.l 8(a6),d7
	move.l 12(a6),d6
	bne L2
	move.l #$80000000,_ldivr
	move.l #$80000000,d0
	divs.w #$0000,d0
	bra.s L1
L2:
	bge L3
	neg.l d6
	add #1,d3
L3:
	tst.l d7
	bge L4
	neg.l d7
	add #1,d3
L4:
	cmp.l d7,d6
	bgt L6
	bne L7
	move.l #1,d5
	clr.l d7
	bra L6
L7:
	cmp.l #$10000,d7
	bge L9
	divu d6,d7
	move d7,d5
	swap d7
	ext.l d7
	bra L6
L9:
	move.l #1,d4
L12:
	cmp.l d6,d7
	blo L11
	asl.l #1,d6
	asl.l #1,d4
	bra L12
L11:
	tst.l d4
	beq L6
	cmp.l d6,d7
	blo L15
	or.l d4,d5
	sub.l d6,d7
L15:
	lsr.l #1,d4
	lsr.l #1,d6
	bra L11
L6:
	cmp #1,d3
	bne L16
	neg.l d7
	move.l d7,_ldivr
	move.l d5,d0
	neg.l d0
	bra L1
L16:
	move.l d7,_ldivr
	move.l d5,d0
L1:
#if (TOSVERSION >= 0x200) | !BINEXACT
	addq.l    #4,a7
#else
	tst.l     (a7)+
#endif
	movem.l (sp)+,d3-d7
	unlk a6
	rts
#endif /* __GNUC__ */
