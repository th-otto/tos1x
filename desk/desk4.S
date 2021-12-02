	xdef _desk_wait
_desk_wait: ds.b 0
#if 0
[00fdb032] 4e56 fffc                 link      a6,#$FFFC
[00fdb036] 4297                      clr.l     (a7)
[00fdb038] 4a6e 0008                 tst.w     8(a6)
[00fdb03c] 6706                      beq.s     $00FDB044
[00fdb03e] 3f3c 0002                 move.w    #$0002,-(a7)
[00fdb042] 6002                      bra.s     $00FDB046
[00fdb044] 4267                      clr.w     -(a7)
[00fdb046] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fdb048] 548f                      addq.l    #2,a7
[00fdb04a] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfdb04c
xfdb04c: ds.b 0
#if 0
[00fdb04c] 4e56 ff7a                 link      a6,#$FF7A
[00fdb050] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fdb054] 3e2e 0008                 move.w    8(a6),d7
[00fdb058] 3c2e 000a                 move.w    10(a6),d6
[00fdb05c] 2a6e 0010                 movea.l   16(a6),a5
[00fdb060] 99cc                      suba.l    a4,a4
[00fdb062] 97cb                      suba.l    a3,a3
[00fdb064] 4a47                      tst.w     d7
[00fdb066] 6622                      bne.s     $00FDB08A
[00fdb068] 3e86                      move.w    d6,(a7)
[00fdb06a] f5c4                      dc.w      $F5C4
[00fdb06c] 2d40 fffc                 move.l    d0,-4(a6)
[00fdb070] 2e8d                      move.l    a5,(a7)
[00fdb072] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fdb076] 3f06                      move.w    d6,-(a7)
[00fdb078] 2f3c 0001 ffff            move.l    #$0001FFFF,-(a7)
[00fdb07e] f4dc                      dc.w      $F4DC
[00fdb080] defc 000a                 adda.w    #10,a7
[00fdb084] 2840                      movea.l   d0,a4
[00fdb086] 6000 00c0                 bra       $00FDB148
[00fdb08a] bc7c ffff                 cmp.w     #$FFFF,d6
[00fdb08e] 6700 00b8                 beq       $00FDB148
[00fdb092] 3e87                      move.w    d7,(a7)
[00fdb094] f2ec                      dc.w      $F2EC
[00fdb096] 2d40 fff8                 move.l    d0,-8(a6)
[00fdb09a] 206e fff8                 movea.l   -8(a6),a0
[00fdb09e] 2068 0018                 movea.l   24(a0),a0
[00fdb0a2] 2668 0082                 movea.l   130(a0),a3
[00fdb0a6] 6008                      bra.s     $00FDB0B0
[00fdb0a8] bc6b 0020                 cmp.w     32(a3),d6
[00fdb0ac] 6706                      beq.s     $00FDB0B4
[00fdb0ae] 2653                      movea.l   (a3),a3
[00fdb0b0] 200b                      move.l    a3,d0
[00fdb0b2] 66f4                      bne.s     $00FDB0A8
[00fdb0b4] 200b                      move.l    a3,d0
[00fdb0b6] 6700 0090                 beq       $00FDB148
[00fdb0ba] 486e ff7e                 pea.l     -130(a6)
[00fdb0be] 206e fff8                 movea.l   -8(a6),a0
[00fdb0c2] 2f28 0018                 move.l    24(a0),-(a7)
[00fdb0c6] 5097                      addq.l    #8,(a7)
[00fdb0c8] f36c                      dc.w      $F36C ; xstrpcpy
[00fdb0ca] 508f                      addq.l    #8,a7
[00fdb0cc] 2e8e                      move.l    a6,(a7)
[00fdb0ce] 0697 ffff ff7e            addi.l    #$FFFFFF7E,(a7)
[00fdb0d4] f5dc                      dc.w      $F5DC ; sh_name
[00fdb0d6] 2d40 ff7a                 move.l    d0,-134(a6)
[00fdb0da] 206e ff7a                 movea.l   -134(a6),a0
[00fdb0de] 4210                      clr.b     (a0)
[00fdb0e0] 206e ff7a                 movea.l   -134(a6),a0
[00fdb0e4] 0c28 005c ffff            cmpi.b    #$5C,-1(a0)
[00fdb0ea] 660c                      bne.s     $00FDB0F8
[00fdb0ec] 486e ff7e                 pea.l     -130(a6)
[00fdb0f0] 486b 0012                 pea.l     18(a3)
[00fdb0f4] f404                      dc.w      $F404 ; xstrpcat
[00fdb0f6] 508f                      addq.l    #8,a7
[00fdb0f8] 41ee ff7e                 lea.l     -130(a6),a0
[00fdb0fc] 2d48 ff7a                 move.l    a0,-134(a6)
[00fdb100] 601a                      bra.s     $00FDB11C
[00fdb102] 2f2e ff7a                 move.l    -134(a6),-(a7)
[00fdb106] 206e ff7a                 movea.l   -134(a6),a0
[00fdb10a] 1010                      move.b    (a0),d0
[00fdb10c] 4880                      ext.w     d0
[00fdb10e] 3f00                      move.w    d0,-(a7)
[00fdb110] f548                      dc.w      $F548 ; toupper
[00fdb112] 548f                      addq.l    #2,a7
[00fdb114] 205f                      movea.l   (a7)+,a0
[00fdb116] 1080                      move.b    d0,(a0)
[00fdb118] 52ae ff7a                 addq.l    #1,-134(a6)
[00fdb11c] 206e ff7a                 movea.l   -134(a6),a0
[00fdb120] 4a10                      tst.b     (a0)
[00fdb122] 66de                      bne.s     $00FDB102
[00fdb124] 2e8d                      move.l    a5,(a7)
[00fdb126] 486e ff7e                 pea.l     -130(a6)
[00fdb12a] 3f3c ffff                 move.w    #$FFFF,-(a7)
[00fdb12e] 082b 0004 0009            btst      #4,9(a3)
[00fdb134] 6706                      beq.s     $00FDB13C
[00fdb136] 3f3c 0001                 move.w    #1,-(a7)
[00fdb13a] 6002                      bra.s     $00FDB13E
[00fdb13c] 4267                      clr.w     -(a7)
[00fdb13e] 4267                      clr.w     -(a7)
[00fdb140] f4dc                      dc.w      $F4DC
[00fdb142] defc 000a                 adda.w    #10,a7
[00fdb146] 2840                      movea.l   d0,a4
[00fdb148] 206e 000c                 movea.l   12(a6),a0
[00fdb14c] 208b                      move.l    a3,(a0)
[00fdb14e] 200c                      move.l    a4,d0
[00fdb150] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfdb152
xfdb152: ds.b 0
#if 0
[00fdb152] 4e56 0000                 link      a6,#0
[00fdb156] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fdb15a] 2e2e 0008                 move.l    8(a6),d7
[00fdb15e] 2a6e 000c                 movea.l   12(a6),a5
[00fdb162] 3c2e 0010                 move.w    16(a6),d6
[00fdb166] 600e                      bra.s     $00FDB176
[00fdb168] 3e86                      move.w    d6,(a7)
[00fdb16a] 101d                      move.b    (a5)+,d0
[00fdb16c] 4880                      ext.w     d0
[00fdb16e] 3f00                      move.w    d0,-(a7)
[00fdb170] 2f07                      move.l    d7,-(a7)
[00fdb172] f5e0                      dc.w      $F5E0 ; menu_ienable
[00fdb174] 5c8f                      addq.l    #6,a7
[00fdb176] 4a15                      tst.b     (a5)
[00fdb178] 66ee                      bne.s     $00FDB168
[00fdb17a] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfdb17c
xfdb17c: ds.b 0
#if 0
[00fdb17c] 4e56 fff0                 link      a6,#$FFF0
[00fdb180] 48e7 1f04                 movem.l   d3-d7/a5,-(a7)
[00fdb184] 2e2e 0008                 move.l    8(a6),d7
[00fdb188] 7c12                      moveq.l   #18,d6
[00fdb18a] 600e                      bra.s     $00FDB19A
[00fdb18c] 3ebc 0001                 move.w    #1,(a7)
[00fdb190] 3f06                      move.w    d6,-(a7)
[00fdb192] 2f07                      move.l    d7,-(a7)
[00fdb194] f5e0                      dc.w      $F5E0 ; menu_ienable
[00fdb196] 5c8f                      addq.l    #6,a7
[00fdb198] 5246                      addq.w    #1,d6
[00fdb19a] bc7c 0026                 cmp.w     #$0026,d6
[00fdb19e] 6fec                      ble.s     $00FDB18C
[00fdb1a0] 4257                      clr.w     (a7)
[00fdb1a2] 2f3c 00fe b1c4            move.l    #$00FEB1C4,-(a7)
[00fdb1a8] 2f07                      move.l    d7,-(a7)
[00fdb1aa] f5e4                      dc.w      $F5E4
[00fdb1ac] 508f                      addq.l    #8,a7
[00fdb1ae] 4245                      clr.w     d5
[00fdb1b0] 4246                      clr.w     d6
[00fdb1b2] 6000 009e                 bra       $00FDB252
[00fdb1b6] 486e fffe                 pea.l     -2(a6)
[00fdb1ba] 486e fffa                 pea.l     -6(a6)
[00fdb1be] 3f06                      move.w    d6,-(a7)
[00fdb1c0] 2079 0000 a788            movea.l   _thedesk,a0
[00fdb1c6] 3f28 3598                 move.w    13720(a0),-(a7)
[00fdb1ca] f2f8                      dc.w      $F2F8
[00fdb1cc] defc 000c                 adda.w    #12,a7
[00fdb1d0] 2a40                      movea.l   d0,a5
[00fdb1d2] 302d 0006                 move.w    6(a5),d0
[00fdb1d6] 6058                      bra.s     $00FDB230
[00fdb1d8] 4a6e fffe                 tst.w     -2(a6)
[00fdb1dc] 6708                      beq.s     $00FDB1E6
[00fdb1de] 203c 00fe b1ca            move.l    #$00FEB1CA,d0
[00fdb1e4] 6006                      bra.s     $00FDB1EC
[00fdb1e6] 203c 00fe b1ce            move.l    #$00FEB1CE,d0
[00fdb1ec] 2d40 fff6                 move.l    d0,-10(a6)
[00fdb1f0] 6052                      bra.s     $00FDB244
[00fdb1f2] 2d7c 00fe b1ce fff6       move.l    #$00FEB1CE,-10(a6)
[00fdb1fa] 6048                      bra.s     $00FDB244
[00fdb1fc] 2d7c 00fe b1f4 fff6       move.l    #$00FEB1F4,-10(a6)
[00fdb204] 603e                      bra.s     $00FDB244
[00fdb206] 302d 0016                 move.w    22(a5),d0
[00fdb20a] 4880                      ext.w     d0
[00fdb20c] b07c 0042                 cmp.w     #$0042,d0
[00fdb210] 6f08                      ble.s     $00FDB21A
[00fdb212] 203c 00fe b1c0            move.l    #$00FEB1C0,d0
[00fdb218] 6006                      bra.s     $00FDB220
[00fdb21a] 203c 00fe b1d2            move.l    #$00FEB1D2,d0
[00fdb220] 2d40 fff6                 move.l    d0,-10(a6)
[00fdb224] 601e                      bra.s     $00FDB244
[00fdb226] 2d7c 00fe b1d4 fff6       move.l    #$00FEB1D4,-10(a6)
[00fdb22e] 6014                      bra.s     $00FDB244
[00fdb230] b07c 0004                 cmp.w     #$0004,d0
[00fdb234] 620e                      bhi.s     $00FDB244
[00fdb236] e540                      asl.w     #2,d0
[00fdb238] 3040                      movea.w   d0,a0
[00fdb23a] d1fc 00fe b206            adda.l    #$00FEB206,a0
[00fdb240] 2050                      movea.l   (a0),a0
[00fdb242] 4ed0                      jmp       (a0)
[00fdb244] 4257                      clr.w     (a7)
[00fdb246] 2f2e fff6                 move.l    -10(a6),-(a7)
[00fdb24a] 2f07                      move.l    d7,-(a7)
[00fdb24c] f5e4                      dc.w      $F5E4
[00fdb24e] 508f                      addq.l    #8,a7
[00fdb250] 5245                      addq.w    #1,d5
[00fdb252] 3e86                      move.w    d6,(a7)
[00fdb254] 2079 0000 a788            movea.l   _thedesk,a0
[00fdb25a] 3f28 3596                 move.w    13718(a0),-(a7)
[00fdb25e] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fdb264] 0697 0000 5e88            addi.l    #$00005E88,(a7)
[00fdb26a] f4f8                      dc.w      $F4F8
[00fdb26c] 5c8f                      addq.l    #6,a7
[00fdb26e] 3c00                      move.w    d0,d6
[00fdb270] 6600 ff44                 bne       $00FDB1B6
[00fdb274] f584                      dc.w      $F584
[00fdb276] 4a80                      tst.l     d0
[00fdb278] 6708                      beq.s     $00FDB282
#endif

	xdef xfdb27a
