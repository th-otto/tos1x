	xdef _fc_start
_fc_start: ds.b 0
		link      a6,#-12
		movem.l   d4-d7/a5,-(a7)
		movea.l   _thedesk,a0
		move.l    13698(a0),d5
		movea.l   d5,a5
		adda.l    #$0000009C,a5
		movea.l   d5,a0
		adda.l    #$000001F4,a0
		move.w    (a0),d6
		move.w    d6,d0
		ext.l     d0
		divs.w    #80,d0
		move.w    d0,_w_inc
		move.w    _w_inc,d6
		move.w    d6,d0
		muls.w    #80,d0
		move.w    d0,d6
		move.w    d0,_bar_max
		movea.l   d5,a0
		adda.l    #$000001F4,a0
		move.w    d6,(a0)
		movea.l   d5,a0
		adda.l    #$00000224,a0
		move.w    d6,(a0)
		clr.w     -2(a6)
		bra.s     fc_st2
fc_st1:
		movea.l   d5,a0
		movea.w   -2(a6),a1
		adda.l    a1,a1
		adda.l    #ttable,a1
		move.w    (a1),d1
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		clr.w     (a0)
		addq.w    #1,-2(a6)
fc_st2:
		cmpi.w    #7,-2(a6)
		blt.s     fc_st1
		move.l    #nostr,(a7)
		move.w    #13,-(a7)
		move.l    d5,-(a7)
		jsr _inf_sset
		addq.l    #6,a7
		movea.l   d5,a0
		adda.l    #$000000E0,a0
		move.w    #$0080,(a0)
		movea.l   d5,a0
		adda.l    #$00000038,a0
		move.w    #$0080,(a0)
		movea.l   8(a6),a0
		cmpi.b    #$41,(a0)
		beq.s     fc_st3
		clr.w     d0
		bra.s     fc_st4
fc_st3:
		moveq.l   #1,d0
fc_st4:
		move.w    d0,d7
		cmpi.w    #$00FB,12(a6)
		bne.s     fc_st11
		movea.l   d5,a0
		tst.w     d7
		beq.s     fc_st5
		moveq.l   #12,d1
		bra.s     fc_st6
fc_st5:
		moveq.l   #11,d1
fc_st6:
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		move.w    #1,(a0)
		movea.l   d5,a0
		tst.w     d7
		beq.s     fc_st7
		moveq.l   #4,d1
		bra.s     fc_st8
fc_st7:
		moveq.l   #5,d1
fc_st8:
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		move.w    #1,(a0)
		tst.w     d7
		beq.s     fc_st9
		moveq.l   #66,d0
		bra.s     fc_st10
fc_st9:
		moveq.l   #65,d0
fc_st10:
		move.b    d0,(a5)
		movea.l   d5,a0
		adda.l    #$000000B2,a0
		move.w    #1,(a0)
		moveq.l   #7,d7
		bra.s     fc_st18
fc_st11:
		movea.l   d5,a0
		tst.w     d7
		beq.s     fc_st12
		moveq.l   #5,d1
		bra.s     fc_st13
fc_st12:
		moveq.l   #4,d1
fc_st13:
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		move.w    #1,(a0)
		tst.w     d7
		beq.s     fc_st14
		moveq.l   #65,d0
		bra.s     fc_st15
fc_st14:
		moveq.l   #66,d0
fc_st15:
		move.b    d0,(a5)
		movea.l   d5,a0
		tst.w     d7
		beq.s     fc_st16
		moveq.l   #11,d1
		bra.s     fc_st17
fc_st16:
		moveq.l   #12,d1
fc_st17:
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		move.w    #1,(a0)
		movea.l   d5,a0
		adda.l    #$000001BA,a0
		move.w    #1,(a0)
		moveq.l   #18,d7
fc_st18:
		move.l    d5,(a7)
		jsr _fm_draw
		bra       fc_st29
fc_st31:
		move.w    d7,d0
		bra       fc_st26

