/*******************************  sbescape.s  **********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/31 12:04:31 $
 * =============================================================================
 *
 * Revision 3.1  91/01/31  12:04:31  lozben
 * Adjusted the code to work with the multiple linea variable structures.
 *
 * Revision 3.0  91/01/03  15:16:31  lozben
 * New generation VDI
 *
 * Revision 2.3  90/02/09  18:53:17  lozben
 * We don't use v_cel_wr flag any more. Now the code looks at the
 * offset table to determine if cell width is 8 or 16 bits.
 *
 * Revision 2.2  89/04/14  15:21:01  lozben
 * Changed sb_cell() and sb_blank() to be able to deal with
 * word wide characters (cells). Also made other changes to
 * sb_blank() so that it can deal with 8 planes.
 *
 * Revision 2.1  89/02/21  17:25:42  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 *******************************************************************************/

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"

O6 equ 6 /* WTF? why? */
#define V_FUNC(func,la,r) \
	move.l	LV((LA_ROUTINES)+O6+func,la),r
#define PIXL6(r) lea lineavars-O6,r

#define V_CALL(func,la,r) \
		V_FUNC(func,la,r) \
		jsr (r)
#define V_JUMP(func,la,r) \
		V_FUNC(func,la,r) \
		jmp (r)

/*******************************************************************************
 *
 * name: sb_cell (soft blt version)
 *
 * purpose:  This routine performs a byte aligned block transfer for the
 *           purpose of manipulating monospaced byte-wide text. the routine
 *           maps an single plane arbitrarilly long byte-wide image to a
 *           multi-plane bit map. all transfers are byte/word aligned.
 *
 * in:	a0.l	points to contiguous source block (1 byte wide)
 *	a1.l	points to destination (1st plane, top of block)
 *	d6.w	foreground
 *	d7.w	background
 *
 * damaged:	a2-a3/a5/d0-d7
 *
 *******************************************************************************/


/* 306de: 00e0da98 */
/* 206de: 00e0e45c */
/* 104de: 00fd25bc */
		xdef sb_cell
sb_cell:
		move.w	LV((v_planes)+O6,a4),d1	/* d1 <- number of planes */
		subq.w	#1,d1			/* d1 <- dbra plane counter */
		move.w	LV((v_fnt_wr)+O6,a4),d2		/* d2 <- src width (in bytes) */
		move.w	LV((v_lin_wr)+O6,a4),d3	/* d3 <- dst width (in bytes) */
		move.w	LV((v_cel_ht)+O6,a4),d4
		subq.w	#1,d4			/* d4 <- cell height -1 */
		move.l	a1,a5			/* a5 -> 1st byte of destination */
blk_next:
		move.l	a5,a3		/* a3 -> dst plane */
		move.w	d4,d0		/* d0 <- dbra row counter */

		clr.w	d5
		lsr.w	#1,d6		/* extract foreground color bit */
		addx.w	d5,d5
		lsr.w	#1,d7		/* extract background color bit */
		roxl.w	#3,d5		/* d5 <- offset to fragment addr */

		move.l	blk_byte(pc,d5.w),a2	/* a2 -> to fragment */
		jmp	(a2)

blk_byte:	dc.l	byte_zero,byte_invert,byte_normal,byte_ones


/*
 * The routines below deal with byte wide font
 */
byte_normal:	move.l	a0,a2		/* a2 -> single plane char cell */
byte_n:		move.b	(a2),(a3)	/* move character byte */
		adda.w	d2,a2		/* a2 -> next row of character */
		adda.w	d3,a3		/* a3 -> next row of destination */
		dbra	d0,byte_n
		addq.l	#2,a5		/* a5 -> 1st row of next dst plane */
		dbra	d1,blk_next
		rts


byte_ones:	moveq.l	#-1,d5		/* fill cell with ones */
		bra	byte_0

byte_zero:	moveq.l	#0,d5		/* fill cell with zeros */
byte_0:		move.l	a0,a2		/* a2 -> single plane character cell */
byte_1:		move.b	d5,(a3)
		adda.w	d3,a3		/* a3 -> next dst row */
		dbra	d0,byte_1
		addq.l	#2,a5		/* a5 -> 1st row of next dst plane */
		dbra	d1,blk_next
		rts


byte_invert:	move.l	a0,a2		/* a2 -> single plane character cell */
byte_i:		move.b	(a2),d5		/* d5 <- character byte */
		not.b	d5		/* d5 <- inverted character byte */
		move.b	d5,(a3)
		adda.w	d2,a2		/* a2 -> next row of character form */
		adda.w	d3,a3		/* a3 -> next row of destination */
		dbra	d0,byte_i
		addq.l	#2,a5		/* a5 -> 1st row of next dst plane */
		dbra	d1,blk_next
		rts


/*******************************************************************************
 *
 * title:	 Scroll
 *
 *
 * author:	jim eisenstein
 *
 *
 *   Scroll copies a source region as wide as the screen to an overlapping
 *   destination region on a one cell-height offset basis.  Two entry points
 *   are provided:  Partial-lower scroll-up, partial-lower scroll-down.
 *   Partial-lower screen operations require cell y # indicating the top line
 *   where scrolling will take place.
 *
 *   After the copy is performed, any non-overlapping area of the previous
 *   source region is "erased" by filling with the background color.
 *
 *
 *  in:  d1.w	   cell Y of region top
 *	v_celmy   cell Y of region bottom
 *
 *
 *  munged:	d0-d7/a2-a3
 *
 *
 *******************************************************************************/

/* 306de: 00e0db90 */
/* 206de: 00e0e4da */
/* 104de: 00fd263a */
		xdef sb_scrup
sb_scrup:
	move.w	LV((v_celmy)+O6,a4),d3		/* d3 <- Ymax */
	move.w	d3,d7
	sub.w	d1,d7			/* d7 <- height of region in cells -1 */
	beq	blank_up

	mulu	LV((v_cel_ht)+O6,a4),d7		/* d7 <- scroll region height */

	move.w	LV((v_cel_wr)+O6,a4),d0
	mulu.w	d0,d1
	move.l	_v_bas_ad,a3		/* a3 -> base of screen */
	add.l	d1,a3			/* a3 -> scroll dst: Ymin */
	move.l	a3,a2
	adda.w	d0,a2			/* a2 -> scroll src: Ymin+1 */

	move.w	LV((v_lin_wr)+O6,a4),d0	/* d0 <- bytes per line */
	lsr.w	#4,d0			/* d0 <- iterations per line */
	mulu	d0,d7			/* d7 <- total iterations */
	subq.w	#1,d7			/* d7 <- dbra loop counter */

loop_up:

	move.l	(a2)+,(a3)+		/* move 16 bytes in a hurry */
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	dbra	d7,loop_up

blank_up:

	clr.w	d0			/* d0 <- Xmin */
	move.w	LV((v_celmx)+O6,a4),d2		/* d2 <- Xmax */
	move.w	d3,d1			/* d1 <- Ymax  d3 <- Ymax */
	V_JUMP(V_BLANK,a4,a2)	/* fill the vacated space */


/* 306de: 00e0dbd4 */
/* 206de: 00e0e51e */
/* 104de: 00fd267e */
		xdef sb_scrdn
sb_scrdn:
	move.w	LV((v_celmy)+O6,a4),d3		/* d3 <- Ymax */
	move.w	d3,d7
	sub.w	d1,d7			/* d7 <- height of region in cells -1 */
	beq	blank_dn

	mulu	LV((v_cel_ht)+O6,a4),d7		/* d7 <- scroll region pixel height */

	move.w	LV((v_cel_wr)+O6,a4),d0 /* d0 <- cell wrap */
	mulu.w	d0,d3
	move.l	_v_bas_ad,a2		/* a2 -> base of screen */

	add.l	d3,a2			/* a2 -> scroll src: 1st word of Ymax */
	move.l	a2,a3
	add.w	d0,a3			/* a3 -> scroll dst: 1st word of Ymax+1 */

	move.w	LV((v_lin_wr)+O6,a4),d0	/* d0 <- bytes per line */
	lsr.w	#4,d0			/* d0 <- iterations per line */
	mulu	d0,d7			/* d7 <- total iterations */
	subq.w	#1,d7			/* d7 <- dbra loop counter */

loop_dn:

	move.l	-(a2),-(a3)		/* move 16 bytes in a hurry */
	move.l	-(a2),-(a3)
	move.l	-(a2),-(a3)
	move.l	-(a2),-(a3)
	dbra	d7,loop_dn

blank_dn:

	clr.w	d0			/* d0 <- Xmin */
	move.w	LV((v_celmx)+O6,a4),d2		/* d2 <- Xmax */
	move.w	d1,d3			/* d1 <- Ymin  d3 <- Ymin */
	V_JUMP(V_BLANK,a4,a2)		/* fill the vacated space */


/*******************************************************************************
 *
 * title:	Blank blt
 *
 * author:	 jim eisenstein
 *
 * purpose:	This routine fills a cell-word aligned region with the
 *		background color.  The rectangular region is specified by a
 *		top/left cell x,y and a bottom/right cell x,y, inclusive.
 *
 * in:	d0	cell Xmin of region
 *	d1	cell Ymin of region
 *	d2	cell Xmax of region
 *	d3	cell Ymax of region
 *
 *
 * mutated:	d4-d7/a2-a3/a5
 *
 *******************************************************************************/

blank_tab:
/*   fringe masks                       *   odd      odd  multi word
 *         *      lf    rt              *  Xmin     Xmax     SPAN
 */
        dc.w    $FF00,$0000             /*   0        0        0 */
        dc.w    $FFFF,$FF00             /*   0        0        1 */
        dc.w    $FFFF,$0000             /*   0        1        0 */
        dc.w    $FFFF,$FFFF             /*   0        1        1 */
        dc.w    $0000,$0000             /*   1        0        0 * undefined */
        dc.w    $00FF,$FF00             /*   1        0        1 */
        dc.w    $00FF,$0000             /*   1        1        0 */
        dc.w    $00FF,$FFFF             /*   1        1        1 */


/* 306de: 00e0dc38 */
/* 206de: 00e0e582 */
/* 104de: 00fd26e2 */
		xdef sb_blank
sb_blank:
	movem.l	d0-d3/a0-a1,-(sp)

	move.w	d0,d4			/* d4 <- X min */
	move.w	d2,d5			/* d5 <- X max */

	clr.w	d0
	lsr.w	#1,d4			/* d4 <- word offset to Xmin */
	addx.w	d0,d0
	lsr.w	#1,d5			/* d5 <- word offset to Xmax */
	addx.w	d0,d0


