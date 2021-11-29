#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

/*
 * The LineF handler is used to save code in the 192k ROM version.
 * It is used in two ways:
 * - if the opcode has bit #0 set, the remainder of the opcode
 *   is a register mask for a movem instruction from the epilogue
 * - otherwise, it is an offset to the jmp table for functions to call
 *
 * The register mask was shifted 2 bits to the right, so it does
 * not conflict with the linef opcode itself ($Fxxx). This works,
 * because
 * - a7 can never occur in such a mask
 * - a6 is the framepointer, and also will never occur in the mask
 * - d0 (which would be indicated by bit #0) is a scratch register,
 *      and never occurs in the mask
 * - d1-d2, which are shifted out, are also scratch registers,
 *      and never occur in the mask
 */
#if LINEF_HACK

	xdef linefhandler
linefhandler:
		move.w    (a7)+,d2	/* fetch sr */
		movea.l   (a7)+,a0	/* fetch caller pc */
		move.w    (a0)+,d1	/* fetch opcode */
		btst      #0,d1
		bne.s     linefh1
		move.w    d2,sr
		move.l    a0,-(a7)
		andi.w    #$0FFF,d1
		movea.l   #lineftab,a0
		movea.l   0(a0,d1.w),a0
		jmp       (a0)
linefh1:
		andi.w    #$0FFE,d1	/* were any registers saved? */
		beq.s     linefh2	/* -> no */
		lsl.w     #2,d1		/* correct the mask */
		ori.w     #$0700,sr /* block interrupts since we might be called from the timer interrupt */
		lea.l     movinst+2(pc),a0
		move.w    d1,(a0)
		/* if any registers were saved, the epilogue would contain a tst.l (a7)+ instruction */
		addq.l    #4,a7
movinst:
		dc.w $4cdf,0		/* movem.l (a7)+,noregs */
linefh2:
		move.w    d2,sr		/* restore interrupts */
		unlk      a6		/* perform the unlk that was removed from epilogue */
		rts					/* perform the rts that was removed from epilogue */
		
		xdef lineftab
lineftab: ds.b 0

#endif
