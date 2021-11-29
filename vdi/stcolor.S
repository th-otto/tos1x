#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"

#if !PLANES8 /* whole file, 3.x uses C version */

palette equ $00FF8240

		text

#if TOSVERSION >= 0x200

/* sigh, once again; duplicate from tables.c */
plane_mask:
	dc.b 1,3,0,15

/* 206de: 00e0dad2 */
	xdef _vs_color
_vs_color:
        movem.w   d3-d5,-(a7)
        PIXLA(a4)
        move.w    PIXLV((INQ_TAB)+2,a4),d5
        bne       vs_col1a
        bsr       cookvdo
        move.w    #512,d5
        tst.w     d0
        beq       vs_col1
        move.w    #4096,d5
vs_col1:
        move.w    d5,PIXLV((INQ_TAB)+2,a4)
        move.w    d5,PIXLV((DEV_TAB)+78,a4)
vs_col1a:
        sub.w     #512,d5
        movea.l   PIXLV(INTIN,a4),a0
        move.w    (a0)+,d0
        move.w    PIXLV(v_planes,a4),d1
        move.b    plane_mask-1(pc,d1.w),d4
        cmp.b     d4,d0
        bhi       vs_col10
        move.w    d0,d2
        mulu.w    #6,d2
        lea.l     PIXLV(REQ_COL,a4),a1
        adda.w    d2,a1
        subq.w    #1,d1
        beq       vs_col8
        moveq.l   #2,d3
        moveq.l   #0,d1
vs_col2:
        moveq.l   #0,d2
        move.w    (a0)+,d2
        move.w    d2,(a1)+
        bge       vs_col3
        clr.w     d2
vs_col3:
        cmp.w     #1000,d2
        ble       vs_col4
        move.w    #1000,d2
vs_col4:
        tst.w     d5
        beq       vs_col5
        mulu.w    #15,d2
        add.w     #500,d2
        divu.w    #1000,d2
        bra       vs_col6
vs_col5:
        add.w     #$0048,d2
        divu.w    #$008F,d2
vs_col6:
        asl.w     #4,d1
        tst.w     d5
        beq       vs_col7
        move.w    d5,-(a7)
        move.w    d2,d5
        andi.w    #$0001,d5
        asl.w     #3,d5
        asr.w     #1,d2
        or.w      d5,d2
        move.w    (a7)+,d5
vs_col7:
        or.w      d2,d1
        dbf       d3,vs_col2
        lea.l     _MAP_COL,a0
        add.w     d0,d0
        move.w    0(a0,d0.w),d0
        and.b     d4,d0
        lea.l     palette,a0
        add.w     d0,d0
        move.w    d1,0(a0,d0.w)
        movem.w   (a7)+,d3-d5
        rts
vs_col8:
        move.w    (a0)+,d1
        move.w    d1,(a1)+
        bsr       vs_col11
        move.w    d1,d2
        move.w    (a0)+,d1
        move.w    d1,(a1)+
        bsr       vs_col11
        add.w     d1,d2
        move.w    (a0)+,d1
        move.w    d1,(a1)+
        bsr       vs_col11
        add.w     d1,d2
        beq       vs_col9
        cmp.w     #$0BB8,d2
        bne       vs_col10
        not.w     d0
vs_col9:
        move.w    d0,palette
vs_col10:
        movem.w   (a7)+,d3-d5
vs_col11:
        tst.w     d5
        beq       vs_col12
        cmp.w     #67,d1
        blt       vs_col14
        cmp.w     #934,d1
        blt       vs_col13
        move.w    #1000,d1
        rts
vs_col12:
        cmp.w     #142,d1
        blt       vs_col14
        cmp.w     #858,d1
        blt       vs_col13
        move.w    #1000,d1
vs_col13:
        rts
vs_col14:
        moveq.l   #0,d1
        rts

/* 206de: 00e0dbee */
	xdef _vq_color
_vq_color:
        movem.l   d4-d5,-(a7)
        PIXLA(a4)
        move.w    PIXLV((INQ_TAB)+2,a4),d5
        bne       vq_col2
        bsr       cookvdo
        move.w    #512,d5
        tst.w     d0
        beq       vq_col1
        move.w    #4096,d5
vq_col1:
        move.w    d5,PIXLV((INQ_TAB)+2,a4)
        move.w    d5,PIXLV((DEV_TAB)+78,a4)
vq_col2:
        sub.w     #$0200,d5
        movea.l   PIXLV(local_pb,a4),a0
        move.w    #4,8(a0)
        movea.l   PIXLV(INTIN,a4),a0
        move.w    (a0)+,d0
        move.w    (a0),d2
        movea.l   PIXLV(INTOUT,a4),a0
        move.w    PIXLV(v_planes,a4),d1
        move.b    planem2-1(pc,d1.w),d4
        cmp.b     d4,d0
        bls       vq_col3
        move.w    #$FFFF,(a0)
        bra       vq_col4

