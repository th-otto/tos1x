[00fe411e] 226f 0004                 movea.l    4(a7),a1
[00fe4122] 2449                      movea.l    a1,a2
[00fe4124] 4a19                      tst.b      (a1)+
[00fe4126] 66fc                      bne.s      $00FE4124
[00fe4128] 1021                      move.b     -(a1),d0
[00fe412a] b3ca                      cmpa.l     a2,a1
[00fe412c] 650c                      bcs.s      $00FE413A
[00fe412e] b03c 005c                 cmp.b      #$5C,d0
[00fe4132] 6706                      beq.s      $00FE413A
[00fe4134] b03c 003a                 cmp.b      #$3A,d0
[00fe4138] 66ee                      bne.s      $00FE4128
[00fe413a] 5289                      addq.l     #1,a1
[00fe413c] 2009                      move.l     a1,d0
[00fe413e] 4e75                      rts
[00fe4140] ffff ffff ffff ffff
[00fe4148] ffff
