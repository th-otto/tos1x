	xdef _app_alloc
_app_alloc: ds.b 0
#if 0
[00fd4cb0] 4e56 0000                 link      a6,#0
[00fd4cb4] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fd4cb8] 3e2e 0008                 move.w    8(a6),d7
[00fd4cbc] 2679 0000 a788            movea.l   _thedesk,a3
[00fd4cc2] 2a6b 5a46                 movea.l   23110(a3),a5
[00fd4cc6] 200d                      move.l    a5,d0
[00fd4cc8] 672e                      beq.s     $00FD4CF8
[00fd4cca] 2755 5a46                 move.l    (a5),23110(a3)
[00fd4cce] 4a47                      tst.w     d7
[00fd4cd0] 6606                      bne.s     $00FD4CD8
[00fd4cd2] 4aab 5a4a                 tst.l     23114(a3)
[00fd4cd6] 660a                      bne.s     $00FD4CE2
[00fd4cd8] 2aab 5a4a                 move.l    23114(a3),(a5)
[00fd4cdc] 274d 5a4a                 move.l    a5,23114(a3)
[00fd4ce0] 6010                      bra.s     $00FD4CF2
[00fd4ce2] 286b 5a4a                 movea.l   23114(a3),a4
[00fd4ce6] 6002                      bra.s     $00FD4CEA
[00fd4ce8] 2854                      movea.l   (a4),a4
[00fd4cea] 4a94                      tst.l     (a4)
[00fd4cec] 66fa                      bne.s     $00FD4CE8
[00fd4cee] 288d                      move.l    a5,(a4)
[00fd4cf0] 4295                      clr.l     (a5)
[00fd4cf2] 200d                      move.l    a5,d0
[00fd4cf4] 6004                      bra.s     $00FD4CFA
[00fd4cf6] 6002                      bra.s     $00FD4CFA
[00fd4cf8] 4280                      clr.l     d0
[00fd4cfa] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef _app_free
_app_free: ds.b 0
#if 0
[00fd4cfc] 4e56 0000                 link      a6,#0
[00fd4d00] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd4d04] 2a6e 0008                 movea.l   8(a6),a5
[00fd4d08] 2679 0000 a788            movea.l   _thedesk,a3
[00fd4d0e] bbeb 5a4a                 cmpa.l    23114(a3),a5
[00fd4d12] 6606                      bne.s     $00FD4D1A
[00fd4d14] 2755 5a4a                 move.l    (a5),23114(a3)
[00fd4d18] 6016                      bra.s     $00FD4D30
[00fd4d1a] 286b 5a4a                 movea.l   23114(a3),a4
[00fd4d1e] 6002                      bra.s     $00FD4D22
[00fd4d20] 2854                      movea.l   (a4),a4
[00fd4d22] 200c                      move.l    a4,d0
[00fd4d24] 6704                      beq.s     $00FD4D2A
[00fd4d26] bbd4                      cmpa.l    (a4),a5
[00fd4d28] 66f6                      bne.s     $00FD4D20
[00fd4d2a] 200c                      move.l    a4,d0
[00fd4d2c] 6702                      beq.s     $00FD4D30
[00fd4d2e] 2895                      move.l    (a5),(a4)
[00fd4d30] 2aab 5a46                 move.l    23110(a3),(a5)
[00fd4d34] 274d 5a46                 move.l    a5,23110(a3)
[00fd4d38] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef _hex_dig
_hex_dig: ds.b 0
#if 0
[00fd4d3a] 4e56 0000                 link      a6,#0
[00fd4d3e] 48e7 0300                 movem.l   d6-d7,-(a7)
[00fd4d42] 1e2e 0009                 move.b    9(a6),d7
[00fd4d46] be3c 0030                 cmp.b     #$30,d7
[00fd4d4a] 6d10                      blt.s     $00FD4D5C
[00fd4d4c] be3c 0039                 cmp.b     #$39,d7
[00fd4d50] 6e0a                      bgt.s     $00FD4D5C
[00fd4d52] 1007                      move.b    d7,d0
[00fd4d54] 4880                      ext.w     d0
[00fd4d56] d07c ffd0                 add.w     #$FFD0,d0
[00fd4d5a] 6018                      bra.s     $00FD4D74
[00fd4d5c] be3c 0041                 cmp.b     #$41,d7
[00fd4d60] 6d10                      blt.s     $00FD4D72
[00fd4d62] be3c 0046                 cmp.b     #$46,d7
[00fd4d66] 6e0a                      bgt.s     $00FD4D72
[00fd4d68] 1007                      move.b    d7,d0
[00fd4d6a] 4880                      ext.w     d0
[00fd4d6c] d07c ffc9                 add.w     #$FFC9,d0
[00fd4d70] 6002                      bra.s     $00FD4D74
[00fd4d72] 4240                      clr.w     d0
[00fd4d74] f021                      dc.w      $F021 ; movem.l (a7)+,d7
#endif

	xdef _uhex_dig
_uhex_dig: ds.b 0
#if 0
[00fd4d76] 4e56 0000                 link      a6,#0
[00fd4d7a] 48e7 0300                 movem.l   d6-d7,-(a7)
[00fd4d7e] 3e2e 0008                 move.w    8(a6),d7
[00fd4d82] 4a47                      tst.w     d7
[00fd4d84] 6d0e                      blt.s     $00FD4D94
[00fd4d86] be7c 0009                 cmp.w     #$0009,d7
[00fd4d8a] 6e08                      bgt.s     $00FD4D94
[00fd4d8c] 3007                      move.w    d7,d0
[00fd4d8e] d07c 0030                 add.w     #$0030,d0
[00fd4d92] 6016                      bra.s     $00FD4DAA
[00fd4d94] be7c 000a                 cmp.w     #$000A,d7
[00fd4d98] 6d0e                      blt.s     $00FD4DA8
[00fd4d9a] be7c 000f                 cmp.w     #$000F,d7
[00fd4d9e] 6e08                      bgt.s     $00FD4DA8
[00fd4da0] 3007                      move.w    d7,d0
[00fd4da2] d07c 0037                 add.w     #$0037,d0
[00fd4da6] 6002                      bra.s     $00FD4DAA
[00fd4da8] 7020                      moveq.l   #32,d0
[00fd4daa] f021                      dc.w      $F021 ; movem.l (a7)+,d7
#endif

	xdef _scan_2
_scan_2: ds.b 0
#if 0
[00fd4dac] 4e56 0000                 link      a6,#0
[00fd4db0] 48e7 030c                 movem.l   d6-d7/a4-a5,-(a7)
[00fd4db4] 2a6e 0008                 movea.l   8(a6),a5
[00fd4db8] 286e 000c                 movea.l   12(a6),a4
[00fd4dbc] 4247                      clr.w     d7
[00fd4dbe] 101d                      move.b    (a5)+,d0
[00fd4dc0] 4880                      ext.w     d0
[00fd4dc2] 3e80                      move.w    d0,(a7)
[00fd4dc4] f31c                      dc.w      $F31C ; hex_dig
[00fd4dc6] e940                      asl.w     #4,d0
[00fd4dc8] 8e40                      or.w      d0,d7
[00fd4dca] 101d                      move.b    (a5)+,d0
[00fd4dcc] 4880                      ext.w     d0
[00fd4dce] 3e80                      move.w    d0,(a7)
[00fd4dd0] f31c                      dc.w      $F31C ; hex_dig
[00fd4dd2] 8e40                      or.w      d0,d7
[00fd4dd4] be7c 00ff                 cmp.w     #$00FF,d7
[00fd4dd8] 6602                      bne.s     $00FD4DDC
[00fd4dda] 7eff                      moveq.l   #-1,d7
[00fd4ddc] 3887                      move.w    d7,(a4)
[00fd4dde] 528d                      addq.l    #1,a5
[00fd4de0] 200d                      move.l    a5,d0
[00fd4de2] fc21                      dc.w      $FC21 ; movem.l (a7)+,d7/a4-a5
#endif

	xdef _save_2
