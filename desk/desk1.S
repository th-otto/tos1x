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
		cmpi.b    #92,(a5)
		bne.s     r_slas3
		move.l    a5,d0
		dc.w      $f801

	xdef _do_finish
_do_finish: ds.b 0
		link      a6,#-12
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.l    8(a6),-(a7)
		jsr _form_center
		adda.w    #20,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		move.w    #3,-(a7)
		jsr _form_dial
		adda.w    #16,a7
		dc.w      $f001

	xdef _fm_draw
_fm_draw: ds.b 0
		link      a6,#-12
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.l    8(a6),-(a7)
		jsr _form_center
		adda.w    #20,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.w     -(a7)
		jsr _form_dial
		adda.w    #16,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		move.w    #8,-(a7)
		clr.w     -(a7)
		move.l    8(a6),-(a7)
		jsr _objc_draw
		adda.w    #14,a7
		dc.w      $f001

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
		jsr _LWCOPY
		addq.l    #8,a7
		pea.l     -6(a6)
		pea.l     -8(a6)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _objc_offset
		adda.w    #14,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		clr.w     -(a7)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _objc_draw
		adda.w    #16,a7
		dc.w      $f001

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
		jsr _LWCOPY
		addq.l    #8,a7
		pea.l     -6(a6)
		pea.l     -8(a6)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _ob_offset
		adda.w    #14,a7
		move.l    a6,(a7)
		subq.l    #8,(a7)
		jsr _gsx_sclip
		clr.w     (a7)
		move.w    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _ob_draw
		addq.l    #6,a7
		dc.w      $f001

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
		jsr _xstrpcpy
		addq.l    #4,a7
		dc.w      $f801

	xdef _rep_all
_rep_all: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.l    a5,(a7)
		jsr _r_slash
		movea.l   d0,a5
		move.l    a5,(a7)
		move.l    #_wilds,-(a7)
		jsr _xstrpcpy
		addq.l    #4,a7
		dc.w      $f801

	xdef _xfd6a9c
_xfd6a9c: ds.b 0
		link      a6,#0
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   12(a6),a4
		movea.l   _thedesk,a3
		move.l    a5,(a7)
		jsr _r_slash
		movea.l   d0,a5
		addq.l    #1,a5
		pea.l     24171(a3)
		move.l    a5,-(a7)
		jsr _xstrpcpy
		addq.l    #8,a7
		move.l    a4,(a7)
		pea.l     24171(a3)
		jsr _fmt_str
		addq.l    #4,a7
		dc.w      $fE01

	xdef _dos_error
_dos_error: ds.b 0
		link      a6,#-4
		tst.w     _DOS_ERR
		beq.s     dos_er2
		cmpi.w    #-36,_DOS_AX
		bne.s     dos_er4
		clr.l     (a7)
		move.l    #65561,-(a7)
		jsr _fun_alert
		addq.l    #4,a7
		bra.s     dos_er1
dos_er4:
		cmpi.w    #-32,_DOS_AX
		bgt.s     dos_er1
		move.w    _DOS_AX,d0
		not.w     d0
		move.w    d0,(a7)
		addi.w    #-30,(a7)
		jsr _form_error
dos_er1:
		clr.w     d0
		bra.s     dos_er3
dos_er2:
		moveq.l   #1,d0
dos_er3:
		dc.w      $f001

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
		jsr _dos_avail
		move.l    d0,12570(a5)
		tst.l     12570(a5)
		bne.s     xfd6b_7
		move.w    #27,(a7)
		jsr _do1_alert
		clr.w     d0
		bra       xfd6b_13
xfd6b_7:
		move.l    12570(a5),(a7)
		jsr _dos_alloc
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
		beq       xfd6b_1
		cmp.w     #1,d0
		beq.s     xfd6b_8
		cmp.w     #2,d0
		beq.s     xfd6b_5
		cmp.w     #3,d0
		beq       xfd6b_2
