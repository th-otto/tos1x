	xdef _showfile
_showfile: ds.b 0
#if 0
[00fe66b2] 4e56 ffee                 link      a6,#-18
[00fe66b6] 48e7 1f04                 movem.l   d3-d7/a5,-(a7)
[00fe66ba] 4247                      clr.w     d7
[00fe66bc] 3d47 fffe                 move.w    d7,-2(a6)
[00fe66c0] 7cff                      moveq.l   #-1,d6
[00fe66c2] 2ebc 0000 1000            move.l    #$00001000,(a7)
[00fe66c8] 3f3c 0048                 move.w    #$0048,-(a7) ; Malloc
[00fe66cc] f0d8                      dc.w      $F0D8 ; trap
[00fe66ce] 548f                      addq.l    #2,a7
[00fe66d0] 2d40 fff8                 move.l    d0,-8(a6)
[00fe66d4] 6638                      bne.s     $00FE670E
[00fe66d6] 4a6e 000c                 tst.w     12(a6)
[00fe66da] 6712                      beq.s     $00FE66EE
[00fe66dc] 4297                      clr.l     (a7)
[00fe66de] 2f3c 0001 001b            move.l    #$0001001B,-(a7)
[00fe66e4] f0dc                      dc.w      $F0DC ; fill_string
[00fe66e6] 588f                      addq.l    #4,a7
[00fe66e8] 6000 028a                 bra       $00FE6974
[00fe66ec] 601c                      bra.s     $00FE670A
[00fe66ee] 486e ffee                 pea.l     -18(a6)
[00fe66f2] 2f3c 0005 000b            move.l    #$0005000B,-(a7)
[00fe66f8] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fe66fa] 508f                      addq.l    #8,a7
[00fe66fc] 2eae ffee                 move.l    -18(a6),(a7)
[00fe6700] f0e4                      dc.w      $F0E4 ; bconws
[00fe6702] 2ebc 00fe b9ae            move.l    #$00FEB9AE,(a7)
[00fe6708] f0e4                      dc.w      $F0E4 ; bconws
[00fe670a] 6000 024e                 bra       $00FE695A
[00fe670e] 4257                      clr.w     (a7)
[00fe6710] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe6714] 3f3c 003d                 move.w    #$003D,-(a7)
[00fe6718] f0d8                      dc.w      $F0D8 ; trap
[00fe671a] 5c8f                      addq.l    #6,a7
[00fe671c] 3c00                      move.w    d0,d6
[00fe671e] 6c38                      bge.s     $00FE6758
[00fe6720] 4a6e 000c                 tst.w     12(a6)
[00fe6724] 670c                      beq.s     $00FE6732
[00fe6726] 3ebc 0002                 move.w    #$0002,(a7)
[00fe672a] f0e8                      dc.w      $F0E8 ; form_error
[00fe672c] 6000 0246                 bra       $00FE6974
[00fe6730] 6022                      bra.s     $00FE6754
[00fe6732] 486e ffee                 pea.l     -18(a6)
[00fe6736] 2f3c 0005 000a            move.l    #$0005000A,-(a7)
[00fe673c] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fe673e] 508f                      addq.l    #8,a7
[00fe6740] 2eae ffee                 move.l    -18(a6),(a7)
[00fe6744] f0e4                      dc.w      $F0E4 ; bconws
[00fe6746] 2eae 0008                 move.l    8(a6),(a7)
[00fe674a] f0e4                      dc.w      $F0E4 ; bconws
[00fe674c] 2ebc 00fe b9b1            move.l    #$00FEB9B1,(a7)
[00fe6752] f0e4                      dc.w      $F0E4 ; bconws
[00fe6754] 6000 0204                 bra       $00FE695A
[00fe6758] 4a6e 000c                 tst.w     12(a6)
[00fe675c] 6700 0118                 beq       $00FE6876
[00fe6760] 3ebc ffff                 move.w    #$FFFF,(a7)
[00fe6764] 3f3c 0021                 move.w    #$0021,-(a7)
[00fe6768] f0ec                      dc.w      $F0EC ; trp14
[00fe676a] 548f                      addq.l    #2,a7
[00fe676c] c07c 0010                 and.w     #$0010,d0
[00fe6770] 6704                      beq.s     $00FE6776
[00fe6772] 7001                      moveq.l   #1,d0
[00fe6774] 6002                      bra.s     $00FE6778
[00fe6776] 4240                      clr.w     d0
[00fe6778] 3d40 fffc                 move.w    d0,-4(a6)
[00fe677c] 4247                      clr.w     d7
[00fe677e] 6000 00d8                 bra       $00FE6858
[00fe6782] 2a6e fff8                 movea.l   -8(a6),a5
[00fe6786] 4244                      clr.w     d4
[00fe6788] 6000 00c4                 bra       $00FE684E
[00fe678c] 1015                      move.b    (a5),d0
[00fe678e] 4880                      ext.w     d0
[00fe6790] 6012                      bra.s     $00FE67A4
[00fe6792] 4247                      clr.w     d7
[00fe6794] 601c                      bra.s     $00FE67B2
[00fe6796] 5347                      subq.w    #1,d7
[00fe6798] 6018                      bra.s     $00FE67B2
[00fe679a] 0c15 0020                 cmpi.b    #$20,(a5)
[00fe679e] 6502                      bcs.s     $00FE67A2
[00fe67a0] 5247                      addq.w    #1,d7
[00fe67a2] 600e                      bra.s     $00FE67B2
[00fe67a4] b07c 0008                 cmp.w     #$0008,d0
[00fe67a8] 67ec                      beq.s     $00FE6796
[00fe67aa] b07c 000d                 cmp.w     #$000D,d0
[00fe67ae] 67e2                      beq.s     $00FE6792
[00fe67b0] 60e8                      bra.s     $00FE679A
[00fe67b2] 1015                      move.b    (a5),d0
[00fe67b4] 4880                      ext.w     d0
[00fe67b6] 3e80                      move.w    d0,(a7)
[00fe67b8] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fe67bc] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe67c0] f0f0                      dc.w      $F0F0 ; trp13
[00fe67c2] 588f                      addq.l    #4,a7
[00fe67c4] 4a80                      tst.l     d0
[00fe67c6] 661a                      bne.s     $00FE67E2
[00fe67c8] 3ebc 0002                 move.w    #$0002,(a7)
[00fe67cc] 42a7                      clr.l     -(a7)
[00fe67ce] 3f39 0000 a81a            move.w    $0000A81A,-(a7)
[00fe67d4] f0f4                      dc.w      $F0F4 ; fm_show
[00fe67d6] 5c8f                      addq.l    #6,a7
[00fe67d8] b07c 0002                 cmp.w     #$0002,d0
[00fe67dc] 67d4                      beq.s     $00FE67B2
[00fe67de] 6000 0186                 bra       $00FE6966
[00fe67e2] 526e fffe                 addq.w    #1,-2(a6)
[00fe67e6] 302e fffe                 move.w    -2(a6),d0
[00fe67ea] b07c 0010                 cmp.w     #$0010,d0
[00fe67ee] 6d5a                      blt.s     $00FE684A
[00fe67f0] 426e fffe                 clr.w     -2(a6)
[00fe67f4] 3ebc 0002                 move.w    #$0002,(a7)
[00fe67f8] 3f3c 0001                 move.w    #1,-(a7)
[00fe67fc] f0f0                      dc.w      $F0F0 ; trp13
[00fe67fe] 548f                      addq.l    #2,a7
[00fe6800] 4a80                      tst.l     d0
[00fe6802] 6746                      beq.s     $00FE684A
[00fe6804] 3ebc 0002                 move.w    #$0002,(a7)
[00fe6808] 3f3c 0002                 move.w    #$0002,-(a7)
[00fe680c] f0f0                      dc.w      $F0F0 ; trp13
[00fe680e] 548f                      addq.l    #2,a7
[00fe6810] 2d40 fff4                 move.l    d0,-12(a6)
[00fe6814] 3d40 fff2                 move.w    d0,-14(a6)
[00fe6818] 0c6e 0003 fff2            cmpi.w    #$0003,-14(a6)
[00fe681e] 6700 0146                 beq       $00FE6966
[00fe6822] 0c6e 0071 fff2            cmpi.w    #$0071,-14(a6)
[00fe6828] 6700 013c                 beq       $00FE6966
[00fe682c] 0c6e 0051 fff2            cmpi.w    #$0051,-14(a6)
[00fe6832] 6700 0132                 beq       $00FE6966
[00fe6836] 202e fff4                 move.l    -12(a6),d0
[00fe683a] c0bc 00ff 0000            and.l     #$00FF0000,d0
[00fe6840] b0bc 0061 0000            cmp.l     #$00610000,d0
[00fe6846] 6700 011e                 beq       $00FE6966
[00fe684a] 5244                      addq.w    #1,d4
[00fe684c] 528d                      addq.l    #1,a5
[00fe684e] 3004                      move.w    d4,d0
[00fe6850] 48c0                      ext.l     d0
[00fe6852] ba80                      cmp.l     d0,d5
[00fe6854] 6e00 ff36                 bgt       $00FE678C
[00fe6858] 2eae fff8                 move.l    -8(a6),(a7)
[00fe685c] 2f3c 0000 1000            move.l    #$00001000,-(a7)
[00fe6862] 3f06                      move.w    d6,-(a7)
[00fe6864] 3f3c 003f                 move.w    #$003F,-(a7)
[00fe6868] f0d8                      dc.w      $F0D8 ; trap
[00fe686a] 508f                      addq.l    #8,a7
[00fe686c] 2a00                      move.l    d0,d5
[00fe686e] 6e00 ff12                 bgt       $00FE6782
[00fe6872] 6000 00f2                 bra       $00FE6966
[00fe6876] 6000 008a                 bra       $00FE6902
[00fe687a] 2a6e fff8                 movea.l   -8(a6),a5
[00fe687e] 4244                      clr.w     d4
[00fe6880] 6000 0078                 bra.w     $00FE68FA
[00fe6884] 1015                      move.b    (a5),d0
[00fe6886] 4880                      ext.w     d0
[00fe6888] 3e80                      move.w    d0,(a7)
[00fe688a] 2f3c 0003 0002            move.l    #$00030002,-(a7)
[00fe6890] f0f0                      dc.w      $F0F0 ; trp13
[00fe6892] 588f                      addq.l    #4,a7
[00fe6894] 5247                      addq.w    #1,d7
[00fe6896] 0c15 000a                 cmpi.b    #$0A,(a5)
[00fe689a] 6646                      bne.s     $00FE68E2
[00fe689c] 4247                      clr.w     d7
[00fe689e] 526e fffe                 addq.w    #1,-2(a6)
[00fe68a2] 0c6e 0018 fffe            cmpi.w    #24,-2(a6)
[00fe68a8] 6d36                      blt.s     $00FE68E0
[00fe68aa] 486e ffee                 pea.l     -18(a6)
[00fe68ae] 2f3c 0005 0001            move.l    #$00050001,-(a7)
[00fe68b4] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fe68b6] 508f                      addq.l    #8,a7
[00fe68b8] 2ebc 00fe b9b4            move.l    #$00FEB9B4,(a7)
[00fe68be] f0e4                      dc.w      $F0E4 ; bconws
[00fe68c0] 2eae ffee                 move.l    -18(a6),(a7)
[00fe68c4] f0e4                      dc.w      $F0E4 ; bconws
[00fe68c6] 486e fffe                 pea.l     -2(a6)
[00fe68ca] 3f3c 0001                 move.w    #1,-(a7)
[00fe68ce] f0f8                      dc.w      $F0F8
[00fe68d0] 5c8f                      addq.l    #6,a7
[00fe68d2] 4a40                      tst.w     d0
[00fe68d4] 6600 0090                 bne       $00FE6966
[00fe68d8] 2ebc 00fe b9b6            move.l    #$00FEB9B6,(a7)
[00fe68de] f0e4                      dc.w      $F0E4 ; bconws
[00fe68e0] 6014                      bra.s     $00FE68F6
[00fe68e2] be7c 0010                 cmp.w     #$0010,d7
[00fe68e6] 6d0e                      blt.s     $00FE68F6
[00fe68e8] 486e fffe                 pea.l     -2(a6)
[00fe68ec] 4267                      clr.w     -(a7)
[00fe68ee] f0f8                      dc.w      $F0F8
[00fe68f0] 5c8f                      addq.l    #6,a7
[00fe68f2] 4a40                      tst.w     d0
[00fe68f4] 6670                      bne.s     $00FE6966
[00fe68f6] 5244                      addq.w    #1,d4
[00fe68f8] 528d                      addq.l    #1,a5
[00fe68fa] 3004                      move.w    d4,d0
[00fe68fc] 48c0                      ext.l     d0
[00fe68fe] ba80                      cmp.l     d0,d5
[00fe6900] 6e82                      bgt.s     $00FE6884
[00fe6902] 2eae fff8                 move.l    -8(a6),(a7)
[00fe6906] 2f3c 0000 1000            move.l    #$00001000,-(a7)
[00fe690c] 3f06                      move.w    d6,-(a7)
[00fe690e] 3f3c 003f                 move.w    #$003F,-(a7)
[00fe6912] f0d8                      dc.w      $F0D8 ; trap
[00fe6914] 508f                      addq.l    #8,a7
[00fe6916] 2a00                      move.l    d0,d5
[00fe6918] 6e00 ff60                 bgt       $00FE687A
[00fe691c] 4a85                      tst.l     d5
[00fe691e] 6c1e                      bge.s     $00FE693E
[00fe6920] 486e ffee                 pea.l     -18(a6)
[00fe6924] 2f3c 0005 0009            move.l    #$00050009,-(a7)
[00fe692a] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fe692c] 508f                      addq.l    #8,a7
[00fe692e] 2ebc 00fe b9bb            move.l    #$00FEB9BB,(a7)
[00fe6934] f0e4                      dc.w      $F0E4 ; bconws
[00fe6936] 2eae ffee                 move.l    -18(a6),(a7)
[00fe693a] f0e4                      dc.w      $F0E4 ; bconws
[00fe693c] 601c                      bra.s     $00FE695A
[00fe693e] 486e ffee                 pea.l     -18(a6)
[00fe6942] 2f3c 0005 0002            move.l    #$00050002,-(a7)
[00fe6948] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fe694a] 508f                      addq.l    #8,a7
[00fe694c] 2ebc 00fe b9be            move.l    #$00FEB9BE,(a7)
[00fe6952] f0e4                      dc.w      $F0E4 ; bconws
[00fe6954] 2eae ffee                 move.l    -18(a6),(a7)
[00fe6958] f0e4                      dc.w      $F0E4 ; bconws
[00fe695a] 486e fffe                 pea.l     -2(a6)
[00fe695e] 3f3c 0001                 move.w    #1,-(a7)
[00fe6962] f0f8                      dc.w      $F0F8
[00fe6964] 5c8f                      addq.l    #6,a7
[00fe6966] 4a46                      tst.w     d6
[00fe6968] 6d0a                      blt.s     $00FE6974
[00fe696a] 3e86                      move.w    d6,(a7)
[00fe696c] 3f3c 003e                 move.w    #$003E,-(a7)
[00fe6970] f0d8                      dc.w      $F0D8 ; trap
[00fe6972] 548f                      addq.l    #2,a7
[00fe6974] 4aae fff8                 tst.l     -8(a6)
[00fe6978] 670c                      beq.s     $00FE6986
[00fe697a] 2eae fff8                 move.l    -8(a6),(a7)
[00fe697e] 3f3c 0049                 move.w    #$0049,-(a7)
[00fe6982] f0d8                      dc.w      $F0D8 ; trap
[00fe6984] 548f                      addq.l    #2,a7
[00fe6986] f83d                      dc.w      $F83D ; movem.l (a7)+,d4-d7/a5
#endif

	xdef _doui