xfdb27a: ds.b 0
#if 0
[00fdb27a] 203c 00fe b1e4            move.l    #$00FEB1E4,d0
[00fdb280] 6006                      bra.s     $00FDB288
[00fdb282] 203c 00fe b1e0            move.l    #$00FEB1E0,d0
[00fdb288] 2d40 fff6                 move.l    d0,-10(a6)
[00fdb28c] 202e fff6                 move.l    -10(a6),d0
[00fdb290] b0bc 00fe b1e4            cmp.l     #$00FEB1E4,d0
[00fdb296] 6704                      beq.s     $00FDB29C
[00fdb298] 4257                      clr.w     (a7)
[00fdb29a] 6004                      bra.s     $00FDB2A0
[00fdb29c] 3ebc 0001                 move.w    #1,(a7)
[00fdb2a0] 2f2e fff6                 move.l    -10(a6),-(a7)
[00fdb2a4] 2f07                      move.l    d7,-(a7)
[00fdb2a6] f5e4                      dc.w      $F5E4
[00fdb2a8] 508f                      addq.l    #8,a7
[00fdb2aa] f584                      dc.w      $F584
[00fdb2ac] 2d40 fff0                 move.l    d0,-16(a6)
[00fdb2b0] 4aae fff0                 tst.l     -16(a6)
[00fdb2b4] 6738                      beq.s     $00FDB2EE
[00fdb2b6] 2079 0000 a788            movea.l   _thedesk,a0
[00fdb2bc] 2ea8 35a8                 move.l    13736(a0),(a7)
[00fdb2c0] 2f2e fff0                 move.l    -16(a6),-(a7)
[00fdb2c4] 0697 0000 001c            addi.l    #$0000001C,(a7)
[00fdb2ca] f39c                      dc.w      $F39C ; streq
[00fdb2cc] 588f                      addq.l    #4,a7
[00fdb2ce] 4a40                      tst.w     d0
[00fdb2d0] 6706                      beq.s     $00FDB2D8
[00fdb2d2] 426e fff4                 clr.w     -12(a6)
[00fdb2d6] 6006                      bra.s     $00FDB2DE
[00fdb2d8] 3d7c 0001 fff4            move.w    #1,-12(a6)
[00fdb2de] 3eae fff4                 move.w    -12(a6),(a7)
[00fdb2e2] 2f3c 00fe b1fa            move.l    #$00FEB1FA,-(a7)
[00fdb2e8] 2f07                      move.l    d7,-(a7)
[00fdb2ea] f5e4                      dc.w      $F5E4
[00fdb2ec] 508f                      addq.l    #8,a7
[00fdb2ee] ba7c 0001                 cmp.w     #1,d5
[00fdb2f2] 6722                      beq.s     $00FDB316
[00fdb2f4] 4a45                      tst.w     d5
[00fdb2f6] 6708                      beq.s     $00FDB300
[00fdb2f8] 203c 00fe b1ee            move.l    #$00FEB1EE,d0
[00fdb2fe] 6006                      bra.s     $00FDB306
[00fdb300] 203c 00fe b1da            move.l    #$00FEB1DA,d0
[00fdb306] 2d40 fff6                 move.l    d0,-10(a6)
[00fdb30a] 4257                      clr.w     (a7)
[00fdb30c] 2f2e fff6                 move.l    -10(a6),-(a7)
[00fdb310] 2f07                      move.l    d7,-(a7)
[00fdb312] f5e4                      dc.w      $F5E4
[00fdb314] 508f                      addq.l    #8,a7
[00fdb316] f83d                      dc.w      $F83D ; movem.l (a7)+,d4-d7/a5
#endif

	xdef xfdb318
