	xdef _desk_wait
_desk_wait: ds.b 0
		link      a6,#-4
		clr.l     (a7)
		tst.w     8(a6)
		beq.s     desk_w1
		move.w    #2,-(a7)
		bra.s     desk_w2
desk_w1:
		clr.w     -(a7)
desk_w2:
		dc.w      0xF2C4 ; graf_mouse
		addq.l    #2,a7
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef xfdb04c
xfdb04c: ds.b 0
		link      a6,#-134
		movem.l   d5-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		move.w    10(a6),d6
		movea.l   16(a6),a5
		suba.l    a4,a4
		suba.l    a3,a3
		tst.w     d7
		bne.s     xfdb0_1
		move.w    d6,(a7)
		dc.w      0xF5C4
		move.l    d0,-4(a6)
		move.l    a5,(a7)
		move.l    -4(a6),-(a7)
		move.w    d6,-(a7)
		move.l    #0x0001FFFF,-(a7)
		dc.w      0xF4DC
		adda.w    #10,a7
		movea.l   d0,a4
		bra       xfdb0_10
xfdb0_1:
		cmp.w     #-1,d6
		beq       xfdb0_10
		move.w    d7,(a7)
		dc.w      0xF2EC
		move.l    d0,-8(a6)
		movea.l   -8(a6),a0
		movea.l   24(a0),a0
		movea.l   130(a0),a3
		bra.s     xfdb0_3
xfdb0_2:
		cmp.w     32(a3),d6
		beq.s     xfdb0_4
		movea.l   (a3),a3
xfdb0_3:
		move.l    a3,d0
		bne.s     xfdb0_2
xfdb0_4:
		move.l    a3,d0
		beq       xfdb0_10
		pea.l     -130(a6)
		movea.l   -8(a6),a0
		move.l    24(a0),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
		move.l    a6,(a7)
		addi.l    #-130,(a7)
		dc.w      0xF5DC ; sh_name
		move.l    d0,-134(a6)
		movea.l   -134(a6),a0
		clr.b     (a0)
		movea.l   -134(a6),a0
		cmpi.b    #0x5C,-1(a0)
		bne.s     xfdb0_5
		pea.l     -130(a6)
		pea.l     18(a3)
		dc.w      0xF404 ; xstrpcat
		addq.l    #8,a7
xfdb0_5:
		lea.l     -130(a6),a0
		move.l    a0,-134(a6)
		bra.s     xfdb0_7
xfdb0_6:
		move.l    -134(a6),-(a7)
		movea.l   -134(a6),a0
		move.b    (a0),d0
		ext.w     d0
		move.w    d0,-(a7)
		dc.w      0xF548 ; toupper
		addq.l    #2,a7
		movea.l   (a7)+,a0
		move.b    d0,(a0)
		addq.l    #1,-134(a6)
xfdb0_7:
		movea.l   -134(a6),a0
		tst.b     (a0)
		bne.s     xfdb0_6
		move.l    a5,(a7)
		pea.l     -130(a6)
		move.w    #-1,-(a7)
		btst      #4,9(a3)
		beq.s     xfdb0_8
		move.w    #1,-(a7)
		bra.s     xfdb0_9
xfdb0_8:
		clr.w     -(a7)
xfdb0_9:
		clr.w     -(a7)
		dc.w      0xF4DC
		adda.w    #10,a7
		movea.l   d0,a4
xfdb0_10:
		movea.l   12(a6),a0
		move.l    a3,(a0)
		move.l    a4,d0
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfdb152
xfdb152: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a5,-(a7)
		move.l    8(a6),d7
		movea.l   12(a6),a5
		move.w    16(a6),d6
		bra.s     xfdb15_2
xfdb15_1:
		move.w    d6,(a7)
		move.b    (a5)+,d0
		ext.w     d0
		move.w    d0,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E0 ; menu_ienable
		addq.l    #6,a7
xfdb15_2:
		tst.b     (a5)
		bne.s     xfdb15_1
		dc.w      0xF831 ; movem.l (a7)+,d6-d7/a5

	xdef xfdb17c
xfdb17c: ds.b 0
		link      a6,#-16
		movem.l   d3-d7/a5,-(a7)
		move.l    8(a6),d7
		moveq.l   #18,d6
		bra.s     xfdb1_2
xfdb1_1:
		move.w    #1,(a7)
		move.w    d6,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E0 ; menu_ienable
		addq.l    #6,a7
		addq.w    #1,d6
xfdb1_2:
		cmp.w     #38,d6
		ble.s     xfdb1_1
		clr.w     (a7)
		move.l    #xfeb1c4,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E4
		addq.l    #8,a7
		clr.w     d5
		clr.w     d6
		bra       xfdb1_14