xfd6b_11:
		tst.w     24130(a5)
		beq       xfd6b_12
		move.l    13682(a5),d7
		pea.l     -4(a6)
		move.w    -6(a6),-(a7)
		move.w    #5,-(a7)
		jsr _rsrc_gaddr
		addq.l    #8,a7
		movea.l   #180,a0
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
		jsr _inf_setsize
		adda.w    #14,a7
		clr.w     (a7)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		pea.l     24116(a5)
		pea.l     -14(a6)
		jsr _inf_setsize
		adda.w    #14,a7
		move.l    #xfeb13a,(a7)
		move.w    #4,-(a7)
		move.l    d7,-(a7)
		jsr _inf_sset
		addq.l    #6,a7
		move.l    #xfeb13b,(a7)
		move.w    #3,-(a7)
		move.l    d7,-(a7)
		jsr _inf_sset
		addq.l    #6,a7
		movea.l   d7,a0
		adda.l    #104,a0
		move.w    #128,(a0)
		movea.l   d7,a0
		adda.l    #80,a0
		move.w    #128,(a0)
		move.l    d7,(a7)
		jsr _fm_draw
		movea.l   d7,a0
		adda.l    #104,a0
		clr.w     (a0)
		movea.l   d7,a0
		adda.l    #80,a0
		clr.w     (a0)
		move.w    #-1,(a7)
		move.l    d7,-(a7)
		jsr _form_do
		addq.l    #4,a7
		move.w    #6,(a7)
		move.w    #5,-(a7)
		move.l    d7,-(a7)
		jsr _inf_what
		addq.l    #6,a7
		tst.w     d0
		bne.s     xfd6b_12
		clr.w     d0
		bra.s     xfd6b_13
xfd6b_12:
		moveq.l   #1,d0
xfd6b_13:
		dc.w      $f821

	xdef _dir_op
_dir_op: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a4-a5,-(a7)
		movea.l   14(a6),a5
		movea.l   _thedesk,a4
		move.l    #x00622c,(a7)
		move.l    10(a6),-(a7)
		jsr _xstrpcpy
		addq.l    #4,a7
		move.l    #x0062ac,(a7)
		move.l    18(a6),-(a7)
		jsr _xstrpcpy
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
		jsr _desk_wait
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
		jsr _d_doop
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
		jsr _do_finish
		bra.s     xfd6c_10
xfd6c_9:
		tst.w     24128(a4)
		beq.s     xfd6c_10
		move.l    13686(a4),(a7)
		jsr _do_finish
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
		jsr _dos_free
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
		jsr _desk_wait
		move.w    d6,d0
		dc.w      $fC31

	xdef _d_doop
_d_doop: ds.b 0
		link      a6,#-24
		movem.l   d4-d7/a3-a5,-(a7)
		movea.l   14(a6),a5
		movea.l   18(a6),a4
		clr.w     d5
		move.l    _thedesk,-24(a6)
		clr.w     d6
		move.l    a5,(a7)
		jsr _r_slash
		movea.l   d0,a3
		move.l    a3,-20(a6)
		movea.l   a3,a0
		clr.b     (a0)
		subq.l    #1,a3
		bra.s     xfd6e_2
xfd6e_1:
		movea.l   a3,a0
		cmpi.b    #92,(a0)
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
		jsr _xstrpcpy
		addq.l    #4,a7
		movea.l   -20(a6),a0
		move.b    #92,(a0)
		clr.w     _f_level
		tst.w     8(a6)
		beq.s     xfd6e_4
		cmpi.w    #1,8(a6)
		bne.s     xfd6e_5
xfd6e_4:
		move.l    a5,-20(a6)
		bra.s     xfd6e_6
xfd6e_5:
		move.l    a4,-20(a6)
		addq.w    #1,_f_level
xfd6e_6:
		bra.s     xfd6e_8
xfd6e_7:
		movea.l   -20(a6),a0
		cmpi.b    #92,(a0)
		move.w    sr,d0
		addq.l    #1,-20(a6)
		move.w    d0,ccr
		bne.s     xfd6e_8
		addq.w    #1,_f_level
xfd6e_8:
		movea.l   -20(a6),a0
		tst.b     (a0)
		bne.s     xfd6e_7
		subq.w    #1,_f_level
		move.l    -24(a6),(a7)
		addi.l    #12310,(a7)
		move.l    a5,-(a7)
		jsr _xstrpcpy
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    a4,-(a7)
		jsr _xstrpcpy
		addq.l    #4,a7
xfd6e_9:
		cmpi.w    #8,_f_level
		ble.s     xfd6e_10
		clr.l     (a7)
		move.l    #65559,-(a7)
		jsr _fun_alert
		addq.l    #4,a7
		clr.w     d5
		bra       xfd6e_37
xfd6e_10:
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,(a7)
		addi.l    #12574,(a7)
		jsr _dos_sdta
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
		jsr _xstrpcpy
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
		jsr _dos_sfirst
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd6e_14
		cmpi.w    #18,_DOS_AX
		beq       xfd6e_17
		jsr _dos_error
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
		jsr _streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd6e_15
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    #_wilds,-(a7)
		jsr _xstrpcat
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
		jsr _r_slash
		movea.l   d0,a3
		clr.b     (a3)
		tst.w     d7
		beq       xfd6e_14
		bra       xfd6e_18
