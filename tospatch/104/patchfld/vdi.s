[00fce22a] 4878 0134                 pea.l      ($00000134).w
[00fce22e] 3f3c 0048                 move.w     #$0048,-(a7) ; Malloc
[00fce232] 4e41                      trap       #1
[00fce234] 5c8f                      addq.l     #6,a7
[00fce236] 4a80                      tst.l      d0
[00fce238] 660a                      bne.s      $00FCE244
[00fce23a] 2078 2ae0                 movea.l    ($00002AE0).w,a0
[00fce23e] 4268 000c                 clr.w      12(a0)
[00fce242] 4e75                      rts
[00fce244] 2240                      movea.l    d0,a1
[00fce246] 7001                      moveq.l    #1,d0
[00fce248] 7400                      moveq.l    #0,d2
[00fce24a] 45f8 3baa                 lea.l      ($00003BAA).w,a2
[00fce24e] 600c                      bra.s      $00FCE25C
[00fce250] 5240                      addq.w     #1,d0
[00fce252] 240a                      move.l     a2,d2
[00fce254] 222a 0040                 move.l     64(a2),d1
[00fce258] 670e                      beq.s      $00FCE268
[00fce25a] 2441                      movea.l    d1,a2
[00fce25c] b06a 0028                 cmp.w      40(a2),d0
[00fce260] 67ee                      beq.s      $00FCE250
[00fce262] 4a82                      tst.l      d2
[00fce264] 6702                      beq.s      $00FCE268
[00fce266] 2442                      movea.l    d2,a2
[00fce268] 236a 0040 0040            move.l     64(a2),64(a1)
[00fce26e] 2549 0040                 move.l     a1,64(a2)
[00fce272] 21c9 290c                 move.l     a1,($0000290C).w
[00fce276] 2078 2ae0                 movea.l    ($00002AE0).w,a0
[00fce27a] 3140 000c                 move.w     d0,12(a0)
[00fce27e] 3340 0028                 move.w     d0,40(a1)
[00fce282] 6000 fd96                 bra        $00FCE01A
[00fce286] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00fce28e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00fce296] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00fce29e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00fce2a6] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00fce2ae] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00fce2b6] ffff ffff ffff 0000       vperm      #$FFFF0000,e23,e23,e23
