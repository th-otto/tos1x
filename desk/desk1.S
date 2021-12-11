	xdef _xfd59a0
_xfd59a0: ds.b 0
		link      a6,#-10
		movem.l   d6-d7/a4-a5,-(a7)
		movea.l   _thedesk,a4
		move.w    _gl_height,(a7)
		move.w    _gl_width,-(a7)
		clr.l     -(a7)
		move.w    #1,-(a7)
		jsr       _xfd9eca
		addq.l    #8,a7
		move.w    #4,(a7) ; Getrez
		dc.w      0xF0EC ; trp14
		move.w    d0,-8(a6)
		cmpi.w    #2,-8(a6)
		beq.s     xfd59_1
		cmpi.w    #4,-8(a6)
		bne.s     xfd59_2
xfd59_1:
		move.l    #0x00001143,d0
		bra.s     xfd59_3
xfd59_2:
		move.l    #0x00001173,d0
xfd59_3:
		move.l    d0,24236(a4)
		clr.w     d0
		move.w    d0,-4(a6)
		move.w    d0,-2(a6)
		movea.l   23114(a4),a5
		bra       xfd59_6
xfd59_8:
		btst      #2,5(a5)
		beq       xfd59_5
		move.l    13820(a4),-(a7)
		move.l    24(a5),-(a7)
		move.w    #1,-(a7)
		jsr       _xfd9f56
		adda.w    #10,a7
		move.w    d0,d7
		tst.w     d7
		beq       xfd59_7
		cmpi.w    #2,6(a5)
		bne.s     xfd59_4
		move.w    #0x8000,d0
		move.w    22(a5),d1
		add.w     #0xFFBF,d1
		lsr.w     d1,d0
		move.w    d0,-6(a6)
		move.w    -6(a6),d0
		or.w      d0,-2(a6)
xfd59_4:
		move.w    d7,8(a5)
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		clr.w     24210(a0)
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		clr.w     24208(a0)
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #31,24206(a0)
		movea.l   a4,a0
		movea.w   d7,a1
		adda.l    a1,a1
		adda.l    a1,a0
		move.w    18(a5),9686(a0)
		move.l    a4,d0
		move.w    d7,d1
		muls.w    #34,d1
		add.l     d1,d0
		add.l     #0x0000034E,d0
		movea.l   a4,a1
		move.w    d7,d2
		muls.w    #24,d2
		adda.l    d2,a1
		move.l    d0,24212(a1)
		move.l    a4,d0
		move.w    d7,d1
		muls.w    #34,d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #0x0000034E,(a7)
		move.l    a4,d0
		move.w    18(a5),d1
		muls.w    #34,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #0x00005B1A,(a7)
		move.w    #34,-(a7)
		dc.w      0xF390 ; movs
		addq.l    #6,a7
		move.w    13820(a4),d0
		movea.l   a4,a1
		move.w    d7,d2
		muls.w    #34,d2
		adda.l    d2,a1
		move.w    868(a1),d1
		sub.w     d1,d0
		ext.l     d0
		divs.w    #2,d0
		movea.l   a4,a1
		move.w    d7,d2
		muls.w    #34,d2
		adda.l    d2,a1
		move.w    d0,864(a1)
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #34,d1
		adda.l    d1,a0
		move.l    10(a5),854(a0)
		move.w    22(a5),d0
		and.w     #0x00FF,d0
		movea.l   a4,a1
		move.w    d7,d2
		muls.w    #34,d2
		adda.l    d2,a1
		or.w      d0,858(a1)
xfd59_5:
		movea.l   (a5),a5
xfd59_6:
		move.l    a5,d0
		bne       xfd59_8
xfd59_7:
		move.w    -4(a6),(a7)
		move.w    -2(a6),-(a7)
		dc.w      0xF394 ; ap_bvset
		addq.l    #2,a7
		dc.w      0xFC21 ; movem.l (a7)+,d7/a4-a5

	xdef _xfd5b36
_xfd5b36: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a3-a5,-(a7)
		movea.l   14(a6),a5
		movea.l   a5,a3
		move.l    a3,d0
		beq.s     xfd5b_5
xfd5b_1:
		tst.b     (a3)+
		bne.s     xfd5b_1
		bra.s     xfd5b_3
xfd5b_2:
		subq.l    #1,a3
xfd5b_3:
		cmpa.l    a5,a3
		bcs.s     xfd5b_4
		cmpi.b    #0x5c,(a3)
		bne.s     xfd5b_2
xfd5b_4:
		addq.l    #1,a3
xfd5b_5:
		movea.l   _thedesk,a0
		movea.l   23114(a0),a4
		bra       xfd5b_13
xfd5b_6:
		tst.w     8(a6)
		beq.s     xfd5b_8
		move.w    8(a4),d0
		cmp.w     12(a6),d0
		bne.s     xfd5b_7
		move.l    a4,d0
		bra.w     xfd5b_14
xfd5b_7:
		bra.w     xfd5b_12
xfd5b_8:
		move.w    6(a4),d0
		cmp.w     10(a6),d0
		bne.s     xfd5b_12
		btst      #2,5(a4)
		bne.s     xfd5b_12
		move.l    a3,(a7)
		move.l    14(a4),-(a7)
		dc.w      0xF398 ; wildcmp
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd5b_9
		movea.l   18(a6),a0
		clr.w     (a0)
		move.l    a4,d0
		bra.s     xfd5b_14
xfd5b_9:
		movea.l   10(a4),a0
		cmpi.b    #'*',(a0)
		bne.s     xfd5b_10
		move.l    a3,(a7)
		move.l    10(a4),-(a7)
		dc.w      0xF398 ; wildcmp
		addq.l    #4,a7
		move.w    d0,d7
		bra.s     xfd5b_11
xfd5b_10:
		move.l    a5,(a7)
		move.l    10(a4),-(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		move.w    d0,d7
		tst.w     d7
		bne.s     xfd5b_11
		move.l    a3,(a7)
		move.l    10(a4),-(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		move.w    d0,d7
xfd5b_11:
		tst.w     d7
		beq.s     xfd5b_12
		movea.l   18(a6),a0
		move.w    #1,(a0)
		move.l    a4,d0
		bra.s     xfd5b_14
xfd5b_12:
		movea.l   (a4),a4
xfd5b_13:
		move.l    a4,d0
		bne       xfd5b_6
		clr.l     d0
xfd5b_14:
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	xdef _xfd5bfe
_xfd5bfe: ds.b 0
		link      a6,#0
		movem.l   d3-d7,-(a7)
		move.w    12(a6),d7
		move.w    14(a6),d6
		move.w    16(a6),d5
		move.w    d5,(a7)
		move.w    d6,-(a7)
		move.w    #2,-(a7)
		move.w    d7,-(a7)
		move.l    8(a6),-(a7)
		dc.w      0xF2B4 ; objc_find
		adda.w    #10,a7
		move.w    d0,d4
		cmp.w     d7,d4
		beq.s     xfd5bf_1
		cmp.w     #-1,d4
		beq.s     xfd5bf_1
		move.l    #0x00010001,(a7)
		move.w    d5,-(a7)
		move.w    d6,-(a7)
		move.w    d4,-(a7)
		move.w    d7,-(a7)
		move.l    8(a6),-(a7)
		jsr       _xfd6228
		adda.w    #12,a7
		move.w    d0,d4
xfd5bf_1:
		move.w    d4,d0
		dc.w      0xF03D ; movem.l (a7)+,d4-d7

	xdef _xfd5c50
_xfd5c50: ds.b 0
		link      a6,#-4
		movem.l   d5-d7/a3-a5,-(a7)
		movea.l   _thedesk,a3
		movea.l   8(a6),a5
		clr.w     d7
		movea.l   a5,a0
		move.w    12(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    2(a0),d6
		bra       xfd5c_6
xfd5c_1:
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		btst      #0,11(a0)
		beq       xfd5c_5
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),-2(a6)
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),-4(a6)
		move.l    a5,d0
		move.w    d6,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #18,(a7)
		move.l    a5,d0
		move.w    d6,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		movea.l   18(a6),a0
		movea.w   d7,a1
		adda.w    a1,a1
		addq.w    #1,a1
		adda.l    a1,a1
		move.w    0(a0,a1.l),-(a7)
		move.w    16(a6),d0
		add.w     d0,(a7)
		movea.l   18(a6),a0
		movea.w   d7,a1
		adda.w    a1,a1
		adda.w    a1,a1
		move.w    0(a0,a1.w),-(a7)
		move.w    14(a6),d0
		add.w     d0,(a7)
		dc.w      0xF2BC ; app_mtoi
		addq.l    #8,a7
		movea.l   23114(a3),a4
		bra.s     xfd5c_4
xfd5c_2:
		cmp.w     8(a4),d6
		bne.s     xfd5c_3
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),24(a4)
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),26(a4)
xfd5c_3:
		movea.l   (a4),a4
xfd5c_4:
		move.l    a4,d0
		bne.s     xfd5c_2
		move.l    13820(a3),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		clr.w     -(a7)
		dc.w      0xF2C0
		adda.w    #10,a7
		move.l    13820(a3),-(a7)
		move.w    d6,d0
		muls.w    #24,d0
		move.w    18(a5,d0.l),-(a7)
		move.w    d6,d0
		muls.w    #24,d0
		move.w    16(a5,d0.l),-(a7)
		clr.w     -(a7)
		dc.w      0xF2C0
		adda.w    #10,a7
		addq.w    #1,d7
