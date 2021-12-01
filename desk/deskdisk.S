	xdef _fc_start
_fc_start: ds.b 0
#if 0
[00fe6a5a] 4e56 fff4                 link      a6,#$FFF4
[00fe6a5e] 48e7 0f04                 movem.l   d4-d7/a5,-(a7)
[00fe6a62] 2079 0000 a788            movea.l   _thedesk,a0
[00fe6a68] 2a28 3582                 move.l    13698(a0),d5
[00fe6a6c] 2a45                      movea.l   d5,a5
[00fe6a6e] dbfc 0000 009c            adda.l    #$0000009C,a5
[00fe6a74] 2045                      movea.l   d5,a0
[00fe6a76] d1fc 0000 01f4            adda.l    #$000001F4,a0
[00fe6a7c] 3c10                      move.w    (a0),d6
[00fe6a7e] 3006                      move.w    d6,d0
[00fe6a80] 48c0                      ext.l     d0
[00fe6a82] 81fc 0050                 divs.w    #$0050,d0
[00fe6a86] 33c0 0000 6be2            move.w    d0,$00006BE2
[00fe6a8c] 3c39 0000 6be2            move.w    $00006BE2,d6
[00fe6a92] 3006                      move.w    d6,d0
[00fe6a94] c1fc 0050                 muls.w    #$0050,d0
[00fe6a98] 3c00                      move.w    d0,d6
[00fe6a9a] 33c0 0000 6be4            move.w    d0,$00006BE4
[00fe6aa0] 2045                      movea.l   d5,a0
[00fe6aa2] d1fc 0000 01f4            adda.l    #$000001F4,a0
[00fe6aa8] 3086                      move.w    d6,(a0)
[00fe6aaa] 2045                      movea.l   d5,a0
[00fe6aac] d1fc 0000 0224            adda.l    #$00000224,a0
[00fe6ab2] 3086                      move.w    d6,(a0)
[00fe6ab4] 426e fffe                 clr.w     -2(a6)
[00fe6ab8] 6022                      bra.s     $00FE6ADC
[00fe6aba] 2045                      movea.l   d5,a0
[00fe6abc] 326e fffe                 movea.w   -2(a6),a1
[00fe6ac0] d3c9                      adda.l    a1,a1
[00fe6ac2] d3fc 00fe b9c2            adda.l    #$00FEB9C2,a1
[00fe6ac8] 3211                      move.w    (a1),d1
[00fe6aca] c3fc 0018                 muls.w    #$0018,d1
[00fe6ace] d1c1                      adda.l    d1,a0
[00fe6ad0] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fe6ad6] 4250                      clr.w     (a0)
[00fe6ad8] 526e fffe                 addq.w    #1,-2(a6)
[00fe6adc] 0c6e 0007 fffe            cmpi.w    #$0007,-2(a6)
[00fe6ae2] 6dd6                      blt.s     $00FE6ABA
[00fe6ae4] 2ebc 00fe ba1a            move.l    #Nostr,(a7)
[00fe6aea] 3f3c 000d                 move.w    #$000D,-(a7)
[00fe6aee] 2f05                      move.l    d5,-(a7)
[00fe6af0] f3c8                      dc.w      $F3C8 ; inf_sset
[00fe6af2] 5c8f                      addq.l    #6,a7
[00fe6af4] 2045                      movea.l   d5,a0
[00fe6af6] d1fc 0000 00e0            adda.l    #$000000E0,a0
[00fe6afc] 30bc 0080                 move.w    #$0080,(a0)
[00fe6b00] 2045                      movea.l   d5,a0
[00fe6b02] d1fc 0000 0038            adda.l    #$00000038,a0
[00fe6b08] 30bc 0080                 move.w    #$0080,(a0)
[00fe6b0c] 206e 0008                 movea.l   8(a6),a0
[00fe6b10] 0c10 0041                 cmpi.b    #$41,(a0)
[00fe6b14] 6704                      beq.s     $00FE6B1A
[00fe6b16] 4240                      clr.w     d0
[00fe6b18] 6002                      bra.s     $00FE6B1C
[00fe6b1a] 7001                      moveq.l   #1,d0
[00fe6b1c] 3e00                      move.w    d0,d7
[00fe6b1e] 0c6e 00fb 000c            cmpi.w    #$00FB,12(a6)
[00fe6b24] 6654                      bne.s     $00FE6B7A
[00fe6b26] 2045                      movea.l   d5,a0
[00fe6b28] 4a47                      tst.w     d7
[00fe6b2a] 6704                      beq.s     $00FE6B30
[00fe6b2c] 720c                      moveq.l   #12,d1
[00fe6b2e] 6002                      bra.s     $00FE6B32
[00fe6b30] 720b                      moveq.l   #11,d1
[00fe6b32] c3fc 0018                 muls.w    #$0018,d1
[00fe6b36] d1c1                      adda.l    d1,a0
[00fe6b38] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fe6b3e] 30bc 0001                 move.w    #1,(a0)
[00fe6b42] 2045                      movea.l   d5,a0
[00fe6b44] 4a47                      tst.w     d7
[00fe6b46] 6704                      beq.s     $00FE6B4C
[00fe6b48] 7204                      moveq.l   #4,d1
[00fe6b4a] 6002                      bra.s     $00FE6B4E
[00fe6b4c] 7205                      moveq.l   #5,d1
[00fe6b4e] c3fc 0018                 muls.w    #$0018,d1
[00fe6b52] d1c1                      adda.l    d1,a0
[00fe6b54] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fe6b5a] 30bc 0001                 move.w    #1,(a0)
[00fe6b5e] 4a47                      tst.w     d7
[00fe6b60] 6704                      beq.s     $00FE6B66
[00fe6b62] 7042                      moveq.l   #66,d0
[00fe6b64] 6002                      bra.s     $00FE6B68
[00fe6b66] 7041                      moveq.l   #65,d0
[00fe6b68] 1a80                      move.b    d0,(a5)
[00fe6b6a] 2045                      movea.l   d5,a0
[00fe6b6c] d1fc 0000 00b2            adda.l    #$000000B2,a0
[00fe6b72] 30bc 0001                 move.w    #1,(a0)
[00fe6b76] 7e07                      moveq.l   #7,d7
[00fe6b78] 6052                      bra.s     $00FE6BCC
[00fe6b7a] 2045                      movea.l   d5,a0
[00fe6b7c] 4a47                      tst.w     d7
[00fe6b7e] 6704                      beq.s     $00FE6B84
[00fe6b80] 7205                      moveq.l   #5,d1
[00fe6b82] 6002                      bra.s     $00FE6B86
[00fe6b84] 7204                      moveq.l   #4,d1
[00fe6b86] c3fc 0018                 muls.w    #$0018,d1
[00fe6b8a] d1c1                      adda.l    d1,a0
[00fe6b8c] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fe6b92] 30bc 0001                 move.w    #1,(a0)
[00fe6b96] 4a47                      tst.w     d7
[00fe6b98] 6704                      beq.s     $00FE6B9E
[00fe6b9a] 7041                      moveq.l   #65,d0
[00fe6b9c] 6002                      bra.s     $00FE6BA0
[00fe6b9e] 7042                      moveq.l   #66,d0
[00fe6ba0] 1a80                      move.b    d0,(a5)
[00fe6ba2] 2045                      movea.l   d5,a0
[00fe6ba4] 4a47                      tst.w     d7
[00fe6ba6] 6704                      beq.s     $00FE6BAC
[00fe6ba8] 720b                      moveq.l   #11,d1
[00fe6baa] 6002                      bra.s     $00FE6BAE
[00fe6bac] 720c                      moveq.l   #12,d1
[00fe6bae] c3fc 0018                 muls.w    #$0018,d1
[00fe6bb2] d1c1                      adda.l    d1,a0
[00fe6bb4] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fe6bba] 30bc 0001                 move.w    #1,(a0)
[00fe6bbe] 2045                      movea.l   d5,a0
[00fe6bc0] d1fc 0000 01ba            adda.l    #$000001BA,a0
[00fe6bc6] 30bc 0001                 move.w    #1,(a0)
[00fe6bca] 7e12                      moveq.l   #18,d7
[00fe6bcc] 2e85                      move.l    d5,(a7)
[00fe6bce] f3cc                      dc.w      $F3CC
[00fe6bd0] 6000 0148                 bra       $00FE6D1A
[00fe6bd4] 3007                      move.w    d7,d0
[00fe6bd6] 6000 011c                 bra       $00FE6CF4
[00fe6bda] 3ebc 0002                 move.w    #$0002,(a7)
[00fe6bde] 2f05                      move.l    d5,-(a7)
[00fe6be0] f43c                      dc.w      $F43C
[00fe6be2] 588f                      addq.l    #4,a7
[00fe6be4] 2045                      movea.l   d5,a0
[00fe6be6] d1fc 0000 0038            adda.l    #$00000038,a0
[00fe6bec] 30bc 0080                 move.w    #$0080,(a0)
[00fe6bf0] 2045                      movea.l   d5,a0
[00fe6bf2] d1fc 0000 00e0            adda.l    #$000000E0,a0
[00fe6bf8] 4250                      clr.w     (a0)
[00fe6bfa] 3ebc 0009                 move.w    #$0009,(a7)
[00fe6bfe] 2f05                      move.l    d5,-(a7)
[00fe6c00] f440                      dc.w      $F440
[00fe6c02] 588f                      addq.l    #4,a7
[00fe6c04] 426e fffc                 clr.w     -4(a6)
[00fe6c08] 6000 0100                 bra       $00FE6D0A
[00fe6c0c] 3ebc 0009                 move.w    #$0009,(a7)
[00fe6c10] 2f05                      move.l    d5,-(a7)
[00fe6c12] f43c                      dc.w      $F43C
[00fe6c14] 588f                      addq.l    #4,a7
[00fe6c16] 2045                      movea.l   d5,a0
[00fe6c18] d1fc 0000 00e0            adda.l    #$000000E0,a0
[00fe6c1e] 30bc 0080                 move.w    #$0080,(a0)
[00fe6c22] 2045                      movea.l   d5,a0
[00fe6c24] d1fc 0000 0038            adda.l    #$00000038,a0
[00fe6c2a] 4250                      clr.w     (a0)
[00fe6c2c] 3ebc 0002                 move.w    #$0002,(a7)
[00fe6c30] 2f05                      move.l    d5,-(a7)
[00fe6c32] f440                      dc.w      $F440
[00fe6c34] 588f                      addq.l    #4,a7
[00fe6c36] 3d7c ffff fffc            move.w    #$FFFF,-4(a6)
[00fe6c3c] 6000 00cc                 bra       $00FE6D0A
[00fe6c40] be7c 0004                 cmp.w     #$0004,d7
[00fe6c44] 6604                      bne.s     $00FE6C4A
[00fe6c46] 7042                      moveq.l   #66,d0
[00fe6c48] 6002                      bra.s     $00FE6C4C
[00fe6c4a] 7041                      moveq.l   #65,d0
[00fe6c4c] 1a80                      move.b    d0,(a5)
[00fe6c4e] 3ebc 0006                 move.w    #$0006,(a7)
[00fe6c52] 2f05                      move.l    d5,-(a7)
[00fe6c54] f43c                      dc.w      $F43C
[00fe6c56] 588f                      addq.l    #4,a7
[00fe6c58] 6000 00b0                 bra       $00FE6D0A
[00fe6c5c] 2e85                      move.l    d5,(a7)
[00fe6c5e] f3ec                      dc.w      $F3EC ; do_finish
[00fe6c60] 4257                      clr.w     (a7)
[00fe6c62] 2f3c 00fe ba1b            move.l    #$00FEBA1B,-(a7)
[00fe6c68] f380                      dc.w      $F380 ; up_allwin
[00fe6c6a] 588f                      addq.l    #4,a7
[00fe6c6c] 4257                      clr.w     (a7)
[00fe6c6e] 2f3c 00fe ba1d            move.l    #$00FEBA1D,-(a7)
[00fe6c74] f380                      dc.w      $F380 ; up_allwin
[00fe6c76] 588f                      addq.l    #4,a7
[00fe6c78] 4257                      clr.w     (a7)
[00fe6c7a] f444                      dc.w      $F444
[00fe6c7c] 6000 00a0                 bra       $00FE6D1E
[00fe6c80] 3ebc 0001                 move.w    #1,(a7)
[00fe6c84] f094                      dc.w      $F094 ; desk_wait
[00fe6c86] 2045                      movea.l   d5,a0
[00fe6c88] d1fc 0000 01f4            adda.l    #$000001F4,a0
[00fe6c8e] 4250                      clr.w     (a0)
[00fe6c90] 2045                      movea.l   d5,a0
[00fe6c92] d1fc 0000 0224            adda.l    #$00000224,a0
[00fe6c98] 4250                      clr.w     (a0)
[00fe6c9a] 2045                      movea.l   d5,a0
[00fe6c9c] d1fc 0000 01bb            adda.l    #$000001BB,a0
[00fe6ca2] 0810 0000                 btst      #0,(a0)
[00fe6ca6] 6706                      beq.s     $00FE6CAE
[00fe6ca8] 2e85                      move.l    d5,(a7)
[00fe6caa] f448                      dc.w      $F448 ; fc_format
[00fe6cac] 6004                      bra.s     $00FE6CB2
[00fe6cae] 2e85                      move.l    d5,(a7)
[00fe6cb0] f44c                      dc.w      $F44C ; fc_copy
[00fe6cb2] 2045                      movea.l   d5,a0
[00fe6cb4] d1fc 0000 01f4            adda.l    #$000001F4,a0
[00fe6cba] 3086                      move.w    d6,(a0)
[00fe6cbc] 2045                      movea.l   d5,a0
[00fe6cbe] d1fc 0000 0224            adda.l    #$00000224,a0
[00fe6cc4] 3086                      move.w    d6,(a0)
[00fe6cc6] 2045                      movea.l   d5,a0
[00fe6cc8] d1fc 0000 0232            adda.l    #$00000232,a0
[00fe6cce] 4250                      clr.w     (a0)
[00fe6cd0] 3ebc 0014                 move.w    #$0014,(a7)
[00fe6cd4] 2f05                      move.l    d5,-(a7)
[00fe6cd6] f43c                      dc.w      $F43C
[00fe6cd8] 588f                      addq.l    #4,a7
[00fe6cda] 3ebc 0016                 move.w    #$0016,(a7)
[00fe6cde] 2f05                      move.l    d5,-(a7)
[00fe6ce0] f43c                      dc.w      $F43C
[00fe6ce2] 588f                      addq.l    #4,a7
[00fe6ce4] 3ebc 0017                 move.w    #$0017,(a7)
[00fe6ce8] 2f05                      move.l    d5,-(a7)
[00fe6cea] f43c                      dc.w      $F43C
[00fe6cec] 588f                      addq.l    #4,a7
[00fe6cee] 4257                      clr.w     (a7)
[00fe6cf0] f094                      dc.w      $F094 ; desk_wait
[00fe6cf2] 6016                      bra.s     $00FE6D0A
[00fe6cf4] 48c0                      ext.l     d0
[00fe6cf6] 207c 00fe b9e2            movea.l   #$00FEB9E2,a0
[00fe6cfc] 7206                      moveq.l   #6,d1
[00fe6cfe] b098                      cmp.l     (a0)+,d0
[00fe6d00] 57c9 fffc                 dbeq      d1,$00FE6CFE
[00fe6d04] 2068 0018                 movea.l   24(a0),a0
[00fe6d08] 4ed0                      jmp       (a0)
[00fe6d0a] 3eae fffc                 move.w    -4(a6),(a7)
[00fe6d0e] 2f05                      move.l    d5,-(a7)
[00fe6d10] f3d0                      dc.w      $F3D0 ; form_do
[00fe6d12] 588f                      addq.l    #4,a7
[00fe6d14] 3e00                      move.w    d0,d7
[00fe6d16] ce7c 7fff                 and.w     #$7FFF,d7
[00fe6d1a] 6000 feb8                 bra       $00FE6BD4
[00fe6d1e] f839                      dc.w      $F839 ; movem.l (a7)+,d5-d7/a5
#endif

	xdef _fc_format
