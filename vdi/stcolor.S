#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"

palette equ $00FF8240

		text

/*
 * VDI #14 - vs_color - Set color representation
 */
/* 104de: 00fd1d2e */
/* 106de: 00e11f52 */
/* 100de: 00fd1a00 */
	xdef _vs_color
_vs_color:
#if TOSVERSION >= 0x106
		movem.w   d3-d4,-(a7)
#endif
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
#if TOSVERSION >= 0x106
		mulu.w    #15,d2
		add.w     #500,d2
		divu.w    #1000,d2
* shift least significant bit into bit #3
        asl.w     #4,d1
        move.w    d5,-(a7)
        move.w    d2,d5
        andi.w    #1,d5
        asl.w     #3,d5
        asr.w     #1,d2
        or.w      d5,d2
        move.w    (a7)+,d5
#else
        add.w     #$0048,d2
        divu.w    #$008F,d2
        asl.w     #4,d1
#endif
        or.w      d2,d1
        dbf       d3,vs_col2
        lea.l     _MAP_COL,a0
        add.w     d0,d0
        move.w    0(a0,d0.w),d0
        and.b     d4,d0
        lea.l     palette,a0
        add.w     d0,d0
        move.w    d1,0(a0,d0.w)
#if TOSVERSION >= 0x106
		movem.w   (a7)+,d3-d4
#endif
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
#if TOSVERSION >= 0x106
		movem.w   (a7)+,d3-d4
#endif
		rts
vs_col11:
#if TOSVERSION >= 0x106
        cmp.w     #67,d1
        blt       vs_col14
        cmp.w     #934,d1
#else
        cmp.w     #142,d1
        blt       vs_col14
        cmp.w     #858,d1
#endif
        blt       vs_col13
        move.w    #1000,d1
vs_col13:
        rts
vs_col14:
        moveq.l   #0,d1
        rts

/* 104de: 00fd1de0 */
/* 106de: 00e12024 */
/* 100de: 00fd1ab2 */
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
#if TOSVERSION >= 0x106
		move.w    d2,d4
        andi.w    #$000E,d2
        asr.w     #4,d4
        andi.w    #1,d4
        or.w      d4,d2
        add.w     d2,d2
#else
        and.w     #$000E,d2
#endif
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
#if TOSVERSION >= 0x106
    dc.w 0,67,133,200,267,333,400,467,533,600,667,733,800,867,933,1000
#else
    dc.w 0,142,285,428,571,714,857,1000
#endif

