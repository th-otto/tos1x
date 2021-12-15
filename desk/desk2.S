    xdef _xfd9922
_xfd9922: ds.b 0
        link      a6,#-2
        movem.l   d7/a3-a5,-(a7)
        movea.l   16(a6),a5
        movea.l   20(a6),a4
        move.l    _thedesk,(a7)
        addi.l    #12982,(a7)
        move.l    12(a6),-(a7)
        jsr _xstrpcpy
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
        jsr _xstrpcpy
        addq.l    #4,a7
        movea.l   d0,a3
        pea.l     -1(a3)
        move.l    #_wilds,-(a7)
        jsr _xstrpcpy
        addq.l    #8,a7
        bra.s     xfd99_4
xfd99_3:
        move.l    a3,(a7)
        move.l    #_getall,-(a7)
        jsr _xstrpcat
        addq.l    #4,a7
xfd99_4:
        move.l    #x00634c,(a7)
        move.l    _thedesk,-(a7)
        addi.l    #12982,(a7)
        jsr _xstrpcpy
        addq.l    #4,a7
        move.l    8(a6),(a7)
        move.w    #2,-(a7)
        jsr       _fun_op
        addq.l    #2,a7
        move.w    d0,-2(a6)
        tst.w     -2(a6)
        beq.s     xfd99_5
        move.w    #1,(a7)
        move.l    #x00634c,-(a7)
        jsr _up_allwin
        addq.l    #4,a7
        move.w    #1,(a7)
        move.l    8(a6),-(a7)
        addq.l    #8,(a7)
        jsr _up_allwin
        addq.l    #4,a7
xfd99_5:
        move.w    -2(a6),d0
        dc.w      $FE01

    xdef _xfd99e0
_xfd99e0: ds.b 0
        link      a6,#-12
        clr.l     (a7)
        clr.l     -(a7)
        move.w    10(a6),-(a7)
        clr.w     -(a7)
        move.w    #1,-(a7)
        jsr       _xfd5b36
        adda.w    #10,a7
        move.l    d0,-8(a6)
        move.w    8(a6),(a7)
        jsr       _xfdc3f4
        move.l    d0,-4(a6)
        movea.l   _thedesk,a0
        move.l    13736(a0),(a7)
        move.l    -4(a6),-(a7)
        addi.l    #28,(a7)
        jsr _streq
        addq.l    #4,a7
        tst.w     d0
        beq.s     xfd99e_5
        movea.l   -8(a6),a0
        move.w    6(a0),d0
        bra.s     xfd99e_3
xfd99e_1:
        clr.l     (a7)
        move.l    #$00010018,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        bra.s     xfd99e_4
xfd99e_2:
        move.w    #5,(a7)
        jsr _form_error
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
        jsr       _fun_wdst
        addq.l    #8,a7
xfd99e_6:
        dc.w      $F001

    xdef _xfd9a6c
_xfd9a6c: ds.b 0
        link      a6,#-4
        movem.l   d6-d7/a4-a5,-(a7)
        move.w    8(a6),(a7)
        move.l    _thedesk,-(a7)
        addi.l    #24200,(a7)
        jsr       _get_spec
        addq.l    #4,a7
        move.l    d0,-4(a6)
        movea.l   -4(a6),a0
        move.w    12(a0),(a7)
        jsr       _xfdadb6
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
        jsr       _pn_open
        adda.w    #14,a7
        movea.l   d0,a4
        move.l    a4,d0
        beq.s     xfd9a_7
        move.l    a4,(a7)
        jsr       _pn_folder
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
        jsr       _xfd9922
        adda.w    #12,a7
        move.w    d0,d7
        bra.s     xfd9a_5
xfd9a_4:
        move.w    22(a6),(a7)
        move.l    14(a6),-(a7)
        move.l    a4,-(a7)
        jsr       _fun_wdst
        addq.l    #8,a7
        move.w    d0,d7
xfd9a_5:
        movea.l   _thedesk,a0
        clr.w     24210(a0)
xfd9a_6:
        move.l    a4,(a7)
        jsr       _pn_free
        clr.w     (a7)
        jsr _hd_win
xfd9a_7:
        move.w    d7,d0
xfd9a_8:
        dc.w      $FC21

    xdef _xfd9b3c
_xfd9b3c: ds.b 0
        link      a6,#-10
        movem.l   d5-d7/a3-a5,-(a7)
        move.w    10(a6),d7
        move.w    8(a6),(a7)
        jsr       _xfdc3f4
        movea.l   d0,a5
        pea.l     -6(a6)
        pea.l     -4(a6)
        move.w    d7,-(a7)
        move.w    8(a6),-(a7)
        jsr       _xfdb04c
        adda.w    #12,a7
        movea.l   d0,a3
        clr.w     d6
        bra.s     xfd9b3_3
xfd9b3_4:
        pea.l     -6(a6)
        pea.l     -10(a6)
        move.w    d6,-(a7)
        clr.w     -(a7)
        jsr       _xfdb04c
        adda.w    #12,a7
        movea.l   d0,a4
        cmpi.w    #3,6(a4)
        bne.s     xfd9b3_1
        clr.l     (a7)
        move.l    #$00010014,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        bra.s     xfd9b3_3
