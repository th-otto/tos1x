[00e02148] 4280                      clr.l      d0
[00e0214a] 4e75                      rts
[00e0214c] 41fa 01be                 lea.l      $00E0230C(pc),a0
[00e02150] 47f9 00fe ff00            lea.l      $00FEFF00,a3
[00e02156] 43eb 00ee                 lea.l      238(a3),a1
[00e0215a] 7218                      moveq.l    #24,d1
[00e0215c] 780a                      moveq.l    #10,d4
[00e0215e] 46fc 2700                 move.w     #$2700,sr
[00e02162] 4a11                      tst.b      (a1)
[00e02164] 4a11                      tst.b      (a1)
[00e02166] 4a11                      tst.b      (a1)
[00e02168] 4e75                      rts
[00e0216a] ffff ffff ffff ffff
[00e02172] ffff ffff ffff ffff
[00e0217a] ffff ffff ffff ffff
[00e02182] ffff ffff ffff ffff
[00e0218a] ffff ffff ffff ffff
[00e02192] ffff ffff ffff ffff
[00e0219a] 6000 0108                 bra        $00E022A4
[00e0219e] ffff ffff ffff ffff
[00e021a6] ffff ffff ffff ffff
[00e021ae] ffff ffff ffff ffff
[00e021b6] ffff ffff ffff ffff
[00e021be] ffff ffff ffff ffff
[00e021c6] ffff ffff ffff ffff
[00e021ce] ffff ffff ffff ffff
[00e021d6] ffff ffff ffff ffff
[00e021de] ffff ffff ffff ffff
[00e021e6] ffff ffff ffff ffff
[00e021ee] ffff ffff ffff ffff
[00e021f6] ffff ffff ffff ffff
[00e021fe] ffff ffff ffff ffff
[00e02206] ffff ffff ffff ffff
[00e0220e] ffff ffff ffff ffff
[00e02216] ffff ffff ffff ffff
[00e0221e] ffff ffff ffff ffff
[00e02226] ffff ffff ffff ffff
[00e0222e] ffff ffff ffff ffff
[00e02236] ffff ffff ffff ffff
[00e0223e] ffff ffff ffff ffff
[00e02246] ffff ffff ffff ffff
[00e0224e] ffff ffff ffff ffff
[00e02256] ffff
[00e02258] 40e7                      move.w     sr,-(a7)
[00e0225a] 48e7 7c70                 movem.l    d1-d5/a1-a3,-(a7)
[00e0225e] 6100 feec                 bsr        $00E0214C
[00e02262] 43d3                      lea.l      (a3),a1
[00e02264] 45eb 0060                 lea.l      96(a3),a2
[00e02268] 7a00                      moveq.l    #0,d5
[00e0226a] 262f 0026                 move.l     38(a7),d3
[00e0226e] 1a18                      move.b     (a0)+,d5
[00e02270] 6602                      bne.s      $00E02274
[00e02272] e303                      asl.b      #1,d3
[00e02274] eaab                      lsr.l      d5,d3
[00e02276] c628 0005                 and.b      5(a0),d3
[00e0227a] 4883                      ext.w      d3
[00e0227c] 48c3                      ext.l      d3
[00e0227e] 86c4                      divu.w     d4,d3
[00e02280] 610a                      bsr.s      $00E0228C
[00e02282] 4843                      swap       d3
[00e02284] 6106                      bsr.s      $00E0228C
[00e02286] 4a41                      tst.w      d1
[00e02288] 6ade                      bpl.s      $00E02268
[00e0228a] 6046                      bra.s      $00E022D2
[00e0228c] b244                      cmp.w      d4,d1
[00e0228e] 6604                      bne.s      $00E02294
[00e02290] 863c 0008                 or.b       #$08,d3
[00e02294] e30b                      lsl.b      #1,d3
[00e02296] 1431 1000                 move.b     0(a1,d1.w),d2
[00e0229a] 1432 1000                 move.b     0(a2,d1.w),d2
[00e0229e] 1633 3020                 move.b     32(a3,d3.w),d3
[00e022a2] 6056                      bra.s      $00E022FA
[00e022a4] 40e7                      move.w     sr,-(a7)
[00e022a6] 48e7 7c70                 movem.l    d1-d5/a1-a3,-(a7)
[00e022aa] 6100 fea0                 bsr        $00E0214C
[00e022ae] 43eb 0080                 lea.l      128(a3),a1
[00e022b2] 45eb 00e0                 lea.l      224(a3),a2
[00e022b6] 7000                      moveq.l    #0,d0
[00e022b8] 6124                      bsr.s      $00E022DE
[00e022ba] c4c4                      mulu.w     d4,d2
[00e022bc] 7600                      moveq.l    #0,d3
[00e022be] 1602                      move.b     d2,d3
[00e022c0] 611c                      bsr.s      $00E022DE
[00e022c2] d403                      add.b      d3,d2
[00e022c4] 1618                      move.b     (a0)+,d3
[00e022c6] 6602                      bne.s      $00E022CA
[00e022c8] e20a                      lsr.b      #1,d2
[00e022ca] e7aa                      lsl.l      d3,d2
[00e022cc] 8082                      or.l       d2,d0
[00e022ce] 4a41                      tst.w      d1
[00e022d0] 6ae6                      bpl.s      $00E022B8
[00e022d2] 4a39 00fe 0000            tst.b      $00FE0000
[00e022d8] 4cdf 0e3e                 movem.l    (a7)+,d1-d5/a1-a3
[00e022dc] 4e73                      rte
[00e022de] 7400                      moveq.l    #0,d2
[00e022e0] 1431 1000                 move.b     0(a1,d1.w),d2
[00e022e4] 1432 1000                 move.b     0(a2,d1.w),d2
[00e022e8] 142b 00c0                 move.b     192(a3),d2
[00e022ec] 142b 00c0                 move.b     192(a3),d2
[00e022f0] 4602                      not.b      d2
[00e022f2] b244                      cmp.w      d4,d1
[00e022f4] 6604                      bne.s      $00E022FA
[00e022f6] c43c 0007                 and.b      #$07,d2
[00e022fa] 1a29 001e                 move.b     30(a1),d5
[00e022fe] 1a2b 00ee                 move.b     238(a3),d5
[00e02302] 5541                      subq.w     #2,d1
[00e02304] 0c41 000c                 cmpi.w     #$000C,d1
[00e02308] 67f0                      beq.s      $00E022FA
[00e0230a] 4e75                      rts
[00e0230c] 1915                      move.b     (a5),-(a4)
[00e0230e] 100b                      move.l     b3,d0 ; apollo only
[00e02310] 0500                      btst       d2,d0
[00e02312] 7f0f                      ???
[00e02314] 1f1f                      move.b     (a7)+,-(a7)
[00e02316] 3f1f                      move.w     (a7)+,-(a7)
[00e02318] ffff ffff ffff ffff
[00e02320] ffff ffff ffff ffff
[00e02328] ffff ffff ffff ffff
[00e02330] ffff ffff
