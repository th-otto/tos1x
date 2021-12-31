[00fe0000] 31f9 00e0 001e 60fe       move.w     $00E0001E,($000060FE).w
[00fe0008] 2c3c 0000 0960            move.l     #$00000960,d6
[00fe000e] bcb8 04ba                 cmp.l      ($000004BA).w,d6
[00fe0012] 6322                      bls.s      $00FE0036
[00fe0014] dcb8 04ba                 add.l      ($000004BA).w,d6
[00fe0018] bcb8 04ba                 cmp.l      ($000004BA).w,d6
[00fe001c] 6318                      bls.s      $00FE0036
[00fe001e] 2f3c 0001 0002            move.l     #$00010002,-(a7)
[00fe0024] 4e4d                      trap       #13
[00fe0026] 588f                      addq.l     #4,a7
[00fe0028] 4a40                      tst.w      d0
[00fe002a] 67ec                      beq.s      $00FE0018
[00fe002c] 2f3c 0002 0002            move.l     #$00020002,-(a7)
[00fe0032] 4e4d                      trap       #13
[00fe0034] 588f                      addq.l     #4,a7
[00fe0036] 4e75                      rts