xfdb318: ds.b 0
#if 0
[00fdb318] 4e56 fff6                 link      a6,#$FFF6
[00fdb31c] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fdb320] 2679 0000 a788            movea.l   _thedesk,a3
[00fdb326] 4247                      clr.w     d7
[00fdb328] f584                      dc.w      $F584
[00fdb32a] 2a40                      movea.l   d0,a5
[00fdb32c] 4257                      clr.w     (a7)
[00fdb32e] 3f2b 3596                 move.w    13718(a3),-(a7)
[00fdb332] 486b 5e88                 pea.l     24200(a3)
[00fdb336] f4f8                      dc.w      $F4F8
[00fdb338] 5c8f                      addq.l    #6,a7
[00fdb33a] 3c00                      move.w    d0,d6
[00fdb33c] 302e 0008                 move.w    8(a6),d0
[00fdb340] 605e                      bra.s     $00FDB3A0
[00fdb342] 4a46                      tst.w     d6
[00fdb344] 6706                      beq.s     $00FDB34C
[00fdb346] 3e86                      move.w    d6,(a7)
[00fdb348] f5e8                      dc.w      $F5E8
[00fdb34a] 3e00                      move.w    d0,d7
[00fdb34c] 6000 006a                 bra.w     $00FDB3B8
[00fdb350] 4a46                      tst.w     d6
[00fdb352] 6706                      beq.s     $00FDB35A
[00fdb354] 3e86                      move.w    d6,(a7)
[00fdb356] f5ec                      dc.w      $F5EC
[00fdb358] 3e00                      move.w    d0,d7
[00fdb35a] 605c                      bra.s     $00FDB3B8
[00fdb35c] 200d                      move.l    a5,d0
[00fdb35e] 6708                      beq.s     $00FDB368
[00fdb360] 2e8d                      move.l    a5,(a7)
[00fdb362] f5f0                      dc.w      $F5F0
[00fdb364] 4257                      clr.w     (a7)
[00fdb366] f444                      dc.w      $F444
[00fdb368] 604e                      bra.s     $00FDB3B8
[00fdb36a] 200d                      move.l    a5,d0
[00fdb36c] 670e                      beq.s     $00FDB37C
[00fdb36e] 3eab 3598                 move.w    13720(a3),(a7)
[00fdb372] f444                      dc.w      $F444
[00fdb374] 4257                      clr.w     (a7)
[00fdb376] 2f0d                      move.l    a5,-(a7)
[00fdb378] f5f4                      dc.w      $F5F4
[00fdb37a] 588f                      addq.l    #4,a7
[00fdb37c] 603a                      bra.s     $00FDB3B8
[00fdb37e] 200d                      move.l    a5,d0
[00fdb380] 6710                      beq.s     $00FDB392
[00fdb382] 3eab 3598                 move.w    13720(a3),(a7)
[00fdb386] f444                      dc.w      $F444
[00fdb388] 3ebc 0001                 move.w    #1,(a7)
[00fdb38c] 2f0d                      move.l    a5,-(a7)
[00fdb38e] f5f4                      dc.w      $F5F4
[00fdb390] 588f                      addq.l    #4,a7
[00fdb392] 6024                      bra.s     $00FDB3B8
[00fdb394] 4a46                      tst.w     d6
[00fdb396] 6706                      beq.s     $00FDB39E
[00fdb398] 3e86                      move.w    d6,(a7)
[00fdb39a] f5f8                      dc.w      $F5F8
[00fdb39c] 3e00                      move.w    d0,d7
[00fdb39e] 6018                      bra.s     $00FDB3B8
[00fdb3a0] 907c 0012                 sub.w     #$0012,d0
[00fdb3a4] b07c 0007                 cmp.w     #$0007,d0
[00fdb3a8] 620e                      bhi.s     $00FDB3B8
[00fdb3aa] e540                      asl.w     #2,d0
[00fdb3ac] 3040                      movea.w   d0,a0
[00fdb3ae] d1fc 00fe b21a            adda.l    #$00FEB21A,a0
[00fdb3b4] 2050                      movea.l   (a0),a0
[00fdb3b6] 4ed0                      jmp       (a0)
[00fdb3b8] 3007                      move.w    d7,d0
[00fdb3ba] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef xfdb3bc
xfdb3bc: ds.b 0
#if 0
[00fdb3bc] 4e56 0000                 link      a6,#0
[00fdb3c0] 48e7 3f04                 movem.l   d2-d7/a5,-(a7)
[00fdb3c4] 3e2e 0008                 move.w    8(a6),d7
[00fdb3c8] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdb3ce] 4246                      clr.w     d6
[00fdb3d0] 3a2d 3004                 move.w    12292(a5),d5
[00fdb3d4] 382d 3014                 move.w    12308(a5),d4
[00fdb3d8] 3007                      move.w    d7,d0
[00fdb3da] 6018                      bra.s     $00FDB3F4
[00fdb3dc] 4245                      clr.w     d5
[00fdb3de] 602c                      bra.s     $00FDB40C
[00fdb3e0] 7a01                      moveq.l   #1,d5
[00fdb3e2] 6028                      bra.s     $00FDB40C
[00fdb3e4] 4244                      clr.w     d4
[00fdb3e6] 6024                      bra.s     $00FDB40C
[00fdb3e8] 7801                      moveq.l   #1,d4
[00fdb3ea] 6020                      bra.s     $00FDB40C
[00fdb3ec] 7802                      moveq.l   #2,d4
[00fdb3ee] 601c                      bra.s     $00FDB40C
[00fdb3f0] 7803                      moveq.l   #3,d4
[00fdb3f2] 6018                      bra.s     $00FDB40C
[00fdb3f4] 907c 001b                 sub.w     #$001B,d0
[00fdb3f8] b07c 0006                 cmp.w     #$0006,d0
[00fdb3fc] 620e                      bhi.s     $00FDB40C
[00fdb3fe] e540                      asl.w     #2,d0
[00fdb400] 3040                      movea.w   d0,a0
[00fdb402] d1fc 00fe b23a            adda.l    #$00FEB23A,a0
[00fdb408] 2050                      movea.l   (a0),a0
[00fdb40a] 4ed0                      jmp       (a0)
[00fdb40c] ba6d 3004                 cmp.w     12292(a5),d5
[00fdb410] 6606                      bne.s     $00FDB418
[00fdb412] b86d 3014                 cmp.w     12308(a5),d4
[00fdb416] 6754                      beq.s     $00FDB46C
[00fdb418] ba6d 3004                 cmp.w     12292(a5),d5
[00fdb41c] 6720                      beq.s     $00FDB43E
[00fdb41e] 4257                      clr.w     (a7)
[00fdb420] 3f2d 359c                 move.w    13724(a5),-(a7)
[00fdb424] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdb428] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdb42a] 5c8f                      addq.l    #6,a7
[00fdb42c] 3b47 359c                 move.w    d7,13724(a5)
[00fdb430] 3ebc 0001                 move.w    #1,(a7)
[00fdb434] 3f07                      move.w    d7,-(a7)
[00fdb436] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdb43a] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdb43c] 5c8f                      addq.l    #6,a7
[00fdb43e] b86d 3014                 cmp.w     12308(a5),d4
[00fdb442] 6720                      beq.s     $00FDB464
[00fdb444] 4257                      clr.w     (a7)
[00fdb446] 3f2d 359e                 move.w    13726(a5),-(a7)
[00fdb44a] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdb44e] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdb450] 5c8f                      addq.l    #6,a7
[00fdb452] 3b47 359e                 move.w    d7,13726(a5)
[00fdb456] 3ebc 0001                 move.w    #1,(a7)
[00fdb45a] 3f07                      move.w    d7,-(a7)
[00fdb45c] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdb460] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdb462] 5c8f                      addq.l    #6,a7
[00fdb464] 3e84                      move.w    d4,(a7)
[00fdb466] 3f05                      move.w    d5,-(a7)
[00fdb468] f600                      dc.w      $F600
[00fdb46a] 548f                      addq.l    #2,a7
[00fdb46c] 3006                      move.w    d6,d0
[00fdb46e] f83f                      dc.w      $F83F ; movem.l (a7)+,d3-d7/a5
#endif

	xdef xfdb470
