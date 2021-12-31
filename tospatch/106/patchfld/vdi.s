[00e0e454] 4878 0134                 pea.l      ($00000134).w
[00e0e458] 3f3c 0048                 move.w     #$0048,-(a7) ; Malloc
[00e0e45c] 4e41                      trap       #1
[00e0e45e] 5c8f                      addq.l     #6,a7
[00e0e460] 4a80                      tst.l      d0
[00e0e462] 660a                      bne.s      $00E0E46E
[00e0e464] 2078 2b20                 movea.l    ($00002B20).w,a0
[00e0e468] 4268 000c                 clr.w      12(a0)
[00e0e46c] 4e75                      rts
[00e0e46e] 2240                      movea.l    d0,a1
[00e0e470] 7001                      moveq.l    #1,d0
[00e0e472] 7400                      moveq.l    #0,d2
[00e0e474] 45f8 3bea                 lea.l      ($00003BEA).w,a2
[00e0e478] 600c                      bra.s      $00E0E486
[00e0e47a] 5240                      addq.w     #1,d0
[00e0e47c] 240a                      move.l     a2,d2
[00e0e47e] 222a 0040                 move.l     64(a2),d1
[00e0e482] 670e                      beq.s      $00E0E492
[00e0e484] 2441                      movea.l    d1,a2
[00e0e486] b06a 0028                 cmp.w      40(a2),d0
[00e0e48a] 67ee                      beq.s      $00E0E47A
[00e0e48c] 4a82                      tst.l      d2
[00e0e48e] 6702                      beq.s      $00E0E492
[00e0e490] 2442                      movea.l    d2,a2
[00e0e492] 236a 0040 0040            move.l     64(a2),64(a1)
[00e0e498] 2549 0040                 move.l     a1,64(a2)
[00e0e49c] 21c9 294c                 move.l     a1,($0000294C).w
[00e0e4a0] 2078 2b20                 movea.l    ($00002B20).w,a0
[00e0e4a4] 3140 000c                 move.w     d0,12(a0)
[00e0e4a8] 3340 0028                 move.w     d0,40(a1)
[00e0e4ac] 6000 fd96                 bra        $00E0E244
[00e0e4b0] ffff ffff ffff ffff
[00e0e4b8] ffff ffff ffff ffff
[00e0e4c0] ffff ffff ffff ffff
[00e0e4c8] ffff ffff ffff ffff
[00e0e4d0] ffff ffff ffff ffff
[00e0e4d8] ffff ffff ffff ffff
[00e0e4e0] ffff ffff ffff
