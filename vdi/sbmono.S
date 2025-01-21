*********************************  sbmono.s  **********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:53:40 $
* =============================================================================
*
* Revision 3.1  91/07/30  12:53:40  lozben
* Changed some absolute offsets to equate offsets.
*
* Revision 3.0  91/01/03  15:17:23  lozben
* New generation VDI
*
* Revision 2.1  89/02/21  17:26:13  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
* Revision 1.1  87/11/20  15:17:24  lozben
* Initial revision
*
*******************************************************************************

*  no clipping to worry about
*
*   d0.w =  DESTX
*   d1.w =  DESTY
*   d2.w =  # of characters
*   d3.w =  DELY
*   a1   =  line A variable reference base

/* 306de: 00e0e104 */
/* 206de: 00e0e9ba */
/* 104de: 00fd2b1a */
/* 106de: 00e12d7a */
/* 100fr: 00fcfe1a */
		xdef	 sb_mono
sb_mono:
		move.l     a6,-(a7)	; save a6 
		jsr        concat
		tst.w      d0
		beq.s      word_ok
		addq.w     #1,d1
word_ok:

	move.l	_v_bas_ad,a1
	add.w	d1,a1					; a1 -> screen destination
	move.l  LV(FBASE,a5),a0			; a0 -> source form base address
	move.l	LV(INTIN,a5),a2			; a2 -> character string
	move.w	LV(FWIDTH,a5),d0		; d0 <- source form width
	move.w  LV(v_lin_wr,a5),d1	; d1 <- screen form width
	move.w	LV(WRT_MODE,a5),d4	; d4 <- writing mode
	lsl.w	#1,d4			; d4 <- writing mode index
	lea mode_base,a4
	bra    next_char


*	a0   -> source form base
*	a1   -> screen destination
*	a2   -> character string
*
*	d0.w = source form width
*	d1.w = screen form width
*	d2.w = # of characters
*	d3.w = height of character -1 (in rows)
*	d4.w = writing mode index (0,2,4,or6)

mchar_lp:

	move.l	a1,-(sp)		; save screen destination on stack
	move.w	(a2)+,d5		; d5 <- next character from string
	lea	0(a0,d5.w),a3		; a3 -> top-most grfx byt for cur char
	move.w	 LV(TEXT_FG,a5),d6	; d6 <- foreground color
	move.w	LV(v_planes,a5),d5	; d5 <- plane count
	bra	next_plane

mplan_lp:

	move.w	d4,d7		; d7 <- writing mode index
	ror.w	#1,d6		; cy <- current plane's foreground color bit
	bcc	bit_clr		; cy:0 => use top half of table

	ori.w	#8,d7		; cy:1 => use bottom half of table

bit_clr:

	move.w	mode_tbl(pc,d7.w),d7	; d7 <- offset to routine
	jsr	0(a4,d7.w)	; perform proper operation


mplan_cont:

	addq.w	#2,a1			;destination to next plane

next_plane:

	dbra	d5,mplan_lp		;do next plane


	move.l	(sp)+,a1	; a1 -> original screen destination
	addq.w	#1,a1		; a1 -> next character position
	move.l	a1,d7
	andi.w	#1,d7		; word fault ?
	bne	next_char	; if not, use other half of current word

	move.w	LV(v_planes,a5),d7	; d7 <- number of planes
	subq.w	#1,d7			; d7 <-	number of planes -1
	lsl.w	#1,d7			; d7 <- offset to 1st plane of nxt byte
	add.w	d7,a1			; a1 -> next char position

next_char:

	dbra	d2,mchar_lp		; do next character

	moveq.l	#1,d0			; exit blit with success code in d0
	move.l	(sp)+,a6		; restore a6
	rts


mode_tbl:

	dc.w	 mon_zer-mode_base	;replace		0
	dc.w	mon_set0-mode_base	;transparent		0
	dc.w	 mon_xor-mode_base	;exclusive or (xor)	0
	dc.w	mon_not0-mode_base	;inverse transparent	0

	dc.w	 mon_rep-mode_base	;replace		1
	dc.w	mon_set1-mode_base	;transparent		1
	dc.w	 mon_xor-mode_base	;exclusive or (xor)	1
	dc.w	mon_not1-mode_base	;inverse transparent	1