xfd5c_5:
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    (a0),d6
xfd5c_6:
		cmp.w     12(a6),d6
		bgt       xfd5c_1
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef _xfd5d7c
_xfd5d7c: ds.b 0
		link      a6,#-2
		movem.l   d2-d7/a4-a5,-(a7)
		movea.l   10(a6),a5
		movea.l   14(a6),a4
		move.w    #10000,d5
		move.w    d5,d6
		clr.w     d4
		clr.w     d3
		clr.w     d7
		bra.w     xfd5d_6
xfd5d_1:
		move.w    d7,d0
		asl.w     #1,d0
		move.w    d0,-2(a6)
		movea.l   a5,a0
		movea.w   -2(a6),a1
		adda.l    a1,a1
		adda.l    a1,a0
		cmp.w     (a0),d6
		ble.s     xfd5d_2
		movea.l   a5,a0
		movea.w   -2(a6),a1
		adda.l    a1,a1
		adda.l    a1,a0
		move.w    (a0),d6
xfd5d_2:
		movea.l   a5,a0
		movea.w   -2(a6),a1
		addq.w    #1,a1
		adda.l    a1,a1
		adda.l    a1,a0
		cmp.w     (a0),d5
		ble.s     xfd5d_3
		movea.l   a5,a0
		movea.w   -2(a6),a1
		addq.w    #1,a1
		adda.l    a1,a1
		adda.l    a1,a0
		move.w    (a0),d5
xfd5d_3:
		movea.l   a5,a0
		movea.w   -2(a6),a1
		adda.l    a1,a1
		adda.l    a1,a0
		cmp.w     (a0),d4
		bge.s     xfd5d_4
		movea.l   a5,a0
		movea.w   -2(a6),a1
		adda.l    a1,a1
		adda.l    a1,a0
		move.w    (a0),d4
xfd5d_4:
		movea.l   a5,a0
		movea.w   -2(a6),a1
		addq.w    #1,a1
		adda.l    a1,a1
		adda.l    a1,a0
		cmp.w     (a0),d3
		bge.s     xfd5d_5
		movea.l   a5,a0
		movea.w   -2(a6),a1
		addq.w    #1,a1
		adda.l    a1,a1
		adda.l    a1,a0
		move.w    (a0),d3
xfd5d_5:
		addq.w    #1,d7
xfd5d_6:
		cmp.w     8(a6),d7
		blt.s     xfd5d_1
		move.w    d3,(a7)
		move.w    d5,d0
		sub.w     d0,(a7)
		addq.w    #1,(a7)
		move.w    d4,-(a7)
		move.w    d6,d0
		sub.w     d0,(a7)
		addq.w    #1,(a7)
		move.w    d5,-(a7)
		move.w    d6,-(a7)
		move.l    a4,-(a7)
		dc.w      0xF298 ; r_set
		adda.w    #10,a7
		dc.w      0xFC3F ; movem.l (a7)+,d3-d7/a4-a5

	xdef _xfd5e3a
_xfd5e3a: ds.b 0
		link      a6,#0
		movem.l   d4-d7/a4-a5,-(a7)
		movea.l   14(a6),a5
		move.w    18(a6),d7
		movea.l   20(a6),a4
		clr.l     (a7)
		move.w    #256,-(a7)
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		clr.w     d6
		bra.s     xfd5e3_2
xfd5e3_1:
		move.w    d6,d5
		asl.w     #1,d5
		move.l    a5,(a7)
		move.w    12(a6),-(a7)
		movea.w   d5,a0
		addq.w    #1,a0
		adda.l    a0,a0
		move.w    0(a4,a0.l),-(a7)
		move.w    10(a6),d0
		add.w     d0,(a7)
		movea.w   d5,a0
		adda.l    a0,a0
		move.w    0(a4,a0.l),-(a7)
		move.w    8(a6),d0
		add.w     d0,(a7)
		dc.w      0xF2C8 ; gsx_pline
		addq.l    #6,a7
		addq.w    #1,d6
xfd5e3_2:
		cmp.w     d7,d6
		blt.s     xfd5e3_1
		clr.l     (a7)
		move.w    #257,-(a7)
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		dc.w      0xFC39 ; movem.l (a7)+,d5-d7/a4-a5

	xdef _xfd5e9a
_xfd5e9a: ds.b 0
		link      a6,#-16
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   18(a6),a4
		movea.l   24(a6),a3
		move.l    a3,(a7)
		move.w    22(a6),-(a7)
		move.l    a4,-(a7)
		move.w    16(a6),-(a7)
		move.l    (a5),-(a7)
		jsr       _xfd5e3a
		adda.w    #12,a7
		pea.l     -14(a6)
		pea.l     -12(a6)
		pea.l     -4(a6)
		pea.l     -6(a6)
		pea.l     -8(a6)
		pea.l     -10(a6)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.w     -(a7)
		move.l    #0x00020002,-(a7)
		move.l    12(a6),-(a7)
		move.w    #1,-(a7)
		move.l    #0x00010000,-(a7)
		move.l    #0x00060001,-(a7)
		dc.w      0xF2D0 ; evnt_multi
		adda.w    #60,a7
		move.w    d0,-16(a6)
		btst      #1,-15(a6)
		beq.s     xfd5e9_1
		clr.w     d0
		bra.s     xfd5e9_2
xfd5e9_1:
		moveq.l   #1,d0
xfd5e9_2:
		move.w    d0,-2(a6)
		move.l    a3,(a7)
		move.w    22(a6),-(a7)
		move.l    a4,-(a7)
		move.w    16(a6),-(a7)
		move.l    (a5),-(a7)
		jsr       _xfd5e3a
		adda.w    #12,a7
		move.w    -2(a6),d0
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef _xfd5f34
_xfd5f34: ds.b 0
		link      a6,#-60
		movem.l   d5-d7/a3-a5,-(a7)
		move.w    16(a6),d7
		move.w    22(a6),d6
		movea.l   36(a6),a5
		movea.l   40(a6),a4
		pea.l     -60(a6)
		move.l    18(a6),-(a7)
		move.w    d7,-(a7)
		jsr       _xfd5d7c
		adda.w    #10,a7
		pea.l     -52(a6)
		move.l    24(a6),-(a7)
		move.w    d6,-(a7)
		jsr       _xfd5d7c
		adda.w    #10,a7
		move.w    -56(a6),d0
		add.w     d0,-48(a6)
		move.w    -54(a6),d0
		add.w     d0,-46(a6)
		clr.w     -18(a6)
		bra.s     xfd5f_2
xfd5f_1:
		move.w    -18(a6),d0
		asl.w     #1,d0
		move.w    d0,-20(a6)
		move.w    -52(a6),d0
		movea.w   -20(a6),a1
		adda.l    a1,a1
		adda.l    24(a6),a1
		sub.w     d0,(a1)
		move.w    -50(a6),d0
		movea.w   -20(a6),a1
		addq.w    #1,a1
		adda.l    a1,a1
		adda.l    24(a6),a1
		sub.w     d0,(a1)
		addq.w    #1,-18(a6)
xfd5f_2:
		cmp.w     -18(a6),d6
		bgt.s     xfd5f_1
		move.w    8(a6),d0
		sub.w     -52(a6),d0
		move.w    d0,-30(a6)
		move.w    10(a6),d0
		sub.w     -50(a6),d0
		move.w    d0,-32(a6)
		clr.w     -22(a6)
		clr.l     -8(a6)
		clr.w     -24(a6)
		clr.w     -26(a6)
xfd5f_3:
		move.l    #_gl_rscreen,(a7)
		dc.w      0xF0C0 ; gsx_sclip
		move.w    #1,(a7)
		move.w    #3,-(a7)
		clr.w     -(a7)
		jsr       _gsx_fattr
		addq.l    #4,a7
		pea.l     -38(a6)
		pea.l     -36(a6)
		pea.l     10(a6)
		pea.l     8(a6)
		dc.w      0xF2DC ; graf_mkstate
		adda.w    #16,a7
		move.w    8(a6),d0
		sub.w     -30(a6),d0
		move.w    d0,-52(a6)
		move.w    10(a6),d0
		sub.w     -32(a6),d0
		move.w    d0,-50(a6)
		pea.l     -52(a6)
		move.l    12(a6),-(a7)
		dc.w      0xF2E0 ; rc_constrain
		addq.l    #8,a7
		move.l    24(a6),(a7)
		move.w    d6,-(a7)
		move.l    18(a6),-(a7)
		move.w    d7,-(a7)
		move.l    8(a6),-(a7)
		pea.l     -52(a6)
		jsr       _xfd5e9a
		adda.w    #16,a7
		move.w    d0,-34(a6)
		move.l    8(a6),-(a7)
		dc.w      0xF2E8 ; wind_find
		addq.l    #4,a7
		move.w    d0,-28(a6)
		movea.l   _thedesk,a0
		move.l    24108(a0),-4(a6)
		move.w    #1,-14(a6)
		tst.w     -28(a6)
		beq.s     xfd5f_5
		move.w    -28(a6),(a7)
		dc.w      0xF2EC
		move.l    d0,-12(a6)
		tst.l     -12(a6)
		beq.s     xfd5f_4
		movea.l   _thedesk,a0
		move.l    24108(a0),-4(a6)
		movea.l   -12(a6),a0
		move.w    10(a0),-14(a6)
		bra.s     xfd5f_5