xfd9b3_1:
        cmpi.w    #4,6(a4)
        bne.s     xfd9b3_2
        clr.l     (a7)
        move.l    #$00010018,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        bra.s     xfd9b3_3
xfd9b3_2:
        move.w    d7,(a7)
        move.l    -4(a6),-(a7)
        move.l    a3,-(a7)
        move.l    a5,-(a7)
        move.w    d6,-(a7)
        jsr       _xfd9a6c
        adda.w    #14,a7
        tst.w     d0
        beq.s     xfd9b3_3
        move.l    a5,(a7)
        jsr       _up_1win
xfd9b3_3:
        move.w    d6,(a7)
        move.w    #1,-(a7)
        move.l    _thedesk,-(a7)
        addi.l    #24200,(a7)
        jsr       _xfdcd06
        addq.l    #6,a7
        move.w    d0,d6
        bne       xfd9b3_4
        dc.w      $FE31

    xdef _xfd9be0
_xfd9be0: ds.b 0
        link      a6,#-52
        movem.l   d7/a3-a5,-(a7)
        movea.l   _thedesk,a3
        clr.w     -48(a6)
        clr.l     (a7)
        clr.l     -(a7)
        move.w    8(a6),-(a7)
        clr.w     -(a7)
        move.w    #1,-(a7)
        jsr       _xfd5b36
        adda.w    #10,a7
        movea.l   d0,a4
        clr.w     -2(a6)
        bra       xfd9b_13
xfd9b_1:
        pea.l     -4(a6)
        pea.l     -8(a6)
        move.w    -2(a6),-(a7)
        clr.w     -(a7)
        jsr       _xfdb04c
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
        move.l    #$00010010,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        clr.w     d0
        bra       xfd9b_14
        bra       xfd9b_13
xfd9b_3:
        move.w    6(a4),d0
        bra       xfd9b_12
xfd9b_4:
        clr.l     (a7)
        move.l    #$00010011,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        clr.w     d0
        bra       xfd9b_14
xfd9b_5:
        clr.l     (a7)
        move.l    #$00010018,-(a7)
xfd9b_6:
        jsr _fun_alert
        addq.l    #4,a7
        clr.w     d0
        bra       xfd9b_14
xfd9b_7:
        bra       xfd9b_13
xfd9b_8:
        move.w    -2(a6),(a7)
        pea.l     24200(a3)
        jsr       _get_spec
        addq.l    #4,a7
        move.l    d0,-16(a6)
        move.w    8(a6),(a7)
        pea.l     24200(a3)
        jsr       _get_spec
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
        move.l    #$00010021,-(a7)
        jsr _fun_alert
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
        move.l    #$00020012,-(a7)
        jsr _fun_alert
        addq.l    #8,a7
        cmp.w     #1,d0
        bne.s     xfd9b_11
        move.w    #$00FB,(a7)
        pea.l     -34(a6)
        jsr _fc_start
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
        jsr       _xfdcd06
        addq.l    #6,a7
        move.w    d0,-2(a6)
        bne       xfd9b_1
        move.w    -48(a6),d0
xfd9b_14:
        dc.w      $FE01

    xdef _xfd9d76
_xfd9d76: ds.b 0
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
        jsr       _xfdc3f4
        movea.l   d0,a5
        move.w    d6,(a7)
        jsr       _xfdc3f4
        movea.l   d0,a4
        movea.l   _thedesk,a0
        move.l    13736(a0),(a7)
        pea.l     28(a5)
        jsr _streq
        addq.l    #4,a7
        tst.w     d0
        bne.s     xfd9d_1
        movea.l   _thedesk,a0
        move.l    13736(a0),(a7)
        pea.l     28(a4)
        jsr _streq
        addq.l    #4,a7
        tst.w     d0
        beq.s     xfd9d_2
xfd9d_1:
        clr.l     (a7)
        move.l    #$00010018,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        bra.s     xfd9d_3
xfd9d_2:
        pea.l     -4(a6)
        pea.l     -8(a6)
        move.w    d4,-(a7)
        move.w    d6,-(a7)
        jsr       _xfdb04c
        adda.w    #12,a7
        movea.l   d0,a3
        move.l    -8(a6),(a7)
        move.l    a3,-(a7)
        move.l    24(a4),-(a7)
        addq.l    #8,(a7)
        move.l    24(a5),-(a7)
        jsr       _xfd9922
        adda.w    #12,a7
        tst.w     d0
        beq.s     xfd9d_3
        cmp.w     d6,d7
        beq.s     xfd9d_3
        move.w    d7,(a7)
        jsr _hd_win
xfd9d_3:
        bra.s     xfd9d_6
xfd9d_4:
        cmp.w     d5,d4
        bne.s     xfd9d_5
        clr.l     (a7)
        move.l    #$00010013,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        bra.s     xfd9d_6
