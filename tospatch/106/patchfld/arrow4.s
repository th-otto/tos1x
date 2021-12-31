[00fdffe6] 41f9 0000 6daf            lea.l      $00006DAF,a0
[00fdffec] 4240                      clr.w      d0
[00fdffee] 1010                      move.b     (a0),d0
[00fdfff0] 43ef 0006                 lea.l      6(a7),a1
[00fdfff4] 4a51                      tst.w      (a1)
[00fdfff6] 6726                      beq.s      $00FE001E
[00fdfff8] 1021                      move.b     -(a1),d0
[00fdfffa] 1080                      move.b     d0,(a0)
[00fdfffc] 4eb9 00fe 6514            jsr        $00FE6514
[00fe0002] 7200                      moveq.l    #0,d1
[00fe0004] 1200                      move.b     d0,d1
[00fe0006] 43f9 00fe b578            lea.l      $00FEB578,a1
[00fe000c] d2c1                      adda.w     d1,a1
[00fe000e] d2c1                      adda.w     d1,a1
[00fe0010] 3211                      move.w     (a1),d1
[00fe0012] 83f9 0000 6e18            divs.w     $00006E18,d1
[00fe0018] 33c1 0000 6d62            move.w     d1,$00006D62
[00fe001e] 4e75                      rts
