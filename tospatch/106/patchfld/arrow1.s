[00fdcbe0] 4e56 ffec                 link       a6,#$FFEC
[00fdcbe4] 2eae 0008                 move.l     8(a6),(a7)
[00fdcbe8] f2ec                      dc.w       $F2EC ; win_find
[00fdcbea] 4e71                      nop
[00fdcbec] 2040                      movea.l    d0,a0
[00fdcbee] 2017                      move.l     (a7),d0
[00fdcbf0] 7200                      moveq.l    #0,d1
[00fdcbf2] 43e8 000c                 lea.l      12(a0),a1
[00fdcbf6] 0880 0002                 bclr       #2,d0
[00fdcbfa] 6604                      bne.s      $00FDCC00
[00fdcbfc] 7201                      moveq.l    #1,d1
[00fdcbfe] 5489                      addq.l     #2,a1
[00fdcc00] 3411                      move.w     (a1),d2
[00fdcc02] 5889                      addq.l     #4,a1
[00fdcc04] 5740                      subq.w     #3,d0
[00fdcc06] 6712                      beq.s      $00FDCC1A
[00fdcc08] 5440                      addq.w     #2,d0
[00fdcc0a] 6e0a                      bgt.s      $00FDCC16
[00fdcc0c] 6704                      beq.s      $00FDCC12
[00fdcc0e] 9451                      sub.w      (a1),d2
[00fdcc10] 600a                      bra.s      $00FDCC1C
[00fdcc12] d451                      add.w      (a1),d2
[00fdcc14] 6006                      bra.s      $00FDCC1C
[00fdcc16] 5342                      subq.w     #1,d2
[00fdcc18] 6002                      bra.s      $00FDCC1C
[00fdcc1a] 5242                      addq.w     #1,d2
[00fdcc1c] 3f02                      move.w     d2,-(a7)
[00fdcc1e] 3f01                      move.w     d1,-(a7)
[00fdcc20] 2f08                      move.l     a0,-(a7)
[00fdcc22] f6b0                      dc.w       $F6B0 ; win_blt
[00fdcc24] 4e71                      nop
[00fdcc26] 508f                      addq.l     #8,a7
[00fdcc28] 6124                      bsr.s      $00FDCC4E
[00fdcc2a] 661e                      bne.s      $00FDCC4A
[00fdcc2c] 4257                      clr.w      (a7)
[00fdcc2e] f66c                      dc.w       $F66C ; wind_update
[00fdcc30] 4e71                      nop
[00fdcc32] 5257                      addq.w     #1,(a7)
[00fdcc34] f180                      dc.w       $F180 ; wm_update
[00fdcc36] 4e71                      nop
[00fdcc38] 4e71                      nop
[00fdcc3a] 2e8f                      move.l     a7,(a7)
[00fdcc3c] 5897                      addq.l     #4,(a7)
[00fdcc3e] f110                      dc.w       $F110 ; ev_mesag
[00fdcc40] 4e71                      nop
[00fdcc42] 2d6f 000a 0008            move.l     10(a7),8(a6)
[00fdcc48] 609a                      bra.s      $00FDCBE4
[00fdcc4a] 4e5e                      unlk       a6
[00fdcc4c] 4e75                      rts
[00fdcc4e] 2079 0000 a792            movea.l    $0000A792,a0
[00fdcc54] 2268 0032                 movea.l    50(a0),a1
[00fdcc58] 4a68 0036                 tst.w      54(a0)
[00fdcc5c] 6706                      beq.s      $00FDCC64
[00fdcc5e] 0c51 0018                 cmpi.w     #$0018,(a1)
[00fdcc62] 4e75                      rts
[00fdcc64] 7001                      moveq.l    #1,d0
[00fdcc66] 4e75                      rts