_save_2: ds.b 0
#if 0
[00fd4de4] 4e56 0000                 link      a6,#0
[00fd4de8] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd4dec] 2a6e 0008                 movea.l   8(a6),a5
[00fd4df0] 302e 000c                 move.w    12(a6),d0
[00fd4df4] e848                      lsr.w     #4,d0
[00fd4df6] 3e80                      move.w    d0,(a7)
[00fd4df8] 0257 000f                 andi.w    #$000F,(a7)
[00fd4dfc] f320                      dc.w      $F320 ; uhex_dig
[00fd4dfe] 1ac0                      move.b    d0,(a5)+
[00fd4e00] 3eae 000c                 move.w    12(a6),(a7)
[00fd4e04] 0257 000f                 andi.w    #$000F,(a7)
[00fd4e08] f320                      dc.w      $F320 ; uhex_dig
[00fd4e0a] 1ac0                      move.b    d0,(a5)+
[00fd4e0c] 1afc 0020                 move.b    #$20,(a5)+
[00fd4e10] 200d                      move.l    a5,d0
[00fd4e12] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef _escan_str
_escan_str: ds.b 0
#if 0
[00fd4e14] 4e56 0000                 link      a6,#0
[00fd4e18] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd4e1c] 2a6e 0008                 movea.l   8(a6),a5
[00fd4e20] 286e 000c                 movea.l   12(a6),a4
[00fd4e24] 6002                      bra.s     $00FD4E28
[00fd4e26] 528d                      addq.l    #1,a5
[00fd4e28] 0c15 0020                 cmpi.b    #$20,(a5)
[00fd4e2c] 67f8                      beq.s     $00FD4E26
[00fd4e2e] 6002                      bra.s     $00FD4E32
[00fd4e30] 18dd                      move.b    (a5)+,(a4)+
[00fd4e32] 0c15 0040                 cmpi.b    #$40,(a5)
[00fd4e36] 66f8                      bne.s     $00FD4E30
[00fd4e38] 4214                      clr.b     (a4)
[00fd4e3a] 528d                      addq.l    #1,a5
[00fd4e3c] 200d                      move.l    a5,d0
[00fd4e3e] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef _escani_str
_escani_str: ds.b 0
#if 0
[00fd4e40] 4e56 0000                 link      a6,#0
[00fd4e44] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd4e48] 2a6e 0008                 movea.l   8(a6),a5
[00fd4e4c] 206e 000c                 movea.l   12(a6),a0
[00fd4e50] 2e90                      move.l    (a0),(a7)
[00fd4e52] 2f0d                      move.l    a5,-(a7)
[00fd4e54] f324                      dc.w      $F324 ; escan_str
[00fd4e56] 588f                      addq.l    #4,a7
[00fd4e58] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef _save_sstr
_save_sstr: ds.b 0
#if 0
[00fd4e5a] 4e56 0000                 link      a6,#0
[00fd4e5e] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd4e62] 2a6e 0008                 movea.l   8(a6),a5
[00fd4e66] 286e 000c                 movea.l   12(a6),a4
[00fd4e6a] 6002                      bra.s     $00FD4E6E
[00fd4e6c] 1adc                      move.b    (a4)+,(a5)+
[00fd4e6e] 4a14                      tst.b     (a4)
[00fd4e70] 6704                      beq.s     $00FD4E76
[00fd4e72] 200c                      move.l    a4,d0
[00fd4e74] 66f6                      bne.s     $00FD4E6C
[00fd4e76] 1afc 0040                 move.b    #$40,(a5)+
[00fd4e7a] 1afc 0020                 move.b    #$20,(a5)+
[00fd4e7e] 200d                      move.l    a5,d0
[00fd4e80] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef _inf_xdesk
_inf_xdesk: ds.b 0
#if 0
[00fd4e82] 4e56 0000                 link      a6,#0
[00fd4e86] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd4e8a] 2a6e 0008                 movea.l   8(a6),a5
[00fd4e8e] 286e 000c                 movea.l   12(a6),a4
[00fd4e92] 1015                      move.b    (a5),d0
[00fd4e94] 4880                      ext.w     d0
[00fd4e96] 6054                      bra.s     $00FD4EEC
[00fd4e98] 397c 0003 0006            move.w    #$0003,6(a4)
[00fd4e9e] 397c 0007 0004            move.w    #$0007,4(a4)
[00fd4ea4] 605e                      bra.s     $00FD4F04
[00fd4ea6] 397c 0002 0006            move.w    #$0002,6(a4)
[00fd4eac] 397c 0007 0004            move.w    #$0007,4(a4)
[00fd4eb2] 6050                      bra.s     $00FD4F04
[00fd4eb4] 397c 0004 0006            move.w    #$0004,6(a4)
[00fd4eba] 397c 0007 0004            move.w    #$0007,4(a4)
[00fd4ec0] 6042                      bra.s     $00FD4F04
[00fd4ec2] 426c 0006                 clr.w     6(a4)
[00fd4ec6] 397c 0003 0004            move.w    #$0003,4(a4)
[00fd4ecc] 6036                      bra.s     $00FD4F04
[00fd4ece] 426c 0006                 clr.w     6(a4)
[00fd4ed2] 426c 0004                 clr.w     4(a4)
[00fd4ed6] 602c                      bra.s     $00FD4F04
[00fd4ed8] 426c 0006                 clr.w     6(a4)
[00fd4edc] 397c 0008 0004            move.w    #$0008,4(a4)
[00fd4ee2] 6020                      bra.s     $00FD4F04
[00fd4ee4] 397c 0001 0006            move.w    #1,6(a4)
[00fd4eea] 6018                      bra.s     $00FD4F04
[00fd4eec] 907c 0043                 sub.w     #$0043,d0
[00fd4ef0] b07c 0011                 cmp.w     #$0011,d0
[00fd4ef4] 620e                      bhi.s     $00FD4F04
[00fd4ef6] e540                      asl.w     #2,d0
[00fd4ef8] 3040                      movea.w   d0,a0
[00fd4efa] d1fc 00fe b074            adda.l    #$00FEB074,a0
[00fd4f00] 2050                      movea.l   (a0),a0
[00fd4f02] 4ed0                      jmp       (a0)
[00fd4f04] 548d                      addq.l    #2,a5
[00fd4f06] 082c 0002 0005            btst      #2,5(a4)
[00fd4f0c] 6718                      beq.s     $00FD4F26
[00fd4f0e] 486c 0018                 pea.l     24(a4)
[00fd4f12] 2f0d                      move.l    a5,-(a7)
[00fd4f14] f328                      dc.w      $F328 ; scan_2
[00fd4f16] 508f                      addq.l    #8,a7
[00fd4f18] 2a40                      movea.l   d0,a5
[00fd4f1a] 486c 001a                 pea.l     26(a4)
[00fd4f1e] 2f0d                      move.l    a5,-(a7)
[00fd4f20] f328                      dc.w      $F328 ; scan_2
[00fd4f22] 508f                      addq.l    #8,a7
[00fd4f24] 2a40                      movea.l   d0,a5
[00fd4f26] 486c 0012                 pea.l     18(a4)
[00fd4f2a] 2f0d                      move.l    a5,-(a7)
[00fd4f2c] f328                      dc.w      $F328 ; scan_2
[00fd4f2e] 508f                      addq.l    #8,a7
[00fd4f30] 2a40                      movea.l   d0,a5
[00fd4f32] 486c 0014                 pea.l     20(a4)
[00fd4f36] 2f0d                      move.l    a5,-(a7)
[00fd4f38] f328                      dc.w      $F328 ; scan_2
[00fd4f3a] 508f                      addq.l    #8,a7
[00fd4f3c] 2a40                      movea.l   d0,a5
[00fd4f3e] 0c15 0020                 cmpi.b    #$20,(a5)
[00fd4f42] 6604                      bne.s     $00FD4F48
[00fd4f44] 4240                      clr.w     d0
[00fd4f46] 6004                      bra.s     $00FD4F4C
[00fd4f48] 1015                      move.b    (a5),d0
[00fd4f4a] 4880                      ext.w     d0
[00fd4f4c] 3940 0016                 move.w    d0,22(a4)
[00fd4f50] 548d                      addq.l    #2,a5
[00fd4f52] 486c 000a                 pea.l     10(a4)
[00fd4f56] 2f0d                      move.l    a5,-(a7)
[00fd4f58] f32c                      dc.w      $F32C ; escani_str
[00fd4f5a] 508f                      addq.l    #8,a7
[00fd4f5c] 2a40                      movea.l   d0,a5
[00fd4f5e] 486c 000e                 pea.l     14(a4)
[00fd4f62] 2f0d                      move.l    a5,-(a7)
[00fd4f64] f32c                      dc.w      $F32C ; escani_str
[00fd4f66] 508f                      addq.l    #8,a7
[00fd4f68] 2a40                      movea.l   d0,a5
[00fd4f6a] 200d                      move.l    a5,d0
[00fd4f6c] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef _app_mtoi
_app_mtoi: ds.b 0
#if 0
[00fd4f6e] 4e56 fffc                 link      a6,#$FFFC
[00fd4f72] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fd4f76] 2a6e 000c                 movea.l   12(a6),a5
[00fd4f7a] 286e 0010                 movea.l   16(a6),a4
[00fd4f7e] 2679 0000 a788            movea.l   _thedesk,a3
[00fd4f84] 3a2b 35ac                 move.w    13740(a3),d5
[00fd4f88] 3e2e 0008                 move.w    8(a6),d7
[00fd4f8c] 48c7                      ext.l     d7
[00fd4f8e] 8fc5                      divs.w    d5,d7
[00fd4f90] 302e 0008                 move.w    8(a6),d0
[00fd4f94] 48c0                      ext.l     d0
[00fd4f96] 81c5                      divs.w    d5,d0
[00fd4f98] 4840                      swap      d0
[00fd4f9a] 3d40 fffe                 move.w    d0,-2(a6)
[00fd4f9e] 3005                      move.w    d5,d0
[00fd4fa0] 48c0                      ext.l     d0
[00fd4fa2] 81fc 0002                 divs.w    #$0002,d0
[00fd4fa6] b06e fffe                 cmp.w     -2(a6),d0
[00fd4faa] 6c0c                      bge.s     $00FD4FB8
[00fd4fac] 3005                      move.w    d5,d0
[00fd4fae] 3207                      move.w    d7,d1
[00fd4fb0] 5241                      addq.w    #1,d1
[00fd4fb2] c1c1                      muls.w    d1,d0
[00fd4fb4] 3a80                      move.w    d0,(a5)
[00fd4fb6] 6006                      bra.s     $00FD4FBE
[00fd4fb8] 3007                      move.w    d7,d0
[00fd4fba] c1c5                      muls.w    d5,d0
[00fd4fbc] 3a80                      move.w    d0,(a5)
[00fd4fbe] 3eb9 0000 7008            move.w    gl_width,(a7)
[00fd4fc4] 3005                      move.w    d5,d0
[00fd4fc6] 9157                      sub.w     d0,(a7)
[00fd4fc8] 3f15                      move.w    (a5),-(a7)
[00fd4fca] f330                      dc.w      $F330 ; min
[00fd4fcc] 548f                      addq.l    #2,a7
[00fd4fce] 3a80                      move.w    d0,(a5)
[00fd4fd0] 3039 0000 7008            move.w    gl_width,d0
[00fd4fd6] 48c0                      ext.l     d0
[00fd4fd8] 81fc 0002                 divs.w    #$0002,d0
[00fd4fdc] b055                      cmp.w     (a5),d0
[00fd4fde] 6c0e                      bge.s     $00FD4FEE
[00fd4fe0] 3039 0000 7008            move.w    gl_width,d0
[00fd4fe6] 48c0                      ext.l     d0
[00fd4fe8] 81c5                      divs.w    d5,d0
[00fd4fea] 4840                      swap      d0
[00fd4fec] d155                      add.w     d0,(a5)
[00fd4fee] 302b 343c                 move.w    13372(a3),d0
[00fd4ff2] 916e 000a                 sub.w     d0,10(a6)
[00fd4ff6] 382b 35ae                 move.w    13742(a3),d4
[00fd4ffa] 3c2e 000a                 move.w    10(a6),d6
[00fd4ffe] 48c6                      ext.l     d6
[00fd5000] 8dc4                      divs.w    d4,d6
[00fd5002] 302e 000a                 move.w    10(a6),d0
[00fd5006] 48c0                      ext.l     d0
[00fd5008] 81c4                      divs.w    d4,d0
[00fd500a] 4840                      swap      d0
[00fd500c] 3d40 fffc                 move.w    d0,-4(a6)
[00fd5010] 3004                      move.w    d4,d0
[00fd5012] 48c0                      ext.l     d0
[00fd5014] 81fc 0002                 divs.w    #$0002,d0
[00fd5018] b06e fffc                 cmp.w     -4(a6),d0
[00fd501c] 6c0c                      bge.s     $00FD502A
[00fd501e] 3004                      move.w    d4,d0
[00fd5020] 3206                      move.w    d6,d1
[00fd5022] 5241                      addq.w    #1,d1
[00fd5024] c1c1                      muls.w    d1,d0
[00fd5026] 3880                      move.w    d0,(a4)
[00fd5028] 6006                      bra.s     $00FD5030
[00fd502a] 3006                      move.w    d6,d0
[00fd502c] c1c4                      muls.w    d4,d0
[00fd502e] 3880                      move.w    d0,(a4)
[00fd5030] 3eab 3440                 move.w    13376(a3),(a7)
[00fd5034] 3004                      move.w    d4,d0
[00fd5036] 9157                      sub.w     d0,(a7)
[00fd5038] 3f14                      move.w    (a4),-(a7)
[00fd503a] f330                      dc.w      $F330 ; min
[00fd503c] 548f                      addq.l    #2,a7
[00fd503e] 3880                      move.w    d0,(a4)
[00fd5040] 302b 3440                 move.w    13376(a3),d0
[00fd5044] 48c0                      ext.l     d0
[00fd5046] 81fc 0002                 divs.w    #$0002,d0
[00fd504a] b054                      cmp.w     (a4),d0
[00fd504c] 6c0c                      bge.s     $00FD505A
[00fd504e] 302b 3440                 move.w    13376(a3),d0
[00fd5052] 48c0                      ext.l     d0
[00fd5054] 81c4                      divs.w    d4,d0
[00fd5056] 4840                      swap      d0
[00fd5058] d154                      add.w     d0,(a4)
[00fd505a] 302b 343c                 move.w    13372(a3),d0
[00fd505e] d154                      add.w     d0,(a4)
[00fd5060] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef _read_inf
_read_inf: ds.b 0
#if 0
[00fd5062] 4e56 ffe8                 link      a6,#$FFE8
[00fd5066] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd506a] 2679 0000 a788            movea.l   _thedesk,a3
[00fd5070] 41eb 4662                 lea.l     18018(a3),a0
[00fd5074] 2748 56c2                 move.l    a0,22210(a3)
[00fd5078] 41eb 4662                 lea.l     18018(a3),a0
[00fd507c] 2d48 fff6                 move.l    a0,-10(a6)
[00fd5080] 7e1f                      moveq.l   #31,d7
[00fd5082] 604e                      bra.s     $00FD50D2
[00fd5084] 200b                      move.l    a3,d0
[00fd5086] 3207                      move.w    d7,d1
[00fd5088] 5241                      addq.w    #1,d1
[00fd508a] c3fc 001c                 muls.w    #$001C,d1
[00fd508e] d081                      add.l     d1,d0
[00fd5090] d0bc 0000 56c6            add.l     #$000056C6,d0
[00fd5096] 224b                      movea.l   a3,a1
[00fd5098] 3407                      move.w    d7,d2
[00fd509a] c5fc 001c                 muls.w    #$001C,d2
[00fd509e] d3c2                      adda.l    d2,a1
[00fd50a0] 2340 56c6                 move.l    d0,22214(a1)
[00fd50a4] 204b                      movea.l   a3,a0
[00fd50a6] 3207                      move.w    d7,d1
[00fd50a8] c3fc 001c                 muls.w    #$001C,d1
[00fd50ac] d1c1                      adda.l    d1,a0
[00fd50ae] 216e fff6 56d0            move.l    -10(a6),22224(a0)
[00fd50b4] 06ae 0000 0079 fff6       addi.l    #$00000079,-10(a6)
[00fd50bc] 204b                      movea.l   a3,a0
[00fd50be] 3207                      move.w    d7,d1
[00fd50c0] c3fc 001c                 muls.w    #$001C,d1
[00fd50c4] d1c1                      adda.l    d1,a0
[00fd50c6] 216e fff6 56d4            move.l    -10(a6),22228(a0)
[00fd50cc] 5cae fff6                 addq.l    #6,-10(a6)
[00fd50d0] 5347                      subq.w    #1,d7
[00fd50d2] 4a47                      tst.w     d7
[00fd50d4] 6cae                      bge.s     $00FD5084
[00fd50d6] 42ab 5a4a                 clr.l     23114(a3)
[00fd50da] 41eb 56c6                 lea.l     22214(a3),a0
[00fd50de] 2748 5a46                 move.l    a0,23110(a3)
[00fd50e2] 42ab 5a2a                 clr.l     23082(a3)
[00fd50e6] 3ebc 1060                 move.w    #$1060,(a7)
[00fd50ea] 486b 3600                 pea.l     13824(a3)
[00fd50ee] f334                      dc.w      $F334 ; shel_get
[00fd50f0] 588f                      addq.l    #4,a7
[00fd50f2] 0c2b 0023 3600            cmpi.b    #$23,13824(a3)
[00fd50f8] 675c                      beq.s     $00FD5156
[00fd50fa] f338                      dc.w      $F338 ; isdrive
[00fd50fc] 4a40                      tst.w     d0
[00fd50fe] 6738                      beq.s     $00FD5138
[00fd5100] 3ebc 0002                 move.w    #$0002,(a7)
[00fd5104] 2f3c 00fe b068            move.l    #$00FEB068,-(a7)
[00fd510a] f33c                      dc.w      $F33C ; dos_open
[00fd510c] 588f                      addq.l    #4,a7
[00fd510e] 3d40 fff4                 move.w    d0,-12(a6)
[00fd5112] 4a6e fff4                 tst.w     -12(a6)
[00fd5116] 6f1c                      ble.s     $00FD5134
[00fd5118] 486b 3600                 pea.l     13824(a3)
[00fd511c] 3f3c 1060                 move.w    #$1060,-(a7)
[00fd5120] 3f2e fff4                 move.w    -12(a6),-(a7)
[00fd5124] f340                      dc.w      $F340 ; dos_read
[00fd5126] 508f                      addq.l    #8,a7
[00fd5128] 3740 4660                 move.w    d0,18016(a3)
[00fd512c] 3eae fff4                 move.w    -12(a6),(a7)
[00fd5130] f344                      dc.w      $F344 ; dos_close
[00fd5132] 6002                      bra.s     $00FD5136
[00fd5134] 6002                      bra.s     $00FD5138
[00fd5136] 6012                      bra.s     $00FD514A
[00fd5138] 4257                      clr.w     (a7)
[00fd513a] 486b 3600                 pea.l     13824(a3)
[00fd513e] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd5142] f348                      dc.w      $F348 ; rom_ram
[00fd5144] 5c8f                      addq.l    #6,a7
[00fd5146] 3740 4660                 move.w    d0,18016(a3)
[00fd514a] 204b                      movea.l   a3,a0
[00fd514c] 326b 4660                 movea.w   18016(a3),a1
[00fd5150] d1c9                      adda.l    a1,a0
[00fd5152] 4228 3600                 clr.b     13824(a0)
[00fd5156] 4247                      clr.w     d7
[00fd5158] 49eb 3600                 lea.l     13824(a3),a4
[00fd515c] 6000 0234                 bra       $00FD5392
[00fd5160] 0c14 0023                 cmpi.b    #$23,(a4)
[00fd5164] 6706                      beq.s     $00FD516C
[00fd5166] 528c                      addq.l    #1,a4
[00fd5168] 6000 0228                 bra       $00FD5392
[00fd516c] 528c                      addq.l    #1,a4
[00fd516e] 1014                      move.b    (a4),d0
[00fd5170] 4880                      ext.w     d0
[00fd5172] 6000 0206                 bra       $00FD537A
[00fd5176] 548c                      addq.l    #2,a4
[00fd5178] 486b 76e8                 pea.l     30440(a3)
[00fd517c] 2f0c                      move.l    a4,-(a7)
[00fd517e] f324                      dc.w      $F324 ; escan_str
[00fd5180] 508f                      addq.l    #8,a7
[00fd5182] 2840                      movea.l   d0,a4
[00fd5184] 6000 020c                 bra       $00FD5392
[00fd5188] f34c                      dc.w      $F34C ; cart_init
[00fd518a] 4a40                      tst.w     d0
[00fd518c] 661c                      bne.s     $00FD51AA
[00fd518e] 6000 0202                 bra       $00FD5392
[00fd5192] f338                      dc.w      $F338 ; isdrive
[00fd5194] 3c00                      move.w    d0,d6
[00fd5196] 6700 01fa                 beq       $00FD5392
[00fd519a] 0c2c 0043 000e            cmpi.b    #$43,14(a4)
[00fd51a0] 6608                      bne.s     $00FD51AA
[00fd51a2] 0806 0002                 btst      #2,d6
[00fd51a6] 6700 01ea                 beq       $00FD5392
[00fd51aa] 3ebc 0001                 move.w    #1,(a7)
[00fd51ae] f350                      dc.w      $F350 ; app_alloc
[00fd51b0] 2d40 fffc                 move.l    d0,-4(a6)
[00fd51b4] 670e                      beq.s     $00FD51C4
[00fd51b6] 2eae fffc                 move.l    -4(a6),(a7)
[00fd51ba] 2f0c                      move.l    a4,-(a7)
[00fd51bc] f354                      dc.w      $F354 ; inf_xdesk
[00fd51be] 588f                      addq.l    #4,a7
[00fd51c0] 2840                      movea.l   d0,a4
[00fd51c2] 6004                      bra.s     $00FD51C8
[00fd51c4] 6000 01d2                 bra       $00FD5398
[00fd51c8] 6000 01c8                 bra       $00FD5392
[00fd51cc] 548c                      addq.l    #2,a4
[00fd51ce] 2a4b                      movea.l   a3,a5
[00fd51d0] 3007                      move.w    d7,d0
[00fd51d2] c1fc 0088                 muls.w    #$0088,d0
[00fd51d6] dbc0                      adda.l    d0,a5
[00fd51d8] dbfc 0000 5c0c            adda.l    #$00005C0C,a5
[00fd51de] 5247                      addq.w    #1,d7
[00fd51e0] 486d 0008                 pea.l     8(a5)
[00fd51e4] 2f0c                      move.l    a4,-(a7)
[00fd51e6] f328                      dc.w      $F328 ; scan_2
[00fd51e8] 508f                      addq.l    #8,a7
[00fd51ea] 2840                      movea.l   d0,a4
[00fd51ec] 486d 000a                 pea.l     10(a5)
[00fd51f0] 2f0c                      move.l    a4,-(a7)
[00fd51f2] f328                      dc.w      $F328 ; scan_2
[00fd51f4] 508f                      addq.l    #8,a7
[00fd51f6] 2840                      movea.l   d0,a4
[00fd51f8] 2e8d                      move.l    a5,(a7)
[00fd51fa] 2f0c                      move.l    a4,-(a7)
[00fd51fc] f328                      dc.w      $F328 ; scan_2
[00fd51fe] 588f                      addq.l    #4,a7
[00fd5200] 2840                      movea.l   d0,a4
[00fd5202] 3015                      move.w    (a5),d0
[00fd5204] b079 0000 6e24            cmp.w     $00006E24,d0
[00fd520a] 6d0a                      blt.s     $00FD5216
[00fd520c] 3015                      move.w    (a5),d0
[00fd520e] 48c0                      ext.l     d0
[00fd5210] 81fc 0002                 divs.w    #$0002,d0
[00fd5214] 3a80                      move.w    d0,(a5)
[00fd5216] 3015                      move.w    (a5),d0
[00fd5218] c1f9 0000 6dce            muls.w    $00006DCE,d0
[00fd521e] 3a80                      move.w    d0,(a5)
[00fd5220] 486d 0002                 pea.l     2(a5)
[00fd5224] 2f0c                      move.l    a4,-(a7)
[00fd5226] f328                      dc.w      $F328 ; scan_2
[00fd5228] 508f                      addq.l    #8,a7
[00fd522a] 2840                      movea.l   d0,a4
[00fd522c] 302d 0002                 move.w    2(a5),d0
[00fd5230] c1f9 0000 6ce2            muls.w    $00006CE2,d0
[00fd5236] 3b40 0002                 move.w    d0,2(a5)
[00fd523a] 486d 0004                 pea.l     4(a5)
[00fd523e] 2f0c                      move.l    a4,-(a7)
[00fd5240] f328                      dc.w      $F328 ; scan_2
[00fd5242] 508f                      addq.l    #8,a7
[00fd5244] 2840                      movea.l   d0,a4
[00fd5246] 302d 0004                 move.w    4(a5),d0
[00fd524a] b079 0000 6e24            cmp.w     $00006E24,d0
[00fd5250] 6f0e                      ble.s     $00FD5260
[00fd5252] 302d 0004                 move.w    4(a5),d0
[00fd5256] 48c0                      ext.l     d0
[00fd5258] 81fc 0002                 divs.w    #$0002,d0
[00fd525c] 3b40 0004                 move.w    d0,4(a5)
[00fd5260] 302d 0004                 move.w    4(a5),d0
[00fd5264] c1f9 0000 6dce            muls.w    $00006DCE,d0
[00fd526a] 3b40 0004                 move.w    d0,4(a5)
[00fd526e] 3039 0000 705a            move.w    $0000705A,d0
[00fd5274] c1fc 0007                 muls.w    #$0007,d0
[00fd5278] b06d 0004                 cmp.w     4(a5),d0
[00fd527c] 6f0e                      ble.s     $00FD528C
[00fd527e] 3039 0000 705a            move.w    $0000705A,d0
[00fd5284] c1fc 0007                 muls.w    #$0007,d0
[00fd5288] 3b40 0004                 move.w    d0,4(a5)
[00fd528c] 486d 0006                 pea.l     6(a5)
[00fd5290] 2f0c                      move.l    a4,-(a7)
[00fd5292] f328                      dc.w      $F328 ; scan_2
[00fd5294] 508f                      addq.l    #8,a7
[00fd5296] 2840                      movea.l   d0,a4
[00fd5298] 302d 0006                 move.w    6(a5),d0
[00fd529c] c1f9 0000 6ce2            muls.w    $00006CE2,d0
[00fd52a2] 3b40 0006                 move.w    d0,6(a5)
[00fd52a6] 3039 0000 6f18            move.w    $00006F18,d0
[00fd52ac] c1fc 0007                 muls.w    #$0007,d0
[00fd52b0] b06d 0006                 cmp.w     6(a5),d0
[00fd52b4] 6f0e                      ble.s     $00FD52C4
[00fd52b6] 3039 0000 6f18            move.w    $00006F18,d0
[00fd52bc] c1fc 0007                 muls.w    #$0007,d0
[00fd52c0] 3b40 0006                 move.w    d0,6(a5)
[00fd52c4] 486d 000c                 pea.l     12(a5)
[00fd52c8] 2f0c                      move.l    a4,-(a7)
[00fd52ca] f328                      dc.w      $F328 ; scan_2
[00fd52cc] 508f                      addq.l    #8,a7
[00fd52ce] 2840                      movea.l   d0,a4
[00fd52d0] 41ed 000e                 lea.l     14(a5),a0
[00fd52d4] 2d48 fff6                 move.l    a0,-10(a6)
[00fd52d8] 600a                      bra.s     $00FD52E4
[00fd52da] 206e fff6                 movea.l   -10(a6),a0
[00fd52de] 109c                      move.b    (a4)+,(a0)
[00fd52e0] 52ae fff6                 addq.l    #1,-10(a6)
[00fd52e4] 0c14 0040                 cmpi.b    #$40,(a4)
[00fd52e8] 66f0                      bne.s     $00FD52DA
[00fd52ea] 206e fff6                 movea.l   -10(a6),a0
[00fd52ee] 4210                      clr.b     (a0)
[00fd52f0] 6000 00a0                 bra       $00FD5392
[00fd52f4] 548c                      addq.l    #2,a4
[00fd52f6] 486e fff2                 pea.l     -14(a6)
[00fd52fa] 2f0c                      move.l    a4,-(a7)
[00fd52fc] f328                      dc.w      $F328 ; scan_2
[00fd52fe] 508f                      addq.l    #8,a7
[00fd5300] 2840                      movea.l   d0,a4
[00fd5302] 082e 0007 fff3            btst      #7,-13(a6)
[00fd5308] 6604                      bne.s     $00FD530E
[00fd530a] 4240                      clr.w     d0
[00fd530c] 6002                      bra.s     $00FD5310
[00fd530e] 7001                      moveq.l   #1,d0
[00fd5310] 3740 5c00                 move.w    d0,23552(a3)
[00fd5314] 302e fff2                 move.w    -14(a6),d0
[00fd5318] c07c 0060                 and.w     #$0060,d0
[00fd531c] ea40                      asr.w     #5,d0
[00fd531e] 3740 5bfe                 move.w    d0,23550(a3)
[00fd5322] 082e 0004 fff3            btst      #4,-13(a6)
[00fd5328] 6604                      bne.s     $00FD532E
[00fd532a] 4240                      clr.w     d0
[00fd532c] 6002                      bra.s     $00FD5330
[00fd532e] 7001                      moveq.l   #1,d0
[00fd5330] 3740 5c04                 move.w    d0,23556(a3)
[00fd5334] 082e 0003 fff3            btst      #3,-13(a6)
[00fd533a] 6604                      bne.s     $00FD5340
[00fd533c] 4240                      clr.w     d0
[00fd533e] 6002                      bra.s     $00FD5342
[00fd5340] 7001                      moveq.l   #1,d0
[00fd5342] 3740 5c02                 move.w    d0,23554(a3)
[00fd5346] 302e fff2                 move.w    -14(a6),d0
[00fd534a] c07c 0001                 and.w     #1,d0
[00fd534e] 3740 5c0a                 move.w    d0,23562(a3)
[00fd5352] 486e fff2                 pea.l     -14(a6)
[00fd5356] 2f0c                      move.l    a4,-(a7)
[00fd5358] f328                      dc.w      $F328 ; scan_2
[00fd535a] 508f                      addq.l    #8,a7
[00fd535c] 2840                      movea.l   d0,a4
[00fd535e] 302e fff2                 move.w    -14(a6),d0
[00fd5362] c07c 00f0                 and.w     #$00F0,d0
[00fd5366] e840                      asr.w     #4,d0
[00fd5368] 3740 5c06                 move.w    d0,23558(a3)
[00fd536c] 3039 0000 6122            move.w    $00006122,d0
[00fd5372] 5340                      subq.w    #1,d0
[00fd5374] 3740 5c08                 move.w    d0,23560(a3)
[00fd5378] 6018                      bra.s     $00FD5392
[00fd537a] 907c 0043                 sub.w     #$0043,d0
[00fd537e] b07c 0017                 cmp.w     #$0017,d0
[00fd5382] 620e                      bhi.s     $00FD5392
[00fd5384] e540                      asl.w     #2,d0
[00fd5386] 3040                      movea.w   d0,a0
[00fd5388] d1fc 00fe b0bc            adda.l    #$00FEB0BC,a0
[00fd538e] 2050                      movea.l   (a0),a0
[00fd5390] 4ed0                      jmp       (a0)
[00fd5392] 4a14                      tst.b     (a4)
[00fd5394] 6600 fdca                 bne       $00FD5160
[00fd5398] 3d7c 00cc ffe8            move.w    #$00CC,-24(a6)
[00fd539e] 486e ffea                 pea.l     -22(a6)
[00fd53a2] 4267                      clr.w     -(a7)
[00fd53a4] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd53a8] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fd53aa] 508f                      addq.l    #8,a7
[00fd53ac] 3eae ffe8                 move.w    -24(a6),(a7)
[00fd53b0] 2f2e ffea                 move.l    -22(a6),-(a7)
[00fd53b4] 486b 5a4e                 pea.l     23118(a3)
[00fd53b8] f268                      dc.w      $F268 ; LBCOPY
[00fd53ba] 508f                      addq.l    #8,a7
[00fd53bc] 3eae ffe8                 move.w    -24(a6),(a7)
[00fd53c0] 2f2e ffea                 move.l    -22(a6),-(a7)
[00fd53c4] 486b 5b1a                 pea.l     23322(a3)
[00fd53c8] f268                      dc.w      $F268 ; LBCOPY
[00fd53ca] 508f                      addq.l    #8,a7
[00fd53cc] 377c 0005 5a5c            move.w    #$0005,23132(a3)
[00fd53d2] 377c 000e 5a5e            move.w    #$000E,23134(a3)
[00fd53d8] 377c 0005 5b28            move.w    #$0005,23336(a3)
[00fd53de] 377c 000e 5b2a            move.w    #$000E,23338(a3)
[00fd53e4] 302b 5a68                 move.w    23144(a3),d0
[00fd53e8] e340                      asl.w     #1,d0
[00fd53ea] d06b 5a6c                 add.w     23148(a3),d0
[00fd53ee] 3740 35fc                 move.w    d0,13820(a3)
[00fd53f2] 302b 5a66                 move.w    23142(a3),d0
[00fd53f6] d06b 5a6e                 add.w     23150(a3),d0
[00fd53fa] 5440                      addq.w    #2,d0
[00fd53fc] 3740 35fe                 move.w    d0,13822(a3)
[00fd5400] 0c79 012c 0000 6d90       cmpi.w    #$012C,gl_height
[00fd5408] 6e04                      bgt.s     $00FD540E
[00fd540a] 4240                      clr.w     d0
[00fd540c] 6002                      bra.s     $00FD5410
[00fd540e] 7008                      moveq.l   #8,d0
[00fd5410] 3740 35ac                 move.w    d0,13740(a3)
[00fd5414] 302b 35fc                 move.w    13820(a3),d0
[00fd5418] d16b 35ac                 add.w     d0,13740(a3)
[00fd541c] 3039 0000 7008            move.w    gl_width,d0
[00fd5422] 48c0                      ext.l     d0
[00fd5424] 81eb 35ac                 divs.w    13740(a3),d0
[00fd5428] 3d40 fff0                 move.w    d0,-16(a6)
[00fd542c] 3039 0000 7008            move.w    gl_width,d0
[00fd5432] 48c0                      ext.l     d0
[00fd5434] 81eb 35ac                 divs.w    13740(a3),d0
[00fd5438] 4840                      swap      d0
[00fd543a] 48c0                      ext.l     d0
[00fd543c] 81ee fff0                 divs.w    -16(a6),d0
[00fd5440] d16b 35ac                 add.w     d0,13740(a3)
[00fd5444] 302b 35fe                 move.w    13822(a3),d0
[00fd5448] 5440                      addq.w    #2,d0
[00fd544a] 3740 35ae                 move.w    d0,13742(a3)
[00fd544e] 3039 0000 6d90            move.w    gl_height,d0
[00fd5454] 9079 0000 6f18            sub.w     $00006F18,d0
[00fd545a] 48c0                      ext.l     d0
[00fd545c] 81eb 35ae                 divs.w    13742(a3),d0
[00fd5460] 3d40 ffee                 move.w    d0,-18(a6)
[00fd5464] 3039 0000 6d90            move.w    gl_height,d0
[00fd546a] 9079 0000 6f18            sub.w     $00006F18,d0
[00fd5470] 48c0                      ext.l     d0
[00fd5472] 81eb 35ae                 divs.w    13742(a3),d0
[00fd5476] 4840                      swap      d0
[00fd5478] 48c0                      ext.l     d0
[00fd547a] 81ee ffee                 divs.w    -18(a6),d0
[00fd547e] d16b 35ae                 add.w     d0,13742(a3)
[00fd5482] 2d6b 5a4a fffc            move.l    23114(a3),-4(a6)
[00fd5488] 6042                      bra.s     $00FD54CC
[00fd548a] 2eae fffc                 move.l    -4(a6),(a7)
[00fd548e] 0697 0000 001a            addi.l    #$0000001A,(a7)
[00fd5494] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd5498] 0697 0000 0018            addi.l    #$00000018,(a7)
[00fd549e] 206e fffc                 movea.l   -4(a6),a0
[00fd54a2] 3028 001a                 move.w    26(a0),d0
[00fd54a6] c1eb 35ae                 muls.w    13742(a3),d0
[00fd54aa] 3f00                      move.w    d0,-(a7)
[00fd54ac] 302b 343c                 move.w    13372(a3),d0
[00fd54b0] d157                      add.w     d0,(a7)
[00fd54b2] 206e fffc                 movea.l   -4(a6),a0
[00fd54b6] 3028 0018                 move.w    24(a0),d0
[00fd54ba] c1eb 35ac                 muls.w    13740(a3),d0
[00fd54be] 3f00                      move.w    d0,-(a7)
[00fd54c0] f2bc                      dc.w      $F2BC ; app_mtoi
[00fd54c2] 508f                      addq.l    #8,a7
[00fd54c4] 206e fffc                 movea.l   -4(a6),a0
[00fd54c8] 2d50 fffc                 move.l    (a0),-4(a6)
[00fd54cc] 4aae fffc                 tst.l     -4(a6)
[00fd54d0] 66b8                      bne.s     $00FD548A
[00fd54d2] 377c 0009 35b0            move.w    #$0009,13744(a3)
[00fd54d8] 377c 0005 35b2            move.w    #$0005,13746(a3)
[00fd54de] 486b 35b4                 pea.l     13748(a3)
[00fd54e2] 4267                      clr.w     -(a7)
[00fd54e4] 3f3c 0012                 move.w    #$0012,-(a7)
[00fd54e8] f358                      dc.w      $F358 ; bfill
[00fd54ea] 508f                      addq.l    #8,a7
[00fd54ec] 3039 0000 6ff0            move.w    $00006FF0,d0
[00fd54f2] e540                      asl.w     #2,d0
[00fd54f4] 3740 35b4                 move.w    d0,13748(a3)
[00fd54f8] 376b 35b4 35b8            move.w    13748(a3),13752(a3)
[00fd54fe] 302b 35fe                 move.w    13822(a3),d0
[00fd5502] 9079 0000 6ff0            sub.w     $00006FF0,d0
[00fd5508] 5540                      subq.w    #2,d0
[00fd550a] 3740 35ba                 move.w    d0,13754(a3)
[00fd550e] 376b 35ba 35be            move.w    13754(a3),13758(a3)
[00fd5514] 376b 35fe 35c2            move.w    13822(a3),13762(a3)
[00fd551a] 376b 35fc 35c4            move.w    13820(a3),13764(a3)
[00fd5520] 376b 35fe 35c6            move.w    13822(a3),13766(a3)
[00fd5526] 376b 35fc 35c8            move.w    13820(a3),13768(a3)
[00fd552c] 302b 35fe                 move.w    13822(a3),d0
[00fd5530] 9079 0000 6ff0            sub.w     $00006FF0,d0
[00fd5536] 5540                      subq.w    #2,d0
[00fd5538] 3740 35ca                 move.w    d0,13770(a3)
[00fd553c] 3039 0000 6ff0            move.w    $00006FF0,d0
[00fd5542] e740                      asl.w     #3,d0
[00fd5544] 3740 35cc                 move.w    d0,13772(a3)
[00fd5548] 376b 35ca 35ce            move.w    13770(a3),13774(a3)
[00fd554e] 3039 0000 6ff0            move.w    $00006FF0,d0
[00fd5554] e740                      asl.w     #3,d0
[00fd5556] 3740 35d0                 move.w    d0,13776(a3)
[00fd555a] 376b 35b4 35d4            move.w    13748(a3),13780(a3)
[00fd5560] 486b 35d8                 pea.l     13784(a3)
[00fd5564] 4267                      clr.w     -(a7)
[00fd5566] 3f3c 000a                 move.w    #$000A,-(a7)
[00fd556a] f358                      dc.w      $F358 ; bfill
[00fd556c] 508f                      addq.l    #8,a7
[00fd556e] 3039 0000 6dce            move.w    $00006DCE,d0
[00fd5574] c1fc 000c                 muls.w    #$000C,d0
[00fd5578] 3740 35dc                 move.w    d0,13788(a3)
[00fd557c] 376b 35dc 35e0            move.w    13788(a3),13792(a3)
[00fd5582] 3779 0000 6ce2 35e2       move.w    $00006CE2,13794(a3)
[00fd558a] 3779 0000 6ce2 35e6       move.w    $00006CE2,13798(a3)
[00fd5592] 7001                      moveq.l   #1,d0
[00fd5594] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef _app_reschange
_app_reschange: ds.b 0
#if 0
[00fd5596] 4e56 fffc                 link      a6,#$FFFC
[00fd559a] 302e 0008                 move.w    8(a6),d0
[00fd559e] b079 0000 6122            cmp.w     $00006122,d0
[00fd55a4] 6604                      bne.s     $00FD55AA
[00fd55a6] 4240                      clr.w     d0
[00fd55a8] 6012                      bra.s     $00FD55BC
[00fd55aa] 33ee 0008 0000 6122       move.w    8(a6),$00006122
[00fd55b2] 33fc 0001 0000 6124       move.w    #1,$00006124
[00fd55ba] 7001                      moveq.l   #1,d0
[00fd55bc] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef _app_reverse
_app_reverse: ds.b 0
#if 0
[00fd55be] 4e56 0000                 link      a6,#0
[00fd55c2] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd55c6] 2679 0000 a788            movea.l   _thedesk,a3
[00fd55cc] 2a6b 5a4a                 movea.l   23114(a3),a5
[00fd55d0] 42ab 5a4a                 clr.l     23114(a3)
[00fd55d4] 600c                      bra.s     $00FD55E2
[00fd55d6] 2855                      movea.l   (a5),a4
[00fd55d8] 2aab 5a4a                 move.l    23114(a3),(a5)
[00fd55dc] 274d 5a4a                 move.l    a5,23114(a3)
[00fd55e0] 2a4c                      movea.l   a4,a5
[00fd55e2] 200d                      move.l    a5,d0
[00fd55e4] 66f0                      bne.s     $00FD55D6
[00fd55e6] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef _save_inf
_save_inf: ds.b 0
#if 0
[00fd55e8] 4e56 ffda                 link      a6,#$FFDA
[00fd55ec] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fd55f0] 2679 0000 a788            movea.l   _thedesk,a3
[00fd55f6] 4beb 3680                 lea.l     13952(a3),a5
[00fd55fa] 2e8d                      move.l    a5,(a7)
[00fd55fc] 4267                      clr.w     -(a7)
[00fd55fe] 3f3c 0fe0                 move.w    #$0FE0,-(a7)
[00fd5602] f358                      dc.w      $F358 ; bfill
[00fd5604] 588f                      addq.l    #4,a7
[00fd5606] 4a2b 76e8                 tst.b     30440(a3)
[00fd560a] 6720                      beq.s     $00FD562C
[00fd560c] 1afc 0023                 move.b    #$23,(a5)+
[00fd5610] 1afc 005a                 move.b    #$5A,(a5)+
[00fd5614] 1afc 0020                 move.b    #$20,(a5)+
[00fd5618] 486b 76e8                 pea.l     30440(a3)
[00fd561c] 2f0d                      move.l    a5,-(a7)
[00fd561e] f35c                      dc.w      $F35C ; save_sstr
[00fd5620] 508f                      addq.l    #8,a7
[00fd5622] 2a40                      movea.l   d0,a5
[00fd5624] 1afc 000d                 move.b    #$0D,(a5)+
[00fd5628] 1afc 000a                 move.b    #$0A,(a5)+
[00fd562c] 1afc 0023                 move.b    #$23,(a5)+
[00fd5630] 1afc 0045                 move.b    #$45,(a5)+
[00fd5634] 1afc 0020                 move.b    #$20,(a5)+
[00fd5638] 426e fffe                 clr.w     -2(a6)
[00fd563c] 302b 5c0a                 move.w    23562(a3),d0
[00fd5640] 816e fffe                 or.w      d0,-2(a6)
[00fd5644] 4a6b 5c00                 tst.w     23552(a3)
[00fd5648] 6706                      beq.s     $00FD5650
[00fd564a] 303c 0080                 move.w    #$0080,d0
[00fd564e] 6002                      bra.s     $00FD5652
[00fd5650] 4240                      clr.w     d0
[00fd5652] 816e fffe                 or.w      d0,-2(a6)
[00fd5656] 302b 5bfe                 move.w    23550(a3),d0
[00fd565a] eb40                      asl.w     #5,d0
[00fd565c] c07c 0060                 and.w     #$0060,d0
[00fd5660] 816e fffe                 or.w      d0,-2(a6)
[00fd5664] 4a6b 5c04                 tst.w     23556(a3)
[00fd5668] 6704                      beq.s     $00FD566E
[00fd566a] 7010                      moveq.l   #16,d0
[00fd566c] 6002                      bra.s     $00FD5670
[00fd566e] 4240                      clr.w     d0
[00fd5670] 816e fffe                 or.w      d0,-2(a6)
[00fd5674] 4a6b 5c02                 tst.w     23554(a3)
[00fd5678] 6704                      beq.s     $00FD567E
[00fd567a] 7008                      moveq.l   #8,d0
[00fd567c] 6002                      bra.s     $00FD5680
[00fd567e] 4240                      clr.w     d0
[00fd5680] 816e fffe                 or.w      d0,-2(a6)
[00fd5684] 3eae fffe                 move.w    -2(a6),(a7)
[00fd5688] 2f0d                      move.l    a5,-(a7)
[00fd568a] f360                      dc.w      $F360 ; save_2
[00fd568c] 588f                      addq.l    #4,a7
[00fd568e] 2a40                      movea.l   d0,a5
[00fd5690] 426e fffe                 clr.w     -2(a6)
[00fd5694] 302b 5c08                 move.w    23560(a3),d0
[00fd5698] 816e fffe                 or.w      d0,-2(a6)
[00fd569c] 302b 5c06                 move.w    23558(a3),d0
[00fd56a0] e940                      asl.w     #4,d0
[00fd56a2] 816e fffe                 or.w      d0,-2(a6)
[00fd56a6] 3eae fffe                 move.w    -2(a6),(a7)
[00fd56aa] 2f0d                      move.l    a5,-(a7)
[00fd56ac] f360                      dc.w      $F360 ; save_2
[00fd56ae] 588f                      addq.l    #4,a7
[00fd56b0] 2a40                      movea.l   d0,a5
[00fd56b2] 1afc 000d                 move.b    #$0D,(a5)+
[00fd56b6] 1afc 000a                 move.b    #$0A,(a5)+
[00fd56ba] 4247                      clr.w     d7
[00fd56bc] 6000 00c2                 bra       $00FD5780
[00fd56c0] 1afc 0023                 move.b    #$23,(a5)+
[00fd56c4] 1afc 0057                 move.b    #$57,(a5)+
[00fd56c8] 1afc 0020                 move.b    #$20,(a5)+
[00fd56cc] 284b                      movea.l   a3,a4
[00fd56ce] 3007                      move.w    d7,d0
[00fd56d0] c1fc 0088                 muls.w    #$0088,d0
[00fd56d4] d9c0                      adda.l    d0,a4
[00fd56d6] d9fc 0000 5c0c            adda.l    #$00005C0C,a4
[00fd56dc] 3eac 0008                 move.w    8(a4),(a7)
[00fd56e0] 2f0d                      move.l    a5,-(a7)
[00fd56e2] f360                      dc.w      $F360 ; save_2
[00fd56e4] 588f                      addq.l    #4,a7
[00fd56e6] 2a40                      movea.l   d0,a5
[00fd56e8] 3eac 000a                 move.w    10(a4),(a7)
[00fd56ec] 2f0d                      move.l    a5,-(a7)
[00fd56ee] f360                      dc.w      $F360 ; save_2
[00fd56f0] 588f                      addq.l    #4,a7
[00fd56f2] 2a40                      movea.l   d0,a5
[00fd56f4] 3014                      move.w    (a4),d0
[00fd56f6] 48c0                      ext.l     d0
[00fd56f8] 81f9 0000 6dce            divs.w    $00006DCE,d0
[00fd56fe] 3e80                      move.w    d0,(a7)
[00fd5700] 2f0d                      move.l    a5,-(a7)
[00fd5702] f360                      dc.w      $F360 ; save_2
[00fd5704] 588f                      addq.l    #4,a7
[00fd5706] 2a40                      movea.l   d0,a5
[00fd5708] 302c 0002                 move.w    2(a4),d0
[00fd570c] 48c0                      ext.l     d0
[00fd570e] 81f9 0000 6ce2            divs.w    $00006CE2,d0
[00fd5714] 3e80                      move.w    d0,(a7)
[00fd5716] 2f0d                      move.l    a5,-(a7)
[00fd5718] f360                      dc.w      $F360 ; save_2
[00fd571a] 588f                      addq.l    #4,a7
[00fd571c] 2a40                      movea.l   d0,a5
[00fd571e] 302c 0004                 move.w    4(a4),d0
[00fd5722] 48c0                      ext.l     d0
[00fd5724] 81f9 0000 6dce            divs.w    $00006DCE,d0
[00fd572a] 3e80                      move.w    d0,(a7)
[00fd572c] 2f0d                      move.l    a5,-(a7)
[00fd572e] f360                      dc.w      $F360 ; save_2
[00fd5730] 588f                      addq.l    #4,a7
[00fd5732] 2a40                      movea.l   d0,a5
[00fd5734] 302c 0006                 move.w    6(a4),d0
[00fd5738] 48c0                      ext.l     d0
[00fd573a] 81f9 0000 6ce2            divs.w    $00006CE2,d0
[00fd5740] 3e80                      move.w    d0,(a7)
[00fd5742] 2f0d                      move.l    a5,-(a7)
[00fd5744] f360                      dc.w      $F360 ; save_2
[00fd5746] 588f                      addq.l    #4,a7
[00fd5748] 2a40                      movea.l   d0,a5
[00fd574a] 3eac 000c                 move.w    12(a4),(a7)
[00fd574e] 2f0d                      move.l    a5,-(a7)
[00fd5750] f360                      dc.w      $F360 ; save_2
[00fd5752] 588f                      addq.l    #4,a7
[00fd5754] 2a40                      movea.l   d0,a5
[00fd5756] 41ec 000e                 lea.l     14(a4),a0
[00fd575a] 2d48 fff8                 move.l    a0,-8(a6)
[00fd575e] 600a                      bra.s     $00FD576A
[00fd5760] 206e fff8                 movea.l   -8(a6),a0
[00fd5764] 1ad0                      move.b    (a0),(a5)+
[00fd5766] 52ae fff8                 addq.l    #1,-8(a6)
[00fd576a] 206e fff8                 movea.l   -8(a6),a0
[00fd576e] 4a10                      tst.b     (a0)
[00fd5770] 66ee                      bne.s     $00FD5760
[00fd5772] 1afc 0040                 move.b    #$40,(a5)+
[00fd5776] 1afc 000d                 move.b    #$0D,(a5)+
[00fd577a] 1afc 000a                 move.b    #$0A,(a5)+
[00fd577e] 5247                      addq.w    #1,d7
[00fd5780] be7c 0004                 cmp.w     #$0004,d7
[00fd5784] 6d00 ff3a                 blt       $00FD56C0
[00fd5788] f364                      dc.w      $F364 ; app_reverse
[00fd578a] 2d6b 5a4a fff4            move.l    23114(a3),-12(a6)
[00fd5790] 6000 0136                 bra       $00FD58C8
[00fd5794] 200d                      move.l    a5,d0
[00fd5796] 220b                      move.l    a3,d1
[00fd5798] d2bc 0000 3600            add.l     #$00003600,d1
[00fd579e] 9081                      sub.l     d1,d0
[00fd57a0] b0bc 0000 103d            cmp.l     #$0000103D,d0
[00fd57a6] 6c00 0128                 bge       $00FD58D0
[00fd57aa] 1afc 0023                 move.b    #$23,(a5)+
[00fd57ae] 206e fff4                 movea.l   -12(a6),a0
[00fd57b2] 3028 0006                 move.w    6(a0),d0
[00fd57b6] 604c                      bra.s     $00FD5804
[00fd57b8] 1afc 0054                 move.b    #$54,(a5)+
[00fd57bc] 605a                      bra.s     $00FD5818
[00fd57be] 1afc 004d                 move.b    #$4D,(a5)+
[00fd57c2] 6054                      bra.s     $00FD5818
[00fd57c4] 1afc 0043                 move.b    #$43,(a5)+
[00fd57c8] 604e                      bra.s     $00FD5818
[00fd57ca] 206e fff4                 movea.l   -12(a6),a0
[00fd57ce] 0828 0000 0005            btst      #0,5(a0)
[00fd57d4] 6712                      beq.s     $00FD57E8
[00fd57d6] 206e fff4                 movea.l   -12(a6),a0
[00fd57da] 0828 0001 0005            btst      #1,5(a0)
[00fd57e0] 6706                      beq.s     $00FD57E8
[00fd57e2] 1afc 0047                 move.b    #$47,(a5)+
[00fd57e6] 6014                      bra.s     $00FD57FC
[00fd57e8] 206e fff4                 movea.l   -12(a6),a0
[00fd57ec] 0828 0003 0005            btst      #3,5(a0)
[00fd57f2] 6704                      beq.s     $00FD57F8
[00fd57f4] 7050                      moveq.l   #80,d0
[00fd57f6] 6002                      bra.s     $00FD57FA
[00fd57f8] 7046                      moveq.l   #70,d0
[00fd57fa] 1ac0                      move.b    d0,(a5)+
[00fd57fc] 601a                      bra.s     $00FD5818
[00fd57fe] 1afc 0044                 move.b    #$44,(a5)+
[00fd5802] 6014                      bra.s     $00FD5818
[00fd5804] b07c 0004                 cmp.w     #$0004,d0
[00fd5808] 620e                      bhi.s     $00FD5818
[00fd580a] e540                      asl.w     #2,d0
[00fd580c] 3040                      movea.w   d0,a0
[00fd580e] d1fc 00fe b11c            adda.l    #$00FEB11C,a0
[00fd5814] 2050                      movea.l   (a0),a0
[00fd5816] 4ed0                      jmp       (a0)
[00fd5818] 1afc 0020                 move.b    #$20,(a5)+
[00fd581c] 206e fff4                 movea.l   -12(a6),a0
[00fd5820] 0828 0002 0005            btst      #2,5(a0)
[00fd5826] 6734                      beq.s     $00FD585C
[00fd5828] 206e fff4                 movea.l   -12(a6),a0
[00fd582c] 3028 0018                 move.w    24(a0),d0
[00fd5830] 48c0                      ext.l     d0
[00fd5832] 81eb 35ac                 divs.w    13740(a3),d0
[00fd5836] 3e80                      move.w    d0,(a7)
[00fd5838] 2f0d                      move.l    a5,-(a7)
[00fd583a] f360                      dc.w      $F360 ; save_2
[00fd583c] 588f                      addq.l    #4,a7
[00fd583e] 2a40                      movea.l   d0,a5
[00fd5840] 206e fff4                 movea.l   -12(a6),a0
[00fd5844] 3028 001a                 move.w    26(a0),d0
[00fd5848] 906b 343c                 sub.w     13372(a3),d0
[00fd584c] 48c0                      ext.l     d0
[00fd584e] 81eb 35ae                 divs.w    13742(a3),d0
[00fd5852] 3e80                      move.w    d0,(a7)
[00fd5854] 2f0d                      move.l    a5,-(a7)
[00fd5856] f360                      dc.w      $F360 ; save_2
[00fd5858] 588f                      addq.l    #4,a7
[00fd585a] 2a40                      movea.l   d0,a5
[00fd585c] 206e fff4                 movea.l   -12(a6),a0
[00fd5860] 3ea8 0012                 move.w    18(a0),(a7)
[00fd5864] 2f0d                      move.l    a5,-(a7)
[00fd5866] f360                      dc.w      $F360 ; save_2
[00fd5868] 588f                      addq.l    #4,a7
[00fd586a] 2a40                      movea.l   d0,a5
[00fd586c] 206e fff4                 movea.l   -12(a6),a0
[00fd5870] 3ea8 0014                 move.w    20(a0),(a7)
[00fd5874] 2f0d                      move.l    a5,-(a7)
[00fd5876] f360                      dc.w      $F360 ; save_2
[00fd5878] 588f                      addq.l    #4,a7
[00fd587a] 2a40                      movea.l   d0,a5
[00fd587c] 206e fff4                 movea.l   -12(a6),a0
[00fd5880] 4a68 0016                 tst.w     22(a0)
[00fd5884] 6604                      bne.s     $00FD588A
[00fd5886] 7020                      moveq.l   #32,d0
[00fd5888] 6008                      bra.s     $00FD5892
[00fd588a] 206e fff4                 movea.l   -12(a6),a0
[00fd588e] 3028 0016                 move.w    22(a0),d0
[00fd5892] 1ac0                      move.b    d0,(a5)+
[00fd5894] 1afc 0020                 move.b    #$20,(a5)+
[00fd5898] 206e fff4                 movea.l   -12(a6),a0
[00fd589c] 2ea8 000a                 move.l    10(a0),(a7)
[00fd58a0] 2f0d                      move.l    a5,-(a7)
[00fd58a2] f35c                      dc.w      $F35C ; save_sstr
[00fd58a4] 588f                      addq.l    #4,a7
[00fd58a6] 2a40                      movea.l   d0,a5
[00fd58a8] 206e fff4                 movea.l   -12(a6),a0
[00fd58ac] 2ea8 000e                 move.l    14(a0),(a7)
[00fd58b0] 2f0d                      move.l    a5,-(a7)
[00fd58b2] f35c                      dc.w      $F35C ; save_sstr
[00fd58b4] 588f                      addq.l    #4,a7
[00fd58b6] 2a40                      movea.l   d0,a5
[00fd58b8] 1afc 000d                 move.b    #$0D,(a5)+
[00fd58bc] 1afc 000a                 move.b    #$0A,(a5)+
[00fd58c0] 206e fff4                 movea.l   -12(a6),a0
[00fd58c4] 2d50 fff4                 move.l    (a0),-12(a6)
[00fd58c8] 4aae fff4                 tst.l     -12(a6)
[00fd58cc] 6600 fec6                 bne       $00FD5794
[00fd58d0] 1afc 001a                 move.b    #$1A,(a5)+
[00fd58d4] 421d                      clr.b     (a5)+
[00fd58d6] f364                      dc.w      $F364 ; app_reverse
[00fd58d8] 200d                      move.l    a5,d0
[00fd58da] 220b                      move.l    a3,d1
[00fd58dc] d2bc 0000 3600            add.l     #$00003600,d1
[00fd58e2] 9081                      sub.l     d1,d0
[00fd58e4] 3740 4660                 move.w    d0,18016(a3)
[00fd58e8] 3ebc 0080                 move.w    #$0080,(a7)
[00fd58ec] 486b 3600                 pea.l     13824(a3)
[00fd58f0] f334                      dc.w      $F334 ; shel_get
[00fd58f2] 588f                      addq.l    #4,a7
[00fd58f4] 3ebc 1060                 move.w    #$1060,(a7)
[00fd58f8] 486b 3600                 pea.l     13824(a3)
[00fd58fc] f368                      dc.w      $F368 ; shel_put
[00fd58fe] 588f                      addq.l    #4,a7
[00fd5900] 4a6e 0008                 tst.w     8(a6)
[00fd5904] 6700 0086                 beq       $00FD598C
[00fd5908] 536b 4660                 subq.w    #1,18016(a3)
[00fd590c] f338                      dc.w      $F338 ; isdrive
[00fd590e] c07c 0004                 and.w     #$0004,d0
[00fd5912] 6704                      beq.s     $00FD5918
[00fd5914] 7043                      moveq.l   #67,d0
[00fd5916] 6002                      bra.s     $00FD591A
[00fd5918] 7041                      moveq.l   #65,d0
[00fd591a] 1d40 ffda                 move.b    d0,-38(a6)
[00fd591e] 1d7c 003a ffdb            move.b    #$3A,-37(a6)
[00fd5924] 1d7c 005c ffdc            move.b    #$5C,-36(a6)
[00fd592a] 486e ffdd                 pea.l     -35(a6)
[00fd592e] 2f3c 00fe b068            move.l    #$00FEB068,-(a7)
[00fd5934] f36c                      dc.w      $F36C ; xstrpcpy
[00fd5936] 508f                      addq.l    #8,a7
[00fd5938] 4257                      clr.w     (a7)
[00fd593a] 486e ffda                 pea.l     -38(a6)
[00fd593e] f370                      dc.w      $F370 ; dos_create
[00fd5940] 588f                      addq.l    #4,a7
[00fd5942] 3c00                      move.w    d0,d6
[00fd5944] 4a46                      tst.w     d6
[00fd5946] 6e04                      bgt.s     $00FD594C
[00fd5948] f374                      dc.w      $F374 ; dos_error
[00fd594a] 6040                      bra.s     $00FD598C
[00fd594c] 486b 3600                 pea.l     13824(a3)
[00fd5950] 3f2b 4660                 move.w    18016(a3),-(a7)
[00fd5954] 3f06                      move.w    d6,-(a7)
[00fd5956] f378                      dc.w      $F378 ; dos_write
[00fd5958] 508f                      addq.l    #8,a7
[00fd595a] 3d40 ffee                 move.w    d0,-18(a6)
[00fd595e] 3e86                      move.w    d6,(a7)
[00fd5960] f344                      dc.w      $F344 ; dos_close
[00fd5962] 302b 4660                 move.w    18016(a3),d0
[00fd5966] b06e ffee                 cmp.w     -18(a6),d0
[00fd596a] 6f16                      ble.s     $00FD5982
[00fd596c] 4297                      clr.l     (a7)
[00fd596e] 2f3c 0001 0016            move.l    #$00010016,-(a7)
[00fd5974] f0dc                      dc.w      $F0DC ; fill_string
[00fd5976] 588f                      addq.l    #4,a7
[00fd5978] 2e8e                      move.l    a6,(a7)
[00fd597a] 0697 ffff ffda            addi.l    #$FFFFFFDA,(a7)
[00fd5980] f37c                      dc.w      $F37C ; dos_delete
[00fd5982] 4257                      clr.w     (a7)
[00fd5984] 486e ffda                 pea.l     -38(a6)
[00fd5988] f380                      dc.w      $F380 ; up_allwin
[00fd598a] 588f                      addq.l    #4,a7
[00fd598c] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef _set_defdrv
_set_defdrv: ds.b 0
#if 0
[00fd598e] 4e56 fffc                 link      a6,#$FFFC
[00fd5992] f338                      dc.w      $F338 ; isdrive
[00fd5994] c07c 0004                 and.w     #$0004,d0
[00fd5998] e240                      asr.w     #1,d0
[00fd599a] 3e80                      move.w    d0,(a7)
[00fd599c] f384                      dc.w      $F384 ; dos_sdrv
[00fd599e] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif
