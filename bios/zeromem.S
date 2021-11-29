/*
 *
 *  Quickly zero (lots of) memory.
 *  Copyright 1986 Atari Corp.
 *
 *  Synopsis:	zeromem(start, end)
 *		    LONG start;	    4(sp) -> first location
 *		    LONG end;	    8(sp) -> last location + 1
 *
 *    Uses:	C registers d0-d2/a0-a2
 *
 */
/* 306de: 00e01680 */
/* 206de: 00e01548 */
/* 104de: 00fc1ee0 */
		xdef _zeromem
_zeromem:
        movea.l   4(a7),a0	/* a0 -> start */
        movea.l   8(a7),a1	/* a1 -> end+1 */
        movem.l   d3-d7/a3,-(a7)	/* save registers */
        moveq.l   #0,d1		/* store zero into d1-d7/a3 */
        moveq.l   #0,d2
        moveq.l   #0,d3
        moveq.l   #0,d4
        moveq.l   #0,d5
        moveq.l   #0,d6
        moveq.l   #0,d7
        movea.w   d7,a3
        move.l    a0,d0		/* word align first location */
        btst      #0,d0
        beq.s     zerom1
        move.b    d1,(a0)+
zerom1:
        move.l    a1,d0		/* d0 = ((a1 - a0) & ~0xff) */
        sub.l     a0,d0
        and.l     #$FFFFFF00,d0	/* mask fract bits, d0 = whole part */
        beq.s     zerom3		/* if (d0 == 0) do end-fraction; */
        lea.l     0(a0,d0.l),a0	/* a0 -> end of huge area */
        movea.l   a0,a2		/* a2 -> there, too */
        lsr.l     #8,d0		/* get 256-byte chunk count */
zerom2:
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        movem.l   d1-d7/a3,-(a2)	/* clear 32 bytes */
        subq.l    #1,d0			/* decrement count */
        bne.s     zerom2		/* while (d0) clear some more... */
zerom3:
        cmpa.l    a0,a1			/* while (a0 != a1) */
        beq.s     zerom4		/* (done) */
        move.b    d1,(a0)+		/* clear a byte */
        bra.s     zerom3
zerom4:
        movem.l   (a7)+,d3-d7/a3		/* restore registers */
        rts
