/********************************************************************************
 * HD-WAITER                                                                    *
 ********************************************************************************/

hd_wait:
                lea     hd_waitm(pc),a0
                bsr.s   hd_wait6
                moveq   #20-1,d5
hd_wait1:
                lea     hd_w16(pc),a0
                bsr.s   hd_wait6
                moveq   #6-1,d4
hd_wait2:
                btst    #3,(_shifty).w  /* kbshift (test alternate) */
                bne.s   hd_wait3
                bsr.s   hd_wait9
                beq.s   hd_wait4
                bsr.s   hd_wait7
                dbra    d4,hd_wait2
                dbra    d5,hd_wait1
hd_wait3:
                lea     hd_w18(pc),a0
                bra.s   hd_wait6
hd_wait4:
                lea     hd_w17(pc),a0

hd_wait6:
                move.l  a0,-(sp)
                move.w  #9,-(sp)        /* cconws */
                trap    #1
                addq.l  #6,sp
                rts
hd_wait7:
                moveq   #50,d0
                add.l   (_hz_200).w,d0
hd_wait8:
                cmp.l   (_hz_200).w,d0
                bhi.s   hd_wait8
                rts
hd_wait9:
                lea     (DMA_CTRL).w,a1
                lea     (DMA_DATA).w,a0
                st      (_flock).w
                move.w  #$0088,(a1)
                moveq   #5-1,d6
hd_w10:
                move.l  #$0000008a,d0
                bsr.s   hd_w12
                bne.s   hd_w11
                dbra    d6,hd_w10
                moveq   #$0a,d0
                move.l  d0,(a0)
                move.w  #(HD_WAITTIME*200),d0
                bsr.s   hd_w13
                bne.s   hd_w11
                move.w  #$008a,(a1)
                move.w  (a0),d0
                and.w   #$00ff,d0
hd_w11:
                move.w  #$0080,(a1)
                sf      (_flock).w
                tst.w   d0
                rts
hd_w12:
                move.l  d0,(a0)
                moveq   #10,d0
hd_w13:
                add.l   (_hz_200).w,d0
hd_w14:
                btst    #5,$fffffa01.w
                beq.s   hd_w15
                cmp.l   (_hz_200).w,d0
                bne.s   hd_w14
                moveq   #-1,d0
hd_w15:
                rts
hd_waitm:
                dc.b $0A,$0A,$0A,$0A,$0A,$0A
                dc.b 'Warte auf Harddisk'
hd_w16:
                dc.b '.',0
hd_w17:
                dc.b 'OK',$0D,$0A,$00
hd_w18:
                dc.b ' keine da!',$0D,$0A,$00
				even
