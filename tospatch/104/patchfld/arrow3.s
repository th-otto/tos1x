[00fde826] 102f 0009                 move.b     9(a7),d0
[00fde82a] 122f 0005                 move.b     5(a7),d1
[00fde82e] b300                      eor.b      d1,d0
[00fde830] c02f 0008                 and.b      8(a7),d0
[00fde834] 57c0                      seq        d0
[00fde836] c03c 0001                 and.b      #$01,d0
[00fde83a] b02f 0006                 cmp.b      6(a7),d0
[00fde83e] 56c0                      sne        d0
[00fde840] c07c 0001                 and.w      #$0001,d0
[00fde844] 671a                      beq.s      $00FDE860
[00fde846] 2057                      movea.l    (a7),a0
[00fde848] 0c68 2e87 fff2            cmpi.w     #$2E87,-14(a0)
[00fde84e] 6610                      bne.s      $00FDE860
[00fde850] 2239 0000 a792            move.l     $0000A792,d1
[00fde856] b2b9 0000 7060            cmp.l      $00007060,d1
[00fde85c] 6702                      beq.s      $00FDE860
[00fde85e] 7000                      moveq.l    #0,d0
[00fde860] 4e75                      rts