/* case 18 */
fc_st19:
		move.w    #2,(a7)
		move.l    d5,-(a7)
		jsr _drawfld
		addq.l    #4,a7
		movea.l   d5,a0
		adda.l    #$00000038,a0
		move.w    #$0080,(a0)
		movea.l   d5,a0
		adda.l    #$000000E0,a0
		clr.w     (a0)
		move.w    #9,(a7)
		move.l    d5,-(a7)
		jsr _fc_draw
		addq.l    #4,a7
		clr.w     -4(a6)
		bra       fc_st28

/* case 7 */
fc_st32:
		move.w    #9,(a7)
		move.l    d5,-(a7)
		jsr _drawfld
		addq.l    #4,a7
		movea.l   d5,a0
		adda.l    #$000000E0,a0
		move.w    #$0080,(a0)
		movea.l   d5,a0
		adda.l    #$00000038,a0
		clr.w     (a0)
		move.w    #2,(a7)
		move.l    d5,-(a7)
		jsr _fc_draw
		addq.l    #4,a7
		move.w    #-1,-4(a6)
		bra       fc_st28

/* case 4 */
/* case 5 */
fc_st20:
		cmp.w     #4,d7
		bne.s     fc_st21
		moveq.l   #66,d0
		bra.s     fc_st22
fc_st21:
		moveq.l   #65,d0
fc_st22:
		move.b    d0,(a5)
		move.w    #6,(a7)
		move.l    d5,-(a7)
		jsr _drawfld
		addq.l    #4,a7
		bra       fc_st28

/* case 24: */
fc_st33:
		move.l    d5,(a7)
		jsr _do_finish
		clr.w     (a7)
		move.l    #drive_a,-(a7)
		jsr _up_allwin
		addq.l    #4,a7
		clr.w     (a7)
		move.l    #drive_b,-(a7)
		jsr _up_allwin
		addq.l    #4,a7
		clr.w     (a7)
		jsr _desk_clear
		bra       fc_st30

/* case 23 */
fc_st23:
		move.w    #1,(a7)
		jsr _desk_wait
		movea.l   d5,a0
		adda.l    #$000001F4,a0
		clr.w     (a0)
		movea.l   d5,a0
		adda.l    #$00000224,a0
		clr.w     (a0)
		movea.l   d5,a0
		adda.l    #$000001BB,a0
		btst      #0,(a0)
		beq.s     fc_st24
		move.l    d5,(a7)
		jsr _fc_format
		bra.s     fc_st25
fc_st24:
		move.l    d5,(a7)
		jsr _fc_copy
fc_st25:
		movea.l   d5,a0
		adda.l    #$000001F4,a0
		move.w    d6,(a0)
		movea.l   d5,a0
		adda.l    #$00000224,a0
		move.w    d6,(a0)
		movea.l   d5,a0
		adda.l    #$00000232,a0
		clr.w     (a0)
		move.w    #20,(a7)
		move.l    d5,-(a7)
		jsr _drawfld
		addq.l    #4,a7
		move.w    #22,(a7)
		move.l    d5,-(a7)
		jsr _drawfld
		addq.l    #4,a7
		move.w    #23,(a7)
		move.l    d5,-(a7)
		jsr _drawfld
		addq.l    #4,a7
		clr.w     (a7)
		jsr _desk_wait
		bra.s     fc_st28
fc_st26:
		ext.l     d0
		movea.l   #xfeb9e2,a0
		moveq.l   #6,d1
fc_st27:
		cmp.l     (a0)+,d0
		dbeq      d1,fc_st27
		movea.l   24(a0),a0
		jmp       (a0)

/* default: */
fc_st28:
		move.w    -4(a6),(a7)
		move.l    d5,-(a7)
		jsr _form_do
		addq.l    #4,a7
		move.w    d0,d7
		and.w     #$7FFF,d7
fc_st29:
		bra       fc_st31
fc_st30:
		dc.w      $F839

	xdef _fc_format
