#if 0
[00fd59a0] 4e56 fff6                 link      a6,#$FFF6
[00fd59a4] 48e7 030c                 movem.l   d6-d7/a4-a5,-(a7)
[00fd59a8] 2879 0000 a788            movea.l   _thedesk,a4
[00fd59ae] 3eb9 0000 6d90            move.w    gl_height,(a7)
[00fd59b4] 3f39 0000 7008            move.w    gl_width,-(a7)
[00fd59ba] 42a7                      clr.l     -(a7)
[00fd59bc] 3f3c 0001                 move.w    #1,-(a7)
[00fd59c0] f388                      dc.w      $F388
[00fd59c2] 508f                      addq.l    #8,a7
[00fd59c4] 3ebc 0004                 move.w    #$0004,(a7) ; Getrez
[00fd59c8] f0ec                      dc.w      $F0EC ; trp14
[00fd59ca] 3d40 fff8                 move.w    d0,-8(a6)
[00fd59ce] 0c6e 0002 fff8            cmpi.w    #$0002,-8(a6)
[00fd59d4] 6708                      beq.s     $00FD59DE
[00fd59d6] 0c6e 0004 fff8            cmpi.w    #$0004,-8(a6)
[00fd59dc] 6608                      bne.s     $00FD59E6
[00fd59de] 203c 0000 1143            move.l    #$00001143,d0
[00fd59e4] 6006                      bra.s     $00FD59EC
[00fd59e6] 203c 0000 1173            move.l    #$00001173,d0
[00fd59ec] 2940 5eac                 move.l    d0,24236(a4)
[00fd59f0] 4240                      clr.w     d0
[00fd59f2] 3d40 fffc                 move.w    d0,-4(a6)
[00fd59f6] 3d40 fffe                 move.w    d0,-2(a6)
[00fd59fa] 2a6c 5a4a                 movea.l   23114(a4),a5
[00fd59fe] 6000 0122                 bra       $00FD5B22
[00fd5a02] 082d 0002 0005            btst      #2,5(a5)
[00fd5a08] 6700 0116                 beq       $00FD5B20
[00fd5a0c] 2f2c 35fc                 move.l    13820(a4),-(a7)
[00fd5a10] 2f2d 0018                 move.l    24(a5),-(a7)
[00fd5a14] 3f3c 0001                 move.w    #1,-(a7)
[00fd5a18] f38c                      dc.w      $F38C
[00fd5a1a] defc 000a                 adda.w    #$000A,a7
[00fd5a1e] 3e00                      move.w    d0,d7
[00fd5a20] 4a47                      tst.w     d7
[00fd5a22] 6700 0104                 beq       $00FD5B28
[00fd5a26] 0c6d 0002 0006            cmpi.w    #$0002,6(a5)
[00fd5a2c] 661a                      bne.s     $00FD5A48
[00fd5a2e] 303c 8000                 move.w    #$8000,d0
[00fd5a32] 322d 0016                 move.w    22(a5),d1
[00fd5a36] d27c ffbf                 add.w     #$FFBF,d1
[00fd5a3a] e268                      lsr.w     d1,d0
[00fd5a3c] 3d40 fffa                 move.w    d0,-6(a6)
[00fd5a40] 302e fffa                 move.w    -6(a6),d0
[00fd5a44] 816e fffe                 or.w      d0,-2(a6)
[00fd5a48] 3b47 0008                 move.w    d7,8(a5)
[00fd5a4c] 204c                      movea.l   a4,a0
[00fd5a4e] 3207                      move.w    d7,d1
[00fd5a50] c3fc 0018                 muls.w    #$0018,d1
[00fd5a54] d1c1                      adda.l    d1,a0
[00fd5a56] 4268 5e92                 clr.w     24210(a0)
[00fd5a5a] 204c                      movea.l   a4,a0
[00fd5a5c] 3207                      move.w    d7,d1
[00fd5a5e] c3fc 0018                 muls.w    #$0018,d1
[00fd5a62] d1c1                      adda.l    d1,a0
[00fd5a64] 4268 5e90                 clr.w     24208(a0)
[00fd5a68] 204c                      movea.l   a4,a0
[00fd5a6a] 3207                      move.w    d7,d1
[00fd5a6c] c3fc 0018                 muls.w    #$0018,d1
[00fd5a70] d1c1                      adda.l    d1,a0
[00fd5a72] 317c 001f 5e8e            move.w    #$001F,24206(a0)
[00fd5a78] 204c                      movea.l   a4,a0
[00fd5a7a] 3247                      movea.w   d7,a1
[00fd5a7c] d3c9                      adda.l    a1,a1
[00fd5a7e] d1c9                      adda.l    a1,a0
[00fd5a80] 316d 0012 25d6            move.w    18(a5),9686(a0)
[00fd5a86] 200c                      move.l    a4,d0
[00fd5a88] 3207                      move.w    d7,d1
[00fd5a8a] c3fc 0022                 muls.w    #$0022,d1
[00fd5a8e] d081                      add.l     d1,d0
[00fd5a90] d0bc 0000 034e            add.l     #$0000034E,d0
[00fd5a96] 224c                      movea.l   a4,a1
[00fd5a98] 3407                      move.w    d7,d2
[00fd5a9a] c5fc 0018                 muls.w    #$0018,d2
[00fd5a9e] d3c2                      adda.l    d2,a1
[00fd5aa0] 2340 5e94                 move.l    d0,24212(a1)
[00fd5aa4] 200c                      move.l    a4,d0
[00fd5aa6] 3207                      move.w    d7,d1
[00fd5aa8] c3fc 0022                 muls.w    #$0022,d1
[00fd5aac] d081                      add.l     d1,d0
[00fd5aae] 2e80                      move.l    d0,(a7)
[00fd5ab0] 0697 0000 034e            addi.l    #$0000034E,(a7)
[00fd5ab6] 200c                      move.l    a4,d0
[00fd5ab8] 322d 0012                 move.w    18(a5),d1
[00fd5abc] c3fc 0022                 muls.w    #$0022,d1
[00fd5ac0] d081                      add.l     d1,d0
[00fd5ac2] 2f00                      move.l    d0,-(a7)
[00fd5ac4] 0697 0000 5b1a            addi.l    #$00005B1A,(a7)
[00fd5aca] 3f3c 0022                 move.w    #$0022,-(a7)
[00fd5ace] f390                      dc.w      $F390 ; movs
[00fd5ad0] 5c8f                      addq.l    #6,a7
[00fd5ad2] 302c 35fc                 move.w    13820(a4),d0
[00fd5ad6] 224c                      movea.l   a4,a1
[00fd5ad8] 3407                      move.w    d7,d2
[00fd5ada] c5fc 0022                 muls.w    #$0022,d2
[00fd5ade] d3c2                      adda.l    d2,a1
[00fd5ae0] 3229 0364                 move.w    868(a1),d1
[00fd5ae4] 9041                      sub.w     d1,d0
[00fd5ae6] 48c0                      ext.l     d0
[00fd5ae8] 81fc 0002                 divs.w    #$0002,d0
[00fd5aec] 224c                      movea.l   a4,a1
[00fd5aee] 3407                      move.w    d7,d2
[00fd5af0] c5fc 0022                 muls.w    #$0022,d2
[00fd5af4] d3c2                      adda.l    d2,a1
[00fd5af6] 3340 0360                 move.w    d0,864(a1)
[00fd5afa] 204c                      movea.l   a4,a0
[00fd5afc] 3207                      move.w    d7,d1
[00fd5afe] c3fc 0022                 muls.w    #$0022,d1
[00fd5b02] d1c1                      adda.l    d1,a0
[00fd5b04] 216d 000a 0356            move.l    10(a5),854(a0)
[00fd5b0a] 302d 0016                 move.w    22(a5),d0
[00fd5b0e] c07c 00ff                 and.w     #$00FF,d0
[00fd5b12] 224c                      movea.l   a4,a1
[00fd5b14] 3407                      move.w    d7,d2
[00fd5b16] c5fc 0022                 muls.w    #$0022,d2
[00fd5b1a] d3c2                      adda.l    d2,a1
[00fd5b1c] 8169 035a                 or.w      d0,858(a1)
[00fd5b20] 2a55                      movea.l   (a5),a5
[00fd5b22] 200d                      move.l    a5,d0
[00fd5b24] 6600 fedc                 bne       $00FD5A02
[00fd5b28] 3eae fffc                 move.w    -4(a6),(a7)
[00fd5b2c] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd5b30] f394                      dc.w      $F394 ; ap_bvset
[00fd5b32] 548f                      addq.l    #2,a7
[00fd5b34] fc21                      dc.w      $FC21 ; movem.l (a7)+,d7/a4-a5
#endif

	xdef xfd5b36
xfd5b36: ds.b 0
#if 0
[00fd5b36] 4e56 0000                 link      a6,#0
[00fd5b3a] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fd5b3e] 2a6e 000e                 movea.l   14(a6),a5
[00fd5b42] 264d                      movea.l   a5,a3
[00fd5b44] 200b                      move.l    a3,d0
[00fd5b46] 6714                      beq.s     $00FD5B5C
[00fd5b48] 4a1b                      tst.b     (a3)+
[00fd5b4a] 66fc                      bne.s     $00FD5B48
[00fd5b4c] 6002                      bra.s     $00FD5B50
[00fd5b4e] 538b                      subq.l    #1,a3
[00fd5b50] b7cd                      cmpa.l    a5,a3
[00fd5b52] 6506                      bcs.s     $00FD5B5A
[00fd5b54] 0c13 005c                 cmpi.b    #$5C,(a3)
[00fd5b58] 66f4                      bne.s     $00FD5B4E
[00fd5b5a] 528b                      addq.l    #1,a3
[00fd5b5c] 2079 0000 a788            movea.l   _thedesk,a0
[00fd5b62] 2868 5a4a                 movea.l   23114(a0),a4
[00fd5b66] 6000 008c                 bra       $00FD5BF4
[00fd5b6a] 4a6e 0008                 tst.w     8(a6)
[00fd5b6e] 6714                      beq.s     $00FD5B84
[00fd5b70] 302c 0008                 move.w    8(a4),d0
[00fd5b74] b06e 000c                 cmp.w     12(a6),d0
[00fd5b78] 6606                      bne.s     $00FD5B80
[00fd5b7a] 200c                      move.l    a4,d0
[00fd5b7c] 6000 007e                 bra.w     $00FD5BFC
[00fd5b80] 6000 0070                 bra.w     $00FD5BF2
[00fd5b84] 302c 0006                 move.w    6(a4),d0
[00fd5b88] b06e 000a                 cmp.w     10(a6),d0
[00fd5b8c] 6664                      bne.s     $00FD5BF2
[00fd5b8e] 082c 0002 0005            btst      #2,5(a4)
[00fd5b94] 665c                      bne.s     $00FD5BF2
[00fd5b96] 2e8b                      move.l    a3,(a7)
[00fd5b98] 2f2c 000e                 move.l    14(a4),-(a7)
[00fd5b9c] f398                      dc.w      $F398 ; wildcmp
[00fd5b9e] 588f                      addq.l    #4,a7
[00fd5ba0] 4a40                      tst.w     d0
[00fd5ba2] 670a                      beq.s     $00FD5BAE
[00fd5ba4] 206e 0012                 movea.l   18(a6),a0
[00fd5ba8] 4250                      clr.w     (a0)
[00fd5baa] 200c                      move.l    a4,d0
[00fd5bac] 604e                      bra.s     $00FD5BFC
[00fd5bae] 206c 000a                 movea.l   10(a4),a0
[00fd5bb2] 0c10 002a                 cmpi.b    #$2A,(a0)
[00fd5bb6] 660e                      bne.s     $00FD5BC6
[00fd5bb8] 2e8b                      move.l    a3,(a7)
[00fd5bba] 2f2c 000a                 move.l    10(a4),-(a7)
[00fd5bbe] f398                      dc.w      $F398 ; wildcmp
[00fd5bc0] 588f                      addq.l    #4,a7
[00fd5bc2] 3e00                      move.w    d0,d7
[00fd5bc4] 601c                      bra.s     $00FD5BE2
[00fd5bc6] 2e8d                      move.l    a5,(a7)
[00fd5bc8] 2f2c 000a                 move.l    10(a4),-(a7)
[00fd5bcc] f39c                      dc.w      $F39C ; streq
[00fd5bce] 588f                      addq.l    #4,a7
[00fd5bd0] 3e00                      move.w    d0,d7
[00fd5bd2] 4a47                      tst.w     d7
[00fd5bd4] 660c                      bne.s     $00FD5BE2
[00fd5bd6] 2e8b                      move.l    a3,(a7)
[00fd5bd8] 2f2c 000a                 move.l    10(a4),-(a7)
[00fd5bdc] f39c                      dc.w      $F39C ; streq
[00fd5bde] 588f                      addq.l    #4,a7
[00fd5be0] 3e00                      move.w    d0,d7
[00fd5be2] 4a47                      tst.w     d7
[00fd5be4] 670c                      beq.s     $00FD5BF2
[00fd5be6] 206e 0012                 movea.l   18(a6),a0
[00fd5bea] 30bc 0001                 move.w    #1,(a0)
[00fd5bee] 200c                      move.l    a4,d0
[00fd5bf0] 600a                      bra.s     $00FD5BFC
[00fd5bf2] 2854                      movea.l   (a4),a4
[00fd5bf4] 200c                      move.l    a4,d0
[00fd5bf6] 6600 ff72                 bne       $00FD5B6A
[00fd5bfa] 4280                      clr.l     d0
[00fd5bfc] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfd5bfe
xfd5bfe: ds.b 0
#if 0
[00fd5bfe] 4e56 0000                 link      a6,#0
[00fd5c02] 48e7 1f00                 movem.l   d3-d7,-(a7)
[00fd5c06] 3e2e 000c                 move.w    12(a6),d7
[00fd5c0a] 3c2e 000e                 move.w    14(a6),d6
[00fd5c0e] 3a2e 0010                 move.w    16(a6),d5
[00fd5c12] 3e85                      move.w    d5,(a7)
[00fd5c14] 3f06                      move.w    d6,-(a7)
[00fd5c16] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd5c1a] 3f07                      move.w    d7,-(a7)
[00fd5c1c] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd5c20] f2b4                      dc.w      $F2B4 ; objc_find
[00fd5c22] defc 000a                 adda.w    #$000A,a7
[00fd5c26] 3800                      move.w    d0,d4
[00fd5c28] b847                      cmp.w     d7,d4
[00fd5c2a] 6720                      beq.s     $00FD5C4C
[00fd5c2c] b87c ffff                 cmp.w     #$FFFF,d4
[00fd5c30] 671a                      beq.s     $00FD5C4C
[00fd5c32] 2ebc 0001 0001            move.l    #$00010001,(a7)
[00fd5c38] 3f05                      move.w    d5,-(a7)
[00fd5c3a] 3f06                      move.w    d6,-(a7)
[00fd5c3c] 3f04                      move.w    d4,-(a7)
[00fd5c3e] 3f07                      move.w    d7,-(a7)
[00fd5c40] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd5c44] f2b8                      dc.w      $F2B8
[00fd5c46] defc 000c                 adda.w    #$000C,a7
[00fd5c4a] 3800                      move.w    d0,d4
[00fd5c4c] 3004                      move.w    d4,d0
[00fd5c4e] f03d                      dc.w      $F03D ; movem.l (a7)+,d4-d7
#endif

	xdef xfd5c50
