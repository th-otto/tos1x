	xdef _showfile
_showfile: ds.b 0
		link      a6,#-18
		movem.l   d3-d7/a5,-(a7)
		clr.w     d7
		move.w    d7,-2(a6)
		moveq.l   #-1,d6
		move.l    #0x00001000,(a7)
		move.w    #72,-(a7) ; Malloc
		jsr       _trap
		addq.l    #2,a7
		move.l    d0,-8(a6)
		bne.s     showf3
		tst.w     12(a6)
		beq.s     showf1
		clr.l     (a7)
		move.l    #0x0001001B,-(a7)
		jsr       _fill_string
		addq.l    #4,a7
		bra       showf32
		bra.s     showf2
showf1:
		pea.l     -18(a6)
		move.l    #0x0005000B,-(a7)
		jsr       _rsrc_gaddr
		addq.l    #8,a7
		move.l    -18(a6),(a7)
		jsr       _bconws
		move.l    #xfeb9ae,(a7)
		jsr       _bconws
showf2:
		bra       showf30
showf3:
		clr.w     (a7)
		move.l    8(a6),-(a7)
		move.w    #61,-(a7) ; Fopen
		jsr       _trap
		addq.l    #6,a7
		move.w    d0,d6
		bge.s     showf5
		tst.w     12(a6)
		beq.s     showf4
		move.w    #2,(a7)
		jsr       _form_error
		bra       showf32
		bra.s     showf34
showf4:
		pea.l     -18(a6)
		move.l    #0x0005000A,-(a7)
		jsr       _rsrc_gaddr
		addq.l    #8,a7
		move.l    -18(a6),(a7)
		jsr       _bconws
		move.l    8(a6),(a7)
		jsr       _bconws
		move.l    #xfeb9b1,(a7)
		jsr       _bconws
showf34:
		bra       showf30
showf5:
		tst.w     12(a6)
		beq       showf21
		move.w    #-1,(a7)
		move.w    #33,-(a7) ; Setprt
		jsr       _trp14
		addq.l    #2,a7
		and.w     #0x0010,d0
		beq.s     showf7
		moveq.l   #1,d0
showf6:
		bra.s     showf8
showf7:
		clr.w     d0
showf8:
		move.w    d0,-4(a6)
		clr.w     d7
		bra       showf20
showf9:
		movea.l   -8(a6),a5
		clr.w     d4
		bra       showf19
showf10:
		move.b    (a5),d0
		ext.w     d0
		bra.s     showf15
showf11:
		clr.w     d7
		bra.s     showf16
showf12:
		subq.w    #1,d7
		bra.s     showf16
showf13:
		cmpi.b    #' ',(a5)
		bcs.s     showf14
		addq.w    #1,d7
showf14:
		bra.s     showf16
showf15:
		cmp.w     #8,d0
		beq.s     showf12
		cmp.w     #13,d0
		beq.s     showf11
		bra.s     showf13
showf16:
		move.b    (a5),d0
		ext.w     d0
		move.w    d0,(a7)
		move.w    -4(a6),-(a7)
		move.w    #3,-(a7) ; Bconout
		jsr       _trp13
		addq.l    #4,a7
		tst.l     d0
		bne.s     showf17
		move.w    #2,(a7)
		clr.l     -(a7)
		move.w    _er_num,-(a7)
		jsr       _fm_show
		addq.l    #6,a7
		cmp.w     #2,d0
		beq.s     showf16
		bra       showf31
showf17:
		addq.w    #1,-2(a6)
		move.w    -2(a6),d0
		cmp.w     #16,d0
		blt.s     showf18
		clr.w     -2(a6)
		move.w    #2,(a7)
		move.w    #1,-(a7)
		jsr       _trp13
		addq.l    #2,a7
		tst.l     d0
		beq.s     showf18
		move.w    #2,(a7)
		move.w    #2,-(a7)
		jsr       _trp13
		addq.l    #2,a7
		move.l    d0,-12(a6)
		move.w    d0,-14(a6)
		cmpi.w    #3,-14(a6)
		beq       showf31
		cmpi.w    #'q',-14(a6)
		beq       showf31
		cmpi.w    #'Q',-14(a6)
		beq       showf31
		move.l    -12(a6),d0
		and.l     #0x00FF0000,d0
		cmp.l     #0x00610000,d0
		beq       showf31
showf18:
		addq.w    #1,d4
		addq.l    #1,a5
showf19:
		move.w    d4,d0
		ext.l     d0
		cmp.l     d0,d5
		bgt       showf10
showf20:
		move.l    -8(a6),(a7)
		move.l    #0x00001000,-(a7)
		move.w    d6,-(a7)
		move.w    #63,-(a7) ; Fread
		jsr       _trap
		addq.l    #8,a7
		move.l    d0,d5
		bgt       showf9
		bra       showf31
showf21:
		bra       showf28
showf22:
		movea.l   -8(a6),a5
		clr.w     d4
		bra.w     showf27
showf23:
		move.b    (a5),d0
		ext.w     d0
		move.w    d0,(a7)
		move.l    #0x00030002,-(a7)
		jsr       _trp13
		addq.l    #4,a7
		addq.w    #1,d7
		cmpi.b    #10,(a5)
		bne.s     showf25
		clr.w     d7
		addq.w    #1,-2(a6)
		cmpi.w    #24,-2(a6)
		blt.s     showf24
		pea.l     -18(a6)
		move.l    #0x00050001,-(a7)
		jsr       _rsrc_gaddr
		addq.l    #8,a7
		move.l    #xfeb9b4,(a7)
		jsr       _bconws
		move.l    -18(a6),(a7)
		jsr       _bconws
		pea.l     -2(a6)
		move.w    #1,-(a7)
		jsr       _doui
		addq.l    #6,a7
		tst.w     d0
		bne       showf31
		move.l    #xfeb9b6,(a7)
		jsr       _bconws
showf24:
		bra.s     showf26
showf25:
		cmp.w     #16,d7
		blt.s     showf26
		pea.l     -2(a6)
		clr.w     -(a7)
		jsr       _doui
		addq.l    #6,a7
		tst.w     d0
		bne.s     showf31
showf26:
		addq.w    #1,d4
		addq.l    #1,a5
showf27:
		move.w    d4,d0
		ext.l     d0
		cmp.l     d0,d5
		bgt.s     showf23
showf28:
		move.l    -8(a6),(a7)
		move.l    #0x00001000,-(a7)
		move.w    d6,-(a7)
		move.w    #63,-(a7) ; Fread
		jsr       _trap
		addq.l    #8,a7
		move.l    d0,d5
		bgt       showf22
		tst.l     d5
		bge.s     showf29
		pea.l     -18(a6)
		move.l    #0x00050009,-(a7)
		jsr       _rsrc_gaddr
		addq.l    #8,a7
		move.l    #xfeb9bb,(a7)
		jsr       _bconws
		move.l    -18(a6),(a7)
		jsr       _bconws
		bra.s     showf30
showf29:
		pea.l     -18(a6)
		move.l    #0x00050002,-(a7)
		jsr       _rsrc_gaddr
		addq.l    #8,a7
		move.l    #xfeb9be,(a7)
		jsr       _bconws
		move.l    -18(a6),(a7)
		jsr       _bconws
showf30:
		pea.l     -2(a6)
		move.w    #1,-(a7)
		jsr       _doui
		addq.l    #6,a7
showf31:
		tst.w     d6
		blt.s     showf32
		move.w    d6,(a7)
		move.w    #62,-(a7) ; Fclose
		jsr       _trap
		addq.l    #2,a7
showf32:
		tst.l     -8(a6)
		beq.s     showf33
		move.l    -8(a6),(a7)
		move.w    #73,-(a7) ; Mfree
		jsr       _trap
		addq.l    #2,a7
showf33:
		dc.w      0xF83D ; movem.l (a7)+,d4-d7/a5

	xdef _doui
_doui: ds.b 0
		link      a6,#-10
		clr.w     -6(a6)
		bra.w     doui12
doui1:
		move.w    #2,(a7)
		move.w    #2,-(a7)
		jsr       _trp13
		addq.l    #2,a7
		move.l    d0,-4(a6)
		and.w     #255,d0
		bra.s     doui10

/* case 4 */
/* case 'D' */
/* case 'd' */
doui2:
		movea.l   10(a6),a0
		move.w    #12,(a0)
		clr.w     d0
		bra.w     doui13

/* case ' ' */
doui3:
		movea.l   10(a6),a0
		clr.w     (a0)
		clr.w     d0
		bra.w     doui13

/* case 13 */
doui4:
		movea.l   10(a6),a0
		move.w    #0x0017,(a0)
		clr.w     d0
		bra.s     doui13

/* case 19 */
doui5:
		move.w    #1,-6(a6)
		bra.s     doui12

/* case 17 */
doui6:
		clr.w     -6(a6)
		bra.s     doui12

/* case 3 */
/* case 'Q' */
/* case 'q' */
doui7:
		moveq.l   #1,d0
		bra.s     doui13

/* default */
doui8:
		move.l    -4(a6),d0
		and.l     #0x00FF0000,d0
		cmp.l     #0x00610000,d0
		bne.s     doui9
		moveq.l   #1,d0
		bra.s     doui13
doui9:
		bra.s     doui12
doui10:
		ext.l     d0
		movea.l   #xfeb956,a0
		moveq.l   #10,d1
doui11:
		cmp.l     (a0)+,d0
		dbeq      d1,doui11
		movea.l   40(a0),a0
		jmp       (a0)
doui12:
		tst.w     8(a6)
		bne       doui1
		move.w    #2,(a7)
		move.w    #1,-(a7)
		jsr       _trp13
		addq.l    #2,a7
		tst.l     d0
		bne       doui1
		tst.w     -6(a6)
		bne       doui1
		clr.w     d0
doui13:
		dc.w      0xF001 ; movem.l (a7)+,#0


	xdef _bconws
_bconws: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		bra.s     bconws2
bconws1:
		move.b    (a5)+,d0
		ext.w     d0
		move.w    d0,(a7)
		move.l    #0x00030002,-(a7)
		jsr       _trp13
		addq.l    #4,a7
bconws2:
		tst.b     (a5)
		bne.s     bconws1
		dc.w      0xF801 ; movem.l (a7)+,a5

	data

xfeb956:
	dc.l 3
	dc.l 4
	dc.l 13
	dc.l 17
	dc.l 19
	dc.l ' '
	dc.l 'D'
	dc.l 'Q'
	dc.l 'd'
	dc.l 'q'
	dc.l 0
	dc.l doui7
	dc.l doui2
	dc.l doui4
	dc.l doui6
	dc.l doui5
	dc.l doui3
	dc.l doui2
	dc.l doui7
	dc.l doui2
	dc.l doui7
	dc.l doui2

xfeb9ae: dc.b 13,10,0
xfeb9b1: dc.b 13,10,0
xfeb9b4: dc.b 13,0
xfeb9b6: dc.b 13,27,'K',13,0
xfeb9bb: dc.b 13,10,0
xfeb9be: dc.b 13,10,0
	even