_fc_format: ds.b 0
		link      a6,#-100
		movem.l   d3-d7/a3-a5,-(a7)
		move.l    #$00002000,(a7)
		jsr _dos_alloc
		movea.l   d0,a5
		move.l    a5,d0
		bne.s     fc_fo2
fc_fo1:
		move.w    #27,(a7)
		jsr _do1_alert
		bra       fc_fo40
fc_fo2:
		movea.l   a5,a3
		move.l    #$00002000,(a7)
		jsr _dos_alloc
		movea.l   d0,a4
		move.l    a4,d0
		bne.s     fc_fo3
		move.l    a5,(a7)
		jsr _dos_free
		bra.s     fc_fo1
fc_fo3:
		move.w    #80,-26(a6)
		move.w    #2,-28(a6)
		move.w    #3,-20(a6)
		movea.l   8(a6),a0
		adda.l    #$0000018B,a0
		btst      #0,(a0)
		beq.s     fc_fo4
		move.w    #1,-28(a6)
		move.w    #2,-20(a6)
fc_fo4:
		movea.l   8(a6),a0
		adda.l    #$00000113,a0
		btst      #0,(a0)
		beq.s     fc_fo5
		clr.w     d0
		bra.s     fc_fo6
fc_fo5:
		moveq.l   #1,d0
fc_fo6:
		move.w    d0,-14(a6)
		clr.w     d6
		clr.w     d7
		clr.w     d5
		bra.s     fc_fo8
fc_fo7:
		movea.l   a6,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    a1,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    #skew2,a1
		move.w    (a1),-70(a0)
		addq.w    #1,d5
fc_fo8:
		cmp.w     #9,d5
		blt.s     fc_fo7
		cmpi.w    #1,-28(a6)
		bne.s     fc_fo9
		moveq.l   #3,d0
		bra.s     fc_fo10
fc_fo9:
		moveq.l   #2,d0
fc_fo10:
		move.w    d0,-72(a6)
		clr.w     d4
		bra       fc_fo27
fc_fo11:
		clr.w     -22(a6)
		bra       fc_fo25
fc_fo12:
		move.w    -72(a6),d5
		bra.s     fc_fo14
fc_fo13:
		movea.l   a6,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    a1,a0
		movea.l   a6,a1
		movea.w   d5,a2
		suba.w    -72(a6),a2
		adda.l    a2,a2
		adda.l    a2,a1
		move.w    -70(a1),-52(a0)
		addq.w    #1,d5
fc_fo14:
		cmp.w     #9,d5
		blt.s     fc_fo13
		clr.w     d5
		bra.s     fc_fo16
fc_fo15:
		moveq.l   #9,d6
		sub.w     -72(a6),d6
		movea.l   a6,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    a1,a0
		movea.l   a6,a1
		movea.w   d6,a2
		adda.w    d5,a2
		adda.l    a2,a2
		adda.l    a2,a1
		move.w    -70(a1),-52(a0)
		addq.w    #1,d5
fc_fo16:
		cmp.w     -72(a6),d5
		blt.s     fc_fo15
		clr.w     d5
		bra.s     fc_fo18
fc_fo17:
		movea.l   a6,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    a1,a0
		movea.l   a6,a1
		movea.w   d5,a2
		adda.l    a2,a2
		adda.l    a2,a1
		move.w    -52(a1),-70(a0)
		addq.w    #1,d5
fc_fo18:
		cmp.w     #9,d5
		blt.s     fc_fo17
fc_fo19:
		move.w    #$E5E5,(a7)
		move.l    #$87654321,-(a7)
		move.w    #-1,-(a7)
		move.w    -22(a6),-(a7)
		move.w    d4,-(a7)
		move.w    #9,-(a7)
		move.w    -14(a6),-(a7)
		pea.l     -52(a6)
		move.l    a5,-(a7)
		move.w    #10,-(a7)
		jsr _trp14int
		adda.w    #24,a7
		move.w    d0,d6
		cmp.w     #$FFF0,d6
		bne.s     fc_fo23
		cmp.w     #2,d4
		blt.s     fc_fo20
		move.w    d7,d0
		add.w     #9,d0
		cmp.w     #16,d0
		blt.s     fc_fo21