xfdb1_3:
		pea.l     -2(a6)
		pea.l     -6(a6)
		move.w    d6,-(a7)
		movea.l   _thedesk,a0
		move.w    13720(a0),-(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a5
xfdb1_4:
		move.w    6(a5),d0
		bra.s     xfdb1_12

/* case 0 */
xfdb1_5:
		tst.w     -2(a6)
		beq.s     xfdb1_6
		move.l    #xfeb1ca,d0
		bra.s     xfdb1_23
xfdb1_6:
		move.l    #xfeb1ce,d0
xfdb1_23:
		move.l    d0,-10(a6)
		bra.s     xfdb1_13

/* case 1 */
xfdb1_7:
		move.l    #xfeb1ce,-10(a6)
		bra.s     xfdb1_13

/* case 4 */
xfdb1_8:
		move.l    #xfeb1f4,-10(a6)
		bra.s     xfdb1_13

/* case 2 */
xfdb1_9:
		move.w    22(a5),d0
		ext.w     d0
		cmp.w     #'B',d0
		ble.s     xfdb1_24
		move.l    #xfeb1c0,d0
		bra.s     xfdb1_10
xfdb1_24:
		move.l    #xfeb1d2,d0
xfdb1_10:
		move.l    d0,-10(a6)
		bra.s     xfdb1_13

/* case 3 */
xfdb1_11:
		move.l    #xfeb1d4,-10(a6)
		bra.s     xfdb1_13
xfdb1_12:
		cmp.w     #4,d0
		bhi.s     xfdb1_13
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb206,a0
		movea.l   (a0),a0
		jmp       (a0)
xfdb1_13:
		clr.w     (a7)
		move.l    -10(a6),-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E4
		addq.l    #8,a7
		addq.w    #1,d5
xfdb1_14:
		move.w    d6,(a7)
		movea.l   _thedesk,a0
		move.w    13718(a0),-(a7)
		move.l    _thedesk,-(a7)
		addi.l    #24200,(a7)
		dc.w      0xF4F8
		addq.l    #6,a7
		move.w    d0,d6
		bne       xfdb1_3
		dc.w      0xF584
		tst.l     d0
		beq.s     xfdb1_25
		move.l    #xfeb1e4,d0
		bra.s     xfdb1_15
xfdb1_25:
		move.l    #xfeb1e0,d0
xfdb1_15:
		move.l    d0,-10(a6)
		move.l    -10(a6),d0
		cmp.l     #xfeb1e4,d0
		beq.s     xfdb1_16
		clr.w     (a7)
		bra.s     xfdb1_17
xfdb1_16:
		move.w    #1,(a7)
xfdb1_17:
		move.l    -10(a6),-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E4
		addq.l    #8,a7
		dc.w      0xF584
		move.l    d0,-16(a6)
		tst.l     -16(a6)
		beq.s     xfdb1_20
		movea.l   _thedesk,a0
		move.l    13736(a0),(a7)
		move.l    -16(a6),-(a7)
		addi.l    #28,(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		beq.s     xfdb1_18
		clr.w     -12(a6)
		bra.s     xfdb1_19
xfdb1_18:
		move.w    #1,-12(a6)
xfdb1_19:
		move.w    -12(a6),(a7)
		move.l    #xfeb1fa,-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E4
		addq.l    #8,a7
xfdb1_20:
		cmp.w     #1,d5
		beq.s     xfdb1_22
		tst.w     d5
		beq.s     xfdb1_26
		move.l    #xfeb1ee,d0
		bra.s     xfdb1_21
xfdb1_26:
		move.l    #xfeb1da,d0
xfdb1_21:
		move.l    d0,-10(a6)
		clr.w     (a7)
		move.l    -10(a6),-(a7)
		move.l    d7,-(a7)
		dc.w      0xF5E4
		addq.l    #8,a7
xfdb1_22:
		dc.w      0xF83D ; movem.l (a7)+,d4-d7/a5

	xdef _do_file
_do_file: ds.b 0
		link      a6,#-10
		movem.l   d3-d7/a3-a5,-(a7)
		movea.l   _thedesk,a3
		clr.w     d7
		dc.w      0xF584
		movea.l   d0,a5
		clr.w     (a7)
		move.w    13718(a3),-(a7)
		pea.l     24200(a3)
		dc.w      0xF4F8
		addq.l    #6,a7
		move.w    d0,d6
		move.w    8(a6),d0
		bra.s     do_fil12

/* case OPENITEM */
do_fil1:
		tst.w     d6
		beq.s     do_fil2
		move.w    d6,(a7)
		dc.w      0xF5E8
		move.w    d0,d7
do_fil2:
		bra.w     do_fil13

/* case SHOWITEM */
do_fil3:
		tst.w     d6
		beq.s     do_fil4
		move.w    d6,(a7)
		dc.w      0xF5EC
		move.w    d0,d7
do_fil4:
		bra.s     do_fil13

/* case NEWFITEM */
do_fil5:
		move.l    a5,d0
		beq.s     do_fil14
		move.l    a5,(a7)
		dc.w      0xF5F0
		clr.w     (a7)
		dc.w      0xF444 ; _hd_win
do_fil14:
		bra.s     do_fil13

/* case CLSFITEM */
do_fil6:
		move.l    a5,d0
		beq.s     do_fil7
		move.w    13720(a3),(a7)
		dc.w      0xF444 ; _hd_win
		clr.w     (a7)
		move.l    a5,-(a7)
		dc.w      0xF5F4
		addq.l    #4,a7
do_fil7:
		bra.s     do_fil13

/* case CLSWITEM */
do_fil8:
		move.l    a5,d0
		beq.s     do_fil9
		move.w    13720(a3),(a7)
		dc.w      0xF444 ; _hd_win
		move.w    #1,(a7)
		move.l    a5,-(a7)
		dc.w      0xF5F4
		addq.l    #4,a7
do_fil9:
		bra.s     do_fil13

/* case FORMITEM */
do_fil10:
		tst.w     d6
		beq.s     do_fil11
		move.w    d6,(a7)
		dc.w      0xF5F8
		move.w    d0,d7
do_fil11:
		bra.s     do_fil13
do_fil12:
		sub.w     #18,d0
		cmp.w     #7,d0
		bhi.s     do_fil13
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb21a,a0
		movea.l   (a0),a0
		jmp       (a0)
do_fil13:
		move.w    d7,d0
		dc.w      0xFE3D ; movem.l (a7)+,d4-d7/a3-a5

	xdef xfdb3bc
xfdb3bc: ds.b 0
		link      a6,#0
		movem.l   d2-d7/a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a5
		clr.w     d6
		move.w    12292(a5),d5
		move.w    12308(a5),d4
		move.w    d7,d0
		bra.s     xfdb3_7

/* case ICONITEM */
xfdb3_1:
		clr.w     d5
		bra.s     xfdb3_8

/* case TEXTITEM */
xfdb3_2:
		moveq.l   #1,d5
		bra.s     xfdb3_8

/* case NAMEITEM */
xfdb3_3:
		clr.w     d4
		bra.s     xfdb3_8

/* case DATEITEM */
xfdb3_4:
		moveq.l   #1,d4
		bra.s     xfdb3_8

/* case SIZEITEM */
xfdb3_5:
		moveq.l   #2,d4
		bra.s     xfdb3_8

/* case TYPEITEM */
xfdb3_6:
		moveq.l   #3,d4
		bra.s     xfdb3_8

xfdb3_7:
		sub.w     #27,d0
		cmp.w     #6,d0
		bhi.s     xfdb3_8
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb23a,a0
		movea.l   (a0),a0
		jmp       (a0)

xfdb3_8:
		cmp.w     12292(a5),d5
		bne.s     xfdb3_9
		cmp.w     12308(a5),d4
		beq.s     xfdb3_12
xfdb3_9:
		cmp.w     12292(a5),d5
		beq.s     xfdb3_10
		clr.w     (a7)
		move.w    13724(a5),-(a7)
		move.l    13654(a5),-(a7)
		dc.w      0xF5FC ; menu_icheck
		addq.l    #6,a7
		move.w    d7,13724(a5)
		move.w    #1,(a7)
		move.w    d7,-(a7)
		move.l    13654(a5),-(a7)
		dc.w      0xF5FC ; menu_icheck
		addq.l    #6,a7
xfdb3_10:
		cmp.w     12308(a5),d4
		beq.s     xfdb3_11
		clr.w     (a7)
		move.w    13726(a5),-(a7)
		move.l    13654(a5),-(a7)
		dc.w      0xF5FC ; menu_icheck
		addq.l    #6,a7
		move.w    d7,13726(a5)
		move.w    #1,(a7)
		move.w    d7,-(a7)
		move.l    13654(a5),-(a7)
		dc.w      0xF5FC ; menu_icheck
		addq.l    #6,a7
xfdb3_11:
		move.w    d4,(a7)
		move.w    d5,-(a7)
		dc.w      0xF600
		addq.l    #2,a7
xfdb3_12:
		move.w    d6,d0
		dc.w      0xF83F ; movem.l (a7)+,d3-d7/a5

	xdef _do_opt
_do_opt: ds.b 0
		link      a6,#-20
		movem.l   d4-d7/a4-a5,-(a7)
		suba.l    a5,a5
		clr.l     -12(a6)
		clr.w     -14(a6)
		movea.l   _thedesk,a4
		clr.w     d7
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    13718(a4),-(a7)
		pea.l     24200(a4)
		dc.w      0xF56C
		adda.w    #22,a7
		clr.w     (a7)
		move.w    13718(a4),-(a7)
		pea.l     24200(a4)
		dc.w      0xF4F8
		addq.l    #6,a7
		move.w    d0,d6
		tst.w     d6
		beq.s     do_opt1
		pea.l     -14(a6)
		pea.l     -12(a6)
		move.w    d6,-(a7)
		move.w    13720(a4),-(a7)
		dc.w      0xF2F8
		adda.w    #12,a7
		movea.l   d0,a5
do_opt1:
		move.w    8(a6),d0
		bra       do_opt16

/* case IDSKITEM */
do_opt2:
		move.l    a5,d0
		beq.s     do_opt3
		move.l    a5,(a7)
		dc.w      0xF604
		tst.w     d0
		beq.s     do_opt3
		dc.w      0xF608
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    #4,-(a7)
		clr.w     -(a7)
		dc.w      0xF5C8 ; wind_get
		adda.w    #20,a7
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		clr.w     -(a7)
		dc.w      0xF2C0 ; do_redraw
		addq.l    #8,a7
do_opt3:
		bra       do_opt17

/* case IAPPITEM */
do_opt4:
		move.l    a5,d0
		beq.s     do_opt5
		tst.w     -14(a6)
		beq.s     do_opt5
		move.l    a5,(a7)
		move.l    -12(a6),-(a7)
		addi.l    #18,(a7)
		dc.w      0xF60C
		addq.l    #4,a7
		tst.w     d0
		beq.s     do_opt5
		move.w    #0x011B,(a7)
		dc.w      0xF610 ; hd_keybd
do_opt5:
		bra       do_opt17

/* case PREFITEM */
do_opt6:
		dc.w      0xF614 ; desk_pref
		move.w    d0,d7
		bra       do_opt17

/* case SAVEITEM */
do_opt7:
		clr.l     (a7)
		move.l    #0x0001001F,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		cmp.w     #1,d0
		bne.s     do_opt8
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		dc.w      0xF618
		move.w    #1,(a7)
		dc.w      0xF61C ; save_inf
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
do_opt8:
		bra.w     do_opt17

/* case PRINTITEM */
do_opt9:
		clr.l     (a7)
		move.l    #0x00010020,-(a7)
		dc.w      0xF0DC ; fill_string
		addq.l    #4,a7
		cmp.w     #1,d0
		bne.s     do_opt10
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		dc.w      0xF620 ; av_hardcopy
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
do_opt10:
		bra.s     do_opt17

/* case BITBLT */
do_opt11:
		tst.w     13732(a4)
		beq.s     do_opt12
		clr.w     (a7)
		bra.s     do_opt13
do_opt12:
		move.w    #1,(a7)
do_opt13:
		move.w    #64,-(a7) ; Blitmode
		dc.w      0xF0EC ; trp14
		addq.l    #2,a7
		tst.w     13732(a4)
		beq.s     do_opt14
		clr.w     d0
		bra.s     do_opt15
do_opt14:
		moveq.l   #1,d0
do_opt15:
		move.w    d0,13732(a4)
		move.w    13732(a4),(a7)
		move.w    #42,-(a7)
		move.l    13654(a4),-(a7)
		dc.w      0xF5FC ; menu_icheck
		addq.l    #6,a7
		bra.s     do_opt17
do_opt16:
		sub.w     #35,d0
		cmp.w     #7,d0
		bhi.s     do_opt17
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb256,a0
		movea.l   (a0),a0
		jmp       (a0)
do_opt17:
		move.w    d7,d0
		dc.w      0xFC39 ; movem.l (a7)+,d5-d7/a4-a5


	xdef _hd_button
_hd_button: ds.b 0
		link      a6,#-14
		movem.l   d3-d7/a3-a5,-(a7)
		movea.l   _thedesk,a4
		lea.l     -12(a6),a3
		clr.w     -2(a6)
		move.l    10(a6),-(a7)
		dc.w      0xF2E8 ; wind_find
		addq.l    #4,a7
		move.w    d0,d7
		cmp.w     13720(a4),d7
		beq.s     hd_butt1
		move.w    13720(a4),(a7)
		dc.w      0xF444 ; _hd_win
hd_butt1:
		clr.w     (a7)
		move.w    d7,-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		move.w    d7,13722(a4)
		move.l    a3,(a7)
		move.w    #4,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF4BC
		addq.l    #4,a7
		cmpi.w    #1,8(a6)
		bne       hd_butt5
		clr.w     (a7)
		move.l    a3,-(a7)
		move.w    16(a6),-(a7)
		move.l    10(a6),-(a7)
		move.w    13718(a4),-(a7)
		move.l    24108(a4),-(a7)
		move.w    13720(a4),-(a7)
		dc.w      0xF624
		adda.w    #18,a7
		pea.l     -4(a6)
		pea.l     14(a6)
		pea.l     -4(a6)
		pea.l     -4(a6)
		dc.w      0xF2DC ; graf_mkstate
		adda.w    #16,a7
		btst      #0,15(a6)
		beq.s     hd_butt4
		pea.l     -14(a6)
		move.l    a3,-(a7)
		move.l    10(a6),-(a7)
		move.w    13718(a4),-(a7)
		move.l    24108(a4),-(a7)
		move.w    13720(a4),-(a7)
		dc.w      0xF628
		adda.w    #20,a7
		move.w    d0,d4
		cmp.w     #-1,d4
		beq.s     hd_butt4
		tst.w     d4
		beq.s     hd_butt2
		move.w    d4,(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.w    10(a5),d6
		bra.s     hd_butt3
hd_butt2:
		moveq.l   #1,d6
hd_butt3:
		move.w    -14(a6),(a7)
		move.w    d6,-(a7)
		move.w    d4,-(a7)
		move.w    d7,-(a7)
		dc.w      0xF62C
		addq.l    #6,a7
		move.w    d0,-2(a6)
hd_butt4:
		bra.s     hd_butt6
hd_butt5:
		move.w    #1,(a7)
		pea.l     -12(a6)
		move.w    16(a6),-(a7)
		move.l    10(a6),-(a7)
		move.w    13718(a4),-(a7)
		move.l    24108(a4),-(a7)
		move.w    13720(a4),-(a7)
		dc.w      0xF624
		adda.w    #18,a7
		move.w    #18,(a7) ; OPENITEM
		dc.w      0xF630 ; do_file
		move.w    d0,-2(a6)
hd_butt6:
		move.l    13654(a4),(a7)
		dc.w      0xF634
		move.w    -2(a6),d0
		dc.w      0xFE3D ; movem.l (a7)+,d4-d7/a3-a5

	xdef _hd_keybd
_hd_keybd: ds.b 0
		link      a6,#-10
		cmpi.w    #0x011B,8(a6)
		bne.s     hd_key3
		dc.w      0xF584
		move.l    d0,-4(a6)
		beq.s     hd_key3
		move.l    -4(a6),(a7)
		addi.l    #28,(a7)
		movea.l   _thedesk,a0
		move.l    13736(a0),-(a7)
		dc.w      0xF39C ; streq
		addq.l    #4,a7
		tst.w     d0
		bne.s     hd_key2
		movea.l   -4(a6),a0
		movea.l   24(a0),a0
		move.b    8(a0),d0
		ext.w     d0
		move.w    d0,(a7)
		dc.w      0xF4E4
		tst.w     d0
		beq.s     hd_key1
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		movea.l   -4(a6),a0
		movea.l   24(a0),a0
		move.b    8(a0),d0
		ext.w     d0
		move.w    d0,(a7)
		addi.w    #0xFFBF,(a7)
		dc.w      0xF638
		move.w    d0,-6(a6)
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		tst.w     -6(a6)
		bne.s     hd_key3
		bra.s     hd_key2
hd_key1:
		bra.s     hd_key3
hd_key2:
		move.l    -4(a6),(a7)
		dc.w      0xF4C8
hd_key3:
		clr.w     d0
		dc.w      0xF001 ; movem.l (a7)+,#0

	xdef _hd_menu
_hd_menu: ds.b 0
		link      a6,#0
		movem.l   d3-d7/a5,-(a7)
		move.w    8(a6),d7
		move.w    10(a6),d6
		movea.l   _thedesk,a5
		clr.w     d5
		move.w    d7,d0
		bra       hd_men7

/* case DESKMENU */
hd_men1:
		cmp.w     #9,d6
		bne.s     hd_men2
		dc.w      0xF63C ; rb_start
		move.w    #9,(a7)
		movea.l   _thedesk,a0
		move.l    13666(a0),-(a7)
		dc.w      0xF53C
		addq.l    #4,a7
		dc.w      0xF640 ; rb_stop
hd_men2:
		bra       hd_men8

/* case FILEMENU */
hd_men3:
		move.w    d6,(a7)
		dc.w      0xF630 ; do_file
		move.w    d0,d5
		bra       hd_men8

/* case VIEWMENU */
hd_men4:
		move.w    d6,(a7)
		dc.w      0xF644
		move.w    d0,d5
		move.w    #1,(a7)
		dc.w      0xF094 ; desk_wait
		clr.w     d4
		bra.s     hd_men5
hd_men10:
		move.w    d4,d0
		muls.w    #238,d0
		add.l     _lp_mid,d0
		movea.l   d0,a0
		tst.w     6(a0)
		beq.s     hd_men9
		movea.l   _lp_mid,a0
		move.w    d4,d1
		muls.w    #238,d1
		movea.l   24(a0,d1.l),a0
		move.l    130(a0),(a7)
		move.w    #-1,-(a7)
		dc.w      0xF494
		addq.l    #2,a7
		move.l    d0,-(a7)
		movea.l   _lp_mid,a0
		move.w    d4,d1
		muls.w    #238,d1
		movea.l   24(a0,d1.l),a0
		move.l    (a7)+,130(a0)
hd_men9:
		addq.w    #1,d4
hd_men5:
		cmp.w     #4,d4
		blt.s     hd_men10
		dc.w      0xF648
		clr.w     (a7)
		dc.w      0xF094 ; desk_wait
		bra.s     hd_men8

/* case OPTNMENU */
hd_men6:
		move.w    d6,(a7)
		dc.w      0xF64C ; do_opt
		move.w    d0,d5
		bra.s     hd_men8
hd_men7:
		cmp.w     #3,d0
		beq       hd_men1
		cmp.w     #4,d0
		beq       hd_men3
		cmp.w     #5,d0
		beq       hd_men4
		cmp.w     #6,d0
		beq.s     hd_men6
hd_men8:
		move.w    #1,(a7)
		move.w    d7,-(a7)
		move.l    13654(a5),-(a7)
		dc.w      0xF650 ; menu_tnormal
		addq.l    #6,a7
		move.w    d5,d0
		dc.w      0xF83D ; movem.l (a7)+,d4-d7/a5

	xdef _hd_msg
_hd_msg: ds.b 0
		link      a6,#-8
		movem.l   d5-d7/a4-a5,-(a7)
		movea.l   _thedesk,a4
		clr.w     d6
		move.w    d6,d7
		move.w    13350(a4),d0
		bra.s     hd_msg2
hd_msg1:
		move.w    13720(a4),(a7)
		dc.w      0xF444 ; _hd_win
		bra.s     hd_msg3
hd_msg2:
		sub.w     #20,d0
		cmp.w     #8,d0
		bhi.s     hd_msg3
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb276,a0
		movea.l   (a0),a0
		jmp       (a0)
hd_msg3:
		move.w    13350(a4),d0
		bra       hd_msg16

/* case MN_SELECTED */
hd_msg4:
		clr.w     (a7)
		move.w    13722(a4),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		move.l    13356(a4),-(a7)
		dc.w      0xF654 ; hd_menu
		addq.l    #4,a7
		move.w    d0,d7
		bra       hd_msg17

/* case WM_REDRAW */
hd_msg5:
		tst.w     13356(a4)
		beq.s     hd_msg6
		move.l    13362(a4),-(a7)
		move.l    13358(a4),-(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF2C0 ; do_redraw
		adda.w    #10,a7
hd_msg6:
		bra       hd_msg17

/* case WM_TOPPED */
hd_msg7:
		clr.l     (a7)
		clr.l     -(a7)
		move.w    #10,-(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF4B8 ; wind_set
		addq.l    #8,a7
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    #4,-(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF5C8 ; wind_get
		adda.w    #20,a7
		move.w    13356(a4),(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.l    a5,(a7)
		dc.w      0xF58C
		clr.w     (a7)
		move.w    6(a5),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		move.w    6(a5),13722(a4)
		bra       hd_msg17

/* case WM_CLOSED */
hd_msg8:
		move.w    #22,(a7)
		dc.w      0xF630 ; do_file
		bra       hd_msg17

/* case WM_FULLED */
hd_msg9:
		move.w    13356(a4),(a7)
		dc.w      0xF658
		move.w    #1,(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		moveq.l   #1,d6
		bra       hd_msg17

/* case WM_ARROWED */
hd_msg10:
		move.l    13356(a4),-(a7)
		dc.w      0xF65C
		addq.l    #4,a7
		bra       hd_msg17

/* case WM_HSLID */
hd_msg11:
		clr.w     (a7)
		move.l    13356(a4),-(a7)
		dc.w      0xF660 ; srl_bar
		addq.l    #4,a7
		bra       hd_msg17

/* caes WM_VSLID */
hd_msg12:
		move.w    #1,(a7)
		move.l    13356(a4),-(a7)
		dc.w      0xF660 ; srl_bar
		addq.l    #4,a7
		bra       hd_msg17

/* case WM_SIZED */
/* case WM_MOVED */
hd_msg13:
		move.w    13358(a4),-2(a6)
		move.w    13360(a4),-4(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		dc.w      0xF568
		addq.l    #8,a7
		move.w    13362(a4),-6(a6)
		move.w    13364(a4),-8(a6)
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		move.w    #5,-(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF4B8 ; wind_set
		adda.w    #10,a7
		cmpi.w    #27,13350(a4)
		bne.s     hd_msg14
		move.w    #1,(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF4B0
		addq.l    #2,a7
		bra.s     hd_msg15
hd_msg14:
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    #4,-(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF5C8 ; wind_get
		adda.w    #20,a7
		move.w    13356(a4),(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		move.l    a4,d0
		move.w    10(a5),d1
		muls.w    #24,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #24216,(a7)
		dc.w      0xF298 ; r_set
		adda.w    #10,a7
hd_msg15:
		moveq.l   #1,d6
		bra.s     hd_msg17
hd_msg16:
		sub.w     #10,d0
		cmp.w     #18,d0
		bhi.s     hd_msg17
		asl.w     #2,d0
		movea.w   d0,a0
		adda.l    #xfeb29a,a0
		movea.l   (a0),a0
		jmp       (a0)
/* default: */
hd_msg17:
		tst.w     d6
		beq.s     hd_msg18
		pea.l     -8(a6)
		pea.l     -6(a6)
		pea.l     -4(a6)
		pea.l     -2(a6)
		move.w    #5,-(a7)
		move.w    13356(a4),-(a7)
		dc.w      0xF5C8 ; wind_get
		adda.w    #20,a7
		move.w    13356(a4),(a7)
		dc.w      0xF2EC
		movea.l   d0,a5
		move.w    -8(a6),(a7)
		move.w    -6(a6),-(a7)
		move.w    -4(a6),-(a7)
		move.w    -2(a6),-(a7)
		pea.l     230(a5)
		dc.w      0xF298 ; r_set
		adda.w    #10,a7
hd_msg18:
		clr.w     13350(a4)
		move.l    13654(a4),(a7)
		dc.w      0xF634
		move.w    d7,d0
		dc.w      0xFC31 ; movem.l (a7)+,d6-d7/a4-a5


	xdef xfdba7e
xfdba7e: ds.b 0
		link      a6,#0
		movem.l   d5-d7/a3-a5,-(a7)
		movea.l   _thedesk,a3
		move.w    13724(a3),d0
		add.w     #-27,d0
		move.w    d0,23552(a3)
		move.w    13726(a3),d0
		add.w     #-30,d0
		move.w    d0,23550(a3)
		move.w    13728(a3),23554(a3)
		move.w    13730(a3),23556(a3)
		move.w    13732(a3),23558(a3)
		move.w    13734(a3),23562(a3)
		move.w    _gl_restype,d0
		subq.w    #1,d0
		move.w    d0,23560(a3)
		clr.w     d7
		bra.s     xfdba_2
xfdba_1:
		move.w    #8,(a7)
		move.w    d7,d0
		asl.w     #3,d0
		ext.l     d0
		add.l     #x007098,d0
		move.l    d0,-(a7)
		move.l    a3,d0
		move.w    d7,d1
		muls.w    #136,d1
		add.l     d1,d0
		move.l    d0,-(a7)
		addi.l    #23564,(a7)
		dc.w      0xF268 ; LBCOPY
		addq.l    #8,a7
		addq.w    #1,d7
xfdba_2:
		cmp.w     #4,d7
		blt.s     xfdba_1
		clr.w     d6
		clr.w     d7
		bra.s     xfdba_5
xfdba_3:
		move.w    d7,(a7)
		addq.w    #1,(a7)
		dc.w      0xF4A4
		movea.l   d0,a4
		tst.w     6(a4)
		beq.s     xfdba_4
		movea.l   a3,a5
		move.w    d6,d0
		muls.w    #136,d0
		adda.l    d0,a5
		adda.l    #23564,a5
		addq.w    #1,d6
		pea.l     6(a5)
		pea.l     4(a5)
		pea.l     2(a5)
		move.l    a5,-(a7)
		move.w    #5,-(a7)
		move.w    6(a4),-(a7)
		dc.w      0xF5C8 ; wind_get
		adda.w    #20,a7
		pea.l     2(a5)
		move.l    a5,-(a7)
		dc.w      0xF568
		addq.l    #8,a7
		move.w    12(a4),8(a5)
		move.w    14(a4),10(a5)
		move.w    8(a4),12(a5)
		pea.l     14(a5)
		move.l    24(a4),-(a7)
		addq.l    #8,(a7)
		dc.w      0xF36C ; xstrpcpy
		addq.l    #8,a7
xfdba_4:
		addq.w    #1,d7
xfdba_5:
		cmp.w     #4,d7
		blt.s     xfdba_3
		bra.s     xfdba_7
xfdba_6:
		movea.l   a3,a5
		move.w    d6,d0
		muls.w    #136,d0
		adda.l    d0,a5
		adda.l    #23564,a5
		clr.b     14(a5)
		clr.w     12(a5)
		addq.w    #1,d6
xfdba_7:
		cmp.w     #4,d6
		blt.s     xfdba_6
		dc.w      0xFE31 ; movem.l (a7)+,d6-d7/a3-a5

	xdef xfdbb94
xfdbb94: ds.b 0
		link      a6,#-14
		movem.l   d6-d7/a3-a5,-(a7)
		movea.l   _thedesk,a3
		move.w    23552(a3),(a7)
		addi.w    #27,(a7)
		dc.w      0xF644
		move.w    23550(a3),(a7)
		addi.w    #30,(a7)
		dc.w      0xF644
		move.w    23554(a3),13728(a3)
		move.w    23556(a3),13730(a3)
		move.w    23558(a3),13732(a3)
		move.w    23562(a3),13734(a3)
		move.w    #1,(a7)
		move.w    #3,-(a7)
		dc.w      0xF664 ; evnt_dclick
		addq.l    #2,a7
		clr.w     d7
		bra       xfdbb_4
xfdbb_1:
		movea.l   a3,a5
		move.w    d7,d0
		muls.w    #136,d0
		adda.l    d0,a5
		adda.l    #23564,a5
		tst.b     14(a5)
		beq       xfdbb_3
		move.w    12(a5),(a7)
		dc.w      0xF59C
		movea.l   d0,a4
		move.l    a4,d0
		beq.s     xfdbb_3
		move.w    8(a5),12(a4)
		move.w    10(a5),14(a4)
		pea.l     -14(a6)
		pea.l     -10(a6)
		pea.l     12982(a3)
		pea.l     -2(a6)
		pea.l     14(a5)
		dc.w      0xF5AC
		adda.w    #20,a7
		pea.l     2(a5)
		move.l    a5,-(a7)
		dc.w      0xF568
		addq.l    #8,a7
		pea.l     12982(a3)
		move.w    -2(a6),-(a7)
		dc.w      0xF5A0
		addq.l    #6,a7
		tst.w     _DOS_ERR
		bne.s     xfdbb_2
		move.w    -2(a6),(a7)
		dc.w      0xF4E4
		tst.w     d0
		beq.s     xfdbb_2
		move.l    a5,(a7)
		pea.l     -14(a6)
		pea.l     -10(a6)
		pea.l     12982(a3)
		move.w    -2(a6),-(a7)
		move.w    12(a5),-(a7)
		move.w    #1,-(a7)
		move.l    a4,-(a7)
		dc.w      0xF5A4
		adda.w    #22,a7
		bra.s     xfdbb_3
xfdbb_2:
		move.l    a4,(a7)
		dc.w      0xF5A8
xfdbb_3:
		addq.w    #1,d7
xfdbb_4:
		cmp.w     #4,d7
		blt       xfdbb_1
		dc.w      0xF618
		dc.w      0xFE21 ; movem.l (a7)+,d7/a3-a5

	data

xfeb1c0: dc.b 25,36,0,0

xfeb1c4: dc.b 20,24,29,37,0,0

xfeb1ca: dc.b 25,35,0,0

xfeb1ce: dc.b 25,35,36,0

xfeb1d2: dc.b 36,0

xfeb1d4: dc.b 18,25,35,36,35,0

xfeb1da: dc.b 18,19,25,35,36,0

xfeb1e0: dc.b 21,22,23,0

xfeb1e4: dc.b 21,22,23,27,28,30,31,32,33,0

xfeb1ee: dc.b 18,35,25,19,0,0

xfeb1f4: dc.b 19,21,25,36,0,0

xfeb1fa: dc.b 21,0

	xdef xfeb1fc
xfeb1fc:
	dc.w 9,18,27,35,0


xfeb206:
		dc.l xfdb1_5
		dc.l xfdb1_7
		dc.l xfdb1_9
		dc.l xfdb1_11
		dc.l xfdb1_8

xfeb21a:
		dc.l do_fil1
		dc.l do_fil3
		dc.l do_fil13
		dc.l do_fil5
		dc.l do_fil6
		dc.l do_fil8
		dc.l do_fil13
		dc.l do_fil10

xfeb23a:
		dc.l xfdb3_1
		dc.l xfdb3_2
		dc.l xfdb3_8
		dc.l xfdb3_3
		dc.l xfdb3_4
		dc.l xfdb3_5
		dc.l xfdb3_6

xfeb256:
		dc.l do_opt2
		dc.l do_opt4
		dc.l do_opt17
		dc.l do_opt6
		dc.l do_opt7
		dc.l do_opt9
		dc.l do_opt17
		dc.l do_opt11

xfeb276:
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1
		dc.l hd_msg1

xfeb29a:
		dc.l hd_msg4
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg17
		dc.l hd_msg5
		dc.l hd_msg7
		dc.l hd_msg8
		dc.l hd_msg9
		dc.l hd_msg10
		dc.l hd_msg11
		dc.l hd_msg12
		dc.l hd_msg13
		dc.l hd_msg13