/* sigh, once again; duplicate from tables.c, and from above */
planem2:
	dc.b 1,3,0,15

vq_col3:
        move.w    d0,(a0)+
        tst.w     d2
        bne       vq_col5
        lea.l     PIXLV(REQ_COL,a4),a1
        mulu.w    #6,d0
        adda.w    d0,a1
        move.w    (a1)+,(a0)+
        move.w    (a1)+,(a0)+
        move.w    (a1),(a0)
vq_col4:
        movem.l   (a7)+,d4-d5
        rts
vq_col5:
        subq.w    #1,d1
        beq       vq_col8
        lea.l     _MAP_COL,a1
        add.w     d0,d0
        move.w    0(a1,d0.w),d0
        and.b     d4,d0
        lea.l     palette,a1
        add.w     d0,d0
        move.w    0(a1,d0.w),d0
        rol.w     #5,d0
        moveq.l   #2,d1
vq_col6:
        rol.w     #4,d0
        move.w    d0,d2
        tst.w     d5
        beq       vq_col7
        move.w    d2,d4
        andi.w    #$000E,d2
        asr.w     #4,d4
        andi.w    #$0001,d4
        or.w      d4,d2
        add.w     d2,d2
        move.w    pcnt_tab(pc,d2.w),(a0)+
        dbf       d1,vq_col6
        bra       vq_col4
vq_col7:
        and.w     #$000E,d2
        move.w    pcnttab2(pc,d2.w),(a0)+
        dbf       d1,vq_col6
        bra       vq_col4
vq_col8:
        move.w    palette,d1
        eor.w     d1,d0
        moveq.l   #0,d1
        btst      #0,d0
        beq       vq_col9
        move.w    #1000,d1
vq_col9:
        move.w    d1,(a0)+
        move.w    d1,(a0)+
        move.w    d1,(a0)
        bra       vq_col4

pcnt_tab:
	dc.w 0,67,133,200,267,333,400,467,533,600,667,733,800,867,933,1000
pcnttab2:
    dc.w 0,142,285,428,571,714,857,1000

cookvdo:
        move.l    #$5f56444f,d1 /* '_VDO' */
        movea.l   _p_cookies,a0
        move.l    a0,d0
        beq       cookvdo3
cookvdo1:
        move.l    (a0),d0
        cmp.l     d0,d1
        beq       cookvdo2
        tst.l     d0
        beq       cookvdo3
        addq.l    #8,a0
        bra       cookvdo1
cookvdo2:
        move.w    4(a0),d0
cookvdo3:
        rts

#else

/* 104de: 00fd1d2e */
	xdef _vs_color
_vs_color:
        PIXLA(a4)
        movea.l   PIXLV(INTIN,a4),a0
		move.w    (a0)+,d0
        move.w    PIXLV(v_planes,a4),d1
        move.b    plane_mask-1(pc,d1.w),d4
        cmp.b     d4,d0
        bhi       vs_col10
        move.w    d0,d2
        mulu.w    #6,d2
        lea.l     PIXLV(REQ_COL,a4),a1
        adda.w    d2,a1
        subq.w    #1,d1
        beq       vs_col8
        moveq.l   #2,d3
        moveq.l   #0,d1
vs_col2:
        moveq.l   #0,d2
        move.w    (a0)+,d2
        move.w    d2,(a1)+
        bge       vs_col3
        clr.w     d2
vs_col3:
        cmp.w     #1000,d2
        ble       vs_col4
        move.w    #1000,d2
vs_col4:
        add.w     #$0048,d2
        divu.w    #$008F,d2
vs_col6:
        asl.w     #4,d1
        or.w      d2,d1
        dbf       d3,vs_col2
        lea.l     _MAP_COL,a0
        add.w     d0,d0
        move.w    0(a0,d0.w),d0
        and.b     d4,d0
        lea.l     palette,a0
        add.w     d0,d0
        move.w    d1,0(a0,d0.w)
        rts

plane_mask:
	dc.b 1,3,0,15

vs_col8:
        move.w    (a0)+,d1
        move.w    d1,(a1)+
        bsr       vs_col11
        move.w    d1,d2
        move.w    (a0)+,d1
        move.w    d1,(a1)+
        bsr       vs_col11
        add.w     d1,d2
        move.w    (a0)+,d1
        move.w    d1,(a1)+
        bsr       vs_col11
        add.w     d1,d2
        beq       vs_col9
        cmp.w     #$0BB8,d2
        bne       vs_col10
        not.w     d0
