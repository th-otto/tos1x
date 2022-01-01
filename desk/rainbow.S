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
		move.w    ($FFFF8242).w,(colsave).w
		move.w    sr,-(a7)
		move.w    #$2700,sr
		move.l    (vblvec).w,(vblsave).w
		move.l    #vblintr,(vblvec).w
		move.l    (mfpvec).w,(mfpsave).w
		move.l    #mfpintr,(mfpvec).w
		move.l    (hblvec).w,(hblsave).w
		move.l    #hblintr,(hblvec).w
		bclr      #5,($FFFFFA09).w ; disable timer C
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
		move.w    #$2700,sr
		bclr      #0,($FFFFFA07).w ; disable HBL
		bclr      #0,($FFFFFA13).w ; mask HBL
		bset      #5,($FFFFFA09).w ; enable timer C
		move.l    (vblsave).w,(vblvec).w
		move.l    (mfpsave).w,(mfpvec).w
		move.l    (hblsave).w,(hblvec).w
		move.w    (a7)+,sr
		move.w    (colsave).w,($FFFF8242).w
		lea.l     (vblsave).w,a0
		moveq.l   #5,d0
rb_sto1:
		clr.l     (a0)+
		dbf       d0,rb_sto1
		clr.w     (nxtidx).w
rb_sto2:
		rts

mfpintr:
		move.w    #$2500,sr
		move.l    (mfpsave).w,-(a7)
		rts

vblintr:
		move.l    d0,-(a7)
		move.w    sr,-(a7)
		move.w    #$2600,sr
		moveq.l   #2,d0
vblintr1:
#if TOSVERSION >= 0x106
		tst.w     (_longframe).w
		beq.w     vblintr2
		move.w    #0,-(a7)
vblintr2:
#endif
		pea.l     vblintr3(pc)
		move.w    sr,-(a7)
		move.l    (timcvec).w,-(a7)
		rts
vblintr3:
		dbf       d0,vblintr1
		move.w    (a7)+,sr
		moveq.l   #78,d0
		bsr.s     settimer
		move.l    (a7)+,d0
		move.l    (vblsave).w,-(a7)
		rts

settimer:
		clr.b     ($FFFFFA1B).w ; stop timer B
settim1:
		move.b    d0,($FFFFFA21).w ; timer b data register
		cmp.b     ($FFFFFA21).w,d0
		bne.s     settim1
		move.b    #8,($FFFFFA1B).w ; set event count mode
		bset      #0,($FFFFFA07).w ; enable hbl
		bset      #0,($FFFFFA13).w ; unmask hbl
		rts

hblintr:
		move.l    d0,-(a7)
		move.w    (colidx).w,d0
		move.w    coltab(pc,d0.w),($FFFF8242).w
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
		bclr      #0,($FFFFFA07).w ; disable HBL
		move.w    (colsave).w,($FFFF8242).w
hblint5:
		bclr      #0,($FFFFFA0F).w ; service interrupt
		move.l    (a7)+,d0
		rte


coltab:
		dc.w $0701,$0702,$0703,$0704
		dc.w $0705,$0706,$0707,$0717
		dc.w $0707,$0607,$0507,$0407
		dc.w $0307,$0207,$0107,$0007
		dc.w $0017,$0027,$0037,$0047
		dc.w $0057,$0067,$0077,$0177
		dc.w $0077,$0076,$0075,$0074
		dc.w $0073,$0072,$0071,$0070
		dc.w $0170,$0270,$0370,$0470
		dc.w $0570,$0670,$0770,$0771
		dc.w $0770,$0760,$0750,$0740
		dc.w $0730,$0720,$0710,$0700
		dc.w $0222,$0223,$0233,$0333
		dc.w $0334,$0344,$0444,$0445
		dc.w $0455,$0555