fc_fo20:
		move.w    #28,(a7)
		jsr _do1_alert
		cmp.w     #1,d0
		beq.s     fc_fo20
		moveq.l   #1,d6
		bra.s     fc_fo26
		bra.s     fc_fo23
fc_fo21:
		clr.w     d5
		bra.s     fc_fo41
fc_fo22:
		move.w    d4,d0
		muls.w    -28(a6),d0
		muls.w    #9,d0
		movea.w   d5,a1
		adda.l    a1,a1
		move.w    0(a3,a1.l),d1
		add.w     d1,d0
		move.w    -22(a6),d1
		muls.w    #9,d1
		add.w     d1,d0
		subq.w    #1,d0
		movea.l   a4,a1
		movea.w   d7,a2
		adda.l    a2,a2
		adda.l    a2,a1
		move.w    d0,(a1)
		clr.w     d6
		addq.w    #1,d5
		addq.w    #1,d7
fc_fo41:
		movea.w   d5,a0
		adda.l    a0,a0
		tst.w     0(a3,a0.l)
		bne.s     fc_fo22
fc_fo23:
		tst.w     d6
		beq.s     fc_fo24
		move.w    #28,(a7)
		jsr _do1_alert
		cmp.w     #1,d0
		beq       fc_fo19
fc_fo24:
		addq.w    #1,-22(a6)
fc_fo25:
		move.w    -22(a6),d0
		cmp.w     -28(a6),d0
		bge.s     fc_fo26
		tst.w     d6
		beq       fc_fo12
fc_fo26:
		move.w    -14(a6),(a7)
		move.l    8(a6),-(a7)
		jsr _fc_bar
		addq.l    #4,a7
		addq.w    #1,d4
fc_fo27:
		cmp.w     -26(a6),d4
		bge.s     fc_fo28
		tst.w     d6
		beq       fc_fo11
fc_fo28:
		tst.w     d6
		bne       fc_fo38
		clr.w     (a7)
		move.w    -20(a6),-(a7)
		move.l    #$01000000,-(a7)
		move.l    a5,-(a7)
		move.w    #18,-(a7)
		jsr _trp14int
		adda.w    #12,a7
		move.b    #$E9,(a5)
		move.w    -14(a6),(a7)
		move.l    #$00010000,-(a7)
		move.l    a5,-(a7)
		move.w    #3,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
		move.w    d0,d6
		bne       fc_fo38
		move.w    -14(a6),(a7)
		move.w    #7,-(a7)
		jsr _trp13
		addq.l    #2,a7
		move.l    d0,-34(a6)
		move.w    -14(a6),(a7)
		move.l    #$00010000,-(a7)
		move.l    a5,-(a7)
		move.w    #3,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
		move.w    d0,d6
		bne       fc_fo38
		movea.l   -34(a6),a0
		move.w    6(a0),(a7)
		movea.l   -34(a6),a0
		move.w    8(a0),-(a7)
		jsr _max
		addq.l    #2,a7
		move.w    d0,-18(a6)
		move.w    -18(a6),d0
		moveq.l   #9,d1
		asl.w     d1,d0
		ext.l     d0
		divs.w    #2,d0
		move.w    d0,-16(a6)
		clr.w     d5
		bra.s     fc_fo30
fc_fo29:
		movea.l   a3,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    a1,a0
		clr.w     (a0)
		addq.w    #1,d5
fc_fo30:
		cmp.w     -16(a6),d5
		blt.s     fc_fo29
		pea.l     -86(a6)
		move.w    #13,-(a7)
		move.l    8(a6),-(a7)
		jsr _fs_sget
		adda.w    #10,a7
		tst.b     -86(a6)
		beq.s     fc_fo33
		pea.l     -100(a6)
		move.l    #$000B0020,-(a7)
		jsr _bfill
		addq.l    #8,a7
		clr.w     d5
		bra.s     fc_fo32
fc_fo31:
		movea.w   d5,a0
		adda.l    a6,a0
		movea.w   d5,a1
		adda.l    a6,a1
		move.b    -86(a1),-100(a0)
		addq.w    #1,d5
fc_fo32:
		tst.b     -86(a6,d5.w)
		bne.s     fc_fo31
		move.w    #11,(a7)
		pea.l     -100(a6)
		move.l    a5,-(a7)
		jsr _LBCOPY
		addq.l    #8,a7
		ori.w     #8,10(a3)
fc_fo33:
		movea.l   -34(a6),a0
		move.w    8(a0),d5
		asl.w     #1,d5
		addq.w    #1,d5
		move.w    -14(a6),(a7)
		move.w    d5,-(a7)
		movea.l   -34(a6),a0
		move.w    6(a0),-(a7)
		move.l    a5,-(a7)
		move.w    #3,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
		move.w    d0,d6
		bne       fc_fo38
		clr.w     d5
		bra.s     fc_fo35
fc_fo34:
		movea.l   a3,a0
		movea.w   d5,a1
		adda.l    a1,a1
		adda.l    a1,a0
		clr.w     (a0)
		addq.w    #1,d5
fc_fo35:
		cmp.w     -16(a6),d5
		blt.s     fc_fo34
		move.w    #$F9FF,(a3)
		move.w    #$FF00,2(a3)
		clr.w     d5
		bra.s     fc_fo37
fc_fo36:
		movea.w   d5,a0
		adda.l    a0,a0
		move.w    0(a4,a0.l),d0
		movea.l   -34(a6),a1
		move.w    12(a1),d1
		sub.w     d1,d0
		ext.l     d0
		movea.l   -34(a6),a1
		divs.w    2(a1),d0
		addq.w    #2,d0
		move.w    d0,-30(a6)
		move.l    a3,(a7)
		move.w    -30(a6),-(a7)
		jsr _fc_clfix
		addq.l    #2,a7
		addq.w    #1,d5
fc_fo37:
		cmp.w     d7,d5
		blt.s     fc_fo36
		move.w    -14(a6),(a7)
		move.w    #1,-(a7)
		movea.l   -34(a6),a0
		move.w    8(a0),-(a7)
		move.l    a3,-(a7)
		move.w    #3,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
		move.w    d0,d6
		bne.s     fc_fo38
		move.w    -14(a6),(a7)
		movea.l   -34(a6),a0
		move.w    8(a0),-(a7)
		addq.w    #1,(a7)
		movea.l   -34(a6),a0
		move.w    8(a0),-(a7)
		move.l    a3,-(a7)
		move.w    #3,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
		move.w    d0,d6
fc_fo38:
		clr.w     (a7)
		jsr _desk_wait
		tst.w     d6
		bne.s     fc_fo39
		pea.l     -8(a6)
		pea.l     -12(a6)
		move.w    -14(a6),-(a7)
		addq.w    #1,(a7)
		jsr _dos_space
		adda.w    #10,a7
		pea.l     -8(a6)
		move.l    #$0001001D,-(a7)
		jsr _fun_alert
		addq.l    #8,a7
fc_fo39:
		move.l    a5,(a7)
		jsr _dos_free
		move.l    a4,(a7)
		jsr _dos_free
fc_fo40:
		dc.w      $FE3D

	xdef _fc_copy
_fc_copy: ds.b 0
		link      a6,#-40
		movem.l   d2-d7/a4-a5,-(a7)
		move.l    #$00000258,(a7)
		jsr _dos_alloc
		move.l    d0,d7
		bne.s     fc_co2
fc_co1:
		move.w    #27,(a7)
		jsr _do1_alert
		bra       fc_co25
fc_co2:
		movea.l   8(a6),a0
		adda.l    #$0000006B,a0
		btst      #0,(a0)
		beq.s     fc_co3
		clr.w     d0
		bra.s     fc_co4
fc_co3:
		moveq.l   #1,d0