vs_col9:
        move.w    d0,palette
vs_col10:
		rts
vs_col11:
        cmp.w     #142,d1
        blt       vs_col14
        cmp.w     #858,d1
        blt       vs_col13
        move.w    #1000,d1
vs_col13:
        rts
vs_col14:
        moveq.l   #0,d1
        rts

/* 104de: 00fd1de0 */
	xdef _vq_color
_vq_color:
		move.l    d4,-(a7)
        PIXLA(a4)
        movea.l   PIXLV(local_pb,a4),a0
        move.w    #4,8(a0)
        movea.l   PIXLV(INTIN,a4),a0
        move.w    (a0)+,d0
        move.w    (a0),d2
        movea.l   PIXLV(INTOUT,a4),a0
        move.w    PIXLV(v_planes,a4),d1
        move.b    plane_mask-1(pc,d1.w),d4
        cmp.b     d4,d0
        bls       vq_col3
        move.w    #$FFFF,(a0)
        bra       vq_col4

vq_col3:
        move.w    d0,(a0)+
        tst.w     d2
        bne       vq_col5
        lea.l     PIXLV(REQ_COL,a4),a1
        mulu.w    #6,d0
        adda.w    d0,a1
        move.w    (a1)+,(a0)+
        move.w    (a1)+,(a0)+
        move.w    (a1),(a0)
vq_col4:
        move.l    (a7)+,d4
        rts
vq_col5:
        subq.w    #1,d1
        beq       vq_col8
        lea.l     _MAP_COL,a1
        add.w     d0,d0
        move.w    0(a1,d0.w),d0
        and.b     d4,d0
        lea.l     palette,a1
        add.w     d0,d0
        move.w    0(a1,d0.w),d0
        rol.w     #5,d0
        moveq.l   #2,d1
vq_col6:
        rol.w     #4,d0
        move.w    d0,d2
        and.w     #$000E,d2
        move.w    pcnttab2(pc,d2.w),(a0)+
        dbf       d1,vq_col6
        bra       vq_col4
vq_col8:
        move.w    palette,d1
        eor.w     d1,d0
        moveq.l   #0,d1
        btst      #0,d0
        beq       vq_col9
        move.w    #1000,d1
vq_col9:
        move.w    d1,(a0)+
        move.w    d1,(a0)+
        move.w    d1,(a0)
        bra       vq_col4

pcnttab2:
    dc.w 0,142,285,428,571,714,857,1000

#endif /* STE support */

#endif /* !PLANES8 */

#if 0 /* version from PAK patch */
VS_COLOR:
      movem.l   a0-a5/d3-d7,-(a7)
      lea       (lineavars).w,a5
      lea       l001a(pc),a0           
      move.w    0(a5),d4
      move.w    d4,d0
      add.w     d0,d0
      move.w    0(a0,d0.w),d7
      movea.l   8(a5),a0 /* LA_INTIN */
      move.w    (a0)+,d6
      cmp.w     d7,d6
      bhi       l0006
      lea       -594(a5),a4 /* REQ_COL */
      move.w    d6,d0
      mulu      #6,d0
      adda.l    d0,a4
      move.w    (a0)+,(a4)+
      move.w    (a0)+,(a4)+
      move.w    (a0),(a4)
      lea       -4(a0),a5 /* WTF? */
      subq.w    #1,d4
      beq.s     l0007
      move.w    #512,d5
      tst.b     (STEFlag).w
      bne.s     l0000
      move.w    #4096,d5
l0000:move.w    d5,-780(a5) /* INQ_TAB[4] BUG: should be INQ_TAB[1] */
      move.w    d5,-614(a5) /* DEV_TAB[39] */
      sub.w     #512,d5
      lea       _MAP_COL,a0
      add.w     d6,d6
      move.w    0(a0,d6.w),d6
      and.w     d7,d6
      moveq     #0,d3
      moveq     #3,d7
l0001:moveq     #0,d4
      move.w    (a5)+,d4
      bpl.s     l0002
      moveq     #0,d4
l0002:cmp.w     #1000,d4
      bls.s     l0003
      move.w    #1000,d4
l0003:tst.w     d5
      beq.s     l0004
      mulu      #15,d4
      add.l     #500,d4
      divu      #1000,d4
      lsr.w     #1,d4
      bcc.s     l0005
      or.w      #8,d4
      bra.s     l0005
l0004:add.w     #72,d4
      divu      #143,d4
l0005:lsl.w     #4,d3
      or.w      d4,d3
      subq.w    #1,d7
      bne.s     l0001
      lea       (palette).w,a0
      add.w     d6,d6
      move.w    d3,0(a0,d6.w)
l0006:movem.l   (a7)+,a0-a5/d3-d7
      rts
l0007:moveq     #2,d5
      move.w    d5,-780(a5) /* INQ_TAB[4] BUG: should be INQ_TAB[1] */
      move.w    d5,-614(a5) /* DEV_TAB[39] */
      moveq     #0,d3
      moveq     #3,d7
      move.w    #142,d0
      move.w    #858,d1
      tst.b     (STEFlag).w
      bne.s     l0008
      move.w    #67,d0
      move.w    #934,d1
l0008:move.w    (a5)+,d4
      bmi.s     l000b
      cmp.w     #1000,d4
      bhi.s     l0009
      cmp.w     d0,d4
      blt.s     l000b
      cmp.w     d1,d4
      blt.s     l000a
l0009:move.w    #1000,d4
l000a:add.w     d4,d3
l000b:subq.w    #1,d7
      bne.s     l0008
      tst.w     d3
      beq.s     l000c
      cmp.w     #3000,d3
      bne.s     l000d
      not.w     d6
l000c:move.w    d6,(palette).w
l000d:movem.l   (a7)+,a0-a5/d3-d7
      rts

VQ_COLOR:
      movem.l   a0-a5/d3-d7,-(a7)
      lea       (lineavars),a5
      movea.l   4(a5),a0 /* LA_CONTROL */
      move.w    #4,8(a0)
      lea       l001a(pc),a0
      move.w    0(a5),d4
      move.w    d4,d0
      add.w     d0,d0
      move.w    0(a0,d0.w),d7
      movea.l   8(a5),a0 /* LA_INTIN */
      movea.l   16(a5),a3 /* LA_INTOUT */
      move.w    (a0)+,d6
      cmp.w     d7,d6
      bls.s     l000e
      move.w    #-1,(a3)
      bra.s     l0014
l000e:move.w    d6,(a3)+
      lea       -594(a5),a4 /* REQ_COL */
      move.w    d6,d0
      mulu      #6,d0
      adda.l    d0,a4
      tst.w     (a0)
      beq.s     l0015
      subq.w    #1,d4
      beq.s     l0016
      move.w    #512,d5
      tst.b     (STEFlag).w
      bne.s     l000f
      move.w    #4096,d5
l000f:move.w    d5,-780(a5) /* INQ_TAB[4] BUG: should be INQ_TAB[1] */
      move.w    d5,-614(a5) /* DEV_TAB[39] */
      sub.w     #512,d5
      lea       _MAP_COL,a0
      add.w     d6,d6
      move.w    0(a0,d6.w),d6
      and.w     d7,d6
      lea       (palette).w,a0
      move.w    d6,d0
      add.w     d0,d0
      move.w    0(a0,d0.w),d3
      addq.l    #6,a3
      moveq     #3,d1
l0010:move.w    d3,d0
      tst.w     d5
      beq.s     l0012
      add.w     d0,d0
      btst      #4,d0
      beq.s     l0011
      addq.w    #1,d0
l0011:and.w     #$f,d0
      add.w     d0,d0
      move.w    l0018(pc,d0.w),-(a3)
      bra.s     l0013
l0012:and.w     #7,d0
      add.w     d0,d0
      move.w    l0019(pc,d0.w),-(a3)    
l0013:lsr.w     #4,d3
      subq.w    #1,d1
      bne.s     l0010
l0014:movem.l   (a7)+,a0-a5/d3-d7
      rts
l0015:move.w    (a4)+,(a3)+
      move.w    (a4)+,(a3)+
      move.w    (a4),(a3)
      movem.l   (a7)+,a0-a5/d3-d7
      rts
l0016:moveq     #2,d5
      move.w    d5,-780(a5) /* INQ_TAB[4] BUG: should be INQ_TAB[1] */
      move.w    d5,-614(a5) /* DEV_TAB[39] */
      move.w    (palette).w,d0
      eor.w     d0,d6
      moveq     #0,d0
      and.w     #1,d6
      beq.s     l0017
      move.w    #1000,d0
l0017:move.w    d0,(a3)+
      move.w    d0,(a3)+
      move.w    d0,(a3)
      movem.l   (a7)+,a0-a5/d3-d7
      rts

l0018:dc.w      $0000,$0043,$0085,$00c8
      dc.w      $010b,$014d,$0190,$01d3
      dc.w      $0215,$0258,$029b,$02dd
      dc.w      $0320,$0363,$03a5,$03e8
l0019:dc.w      $0000,$008e,$011d,$01ac
      dc.w      $023b,$02ca,$0359,$03e8
l001a:dc.w      $0000,$0001,$0003,$0007
      dc.w      $000f,$001f,$007f,$00ff

#endif