xfd9d_5:
        move.w    d4,(a7)
        move.w    d7,-(a7)
        jsr       _xfd99e0
        addq.l    #2,a7
xfd9d_6:
        bra.s     xfd9d_9
xfd9d_7:
        tst.w     d6
        beq.s     xfd9d_8
        move.w    d4,(a7)
        move.w    d6,-(a7)
        jsr       _xfd9b3c
        addq.l    #2,a7
        bra.s     xfd9d_9
xfd9d_8:
        cmp.w     d5,d4
        beq.s     xfd9d_9
        move.w    d4,(a7)
        jsr       _xfd9be0
        move.w    d0,-2(a6)
xfd9d_9:
        move.w    -2(a6),d0
        dc.w      $FE3D

    xdef _xfd9e58
_xfd9e58: ds.b 0
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
        jsr _r_set
        adda.w    #12,a7
        move.w    d7,d0
        addq.w    #1,d0
        bra.s     xfd9e5_5
        bra.s     xfd9e5_5
xfd9e5_4:
        clr.w     d0
xfd9e5_5:
        dc.w      $F821

    xdef _xfd9eca
_xfd9eca: ds.b 0
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
        jsr _r_set
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
        dc.w      $F831

    xdef _xfd9f56
_xfd9f56: ds.b 0
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
        jsr _objc_add
        addq.l    #6,a7
        move.l    14(a6),-(a7)
        move.l    10(a6),-(a7)
        move.l    a5,d0
        move.w    d7,d1
        muls.w    #24,d1
        add.l     d1,d0
        move.l    d0,-(a7)
        addi.l    #24216,(a7)
        jsr _r_set
        adda.w    #12,a7
        move.w    d7,d0
        bra.s     xfd9f_5
        bra.s     xfd9f_5
xfd9f_4:
        clr.w     d0
xfd9f_5:
        dc.w      $F821

    xdef _xfd9fde
_xfd9fde: ds.b 0
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
        move.b    #92,256(a5)
        pea.l     257(a5)
        move.l    10(a6),-(a7)
        jsr _xstrpcpy
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
        addi.w    #$FFBF,(a7)
        jsr _do_cdir
        addq.l    #6,a7
xfd9fd_7:
        moveq.l   #1,d0
xfd9fd_8:
        dc.w      $F821

    xdef _xfda066
_xfda066: ds.b 0
        link      a6,#-4
        movem.l   d7/a5,-(a7)
        movea.l   _thedesk,a5
        tst.b     13518(a5)
        bne.s     xfda06_1
        move.l    a5,(a7)
        addi.l    #13519,(a7)
        jsr _strlen
        move.w    d0,-4(a6)
        move.b    d0,13518(a5)
        movea.l   a5,a0
        movea.w   -4(a6),a1
        adda.l    a1,a0
        move.b    #13,13519(a0)
xfda06_1:
        move.w    #1,(a7)
        jsr _desk_wait
        move.l    13646(a5),(a7)
        move.l    13514(a5),-(a7)
        move.l    8(a6),-(a7)
        move.w    #1,-(a7)
        jsr _shel_write
        adda.w    #10,a7
        move.w    d0,-2(a6)
        clr.b     13518(a5)
        cmpi.w    #-1,12(a6)
        beq.s     xfda06_2
        move.l    13374(a5),-(a7)
        move.l    13370(a5),-(a7)
        move.l    12(a6),-(a7)
        clr.w     -(a7)
        jsr       _xfda2fa
        adda.w    #14,a7
xfda06_2:
        move.w    -2(a6),d0
        dc.w      $F801

    xdef _hd_win
_hd_win: ds.b 0
        link      a6,#-8
        movem.l   d5-d7/a5,-(a7)
        move.w    8(a6),d7
        pea.l     -8(a6)
        move.w    #4,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #8,a7
        tst.w     d7
        beq.s     hd_win1
        move.w    d7,(a7)
        jsr       _xfdc3f4
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
        jsr       _xfd6452
        adda.w    #24,a7
        dc.w      $F831

    xdef _xfda13c
_xfda13c: ds.b 0
        link      a6,#-8
        movem.l   d5-d7/a4-a5,-(a7)
        move.w    8(a6),d7
        move.w    10(a6),d6
        movea.l   _thedesk,a4
        tst.w     d7
        beq.s     xfda13_2
        move.w    d7,(a7)
        jsr       _xfdc3f4
        movea.l   d0,a5
        tst.w     d6
        beq.s     xfda13_1
        pea.l     -8(a6)
        move.w    #4,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #8,a7
        move.l    -4(a6),-(a7)
        move.l    -8(a6),-(a7)
        move.l    a5,-(a7)
        jsr       _xfdc652
        adda.w    #12,a7
xfda13_1:
        move.w    10(a5),13718(a4)
        bra.s     xfda13_3
xfda13_2:
        move.w    #1,13718(a4)
xfda13_3:
        move.w    d7,13720(a4)
        dc.w      $FC31

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
        jsr       _xfdc3f4
        movea.l   d0,a5
        move.w    10(a5),d5
        bra.s     do_red2
do_red1:
        moveq.l   #1,d5
do_red2:
        clr.l     (a7)
        move.w    #256,-(a7)
        jsr _graf_mouse
        addq.l    #2,a7
        move.l    a4,(a7)
        move.w    #11,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #4,a7
        bra.s     do_red5
do_red3:
        move.l    a4,(a7)
        pea.l     10(a6)
        jsr _rc_intersect
        addq.l    #4,a7
        tst.w     d0
        beq.s     do_red4
        move.l    a4,(a7)
        move.l    #_gl_rscreen,-(a7)
        jsr _rc_intersect
        addq.l    #4,a7
        tst.w     d0
        beq.s     do_red4
        move.l    4(a4),-(a7)
        move.l    (a4),-(a7)
        move.w    #8,-(a7)
        move.w    d5,-(a7)
        move.l    d6,-(a7)
        jsr _objc_draw
        adda.w    #16,a7
do_red4:
        move.l    a4,(a7)
        move.w    #12,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #4,a7
do_red5:
        tst.w     4(a4)
        beq.s     do_red6
        tst.w     6(a4)
        bne.s     do_red3
do_red6:
        clr.l     (a7)
        move.w    #257,-(a7)
        jsr _graf_mouse
        addq.l    #2,a7
        dc.w      $FC39

    xdef _xfda22c
_xfda22c: ds.b 0
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
        dc.w      $F021

    xdef _get_spec
_get_spec: ds.b 0
        link      a6,#-4
        movea.l   8(a6),a0
        move.w    12(a6),d1
        muls.w    #24,d1
        move.l    12(a0,d1.l),d0
        dc.w      $F001

    xdef _xfda2a0
_xfda2a0: ds.b 0
        link      a6,#-8
        movem.l   d7/a4-a5,-(a7)
        movea.l   8(a6),a5
        movea.l   12(a6),a4
        pea.l     -8(a6)
        move.w    #4,-(a7)
        clr.w     -(a7)
        jsr _wind_grget
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
        jsr _max
        addq.l    #2,a7
        move.w    d0,(a4)
        dc.w      $FC01

    xdef _xfda2fa
_xfda2fa: ds.b 0
        link      a6,#-16
        movem.l   d4-d7/a3-a5,-(a7)
        move.w    8(a6),d7
        move.w    10(a6),d6
        move.w    12(a6),d5
        lea.l     -16(a6),a3
        movea.l   _thedesk,a4
        pea.l     16(a6)
        pea.l     14(a6)
        jsr       _xfda2a0
        addq.l    #8,a7
        pea.l     -8(a6)
        pea.l     -6(a6)
        pea.l     -4(a6)
        pea.l     -2(a6)
        move.w    d5,-(a7)
        pea.l     24200(a4)
        jsr       _xfda22c
        adda.w    #22,a7
        pea.l     6(a3)
        pea.l     4(a3)
        pea.l     2(a3)
        move.l    a3,-(a7)
        move.w    13718(a4),-(a7)
        pea.l     24200(a4)
        jsr       _xfda22c
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
        jsr _graf_growbox
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
        jsr       _xfd637e
        adda.w    #20,a7
        tst.w     d7
        beq.s     xfda2f_2
        move.l    18(a6),-(a7)
        move.l    14(a6),-(a7)
        move.w    d6,-(a7)
        jsr _wind_open
        adda.w    #10,a7
xfda2f_2:
        move.w    d6,13722(a4)
        dc.w      $FE39

    xdef _xfda3de
_xfda3de: ds.b 0
        link      a6,#-8
        movem.l   d5-d7/a5,-(a7)
        move.w    8(a6),d7
        move.w    10(a6),d6
        movea.l   _thedesk,a5
        pea.l     -8(a6)
        move.w    #4,-(a7)
        move.w    d6,-(a7)
        jsr _wind_grget
        addq.l    #8,a7
        tst.w     d7
        beq.s     xfda3_1
        move.w    d6,(a7)
        jsr _wind_close
xfda3_1:
        move.l    -4(a6),-(a7)
        move.l    -8(a6),-(a7)
        move.l    13820(a5),-(a7)
        move.l    12(a6),-(a7)
        jsr _graf_shrinkbox
        adda.w    #16,a7
        dc.w      $F831

    xdef _xfda422
_xfda422: ds.b 0
        link      a6,#-24
        movem.l   d6-d7/a3-a5,-(a7)
        move.w    8(a6),d7
        lea.l     -8(a6),a5
        lea.l     -16(a6),a4
        lea.l     -24(a6),a3
        move.l    a5,(a7)
        move.w    #5,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #4,a7
        move.l    a4,(a7)
        move.w    #6,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #4,a7
        move.l    a3,(a7)
        move.w    #7,-(a7)
        move.w    d7,-(a7)
        jsr _wind_grget
        addq.l    #4,a7
        move.l    a3,(a7)
        move.l    a5,-(a7)
        jsr _rc_equal
        addq.l    #4,a7
        tst.w     d0
        beq.s     xfda42_1
        move.l    4(a4),-(a7)
        move.l    (a4),-(a7)
        move.w    #5,-(a7)
        move.w    d7,-(a7)
        jsr _wind_set
        adda.w    #12,a7
        move.l    4(a3),-(a7)
        move.l    (a3),-(a7)
        move.l    4(a4),-(a7)
        move.l    (a4),-(a7)
        jsr _graf_shrinkbox
        adda.w    #16,a7
        bra.s     xfda42_2