xfd5c50: ds.b 0
#if 0
[00fd5c50] 4e56 fffc                 link      a6,#$FFFC
[00fd5c54] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd5c58] 2679 0000 a788            movea.l   _thedesk,a3
[00fd5c5e] 2a6e 0008                 movea.l   8(a6),a5
[00fd5c62] 4247                      clr.w     d7
[00fd5c64] 204d                      movea.l   a5,a0
[00fd5c66] 322e 000c                 move.w    12(a6),d1
[00fd5c6a] c3fc 0018                 muls.w    #$0018,d1
[00fd5c6e] d1c1                      adda.l    d1,a0
[00fd5c70] 3c28 0002                 move.w    2(a0),d6
[00fd5c74] 6000 00fc                 bra       $00FD5D72
[00fd5c78] 204d                      movea.l   a5,a0
[00fd5c7a] 3206                      move.w    d6,d1
[00fd5c7c] c3fc 0018                 muls.w    #$0018,d1
[00fd5c80] d1c1                      adda.l    d1,a0
[00fd5c82] 0828 0000 000b            btst      #0,11(a0)
[00fd5c88] 6700 00dc                 beq       $00FD5D66
[00fd5c8c] 204d                      movea.l   a5,a0
[00fd5c8e] 3206                      move.w    d6,d1
[00fd5c90] c3fc 0018                 muls.w    #$0018,d1
[00fd5c94] d1c1                      adda.l    d1,a0
[00fd5c96] 3d68 0010 fffe            move.w    16(a0),-2(a6)
[00fd5c9c] 204d                      movea.l   a5,a0
[00fd5c9e] 3206                      move.w    d6,d1
[00fd5ca0] c3fc 0018                 muls.w    #$0018,d1
[00fd5ca4] d1c1                      adda.l    d1,a0
[00fd5ca6] 3d68 0012 fffc            move.w    18(a0),-4(a6)
[00fd5cac] 200d                      move.l    a5,d0
[00fd5cae] 3206                      move.w    d6,d1
[00fd5cb0] c3fc 0018                 muls.w    #$0018,d1
[00fd5cb4] d081                      add.l     d1,d0
[00fd5cb6] 2e80                      move.l    d0,(a7)
[00fd5cb8] 0697 0000 0012            addi.l    #$00000012,(a7)
[00fd5cbe] 200d                      move.l    a5,d0
[00fd5cc0] 3206                      move.w    d6,d1
[00fd5cc2] c3fc 0018                 muls.w    #$0018,d1
[00fd5cc6] d081                      add.l     d1,d0
[00fd5cc8] 2f00                      move.l    d0,-(a7)
[00fd5cca] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fd5cd0] 206e 0012                 movea.l   18(a6),a0
[00fd5cd4] 3247                      movea.w   d7,a1
[00fd5cd6] d2c9                      adda.w    a1,a1
[00fd5cd8] 5249                      addq.w    #1,a1
[00fd5cda] d3c9                      adda.l    a1,a1
[00fd5cdc] 3f30 9800                 move.w    0(a0,a1.l),-(a7)
[00fd5ce0] 302e 0010                 move.w    16(a6),d0
[00fd5ce4] d157                      add.w     d0,(a7)
[00fd5ce6] 206e 0012                 movea.l   18(a6),a0
[00fd5cea] 3247                      movea.w   d7,a1
[00fd5cec] d2c9                      adda.w    a1,a1
[00fd5cee] d2c9                      adda.w    a1,a1
[00fd5cf0] 3f30 9000                 move.w    0(a0,a1.w),-(a7)
[00fd5cf4] 302e 000e                 move.w    14(a6),d0
[00fd5cf8] d157                      add.w     d0,(a7)
[00fd5cfa] f2bc                      dc.w      $F2BC ; app_mtoi
[00fd5cfc] 508f                      addq.l    #8,a7
[00fd5cfe] 286b 5a4a                 movea.l   23114(a3),a4
[00fd5d02] 6028                      bra.s     $00FD5D2C
[00fd5d04] bc6c 0008                 cmp.w     8(a4),d6
[00fd5d08] 6620                      bne.s     $00FD5D2A
[00fd5d0a] 204d                      movea.l   a5,a0
[00fd5d0c] 3206                      move.w    d6,d1
[00fd5d0e] c3fc 0018                 muls.w    #$0018,d1
[00fd5d12] d1c1                      adda.l    d1,a0
[00fd5d14] 3968 0010 0018            move.w    16(a0),24(a4)
[00fd5d1a] 204d                      movea.l   a5,a0
[00fd5d1c] 3206                      move.w    d6,d1
[00fd5d1e] c3fc 0018                 muls.w    #$0018,d1
[00fd5d22] d1c1                      adda.l    d1,a0
[00fd5d24] 3968 0012 001a            move.w    18(a0),26(a4)
[00fd5d2a] 2854                      movea.l   (a4),a4
[00fd5d2c] 200c                      move.l    a4,d0
[00fd5d2e] 66d4                      bne.s     $00FD5D04
[00fd5d30] 2f2b 35fc                 move.l    13820(a3),-(a7)
[00fd5d34] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fd5d38] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd5d3c] 4267                      clr.w     -(a7)
[00fd5d3e] f2c0                      dc.w      $F2C0
[00fd5d40] defc 000a                 adda.w    #$000A,a7
[00fd5d44] 2f2b 35fc                 move.l    13820(a3),-(a7)
[00fd5d48] 3006                      move.w    d6,d0
[00fd5d4a] c1fc 0018                 muls.w    #$0018,d0
[00fd5d4e] 3f35 0812                 move.w    18(a5,d0.l),-(a7)
[00fd5d52] 3006                      move.w    d6,d0
[00fd5d54] c1fc 0018                 muls.w    #$0018,d0
[00fd5d58] 3f35 0810                 move.w    16(a5,d0.l),-(a7)
[00fd5d5c] 4267                      clr.w     -(a7)
[00fd5d5e] f2c0                      dc.w      $F2C0
[00fd5d60] defc 000a                 adda.w    #$000A,a7
[00fd5d64] 5247                      addq.w    #1,d7
[00fd5d66] 204d                      movea.l   a5,a0
[00fd5d68] 3206                      move.w    d6,d1
[00fd5d6a] c3fc 0018                 muls.w    #$0018,d1
[00fd5d6e] d1c1                      adda.l    d1,a0
[00fd5d70] 3c10                      move.w    (a0),d6
[00fd5d72] bc6e 000c                 cmp.w     12(a6),d6
[00fd5d76] 6e00 ff00                 bgt       $00FD5C78
[00fd5d7a] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfd5d7c
xfd5d7c: ds.b 0
#if 0
[00fd5d7c] 4e56 fffe                 link      a6,#$FFFE
[00fd5d80] 48e7 3f0c                 movem.l   d2-d7/a4-a5,-(a7)
[00fd5d84] 2a6e 000a                 movea.l   10(a6),a5
[00fd5d88] 286e 000e                 movea.l   14(a6),a4
[00fd5d8c] 3a3c 2710                 move.w    #$2710,d5
[00fd5d90] 3c05                      move.w    d5,d6
[00fd5d92] 4244                      clr.w     d4
[00fd5d94] 4243                      clr.w     d3
[00fd5d96] 4247                      clr.w     d7
[00fd5d98] 6000 007c                 bra.w     $00FD5E16
[00fd5d9c] 3007                      move.w    d7,d0
[00fd5d9e] e340                      asl.w     #1,d0
[00fd5da0] 3d40 fffe                 move.w    d0,-2(a6)
[00fd5da4] 204d                      movea.l   a5,a0
[00fd5da6] 326e fffe                 movea.w   -2(a6),a1
[00fd5daa] d3c9                      adda.l    a1,a1
[00fd5dac] d1c9                      adda.l    a1,a0
[00fd5dae] bc50                      cmp.w     (a0),d6
[00fd5db0] 6f0c                      ble.s     $00FD5DBE
[00fd5db2] 204d                      movea.l   a5,a0
[00fd5db4] 326e fffe                 movea.w   -2(a6),a1
[00fd5db8] d3c9                      adda.l    a1,a1
[00fd5dba] d1c9                      adda.l    a1,a0
[00fd5dbc] 3c10                      move.w    (a0),d6
[00fd5dbe] 204d                      movea.l   a5,a0
[00fd5dc0] 326e fffe                 movea.w   -2(a6),a1
[00fd5dc4] 5249                      addq.w    #1,a1
[00fd5dc6] d3c9                      adda.l    a1,a1
[00fd5dc8] d1c9                      adda.l    a1,a0
[00fd5dca] ba50                      cmp.w     (a0),d5
[00fd5dcc] 6f0e                      ble.s     $00FD5DDC
[00fd5dce] 204d                      movea.l   a5,a0
[00fd5dd0] 326e fffe                 movea.w   -2(a6),a1
[00fd5dd4] 5249                      addq.w    #1,a1
[00fd5dd6] d3c9                      adda.l    a1,a1
[00fd5dd8] d1c9                      adda.l    a1,a0
[00fd5dda] 3a10                      move.w    (a0),d5
[00fd5ddc] 204d                      movea.l   a5,a0
[00fd5dde] 326e fffe                 movea.w   -2(a6),a1
[00fd5de2] d3c9                      adda.l    a1,a1
[00fd5de4] d1c9                      adda.l    a1,a0
[00fd5de6] b850                      cmp.w     (a0),d4
[00fd5de8] 6c0c                      bge.s     $00FD5DF6
[00fd5dea] 204d                      movea.l   a5,a0
[00fd5dec] 326e fffe                 movea.w   -2(a6),a1
[00fd5df0] d3c9                      adda.l    a1,a1
[00fd5df2] d1c9                      adda.l    a1,a0
[00fd5df4] 3810                      move.w    (a0),d4
[00fd5df6] 204d                      movea.l   a5,a0
[00fd5df8] 326e fffe                 movea.w   -2(a6),a1
[00fd5dfc] 5249                      addq.w    #1,a1
[00fd5dfe] d3c9                      adda.l    a1,a1
[00fd5e00] d1c9                      adda.l    a1,a0
[00fd5e02] b650                      cmp.w     (a0),d3
[00fd5e04] 6c0e                      bge.s     $00FD5E14
[00fd5e06] 204d                      movea.l   a5,a0
[00fd5e08] 326e fffe                 movea.w   -2(a6),a1
[00fd5e0c] 5249                      addq.w    #1,a1
[00fd5e0e] d3c9                      adda.l    a1,a1
[00fd5e10] d1c9                      adda.l    a1,a0
[00fd5e12] 3610                      move.w    (a0),d3
[00fd5e14] 5247                      addq.w    #1,d7
[00fd5e16] be6e 0008                 cmp.w     8(a6),d7
[00fd5e1a] 6d80                      blt.s     $00FD5D9C
[00fd5e1c] 3e83                      move.w    d3,(a7)
[00fd5e1e] 3005                      move.w    d5,d0
[00fd5e20] 9157                      sub.w     d0,(a7)
[00fd5e22] 5257                      addq.w    #1,(a7)
[00fd5e24] 3f04                      move.w    d4,-(a7)
[00fd5e26] 3006                      move.w    d6,d0
[00fd5e28] 9157                      sub.w     d0,(a7)
[00fd5e2a] 5257                      addq.w    #1,(a7)
[00fd5e2c] 3f05                      move.w    d5,-(a7)
[00fd5e2e] 3f06                      move.w    d6,-(a7)
[00fd5e30] 2f0c                      move.l    a4,-(a7)
[00fd5e32] f298                      dc.w      $F298 ; r_set
[00fd5e34] defc 000a                 adda.w    #$000A,a7
[00fd5e38] fc3f                      dc.w      $FC3F ; movem.l (a7)+,d3-d7/a4-a5
#endif

	xdef xfd5e3a
xfd5e3a: ds.b 0
#if 0
[00fd5e3a] 4e56 0000                 link      a6,#0
[00fd5e3e] 48e7 0f0c                 movem.l   d4-d7/a4-a5,-(a7)
[00fd5e42] 2a6e 000e                 movea.l   14(a6),a5
[00fd5e46] 3e2e 0012                 move.w    18(a6),d7
[00fd5e4a] 286e 0014                 movea.l   20(a6),a4
[00fd5e4e] 4297                      clr.l     (a7)
[00fd5e50] 3f3c 0100                 move.w    #$0100,-(a7)
[00fd5e54] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fd5e56] 548f                      addq.l    #2,a7
[00fd5e58] 4246                      clr.w     d6
[00fd5e5a] 602e                      bra.s     $00FD5E8A
[00fd5e5c] 3a06                      move.w    d6,d5
[00fd5e5e] e345                      asl.w     #1,d5
[00fd5e60] 2e8d                      move.l    a5,(a7)
[00fd5e62] 3f2e 000c                 move.w    12(a6),-(a7)
[00fd5e66] 3045                      movea.w   d5,a0
[00fd5e68] 5248                      addq.w    #1,a0
[00fd5e6a] d1c8                      adda.l    a0,a0
[00fd5e6c] 3f34 8800                 move.w    0(a4,a0.l),-(a7)
[00fd5e70] 302e 000a                 move.w    10(a6),d0
[00fd5e74] d157                      add.w     d0,(a7)
[00fd5e76] 3045                      movea.w   d5,a0
[00fd5e78] d1c8                      adda.l    a0,a0
[00fd5e7a] 3f34 8800                 move.w    0(a4,a0.l),-(a7)
[00fd5e7e] 302e 0008                 move.w    8(a6),d0
[00fd5e82] d157                      add.w     d0,(a7)
[00fd5e84] f2c8                      dc.w      $F2C8 ; gsx_pline
[00fd5e86] 5c8f                      addq.l    #6,a7
[00fd5e88] 5246                      addq.w    #1,d6
[00fd5e8a] bc47                      cmp.w     d7,d6
[00fd5e8c] 6dce                      blt.s     $00FD5E5C
[00fd5e8e] 4297                      clr.l     (a7)
[00fd5e90] 3f3c 0101                 move.w    #$0101,-(a7)
[00fd5e94] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fd5e96] 548f                      addq.l    #2,a7
[00fd5e98] fc39                      dc.w      $FC39 ; movem.l (a7)+,d5-d7/a4-a5
#endif

	xdef xfd5e9a