xfdb470: ds.b 0
#if 0
[00fdb470] 4e56 ffec                 link      a6,#$FFEC
[00fdb474] 48e7 0f0c                 movem.l   d4-d7/a4-a5,-(a7)
[00fdb478] 9bcd                      suba.l    a5,a5
[00fdb47a] 42ae fff4                 clr.l     -12(a6)
[00fdb47e] 426e fff2                 clr.w     -14(a6)
[00fdb482] 2879 0000 a788            movea.l   _thedesk,a4
[00fdb488] 4247                      clr.w     d7
[00fdb48a] 486e fff8                 pea.l     -8(a6)
[00fdb48e] 486e fffa                 pea.l     -6(a6)
[00fdb492] 486e fffc                 pea.l     -4(a6)
[00fdb496] 486e fffe                 pea.l     -2(a6)
[00fdb49a] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fdb49e] 486c 5e88                 pea.l     24200(a4)
[00fdb4a2] f56c                      dc.w      $F56C
[00fdb4a4] defc 0016                 adda.w    #$0016,a7
[00fdb4a8] 4257                      clr.w     (a7)
[00fdb4aa] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fdb4ae] 486c 5e88                 pea.l     24200(a4)
[00fdb4b2] f4f8                      dc.w      $F4F8
[00fdb4b4] 5c8f                      addq.l    #6,a7
[00fdb4b6] 3c00                      move.w    d0,d6
[00fdb4b8] 4a46                      tst.w     d6
[00fdb4ba] 6716                      beq.s     $00FDB4D2
[00fdb4bc] 486e fff2                 pea.l     -14(a6)
[00fdb4c0] 486e fff4                 pea.l     -12(a6)
[00fdb4c4] 3f06                      move.w    d6,-(a7)
[00fdb4c6] 3f2c 3598                 move.w    13720(a4),-(a7)
[00fdb4ca] f2f8                      dc.w      $F2F8
[00fdb4cc] defc 000c                 adda.w    #12,a7
[00fdb4d0] 2a40                      movea.l   d0,a5
[00fdb4d2] 302e 0008                 move.w    8(a6),d0
[00fdb4d6] 6000 00f6                 bra       $00FDB5CE
[00fdb4da] 200d                      move.l    a5,d0
[00fdb4dc] 673c                      beq.s     $00FDB51A
[00fdb4de] 2e8d                      move.l    a5,(a7)
[00fdb4e0] f604                      dc.w      $F604
[00fdb4e2] 4a40                      tst.w     d0
[00fdb4e4] 6734                      beq.s     $00FDB51A
[00fdb4e6] f608                      dc.w      $F608
[00fdb4e8] 486e fff8                 pea.l     -8(a6)
[00fdb4ec] 486e fffa                 pea.l     -6(a6)
[00fdb4f0] 486e fffc                 pea.l     -4(a6)
[00fdb4f4] 486e fffe                 pea.l     -2(a6)
[00fdb4f8] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdb4fc] 4267                      clr.w     -(a7)
[00fdb4fe] f5c8                      dc.w      $F5C8 ; wind_get
[00fdb500] defc 0014                 adda.w    #$0014,a7
[00fdb504] 3eae fff8                 move.w    -8(a6),(a7)
[00fdb508] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fdb50c] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fdb510] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdb514] 4267                      clr.w     -(a7)
[00fdb516] f2c0                      dc.w      $F2C0
[00fdb518] 508f                      addq.l    #8,a7
[00fdb51a] 6000 00ca                 bra       $00FDB5E6
[00fdb51e] 200d                      move.l    a5,d0
[00fdb520] 6720                      beq.s     $00FDB542
[00fdb522] 4a6e fff2                 tst.w     -14(a6)
[00fdb526] 671a                      beq.s     $00FDB542
[00fdb528] 2e8d                      move.l    a5,(a7)
[00fdb52a] 2f2e fff4                 move.l    -12(a6),-(a7)
[00fdb52e] 0697 0000 0012            addi.l    #$00000012,(a7)
[00fdb534] f60c                      dc.w      $F60C
[00fdb536] 588f                      addq.l    #4,a7
[00fdb538] 4a40                      tst.w     d0
[00fdb53a] 6706                      beq.s     $00FDB542
[00fdb53c] 3ebc 011b                 move.w    #$011B,(a7)
[00fdb540] f610                      dc.w      $F610 ; hd_keybd
[00fdb542] 6000 00a2                 bra       $00FDB5E6
[00fdb546] f614                      dc.w      $F614
[00fdb548] 3e00                      move.w    d0,d7
[00fdb54a] 6000 009a                 bra       $00FDB5E6
[00fdb54e] 4297                      clr.l     (a7)
[00fdb550] 2f3c 0001 001f            move.l    #$0001001F,-(a7)
[00fdb556] f0dc                      dc.w      $F0DC ; fill_string
[00fdb558] 588f                      addq.l    #4,a7
[00fdb55a] b07c 0001                 cmp.w     #1,d0
[00fdb55e] 6612                      bne.s     $00FDB572
[00fdb560] 3ebc 0001                 move.w    #1,(a7)
[00fdb564] f094                      dc.w      $F094 ; desk_wait
[00fdb566] f618                      dc.w      $F618
[00fdb568] 3ebc 0001                 move.w    #1,(a7)
[00fdb56c] f61c                      dc.w      $F61C ; save_inf
[00fdb56e] 4257                      clr.w     (a7)
[00fdb570] f094                      dc.w      $F094 ; desk_wait
[00fdb572] 6000 0072                 bra.w     $00FDB5E6
[00fdb576] 4297                      clr.l     (a7)
[00fdb578] 2f3c 0001 0020            move.l    #$00010020,-(a7)
[00fdb57e] f0dc                      dc.w      $F0DC ; fill_string
[00fdb580] 588f                      addq.l    #4,a7
[00fdb582] b07c 0001                 cmp.w     #1,d0
[00fdb586] 660c                      bne.s     $00FDB594
[00fdb588] 3ebc 0001                 move.w    #1,(a7)
[00fdb58c] f094                      dc.w      $F094 ; desk_wait
[00fdb58e] f620                      dc.w      $F620 ; av_hardcopy
[00fdb590] 4257                      clr.w     (a7)
[00fdb592] f094                      dc.w      $F094 ; desk_wait
[00fdb594] 6050                      bra.s     $00FDB5E6
[00fdb596] 4a6c 35a4                 tst.w     13732(a4)
[00fdb59a] 6704                      beq.s     $00FDB5A0
[00fdb59c] 4257                      clr.w     (a7)
[00fdb59e] 6004                      bra.s     $00FDB5A4
[00fdb5a0] 3ebc 0001                 move.w    #1,(a7)
[00fdb5a4] 3f3c 0040                 move.w    #$0040,-(a7)
[00fdb5a8] f0ec                      dc.w      $F0EC ; trp14
[00fdb5aa] 548f                      addq.l    #2,a7
[00fdb5ac] 4a6c 35a4                 tst.w     13732(a4)
[00fdb5b0] 6704                      beq.s     $00FDB5B6
[00fdb5b2] 4240                      clr.w     d0
[00fdb5b4] 6002                      bra.s     $00FDB5B8
[00fdb5b6] 7001                      moveq.l   #1,d0
[00fdb5b8] 3940 35a4                 move.w    d0,13732(a4)
[00fdb5bc] 3eac 35a4                 move.w    13732(a4),(a7)
[00fdb5c0] 3f3c 002a                 move.w    #$002A,-(a7)
[00fdb5c4] 2f2c 3556                 move.l    13654(a4),-(a7)
[00fdb5c8] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdb5ca] 5c8f                      addq.l    #6,a7
[00fdb5cc] 6018                      bra.s     $00FDB5E6
[00fdb5ce] 907c 0023                 sub.w     #$0023,d0
[00fdb5d2] b07c 0007                 cmp.w     #$0007,d0
[00fdb5d6] 620e                      bhi.s     $00FDB5E6
[00fdb5d8] e540                      asl.w     #2,d0
[00fdb5da] 3040                      movea.w   d0,a0
[00fdb5dc] d1fc 00fe b256            adda.l    #$00FEB256,a0
[00fdb5e2] 2050                      movea.l   (a0),a0
[00fdb5e4] 4ed0                      jmp       (a0)
[00fdb5e6] 3007                      move.w    d7,d0
[00fdb5e8] fc39                      dc.w      $FC39 ; movem.l (a7)+,d5-d7/a4-a5
#endif

	xdef _hd_button
