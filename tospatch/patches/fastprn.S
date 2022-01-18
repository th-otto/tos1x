/**************************************************************************
 *                                                                        *
 * Bconout function for device 0 (parallel i/o port)                      *
 *                                                                        *
 *       this set of routines is for general parallel i/o                 *
 *                                                                        *
 *       entry to listout                                                 *
 *                                                                        *
 *       entry to listin                                                  *
 *                                                                        *
 *       exit from listin                                                 *
 *                                                                        *
 **************************************************************************/
	xdef _bcon0out
_bcon0out:
        btst      #4,(_prtconfig+1).w  /* Printer configured for output to RS232? */
        bne       _bcon6out
		lea.l     (_hz_200).w,a0
		move.l    (a0),d3
		move.l    d3,d2
		sub.l     (lst_timeout).w,d3
		cmpi.l    #1000,d3
        bcs.s     bcon0o2
bcon0o1:
        bsr.s     _bco0stat
        bmi.s     bcon0o3
        move.l    (a0),d3
        sub.l     d2,d3
        cmpi.l    #(PRNTIMEOUT*200),d3
        bcs.s     bcon0o1
bcon0o2:
		move.l    (a0),(lst_timeout).w
        moveq.l   #0,d0
        rts
bcon0o3:
        bsr.s     gpipisr7
        moveq.l   #7,d1
        moveq.l   #$c0,d0
        bsr.s     ongib
        move.b    #$0F,(a0)
        move.b    7(a7),(a1)
        bsr.s     strobeon
        move.w    (a0),d0
        move.w    (a0),d0
        bsr.s     ongib0
        move.w    d3,sr
        moveq.l   #-1,d0
        rts

strobeoff:
        moveq.l   #14,d1
ongib0:
        moveq.l   #$20,d0
ongib:
        move.b    d1,(a0)
        or.b      (a0),d0
        move.b    d0,(a1)
        rts

strobeon:
        moveq.l   #14,d1
offgib0:
        moveq.l   #$DF,d0
offgib:
        move.b    d1,(a0)
        and.b     (a0),d0
        move.b    d0,(a1)
        rts


/*
 * Bconin function for device 0 (printer)
 */
	xdef _bcon0in
_bcon0in:
        bsr.s     gpipisr7
        moveq.l   #7,d1
        moveq.l   #127,d0
        bsr.s     offgib
        bsr.s     strobeoff
        move.w    d3,sr
bcon0in1:
        bsr.s     _bco0stat
        bmi.s     bcon0in1
        bsr.s     gpipisr7
        bsr.s     offgib0
        move.b    #$0F,(a0)
        move.b    (a0),d0
        move.w    d3,sr
        rts

/*
 * Bcostat function for device 0 (printer)
 */
/* 306pl: 00382378 */
/* 206de: 00e020a0 */
	xdef _bco0stat
_bco0stat:
        andi.b    #$FE,(MFP_DDR).w
        moveq.l   #0,d0
        btst      d0,(MFP_GPIP).w
        bne.s     bco0st1
        moveq.l   #-1,d0
bco0st1:
        rts

strobeo0:
        bsr.s     gpipisr7
        bsr.s     strobeoff
        move.w    d3,sr
        rts

gpipisr7:
        lea.l     (psgsel).w,a0
        lea.l     2(a0),a1
        move.w    sr,d3
        ori.w     #$0700,sr
        rts
		dc.w -1