xfd6e_15:
		move.l    #x00632c,(a7)
		pea.l     -16(a6)
		jsr _xstrpcpy
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    a4,-(a7)
		jsr _xstrpcpy
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
		jsr _xstrpcat
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
		jsr _xstrpcat
		addq.l    #4,a7
		clr.w     (a7)
		move.l    -24(a6),-(a7)
		addi.l    #12438,(a7)
		jsr       _xfd7814
		addq.l    #4,a7
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		jsr _r_slash
		movea.l   d0,a3
		clr.b     (a3)
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		jsr _dos_mkdir
		cmpi.w    #5,_DOS_AX
		bne.s     xfd6e_18
		move.w    #-36,_DOS_AX
		jsr _dos_error
		tst.w     d0
		beq       xfd6e_37
xfd6e_18:
		move.l    -24(a6),(a7)
		addi.l    #12438,(a7)
		move.l    #_wilds,-(a7)
		jsr _xstrpcat
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
		move.w    #55,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		jsr _dos_sfirst
		addq.l    #4,a7
		move.w    d0,d7
		bra       xfd6e_26
xfd6e_21:
		tst.w     d7
		bne.s     xfd6e_22
		cmpi.w    #18,_DOS_AX
		beq       xfd6e_27
		jsr _dos_error
		bra       xfd6e_37
xfd6e_22:
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		btst      #4,12595(a0)
		beq.s     xfd6e_24
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		cmpi.b    #'.',12604(a0)
		beq.s     xfd6e_23
		addq.w    #1,d6
		move.l    #x00633c,(a7)
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,-(a7)
		addi.l    #12604,(a7)
		jsr _xstrpcpy
		addq.l    #4,a7
		addq.w    #1,_f_level
		move.l    #x00633c,(a7)
		move.l    -24(a6),-(a7)
		addi.l    #12310,(a7)
		jsr       _xfd75f2
		addq.l    #4,a7
		bra       xfd6e_9
xfd6e_23:
		bra.s     xfd6e_25
xfd6e_24:
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		move.w    12598(a0),(a7)
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		move.w    12596(a0),-(a7)
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		movea.l   d0,a0
		move.b    12595(a0),d0
		ext.w     d0
		move.w    d0,-(a7)
		move.w    _f_level,d0
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
		jsr _dos_snext
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
		jsr _r_slash
		move.l    d0,-20(a6)
		movea.l   -20(a6),a0
		cmpi.b    #':',-1(a0)
		beq.s     xfd6e_29
		movea.l   -20(a6),a0
		clr.b     (a0)
		move.l    -24(a6),(a7)
		addi.l    #12310,(a7)
		jsr _dos_rmdir
		movea.l   -20(a6),a0
		move.b    #92,(a0)
		jsr _dos_error
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
		subq.w    #1,_f_level
		move.w    _f_level,d0
		muls.w    #44,d0
		add.l     -24(a6),d0
		move.l    d0,(a7)
		addi.l    #12574,(a7)
		jsr _dos_sdta
		bra       xfd6e_25
		bra.s     xfd6e_37
xfd6e_36:
		moveq.l   #1,d5
xfd6e_37:
		move.w    d5,d0
		dc.w      $fE39

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
		move.w    _f_level,d1
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
		jsr _xstrpcpy
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
		jsr _dos_delete
		cmpi.w    #-36,_DOS_AX
		bne.s     xfd73_4
		moveq.l   #1,d3
		move.w    #5,(a7)
		jsr _form_error
		bra.s     xfd73_5
xfd73_4:
		jsr _dos_error
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
		jsr _dos_rename
		addq.l    #4,a7
		tst.w     _DOS_ERR
		bne.s     xfd73_7
		moveq.l   #1,d3
		bra       xfd73_28
xfd73_7:
		cmpi.w    #-36,_DOS_AX
		beq.s     xfd73_9
		jsr _dos_error
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
		jsr _dos_open
		addq.l    #4,a7
		move.w    d0,d5
		jsr _dos_error
		tst.w     d0
		beq       xfd73_25
		move.l    12566(a3),(a7)
		move.l    12570(a3),-(a7)
		move.w    d5,-(a7)
		move.w    #63,-(a7) ; Fread
		jsr _trap
		addq.l    #8,a7
		move.l    d0,d4
		jsr _dos_error
		tst.w     d0
		beq       xfd73_23