mode_base:



*  	a1  -> screen address
*  	a3  -> top-most grafix byte in font data of current character
*	a5  -> line A variables base address ( FWIDTH)
*
*	d0.w = source form width
*	d1.w = screen form width
*	d3.w = height of character (in rows)


*  direct replacement

mon_rep:

	move.l	a1,a5		;copy screen address to temp
	move.l	a3,a6		;copy form address to temp
	move.w	d3,d7		;copy height count to temp
    bra rep_lp1
rep_lp:
	move.b	(a6),(a5)	;direct replacement
	adda.w	d0,a6		;advance to next form byte
	adda.w	d1,a5		;advance to next screen byte
rep_lp1:
	dbra	d7,rep_lp	;go for next line

	rts


*  all zeros

mon_zer:

	move.l	a1,a5		;copy screen address to temp
	move.w	d3,d7		;copy height count to temp
    bra zer_lp1

zer_lp:
	clr.b	(a5)		;all zeros
	adda.w	d1,a5		;advance to next screen byte
zer_lp1:
	dbra	d7,zer_lp	;go for next line

	rts



mon_set0:

	swap	d2		;save lower 16 bits in upper 16
	move.l	a1,a5		;copy screen address to temp
	move.l	a3,a6		;copy form address to temp
	move.w	d3,d7		;copy height count to temp
    bra set0_lp1

set0_lp:

	move.b	(a6),d2		;fetch next row data
	not.b	d2
	and.b	d2,(a5)		;perform logic op
	adda.w	d0,a6		;advance to next form byte
	adda.w	d1,a5		;advance to next screen byte
set0_lp1:
	dbra	d7,set0_lp	;go for next line

	swap	d2		;restore d2
	rts




mon_set1:

	swap	d2
	move.l	a1,a5		;copy screen address to temp
	move.l	a3,a6		;copy form address to temp
	move.w	d3,d7		;copy height count to temp
    bra set1_lp1

set1_lp:

	move.b	(a6),d2		;fetch next row data
	or.b	d2,(a5)		;perform logic op
	adda.w	d0,a6		;advance to next form byte
	adda.w	d1,a5		;advance to next screen byte
set1_lp1:
	dbra	d7,set1_lp	;go for next line

	swap	d2
	rts




mon_not0:

	swap	d2		;save lower 16 bits in upper 16
	move.l	a1,a5		;copy screen address to temp
	move.l	a3,a6		;copy form address to temp
	move.w	d3,d7		;copy height count to temp
    bra not0_lp1

not0_lp:

	move.b	(a6),d2		;fetch next row data
	and.b	d2,(a5)		;perform logic op
	adda.w	d0,a6		;advance to next form byte
	adda.w	d1,a5		;advance to next screen byte
not0_lp1:
	dbra	d7,not0_lp	;go for next line

	swap	d2		;restore d2
	rts



mon_not1:

	swap	d2
	move.l	a1,a5		;copy screen address to temp
	move.l	a3,a6		;copy form address to temp
	move.w	d3,d7		;copy height count to temp
    bra not1_lp1

not1_lp:

	move.b	(a6),d2		;fetch next row data
	not.b	d2
	or.b	d2,(a5)		;perform logic op
	adda.w	d0,a6		;advance to next form byte
	adda.w	d1,a5		;advance to next screen byte
not1_lp1:
	dbra	d7,not1_lp	;go for next line

	swap	d2
	rts



mon_xor:

	swap	d2
	move.l	a1,a5		;copy form address to temp
	move.l	a3,a6		;copy screen address to temp
	move.w	d3,d7		;copy height count to temp
    bra xor_lp1

xor_lp:

	move.b	(a6),d2		;fetch next row data
	eor.b	d2,(a5)		;perform logic op
	adda.w	d0,a6		;advance to next form byte
	adda.w	d1,a5		;advance to next screen byte
xor_lp1:
	dbra	d7,xor_lp	;go for next line

	swap	d2
	rts