xfda42_1:
        move.l    4(a3),-(a7)
        move.l    (a3),-(a7)
        move.l    4(a5),-(a7)
        move.l    (a5),-(a7)
        jsr _graf_growbox
        adda.w    #16,a7
        move.l    4(a3),-(a7)
        move.l    (a3),-(a7)
        move.w    #5,-(a7)
        move.w    d7,-(a7)
        jsr _wind_set
        adda.w    #12,a7
xfda42_2:
        dc.w      $FE21

    xdef _xfda4b6
_xfda4b6: ds.b 0
        link      a6,#-4
        movem.l   d4-d7/a4-a5,-(a7)
        movea.l   8(a6),a5
        move.w    12(a6),d7
        move.w    14(a6),d6
        move.w    16(a6),d5
        movea.l   30(a6),a4
        move.w    #1,(a7)
        jsr _desk_wait
        move.w    #16,(a7)
        move.l    26(a6),-(a7)
        move.l    22(a6),-(a7)
        move.l    18(a6),-(a7)
        move.w    d5,-(a7)
        jsr       _pn_open
        adda.w    #14,a7
        move.l    d0,-4(a6)
        tst.l     -4(a6)
        bne.s     xfda4_3
        clr.l     (a7)
        move.l    #$00010017,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        jsr       _xfdc47a
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
        jsr       _xfda13c
        addq.l    #2,a7
        bra       xfda4_8
        bra.s     xfda4_4
xfda4_3:
        move.l    -4(a6),24(a5)
xfda4_4:
        move.l    24(a5),(a7)
        jsr       _pn_folder
        cmp.w     #99,d5
        bne.s     xfda4_5
        pea.l     28(a5)
        movea.l   _thedesk,a0
        move.l    13736(a0),-(a7)
        jsr _xstrpcpy
        addq.l    #8,a7
        bra.s     xfda4_6
xfda4_5:
        move.l    a5,(a7)
        jsr       _xfdcdec
xfda4_6:
        move.l    a5,(a7)
        jsr       _xfdcd94
        clr.l     (a7)
        pea.l     28(a5)
        move.w    #2,-(a7)
        move.w    6(a5),-(a7)
        jsr _wind_set
        addq.l    #8,a7
        clr.l     (a7)
        pea.l     149(a5)
        move.w    #3,-(a7)
        move.w    6(a5),-(a7)
        jsr _wind_set
        addq.l    #8,a7
        tst.w     d6
        ble.s     xfda4_7
        move.l    4(a4),-(a7)
        move.l    (a4),-(a7)
        move.w    d6,-(a7)
        move.w    6(a5),-(a7)
        move.w    d7,-(a7)
        jsr       _xfda2fa
        adda.w    #14,a7
        tst.w     d7
        beq.s     xfda4_7
        move.l    a5,(a7)
        jsr       _xfdc430
xfda4_7:
        move.w    #1,(a7)
        move.w    6(a5),-(a7)
        jsr       _xfda13c
        addq.l    #2,a7
        tst.w     d7
        bne.s     xfda4_8
        move.l    4(a4),-(a7)
        move.l    (a4),-(a7)
        move.w    6(a5),-(a7)
        jsr _do_redraw
        adda.w    #10,a7
xfda4_8:
        clr.w     (a7)
        jsr _desk_wait
        moveq.l   #1,d0
        dc.w      $FC39

    xdef _xfda5d2
_xfda5d2: ds.b 0
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
        jsr       _xfda22c
        adda.w    #22,a7
        pea.l     -16(a6)
        pea.l     -14(a6)
        pea.l     -12(a6)
        pea.l     -10(a6)
        move.w    13718(a4),-(a7)
        pea.l     24200(a4)
        jsr       _xfda22c
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
        jsr _xstrpcpy
        addq.l    #8,a7
        pea.l     13386(a4)
        move.l    a3,-(a7)
        jsr _xstrpcpy
        addq.l    #8,a7
        move.l    8(a6),(a7)
        jsr       _xfdc430
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
        jsr       _inf_setsize
        adda.w    #14,a7
        move.l    #xfeb1ac,(a7)
        move.w    #3,-(a7)
        move.l    d6,-(a7)
        jsr _inf_sset
        addq.l    #6,a7
        move.w    #3,(a7)
        move.l    d6,-(a7)
        jsr _xform_do
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
        jsr _fs_sget
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
        jsr _xstrpcat
        addq.l    #4,a7
        movea.l   22(a6),a0
        tst.b     (a0)
        beq.s     xfda5_7
        move.l    a3,(a7)
        move.l    22(a6),-(a7)
        jsr _xstrpcat
        addq.l    #4,a7
        move.l    a3,(a7)
        move.l    #xfeb1b1,-(a7)
        jsr _xstrpcat
        addq.l    #4,a7
xfda5_7:
        move.l    a3,(a7)
        move.l    26(a6),-(a7)
        jsr _xstrpcat
        addq.l    #4,a7
xfda5_8:
        bra       xfda5_12
xfda5_9:
        clr.l     (a7)
        move.l    #$0001000C,-(a7)
        jsr _fun_alert
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
        jsr _graf_mouse
        addq.l    #2,a7
        move.w    #3,(a7)
        jsr _gsx_escapes
        clr.w     (a7)
        move.l    26(a6),-(a7)
        jsr _showfile
        addq.l    #4,a7
        move.w    #2,(a7)
        jsr _gsx_escapes
        clr.l     (a7)
        move.w    #257,-(a7)
        jsr _graf_mouse
        addq.l    #2,a7
        moveq.l   #1,d0
        bra       xfda5_16
        bra.s     xfda5_12
xfda5_11:
        move.l    13706(a4),d6
        pea.l     24132(a4)
        move.l    26(a6),-(a7)
        jsr _fmt_str
        addq.l    #8,a7
        pea.l     24132(a4)
        move.w    #1,-(a7)
        move.l    d6,-(a7)
        jsr _inf_sset
        adda.w    #10,a7
        move.w    #1,(a7)
        jsr _desk_wait
        move.l    d6,(a7)
        jsr _fm_draw
        move.w    #1,(a7)
        move.l    26(a6),-(a7)
        jsr _showfile
        addq.l    #4,a7
        move.l    d6,(a7)
        jsr _do_finish
        clr.w     (a7)
        jsr _desk_wait
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
        jsr _xstrpcpy
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
        jsr       _xfda066
        addq.l    #6,a7
        bra.s     xfda5_16
xfda5_15:
        clr.w     d0
xfda5_16:
        dc.w      $FE31

    xdef _xfda85e
_xfda85e: ds.b 0
        link      a6,#0
        movem.l   d5-d7/a3-a5,-(a7)
        move.w    8(a6),d7
        movea.l   _thedesk,a3
        move.w    d7,(a7)
        pea.l     24200(a3)
        jsr       _get_spec
        addq.l    #4,a7
        movea.l   d0,a4
        move.w    #1,(a7)
        jsr _desk_wait
        move.w    12(a4),d6
        and.w     #255,d6
        move.w    d7,(a7)
        jsr       _xfdc2a6
        movea.l   d0,a5
        move.l    a5,d0
        beq.s     xfda8_4
        move.w    d6,(a7)
        jsr       _xfdadb6
        tst.w     d0
        beq.s     xfda8_2
        cmp.w     #99,d6
        beq.s     xfda8_1
        move.l    #xfeb1b3,(a7)
        move.w    d6,-(a7)
        jsr       _xfd9fde
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
        jsr       _xfda4b6
        adda.w    #22,a7
        bra.s     xfda8_3
xfda8_2:
        move.l    a5,(a7)
        jsr       _xfdc376
xfda8_3:
        bra.s     xfda8_5
xfda8_4:
        clr.l     (a7)
        move.l    #$0001000D,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
xfda8_5:
        clr.w     (a7)
        jsr _desk_wait
        clr.w     d0
        dc.w      $FE31

    xdef _xfda900
_xfda900: ds.b 0
        link      a6,#-10
        movem.l   d7/a4-a5,-(a7)
        movea.l   8(a6),a5
        lea.l     -10(a6),a4
        move.l    a4,(a7)
        move.w    #4,-(a7)
        move.w    6(a5),-(a7)
        jsr _wind_grget
        addq.l    #4,a7
        move.w    #1,(a7)
        jsr _desk_wait
        move.w    14(a6),(a7)
        jsr       _xfdadb6
        tst.w     d0
        beq.s     xfda90_2
        move.l    16(a6),(a7)
        move.w    14(a6),-(a7)
        jsr       _xfd9fde
        addq.l    #2,a7
        move.l    24(a5),(a7)
        jsr       _pn_free
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
        jsr       _xfda4b6
        adda.w    #22,a7
xfda90_2:
        clr.w     (a7)
        jsr _desk_wait
        clr.w     d0
        dc.w      $FC01

    xdef _open_item
_open_item: ds.b 0
        link      a6,#-146
        movem.l   d6-d7/a3-a5,-(a7)
        move.w    8(a6),d7
        movea.l   _thedesk,a3
        clr.w     -2(a6)
        pea.l     -10(a6)
        pea.l     -6(a6)
        move.w    d7,-(a7)
        move.w    13720(a3),-(a7)
        jsr       _xfdb04c
        adda.w    #12,a7
        movea.l   d0,a5
        tst.w     13720(a3)
        bne.s     xfda9_1
        clr.w     -8(a6)
        bra.s     xfda9_4
xfda9_1:
        move.w    13720(a3),(a7)
        jsr       _xfdc3f4
        movea.l   d0,a4
        move.l    13736(a3),(a7)
        pea.l     28(a4)
        jsr _streq
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
        jsr       _fpd_parse
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
        jsr       _xfda5d2
        adda.w    #18,a7
        move.w    d0,-2(a6)
        bra.s     xfda9_11

