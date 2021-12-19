	xdef _deskmain
_deskmain: ds.b 0
		link      a6,#-78
		movem.l   d2-d7/a5,-(a7)
		move.l    #30572,(a7)
		jsr _dos_alloc
		move.l    d0,_thedesk
		move.l    _thedesk,(a7)
		clr.w     -(a7)
		move.w    #30572,-(a7)
		jsr _bfill
		addq.l    #4,a7
		move.l    #512,(a7)
		jsr _dos_alloc
		move.l    d0,_g_buffer
		move.l    #4*238,(a7)
		jsr _dos_alloc
		move.l    d0,_winhead
		movea.l   _thedesk,a5
		jsr _ap_init
		move.w    #1,(a7)
		jsr _wind_update
		pea.l     13376(a5)
		pea.l     13374(a5)
		pea.l     13372(a5)
		pea.l     13370(a5)
		move.w    #4,-(a7)
		clr.w     -(a7)
		jsr _wind_get
		adda.w    #20,a7
		pea.l     13384(a5)
		pea.l     13382(a5)
		pea.l     13380(a5)
		pea.l     13378(a5)
		move.l    13374(a5),-(a7)
		move.l    13370(a5),-(a7)
		move.l    #$0001FFFF,-(a7)
		jsr _wind_calc
		adda.w    #28,a7
		lea.l     13386(a5),a0
		move.l    a0,13514(a5)
		lea.l     13518(a5),a0
		move.l    a0,13646(a5)
		lea.l     13350(a5),a0
		move.l    a0,13366(a5)
		move.w    #1,(a7)
		jsr _desk_wait
		move.l    #_pglobal,(a7)
		move.w    #1,-(a7)
		jsr _rom_ram
		addq.l    #2,a7
		pea.l     13736(a5)
		move.l    #$00050003,-(a7)
		jsr _rsrc_gaddr
		addq.l    #8,a7
		clr.w     d6
		bra.s     deskm2
deskm1:
		move.l    a5,d0
		move.w    d6,d1
		asl.w     #2,d1
		ext.l     d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #13654,(a7)
		move.w    d6,-(a7)
		clr.w     -(a7)
		jsr _rsrc_gaddr
		addq.l    #4,a7
		addq.w    #1,d6
deskm2:
		cmp.w     #16,d6
		blt.s     deskm1
		jsr _read_inf
		tst.w     d0
		bne.s     deskm3
		jsr _ap_exit
		clr.w     d0
		bra       deskm22
deskm3:
		jsr       _obj_init
		jsr       _pn_init
		clr.l     -(a7)
		jsr       _desk_verify
		addq.l    #4,a7
		move.w    #1,(a7)
		move.l    13654(a5),-(a7)
		jsr _menu_bar
		addq.l    #4,a7
		move.l    13654(a5),(a7)
		jsr       _men_update
		clr.w     d6
		bra.s     deskm5
deskm4:
		clr.l     -(a7)
		move.w    d6,-(a7)
		addi.w    #27,(a7)
		move.l    13654(a5),-(a7)
		jsr _ob_change
		adda.w    #10,a7
		addq.w    #1,d6
deskm5:
		cmp.w     #7,d6
		blt.s     deskm4
		clr.w     (a7)
		move.l    #$001D0008,-(a7)
		move.l    13654(a5),-(a7)
		jsr _ob_change
		addq.l    #8,a7
		jsr _isdrive
		tst.w     d0
		bne.s     deskm6
		clr.w     (a7)
		move.l    #$00290008,-(a7)
		move.l    13654(a5),-(a7)
		jsr _ob_change
		addq.l    #8,a7
deskm6:
		move.w    #27,13724(a5)
		move.w    #1,(a7)
		move.w    13724(a5),-(a7)
		move.l    13654(a5),-(a7)
		jsr _menu_icheck
		addq.l    #6,a7
		move.w    #30,13726(a5)
		move.w    #1,(a7)
		move.w    13726(a5),-(a7)
		move.l    13654(a5),-(a7)
		jsr _menu_icheck
		addq.l    #6,a7
		jsr       _app_blddesk
		move.l    13374(a5),-(a7)
		move.l    13370(a5),-(a7)
		clr.w     -(a7)
		jsr _do_wredraw
		adda.w    #10,a7
		clr.w     (a7)
		move.w    #1,-(a7)
		move.l    24108(a5),-(a7)
		move.w    #14,-(a7)
		clr.w     -(a7)
		jsr _wind_set
		adda.w    #10,a7
		clr.l     -(a7)
		jsr       _desk_verify
		addq.l    #4,a7
		clr.w     13722(a5)
		jsr       _cnx_get
		move.l    13654(a5),-12(a6)
		move.w    #-1,(a7)
		move.w    #$0040,-(a7) ; _Blitmode
		jsr _trp14
		addq.l    #2,a7
		move.w    d0,d5
		btst      #1,d5
		beq.s     deskm7
		movea.l   -12(a6),a0
		adda.l    #$00000334,a0
		move.w    #42,(a0)
		movea.l   -12(a6),a0
		adda.l    #$000003C0,a0
		move.w    #41,(a0)
		move.w    _gl_hchar,d0
		asl.w     #3,d0
		movea.l   -12(a6),a1
		adda.l    #$00000346,a1
		move.w    d0,(a1)
		move.w    23558(a5),13732(a5)
		move.w    13732(a5),(a7)
		move.w    #42,-(a7)
		move.l    13654(a5),-(a7)
		jsr _menu_icheck
		addq.l    #6,a7
		move.w    13732(a5),(a7)
		move.w    #$0040,-(a7) ; Blitmode
		jsr _trp14
		addq.l    #2,a7
		bra.s     deskm8
deskm7:
		movea.l   -12(a6),a0
		adda.l    #$00000334,a0
		move.w    #40,(a0)
		movea.l   -12(a6),a0
		adda.l    #$000003C0,a0
		move.w    #34,(a0)
		move.w    _gl_hchar,d0
		muls.w    #6,d0
		movea.l   -12(a6),a1
		adda.l    #$00000346,a1
		move.w    d0,(a1)