fc_co4:
		move.w    d0,-10(a6)
		tst.w     -10(a6)
		beq.s     fc_co5
		clr.w     d0
		bra.s     fc_co6
fc_co5:
		moveq.l   #1,d0
fc_co6:
		move.w    d0,-12(a6)
fc_co7:
		move.w    -10(a6),(a7)
		move.w    #7,-(a7)
		jsr _trp13
		addq.l    #2,a7
		movea.l   d0,a5
		move.l    a5,d0
		bne.s     fc_co8
		move.w    #28,(a7)
		jsr _do1_alert
		cmp.w     #1,d0
		beq.s     fc_co7
		move.l    d7,(a7)
		jsr _dos_free
		bra       fc_co25
fc_co8:
		move.w    22(a5),-14(a6)
		move.w    (a5),-16(a6)
		move.w    -14(a6),d0
		muls.w    -16(a6),d0
		move.w    d0,-18(a6)
		jsr _dos_avail
		move.l    d0,-8(a6)
		movea.w   -18(a6),a0
		cmp.l     a0,d0
		bge.s     fc_co9
		move.l    d7,(a7)
		jsr _dos_free
		bra       fc_co1
fc_co9:
		move.l    -8(a6),(a7)
		jsr _dos_alloc
		move.l    d0,d6
		move.w    18(a5),d0
		muls.w    -14(a6),d0
		move.w    d0,-20(a6)
		move.l    -8(a6),d0
		divs.w    -16(a6),d0
		ext.l     d0
		move.w    d0,-22(a6)
		move.w    -20(a6),d0
		ext.l     d0
		divs.w    -22(a6),d0
		swap      d0
		move.w    d0,-24(a6)
		move.w    #1,-26(a6)
		clr.w     -28(a6)
		clr.w     d0
		move.w    d0,-34(a6)
		move.w    d0,-38(a6)
		move.w    d0,-36(a6)
		move.w    -20(a6),d3
		ext.l     d3
		divs.w    -22(a6),d3
		bne.s     fc_co10
		move.w    -24(a6),-22(a6)
		move.w    #1,-28(a6)
		moveq.l   #1,d3
fc_co10:
		move.w    -10(a6),(a7)
		move.l    #$00010000,-(a7)
		move.l    d7,-(a7)
		move.w    #2,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
		tst.w     d0
		bne       fc_co24
		bra       fc_co23
fc_co11:
		move.w    -10(a6),-32(a6)
		moveq.l   #2,d4
		bra       fc_co22
fc_co12:
		move.l    d6,-4(a6)
		move.w    -22(a6),d0
		ext.l     d0
		divs.w    -14(a6),d0
		move.w    d0,-40(a6)
		clr.w     d5
		bra.s     fc_co14
fc_co13:
		move.l    -34(a6),-(a7)
		move.w    -14(a6),-(a7)
		move.l    -4(a6),-(a7)
		move.w    d4,-(a7)
		jsr _fc_rwsec
		adda.w    #12,a7
		tst.w     d0
		bne       fc_co24
		move.w    -14(a6),d0
		add.w     d0,-34(a6)
		move.w    -18(a6),d0
		ext.l     d0
		add.l     d0,-4(a6)
		move.w    -32(a6),(a7)
		move.l    8(a6),-(a7)
		jsr _fc_bar
		addq.l    #4,a7
		addq.w    #1,d5
fc_co14:
		cmp.w     -40(a6),d5
		blt.s     fc_co13
		move.w    -22(a6),d5
		ext.l     d5
		divs.w    -14(a6),d5
		swap      d5
		beq.s     fc_co15
		move.l    -34(a6),-(a7)
		move.w    d5,-(a7)
		move.l    -4(a6),-(a7)
		move.w    d4,-(a7)
		jsr _fc_rwsec
		adda.w    #12,a7
		tst.w     d0
		bne       fc_co24
		add.w     d5,-34(a6)
		move.w    -32(a6),(a7)
		move.l    8(a6),-(a7)
		jsr _fc_bar
		addq.l    #4,a7
fc_co15:
		cmp.w     #2,d4
		bne.w     fc_co20
		move.w    -34(a6),-36(a6)
		move.w    -38(a6),-34(a6)
		tst.w     -26(a6)
		beq.s     fc_co19
		clr.w     -26(a6)
fc_co16:
		move.w    -12(a6),(a7)
		move.w    #7,-(a7)
		jsr _trp13
		addq.l    #2,a7
		movea.l   d0,a4
		move.l    a4,d0
		bne.s     fc_co17
		move.w    #28,(a7)
		jsr _do1_alert
		cmp.w     #1,d0
		beq.s     fc_co16
		bra       fc_co24
fc_co17:
		move.w    20(a5),d0
		cmp.w     20(a4),d0
		bne.s     fc_co18
		move.w    22(a4),d0
		cmp.w     -14(a6),d0
		bne.s     fc_co18
		move.w    18(a5),d0
		cmp.w     18(a4),d0
		bne.s     fc_co18
		move.w    (a4),d0
		cmp.w     -16(a6),d0
		beq.s     fc_co19
fc_co18:
		clr.l     (a7)
		move.l    #$0001001E,-(a7)
		jsr _fun_alert
		addq.l    #4,a7
		cmp.w     #1,d0
		bne.s     fc_co24
		bra.s     fc_co16
fc_co19:
		bra.s     fc_co21
fc_co20:
		move.w    -34(a6),-38(a6)
		move.w    -36(a6),-34(a6)
fc_co21:
		move.w    -12(a6),-32(a6)
		addq.w    #1,d4
fc_co22:
		cmp.w     #3,d4
		ble       fc_co12
		tst.w     d3
		bne.s     fc_co23
		tst.w     -28(a6)
		bne.s     fc_co23
		moveq.l   #1,d3
		move.w    -24(a6),-22(a6)
		move.w    #1,-28(a6)
fc_co23:
		move.w    d3,d0
		subq.w    #1,d3
		tst.w     d0
		bne       fc_co11
		move.w    #-1,(a7)
		move.w    #-1,-(a7)
		move.l    #$01000000,-(a7)
		move.l    d7,-(a7)
		move.w    #18,-(a7)
		jsr _trp14int
		adda.w    #12,a7
		move.w    -12(a6),(a7)
		move.l    #$00010000,-(a7)
		move.l    d7,-(a7)
		move.w    #3,-(a7)
		jsr _fc_rwsec
		adda.w    #10,a7
fc_co24:
		move.l    d6,(a7)
		jsr _dos_free
		move.l    d7,(a7)
		jsr _dos_free
fc_co25:
		dc.w      $FC3F

	xdef _fc_rwsec
_fc_rwsec: ds.b 0
		link      a6,#0
		movem.l   d6-d7,-(a7)
fc_rw1:
		move.l    16(a6),-(a7)
		move.w    14(a6),-(a7)
		move.l    10(a6),-(a7)
		move.w    8(a6),-(a7)
		move.w    #4,-(a7)
		jsr _trp13
		adda.w    #14,a7
		move.w    d0,d7
		beq.s     fc_rw2
		move.w    #28,(a7)
		jsr _do1_alert
		move.w    d0,d7
		cmp.w     #1,d7
		beq.s     fc_rw1
fc_rw2:
		move.w    d7,d0
		dc.w      $F021

	xdef _fc_clfix
_fc_clfix: ds.b 0
		link      a6,#-4
		movem.l   d5-d7,-(a7)
		move.w    #$0FF7,-4(a6)
		move.w    8(a6),d7
		lsr.w     #1,d7
		add.w     8(a6),d7
		move.w    d7,d0
		lsl.w     #1,d0
		swap      d0
		clr.w     d0
		swap      d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.w    (a0),d6
		and.w     #$00FF,d6
		movea.l   10(a6),a0
		move.w    d7,d1
		addq.w    #1,d1
		lsl.w     #1,d1
		swap      d1
		clr.w     d1
		swap      d1
		clr.w     d0
		move.w    0(a0,d1.l),d0
		lsl.w     #8,d0
		or.w      d0,d6
		btst      #0,9(a6)
		beq.s     fc_cl1
		and.w     #15,d6
		move.w    -4(a6),d0
		lsl.w     #4,d0
		move.w    d0,-4(a6)
		bra.s     fc_cl2