/* case 1 */
xfda9_6:
        tst.b     -132(a6)
        beq.s     xfda9_7
        pea.l     -132(a6)
        move.l    #xfeb1be,-(a7)
        jsr _xstrpcat
        addq.l    #8,a7
xfda9_7:
        pea.l     -132(a6)
        move.l    -6(a6),-(a7)
        addi.l    #18,(a7)
        jsr _xstrpcat
        addq.l    #8,a7
        pea.l     -146(a6)
        pea.l     -142(a6)
        pea.l     -132(a6)
        move.w    -8(a6),-(a7)
        move.w    d7,-(a7)
        move.l    a4,-(a7)
        jsr       _xfda900
        adda.w    #20,a7
        bra.s     xfda9_11

/* case 2 */
/* case 4 */
xfda9_8:
        move.w    d7,(a7)
        jsr       _xfda85e
        bra.s     xfda9_11

/* case 3 */
xfda9_9:
        clr.l     (a7)
        move.l    #$0001000E,-(a7)
        jsr _fun_alert
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
        dc.w      $FE21


    xdef _show_item
_show_item: ds.b 0
        link      a6,#-10
        movem.l   d5-d7/a3-a5,-(a7)
        move.w    8(a6),d7
        movea.l   _thedesk,a3
        pea.l     -2(a6)
        pea.l     -6(a6)
        move.w    d7,-(a7)
        move.w    13720(a3),-(a7)
        jsr       _xfdb04c
        adda.w    #12,a7
        movea.l   d0,a5
        tst.w     13720(a3)
        beq.s     xfdaa_1
        move.w    13720(a3),(a7)
        jsr       _xfdc3f4
        movea.l   d0,a4
xfdaa_1:
        move.l    a5,d0
        beq       xfdaa_7
        move.w    6(a5),d0
#ifdef __GNUC__
        bra       xfdaa_6
#else
        bra.s     xfdaa_6
#endif
xfdaa_2:
        clr.l     (a7)
        move.l    #$0001001A,-(a7)
        jsr _fun_alert
        addq.l    #4,a7
        bra.w     xfdaa_7
xfdaa_3:
        movea.l   24(a4),a0
        move.b    8(a0),d0
        ext.w     d0
        move.w    d0,(a7)
        jsr       _xfdadb6
        tst.w     d0
        beq.s     xfdaa_7
        move.w    6(a5),(a7)
        move.l    -6(a6),-(a7)
        move.l    24(a4),-(a7)
        addq.l    #8,(a7)
        jsr       _inf_file
        addq.l    #8,a7
        tst.w     d0
        beq.s     xfdaa_4
        move.l    a4,(a7)
        jsr       _up_1win
xfdaa_4:
		bra.s     xfdaa_7
xfdaa_5:
		move.w    d7,(a7)
		pea.l     24200(a3)
		jsr       _get_spec
		addq.l    #4,a7
		move.l    d0,-10(a6)
		movea.l   -10(a6),a0
		move.w    12(a0),(a7)
		andi.w    #255,(a7)
		jsr       _xfdadb6
		tst.w     d0
		beq.s     xfdaa_7
		movea.l   -10(a6),a0
		move.w    12(a0),(a7)
		andi.w    #255,(a7)
		jsr       _inf_disk
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
		dc.w      $FE31

	xdef _xfdab74
_xfdab74: ds.b 0
		link      a6,#-16
		movem.l   d6-d7/a3-a5,-(a7)
		move.w    8(a6),d7
		movea.l   _thedesk,a3
		suba.l    a5,a5
		tst.w     13720(a3)
		bne.s     xfdab_1
		move.w    d7,(a7)
		jsr       _xfdcd6a
		move.l    d0,-10(a6)
		pea.l     -2(a6)
		move.l    -10(a6),-(a7)
		move.w    d7,-(a7)
		move.l    #$0001FFFF,-(a7)
		jsr       _xfd5b36
		adda.w    #14,a7
		movea.l   d0,a5
xfdab_1:
		move.l    a5,d0
		beq.s     xfdab_2
		cmpi.w    #2,6(a5)
		bne.s     xfdab_2
		move.w    d7,(a7)
		pea.l     24200(a3)
		jsr       _get_spec
		addq.l    #4,a7
		movea.l   d0,a4
		move.w    12(a4),d0
		and.w     #255,d0
		move.b    d0,-16(a6)
		clr.b     -15(a6)
		lea.l     -16(a6),a0
		move.l    a0,-6(a6)
		pea.l     -6(a6)
		move.l    #$0002000F,-(a7)
		jsr _fun_alert
		addq.l    #8,a7
		cmp.w     #1,d0
		bne.s     xfdab_2
		move.w    #$00FC,(a7)
		pea.l     -16(a6)
		jsr _fc_start
		addq.l    #4,a7
xfdab_2:
		clr.w     d0
		dc.w      $FE21

	xdef _xfdac02
_xfdac02: ds.b 0
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
		jsr _wind_get
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
		jsr       _xfda3de
		addq.l    #6,a7
		move.l    24(a5),(a7)
		jsr       _pn_free
		move.l    a5,(a7)
		jsr       _xfdc376
		jsr       _xfdc47a
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
		jsr       _xfda13c
		addq.l    #2,a7
		clr.w     d0
		dc.w      $FC21

	xdef _xfdac8c
_xfdac8c: ds.b 0
		link      a6,#-14
		movem.l   d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		lea.l     -10(a6),a3
		movea.l   _thedesk,a4
		move.l    a3,(a7)
		move.w    #4,-(a7)
		move.w    6(a5),-(a7)
		jsr _wind_grget
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
		jsr       _xfda3de
		addq.l    #6,a7
		clr.w     12(a5)
		clr.w     14(a5)
		move.l    22(a6),(a7)
		move.l    18(a6),-(a7)
		move.l    14(a6),-(a7)
		move.w    12(a6),-(a7)
		clr.w     -(a7)
		move.l    a5,-(a7)
		jsr       _xfda900
		adda.w    #16,a7
		clr.w     d0
		dc.w      $FE01

	xdef _close_win
_close_win: ds.b 0
		link      a6,#-138
		movem.l   d5-d7/a3-a5,-(a7)
		movea.l   8(a6),a5
		move.w    12(a6),d7
		clr.w     d6
		move.w    #1,(a7)
		jsr _desk_wait
		pea.l     -138(a6)
		pea.l     -134(a6)
		pea.l     -124(a6)
		pea.l     -2(a6)
		move.l    24(a5),-(a7)
		addq.l    #8,(a7)
		jsr       _fpd_parse
		adda.w    #20,a7
		tst.w     d7
		beq.s     xfdad_1
		clr.b     -124(a6)
xfdad_1:
		tst.b     -124(a6)
		bne.s     xfdad_2
		move.l    a5,(a7)
		jsr       _xfdac02
		move.w    d0,d6
		bra.s     xfdad_6
xfdad_2:
		lea.l     -124(a6),a3
		move.l    a3,d0
		movea.l   d0,a4
		move.l    a6,(a7)
		addi.l    #-124,(a7)
		jsr _strlen
		subq.w    #1,d0
		ext.l     d0
		adda.l    d0,a3
		bra.s     xfdad_4
xfdad_3:
		subq.l    #1,a3
xfdad_4:
		cmpa.l    a4,a3
		beq.s     xfdad_5
		cmpi.b    #92,(a3)
		bne.s     xfdad_3
xfdad_5:
		clr.b     (a3)
		pea.l     -138(a6)
		pea.l     -134(a6)
		pea.l     -124(a6)
		move.w    -2(a6),-(a7)
		move.l    a5,-(a7)
		jsr       _xfdac8c
		adda.w    #18,a7
		move.w    d0,d6
xfdad_6:
		clr.w     (a7)
		jsr _desk_wait
		move.w    d6,d0
		dc.w      $FE31

	xdef _xfdadb6
_xfdadb6: ds.b 0
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
		jsr _desk_wait
		move.w    #10,(a7)
		jsr _trp13int
		move.l    d0,d7
		move.w    8(a6),d0
		add.w     #$FFBF,d0
		move.w    d0,-2(a6)
		move.w    -2(a6),d0
		asr.l     d0,d7
		and.l     #1,d7
		moveq.l   #1,d6
		tst.l     d7
		bne.s     xfdadb_2
		move.w    #15,(a7)
		jsr _fm_error
		clr.w     d6
		bra.s     xfdadb_3
xfdadb_2:
		move.w    8(a6),d0
		ext.w     d0
		move.b    d0,-12(a6)
		move.b    #':',-11(a6)
		pea.l     -10(a6)
		move.l    #_wilds,-(a7)
		jsr _xstrpcpy
		addq.l    #8,a7
		move.l    _thedesk,(a7)
		addi.l    #12574,(a7)
		jsr _dos_sdta
		move.w    #22,(a7)
		pea.l     -12(a6)
		jsr _dos_sfirst
		addq.l    #4,a7
		tst.w     d0
		bne.s     xfdadb_3
		cmpi.w    #18,_DOS_AX
		beq.s     xfdadb_3
		clr.w     d6
xfdadb_3:
		clr.w     (a7)
		jsr _desk_wait
		move.w    d6,d0
xfdadb_4:
		dc.w      $F031

	data

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
	dc.l $1100
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
	dc.b ':',92,0

xfeb1b1:
	dc.b 92,0

xfeb1b3:
	dc.b 0

xfeb1b4:
	dc.b 0

xfeb1b5:
	dc.b 42,0

xfeb1b7:
	dc.b 42,0

xfeb1b9:
	dc.b 0

xfeb1ba:
	dc.b 42,0

xfeb1bc:
	dc.b 42,0

xfeb1be:
	dc.b 92,0

	bss
	xdef x00634c
	comm x00634c,122
	xdef _f_level
	comm _f_level,2