deskm8:
		clr.w     d6
		bra       deskm10
deskm9:
		movea.w   d6,a0
		adda.l    a0,a0
		adda.l    #_ILL_XXX,a0
		move.w    (a0),d7
		move.w    d7,d0
		addq.w    #1,d6
		tst.w     d0
		beq.s     deskm11
		subq.w    #1,d7
		pea.l     -6(a6)
		pea.l     -4(a6)
		move.w    d7,-(a7)
		move.l    -12(a6),-(a7)
		jsr _objc_offset
		adda.w    #14,a7
		move.w    d7,d0
		muls.w    #24,d0
		add.l     -12(a6),d0
		add.l     #20,d0
		movea.l   d0,a0
		move.w    (a0),-6(a6)
		move.w    -4(a6),d0
		add.w     -6(a6),d0
		move.w    d0,-8(a6)
		move.w    13374(a5),d0
		cmp.w     -8(a6),d0
		bgt.s     deskm10
		move.w    -4(a6),d0
		sub.w     -8(a6),d0
		add.w     13374(a5),d0
		sub.w     _gl_wchar,d0
		move.w    d0,-4(a6)
		move.w    d7,d0
		muls.w    #24,d0
		add.l     -12(a6),d0
		add.l     #16,d0
		movea.l   d0,a0
		move.w    -4(a6),(a0)
deskm10:
		bra       deskm9
deskm11:
		clr.w     (a7)
		jsr _wind_update
		moveq.l   #19,d4
		clr.w     d5
		clr.w     (a7)
		jsr _desk_wait
		bra       deskm16