_fc_format: ds.b 0
#if 0
[00fe6d20] 4e56 ff9c                 link      a6,#$FF9C
[00fe6d24] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fe6d28] 2ebc 0000 2000            move.l    #$00002000,(a7)
[00fe6d2e] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fe6d30] 2a40                      movea.l   d0,a5
[00fe6d32] 200d                      move.l    a5,d0
[00fe6d34] 660a                      bne.s     $00FE6D40
[00fe6d36] 3ebc 001b                 move.w    #$001B,(a7)
[00fe6d3a] f3bc                      dc.w      $F3BC ; do1_alert
[00fe6d3c] 6000 03e6                 bra       $00FE7124
[00fe6d40] 264d                      movea.l   a5,a3
[00fe6d42] 2ebc 0000 2000            move.l    #$00002000,(a7)
[00fe6d48] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fe6d4a] 2840                      movea.l   d0,a4
[00fe6d4c] 200c                      move.l    a4,d0
[00fe6d4e] 6606                      bne.s     $00FE6D56
[00fe6d50] 2e8d                      move.l    a5,(a7)
[00fe6d52] f3f0                      dc.w      $F3F0 ; dos_free
[00fe6d54] 60e0                      bra.s     $00FE6D36
[00fe6d56] 3d7c 0050 ffe6            move.w    #$0050,-26(a6)
[00fe6d5c] 3d7c 0002 ffe4            move.w    #$0002,-28(a6)
[00fe6d62] 3d7c 0003 ffec            move.w    #$0003,-20(a6)
[00fe6d68] 206e 0008                 movea.l   8(a6),a0
[00fe6d6c] d1fc 0000 018b            adda.l    #$0000018B,a0
[00fe6d72] 0810 0000                 btst      #0,(a0)
[00fe6d76] 670c                      beq.s     $00FE6D84
[00fe6d78] 3d7c 0001 ffe4            move.w    #1,-28(a6)
[00fe6d7e] 3d7c 0002 ffec            move.w    #$0002,-20(a6)
[00fe6d84] 206e 0008                 movea.l   8(a6),a0
[00fe6d88] d1fc 0000 0113            adda.l    #$00000113,a0
[00fe6d8e] 0810 0000                 btst      #0,(a0)
[00fe6d92] 6704                      beq.s     $00FE6D98
[00fe6d94] 4240                      clr.w     d0
[00fe6d96] 6002                      bra.s     $00FE6D9A
[00fe6d98] 7001                      moveq.l   #1,d0
[00fe6d9a] 3d40 fff2                 move.w    d0,-14(a6)
[00fe6d9e] 4246                      clr.w     d6
[00fe6da0] 4247                      clr.w     d7
[00fe6da2] 4245                      clr.w     d5
[00fe6da4] 6018                      bra.s     $00FE6DBE
[00fe6da6] 204e                      movea.l   a6,a0
[00fe6da8] 3245                      movea.w   d5,a1
[00fe6daa] d3c9                      adda.l    a1,a1
[00fe6dac] d1c9                      adda.l    a1,a0
[00fe6dae] 3245                      movea.w   d5,a1
[00fe6db0] d3c9                      adda.l    a1,a1
[00fe6db2] d3fc 00fe b9d0            adda.l    #$00FEB9D0,a1
[00fe6db8] 3151 ffba                 move.w    (a1),-70(a0)
[00fe6dbc] 5245                      addq.w    #1,d5
[00fe6dbe] ba7c 0009                 cmp.w     #$0009,d5
[00fe6dc2] 6de2                      blt.s     $00FE6DA6
[00fe6dc4] 0c6e 0001 ffe4            cmpi.w    #1,-28(a6)
[00fe6dca] 6604                      bne.s     $00FE6DD0
[00fe6dcc] 7003                      moveq.l   #3,d0
[00fe6dce] 6002                      bra.s     $00FE6DD2
[00fe6dd0] 7002                      moveq.l   #2,d0
[00fe6dd2] 3d40 ffb8                 move.w    d0,-72(a6)
[00fe6dd6] 4244                      clr.w     d4
[00fe6dd8] 6000 0148                 bra       $00FE6F22
[00fe6ddc] 426e ffea                 clr.w     -22(a6)
[00fe6de0] 6000 0122                 bra       $00FE6F04
[00fe6de4] 3a2e ffb8                 move.w    -72(a6),d5
[00fe6de8] 601c                      bra.s     $00FE6E06
[00fe6dea] 204e                      movea.l   a6,a0
[00fe6dec] 3245                      movea.w   d5,a1
[00fe6dee] d3c9                      adda.l    a1,a1
[00fe6df0] d1c9                      adda.l    a1,a0
[00fe6df2] 224e                      movea.l   a6,a1
[00fe6df4] 3445                      movea.w   d5,a2
[00fe6df6] 94ee ffb8                 suba.w    -72(a6),a2
[00fe6dfa] d5ca                      adda.l    a2,a2
[00fe6dfc] d3ca                      adda.l    a2,a1
[00fe6dfe] 3169 ffba ffcc            move.w    -70(a1),-52(a0)
[00fe6e04] 5245                      addq.w    #1,d5
[00fe6e06] ba7c 0009                 cmp.w     #$0009,d5
[00fe6e0a] 6dde                      blt.s     $00FE6DEA
[00fe6e0c] 4245                      clr.w     d5
[00fe6e0e] 6020                      bra.s     $00FE6E30
[00fe6e10] 7c09                      moveq.l   #9,d6
[00fe6e12] 9c6e ffb8                 sub.w     -72(a6),d6
[00fe6e16] 204e                      movea.l   a6,a0
[00fe6e18] 3245                      movea.w   d5,a1
[00fe6e1a] d3c9                      adda.l    a1,a1
[00fe6e1c] d1c9                      adda.l    a1,a0
[00fe6e1e] 224e                      movea.l   a6,a1
[00fe6e20] 3446                      movea.w   d6,a2
[00fe6e22] d4c5                      adda.w    d5,a2
[00fe6e24] d5ca                      adda.l    a2,a2
[00fe6e26] d3ca                      adda.l    a2,a1
[00fe6e28] 3169 ffba ffcc            move.w    -70(a1),-52(a0)
[00fe6e2e] 5245                      addq.w    #1,d5
[00fe6e30] ba6e ffb8                 cmp.w     -72(a6),d5
[00fe6e34] 6dda                      blt.s     $00FE6E10
[00fe6e36] 4245                      clr.w     d5
[00fe6e38] 6018                      bra.s     $00FE6E52
[00fe6e3a] 204e                      movea.l   a6,a0
[00fe6e3c] 3245                      movea.w   d5,a1
[00fe6e3e] d3c9                      adda.l    a1,a1
[00fe6e40] d1c9                      adda.l    a1,a0
[00fe6e42] 224e                      movea.l   a6,a1
[00fe6e44] 3445                      movea.w   d5,a2
[00fe6e46] d5ca                      adda.l    a2,a2
[00fe6e48] d3ca                      adda.l    a2,a1
[00fe6e4a] 3169 ffcc ffba            move.w    -52(a1),-70(a0)
[00fe6e50] 5245                      addq.w    #1,d5
[00fe6e52] ba7c 0009                 cmp.w     #$0009,d5
[00fe6e56] 6de2                      blt.s     $00FE6E3A
[00fe6e58] 3ebc e5e5                 move.w    #$E5E5,(a7)
[00fe6e5c] 2f3c 8765 4321            move.l    #$87654321,-(a7)
[00fe6e62] 3f3c ffff                 move.w    #$FFFF,-(a7)
[00fe6e66] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fe6e6a] 3f04                      move.w    d4,-(a7)
[00fe6e6c] 3f3c 0009                 move.w    #$0009,-(a7)
[00fe6e70] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fe6e74] 486e ffcc                 pea.l     -52(a6)
[00fe6e78] 2f0d                      move.l    a5,-(a7)
[00fe6e7a] 3f3c 000a                 move.w    #$000A,-(a7)
[00fe6e7e] f450                      dc.w      $F450 ; trp14int
[00fe6e80] defc 0018                 adda.w    #$0018,a7
[00fe6e84] 3c00                      move.w    d0,d6
[00fe6e86] bc7c fff0                 cmp.w     #$FFF0,d6
[00fe6e8a] 6662                      bne.s     $00FE6EEE
[00fe6e8c] b87c 0002                 cmp.w     #$0002,d4
[00fe6e90] 6d0c                      blt.s     $00FE6E9E
[00fe6e92] 3007                      move.w    d7,d0
[00fe6e94] d07c 0009                 add.w     #$0009,d0
[00fe6e98] b07c 0010                 cmp.w     #$0010,d0
[00fe6e9c] 6d12                      blt.s     $00FE6EB0
[00fe6e9e] 3ebc 001c                 move.w    #$001C,(a7)
[00fe6ea2] f3bc                      dc.w      $F3BC ; do1_alert
[00fe6ea4] b07c 0001                 cmp.w     #1,d0
[00fe6ea8] 67f4                      beq.s     $00FE6E9E
[00fe6eaa] 7c01                      moveq.l   #1,d6
[00fe6eac] 6066                      bra.s     $00FE6F14
[00fe6eae] 603e                      bra.s     $00FE6EEE
[00fe6eb0] 4245                      clr.w     d5
[00fe6eb2] 6030                      bra.s     $00FE6EE4
[00fe6eb4] 3004                      move.w    d4,d0
[00fe6eb6] c1ee ffe4                 muls.w    -28(a6),d0
[00fe6eba] c1fc 0009                 muls.w    #$0009,d0
[00fe6ebe] 3245                      movea.w   d5,a1
[00fe6ec0] d3c9                      adda.l    a1,a1
[00fe6ec2] 3233 9800                 move.w    0(a3,a1.l),d1
[00fe6ec6] d041                      add.w     d1,d0
[00fe6ec8] 322e ffea                 move.w    -22(a6),d1
[00fe6ecc] c3fc 0009                 muls.w    #$0009,d1
[00fe6ed0] d041                      add.w     d1,d0
[00fe6ed2] 5340                      subq.w    #1,d0
[00fe6ed4] 224c                      movea.l   a4,a1
[00fe6ed6] 3447                      movea.w   d7,a2
[00fe6ed8] d5ca                      adda.l    a2,a2
[00fe6eda] d3ca                      adda.l    a2,a1
[00fe6edc] 3280                      move.w    d0,(a1)
[00fe6ede] 4246                      clr.w     d6
[00fe6ee0] 5245                      addq.w    #1,d5
[00fe6ee2] 5247                      addq.w    #1,d7
[00fe6ee4] 3045                      movea.w   d5,a0
[00fe6ee6] d1c8                      adda.l    a0,a0
[00fe6ee8] 4a73 8800                 tst.w     0(a3,a0.l)
[00fe6eec] 66c6                      bne.s     $00FE6EB4
[00fe6eee] 4a46                      tst.w     d6
[00fe6ef0] 670e                      beq.s     $00FE6F00
[00fe6ef2] 3ebc 001c                 move.w    #$001C,(a7)
[00fe6ef6] f3bc                      dc.w      $F3BC ; do1_alert
[00fe6ef8] b07c 0001                 cmp.w     #1,d0
[00fe6efc] 6700 ff5a                 beq       $00FE6E58
[00fe6f00] 526e ffea                 addq.w    #1,-22(a6)
[00fe6f04] 302e ffea                 move.w    -22(a6),d0
[00fe6f08] b06e ffe4                 cmp.w     -28(a6),d0
[00fe6f0c] 6c06                      bge.s     $00FE6F14
[00fe6f0e] 4a46                      tst.w     d6
[00fe6f10] 6700 fed2                 beq       $00FE6DE4
[00fe6f14] 3eae fff2                 move.w    -14(a6),(a7)
[00fe6f18] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe6f1c] f454                      dc.w      $F454
[00fe6f1e] 588f                      addq.l    #4,a7
[00fe6f20] 5244                      addq.w    #1,d4
[00fe6f22] b86e ffe6                 cmp.w     -26(a6),d4
[00fe6f26] 6c06                      bge.s     $00FE6F2E
[00fe6f28] 4a46                      tst.w     d6
[00fe6f2a] 6700 feb0                 beq       $00FE6DDC
[00fe6f2e] 4a46                      tst.w     d6
[00fe6f30] 6600 01c0                 bne       $00FE70F2
[00fe6f34] 4257                      clr.w     (a7)
[00fe6f36] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fe6f3a] 2f3c 0100 0000            move.l    #$01000000,-(a7)
[00fe6f40] 2f0d                      move.l    a5,-(a7)
[00fe6f42] 3f3c 0012                 move.w    #$0012,-(a7)
[00fe6f46] f450                      dc.w      $F450 ; trp14int
[00fe6f48] defc 000c                 adda.w    #$000C,a7
[00fe6f4c] 1abc 00e9                 move.b    #$E9,(a5)
[00fe6f50] 3eae fff2                 move.w    -14(a6),(a7)
[00fe6f54] 2f3c 0001 0000            move.l    #$00010000,-(a7)
[00fe6f5a] 2f0d                      move.l    a5,-(a7)
[00fe6f5c] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe6f60] f458                      dc.w      $F458 ; fc_rwsec
[00fe6f62] defc 000a                 adda.w    #$000A,a7
[00fe6f66] 3c00                      move.w    d0,d6
[00fe6f68] 6600 0188                 bne       $00FE70F2
[00fe6f6c] 3eae fff2                 move.w    -14(a6),(a7)
[00fe6f70] 3f3c 0007                 move.w    #$0007,-(a7)
[00fe6f74] f0f0                      dc.w      $F0F0 ; trp13
[00fe6f76] 548f                      addq.l    #2,a7
[00fe6f78] 2d40 ffde                 move.l    d0,-34(a6)
[00fe6f7c] 3eae fff2                 move.w    -14(a6),(a7)
[00fe6f80] 2f3c 0001 0000            move.l    #$00010000,-(a7)
[00fe6f86] 2f0d                      move.l    a5,-(a7)
[00fe6f88] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe6f8c] f458                      dc.w      $F458 ; fc_rwsec
[00fe6f8e] defc 000a                 adda.w    #$000A,a7
[00fe6f92] 3c00                      move.w    d0,d6
[00fe6f94] 6600 015c                 bne       $00FE70F2
[00fe6f98] 206e ffde                 movea.l   -34(a6),a0
[00fe6f9c] 3ea8 0006                 move.w    6(a0),(a7)
[00fe6fa0] 206e ffde                 movea.l   -34(a6),a0
[00fe6fa4] 3f28 0008                 move.w    8(a0),-(a7)
[00fe6fa8] f45c                      dc.w      $F45C ; max
[00fe6faa] 548f                      addq.l    #2,a7
[00fe6fac] 3d40 ffee                 move.w    d0,-18(a6)
[00fe6fb0] 302e ffee                 move.w    -18(a6),d0
[00fe6fb4] 7209                      moveq.l   #9,d1
[00fe6fb6] e360                      asl.w     d1,d0
[00fe6fb8] 48c0                      ext.l     d0
[00fe6fba] 81fc 0002                 divs.w    #$0002,d0
[00fe6fbe] 3d40 fff0                 move.w    d0,-16(a6)
[00fe6fc2] 4245                      clr.w     d5
[00fe6fc4] 600c                      bra.s     $00FE6FD2
[00fe6fc6] 204b                      movea.l   a3,a0
[00fe6fc8] 3245                      movea.w   d5,a1
[00fe6fca] d3c9                      adda.l    a1,a1
[00fe6fcc] d1c9                      adda.l    a1,a0
[00fe6fce] 4250                      clr.w     (a0)
[00fe6fd0] 5245                      addq.w    #1,d5
[00fe6fd2] ba6e fff0                 cmp.w     -16(a6),d5
[00fe6fd6] 6dee                      blt.s     $00FE6FC6
[00fe6fd8] 486e ffaa                 pea.l     -86(a6)
[00fe6fdc] 3f3c 000d                 move.w    #$000D,-(a7)
[00fe6fe0] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe6fe4] f42c                      dc.w      $F42C ; fs_sget
[00fe6fe6] defc 000a                 adda.w    #$000A,a7
[00fe6fea] 4a2e ffaa                 tst.b     -86(a6)
[00fe6fee] 673c                      beq.s     $00FE702C
[00fe6ff0] 486e ff9c                 pea.l     -100(a6)
[00fe6ff4] 2f3c 000b 0020            move.l    #$000B0020,-(a7)
[00fe6ffa] f358                      dc.w      $F358 ; bfill
[00fe6ffc] 508f                      addq.l    #8,a7
[00fe6ffe] 4245                      clr.w     d5
[00fe7000] 6010                      bra.s     $00FE7012
[00fe7002] 3045                      movea.w   d5,a0
[00fe7004] d1ce                      adda.l    a6,a0
[00fe7006] 3245                      movea.w   d5,a1
[00fe7008] d3ce                      adda.l    a6,a1
[00fe700a] 1169 ffaa ff9c            move.b    -86(a1),-100(a0)
[00fe7010] 5245                      addq.w    #1,d5
[00fe7012] 4a36 50aa                 tst.b     -86(a6,d5.w)
[00fe7016] 66ea                      bne.s     $00FE7002
[00fe7018] 3ebc 000b                 move.w    #$000B,(a7)
[00fe701c] 486e ff9c                 pea.l     -100(a6)
[00fe7020] 2f0d                      move.l    a5,-(a7)
[00fe7022] f268                      dc.w      $F268 ; LBCOPY
[00fe7024] 508f                      addq.l    #8,a7
[00fe7026] 006b 0008 000a            ori.w     #$0008,10(a3)
[00fe702c] 206e ffde                 movea.l   -34(a6),a0
[00fe7030] 3a28 0008                 move.w    8(a0),d5
[00fe7034] e345                      asl.w     #1,d5
[00fe7036] 5245                      addq.w    #1,d5
[00fe7038] 3eae fff2                 move.w    -14(a6),(a7)
[00fe703c] 3f05                      move.w    d5,-(a7)
[00fe703e] 206e ffde                 movea.l   -34(a6),a0
[00fe7042] 3f28 0006                 move.w    6(a0),-(a7)
[00fe7046] 2f0d                      move.l    a5,-(a7)
[00fe7048] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe704c] f458                      dc.w      $F458 ; fc_rwsec
[00fe704e] defc 000a                 adda.w    #$000A,a7
[00fe7052] 3c00                      move.w    d0,d6
[00fe7054] 6600 009c                 bne       $00FE70F2
[00fe7058] 4245                      clr.w     d5
[00fe705a] 600c                      bra.s     $00FE7068
[00fe705c] 204b                      movea.l   a3,a0
[00fe705e] 3245                      movea.w   d5,a1
[00fe7060] d3c9                      adda.l    a1,a1
[00fe7062] d1c9                      adda.l    a1,a0
[00fe7064] 4250                      clr.w     (a0)
[00fe7066] 5245                      addq.w    #1,d5
[00fe7068] ba6e fff0                 cmp.w     -16(a6),d5
[00fe706c] 6dee                      blt.s     $00FE705C
[00fe706e] 36bc f9ff                 move.w    #$F9FF,(a3)
[00fe7072] 377c ff00 0002            move.w    #$FF00,2(a3)
[00fe7078] 4245                      clr.w     d5
[00fe707a] 602e                      bra.s     $00FE70AA
[00fe707c] 3045                      movea.w   d5,a0
[00fe707e] d1c8                      adda.l    a0,a0
[00fe7080] 3034 8800                 move.w    0(a4,a0.l),d0
[00fe7084] 226e ffde                 movea.l   -34(a6),a1
[00fe7088] 3229 000c                 move.w    12(a1),d1
[00fe708c] 9041                      sub.w     d1,d0
[00fe708e] 48c0                      ext.l     d0
[00fe7090] 226e ffde                 movea.l   -34(a6),a1
[00fe7094] 81e9 0002                 divs.w    2(a1),d0
[00fe7098] 5440                      addq.w    #2,d0
[00fe709a] 3d40 ffe2                 move.w    d0,-30(a6)
[00fe709e] 2e8b                      move.l    a3,(a7)
[00fe70a0] 3f2e ffe2                 move.w    -30(a6),-(a7)
[00fe70a4] f460                      dc.w      $F460 ; fc_clfix
[00fe70a6] 548f                      addq.l    #2,a7
[00fe70a8] 5245                      addq.w    #1,d5
[00fe70aa] ba47                      cmp.w     d7,d5
[00fe70ac] 6dce                      blt.s     $00FE707C
[00fe70ae] 3eae fff2                 move.w    -14(a6),(a7)
[00fe70b2] 3f3c 0001                 move.w    #1,-(a7)
[00fe70b6] 206e ffde                 movea.l   -34(a6),a0
[00fe70ba] 3f28 0008                 move.w    8(a0),-(a7)
[00fe70be] 2f0b                      move.l    a3,-(a7)
[00fe70c0] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe70c4] f458                      dc.w      $F458 ; fc_rwsec
[00fe70c6] defc 000a                 adda.w    #$000A,a7
[00fe70ca] 3c00                      move.w    d0,d6
[00fe70cc] 6624                      bne.s     $00FE70F2
[00fe70ce] 3eae fff2                 move.w    -14(a6),(a7)
[00fe70d2] 206e ffde                 movea.l   -34(a6),a0
[00fe70d6] 3f28 0008                 move.w    8(a0),-(a7)
[00fe70da] 5257                      addq.w    #1,(a7)
[00fe70dc] 206e ffde                 movea.l   -34(a6),a0
[00fe70e0] 3f28 0008                 move.w    8(a0),-(a7)
[00fe70e4] 2f0b                      move.l    a3,-(a7)
[00fe70e6] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe70ea] f458                      dc.w      $F458 ; fc_rwsec
[00fe70ec] defc 000a                 adda.w    #$000A,a7
[00fe70f0] 3c00                      move.w    d0,d6
[00fe70f2] 4257                      clr.w     (a7)
[00fe70f4] f094                      dc.w      $F094 ; desk_wait
[00fe70f6] 4a46                      tst.w     d6
[00fe70f8] 6622                      bne.s     $00FE711C
[00fe70fa] 486e fff8                 pea.l     -8(a6)
[00fe70fe] 486e fff4                 pea.l     -12(a6)
[00fe7102] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fe7106] 5257                      addq.w    #1,(a7)
[00fe7108] f464                      dc.w      $F464
[00fe710a] defc 000a                 adda.w    #$000A,a7
[00fe710e] 486e fff8                 pea.l     -8(a6)
[00fe7112] 2f3c 0001 001d            move.l    #$0001001D,-(a7)
[00fe7118] f0dc                      dc.w      $F0DC ; fill_string
[00fe711a] 508f                      addq.l    #8,a7
[00fe711c] 2e8d                      move.l    a5,(a7)
[00fe711e] f3f0                      dc.w      $F3F0 ; dos_free
[00fe7120] 2e8c                      move.l    a4,(a7)
[00fe7122] f3f0                      dc.w      $F3F0 ; dos_free
[00fe7124] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef _fc_copy
_fc_copy: ds.b 0
#if 0
[00fe7126] 4e56 ffd8                 link      a6,#$FFD8
[00fe712a] 48e7 3f0c                 movem.l   d2-d7/a4-a5,-(a7)
[00fe712e] 2ebc 0000 0258            move.l    #$00000258,(a7)
[00fe7134] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fe7136] 2e00                      move.l    d0,d7
[00fe7138] 660a                      bne.s     $00FE7144
[00fe713a] 3ebc 001b                 move.w    #$001B,(a7)
[00fe713e] f3bc                      dc.w      $F3BC ; do1_alert
[00fe7140] 6000 028c                 bra       $00FE73CE
[00fe7144] 206e 0008                 movea.l   8(a6),a0
[00fe7148] d1fc 0000 006b            adda.l    #$0000006B,a0
[00fe714e] 0810 0000                 btst      #0,(a0)
[00fe7152] 6704                      beq.s     $00FE7158
[00fe7154] 4240                      clr.w     d0
[00fe7156] 6002                      bra.s     $00FE715A
[00fe7158] 7001                      moveq.l   #1,d0
[00fe715a] 3d40 fff6                 move.w    d0,-10(a6)
[00fe715e] 4a6e fff6                 tst.w     -10(a6)
[00fe7162] 6704                      beq.s     $00FE7168
[00fe7164] 4240                      clr.w     d0
[00fe7166] 6002                      bra.s     $00FE716A
[00fe7168] 7001                      moveq.l   #1,d0
[00fe716a] 3d40 fff4                 move.w    d0,-12(a6)
[00fe716e] 3eae fff6                 move.w    -10(a6),(a7)
[00fe7172] 3f3c 0007                 move.w    #$0007,-(a7)
[00fe7176] f0f0                      dc.w      $F0F0 ; trp13
[00fe7178] 548f                      addq.l    #2,a7
[00fe717a] 2a40                      movea.l   d0,a5
[00fe717c] 200d                      move.l    a5,d0
[00fe717e] 6614                      bne.s     $00FE7194
[00fe7180] 3ebc 001c                 move.w    #$001C,(a7)
[00fe7184] f3bc                      dc.w      $F3BC ; do1_alert
[00fe7186] b07c 0001                 cmp.w     #1,d0
[00fe718a] 67e2                      beq.s     $00FE716E
[00fe718c] 2e87                      move.l    d7,(a7)
[00fe718e] f3f0                      dc.w      $F3F0 ; dos_free
[00fe7190] 6000 023c                 bra       $00FE73CE
[00fe7194] 3d6d 0016 fff2            move.w    22(a5),-14(a6)
[00fe719a] 3d55 fff0                 move.w    (a5),-16(a6)
[00fe719e] 302e fff2                 move.w    -14(a6),d0
[00fe71a2] c1ee fff0                 muls.w    -16(a6),d0
[00fe71a6] 3d40 ffee                 move.w    d0,-18(a6)
[00fe71aa] f3b8                      dc.w      $F3B8 ; dos_avail
[00fe71ac] 2d40 fff8                 move.l    d0,-8(a6)
[00fe71b0] 306e ffee                 movea.w   -18(a6),a0
[00fe71b4] b088                      cmp.l     a0,d0
[00fe71b6] 6c08                      bge.s     $00FE71C0
[00fe71b8] 2e87                      move.l    d7,(a7)
[00fe71ba] f3f0                      dc.w      $F3F0 ; dos_free
[00fe71bc] 6000 ff7c                 bra       $00FE713A
[00fe71c0] 2eae fff8                 move.l    -8(a6),(a7)
[00fe71c4] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fe71c6] 2c00                      move.l    d0,d6
[00fe71c8] 302d 0012                 move.w    18(a5),d0
[00fe71cc] c1ee fff2                 muls.w    -14(a6),d0
[00fe71d0] 3d40 ffec                 move.w    d0,-20(a6)
[00fe71d4] 202e fff8                 move.l    -8(a6),d0
[00fe71d8] 81ee fff0                 divs.w    -16(a6),d0
[00fe71dc] 48c0                      ext.l     d0
[00fe71de] 3d40 ffea                 move.w    d0,-22(a6)
[00fe71e2] 302e ffec                 move.w    -20(a6),d0
[00fe71e6] 48c0                      ext.l     d0
[00fe71e8] 81ee ffea                 divs.w    -22(a6),d0
[00fe71ec] 4840                      swap      d0
[00fe71ee] 3d40 ffe8                 move.w    d0,-24(a6)
[00fe71f2] 3d7c 0001 ffe6            move.w    #1,-26(a6)
[00fe71f8] 426e ffe4                 clr.w     -28(a6)
[00fe71fc] 4240                      clr.w     d0
[00fe71fe] 3d40 ffde                 move.w    d0,-34(a6)
[00fe7202] 3d40 ffda                 move.w    d0,-38(a6)
[00fe7206] 3d40 ffdc                 move.w    d0,-36(a6)
[00fe720a] 362e ffec                 move.w    -20(a6),d3
[00fe720e] 48c3                      ext.l     d3
[00fe7210] 87ee ffea                 divs.w    -22(a6),d3
[00fe7214] 660e                      bne.s     $00FE7224
[00fe7216] 3d6e ffe8 ffea            move.w    -24(a6),-22(a6)
[00fe721c] 3d7c 0001 ffe4            move.w    #1,-28(a6)
[00fe7222] 7601                      moveq.l   #1,d3
[00fe7224] 3eae fff6                 move.w    -10(a6),(a7)
[00fe7228] 2f3c 0001 0000            move.l    #$00010000,-(a7)
[00fe722e] 2f07                      move.l    d7,-(a7)
[00fe7230] 3f3c 0002                 move.w    #$0002,-(a7)
[00fe7234] f458                      dc.w      $F458 ; fc_rwsec
[00fe7236] defc 000a                 adda.w    #$000A,a7
[00fe723a] 4a40                      tst.w     d0
[00fe723c] 6600 0188                 bne       $00FE73C6
[00fe7240] 6000 014a                 bra       $00FE738C
[00fe7244] 3d6e fff6 ffe0            move.w    -10(a6),-32(a6)
[00fe724a] 7802                      moveq.l   #2,d4
[00fe724c] 6000 011e                 bra       $00FE736C
[00fe7250] 2d46 fffc                 move.l    d6,-4(a6)
[00fe7254] 302e ffea                 move.w    -22(a6),d0
[00fe7258] 48c0                      ext.l     d0
[00fe725a] 81ee fff2                 divs.w    -14(a6),d0
[00fe725e] 3d40 ffd8                 move.w    d0,-40(a6)
[00fe7262] 4245                      clr.w     d5
[00fe7264] 603a                      bra.s     $00FE72A0
[00fe7266] 2f2e ffde                 move.l    -34(a6),-(a7)
[00fe726a] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fe726e] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fe7272] 3f04                      move.w    d4,-(a7)
[00fe7274] f458                      dc.w      $F458 ; fc_rwsec
[00fe7276] defc 000c                 adda.w    #$000C,a7
[00fe727a] 4a40                      tst.w     d0
[00fe727c] 6600 0148                 bne       $00FE73C6
[00fe7280] 302e fff2                 move.w    -14(a6),d0
[00fe7284] d16e ffde                 add.w     d0,-34(a6)
[00fe7288] 302e ffee                 move.w    -18(a6),d0
[00fe728c] 48c0                      ext.l     d0
[00fe728e] d1ae fffc                 add.l     d0,-4(a6)
[00fe7292] 3eae ffe0                 move.w    -32(a6),(a7)
[00fe7296] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe729a] f454                      dc.w      $F454
[00fe729c] 588f                      addq.l    #4,a7
[00fe729e] 5245                      addq.w    #1,d5
[00fe72a0] ba6e ffd8                 cmp.w     -40(a6),d5
[00fe72a4] 6dc0                      blt.s     $00FE7266
[00fe72a6] 3a2e ffea                 move.w    -22(a6),d5
[00fe72aa] 48c5                      ext.l     d5
[00fe72ac] 8bee fff2                 divs.w    -14(a6),d5
[00fe72b0] 4845                      swap      d5
[00fe72b2] 6728                      beq.s     $00FE72DC
[00fe72b4] 2f2e ffde                 move.l    -34(a6),-(a7)
[00fe72b8] 3f05                      move.w    d5,-(a7)
[00fe72ba] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fe72be] 3f04                      move.w    d4,-(a7)
[00fe72c0] f458                      dc.w      $F458 ; fc_rwsec
[00fe72c2] defc 000c                 adda.w    #$000C,a7
[00fe72c6] 4a40                      tst.w     d0
[00fe72c8] 6600 00fc                 bne       $00FE73C6
[00fe72cc] db6e ffde                 add.w     d5,-34(a6)
[00fe72d0] 3eae ffe0                 move.w    -32(a6),(a7)
[00fe72d4] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe72d8] f454                      dc.w      $F454
[00fe72da] 588f                      addq.l    #4,a7
[00fe72dc] b87c 0002                 cmp.w     #$0002,d4
[00fe72e0] 6600 0076                 bne.w     $00FE7358
[00fe72e4] 3d6e ffde ffdc            move.w    -34(a6),-36(a6)
[00fe72ea] 3d6e ffda ffde            move.w    -38(a6),-34(a6)
[00fe72f0] 4a6e ffe6                 tst.w     -26(a6)
[00fe72f4] 6760                      beq.s     $00FE7356
[00fe72f6] 426e ffe6                 clr.w     -26(a6)
[00fe72fa] 3eae fff4                 move.w    -12(a6),(a7)
[00fe72fe] 3f3c 0007                 move.w    #$0007,-(a7)
[00fe7302] f0f0                      dc.w      $F0F0 ; trp13
[00fe7304] 548f                      addq.l    #2,a7
[00fe7306] 2840                      movea.l   d0,a4
[00fe7308] 200c                      move.l    a4,d0
[00fe730a] 6610                      bne.s     $00FE731C
[00fe730c] 3ebc 001c                 move.w    #$001C,(a7)
[00fe7310] f3bc                      dc.w      $F3BC ; do1_alert
[00fe7312] b07c 0001                 cmp.w     #1,d0
[00fe7316] 67e2                      beq.s     $00FE72FA
[00fe7318] 6000 00ac                 bra       $00FE73C6
[00fe731c] 302d 0014                 move.w    20(a5),d0
[00fe7320] b06c 0014                 cmp.w     20(a4),d0
[00fe7324] 661c                      bne.s     $00FE7342
[00fe7326] 302c 0016                 move.w    22(a4),d0
[00fe732a] b06e fff2                 cmp.w     -14(a6),d0
[00fe732e] 6612                      bne.s     $00FE7342
[00fe7330] 302d 0012                 move.w    18(a5),d0
[00fe7334] b06c 0012                 cmp.w     18(a4),d0
[00fe7338] 6608                      bne.s     $00FE7342
[00fe733a] 3014                      move.w    (a4),d0
[00fe733c] b06e fff0                 cmp.w     -16(a6),d0
[00fe7340] 6714                      beq.s     $00FE7356
[00fe7342] 4297                      clr.l     (a7)
[00fe7344] 2f3c 0001 001e            move.l    #$0001001E,-(a7)
[00fe734a] f0dc                      dc.w      $F0DC ; fill_string
[00fe734c] 588f                      addq.l    #4,a7
[00fe734e] b07c 0001                 cmp.w     #1,d0
[00fe7352] 6672                      bne.s     $00FE73C6
[00fe7354] 60a4                      bra.s     $00FE72FA
[00fe7356] 600c                      bra.s     $00FE7364
[00fe7358] 3d6e ffde ffda            move.w    -34(a6),-38(a6)
[00fe735e] 3d6e ffdc ffde            move.w    -36(a6),-34(a6)
[00fe7364] 3d6e fff4 ffe0            move.w    -12(a6),-32(a6)
[00fe736a] 5244                      addq.w    #1,d4
[00fe736c] b87c 0003                 cmp.w     #$0003,d4
[00fe7370] 6f00 fede                 ble       $00FE7250
[00fe7374] 4a43                      tst.w     d3
[00fe7376] 6614                      bne.s     $00FE738C
[00fe7378] 4a6e ffe4                 tst.w     -28(a6)
[00fe737c] 660e                      bne.s     $00FE738C
[00fe737e] 7601                      moveq.l   #1,d3
[00fe7380] 3d6e ffe8 ffea            move.w    -24(a6),-22(a6)
[00fe7386] 3d7c 0001 ffe4            move.w    #1,-28(a6)
[00fe738c] 3003                      move.w    d3,d0
[00fe738e] 5343                      subq.w    #1,d3
[00fe7390] 4a40                      tst.w     d0
[00fe7392] 6600 feb0                 bne       $00FE7244
[00fe7396] 3ebc ffff                 move.w    #$FFFF,(a7)
[00fe739a] 3f3c ffff                 move.w    #$FFFF,-(a7)
[00fe739e] 2f3c 0100 0000            move.l    #$01000000,-(a7)
[00fe73a4] 2f07                      move.l    d7,-(a7)
[00fe73a6] 3f3c 0012                 move.w    #$0012,-(a7)
[00fe73aa] f450                      dc.w      $F450 ; trp14int
[00fe73ac] defc 000c                 adda.w    #$000C,a7
[00fe73b0] 3eae fff4                 move.w    -12(a6),(a7)
[00fe73b4] 2f3c 0001 0000            move.l    #$00010000,-(a7)
[00fe73ba] 2f07                      move.l    d7,-(a7)
[00fe73bc] 3f3c 0003                 move.w    #$0003,-(a7)
[00fe73c0] f458                      dc.w      $F458 ; fc_rwsec
[00fe73c2] defc 000a                 adda.w    #$000A,a7
[00fe73c6] 2e86                      move.l    d6,(a7)
[00fe73c8] f3f0                      dc.w      $F3F0 ; dos_free
[00fe73ca] 2e87                      move.l    d7,(a7)
[00fe73cc] f3f0                      dc.w      $F3F0 ; dos_free
[00fe73ce] fc3f                      dc.w      $FC3F ; movem.l (a7)+,d3-d7/a4-a5
#endif

	xdef _fc_rwsec
_fc_rwsec: ds.b 0
#if 0
[00fe73d0] 4e56 0000                 link      a6,#0
[00fe73d4] 48e7 0300                 movem.l   d6-d7,-(a7)
[00fe73d8] 2f2e 0010                 move.l    16(a6),-(a7)
[00fe73dc] 3f2e 000e                 move.w    14(a6),-(a7)
[00fe73e0] 2f2e 000a                 move.l    10(a6),-(a7)
[00fe73e4] 3f2e 0008                 move.w    8(a6),-(a7)
[00fe73e8] 3f3c 0004                 move.w    #$0004,-(a7)
[00fe73ec] f0f0                      dc.w      $F0F0 ; trp13
[00fe73ee] defc 000e                 adda.w    #$000E,a7
[00fe73f2] 3e00                      move.w    d0,d7
[00fe73f4] 670e                      beq.s     $00FE7404
[00fe73f6] 3ebc 001c                 move.w    #$001C,(a7)
[00fe73fa] f3bc                      dc.w      $F3BC ; do1_alert
[00fe73fc] 3e00                      move.w    d0,d7
[00fe73fe] be7c 0001                 cmp.w     #1,d7
[00fe7402] 67d4                      beq.s     $00FE73D8
[00fe7404] 3007                      move.w    d7,d0
[00fe7406] f021                      dc.w      $F021 ; movem.l (a7)+,d7
#endif

	xdef _fc_clfix
_fc_clfix: ds.b 0
#if 0
[00fe7408] 4e56 fffc                 link      a6,#$FFFC
[00fe740c] 48e7 0700                 movem.l   d5-d7,-(a7)
[00fe7410] 3d7c 0ff7 fffc            move.w    #$0FF7,-4(a6)
[00fe7416] 3e2e 0008                 move.w    8(a6),d7
[00fe741a] e24f                      lsr.w     #1,d7
[00fe741c] de6e 0008                 add.w     8(a6),d7
[00fe7420] 3007                      move.w    d7,d0
[00fe7422] e348                      lsl.w     #1,d0
[00fe7424] 4840                      swap      d0
[00fe7426] 4240                      clr.w     d0
[00fe7428] 4840                      swap      d0
[00fe742a] d0ae 000a                 add.l     10(a6),d0
[00fe742e] 2040                      movea.l   d0,a0
[00fe7430] 3c10                      move.w    (a0),d6
[00fe7432] cc7c 00ff                 and.w     #$00FF,d6
[00fe7436] 206e 000a                 movea.l   10(a6),a0
[00fe743a] 3207                      move.w    d7,d1
[00fe743c] 5241                      addq.w    #1,d1
[00fe743e] e349                      lsl.w     #1,d1
[00fe7440] 4841                      swap      d1
[00fe7442] 4241                      clr.w     d1
[00fe7444] 4841                      swap      d1
[00fe7446] 4240                      clr.w     d0
[00fe7448] 3030 1800                 move.w    0(a0,d1.l),d0
[00fe744c] e148                      lsl.w     #8,d0
[00fe744e] 8c40                      or.w      d0,d6
[00fe7450] 082e 0000 0009            btst      #0,9(a6)
[00fe7456] 6710                      beq.s     $00FE7468
[00fe7458] cc7c 000f                 and.w     #$000F,d6
[00fe745c] 302e fffc                 move.w    -4(a6),d0
[00fe7460] e948                      lsl.w     #4,d0
[00fe7462] 3d40 fffc                 move.w    d0,-4(a6)
[00fe7466] 6004                      bra.s     $00FE746C
[00fe7468] cc7c f000                 and.w     #$F000,d6
[00fe746c] 3006                      move.w    d6,d0
[00fe746e] 806e fffc                 or.w      -4(a6),d0
[00fe7472] 3d40 fffc                 move.w    d0,-4(a6)
[00fe7476] 3007                      move.w    d7,d0
[00fe7478] e348                      lsl.w     #1,d0
[00fe747a] 4840                      swap      d0
[00fe747c] 4240                      clr.w     d0
[00fe747e] 4840                      swap      d0
[00fe7480] d0ae 000a                 add.l     10(a6),d0
[00fe7484] 2040                      movea.l   d0,a0
[00fe7486] 30ae fffc                 move.w    -4(a6),(a0)
[00fe748a] 302e fffc                 move.w    -4(a6),d0
[00fe748e] e048                      lsr.w     #8,d0
[00fe7490] 3207                      move.w    d7,d1
[00fe7492] 5241                      addq.w    #1,d1
[00fe7494] e349                      lsl.w     #1,d1
[00fe7496] 4841                      swap      d1
[00fe7498] 4241                      clr.w     d1
[00fe749a] 4841                      swap      d1
[00fe749c] d2ae 000a                 add.l     10(a6),d1
[00fe74a0] 2241                      movea.l   d1,a1
[00fe74a2] 3280                      move.w    d0,(a1)
[00fe74a4] f031                      dc.w      $F031 ; movem.l (a7)+,d6-d7
#endif