_doui: ds.b 0
#if 0
[00fe6988] 4e56 fff6                 link      a6,#-10
[00fe698c] 426e fffa                 clr.w     -6(a6)
[00fe6990] 6000 007e                 bra.w     $00FE6A10
[00fe6994] 3ebc 0002                 move.w    #$0002,(a7)
[00fe6998] 3f3c 0002                 move.w    #$0002,-(a7)
[00fe699c] f0f0                      dc.w      $F0F0 ; trp13
[00fe699e] 548f                      addq.l    #2,a7
[00fe69a0] 2d40 fffc                 move.l    d0,-4(a6)
[00fe69a4] c07c 00ff                 and.w     #$00FF,d0
[00fe69a8] 6050                      bra.s     $00FE69FA
[00fe69aa] 206e 000a                 movea.l   10(a6),a0
[00fe69ae] 30bc 000c                 move.w    #12,(a0)
[00fe69b2] 4240                      clr.w     d0
[00fe69b4] 6000 007e                 bra.w     $00FE6A34
[00fe69b8] 206e 000a                 movea.l   10(a6),a0
[00fe69bc] 4250                      clr.w     (a0)
[00fe69be] 4240                      clr.w     d0
[00fe69c0] 6000 0072                 bra.w     $00FE6A34
[00fe69c4] 206e 000a                 movea.l   10(a6),a0
[00fe69c8] 30bc 0017                 move.w    #$0017,(a0)
[00fe69cc] 4240                      clr.w     d0
[00fe69ce] 6064                      bra.s     $00FE6A34
[00fe69d0] 3d7c 0001 fffa            move.w    #1,-6(a6)
[00fe69d6] 6038                      bra.s     $00FE6A10
[00fe69d8] 426e fffa                 clr.w     -6(a6)
[00fe69dc] 6032                      bra.s     $00FE6A10
[00fe69de] 7001                      moveq.l   #1,d0
[00fe69e0] 6052                      bra.s     $00FE6A34
[00fe69e2] 202e fffc                 move.l    -4(a6),d0
[00fe69e6] c0bc 00ff 0000            and.l     #$00FF0000,d0
[00fe69ec] b0bc 0061 0000            cmp.l     #$00610000,d0
[00fe69f2] 6604                      bne.s     $00FE69F8
[00fe69f4] 7001                      moveq.l   #1,d0
[00fe69f6] 603c                      bra.s     $00FE6A34
[00fe69f8] 6016                      bra.s     $00FE6A10
[00fe69fa] 48c0                      ext.l     d0
[00fe69fc] 207c 00fe b956            movea.l   #$00FEB956,a0
[00fe6a02] 720a                      moveq.l   #10,d1
[00fe6a04] b098                      cmp.l     (a0)+,d0
[00fe6a06] 57c9 fffc                 dbeq      d1,$00FE6A04
[00fe6a0a] 2068 0028                 movea.l   40(a0),a0
[00fe6a0e] 4ed0                      jmp       (a0)
[00fe6a10] 4a6e 0008                 tst.w     8(a6)
[00fe6a14] 6600 ff7e                 bne       $00FE6994
[00fe6a18] 3ebc 0002                 move.w    #$0002,(a7)
[00fe6a1c] 3f3c 0001                 move.w    #1,-(a7)
[00fe6a20] f0f0                      dc.w      $F0F0 ; trp13
[00fe6a22] 548f                      addq.l    #2,a7
[00fe6a24] 4a80                      tst.l     d0
[00fe6a26] 6600 ff6c                 bne       $00FE6994
[00fe6a2a] 4a6e fffa                 tst.w     -6(a6)
[00fe6a2e] 6600 ff64                 bne       $00FE6994
[00fe6a32] 4240                      clr.w     d0
[00fe6a34] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef _bconws
_bconws: ds.b 0
#if 0
[00fe6a36] 4e56 0000                 link      a6,#0
[00fe6a3a] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fe6a3e] 2a6e 0008                 movea.l   8(a6),a5
[00fe6a42] 6010                      bra.s     $00FE6A54
[00fe6a44] 101d                      move.b    (a5)+,d0
[00fe6a46] 4880                      ext.w     d0
[00fe6a48] 3e80                      move.w    d0,(a7)
[00fe6a4a] 2f3c 0003 0002            move.l    #$00030002,-(a7)
[00fe6a50] f0f0                      dc.w      $F0F0 ; trp13
[00fe6a52] 588f                      addq.l    #4,a7
[00fe6a54] 4a15                      tst.b     (a5)
[00fe6a56] 66ec                      bne.s     $00FE6A44
[00fe6a58] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif
