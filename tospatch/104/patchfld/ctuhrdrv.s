[00fc1f70] 4280                      clr.l      d0
[00fc1f72] 4e75                      rts
[00fc1f74] 41fa 01be                 lea.l      $00FC2134(pc),a0
[00fc1f78] 47f9 00fe ff00            lea.l      $00FEFF00,a3
[00fc1f7e] 43eb 00ee                 lea.l      238(a3),a1
[00fc1f82] 7218                      moveq.l    #24,d1
[00fc1f84] 780a                      moveq.l    #10,d4
[00fc1f86] 46fc 2700                 move.w     #$2700,sr
[00fc1f8a] 4a11                      tst.b      (a1)
[00fc1f8c] 4a11                      tst.b      (a1)
[00fc1f8e] 4a11                      tst.b      (a1)
[00fc1f90] 4e75                      rts
[00fc1f92] ffff ffff ffff ffff
[00fc1f9a] ffff ffff ffff ffff
[00fc1fa2] ffff ffff ffff ffff
[00fc1faa] ffff ffff ffff ffff
[00fc1fb2] ffff ffff ffff ffff
[00fc1fba] ffff ffff ffff ffff
[00fc1fc2] 6000 0108                 bra        $00FC20CC
[00fc1fc6] ffff ffff ffff ffff
[00fc1fce] ffff ffff ffff ffff
[00fc1fd6] ffff ffff ffff ffff
[00fc1fde] ffff ffff ffff ffff
[00fc1fe6] ffff ffff ffff ffff
[00fc1fee] ffff ffff ffff ffff
[00fc1ff6] ffff ffff ffff ffff
[00fc1ffe] ffff ffff ffff ffff
[00fc2006] ffff ffff ffff ffff
[00fc200e] ffff ffff ffff ffff
[00fc2016] ffff ffff ffff ffff
[00fc201e] ffff ffff ffff ffff
[00fc2026] ffff ffff ffff ffff
[00fc202e] ffff ffff ffff ffff
[00fc2036] ffff ffff ffff ffff
[00fc203e] ffff ffff ffff ffff
[00fc2046] ffff ffff ffff ffff
[00fc204e] ffff ffff ffff ffff
[00fc2056] ffff ffff ffff ffff
[00fc205e] ffff ffff ffff ffff
[00fc2066] ffff ffff ffff ffff
[00fc206e] ffff ffff ffff ffff
[00fc2076] ffff ffff ffff ffff
[00fc207e] ffff
[00fc2080] 40e7                      move.w     sr,-(a7)
[00fc2082] 48e7 7c70                 movem.l    d1-d5/a1-a3,-(a7)
[00fc2086] 6100 feec                 bsr        $00FC1F74
[00fc208a] 43d3                      lea.l      (a3),a1
[00fc208c] 45eb 0060                 lea.l      96(a3),a2
[00fc2090] 7a00                      moveq.l    #0,d5
[00fc2092] 262f 0026                 move.l     38(a7),d3
[00fc2096] 1a18                      move.b     (a0)+,d5
[00fc2098] 6602                      bne.s      $00FC209C
[00fc209a] e303                      asl.b      #1,d3
[00fc209c] eaab                      lsr.l      d5,d3
[00fc209e] c628 0005                 and.b      5(a0),d3
[00fc20a2] 4883                      ext.w      d3
[00fc20a4] 48c3                      ext.l      d3
[00fc20a6] 86c4                      divu.w     d4,d3
[00fc20a8] 610a                      bsr.s      $00FC20B4
[00fc20aa] 4843                      swap       d3
[00fc20ac] 6106                      bsr.s      $00FC20B4
[00fc20ae] 4a41                      tst.w      d1
[00fc20b0] 6ade                      bpl.s      $00FC2090
[00fc20b2] 6046                      bra.s      $00FC20FA
[00fc20b4] b244                      cmp.w      d4,d1
[00fc20b6] 6604                      bne.s      $00FC20BC
[00fc20b8] 863c 0008                 or.b       #$08,d3
[00fc20bc] e30b                      lsl.b      #1,d3
[00fc20be] 1431 1000                 move.b     0(a1,d1.w),d2
[00fc20c2] 1432 1000                 move.b     0(a2,d1.w),d2
[00fc20c6] 1633 3020                 move.b     32(a3,d3.w),d3
[00fc20ca] 6056                      bra.s      $00FC2122
[00fc20cc] 40e7                      move.w     sr,-(a7)
[00fc20ce] 48e7 7c70                 movem.l    d1-d5/a1-a3,-(a7)
[00fc20d2] 6100 fea0                 bsr        $00FC1F74
[00fc20d6] 43eb 0080                 lea.l      128(a3),a1
[00fc20da] 45eb 00e0                 lea.l      224(a3),a2
[00fc20de] 7000                      moveq.l    #0,d0
[00fc20e0] 6124                      bsr.s      $00FC2106
[00fc20e2] c4c4                      mulu.w     d4,d2
[00fc20e4] 7600                      moveq.l    #0,d3
[00fc20e6] 1602                      move.b     d2,d3
[00fc20e8] 611c                      bsr.s      $00FC2106
[00fc20ea] d403                      add.b      d3,d2
[00fc20ec] 1618                      move.b     (a0)+,d3
[00fc20ee] 6602                      bne.s      $00FC20F2
[00fc20f0] e20a                      lsr.b      #1,d2
[00fc20f2] e7aa                      lsl.l      d3,d2
[00fc20f4] 8082                      or.l       d2,d0
[00fc20f6] 4a41                      tst.w      d1
[00fc20f8] 6ae6                      bpl.s      $00FC20E0
[00fc20fa] 4a39 00fe 0000            tst.b      $00FE0000
[00fc2100] 4cdf 0e3e                 movem.l    (a7)+,d1-d5/a1-a3
[00fc2104] 4e73                      rte
[00fc2106] 7400                      moveq.l    #0,d2
[00fc2108] 1431 1000                 move.b     0(a1,d1.w),d2
[00fc210c] 1432 1000                 move.b     0(a2,d1.w),d2
[00fc2110] 142b 00c0                 move.b     192(a3),d2
[00fc2114] 142b 00c0                 move.b     192(a3),d2
[00fc2118] 4602                      not.b      d2
[00fc211a] b244                      cmp.w      d4,d1
[00fc211c] 6604                      bne.s      $00FC2122
[00fc211e] c43c 0007                 and.b      #$07,d2
[00fc2122] 1a29 001e                 move.b     30(a1),d5
[00fc2126] 1a2b 00ee                 move.b     238(a3),d5
[00fc212a] 5541                      subq.w     #2,d1
[00fc212c] 0c41 000c                 cmpi.w     #$000C,d1
[00fc2130] 67f0                      beq.s      $00FC2122
[00fc2132] 4e75                      rts
[00fc2134] 1915
[00fc2136] 100b
[00fc2138] 0500
[00fc213a] 7f0f
[00fc213c] 1f1f
[00fc213e] 3f1f
[00fc2140] ffff ffff ffff ffff
[00fc2148] ffff ffff ffff ffff
[00fc2150] ffff ffff ffff ffff
[00fc2158] ffff ffff
