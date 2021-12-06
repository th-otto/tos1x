#include "config.h"
#include "tosvars.inc"

palette   equ $FFFF8240
vblvec    equ $0070
timcvec   equ $0114
mfpvec    equ $0118
hblvec    equ $0120

vblsave   equ $800
mfpsave   equ $804
hblsave   equ $808
colsave   equ $80c
hblcount  equ $80e
wrapcount equ $810
nxtidx    equ $812
colidx    equ $814


/*
 * Start the rainbow effect for the desktops about dialog
 */
/* 104de: 00fdae56 */
/* 106de: 00e1bfc6 */
	xdef _rb_start
_rb_start: ds.b 0
		cmpi.b    #2,(_sshiftmod).w ; skip for high-res
		bge.s     rb_sta1
		moveq.l   #0,d0
		move.l    d0,(hblcount).w ; also clears wrapcount
		moveq.l   #16,d0
		move.w    d0,(nxtidx).w
		move.w    d0,(colidx).w
		move.w    (0xFFFF8242).w,(colsave).w
		move.w    sr,-(a7)
		move.w    #0x2700,sr
		move.l    (vblvec).w,(vblsave).w
		move.l    #vblintr,(vblvec).w
		move.l    (mfpvec).w,(mfpsave).w
		move.l    #mfpintr,(mfpvec).w
		move.l    (hblvec).w,(hblsave).w
		move.l    #hblintr,(hblvec).w
		bclr      #5,(0xFFFFFA09).w ; disable timer C
		move.w    (a7)+,sr
rb_sta1:
		rts

/*
 * Stop the rainbow effect for the desktops about dialog
 */
/* 104de: 00fdaeae */
/* 106de: 00e1c01e */
	xdef _rb_stop
_rb_stop: ds.b 0
		cmpi.b    #2,(_sshiftmod).w
		bge.s     rb_sto2 ; skip for high-res
		move.w    sr,-(a7)
		move.w    #0x2700,sr
		bclr      #0,(0xFFFFFA07).w ; disable HBL
		bclr      #0,(0xFFFFFA13).w ; mask HBL
		bset      #5,(0xFFFFFA09).w ; enable timer C
		move.l    (vblsave).w,(vblvec).w
		move.l    (mfpsave).w,(mfpvec).w
		move.l    (hblsave).w,(hblvec).w
		move.w    (a7)+,sr
		move.w    (colsave).w,(0xFFFF8242).w
		lea.l     (vblsave).w,a0
		moveq.l   #5,d0
rb_sto1:
		clr.l     (a0)+
		dbf       d0,rb_sto1
		clr.w     (nxtidx).w
rb_sto2:
		rts

mfpintr:
		move.w    #0x2500,sr
		move.l    (mfpsave).w,-(a7)
		rts

vblintr:
		move.l    d0,-(a7)
		move.w    sr,-(a7)
		move.w    #0x2600,sr
		moveq.l   #2,d0
vblintr1:
		pea.l     vblintr2(pc)
		move.w    sr,-(a7)
		move.l    (timcvec).w,-(a7)
		rts
vblintr2:
		dbf       d0,vblintr1
		move.w    (a7)+,sr
		moveq.l   #78,d0
		bsr.s     settimer
		move.l    (a7)+,d0
		move.l    (vblsave).w,-(a7)
		rts

settimer:
		clr.b     (0xFFFFFA1B).w ; stop timer B
settim1:
		move.b    d0,(0xFFFFFA21).w ; timer b data register
		cmp.b     (0xFFFFFA21).w,d0
		bne.s     settim1
		move.b    #8,(0xFFFFFA1B).w ; set event count mode
		bset      #0,(0xFFFFFA07).w ; enable hbl
		bset      #0,(0xFFFFFA13).w ; unmask hbl
		rts

hblintr:
		move.l    d0,-(a7)
		move.w    (colidx).w,d0
		move.w    coltab(pc,d0.w),(0xFFFF8242).w
		tst.w     (hblcount).w
		bne.s     hblint2
		move.w    #36,(hblcount).w
		subq.w    #1,(wrapcount).w
		bge.s     hblint1
		move.w    #4,(wrapcount).w
		subq.w    #2,(nxtidx).w
		bpl.s     hblint1
		move.w    #94,(nxtidx).w
hblint1:
		move.w    (nxtidx).w,(colidx).w
		moveq.l   #1,d0
		bsr.s     settimer
hblint2:
		cmpi.w    #14,(hblcount).w
		bne.s     hblint3
		move.w    #116,(colidx).w
hblint3:
		subq.w    #2,(colidx).w
		bpl.s     hblint4
		move.w    #94,(colidx).w
hblint4:
		subq.w    #1,(hblcount).w
		bne.s     hblint5
		bclr      #0,(0xFFFFFA07).w ; disable HBL
		move.w    (colsave).w,(0xFFFF8242).w
hblint5:
		bclr      #0,(0xFFFFFA0F).w ; service interrupt
		move.l    (a7)+,d0
		rte


coltab:
		dc.w 0x0701,0x0702,0x0703,0x0704
		dc.w 0x0705,0x0706,0x0707,0x0717
		dc.w 0x0707,0x0607,0x0507,0x0407
		dc.w 0x0307,0x0207,0x0107,0x0007
		dc.w 0x0017,0x0027,0x0037,0x0047
		dc.w 0x0057,0x0067,0x0077,0x0177
		dc.w 0x0077,0x0076,0x0075,0x0074
		dc.w 0x0073,0x0072,0x0071,0x0070
		dc.w 0x0170,0x0270,0x0370,0x0470
		dc.w 0x0570,0x0670,0x0770,0x0771
		dc.w 0x0770,0x0760,0x0750,0x0740
		dc.w 0x0730,0x0720,0x0710,0x0700
		dc.w 0x0222,0x0223,0x0233,0x0333
		dc.w 0x0334,0x0344,0x0444,0x0445
		dc.w 0x0455,0x0555