blank_words:

	sub.w	d4,d5
	move.w	d5,a5			/* a5 <- span-1 (words) for 1 plane */

	sne	d5
	add.b	d5,d5			/* 1 dst word  =:00  <>:FF */
	roxl.w	#3,d0			/* d0 <- offset into fringe table */

	move.w	LV((v_cel_wr)+O6,a4),d7 /* d7 <- cell wrap */
	mulu.w	d1,d7

	move.l	_v_bas_ad,a2		/* a2 -> base of screen */
	add.l	d7,a2			/* a2 -> top of row at Ymin */

	move.w	LV((v_planes)+O6,a4),d6	/* d6 <- number of planes */
	lsr.w     #1,d6     /* d6 <- log2(planes) (works only for planes 1,2,4) */
	add.w	d4,d4			/* d4 <- byte offset to Xmin word */
	lsl.w	d6,d4			/* d4 <- offset to Xmin (bytes) */
	add.w	d4,a2			/* a2 -> start of dst */

	lea	blank_tab(pc,d0.w),a3	/* a3 -> left and right fringes */
	move.w	(a3)+,d4		/* d4 <- left fringe in lo word */
	move.w	d4,d0
	swap	d4
	move.w	d0,d4			/* d4 <- left fringe in hi and lo words */
	move.w	(a3)+,d5		/* d5 <- right fringe */
	move.w	d5,d0
	swap	d5
	move.w	d0,d5			/* d5 <- right fringe in hi and lo words */

	move.w	a5,d0			/* d0 <- SPAN-1 (words) */
	addq.w	#1,d0			/* d0 <- span of one plane in words */
	add.w	d0,d0			/* d0 <- span of one plane in bytes */
	lsl.w	d6,d0			/* d0 <- width of span in bytes */
	neg.w	d0
	add.w	LV((v_lin_wr)+O6,a4),d0
	move.w	d0,a3			/* a3 <- wrap */

	sub.w	d1,d3			/* d3 <- height-1 in cells */
	addq.w	#1,d3			/* d3 <- height in cells */
	mulu	LV((v_cel_ht)+O6,a4),d3		/* d3 <- height in pixels */
	move.w	d3,d7

	add.w	d6,d6			/* choose fragment based on plane count */
	add.w	d6,d6
	move.l	brtn_tab(pc,d6.w),a0

	move.w	LV((v_col_bg)+O6,a4),d6		/* d6 <- background color */
	jsr	(a0)

	movem.l	(sp)+,d0-d3/a0-a1
	rts


brtn_tab:	dc.l	blank1,blank2,blank4

/*
 * Blank out a 1 plane region in your choice of colors
 *
 * in:
 *	a2	points to 1st word of destination
 *	a3	offset from last word of one line to first word of next line
 *	a5	span (in words) of 1 destination plane
 *
 *	d4	left mask   1:fill 0:dst
 *	d5	right mask  1:fill 0:dst
 *	d6	color
 *	d7	height
 */
blank1:

	lsr.w	#1,d6			/* what color? */
	moveq.l	#0,d0			/* set the zero flag */
	subx.w	d0,d0			/* d0 <- 0000 or FFFF */
	bne	en11			/* handle the physical color 1 */

	not.w	d4			/* d4 <- left fringe    0:src 1:dst */
	not.w	d5			/* d5 <- right fringe   0:src 1:dst */
	bra	en10			/* handle the physical color 0 */


lf10:	and.w	d4,(a2)+		/* mask out the area of interest */

	subq.w	#1,d6			/* check single fringe case */
	bcs	nx10

	subq.w	#1,d6			/* check for null inner loop */
	bcs	rf10

in10:	move.w	d0,(a2)+
	dbra	d6,in10

rf10:	and.w	d5,(a2)+

nx10:	add.w	a3,a2			/* a2 -> start of next line */

en10:	move.w	a5,d6			/* d6 <- word count */
	dbra	d7,lf10			/* d7 <- line count */

	rts



lf11:	or.w	d4,(a2)+		/* fill in the area of interest */

	subq.w	#1,d6			/* check single fringe case */
	bcs	nx11

	subq.w	#1,d6			/* check for null inner loop */
	bcs	rf11

in11:	move.w	d0,(a2)+
	dbra	d6,in11

rf11:	or.w	d5,(a2)+

nx11:	add.w	a3,a2			/* a2 -> start of next line */

en11:	move.w	a5,d6			/* d6 <- reinited word count */
	dbra	d7,lf11

	rts



/*
 * Blank out a 2 plane region in your choice of colors
 *
 * in:
 *	a2	points to 1st word of destination
 *	a3	offset from last word of one line to first word of next line
 *	a5	span (in words) of 1 destination plane
 *
 *	d4	left mask   0:dst 1:fill
 *	d5	right mask  0:dst 1:fill
 *	d6	color
 *	d7	height
 */