_hd_button: ds.b 0
#if 0
[00fdb5ea] 4e56 fff2                 link      a6,#$FFF2
[00fdb5ee] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fdb5f2] 2879 0000 a788            movea.l   _thedesk,a4
[00fdb5f8] 47ee fff4                 lea.l     -12(a6),a3
[00fdb5fc] 426e fffe                 clr.w     -2(a6)
[00fdb600] 2f2e 000a                 move.l    10(a6),-(a7)
[00fdb604] f2e8                      dc.w      $F2E8 ; wind_find
[00fdb606] 588f                      addq.l    #4,a7
[00fdb608] 3e00                      move.w    d0,d7
[00fdb60a] be6c 3598                 cmp.w     13720(a4),d7
[00fdb60e] 6706                      beq.s     $00FDB616
[00fdb610] 3eac 3598                 move.w    13720(a4),(a7)
[00fdb614] f444                      dc.w      $F444
[00fdb616] 4257                      clr.w     (a7)
[00fdb618] 3f07                      move.w    d7,-(a7)
[00fdb61a] f4b0                      dc.w      $F4B0
[00fdb61c] 548f                      addq.l    #2,a7
[00fdb61e] 3947 359a                 move.w    d7,13722(a4)
[00fdb622] 2e8b                      move.l    a3,(a7)
[00fdb624] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdb628] 3f07                      move.w    d7,-(a7)
[00fdb62a] f4bc                      dc.w      $F4BC
[00fdb62c] 588f                      addq.l    #4,a7
[00fdb62e] 0c6e 0001 0008            cmpi.w    #1,8(a6)
[00fdb634] 6600 0088                 bne       $00FDB6BE
[00fdb638] 4257                      clr.w     (a7)
[00fdb63a] 2f0b                      move.l    a3,-(a7)
[00fdb63c] 3f2e 0010                 move.w    16(a6),-(a7)
[00fdb640] 2f2e 000a                 move.l    10(a6),-(a7)
[00fdb644] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fdb648] 2f2c 5e2c                 move.l    24108(a4),-(a7)
[00fdb64c] 3f2c 3598                 move.w    13720(a4),-(a7)
[00fdb650] f624                      dc.w      $F624
[00fdb652] defc 0012                 adda.w    #$0012,a7
[00fdb656] 486e fffc                 pea.l     -4(a6)
[00fdb65a] 486e 000e                 pea.l     14(a6)
[00fdb65e] 486e fffc                 pea.l     -4(a6)
[00fdb662] 486e fffc                 pea.l     -4(a6)
[00fdb666] f2dc                      dc.w      $F2DC ; graf_mkstate
[00fdb668] defc 0010                 adda.w    #$0010,a7
[00fdb66c] 082e 0000 000f            btst      #0,15(a6)
[00fdb672] 6748                      beq.s     $00FDB6BC
[00fdb674] 486e fff2                 pea.l     -14(a6)
[00fdb678] 2f0b                      move.l    a3,-(a7)
[00fdb67a] 2f2e 000a                 move.l    10(a6),-(a7)
[00fdb67e] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fdb682] 2f2c 5e2c                 move.l    24108(a4),-(a7)
[00fdb686] 3f2c 3598                 move.w    13720(a4),-(a7)
[00fdb68a] f628                      dc.w      $F628
[00fdb68c] defc 0014                 adda.w    #$0014,a7
[00fdb690] 3800                      move.w    d0,d4
[00fdb692] b87c ffff                 cmp.w     #$FFFF,d4
[00fdb696] 6724                      beq.s     $00FDB6BC
[00fdb698] 4a44                      tst.w     d4
[00fdb69a] 670c                      beq.s     $00FDB6A8
[00fdb69c] 3e84                      move.w    d4,(a7)
[00fdb69e] f2ec                      dc.w      $F2EC
[00fdb6a0] 2a40                      movea.l   d0,a5
[00fdb6a2] 3c2d 000a                 move.w    10(a5),d6
[00fdb6a6] 6002                      bra.s     $00FDB6AA
[00fdb6a8] 7c01                      moveq.l   #1,d6
[00fdb6aa] 3eae fff2                 move.w    -14(a6),(a7)
[00fdb6ae] 3f06                      move.w    d6,-(a7)
[00fdb6b0] 3f04                      move.w    d4,-(a7)
[00fdb6b2] 3f07                      move.w    d7,-(a7)
[00fdb6b4] f62c                      dc.w      $F62C
[00fdb6b6] 5c8f                      addq.l    #6,a7
[00fdb6b8] 3d40 fffe                 move.w    d0,-2(a6)
[00fdb6bc] 602c                      bra.s     $00FDB6EA
[00fdb6be] 3ebc 0001                 move.w    #1,(a7)
[00fdb6c2] 486e fff4                 pea.l     -12(a6)
[00fdb6c6] 3f2e 0010                 move.w    16(a6),-(a7)
[00fdb6ca] 2f2e 000a                 move.l    10(a6),-(a7)
[00fdb6ce] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fdb6d2] 2f2c 5e2c                 move.l    24108(a4),-(a7)
[00fdb6d6] 3f2c 3598                 move.w    13720(a4),-(a7)
[00fdb6da] f624                      dc.w      $F624
[00fdb6dc] defc 0012                 adda.w    #$0012,a7
[00fdb6e0] 3ebc 0012                 move.w    #$0012,(a7)
[00fdb6e4] f630                      dc.w      $F630
[00fdb6e6] 3d40 fffe                 move.w    d0,-2(a6)
[00fdb6ea] 2eac 3556                 move.l    13654(a4),(a7)
[00fdb6ee] f634                      dc.w      $F634
[00fdb6f0] 302e fffe                 move.w    -2(a6),d0
[00fdb6f4] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef _hd_keybd
_hd_keybd: ds.b 0
#if 0
[00fdb6f6] 4e56 fff6                 link      a6,#$FFF6
[00fdb6fa] 0c6e 011b 0008            cmpi.w    #$011B,8(a6)
[00fdb700] 666e                      bne.s     $00FDB770
[00fdb702] f584                      dc.w      $F584
[00fdb704] 2d40 fffc                 move.l    d0,-4(a6)
[00fdb708] 6766                      beq.s     $00FDB770
[00fdb70a] 2eae fffc                 move.l    -4(a6),(a7)
[00fdb70e] 0697 0000 001c            addi.l    #$0000001C,(a7)
[00fdb714] 2079 0000 a788            movea.l   _thedesk,a0
[00fdb71a] 2f28 35a8                 move.l    13736(a0),-(a7)
[00fdb71e] f39c                      dc.w      $F39C ; streq
[00fdb720] 588f                      addq.l    #4,a7
[00fdb722] 4a40                      tst.w     d0
[00fdb724] 6644                      bne.s     $00FDB76A
[00fdb726] 206e fffc                 movea.l   -4(a6),a0
[00fdb72a] 2068 0018                 movea.l   24(a0),a0
[00fdb72e] 1028 0008                 move.b    8(a0),d0
[00fdb732] 4880                      ext.w     d0
[00fdb734] 3e80                      move.w    d0,(a7)
[00fdb736] f4e4                      dc.w      $F4E4
[00fdb738] 4a40                      tst.w     d0
[00fdb73a] 672c                      beq.s     $00FDB768
[00fdb73c] 3ebc 0001                 move.w    #1,(a7)
[00fdb740] f094                      dc.w      $F094 ; desk_wait
[00fdb742] 206e fffc                 movea.l   -4(a6),a0
[00fdb746] 2068 0018                 movea.l   24(a0),a0
[00fdb74a] 1028 0008                 move.b    8(a0),d0
[00fdb74e] 4880                      ext.w     d0
[00fdb750] 3e80                      move.w    d0,(a7)
[00fdb752] 0657 ffbf                 addi.w    #$FFBF,(a7)
[00fdb756] f638                      dc.w      $F638
[00fdb758] 3d40 fffa                 move.w    d0,-6(a6)
[00fdb75c] 4257                      clr.w     (a7)
[00fdb75e] f094                      dc.w      $F094 ; desk_wait
[00fdb760] 4a6e fffa                 tst.w     -6(a6)
[00fdb764] 660a                      bne.s     $00FDB770
[00fdb766] 6002                      bra.s     $00FDB76A
[00fdb768] 6006                      bra.s     $00FDB770
[00fdb76a] 2eae fffc                 move.l    -4(a6),(a7)
[00fdb76e] f4c8                      dc.w      $F4C8
[00fdb770] 4240                      clr.w     d0
[00fdb772] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfdb774
xfdb774: ds.b 0
#if 0
[00fdb774] 4e56 0000                 link      a6,#0
[00fdb778] 48e7 1f04                 movem.l   d3-d7/a5,-(a7)
[00fdb77c] 3e2e 0008                 move.w    8(a6),d7
[00fdb780] 3c2e 000a                 move.w    10(a6),d6
[00fdb784] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdb78a] 4245                      clr.w     d5
[00fdb78c] 3007                      move.w    d7,d0
[00fdb78e] 6000 009a                 bra       $00FDB82A
[00fdb792] bc7c 0009                 cmp.w     #$0009,d6
[00fdb796] 6616                      bne.s     $00FDB7AE
[00fdb798] f63c                      dc.w      $F63C
[00fdb79a] 3ebc 0009                 move.w    #$0009,(a7)
[00fdb79e] 2079 0000 a788            movea.l   _thedesk,a0
[00fdb7a4] 2f28 3562                 move.l    13666(a0),-(a7)
[00fdb7a8] f53c                      dc.w      $F53C
[00fdb7aa] 588f                      addq.l    #4,a7
[00fdb7ac] f640                      dc.w      $F640
[00fdb7ae] 6000 0098                 bra       $00FDB848
[00fdb7b2] 3e86                      move.w    d6,(a7)
[00fdb7b4] f630                      dc.w      $F630
[00fdb7b6] 3a00                      move.w    d0,d5
[00fdb7b8] 6000 008e                 bra       $00FDB848
[00fdb7bc] 3e86                      move.w    d6,(a7)
[00fdb7be] f644                      dc.w      $F644
[00fdb7c0] 3a00                      move.w    d0,d5
[00fdb7c2] 3ebc 0001                 move.w    #1,(a7)
[00fdb7c6] f094                      dc.w      $F094 ; desk_wait
[00fdb7c8] 4244                      clr.w     d4
[00fdb7ca] 6048                      bra.s     $00FDB814
[00fdb7cc] 3004                      move.w    d4,d0
[00fdb7ce] c1fc 00ee                 muls.w    #$00EE,d0
[00fdb7d2] d0b9 0000 a7ba            add.l     $0000A7BA,d0
[00fdb7d8] 2040                      movea.l   d0,a0
[00fdb7da] 4a68 0006                 tst.w     6(a0)
[00fdb7de] 6732                      beq.s     $00FDB812
[00fdb7e0] 2079 0000 a7ba            movea.l   $0000A7BA,a0
[00fdb7e6] 3204                      move.w    d4,d1
[00fdb7e8] c3fc 00ee                 muls.w    #$00EE,d1
[00fdb7ec] 2070 1818                 movea.l   24(a0,d1.l),a0
[00fdb7f0] 2ea8 0082                 move.l    130(a0),(a7)
[00fdb7f4] 3f3c ffff                 move.w    #$FFFF,-(a7)
[00fdb7f8] f494                      dc.w      $F494
[00fdb7fa] 548f                      addq.l    #2,a7
[00fdb7fc] 2f00                      move.l    d0,-(a7)
[00fdb7fe] 2079 0000 a7ba            movea.l   $0000A7BA,a0
[00fdb804] 3204                      move.w    d4,d1
[00fdb806] c3fc 00ee                 muls.w    #$00EE,d1
[00fdb80a] 2070 1818                 movea.l   24(a0,d1.l),a0
[00fdb80e] 215f 0082                 move.l    (a7)+,130(a0)
[00fdb812] 5244                      addq.w    #1,d4
[00fdb814] b87c 0004                 cmp.w     #$0004,d4
[00fdb818] 6db2                      blt.s     $00FDB7CC
[00fdb81a] f648                      dc.w      $F648
[00fdb81c] 4257                      clr.w     (a7)
[00fdb81e] f094                      dc.w      $F094 ; desk_wait
[00fdb820] 6026                      bra.s     $00FDB848
[00fdb822] 3e86                      move.w    d6,(a7)
[00fdb824] f64c                      dc.w      $F64C
[00fdb826] 3a00                      move.w    d0,d5
[00fdb828] 601e                      bra.s     $00FDB848
[00fdb82a] b07c 0003                 cmp.w     #$0003,d0
[00fdb82e] 6700 ff62                 beq       $00FDB792
[00fdb832] b07c 0004                 cmp.w     #$0004,d0
[00fdb836] 6700 ff7a                 beq       $00FDB7B2
[00fdb83a] b07c 0005                 cmp.w     #$0005,d0
[00fdb83e] 6700 ff7c                 beq       $00FDB7BC
[00fdb842] b07c 0006                 cmp.w     #$0006,d0
[00fdb846] 67da                      beq.s     $00FDB822
[00fdb848] 3ebc 0001                 move.w    #1,(a7)
[00fdb84c] 3f07                      move.w    d7,-(a7)
[00fdb84e] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdb852] f650                      dc.w      $F650 ; menu_tnormal
[00fdb854] 5c8f                      addq.l    #6,a7
[00fdb856] 3005                      move.w    d5,d0
[00fdb858] f83d                      dc.w      $F83D ; movem.l (a7)+,d4-d7/a5
#endif

	xdef _hd_msg
_hd_msg: ds.b 0
#if 0
[00fdb85a] 4e56 fff8                 link      a6,#$FFF8
[00fdb85e] 48e7 070c                 movem.l   d5-d7/a4-a5,-(a7)
[00fdb862] 2879 0000 a788            movea.l   _thedesk,a4
[00fdb868] 4246                      clr.w     d6
[00fdb86a] 3e06                      move.w    d6,d7
[00fdb86c] 302c 3426                 move.w    13350(a4),d0
[00fdb870] 6008                      bra.s     $00FDB87A
[00fdb872] 3eac 3598                 move.w    13720(a4),(a7)
[00fdb876] f444                      dc.w      $F444
[00fdb878] 6018                      bra.s     $00FDB892
[00fdb87a] 907c 0014                 sub.w     #$0014,d0
[00fdb87e] b07c 0008                 cmp.w     #$0008,d0
[00fdb882] 620e                      bhi.s     $00FDB892
[00fdb884] e540                      asl.w     #2,d0
[00fdb886] 3040                      movea.w   d0,a0
[00fdb888] d1fc 00fe b276            adda.l    #$00FEB276,a0
[00fdb88e] 2050                      movea.l   (a0),a0
[00fdb890] 4ed0                      jmp       (a0)
[00fdb892] 302c 3426                 move.w    13350(a4),d0
[00fdb896] 6000 017c                 bra       $00FDBA14
[00fdb89a] 4257                      clr.w     (a7)
[00fdb89c] 3f2c 359a                 move.w    13722(a4),-(a7)
[00fdb8a0] f4b0                      dc.w      $F4B0
[00fdb8a2] 548f                      addq.l    #2,a7
[00fdb8a4] 2f2c 342c                 move.l    13356(a4),-(a7)
[00fdb8a8] f654                      dc.w      $F654
[00fdb8aa] 588f                      addq.l    #4,a7
[00fdb8ac] 3e00                      move.w    d0,d7
[00fdb8ae] 6000 017c                 bra       $00FDBA2C
[00fdb8b2] 4a6c 342c                 tst.w     13356(a4)
[00fdb8b6] 6712                      beq.s     $00FDB8CA
[00fdb8b8] 2f2c 3432                 move.l    13362(a4),-(a7)
[00fdb8bc] 2f2c 342e                 move.l    13358(a4),-(a7)
[00fdb8c0] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb8c4] f2c0                      dc.w      $F2C0
[00fdb8c6] defc 000a                 adda.w    #10,a7
[00fdb8ca] 6000 0160                 bra       $00FDBA2C
[00fdb8ce] 4297                      clr.l     (a7)
[00fdb8d0] 42a7                      clr.l     -(a7)
[00fdb8d2] 3f3c 000a                 move.w    #10,-(a7)
[00fdb8d6] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb8da] f4b8                      dc.w      $F4B8 ; wind_set
[00fdb8dc] 508f                      addq.l    #8,a7
[00fdb8de] 486e fff8                 pea.l     -8(a6)
[00fdb8e2] 486e fffa                 pea.l     -6(a6)
[00fdb8e6] 486e fffc                 pea.l     -4(a6)
[00fdb8ea] 486e fffe                 pea.l     -2(a6)
[00fdb8ee] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdb8f2] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb8f6] f5c8                      dc.w      $F5C8 ; wind_get
[00fdb8f8] defc 0014                 adda.w    #$0014,a7
[00fdb8fc] 3eac 342c                 move.w    13356(a4),(a7)
[00fdb900] f2ec                      dc.w      $F2EC
[00fdb902] 2a40                      movea.l   d0,a5
[00fdb904] 2e8d                      move.l    a5,(a7)
[00fdb906] f58c                      dc.w      $F58C
[00fdb908] 4257                      clr.w     (a7)
[00fdb90a] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdb90e] f4b0                      dc.w      $F4B0
[00fdb910] 548f                      addq.l    #2,a7
[00fdb912] 396d 0006 359a            move.w    6(a5),13722(a4)
[00fdb918] 6000 0112                 bra       $00FDBA2C
[00fdb91c] 3ebc 0016                 move.w    #$0016,(a7)
[00fdb920] f630                      dc.w      $F630
[00fdb922] 6000 0108                 bra       $00FDBA2C
[00fdb926] 3eac 342c                 move.w    13356(a4),(a7)
[00fdb92a] f658                      dc.w      $F658
[00fdb92c] 3ebc 0001                 move.w    #1,(a7)
[00fdb930] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb934] f4b0                      dc.w      $F4B0
[00fdb936] 548f                      addq.l    #2,a7
[00fdb938] 7c01                      moveq.l   #1,d6
[00fdb93a] 6000 00f0                 bra       $00FDBA2C
[00fdb93e] 2f2c 342c                 move.l    13356(a4),-(a7)
[00fdb942] f65c                      dc.w      $F65C
[00fdb944] 588f                      addq.l    #4,a7
[00fdb946] 6000 00e4                 bra       $00FDBA2C
[00fdb94a] 4257                      clr.w     (a7)
[00fdb94c] 2f2c 342c                 move.l    13356(a4),-(a7)
[00fdb950] f660                      dc.w      $F660
[00fdb952] 588f                      addq.l    #4,a7
[00fdb954] 6000 00d6                 bra       $00FDBA2C
[00fdb958] 3ebc 0001                 move.w    #1,(a7)
[00fdb95c] 2f2c 342c                 move.l    13356(a4),-(a7)
[00fdb960] f660                      dc.w      $F660
[00fdb962] 588f                      addq.l    #4,a7
[00fdb964] 6000 00c6                 bra       $00FDBA2C
[00fdb968] 3d6c 342e fffe            move.w    13358(a4),-2(a6)
[00fdb96e] 3d6c 3430 fffc            move.w    13360(a4),-4(a6)
[00fdb974] 486e fffc                 pea.l     -4(a6)
[00fdb978] 486e fffe                 pea.l     -2(a6)
[00fdb97c] f568                      dc.w      $F568
[00fdb97e] 508f                      addq.l    #8,a7
[00fdb980] 3d6c 3432 fffa            move.w    13362(a4),-6(a6)
[00fdb986] 3d6c 3434 fff8            move.w    13364(a4),-8(a6)
[00fdb98c] 3eae fff8                 move.w    -8(a6),(a7)
[00fdb990] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fdb994] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fdb998] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdb99c] 3f3c 0005                 move.w    #$0005,-(a7)
[00fdb9a0] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb9a4] f4b8                      dc.w      $F4B8 ; wind_set
[00fdb9a6] defc 000a                 adda.w    #10,a7
[00fdb9aa] 0c6c 001b 3426            cmpi.w    #$001B,13350(a4)
[00fdb9b0] 660e                      bne.s     $00FDB9C0
[00fdb9b2] 3ebc 0001                 move.w    #1,(a7)
[00fdb9b6] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb9ba] f4b0                      dc.w      $F4B0
[00fdb9bc] 548f                      addq.l    #2,a7
[00fdb9be] 6050                      bra.s     $00FDBA10
[00fdb9c0] 486e fff8                 pea.l     -8(a6)
[00fdb9c4] 486e fffa                 pea.l     -6(a6)
[00fdb9c8] 486e fffc                 pea.l     -4(a6)
[00fdb9cc] 486e fffe                 pea.l     -2(a6)
[00fdb9d0] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdb9d4] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdb9d8] f5c8                      dc.w      $F5C8 ; wind_get
[00fdb9da] defc 0014                 adda.w    #$0014,a7
[00fdb9de] 3eac 342c                 move.w    13356(a4),(a7)
[00fdb9e2] f2ec                      dc.w      $F2EC
[00fdb9e4] 2a40                      movea.l   d0,a5
[00fdb9e6] 3eae fff8                 move.w    -8(a6),(a7)
[00fdb9ea] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fdb9ee] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fdb9f2] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdb9f6] 200c                      move.l    a4,d0
[00fdb9f8] 322d 000a                 move.w    10(a5),d1
[00fdb9fc] c3fc 0018                 muls.w    #24,d1
[00fdba00] d081                      add.l     d1,d0
[00fdba02] 2f00                      move.l    d0,-(a7)
[00fdba04] 0697 0000 5e98            addi.l    #$00005E98,(a7)
[00fdba0a] f298                      dc.w      $F298 ; r_set
[00fdba0c] defc 000a                 adda.w    #10,a7
[00fdba10] 7c01                      moveq.l   #1,d6
[00fdba12] 6018                      bra.s     $00FDBA2C
[00fdba14] 907c 000a                 sub.w     #10,d0
[00fdba18] b07c 0012                 cmp.w     #$0012,d0
[00fdba1c] 620e                      bhi.s     $00FDBA2C
[00fdba1e] e540                      asl.w     #2,d0
[00fdba20] 3040                      movea.w   d0,a0
[00fdba22] d1fc 00fe b29a            adda.l    #$00FEB29A,a0
[00fdba28] 2050                      movea.l   (a0),a0
[00fdba2a] 4ed0                      jmp       (a0)
[00fdba2c] 4a46                      tst.w     d6
[00fdba2e] 6740                      beq.s     $00FDBA70
[00fdba30] 486e fff8                 pea.l     -8(a6)
[00fdba34] 486e fffa                 pea.l     -6(a6)
[00fdba38] 486e fffc                 pea.l     -4(a6)
[00fdba3c] 486e fffe                 pea.l     -2(a6)
[00fdba40] 3f3c 0005                 move.w    #$0005,-(a7)
[00fdba44] 3f2c 342c                 move.w    13356(a4),-(a7)
[00fdba48] f5c8                      dc.w      $F5C8 ; wind_get
[00fdba4a] defc 0014                 adda.w    #$0014,a7
[00fdba4e] 3eac 342c                 move.w    13356(a4),(a7)
[00fdba52] f2ec                      dc.w      $F2EC
[00fdba54] 2a40                      movea.l   d0,a5
[00fdba56] 3eae fff8                 move.w    -8(a6),(a7)
[00fdba5a] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fdba5e] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fdba62] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdba66] 486d 00e6                 pea.l     230(a5)
[00fdba6a] f298                      dc.w      $F298 ; r_set
[00fdba6c] defc 000a                 adda.w    #10,a7
[00fdba70] 426c 3426                 clr.w     13350(a4)
[00fdba74] 2eac 3556                 move.l    13654(a4),(a7)
[00fdba78] f634                      dc.w      $F634
[00fdba7a] 3007                      move.w    d7,d0
[00fdba7c] fc31                      dc.w      $FC31 ; movem.l (a7)+,d6-d7/a4-a5
#endif

	xdef xfdba7e