fc_cl1:
		and.w     #$F000,d6
fc_cl2:
		move.w    d6,d0
		or.w      -4(a6),d0
		move.w    d0,-4(a6)
		move.w    d7,d0
		lsl.w     #1,d0
		swap      d0
		clr.w     d0
		swap      d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.w    -4(a6),(a0)
		move.w    -4(a6),d0
		lsr.w     #8,d0
		move.w    d7,d1
		addq.w    #1,d1
		lsl.w     #1,d1
		swap      d1
		clr.w     d1
		swap      d1
		add.l     10(a6),d1
		movea.l   d1,a1
		move.w    d0,(a1)
		dc.w      $F031

	xdef _do1_alert
_do1_alert: ds.b 0
		link      a6,#-4
		clr.l     (a7)
		move.w    8(a6),-(a7)
		move.w    #1,-(a7)
		jsr _fun_alert
		addq.l    #4,a7
		dc.w      $F001

	xdef _fc_bar
_fc_bar: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a4-a5,-(a7)
		move.w    12(a6),d7
		tst.w     d7
		beq.s     fc_b1
		moveq.l   #22,d7
		bra.s     fc_b2
fc_b1:
		moveq.l   #20,d7
fc_b2:
		move.w    d7,d0
		muls.w    #24,d0
		movea.l   d0,a5
		adda.l    8(a6),a5
		adda.l    #20,a5
		move.w    d7,d0
		muls.w    #24,d0
		movea.l   d0,a4
		adda.l    8(a6),a4
		adda.l    #12,a4
		move.w    (a5),d6
		add.w     _w_inc,d6
		cmp.w     _bar_max,d6
		bge.s     fc_b3
		move.w    d6,d0
		bra.s     fc_b4
fc_b3:
		move.w    _bar_max,d0
fc_b4:
		move.w    d0,d6
		move.w    d6,(a5)
		move.l    #$00FF1121,(a4)
		move.w    d7,(a7)
		move.l    8(a6),-(a7)
		jsr _fc_draw
		addq.l    #4,a7
		move.l    #$00FF1101,(a4)
		dc.w      $FC31

	xdef _fc_draw
_fc_draw: ds.b 0
		link      a6,#-12
		move.w    #4,(a7)
		move.w    12(a6),d0
		muls.w    #24,d0
		add.l     8(a6),d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		pea.l     -8(a6)
		jsr _LWCOPY
		addq.l    #8,a7
		pea.l     -6(a6)
		pea.l     -8(a6)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _objc_offset
		adda.w    #14,a7
		move.l    -4(a6),-(a7)
		addq.w    #2,(a7)
		move.l    -8(a6),-(a7)
		move.w    #8,-(a7)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _objc_draw
		adda.w    #16,a7
		dc.w      $F001

	data

ttable:
	dc.w $0018,$0007
	dc.w $0012,$0004
	dc.w $0005,$000b
	dc.w $000c
skew2: dc.w $0003
	dc.w $0004,$0005
	dc.w $0006,$0007
	dc.w $0008,$0009
	dc.w $0001,$0002

xfeb9e2:
	dc.l 4
	dc.l 5
	dc.l 7
	dc.l 18
	dc.l 23
	dc.l 24
	dc.l 0
	dc.l fc_st20
	dc.l fc_st20
	dc.l fc_st32
	dc.l fc_st19
	dc.l fc_st23
	dc.l fc_st33
	dc.l fc_st28

nostr: dc.b 0

drive_a: dc.b 65,0
drive_b: dc.b 66,0

	bss
	xdef _w_inc
	comm _w_inc,2
	xdef _bar_max
	comm _bar_max,2