xfd5e9a: ds.b 0
#if 0
[00fd5e9a] 4e56 fff0                 link      a6,#$FFF0
[00fd5e9e] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd5ea2] 2a6e 0008                 movea.l   8(a6),a5
[00fd5ea6] 286e 0012                 movea.l   18(a6),a4
[00fd5eaa] 266e 0018                 movea.l   24(a6),a3
[00fd5eae] 2e8b                      move.l    a3,(a7)
[00fd5eb0] 3f2e 0016                 move.w    22(a6),-(a7)
[00fd5eb4] 2f0c                      move.l    a4,-(a7)
[00fd5eb6] 3f2e 0010                 move.w    16(a6),-(a7)
[00fd5eba] 2f15                      move.l    (a5),-(a7)
[00fd5ebc] f2cc                      dc.w      $F2CC
[00fd5ebe] defc 000c                 adda.w    #$000C,a7
[00fd5ec2] 486e fff2                 pea.l     -14(a6)
[00fd5ec6] 486e fff4                 pea.l     -12(a6)
[00fd5eca] 486e fffc                 pea.l     -4(a6)
[00fd5ece] 486e fffa                 pea.l     -6(a6)
[00fd5ed2] 486e fff8                 pea.l     -8(a6)
[00fd5ed6] 486e fff6                 pea.l     -10(a6)
[00fd5eda] 42a7                      clr.l     -(a7)
[00fd5edc] 42a7                      clr.l     -(a7)
[00fd5ede] 42a7                      clr.l     -(a7)
[00fd5ee0] 42a7                      clr.l     -(a7)
[00fd5ee2] 4267                      clr.w     -(a7)
[00fd5ee4] 2f3c 0002 0002            move.l    #$00020002,-(a7)
[00fd5eea] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd5eee] 3f3c 0001                 move.w    #1,-(a7)
[00fd5ef2] 2f3c 0001 0000            move.l    #$00010000,-(a7)
[00fd5ef8] 2f3c 0006 0001            move.l    #$00060001,-(a7)
[00fd5efe] f2d0                      dc.w      $F2D0 ; evnt_multi
[00fd5f00] defc 003c                 adda.w    #$003C,a7
[00fd5f04] 3d40 fff0                 move.w    d0,-16(a6)
[00fd5f08] 082e 0001 fff1            btst      #1,-15(a6)
[00fd5f0e] 6704                      beq.s     $00FD5F14
[00fd5f10] 4240                      clr.w     d0
[00fd5f12] 6002                      bra.s     $00FD5F16
[00fd5f14] 7001                      moveq.l   #1,d0
[00fd5f16] 3d40 fffe                 move.w    d0,-2(a6)
[00fd5f1a] 2e8b                      move.l    a3,(a7)
[00fd5f1c] 3f2e 0016                 move.w    22(a6),-(a7)
[00fd5f20] 2f0c                      move.l    a4,-(a7)
[00fd5f22] 3f2e 0010                 move.w    16(a6),-(a7)
[00fd5f26] 2f15                      move.l    (a5),-(a7)
[00fd5f28] f2cc                      dc.w      $F2CC
[00fd5f2a] defc 000c                 adda.w    #$000C,a7
[00fd5f2e] 302e fffe                 move.w    -2(a6),d0
[00fd5f32] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfd5f34
xfd5f34: ds.b 0
#if 0
[00fd5f34] 4e56 ffc4                 link      a6,#$FFC4
[00fd5f38] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd5f3c] 3e2e 0010                 move.w    16(a6),d7
[00fd5f40] 3c2e 0016                 move.w    22(a6),d6
[00fd5f44] 2a6e 0024                 movea.l   36(a6),a5
[00fd5f48] 286e 0028                 movea.l   40(a6),a4
[00fd5f4c] 486e ffc4                 pea.l     -60(a6)
[00fd5f50] 2f2e 0012                 move.l    18(a6),-(a7)
[00fd5f54] 3f07                      move.w    d7,-(a7)
[00fd5f56] f2d4                      dc.w      $F2D4
[00fd5f58] defc 000a                 adda.w    #$000A,a7
[00fd5f5c] 486e ffcc                 pea.l     -52(a6)
[00fd5f60] 2f2e 0018                 move.l    24(a6),-(a7)
[00fd5f64] 3f06                      move.w    d6,-(a7)
[00fd5f66] f2d4                      dc.w      $F2D4
[00fd5f68] defc 000a                 adda.w    #$000A,a7
[00fd5f6c] 302e ffc8                 move.w    -56(a6),d0
[00fd5f70] d16e ffd0                 add.w     d0,-48(a6)
[00fd5f74] 302e ffca                 move.w    -54(a6),d0
[00fd5f78] d16e ffd2                 add.w     d0,-46(a6)
[00fd5f7c] 426e ffee                 clr.w     -18(a6)
[00fd5f80] 6030                      bra.s     $00FD5FB2
[00fd5f82] 302e ffee                 move.w    -18(a6),d0
[00fd5f86] e340                      asl.w     #1,d0
[00fd5f88] 3d40 ffec                 move.w    d0,-20(a6)
[00fd5f8c] 302e ffcc                 move.w    -52(a6),d0
[00fd5f90] 326e ffec                 movea.w   -20(a6),a1
[00fd5f94] d3c9                      adda.l    a1,a1
[00fd5f96] d3ee 0018                 adda.l    24(a6),a1
[00fd5f9a] 9151                      sub.w     d0,(a1)
[00fd5f9c] 302e ffce                 move.w    -50(a6),d0
[00fd5fa0] 326e ffec                 movea.w   -20(a6),a1
[00fd5fa4] 5249                      addq.w    #1,a1
[00fd5fa6] d3c9                      adda.l    a1,a1
[00fd5fa8] d3ee 0018                 adda.l    24(a6),a1
[00fd5fac] 9151                      sub.w     d0,(a1)
[00fd5fae] 526e ffee                 addq.w    #1,-18(a6)
[00fd5fb2] bc6e ffee                 cmp.w     -18(a6),d6
[00fd5fb6] 6eca                      bgt.s     $00FD5F82
[00fd5fb8] 302e 0008                 move.w    8(a6),d0
[00fd5fbc] 906e ffcc                 sub.w     -52(a6),d0
[00fd5fc0] 3d40 ffe2                 move.w    d0,-30(a6)
[00fd5fc4] 302e 000a                 move.w    10(a6),d0
[00fd5fc8] 906e ffce                 sub.w     -50(a6),d0
[00fd5fcc] 3d40 ffe0                 move.w    d0,-32(a6)
[00fd5fd0] 426e ffea                 clr.w     -22(a6)
[00fd5fd4] 42ae fff8                 clr.l     -8(a6)
[00fd5fd8] 426e ffe8                 clr.w     -24(a6)
[00fd5fdc] 426e ffe6                 clr.w     -26(a6)
[00fd5fe0] 2ebc 0000 702c            move.l    #$0000702C,(a7)
[00fd5fe6] f0c0                      dc.w      $F0C0 ; gsx_sclip
[00fd5fe8] 3ebc 0001                 move.w    #1,(a7)
[00fd5fec] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd5ff0] 4267                      clr.w     -(a7)
[00fd5ff2] f2d8                      dc.w      $F2D8
[00fd5ff4] 588f                      addq.l    #4,a7
[00fd5ff6] 486e ffda                 pea.l     -38(a6)
[00fd5ffa] 486e ffdc                 pea.l     -36(a6)
[00fd5ffe] 486e 000a                 pea.l     10(a6)
[00fd6002] 486e 0008                 pea.l     8(a6)
[00fd6006] f2dc                      dc.w      $F2DC ; graf_mkstate
[00fd6008] defc 0010                 adda.w    #$0010,a7
[00fd600c] 302e 0008                 move.w    8(a6),d0
[00fd6010] 906e ffe2                 sub.w     -30(a6),d0
[00fd6014] 3d40 ffcc                 move.w    d0,-52(a6)
[00fd6018] 302e 000a                 move.w    10(a6),d0
[00fd601c] 906e ffe0                 sub.w     -32(a6),d0
[00fd6020] 3d40 ffce                 move.w    d0,-50(a6)
[00fd6024] 486e ffcc                 pea.l     -52(a6)
[00fd6028] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd602c] f2e0                      dc.w      $F2E0 ; rc_constrain
[00fd602e] 508f                      addq.l    #8,a7
[00fd6030] 2eae 0018                 move.l    24(a6),(a7)
[00fd6034] 3f06                      move.w    d6,-(a7)
[00fd6036] 2f2e 0012                 move.l    18(a6),-(a7)
[00fd603a] 3f07                      move.w    d7,-(a7)
[00fd603c] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6040] 486e ffcc                 pea.l     -52(a6)
[00fd6044] f2e4                      dc.w      $F2E4
[00fd6046] defc 0010                 adda.w    #$0010,a7
[00fd604a] 3d40 ffde                 move.w    d0,-34(a6)
[00fd604e] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6052] f2e8                      dc.w      $F2E8 ; wind_find
[00fd6054] 588f                      addq.l    #4,a7
[00fd6056] 3d40 ffe4                 move.w    d0,-28(a6)
[00fd605a] 2079 0000 a788            movea.l   _thedesk,a0
[00fd6060] 2d68 5e2c fffc            move.l    24108(a0),-4(a6)
[00fd6066] 3d7c 0001 fff2            move.w    #1,-14(a6)
[00fd606c] 4a6e ffe4                 tst.w     -28(a6)
[00fd6070] 672c                      beq.s     $00FD609E
[00fd6072] 3eae ffe4                 move.w    -28(a6),(a7)
[00fd6076] f2ec                      dc.w      $F2EC
[00fd6078] 2d40 fff4                 move.l    d0,-12(a6)
[00fd607c] 4aae fff4                 tst.l     -12(a6)
[00fd6080] 6718                      beq.s     $00FD609A
[00fd6082] 2079 0000 a788            movea.l   _thedesk,a0
[00fd6088] 2d68 5e2c fffc            move.l    24108(a0),-4(a6)
[00fd608e] 206e fff4                 movea.l   -12(a6),a0
[00fd6092] 3d68 000a fff2            move.w    10(a0),-14(a6)
[00fd6098] 6004                      bra.s     $00FD609E
[00fd609a] 426e ffe4                 clr.w     -28(a6)
[00fd609e] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd60a2] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fd60a6] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd60aa] f2f0                      dc.w      $F2F0
[00fd60ac] defc 000a                 adda.w    #$000A,a7
[00fd60b0] 3880                      move.w    d0,(a4)
[00fd60b2] 3014                      move.w    (a4),d0
[00fd60b4] b06e fff2                 cmp.w     -14(a6),d0
[00fd60b8] 6706                      beq.s     $00FD60C0
[00fd60ba] 0c54 ffff                 cmpi.w    #$FFFF,(a4)
[00fd60be] 6642                      bne.s     $00FD6102
[00fd60c0] 4a6e ffe6                 tst.w     -26(a6)
[00fd60c4] 6738                      beq.s     $00FD60FE
[00fd60c6] 3ebc 0001                 move.w    #1,(a7)
[00fd60ca] 3f3c 0001                 move.w    #1,-(a7)
[00fd60ce] 4267                      clr.w     -(a7)
[00fd60d0] 3f3c 0001                 move.w    #1,-(a7)
[00fd60d4] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd60d8] 3f2e ffe6                 move.w    -26(a6),-(a7)
[00fd60dc] 3f2e ffe8                 move.w    -24(a6),-(a7)
[00fd60e0] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd60e4] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fd60e8] f2f4                      dc.w      $F2F4
[00fd60ea] defc 0014                 adda.w    #$0014,a7
[00fd60ee] 426e ffea                 clr.w     -22(a6)
[00fd60f2] 42ae fff8                 clr.l     -8(a6)
[00fd60f6] 426e ffe8                 clr.w     -24(a6)
[00fd60fa] 426e ffe6                 clr.w     -26(a6)
[00fd60fe] 6000 00dc                 bra       $00FD61DC
[00fd6102] 3014                      move.w    (a4),d0
[00fd6104] b06e ffe6                 cmp.w     -26(a6),d0
[00fd6108] 6700 00d2                 beq       $00FD61DC
[00fd610c] 4a6e ffe6                 tst.w     -26(a6)
[00fd6110] 6738                      beq.s     $00FD614A
[00fd6112] 3ebc 0001                 move.w    #1,(a7)
[00fd6116] 3f3c 0001                 move.w    #1,-(a7)
[00fd611a] 4267                      clr.w     -(a7)
[00fd611c] 3f3c 0001                 move.w    #1,-(a7)
[00fd6120] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd6124] 3f2e ffe6                 move.w    -26(a6),-(a7)
[00fd6128] 3f2e ffe8                 move.w    -24(a6),-(a7)
[00fd612c] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd6130] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fd6134] f2f4                      dc.w      $F2F4
[00fd6136] defc 0014                 adda.w    #$0014,a7
[00fd613a] 426e ffea                 clr.w     -22(a6)
[00fd613e] 42ae fff8                 clr.l     -8(a6)
[00fd6142] 426e ffe8                 clr.w     -24(a6)
[00fd6146] 426e ffe6                 clr.w     -26(a6)
[00fd614a] 3014                      move.w    (a4),d0
[00fd614c] c1fc 0018                 muls.w    #$0018,d0
[00fd6150] d0ae fffc                 add.l     -4(a6),d0
[00fd6154] d0bc 0000 000a            add.l     #$0000000A,d0
[00fd615a] 2040                      movea.l   d0,a0
[00fd615c] 3d50 fff0                 move.w    (a0),-16(a6)
[00fd6160] 082e 0000 fff1            btst      #0,-15(a6)
[00fd6166] 6674                      bne.s     $00FD61DC
[00fd6168] 486e ffd8                 pea.l     -40(a6)
[00fd616c] 486e ffd4                 pea.l     -44(a6)
[00fd6170] 3f14                      move.w    (a4),-(a7)
[00fd6172] 3f2e ffe4                 move.w    -28(a6),-(a7)
[00fd6176] f2f8                      dc.w      $F2F8
[00fd6178] defc 000c                 adda.w    #$000C,a7
[00fd617c] 2640                      movea.l   d0,a3
[00fd617e] 0c6b 0001 0006            cmpi.w    #1,6(a3)
[00fd6184] 6718                      beq.s     $00FD619E
[00fd6186] 0c6b 0002 0006            cmpi.w    #$0002,6(a3)
[00fd618c] 6710                      beq.s     $00FD619E
[00fd618e] 0c6b 0004 0006            cmpi.w    #$0004,6(a3)
[00fd6194] 6708                      beq.s     $00FD619E
[00fd6196] 0c6b 0003 0006            cmpi.w    #$0003,6(a3)
[00fd619c] 663e                      bne.s     $00FD61DC
[00fd619e] 3d6e ffe4 ffea            move.w    -28(a6),-22(a6)
[00fd61a4] 2d6e fffc fff8            move.l    -4(a6),-8(a6)
[00fd61aa] 3d6e fff2 ffe8            move.w    -14(a6),-24(a6)
[00fd61b0] 3d54 ffe6                 move.w    (a4),-26(a6)
[00fd61b4] 3ebc 0001                 move.w    #1,(a7)
[00fd61b8] 2f3c 0001 0001            move.l    #$00010001,-(a7)
[00fd61be] 3f3c 0001                 move.w    #1,-(a7)
[00fd61c2] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd61c6] 3f2e ffe6                 move.w    -26(a6),-(a7)
[00fd61ca] 3f2e ffe8                 move.w    -24(a6),-(a7)
[00fd61ce] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd61d2] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fd61d6] f2f4                      dc.w      $F2F4
[00fd61d8] defc 0014                 adda.w    #$0014,a7
[00fd61dc] 4a6e ffde                 tst.w     -34(a6)
[00fd61e0] 6600 fdfe                 bne       $00FD5FE0
[00fd61e4] 4a6e ffe6                 tst.w     -26(a6)
[00fd61e8] 6728                      beq.s     $00FD6212
[00fd61ea] 3ebc 0001                 move.w    #1,(a7)
[00fd61ee] 3f3c 0001                 move.w    #1,-(a7)
[00fd61f2] 4267                      clr.w     -(a7)
[00fd61f4] 3f3c 0001                 move.w    #1,-(a7)
[00fd61f8] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd61fc] 3f2e ffe6                 move.w    -26(a6),-(a7)
[00fd6200] 3f2e ffe8                 move.w    -24(a6),-(a7)
[00fd6204] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd6208] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fd620c] f2f4                      dc.w      $F2F4
[00fd620e] defc 0014                 adda.w    #$0014,a7
[00fd6212] 206e 001c                 movea.l   28(a6),a0
[00fd6216] 30ae ffcc                 move.w    -52(a6),(a0)
[00fd621a] 206e 0020                 movea.l   32(a6),a0
[00fd621e] 30ae ffce                 move.w    -50(a6),(a0)
[00fd6222] 3aae ffe4                 move.w    -28(a6),(a5)
[00fd6226] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfd6228
xfd6228: ds.b 0
#if 0
[00fd6228] 4e56 ffee                 link      a6,#$FFEE
[00fd622c] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd6230] 47ee ffee                 lea.l     -18(a6),a3
[00fd6234] 2a6e 0008                 movea.l   8(a6),a5
[00fd6238] 204d                      movea.l   a5,a0
[00fd623a] 322e 000c                 move.w    12(a6),d1
[00fd623e] c3fc 0018                 muls.w    #$0018,d1
[00fd6242] d1c1                      adda.l    d1,a0
[00fd6244] 3e28 0010                 move.w    16(a0),d7
[00fd6248] 204d                      movea.l   a5,a0
[00fd624a] 322e 000e                 move.w    14(a6),d1
[00fd624e] c3fc 0018                 muls.w    #$0018,d1
[00fd6252] d1c1                      adda.l    d1,a0
[00fd6254] 3028 0010                 move.w    16(a0),d0
[00fd6258] de40                      add.w     d0,d7
[00fd625a] 204d                      movea.l   a5,a0
[00fd625c] 322e 000c                 move.w    12(a6),d1
[00fd6260] c3fc 0018                 muls.w    #$0018,d1
[00fd6264] d1c1                      adda.l    d1,a0
[00fd6266] 3c28 0012                 move.w    18(a0),d6
[00fd626a] 204d                      movea.l   a5,a0
[00fd626c] 322e 000e                 move.w    14(a6),d1
[00fd6270] c3fc 0018                 muls.w    #$0018,d1
[00fd6274] d1c1                      adda.l    d1,a0
[00fd6276] 3028 0012                 move.w    18(a0),d0
[00fd627a] dc40                      add.w     d0,d6
[00fd627c] 0c6e 0001 000c            cmpi.w    #1,12(a6)
[00fd6282] 6604                      bne.s     $00FD6288
[00fd6284] 4240                      clr.w     d0
[00fd6286] 600a                      bra.s     $00FD6292
[00fd6288] 2079 0000 a788            movea.l   _thedesk,a0
[00fd628e] 3028 3004                 move.w    12292(a0),d0
[00fd6292] 3d40 fffe                 move.w    d0,-2(a6)
[00fd6296] 302e fffe                 move.w    -2(a6),d0
[00fd629a] 6000 00ce                 bra       $00FD636A
[00fd629e] 3eb9 0000 6ce2            move.w    $00006CE2,(a7)
[00fd62a4] 3039 0000 6dce            move.w    $00006DCE,d0
[00fd62aa] c1fc 002d                 muls.w    #$002D,d0
[00fd62ae] 3f00                      move.w    d0,-(a7)
[00fd62b0] 3f06                      move.w    d6,-(a7)
[00fd62b2] 3f07                      move.w    d7,-(a7)
[00fd62b4] 486e fff6                 pea.l     -10(a6)
[00fd62b8] f298                      dc.w      $F298 ; r_set
[00fd62ba] defc 000a                 adda.w    #$000A,a7
[00fd62be] 2f2e 0014                 move.l    20(a6),-(a7)
[00fd62c2] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd62c6] 2f0b                      move.l    a3,-(a7)
[00fd62c8] f298                      dc.w      $F298 ; r_set
[00fd62ca] defc 000c                 adda.w    #$000C,a7
[00fd62ce] 2e8b                      move.l    a3,(a7)
[00fd62d0] 486e fff6                 pea.l     -10(a6)
[00fd62d4] f2fc                      dc.w      $F2FC ; rc_intersect
[00fd62d6] 588f                      addq.l    #4,a7
[00fd62d8] 4a40                      tst.w     d0
[00fd62da] 6608                      bne.s     $00FD62E4
[00fd62dc] 302e 000c                 move.w    12(a6),d0
[00fd62e0] 6000 009a                 bra       $00FD637C
[00fd62e4] 6000 0092                 bra       $00FD6378
[00fd62e8] 2f2e 0014                 move.l    20(a6),-(a7)
[00fd62ec] 3f2e 0012                 move.w    18(a6),-(a7)
[00fd62f0] 3006                      move.w    d6,d0
[00fd62f2] 9157                      sub.w     d0,(a7)
[00fd62f4] 3f2e 0010                 move.w    16(a6),-(a7)
[00fd62f8] 3007                      move.w    d7,d0
[00fd62fa] 9157                      sub.w     d0,(a7)
[00fd62fc] 486e fff6                 pea.l     -10(a6)
[00fd6300] f298                      dc.w      $F298 ; r_set
[00fd6302] defc 000c                 adda.w    #$000C,a7
[00fd6306] 2f2e 0014                 move.l    20(a6),-(a7)
[00fd630a] 3f2e 0012                 move.w    18(a6),-(a7)
[00fd630e] 3006                      move.w    d6,d0
[00fd6310] 9157                      sub.w     d0,(a7)
[00fd6312] 3f2e 0010                 move.w    16(a6),-(a7)
[00fd6316] 3007                      move.w    d7,d0
[00fd6318] 9157                      sub.w     d0,(a7)
[00fd631a] 2f0b                      move.l    a3,-(a7)
[00fd631c] f298                      dc.w      $F298 ; r_set
[00fd631e] defc 000c                 adda.w    #$000C,a7
[00fd6322] 306e 000e                 movea.w   14(a6),a0
[00fd6326] d1c8                      adda.l    a0,a0
[00fd6328] d1f9 0000 a788            adda.l    _thedesk,a0
[00fd632e] 3028 25d6                 move.w    9686(a0),d0
[00fd6332] c1fc 0022                 muls.w    #$0022,d0
[00fd6336] 2840                      movea.l   d0,a4
[00fd6338] d9f9 0000 a788            adda.l    _thedesk,a4
[00fd633e] d9fc 0000 5a4e            adda.l    #$00005A4E,a4
[00fd6344] 486e fff6                 pea.l     -10(a6)
[00fd6348] 486c 001a                 pea.l     26(a4)
[00fd634c] f2fc                      dc.w      $F2FC ; rc_intersect
[00fd634e] 508f                      addq.l    #8,a7
[00fd6350] 4a40                      tst.w     d0
[00fd6352] 6614                      bne.s     $00FD6368
[00fd6354] 2e8b                      move.l    a3,(a7)
[00fd6356] 486c 0012                 pea.l     18(a4)
[00fd635a] f2fc                      dc.w      $F2FC ; rc_intersect
[00fd635c] 588f                      addq.l    #4,a7
[00fd635e] 4a40                      tst.w     d0
[00fd6360] 6606                      bne.s     $00FD6368
[00fd6362] 302e 000c                 move.w    12(a6),d0
[00fd6366] 6014                      bra.s     $00FD637C
[00fd6368] 600e                      bra.s     $00FD6378
[00fd636a] 4a40                      tst.w     d0
[00fd636c] 6700 ff7a                 beq       $00FD62E8
[00fd6370] b07c 0001                 cmp.w     #1,d0
[00fd6374] 6700 ff28                 beq       $00FD629E
[00fd6378] 302e 000e                 move.w    14(a6),d0
[00fd637c] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfd637e
xfd637e: ds.b 0
#if 0
[00fd637e] 4e56 fff6                 link      a6,#$FFF6
[00fd6382] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd6386] 2a6e 0012                 movea.l   18(a6),a5
[00fd638a] 3e2e 0016                 move.w    22(a6),d7
[00fd638e] 47ee fff6                 lea.l     -10(a6),a3
[00fd6392] 286e 000a                 movea.l   10(a6),a4
[00fd6396] 204c                      movea.l   a4,a0
[00fd6398] 322e 0010                 move.w    16(a6),d1
[00fd639c] c3fc 0018                 muls.w    #$0018,d1
[00fd63a0] d1c1                      adda.l    d1,a0
[00fd63a2] 3c28 000a                 move.w    10(a0),d6
[00fd63a6] 3d46 fffe                 move.w    d6,-2(a6)
[00fd63aa] 4a6e 001c                 tst.w     28(a6)
[00fd63ae] 670c                      beq.s     $00FD63BC
[00fd63b0] 0806 0003                 btst      #3,d6
[00fd63b4] 6706                      beq.s     $00FD63BC
[00fd63b6] 4240                      clr.w     d0
[00fd63b8] 6000 0096                 bra       $00FD6450
[00fd63bc] 2e8b                      move.l    a3,(a7)
[00fd63be] 200c                      move.l    a4,d0
[00fd63c0] 322e 0010                 move.w    16(a6),d1
[00fd63c4] c3fc 0018                 muls.w    #$0018,d1
[00fd63c8] d081                      add.l     d1,d0
[00fd63ca] 2f00                      move.l    d0,-(a7)
[00fd63cc] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fd63d2] f250                      dc.w      $F250 ; rc_copy
[00fd63d4] 588f                      addq.l    #4,a7
[00fd63d6] 204c                      movea.l   a4,a0
[00fd63d8] 322e 000e                 move.w    14(a6),d1
[00fd63dc] c3fc 0018                 muls.w    #$0018,d1
[00fd63e0] d1c1                      adda.l    d1,a0
[00fd63e2] 3028 0010                 move.w    16(a0),d0
[00fd63e6] d153                      add.w     d0,(a3)
[00fd63e8] 204c                      movea.l   a4,a0
[00fd63ea] 322e 000e                 move.w    14(a6),d1
[00fd63ee] c3fc 0018                 muls.w    #$0018,d1
[00fd63f2] d1c1                      adda.l    d1,a0
[00fd63f4] 3028 0012                 move.w    18(a0),d0
[00fd63f8] d16b 0002                 add.w     d0,2(a3)
[00fd63fc] 4a6e 0018                 tst.w     24(a6)
[00fd6400] 6704                      beq.s     $00FD6406
[00fd6402] 8c47                      or.w      d7,d6
[00fd6404] 6006                      bra.s     $00FD640C
[00fd6406] 3007                      move.w    d7,d0
[00fd6408] 4640                      not.w     d0
[00fd640a] cc40                      and.w     d0,d6
[00fd640c] bc6e fffe                 cmp.w     -2(a6),d6
[00fd6410] 673c                      beq.s     $00FD644E
[00fd6412] 4257                      clr.w     (a7)
[00fd6414] 3f06                      move.w    d6,-(a7)
[00fd6416] 2f2d 0004                 move.l    4(a5),-(a7)
[00fd641a] 2f15                      move.l    (a5),-(a7)
[00fd641c] 4267                      clr.w     -(a7)
[00fd641e] 3f2e 0010                 move.w    16(a6),-(a7)
[00fd6422] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd6426] f300                      dc.w      $F300 ; objc_change
[00fd6428] defc 0012                 adda.w    #$0012,a7
[00fd642c] 4a6e 001a                 tst.w     26(a6)
[00fd6430] 671c                      beq.s     $00FD644E
[00fd6432] 2e8b                      move.l    a3,(a7)
[00fd6434] 2f0d                      move.l    a5,-(a7)
[00fd6436] f2fc                      dc.w      $F2FC ; rc_intersect
[00fd6438] 588f                      addq.l    #4,a7
[00fd643a] 4a40                      tst.w     d0
[00fd643c] 6710                      beq.s     $00FD644E
[00fd643e] 2f2b 0004                 move.l    4(a3),-(a7)
[00fd6442] 2f13                      move.l    (a3),-(a7)
[00fd6444] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd6448] f2c0                      dc.w      $F2C0
[00fd644a] defc 000a                 adda.w    #$000A,a7
[00fd644e] 7001                      moveq.l   #1,d0
[00fd6450] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfd6452
xfd6452: ds.b 0
#if 0
[00fd6452] 4e56 ffec                 link      a6,#$FFEC
[00fd6456] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd645a] 49ee fff4                 lea.l     -12(a6),a4
[00fd645e] 47ee ffec                 lea.l     -20(a6),a3
[00fd6462] 2a6e 000a                 movea.l   10(a6),a5
[00fd6466] 204d                      movea.l   a5,a0
[00fd6468] 322e 000e                 move.w    14(a6),d1
[00fd646c] c3fc 0018                 muls.w    #$0018,d1
[00fd6470] d1c1                      adda.l    d1,a0
[00fd6472] 3d68 0010 fffe            move.w    16(a0),-2(a6)
[00fd6478] 204d                      movea.l   a5,a0
[00fd647a] 322e 000e                 move.w    14(a6),d1
[00fd647e] c3fc 0018                 muls.w    #$0018,d1
[00fd6482] d1c1                      adda.l    d1,a0
[00fd6484] 3d68 0012 fffc            move.w    18(a0),-4(a6)
[00fd648a] 426b 0004                 clr.w     4(a3)
[00fd648e] 426b 0006                 clr.w     6(a3)
[00fd6492] 204d                      movea.l   a5,a0
[00fd6494] 322e 000e                 move.w    14(a6),d1
[00fd6498] c3fc 0018                 muls.w    #$0018,d1
[00fd649c] d1c1                      adda.l    d1,a0
[00fd649e] 3e28 0002                 move.w    2(a0),d7
[00fd64a2] 6000 00e8                 bra       $00FD658C
[00fd64a6] be6e 0010                 cmp.w     16(a6),d7
[00fd64aa] 6700 00d4                 beq       $00FD6580
[00fd64ae] 2e8c                      move.l    a4,(a7)
[00fd64b0] 200d                      move.l    a5,d0
[00fd64b2] 3207                      move.w    d7,d1
[00fd64b4] c3fc 0018                 muls.w    #$0018,d1
[00fd64b8] d081                      add.l     d1,d0
[00fd64ba] 2f00                      move.l    d0,-(a7)
[00fd64bc] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fd64c2] f250                      dc.w      $F250 ; rc_copy
[00fd64c4] 588f                      addq.l    #4,a7
[00fd64c6] 302e fffe                 move.w    -2(a6),d0
[00fd64ca] d154                      add.w     d0,(a4)
[00fd64cc] 302e fffc                 move.w    -4(a6),d0
[00fd64d0] d16c 0002                 add.w     d0,2(a4)
[00fd64d4] 2e8c                      move.l    a4,(a7)
[00fd64d6] 2f2e 0012                 move.l    18(a6),-(a7)
[00fd64da] f2fc                      dc.w      $F2FC ; rc_intersect
[00fd64dc] 588f                      addq.l    #4,a7
[00fd64de] 4a40                      tst.w     d0
[00fd64e0] 6700 009e                 beq       $00FD6580
[00fd64e4] 2f2c 0004                 move.l    4(a4),-(a7)
[00fd64e8] 2f14                      move.l    (a4),-(a7)
[00fd64ea] 3f07                      move.w    d7,-(a7)
[00fd64ec] 3f2e 000e                 move.w    14(a6),-(a7)
[00fd64f0] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd64f4] f2b8                      dc.w      $F2B8
[00fd64f6] defc 0010                 adda.w    #$0010,a7
[00fd64fa] b06e 000e                 cmp.w     14(a6),d0
[00fd64fe] 6700 0080                 beq       $00FD6580
[00fd6502] 204d                      movea.l   a5,a0
[00fd6504] 3207                      move.w    d7,d1
[00fd6506] c3fc 0018                 muls.w    #$0018,d1
[00fd650a] d1c1                      adda.l    d1,a0
[00fd650c] 3c28 000a                 move.w    10(a0),d6
[00fd6510] 4a6e 001c                 tst.w     28(a6)
[00fd6514] 6706                      beq.s     $00FD651C
[00fd6516] 8c6e 001a                 or.w      26(a6),d6
[00fd651a] 6008                      bra.s     $00FD6524
[00fd651c] 302e 001a                 move.w    26(a6),d0
[00fd6520] 4640                      not.w     d0
[00fd6522] cc40                      and.w     d0,d6
[00fd6524] 204d                      movea.l   a5,a0
[00fd6526] 3207                      move.w    d7,d1
[00fd6528] c3fc 0018                 muls.w    #$0018,d1
[00fd652c] d1c1                      adda.l    d1,a0
[00fd652e] bc68 000a                 cmp.w     10(a0),d6
[00fd6532] 674c                      beq.s     $00FD6580
[00fd6534] 204d                      movea.l   a5,a0
[00fd6536] 3207                      move.w    d7,d1
[00fd6538] c3fc 0018                 muls.w    #$0018,d1
[00fd653c] d1c1                      adda.l    d1,a0
[00fd653e] 3146 000a                 move.w    d6,10(a0)
[00fd6542] 2e8c                      move.l    a4,(a7)
[00fd6544] 200d                      move.l    a5,d0
[00fd6546] 3207                      move.w    d7,d1
[00fd6548] c3fc 0018                 muls.w    #$0018,d1
[00fd654c] d081                      add.l     d1,d0
[00fd654e] 2f00                      move.l    d0,-(a7)
[00fd6550] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fd6556] f250                      dc.w      $F250 ; rc_copy
[00fd6558] 588f                      addq.l    #4,a7
[00fd655a] 302e fffe                 move.w    -2(a6),d0
[00fd655e] d154                      add.w     d0,(a4)
[00fd6560] 302e fffc                 move.w    -4(a6),d0
[00fd6564] d16c 0002                 add.w     d0,2(a4)
[00fd6568] 4a6b 0004                 tst.w     4(a3)
[00fd656c] 670a                      beq.s     $00FD6578
[00fd656e] 2e8b                      move.l    a3,(a7)
[00fd6570] 2f0c                      move.l    a4,-(a7)
[00fd6572] f304                      dc.w      $F304 ; rc_union
[00fd6574] 588f                      addq.l    #4,a7
[00fd6576] 6008                      bra.s     $00FD6580
[00fd6578] 2e8b                      move.l    a3,(a7)
[00fd657a] 2f0c                      move.l    a4,-(a7)
[00fd657c] f250                      dc.w      $F250 ; rc_copy
[00fd657e] 588f                      addq.l    #4,a7
[00fd6580] 204d                      movea.l   a5,a0
[00fd6582] 3207                      move.w    d7,d1
[00fd6584] c3fc 0018                 muls.w    #$0018,d1
[00fd6588] d1c1                      adda.l    d1,a0
[00fd658a] 3e10                      move.w    (a0),d7
[00fd658c] be6e 000e                 cmp.w     14(a6),d7
[00fd6590] 6e00 ff14                 bgt       $00FD64A6
[00fd6594] 4a6e 001e                 tst.w     30(a6)
[00fd6598] 671e                      beq.s     $00FD65B8
[00fd659a] 2e8b                      move.l    a3,(a7)
[00fd659c] 2f2e 0016                 move.l    22(a6),-(a7)
[00fd65a0] f2fc                      dc.w      $F2FC ; rc_intersect
[00fd65a2] 588f                      addq.l    #4,a7
[00fd65a4] 4a40                      tst.w     d0
[00fd65a6] 6710                      beq.s     $00FD65B8
[00fd65a8] 2f2b 0004                 move.l    4(a3),-(a7)
[00fd65ac] 2f13                      move.l    (a3),-(a7)
[00fd65ae] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd65b2] f2c0                      dc.w      $F2C0
[00fd65b4] defc 000a                 adda.w    #$000A,a7
[00fd65b8] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfd65ba
xfd65ba: ds.b 0
#if 0
[00fd65ba] 4e56 fffc                 link      a6,#$FFFC
[00fd65be] 48e7 1f0c                 movem.l   d3-d7/a4-a5,-(a7)
[00fd65c2] 3e2e 0008                 move.w    8(a6),d7
[00fd65c6] 2c2e 000a                 move.l    10(a6),d6
[00fd65ca] 3a2e 000e                 move.w    14(a6),d5
[00fd65ce] 2a6e 0016                 movea.l   22(a6),a5
[00fd65d2] 302e 0014                 move.w    20(a6),d0
[00fd65d6] c07c 0003                 and.w     #$0003,d0
[00fd65da] 3d40 fffe                 move.w    d0,-2(a6)
[00fd65de] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd65e2] 3f05                      move.w    d5,-(a7)
[00fd65e4] 2f06                      move.l    d6,-(a7)
[00fd65e6] f2f0                      dc.w      $F2F0
[00fd65e8] defc 000a                 adda.w    #$000A,a7
[00fd65ec] 3800                      move.w    d0,d4
[00fd65ee] b845                      cmp.w     d5,d4
[00fd65f0] 6706                      beq.s     $00FD65F8
[00fd65f2] b87c ffff                 cmp.w     #$FFFF,d4
[00fd65f6] 6634                      bne.s     $00FD662C
[00fd65f8] 4a6e fffe                 tst.w     -2(a6)
[00fd65fc] 6706                      beq.s     $00FD6604
[00fd65fe] 4a6e 001a                 tst.w     26(a6)
[00fd6602] 6724                      beq.s     $00FD6628
[00fd6604] 3ebc 0001                 move.w    #1,(a7)
[00fd6608] 3f3c 0001                 move.w    #1,-(a7)
[00fd660c] 4267                      clr.w     -(a7)
[00fd660e] 3f3c 0001                 move.w    #1,-(a7)
[00fd6612] 2f0d                      move.l    a5,-(a7)
[00fd6614] 2f3c 0000 700e            move.l    #$0000700E,-(a7)
[00fd661a] 3f04                      move.w    d4,-(a7)
[00fd661c] 3f05                      move.w    d5,-(a7)
[00fd661e] 2f06                      move.l    d6,-(a7)
[00fd6620] 3f07                      move.w    d7,-(a7)
[00fd6622] f308                      dc.w      $F308
[00fd6624] defc 0018                 adda.w    #$0018,a7
[00fd6628] 6000 008e                 bra       $00FD66B8
[00fd662c] 2846                      movea.l   d6,a4
[00fd662e] 204c                      movea.l   a4,a0
[00fd6630] 3204                      move.w    d4,d1
[00fd6632] c3fc 0018                 muls.w    #$0018,d1
[00fd6636] d1c1                      adda.l    d1,a0
[00fd6638] 3d68 000a fffc            move.w    10(a0),-4(a6)
[00fd663e] 4a6e fffe                 tst.w     -2(a6)
[00fd6642] 663a                      bne.s     $00FD667E
[00fd6644] 4a6e 001a                 tst.w     26(a6)
[00fd6648] 6608                      bne.s     $00FD6652
[00fd664a] 082e 0000 fffd            btst      #0,-3(a6)
[00fd6650] 662a                      bne.s     $00FD667C
[00fd6652] 3ebc 0001                 move.w    #1,(a7)
[00fd6656] 3f3c 0001                 move.w    #1,-(a7)
[00fd665a] 4267                      clr.w     -(a7)
[00fd665c] 3f3c 0001                 move.w    #1,-(a7)
[00fd6660] 2f0d                      move.l    a5,-(a7)
[00fd6662] 2f3c 0000 700e            move.l    #$0000700E,-(a7)
[00fd6668] 3f04                      move.w    d4,-(a7)
[00fd666a] 3f05                      move.w    d5,-(a7)
[00fd666c] 2f06                      move.l    d6,-(a7)
[00fd666e] 3f07                      move.w    d7,-(a7)
[00fd6670] f308                      dc.w      $F308
[00fd6672] defc 0018                 adda.w    #$0018,a7
[00fd6676] 006e 0001 fffc            ori.w     #1,-4(a6)
[00fd667c] 6016                      bra.s     $00FD6694
[00fd667e] 082e 0000 fffd            btst      #0,-3(a6)
[00fd6684] 6708                      beq.s     $00FD668E
[00fd6686] 026e fffe fffc            andi.w    #$FFFE,-4(a6)
[00fd668c] 6006                      bra.s     $00FD6694
[00fd668e] 006e 0001 fffc            ori.w     #1,-4(a6)
[00fd6694] 3ebc 0001                 move.w    #1,(a7)
[00fd6698] 3f3c 0001                 move.w    #1,-(a7)
[00fd669c] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fd66a0] 0257 0001                 andi.w    #1,(a7)
[00fd66a4] 3f3c 0001                 move.w    #1,-(a7)
[00fd66a8] 2f0d                      move.l    a5,-(a7)
[00fd66aa] 3f04                      move.w    d4,-(a7)
[00fd66ac] 3f05                      move.w    d5,-(a7)
[00fd66ae] 2f06                      move.l    d6,-(a7)
[00fd66b0] 3f07                      move.w    d7,-(a7)
[00fd66b2] f2f4                      dc.w      $F2F4
[00fd66b4] defc 0014                 adda.w    #$0014,a7
[00fd66b8] fc3d                      dc.w      $FC3D ; movem.l (a7)+,d4-d7/a4-a5
#endif

	xdef xfd66ba
xfd66ba: ds.b 0
#if 0
[00fd66ba] 4e56 ffdc                 link      a6,#$FFDC
[00fd66be] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fd66c2] 3e2e 0008                 move.w    8(a6),d7
[00fd66c6] 2c2e 000a                 move.l    10(a6),d6
[00fd66ca] 3a2e 000e                 move.w    14(a6),d5
[00fd66ce] 49ee ffdc                 lea.l     -36(a6),a4
[00fd66d2] 2679 0000 a788            movea.l   _thedesk,a3
[00fd66d8] 3d7c ffff fff4            move.w    #$FFFF,-12(a6)
[00fd66de] 206e 0018                 movea.l   24(a6),a0
[00fd66e2] 3085                      move.w    d5,(a0)
[00fd66e4] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd66e8] 3f05                      move.w    d5,-(a7)
[00fd66ea] 2f06                      move.l    d6,-(a7)
[00fd66ec] f2f0                      dc.w      $F2F0
[00fd66ee] defc 000a                 adda.w    #$000A,a7
[00fd66f2] 3d40 fffe                 move.w    d0,-2(a6)
[00fd66f6] ba6e fffe                 cmp.w     -2(a6),d5
[00fd66fa] 6708                      beq.s     $00FD6704
[00fd66fc] 0c6e ffff fffe            cmpi.w    #$FFFF,-2(a6)
[00fd6702] 664e                      bne.s     $00FD6752
[00fd6704] 2ebc 0006 0006            move.l    #$00060006,(a7)
[00fd670a] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd670e] 2f0c                      move.l    a4,-(a7)
[00fd6710] f298                      dc.w      $F298 ; r_set
[00fd6712] 508f                      addq.l    #8,a7
[00fd6714] 486c 0006                 pea.l     6(a4)
[00fd6718] 486c 0004                 pea.l     4(a4)
[00fd671c] 2f3c 0006 0006            move.l    #$00060006,-(a7)
[00fd6722] 2f14                      move.l    (a4),-(a7)
[00fd6724] f30c                      dc.w      $F30C ; graf_rubbox
[00fd6726] defc 0010                 adda.w    #$0010,a7
[00fd672a] 3ebc 0001                 move.w    #1,(a7)
[00fd672e] 2f3c 0001 0001            move.l    #$00010001,-(a7)
[00fd6734] 3f3c 0001                 move.w    #1,-(a7)
[00fd6738] 2f2e 0014                 move.l    20(a6),-(a7)
[00fd673c] 2f0c                      move.l    a4,-(a7)
[00fd673e] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd6742] 3f05                      move.w    d5,-(a7)
[00fd6744] 2f06                      move.l    d6,-(a7)
[00fd6746] 3f07                      move.w    d7,-(a7)
[00fd6748] f308                      dc.w      $F308
[00fd674a] defc 0018                 adda.w    #$0018,a7
[00fd674e] 6000 0182                 bra       $00FD68D2
[00fd6752] 2a46                      movea.l   d6,a5
[00fd6754] 204d                      movea.l   a5,a0
[00fd6756] 322e fffe                 move.w    -2(a6),d1
[00fd675a] c3fc 0018                 muls.w    #$0018,d1
[00fd675e] d1c1                      adda.l    d1,a0
[00fd6760] 0828 0000 000b            btst      #0,11(a0)
[00fd6766] 6700 016a                 beq       $00FD68D2
[00fd676a] 41eb 3336                 lea.l     13110(a3),a0
[00fd676e] 2d48 ffe4                 move.l    a0,-28(a6)
[00fd6772] 2a46                      movea.l   d6,a5
[00fd6774] 204d                      movea.l   a5,a0
[00fd6776] 3205                      move.w    d5,d1
[00fd6778] c3fc 0018                 muls.w    #$0018,d1
[00fd677c] d1c1                      adda.l    d1,a0
[00fd677e] 3d68 0010 fffc            move.w    16(a0),-4(a6)
[00fd6784] 204d                      movea.l   a5,a0
[00fd6786] 3205                      move.w    d5,d1
[00fd6788] c3fc 0018                 muls.w    #$0018,d1
[00fd678c] d1c1                      adda.l    d1,a0
[00fd678e] 3d68 0012 fffa            move.w    18(a0),-6(a6)
[00fd6794] 426e ffee                 clr.w     -18(a6)
[00fd6798] 204d                      movea.l   a5,a0
[00fd679a] 3205                      move.w    d5,d1
[00fd679c] c3fc 0018                 muls.w    #$0018,d1
[00fd67a0] d1c1                      adda.l    d1,a0
[00fd67a2] 3828 0002                 move.w    2(a0),d4
[00fd67a6] 606a                      bra.s     $00FD6812
[00fd67a8] 204d                      movea.l   a5,a0
[00fd67aa] 3204                      move.w    d4,d1
[00fd67ac] c3fc 0018                 muls.w    #$0018,d1
[00fd67b0] d1c1                      adda.l    d1,a0
[00fd67b2] 0828 0000 000b            btst      #0,11(a0)
[00fd67b8] 6744                      beq.s     $00FD67FE
[00fd67ba] 302e ffee                 move.w    -18(a6),d0
[00fd67be] e340                      asl.w     #1,d0
[00fd67c0] 3d40 ffec                 move.w    d0,-20(a6)
[00fd67c4] 3004                      move.w    d4,d0
[00fd67c6] c1fc 0018                 muls.w    #$0018,d0
[00fd67ca] 3035 0810                 move.w    16(a5,d0.l),d0
[00fd67ce] d06e fffc                 add.w     -4(a6),d0
[00fd67d2] 326e ffec                 movea.w   -20(a6),a1
[00fd67d6] d3c9                      adda.l    a1,a1
[00fd67d8] d3ee ffe4                 adda.l    -28(a6),a1
[00fd67dc] 3280                      move.w    d0,(a1)
[00fd67de] 3004                      move.w    d4,d0
[00fd67e0] c1fc 0018                 muls.w    #$0018,d0
[00fd67e4] 3035 0812                 move.w    18(a5,d0.l),d0
[00fd67e8] d06e fffa                 add.w     -6(a6),d0
[00fd67ec] 326e ffec                 movea.w   -20(a6),a1
[00fd67f0] 5249                      addq.w    #1,a1
[00fd67f2] d3c9                      adda.l    a1,a1
[00fd67f4] d3ee ffe4                 adda.l    -28(a6),a1
[00fd67f8] 3280                      move.w    d0,(a1)
[00fd67fa] 526e ffee                 addq.w    #1,-18(a6)
[00fd67fe] 0c6e 003c ffee            cmpi.w    #$003C,-18(a6)
[00fd6804] 6c10                      bge.s     $00FD6816
[00fd6806] 204d                      movea.l   a5,a0
[00fd6808] 3204                      move.w    d4,d1
[00fd680a] c3fc 0018                 muls.w    #$0018,d1
[00fd680e] d1c1                      adda.l    d1,a0
[00fd6810] 3810                      move.w    (a0),d4
[00fd6812] b845                      cmp.w     d5,d4
[00fd6814] 6e92                      bgt.s     $00FD67A8
[00fd6816] 3d6e ffee fff8            move.w    -18(a6),-8(a6)
[00fd681c] 4a6e fff8                 tst.w     -8(a6)
[00fd6820] 6700 00b0                 beq       $00FD68D2
[00fd6824] ba7c 0001                 cmp.w     #1,d5
[00fd6828] 6604                      bne.s     $00FD682E
[00fd682a] 4240                      clr.w     d0
[00fd682c] 6004                      bra.s     $00FD6832
[00fd682e] 302b 3004                 move.w    12292(a3),d0
[00fd6832] 3d40 ffea                 move.w    d0,-22(a6)
[00fd6836] 4a6e ffea                 tst.w     -22(a6)
[00fd683a] 6610                      bne.s     $00FD684C
[00fd683c] 3d6b 35b0 ffe8            move.w    13744(a3),-24(a6)
[00fd6842] 41eb 35b4                 lea.l     13748(a3),a0
[00fd6846] 2d48 ffe4                 move.l    a0,-28(a6)
[00fd684a] 600e                      bra.s     $00FD685A
[00fd684c] 3d6b 35b2 ffe8            move.w    13746(a3),-24(a6)
[00fd6852] 41eb 35d8                 lea.l     13784(a3),a0
[00fd6856] 2d48 ffe4                 move.l    a0,-28(a6)
[00fd685a] 2eae 0018                 move.l    24(a6),(a7)
[00fd685e] 486e fff4                 pea.l     -12(a6)
[00fd6862] 486e fff0                 pea.l     -16(a6)
[00fd6866] 486e fff2                 pea.l     -14(a6)
[00fd686a] 486b 3336                 pea.l     13110(a3)
[00fd686e] 3f2e fff8                 move.w    -8(a6),-(a7)
[00fd6872] 2f2e ffe4                 move.l    -28(a6),-(a7)
[00fd6876] 3f2e ffe8                 move.w    -24(a6),-(a7)
[00fd687a] 2f3c 0000 700e            move.l    #$0000700E,-(a7)
[00fd6880] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd6884] f310                      dc.w      $F310
[00fd6886] defc 0020                 adda.w    #$0020,a7
[00fd688a] 4a6e fff4                 tst.w     -12(a6)
[00fd688e] 671a                      beq.s     $00FD68AA
[00fd6890] be6e fff4                 cmp.w     -12(a6),d7
[00fd6894] 6612                      bne.s     $00FD68A8
[00fd6896] 206e 0018                 movea.l   24(a6),a0
[00fd689a] 3010                      move.w    (a0),d0
[00fd689c] b06e fffe                 cmp.w     -2(a6),d0
[00fd68a0] 6606                      bne.s     $00FD68A8
[00fd68a2] 3d7c ffff fff4            move.w    #$FFFF,-12(a6)
[00fd68a8] 6028                      bra.s     $00FD68D2
[00fd68aa] 4a47                      tst.w     d7
[00fd68ac] 6624                      bne.s     $00FD68D2
[00fd68ae] 206e 0018                 movea.l   24(a6),a0
[00fd68b2] ba50                      cmp.w     (a0),d5
[00fd68b4] 661c                      bne.s     $00FD68D2
[00fd68b6] 486b 3336                 pea.l     13110(a3)
[00fd68ba] 3f2e fff0                 move.w    -16(a6),-(a7)
[00fd68be] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fd68c2] 3f05                      move.w    d5,-(a7)
[00fd68c4] 2f06                      move.l    d6,-(a7)
[00fd68c6] f314                      dc.w      $F314
[00fd68c8] defc 000e                 adda.w    #$000E,a7
[00fd68cc] 3d7c ffff fff4            move.w    #$FFFF,-12(a6)
[00fd68d2] 2ebc 0000 70c2            move.l    #$000070C2,(a7)
[00fd68d8] 486e fff6                 pea.l     -10(a6)
[00fd68dc] 486e 0012                 pea.l     18(a6)
[00fd68e0] 486e 0010                 pea.l     16(a6)
[00fd68e4] 2f3c 0001 0000            move.l    #$00010000,-(a7)
[00fd68ea] 3f3c 0001                 move.w    #1,-(a7)
[00fd68ee] f318                      dc.w      $F318 ; evnt_button
[00fd68f0] defc 0012                 adda.w    #$0012,a7
[00fd68f4] 302e fff4                 move.w    -12(a6),d0
[00fd68f8] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef _r_slash
_r_slash: ds.b 0
#if 0
[00fd68fa] 4e56 0000                 link      a6,#0
[00fd68fe] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd6902] 2a6e 0008                 movea.l   8(a6),a5
[00fd6906] 6002                      bra.s     $00FD690A
[00fd6908] 528d                      addq.l    #1,a5
[00fd690a] 4a15                      tst.b     (a5)
[00fd690c] 66fa                      bne.s     $00FD6908
[00fd690e] 6002                      bra.s     $00FD6912
[00fd6910] 538d                      subq.l    #1,a5
[00fd6912] 0c15 005c                 cmpi.b    #$5C,(a5)
[00fd6916] 66f8                      bne.s     $00FD6910
[00fd6918] 200d                      move.l    a5,d0
[00fd691a] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef _do_finish
_do_finish: ds.b 0
#if 0
[00fd691c] 4e56 fff4                 link      a6,#$FFF4
[00fd6920] 486e fff8                 pea.l     -8(a6)
[00fd6924] 486e fffa                 pea.l     -6(a6)
[00fd6928] 486e fffc                 pea.l     -4(a6)
[00fd692c] 486e fffe                 pea.l     -2(a6)
[00fd6930] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6934] f3a0                      dc.w      $F3A0 ; form_center
[00fd6936] defc 0014                 adda.w    #$0014,a7
[00fd693a] 3eae fff8                 move.w    -8(a6),(a7)
[00fd693e] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fd6942] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fd6946] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd694a] 42a7                      clr.l     -(a7)
[00fd694c] 42a7                      clr.l     -(a7)
[00fd694e] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd6952] f3a4                      dc.w      $F3A4 ; form_dial
[00fd6954] defc 0010                 adda.w    #$0010,a7
[00fd6958] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd695a
xfd695a: ds.b 0
#if 0
[00fd695a] 4e56 fff4                 link      a6,#$FFF4
[00fd695e] 486e fff8                 pea.l     -8(a6)
[00fd6962] 486e fffa                 pea.l     -6(a6)
[00fd6966] 486e fffc                 pea.l     -4(a6)
[00fd696a] 486e fffe                 pea.l     -2(a6)
[00fd696e] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6972] f3a0                      dc.w      $F3A0 ; form_center
[00fd6974] defc 0014                 adda.w    #$0014,a7
[00fd6978] 3eae fff8                 move.w    -8(a6),(a7)
[00fd697c] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fd6980] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fd6984] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd6988] 42a7                      clr.l     -(a7)
[00fd698a] 42a7                      clr.l     -(a7)
[00fd698c] 4267                      clr.w     -(a7)
[00fd698e] f3a4                      dc.w      $F3A4 ; form_dial
[00fd6990] defc 0010                 adda.w    #$0010,a7
[00fd6994] 3eae fff8                 move.w    -8(a6),(a7)
[00fd6998] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fd699c] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fd69a0] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd69a4] 3f3c 0008                 move.w    #$0008,-(a7)
[00fd69a8] 4267                      clr.w     -(a7)
[00fd69aa] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd69ae] f3a8                      dc.w      $F3A8 ; objc_draw
[00fd69b0] defc 000e                 adda.w    #$000E,a7
[00fd69b4] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd69b6
xfd69b6: ds.b 0
#if 0
[00fd69b6] 4e56 fff4                 link      a6,#$FFF4
[00fd69ba] 3ebc 0004                 move.w    #$0004,(a7)
[00fd69be] 302e 000c                 move.w    12(a6),d0
[00fd69c2] c1fc 0018                 muls.w    #$0018,d0
[00fd69c6] d0ae 0008                 add.l     8(a6),d0
[00fd69ca] 2f00                      move.l    d0,-(a7)
[00fd69cc] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fd69d2] 486e fff8                 pea.l     -8(a6)
[00fd69d6] f1ac                      dc.w      $F1AC ; LWCOPY
[00fd69d8] 508f                      addq.l    #8,a7
[00fd69da] 486e fffa                 pea.l     -6(a6)
[00fd69de] 486e fff8                 pea.l     -8(a6)
[00fd69e2] 3f2e 000c                 move.w    12(a6),-(a7)
[00fd69e6] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd69ea] f3ac                      dc.w      $F3AC ; objc_offset
[00fd69ec] defc 000e                 adda.w    #$000E,a7
[00fd69f0] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd69f4] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd69f8] 4267                      clr.w     -(a7)
[00fd69fa] 3f2e 000c                 move.w    12(a6),-(a7)
[00fd69fe] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6a02] f3a8                      dc.w      $F3A8 ; objc_draw
[00fd6a04] defc 0010                 adda.w    #$0010,a7
[00fd6a08] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd6a0a
xfd6a0a: ds.b 0
#if 0
[00fd6a0a] 4e56 fff4                 link      a6,#$FFF4
[00fd6a0e] 3ebc 0004                 move.w    #$0004,(a7)
[00fd6a12] 302e 000c                 move.w    12(a6),d0
[00fd6a16] c1fc 0018                 muls.w    #$0018,d0
[00fd6a1a] d0ae 0008                 add.l     8(a6),d0
[00fd6a1e] 2f00                      move.l    d0,-(a7)
[00fd6a20] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fd6a26] 486e fff8                 pea.l     -8(a6)
[00fd6a2a] f1ac                      dc.w      $F1AC ; LWCOPY
[00fd6a2c] 508f                      addq.l    #8,a7
[00fd6a2e] 486e fffa                 pea.l     -6(a6)
[00fd6a32] 486e fff8                 pea.l     -8(a6)
[00fd6a36] 3f2e 000c                 move.w    12(a6),-(a7)
[00fd6a3a] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6a3e] f130                      dc.w      $F130 ; ob_offset
[00fd6a40] defc 000e                 adda.w    #$000E,a7
[00fd6a44] 2e8e                      move.l    a6,(a7)
[00fd6a46] 5197                      subq.l    #8,(a7)
[00fd6a48] f0c0                      dc.w      $F0C0 ; gsx_sclip
[00fd6a4a] 4257                      clr.w     (a7)
[00fd6a4c] 3f2e 000c                 move.w    12(a6),-(a7)
[00fd6a50] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd6a54] f128                      dc.w      $F128 ; ob_draw
[00fd6a56] 5c8f                      addq.l    #6,a7
[00fd6a58] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd6a5a
xfd6a5a: ds.b 0
#if 0
[00fd6a5a] 4e56 0000                 link      a6,#0
[00fd6a5e] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd6a62] 2a6e 0008                 movea.l   8(a6),a5
[00fd6a66] 6002                      bra.s     $00FD6A6A
[00fd6a68] 528d                      addq.l    #1,a5
[00fd6a6a] 0c15 002a                 cmpi.b    #$2A,(a5)
[00fd6a6e] 66f8                      bne.s     $00FD6A68
[00fd6a70] 2e8d                      move.l    a5,(a7)
[00fd6a72] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd6a76] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6a78] 588f                      addq.l    #4,a7
[00fd6a7a] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef _rep_all
_rep_all: ds.b 0
#if 0
[00fd6a7c] 4e56 0000                 link      a6,#0
[00fd6a80] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd6a84] 2a6e 0008                 movea.l   8(a6),a5
[00fd6a88] 2e8d                      move.l    a5,(a7)
[00fd6a8a] f3b0                      dc.w      $F3B0 ; r_slash
[00fd6a8c] 2a40                      movea.l   d0,a5
[00fd6a8e] 2e8d                      move.l    a5,(a7)
[00fd6a90] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd6a96] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6a98] 588f                      addq.l    #4,a7
[00fd6a9a] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd6a9c
xfd6a9c: ds.b 0
#if 0
[00fd6a9c] 4e56 0000                 link      a6,#0
[00fd6aa0] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd6aa4] 2a6e 0008                 movea.l   8(a6),a5
[00fd6aa8] 286e 000c                 movea.l   12(a6),a4
[00fd6aac] 2679 0000 a788            movea.l   _thedesk,a3
[00fd6ab2] 2e8d                      move.l    a5,(a7)
[00fd6ab4] f3b0                      dc.w      $F3B0 ; r_slash
[00fd6ab6] 2a40                      movea.l   d0,a5
[00fd6ab8] 528d                      addq.l    #1,a5
[00fd6aba] 486b 5e6b                 pea.l     24171(a3)
[00fd6abe] 2f0d                      move.l    a5,-(a7)
[00fd6ac0] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6ac2] 508f                      addq.l    #8,a7
[00fd6ac4] 2e8c                      move.l    a4,(a7)
[00fd6ac6] 486b 5e6b                 pea.l     24171(a3)
[00fd6aca] f3b4                      dc.w      $F3B4 ; fmt_str
[00fd6acc] 588f                      addq.l    #4,a7
[00fd6ace] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef _dos_error
_dos_error: ds.b 0
#if 0
[00fd6ad0] 4e56 fffc                 link      a6,#$FFFC
[00fd6ad4] 4a79 0000 742a            tst.w     DOS_ERR
[00fd6ada] 6736                      beq.s     $00FD6B12
[00fd6adc] 0c79 ffdc 0000 6e20       cmpi.w    #$FFDC,DOS_AX
[00fd6ae4] 660e                      bne.s     $00FD6AF4
[00fd6ae6] 4297                      clr.l     (a7)
[00fd6ae8] 2f3c 0001 0019            move.l    #$00010019,-(a7)
[00fd6aee] f0dc                      dc.w      $F0DC ; fill_string
[00fd6af0] 588f                      addq.l    #4,a7
[00fd6af2] 601a                      bra.s     $00FD6B0E
[00fd6af4] 0c79 ffe0 0000 6e20       cmpi.w    #$FFE0,DOS_AX
[00fd6afc] 6e10                      bgt.s     $00FD6B0E
[00fd6afe] 3039 0000 6e20            move.w    DOS_AX,d0
[00fd6b04] 4640                      not.w     d0
[00fd6b06] 3e80                      move.w    d0,(a7)
[00fd6b08] 0657 ffe2                 addi.w    #$FFE2,(a7)
[00fd6b0c] f0e8                      dc.w      $F0E8 ; form_error
[00fd6b0e] 4240                      clr.w     d0
[00fd6b10] 6002                      bra.s     $00FD6B14
[00fd6b12] 7001                      moveq.l   #1,d0
[00fd6b14] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd6b16
xfd6b16: ds.b 0
#if 0
[00fd6b16] 4e56 fff2                 link      a6,#$FFF2
[00fd6b1a] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd6b1e] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd6b24] 4287                      clr.l     d7
[00fd6b26] 42ad 3116                 clr.l     12566(a5)
[00fd6b2a] 426d 5e42                 clr.w     24130(a5)
[00fd6b2e] 426d 5e40                 clr.w     24128(a5)
[00fd6b32] 206e 0012                 movea.l   18(a6),a0
[00fd6b36] 3010                      move.w    (a0),d0
[00fd6b38] 4840                      swap      d0
[00fd6b3a] 4240                      clr.w     d0
[00fd6b3c] 4840                      swap      d0
[00fd6b3e] 2b40 32aa                 move.l    d0,12970(a5)
[00fd6b42] 206e 0016                 movea.l   22(a6),a0
[00fd6b46] 3010                      move.w    (a0),d0
[00fd6b48] 4840                      swap      d0
[00fd6b4a] 4240                      clr.w     d0
[00fd6b4c] 4840                      swap      d0
[00fd6b4e] 2b40 32ae                 move.l    d0,12974(a5)
[00fd6b52] 302e 0008                 move.w    8(a6),d0
[00fd6b56] 6000 0076                 bra.w     $00FD6BCE
[00fd6b5a] 42ad 32aa                 clr.l     12970(a5)
[00fd6b5e] 42ad 32ae                 clr.l     12974(a5)
[00fd6b62] 42ad 32b2                 clr.l     12978(a5)
[00fd6b66] 6000 007c                 bra.w     $00FD6BE4
[00fd6b6a] 3d7c 0008 fffa            move.w    #$0008,-6(a6)
[00fd6b70] 4a6d 35a0                 tst.w     13728(a5)
[00fd6b74] 6606                      bne.s     $00FD6B7C
[00fd6b76] 4a6d 35a2                 tst.w     13730(a5)
[00fd6b7a] 6706                      beq.s     $00FD6B82
[00fd6b7c] 3b7c 0001 5e42            move.w    #1,24130(a5)
[00fd6b82] 6012                      bra.s     $00FD6B96
[00fd6b84] 3d7c 0004 fffa            move.w    #$0004,-6(a6)
[00fd6b8a] 4a6d 35a0                 tst.w     13728(a5)
[00fd6b8e] 6706                      beq.s     $00FD6B96
[00fd6b90] 3b7c 0001 5e42            move.w    #1,24130(a5)
[00fd6b96] f3b8                      dc.w      $F3B8 ; dos_avail
[00fd6b98] 2b40 311a                 move.l    d0,12570(a5)
[00fd6b9c] 4aad 311a                 tst.l     12570(a5)
[00fd6ba0] 660c                      bne.s     $00FD6BAE
[00fd6ba2] 3ebc 001b                 move.w    #$001B,(a7)
[00fd6ba6] f3bc                      dc.w      $F3BC ; do1_alert
[00fd6ba8] 4240                      clr.w     d0
[00fd6baa] 6000 0120                 bra       $00FD6CCC
[00fd6bae] 2ead 311a                 move.l    12570(a5),(a7)
[00fd6bb2] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fd6bb4] 2b40 3116                 move.l    d0,12566(a5)
[00fd6bb8] 602a                      bra.s     $00FD6BE4
[00fd6bba] 3d7c 0005 fffa            move.w    #$0005,-6(a6)
[00fd6bc0] 4a6d 35a2                 tst.w     13730(a5)
[00fd6bc4] 6706                      beq.s     $00FD6BCC
[00fd6bc6] 3b7c 0001 5e42            move.w    #1,24130(a5)
[00fd6bcc] 6016                      bra.s     $00FD6BE4
[00fd6bce] 4a40                      tst.w     d0
[00fd6bd0] 6788                      beq.s     $00FD6B5A
[00fd6bd2] b07c 0001                 cmp.w     #1,d0
[00fd6bd6] 67e2                      beq.s     $00FD6BBA
[00fd6bd8] b07c 0002                 cmp.w     #$0002,d0
[00fd6bdc] 67a6                      beq.s     $00FD6B84
[00fd6bde] b07c 0003                 cmp.w     #$0003,d0
[00fd6be2] 6786                      beq.s     $00FD6B6A
[00fd6be4] 4a6d 5e42                 tst.w     24130(a5)
[00fd6be8] 6700 00e0                 beq       $00FD6CCA
[00fd6bec] 2e2d 3572                 move.l    13682(a5),d7
[00fd6bf0] 486e fffc                 pea.l     -4(a6)
[00fd6bf4] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fd6bf8] 3f3c 0005                 move.w    #$0005,-(a7)
[00fd6bfc] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fd6bfe] 508f                      addq.l    #8,a7
[00fd6c00] 207c 0000 00b4            movea.l   #$000000B4,a0
[00fd6c06] 2070 7800                 movea.l   0(a0,d7.l),a0
[00fd6c0a] 20ae fffc                 move.l    -4(a6),(a0)
[00fd6c0e] 206e 0012                 movea.l   18(a6),a0
[00fd6c12] 3010                      move.w    (a0),d0
[00fd6c14] 4840                      swap      d0
[00fd6c16] 4240                      clr.w     d0
[00fd6c18] 4840                      swap      d0
[00fd6c1a] 2d40 fff6                 move.l    d0,-10(a6)
[00fd6c1e] 206e 0016                 movea.l   22(a6),a0
[00fd6c22] 3010                      move.w    (a0),d0
[00fd6c24] 4840                      swap      d0
[00fd6c26] 4240                      clr.w     d0
[00fd6c28] 4840                      swap      d0
[00fd6c2a] 2d40 fff2                 move.l    d0,-14(a6)
[00fd6c2e] 4257                      clr.w     (a7)
[00fd6c30] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd6c34] 2f07                      move.l    d7,-(a7)
[00fd6c36] 486d 5e30                 pea.l     24112(a5)
[00fd6c3a] 486e fff6                 pea.l     -10(a6)
[00fd6c3e] f3c4                      dc.w      $F3C4
[00fd6c40] defc 000e                 adda.w    #$000E,a7
[00fd6c44] 4257                      clr.w     (a7)
[00fd6c46] 3f3c 0001                 move.w    #1,-(a7)
[00fd6c4a] 2f07                      move.l    d7,-(a7)
[00fd6c4c] 486d 5e34                 pea.l     24116(a5)
[00fd6c50] 486e fff2                 pea.l     -14(a6)
[00fd6c54] f3c4                      dc.w      $F3C4
[00fd6c56] defc 000e                 adda.w    #$000E,a7
[00fd6c5a] 2ebc 00fe b13a            move.l    #$00FEB13A,(a7)
[00fd6c60] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd6c64] 2f07                      move.l    d7,-(a7)
[00fd6c66] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd6c68] 5c8f                      addq.l    #6,a7
[00fd6c6a] 2ebc 00fe b13b            move.l    #$00FEB13B,(a7)
[00fd6c70] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd6c74] 2f07                      move.l    d7,-(a7)
[00fd6c76] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd6c78] 5c8f                      addq.l    #6,a7
[00fd6c7a] 2047                      movea.l   d7,a0
[00fd6c7c] d1fc 0000 0068            adda.l    #$00000068,a0
[00fd6c82] 30bc 0080                 move.w    #$0080,(a0)
[00fd6c86] 2047                      movea.l   d7,a0
[00fd6c88] d1fc 0000 0050            adda.l    #$00000050,a0
[00fd6c8e] 30bc 0080                 move.w    #$0080,(a0)
[00fd6c92] 2e87                      move.l    d7,(a7)
[00fd6c94] f3cc                      dc.w      $F3CC
[00fd6c96] 2047                      movea.l   d7,a0
[00fd6c98] d1fc 0000 0068            adda.l    #$00000068,a0
[00fd6c9e] 4250                      clr.w     (a0)
[00fd6ca0] 2047                      movea.l   d7,a0
[00fd6ca2] d1fc 0000 0050            adda.l    #$00000050,a0
[00fd6ca8] 4250                      clr.w     (a0)
[00fd6caa] 3ebc ffff                 move.w    #$FFFF,(a7)
[00fd6cae] 2f07                      move.l    d7,-(a7)
[00fd6cb0] f3d0                      dc.w      $F3D0 ; form_do
[00fd6cb2] 588f                      addq.l    #4,a7
[00fd6cb4] 3ebc 0006                 move.w    #$0006,(a7)
[00fd6cb8] 3f3c 0005                 move.w    #$0005,-(a7)
[00fd6cbc] 2f07                      move.l    d7,-(a7)
[00fd6cbe] f3d4                      dc.w      $F3D4 ; inf_what
[00fd6cc0] 5c8f                      addq.l    #6,a7
[00fd6cc2] 4a40                      tst.w     d0
[00fd6cc4] 6604                      bne.s     $00FD6CCA
[00fd6cc6] 4240                      clr.w     d0
[00fd6cc8] 6002                      bra.s     $00FD6CCC
[00fd6cca] 7001                      moveq.l   #1,d0
[00fd6ccc] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd6cce
xfd6cce: ds.b 0
#if 0
[00fd6cce] 4e56 0000                 link      a6,#0
[00fd6cd2] 48e7 070c                 movem.l   d5-d7/a4-a5,-(a7)
[00fd6cd6] 2a6e 000e                 movea.l   14(a6),a5
[00fd6cda] 2879 0000 a788            movea.l   _thedesk,a4
[00fd6ce0] 2ebc 0000 622c            move.l    #$0000622C,(a7)
[00fd6ce6] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd6cea] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6cec] 588f                      addq.l    #4,a7
[00fd6cee] 2ebc 0000 62ac            move.l    #$000062AC,(a7)
[00fd6cf4] 2f2e 0012                 move.l    18(a6),-(a7)
[00fd6cf8] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6cfa] 588f                      addq.l    #4,a7
[00fd6cfc] 0839 0002 0000 70c3       btst      #2,$000070C3
[00fd6d04] 670c                      beq.s     $00FD6D12
[00fd6d06] 0c6e 0002 0008            cmpi.w    #$0002,8(a6)
[00fd6d0c] 6604                      bne.s     $00FD6D12
[00fd6d0e] 7003                      moveq.l   #3,d0
[00fd6d10] 6004                      bra.s     $00FD6D16
[00fd6d12] 302e 0008                 move.w    8(a6),d0
[00fd6d16] 3d40 0008                 move.w    d0,8(a6)
[00fd6d1a] 2eae 001a                 move.l    26(a6),(a7)
[00fd6d1e] 2f2e 0016                 move.l    22(a6),-(a7)
[00fd6d22] 2f3c 0000 62ac            move.l    #$000062AC,-(a7)
[00fd6d28] 2f3c 0000 622c            move.l    #$0000622C,-(a7)
[00fd6d2e] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd6d32] f3d8                      dc.w      $F3D8
[00fd6d34] defc 000e                 adda.w    #$000E,a7
[00fd6d38] 4a40                      tst.w     d0
[00fd6d3a] 6700 00a0                 beq       $00FD6DDC
[00fd6d3e] 3ebc 0001                 move.w    #1,(a7)
[00fd6d42] f094                      dc.w      $F094 ; desk_wait
[00fd6d44] 6000 0090                 bra       $00FD6DD6
[00fd6d48] 0c6d ffff 0020            cmpi.w    #$FFFF,32(a5)
[00fd6d4e] 6700 0084                 beq       $00FD6DD4
[00fd6d52] 204c                      movea.l   a4,a0
[00fd6d54] 322d 0020                 move.w    32(a5),d1
[00fd6d58] c3fc 0018                 muls.w    #$0018,d1
[00fd6d5c] d1c1                      adda.l    d1,a0
[00fd6d5e] 0828 0000 5e93            btst      #0,24211(a0)
[00fd6d64] 676e                      beq.s     $00FD6DD4
[00fd6d66] 0c2d 0010 0009            cmpi.b    #$10,9(a5)
[00fd6d6c] 663a                      bne.s     $00FD6DA8
[00fd6d6e] 486d 0012                 pea.l     18(a5)
[00fd6d72] 2f3c 0000 622c            move.l    #$0000622C,-(a7)
[00fd6d78] f3dc                      dc.w      $F3DC
[00fd6d7a] 508f                      addq.l    #8,a7
[00fd6d7c] 2eae 001a                 move.l    26(a6),(a7)
[00fd6d80] 2f2e 0016                 move.l    22(a6),-(a7)
[00fd6d84] 2f3c 0000 62ac            move.l    #$000062AC,-(a7)
[00fd6d8a] 2f3c 0000 622c            move.l    #$0000622C,-(a7)
[00fd6d90] 2f07                      move.l    d7,-(a7)
[00fd6d92] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd6d96] f3e0                      dc.w      $F3E0
[00fd6d98] defc 0012                 adda.w    #$0012,a7
[00fd6d9c] 3c00                      move.w    d0,d6
[00fd6d9e] 2ebc 0000 622c            move.l    #$0000622C,(a7)
[00fd6da4] f3e4                      dc.w      $F3E4
[00fd6da6] 6028                      bra.s     $00FD6DD0
[00fd6da8] 2f2d 000a                 move.l    10(a5),-(a7)
[00fd6dac] 102d 0009                 move.b    9(a5),d0
[00fd6db0] 4880                      ext.w     d0
[00fd6db2] 3f00                      move.w    d0,-(a7)
[00fd6db4] 486d 0012                 pea.l     18(a5)
[00fd6db8] 2f3c 0000 62ac            move.l    #$000062AC,-(a7)
[00fd6dbe] 2f3c 0000 622c            move.l    #$0000622C,-(a7)
[00fd6dc4] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd6dc8] f3e8                      dc.w      $F3E8
[00fd6dca] defc 0014                 adda.w    #$0014,a7
[00fd6dce] 3c00                      move.w    d0,d6
[00fd6dd0] 4a46                      tst.w     d6
[00fd6dd2] 6708                      beq.s     $00FD6DDC
[00fd6dd4] 2a55                      movea.l   (a5),a5
[00fd6dd6] 200d                      move.l    a5,d0
[00fd6dd8] 6600 ff6e                 bne       $00FD6D48
[00fd6ddc] 4a6c 5e42                 tst.w     24130(a4)
[00fd6de0] 6708                      beq.s     $00FD6DEA
[00fd6de2] 2eac 3572                 move.l    13682(a4),(a7)
[00fd6de6] f3ec                      dc.w      $F3EC ; do_finish
[00fd6de8] 600c                      bra.s     $00FD6DF6
[00fd6dea] 4a6c 5e40                 tst.w     24128(a4)
[00fd6dee] 6706                      beq.s     $00FD6DF6
[00fd6df0] 2eac 3576                 move.l    13686(a4),(a7)
[00fd6df4] f3ec                      dc.w      $F3EC ; do_finish
[00fd6df6] 302e 0008                 move.w    8(a6),d0
[00fd6dfa] 602c                      bra.s     $00FD6E28
[00fd6dfc] 202c 32aa                 move.l    12970(a4),d0
[00fd6e00] 226e 0016                 movea.l   22(a6),a1
[00fd6e04] 3280                      move.w    d0,(a1)
[00fd6e06] 202c 32ae                 move.l    12974(a4),d0
[00fd6e0a] 226e 001a                 movea.l   26(a6),a1
[00fd6e0e] 3280                      move.w    d0,(a1)
[00fd6e10] 206e 001e                 movea.l   30(a6),a0
[00fd6e14] 20ac 32b2                 move.l    12978(a4),(a0)
[00fd6e18] 601e                      bra.s     $00FD6E38
[00fd6e1a] 4aac 3116                 tst.l     12566(a4)
[00fd6e1e] 6706                      beq.s     $00FD6E26
[00fd6e20] 2eac 3116                 move.l    12566(a4),(a7)
[00fd6e24] f3f0                      dc.w      $F3F0 ; dos_free
[00fd6e26] 6010                      bra.s     $00FD6E38
[00fd6e28] 4a40                      tst.w     d0
[00fd6e2a] 67d0                      beq.s     $00FD6DFC
[00fd6e2c] b07c 0002                 cmp.w     #$0002,d0
[00fd6e30] 67e8                      beq.s     $00FD6E1A
[00fd6e32] b07c 0003                 cmp.w     #$0003,d0
[00fd6e36] 67e2                      beq.s     $00FD6E1A
[00fd6e38] 4257                      clr.w     (a7)
[00fd6e3a] f094                      dc.w      $F094 ; desk_wait
[00fd6e3c] 3006                      move.w    d6,d0
[00fd6e3e] fc31                      dc.w      $FC31 ; movem.l (a7)+,d6-d7/a4-a5
#endif

	xdef xfd6e40
xfd6e40: ds.b 0
#if 0
[00fd6e40] 4e56 ffe8                 link      a6,#$FFE8
[00fd6e44] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fd6e48] 2a6e 000e                 movea.l   14(a6),a5
[00fd6e4c] 286e 0012                 movea.l   18(a6),a4
[00fd6e50] 4245                      clr.w     d5
[00fd6e52] 2d79 0000 a788 ffe8       move.l    _thedesk,-24(a6)
[00fd6e5a] 4246                      clr.w     d6
[00fd6e5c] 2e8d                      move.l    a5,(a7)
[00fd6e5e] f3b0                      dc.w      $F3B0 ; r_slash
[00fd6e60] 2640                      movea.l   d0,a3
[00fd6e62] 2d4b ffec                 move.l    a3,-20(a6)
[00fd6e66] 204b                      movea.l   a3,a0
[00fd6e68] 4210                      clr.b     (a0)
[00fd6e6a] 538b                      subq.l    #1,a3
[00fd6e6c] 600e                      bra.s     $00FD6E7C
[00fd6e6e] 204b                      movea.l   a3,a0
[00fd6e70] 0c10 005c                 cmpi.b    #$5C,(a0)
[00fd6e74] 40c0                      move.w    sr,d0
[00fd6e76] 538b                      subq.l    #1,a3
[00fd6e78] 44c0                      move.w    d0,ccr
[00fd6e7a] 6704                      beq.s     $00FD6E80
[00fd6e7c] 200b                      move.l    a3,d0
[00fd6e7e] 66ee                      bne.s     $00FD6E6E
[00fd6e80] 548b                      addq.l    #2,a3
[00fd6e82] 2ebc 0000 633c            move.l    #$0000633C,(a7)
[00fd6e88] 2f0b                      move.l    a3,-(a7)
[00fd6e8a] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6e8c] 588f                      addq.l    #4,a7
[00fd6e8e] 206e ffec                 movea.l   -20(a6),a0
[00fd6e92] 10bc 005c                 move.b    #$5C,(a0)
[00fd6e96] 4279 0000 a786            clr.w     $0000A786
[00fd6e9c] 4a6e 0008                 tst.w     8(a6)
[00fd6ea0] 6708                      beq.s     $00FD6EAA
[00fd6ea2] 0c6e 0001 0008            cmpi.w    #1,8(a6)
[00fd6ea8] 6606                      bne.s     $00FD6EB0
[00fd6eaa] 2d4d ffec                 move.l    a5,-20(a6)
[00fd6eae] 600a                      bra.s     $00FD6EBA
[00fd6eb0] 2d4c ffec                 move.l    a4,-20(a6)
[00fd6eb4] 5279 0000 a786            addq.w    #1,$0000A786
[00fd6eba] 6018                      bra.s     $00FD6ED4
[00fd6ebc] 206e ffec                 movea.l   -20(a6),a0
[00fd6ec0] 0c10 005c                 cmpi.b    #$5C,(a0)
[00fd6ec4] 40c0                      move.w    sr,d0
[00fd6ec6] 52ae ffec                 addq.l    #1,-20(a6)
[00fd6eca] 44c0                      move.w    d0,ccr
[00fd6ecc] 6606                      bne.s     $00FD6ED4
[00fd6ece] 5279 0000 a786            addq.w    #1,$0000A786
[00fd6ed4] 206e ffec                 movea.l   -20(a6),a0
[00fd6ed8] 4a10                      tst.b     (a0)
[00fd6eda] 66e0                      bne.s     $00FD6EBC
[00fd6edc] 5379 0000 a786            subq.w    #1,$0000A786
[00fd6ee2] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd6ee6] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd6eec] 2f0d                      move.l    a5,-(a7)
[00fd6eee] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6ef0] 588f                      addq.l    #4,a7
[00fd6ef2] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd6ef6] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd6efc] 2f0c                      move.l    a4,-(a7)
[00fd6efe] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6f00] 588f                      addq.l    #4,a7
[00fd6f02] 0c79 0008 0000 a786       cmpi.w    #$0008,$0000A786
[00fd6f0a] 6f12                      ble.s     $00FD6F1E
[00fd6f0c] 4297                      clr.l     (a7)
[00fd6f0e] 2f3c 0001 0017            move.l    #$00010017,-(a7)
[00fd6f14] f0dc                      dc.w      $F0DC ; fill_string
[00fd6f16] 588f                      addq.l    #4,a7
[00fd6f18] 4245                      clr.w     d5
[00fd6f1a] 6000 03f6                 bra       $00FD7312
[00fd6f1e] 3039 0000 a786            move.w    $0000A786,d0
[00fd6f24] c1fc 002c                 muls.w    #$002C,d0
[00fd6f28] d0ae ffe8                 add.l     -24(a6),d0
[00fd6f2c] 2e80                      move.l    d0,(a7)
[00fd6f2e] 0697 0000 311e            addi.l    #$0000311E,(a7)
[00fd6f34] f3f4                      dc.w      $F3F4 ; dos_sdta
[00fd6f36] 302e 0008                 move.w    8(a6),d0
[00fd6f3a] 6000 01b6                 bra       $00FD70F2
[00fd6f3e] 206e ffe8                 movea.l   -24(a6),a0
[00fd6f42] 2028 32ae                 move.l    12974(a0),d0
[00fd6f46] 226e ffe8                 movea.l   -24(a6),a1
[00fd6f4a] 52a9 32ae                 addq.l    #1,12974(a1)
[00fd6f4e] 6000 01b8                 bra       $00FD7108
[00fd6f52] 2ebc 0000 632c            move.l    #$0000632C,(a7)
[00fd6f58] 2f3c 0000 633c            move.l    #$0000633C,-(a7)
[00fd6f5e] f36c                      dc.w      $F36C ; xstrpcpy
[00fd6f60] 588f                      addq.l    #4,a7
[00fd6f62] 2ebc 0000 632c            move.l    #$0000632C,(a7)
[00fd6f68] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd6f6c] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd6f72] f3f8                      dc.w      $F3F8
[00fd6f74] 588f                      addq.l    #4,a7
[00fd6f76] 3ebc 0016                 move.w    #$0016,(a7)
[00fd6f7a] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd6f7e] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd6f84] f3fc                      dc.w      $F3FC ; dos_sfirst
[00fd6f86] 588f                      addq.l    #4,a7
[00fd6f88] 4a40                      tst.w     d0
[00fd6f8a] 6616                      bne.s     $00FD6FA2
[00fd6f8c] 0c79 0012 0000 6e20       cmpi.w    #$0012,DOS_AX
[00fd6f94] 6700 00dc                 beq       $00FD7072
[00fd6f98] f374                      dc.w      $F374 ; dos_error
[00fd6f9a] 6000 0376                 bra       $00FD7312
[00fd6f9e] 6000 00d2                 bra       $00FD7072
[00fd6fa2] 486e fff0                 pea.l     -16(a6)
[00fd6fa6] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd6faa] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd6fb0] f400                      dc.w      $F400
[00fd6fb2] 508f                      addq.l    #8,a7
[00fd6fb4] 3e00                      move.w    d0,d7
[00fd6fb6] 4a47                      tst.w     d7
[00fd6fb8] 6700 0358                 beq       $00FD7312
[00fd6fbc] be7c 0001                 cmp.w     #1,d7
[00fd6fc0] 6600 0098                 bne       $00FD705A
[00fd6fc4] 4a2e fff0                 tst.b     -16(a6)
[00fd6fc8] 67d8                      beq.s     $00FD6FA2
[00fd6fca] 2ebc 0000 632c            move.l    #$0000632C,(a7)
[00fd6fd0] 486e fff0                 pea.l     -16(a6)
[00fd6fd4] f39c                      dc.w      $F39C ; streq
[00fd6fd6] 588f                      addq.l    #4,a7
[00fd6fd8] 4a40                      tst.w     d0
[00fd6fda] 6746                      beq.s     $00FD7022
[00fd6fdc] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd6fe0] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd6fe6] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd6fec] f404                      dc.w      $F404 ; xstrpcat
[00fd6fee] 588f                      addq.l    #4,a7
[00fd6ff0] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd6ff4] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd6ffa] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd6ffe] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd7004] f408                      dc.w      $F408
[00fd7006] 588f                      addq.l    #4,a7
[00fd7008] 3e00                      move.w    d0,d7
[00fd700a] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd700e] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd7014] f3b0                      dc.w      $F3B0 ; r_slash
[00fd7016] 2640                      movea.l   d0,a3
[00fd7018] 4213                      clr.b     (a3)
[00fd701a] 4a47                      tst.w     d7
[00fd701c] 6784                      beq.s     $00FD6FA2
[00fd701e] 6000 00bc                 bra       $00FD70DC
[00fd7022] 2ebc 0000 632c            move.l    #$0000632C,(a7)
[00fd7028] 486e fff0                 pea.l     -16(a6)
[00fd702c] f36c                      dc.w      $F36C ; xstrpcpy
[00fd702e] 588f                      addq.l    #4,a7
[00fd7030] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd7034] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd703a] 2f0c                      move.l    a4,-(a7)
[00fd703c] f36c                      dc.w      $F36C ; xstrpcpy
[00fd703e] 588f                      addq.l    #4,a7
[00fd7040] 2ebc 0000 632c            move.l    #$0000632C,(a7)
[00fd7046] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd704a] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd7050] f3f8                      dc.w      $F3F8
[00fd7052] 588f                      addq.l    #4,a7
[00fd7054] 6000 ff20                 bra       $00FD6F76
[00fd7058] 6018                      bra.s     $00FD7072
[00fd705a] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd705e] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd7064] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd706a] f404                      dc.w      $F404 ; xstrpcat
[00fd706c] 588f                      addq.l    #4,a7
[00fd706e] 6000 0208                 bra       $00FD7278
[00fd7072] 206e ffe8                 movea.l   -24(a6),a0
[00fd7076] 2028 32ae                 move.l    12974(a0),d0
[00fd707a] 226e ffe8                 movea.l   -24(a6),a1
[00fd707e] 52a9 32ae                 addq.l    #1,12974(a1)
[00fd7082] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd7086] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd708c] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd7092] f404                      dc.w      $F404 ; xstrpcat
[00fd7094] 588f                      addq.l    #4,a7
[00fd7096] 4257                      clr.w     (a7)
[00fd7098] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd709c] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd70a2] f40c                      dc.w      $F40C
[00fd70a4] 588f                      addq.l    #4,a7
[00fd70a6] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd70aa] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd70b0] f3b0                      dc.w      $F3B0 ; r_slash
[00fd70b2] 2640                      movea.l   d0,a3
[00fd70b4] 4213                      clr.b     (a3)
[00fd70b6] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd70ba] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd70c0] f410                      dc.w      $F410 ; dos_mkdir
[00fd70c2] 0c79 0005 0000 6e20       cmpi.w    #$0005,DOS_AX
[00fd70ca] 6610                      bne.s     $00FD70DC
[00fd70cc] 33fc ffdc 0000 6e20       move.w    #$FFDC,DOS_AX
[00fd70d4] f374                      dc.w      $F374 ; dos_error
[00fd70d6] 4a40                      tst.w     d0
[00fd70d8] 6700 0238                 beq       $00FD7312
[00fd70dc] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd70e0] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd70e6] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd70ec] f404                      dc.w      $F404 ; xstrpcat
[00fd70ee] 588f                      addq.l    #4,a7
[00fd70f0] 6016                      bra.s     $00FD7108
[00fd70f2] 4a40                      tst.w     d0
[00fd70f4] 6700 fe48                 beq       $00FD6F3E
[00fd70f8] b07c 0002                 cmp.w     #$0002,d0
[00fd70fc] 6700 fe54                 beq       $00FD6F52
[00fd7100] b07c 0003                 cmp.w     #$0003,d0
[00fd7104] 6700 fe4c                 beq       $00FD6F52
[00fd7108] 3ebc 0037                 move.w    #$0037,(a7)
[00fd710c] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd7110] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd7116] f3fc                      dc.w      $F3FC ; dos_sfirst
[00fd7118] 588f                      addq.l    #4,a7
[00fd711a] 3e00                      move.w    d0,d7
[00fd711c] 6000 0108                 bra       $00FD7226
[00fd7120] 4a47                      tst.w     d7
[00fd7122] 6612                      bne.s     $00FD7136
[00fd7124] 0c79 0012 0000 6e20       cmpi.w    #$0012,DOS_AX
[00fd712c] 6700 00fc                 beq       $00FD722A
[00fd7130] f374                      dc.w      $F374 ; dos_error
[00fd7132] 6000 01de                 bra       $00FD7312
[00fd7136] 3039 0000 a786            move.w    $0000A786,d0
[00fd713c] c1fc 002c                 muls.w    #$002C,d0
[00fd7140] d0ae ffe8                 add.l     -24(a6),d0
[00fd7144] 2040                      movea.l   d0,a0
[00fd7146] 0828 0004 3133            btst      #4,12595(a0)
[00fd714c] 675a                      beq.s     $00FD71A8
[00fd714e] 3039 0000 a786            move.w    $0000A786,d0
[00fd7154] c1fc 002c                 muls.w    #$002C,d0
[00fd7158] d0ae ffe8                 add.l     -24(a6),d0
[00fd715c] 2040                      movea.l   d0,a0
[00fd715e] 0c28 002e 313c            cmpi.b    #$2E,12604(a0)
[00fd7164] 6740                      beq.s     $00FD71A6
[00fd7166] 5246                      addq.w    #1,d6
[00fd7168] 2ebc 0000 633c            move.l    #$0000633C,(a7)
[00fd716e] 3039 0000 a786            move.w    $0000A786,d0
[00fd7174] c1fc 002c                 muls.w    #$002C,d0
[00fd7178] d0ae ffe8                 add.l     -24(a6),d0
[00fd717c] 2f00                      move.l    d0,-(a7)
[00fd717e] 0697 0000 313c            addi.l    #$0000313C,(a7)
[00fd7184] f36c                      dc.w      $F36C ; xstrpcpy
[00fd7186] 588f                      addq.l    #4,a7
[00fd7188] 5279 0000 a786            addq.w    #1,$0000A786
[00fd718e] 2ebc 0000 633c            move.l    #$0000633C,(a7)
[00fd7194] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd7198] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd719e] f3dc                      dc.w      $F3DC
[00fd71a0] 588f                      addq.l    #4,a7
[00fd71a2] 6000 fd5e                 bra       $00FD6F02
[00fd71a6] 607a                      bra.s     $00FD7222
[00fd71a8] 3039 0000 a786            move.w    $0000A786,d0
[00fd71ae] c1fc 002c                 muls.w    #$002C,d0
[00fd71b2] d0ae ffe8                 add.l     -24(a6),d0
[00fd71b6] 2040                      movea.l   d0,a0
[00fd71b8] 3ea8 3136                 move.w    12598(a0),(a7)
[00fd71bc] 3039 0000 a786            move.w    $0000A786,d0
[00fd71c2] c1fc 002c                 muls.w    #$002C,d0
[00fd71c6] d0ae ffe8                 add.l     -24(a6),d0
[00fd71ca] 2040                      movea.l   d0,a0
[00fd71cc] 3f28 3134                 move.w    12596(a0),-(a7)
[00fd71d0] 3039 0000 a786            move.w    $0000A786,d0
[00fd71d6] c1fc 002c                 muls.w    #$002C,d0
[00fd71da] d0ae ffe8                 add.l     -24(a6),d0
[00fd71de] 2040                      movea.l   d0,a0
[00fd71e0] 1028 3133                 move.b    12595(a0),d0
[00fd71e4] 4880                      ext.w     d0
[00fd71e6] 3f00                      move.w    d0,-(a7)
[00fd71e8] 3039 0000 a786            move.w    $0000A786,d0
[00fd71ee] c1fc 002c                 muls.w    #$002C,d0
[00fd71f2] d0ae ffe8                 add.l     -24(a6),d0
[00fd71f6] 2f00                      move.l    d0,-(a7)
[00fd71f8] 0697 0000 313c            addi.l    #$0000313C,(a7)
[00fd71fe] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd7202] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd7208] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd720c] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd7212] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd7216] f3e8                      dc.w      $F3E8
[00fd7218] defc 0012                 adda.w    #$0012,a7
[00fd721c] 4a40                      tst.w     d0
[00fd721e] 6700 00f2                 beq       $00FD7312
[00fd7222] f414                      dc.w      $F414 ; dos_snext
[00fd7224] 3e00                      move.w    d0,d7
[00fd7226] 6000 fef8                 bra       $00FD7120
[00fd722a] 0c6e 0001 0008            cmpi.w    #1,8(a6)
[00fd7230] 6708                      beq.s     $00FD723A
[00fd7232] 0c6e 0003 0008            cmpi.w    #$0003,8(a6)
[00fd7238] 663e                      bne.s     $00FD7278
[00fd723a] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd723e] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd7244] f3b0                      dc.w      $F3B0 ; r_slash
[00fd7246] 2d40 ffec                 move.l    d0,-20(a6)
[00fd724a] 206e ffec                 movea.l   -20(a6),a0
[00fd724e] 0c28 003a ffff            cmpi.b    #$3A,-1(a0)
[00fd7254] 6722                      beq.s     $00FD7278
[00fd7256] 206e ffec                 movea.l   -20(a6),a0
[00fd725a] 4210                      clr.b     (a0)
[00fd725c] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd7260] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd7266] f418                      dc.w      $F418 ; dos_rmdir
[00fd7268] 206e ffec                 movea.l   -20(a6),a0
[00fd726c] 10bc 005c                 move.b    #$5C,(a0)
[00fd7270] f374                      dc.w      $F374 ; dos_error
[00fd7272] 4a40                      tst.w     d0
[00fd7274] 6700 009c                 beq       $00FD7312
[00fd7278] 302e 0008                 move.w    8(a6),d0
[00fd727c] 602e                      bra.s     $00FD72AC
[00fd727e] 4257                      clr.w     (a7)
[00fd7280] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd7284] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd728a] f40c                      dc.w      $F40C
[00fd728c] 588f                      addq.l    #4,a7
[00fd728e] 4a40                      tst.w     d0
[00fd7290] 6700 0080                 beq       $00FD7312
[00fd7294] 6028                      bra.s     $00FD72BE
[00fd7296] 4257                      clr.w     (a7)
[00fd7298] 2f2e ffe8                 move.l    -24(a6),-(a7)
[00fd729c] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd72a2] f40c                      dc.w      $F40C
[00fd72a4] 588f                      addq.l    #4,a7
[00fd72a6] 4a40                      tst.w     d0
[00fd72a8] 6768                      beq.s     $00FD7312
[00fd72aa] 6012                      bra.s     $00FD72BE
[00fd72ac] b07c 0001                 cmp.w     #1,d0
[00fd72b0] 67e4                      beq.s     $00FD7296
[00fd72b2] b07c 0002                 cmp.w     #$0002,d0
[00fd72b6] 67c6                      beq.s     $00FD727E
[00fd72b8] b07c 0003                 cmp.w     #$0003,d0
[00fd72bc] 67c0                      beq.s     $00FD727E
[00fd72be] 4a46                      tst.w     d6
[00fd72c0] 674e                      beq.s     $00FD7310
[00fd72c2] 0c6e 0002 0008            cmpi.w    #$0002,8(a6)
[00fd72c8] 6708                      beq.s     $00FD72D2
[00fd72ca] 0c6e 0003 0008            cmpi.w    #$0003,8(a6)
[00fd72d0] 660c                      bne.s     $00FD72DE
[00fd72d2] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd72d6] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd72dc] f3e4                      dc.w      $F3E4
[00fd72de] 2eae ffe8                 move.l    -24(a6),(a7)
[00fd72e2] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd72e8] f3e4                      dc.w      $F3E4
[00fd72ea] 5346                      subq.w    #1,d6
[00fd72ec] 5379 0000 a786            subq.w    #1,$0000A786
[00fd72f2] 3039 0000 a786            move.w    $0000A786,d0
[00fd72f8] c1fc 002c                 muls.w    #$002C,d0
[00fd72fc] d0ae ffe8                 add.l     -24(a6),d0
[00fd7300] 2e80                      move.l    d0,(a7)
[00fd7302] 0697 0000 311e            addi.l    #$0000311E,(a7)
[00fd7308] f3f4                      dc.w      $F3F4 ; dos_sdta
[00fd730a] 6000 ff16                 bra       $00FD7222
[00fd730e] 6002                      bra.s     $00FD7312
[00fd7310] 7a01                      moveq.l   #1,d5
[00fd7312] 3005                      move.w    d5,d0
[00fd7314] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef xfd7316
xfd7316: ds.b 0
#if 0
[00fd7316] 4e56 ffd8                 link      a6,#$FFD8
[00fd731a] 48e7 3f1c                 movem.l   d2-d7/a3-a5,-(a7)
[00fd731e] 7e01                      moveq.l   #1,d7
[00fd7320] 2a6e 000a                 movea.l   10(a6),a5
[00fd7324] 286e 000e                 movea.l   14(a6),a4
[00fd7328] 2679 0000 a788            movea.l   _thedesk,a3
[00fd732e] 4a6e 0008                 tst.w     8(a6)
[00fd7332] 6620                      bne.s     $00FD7354
[00fd7334] 52ab 32aa                 addq.l    #1,12970(a3)
[00fd7338] 204b                      movea.l   a3,a0
[00fd733a] 3239 0000 a786            move.w    $0000A786,d1
[00fd7340] c3fc 002c                 muls.w    #$002C,d1
[00fd7344] d1c1                      adda.l    d1,a0
[00fd7346] 2028 3138                 move.l    12600(a0),d0
[00fd734a] d1ab 32b2                 add.l     d0,12978(a3)
[00fd734e] 7001                      moveq.l   #1,d0
[00fd7350] 6000 029e                 bra       $00FD75F0
[00fd7354] 2eae 0012                 move.l    18(a6),(a7)
[00fd7358] 2f0d                      move.l    a5,-(a7)
[00fd735a] f3f8                      dc.w      $F3F8
[00fd735c] 588f                      addq.l    #4,a7
[00fd735e] 0c6e 0001 0008            cmpi.w    #1,8(a6)
[00fd7364] 6716                      beq.s     $00FD737C
[00fd7366] 2eae 0012                 move.l    18(a6),(a7)
[00fd736a] 2f0c                      move.l    a4,-(a7)
[00fd736c] f3f8                      dc.w      $F3F8
[00fd736e] 588f                      addq.l    #4,a7
[00fd7370] 486e ffec                 pea.l     -20(a6)
[00fd7374] 2f2e 0012                 move.l    18(a6),-(a7)
[00fd7378] f36c                      dc.w      $F36C ; xstrpcpy
[00fd737a] 508f                      addq.l    #8,a7
[00fd737c] 4243                      clr.w     d3
[00fd737e] 302e 0008                 move.w    8(a6),d0
[00fd7382] 6000 01fe                 bra       $00FD7582
[00fd7386] 3ebc 0001                 move.w    #1,(a7)
[00fd738a] 2f0d                      move.l    a5,-(a7)
[00fd738c] f40c                      dc.w      $F40C
[00fd738e] 588f                      addq.l    #4,a7
[00fd7390] 4a40                      tst.w     d0
[00fd7392] 6700 0206                 beq       $00FD759A
[00fd7396] 2e8d                      move.l    a5,(a7)
[00fd7398] f37c                      dc.w      $F37C ; dos_delete
[00fd739a] 0c79 ffdc 0000 6e20       cmpi.w    #$FFDC,DOS_AX
[00fd73a2] 660a                      bne.s     $00FD73AE
[00fd73a4] 7601                      moveq.l   #1,d3
[00fd73a6] 3ebc 0005                 move.w    #$0005,(a7)
[00fd73aa] f0e8                      dc.w      $F0E8 ; form_error
[00fd73ac] 6008                      bra.s     $00FD73B6
[00fd73ae] f374                      dc.w      $F374 ; dos_error
[00fd73b0] 4a40                      tst.w     d0
[00fd73b2] 6702                      beq.s     $00FD73B6
[00fd73b4] 7601                      moveq.l   #1,d3
[00fd73b6] 6000 01e2                 bra       $00FD759A
[00fd73ba] 1015                      move.b    (a5),d0
[00fd73bc] 4880                      ext.w     d0
[00fd73be] b014                      cmp.b     (a4),d0
[00fd73c0] 6636                      bne.s     $00FD73F8
[00fd73c2] 3ebc 0001                 move.w    #1,(a7)
[00fd73c6] 2f0c                      move.l    a4,-(a7)
[00fd73c8] f40c                      dc.w      $F40C
[00fd73ca] 588f                      addq.l    #4,a7
[00fd73cc] 4a40                      tst.w     d0
[00fd73ce] 6700 01ca                 beq       $00FD759A
[00fd73d2] 2e8c                      move.l    a4,(a7)
[00fd73d4] 2f0d                      move.l    a5,-(a7)
[00fd73d6] f41c                      dc.w      $F41C ; dos_rename
[00fd73d8] 588f                      addq.l    #4,a7
[00fd73da] 4a79 0000 742a            tst.w     DOS_ERR
[00fd73e0] 6606                      bne.s     $00FD73E8
[00fd73e2] 7601                      moveq.l   #1,d3
[00fd73e4] 6000 01f8                 bra       $00FD75DE
[00fd73e8] 0c79 ffdc 0000 6e20       cmpi.w    #$FFDC,DOS_AX
[00fd73f0] 6716                      beq.s     $00FD7408
[00fd73f2] f374                      dc.w      $F374 ; dos_error
[00fd73f4] 6000 01e8                 bra       $00FD75DE
[00fd73f8] 3ebc 0001                 move.w    #1,(a7)
[00fd73fc] 2f0c                      move.l    a4,-(a7)
[00fd73fe] f40c                      dc.w      $F40C
[00fd7400] 588f                      addq.l    #4,a7
[00fd7402] 4a40                      tst.w     d0
[00fd7404] 6700 0194                 beq       $00FD759A
[00fd7408] 4257                      clr.w     (a7)
[00fd740a] 2f0d                      move.l    a5,-(a7)
[00fd740c] f33c                      dc.w      $F33C ; dos_open
[00fd740e] 588f                      addq.l    #4,a7
[00fd7410] 3a00                      move.w    d0,d5
[00fd7412] f374                      dc.w      $F374 ; dos_error
[00fd7414] 4a40                      tst.w     d0
[00fd7416] 6700 0182                 beq       $00FD759A
[00fd741a] 2eab 3116                 move.l    12566(a3),(a7)
[00fd741e] 2f2b 311a                 move.l    12570(a3),-(a7)
[00fd7422] 3f05                      move.w    d5,-(a7)
[00fd7424] 3f3c 003f                 move.w    #$003F,-(a7)
[00fd7428] f0d8                      dc.w      $F0D8 ; trap
[00fd742a] 508f                      addq.l    #8,a7
[00fd742c] 2800                      move.l    d0,d4
[00fd742e] f374                      dc.w      $F374 ; dos_error
[00fd7430] 4a40                      tst.w     d0
[00fd7432] 6700 0148                 beq       $00FD757C
[00fd7436] 4257                      clr.w     (a7)
[00fd7438] 2f0c                      move.l    a4,-(a7)
[00fd743a] f33c                      dc.w      $F33C ; dos_open
[00fd743c] 588f                      addq.l    #4,a7
[00fd743e] 3c00                      move.w    d0,d6
[00fd7440] 4a79 0000 742a            tst.w     DOS_ERR
[00fd7446] 6714                      beq.s     $00FD745C
[00fd7448] 0c79 0002 0000 6e20       cmpi.w    #$0002,DOS_AX
[00fd7450] 6700 008c                 beq       $00FD74DE
[00fd7454] f374                      dc.w      $F374 ; dos_error
[00fd7456] 6000 0124                 bra       $00FD757C
[00fd745a] 6004                      bra.s     $00FD7460
[00fd745c] 3e86                      move.w    d6,(a7)
[00fd745e] f344                      dc.w      $F344 ; dos_close
[00fd7460] 4a6b 35a6                 tst.w     13734(a3)
[00fd7464] 6624                      bne.s     $00FD748A
[00fd7466] 486e ffdc                 pea.l     -36(a6)
[00fd746a] 2f0c                      move.l    a4,-(a7)
[00fd746c] f400                      dc.w      $F400
[00fd746e] 508f                      addq.l    #8,a7
[00fd7470] 3e00                      move.w    d0,d7
[00fd7472] 6700 0108                 beq       $00FD757C
[00fd7476] be7c 0002                 cmp.w     #$0002,d7
[00fd747a] 6606                      bne.s     $00FD7482
[00fd747c] 7601                      moveq.l   #1,d3
[00fd747e] 6000 00fc                 bra       $00FD757C
[00fd7482] 4a2e ffdc                 tst.b     -36(a6)
[00fd7486] 67d8                      beq.s     $00FD7460
[00fd7488] 600c                      bra.s     $00FD7496
[00fd748a] 486e ffdc                 pea.l     -36(a6)
[00fd748e] 486e ffec                 pea.l     -20(a6)
[00fd7492] f36c                      dc.w      $F36C ; xstrpcpy
[00fd7494] 508f                      addq.l    #8,a7
[00fd7496] 2e8c                      move.l    a4,(a7)
[00fd7498] f3b0                      dc.w      $F3B0 ; r_slash
[00fd749a] 2d40 ffd8                 move.l    d0,-40(a6)
[00fd749e] 2eae ffd8                 move.l    -40(a6),(a7)
[00fd74a2] 5297                      addq.l    #1,(a7)
[00fd74a4] 486e ffdc                 pea.l     -36(a6)
[00fd74a8] f36c                      dc.w      $F36C ; xstrpcpy
[00fd74aa] 588f                      addq.l    #4,a7
[00fd74ac] 2e8d                      move.l    a5,(a7)
[00fd74ae] 2f0c                      move.l    a4,-(a7)
[00fd74b0] f39c                      dc.w      $F39C ; streq
[00fd74b2] 588f                      addq.l    #4,a7
[00fd74b4] 4a40                      tst.w     d0
[00fd74b6] 6706                      beq.s     $00FD74BE
[00fd74b8] 7601                      moveq.l   #1,d3
[00fd74ba] 6000 00c0                 bra       $00FD757C
[00fd74be] 486e ffec                 pea.l     -20(a6)
[00fd74c2] 486e ffdc                 pea.l     -36(a6)
[00fd74c6] f39c                      dc.w      $F39C ; streq
[00fd74c8] 508f                      addq.l    #8,a7
[00fd74ca] 4a40                      tst.w     d0
[00fd74cc] 6610                      bne.s     $00FD74DE
[00fd74ce] 486e ffec                 pea.l     -20(a6)
[00fd74d2] 486e ffdc                 pea.l     -36(a6)
[00fd74d6] f36c                      dc.w      $F36C ; xstrpcpy
[00fd74d8] 508f                      addq.l    #8,a7
[00fd74da] 6000 ff5a                 bra       $00FD7436
[00fd74de] 3ebc 0001                 move.w    #1,(a7)
[00fd74e2] 2f0c                      move.l    a4,-(a7)
[00fd74e4] f40c                      dc.w      $F40C
[00fd74e6] 588f                      addq.l    #4,a7
[00fd74e8] 4a40                      tst.w     d0
[00fd74ea] 6700 0090                 beq       $00FD757C
[00fd74ee] 3eae 0016                 move.w    22(a6),(a7)
[00fd74f2] 0257 fffe                 andi.w    #$FFFE,(a7)
[00fd74f6] 2f0c                      move.l    a4,-(a7)
[00fd74f8] f370                      dc.w      $F370 ; dos_create
[00fd74fa] 588f                      addq.l    #4,a7
[00fd74fc] 3c00                      move.w    d0,d6
[00fd74fe] f374                      dc.w      $F374 ; dos_error
[00fd7500] 4a40                      tst.w     d0
[00fd7502] 6700 0078                 beq.w     $00FD757C
[00fd7506] 52ab 32aa                 addq.l    #1,12970(a3)
[00fd750a] 2eab 3116                 move.l    12566(a3),(a7)
[00fd750e] 2f04                      move.l    d4,-(a7)
[00fd7510] 3f06                      move.w    d6,-(a7)
[00fd7512] 3f3c 0040                 move.w    #$0040,-(a7)
[00fd7516] f0d8                      dc.w      $F0D8 ; trap
[00fd7518] 508f                      addq.l    #8,a7
[00fd751a] 2d40 fffc                 move.l    d0,-4(a6)
[00fd751e] f374                      dc.w      $F374 ; dos_error
[00fd7520] 4a40                      tst.w     d0
[00fd7522] 6754                      beq.s     $00FD7578
[00fd7524] b8ae fffc                 cmp.l     -4(a6),d4
[00fd7528] 6718                      beq.s     $00FD7542
[00fd752a] 4297                      clr.l     (a7)
[00fd752c] 2f3c 0001 0016            move.l    #$00010016,-(a7)
[00fd7532] f0dc                      dc.w      $F0DC ; fill_string
[00fd7534] 588f                      addq.l    #4,a7
[00fd7536] 3e86                      move.w    d6,(a7)
[00fd7538] f344                      dc.w      $F344 ; dos_close
[00fd753a] 2e8c                      move.l    a4,(a7)
[00fd753c] f37c                      dc.w      $F37C ; dos_delete
[00fd753e] f374                      dc.w      $F374 ; dos_error
[00fd7540] 603a                      bra.s     $00FD757C
[00fd7542] b8ab 311a                 cmp.l     12570(a3),d4
[00fd7546] 6c10                      bge.s     $00FD7558
[00fd7548] 2f2e 0018                 move.l    24(a6),-(a7)
[00fd754c] 3f06                      move.w    d6,-(a7)
[00fd754e] f420                      dc.w      $F420 ; dos_set
[00fd7550] 5c8f                      addq.l    #6,a7
[00fd7552] 7601                      moveq.l   #1,d3
[00fd7554] 6022                      bra.s     $00FD7578
[00fd7556] 601e                      bra.s     $00FD7576
[00fd7558] 2eab 3116                 move.l    12566(a3),(a7)
[00fd755c] 2f2b 311a                 move.l    12570(a3),-(a7)
[00fd7560] 3f05                      move.w    d5,-(a7)
[00fd7562] 3f3c 003f                 move.w    #$003F,-(a7)
[00fd7566] f0d8                      dc.w      $F0D8 ; trap
[00fd7568] 508f                      addq.l    #8,a7
[00fd756a] 2800                      move.l    d0,d4
[00fd756c] 4a84                      tst.l     d4
[00fd756e] 6708                      beq.s     $00FD7578
[00fd7570] f374                      dc.w      $F374 ; dos_error
[00fd7572] 4a40                      tst.w     d0
[00fd7574] 6702                      beq.s     $00FD7578
[00fd7576] 6092                      bra.s     $00FD750A
[00fd7578] 3e86                      move.w    d6,(a7)
[00fd757a] f344                      dc.w      $F344 ; dos_close
[00fd757c] 3e85                      move.w    d5,(a7)
[00fd757e] f344                      dc.w      $F344 ; dos_close
[00fd7580] 6018                      bra.s     $00FD759A
[00fd7582] b07c 0001                 cmp.w     #1,d0
[00fd7586] 6700 fdfe                 beq       $00FD7386
[00fd758a] b07c 0002                 cmp.w     #$0002,d0
[00fd758e] 6700 fe68                 beq       $00FD73F8
[00fd7592] b07c 0003                 cmp.w     #$0003,d0
[00fd7596] 6700 fe22                 beq       $00FD73BA
[00fd759a] 0c6e 0003 0008            cmpi.w    #$0003,8(a6)
[00fd75a0] 663c                      bne.s     $00FD75DE
[00fd75a2] b67c 0001                 cmp.w     #1,d3
[00fd75a6] 6636                      bne.s     $00FD75DE
[00fd75a8] be7c 0001                 cmp.w     #1,d7
[00fd75ac] 6630                      bne.s     $00FD75DE
[00fd75ae] 2e8c                      move.l    a4,(a7)
[00fd75b0] 2f0d                      move.l    a5,-(a7)
[00fd75b2] f39c                      dc.w      $F39C ; streq
[00fd75b4] 588f                      addq.l    #4,a7
[00fd75b6] 4a40                      tst.w     d0
[00fd75b8] 6624                      bne.s     $00FD75DE
[00fd75ba] 2e8d                      move.l    a5,(a7)
[00fd75bc] f37c                      dc.w      $F37C ; dos_delete
[00fd75be] 4a79 0000 742a            tst.w     DOS_ERR
[00fd75c4] 6718                      beq.s     $00FD75DE
[00fd75c6] 4243                      clr.w     d3
[00fd75c8] 0c79 ffdc 0000 6e20       cmpi.w    #$FFDC,DOS_AX
[00fd75d0] 660a                      bne.s     $00FD75DC
[00fd75d2] 7601                      moveq.l   #1,d3
[00fd75d4] 3ebc 0005                 move.w    #$0005,(a7)
[00fd75d8] f0e8                      dc.w      $F0E8 ; form_error
[00fd75da] 6002                      bra.s     $00FD75DE
[00fd75dc] f374                      dc.w      $F374 ; dos_error
[00fd75de] 2e8d                      move.l    a5,(a7)
[00fd75e0] f424                      dc.w      $F424 ; rep_all
[00fd75e2] 0c6e 0001 0008            cmpi.w    #1,8(a6)
[00fd75e8] 6704                      beq.s     $00FD75EE
[00fd75ea] 2e8c                      move.l    a4,(a7)
[00fd75ec] f424                      dc.w      $F424 ; rep_all
[00fd75ee] 3003                      move.w    d3,d0
[00fd75f0] fe3f                      dc.w      $FE3F ; movem.l (a7)+,d3-d7/a3-a5
#endif

	xdef xfd75f2
xfd75f2: ds.b 0
#if 0
[00fd75f2] 4e56 0000                 link      a6,#0
[00fd75f6] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd75fa] 2a6e 0008                 movea.l   8(a6),a5
[00fd75fe] 6002                      bra.s     $00FD7602
[00fd7600] 528d                      addq.l    #1,a5
[00fd7602] 0c15 002a                 cmpi.b    #$2A,(a5)
[00fd7606] 66f8                      bne.s     $00FD7600
[00fd7608] 2e8d                      move.l    a5,(a7)
[00fd760a] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd760e] f36c                      dc.w      $F36C ; xstrpcpy
[00fd7610] 588f                      addq.l    #4,a7
[00fd7612] 2e8d                      move.l    a5,(a7)
[00fd7614] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd761a] f404                      dc.w      $F404 ; xstrpcat
[00fd761c] 588f                      addq.l    #4,a7
[00fd761e] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd7620
xfd7620: ds.b 0
#if 0
[00fd7620] 4e56 ffe8                 link      a6,#$FFE8
[00fd7624] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fd7628] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd762e] 4257                      clr.w     (a7)
[00fd7630] f094                      dc.w      $F094 ; desk_wait
[00fd7632] 2e2d 3576                 move.l    13686(a5),d7
[00fd7636] 486e ffe8                 pea.l     -24(a6)
[00fd763a] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd763e] f428                      dc.w      $F428
[00fd7640] 508f                      addq.l    #8,a7
[00fd7642] 486e ffe8                 pea.l     -24(a6)
[00fd7646] 3f3c 0001                 move.w    #1,-(a7)
[00fd764a] 2f07                      move.l    d7,-(a7)
[00fd764c] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd764e] defc 000a                 adda.w    #$000A,a7
[00fd7652] 486e ffe8                 pea.l     -24(a6)
[00fd7656] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd765a] 2f07                      move.l    d7,-(a7)
[00fd765c] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd765e] defc 000a                 adda.w    #$000A,a7
[00fd7662] 2e87                      move.l    d7,(a7)
[00fd7664] f3cc                      dc.w      $F3CC
[00fd7666] 3b7c 0001 5e40            move.w    #1,24128(a5)
[00fd766c] 4257                      clr.w     (a7)
[00fd766e] 2f07                      move.l    d7,-(a7)
[00fd7670] f3d0                      dc.w      $F3D0 ; form_do
[00fd7672] 588f                      addq.l    #4,a7
[00fd7674] 3c00                      move.w    d0,d6
[00fd7676] cc7c 7fff                 and.w     #$7FFF,d6
[00fd767a] 2047                      movea.l   d7,a0
[00fd767c] 3206                      move.w    d6,d1
[00fd767e] c3fc 0018                 muls.w    #$0018,d1
[00fd7682] d1c1                      adda.l    d1,a0
[00fd7684] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fd768a] 4250                      clr.w     (a0)
[00fd768c] 4a6d 5e42                 tst.w     24130(a5)
[00fd7690] 675e                      beq.s     $00FD76F0
[00fd7692] 2e2d 3572                 move.l    13682(a5),d7
[00fd7696] bc7c 0005                 cmp.w     #$0005,d6
[00fd769a] 6610                      bne.s     $00FD76AC
[00fd769c] 2ebc 00fe b13c            move.l    #$00FEB13C,(a7)
[00fd76a2] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd76a6] 2f07                      move.l    d7,-(a7)
[00fd76a8] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd76aa] 5c8f                      addq.l    #6,a7
[00fd76ac] 2047                      movea.l   d7,a0
[00fd76ae] d1fc 0000 0082            adda.l    #$00000082,a0
[00fd76b4] 30bc 0001                 move.w    #1,(a0)
[00fd76b8] 486e fffe                 pea.l     -2(a6)
[00fd76bc] 486e fffc                 pea.l     -4(a6)
[00fd76c0] 486e fffa                 pea.l     -6(a6)
[00fd76c4] 486e fff8                 pea.l     -8(a6)
[00fd76c8] 2f07                      move.l    d7,-(a7)
[00fd76ca] f3a0                      dc.w      $F3A0 ; form_center
[00fd76cc] defc 0014                 adda.w    #$0014,a7
[00fd76d0] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd76d4] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd76d8] 3f3c 0008                 move.w    #$0008,-(a7)
[00fd76dc] 4267                      clr.w     -(a7)
[00fd76de] 2f07                      move.l    d7,-(a7)
[00fd76e0] f3a8                      dc.w      $F3A8 ; objc_draw
[00fd76e2] defc 0010                 adda.w    #$0010,a7
[00fd76e6] 2047                      movea.l   d7,a0
[00fd76e8] d1fc 0000 0082            adda.l    #$00000082,a0
[00fd76ee] 4250                      clr.w     (a0)
[00fd76f0] 3ebc 0001                 move.w    #1,(a7)
[00fd76f4] f094                      dc.w      $F094 ; desk_wait
[00fd76f6] bc7c 0003                 cmp.w     #$0003,d6
[00fd76fa] 6604                      bne.s     $00FD7700
[00fd76fc] 7c01                      moveq.l   #1,d6
[00fd76fe] 600e                      bra.s     $00FD770E
[00fd7700] bc7c 0004                 cmp.w     #$0004,d6
[00fd7704] 6604                      bne.s     $00FD770A
[00fd7706] 4240                      clr.w     d0
[00fd7708] 6002                      bra.s     $00FD770C
[00fd770a] 7002                      moveq.l   #2,d0
[00fd770c] 3c00                      move.w    d0,d6
[00fd770e] 486d 5e5e                 pea.l     24158(a5)
[00fd7712] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd7716] 2f2d 3576                 move.l    13686(a5),-(a7)
[00fd771a] f42c                      dc.w      $F42C ; fs_sget
[00fd771c] defc 000a                 adda.w    #$000A,a7
[00fd7720] 2eae 000c                 move.l    12(a6),(a7)
[00fd7724] 486d 5e5e                 pea.l     24158(a5)
[00fd7728] f430                      dc.w      $F430 ; unfmt_str
[00fd772a] 588f                      addq.l    #4,a7
[00fd772c] 3006                      move.w    d6,d0
[00fd772e] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfd7730
xfd7730: ds.b 0
#if 0
[00fd7730] 4e56 0000                 link      a6,#0
[00fd7734] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd7738] 2a6e 0008                 movea.l   8(a6),a5
[00fd773c] 286e 000c                 movea.l   12(a6),a4
[00fd7740] 2e8c                      move.l    a4,(a7)
[00fd7742] 2f0d                      move.l    a5,-(a7)
[00fd7744] f39c                      dc.w      $F39C ; streq
[00fd7746] 588f                      addq.l    #4,a7
[00fd7748] 4a40                      tst.w     d0
[00fd774a] 6624                      bne.s     $00FD7770
[00fd774c] 601e                      bra.s     $00FD776C
[00fd774e] 1015                      move.b    (a5),d0
[00fd7750] 4880                      ext.w     d0
[00fd7752] b014                      cmp.b     (a4),d0
[00fd7754] 670a                      beq.s     $00FD7760
[00fd7756] 0c15 002a                 cmpi.b    #$2A,(a5)
[00fd775a] 6714                      beq.s     $00FD7770
[00fd775c] 7001                      moveq.l   #1,d0
[00fd775e] 6012                      bra.s     $00FD7772
[00fd7760] 4a14                      tst.b     (a4)
[00fd7762] 6604                      bne.s     $00FD7768
[00fd7764] 7001                      moveq.l   #1,d0
[00fd7766] 600a                      bra.s     $00FD7772
[00fd7768] 528d                      addq.l    #1,a5
[00fd776a] 528c                      addq.l    #1,a4
[00fd776c] 4a15                      tst.b     (a5)
[00fd776e] 66de                      bne.s     $00FD774E
[00fd7770] 4240                      clr.w     d0
[00fd7772] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfd7774
xfd7774: ds.b 0
#if 0
[00fd7774] 4e56 0000                 link      a6,#0
[00fd7778] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd777c] 2a6e 000c                 movea.l   12(a6),a5
[00fd7780] 2879 0000 a788            movea.l   _thedesk,a4
[00fd7786] 206e 0008                 movea.l   8(a6),a0
[00fd778a] 1010                      move.b    (a0),d0
[00fd778c] 4880                      ext.w     d0
[00fd778e] 226e 0010                 movea.l   16(a6),a1
[00fd7792] 1211                      move.b    (a1),d1
[00fd7794] 4881                      ext.w     d1
[00fd7796] b041                      cmp.w     d1,d0
[00fd7798] 6706                      beq.s     $00FD77A0
[00fd779a] 7001                      moveq.l   #1,d0
[00fd779c] 6000 0074                 bra.w     $00FD7812
[00fd77a0] 606a                      bra.s     $00FD780C
[00fd77a2] 0c6d ffff 0020            cmpi.w    #$FFFF,32(a5)
[00fd77a8] 6760                      beq.s     $00FD780A
[00fd77aa] 204c                      movea.l   a4,a0
[00fd77ac] 322d 0020                 move.w    32(a5),d1
[00fd77b0] c3fc 0018                 muls.w    #$0018,d1
[00fd77b4] d1c1                      adda.l    d1,a0
[00fd77b6] 0828 0000 5e93            btst      #0,24211(a0)
[00fd77bc] 674c                      beq.s     $00FD780A
[00fd77be] 0c2d 0010 0009            cmpi.b    #$10,9(a5)
[00fd77c4] 6644                      bne.s     $00FD780A
[00fd77c6] 486c 3016                 pea.l     12310(a4)
[00fd77ca] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd77ce] f36c                      dc.w      $F36C ; xstrpcpy
[00fd77d0] 508f                      addq.l    #8,a7
[00fd77d2] 486d 0012                 pea.l     18(a5)
[00fd77d6] 486c 3016                 pea.l     12310(a4)
[00fd77da] f3dc                      dc.w      $F3DC
[00fd77dc] 508f                      addq.l    #8,a7
[00fd77de] 486c 3096                 pea.l     12438(a4)
[00fd77e2] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd77e6] f36c                      dc.w      $F36C ; xstrpcpy
[00fd77e8] 508f                      addq.l    #8,a7
[00fd77ea] 486c 3096                 pea.l     12438(a4)
[00fd77ee] 486c 3016                 pea.l     12310(a4)
[00fd77f2] f408                      dc.w      $F408
[00fd77f4] 508f                      addq.l    #8,a7
[00fd77f6] 4a40                      tst.w     d0
[00fd77f8] 6610                      bne.s     $00FD780A
[00fd77fa] 4297                      clr.l     (a7)
[00fd77fc] 2f3c 0001 0019            move.l    #$00010019,-(a7)
[00fd7802] f0dc                      dc.w      $F0DC ; fill_string
[00fd7804] 588f                      addq.l    #4,a7
[00fd7806] 4240                      clr.w     d0
[00fd7808] 6008                      bra.s     $00FD7812
[00fd780a] 2a55                      movea.l   (a5),a5
[00fd780c] 200d                      move.l    a5,d0
[00fd780e] 6692                      bne.s     $00FD77A2
[00fd7810] 7001                      moveq.l   #1,d0
[00fd7812] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfd7814
xfd7814: ds.b 0
#if 0
[00fd7814] 4e56 ffd8                 link      a6,#$FFD8
[00fd7818] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd781c] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd7822] 2ebc 0001 0002            move.l    #$00010002,(a7)
[00fd7828] f0f0                      dc.w      $F0F0 ; trp13
[00fd782a] 4a80                      tst.l     d0
[00fd782c] 6728                      beq.s     $00FD7856
[00fd782e] 2ebc 0002 0002            move.l    #$00020002,(a7)
[00fd7834] f0f0                      dc.w      $F0F0 ; trp13
[00fd7836] b0bc 0061 0000            cmp.l     #$00610000,d0
[00fd783c] 6618                      bne.s     $00FD7856
[00fd783e] 4297                      clr.l     (a7)
[00fd7840] 2f3c 0001 0022            move.l    #$00010022,-(a7)
[00fd7846] f0dc                      dc.w      $F0DC ; fill_string
[00fd7848] 588f                      addq.l    #4,a7
[00fd784a] b07c 0001                 cmp.w     #1,d0
[00fd784e] 6606                      bne.s     $00FD7856
[00fd7850] 4240                      clr.w     d0
[00fd7852] 6000 00c8                 bra       $00FD791C
[00fd7856] 4a6d 5e42                 tst.w     24130(a5)
[00fd785a] 6700 00be                 beq       $00FD791A
[00fd785e] 2e2d 3572                 move.l    13682(a5),d7
[00fd7862] 486e ffd8                 pea.l     -40(a6)
[00fd7866] 486e ffe8                 pea.l     -24(a6)
[00fd786a] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd786e] f434                      dc.w      $F434
[00fd7870] defc 000c                 adda.w    #$000C,a7
[00fd7874] 486e ffe8                 pea.l     -24(a6)
[00fd7878] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd787c] 2f07                      move.l    d7,-(a7)
[00fd787e] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd7880] defc 000a                 adda.w    #$000A,a7
[00fd7884] 486e ffd8                 pea.l     -40(a6)
[00fd7888] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd788c] 2f07                      move.l    d7,-(a7)
[00fd788e] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd7890] defc 000a                 adda.w    #$000A,a7
[00fd7894] 4a6e 000c                 tst.w     12(a6)
[00fd7898] 672c                      beq.s     $00FD78C6
[00fd789a] 2d6d 32aa fffc            move.l    12970(a5),-4(a6)
[00fd78a0] 4257                      clr.w     (a7)
[00fd78a2] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd78a6] 2f07                      move.l    d7,-(a7)
[00fd78a8] 486d 5e30                 pea.l     24112(a5)
[00fd78ac] 486e fffc                 pea.l     -4(a6)
[00fd78b0] f3c4                      dc.w      $F3C4
[00fd78b2] defc 000e                 adda.w    #$000E,a7
[00fd78b6] 3ebc 0002                 move.w    #$0002,(a7)
[00fd78ba] 2f07                      move.l    d7,-(a7)
[00fd78bc] f438                      dc.w      $F438
[00fd78be] 588f                      addq.l    #4,a7
[00fd78c0] 53ad 32aa                 subq.l    #1,12970(a5)
[00fd78c4] 6040                      bra.s     $00FD7906
[00fd78c6] 2ebc 00fe b13d            move.l    #$00FEB13D,(a7)
[00fd78cc] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd78d0] 2f07                      move.l    d7,-(a7)
[00fd78d2] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd78d4] 5c8f                      addq.l    #6,a7
[00fd78d6] 4aad 32ae                 tst.l     12974(a5)
[00fd78da] 6704                      beq.s     $00FD78E0
[00fd78dc] 53ad 32ae                 subq.l    #1,12974(a5)
[00fd78e0] 2d6d 32ae fff8            move.l    12974(a5),-8(a6)
[00fd78e6] 4257                      clr.w     (a7)
[00fd78e8] 3f3c 0001                 move.w    #1,-(a7)
[00fd78ec] 2f07                      move.l    d7,-(a7)
[00fd78ee] 486d 5e34                 pea.l     24116(a5)
[00fd78f2] 486e fff8                 pea.l     -8(a6)
[00fd78f6] f3c4                      dc.w      $F3C4
[00fd78f8] defc 000e                 adda.w    #$000E,a7
[00fd78fc] 3ebc 0001                 move.w    #1,(a7)
[00fd7900] 2f07                      move.l    d7,-(a7)
[00fd7902] f438                      dc.w      $F438
[00fd7904] 588f                      addq.l    #4,a7
[00fd7906] 3ebc 0004                 move.w    #$0004,(a7)
[00fd790a] 2f07                      move.l    d7,-(a7)
[00fd790c] f438                      dc.w      $F438
[00fd790e] 588f                      addq.l    #4,a7
[00fd7910] 3ebc 0003                 move.w    #$0003,(a7)
[00fd7914] 2f07                      move.l    d7,-(a7)
[00fd7916] f438                      dc.w      $F438
[00fd7918] 588f                      addq.l    #4,a7
[00fd791a] 7001                      moveq.l   #1,d0
[00fd791c] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd791e
xfd791e: ds.b 0
#if 0
[00fd791e] 4e56 0000                 link      a6,#0
[00fd7922] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd7926] 2a6e 0008                 movea.l   8(a6),a5
[00fd792a] 2eae 000c                 move.l    12(a6),(a7)
[00fd792e] 2f0d                      move.l    a5,-(a7)
[00fd7930] f428                      dc.w      $F428
[00fd7932] 588f                      addq.l    #4,a7
[00fd7934] 2e8d                      move.l    a5,(a7)
[00fd7936] f3b0                      dc.w      $F3B0 ; r_slash
[00fd7938] 2a40                      movea.l   d0,a5
[00fd793a] 0c2d 003a ffff            cmpi.b    #$3A,-1(a5)
[00fd7940] 6608                      bne.s     $00FD794A
[00fd7942] 206e 0010                 movea.l   16(a6),a0
[00fd7946] 4210                      clr.b     (a0)
[00fd7948] 6010                      bra.s     $00FD795A
[00fd794a] 4215                      clr.b     (a5)
[00fd794c] 2eae 0010                 move.l    16(a6),(a7)
[00fd7950] 2f0d                      move.l    a5,-(a7)
[00fd7952] f428                      dc.w      $F428
[00fd7954] 588f                      addq.l    #4,a7
[00fd7956] 1abc 005c                 move.b    #$5C,(a5)
[00fd795a] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd795c
xfd795c: ds.b 0
#if 0
[00fd795c] 4e56 0000                 link      a6,#0
[00fd7960] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd7964] 2a6e 0008                 movea.l   8(a6),a5
[00fd7968] 2e8d                      move.l    a5,(a7)
[00fd796a] f3b0                      dc.w      $F3B0 ; r_slash
[00fd796c] 2a40                      movea.l   d0,a5
[00fd796e] 538d                      subq.l    #1,a5
[00fd7970] 6002                      bra.s     $00FD7974
[00fd7972] 538d                      subq.l    #1,a5
[00fd7974] 0c15 005c                 cmpi.b    #$5C,(a5)
[00fd7978] 66f8                      bne.s     $00FD7972
[00fd797a] 2e8d                      move.l    a5,(a7)
[00fd797c] 2f3c 00fe b130            move.l    #$00FEB130,-(a7)
[00fd7982] f36c                      dc.w      $F36C ; xstrpcpy
[00fd7984] 588f                      addq.l    #4,a7
[00fd7986] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif
