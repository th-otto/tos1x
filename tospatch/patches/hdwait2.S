/********************************************************************************
 * Alternativer HD-Waiter
 ********************************************************************************/

hd_wait:
                move.l  #(HD_WAITTIME*200),d6
                cmp.l   (_hz_200).w,d6
                bls.s   hd_wait3
                add.l   (_hz_200).w,d6
hd_wait1:
                cmp.l   (_hz_200).w,d6
                bls.s   hd_wait2
                move.l  #$00010002,-(sp)
                trap    #13
                addq.l  #4,sp
                tst.w   d0
                beq.s   hd_wait1
                move.l  #$00020002,-(sp)
                trap    #13
                addq.l  #4,sp
hd_wait2:
hd_wait3:
                rts