xfd5f_4:
		clr.w     -28(a6)
xfd5f_5:
		move.l    8(a6),-(a7)
		move.w    -14(a6),-(a7)
		move.l    -4(a6),-(a7)
		dc.w      0xF2F0 ; xfd5bfe
		adda.w    #10,a7
		move.w    d0,(a4)
		move.w    (a4),d0
		cmp.w     -14(a6),d0
		beq.s     xfd5f_6
		cmpi.w    #-1,(a4)
		bne.s     xfd5f_8
xfd5f_6:
		tst.w     -26(a6)
		beq.s     xfd5f_7
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.l    12(a6),-(a7)
		move.w    -26(a6),-(a7)
		move.w    -24(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    -22(a6),-(a7)
		jsr       _xfd637e
		adda.w    #20,a7
		clr.w     -22(a6)
		clr.l     -8(a6)
		clr.w     -24(a6)
		clr.w     -26(a6)
xfd5f_7:
		bra       xfd5f_11
xfd5f_8:
		move.w    (a4),d0
		cmp.w     -26(a6),d0
		beq       xfd5f_11
		tst.w     -26(a6)
		beq.s     xfd5f_9
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.l    12(a6),-(a7)
		move.w    -26(a6),-(a7)
		move.w    -24(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    -22(a6),-(a7)
		jsr       _xfd637e
		adda.w    #20,a7
		clr.w     -22(a6)
		clr.l     -8(a6)
		clr.w     -24(a6)
		clr.w     -26(a6)
xfd5f_9:
		move.w    (a4),d0
		muls.w    #24,d0
		add.l     -4(a6),d0
		add.l     #10,d0
		movea.l   d0,a0
		move.w    (a0),-16(a6)
		btst      #0,-15(a6)
		bne.s     xfd5f_11
		pea.l     -40(a6)
		pea.l     -44(a6)
		move.w    (a4),-(a7)
		move.w    -28(a6),-(a7)
		jsr       _xfdb04c
		adda.w    #12,a7
		movea.l   d0,a3
		cmpi.w    #1,6(a3)
		beq.s     xfd5f_10
		cmpi.w    #2,6(a3)
		beq.s     xfd5f_10
		cmpi.w    #4,6(a3)
		beq.s     xfd5f_10
		cmpi.w    #3,6(a3)
		bne.s     xfd5f_11
xfd5f_10:
		move.w    -28(a6),-22(a6)
		move.l    -4(a6),-8(a6)
		move.w    -14(a6),-24(a6)
		move.w    (a4),-26(a6)
		move.w    #1,(a7)
		move.l    #0x00010001,-(a7)
		move.w    #1,-(a7)
		move.l    12(a6),-(a7)
		move.w    -26(a6),-(a7)
		move.w    -24(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    -22(a6),-(a7)
		jsr       _xfd637e
		adda.w    #20,a7
xfd5f_11:
		tst.w     -34(a6)
		bne       xfd5f_3
		tst.w     -26(a6)
		beq.s     xfd5f_12
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.l    12(a6),-(a7)
		move.w    -26(a6),-(a7)
		move.w    -24(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    -22(a6),-(a7)
		jsr       _xfd637e
		adda.w    #20,a7
xfd5f_12:
		movea.l   28(a6),a0
		move.w    -52(a6),(a0)
		movea.l   32(a6),a0
		move.w    -50(a6),(a0)
		move.w    -28(a6),(a5)
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef _xfd6228
_xfd6228: ds.b 0
		link      a6,#-18
		movem.l   d5-d7/a3-a5,-(a7)
		lea.l     -18(a6),a3
		movea.l   8(a6),a5
		movea.l   a5,a0
		move.w    12(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),d7
		movea.l   a5,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),d0
		add.w     d0,d7
		movea.l   a5,a0
		move.w    12(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),d6
		movea.l   a5,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),d0
		add.w     d0,d6
		cmpi.w    #1,12(a6)
		bne.s     xfd62_1
		clr.w     d0
		bra.s     xfd62_2
xfd62_1:
		movea.l   _thedesk,a0
		move.w    12292(a0),d0
xfd62_2:
		move.w    d0,-2(a6)
		move.w    -2(a6),d0
		bra       xfd62_7
xfd62_3:
		move.w    _gl_hchar,(a7)
		move.w    _gl_wchar,d0
		muls.w    #45,d0
		move.w    d0,-(a7)
		move.w    d6,-(a7)
		move.w    d7,-(a7)
		pea.l     -10(a6)
		dc.w      0xF298 ; r_set
		adda.w    #10,a7
		move.l    20(a6),-(a7)
		move.l    16(a6),-(a7)
		move.l    a3,-(a7)
		dc.w      0xF298 ; r_set
		adda.w    #12,a7
		move.l    a3,(a7)
		pea.l     -10(a6)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd62_4
		move.w    12(a6),d0
		bra       xfd62_9
xfd62_4:
		bra       xfd62_8
xfd62_5:
		move.l    20(a6),-(a7)
		move.w    18(a6),-(a7)
		move.w    d6,d0
		sub.w     d0,(a7)
		move.w    16(a6),-(a7)
		move.w    d7,d0
		sub.w     d0,(a7)
		pea.l     -10(a6)
		dc.w      0xF298 ; r_set
		adda.w    #12,a7
		move.l    20(a6),-(a7)
		move.w    18(a6),-(a7)
		move.w    d6,d0
		sub.w     d0,(a7)
		move.w    16(a6),-(a7)
		move.w    d7,d0
		sub.w     d0,(a7)
		move.l    a3,-(a7)
		dc.w      0xF298 ; r_set
		adda.w    #12,a7
		movea.w   14(a6),a0
		adda.l    a0,a0
		adda.l    _thedesk,a0
		move.w    9686(a0),d0
		muls.w    #34,d0
		movea.l   d0,a4
		adda.l    _thedesk,a4
		adda.l    #23118,a4
		pea.l     -10(a6)
		pea.l     26(a4)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfd62_6
		move.l    a3,(a7)
		pea.l     18(a4)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd62_6
		move.w    12(a6),d0
		bra.s     xfd62_9
xfd62_6:
		bra.s     xfd62_8
xfd62_7:
		tst.w     d0
		beq       xfd62_5
		cmp.w     #1,d0
		beq       xfd62_3
xfd62_8:
		move.w    14(a6),d0
xfd62_9:
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef _xfd637e
_xfd637e: ds.b 0
		link      a6,#-10
		movem.l   d5-d7/a3-a5,-(a7)
		movea.l   18(a6),a5
		move.w    22(a6),d7
		lea.l     -10(a6),a3
		movea.l   10(a6),a4
		movea.l   a4,a0
		move.w    16(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    10(a0),d6
		move.w    d6,-2(a6)
		tst.w     28(a6)
		beq.s     xfd63_1
		btst      #3,d6
		beq.s     xfd63_1
		clr.w     d0
		bra       xfd63_5
xfd63_1:
		move.l    a3,(a7)
		move.l    a4,d0
		move.w    16(a6),d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		dc.w      0xF250 ; rc_copy
		addq.l    #4,a7
		movea.l   a4,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),d0
		add.w     d0,(a3)
		movea.l   a4,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),d0
		add.w     d0,2(a3)
		tst.w     24(a6)
		beq.s     xfd63_2
		or.w      d7,d6
		bra.s     xfd63_3
xfd63_2:
		move.w    d7,d0
		not.w     d0
		and.w     d0,d6
xfd63_3:
		cmp.w     -2(a6),d6
		beq.s     xfd63_4
		clr.w     (a7)
		move.w    d6,-(a7)
		move.l    4(a5),-(a7)
		move.l    (a5),-(a7)
		clr.w     -(a7)
		move.w    16(a6),-(a7)
		move.l    10(a6),-(a7)
		dc.w      0xF300 ; objc_change
		adda.w    #18,a7
		tst.w     26(a6)
		beq.s     xfd63_4
		move.l    a3,(a7)
		move.l    a5,-(a7)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd63_4
		move.l    4(a3),-(a7)
		move.l    (a3),-(a7)
		move.w    8(a6),-(a7)
		dc.w      0xF2C0
		adda.w    #10,a7
xfd63_4:
		moveq.l   #1,d0
xfd63_5:
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef _xfd6452
_xfd6452: ds.b 0
		link      a6,#-20
		movem.l   d5-d7/a3-a5,-(a7)
		lea.l     -12(a6),a4
		lea.l     -20(a6),a3
		movea.l   10(a6),a5
		movea.l   a5,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),-2(a6)
		movea.l   a5,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),-4(a6)
		clr.w     4(a3)
		clr.w     6(a3)
		movea.l   a5,a0
		move.w    14(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    2(a0),d7
		bra       xfd64_6
xfd64_1:
		cmp.w     16(a6),d7
		beq       xfd64_5
		move.l    a4,(a7)
		move.l    a5,d0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		dc.w      0xF250 ; rc_copy
		addq.l    #4,a7
		move.w    -2(a6),d0
		add.w     d0,(a4)
		move.w    -4(a6),d0
		add.w     d0,2(a4)
		move.l    a4,(a7)
		move.l    18(a6),-(a7)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		beq       xfd64_5
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.w    d7,-(a7)
		move.w    14(a6),-(a7)
		move.l    10(a6),-(a7)
		jsr       _xfd6228
		adda.w    #16,a7
		cmp.w     14(a6),d0
		beq       xfd64_5
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    10(a0),d6
		tst.w     28(a6)
		beq.s     xfd64_2
		or.w      26(a6),d6
		bra.s     xfd64_3
xfd64_2:
		move.w    26(a6),d0
		not.w     d0
		and.w     d0,d6
xfd64_3:
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		cmp.w     10(a0),d6
		beq.s     xfd64_5
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    d6,10(a0)
		move.l    a4,(a7)
		move.l    a5,d0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		dc.w      0xF250 ; rc_copy
		addq.l    #4,a7
		move.w    -2(a6),d0
		add.w     d0,(a4)
		move.w    -4(a6),d0
		add.w     d0,2(a4)
		tst.w     4(a3)
		beq.s     xfd64_4
		move.l    a3,(a7)
		move.l    a4,-(a7)
		dc.w      0xF304 ; rc_union
		addq.l    #4,a7
		bra.s     xfd64_5
xfd64_4:
		move.l    a3,(a7)
		move.l    a4,-(a7)
		dc.w      0xF250 ; rc_copy
		addq.l    #4,a7
xfd64_5:
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    (a0),d7
xfd64_6:
		cmp.w     14(a6),d7
		bgt       xfd64_1
		tst.w     30(a6)
		beq.s     xfd64_8
		move.l    a3,(a7)
		move.l    22(a6),-(a7)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd64_8
		move.l    4(a3),-(a7)
		move.l    (a3),-(a7)
		move.w    8(a6),-(a7)
		dc.w      0xF2C0
		adda.w    #10,a7
xfd64_8:
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef _xfd65ba
_xfd65ba: ds.b 0
		link      a6,#-4
		movem.l   d3-d7/a4-a5,-(a7)
		move.w    8(a6),d7
		move.l    10(a6),d6
		move.w    14(a6),d5
		movea.l   22(a6),a5
		move.w    20(a6),d0
		and.w     #3,d0
		move.w    d0,-2(a6)
		move.l    16(a6),-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		dc.w      0xF2F0 ; xfd5bfe
		adda.w    #10,a7
		move.w    d0,d4
		cmp.w     d5,d4
		beq.s     xfd65_1
		cmp.w     #-1,d4
		bne.s     xfd65_4
xfd65_1:
		tst.w     -2(a6)
		beq.s     xfd65_2
		tst.w     26(a6)
		beq.s     xfd65_3
xfd65_2:
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.l    a5,-(a7)
		move.l    #_gl_rfull,-(a7)
		move.w    d4,-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		move.w    d7,-(a7)
		jsr       _xfd6452
		adda.w    #24,a7
xfd65_3:
		bra       xfd65_10
xfd65_4:
		movea.l   d6,a4
		movea.l   a4,a0
		move.w    d4,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    10(a0),-4(a6)
		tst.w     -2(a6)
		bne.s     xfd65_7
		tst.w     26(a6)
		bne.s     xfd65_5
		btst      #0,-3(a6)
		bne.s     xfd65_6
xfd65_5:
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.l    a5,-(a7)
		move.l    #_gl_rfull,-(a7)
		move.w    d4,-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		move.w    d7,-(a7)
		jsr       _xfd6452
		adda.w    #24,a7
		ori.w     #1,-4(a6)
xfd65_6:
		bra.s     xfd65_9
xfd65_7:
		btst      #0,-3(a6)
		beq.s     xfd65_8
		andi.w    #-2,-4(a6)
		bra.s     xfd65_9
xfd65_8:
		ori.w     #1,-4(a6)
xfd65_9:
		move.w    #1,(a7)
		move.w    #1,-(a7)
		move.w    -4(a6),-(a7)
		andi.w    #1,(a7)
		move.w    #1,-(a7)
		move.l    a5,-(a7)
		move.w    d4,-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		move.w    d7,-(a7)
		jsr       _xfd637e
		adda.w    #20,a7
xfd65_10:
		dc.w      0xFC3D ; movem.l (a7)+,d4-d7/a4-a5

	xdef _xfd66ba
_xfd66ba: ds.b 0
		link      a6,#-36
		movem.l   d3-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		move.l    10(a6),d6
		move.w    14(a6),d5
		lea.l     -36(a6),a4
		movea.l   _thedesk,a3
		move.w    #-1,-12(a6)
		movea.l   24(a6),a0
		move.w    d5,(a0)
		move.l    16(a6),-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		dc.w      0xF2F0 ; xfd5bfe
		adda.w    #10,a7
		move.w    d0,-2(a6)
		cmp.w     -2(a6),d5
		beq.s     xfd66_1
		cmpi.w    #-1,-2(a6)
		bne.s     xfd66_2
xfd66_1:
		move.l    #0x00060006,(a7)
		move.l    16(a6),-(a7)
		move.l    a4,-(a7)
		dc.w      0xF298 ; r_set
		addq.l    #8,a7
		pea.l     6(a4)
		pea.l     4(a4)
		move.l    #0x00060006,-(a7)
		move.l    (a4),-(a7)
		dc.w      0xF30C ; graf_rubbox
		adda.w    #16,a7
		move.w    #1,(a7)
		move.l    #0x00010001,-(a7)
		move.w    #1,-(a7)
		move.l    20(a6),-(a7)
		move.l    a4,-(a7)
		move.w    -2(a6),-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		move.w    d7,-(a7)
		jsr       _xfd6452
		adda.w    #24,a7
		bra       xfd66_13
xfd66_2:
		movea.l   d6,a5
		movea.l   a5,a0
		move.w    -2(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		btst      #0,11(a0)
		beq       xfd66_13
		lea.l     13110(a3),a0
		move.l    a0,-28(a6)
		movea.l   d6,a5
		movea.l   a5,a0
		move.w    d5,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    16(a0),-4(a6)
		movea.l   a5,a0
		move.w    d5,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    18(a0),-6(a6)
		clr.w     -18(a6)
		movea.l   a5,a0
		move.w    d5,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    2(a0),d4
		bra.s     xfd66_5
xfd66_3:
		movea.l   a5,a0
		move.w    d4,d1
		muls.w    #24,d1
		adda.l    d1,a0
		btst      #0,11(a0)
		beq.s     xfd66_4
		move.w    -18(a6),d0
		asl.w     #1,d0
		move.w    d0,-20(a6)
		move.w    d4,d0
		muls.w    #24,d0
		move.w    16(a5,d0.l),d0
		add.w     -4(a6),d0
		movea.w   -20(a6),a1
		adda.l    a1,a1
		adda.l    -28(a6),a1
		move.w    d0,(a1)
		move.w    d4,d0
		muls.w    #24,d0
		move.w    18(a5,d0.l),d0
		add.w     -6(a6),d0
		movea.w   -20(a6),a1
		addq.w    #1,a1
		adda.l    a1,a1
		adda.l    -28(a6),a1
		move.w    d0,(a1)
		addq.w    #1,-18(a6)
xfd66_4:
		cmpi.w    #60,-18(a6)
		bge.s     xfd66_6
		movea.l   a5,a0
		move.w    d4,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    (a0),d4
xfd66_5:
		cmp.w     d5,d4
		bgt.s     xfd66_3
xfd66_6:
		move.w    -18(a6),-8(a6)
		tst.w     -8(a6)
		beq       xfd66_13
		cmp.w     #1,d5
		bne.s     xfd66_7
		clr.w     d0
		bra.s     xfd66_8
xfd66_7:
		move.w    12292(a3),d0
xfd66_8:
		move.w    d0,-22(a6)
		tst.w     -22(a6)
		bne.s     xfd66_9
		move.w    13744(a3),-24(a6)
		lea.l     13748(a3),a0
		move.l    a0,-28(a6)
		bra.s     xfd66_10
xfd66_9:
		move.w    13746(a3),-24(a6)
		lea.l     13784(a3),a0
		move.l    a0,-28(a6)
xfd66_10:
		move.l    24(a6),(a7)
		pea.l     -12(a6)
		pea.l     -16(a6)
		pea.l     -14(a6)
		pea.l     13110(a3)
		move.w    -8(a6),-(a7)
		move.l    -28(a6),-(a7)
		move.w    -24(a6),-(a7)
		move.l    #_gl_rfull,-(a7)
		move.l    16(a6),-(a7)
		jsr       _xfd5f34
		adda.w    #32,a7
		tst.w     -12(a6)
		beq.s     xfd66_12
		cmp.w     -12(a6),d7
		bne.s     xfd66_11
		movea.l   24(a6),a0
		move.w    (a0),d0
		cmp.w     -2(a6),d0
		bne.s     xfd66_11
		move.w    #-1,-12(a6)
xfd66_11:
		bra.s     xfd66_13
xfd66_12:
		tst.w     d7
		bne.s     xfd66_13
		movea.l   24(a6),a0
		cmp.w     (a0),d5
		bne.s     xfd66_13
		pea.l     13110(a3)
		move.w    -16(a6),-(a7)
		move.w    -14(a6),-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		jsr       _xfd5c50
		adda.w    #14,a7
		move.w    #-1,-12(a6)
xfd66_13:
		move.l    #_gl_kstate,(a7)
		pea.l     -10(a6)
		pea.l     18(a6)
		pea.l     16(a6)
		move.l    #0x00010000,-(a7)
		move.w    #1,-(a7)
		dc.w      0xF318 ; evnt_button
		adda.w    #18,a7
		move.w    -12(a6),d0
		dc.w      0xFE3D ; movem.l (a7)+,d4-d7/a3-a5

	xdef _r_slash
_r_slash: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		bra.s     r_slas2
r_slas1:
		addq.l    #1,a5
r_slas2:
		tst.b     (a5)
		bne.s     r_slas1
		bra.s     r_slas4
r_slas3:
		subq.l    #1,a5
r_slas4:
		cmpi.b    #0x5c,(a5)
		bne.s     r_slas3
		move.l    a5,d0
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef _do_finish
_do_finish: ds.b 0
		link      a6,#-12
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.l    8(a6),-(a7)
		dc.w      0xF3A0 ; form_center
		adda.w    #20,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		move.w    #3,-(a7)
		dc.w      0xF3A4 ; form_dial
		adda.w    #16,a7
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _fm_draw
_fm_draw: ds.b 0
		link      a6,#-12
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.l    8(a6),-(a7)
		dc.w      0xF3A0 ; form_center
		adda.w    #20,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.w     -(a7)
		dc.w      0xF3A4 ; form_dial
		adda.w    #16,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		move.w    #8,-(a7)
		clr.w     -(a7)
		move.l    8(a6),-(a7)
		dc.w      0xF3A8 ; objc_draw
		adda.w    #14,a7
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _drawfld
_drawfld: ds.b 0
		link      a6,#-12
		move.w    #4,(a7)
		move.w    12(a6),d0
		muls.w    #24,d0
		add.l     8(a6),d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		pea.l     -8(a6)
		dc.w      0xF1AC ; LWCOPY
		addq.l    #8,a7
		pea.l     -6(a6)
		pea.l     -8(a6)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		dc.w      0xF3AC ; objc_offset
		adda.w    #14,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		clr.w     -(a7)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		dc.w      0xF3A8 ; objc_draw
		adda.w    #16,a7
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _drawclip
_drawclip: ds.b 0
		link      a6,#-12
		move.w    #4,(a7)
		move.w    12(a6),d0
		muls.w    #24,d0
		add.l     8(a6),d0
		move.l    d0,-(a7)
		addi.l    #16,(a7)
		pea.l     -8(a6)
		dc.w      0xF1AC ; LWCOPY
		addq.l    #8,a7
		pea.l     -6(a6)
		pea.l     -8(a6)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		dc.w      0xF130 ; ob_offset
		adda.w    #14,a7
		move.l    a6,(a7)
		subq.l    #8,(a7)
		dc.w      0xF0C0 ; gsx_sclip
		clr.w     (a7)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		dc.w      0xF128 ; ob_draw
		addq.l    #6,a7
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _xtr_mask
_xtr_mask: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		bra.s     xtrm2
xtrm1:
		addq.l    #1,a5
xtrm2:
		cmpi.b    #'*',(a5)
		bne.s     xtrm1
		move.l    a5,(a7)
		move.l    12(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef _rep_all
_rep_all: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.l    a5,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a5
		move.l    a5,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef _xfd6a9c
_xfd6a9c: ds.b 0
		link      a6,#0
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   12(a6),a4
		movea.l   _thedesk,a3
		move.l    a5,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a5
		addq.l    #1,a5
		pea.l     24171(a3)
		move.l    a5,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		move.l    a4,(a7)
		pea.l     24171(a3)
		dc.w      0xF3B4 ; fmt_str
		addq.l    #4,a7
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef _dos_error
_dos_error: ds.b 0
		link      a6,#-4
		tst.w     _DOS_ERR
		beq.s     dos_er2
		cmpi.w    #-36,_DOS_AX
		bne.s     dos_er4
		clr.l     (a7)
		move.l    #0x00010019,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     dos_er1
dos_er4:
		cmpi.w    #-32,_DOS_AX
		bgt.s     dos_er1
		move.w    _DOS_AX,d0
		not.w     d0
		move.w    d0,(a7)
		addi.w    #-30,(a7)
		dc.w      0xF0E8 ; form_error
dos_er1:
		clr.w     d0
		bra.s     dos_er3
dos_er2:
		moveq.l   #1,d0
dos_er3:
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _xfd6b16
_xfd6b16: ds.b 0
		link      a6,#-14
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		clr.l     d7
		clr.l     12566(a5)
		clr.w     24130(a5)
		clr.w     24128(a5)
		movea.l   18(a6),a0
		move.w    (a0),d0
		swap      d0
		clr.w     d0
		swap      d0
		move.l    d0,12970(a5)
		movea.l   22(a6),a0
		move.w    (a0),d0
		swap      d0
		clr.w     d0
		swap      d0
		move.l    d0,12974(a5)
		move.w    8(a6),d0
		bra.w     xfd6b_10
xfd6b_1:
		clr.l     12970(a5)
		clr.l     12974(a5)
		clr.l     12978(a5)
		bra.w     xfd6b_11
xfd6b_2:
		move.w    #8,-6(a6)
		tst.w     13728(a5)
		bne.s     xfd6b_3
		tst.w     13730(a5)
		beq.s     xfd6b_4
xfd6b_3:
		move.w    #1,24130(a5)
xfd6b_4:
		bra.s     xfd6b_6
xfd6b_5:
		move.w    #4,-6(a6)
		tst.w     13728(a5)
		beq.s     xfd6b_6
		move.w    #1,24130(a5)
xfd6b_6:
		dc.w      0xF3B8 ; dos_avail
		move.l    d0,12570(a5)
		tst.l     12570(a5)
		bne.s     xfd6b_7
		move.w    #27,(a7)
		dc.w      0xF3BC ; do1_alert
		clr.w     d0
		bra       xfd6b_13
xfd6b_7:
		move.l    12570(a5),(a7)
		dc.w      0xF3C0 ; dos_alloc
		move.l    d0,12566(a5)
		bra.s     xfd6b_11
xfd6b_8:
		move.w    #5,-6(a6)
		tst.w     13730(a5)
		beq.s     xfd6b_9
		move.w    #1,24130(a5)
xfd6b_9:
		bra.s     xfd6b_11
xfd6b_10:
		tst.w     d0
		beq.s     xfd6b_1
		cmp.w     #1,d0
		beq.s     xfd6b_8
		cmp.w     #2,d0
		beq.s     xfd6b_5
		cmp.w     #3,d0
		beq.s     xfd6b_2
xfd6b_11:
		tst.w     24130(a5)
		beq       xfd6b_12
		move.l    13682(a5),d7
		pea.l     -4(a6)
		move.w    -6(a6),-(a7)
		move.w    #5,-(a7)
		dc.w      0xF0E0 ; rsrc_gaddr
		addq.l    #8,a7
		movea.l   #0x000000B4,a0
		movea.l   0(a0,d7.l),a0
		move.l    -4(a6),(a0)
		movea.l   18(a6),a0
		move.w    (a0),d0
		swap      d0
		clr.w     d0
		swap      d0
		move.l    d0,-10(a6)
		movea.l   22(a6),a0
		move.w    (a0),d0
		swap      d0
		clr.w     d0
		swap      d0
		move.l    d0,-14(a6)
		clr.w     (a7)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		pea.l     24112(a5)
		pea.l     -10(a6)
		dc.w      0xF3C4
		adda.w    #14,a7
		clr.w     (a7)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		pea.l     24116(a5)
		pea.l     -14(a6)
		dc.w      0xF3C4
		adda.w    #14,a7
		move.l    #xfeb13a,(a7)
		move.w    #4,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		addq.l    #6,a7
		move.l    #xfeb13b,(a7)
		move.w    #3,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		addq.l    #6,a7
		movea.l   d7,a0
		adda.l    #104,a0
		move.w    #0x0080,(a0)
		movea.l   d7,a0
		adda.l    #80,a0
		move.w    #0x0080,(a0)
		move.l    d7,(a7)
		dc.w      0xF3CC ; fm_draw
		movea.l   d7,a0
		adda.l    #104,a0
		clr.w     (a0)
		movea.l   d7,a0
		adda.l    #80,a0
		clr.w     (a0)
		move.w    #-1,(a7)
		move.l    d7,-(a7)
		dc.w      0xF3D0 ; form_do
		addq.l    #4,a7
		move.w    #6,(a7)
		move.w    #5,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3D4 ; inf_what
		addq.l    #6,a7
		tst.w     d0
		bne.s     xfd6b_12
		clr.w     d0
		bra.s     xfd6b_13
xfd6b_12:
		moveq.l   #1,d0
xfd6b_13:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef _xfd6cce
_xfd6cce: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a4-a5,-(a7)
		movea.l   14(a6),a5
		movea.l   _thedesk,a4
		move.l    #x00622c,(a7)
		move.l    10(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    #x0062ac,(a7)
		move.l    18(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		btst      #2,_gl_kstate+1
		beq.s     xfd6c_1
		cmpi.w    #2,8(a6)
		bne.s     xfd6c_1
		moveq.l   #3,d0
		bra.s     xfd6c_2
xfd6c_1:
		move.w    8(a6),d0
xfd6c_2:
		move.w    d0,8(a6)
		move.l    26(a6),(a7)
		move.l    22(a6),-(a7)
		move.l    #x0062ac,-(a7)
		move.l    #x00622c,-(a7)
		move.w    8(a6),-(a7)
		jsr       _xfd6b16
		adda.w    #14,a7
		tst.w     d0
		beq       xfd6c_8
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		bra       xfd6c_7
xfd6c_3:
		cmpi.w    #-1,32(a5)
		beq       xfd6c_6
		movea.l   a4,a0
		move.w    32(a5),d1
		muls.w    #24,d1
		adda.l    d1,a0
		btst      #0,24211(a0)
		beq.s     xfd6c_6
		cmpi.b    #16,9(a5)
		bne.s     xfd6c_4
		pea.l     18(a5)
		move.l    #x00622c,-(a7)
		jsr       _xfd75f2
		addq.l    #8,a7
		move.l    26(a6),(a7)
		move.l    22(a6),-(a7)
		move.l    #x0062ac,-(a7)
		move.l    #x00622c,-(a7)
		move.l    d7,-(a7)
		move.w    8(a6),-(a7)
		dc.w      0xF3E0
		adda.w    #18,a7
		move.w    d0,d6
		move.l    #x00622c,(a7)
		jsr       _xfd795c
		bra.s     xfd6c_5
xfd6c_4:
		move.l    10(a5),-(a7)
		move.b    9(a5),d0
		ext.w     d0
		move.w    d0,-(a7)
		pea.l     18(a5)
		move.l    #x0062ac,-(a7)
		move.l    #x00622c,-(a7)
		move.w    8(a6),-(a7)
		jsr       _xfd7316
		adda.w    #20,a7
		move.w    d0,d6
xfd6c_5:
		tst.w     d6
		beq.s     xfd6c_8
xfd6c_6:
		movea.l   (a5),a5
xfd6c_7:
		move.l    a5,d0
		bne       xfd6c_3
xfd6c_8:
		tst.w     24130(a4)
		beq.s     xfd6c_9
		move.l    13682(a4),(a7)
		dc.w      0xF3EC ; do_finish
		bra.s     xfd6c_10
xfd6c_9:
		tst.w     24128(a4)
		beq.s     xfd6c_10
		move.l    13686(a4),(a7)
		dc.w      0xF3EC ; do_finish
xfd6c_10:
		move.w    8(a6),d0
		bra.s     xfd6c_14
xfd6c_11:
		move.l    12970(a4),d0
		movea.l   22(a6),a1
		move.w    d0,(a1)
		move.l    12974(a4),d0
		movea.l   26(a6),a1
		move.w    d0,(a1)
		movea.l   30(a6),a0
		move.l    12978(a4),(a0)
		bra.s     xfd6c_15
xfd6c_12:
		tst.l     12566(a4)
		beq.s     xfd6c_13
		move.l    12566(a4),(a7)
		dc.w      0xF3F0 ; dos_free
xfd6c_13:
		bra.s     xfd6c_15
xfd6c_14:
		tst.w     d0
		beq.s     xfd6c_11
		cmp.w     #2,d0
		beq.s     xfd6c_12
		cmp.w     #3,d0
		beq.s     xfd6c_12
xfd6c_15:
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		move.w    d6,d0
		dc.w      0xFC31 ; movem.l (a7)+,d6-d7/a4-a5

	xdef _xfd6e40
_xfd6e40: ds.b 0
		link      a6,#-24
		movem.l   d4-d7/a3-a5,-(a7)
		movea.l   14(a6),a5
		movea.l   18(a6),a4
		clr.w     d5
		move.l    _thedesk,-24(a6)
		clr.w     d6
		move.l    a5,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a3
		move.l    a3,-20(a6)
		movea.l   a3,a0
		clr.b     (a0)
		subq.l    #1,a3
		bra.s     xfd6e_2
xfd6e_1:
		movea.l   a3,a0
		cmpi.b    #0x5c,(a0)
		move.w    sr,d0
		subq.l    #1,a3
		move.w    d0,ccr
		beq.s     xfd6e_3
xfd6e_2:
		move.l    a3,d0
		bne.s     xfd6e_1
xfd6e_3:
		addq.l    #2,a3
		move.l    #x00633c,(a7)
		move.l    a3,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		movea.l   -20(a6),a0
		move.b    #0x5C,(a0)
		clr.w     x00a786
		tst.w     8(a6)
		beq.s     xfd6e_4
		cmpi.w    #1,8(a6)
		bne.s     xfd6e_5
xfd6e_4:
		move.l    a5,-20(a6)
		bra.s     xfd6e_6
xfd6e_5:
		move.l    a4,-20(a6)
		addq.w    #1,x00a786
xfd6e_6:
		bra.s     xfd6e_8
xfd6e_7:
		movea.l   -20(a6),a0
		cmpi.b    #0x5C,(a0)
		move.w    sr,d0
		addq.l    #1,-20(a6)
		move.w    d0,ccr
		bne.s     xfd6e_8
		addq.w    #1,x00a786
xfd6e_8:
		movea.l   -20(a6),a0
		tst.b     (a0)
		bne.s     xfd6e_7
		subq.w    #1,x00a786
		move.l    -24(a6),(a7)
		addi.l    #12310,(a7)
		move.l    a5,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    a4,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
xfd6e_9:
		cmpi.w    #8,x00a786
		ble.s     xfd6e_10
		clr.l     (a7)
		move.l    #0x00010017,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d5
		bra       xfd6e_37
xfd6e_10:
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,(a7)
		addi.l    #12574,(a7)
		dc.w      0xF3F4 ; dos_sdta
		move.w    8(a6),d0
		bra       xfd6e_19
xfd6e_11:
		movea.l   -24(a6),a0
		move.l    12974(a0),d0
		movea.l   -24(a6),a1
		addq.l    #1,12974(a1)
		bra       xfd6e_20
xfd6e_12:
		move.l    #x00632c,(a7)
		move.l    #x00633c,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    #x00632c,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		jsr       _xtr_mask
		addq.l    #4,a7
xfd6e_13:
		move.w    #22,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		dc.w      0xF3FC ; dos_sfirst
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd6e_14
		cmpi.w    #18,_DOS_AX
		beq       xfd6e_17
		dc.w      0xF374 ; dos_error
		bra       xfd6e_37
		bra       xfd6e_17
xfd6e_14:
		pea.l     -16(a6)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		jsr       _xfd7620
		addq.l    #8,a7
		move.w    d0,d7
		tst.w     d7
		beq       xfd6e_37
		cmp.w     #1,d7
		bne       xfd6e_16
		tst.b     -16(a6)
		beq.s     xfd6e_14
		move.l    #x00632c,(a7)
		pea.l     -16(a6)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd6e_15
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		jsr       _xfd7730
		addq.l    #4,a7
		move.w    d0,d7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a3
		clr.b     (a3)
		tst.w     d7
		beq.s     xfd6e_14
		bra       xfd6e_18
xfd6e_15:
		move.l    #x00632c,(a7)
		pea.l     -16(a6)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    a4,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    #x00632c,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		jsr       _xtr_mask
		addq.l    #4,a7
		bra       xfd6e_13
		bra.s     xfd6e_17
xfd6e_16:
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		bra       xfd6e_29
xfd6e_17:
		movea.l   -24(a6),a0
		move.l    12974(a0),d0
		movea.l   -24(a6),a1
		addq.l    #1,12974(a1)
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		clr.w     (a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a3
		clr.b     (a3)
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		dc.w      0xF410 ; dos_mkdir
		cmpi.w    #5,_DOS_AX
		bne.s     xfd6e_18
		move.w    #-36,_DOS_AX
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq       xfd6e_37
xfd6e_18:
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		bra.s     xfd6e_20
xfd6e_19:
		tst.w     d0
		beq       xfd6e_11
		cmp.w     #2,d0
		beq       xfd6e_12
		cmp.w     #3,d0
		beq       xfd6e_12
xfd6e_20:
		move.w    #0x0037,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		dc.w      0xF3FC ; dos_sfirst
		addq.l    #4,a7
		move.w    d0,d7
		bra       xfd6e_26
xfd6e_21:
		tst.w     d7
		bne.s     xfd6e_22
		cmpi.w    #18,_DOS_AX
		beq       xfd6e_27
		dc.w      0xF374 ; dos_error
		bra       xfd6e_37
xfd6e_22:
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		btst      #4,12595(a0)
		beq.s     xfd6e_24
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		cmpi.b    #'.',12604(a0)
		beq.s     xfd6e_23
		addq.w    #1,d6
		move.l    #x00633c,(a7)
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,-(a7)
		addi.l    #12604,(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		addq.w    #1,x00a786
		move.l    #x00633c,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		jsr       _xfd75f2
		addq.l    #4,a7
		bra       xfd6e_9
xfd6e_23:
		bra.s     xfd6e_25
xfd6e_24:
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		move.w    12598(a0),(a7)
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		move.w    12596(a0),-(a7)
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		move.b    12595(a0),d0
		ext.w     d0
		move.w    d0,-(a7)
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,-(a7)
		addi.l    #12604,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		move.w    8(a6),-(a7)
		jsr       _xfd7316
		adda.w    #18,a7
		tst.w     d0
		beq       xfd6e_37
xfd6e_25:
		dc.w      0xF414 ; dos_snext
		move.w    d0,d7
xfd6e_26:
		bra       xfd6e_21
xfd6e_27:
		cmpi.w    #1,8(a6)
		beq.s     xfd6e_28
		cmpi.w    #3,8(a6)
		bne.s     xfd6e_29
xfd6e_28:
		move.l    -24(a6),(a7)
		addi.l    #12310,(a7)
		dc.w      0xF3B0 ; r_slash
		move.l    d0,-20(a6)
		movea.l   -20(a6),a0
		cmpi.b    #':',-1(a0)
		beq.s     xfd6e_29
		movea.l   -20(a6),a0
		clr.b     (a0)
		move.l    -24(a6),(a7)
		addi.l    #12310,(a7)
		dc.w      0xF418 ; dos_rmdir
		movea.l   -20(a6),a0
		move.b    #0x5C,(a0)
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq       xfd6e_37
xfd6e_29:
		move.w    8(a6),d0
		bra.s     xfd6e_32
xfd6e_30:
		clr.w     (a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		tst.w     d0
		beq       xfd6e_37
		bra.s     xfd6e_33
xfd6e_31:
		clr.w     (a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd6e_37
		bra.s     xfd6e_33
xfd6e_32:
		cmp.w     #1,d0
		beq.s     xfd6e_31
		cmp.w     #2,d0
		beq.s     xfd6e_30
		cmp.w     #3,d0
		beq.s     xfd6e_30
xfd6e_33:
		tst.w     d6
		beq.s     xfd6e_36
		cmpi.w    #2,8(a6)
		beq.s     xfd6e_34
		cmpi.w    #3,8(a6)
		bne.s     xfd6e_35
xfd6e_34:
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		jsr       _xfd795c
xfd6e_35:
		move.l    -24(a6),(a7)
		addi.l    #12310,(a7)
		jsr       _xfd795c
		subq.w    #1,d6
		subq.w    #1,x00a786
		move.w    x00a786,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,(a7)
		addi.l    #12574,(a7)
		dc.w      0xF3F4 ; dos_sdta
		bra       xfd6e_25
		bra.s     xfd6e_37
xfd6e_36:
		moveq.l   #1,d5
xfd6e_37:
		move.w    d5,d0
		dc.w      0xFE39 ; movem.l (a7)+,d5-d7/a3-a5

	xdef _xfd7316
_xfd7316: ds.b 0
		link      a6,#-40
		movem.l   d2-d7/a3-a5,-(a7)
		moveq.l   #1,d7
		movea.l   10(a6),a5
		movea.l   14(a6),a4
		movea.l   _thedesk,a3
		tst.w     8(a6)
		bne.s     xfd73_1
		addq.l    #1,12970(a3)
		movea.l   a3,a0
		move.w    x00a786,d1
		muls.w    #44,d1
		adda.l    d1,a0
		move.l    12600(a0),d0
		add.l     d0,12978(a3)
		moveq.l   #1,d0
		bra       xfd73_30
xfd73_1:
		move.l    18(a6),(a7)
		move.l    a5,-(a7)
		jsr       _xtr_mask
		addq.l    #4,a7
		cmpi.w    #1,8(a6)
		beq.s     xfd73_2
		move.l    18(a6),(a7)
		move.l    a4,-(a7)
		jsr       _xtr_mask
		addq.l    #4,a7
		pea.l     -20(a6)
		move.l    18(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
xfd73_2:
		clr.w     d3
		move.w    8(a6),d0
		bra       xfd73_24
xfd73_3:
		move.w    #1,(a7)
		move.l    a5,-(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		tst.w     d0
		beq       xfd73_25
		move.l    a5,(a7)
		dc.w      0xF37C ; dos_delete
		cmpi.w    #-36,_DOS_AX
		bne.s     xfd73_4
		moveq.l   #1,d3
		move.w    #5,(a7)
		dc.w      0xF0E8 ; form_error
		bra.s     xfd73_5
xfd73_4:
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq.s     xfd73_5
		moveq.l   #1,d3
xfd73_5:
		bra       xfd73_25
xfd73_6:
		move.b    (a5),d0
		ext.w     d0
		cmp.b     (a4),d0
		bne.s     xfd73_8
		move.w    #1,(a7)
		move.l    a4,-(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		tst.w     d0
		beq       xfd73_25
		move.l    a4,(a7)
		move.l    a5,-(a7)
		dc.w      0xF41C ; dos_rename
		addq.l    #4,a7
		tst.w     _DOS_ERR
		bne.s     xfd73_7
		moveq.l   #1,d3
		bra       xfd73_28
xfd73_7:
		cmpi.w    #-36,_DOS_AX
		beq.s     xfd73_9
		dc.w      0xF374 ; dos_error
		bra       xfd73_28
xfd73_8:
		move.w    #1,(a7)
		move.l    a4,-(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		tst.w     d0
		beq       xfd73_25
xfd73_9:
		clr.w     (a7)
		move.l    a5,-(a7)
		dc.w      0xF33C ; dos_open
		addq.l    #4,a7
		move.w    d0,d5
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq       xfd73_25
		move.l    12566(a3),(a7)
		move.l    12570(a3),-(a7)
		move.w    d5,-(a7)
		move.w    #63,-(a7) ; Fread
		dc.w      0xF0D8 ; trap
		addq.l    #8,a7
		move.l    d0,d4
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq       xfd73_23
xfd73_10:
		clr.w     (a7)
		move.l    a4,-(a7)
		dc.w      0xF33C ; dos_open
		addq.l    #4,a7
		move.w    d0,d6
		tst.w     _DOS_ERR
		beq.s     xfd73_11
		cmpi.w    #2,_DOS_AX
		beq       xfd73_17
		dc.w      0xF374 ; dos_error
		bra       xfd73_23
		bra.s     xfd73_12
xfd73_11:
		move.w    d6,(a7)
		dc.w      0xF344 ; dos_close
xfd73_12:
		tst.w     13734(a3)
		bne.s     xfd73_14
		pea.l     -36(a6)
		move.l    a4,-(a7)
		jsr       _xfd7620
		addq.l    #8,a7
		move.w    d0,d7
		beq       xfd73_23
		cmp.w     #2,d7
		bne.s     xfd73_13
		moveq.l   #1,d3
		bra       xfd73_23
xfd73_13:
		tst.b     -36(a6)
		beq.s     xfd73_12
		bra.s     xfd73_15
xfd73_14:
		pea.l     -36(a6)
		pea.l     -20(a6)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
xfd73_15:
		move.l    a4,(a7)
		dc.w      0xF3B0 ; r_slash
		move.l    d0,-40(a6)
		move.l    -40(a6),(a7)
		addq.l    #1,(a7)
		pea.l     -36(a6)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    a5,(a7)
		move.l    a4,-(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd73_16
		moveq.l   #1,d3
		bra       xfd73_23
xfd73_16:
		pea.l     -20(a6)
		pea.l     -36(a6)
		dc.w      0xF39C ; streq
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfd73_17
		pea.l     -20(a6)
		pea.l     -36(a6)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		bra       xfd73_10
xfd73_17:
		move.w    #1,(a7)
		move.l    a4,-(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		tst.w     d0
		beq       xfd73_23
		move.w    22(a6),(a7)
		andi.w    #-2,(a7)
		move.l    a4,-(a7)
		dc.w      0xF370 ; dos_create
		addq.l    #4,a7
		move.w    d0,d6
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq.w     xfd73_23
		addq.l    #1,12970(a3)
xfd73_18:
		move.l    12566(a3),(a7)
		move.l    d4,-(a7)
		move.w    d6,-(a7)
		move.w    #64,-(a7) ; Fwrite
		dc.w      0xF0D8 ; trap
		addq.l    #8,a7
		move.l    d0,-4(a6)
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq.s     xfd73_22
		cmp.l     -4(a6),d4
		beq.s     xfd73_19
		clr.l     (a7)
		move.l    #0x00010016,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		move.w    d6,(a7)
		dc.w      0xF344 ; dos_close
		move.l    a4,(a7)
		dc.w      0xF37C ; dos_delete
		dc.w      0xF374 ; dos_error
		bra.s     xfd73_23
xfd73_19:
		cmp.l     12570(a3),d4
		bge.s     xfd73_20
		move.l    24(a6),-(a7)
		move.w    d6,-(a7)
		dc.w      0xF420 ; dos_set
		addq.l    #6,a7
		moveq.l   #1,d3
		bra.s     xfd73_22
		bra.s     xfd73_21
xfd73_20:
		move.l    12566(a3),(a7)
		move.l    12570(a3),-(a7)
		move.w    d5,-(a7)
		move.w    #63,-(a7) ; Fread
		dc.w      0xF0D8 ; trap
		addq.l    #8,a7
		move.l    d0,d4
		tst.l     d4
		beq.s     xfd73_22
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq.s     xfd73_22
xfd73_21:
		bra.s     xfd73_18
xfd73_22:
		move.w    d6,(a7)
		dc.w      0xF344 ; dos_close
xfd73_23:
		move.w    d5,(a7)
		dc.w      0xF344 ; dos_close
		bra.s     xfd73_25
xfd73_24:
		cmp.w     #1,d0
		beq       xfd73_3
		cmp.w     #2,d0
		beq       xfd73_8
		cmp.w     #3,d0
		beq       xfd73_6
xfd73_25:
		cmpi.w    #3,8(a6)
		bne.s     xfd73_28
		cmp.w     #1,d3
		bne.s     xfd73_28
		cmp.w     #1,d7
		bne.s     xfd73_28
		move.l    a4,(a7)
		move.l    a5,-(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd73_28
		move.l    a5,(a7)
		dc.w      0xF37C ; dos_delete
		tst.w     _DOS_ERR
		beq.s     xfd73_28
		clr.w     d3
		cmpi.w    #-36,_DOS_AX
		bne.s     xfd73_27
		moveq.l   #1,d3
		move.w    #5,(a7)
		dc.w      0xF0E8 ; form_error
xfd73_26:
		bra.s     xfd73_28
xfd73_27:
		dc.w      0xF374 ; dos_error
xfd73_28:
		move.l    a5,(a7)
		dc.w      0xF424 ; rep_all
		cmpi.w    #1,8(a6)
		beq.s     xfd73_29
		move.l    a4,(a7)
		dc.w      0xF424 ; rep_all
xfd73_29:
		move.w    d3,d0
xfd73_30:
		dc.w      0xFE3F ; movem.l (a7)+,d3-d7/a3-a5

	xdef _xfd75f2
_xfd75f2: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		bra.s     xfd75_2
xfd75_1:
		addq.l    #1,a5
xfd75_2:
		cmpi.b    #'*',(a5)
		bne.s     xfd75_1
		move.l    a5,(a7)
		move.l    12(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    a5,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef _xfd7620
_xfd7620: ds.b 0
		link      a6,#-24
		movem.l   d5-d7/a5,-(a7)
		movea.l   _thedesk,a5
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		move.l    13686(a5),d7
		pea.l     -24(a6)
		move.l    8(a6),-(a7)
		jsr       _xfd6a9c
		addq.l    #8,a7
		pea.l     -24(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		pea.l     -24(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		move.l    d7,(a7)
		dc.w      0xF3CC ; fm_draw
		move.w    #1,24128(a5)
		clr.w     (a7)
		move.l    d7,-(a7)
		dc.w      0xF3D0 ; form_do
		addq.l    #4,a7
		move.w    d0,d6
		and.w     #0x7FFF,d6
		movea.l   d7,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		clr.w     (a0)
		tst.w     24130(a5)
		beq.s     xfd76_2
		move.l    13682(a5),d7
		cmp.w     #5,d6
		bne.s     xfd76_1
		move.l    #xfeb13c,(a7)
		move.w    #4,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		addq.l    #6,a7
xfd76_1:
		movea.l   d7,a0
		adda.l    #130,a0
		move.w    #1,(a0)
		pea.l     -2(a6)
		pea.l     -4(a6)
		pea.l     -6(a6)
		pea.l     -8(a6)
		move.l    d7,-(a7)
		dc.w      0xF3A0 ; form_center
		adda.w    #20,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    #8,-(a7)
		clr.w     -(a7)
		move.l    d7,-(a7)
		dc.w      0xF3A8 ; objc_draw
		adda.w    #16,a7
		movea.l   d7,a0
		adda.l    #130,a0
		clr.w     (a0)
xfd76_2:
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		cmp.w     #3,d6
		bne.s     xfd76_3
		moveq.l   #1,d6
		bra.s     xfd76_6
xfd76_3:
		cmp.w     #4,d6
		bne.s     xfd76_4
		clr.w     d0
		bra.s     xfd76_5
xfd76_4:
		moveq.l   #2,d0
xfd76_5:
		move.w    d0,d6
xfd76_6:
		pea.l     24158(a5)
		move.w    #2,-(a7)
		move.l    13686(a5),-(a7)
		dc.w      0xF42C ; fs_sget
		adda.w    #10,a7
		move.l    12(a6),(a7)
		pea.l     24158(a5)
		dc.w      0xF430 ; unfmt_str
		addq.l    #4,a7
		move.w    d6,d0
		dc.w      0xF831 ; movem.l (a7)+,d6-d7/a5

	xdef _xfd7730
_xfd7730: ds.b 0
		link      a6,#0
		movem.l   d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   12(a6),a4
		move.l    a4,(a7)
		move.l    a5,-(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd773_5
		bra.s     xfd773_4
xfd773_1:
		move.b    (a5),d0
		ext.w     d0
		cmp.b     (a4),d0
		beq.s     xfd773_2
		cmpi.b    #'*',(a5)
		beq.s     xfd773_5
		moveq.l   #1,d0
		bra.s     xfd773_6
xfd773_2:
		tst.b     (a4)
		bne.s     xfd773_3
		moveq.l   #1,d0
		bra.s     xfd773_6
xfd773_3:
		addq.l    #1,a5
		addq.l    #1,a4
xfd773_4:
		tst.b     (a5)
		bne.s     xfd773_1
xfd773_5:
		clr.w     d0
xfd773_6:
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef _xfd7774
_xfd7774: ds.b 0
		link      a6,#0
		movem.l   d7/a4-a5,-(a7)
		movea.l   12(a6),a5
		movea.l   _thedesk,a4
		movea.l   8(a6),a0
		move.b    (a0),d0
		ext.w     d0
		movea.l   16(a6),a1
		move.b    (a1),d1
		ext.w     d1
		cmp.w     d1,d0
		beq.s     xfd777_1
		moveq.l   #1,d0
		bra.w     xfd777_5
xfd777_1:
		bra.s     xfd777_4
xfd777_2:
		cmpi.w    #-1,32(a5)
		beq.s     xfd777_3
		movea.l   a4,a0
		move.w    32(a5),d1
		muls.w    #24,d1
		adda.l    d1,a0
		btst      #0,24211(a0)
		beq.s     xfd777_3
		cmpi.b    #16,9(a5)
		bne.s     xfd777_3
		pea.l     12310(a4)
		move.l    8(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		pea.l     18(a5)
		pea.l     12310(a4)
		jsr       _xfd75f2
		addq.l    #8,a7
		pea.l     12438(a4)
		move.l    16(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		pea.l     12438(a4)
		pea.l     12310(a4)
		jsr       _xfd7730
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfd777_3
		clr.l     (a7)
		move.l    #0x00010019,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra.s     xfd777_5
xfd777_3:
		movea.l   (a5),a5
xfd777_4:
		move.l    a5,d0
		bne.s     xfd777_2
		moveq.l   #1,d0
xfd777_5:
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef _xfd7814
_xfd7814: ds.b 0
		link      a6,#-40
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		move.l    #0x00010002,(a7)
		dc.w      0xF0F0 ; trp13
		tst.l     d0
		beq.s     xfd78_1
		move.l    #0x00020002,(a7)
		dc.w      0xF0F0 ; trp13
		cmp.l     #0x00610000,d0
		bne.s     xfd78_1
		clr.l     (a7)
		move.l    #0x00010022,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		cmp.w     #1,d0
		bne.s     xfd78_1
		clr.w     d0
		bra       xfd78_6
xfd78_1:
		tst.w     24130(a5)
		beq       xfd78_5
		move.l    13682(a5),d7
		pea.l     -40(a6)
		pea.l     -24(a6)
		move.l    8(a6),-(a7)
		jsr       _xfd791e
		adda.w    #12,a7
		pea.l     -24(a6)
		move.w    #4,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		pea.l     -40(a6)
		move.w    #3,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		tst.w     12(a6)
		beq.s     xfd78_2
		move.l    12970(a5),-4(a6)
		clr.w     (a7)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		pea.l     24112(a5)
		pea.l     -4(a6)
		dc.w      0xF3C4
		adda.w    #14,a7
		move.w    #2,(a7)
		move.l    d7,-(a7)
		jsr       _drawclip
		addq.l    #4,a7
		subq.l    #1,12970(a5)
		bra.s     xfd78_4
xfd78_2:
		move.l    #xfeb13d,(a7)
		move.w    #4,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		addq.l    #6,a7
		tst.l     12974(a5)
		beq.s     xfd78_3
		subq.l    #1,12974(a5)
xfd78_3:
		move.l    12974(a5),-8(a6)
		clr.w     (a7)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		pea.l     24116(a5)
		pea.l     -8(a6)
		dc.w      0xF3C4
		adda.w    #14,a7
		move.w    #1,(a7)
		move.l    d7,-(a7)
		jsr       _drawclip
		addq.l    #4,a7
xfd78_4:
		move.w    #4,(a7)
		move.l    d7,-(a7)
		jsr       _drawclip
		addq.l    #4,a7
		move.w    #3,(a7)
		move.l    d7,-(a7)
		jsr       _drawclip
		addq.l    #4,a7
xfd78_5:
		moveq.l   #1,d0
xfd78_6:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef _xfd791e
_xfd791e: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.l    12(a6),(a7)
		move.l    a5,-(a7)
		jsr       _xfd6a9c
		addq.l    #4,a7
		move.l    a5,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a5
		cmpi.b    #':',-1(a5)
		bne.s     xfd791_1
		movea.l   16(a6),a0
		clr.b     (a0)
		bra.s     xfd791_2
xfd791_1:
		clr.b     (a5)
		move.l    16(a6),(a7)
		move.l    a5,-(a7)
		jsr       _xfd6a9c
		addq.l    #4,a7
		move.b    #0x5C,(a5)
xfd791_2:
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef _xfd795c
_xfd795c: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.l    a5,(a7)
		dc.w      0xF3B0 ; r_slash
		movea.l   d0,a5
		subq.l    #1,a5
		bra.s     xfd795_2
xfd795_1:
		subq.l    #1,a5
xfd795_2:
		cmpi.b    #0x5C,(a5)
		bne.s     xfd795_1
		move.l    a5,(a7)
		move.l    #_wilds,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		dc.w      0xF801 ; movem.l (a7)+,a5

	.data

	xdef _wilds
_wilds:
	.ascii "\*.*"
	dc.b 0,0
	xdef _getall
_getall:
	.ascii "*.*"
	dc.b 0

xfeb13a: dc.b 0
xfeb13b: dc.b 0
xfeb13c: dc.b 0
xfeb13d: dc.b 0