deskm12:
		pea.l     -24(a6)
		pea.l     -22(a6)
		pea.l     -20(a6)
		pea.l     -18(a6)
		pea.l     -16(a6)
		pea.l     -14(a6)
		clr.l     -(a7)
		move.l    13366(a5),-(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		move.l    #$00010001,-(a7)
		move.w    #2,-(a7)
		move.w    d4,-(a7)
		jsr _evnt_multi
		adda.w    #60,a7
		move.w    d0,-2(a6)
		move.w    #1,(a7)
		jsr _wind_update
		btst      #4,-1(a6)
		beq.s     deskm13
		jsr _hd_msg
		move.w    d0,d5
deskm13:
		btst      #0,-1(a6)
		beq.s     deskm14
		move.w    -22(a6),(a7)
		jsr _hd_keybd
		move.w    d0,d5
deskm14:
		btst      #1,-1(a6)
		beq.s     deskm15
		move.w    -20(a6),(a7)
		move.w    -18(a6),-(a7)
		move.w    -16(a6),-(a7)
		move.w    -14(a6),-(a7)
		move.w    -24(a6),-(a7)
		jsr _hd_button
		addq.l    #8,a7
		move.w    d0,d5
deskm15:
		clr.w     (a7)
		jsr _wind_update
deskm16:
		tst.w     d5
		beq       deskm12
		jsr       _cnx_put
		clr.w     (a7)
		jsr _save_inf
		clr.w     (a7)
		clr.l     -(a7)
		jsr _menu_bar
		addq.l    #4,a7
		clr.w     d6
		bra.s     deskm19
deskm17:
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #140,d1
		adda.l    d1,a0
		tst.l     134(a0)
		beq.s     deskm18
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #140,d1
		adda.l    d1,a0
		move.l    134(a0),(a7)
		jsr _dos_free
deskm18:
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #140,d1
		adda.l    d1,a0
		move.l    #0,134(a0)
		addq.w    #1,d6
deskm19:
		cmp.w     #5,d6
		blt.s     deskm17
		jsr _ap_exit
		moveq.l   #1,d7
		tst.w     _gl_rschange
		beq.s     deskm21
		jsr _set_defdrv
		jsr _isdrive
		tst.w     d0
		beq.s     deskm20
		jsr _dos_gdrv
		move.w    d0,(a7)
		addi.w    #'A',(a7)
		jsr       _pro_chroot
		move.w    d0,_diskin
deskm20:
		clr.w     d7
deskm21:
		move.l    _g_buffer,(a7)
		jsr _dos_free
		move.l    _thedesk,(a7)
		jsr _dos_free
		move.l    _winhead,(a7)
		jsr _dos_free
		move.w    d7,d0
deskm22:
		dc.w      $F83F


	xdef _win_view
_win_view: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   _thedesk,a5
		move.w    8(a6),12292(a5)
		move.w    10(a6),12308(a5)
		move.w    8(a6),d0
		bra       xfdc0_9
xfdc0_1:
		cmpi.w    #320,_gl_width
		bne.s     xfdc0_2
		moveq.l   #43,d0
		bra.s     xfdc0_3
xfdc0_2:
		moveq.l   #45,d0
xfdc0_3:
		muls.w    _gl_wchar,d0
		move.w    d0,12294(a5)
		move.w    _gl_hchar,12296(a5)
		cmpi.w    #320,_gl_width
		bne.s     xfdc0_4
		clr.w     d0
		bra.s     xfdc0_5
xfdc0_4:
		move.w    _gl_wchar,d0
		asl.w     #1,d0
		subq.w    #1,d0
xfdc0_5:
		move.w    d0,12298(a5)
		move.w    #2,12300(a5)
		move.w    13746(a5),12286(a5)
		lea.l     13784(a5),a0
		move.l    a0,12288(a5)
		bra.s     xfdc0_10
xfdc0_6:
		move.w    13820(a5),12294(a5)
		move.w    13822(a5),12296(a5)
		cmpi.w    #300,_gl_height
		bgt.s     xfdc0_7
		clr.w     d0
		bra.s     xfdc0_8
xfdc0_7:
		moveq.l   #8,d0
xfdc0_8:
		move.w    d0,12298(a5)
		move.w    #2,12300(a5)
		move.w    13744(a5),12286(a5)
		lea.l     13748(a5),a0
		move.l    a0,12288(a5)
		bra.s     xfdc0_10
xfdc0_9:
		tst.w     d0
		beq.s     xfdc0_6
		cmp.w     #1,d0
		beq       xfdc0_1
xfdc0_10:
		move.w    12294(a5),d0
		add.w     12298(a5),d0
		move.w    d0,12302(a5)
		move.w    12296(a5),d0
		add.w     12300(a5),d0
		move.w    d0,12304(a5)
		move.w    13382(a5),d0
		ext.l     d0
		divs.w    12302(a5),d0
		move.w    d0,12306(a5)
		bne.s     xfdc0_11
		move.w    #1,12306(a5)
xfdc0_11:
		dc.w      $F801

	xdef _obj_init
_obj_init: ds.b 0
		link      a6,#-4
		movem.l   d6-d7/a4-a5,-(a7)
		movea.l   _thedesk,a4
		lea.l     24200(a4),a0
		move.l    a0,24108(a4)
		move.l    a0,d0
		move.l    d0,-4(a6)
		clr.w     d7
		bra.s     xfdc1_2
xfdc1_1:
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #-1,24202(a0)
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #-1,24200(a0)
		movea.l   a4,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #-1,24204(a0)
		addq.w    #1,d7
xfdc1_2:
		cmp.w     #260,d7
		blt.s     xfdc1_1
		pea.l     24200(a4)
		move.l    #_gl_sampob,-(a7)
		move.w    #24,-(a7)
		jsr _movs
		adda.w    #10,a7
		move.w    _gl_height,(a7)
		move.w    _gl_width,-(a7)
		clr.l     -(a7)
		pea.l     24216(a4)
		jsr _r_set
		adda.w    #10,a7
		clr.w     d7
		bra.s     xfdc1_4
xfdc1_3:
		move.l    a4,d0
		move.w    d7,d1
		addq.w    #1,d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #24200,(a7)
		move.l    #_gl_sampob+24,-(a7)
		move.w    #24,-(a7)
		jsr _movs
		addq.l    #6,a7
		move.w    d7,(a7)
		addq.w    #1,(a7)
		clr.w     -(a7)
		move.l    -4(a6),-(a7)
		jsr _objc_add
		addq.l    #6,a7
		addq.w    #1,d7
xfdc1_4:
		cmp.w     #5,d7
		blt.s     xfdc1_3
		clr.l     -(a7)
		jsr       _win_view
		addq.l    #4,a7
		clr.w     d7
		bra.s     xfdc1_6
xfdc1_5:
		move.w    d7,d0
		muls.w    #238,d0
		movea.l   d0,a5
		adda.l    _winhead,a5
		clr.w     8(a5)
		clr.w     6(a5)
		move.w    #8,(a7)
		move.l    a4,d0
		move.w    d7,d1
		muls.w    #136,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #23564,(a7)
		move.w    d7,d0
		asl.w     #3,d0
		ext.l     d0
		add.l     #_g_winsave,d0
		move.l    d0,-(a7)
		jsr _LBCOPY
		addq.l    #8,a7
		addq.w    #1,d7
xfdc1_6:
		cmp.w     #4,d7
		blt.s     xfdc1_5
		movea.l   _thedesk,a0
		clr.w     844(a0)
		clr.w     x0063c6
		dc.w      $FC21

	xdef _win_alloc
_win_alloc: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a3-a5,-(a7)
		movea.l   _thedesk,a3
		cmpi.w    #4,844(a3)
		bne.s     xfdc2_1
		clr.l     d0
		bra       xfdc2_4
xfdc2_1:
		move.w    x0063c6,d0
		asl.w     #3,d0
		ext.l     d0
		movea.l   d0,a4
		adda.l    #_g_winsave,a4
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		jsr       _obj_walloc
		addq.l    #8,a7
		move.w    d0,d7
		tst.w     d7
		beq       xfdc2_3
		addq.w    #1,844(a3)
		addq.w    #1,x0063c6
		move.w    d7,d0
		subq.w    #2,d0
		muls.w    #238,d0
		movea.l   d0,a5
		adda.l    _winhead,a5
		clr.w     4(a5)
		move.w    8(a6),8(a5)
		move.w    d7,10(a5)
		clr.w     12(a5)
		clr.w     14(a5)
		move.w    4(a4),d0
		ext.l     d0
		divs.w    12302(a3),d0
		move.w    d0,16(a5)
		move.w    6(a4),d0
		ext.l     d0
		divs.w    12304(a3),d0
		move.w    d0,18(a5)
		clr.w     20(a5)
		clr.w     22(a5)
		move.l    13374(a3),-(a7)
		move.l    13370(a3),-(a7)
		move.w    #-1,-(a7)
		jsr _wind_create
		adda.w    #10,a7
		move.w    d0,6(a5)
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		pea.l     230(a5)
		jsr _r_set
		adda.w    #12,a7
		cmpi.w    #-1,6(a5)
		beq.s     xfdc2_2
		move.l    a5,d0
		bra.s     xfdc2_4
		bra.s     xfdc2_3
xfdc2_2:
		move.l    a5,(a7)
		jsr       _win_free
xfdc2_3:
		clr.l     d0
xfdc2_4:
		dc.w      $FE21

	xdef _win_free
_win_free: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		cmpi.w    #-1,6(a5)
		beq.s     xfdc37_1
		move.w    6(a5),(a7)
		jsr _wind_delete
xfdc37_1:
		movea.l   _thedesk,a0
		move.w    844(a0),d0
		movea.l   _thedesk,a1
		subq.w    #1,844(a1)
		clr.w     6(a5)
		clr.w     8(a5)
		move.w    #1,(a7)
		move.w    10(a5),-(a7)
		movea.l   _thedesk,a0
		move.l    24108(a0),-(a7)
		jsr _objc_order
		addq.l    #6,a7
		clr.l     (a7)
		clr.l     -(a7)
		move.w    10(a5),-(a7)
		jsr       _obj_wfree
		addq.l    #6,a7
		subq.w    #1,x0063c6
		move.w    #8,(a7)
		pea.l     230(a5)
		move.w    x0063c6,d0
		asl.w     #3,d0
		ext.l     d0
		add.l     #_g_winsave,d0
		move.l    d0,-(a7)
		jsr _LBCOPY
		addq.l    #8,a7
		dc.w      $F801

	xdef _win_find
_win_find: ds.b 0
		link      a6,#0
		movem.l   d6-d7,-(a7)
		clr.w     d7
		bra.s     xfdc3f_3
xfdc3f_1:
		movea.l   _winhead,a0
		move.w    d7,d1
		muls.w    #238,d1
		move.w    6(a0,d1.l),d0
		cmp.w     8(a6),d0
		bne.s     xfdc3f_2
		move.w    d7,d0
		muls.w    #238,d0
		add.l     _winhead,d0
		bra.s     xfdc3f_4
xfdc3f_2:
		addq.w    #1,d7
xfdc3f_3:
		cmp.w     #4,d7
		blt.s     xfdc3f_1
		clr.l     d0
xfdc3f_4:
		dc.w      $F021


	xdef _win_top
_win_top: ds.b 0
		link      a6,#-2
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		move.w    #-1,(a7)
		move.w    10(a5),-(a7)
		movea.l   _thedesk,a0
		move.l    24108(a0),-(a7)
		jsr _objc_order
		addq.l    #6,a7
		pea.l     28(a5)
		movea.l   _thedesk,a0
		move.l    13736(a0),-(a7)
		jsr _streq
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfdc43_1
		pea.l     32(a5)
		move.b    29(a5),d0
		ext.w     d0
		move.w    d0,-(a7)
		jsr       _pro_chdir
		addq.l    #6,a7
xfdc43_1:
		dc.w      $F801

	xdef _win_ontop
_win_ontop: ds.b 0
		link      a6,#0
		movem.l   d6-d7/a4-a5,-(a7)
		movea.l   _thedesk,a5
		move.w    24204(a5),d7
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		tst.w     24220(a0)
		beq.s     xfdc47_2
		movea.l   a5,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		tst.w     24222(a0)
		beq.s     xfdc47_2
		move.w    d7,d0
		subq.w    #2,d0
		muls.w    #238,d0
		movea.l   d0,a4
		adda.l    _winhead,a4
		pea.l     28(a4)
		move.l    13736(a5),-(a7)
		jsr _streq
		addq.l    #8,a7
		tst.w     d0
		bne.s     xfdc47_1
		pea.l     32(a4)
		move.b    29(a4),d0
		ext.w     d0
		move.w    d0,-(a7)
		jsr       _pro_chdir
		addq.l    #6,a7
xfdc47_1:
		move.l    a4,d0
		bra.s     xfdc47_3
		bra.s     xfdc47_3
xfdc47_2:
		clr.l     d0
xfdc47_3:
		dc.w      $FC21

	xdef _win_ith
_win_ith: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a5
		move.w    24202(a5),d6
		bra.s     xfdc4_2
xfdc4_1:
		movea.l   a5,a0
		move.w    d6,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    24200(a0),d6
xfdc4_2:
		move.w    d7,d0
		subq.w    #1,d7
		tst.w     d0
		bne.s     xfdc4_1
		move.w    d6,d0
		subq.w    #2,d0
		muls.w    #238,d0
		add.l     _winhead,d0
		dc.w      $F831

	xdef _xfdc524
_xfdc524: ds.b 0
		link      a6,#0
		movem.l   d4-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a3
		clr.w     d6
		movea.l   24(a5),a0
		movea.l   130(a0),a4
		bra.s     xfdc5_2
xfdc5_1:
		move.w    #-1,32(a4)
		addq.w    #1,d6
		movea.l   (a4),a4
xfdc5_2:
		move.l    a4,d0
		bne.s     xfdc5_1
		cmp.w     12306(a3),d6
		bge.s     xfdc5_3
		move.w    d6,d0
		bra.s     xfdc5_4
xfdc5_3:
		move.w    12306(a3),d0
xfdc5_4:
		move.w    d0,20(a5)
		move.w    d6,d0
		ext.l     d0
		divs.w    12306(a3),d0
		move.w    d0,22(a5)
		move.w    d6,d0
		ext.l     d0
		divs.w    12306(a3),d0
		swap      d0
		tst.w     d0
		beq.s     xfdc5_5
		addq.w    #1,22(a5)
xfdc5_5:
		tst.w     22(a5)
		bne.s     xfdc5_6
		addq.w    #1,22(a5)
xfdc5_6:
		tst.w     20(a5)
		bne.s     xfdc5_7
		addq.w    #1,20(a5)
xfdc5_7:
		tst.w     12(a6)
		bne.s     xfdc5_8
		addq.w    #1,12(a6)
xfdc5_8:
		move.w    20(a5),(a7)
		move.w    12(a6),-(a7)
		jsr _min
		addq.l    #2,a7
		move.w    d0,16(a5)
		move.w    d0,d5
		bra.s     xfdc5_10
xfdc5_9:
		subq.w    #1,12(a5)
xfdc5_10:
		move.w    20(a5),d0
		sub.w     12(a5),d0
		cmp.w     d0,d5
		bgt.s     xfdc5_9
		tst.w     14(a6)
		bne.s     xfdc5_11
		addq.w    #1,14(a6)
xfdc5_11:
		move.w    22(a5),(a7)
		move.w    14(a6),-(a7)
		jsr _min
		addq.l    #2,a7
		move.w    d0,18(a5)
		move.w    d0,d5
		bra.s     xfdc5_13
xfdc5_12:
		subq.w    #1,14(a5)
xfdc5_13:
		move.w    22(a5),d0
		sub.w     14(a5),d0
		cmp.w     d0,d5
		bgt.s     xfdc5_12
		move.w    14(a5),d7
		muls.w    12306(a3),d7
		add.w     12(a5),d7
		movea.l   24(a5),a0
		movea.l   130(a0),a4
		bra.s     xfdc5_15
xfdc5_14:
		movea.l   (a4),a4
xfdc5_15:
		move.w    d7,d0
		subq.w    #1,d7
		tst.w     d0
		beq.s     xfdc5_16
		move.l    a4,d0
		bne.s     xfdc5_14
xfdc5_16:
		movea.l   16(a6),a0
		move.l    a4,(a0)
		dc.w      $FE39


	xdef _xfdc61c
_xfdc61c: ds.b 0
		link      a6,#0
		movem.l   d7/a5,-(a7)
		movea.l   8(a6),a5
		pea.l     38(a5)
		pea.l     18(a5)
		move.w    #-1,-(a7)
		btst      #4,9(a5)
		beq.s     xfdc61_1
		move.w    #1,-(a7)
		bra.s     xfdc61_2
xfdc61_1:
		clr.w     -(a7)
xfdc61_2:
		clr.w     -(a7)
		jsr       _app_afind
		adda.w    #14,a7
		move.l    d0,34(a5)
		dc.w      $F801

	xdef _win_bldview
_win_bldview: ds.b 0
		link      a6,#-22
		movem.l   d2-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a3
		move.l    16(a6),-(a7)
		move.l    12(a6),-(a7)
		move.w    10(a5),-(a7)
		jsr       _obj_wfree
		adda.w    #10,a7
		pea.l     -4(a6)
		move.w    18(a6),d0
		ext.l     d0
		divs.w    12304(a3),d0
		move.w    d0,-(a7)
		move.w    16(a6),d0
		ext.l     d0
		divs.w    12302(a3),d0
		move.w    d0,-(a7)
		move.l    a5,-(a7)
		jsr       _xfdc524
		adda.w    #12,a7
		movea.l   -4(a6),a4
		move.w    20(a5),(a7)
		move.w    12(a5),d0
		sub.w     d0,(a7)
		move.w    16(a5),-(a7)
		addq.w    #1,(a7)
		jsr _min
		addq.l    #2,a7
		move.w    d0,-6(a6)
		move.w    22(a5),(a7)
		move.w    14(a5),d0
		sub.w     d0,(a7)
		move.w    18(a5),-(a7)
		addq.w    #1,(a7)
		jsr _min
		addq.l    #2,a7
		move.w    d0,-8(a6)
		clr.w     d3
		move.w    d3,d4
		bra       xfdc6_10
xfdc6_1:
		move.w    d4,d0
		muls.w    12304(a3),d0
		move.w    d0,-18(a6)
		move.w    d3,d0
		muls.w    12302(a3),d0
		move.w    d0,-16(a6)
		move.l    12294(a3),-(a7)
		move.w    12300(a3),-(a7)
		move.w    -18(a6),d0
		add.w     d0,(a7)
		move.w    12298(a3),-(a7)
		move.w    -16(a6),d0
		add.w     d0,(a7)
		move.w    10(a5),-(a7)
		jsr       _obj_ialloc
		adda.w    #10,a7
		move.w    d0,d7
		tst.w     d7
		beq       xfdc6_16
		move.w    d7,32(a4)
		movea.l   a3,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #64,24210(a0)
		movea.l   a3,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		clr.w     24208(a0)
		move.w    12292(a3),d0
		bra       xfdc6_6
xfdc6_2:
		movea.l   a3,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #24,24206(a0)
		move.l    a3,d0
		move.w    d7,d1
		asl.w     #3,d1
		ext.l     d1
		add.l     d1,d0
		add.l     #10206,d0
		movea.l   a3,a1
		move.w    d7,d2
		muls.w    #24,d2
		adda.l    d2,a1
		move.l    d0,24212(a1)
		movea.l   a3,a0
		move.w    d7,d1
		asl.w     #3,d1
		ext.l     d1
		adda.l    d1,a0
		move.l    _drawaddr,10206(a0)
		movea.l   a3,a1
		move.w    d7,d2
		asl.w     #3,d2
		ext.l     d2
		adda.l    d2,a1
		lea.l     9(a4),a0
		move.l    a0,10210(a1)
		move.l    a4,(a7)
		jsr       _xfdc61c
		bra       xfdc6_7
xfdc6_3:
		movea.l   a3,a0
		move.w    d7,d1
		muls.w    #24,d1
		adda.l    d1,a0
		move.w    #31,24206(a0)
		move.l    a4,(a7)
		jsr       _xfdc61c
		tst.w     38(a4)
		beq.s     xfdc6_4
		movea.l   34(a4),a0
		move.w    18(a0),d0
		bra.s     xfdc6_5
xfdc6_4:
		movea.l   34(a4),a0
		move.w    20(a0),d0
xfdc6_5:
		move.w    d0,-10(a6)
		movea.l   a3,a0
		movea.w   d7,a1
		adda.l    a1,a1
		adda.l    a1,a0
		move.w    -10(a6),9686(a0)
		move.l    a3,d0
		move.w    d7,d1
		muls.w    #34,d1
		add.l     d1,d0
		add.l     #$0000034E,d0
		movea.l   a3,a1
		move.w    d7,d2
		muls.w    #24,d2
		adda.l    d2,a1
		move.l    d0,24212(a1)
		move.l    a3,d0
		move.w    d7,d1
		muls.w    #34,d1
		add.l     d1,d0
		move.l    d0,(a7)
		addi.l    #$0000034E,(a7)
		move.l    a3,d0
		move.w    -10(a6),d1
		muls.w    #34,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #23322,(a7)
		move.w    #34,-(a7)
		jsr _movs
		addq.l    #6,a7
		movea.l   a3,a1
		move.w    d7,d2
		muls.w    #34,d2
		adda.l    d2,a1
		lea.l     18(a4),a0
		move.l    a0,854(a1)
		bra.s     xfdc6_7
xfdc6_6:
		tst.w     d0
		beq       xfdc6_3
		cmp.w     #1,d0
		beq       xfdc6_2
xfdc6_7:
		movea.l   (a4),a4
		addq.w    #1,d3
		cmp.w     -6(a6),d3
		bne.s     xfdc6_10
		addq.w    #1,d4
		clr.w     d3
		move.w    20(a5),d6
		sub.w     -6(a6),d6
		bra.s     xfdc6_9
xfdc6_8:
		movea.l   (a4),a4
xfdc6_9:
		move.w    d6,d0
		subq.w    #1,d6
		tst.w     d0
		beq.s     xfdc6_10
		move.l    a4,d0
		bne.s     xfdc6_8
xfdc6_10:
		cmp.w     -6(a6),d3
		bge.s     xfdc6_11
		cmp.w     -8(a6),d4
		bge.s     xfdc6_11
		move.l    a4,d0
		bne       xfdc6_1
xfdc6_11:
		move.w    6(a5),-20(a6)
		move.w    20(a5),(a7)
		move.w    #1000,-(a7)
		move.w    16(a5),-(a7)
		jsr _mul_div
		addq.l    #4,a7
		move.w    d0,-22(a6)
		clr.w     (a7)
		clr.l     -(a7)
		move.w    -22(a6),-(a7)
		move.w    #15,-(a7)
		move.w    -20(a6),-(a7)
		jsr _wind_set
		adda.w    #10,a7
		pea.l     -12(a6)
		pea.l     -12(a6)
		pea.l     -12(a6)
		pea.l     -22(a6)
		move.w    #15,-(a7)
		move.w    -20(a6),-(a7)
		jsr _wind_get
		adda.w    #20,a7
		move.w    20(a5),d0
		cmp.w     16(a5),d0
		ble.s     xfdc6_12
		move.w    20(a5),(a7)
		move.w    16(a5),d0
		sub.w     d0,(a7)
		move.w    #1000,-(a7)
		move.w    12(a5),-(a7)
		jsr _mul_div
		addq.l    #4,a7
		move.w    d0,d5
		bra.s     xfdc6_13
xfdc6_12:
		clr.w     d5
xfdc6_13:
		clr.w     (a7)
		clr.l     -(a7)
		move.w    d5,-(a7)
		move.w    #8,-(a7)
		move.w    -20(a6),-(a7)
		jsr _wind_set
		adda.w    #10,a7
		move.w    22(a5),(a7)
		move.w    #1000,-(a7)
		move.w    18(a5),-(a7)
		jsr _mul_div
		addq.l    #4,a7
		move.w    d0,-22(a6)
		clr.w     (a7)
		clr.l     -(a7)
		move.w    -22(a6),-(a7)
		move.w    #16,-(a7)
		move.w    -20(a6),-(a7)
		jsr _wind_set
		adda.w    #10,a7
		pea.l     -12(a6)
		pea.l     -12(a6)
		pea.l     -12(a6)
		pea.l     -22(a6)
		move.w    #16,-(a7)
		move.w    -20(a6),-(a7)
		jsr _wind_get
		adda.w    #20,a7
		move.w    22(a5),d0
		cmp.w     18(a5),d0
		ble.s     xfdc6_14
		move.w    22(a5),(a7)
		move.w    18(a5),d0
		sub.w     d0,(a7)
		move.w    #1000,-(a7)
		move.w    14(a5),-(a7)
		jsr _mul_div
		addq.l    #4,a7
		move.w    d0,d5
		bra.s     xfdc6_15
xfdc6_14:
		clr.w     d5
xfdc6_15:
		clr.w     (a7)
		clr.l     -(a7)
		move.w    d5,-(a7)
		move.w    #9,-(a7)
		move.w    -20(a6),-(a7)
		jsr _wind_set
		adda.w    #10,a7
xfdc6_16:
		dc.w      $FE3F


	xdef _xfdc988
_xfdc988: ds.b 0
		link      a6,#-30
		movem.l   d3-d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		move.w    14(a6),d7
		lea.l     -22(a6),a4
		tst.w     d7
		ble.s     xfdc9_1
		move.w    d7,d0
		bra.s     xfdc9_2
xfdc9_1:
		clr.w     d0
xfdc9_2:
		move.w    d0,d7
		tst.w     12(a6)
		beq.s     xfdc9_3
		move.w    d7,(a7)
		move.w    22(a5),-(a7)
		move.w    18(a5),d0
		sub.w     d0,(a7)
		jsr _min
		addq.l    #2,a7
		move.w    d0,d7
		move.w    18(a5),-2(a6)
		move.w    d7,d6
		sub.w     14(a5),d6
		add.w     d6,14(a5)
		bra.s     xfdc9_4
xfdc9_3:
		move.w    d7,(a7)
		move.w    20(a5),-(a7)
		move.w    16(a5),d0
		sub.w     d0,(a7)
		jsr _min
		addq.l    #2,a7
		move.w    d0,d7
		move.w    16(a5),-2(a6)
		move.w    d7,d6
		sub.w     12(a5),d6
		add.w     d6,12(a5)
xfdc9_4:
		tst.w     d6
		bne.s     xfdc9_5
		clr.w     d0
		bra       xfdc9_17
xfdc9_5:
		move.l    a4,(a7)
		move.w    #4,-(a7)
		move.w    6(a5),-(a7)
		jsr _wind_grget
		addq.l    #4,a7
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.l    a5,-(a7)
		jsr       _win_bldview
		adda.w    #12,a7
		pea.l     -30(a6)
		move.l    a4,-(a7)
		jsr _rc_copy
		addq.l    #8,a7
		pea.l     -30(a6)
		move.l    #_gl_rfull,-(a7)
		jsr _rc_intersect
		addq.l    #8,a7
		pea.l     -30(a6)
		move.l    a4,-(a7)
		jsr _rc_equal
		addq.l    #8,a7
		tst.w     d0
		beq       xfdc9_16
		tst.w     d6
		blt.s     xfdc9_6
		clr.w     d0
		bra.s     xfdc9_7
xfdc9_6:
		moveq.l   #1,d0
xfdc9_7:
		move.w    d0,-12(a6)
		beq.s     xfdc9_8
		move.w    d6,d0
		neg.w     d0
		move.w    d0,d6
xfdc9_8:
		cmp.w     -2(a6),d6
		bge       xfdc9_16
		tst.w     12(a6)
		beq.s     xfdc9_10
		clr.w     d0
		move.w    d0,-4(a6)
		move.w    d0,d5
		move.w    d6,d4
		movea.l   _thedesk,a0
		move.w    d4,d0
		muls.w    12304(a0),d0
		move.w    d0,d4
		clr.w     -6(a6)
		move.w    4(a4),-8(a6)
		move.w    6(a4),d0
		sub.w     d4,d0
		move.w    d0,-10(a6)
		bra.s     xfdc9_11
xfdc9_10:
		move.w    d6,d5
		movea.l   _thedesk,a0
		move.w    d5,d0
		muls.w    12302(a0),d0
		move.w    d0,d5
		clr.w     -4(a6)
		clr.w     d0
		move.w    d0,-6(a6)
		move.w    d0,d4
		move.w    4(a4),d0
		sub.w     d5,d0
		move.w    d0,-8(a6)
		move.w    6(a4),-10(a6)
xfdc9_11:
		tst.w     -12(a6)
		beq.s     xfdc9_12
		move.w    d5,-14(a6)
		move.w    -4(a6),d5
		move.w    -14(a6),-4(a6)
		move.w    d4,-14(a6)
		move.w    -6(a6),d4
		move.w    -14(a6),-6(a6)
xfdc9_12:
		move.l    a4,(a7)
		jsr _gsx_sclip
		move.w    -10(a6),(a7)
		move.w    -8(a6),-(a7)
		move.w    2(a4),-(a7)
		move.w    -6(a6),d0
		add.w     d0,(a7)
		move.w    (a4),-(a7)
		move.w    -4(a6),d0
		add.w     d0,(a7)
		move.w    d4,-(a7)
		move.w    2(a4),d0
		add.w     d0,(a7)
		move.w    d5,-(a7)
		move.w    (a4),d0
		add.w     d0,(a7)
		move.w    #3,-(a7)
		jsr _bb_screen
		adda.w    #12,a7
		tst.w     12(a6)
		beq.s     xfdc9_14
		tst.w     -12(a6)
		bne.s     xfdc9_13
		move.w    -10(a6),d0
		add.w     d0,2(a4)
xfdc9_13:
		move.w    -10(a6),d0
		sub.w     d0,6(a4)
		bra.s     xfdc9_16
xfdc9_14:
		tst.w     -12(a6)
		bne.s     xfdc9_15
		move.w    -8(a6),d0
		add.w     d0,(a4)
xfdc9_15:
		move.w    -8(a6),d0
		sub.w     d0,4(a4)
xfdc9_16:
		move.l    4(a4),-(a7)
		move.l    (a4),-(a7)
		move.w    6(a5),-(a7)
		jsr _do_wredraw
		adda.w    #10,a7
xfdc9_17:
		dc.w      $FC3D

	xdef _win_slide
_win_slide: ds.b 0
		link      a6,#-16
		movem.l   d7/a5,-(a7)
		move.w    8(a6),(a7)
		jsr _win_find
		movea.l   d0,a5
		tst.w     12(a6)
		beq.s     srl_bar1
		move.w    22(a5),-8(a6)
		move.w    18(a5),-10(a6)
		move.w    #16,-14(a6)
		bra.s     srl_bar2
srl_bar1:
		move.w    20(a5),-8(a6)
		move.w    16(a5),-10(a6)
		move.w    #15,-14(a6)
srl_bar2:
		pea.l     -12(a6)
		pea.l     -12(a6)
		pea.l     -12(a6)
		pea.l     -16(a6)
		move.w    -14(a6),-(a7)
		move.w    8(a6),-(a7)
		jsr _wind_get
		adda.w    #20,a7
		move.w    #1000,(a7)
		move.w    -8(a6),-(a7)
		move.w    -10(a6),d0
		sub.w     d0,(a7)
		move.w    10(a6),-(a7)
		jsr _mul_div
		addq.l    #4,a7
		move.w    d0,-4(a6)
		move.w    -4(a6),(a7)
		move.w    12(a6),-(a7)
		move.l    a5,-(a7)
		jsr       _xfdc988
		addq.l    #6,a7
		dc.w      $F801


	xdef _win_arrow
_win_arrow: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a5,-(a7)
		move.w    8(a6),(a7)
		jsr _win_find
		movea.l   d0,a5
		moveq.l   #1,d7
		move.w    10(a6),d0
		bra.s     xfdcb_9

/* case 0 */
xfdcb_1:
		move.w    14(a5),d6
		sub.w     18(a5),d6
		bra.s     xfdcb_10

/* case 1 */
xfdcb_2:
		move.w    14(a5),d6
		add.w     18(a5),d6
		bra.s     xfdcb_10

/* case 2 */
xfdcb_3:
		move.w    14(a5),d6
		subq.w    #1,d6
		bra.s     xfdcb_10

/* case 3 */
xfdcb_4:
		move.w    14(a5),d6
		addq.w    #1,d6
		bra.s     xfdcb_10

/* case 4 */
xfdcb_5:
		move.w    12(a5),d6
		sub.w     16(a5),d6
		clr.w     d7
		bra.s     xfdcb_10

/* case 5 */
xfdcb_6:
		move.w    12(a5),d6
		add.w     16(a5),d6
		clr.w     d7
		bra.s     xfdcb_10

/* case 6 */
xfdcb_7:
		move.w    12(a5),d6
		subq.w    #1,d6
		clr.w     d7
		bra.s     xfdcb_10

/* case 7 */
xfdcb_8:
		move.w    12(a5),d6
		addq.w    #1,d6
		clr.w     d7
		bra.s     xfdcb_10
xfdcb_9:
		cmp.w     #7,d0
		bhi.s     xfdcb_10
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb2e6,a0
		movea.l   (a0),a0
		jmp       (a0)
xfdcb_10:
		move.w    d6,(a7)
		move.w    d7,-(a7)
		move.l    a5,-(a7)
		jsr       _xfdc988
		addq.l    #6,a7
		dc.w      $F831

	xdef _win_bdall
_win_bdall: ds.b 0
		link      a6,#-8
		movem.l   d5-d7/a4-a5,-(a7)
		movea.l   _thedesk,a5
		clr.w     d7
		bra.s     xfdcc_3
xfdcc_1:
		move.w    d7,d0
		muls.w    #238,d0
		add.l     _winhead,d0
		movea.l   d0,a0
		move.w    6(a0),d6
		tst.w     d6
		beq.s     xfdcc_2
		pea.l     -8(a6)
		move.w    #4,-(a7)
		move.w    d6,-(a7)
		jsr _wind_grget
		addq.l    #8,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    d7,d0
		muls.w    #238,d0
		add.l     _winhead,d0
		move.l    d0,-(a7)
		jsr       _win_bldview
		adda.w    #12,a7
xfdcc_2:
		addq.w    #1,d7
xfdcc_3:
		cmp.w     #4,d7
		blt.s     xfdcc_1
		moveq.l   #4,d7
		bra.s     xfdcc_6
xfdcc_4:
		move.w    d7,(a7)
		jsr       _win_ith
		movea.l   d0,a4
		tst.w     6(a4)
		beq.s     xfdcc_5
		pea.l     -8(a6)
		move.w    #4,-(a7)
		move.w    6(a4),-(a7)
		jsr _wind_grget
		addq.l    #8,a7
		move.l    -4(a6),-(a7)
		move.l    -8(a6),-(a7)
		move.w    6(a4),-(a7)
		move.w    _gl_apid,-(a7)
		move.w    #20,-(a7)
		jsr _send_msg
		adda.w    #14,a7
xfdcc_5:
		subq.w    #1,d7
xfdcc_6:
		tst.w     d7
		bne.s     xfdcc_4
		dc.w      $FC31


	xdef _win_isel
_win_isel: ds.b 0
		link      a6,#0
		movem.l   d5-d7,-(a7)
		move.w    12(a6),d7
		move.w    14(a6),d6
		tst.w     d6
		bne.s     xfdcd_1
		move.w    d7,d0
		muls.w    #24,d0
		add.l     8(a6),d0
		movea.l   d0,a0
		move.w    2(a0),d6
		bra.s     xfdcd_2
xfdcd_1:
		move.w    d6,d0
		muls.w    #24,d0
		add.l     8(a6),d0
		movea.l   d0,a0
		move.w    (a0),d6
xfdcd_2:
		bra.s     xfdcd_5
xfdcd_3:
		move.w    d6,d0
		muls.w    #24,d0
		add.l     8(a6),d0
		movea.l   d0,a0
		btst      #0,11(a0)
		beq.s     xfdcd_4
		move.w    d6,d0
		bra.s     xfdcd_6
xfdcd_4:
		move.w    d6,d0
		muls.w    #24,d0
		add.l     8(a6),d0
		movea.l   d0,a0
		move.w    (a0),d6
xfdcd_5:
		cmp.w     d7,d6
		bgt.s     xfdcd_3
		clr.w     d0
xfdcd_6:
		dc.w      $F031


	xdef _win_iname
_win_iname: ds.b 0
		link      a6,#-12
		move.w    8(a6),d0
		muls.w    #24,d0
		add.l     _thedesk,d0
		movea.l   d0,a0
		move.l    24212(a0),-4(a6)
		movea.l   -4(a6),a0
		move.l    8(a0),-8(a6)
		move.l    -8(a6),d0
		dc.w      $F001

	xdef _win_sinfo
_win_sinfo: ds.b 0
		link      a6,#-6
		movem.l   d7/a4-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   _thedesk,a4
		movea.l   24(a5),a0
		move.l    136(a0),-6(a6)
		movea.l   24(a5),a0
		move.w    134(a0),-2(a6)
		pea.l     13650(a4)
		clr.w     -(a7)
		move.w    #5,-(a7)
		jsr _rsrc_gaddr
		addq.l    #8,a7
		move.l    13650(a4),(a7)
		move.l    _g_buffer,-(a7)
		jsr _LSTCPY
		addq.l    #4,a7
		pea.l     -6(a6)
		move.l    _g_buffer,-(a7)
		pea.l     149(a5)
		jsr _merge_str
		adda.w    #12,a7
		dc.w      $FC01

	xdef _win_sname
_win_sname: ds.b 0
		link      a6,#0
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		movea.l   24(a5),a4
		addq.l    #8,a4
		lea.l     28(a5),a3
		move.b    #' ',(a3)+
		bra.s     xfdcde_2
xfdcde_1:
		move.b    (a4)+,(a3)+
xfdcde_2:
		tst.b     (a4)
		beq.s     xfdcde_3
		cmpi.b    #'*',(a4)
		bne.s     xfdcde_1
xfdcde_3:
		move.b    #' ',(a3)+
		clr.b     (a3)
		dc.w      $FE01

	xdef _wind_grget
_wind_grget: ds.b 0
		link      a6,#-4
		move.l    12(a6),(a7)
		addq.l    #6,(a7)
		move.l    12(a6),-(a7)
		addq.l    #4,(a7)
		move.l    12(a6),-(a7)
		addq.l    #2,(a7)
		move.l    12(a6),-(a7)
		move.l    8(a6),-(a7)
		jsr _wind_get
		adda.w    #16,a7
		dc.w      $F001


	data


xfeb2e6:
		dc.l xfdcb_1
		dc.l xfdcb_2
		dc.l xfdcb_3
		dc.l xfdcb_4
		dc.l xfdcb_5
		dc.l xfdcb_6
		dc.l xfdcb_7
		dc.l xfdcb_8

	bss
	xdef x0063c6
	comm x0063c6,2
	xdef _winhead
	comm _winhead,4
	