xfd73_10:
		clr.w     (a7)
		move.l    a4,-(a7)
		jsr _dos_open
		addq.l    #4,a7
		move.w    d0,d6
		tst.w     _DOS_ERR
		beq.s     xfd73_11
		cmpi.w    #2,_DOS_AX
		beq       xfd73_17
		jsr _dos_error
		bra       xfd73_23
		bra.s     xfd73_12
xfd73_11:
		move.w    d6,(a7)
		jsr _dos_close
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
		jsr _xstrpcpy
		addq.l    #8,a7
xfd73_15:
		move.l    a4,(a7)
		jsr _r_slash
		move.l    d0,-40(a6)
		move.l    -40(a6),(a7)
		addq.l    #1,(a7)
		pea.l     -36(a6)
		jsr _xstrpcpy
		addq.l    #4,a7
		move.l    a5,(a7)
		move.l    a4,-(a7)
		jsr _streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfd73_16
		moveq.l   #1,d3
		bra       xfd73_23
xfd73_16:
		pea.l     -20(a6)
		pea.l     -36(a6)
		jsr _streq
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfd73_17
		pea.l     -20(a6)
		pea.l     -36(a6)
		jsr _xstrpcpy
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
		jsr _dos_create
		addq.l    #4,a7
		move.w    d0,d6
		jsr _dos_error
		tst.w     d0
		beq.w     xfd73_23
		addq.l    #1,12970(a3)
xfd73_18:
		move.l    12566(a3),(a7)
		move.l    d4,-(a7)
		move.w    d6,-(a7)
		move.w    #64,-(a7) ; Fwrite
		jsr _trap
		addq.l    #8,a7
		move.l    d0,-4(a6)
		jsr _dos_error
		tst.w     d0
		beq.s     xfd73_22
		cmp.l     -4(a6),d4
		beq.s     xfd73_19
		clr.l     (a7)
		move.l    #65558,-(a7)
		jsr _fun_alert
		addq.l    #4,a7
		move.w    d6,(a7)
		jsr _dos_close
		move.l    a4,(a7)
		jsr _dos_delete
		jsr _dos_error
		bra.s     xfd73_23
xfd73_19:
		cmp.l     12570(a3),d4
		bge.s     xfd73_20
		move.l    24(a6),-(a7)
		move.w    d6,-(a7)
		jsr _dos_set
		addq.l    #6,a7
		moveq.l   #1,d3
		bra.s     xfd73_22
		bra.s     xfd73_21
xfd73_20:
		move.l    12566(a3),(a7)
		move.l    12570(a3),-(a7)
		move.w    d5,-(a7)
		move.w    #63,-(a7) ; Fread
		jsr _trap
		addq.l    #8,a7
		move.l    d0,d4
		tst.l     d4
		beq.s     xfd73_22
		jsr _dos_error
		tst.w     d0
		beq.s     xfd73_22
xfd73_21:
		bra       xfd73_18
xfd73_22:
		move.w    d6,(a7)
		jsr _dos_close
xfd73_23:
		move.w    d5,(a7)
		jsr _dos_close
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
		jsr _streq
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfd73_28
		move.l    a5,(a7)
		jsr _dos_delete
		tst.w     _DOS_ERR
		beq.s     xfd73_28
		clr.w     d3
		cmpi.w    #-36,_DOS_AX
		bne.s     xfd73_27
		moveq.l   #1,d3
		move.w    #5,(a7)
		jsr _form_error
xfd73_26:
		bra.s     xfd73_28
xfd73_27:
		jsr _dos_error
xfd73_28:
		move.l    a5,(a7)
		jsr _rep_all
		cmpi.w    #1,8(a6)
		beq.s     xfd73_29
		move.l    a4,(a7)
		jsr _rep_all
xfd73_29:
		move.w    d3,d0
xfd73_30:
		dc.w      $fE3F

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
		jsr _xstrpcpy
		addq.l    #4,a7
		move.l    a5,(a7)
		move.l    #_wilds,-(a7)
		jsr _xstrpcat
		addq.l    #4,a7
		dc.w      $f801

	xdef _xfd7620