blank2:	lsr.w	#1,d6			/* cy: plane 0 color */
	subx.l	d0,d0			/* d0[31:16] <- 0000:cy=0 or FFFF:cy=1 */
	lsr.w	#1,d6			/* cy: plane 1 color */
	subx.w	d0,d0			/* d0[15:00] <- 0000:cy=0 or FFFF:cy=1 */

	move.l	d0,a0			/* a0 <- fill value */
	move.l	d0,d2
	and.l	d4,d0			/* d0 <-  left fringe fill value */
	and.l	d5,d2			/* d2 <- right fringe fill value */
	not.l	d4			/* d4 <-  left fringe mask  0:fill 1:dst */
	not.l	d5			/* d5 <- right fringe mask  0:fill 1:dst */
	bra	en2


lf2:	and.l	d4,(a2)			/* clear a space for the background */
	or.l	d0,(a2)+		/* and insert it */

	subq.w	#1,d6			/* check single fringe case */
	bcs	nx2

	subq.w	#1,d6			/* check for null inner loop */
	bcs	rf2

in2:	move.l	a0,(a2)+
	dbra	d6,in2

rf2:	and.l	d5,(a2)
	or.l	d2,(a2)+

nx2:	add.w	a3,a2			/* a2 -> start of next line */

en2:	move.w	a5,d6			/* d6 <- word counter */
	dbra	d7,lf2

	rts





/*
 * Blank out a 4 plane region in your choice of colors
 *
 * in:
 *	a2	points to 1st word of destination
 *	a3	offset from last word of one line to first word of next line
 *	a5	span (in words) of destination plane
 *
 *	d4	left mask   0:dst 1:fill
 *	d5	right mask  0:dst 1:fill
 *	d6	color
 *	d7	height
 */

blank4:	lsr.w	#1,d6			/* cy: plane 0 color */
	subx.l	d0,d0			/* d0[31:16] <- 0000:cy=0 or FFFF:cy=1 */
	lsr.w	#1,d6			/* cy: plane 1 color */
	subx.w	d0,d0			/* d0[15:00] <- 0000:cy=0 or FFFF:cy=1 */
	lsr.w	#1,d6			/* cy: plane 2 color */
	subx.l	d1,d1			/* d1[31:16] <- 0000:cy=0 or FFFF:cy=1 */
	lsr.w	#1,d6			/* cy: plane 3 color */
	subx.w	d1,d1			/* d1[15:00] <- 0000:cy=0 or FFFF:cy=1 */

	move.l	d0,a0			/* a0 <- fill value for planes 0 & 1 */
	move.l	d0,d2
	move.l	d1,a1			/* a1 <- fill value for planes 2 & 3 */
	move.l	d1,d3
	and.l	d4,d0			/* d0 <- lf fringe fill for planes 0 & 1 */
	and.l	d4,d1			/* d1 <- rt fringe fill for planes 0 & 1 */
	and.l	d5,d2			/* d2 <- lf fringe fill for planes 2 & 3 */
	and.l	d5,d3			/* d3 <- rt fringe fill for planes 2 & 3 */
	not.l	d4			/* d4 <- lf fringe mask     0:fill 1:dst */
	not.l	d5			/* d5 <- rt fringe mask     0:fill 1:dst */
	bra	en4


lf4:	and.l	d4,(a2)
	or.l	d0,(a2)+
	and.l	d4,(a2)
	or.l	d1,(a2)+

	subq.w	#1,d6			/* check single fringe case */
	bcs	nx4

	subq.w	#1,d6			/* check for null inner loop */
	bcs	rf4

in4:	move.l	a0,(a2)+
	move.l	a1,(a2)+
	dbra	d6,in4

rf4:	and.l	d5,(a2)
	or.l	d2,(a2)+
	and.l	d5,(a2)
	or.l	d3,(a2)+

nx4:	add.w	a3,a2			/* a2 -> start of next line */

en4:	move.w	a5,d6			/* d6 <- word counter */
	dbra	d7,lf4

	rts





