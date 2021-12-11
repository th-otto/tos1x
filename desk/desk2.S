/* (OBJECT *tree, register DIR *dir, int16_t dateidx, int16_t timeidx, int16_t o20) */
	xdef _xfd8284
_xfd8284: ds.b 0
		link      a6,#-26
		movem.l   d7/a4-a5,-(a7)
		movea.l   12(a6),a5
		movea.l   22(a6),a4
		pea.l     -26(a6)
		move.w    12(a5),-(a7)
		jsr       _fmt_date
		addq.l    #6,a7
		pea.l     -26(a6)
		move.w    16(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr       _inf_sset
		adda.w    #10,a7
		pea.l     -18(a6)
		move.w    10(a5),-(a7)
		jsr       _fmt_time
		addq.l    #6,a7
		pea.l     -18(a6)
		move.w    18(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr       _inf_sset
		adda.w    #10,a7
		clr.w     (a7)
		move.w    20(a6),-(a7)
		move.l    8(a6),-(a7)
		pea.l     -10(a6)
		move.l    a4,-(a7)
		jsr       _xfd81e8
		adda.w    #14,a7
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef xfd82e8
xfd82e8: ds.b 0
		link      a6,#-36
		movem.l   d3-d7/a3-a5,-(a7)
		movea.l   12(a6),a5
		movea.l   _thedesk,a3
		move.l    13658(a3),d7
		pea.l     12310(a3)
		move.l    8(a6),-(a7)
		jsr       _xstrpcpy
		addq.l    #8,a7
		pea.l     12438(a3)
		move.l    8(a6),-(a7)
		jsr       _xstrpcpy
		addq.l    #8,a7
		clr.w     d4
		bra.s     xfd82_2
xfd82_1:
		addq.w    #1,d4
xfd82_2:
		movea.l   a3,a0
		movea.w   d4,a1
		adda.l    a1,a0
		cmpi.b    #'*',12310(a0)
		bne.s     xfd82_1
		tst.w     16(a6)
		bne.s     xfd82_3
		clr.w     (a7)
		move.l    #0x00010001,-(a7)
		move.b    9(a5),d0
		ext.w     d0
		move.w    d0,-(a7)
		move.w    #8,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_fldset
		adda.w    #12,a7
		move.w    #1,(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.b    9(a5),d0
		ext.w     d0
		move.w    d0,-(a7)
		move.w    #9,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_fldset
		adda.w    #12,a7
		move.l    #xfeb14a,(a7)
		move.w    #7,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_sset
		addq.l    #6,a7
		move.l    #xfeb150,(a7)
		move.w    #6,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_sset
		addq.l    #6,a7
		move.w    #6,-36(a6)
		move.l    14(a5),12978(a3)
		bra.s     xfd82_4
xfd82_3:
		movea.l   d7,a0
		adda.l    #202,a0
		move.w    #8,(a0)
		movea.l   d7,a0
		adda.l    #226,a0
		move.w    #8,(a0)
		pea.l     18(a5)
		pea.l     12310(a3)
		dc.w      0xF3DC
		addq.l    #8,a7
		move.w    #7,-36(a6)
		pea.l     12310(a3)
		move.l    #0x00070006,-(a7)
		move.l    d7,-(a7)
		jsr       _xfd8164
		adda.w    #12,a7
		tst.w     d0
		beq       xfd82_11
xfd82_4:
		pea.l     -32(a6)
		move.w    -36(a6),-(a7)
		move.w    #5,-(a7)
		jsr       _rsrc_gaddr
		addq.l    #8,a7
		movea.l   #36,a0
		movea.l   0(a0,d7.l),a0
		move.l    -32(a6),(a0)
		pea.l     12978(a3)
		move.l    #0x00050003,-(a7)
		move.w    #4,-(a7)
		move.l    a5,-(a7)
		move.l    d7,-(a7)
		jsr       _xfd8284
		adda.w    #18,a7
		move.w    #1,(a7)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		pea.l     -14(a6)
		pea.l     18(a5)
		jsr       _xfd81e8
		adda.w    #14,a7
		clr.w     d5
		clr.w     (a7)
		move.l    d7,-(a7)
		jsr       _xform_do
		addq.l    #4,a7
		cmp.w     #11,d0
		bne       xfd82_10
		move.w    #1,(a7)
		jsr       _desk_wait
		pea.l     -28(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		jsr       _fs_sget
		adda.w    #10,a7
		move.l    a3,d0
		move.w    d4,d1
		ext.l     d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #12310,(a7)
		pea.l     -14(a6)
		jsr       _unfmt_str
		addq.l    #4,a7
		move.l    a3,d0
		move.w    d4,d1
		ext.l     d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #12438,(a7)
		pea.l     -28(a6)
		jsr       _unfmt_str
		addq.l    #4,a7
		move.l    a3,d0
		move.w    d4,d1
		ext.l     d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #12438,(a7)
		move.l    a3,d0
		move.w    d4,d1
		ext.l     d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #12310,(a7)
		jsr       _streq
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd82_6
		pea.l     12438(a3)
		pea.l     12310(a3)
		jsr       _dos_rename
		addq.l    #8,a7
		cmpi.w    #-36,_DOS_AX
		bne.s     xfd82_5
		move.w    #05,(a7)
		jsr       _form_error
		bra.s     xfd82_6
xfd82_5:
		jsr       _dos_error
		move.w    d0,d5
		beq.s     xfd82_6
		pea.l     18(a5)
		move.l    a3,d0
		move.w    d4,d1
		ext.l     d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #12438,(a7)
		jsr       _xstrpcpy
		addq.l    #8,a7
xfd82_6:
		move.b    9(a5),d6
		ext.w     d6
		movea.l   d7,a0
		adda.l    #203,a0
		btst      #0,(a0)
		beq.s     xfd82_7
		or.w      #1,d6
		bra.s     xfd82_8
xfd82_7:
		and.w     #-2,d6
xfd82_8:
		tst.w     16(a6)
		bne.s     xfd82_9
		move.w    d6,d0
		ext.w     d0
		cmp.b     9(a5),d0
		beq.s     xfd82_9
		move.w    d6,(a7)
		move.w    #1,-(a7)
		pea.l     12438(a3)
		jsr       _dos_chmod
		addq.l    #6,a7
		jsr       _dos_error
		move.w    d0,d5
		beq.s     xfd82_9
		move.b    d6,9(a5)
xfd82_9:
		clr.w     (a7)
		jsr       _desk_wait
		move.w    d5,d0
		bra.s     xfd82_11
		bra.s     xfd82_11
xfd82_10:
		clr.w     d0
xfd82_11:
		dc.w      0xFE3D ; movem.l (a7)+,d4-d7/a3-a5

	xdef xfd8538
xfd8538: ds.b 0
		link      a6,#-58
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		move.l    13662(a5),d7
		move.b    9(a6),-46(a6)
		clr.b     -45(a6)
		move.b    -46(a6),12310(a5)
		pea.l     12311(a5)
		move.l    #xfeb156,-(a7)
		jsr       _xstrpcpy
		addq.l    #8,a7
		pea.l     12310(a5)
		move.l    #0x00040003,-(a7)
		move.l    d7,-(a7)
		jsr       _xfd8164
		adda.w    #12,a7
		tst.w     d0
		beq       xfd85_1
		move.w    #1,(a7)
		jsr       _desk_wait
		pea.l     -8(a6)
		pea.l     -4(a6)
		move.b    9(a6),d0
		ext.w     d0
		move.w    d0,-(a7)
		addi.w    #0xFFC0,(a7)
		dc.w      0xF464
		adda.w    #10,a7
		clr.b     -44(a6)
		pea.l     -44(a6)
		move.b    9(a6),d0
		ext.w     d0
		move.w    d0,-(a7)
		addi.w    #0xFFC0,(a7)
		jsr       _dos_label
		addq.l    #6,a7
		pea.l     -58(a6)
		pea.l     -44(a6)
		jsr       _fmt_str
		addq.l    #8,a7
		pea.l     -46(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_sset
		adda.w    #10,a7
		pea.l     -58(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_sset
		adda.w    #10,a7
		clr.w     (a7)
		move.w    #5,-(a7)
		move.l    d7,-(a7)
		pea.l     -22(a6)
		pea.l     12978(a5)
		jsr       _xfd81e8
		adda.w    #14,a7
		clr.w     (a7)
		move.w    #6,-(a7)
		move.l    d7,-(a7)
		pea.l     -32(a6)
		pea.l     -8(a6)
		jsr       _xfd81e8
		adda.w    #14,a7
		clr.w     (a7)
		jsr       _desk_wait
		move.w    #7,(a7)
		move.l    d7,-(a7)
		dc.w      0xF53C
		addq.l    #4,a7
xfd85_1:
		moveq.l   #1,d0
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef _desk_pref
_desk_pref: ds.b 0
		link      a6,#-2
		movem.l   d3-d7/a5,-(a7)
		movea.l   _thedesk,a5
		move.l    13694(a5),d7
		move.w    13730(a5),d6
		movea.l   d7,a0
		adda.l    #106,a0
		move.w    d6,(a0)
		tst.w     d6
		beq.s     xfd86_1
		clr.w     d0
		bra.s     xfd86_2
xfd86_1:
		moveq.l   #1,d0
xfd86_2:
		movea.l   d7,a1
		adda.l    #130,a1
		move.w    d0,(a1)
		move.w    13734(a5),d6
		tst.w     d6
		beq.s     xfd86_3
		clr.w     d0
		bra.s     xfd86_4
xfd86_3:
		moveq.l   #1,d0
xfd86_4:
		movea.l   d7,a1
		adda.l    #250,a1
		move.w    d0,(a1)
		movea.l   d7,a0
		adda.l    #0x00000112,a0
		move.w    d6,(a0)
		move.w    13728(a5),d6
		movea.l   d7,a0
		adda.l    #0x000000B2,a0
		move.w    d6,(a0)
		tst.w     d6
		beq.s     xfd86_5
		clr.w     d0
		bra.s     xfd86_6
xfd86_5:
		moveq.l   #1,d0
xfd86_6:
		movea.l   d7,a1
		adda.l    #202,a1
		move.w    d0,(a1)
		clr.w     d5
		bra.s     xfd86_8
xfd86_7:
		movea.l   d7,a0
		move.w    d5,d1
		add.w     #14,d1
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		clr.w     (a0)
		addq.w    #1,d5
xfd86_8:
		cmp.w     #3,d5
		blt.s     xfd86_7
		move.w    #4,(a7)
		jsr       _trp14
		move.w    d0,d4
		cmp.w     #2,d4
		beq.s     xfd86_9
		movea.l   d7,a0
		adda.l    #0x0000018A,a0
		move.w    #8,(a0)
		bra.s     xfd86_10
xfd86_9:
		movea.l   d7,a0
		adda.l    #0x0000015A,a0
		move.w    #8,(a0)
		movea.l   d7,a0
		adda.l    #0x00000172,a0
		move.w    #8,(a0)
xfd86_10:
		move.w    _gl_restype,d4
		subq.w    #2,d4
		movea.l   d7,a0
		move.w    d4,d1
		add.w     #14,d1
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		move.w    #1,(a0)
		clr.w     (a7)
		move.l    d7,-(a7)
		jsr       _xform_do
		addq.l    #4,a7
		cmp.w     #17,d0
		bne.s     xfd86_13
		move.w    #5,(a7)
		move.w    #4,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_what
		addq.l    #6,a7
		move.w    d0,13730(a5)
		move.w    #8,(a7)
		move.w    #7,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_what
		addq.l    #6,a7
		move.w    d0,13728(a5)
		move.w    #11,(a7)
		move.w    #10,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_what
		addq.l    #6,a7
		tst.w     d0
		beq.s     xfd86_11
		clr.w     d0
		bra.s     xfd86_12
xfd86_11:
		moveq.l   #1,d0
xfd86_12:
		move.w    d0,13734(a5)
		move.w    #3,(a7)
		move.w    #14,-(a7)
		move.l    d7,-(a7)
		jsr       _inf_gindex
		addq.l    #6,a7
		move.w    d0,d4
		addq.w    #2,d4
		move.w    d4,(a7)
		jsr       _app_reschange
		tst.w     d0
		beq.s     xfd86_13
		moveq.l   #1,d0
		bra.s     xfd86_14
xfd86_13:
		clr.w     d0
xfd86_14:
		dc.w      0xF83D ; movem.l (a7)+,d4-d7/a5

	xdef _desk_dfree
_desk_dfree: ds.b 0
		link      a6,#-24
		move.w    8(a6),(a7)
		pea.l     -16(a6)
		move.w    #54,-(a7) ; Dfree
		dc.w      0xF0D8 ; trap
		addq.l    #6,a7
		move.l    -8(a6),-(a7)
		move.l    -4(a6),-(a7)
		jsr       _lmul
		addq.l    #8,a7
		move.l    d0,-20(a6)
		move.l    -20(a6),-(a7)
		move.l    -12(a6),-(a7)
		jsr       _lmul
		addq.l    #8,a7
		move.l    d0,-(a7)
		movea.l   10(a6),a0
		move.l    (a7)+,(a0)
		move.l    -20(a6),-(a7)
		move.l    -16(a6),-(a7)
		jsr       _lmul
		addq.l    #8,a7
		move.l    d0,-(a7)
		movea.l   14(a6),a0
		move.l    (a7)+,(a0)
		moveq.l   #1,d0
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef xfd87dc
xfd87dc: ds.b 0
		link      a6,#-34
		movem.l   d4-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a0
		move.l    13674(a0),d7
		move.w    22(a5),d0
		move.b    d0,-2(a6)
		clr.b     -1(a6)
		pea.l     -16(a6)
		move.l    10(a5),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		pea.l     -2(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		pea.l     -16(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		clr.w     d6
		clr.w     (a7)
		move.l    d7,-(a7)
		dc.w      0xF4C4 ; xform_do
		addq.l    #4,a7
		move.w    d0,-34(a6)
		pea.l     -18(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF42C ; fs_sget
		adda.w    #10,a7
		pea.l     -32(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF42C ; fs_sget
		adda.w    #10,a7
		cmpi.w    #5,-34(a6)
		bne.s     xfd87_1
		clr.w     d0
		bra       xfd87_21
xfd87_1:
		cmpi.b    #' ',-18(a6)
		beq.s     xfd87_2
		tst.b     -18(a6)
		bne.s     xfd87_3
xfd87_2:
		clr.w     d0
		bra       xfd87_21
xfd87_3:
		cmpi.b    #'c',-18(a6)
		beq.s     xfd87_4
		move.b    -18(a6),d0
		ext.w     d0
		move.w    d0,(a7)
		dc.w      0xF548 ; toupper
		move.b    d0,-18(a6)
xfd87_4:
		move.b    -18(a6),d0
		ext.w     d0
		cmp.b     -2(a6),d0
		beq.s     xfd87_9
		movea.l   _thedesk,a0
		movea.l   23114(a0),a3
		clr.w     d5
		bra.s     xfd87_7
xfd87_5:
		move.w    22(a3),d0
		move.b    -18(a6),d1
		ext.w     d1
		cmp.w     d1,d0
		bne.s     xfd87_6
		moveq.l   #1,d5
		movea.l   a3,a5
		bra.s     xfd87_8
		bra.s     xfd87_7
xfd87_6:
		movea.l   (a3),a3
xfd87_7:
		move.l    a3,d0
		bne.s     xfd87_5
xfd87_8:
		bra.s     xfd87_10
xfd87_9:
		moveq.l   #1,d5
xfd87_10:
		cmpi.w    #4,-34(a6)
		bne.s     xfd87_12
		tst.w     d5
		beq.s     xfd87_11
		move.l    a5,(a7)
		dc.w      0xF54C ; app_free
xfd87_11:
		move.w    d5,d0
		bra       xfd87_21
		bra       xfd87_21
xfd87_12:
		tst.w     d5
		bne       xfd87_19
		moveq.l   #1,d6
		clr.w     (a7)
		dc.w      0xF350 ; app_alloc
		movea.l   d0,a4
		move.l    a4,d0
		beq       xfd87_18
		move.w    4(a5),4(a4)
		cmpi.b    #'c',-18(a6)
		beq.s     xfd87_22
		moveq.l   #2,d0
		bra.s     xfd87_13
xfd87_22:
		moveq.l   #4,d0
xfd87_13:
		move.w    d0,6(a4)
		move.w    8(a5),8(a4)
		move.w    18(a5),18(a4)
		move.w    #-1,20(a4)
		move.w    _gl_width,d0
		ext.l     d0
		divs.w    #2,d0
		cmp.w     24(a5),d0
		ble.s     xfd87_14
		movea.l   _thedesk,a0
		move.w    13740(a0),d0
		add.w     24(a5),d0
		move.w    d0,24(a4)
		bra.s     xfd87_15
xfd87_14:
		move.w    24(a5),d0
		movea.l   _thedesk,a1
		move.w    13740(a1),d1
		sub.w     d1,d0
		move.w    d0,24(a4)
xfd87_15:
		move.w    _gl_height,d0
		sub.w     _gl_hbox,d0
		ext.l     d0
		divs.w    #2,d0
		cmp.w     26(a5),d0
		ble.s     xfd87_16
		movea.l   _thedesk,a0
		move.w    13742(a0),d0
		add.w     26(a5),d0
		move.w    d0,26(a4)
		bra.s     xfd87_17
xfd87_16:
		move.w    26(a5),d0
		movea.l   _thedesk,a1
		move.w    13742(a1),d1
		sub.w     d1,d0
		move.w    d0,26(a4)
xfd87_17:
		movea.l   _thedesk,a0
		move.w    13822(a0),d0
		add.w     26(a5),d0
		move.w    d0,26(a4)
		pea.l     26(a4)
		pea.l     24(a4)
		move.l    24(a4),-(a7)
		dc.w      0xF2BC ; app_mtoi
		adda.w    #12,a7
		movea.l   a4,a5
		bra.s     xfd87_19
xfd87_18:
		clr.l     (a7)
		move.l    #0x00010023,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra.s     xfd87_21
xfd87_19:
		move.b    -18(a6),d0
		ext.w     d0
		move.w    d0,22(a5)
		pea.l     -16(a6)
		pea.l     -32(a6)
		dc.w      0xF39C ; streq
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfd87_20
		moveq.l   #1,d6
xfd87_20:
		move.l    a6,(a7)
		addi.l    #-32,(a7)
		dc.w      0xF24C ; strlen
		ext.l     d0
		add.l     a6,d0
		movea.l   d0,a0
		move.b    #'@',-32(a0)
		pea.l     10(a5)
		pea.l     -32(a6)
		dc.w      0xF32C ; escani_str
		addq.l    #8,a7
		move.w    d6,d0
xfd87_21:
		dc.w      0xFE39 ; movem.l (a7)+,d5-d7/a3-a5

	xdef xfd8a16
xfd8a16: ds.b 0
		link      a6,#-188
		movem.l   d6-d7/a3-a5,-(a7)
		movea.l   12(a6),a5
		move.l    _thedesk,-184(a6)
		movea.l   -184(a6),a0
		move.l    13678(a0),d7
		movea.l   10(a5),a0
		cmpi.b    #'*',(a0)
		beq.s     xfd8a_1
		movea.l   10(a5),a0
		cmpi.b    #'?',(a0)
		beq.s     xfd8a_1
		clr.w     d0
		bra.s     xfd8a_2
xfd8a_1:
		moveq.l   #1,d0
xfd8a_2:
		move.w    d0,-50(a6)
		pea.l     -12(a6)
		move.l    8(a6),-(a7)
		dc.w      0xF3B4 ; fmt_str
		addq.l    #8,a7
		movea.l   14(a5),a3
		move.w    #'.',(a7)
		move.l    a3,-(a7)
		dc.w      0xF480 ; scasb
		addq.l    #4,a7
		movea.l   d0,a3
		cmpi.b    #'.',(a3)
		bne.s     xfd8a_3
		addq.l    #1,a3
xfd8a_3:
		pea.l     -16(a6)
		move.l    a3,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		pea.l     -12(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		pea.l     -16(a6)
		move.w    #3,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		move.w    4(a5),-42(a6)
		btst      #0,5(a5)
		beq.s     xfd8a_4
		movea.l   d7,a0
		adda.l    #0x000000E2,a0
		move.w    #1,(a0)
		bra.s     xfd8a_6
xfd8a_4:
		btst      #3,5(a5)
		beq.s     xfd8a_5
		movea.l   d7,a0
		adda.l    #0x00000112,a0
		move.w    #1,(a0)
		bra.s     xfd8a_6
xfd8a_5:
		movea.l   d7,a0
		adda.l    #0x000000FA,a0
		move.w    #1,(a0)
xfd8a_6:
		movea.l   -184(a6),a0
		move.w    13720(a0),(a7)
		dc.w      0xF2EC
		move.l    d0,-178(a6)
		move.w    #' ',(a7)
		pea.l     -174(a6)
		move.l    -178(a6),-(a7)
		addi.l    #29,(a7)
		dc.w      0xF550 ; strscn
		addq.l    #8,a7
		move.l    d0,-188(a6)
		movea.l   -188(a6),a0
		clr.b     (a0)
		pea.l     -34(a6)
		pea.l     -12(a6)
		dc.w      0xF430 ; unfmt_str
		addq.l    #8,a7
		movea.l   -188(a6),a0
		cmpi.b    #0x5C,-1(a0)
		bne.s     xfd8a_7
		pea.l     -174(a6)
		pea.l     -34(a6)
		dc.w      0xF404 ; xstrpcat
		addq.l    #8,a7
xfd8a_7:
		clr.w     -52(a6)
		movea.l   d7,a0
		adda.l    #130,a0
		clr.w     (a0)
		movea.l   d7,a0
		adda.l    #0x0000009A,a0
		clr.w     (a0)
		move.l    -184(a6),(a7)
		addi.l    #30443,(a7)
		pea.l     -174(a6)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd8a_8
		movea.l   d7,a0
		adda.l    #0x00000082,a0
		move.w    #1,(a0)
		move.w    #1,-52(a6)
		bra.s     xfd8a_9
xfd8a_8:
		movea.l   d7,a0
		adda.l    #0x0000009A,a0
		move.w    #1,(a0)
xfd8a_9:
		clr.w     (a7)
		move.l    d7,-(a7)
		dc.w      0xF4C4 ; xform_do
		addq.l    #4,a7
		move.w    d0,-40(a6)
		move.w    #1,-46(a6)
		pea.l     -20(a6)
		move.w    #3,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF42C ; fs_sget
		adda.w    #10,a7
		move.w    #3,(a7)
		move.w    #9,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF540 ; inf_gindex
		addq.l    #6,a7
		move.w    d0,-48(a6)
		move.b    #'0',-180(a6)
		move.w    -48(a6),d0
		bra.s     xfd8a_13
xfd8a_10:
		move.w    #3,-44(a6)
		move.b    #'1',-180(a6)
		bra.s     xfd8a_14
xfd8a_11:
		clr.w     -44(a6)
		bra.s     xfd8a_14
xfd8a_12:
		move.w    #8,-44(a6)
		bra.s     xfd8a_14
xfd8a_13:
		tst.w     d0
		beq.s     xfd8a_10
		cmp.w     #1,d0
		beq.s     xfd8a_11
		cmp.w     #2,d0
		beq.s     xfd8a_12
xfd8a_14:
		movea.l   d7,a0
		move.w    -48(a6),d1
		add.w     #9,d1
		muls.w    #24,d1
		adda.l    d1,a0
		adda.l    #10,a0
		clr.w     (a0)
		cmpi.w    #14,-40(a6)
		bne.s     xfd8a_15
		clr.w     d0
		bra       xfd8a_28
xfd8a_15:
		cmpi.w    #13,-40(a6)
		bne.s     xfd8a_18
		tst.w     -52(a6)
		beq.s     xfd8a_16
		movea.l   -184(a6),a0
		clr.b     30440(a0)
		movea.l   -184(a6),a0
		clr.b     30443(a0)
xfd8a_16:
		tst.w     -50(a6)
		bne.s     xfd8a_17
		move.l    a5,(a7)
		dc.w      0xF54C ; app_free
xfd8a_17:
		bra       xfd8a_27
		bra       xfd8a_27
xfd8a_18:
		btst      #4,-41(a6)
		beq.s     xfd8a_19
		ori.w     #0x0010,-44(a6)
xfd8a_19:
		pea.l     -20(a6)
		pea.l     -16(a6)
		dc.w      0xF39C ; streq
		addq.l    #8,a7
		tst.w     d0
		beq.s     xfd8a_20
		move.w    -42(a6),d0
		cmp.w     -44(a6),d0
		beq       xfd8a_25
xfd8a_20:
		tst.w     -50(a6)
		beq.s     xfd8a_22
		move.w    #1,(a7)
		dc.w      0xF350 ; app_alloc
		movea.l   d0,a4
		move.l    a4,d0
		beq.s     xfd8a_21
		clr.w     6(a4)
		move.w    #-1,8(a4)
		move.l    a6,(a7)
		addi.l    #-174,(a7)
		dc.w      0xF24C ; strlen
		ext.l     d0
		add.l     a6,d0
		movea.l   d0,a0
		move.b    #'@',-174(a0)
		pea.l     10(a4)
		pea.l     -174(a6)
		dc.w      0xF32C ; escani_str
		addq.l    #8,a7
		movea.l   d0,a0
		clr.b     -1(a0)
		move.w    #3,18(a4)
		move.w    #4,20(a4)
		clr.w     22(a4)
		clr.w     24(a4)
		clr.w     26(a4)
		movea.l   a4,a5
		bra.s     xfd8a_22
xfd8a_21:
		clr.l     (a7)
		move.l    #0x00010024,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra       xfd8a_28
xfd8a_22:
		move.w    -44(a6),4(a5)
		tst.b     -20(a6)
		beq.s     xfd8a_23
		pea.l     -34(a6)
		move.l    #_getall,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		pea.l     -32(a6)
		pea.l     -20(a6)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		bra.s     xfd8a_24
xfd8a_23:
		clr.b     -34(a6)
xfd8a_24:
		move.l    a6,(a7)
		addi.l    #-34,(a7)
		dc.w      0xF24C ; strlen
		ext.l     d0
		add.l     a6,d0
		movea.l   d0,a0
		move.b    #'@',-34(a0)
		pea.l     14(a5)
		pea.l     -34(a6)
		dc.w      0xF32C ; escani_str
		addq.l    #8,a7
xfd8a_25:
		movea.l   d7,a0
		adda.l    #0x00000083,a0
		btst      #0,(a0)
		beq.s     xfd8a_26
		movea.l   -184(a6),a0
		move.b    #'0',30440(a0)
		movea.l   -184(a6),a0
		move.b    -180(a6),30441(a0)
		movea.l   -184(a6),a0
		move.b    #' ',30442(a0)
		move.l    -184(a6),(a7)
		addi.l    #30443,(a7)
		pea.l     -174(a6)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		bra.s     xfd8a_27
xfd8a_26:
		movea.l   -184(a6),a0
		clr.b     30440(a0)
xfd8a_27:
		move.w    -46(a6),d0
xfd8a_28:
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	xdef xfd8d76
xfd8d76: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   _thedesk,a5
		clr.l     (a5)
		clr.w     30568(a5)
		clr.w     30570(a5)
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef xfd8d90
xfd8d90: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		lea.l     712(a5),a0
		move.l    a0,840(a5)
		dc.w      0xF468
		moveq.l   #4,d7
		bra.s     xfd8d_2
xfd8d_1:
		move.l    a5,d0
		move.w    d7,d1
		addq.w    #1,d1
		muls.w    #140,d1
		add.l     d1,d0
		addq.l    #4,d0
		movea.l   a5,a1
		move.w    d7,d2
		muls.w    #140,d2
		adda.l    d2,a1
		move.l    d0,4(a1)
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #140,d1
		adda.l    d1,a0
		move.l    #0,134(a0)
		subq.w    #1,d7
xfd8d_2:
		tst.w     d7
		bge.s     xfd8d_1
		lea.l     4(a5),a0
		move.l    a0,704(a5)
		clr.l     708(a5)
		clr.l     564(a5)
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd8df2
xfd8df2: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		movea.l   10(a6),a5
		movea.l   14(a6),a4
		movea.l   22(a6),a3
		move.l    a5,(a7)
		dc.w      0xF24C ; strlen
		add.w     #13,d0
		cmp.w     #121,d0
		blt.s     xfd8df_1
		clr.w     d0
		bra.s     xfd8df11
xfd8df_1:
		move.b    d7,(a3)+
		move.b    #':',(a3)+
		move.b    #0x5C,(a3)+
		tst.b     (a5)
		beq.s     xfd8df_4
		bra.s     xfd8df_3
xfd8df_2:
		move.b    (a5)+,(a3)+
xfd8df_3:
		tst.b     (a5)
		bne.s     xfd8df_2
		tst.b     (a4)
		beq.s     xfd8df_4
		move.b    #0x5C,(a3)+
xfd8df_4:
		tst.b     (a4)
		beq.s     xfd8df10
xfd8df_5:
		bra.s     xfd8df_7
xfd8df_6:
		move.b    (a4)+,(a3)+
xfd8df_7:
		tst.b     (a4)
		bne.s     xfd8df_6
		movea.l   18(a6),a0
		tst.b     (a0)
		beq.s     xfd8df10
		move.b    #'.',(a3)+
		bra.s     xfd8df_9
xfd8df_8:
		movea.l   18(a6),a0
		move.b    (a0),(a3)+
		addq.l    #1,18(a6)
xfd8df_9:
		movea.l   18(a6),a0
		tst.b     (a0)
		bne.s     xfd8df_8
xfd8df10:
		clr.b     (a3)+
		moveq.l   #1,d0
xfd8df11:
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	xdef xfd8e6c
xfd8e6c: ds.b 0
		link      a6,#-8
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		move.l    a5,-4(a6)
		tst.b     (a5)+
		beq.s     xfd8e_2
		cmpi.b    #':',(a5)
		bne.s     xfd8e_2
		subq.l    #1,a5
		move.b    (a5),d0
		ext.w     d0
		movea.l   12(a6),a1
		move.w    d0,(a1)
		addq.l    #2,a5
		cmpi.b    #0x5C,(a5)
		bne.s     xfd8e_1
		addq.l    #1,a5
xfd8e_1:
		bra.s     xfd8e_16
xfd8e_2:
		dc.w      0xF46C ; dos_gdrv
		move.w    d0,-(a7)
		addi.w    #'A',(a7)
		movea.l   12(a6),a0
		move.w    (a7)+,(a0)
		movea.l   -4(a6),a5
xfd8e_16:
		move.l    a5,-8(a6)
		movea.l   a5,a4
		suba.l    a3,a3
		bra.s     xfd8e_6
xfd8e_3:
		cmpi.b    #0x5C,(a5)
		bne.s     xfd8e_4
		movea.l   a5,a4
xfd8e_4:
		cmpi.b    #'.',(a5)
		bne.s     xfd8e_5
		movea.l   a5,a3
xfd8e_5:
		addq.l    #1,a5
xfd8e_6:
		tst.b     (a5)
		bne.s     xfd8e_3
		move.l    a3,d0
		bne.s     xfd8e_7
		movea.l   a5,a3
xfd8e_7:
		bra.s     xfd8e_9
xfd8e_8:
		movea.l   16(a6),a0
		movea.l   -8(a6),a1
		move.b    (a1),(a0)
		addq.l    #1,-8(a6)
		addq.l    #1,16(a6)
xfd8e_9:
		cmpa.l    -8(a6),a4
		bne.s     xfd8e_8
		movea.l   16(a6),a0
		clr.b     (a0)
		cmpi.b    #0x5C,(a4)
		bne.s     xfd8e_10
		addq.l    #1,a4
xfd8e_10:
		bra.s     xfd8e_12
xfd8e_11:
		movea.l   20(a6),a0
		move.b    (a4)+,(a0)
		addq.l    #1,20(a6)
xfd8e_12:
		cmpa.l    a3,a4
		bne.s     xfd8e_11
		movea.l   20(a6),a0
		clr.b     (a0)
		tst.b     (a3)
		beq.s     xfd8e_15
		addq.l    #1,a3
		bra.s     xfd8e_14
xfd8e_13:
		movea.l   24(a6),a0
		move.b    (a3)+,(a0)
		addq.l    #1,24(a6)
xfd8e_14:
		cmpa.l    a5,a3
		bne.s     xfd8e_13
xfd8e_15:
		movea.l   24(a6),a0
		clr.b     (a0)
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef xfd8f32
xfd8f32: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		tst.l     (a5)
		beq.s     xfd8f3_1
		move.l    (a5),(a7)
		dc.w      0xF3F0 ; dos_free
		clr.l     (a5)
xfd8f3_1:
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef xfd8f4a
xfd8f4a: ds.b 0
		link      a6,#-4
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		tst.l     (a5)
		bne.s     xfd8f4_2
		dc.w      0xF3B8 ; dos_avail
		move.l    d0,d7
		cmp.l     #40,d7
		blt.s     xfd8f4_1
		move.l    d7,(a7)
		dc.w      0xF3C0 ; dos_alloc
		move.l    d0,(a5)
		clr.w     30568(a5)
		move.l    #40,-(a7)
		move.l    d7,-(a7)
		jsr       _ldiv
		addq.l    #8,a7
		move.w    d0,30570(a5)
		bra.s     xfd8f4_2
xfd8f4_1:
		bra.s     xfd8f4_3
xfd8f4_2:
		move.w    30568(a5),d0
		cmp.w     30570(a5),d0
		bcc.s     xfd8f4_3
		move.l    (a5),-4(a6)
		move.w    30568(a5),d0
		mulu.w    #40,d0
		add.l     -4(a6),d0
		addq.w    #1,30568(a5)
		bra.s     xfd8f4_4
xfd8f4_3:
		clr.l     d0
xfd8f4_4:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd8fae
xfd8fae: ds.b 0
		link      a6,#0
		movem.l   d7/a4-a5,-(a7)
		movea.l   _thedesk,a4
		tst.l     704(a4)
		beq.s     xfd8fa_1
		movea.l   704(a4),a5
		movea.l   704(a4),a0
		move.l    (a0),704(a4)
		move.l    708(a4),(a5)
		move.l    a5,708(a4)
		clr.w     4(a5)
		clr.l     130(a5)
		move.l    a5,d0
		bra.s     xfd8fa_2
xfd8fa_1:
		clr.l     d0
xfd8fa_2:
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef xfd8fe6
xfd8fe6: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		dc.w      0xF470
		movea.l   d0,a5
		move.l    a5,d0
		beq.s     xfd8fe_1
		pea.l     8(a5)
		move.l    18(a6),-(a7)
		move.l    14(a6),-(a7)
		move.l    10(a6),-(a7)
		move.w    8(a6),-(a7)
		dc.w      0xF474
		adda.w    #18,a7
		tst.w     d0
		beq.s     xfd8fe_1
		move.w    22(a6),6(a5)
		move.l    a5,d0
		bra.s     xfd8fe_2
xfd8fe_1:
		clr.l     d0
xfd8fe_2:
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef xfd9022
xfd9022: ds.b 0
		link      a6,#0
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a3
		move.l    a5,(a7)
		addi.l    #130,(a7)
		dc.w      0xF478
		lea.l     708(a3),a4
		bra.s     xfd902_2
xfd902_1:
		movea.l   (a4),a4
xfd902_2:
		cmpa.l    (a4),a5
		bne.s     xfd902_1
		move.l    (a5),(a4)
		move.l    704(a3),(a5)
		move.l    a5,704(a3)
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef xfd9056
xfd9056: ds.b 0
		link      a6,#-4
		movem.l   d6-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   12(a6),a4
		lea.l     18(a5),a3
		lea.l     18(a4),a0
		move.l    a0,-4(a6)
		move.w    16(a6),d0
		bra       xfd90_9
xfd90_1:
		move.l    14(a4),d0
		cmp.l     14(a5),d0
		ble.s     xfd90_2
		moveq.l   #1,d0
		bra       xfd90_10
xfd90_2:
		move.l    14(a4),d0
		cmp.l     14(a5),d0
		bge.s     xfd90_3
		moveq.l   #-1,d0
		bra.w     xfd90_10
xfd90_3:
		move.l    -4(a6),(a7)
		move.l    a3,-(a7)
		dc.w      0xF47C ; strchk
		addq.l    #4,a7
		bra.w     xfd90_10
xfd90_4:
		move.w    #'.',(a7)
		move.l    -4(a6),-(a7)
		dc.w      0xF480 ; scasb
		addq.l    #4,a7
		move.l    d0,(a7)
		move.w    #'.',-(a7)
		move.l    a3,-(a7)
		dc.w      0xF480 ; scasb
		addq.l    #6,a7
		move.l    d0,-(a7)
		dc.w      0xF47C ; strchk
		addq.l    #4,a7
		move.w    d0,d7
		beq.s     xfd90_5
		move.w    d7,d0
		bra.s     xfd90_10
xfd90_5:
		move.l    -4(a6),(a7)
		move.l    a3,-(a7)
		dc.w      0xF47C ; strchk
		addq.l    #4,a7
		bra.s     xfd90_10
xfd90_6:
		move.w    12(a4),d7
		sub.w     12(a5),d7
		tst.w     d7
		beq.s     xfd90_7
		move.w    d7,d0
		bra.s     xfd90_10
		bra.s     xfd90_8
xfd90_7:
		move.w    10(a4),d0
		lsr.w     #5,d0
		move.w    10(a5),d1
		lsr.w     #5,d1
		sub.w     d1,d0
		bra.s     xfd90_10
xfd90_8:
		bra.s     xfd90_10
xfd90_9:
		tst.w     d0
		beq.s     xfd90_5
		cmp.w     #1,d0
		beq.s     xfd90_6
		cmp.w     #2,d0
		beq       xfd90_1
		cmp.w     #3,d0
		beq.s     xfd90_4
xfd90_10:
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	xdef xfd9118
xfd9118: ds.b 0
		link      a6,#-46
		movem.l   d3-d7/a5,-(a7)
		move.w    8(a6),d7
		cmp.w     #-1,d7
		bne.s     xfd91_3
		clr.w     d7
		movea.l   10(a6),a5
		bra.s     xfd91_2
xfd91_1:
		move.w    d7,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.l    a5,4(a0)
		addq.w    #1,d7
		movea.l   (a5),a5
xfd91_2:
		move.l    a5,d0
		bne.s     xfd91_1
xfd91_3:
		tst.w     d7
		bne.s     xfd91_4
		move.l    10(a6),d0
		bra       xfd91_22
xfd91_4:
		move.w    d7,d4
		ext.l     d4
		divs.w    #2,d4
		bra       xfd91_15
xfd91_5:
		move.w    d4,d6
		bra       xfd91_14
xfd91_6:
		move.w    d6,d5
		sub.w     d4,d5
		bra       xfd91_12
xfd91_7:
		movea.l   10(a6),a0
		move.w    d5,d1
		muls.w    #40,d1
		movea.l   4(a0,d1.l),a0
		move.b    9(a0),d0
		ext.w     d0
		move.w    d5,d1
		add.w     d4,d1
		muls.w    #40,d1
		add.l     10(a6),d1
		movea.l   d1,a1
		movea.l   4(a1),a1
		move.b    9(a1),d1
		ext.w     d1
		eor.w     d1,d0
		and.w     #0x0010,d0
		beq.s     xfd91_10
		movea.l   10(a6),a0
		move.w    d5,d1
		muls.w    #40,d1
		movea.l   4(a0,d1.l),a0
		btst      #4,9(a0)
		beq.s     xfd91_8
		moveq.l   #-1,d0
		bra.s     xfd91_9
xfd91_8:
		moveq.l   #1,d0
xfd91_9:
		move.w    d0,-46(a6)
		bra.s     xfd91_11
xfd91_10:
		movea.l   _thedesk,a0
		move.w    12308(a0),(a7)
		movea.l   10(a6),a0
		move.w    d5,d1
		add.w     d4,d1
		muls.w    #40,d1
		move.l    4(a0,d1.l),-(a7)
		movea.l   10(a6),a0
		move.w    d5,d1
		muls.w    #40,d1
		move.l    4(a0,d1.l),-(a7)
		dc.w      0xF484
		addq.l    #8,a7
		move.w    d0,-46(a6)
xfd91_11:
		tst.w     -46(a6)
		ble.s     xfd91_13
		move.w    d5,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		movea.l   4(a0),a5
		move.w    d5,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.w    d5,d1
		add.w     d4,d1
		muls.w    #40,d1
		add.l     10(a6),d1
		movea.l   d1,a1
		move.l    4(a1),4(a0)
		move.w    d5,d0
		add.w     d4,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.l    a5,4(a0)
		sub.w     d4,d5
xfd91_12:
		tst.w     d5
		bge       xfd91_7
xfd91_13:
		addq.w    #1,d6
xfd91_14:
		cmp.w     d7,d6
		blt       xfd91_6
		ext.l     d4
		divs.w    #2,d4
xfd91_15:
		tst.w     d4
		bgt       xfd91_5
		clr.l     -4(a6)
		lea.l     -4(a6),a5
		clr.w     d6
		bra.s     xfd91_17
xfd91_16:
		move.w    d6,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.l    4(a0),(a5)
		move.w    d6,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		movea.l   4(a0),a5
		addq.w    #1,d6
xfd91_17:
		cmp.w     d7,d6
		blt.s     xfd91_16
		clr.l     (a5)
		pea.l     -44(a6)
		move.l    -4(a6),-(a7)
		move.w    #40,-(a7)
		dc.w      0xF390 ; movs
		adda.w    #10,a7
		move.l    -4(a6),(a7)
		move.l    10(a6),-(a7)
		move.w    #40,-(a7)
		dc.w      0xF390 ; movs
		addq.l    #6,a7
		move.l    10(a6),(a7)
		pea.l     -44(a6)
		move.w    #40,-(a7)
		dc.w      0xF390 ; movs
		addq.l    #6,a7
		clr.w     d6
		bra.s     xfd91_21
xfd91_18:
		movea.l   10(a6),a0
		move.w    d6,d1
		muls.w    #40,d1
		move.l    0(a0,d1.l),d0
		cmp.l     10(a6),d0
		bne.s     xfd91_19
		move.w    d6,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.l    -4(a6),(a0)
		bra.s     xfd91_20
xfd91_19:
		movea.l   10(a6),a0
		move.w    d6,d1
		muls.w    #40,d1
		move.l    0(a0,d1.l),d0
		cmp.l     -4(a6),d0
		bne.s     xfd91_20
		move.w    d6,d0
		muls.w    #40,d0
		add.l     10(a6),d0
		movea.l   d0,a0
		move.l    10(a6),(a0)
xfd91_20:
		addq.w    #1,d6
xfd91_21:
		cmp.w     d7,d6
		blt.s     xfd91_18
		move.l    10(a6),d0
xfd91_22:
		dc.w      0xF83D ; movem.l (a7)+,d4-d7/a5

	xdef xfd931a
xfd931a: ds.b 0
		link      a6,#-4
		movem.l   d4-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		cmpi.b    #'c',8(a5)
		bne.s     xfd93_1
		moveq.l   #1,d5
		bra.s     xfd93_2
xfd93_1:
		clr.w     d5
xfd93_2:
		movea.l   _thedesk,a3
		clr.w     134(a5)
		clr.l     136(a5)
		move.l    a5,(a7)
		addi.l    #130,(a7)
		dc.w      0xF478
		suba.l    a4,a4
		tst.w     d5
		beq.s     xfd93_3
		move.w    6(a5),(a7)
		movea.l   _thedesk,a0
		move.l    840(a0),-(a7)
		dc.w      0xF488 ; cart_sfirst
		addq.l    #4,a7
		move.w    d0,d7
		bra.s     xfd93_4
xfd93_3:
		movea.l   _thedesk,a0
		move.l    840(a0),(a7)
		dc.w      0xF3F4 ; dos_sdta
		move.w    6(a5),(a7)
		pea.l     8(a5)
		dc.w      0xF3FC ; dos_sfirst
		addq.l    #4,a7
		move.w    d0,d7
xfd93_4:
		bra       xfd93_11
xfd93_5:
		movea.l   _thedesk,a0
		cmpi.b    #'.',742(a0)
		bne.s     xfd93_6
		movea.l   _thedesk,a0
		cmpi.b    #'.',743(a0)
		beq.s     xfd93_9
		movea.l   _thedesk,a0
		tst.b     743(a0)
		beq.s     xfd93_9
xfd93_6:
		movea.l   _thedesk,a0
		move.b    733(a0),d0
		ext.w     d0
		and.w     #6,d0
		bne.s     xfd93_9
		dc.w      0xF48C
		movea.l   d0,a4
		move.l    a4,d0
		bne.s     xfd93_7
		clr.w     d7
		move.w    #100,_DOS_AX
		bra.s     xfd93_12
xfd93_7:
		pea.l     8(a4)
		move.l    _thedesk,-(a7)
		addi.l    #732,(a7)
		move.w    #23,-(a7)
		dc.w      0xF390 ; movs
		adda.w    #10,a7
		move.l    14(a4),d0
		add.l     d0,136(a5)
		move.l    a4,4(a4)
		tst.w     134(a5)
		bne.s     xfd93_8
		move.l    a4,130(a5)
xfd93_8:
		addq.w    #1,134(a5)
xfd93_9:
		tst.w     d5
		beq.s     xfd93_10
		dc.w      0xF490 ; cart_snext
		move.w    d0,d7
		bra.s     xfd93_11
xfd93_10:
		dc.w      0xF414 ; dos_snext
		move.w    d0,d7
xfd93_11:
		tst.w     d7
		bne       xfd93_5
xfd93_12:
		tst.w     134(a5)
		beq.s     xfd93_13
		move.l    130(a5),(a7)
		move.w    134(a5),-(a7)
		dc.w      0xF494
		addq.l    #2,a7
		move.l    d0,130(a5)
		move.l    (a3),-4(a6)
		clr.l     d6
		move.w    30568(a3),d6
		move.l    #40,-(a7)
		move.l    d6,-(a7)
		jsr       _lmul
		addq.l    #8,a7
		move.l    d0,d6
		add.l     -4(a6),d6
		sub.l     (a3),d6
		move.l    d6,(a7)
		move.l    (a3),-(a7)
		clr.w     -(a7)
		move.w    #74,-(a7) ; Mshrink
		dc.w      0xF0D8 ; trap
		addq.l    #8,a7
		bra.s     xfd93_15
xfd93_13:
		tst.l     130(a5)
		beq.s     xfd93_14
		move.l    130(a5),(a7)
		dc.w      0xF3F0 ; dos_free
xfd93_14:
		clr.l     130(a5)
xfd93_15:
		dc.w      0xF468
		move.w    _DOS_AX,d0
		dc.w      0xFE39 ; movem.l (a7)+,d5-d7/a3-a5

	xdef _fill_string
_fill_string: ds.b 0
		link      a6,#0
		movem.l   d7/a4-a5,-(a7)
		movea.l   _g_buffer,a5
		movea.l   _thedesk,a4
		pea.l     13650(a4)
		move.w    10(a6),-(a7)
		move.w    #5,-(a7)
		dc.w      0xF0E0 ; rsrc_gaddr
		addq.l    #8,a7
		tst.l     12(a6)
		beq.s     fill_s1
		move.l    12(a6),(a7)
		move.l    13650(a4),-(a7)
		move.l    a5,-(a7)
		dc.w      0xF498 ; merge_str
		addq.l    #8,a7
		move.l    a5,13650(a4)
fill_s1:
		move.l    13650(a4),(a7)
		move.w    8(a6),-(a7)
		dc.w      0xF49C ; form_alert
		addq.l    #2,a7
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef _send_msg
_send_msg: ds.b 0
		link      a6,#-20
		move.w    8(a6),-16(a6)
		move.w    _gl_apid,-14(a6)
		clr.w     -12(a6)
		move.w    12(a6),-10(a6)
		move.w    14(a6),-8(a6)
		move.w    16(a6),-6(a6)
		move.w    18(a6),-4(a6)
		move.w    20(a6),-2(a6)
		pea.l     -16(a6)
		move.w    #16,-(a7)
		move.w    _gl_apid,-(a7)
		dc.w      0xF4A0 ; appl_write
		addq.l    #8,a7
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _up_allwin
_up_allwin: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a5,-(a7)
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		moveq.l   #4,d7
		bra.s     up_all5
up_all1:
		move.w    d7,(a7)
		dc.w      0xF4A4
		movea.l   d0,a5
		tst.w     6(a5)
		beq.s     up_all4
		tst.w     12(a6)
		beq.s     up_all3
		move.l    8(a6),(a7)
		move.l    24(a5),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     up_all2
		move.l    a5,(a7)
		dc.w      0xF4A8
up_all2:
		bra.s     up_all4
up_all3:
		movea.l   24(a5),a0
		move.b    8(a0),d0
		ext.w     d0
		movea.l   8(a6),a1
		move.b    (a1),d1
		ext.w     d1
		cmp.w     d1,d0
		bne.s     up_all4
		move.l    a5,(a7)
		dc.w      0xF4A8
up_all4:
		subq.w    #1,d7
up_all5:
		tst.w     d7
		bne.s     up_all1
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd9572
xfd9572: ds.b 0
		link      a6,#-4
		movem.l   d6-d7/a5,-(a7)
		movea.l   8(a6),a5
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.l    24(a5),d0
		addq.l    #8,d0
		move.l    d0,-4(a6)
		moveq.l   #4,d7
		bra.s     xfd95_3
xfd95_1:
		move.w    d7,(a7)
		dc.w      0xF4A4
		movea.l   d0,a5
		tst.w     6(a5)
		beq.s     xfd95_2
		move.l    -4(a6),(a7)
		move.l    24(a5),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd95_2
		move.l    a5,(a7)
		dc.w      0xF4A8
xfd95_2:
		subq.w    #1,d7
xfd95_3:
		tst.w     d7
		bne.s     xfd95_1
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd95c0
xfd95c0: ds.b 0
		link      a6,#-8
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.l    24(a5),(a7)
		dc.w      0xF4AC
		move.w    #1,(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		move.l    a5,(a7)
		dc.w      0xF4B4
		clr.l     -(a7)
		pea.l     149(a5)
		move.w    #3,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4B8 ; wind_set
		adda.w    #12,a7
		pea.l     -8(a6)
		move.w    #4,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4BC
		addq.l    #8,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    6(a5),-(a7)
		move.w    _gl_apid,-(a7)
		move.w    #20,-(a7)
		dc.w      0xF4C0 ; send_msg
		adda.w    #14,a7
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef xfd9624
xfd9624: ds.b 0
		link      a6,#-78
		movem.l   d4-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a0
		move.l    13690(a0),d7
		movea.l   24(a5),a4
		movea.l   _thedesk,a3
		adda.l    #12310,a3
		move.l    a3,(a7)
		pea.l     8(a4)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		clr.w     d5
		bra.s     xfd96_2
xfd96_1:
		cmpi.b    #0x5C,(a3)
		bne.s     xfd96_2
		addq.w    #1,d5
xfd96_2:
		tst.b     (a3)+
		bne.s     xfd96_1
		cmp.w     #8,d5
		ble.s     xfd96_3
		clr.l     (a7)
		move.l    #0x00010017,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra       xfd96_10
xfd96_3:
		clr.b     -12(a6)
		pea.l     -12(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		clr.w     d6
		clr.w     (a7)
		move.l    d7,-(a7)
		dc.w      0xF4C4 ; xform_do
		addq.l    #4,a7
		cmp.w     #2,d0
		bne       xfd96_9
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		pea.l     -12(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF42C ; fs_sget
		adda.w    #10,a7
		pea.l     -26(a6)
		pea.l     -12(a6)
		dc.w      0xF430 ; unfmt_str
		addq.l    #8,a7
		tst.b     -26(a6)
		beq       xfd96_9
		pea.l     -26(a6)
		move.l    _thedesk,-(a7)
		addi.l    #12310,(a7)
		dc.w      0xF3F8
		addq.l    #8,a7
		move.l    a6,(a7)
		addi.l    #-76,(a7)
		dc.w      0xF3F4 ; dos_sdta
		move.w    #22,(a7)
		move.l    _thedesk,-(a7)
		addi.l    #12310,(a7)
		dc.w      0xF3FC ; dos_sfirst
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd96_6
		clr.l     (a7)
		move.l    #0x00010015,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		subq.w    #1,d0
		beq.s     xfd96_4
		clr.w     d0
		bra.s     xfd96_5
xfd96_4:
		moveq.l   #1,d0
xfd96_5:
		move.w    d0,d6
		bra.s     xfd96_8
xfd96_6:
		move.l    _thedesk,(a7)
		addi.l    #12310,(a7)
		dc.w      0xF410 ; dos_mkdir
		cmpi.w    #5,_DOS_AX
		bne.s     xfd96_7
		clr.l     (a7)
		move.l    #0x00010016,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfd96_8
xfd96_7:
		dc.w      0xF374 ; dos_error
		tst.w     d0
		beq.s     xfd96_8
		move.l    a5,(a7)
		dc.w      0xF4C8
xfd96_8:
		move.l    _thedesk,(a7)
		addi.l    #12310,(a7)
		dc.w      0xF424 ; rep_all
xfd96_9:
		tst.w     d6
		bne       xfd96_3
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		moveq.l   #1,d0
xfd96_10:
		dc.w      0xFE39 ; movem.l (a7)+,d5-d7/a3-a5

	xdef xfd9768
xfd9768: ds.b 0
		link      a6,#-8
		movem.l   d5-d7/a4-a5,-(a7)
		move.w    8(a6),d7
		movea.l   10(a6),a5
		cmp.w     #-1,d7
		beq       xfd97_8
		pea.l     -8(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.l    _thedesk,-(a7)
		addi.l    #12982,(a7)
		move.l    130(a5),-(a7)
		pea.l     8(a5)
		clr.w     -(a7)
		dc.w      0xF4CC
		adda.w    #26,a7
		tst.w     d0
		bne.s     xfd97_1
		clr.w     d0
		bra       xfd97_9
xfd97_1:
		cmp.w     #2,d7
		beq.s     xfd97_2
		cmp.w     #3,d7
		bne.s     xfd97_7
xfd97_2:
		move.l    _thedesk,(a7)
		addi.l    #12982,(a7)
		move.l    130(a5),-(a7)
		pea.l     8(a5)
		dc.w      0xF4D0
		addq.l    #8,a7
		tst.w     d0
		beq.s     xfd97_6
		move.w    x00a786,d6
		subq.w    #2,d6
		movea.l   _thedesk,a4
		adda.l    #12982,a4
		bra.s     xfd97_4
xfd97_3:
		cmpi.b    #0x5C,(a4)
		bne.s     xfd97_4
		addq.w    #1,d6
xfd97_4:
		tst.b     (a4)+
		bne.s     xfd97_3
		cmp.w     #9,d6
		ble.s     xfd97_5
		clr.l     (a7)
		move.l    #0x00010017,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra.s     xfd97_9
xfd97_5:
		bra.s     xfd97_7
xfd97_6:
		clr.w     d0
		bra.s     xfd97_9
xfd97_7:
		pea.l     -8(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.l    _thedesk,-(a7)
		addi.l    #12982,(a7)
		move.l    130(a5),-(a7)
		pea.l     8(a5)
		move.w    d7,-(a7)
		dc.w      0xF4CC
		adda.w    #26,a7
		moveq.l   #1,d0
		bra.s     xfd97_9
xfd97_8:
		clr.w     d0
xfd97_9:
		dc.w      0xFC31 ; movem.l (a7)+,d6-d7/a4-a5

	xdef xfd9848
xfd9848: ds.b 0
		link      a6,#-6
		movem.l   d6-d7/a5,-(a7)
		movea.l   12(a6),a5
		moveq.l   #-1,d7
		move.l    a5,d0
		beq.w     xfd98_6
		move.w    6(a5),d0
		bra.s     xfd98_5
xfd98_1:
		clr.l     (a7)
		move.l    #0x00010018,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra       xfd98_10
xfd98_2:
		bra.s     xfd98_6
xfd98_3:
		moveq.l   #1,d7
		bra.s     xfd98_6
xfd98_4:
		move.w    16(a6),(a7)
		move.l    _thedesk,-(a7)
		addi.l    #24200,(a7)
		dc.w      0xF4D4
		addq.l    #4,a7
		move.l    d0,-4(a6)
		movea.l   -4(a6),a0
		move.w    12(a0),d0
		and.w     #255,d0
		movea.l   _thedesk,a1
		move.b    d0,12982(a1)
		move.l    _thedesk,(a7)
		addi.l    #12983,(a7)
		move.l    #xfeb15c,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		moveq.l   #2,d7
		bra.s     xfd98_6
xfd98_5:
		cmp.w     #2,d0
		beq.s     xfd98_4
		cmp.w     #3,d0
		beq.s     xfd98_3
		cmp.w     #4,d0
		beq.s     xfd98_1
xfd98_6:
		move.l    8(a6),(a7)
		move.w    d7,-(a7)
		dc.w      0xF4D8
		addq.l    #2,a7
		move.w    d0,-6(a6)
		tst.w     -6(a6)
		beq.s     xfd98_9
		cmpi.w    #2,6(a5)
		bne.s     xfd98_7
		move.w    #1,(a7)
		move.l    _thedesk,-(a7)
		addi.l    #12982,(a7)
		dc.w      0xF380 ; up_allwin
		addq.l    #4,a7
		bra.s     xfd98_8
xfd98_7:
		cmpi.w    #3,6(a5)
		bne.s     xfd98_9
xfd98_8:
		move.w    #1,(a7)
		move.l    8(a6),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF380 ; up_allwin
		addq.l    #4,a7
xfd98_9:
		move.w    -6(a6),d0
xfd98_10:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd9922
xfd9922: ds.b 0
		link      a6,#-2
		movem.l   d7/a3-a5,-(a7)
		movea.l   16(a6),a5
		movea.l   20(a6),a4
		move.l    _thedesk,(a7)
		addi.l    #12982,(a7)
		move.l    12(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		movea.l   _thedesk,a3
		adda.l    #12982,a3
		bra.s     xfd99_2
xfd99_1:
		addq.l    #1,a3
xfd99_2:
		cmpi.b    #'*',(a3)
		bne.s     xfd99_1
		clr.b     (a3)
		move.l    a5,d0
		beq.s     xfd99_3
		cmpi.w    #1,6(a5)
		bne.s     xfd99_3
		move.l    a3,(a7)
		pea.l     18(a4)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		movea.l   d0,a3
		pea.l     -1(a3)
		move.l    #_wilds,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		bra.s     xfd99_4
xfd99_3:
		move.l    a3,(a7)
		move.l    #_getall,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
xfd99_4:
		move.l    #x00634c,(a7)
		move.l    _thedesk,-(a7)
		addi.l    #12982,(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #4,a7
		move.l    8(a6),(a7)
		move.w    #2,-(a7)
		dc.w      0xF4D8
		addq.l    #2,a7
		move.w    d0,-2(a6)
		tst.w     -2(a6)
		beq.s     xfd99_5
		move.w    #1,(a7)
		move.l    #x00634c,-(a7)
		dc.w      0xF380 ; up_allwin
		addq.l    #4,a7
		move.w    #1,(a7)
		move.l    8(a6),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF380 ; up_allwin
		addq.l    #4,a7
xfd99_5:
		move.w    -2(a6),d0
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef xfd99e0
xfd99e0: ds.b 0
		link      a6,#-12
		clr.l     (a7)
		clr.l     -(a7)
		move.w    10(a6),-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		dc.w      0xF4DC
		adda.w    #10,a7
		move.l    d0,-8(a6)
		move.w    8(a6),(a7)
		dc.w      0xF2EC
		move.l    d0,-4(a6)
		movea.l   _thedesk,a0
		move.l    13736(a0),(a7)
		move.l    -4(a6),-(a7)
		addi.l    #28,(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd99e_5
		movea.l   -8(a6),a0
		move.w    6(a0),d0
		bra.s     xfd99e_3
xfd99e_1:
		clr.l     (a7)
		move.l    #0x00010018,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfd99e_4
xfd99e_2:
		move.w    #5,(a7)
		dc.w      0xF0E8 ; form_error
		bra.s     xfd99e_4
xfd99e_3:
		cmp.w     #2,d0
		beq.s     xfd99e_1
		cmp.w     #3,d0
		beq.s     xfd99e_2
		cmp.w     #4,d0
		beq.s     xfd99e_1
xfd99e_4:
		bra.s     xfd99e_6
xfd99e_5:
		move.w    10(a6),(a7)
		move.l    -8(a6),-(a7)
		movea.l   -4(a6),a0
		move.l    24(a0),-(a7)
		dc.w      0xF4E0
		addq.l    #8,a7
xfd99e_6:
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef xfd9a6c
xfd9a6c: ds.b 0
		link      a6,#-4
		movem.l   d6-d7/a4-a5,-(a7)
		move.w    8(a6),(a7)
		move.l    _thedesk,-(a7)
		addi.l    #24200,(a7)
		dc.w      0xF4D4
		addq.l    #4,a7
		move.l    d0,-4(a6)
		movea.l   -4(a6),a0
		move.w    12(a0),(a7)
		dc.w      0xF4E4
		tst.w     d0
		bne.s     xfd9a_1
		clr.w     d0
		bra       xfd9a_8
xfd9a_1:
		move.w    #22,(a7)
		move.l    #xfeb165,-(a7)
		move.l    #xfeb163,-(a7)
		move.l    #xfeb162,-(a7)
		movea.l   -4(a6),a0
		move.w    12(a0),-(a7)
		dc.w      0xF4E8
		adda.w    #14,a7
		movea.l   d0,a4
		move.l    a4,d0
		beq.s     xfd9a_7
		move.l    a4,(a7)
		dc.w      0xF4AC
		clr.w     d7
		tst.l     130(a4)
		beq.s     xfd9a_6
		movea.l   130(a4),a5
		bra.s     xfd9a_3
xfd9a_2:
		clr.w     32(a5)
		movea.l   (a5),a5
xfd9a_3:
		move.l    a5,d0
		bne.s     xfd9a_2
		movea.l   _thedesk,a0
		move.w    #1,24210(a0)
		tst.l     10(a6)
		beq.s     xfd9a_4
		move.l    18(a6),(a7)
		move.l    14(a6),-(a7)
		movea.l   10(a6),a0
		move.l    24(a0),-(a7)
		addq.l    #8,(a7)
		move.l    a4,-(a7)
		dc.w      0xF4EC
		adda.w    #12,a7
		move.w    d0,d7
		bra.s     xfd9a_5
xfd9a_4:
		move.w    22(a6),(a7)
		move.l    14(a6),-(a7)
		move.l    a4,-(a7)
		dc.w      0xF4E0
		addq.l    #8,a7
		move.w    d0,d7
xfd9a_5:
		movea.l   _thedesk,a0
		clr.w     24210(a0)
xfd9a_6:
		move.l    a4,(a7)
		dc.w      0xF4F0
		clr.w     (a7)
		dc.w      0xF444 ; hd_win
xfd9a_7:
		move.w    d7,d0
xfd9a_8:
		dc.w      0xFC21 ; movem.l (a7)+,d7/a4-a5

	xdef xfd9b3c
xfd9b3c: ds.b 0
		link      a6,#-10
		movem.l   d5-d7/a3-a5,-(a7)
		move.w    10(a6),d7
		move.w    8(a6),(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		pea.l     -6(a6)
		pea.l     -4(a6)
		move.w    d7,-(a7)
		move.w    8(a6),-(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a3
		clr.w     d6
		bra.s     xfd9b3_3
xfd9b3_4:
		pea.l     -6(a6)
		pea.l     -10(a6)
		move.w    d6,-(a7)
		clr.w     -(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a4
		cmpi.w    #3,6(a4)
		bne.s     xfd9b3_1
		clr.l     (a7)
		move.l    #0x00010014,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfd9b3_3
xfd9b3_1:
		cmpi.w    #4,6(a4)
		bne.s     xfd9b3_2
		clr.l     (a7)
		move.l    #0x00010018,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfd9b3_3
xfd9b3_2:
		move.w    d7,(a7)
		move.l    -4(a6),-(a7)
		move.l    a3,-(a7)
		move.l    a5,-(a7)
		move.w    d6,-(a7)
		dc.w      0xF4F4
		adda.w    #14,a7
		tst.w     d0
		beq.s     xfd9b3_3
		move.l    a5,(a7)
		dc.w      0xF4C8
xfd9b3_3:
		move.w    d6,(a7)
		move.w    #1,-(a7)
		move.l    _thedesk,-(a7)
		addi.l    #24200,(a7)
		dc.w      0xF4F8
		addq.l    #6,a7
		move.w    d0,d6
		bne.s     xfd9b3_4
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfd9be0
xfd9be0: ds.b 0
		link      a6,#-52
		movem.l   d7/a3-a5,-(a7)
		movea.l   _thedesk,a3
		clr.w     -48(a6)
		clr.l     (a7)
		clr.l     -(a7)
		move.w    8(a6),-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		dc.w      0xF4DC
		adda.w    #10,a7
		movea.l   d0,a4
		clr.w     -2(a6)
		bra       xfd9b_13
xfd9b_1:
		pea.l     -4(a6)
		pea.l     -8(a6)
		move.w    -2(a6),-(a7)
		clr.w     -(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a5
		cmpa.l    a4,a5
		beq       xfd9b_13
		cmpi.w    #4,6(a5)
		beq.s     xfd9b_2
		cmpi.w    #3,6(a5)
		bne.s     xfd9b_3
xfd9b_2:
		clr.l     (a7)
		move.l    #0x00010010,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra       xfd9b_14
		bra       xfd9b_13
xfd9b_3:
		move.w    6(a4),d0
		bra       xfd9b_12
xfd9b_4:
		clr.l     (a7)
		move.l    #0x00010011,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra       xfd9b_14
xfd9b_5:
		clr.l     (a7)
		move.l    #0x00010018,-(a7)
xfd9b_6:
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra       xfd9b_14
xfd9b_7:
		bra       xfd9b_13
xfd9b_8:
		move.w    -2(a6),(a7)
		pea.l     24200(a3)
		dc.w      0xF4D4
		addq.l    #4,a7
		move.l    d0,-16(a6)
		move.w    8(a6),(a7)
		pea.l     24200(a3)
		dc.w      0xF4D4
		addq.l    #4,a7
		move.l    d0,-20(a6)
		movea.l   -16(a6),a0
		move.w    12(a0),d0
		and.w     #255,d0
		move.b    d0,-34(a6)
		clr.b     -33(a6)
		move.b    #' ',-32(a6)
		movea.l   -20(a6),a0
		move.w    12(a0),d0
		and.w     #255,d0
		move.b    d0,-31(a6)
		clr.b     -30(a6)
		cmpi.b    #'B',-34(a6)
		bgt.s     xfd9b_9
		cmpi.b    #'A',-34(a6)
		blt.s     xfd9b_9
		cmpi.b    #'B',-31(a6)
		bgt.s     xfd9b_9
		cmpi.b    #'A',-31(a6)
		bge.s     xfd9b_10
xfd9b_9:
		clr.l     (a7)
		move.l    #0x00010021,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		clr.w     d0
		bra.w     xfd9b_14
xfd9b_10:
		lea.l     -34(a6),a0
		move.l    a0,-46(a6)
		lea.l     -31(a6),a0
		move.l    a0,-42(a6)
		lea.l     -31(a6),a0
		move.l    a0,-38(a6)
		pea.l     -46(a6)
		move.l    #0x00020012,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #8,a7
		cmp.w     #1,d0
		bne.s     xfd9b_11
		move.w    #0x00FB,(a7)
		pea.l     -34(a6)
		dc.w      0xF4FC ; fc_start
		addq.l    #4,a7
		clr.w     -48(a6)
xfd9b_11:
		bra.s     xfd9b_13
xfd9b_12:
		cmp.w     #2,d0
		beq       xfd9b_8
		cmp.w     #3,d0
		beq       xfd9b_4
		cmp.w     #4,d0
		beq       xfd9b_5
xfd9b_13:
		move.w    -2(a6),(a7)
		move.w    #1,-(a7)
		pea.l     24200(a3)
		dc.w      0xF4F8
		addq.l    #6,a7
		move.w    d0,-2(a6)
		bne       xfd9b_1
		move.w    -48(a6),d0
xfd9b_14:
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef xfd9d76
xfd9d76: ds.b 0
		link      a6,#-8
		movem.l   d3-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		move.w    10(a6),d6
		move.w    12(a6),d5
		move.w    14(a6),d4
		clr.w     -2(a6)
		tst.w     d7
		beq       xfd9d_7
		tst.w     d6
		beq       xfd9d_4
		move.w    d7,(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.w    d6,(a7)
		dc.w      0xF2EC
		movea.l   d0,a4
		movea.l   _thedesk,a0
		move.l    13736(a0),(a7)
		pea.l     28(a5)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd9d_1
		movea.l   _thedesk,a0
		move.l    13736(a0),(a7)
		pea.l     28(a4)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd9d_2
xfd9d_1:
		clr.l     (a7)
		move.l    #0x00010018,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfd9d_3
xfd9d_2:
		pea.l     -4(a6)
		pea.l     -8(a6)
		move.w    d4,-(a7)
		move.w    d6,-(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a3
		move.l    -8(a6),(a7)
		move.l    a3,-(a7)
		move.l    24(a4),-(a7)
		addq.l    #8,(a7)
		move.l    24(a5),-(a7)
		dc.w      0xF4EC
		adda.w    #12,a7
		tst.w     d0
		beq.s     xfd9d_3
		cmp.w     d6,d7
		beq.s     xfd9d_3
		move.w    d7,(a7)
		dc.w      0xF444 ; hd_win
xfd9d_3:
		bra.s     xfd9d_6
xfd9d_4:
		cmp.w     d5,d4
		bne.s     xfd9d_5
		clr.l     (a7)
		move.l    #0x00010013,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfd9d_6
xfd9d_5:
		move.w    d4,(a7)
		move.w    d7,-(a7)
		dc.w      0xF500
		addq.l    #2,a7
xfd9d_6:
		bra.s     xfd9d_9
xfd9d_7:
		tst.w     d6
		beq.s     xfd9d_8
		move.w    d4,(a7)
		move.w    d6,-(a7)
		dc.w      0xF504
		addq.l    #2,a7
		bra.s     xfd9d_9
xfd9d_8:
		cmp.w     d5,d4
		beq.s     xfd9d_9
		move.w    d4,(a7)
		dc.w      0xF508
		move.w    d0,-2(a6)
xfd9d_9:
		move.w    -2(a6),d0
		dc.w      0xFE3D ; movem.l (a7)+,d4-d7/a3-a5

	xdef xfd9e58
xfd9e58: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		moveq.l   #1,d7
		bra.s     xfd9e5_2
xfd9e5_1:
		movea.l   a5,a0
		move.w    d7,d1
		addq.w    #1,d1
		muls.w    #24,d1
		adda.l    d1,a0
		tst.w     24220(a0)
		beq.s     xfd9e5_3
		movea.l   a5,a0
		move.w    d7,d1
		addq.w    #1,d1
		muls.w    #24,d1
		adda.l    d1,a0
		tst.w     24222(a0)
		beq.s     xfd9e5_3
		addq.w    #1,d7
xfd9e5_2:
		cmp.w     #5,d7
		blt.s     xfd9e5_1
xfd9e5_3:
		cmp.w     #5,d7
		bge.s     xfd9e5_4
		move.l    12(a6),-(a7)
		move.l    8(a6),-(a7)
		move.l    a5,d0
		move.w    d7,d1
		addq.w    #1,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #24216,(a7)
		dc.w      0xF298 ; r_set
		adda.w    #12,a7
		move.w    d7,d0
		addq.w    #1,d0
		bra.s     xfd9e5_5
		bra.s     xfd9e5_5
xfd9e5_4:
		clr.w     d0
xfd9e5_5:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd9eca
xfd9eca: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a5,-(a7)
		movea.l   _thedesk,a5
		move.l    14(a6),-(a7)
		move.l    10(a6),-(a7)
		move.l    a5,d0
		move.w    8(a6),d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #24216,(a7)
		dc.w      0xF298 ; r_set
		adda.w    #12,a7
		movea.l   a5,a0
		move.w    8(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    24202(a0),d7
		bra.s     xfd9e_2
xfd9e_1:
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    24200(a0),d6
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #-1,24200(a0)
		move.w    d6,d7
xfd9e_2:
		cmp.w     8(a6),d7
		bgt.s     xfd9e_1
		movea.l   a5,a0
		move.w    8(a6),d1
		muls.w    #24,d1
		adda.l    d1,a0
		moveq.l   #-1,d0
		move.w    d0,24204(a0)
		movea.l   a5,a1
		move.w    8(a6),d2
		muls.w    #24,d2
		adda.l    d2,a1
		move.w    d0,24202(a1)
		dc.w      0xF831 ; movem.l (a7)+,d6-d7/a5

	xdef xfd9f56
xfd9f56: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		moveq.l   #6,d7
		bra.s     xfd9f_2
xfd9f_1:
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		cmpi.w    #-1,24200(a0)
		beq.s     xfd9f_3
		addq.w    #1,d7
xfd9f_2:
		cmp.w     #260,d7
		blt.s     xfd9f_1
xfd9f_3:
		cmp.w     #260,d7
		bge.s     xfd9f_4
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		moveq.l   #-1,d0
		move.w    d0,24204(a0)
		movea.l   a5,a1
		move.w    d7,d2
		muls.w    #24,d2
		adda.l    d2,a1
		move.w    d0,24202(a1)
		move.w    d7,(a7)
		move.w    8(a6),-(a7)
		move.l    24108(a5),-(a7)
		dc.w      0xF554 ; objc_add
		addq.l    #6,a7
		move.l    14(a6),-(a7)
		move.l    10(a6),-(a7)
		move.l    a5,d0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #24216,(a7)
		dc.w      0xF298 ; r_set
		adda.w    #12,a7
		move.w    d7,d0
		bra.s     xfd9f_5
		bra.s     xfd9f_5
xfd9f_4:
		clr.w     d0
xfd9f_5:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfd9fde
xfd9fde: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a5,-(a7)
		movea.l   _g_buffer,a5
		cmpi.w    #99,8(a6)
		bne.s     xfd9fd_1
		clr.w     _DOS_ERR
		moveq.l   #1,d0
		bra.s     xfd9fd_8
xfd9fd_1:
		tst.w     8(a6)
		beq.s     xfd9fd_7
		move.b    #0x5C,256(a5)
		pea.l     257(a5)
		move.l    10(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		moveq.l   #1,d7
		bra.s     xfd9fd_5
xfd9fd_2:
		movea.l   a5,a0
		movea.w   d7,a1
		adda.l    a1,a0
		cmpi.b    #' ',256(a0)
		beq.s     xfd9fd_3
		movea.l   a5,a0
		movea.w   d7,a1
		adda.l    a1,a0
		cmpi.b    #'*',256(a0)
		bne.s     xfd9fd_4
xfd9fd_3:
		movea.l   a5,a0
		movea.w   d7,a1
		adda.l    a1,a0
		clr.b     256(a0)
		bra.s     xfd9fd_6
		bra.s     xfd9fd_5
xfd9fd_4:
		addq.w    #1,d7
xfd9fd_5:
		movea.l   a5,a0
		movea.w   d7,a1
		adda.l    a1,a0
		tst.b     256(a0)
		bne.s     xfd9fd_2
xfd9fd_6:
		pea.l     256(a5)
		move.w    8(a6),-(a7)
		addi.w    #0xFFBF,(a7)
		dc.w      0xF558 ; do_cdir
		addq.l    #6,a7
xfd9fd_7:
		moveq.l   #1,d0
xfd9fd_8:
		dc.w      0xF821 ; movem.l (a7)+,d7/a5

	xdef xfda066
xfda066: ds.b 0
		link      a6,#-4
		movem.l   d7/a5,-(a7)
		movea.l   _thedesk,a5
		tst.b     13518(a5)
		bne.s     xfda06_1
		move.l    a5,(a7)
		addi.l    #13519,(a7)
		dc.w      0xF24C ; strlen
		move.w    d0,-4(a6)
		move.b    d0,13518(a5)
		movea.l   a5,a0
		movea.w   -4(a6),a1
		adda.l    a1,a0
		move.b    #13,13519(a0)
xfda06_1:
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.l    13646(a5),(a7)
		move.l    13514(a5),-(a7)
		move.l    8(a6),-(a7)
		move.w    #1,-(a7)
		dc.w      0xF55C ; shel_write
		adda.w    #10,a7
		move.w    d0,-2(a6)
		clr.b     13518(a5)
		cmpi.w    #-1,12(a6)
		beq.s     xfda06_2
		move.l    13374(a5),-(a7)
		move.l    13370(a5),-(a7)
		move.l    12(a6),-(a7)
		clr.w     -(a7)
		dc.w      0xF560
		adda.w    #14,a7
xfda06_2:
		move.w    -2(a6),d0
		dc.w      0xF801 ; movem.l (a7)+,a5

	xdef _hd_win
_hd_win: ds.b 0
		link      a6,#-8
		movem.l   d5-d7/a5,-(a7)
		move.w    8(a6),d7
		pea.l     -8(a6)
		move.w    #4,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #8,a7
		tst.w     d7
		beq.s     hd_win1
		move.w    d7,(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.w    10(a5),d6
		bra.s     hd_win2
hd_win1:
		moveq.l   #1,d6
hd_win2:
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		pea.l     -8(a6)
		move.l    #_gl_rfull,-(a7)
		clr.w     -(a7)
		move.w    d6,-(a7)
		movea.l   _thedesk,a0
		move.l    24108(a0),-(a7)
		move.w    d7,-(a7)
		dc.w      0xF308
		adda.w    #24,a7
		dc.w      0xF831 ; movem.l (a7)+,d6-d7/a5

	xdef xfda13c
xfda13c: ds.b 0
		link      a6,#-8
		movem.l   d5-d7/a4-a5,-(a7)
		move.w    8(a6),d7
		move.w    10(a6),d6
		movea.l   _thedesk,a4
		tst.w     d7
		beq.s     xfda13_2
		move.w    d7,(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		tst.w     d6
		beq.s     xfda13_1
		pea.l     -8(a6)
		move.w    #4,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #8,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.l    a5,-(a7)
		dc.w      0xF564
		adda.w    #12,a7
xfda13_1:
		move.w    10(a5),13718(a4)
		bra.s     xfda13_3
xfda13_2:
		move.w    #1,13718(a4)
xfda13_3:
		move.w    d7,13720(a4)
		dc.w      0xFC31 ; movem.l (a7)+,d6-d7/a4-a5

	xdef _do_redraw
_do_redraw: ds.b 0
		link      a6,#-8
		movem.l   d4-d7/a4-a5,-(a7)
		move.w    8(a6),d7
		lea.l     -8(a6),a4
		movea.l   _thedesk,a0
		move.l    24108(a0),d6
		tst.w     d7
		beq.s     do_red1
		move.w    d7,(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.w    10(a5),d5
		bra.s     do_red2
do_red1:
		moveq.l   #1,d5
do_red2:
		clr.l     (a7)
		move.w    #256,-(a7)
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		move.l    a4,(a7)
		move.w    #11,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		bra.s     do_red5
do_red3:
		move.l    a4,(a7)
		pea.l     10(a6)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		beq.s     do_red4
		move.l    a4,(a7)
		move.l    #_gl_rscreen,-(a7)
		dc.w      0xF2FC ; rc_intersect
		addq.l    #4,a7
		tst.w     d0
		beq.s     do_red4
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.w    #8,-(a7)
		move.w    d5,-(a7)
		move.l    d6,-(a7)
		dc.w      0xF3A8 ; objc_draw
		adda.w    #16,a7
do_red4:
		move.l    a4,(a7)
		move.w    #12,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
do_red5:
		tst.w     4(a4)
		beq.s     do_red6
		tst.w     6(a4)
		bne.s     do_red3
do_red6:
		clr.l     (a7)
		move.w    #257,-(a7)
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		dc.w      0xFC39 ; movem.l (a7)+,d5-d7/a4-a5

	xdef xfda22c
xfda22c: ds.b 0
		link      a6,#0
		movem.l   d6-d7,-(a7)
		move.w    12(a6),d7
		movea.l   14(a6),a0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     8(a6),d1
		movea.l   d1,a1
		move.w    16(a1),(a0)
		movea.l   18(a6),a0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     8(a6),d1
		movea.l   d1,a1
		move.w    18(a1),(a0)
		movea.l   22(a6),a0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     8(a6),d1
		movea.l   d1,a1
		move.w    20(a1),(a0)
		movea.l   26(a6),a0
		move.w    d7,d1
		muls.w    #24,d1
		add.l     8(a6),d1
		movea.l   d1,a1
		move.w    22(a1),(a0)
		dc.w      0xF021 ; movem.l (a7)+,d7

	xdef xfda28a
xfda28a: ds.b 0
		link      a6,#-4
		movea.l   8(a6),a0
		move.w    12(a6),d1
		muls.w    #24,d1
		move.l    12(a0,d1.l),d0
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef xfda2a0
xfda2a0: ds.b 0
		link      a6,#-8
		movem.l   d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   12(a6),a4
		pea.l     -8(a6)
		move.w    #4,-(a7)
		clr.w     -(a7)
		dc.w      0xF4BC
		addq.l    #8,a7
		move.w    (a5),-8(a6)
		move.w    -8(a6),d0
		and.w     #15,d0
		move.w    d0,(a5)
		cmpi.w    #8,(a5)
		bge.s     xfda2_1
		move.w    -8(a6),d0
		and.w     #-16,d0
		move.w    d0,(a5)
		bra.s     xfda2_2
xfda2_1:
		move.w    -8(a6),d0
		and.w     #-16,d0
		add.w     #16,d0
		move.w    d0,(a5)
xfda2_2:
		move.w    -6(a6),(a7)
		move.w    (a4),-(a7)
		dc.w      0xF45C ; max
		addq.l    #2,a7
		move.w    d0,(a4)
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef xfda2fa
xfda2fa: ds.b 0
		link      a6,#-16
		movem.l   d4-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		move.w    10(a6),d6
		move.w    12(a6),d5
		lea.l     -16(a6),a3
		movea.l   _thedesk,a4
		pea.l     16(a6)
		pea.l     14(a6)
		dc.w      0xF568
		addq.l    #8,a7
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    d5,-(a7)
		pea.l     24200(a4)
		dc.w      0xF56C
		adda.w    #22,a7
		pea.l     6(a3)
		pea.l     4(a3)
		pea.l     2(a3)
		move.l    a3,-(a7)
		move.w    13718(a4),-(a7)
		pea.l     24200(a4)
		dc.w      0xF56C
		adda.w    #22,a7
		move.w    (a3),d0
		add.w     d0,-2(a6)
		move.w    2(a3),d0
		add.w     d0,-4(a6)
		movea.l   a4,a0
		move.w    d5,d1
		muls.w    #24,d1
		adda.l    d1,a0
		cmpi.w    #24,24206(a0)
		bne.s     xfda2f_1
		move.w    18(a6),-6(a6)
xfda2f_1:
		move.l    18(a6),-(a7)
		move.l    14(a6),-(a7)
		move.w    -8(a6),-(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		dc.w      0xF570 ; graf_growbox
		adda.w    #16,a7
		move.w    #1,(a7)
		move.w    #1,-(a7)
		clr.w     -(a7)
		move.w    #1,-(a7)
		move.l    a3,-(a7)
		move.w    d5,-(a7)
		move.w    13718(a4),-(a7)
		move.l    24108(a4),-(a7)
		move.w    13720(a4),-(a7)
		dc.w      0xF2F4
		adda.w    #20,a7
		tst.w     d7
		beq.s     xfda2f_2
		move.l    18(a6),-(a7)
		move.l    14(a6),-(a7)
		move.w    d6,-(a7)
		dc.w      0xF574 ; wind_open
		adda.w    #10,a7
xfda2f_2:
		move.w    d6,13722(a4)
		dc.w      0xFE39 ; movem.l (a7)+,d5-d7/a3-a5

	xdef xfda3de
xfda3de: ds.b 0
		link      a6,#-8
		movem.l   d5-d7/a5,-(a7)
		move.w    8(a6),d7
		move.w    10(a6),d6
		movea.l   _thedesk,a5
		pea.l     -8(a6)
		move.w    #4,-(a7)
		move.w    d6,-(a7)
		dc.w      0xF4BC
		addq.l    #8,a7
		tst.w     d7
		beq.s     xfda3_1
		move.w    d6,(a7)
		dc.w      0xF578
xfda3_1:
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.l    13820(a5),-(a7)
		move.l    12(a6),-(a7)
		dc.w      0xF57C
		adda.w    #16,a7
		dc.w      0xF831 ; movem.l (a7)+,d6-d7/a5

	xdef xfda422
xfda422: ds.b 0
		link      a6,#-24
		movem.l   d6-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		lea.l     -8(a6),a5
		lea.l     -16(a6),a4
		lea.l     -24(a6),a3
		move.l    a5,(a7)
		move.w    #5,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		move.l    a4,(a7)
		move.w    #6,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		move.l    a3,(a7)
		move.w    #7,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		move.l    a3,(a7)
		move.l    a5,-(a7)
		dc.w      0xF580 ; rc_equal
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfda42_1
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.w    #5,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4B8 ; wind_set
		adda.w    #12,a7
		move.l    4(a3),-(a7)
		move.l    (a3),-(a7)
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		dc.w      0xF57C
		adda.w    #16,a7
		bra.s     xfda42_2
xfda42_1:
		move.l    4(a3),-(a7)
		move.l    (a3),-(a7)
		move.l    4(a5),-(a7)
		move.l    (a5),-(a7)
		dc.w      0xF570 ; graf_growbox
		adda.w    #16,a7
		move.l    4(a3),-(a7)
		move.l    (a3),-(a7)
		move.w    #5,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4B8 ; wind_set
		adda.w    #12,a7
xfda42_2:
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	xdef xfda4b6
xfda4b6: ds.b 0
		link      a6,#-4
		movem.l   d4-d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		move.w    12(a6),d7
		move.w    14(a6),d6
		move.w    16(a6),d5
		movea.l   30(a6),a4
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.w    #16,(a7)
		move.l    26(a6),-(a7)
		move.l    22(a6),-(a7)
		move.l    18(a6),-(a7)
		move.w    d5,-(a7)
		dc.w      0xF4E8
		adda.w    #14,a7
		move.l    d0,-4(a6)
		tst.l     -4(a6)
		bne.s     xfda4_3
		clr.l     (a7)
		move.l    #0x00010017,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		dc.w      0xF584
		movea.l   d0,a5
		move.l    a5,d0
		beq.s     xfda4_1
		move.w    6(a5),d0
		bra.s     xfda4_2
xfda4_1:
		clr.w     d0
xfda4_2:
		movea.l   _thedesk,a1
		move.w    d0,13722(a1)
		move.w    #1,(a7)
		movea.l   _thedesk,a0
		move.w    13722(a0),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		bra       xfda4_8
		bra.s     xfda4_4
xfda4_3:
		move.l    -4(a6),24(a5)
xfda4_4:
		move.l    24(a5),(a7)
		dc.w      0xF4AC
		cmp.w     #99,d5
		bne.s     xfda4_5
		pea.l     28(a5)
		movea.l   _thedesk,a0
		move.l    13736(a0),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		bra.s     xfda4_6
xfda4_5:
		move.l    a5,(a7)
		dc.w      0xF588
xfda4_6:
		move.l    a5,(a7)
		dc.w      0xF4B4
		clr.l     (a7)
		pea.l     28(a5)
		move.w    #2,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4B8 ; wind_set
		addq.l    #8,a7
		clr.l     (a7)
		pea.l     149(a5)
		move.w    #3,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4B8 ; wind_set
		addq.l    #8,a7
		tst.w     d6
		ble.s     xfda4_7
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.w    d6,-(a7)
		move.w    6(a5),-(a7)
		move.w    d7,-(a7)
		dc.w      0xF560
		adda.w    #14,a7
		tst.w     d7
		beq.s     xfda4_7
		move.l    a5,(a7)
		dc.w      0xF58C
xfda4_7:
		move.w    #1,(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		tst.w     d7
		bne.s     xfda4_8
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF2C0
		adda.w    #10,a7
xfda4_8:
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		moveq.l   #1,d0
		dc.w      0xFC39 ; movem.l (a7)+,d5-d7/a4-a5

	xdef xfda5d2
xfda5d2: ds.b 0
		link      a6,#-56
		movem.l   d5-d7/a3-a5,-(a7)
		movea.l   12(a6),a5
		movea.l   _thedesk,a4
		pea.l     -24(a6)
		pea.l     -22(a6)
		pea.l     -20(a6)
		pea.l     -18(a6)
		move.w    18(a6),-(a7)
		pea.l     24200(a4)
		dc.w      0xF56C
		adda.w    #22,a7
		pea.l     -16(a6)
		pea.l     -14(a6)
		pea.l     -12(a6)
		pea.l     -10(a6)
		move.w    13718(a4),-(a7)
		pea.l     24200(a4)
		dc.w      0xF56C
		adda.w    #22,a7
		move.w    -10(a6),d0
		add.w     d0,-18(a6)
		move.w    -12(a6),d0
		add.w     d0,-20(a6)
		move.w    4(a5),d0
		and.w     #2,d0
		move.w    d0,-2(a6)
		move.w    #1,-4(a6)
		move.w    4(a5),d0
		and.w     #8,d0
		move.w    d0,-6(a6)
		move.w    4(a5),d0
		and.w     #16,d0
		move.w    d0,-56(a6)
		movea.l   10(a5),a0
		cmpi.b    #'*',(a0)
		beq.s     xfda5_1
		movea.l   10(a5),a0
		cmpi.b    #'?',(a0)
		beq.s     xfda5_1
		movea.l   10(a5),a0
		tst.b     (a0)
		beq.s     xfda5_1
		clr.w     d0
		bra.s     xfda5_2
xfda5_1:
		moveq.l   #1,d0
xfda5_2:
		move.w    d0,-8(a6)
		clr.l     d0
		move.l    d0,-28(a6)
		movea.l   d0,a3
		clr.b     13386(a4)
		clr.b     13519(a4)
		moveq.l   #1,d7
		tst.w     -8(a6)
		bne.s     xfda5_3
		tst.w     16(a6)
		bne.s     xfda5_3
		movea.l   10(a5),a3
		lea.l     12310(a4),a0
		move.l    a0,-28(a6)
		pea.l     12310(a4)
		move.l    26(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		pea.l     13386(a4)
		move.l    a3,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		move.l    8(a6),(a7)
		dc.w      0xF58C
		bra       xfda5_12
xfda5_3:
		tst.w     16(a6)
		beq       xfda5_9
		tst.w     -6(a6)
		beq.s     xfda5_6
		lea.l     13519(a4),a0
		move.l    a0,-28(a6)
		move.l    13670(a4),d6
		move.w    #1,(a7)
		move.w    #1,-(a7)
		move.l    d6,-(a7)
		pea.l     -54(a6)
		move.l    26(a6),-(a7)
		jsr       _xfd81e8
		adda.w    #14,a7
		move.l    #xfeb1ac,(a7)
		move.w    #3,-(a7)
		move.l    d6,-(a7)
		dc.w      0xF3C8 ; inf_sset
		addq.l    #6,a7
		move.w    #3,(a7)
		move.l    d6,-(a7)
		dc.w      0xF4C4 ; xform_do
		addq.l    #4,a7
		cmp.w     #4,d0
		beq.s     xfda5_4
		clr.w     d0
		bra.s     xfda5_5
xfda5_4:
		moveq.l   #1,d0
xfda5_5:
		move.w    d0,d7
		beq.s     xfda5_6
		move.l    -28(a6),(a7)
		move.w    #3,-(a7)
		move.l    d6,-(a7)
		dc.w      0xF42C ; fs_sget
		addq.l    #6,a7
xfda5_6:
		tst.w     d7
		beq.s     xfda5_8
		lea.l     13386(a4),a3
		move.w    20(a6),d0
		ext.w     d0
		move.b    d0,(a3)
		clr.b     1(a3)
		move.l    a3,(a7)
		move.l    #xfeb1ae,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		movea.l   22(a6),a0
		tst.b     (a0)
		beq.s     xfda5_7
		move.l    a3,(a7)
		move.l    22(a6),-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
		move.l    a3,(a7)
		move.l    #xfeb1b1,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
xfda5_7:
		move.l    a3,(a7)
		move.l    26(a6),-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #4,a7
xfda5_8:
		bra       xfda5_12
xfda5_9:
		clr.l     (a7)
		move.l    #0x0001000C,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		move.w    d0,d7
		cmp.w     #3,d7
		bne.s     xfda5_10
		clr.w     d0
		bra       xfda5_16
xfda5_10:
		cmp.w     #1,d7
		bne.s     xfda5_11
		clr.l     (a7)
		move.w    #256,-(a7)
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		move.w    #3,(a7)
		dc.w      0xF590 ; gsx_escapes
		clr.w     (a7)
		move.l    26(a6),-(a7)
		dc.w      0xF594 ; showfile
		addq.l    #4,a7
		move.w    #2,(a7)
		dc.w      0xF590 ; gsx_escapes
		clr.l     (a7)
		move.w    #257,-(a7)
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		moveq.l   #1,d0
		bra       xfda5_16
		bra.s     xfda5_12
xfda5_11:
		move.l    13706(a4),d6
		pea.l     24132(a4)
		move.l    26(a6),-(a7)
		dc.w      0xF3B4 ; fmt_str
		addq.l    #8,a7
		pea.l     24132(a4)
		move.w    #1,-(a7)
		move.l    d6,-(a7)
		dc.w      0xF3C8 ; inf_sset
		adda.w    #10,a7
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.l    d6,(a7)
		dc.w      0xF3CC ; fm_draw
		move.w    #1,(a7)
		move.l    26(a6),-(a7)
		dc.w      0xF594 ; showfile
		addq.l    #4,a7
		move.l    d6,(a7)
		dc.w      0xF3EC ; do_finish
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		clr.w     d0
		bra.s     xfda5_16
xfda5_12:
		tst.w     d7
		beq.s     xfda5_15
		move.l    a4,d0
		add.l     #13519,d0
		cmp.l     -28(a6),d0
		beq.s     xfda5_13
		tst.l     -28(a6)
		beq.s     xfda5_13
		pea.l     13519(a4)
		move.l    -28(a6),-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
xfda5_13:
		tst.w     -56(a6)
		beq.s     xfda5_14
		move.b    #255,13518(a4)
xfda5_14:
		move.w    18(a6),(a7)
		move.w    13720(a4),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		dc.w      0xF598
		addq.l    #6,a7
		bra.s     xfda5_16
xfda5_15:
		clr.w     d0
xfda5_16:
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfda85e
xfda85e: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a3
		move.w    d7,(a7)
		pea.l     24200(a3)
		dc.w      0xF4D4
		addq.l    #4,a7
		movea.l   d0,a4
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.w    12(a4),d6
		and.w     #255,d6
		move.w    d7,(a7)
		dc.w      0xF59C
		movea.l   d0,a5
		move.l    a5,d0
		beq.s     xfda8_4
		move.w    d6,(a7)
		dc.w      0xF4E4
		tst.w     d0
		beq.s     xfda8_2
		cmp.w     #99,d6
		beq.s     xfda8_1
		move.l    #xfeb1b3,(a7)
		move.w    d6,-(a7)
		dc.w      0xF5A0
		addq.l    #2,a7
xfda8_1:
		move.l    a3,d0
		move.w    10(a5),d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #24216,(a7)
		move.l    #xfeb1b7,-(a7)
		move.l    #xfeb1b5,-(a7)
		move.l    #xfeb1b4,-(a7)
		move.w    d6,-(a7)
		move.w    d7,-(a7)
		move.w    #1,-(a7)
		move.l    a5,-(a7)
		dc.w      0xF5A4
		adda.w    #22,a7
		bra.s     xfda8_3
xfda8_2:
		move.l    a5,(a7)
		dc.w      0xF5A8
xfda8_3:
		bra.s     xfda8_5
xfda8_4:
		clr.l     (a7)
		move.l    #0x0001000D,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
xfda8_5:
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		clr.w     d0
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfda900
xfda900: ds.b 0
		link      a6,#-10
		movem.l   d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		lea.l     -10(a6),a4
		move.l    a4,(a7)
		move.w    #4,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.w    14(a6),(a7)
		dc.w      0xF4E4
		tst.w     d0
		beq.s     xfda90_2
		move.l    16(a6),(a7)
		move.w    14(a6),-(a7)
		dc.w      0xF5A0
		addq.l    #2,a7
		move.l    24(a5),(a7)
		dc.w      0xF4F0
		tst.w     _DOS_ERR
		beq.s     xfda90_1
		move.l    #xfeb1b9,16(a6)
		move.l    #xfeb1ba,20(a6)
		move.l    #xfeb1bc,24(a6)
xfda90_1:
		move.l    a4,(a7)
		move.l    24(a6),-(a7)
		move.l    20(a6),-(a7)
		move.l    16(a6),-(a7)
		move.l    12(a6),-(a7)
		clr.w     -(a7)
		move.l    a5,-(a7)
		dc.w      0xF5A4
		adda.w    #22,a7
xfda90_2:
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		clr.w     d0
		dc.w      0xFC01 ; movem.l (a7)+,a4-a5

	xdef xfda984
xfda984: ds.b 0
		link      a6,#-146
		movem.l   d6-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a3
		clr.w     -2(a6)
		pea.l     -10(a6)
		pea.l     -6(a6)
		move.w    d7,-(a7)
		move.w    13720(a3),-(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a5
		tst.w     13720(a3)
		bne.s     xfda9_1
		clr.w     -8(a6)
		bra.s     xfda9_4
xfda9_1:
		move.w    13720(a3),(a7)
		dc.w      0xF2EC
		movea.l   d0,a4
		move.l    13736(a3),(a7)
		pea.l     28(a4)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfda9_2
		moveq.l   #1,d0
		bra.s     xfda9_3
xfda9_2:
		clr.w     d0
xfda9_3:
		move.w    d0,_sh_iscart
		tst.l     -6(a6)
		beq.s     xfda9_4
		pea.l     -146(a6)
		pea.l     -142(a6)
		pea.l     -132(a6)
		pea.l     -8(a6)
		move.l    24(a4),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF5AC
		adda.w    #20,a7
xfda9_4:
		move.l    a5,d0
		beq       xfda9_11
		move.w    6(a5),d0
		bra       xfda9_10

/* case 0 */
xfda9_5:
		move.l    -6(a6),(a7)
		addi.l    #18,(a7)
		pea.l     -132(a6)
		move.w    -8(a6),-(a7)
		move.w    d7,-(a7)
		move.w    -10(a6),-(a7)
		move.l    a5,-(a7)
		move.l    a4,-(a7)
		dc.w      0xF5B0
		adda.w    #18,a7
		move.w    d0,-2(a6)
		bra.s     xfda9_11

/* case 1 */
xfda9_6:
		tst.b     -132(a6)
		beq.s     xfda9_7
		pea.l     -132(a6)
		move.l    #xfeb1be,-(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #8,a7
xfda9_7:
		pea.l     -132(a6)
		move.l    -6(a6),-(a7)
		addi.l    #18,(a7)
		dc.w      0xF404 ; xstrpcat
		addq.l    #8,a7
		pea.l     -146(a6)
		pea.l     -142(a6)
		pea.l     -132(a6)
		move.w    -8(a6),-(a7)
		move.w    d7,-(a7)
		move.l    a4,-(a7)
		dc.w      0xF5B4
		adda.w    #20,a7
		bra.s     xfda9_11

/* case 2 */
/* case 4 */
xfda9_8:
		move.w    d7,(a7)
		dc.w      0xF5B8
		bra.s     xfda9_11

/* case 3 */
xfda9_9:
		clr.l     (a7)
		move.l    #0x0001000E,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.s     xfda9_11
xfda9_10:
		cmp.w     #4,d0
		bhi.s     xfda9_11
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb198,a0
		movea.l   (a0),a0
		jmp       (a0)
xfda9_11:
		move.w    -2(a6),d0
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5


	xdef xfdaaa8
xfdaaa8: ds.b 0
		link      a6,#-10
		movem.l   d5-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a3
		pea.l     -2(a6)
		pea.l     -6(a6)
		move.w    d7,-(a7)
		move.w    13720(a3),-(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a5
		tst.w     13720(a3)
		beq.s     xfdaa_1
		move.w    13720(a3),(a7)
		dc.w      0xF2EC
		movea.l   d0,a4
xfdaa_1:
		move.l    a5,d0
		beq       xfdaa_7
		move.w    6(a5),d0
		bra.s     xfdaa_6
xfdaa_2:
		clr.l     (a7)
		move.l    #0x0001001A,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		bra.w     xfdaa_7
xfdaa_3:
		movea.l   24(a4),a0
		move.b    8(a0),d0
		ext.w     d0
		move.w    d0,(a7)
		dc.w      0xF4E4
		tst.w     d0
		beq.s     xfdaa_7
		move.w    6(a5),(a7)
		move.l    -6(a6),-(a7)
		move.l    24(a4),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF5BC
		addq.l    #8,a7
		tst.w     d0
		beq.s     xfdaa_4
		move.l    a4,(a7)
		dc.w      0xF4C8
xfdaa_4:
		bra.s     xfdaa_7
xfdaa_5:
		move.w    d7,(a7)
		pea.l     24200(a3)
		dc.w      0xF4D4
		addq.l    #4,a7
		move.l    d0,-10(a6)
		movea.l   -10(a6),a0
		move.w    12(a0),(a7)
		andi.w    #255,(a7)
		dc.w      0xF4E4
		tst.w     d0
		beq.s     xfdaa_7
		movea.l   -10(a6),a0
		move.w    12(a0),(a7)
		andi.w    #255,(a7)
		dc.w      0xF5C0
		bra.s     xfdaa_7
xfdaa_6:
		tst.w     d0
		beq.s     xfdaa_3
		cmp.w     #1,d0
		beq.s     xfdaa_3
		cmp.w     #2,d0
		beq.s     xfdaa_5
		cmp.w     #3,d0
		beq       xfdaa_2
xfdaa_7:
		clr.w     d0
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfdab74
xfdab74: ds.b 0
		link      a6,#-16
		movem.l   d6-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a3
		suba.l    a5,a5
		tst.w     13720(a3)
		bne.s     xfdab_1
		move.w    d7,(a7)
		dc.w      0xF5C4
		move.l    d0,-10(a6)
		pea.l     -2(a6)
		move.l    -10(a6),-(a7)
		move.w    d7,-(a7)
		move.l    #0x0001FFFF,-(a7)
		dc.w      0xF4DC
		adda.w    #14,a7
		movea.l   d0,a5
xfdab_1:
		move.l    a5,d0
		beq.s     xfdab_2
		cmpi.w    #2,6(a5)
		bne.s     xfdab_2
		move.w    d7,(a7)
		pea.l     24200(a3)
		dc.w      0xF4D4
		addq.l    #4,a7
		movea.l   d0,a4
		move.w    12(a4),d0
		and.w     #255,d0
		move.b    d0,-16(a6)
		clr.b     -15(a6)
		lea.l     -16(a6),a0
		move.l    a0,-6(a6)
		pea.l     -6(a6)
		move.l    #0x0002000F,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #8,a7
		cmp.w     #1,d0
		bne.s     xfdab_2
		move.w    #0x00FC,(a7)
		pea.l     -16(a6)
		dc.w      0xF4FC ; fc_start
		addq.l    #4,a7
xfdab_2:
		clr.w     d0
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	xdef xfdac02
xfdac02: ds.b 0
		link      a6,#-8
		movem.l   d6-d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a4
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    #4,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF5C8 ; wind_get
		adda.w    #20,a7
		movea.l   a4,a0
		move.w    8(a5),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    24218(a0),(a7)
		movea.l   a4,a0
		move.w    8(a5),d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    24216(a0),-(a7)
		move.w    6(a5),-(a7)
		move.w    #1,-(a7)
		dc.w      0xF5CC
		addq.l    #6,a7
		move.l    24(a5),(a7)
		dc.w      0xF4F0
		move.l    a5,(a7)
		dc.w      0xF5A8
		dc.w      0xF584
		movea.l   d0,a5
		move.l    a5,d0
		beq.s     xfdac0_1
		move.w    6(a5),d0
		bra.s     xfdac0_2
xfdac0_1:
		clr.w     d0
xfdac0_2:
		move.w    d0,13722(a4)
		move.w    #1,(a7)
		move.w    13722(a4),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		clr.w     d0
		dc.w      0xFC21 ; movem.l (a7)+,d7/a4-a5

	xdef xfdac8c
xfdac8c: ds.b 0
		link      a6,#-14
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		lea.l     -10(a6),a3
		movea.l   _thedesk,a4
		move.l    a3,(a7)
		move.w    #4,-(a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		move.w    4(a3),d0
		ext.l     d0
		divs.w    #2,d0
		add.w     (a3),d0
		move.w    13820(a4),d1
		ext.l     d1
		divs.w    #2,d1
		sub.w     d1,d0
		move.w    d0,-12(a6)
		move.w    6(a3),d0
		ext.l     d0
		divs.w    #2,d0
		add.w     2(a3),d0
		move.w    13822(a4),d1
		ext.l     d1
		divs.w    #2,d1
		sub.w     d1,d0
		move.w    d0,-14(a6)
		move.w    -14(a6),(a7)
		move.w    -12(a6),-(a7)
		move.w    6(a5),-(a7)
		clr.w     -(a7)
		dc.w      0xF5CC
		addq.l    #6,a7
		clr.w     12(a5)
		clr.w     14(a5)
		move.l    22(a6),(a7)
		move.l    18(a6),-(a7)
		move.l    14(a6),-(a7)
		move.w    12(a6),-(a7)
		clr.w     -(a7)
		move.l    a5,-(a7)
		dc.w      0xF5B4
		adda.w    #16,a7
		clr.w     d0
		dc.w      0xFE01 ; movem.l (a7)+,a3-a5

	xdef xfdad22
xfdad22: ds.b 0
		link      a6,#-138
		movem.l   d5-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		move.w    12(a6),d7
		clr.w     d6
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		pea.l     -138(a6)
		pea.l     -134(a6)
		pea.l     -124(a6)
		pea.l     -2(a6)
		move.l    24(a5),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF5AC
		adda.w    #20,a7
		tst.w     d7
		beq.s     xfdad_1
		clr.b     -124(a6)
xfdad_1:
		tst.b     -124(a6)
		bne.s     xfdad_2
		move.l    a5,(a7)
		dc.w      0xF5D0
		move.w    d0,d6
		bra.s     xfdad_6
xfdad_2:
		lea.l     -124(a6),a3
		move.l    a3,d0
		movea.l   d0,a4
		move.l    a6,(a7)
		addi.l    #-124,(a7)
		dc.w      0xF24C ; strlen
		subq.w    #1,d0
		ext.l     d0
		adda.l    d0,a3
		bra.s     xfdad_4
xfdad_3:
		subq.l    #1,a3
xfdad_4:
		cmpa.l    a4,a3
		beq.s     xfdad_5
		cmpi.b    #0x5C,(a3)
		bne.s     xfdad_3
xfdad_5:
		clr.b     (a3)
		pea.l     -138(a6)
		pea.l     -134(a6)
		pea.l     -124(a6)
		move.w    -2(a6),-(a7)
		move.l    a5,-(a7)
		dc.w      0xF5D4
		adda.w    #18,a7
		move.w    d0,d6
xfdad_6:
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		move.w    d6,d0
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfdadb6
xfdadb6: ds.b 0
		link      a6,#-12
		movem.l   d5-d7,-(a7)
		move.w    8(a6),d0
		ext.w     d0
		cmp.w     #99,d0
		bne.s     xfdadb_1
		moveq.l   #1,d0
		bra       xfdadb_4
xfdadb_1:
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		move.w    #10,(a7)
		dc.w      0xF5D8 ; ftrp13
		move.l    d0,d7
		move.w    8(a6),d0
		add.w     #0xFFBF,d0
		move.w    d0,-2(a6)
		move.w    -2(a6),d0
		asr.l     d0,d7
		and.l     #1,d7
		moveq.l   #1,d6
		tst.l     d7
		bne.s     xfdadb_2
		move.w    #15,(a7)
		dc.w      0xF0A4 ; fm_error
		clr.w     d6
		bra.s     xfdadb_3
xfdadb_2:
		move.w    8(a6),d0
		ext.w     d0
		move.b    d0,-12(a6)
		move.b    #':',-11(a6)
		pea.l     -10(a6)
		move.l    #_wilds,-(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		move.l    _thedesk,(a7)
		addi.l    #12574,(a7)
		dc.w      0xF3F4 ; dos_sdta
		move.w    #22,(a7)
		pea.l     -12(a6)
		dc.w      0xF3FC ; dos_sfirst
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfdadb_3
		cmpi.w    #18,_DOS_AX
		beq.s     xfdadb_3
		clr.w     d6
xfdadb_3:
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		move.w    d6,d0
xfdadb_4:
		dc.w      0xF031 ; movem.l (a7)+,d6-d7

	data
xfeb14a:
	ascii "     "
	dc.b 0
xfeb150:
	ascii "     "
	dc.b 0
xfeb156:
	ascii ":\*.*"
	dc.b 0
xfeb15c:
	ascii ":\*.*"
	dc.b 0
xfeb162:
	dc.b 0
xfeb163:
	ascii "*"
	dc.b 0
xfeb165:
	ascii "*"
	dc.b 0
	even

	xdef xfeb168
xfeb168:
	dc.w -1
	dc.w -1
	dc.w -1
	dc.w 25 ; G_IBOX
	dc.w 0
	dc.w 0
	dc.l 0
	dc.w 0
	dc.w 0
	dc.w 0
	dc.w 0
	xdef xfeb180
xfeb180:
	dc.w -1
	dc.w -1
	dc.w -1
	dc.w 20 ; G_BOX
	dc.w 0
	dc.w 0
	dc.l 0x1100
	dc.w 0
	dc.w 0
	dc.w 0
	dc.w 0


xfeb198:
	dc.l xfda9_5
	dc.l xfda9_6
	dc.l xfda9_8
	dc.l xfda9_9
	dc.l xfda9_8

	xdef xfeb1ac
xfeb1ac:
	dc.b 0,0

xfeb1ae:
	dc.b ':',0x5c,0

xfeb1b1:
	dc.b 0x5c,0

xfeb1b3:
	dc.b 0

xfeb1b4:
	dc.b 0

xfeb1b5:
	dc.b '*',0

xfeb1b7:
	dc.b '*',0

xfeb1b9:
	dc.b 0

xfeb1ba:
	dc.b '*',0

xfeb1bc:
	dc.b '*',0

xfeb1be:
	dc.b 0x5c,0