_xfd7620: ds.b 0
		link      a6,#-24
		movem.l   d5-d7/a5,-(a7)
		movea.l   _thedesk,a5
		clr.w     (a7)
		jsr _desk_wait
		move.l    13686(a5),d7
		pea.l     -24(a6)
		move.l    8(a6),-(a7)
		jsr       _xfd6a9c
		addq.l    #8,a7
		pea.l     -24(a6)
		move.w    #1,-(a7)
		move.l    d7,-(a7)
		jsr _inf_sset
		adda.w    #10,a7
		pea.l     -24(a6)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		jsr _inf_sset
		adda.w    #10,a7
		move.l    d7,(a7)
		jsr _fm_draw
		move.w    #1,24128(a5)
		clr.w     (a7)
		move.l    d7,-(a7)
		jsr _form_do
		addq.l    #4,a7
		move.w    d0,d6
		and.w     #32767,d6
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
		jsr _inf_sset
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
		jsr _form_center
		adda.w    #20,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    #8,-(a7)
		clr.w     -(a7)
		move.l    d7,-(a7)
		jsr _objc_draw
		adda.w    #16,a7
		movea.l   d7,a0
		adda.l    #130,a0
		clr.w     (a0)
xfd76_2:
		move.w    #1,(a7)
		jsr _desk_wait
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
		jsr _fs_sget
		adda.w    #10,a7
		move.l    12(a6),(a7)
		pea.l     24158(a5)
		jsr _unfmt_str
		addq.l    #4,a7
		move.w    d6,d0
		dc.w      $f831

	xdef _xfd7730
_xfd7730: ds.b 0
		link      a6,#0
		movem.l   d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   12(a6),a4
		move.l    a4,(a7)
		move.l    a5,-(a7)
		jsr _streq
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
		dc.w      $fC01

	xdef _par_chk
_par_chk: ds.b 0
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
		jsr _xstrpcpy
		addq.l    #8,a7
		pea.l     18(a5)
		pea.l     12310(a4)
		jsr       _xfd75f2
		addq.l    #8,a7
		pea.l     12438(a4)
		move.l    16(a6),-(a7)
		jsr _xstrpcpy
		addq.l    #8,a7
		pea.l     12438(a4)
		pea.l     12310(a4)
		jsr       _xfd7730
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfd777_3
		clr.l     (a7)
		move.l    #65561,-(a7)
		jsr _fun_alert
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
		dc.w      $fC01

	xdef _xfd7814
_xfd7814: ds.b 0
		link      a6,#-40
		movem.l   d6-d7/a5,-(a7)
		movea.l   _thedesk,a5
		move.l    #65538,(a7)
		jsr _trp13
		tst.l     d0
		beq.s     xfd78_1
		move.l    #131074,(a7)
		jsr _trp13
		cmp.l     #6356992,d0
		bne.s     xfd78_1
		clr.l     (a7)
		move.l    #65570,-(a7)
		jsr _fun_alert
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
		jsr _inf_sset
		adda.w    #10,a7
		pea.l     -40(a6)
		move.w    #3,-(a7)
		move.l    d7,-(a7)
		jsr _inf_sset
		adda.w    #10,a7
		tst.w     12(a6)
		beq.s     xfd78_2
		move.l    12970(a5),-4(a6)
		clr.w     (a7)
		move.w    #2,-(a7)
		move.l    d7,-(a7)
		pea.l     24112(a5)
		pea.l     -4(a6)
		jsr _inf_setsize
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
		jsr _inf_sset
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
		jsr _inf_setsize
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
		dc.w      $f821

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
		jsr _r_slash
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
		move.b    #92,(a5)
xfd791_2:
		dc.w      $f801

	xdef _xfd795c
_xfd795c: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.l    a5,(a7)
		jsr _r_slash
		movea.l   d0,a5
		subq.l    #1,a5
		bra.s     xfd795_2
xfd795_1:
		subq.l    #1,a5
xfd795_2:
		cmpi.b    #92,(a5)
		bne.s     xfd795_1
		move.l    a5,(a7)
		move.l    #_wilds,-(a7)
		jsr _xstrpcpy
		addq.l    #4,a7
		dc.w      $f801

	data

	xdef _wilds
_wilds:
	ascii "\*.*"
	dc.b 0,0
	xdef _getall
_getall:
	ascii "*.*"
	dc.b 0

xfeb13a: dc.b 0
xfeb13b: dc.b 0
xfeb13c: dc.b 0
xfeb13d: dc.b 0

	bss
	xdef x00622c
	comm x00622c,128
	xdef x0062ac
	comm x0062ac,128
	xdef x00632c
	comm x00632c,16
	xdef x00633c
	comm x00633c,16

	bss
	xdef _f_level
	comm _f_level,2