xfdba7e: ds.b 0
#if 0
[00fdba7e] 4e56 0000                 link      a6,#0
[00fdba82] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fdba86] 2679 0000 a788            movea.l   _thedesk,a3
[00fdba8c] 302b 359c                 move.w    13724(a3),d0
[00fdba90] d07c ffe5                 add.w     #$FFE5,d0
[00fdba94] 3740 5c00                 move.w    d0,23552(a3)
[00fdba98] 302b 359e                 move.w    13726(a3),d0
[00fdba9c] d07c ffe2                 add.w     #$FFE2,d0
[00fdbaa0] 3740 5bfe                 move.w    d0,23550(a3)
[00fdbaa4] 376b 35a0 5c02            move.w    13728(a3),23554(a3)
[00fdbaaa] 376b 35a2 5c04            move.w    13730(a3),23556(a3)
[00fdbab0] 376b 35a4 5c06            move.w    13732(a3),23558(a3)
[00fdbab6] 376b 35a6 5c0a            move.w    13734(a3),23562(a3)
[00fdbabc] 3039 0000 6122            move.w    $00006122,d0
[00fdbac2] 5340                      subq.w    #1,d0
[00fdbac4] 3740 5c08                 move.w    d0,23560(a3)
[00fdbac8] 4247                      clr.w     d7
[00fdbaca] 602a                      bra.s     $00FDBAF6
[00fdbacc] 3ebc 0008                 move.w    #$0008,(a7)
[00fdbad0] 3007                      move.w    d7,d0
[00fdbad2] e740                      asl.w     #3,d0
[00fdbad4] 48c0                      ext.l     d0
[00fdbad6] d0bc 0000 7098            add.l     #$00007098,d0
[00fdbadc] 2f00                      move.l    d0,-(a7)
[00fdbade] 200b                      move.l    a3,d0
[00fdbae0] 3207                      move.w    d7,d1
[00fdbae2] c3fc 0088                 muls.w    #$0088,d1
[00fdbae6] d081                      add.l     d1,d0
[00fdbae8] 2f00                      move.l    d0,-(a7)
[00fdbaea] 0697 0000 5c0c            addi.l    #$00005C0C,(a7)
[00fdbaf0] f268                      dc.w      $F268 ; LBCOPY
[00fdbaf2] 508f                      addq.l    #8,a7
[00fdbaf4] 5247                      addq.w    #1,d7
[00fdbaf6] be7c 0004                 cmp.w     #$0004,d7
[00fdbafa] 6dd0                      blt.s     $00FDBACC
[00fdbafc] 4246                      clr.w     d6
[00fdbafe] 4247                      clr.w     d7
[00fdbb00] 6068                      bra.s     $00FDBB6A
[00fdbb02] 3e87                      move.w    d7,(a7)
[00fdbb04] 5257                      addq.w    #1,(a7)
[00fdbb06] f4a4                      dc.w      $F4A4
[00fdbb08] 2840                      movea.l   d0,a4
[00fdbb0a] 4a6c 0006                 tst.w     6(a4)
[00fdbb0e] 6758                      beq.s     $00FDBB68
[00fdbb10] 2a4b                      movea.l   a3,a5
[00fdbb12] 3006                      move.w    d6,d0
[00fdbb14] c1fc 0088                 muls.w    #$0088,d0
[00fdbb18] dbc0                      adda.l    d0,a5
[00fdbb1a] dbfc 0000 5c0c            adda.l    #$00005C0C,a5
[00fdbb20] 5246                      addq.w    #1,d6
[00fdbb22] 486d 0006                 pea.l     6(a5)
[00fdbb26] 486d 0004                 pea.l     4(a5)
[00fdbb2a] 486d 0002                 pea.l     2(a5)
[00fdbb2e] 2f0d                      move.l    a5,-(a7)
[00fdbb30] 3f3c 0005                 move.w    #$0005,-(a7)
[00fdbb34] 3f2c 0006                 move.w    6(a4),-(a7)
[00fdbb38] f5c8                      dc.w      $F5C8 ; wind_get
[00fdbb3a] defc 0014                 adda.w    #$0014,a7
[00fdbb3e] 486d 0002                 pea.l     2(a5)
[00fdbb42] 2f0d                      move.l    a5,-(a7)
[00fdbb44] f568                      dc.w      $F568
[00fdbb46] 508f                      addq.l    #8,a7
[00fdbb48] 3b6c 000c 0008            move.w    12(a4),8(a5)
[00fdbb4e] 3b6c 000e 000a            move.w    14(a4),10(a5)
[00fdbb54] 3b6c 0008 000c            move.w    8(a4),12(a5)
[00fdbb5a] 486d 000e                 pea.l     14(a5)
[00fdbb5e] 2f2c 0018                 move.l    24(a4),-(a7)
[00fdbb62] 5097                      addq.l    #8,(a7)
[00fdbb64] f36c                      dc.w      $F36C ; xstrpcpy
[00fdbb66] 508f                      addq.l    #8,a7
[00fdbb68] 5247                      addq.w    #1,d7
[00fdbb6a] be7c 0004                 cmp.w     #$0004,d7
[00fdbb6e] 6d92                      blt.s     $00FDBB02
[00fdbb70] 601a                      bra.s     $00FDBB8C
[00fdbb72] 2a4b                      movea.l   a3,a5
[00fdbb74] 3006                      move.w    d6,d0
[00fdbb76] c1fc 0088                 muls.w    #$0088,d0
[00fdbb7a] dbc0                      adda.l    d0,a5
[00fdbb7c] dbfc 0000 5c0c            adda.l    #$00005C0C,a5
[00fdbb82] 422d 000e                 clr.b     14(a5)
[00fdbb86] 426d 000c                 clr.w     12(a5)
[00fdbb8a] 5246                      addq.w    #1,d6
[00fdbb8c] bc7c 0004                 cmp.w     #$0004,d6
[00fdbb90] 6de0                      blt.s     $00FDBB72
[00fdbb92] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfdbb94
xfdbb94: ds.b 0
#if 0
[00fdbb94] 4e56 fff2                 link      a6,#$FFF2
[00fdbb98] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fdbb9c] 2679 0000 a788            movea.l   _thedesk,a3
[00fdbba2] 3eab 5c00                 move.w    23552(a3),(a7)
[00fdbba6] 0657 001b                 addi.w    #$001B,(a7)
[00fdbbaa] f644                      dc.w      $F644
[00fdbbac] 3eab 5bfe                 move.w    23550(a3),(a7)
[00fdbbb0] 0657 001e                 addi.w    #$001E,(a7)
[00fdbbb4] f644                      dc.w      $F644
[00fdbbb6] 376b 5c02 35a0            move.w    23554(a3),13728(a3)
[00fdbbbc] 376b 5c04 35a2            move.w    23556(a3),13730(a3)
[00fdbbc2] 376b 5c06 35a4            move.w    23558(a3),13732(a3)
[00fdbbc8] 376b 5c0a 35a6            move.w    23562(a3),13734(a3)
[00fdbbce] 3ebc 0001                 move.w    #1,(a7)
[00fdbbd2] 3f3c 0003                 move.w    #$0003,-(a7)
[00fdbbd6] f664                      dc.w      $F664 ; evnt_dclick
[00fdbbd8] 548f                      addq.l    #2,a7
[00fdbbda] 4247                      clr.w     d7
[00fdbbdc] 6000 009e                 bra       $00FDBC7C
[00fdbbe0] 2a4b                      movea.l   a3,a5
[00fdbbe2] 3007                      move.w    d7,d0
[00fdbbe4] c1fc 0088                 muls.w    #$0088,d0
[00fdbbe8] dbc0                      adda.l    d0,a5
[00fdbbea] dbfc 0000 5c0c            adda.l    #$00005C0C,a5
[00fdbbf0] 4a2d 000e                 tst.b     14(a5)
[00fdbbf4] 6700 0084                 beq       $00FDBC7A
[00fdbbf8] 3ead 000c                 move.w    12(a5),(a7)
[00fdbbfc] f59c                      dc.w      $F59C
[00fdbbfe] 2840                      movea.l   d0,a4
[00fdbc00] 200c                      move.l    a4,d0
[00fdbc02] 6776                      beq.s     $00FDBC7A
[00fdbc04] 396d 0008 000c            move.w    8(a5),12(a4)
[00fdbc0a] 396d 000a 000e            move.w    10(a5),14(a4)
[00fdbc10] 486e fff2                 pea.l     -14(a6)
[00fdbc14] 486e fff6                 pea.l     -10(a6)
[00fdbc18] 486b 32b6                 pea.l     12982(a3)
[00fdbc1c] 486e fffe                 pea.l     -2(a6)
[00fdbc20] 486d 000e                 pea.l     14(a5)
[00fdbc24] f5ac                      dc.w      $F5AC
[00fdbc26] defc 0014                 adda.w    #$0014,a7
[00fdbc2a] 486d 0002                 pea.l     2(a5)
[00fdbc2e] 2f0d                      move.l    a5,-(a7)
[00fdbc30] f568                      dc.w      $F568
[00fdbc32] 508f                      addq.l    #8,a7
[00fdbc34] 486b 32b6                 pea.l     12982(a3)
[00fdbc38] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdbc3c] f5a0                      dc.w      $F5A0
[00fdbc3e] 5c8f                      addq.l    #6,a7
[00fdbc40] 4a79 0000 742a            tst.w     _DOS_ERR
[00fdbc46] 662e                      bne.s     $00FDBC76
[00fdbc48] 3eae fffe                 move.w    -2(a6),(a7)
[00fdbc4c] f4e4                      dc.w      $F4E4
[00fdbc4e] 4a40                      tst.w     d0
[00fdbc50] 6724                      beq.s     $00FDBC76
[00fdbc52] 2e8d                      move.l    a5,(a7)
[00fdbc54] 486e fff2                 pea.l     -14(a6)
[00fdbc58] 486e fff6                 pea.l     -10(a6)
[00fdbc5c] 486b 32b6                 pea.l     12982(a3)
[00fdbc60] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdbc64] 3f2d 000c                 move.w    12(a5),-(a7)
[00fdbc68] 3f3c 0001                 move.w    #1,-(a7)
[00fdbc6c] 2f0c                      move.l    a4,-(a7)
[00fdbc6e] f5a4                      dc.w      $F5A4
[00fdbc70] defc 0016                 adda.w    #$0016,a7
[00fdbc74] 6004                      bra.s     $00FDBC7A
[00fdbc76] 2e8c                      move.l    a4,(a7)
[00fdbc78] f5a8                      dc.w      $F5A8
[00fdbc7a] 5247                      addq.w    #1,d7
[00fdbc7c] be7c 0004                 cmp.w     #$0004,d7
[00fdbc80] 6d00 ff5e                 blt       $00FDBBE0
[00fdbc84] f618                      dc.w      $F618
[00fdbc86] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif
