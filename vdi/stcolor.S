#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"

/* whole file, 3.x uses C version */

palette equ $00FF8240

		text

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
