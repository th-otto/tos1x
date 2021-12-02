	xdef _my_itoa
_my_itoa: ds.b 0
#if 0
[00fd7d6e] 4e56 0000                 link      a6,#0
[00fd7d72] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd7d76] 2a6e 000a                 movea.l   10(a6),a5
[00fd7d7a] 4247                      clr.w     d7
[00fd7d7c] 600c                      bra.s     $00FD7D8A
[00fd7d7e] 204d                      movea.l   a5,a0
[00fd7d80] 3247                      movea.w   d7,a1
[00fd7d82] d1c9                      adda.l    a1,a0
[00fd7d84] 10bc 0030                 move.b    #$30,(a0)
[00fd7d88] 5247                      addq.w    #1,d7
[00fd7d8a] be7c 0002                 cmp.w     #$0002,d7
[00fd7d8e] 6dee                      blt.s     $00FD7D7E
[00fd7d90] 422d 0002                 clr.b     2(a5)
[00fd7d94] 486e 0008                 pea.l     8(a6)
[00fd7d98] 2f3c 00fe b13e            move.l    #$00FEB13E,-(a7)
[00fd7d9e] 0c6e 0009 0008            cmpi.w    #$0009,8(a6)
[00fd7da4] 6304                      bls.s     $00FD7DAA
[00fd7da6] 2f0d                      move.l    a5,-(a7)
[00fd7da8] 6004                      bra.s     $00FD7DAE
[00fd7daa] 486d 0001                 pea.l     1(a5)
[00fd7dae] f498                      dc.w      $F498 ; merge_str
[00fd7db0] defc 000c                 adda.w    #12,a7
[00fd7db4] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef _fmt_time
_fmt_time: ds.b 0
#if 0
[00fd7db6] 4e56 0000                 link      a6,#0
[00fd7dba] 48e7 0f04                 movem.l   d4-d7/a5,-(a7)
[00fd7dbe] 3e2e 0008                 move.w    8(a6),d7
[00fd7dc2] 2a6e 000a                 movea.l   10(a6),a5
[00fd7dc6] 3a07                      move.w    d7,d5
[00fd7dc8] ca7c f800                 and.w     #$F800,d5
[00fd7dcc] 700b                      moveq.l   #11,d0
[00fd7dce] e065                      asr.w     d0,d5
[00fd7dd0] ca7c 001f                 and.w     #$001F,d5
[00fd7dd4] 2e8d                      move.l    a5,(a7)
[00fd7dd6] 3f05                      move.w    d5,-(a7)
[00fd7dd8] f50c                      dc.w      $F50C ; my_itoa
[00fd7dda] 548f                      addq.l    #2,a7
[00fd7ddc] 486d 0002                 pea.l     2(a5)
[00fd7de0] 3007                      move.w    d7,d0
[00fd7de2] c07c 07e0                 and.w     #$07E0,d0
[00fd7de6] ea48                      lsr.w     #5,d0
[00fd7de8] 3f00                      move.w    d0,-(a7)
[00fd7dea] 0257 003f                 andi.w    #$003F,(a7)
[00fd7dee] f50c                      dc.w      $F50C ; my_itoa
[00fd7df0] 5c8f                      addq.l    #6,a7
[00fd7df2] 486d 0004                 pea.l     4(a5)
[00fd7df6] 2f3c 00fe b141            move.l    #$00FEB141,-(a7)
[00fd7dfc] f36c                      dc.w      $F36C ; xstrpcpy
[00fd7dfe] 508f                      addq.l    #8,a7
[00fd7e00] f839                      dc.w      $F839 ; movem.l (a7)+,d5-d7/a5
#endif

	xdef _fmt_date
_fmt_date: ds.b 0
#if 0
[00fd7e02] 4e56 0000                 link      a6,#0
[00fd7e06] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd7e0a] 2a6e 000a                 movea.l   10(a6),a5
[00fd7e0e] 2e8d                      move.l    a5,(a7)
[00fd7e10] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd7e14] 0257 001f                 andi.w    #$001F,(a7)
[00fd7e18] f50c                      dc.w      $F50C ; my_itoa
[00fd7e1a] 548f                      addq.l    #2,a7
[00fd7e1c] 486d 0002                 pea.l     2(a5)
[00fd7e20] 302e 0008                 move.w    8(a6),d0
[00fd7e24] c07c 01e0                 and.w     #$01E0,d0
[00fd7e28] ea48                      lsr.w     #5,d0
[00fd7e2a] 3f00                      move.w    d0,-(a7)
[00fd7e2c] f50c                      dc.w      $F50C ; my_itoa
[00fd7e2e] 5c8f                      addq.l    #6,a7
[00fd7e30] 486d 0004                 pea.l     4(a5)
[00fd7e34] 302e 0008                 move.w    8(a6),d0
[00fd7e38] 7209                      moveq.l   #9,d1
[00fd7e3a] e268                      lsr.w     d1,d0
[00fd7e3c] c07c 007f                 and.w     #$007F,d0
[00fd7e40] d07c 0050                 add.w     #$0050,d0
[00fd7e44] 4840                      swap      d0
[00fd7e46] 4240                      clr.w     d0
[00fd7e48] 4840                      swap      d0
[00fd7e4a] 80fc 0064                 divu.w    #$0064,d0
[00fd7e4e] 4840                      swap      d0
[00fd7e50] 3f00                      move.w    d0,-(a7)
[00fd7e52] f50c                      dc.w      $F50C ; my_itoa
[00fd7e54] 5c8f                      addq.l    #6,a7
[00fd7e56] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd7e58
xfd7e58: ds.b 0
#if 0
[00fd7e58] 4e56 ffcc                 link      a6,#$FFCC
[00fd7e5c] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd7e60] 2e2e 0008                 move.l    8(a6),d7
[00fd7e64] 2a6e 000c                 movea.l   12(a6),a5
[00fd7e68] 3ebc 0017                 move.w    #$0017,(a7)
[00fd7e6c] 2f07                      move.l    d7,-(a7)
[00fd7e6e] 486e ffe9                 pea.l     -23(a6)
[00fd7e72] f268                      dc.w      $F268 ; LBCOPY
[00fd7e74] 508f                      addq.l    #8,a7
[00fd7e76] 284d                      movea.l   a5,a4
[00fd7e78] 47ee fff2                 lea.l     -14(a6),a3
[00fd7e7c] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7e84] 6704                      beq.s     $00FD7E8A
[00fd7e86] 18fc 0020                 move.b    #$20,(a4)+
[00fd7e8a] 082e 0004 ffe9            btst      #4,-23(a6)
[00fd7e90] 6704                      beq.s     $00FD7E96
[00fd7e92] 7007                      moveq.l   #7,d0
[00fd7e94] 6002                      bra.s     $00FD7E98
[00fd7e96] 7020                      moveq.l   #32,d0
[00fd7e98] 18c0                      move.b    d0,(a4)+
[00fd7e9a] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7ea2] 6704                      beq.s     $00FD7EA8
[00fd7ea4] 18fc 0020                 move.b    #$20,(a4)+
[00fd7ea8] 6002                      bra.s     $00FD7EAC
[00fd7eaa] 18db                      move.b    (a3)+,(a4)+
[00fd7eac] 4a13                      tst.b     (a3)
[00fd7eae] 6706                      beq.s     $00FD7EB6
[00fd7eb0] 0c13 002e                 cmpi.b    #$2E,(a3)
[00fd7eb4] 66f4                      bne.s     $00FD7EAA
[00fd7eb6] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7ebe] 6604                      bne.s     $00FD7EC4
[00fd7ec0] 700a                      moveq.l   #10,d0
[00fd7ec2] 6002                      bra.s     $00FD7EC6
[00fd7ec4] 700c                      moveq.l   #12,d0
[00fd7ec6] 3d40 ffcc                 move.w    d0,-52(a6)
[00fd7eca] 6004                      bra.s     $00FD7ED0
[00fd7ecc] 18fc 0020                 move.b    #$20,(a4)+
[00fd7ed0] 200c                      move.l    a4,d0
[00fd7ed2] 908d                      sub.l     a5,d0
[00fd7ed4] 306e ffcc                 movea.w   -52(a6),a0
[00fd7ed8] b088                      cmp.l     a0,d0
[00fd7eda] 6df0                      blt.s     $00FD7ECC
[00fd7edc] 4a13                      tst.b     (a3)
[00fd7ede] 6702                      beq.s     $00FD7EE2
[00fd7ee0] 528b                      addq.l    #1,a3
[00fd7ee2] 6002                      bra.s     $00FD7EE6
[00fd7ee4] 18db                      move.b    (a3)+,(a4)+
[00fd7ee6] 4a13                      tst.b     (a3)
[00fd7ee8] 66fa                      bne.s     $00FD7EE4
[00fd7eea] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7ef2] 6604                      bne.s     $00FD7EF8
[00fd7ef4] 700d                      moveq.l   #13,d0
[00fd7ef6] 6002                      bra.s     $00FD7EFA
[00fd7ef8] 7010                      moveq.l   #16,d0
[00fd7efa] 3d40 ffcc                 move.w    d0,-52(a6)
[00fd7efe] 6004                      bra.s     $00FD7F04
[00fd7f00] 18fc 0020                 move.b    #$20,(a4)+
[00fd7f04] 200c                      move.l    a4,d0
[00fd7f06] 908d                      sub.l     a5,d0
[00fd7f08] 306e ffcc                 movea.w   -52(a6),a0
[00fd7f0c] b088                      cmp.l     a0,d0
[00fd7f0e] 6df0                      blt.s     $00FD7F00
[00fd7f10] 47ee ffce                 lea.l     -50(a6),a3
[00fd7f14] 082e 0004 ffe9            btst      #4,-23(a6)
[00fd7f1a] 6704                      beq.s     $00FD7F20
[00fd7f1c] 4213                      clr.b     (a3)
[00fd7f1e] 6014                      bra.s     $00FD7F34
[00fd7f20] 486e ffee                 pea.l     -18(a6)
[00fd7f24] 2f3c 00fe b144            move.l    #$00FEB144,-(a7)
[00fd7f2a] 486e ffce                 pea.l     -50(a6)
[00fd7f2e] f498                      dc.w      $F498 ; merge_str
[00fd7f30] defc 000c                 adda.w    #12,a7
[00fd7f34] 7c08                      moveq.l   #8,d6
[00fd7f36] 2e8b                      move.l    a3,(a7)
[00fd7f38] f24c                      dc.w      $F24C ; strlen
[00fd7f3a] 9c40                      sub.w     d0,d6
[00fd7f3c] 6004                      bra.s     $00FD7F42
[00fd7f3e] 18fc 0020                 move.b    #$20,(a4)+
[00fd7f42] 3006                      move.w    d6,d0
[00fd7f44] 5346                      subq.w    #1,d6
[00fd7f46] 4a40                      tst.w     d0
[00fd7f48] 66f4                      bne.s     $00FD7F3E
[00fd7f4a] 6002                      bra.s     $00FD7F4E
[00fd7f4c] 18db                      move.b    (a3)+,(a4)+
[00fd7f4e] 4a13                      tst.b     (a3)
[00fd7f50] 66fa                      bne.s     $00FD7F4C
[00fd7f52] 18fc 0020                 move.b    #$20,(a4)+
[00fd7f56] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7f5e] 6704                      beq.s     $00FD7F64
[00fd7f60] 18fc 0020                 move.b    #$20,(a4)+
[00fd7f64] 486e ffe0                 pea.l     -32(a6)
[00fd7f68] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fd7f6c] f510                      dc.w      $F510 ; fmt_date
[00fd7f6e] 5c8f                      addq.l    #6,a7
[00fd7f70] 47ee ffe0                 lea.l     -32(a6),a3
[00fd7f74] 7c03                      moveq.l   #3,d6
[00fd7f76] 600c                      bra.s     $00FD7F84
[00fd7f78] 18db                      move.b    (a3)+,(a4)+
[00fd7f7a] 18db                      move.b    (a3)+,(a4)+
[00fd7f7c] 4a46                      tst.w     d6
[00fd7f7e] 6704                      beq.s     $00FD7F84
[00fd7f80] 18fc 002d                 move.b    #$2D,(a4)+
[00fd7f84] 3006                      move.w    d6,d0
[00fd7f86] 5346                      subq.w    #1,d6
[00fd7f88] 4a40                      tst.w     d0
[00fd7f8a] 66ec                      bne.s     $00FD7F78
[00fd7f8c] 18fc 0020                 move.b    #$20,(a4)+
[00fd7f90] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7f98] 6704                      beq.s     $00FD7F9E
[00fd7f9a] 18fc 0020                 move.b    #$20,(a4)+
[00fd7f9e] 486e ffd8                 pea.l     -40(a6)
[00fd7fa2] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fd7fa6] f514                      dc.w      $F514 ; fmt_time
[00fd7fa8] 5c8f                      addq.l    #6,a7
[00fd7faa] 47ee ffd8                 lea.l     -40(a6),a3
[00fd7fae] 7c02                      moveq.l   #2,d6
[00fd7fb0] 600c                      bra.s     $00FD7FBE
[00fd7fb2] 18db                      move.b    (a3)+,(a4)+
[00fd7fb4] 18db                      move.b    (a3)+,(a4)+
[00fd7fb6] 4a46                      tst.w     d6
[00fd7fb8] 6704                      beq.s     $00FD7FBE
[00fd7fba] 18fc 003a                 move.b    #$3A,(a4)+
[00fd7fbe] 3006                      move.w    d6,d0
[00fd7fc0] 5346                      subq.w    #1,d6
[00fd7fc2] 4a40                      tst.w     d0
[00fd7fc4] 66ec                      bne.s     $00FD7FB2
[00fd7fc6] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fd7fce] 6704                      beq.s     $00FD7FD4
[00fd7fd0] 18fc 0020                 move.b    #$20,(a4)+
[00fd7fd4] 2e8c                      move.l    a4,(a7)
[00fd7fd6] 486e ffdc                 pea.l     -36(a6)
[00fd7fda] f36c                      dc.w      $F36C ; xstrpcpy
[00fd7fdc] 588f                      addq.l    #4,a7
[00fd7fde] 568c                      addq.l    #3,a4
[00fd7fe0] 200c                      move.l    a4,d0
[00fd7fe2] 908d                      sub.l     a5,d0
[00fd7fe4] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef _dr_code
_dr_code: ds.b 0
#if 0
[00fd7fe6] 4e56 ffd8                 link      a6,#$FFD8
[00fd7fea] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd7fee] 2e2e 0008                 move.l    8(a6),d7
[00fd7ff2] 4bee ffe2                 lea.l     -30(a6),a5
[00fd7ff6] 3ebc 001e                 move.w    #$001E,(a7)
[00fd7ffa] 2f07                      move.l    d7,-(a7)
[00fd7ffc] 2f0d                      move.l    a5,-(a7)
[00fd7ffe] f268                      dc.w      $F268 ; LBCOPY
[00fd8000] 508f                      addq.l    #8,a7
[00fd8002] 2e8e                      move.l    a6,(a7)
[00fd8004] 0697 ffff ffda            addi.l    #$FFFFFFDA,(a7)
[00fd800a] f518                      dc.w      $F518 ; gsx_gclip
[00fd800c] 2e8d                      move.l    a5,(a7)
[00fd800e] 0697 0000 0012            addi.l    #$00000012,(a7)
[00fd8014] f0c0                      dc.w      $F0C0 ; gsx_sclip
[00fd8016] 302d 0006                 move.w    6(a5),d0
[00fd801a] 322d 0008                 move.w    8(a5),d1
[00fd801e] b340                      eor.w     d1,d0
[00fd8020] c07c 0001                 and.w     #1,d0
[00fd8024] 671a                      beq.s     $00FD8040
[00fd8026] 2f2d 000e                 move.l    14(a5),-(a7)
[00fd802a] 2f2d 000a                 move.l    10(a5),-(a7)
[00fd802e] 2f3c 0001 0007            move.l    #$00010007,-(a7)
[00fd8034] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd8038] f004                      dc.w      $F004 ; bb_fill
[00fd803a] defc 000e                 adda.w    #$000E,a7
[00fd803e] 605a                      bra.s     $00FD809A
[00fd8040] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd8046] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd804c] 2f2d 001a                 move.l    26(a5),-(a7)
[00fd8050] f51c                      dc.w      $F51C
[00fd8052] 588f                      addq.l    #4,a7
[00fd8054] 3ebc 0001                 move.w    #1,(a7)
[00fd8058] 2f3c 0001 0001            move.l    #$00010001,-(a7)
[00fd805e] f2d8                      dc.w      $F2D8
[00fd8060] 588f                      addq.l    #4,a7
[00fd8062] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd8068] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd806e] 2f39 0000 6dda            move.l    $00006DDA,-(a7)
[00fd8074] f068                      dc.w      $F068 ; LBWMOV
[00fd8076] 588f                      addq.l    #4,a7
[00fd8078] 3d40 ffd8                 move.w    d0,-40(a6)
[00fd807c] 3eae ffd8                 move.w    -40(a6),(a7)
[00fd8080] 2f2d 000a                 move.l    10(a5),-(a7)
[00fd8084] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd8088] f520                      dc.w      $F520 ; gsx_tblt
[00fd808a] 5c8f                      addq.l    #6,a7
[00fd808c] 3ebc 0001                 move.w    #1,(a7)
[00fd8090] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd8094] 4267                      clr.w     -(a7)
[00fd8096] f2d8                      dc.w      $F2D8
[00fd8098] 588f                      addq.l    #4,a7
[00fd809a] 2e8e                      move.l    a6,(a7)
[00fd809c] 0697 ffff ffda            addi.l    #$FFFFFFDA,(a7)
[00fd80a2] f0c0                      dc.w      $F0C0 ; gsx_sclip
[00fd80a4] 302d 0008                 move.w    8(a5),d0
[00fd80a8] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd80aa
xfd80aa: ds.b 0
#if 0
[00fd80aa] 4e56 ffee                 link      a6,#$FFEE
[00fd80ae] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd80b2] 2d79 0000 a788 ffee       move.l    _thedesk,-18(a6)
[00fd80ba] 2eae 0008                 move.l    8(a6),(a7)
[00fd80be] f3cc                      dc.w      $F3CC
[00fd80c0] 3eae 000c                 move.w    12(a6),(a7)
[00fd80c4] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd80c8] f3d0                      dc.w      $F3D0 ; form_do
[00fd80ca] 588f                      addq.l    #4,a7
[00fd80cc] c07c 7fff                 and.w     #$7FFF,d0
[00fd80d0] 3d40 fff2                 move.w    d0,-14(a6)
[00fd80d4] 2eae 0008                 move.l    8(a6),(a7)
[00fd80d8] f3ec                      dc.w      $F3EC ; do_finish
[00fd80da] 4bee fff4                 lea.l     -12(a6),a5
[00fd80de] 2e8d                      move.l    a5,(a7)
[00fd80e0] 2f0d                      move.l    a5,-(a7)
[00fd80e2] 2f0d                      move.l    a5,-(a7)
[00fd80e4] 2f0d                      move.l    a5,-(a7)
[00fd80e6] 2f0d                      move.l    a5,-(a7)
[00fd80e8] 2f0d                      move.l    a5,-(a7)
[00fd80ea] 42a7                      clr.l     -(a7)
[00fd80ec] 206e ffee                 movea.l   -18(a6),a0
[00fd80f0] 2f28 3436                 move.l    13366(a0),-(a7)
[00fd80f4] 4267                      clr.w     -(a7)
[00fd80f6] 42a7                      clr.l     -(a7)
[00fd80f8] 42a7                      clr.l     -(a7)
[00fd80fa] 42a7                      clr.l     -(a7)
[00fd80fc] 42a7                      clr.l     -(a7)
[00fd80fe] 42a7                      clr.l     -(a7)
[00fd8100] 42a7                      clr.l     -(a7)
[00fd8102] 3f3c 0030                 move.w    #$0030,-(a7)
[00fd8106] f2d0                      dc.w      $F2D0 ; evnt_multi
[00fd8108] defc 0038                 adda.w    #$0038,a7
[00fd810c] 3d40 fff6                 move.w    d0,-10(a6)
[00fd8110] 082e 0004 fff7            btst      #4,-9(a6)
[00fd8116] 6702                      beq.s     $00FD811A
[00fd8118] f524                      dc.w      $F524 ; hd_msg
[00fd811a] 082e 0004 fff7            btst      #4,-9(a6)
[00fd8120] 66bc                      bne.s     $00FD80DE
[00fd8122] 302e fff2                 move.w    -14(a6),d0
[00fd8126] c1fc 0018                 muls.w    #24,d0
[00fd812a] d0ae 0008                 add.l     8(a6),d0
[00fd812e] d0bc 0000 000a            add.l     #$0000000A,d0
[00fd8134] 2040                      movea.l   d0,a0
[00fd8136] 4250                      clr.w     (a0)
[00fd8138] 302e fff2                 move.w    -14(a6),d0
[00fd813c] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd813e
xfd813e: ds.b 0
#if 0
[00fd813e] 4e56 fffc                 link      a6,#-4
[00fd8142] 4257                      clr.w     (a7)
[00fd8144] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd8148] f4c4                      dc.w      $F4C4
[00fd814a] 588f                      addq.l    #4,a7
[00fd814c] 302e 000c                 move.w    12(a6),d0
[00fd8150] c1fc 0018                 muls.w    #24,d0
[00fd8154] d0ae 0008                 add.l     8(a6),d0
[00fd8158] d0bc 0000 000a            add.l     #$0000000A,d0
[00fd815e] 2040                      movea.l   d0,a0
[00fd8160] 4250                      clr.w     (a0)
[00fd8162] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd8164
xfd8164: ds.b 0
#if 0
[00fd8164] 4e56 fff0                 link      a6,#$FFF0
[00fd8168] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd816c] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd8172] 42ad 32aa                 clr.l     12970(a5)
[00fd8176] 42ad 32ae                 clr.l     12974(a5)
[00fd817a] 42ad 32b2                 clr.l     12978(a5)
[00fd817e] 3ebc 0001                 move.w    #1,(a7)
[00fd8182] f094                      dc.w      $F094 ; desk_wait
[00fd8184] 486e fffe                 pea.l     -2(a6)
[00fd8188] 486e fffe                 pea.l     -2(a6)
[00fd818c] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd8190] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd8194] 42a7                      clr.l     -(a7)
[00fd8196] 4267                      clr.w     -(a7)
[00fd8198] f3e0                      dc.w      $F3E0
[00fd819a] defc 0016                 adda.w    #$0016,a7
[00fd819e] 3d40 fff0                 move.w    d0,-16(a6)
[00fd81a2] 4257                      clr.w     (a7)
[00fd81a4] f094                      dc.w      $F094 ; desk_wait
[00fd81a6] 4a6e fff0                 tst.w     -16(a6)
[00fd81aa] 6604                      bne.s     $00FD81B0
[00fd81ac] 4240                      clr.w     d0
[00fd81ae] 6036                      bra.s     $00FD81E6
[00fd81b0] 53ad 32ae                 subq.l    #1,12974(a5)
[00fd81b4] 4257                      clr.w     (a7)
[00fd81b6] 3f2e 000c                 move.w    12(a6),-(a7)
[00fd81ba] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd81be] 486e fff8                 pea.l     -8(a6)
[00fd81c2] 486d 32aa                 pea.l     12970(a5)
[00fd81c6] f3c4                      dc.w      $F3C4
[00fd81c8] defc 000e                 adda.w    #$000E,a7
[00fd81cc] 4257                      clr.w     (a7)
[00fd81ce] 3f2e 000e                 move.w    14(a6),-(a7)
[00fd81d2] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd81d6] 486e fff2                 pea.l     -14(a6)
[00fd81da] 486d 32ae                 pea.l     12974(a5)
[00fd81de] f3c4                      dc.w      $F3C4
[00fd81e0] defc 000e                 adda.w    #$000E,a7
[00fd81e4] 7001                      moveq.l   #1,d0
[00fd81e6] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd81e8
xfd81e8: ds.b 0
#if 0
[00fd81e8] 4e56 fff0                 link      a6,#$FFF0
[00fd81ec] 4a6e 0016                 tst.w     22(a6)
[00fd81f0] 671e                      beq.s     $00FD8210
[00fd81f2] 2eae 000c                 move.l    12(a6),(a7)
[00fd81f6] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd81fa] f3b4                      dc.w      $F3B4 ; fmt_str
[00fd81fc] 588f                      addq.l    #4,a7
[00fd81fe] 2eae 000c                 move.l    12(a6),(a7)
[00fd8202] 3f2e 0014                 move.w    20(a6),-(a7)
[00fd8206] 2f2e 0010                 move.l    16(a6),-(a7)
[00fd820a] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd820c] 5c8f                      addq.l    #6,a7
[00fd820e] 6072                      bra.s     $00FD8282
[00fd8210] 2eae 0008                 move.l    8(a6),(a7)
[00fd8214] 2f3c 00fe b147            move.l    #$00FEB147,-(a7)
[00fd821a] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd821e] f498                      dc.w      $F498 ; merge_str
[00fd8220] 508f                      addq.l    #8,a7
[00fd8222] 302e 0014                 move.w    20(a6),d0
[00fd8226] c1fc 0018                 muls.w    #24,d0
[00fd822a] d0ae 0010                 add.l     16(a6),d0
[00fd822e] d0bc 0000 000c            add.l     #$0000000C,d0
[00fd8234] 2040                      movea.l   d0,a0
[00fd8236] 2d50 fff4                 move.l    (a0),-12(a6)
[00fd823a] 206e fff4                 movea.l   -12(a6),a0
[00fd823e] 2d50 fffc                 move.l    (a0),-4(a6)
[00fd8242] 206e fff4                 movea.l   -12(a6),a0
[00fd8246] 3028 0018                 move.w    24(a0),d0
[00fd824a] 5340                      subq.w    #1,d0
[00fd824c] 3d40 fffa                 move.w    d0,-6(a6)
[00fd8250] 2eae fffc                 move.l    -4(a6),(a7)
[00fd8254] 3f3c 0020                 move.w    #$0020,-(a7)
[00fd8258] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fd825c] f358                      dc.w      $F358 ; bfill
[00fd825e] 588f                      addq.l    #4,a7
[00fd8260] 2eae 000c                 move.l    12(a6),(a7)
[00fd8264] f24c                      dc.w      $F24C ; strlen
[00fd8266] 3d40 fff8                 move.w    d0,-8(a6)
[00fd826a] 302e fffa                 move.w    -6(a6),d0
[00fd826e] 906e fff8                 sub.w     -8(a6),d0
[00fd8272] 48c0                      ext.l     d0
[00fd8274] d0ae fffc                 add.l     -4(a6),d0
[00fd8278] 2e80                      move.l    d0,(a7)
[00fd827a] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd827e] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8280] 588f                      addq.l    #4,a7
[00fd8282] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd8284
xfd8284: ds.b 0
#if 0
[00fd8284] 4e56 ffe6                 link      a6,#$FFE6
[00fd8288] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd828c] 2a6e 000c                 movea.l   12(a6),a5
[00fd8290] 286e 0016                 movea.l   22(a6),a4
[00fd8294] 486e ffe6                 pea.l     -26(a6)
[00fd8298] 3f2d 000c                 move.w    12(a5),-(a7)
[00fd829c] f510                      dc.w      $F510 ; fmt_date
[00fd829e] 5c8f                      addq.l    #6,a7
[00fd82a0] 486e ffe6                 pea.l     -26(a6)
[00fd82a4] 3f2e 0010                 move.w    16(a6),-(a7)
[00fd82a8] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd82ac] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd82ae] defc 000a                 adda.w    #10,a7
[00fd82b2] 486e ffee                 pea.l     -18(a6)
[00fd82b6] 3f2d 000a                 move.w    10(a5),-(a7)
[00fd82ba] f514                      dc.w      $F514 ; fmt_time
[00fd82bc] 5c8f                      addq.l    #6,a7
[00fd82be] 486e ffee                 pea.l     -18(a6)
[00fd82c2] 3f2e 0012                 move.w    18(a6),-(a7)
[00fd82c6] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd82ca] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd82cc] defc 000a                 adda.w    #10,a7
[00fd82d0] 4257                      clr.w     (a7)
[00fd82d2] 3f2e 0014                 move.w    20(a6),-(a7)
[00fd82d6] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd82da] 486e fff6                 pea.l     -10(a6)
[00fd82de] 2f0c                      move.l    a4,-(a7)
[00fd82e0] f3c4                      dc.w      $F3C4
[00fd82e2] defc 000e                 adda.w    #$000E,a7
[00fd82e6] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfd82e8
xfd82e8: ds.b 0
#if 0
[00fd82e8] 4e56 ffdc                 link      a6,#$FFDC
[00fd82ec] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fd82f0] 2a6e 000c                 movea.l   12(a6),a5
[00fd82f4] 2679 0000 a788            movea.l   _thedesk,a3
[00fd82fa] 2e2b 355a                 move.l    13658(a3),d7
[00fd82fe] 486b 3016                 pea.l     12310(a3)
[00fd8302] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd8306] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8308] 508f                      addq.l    #8,a7
[00fd830a] 486b 3096                 pea.l     12438(a3)
[00fd830e] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd8312] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8314] 508f                      addq.l    #8,a7
[00fd8316] 4244                      clr.w     d4
[00fd8318] 6002                      bra.s     $00FD831C
[00fd831a] 5244                      addq.w    #1,d4
[00fd831c] 204b                      movea.l   a3,a0
[00fd831e] 3244                      movea.w   d4,a1
[00fd8320] d1c9                      adda.l    a1,a0
[00fd8322] 0c28 002a 3016            cmpi.b    #$2A,12310(a0)
[00fd8328] 66f0                      bne.s     $00FD831A
[00fd832a] 4a6e 0010                 tst.w     16(a6)
[00fd832e] 6668                      bne.s     $00FD8398
[00fd8330] 4257                      clr.w     (a7)
[00fd8332] 2f3c 0001 0001            move.l    #$00010001,-(a7)
[00fd8338] 102d 0009                 move.b    9(a5),d0
[00fd833c] 4880                      ext.w     d0
[00fd833e] 3f00                      move.w    d0,-(a7)
[00fd8340] 3f3c 0008                 move.w    #$0008,-(a7)
[00fd8344] 2f07                      move.l    d7,-(a7)
[00fd8346] f528                      dc.w      $F528 ; inf_fldset
[00fd8348] defc 000c                 adda.w    #12,a7
[00fd834c] 3ebc 0001                 move.w    #1,(a7)
[00fd8350] 4267                      clr.w     -(a7)
[00fd8352] 3f3c 0001                 move.w    #1,-(a7)
[00fd8356] 102d 0009                 move.b    9(a5),d0
[00fd835a] 4880                      ext.w     d0
[00fd835c] 3f00                      move.w    d0,-(a7)
[00fd835e] 3f3c 0009                 move.w    #$0009,-(a7)
[00fd8362] 2f07                      move.l    d7,-(a7)
[00fd8364] f528                      dc.w      $F528 ; inf_fldset
[00fd8366] defc 000c                 adda.w    #12,a7
[00fd836a] 2ebc 00fe b14a            move.l    #$00FEB14A,(a7)
[00fd8370] 3f3c 0007                 move.w    #$0007,-(a7)
[00fd8374] 2f07                      move.l    d7,-(a7)
[00fd8376] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd8378] 5c8f                      addq.l    #6,a7
[00fd837a] 2ebc 00fe b150            move.l    #$00FEB150,(a7)
[00fd8380] 3f3c 0006                 move.w    #$0006,-(a7)
[00fd8384] 2f07                      move.l    d7,-(a7)
[00fd8386] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd8388] 5c8f                      addq.l    #6,a7
[00fd838a] 3d7c 0006 ffdc            move.w    #$0006,-36(a6)
[00fd8390] 276d 000e 32b2            move.l    14(a5),12978(a3)
[00fd8396] 6042                      bra.s     $00FD83DA
[00fd8398] 2047                      movea.l   d7,a0
[00fd839a] d1fc 0000 00ca            adda.l    #$000000CA,a0
[00fd83a0] 30bc 0008                 move.w    #$0008,(a0)
[00fd83a4] 2047                      movea.l   d7,a0
[00fd83a6] d1fc 0000 00e2            adda.l    #$000000E2,a0
[00fd83ac] 30bc 0008                 move.w    #$0008,(a0)
[00fd83b0] 486d 0012                 pea.l     18(a5)
[00fd83b4] 486b 3016                 pea.l     12310(a3)
[00fd83b8] f3dc                      dc.w      $F3DC
[00fd83ba] 508f                      addq.l    #8,a7
[00fd83bc] 3d7c 0007 ffdc            move.w    #$0007,-36(a6)
[00fd83c2] 486b 3016                 pea.l     12310(a3)
[00fd83c6] 2f3c 0007 0006            move.l    #$00070006,-(a7)
[00fd83cc] 2f07                      move.l    d7,-(a7)
[00fd83ce] f52c                      dc.w      $F52C
[00fd83d0] defc 000c                 adda.w    #12,a7
[00fd83d4] 4a40                      tst.w     d0
[00fd83d6] 6700 015e                 beq       $00FD8536
[00fd83da] 486e ffe0                 pea.l     -32(a6)
[00fd83de] 3f2e ffdc                 move.w    -36(a6),-(a7)
[00fd83e2] 3f3c 0005                 move.w    #$0005,-(a7)
[00fd83e6] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fd83e8] 508f                      addq.l    #8,a7
[00fd83ea] 207c 0000 0024            movea.l   #$00000024,a0
[00fd83f0] 2070 7800                 movea.l   0(a0,d7.l),a0
[00fd83f4] 20ae ffe0                 move.l    -32(a6),(a0)
[00fd83f8] 486b 32b2                 pea.l     12978(a3)
[00fd83fc] 2f3c 0005 0003            move.l    #$00050003,-(a7)
[00fd8402] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd8406] 2f0d                      move.l    a5,-(a7)
[00fd8408] 2f07                      move.l    d7,-(a7)
[00fd840a] f530                      dc.w      $F530
[00fd840c] defc 0012                 adda.w    #$0012,a7
[00fd8410] 3ebc 0001                 move.w    #1,(a7)
[00fd8414] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd8418] 2f07                      move.l    d7,-(a7)
[00fd841a] 486e fff2                 pea.l     -14(a6)
[00fd841e] 486d 0012                 pea.l     18(a5)
[00fd8422] f3c4                      dc.w      $F3C4
[00fd8424] defc 000e                 adda.w    #$000E,a7
[00fd8428] 4245                      clr.w     d5
[00fd842a] 4257                      clr.w     (a7)
[00fd842c] 2f07                      move.l    d7,-(a7)
[00fd842e] f4c4                      dc.w      $F4C4
[00fd8430] 588f                      addq.l    #4,a7
[00fd8432] b07c 000b                 cmp.w     #$000B,d0
[00fd8436] 6600 00fc                 bne       $00FD8534
[00fd843a] 3ebc 0001                 move.w    #1,(a7)
[00fd843e] f094                      dc.w      $F094 ; desk_wait
[00fd8440] 486e ffe4                 pea.l     -28(a6)
[00fd8444] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd8448] 2f07                      move.l    d7,-(a7)
[00fd844a] f42c                      dc.w      $F42C ; fs_sget
[00fd844c] defc 000a                 adda.w    #10,a7
[00fd8450] 200b                      move.l    a3,d0
[00fd8452] 3204                      move.w    d4,d1
[00fd8454] 48c1                      ext.l     d1
[00fd8456] d081                      add.l     d1,d0
[00fd8458] 2e80                      move.l    d0,(a7)
[00fd845a] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd8460] 486e fff2                 pea.l     -14(a6)
[00fd8464] f430                      dc.w      $F430 ; unfmt_str
[00fd8466] 588f                      addq.l    #4,a7
[00fd8468] 200b                      move.l    a3,d0
[00fd846a] 3204                      move.w    d4,d1
[00fd846c] 48c1                      ext.l     d1
[00fd846e] d081                      add.l     d1,d0
[00fd8470] 2e80                      move.l    d0,(a7)
[00fd8472] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd8478] 486e ffe4                 pea.l     -28(a6)
[00fd847c] f430                      dc.w      $F430 ; unfmt_str
[00fd847e] 588f                      addq.l    #4,a7
[00fd8480] 200b                      move.l    a3,d0
[00fd8482] 3204                      move.w    d4,d1
[00fd8484] 48c1                      ext.l     d1
[00fd8486] d081                      add.l     d1,d0
[00fd8488] 2e80                      move.l    d0,(a7)
[00fd848a] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd8490] 200b                      move.l    a3,d0
[00fd8492] 3204                      move.w    d4,d1
[00fd8494] 48c1                      ext.l     d1
[00fd8496] d081                      add.l     d1,d0
[00fd8498] 2f00                      move.l    d0,-(a7)
[00fd849a] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd84a0] f39c                      dc.w      $F39C ; streq
[00fd84a2] 588f                      addq.l    #4,a7
[00fd84a4] 4a40                      tst.w     d0
[00fd84a6] 663c                      bne.s     $00FD84E4
[00fd84a8] 486b 3096                 pea.l     12438(a3)
[00fd84ac] 486b 3016                 pea.l     12310(a3)
[00fd84b0] f41c                      dc.w      $F41C ; dos_rename
[00fd84b2] 508f                      addq.l    #8,a7
[00fd84b4] 0c79 ffdc 0000 6e20       cmpi.w    #$FFDC,_DOS_AX
[00fd84bc] 6608                      bne.s     $00FD84C6
[00fd84be] 3ebc 0005                 move.w    #$0005,(a7)
[00fd84c2] f0e8                      dc.w      $F0E8 ; form_error
[00fd84c4] 601e                      bra.s     $00FD84E4
[00fd84c6] f374                      dc.w      $F374 ; dos_error
[00fd84c8] 3a00                      move.w    d0,d5
[00fd84ca] 6718                      beq.s     $00FD84E4
[00fd84cc] 486d 0012                 pea.l     18(a5)
[00fd84d0] 200b                      move.l    a3,d0
[00fd84d2] 3204                      move.w    d4,d1
[00fd84d4] 48c1                      ext.l     d1
[00fd84d6] d081                      add.l     d1,d0
[00fd84d8] 2f00                      move.l    d0,-(a7)
[00fd84da] 0697 0000 3096            addi.l    #$00003096,(a7)
[00fd84e0] f36c                      dc.w      $F36C ; xstrpcpy
[00fd84e2] 508f                      addq.l    #8,a7
[00fd84e4] 1c2d 0009                 move.b    9(a5),d6
[00fd84e8] 4886                      ext.w     d6
[00fd84ea] 2047                      movea.l   d7,a0
[00fd84ec] d1fc 0000 00cb            adda.l    #$000000CB,a0
[00fd84f2] 0810 0000                 btst      #0,(a0)
[00fd84f6] 6706                      beq.s     $00FD84FE
[00fd84f8] 8c7c 0001                 or.w      #1,d6
[00fd84fc] 6004                      bra.s     $00FD8502
[00fd84fe] cc7c fffe                 and.w     #$FFFE,d6
[00fd8502] 4a6e 0010                 tst.w     16(a6)
[00fd8506] 6622                      bne.s     $00FD852A
[00fd8508] 3006                      move.w    d6,d0
[00fd850a] 4880                      ext.w     d0
[00fd850c] b02d 0009                 cmp.b     9(a5),d0
[00fd8510] 6718                      beq.s     $00FD852A
[00fd8512] 3e86                      move.w    d6,(a7)
[00fd8514] 3f3c 0001                 move.w    #1,-(a7)
[00fd8518] 486b 3096                 pea.l     12438(a3)
[00fd851c] f534                      dc.w      $F534 ; dos_chmod
[00fd851e] 5c8f                      addq.l    #6,a7
[00fd8520] f374                      dc.w      $F374 ; dos_error
[00fd8522] 3a00                      move.w    d0,d5
[00fd8524] 6704                      beq.s     $00FD852A
[00fd8526] 1b46 0009                 move.b    d6,9(a5)
[00fd852a] 4257                      clr.w     (a7)
[00fd852c] f094                      dc.w      $F094 ; desk_wait
[00fd852e] 3005                      move.w    d5,d0
[00fd8530] 6004                      bra.s     $00FD8536
[00fd8532] 6002                      bra.s     $00FD8536
[00fd8534] 4240                      clr.w     d0
[00fd8536] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef xfd8538
xfd8538: ds.b 0
#if 0
[00fd8538] 4e56 ffc6                 link      a6,#$FFC6
[00fd853c] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd8540] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd8546] 2e2d 355e                 move.l    13662(a5),d7
[00fd854a] 1d6e 0009 ffd2            move.b    9(a6),-46(a6)
[00fd8550] 422e ffd3                 clr.b     -45(a6)
[00fd8554] 1b6e ffd2 3016            move.b    -46(a6),12310(a5)
[00fd855a] 486d 3017                 pea.l     12311(a5)
[00fd855e] 2f3c 00fe b156            move.l    #$00FEB156,-(a7)
[00fd8564] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8566] 508f                      addq.l    #8,a7
[00fd8568] 486d 3016                 pea.l     12310(a5)
[00fd856c] 2f3c 0004 0003            move.l    #$00040003,-(a7)
[00fd8572] 2f07                      move.l    d7,-(a7)
[00fd8574] f52c                      dc.w      $F52C
[00fd8576] defc 000c                 adda.w    #12,a7
[00fd857a] 4a40                      tst.w     d0
[00fd857c] 6700 00a0                 beq       $00FD861E
[00fd8580] 3ebc 0001                 move.w    #1,(a7)
[00fd8584] f094                      dc.w      $F094 ; desk_wait
[00fd8586] 486e fff8                 pea.l     -8(a6)
[00fd858a] 486e fffc                 pea.l     -4(a6)
[00fd858e] 102e 0009                 move.b    9(a6),d0
[00fd8592] 4880                      ext.w     d0
[00fd8594] 3f00                      move.w    d0,-(a7)
[00fd8596] 0657 ffc0                 addi.w    #$FFC0,(a7)
[00fd859a] f464                      dc.w      $F464
[00fd859c] defc 000a                 adda.w    #10,a7
[00fd85a0] 422e ffd4                 clr.b     -44(a6)
[00fd85a4] 486e ffd4                 pea.l     -44(a6)
[00fd85a8] 102e 0009                 move.b    9(a6),d0
[00fd85ac] 4880                      ext.w     d0
[00fd85ae] 3f00                      move.w    d0,-(a7)
[00fd85b0] 0657 ffc0                 addi.w    #$FFC0,(a7)
[00fd85b4] f538                      dc.w      $F538 ; dos_label
[00fd85b6] 5c8f                      addq.l    #6,a7
[00fd85b8] 486e ffc6                 pea.l     -58(a6)
[00fd85bc] 486e ffd4                 pea.l     -44(a6)
[00fd85c0] f3b4                      dc.w      $F3B4 ; fmt_str
[00fd85c2] 508f                      addq.l    #8,a7
[00fd85c4] 486e ffd2                 pea.l     -46(a6)
[00fd85c8] 3f3c 0001                 move.w    #1,-(a7)
[00fd85cc] 2f07                      move.l    d7,-(a7)
[00fd85ce] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd85d0] defc 000a                 adda.w    #10,a7
[00fd85d4] 486e ffc6                 pea.l     -58(a6)
[00fd85d8] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd85dc] 2f07                      move.l    d7,-(a7)
[00fd85de] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd85e0] defc 000a                 adda.w    #10,a7
[00fd85e4] 4257                      clr.w     (a7)
[00fd85e6] 3f3c 0005                 move.w    #$0005,-(a7)
[00fd85ea] 2f07                      move.l    d7,-(a7)
[00fd85ec] 486e ffea                 pea.l     -22(a6)
[00fd85f0] 486d 32b2                 pea.l     12978(a5)
[00fd85f4] f3c4                      dc.w      $F3C4
[00fd85f6] defc 000e                 adda.w    #$000E,a7
[00fd85fa] 4257                      clr.w     (a7)
[00fd85fc] 3f3c 0006                 move.w    #$0006,-(a7)
[00fd8600] 2f07                      move.l    d7,-(a7)
[00fd8602] 486e ffe0                 pea.l     -32(a6)
[00fd8606] 486e fff8                 pea.l     -8(a6)
[00fd860a] f3c4                      dc.w      $F3C4
[00fd860c] defc 000e                 adda.w    #$000E,a7
[00fd8610] 4257                      clr.w     (a7)
[00fd8612] f094                      dc.w      $F094 ; desk_wait
[00fd8614] 3ebc 0007                 move.w    #$0007,(a7)
[00fd8618] 2f07                      move.l    d7,-(a7)
[00fd861a] f53c                      dc.w      $F53C
[00fd861c] 588f                      addq.l    #4,a7
[00fd861e] 7001                      moveq.l   #1,d0
[00fd8620] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd8622
xfd8622: ds.b 0
#if 0
[00fd8622] 4e56 fffe                 link      a6,#$FFFE
[00fd8626] 48e7 1f04                 movem.l   d3-d7/a5,-(a7)
[00fd862a] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd8630] 2e2d 357e                 move.l    13694(a5),d7
[00fd8634] 3c2d 35a2                 move.w    13730(a5),d6
[00fd8638] 2047                      movea.l   d7,a0
[00fd863a] d1fc 0000 006a            adda.l    #$0000006A,a0
[00fd8640] 3086                      move.w    d6,(a0)
[00fd8642] 4a46                      tst.w     d6
[00fd8644] 6704                      beq.s     $00FD864A
[00fd8646] 4240                      clr.w     d0
[00fd8648] 6002                      bra.s     $00FD864C
[00fd864a] 7001                      moveq.l   #1,d0
[00fd864c] 2247                      movea.l   d7,a1
[00fd864e] d3fc 0000 0082            adda.l    #$00000082,a1
[00fd8654] 3280                      move.w    d0,(a1)
[00fd8656] 3c2d 35a6                 move.w    13734(a5),d6
[00fd865a] 4a46                      tst.w     d6
[00fd865c] 6704                      beq.s     $00FD8662
[00fd865e] 4240                      clr.w     d0
[00fd8660] 6002                      bra.s     $00FD8664
[00fd8662] 7001                      moveq.l   #1,d0
[00fd8664] 2247                      movea.l   d7,a1
[00fd8666] d3fc 0000 00fa            adda.l    #$000000FA,a1
[00fd866c] 3280                      move.w    d0,(a1)
[00fd866e] 2047                      movea.l   d7,a0
[00fd8670] d1fc 0000 0112            adda.l    #$00000112,a0
[00fd8676] 3086                      move.w    d6,(a0)
[00fd8678] 3c2d 35a0                 move.w    13728(a5),d6
[00fd867c] 2047                      movea.l   d7,a0
[00fd867e] d1fc 0000 00b2            adda.l    #$000000B2,a0
[00fd8684] 3086                      move.w    d6,(a0)
[00fd8686] 4a46                      tst.w     d6
[00fd8688] 6704                      beq.s     $00FD868E
[00fd868a] 4240                      clr.w     d0
[00fd868c] 6002                      bra.s     $00FD8690
[00fd868e] 7001                      moveq.l   #1,d0
[00fd8690] 2247                      movea.l   d7,a1
[00fd8692] d3fc 0000 00ca            adda.l    #$000000CA,a1
[00fd8698] 3280                      move.w    d0,(a1)
[00fd869a] 4245                      clr.w     d5
[00fd869c] 6018                      bra.s     $00FD86B6
[00fd869e] 2047                      movea.l   d7,a0
[00fd86a0] 3205                      move.w    d5,d1
[00fd86a2] d27c 000e                 add.w     #$000E,d1
[00fd86a6] c3fc 0018                 muls.w    #24,d1
[00fd86aa] d1c1                      adda.l    d1,a0
[00fd86ac] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fd86b2] 4250                      clr.w     (a0)
[00fd86b4] 5245                      addq.w    #1,d5
[00fd86b6] ba7c 0003                 cmp.w     #$0003,d5
[00fd86ba] 6de2                      blt.s     $00FD869E
[00fd86bc] 3ebc 0004                 move.w    #$0004,(a7)
[00fd86c0] f0ec                      dc.w      $F0EC ; trp14
[00fd86c2] 3800                      move.w    d0,d4
[00fd86c4] b87c 0002                 cmp.w     #$0002,d4
[00fd86c8] 670e                      beq.s     $00FD86D8
[00fd86ca] 2047                      movea.l   d7,a0
[00fd86cc] d1fc 0000 018a            adda.l    #$0000018A,a0
[00fd86d2] 30bc 0008                 move.w    #$0008,(a0)
[00fd86d6] 6018                      bra.s     $00FD86F0
[00fd86d8] 2047                      movea.l   d7,a0
[00fd86da] d1fc 0000 015a            adda.l    #$0000015A,a0
[00fd86e0] 30bc 0008                 move.w    #$0008,(a0)
[00fd86e4] 2047                      movea.l   d7,a0
[00fd86e6] d1fc 0000 0172            adda.l    #$00000172,a0
[00fd86ec] 30bc 0008                 move.w    #$0008,(a0)
[00fd86f0] 3839 0000 6122            move.w    $00006122,d4
[00fd86f6] 5544                      subq.w    #2,d4
[00fd86f8] 2047                      movea.l   d7,a0
[00fd86fa] 3204                      move.w    d4,d1
[00fd86fc] d27c 000e                 add.w     #$000E,d1
[00fd8700] c3fc 0018                 muls.w    #24,d1
[00fd8704] d1c1                      adda.l    d1,a0
[00fd8706] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fd870c] 30bc 0001                 move.w    #1,(a0)
[00fd8710] 4257                      clr.w     (a7)
[00fd8712] 2f07                      move.l    d7,-(a7)
[00fd8714] f4c4                      dc.w      $F4C4
[00fd8716] 588f                      addq.l    #4,a7
[00fd8718] b07c 0011                 cmp.w     #$0011,d0
[00fd871c] 665e                      bne.s     $00FD877C
[00fd871e] 3ebc 0005                 move.w    #$0005,(a7)
[00fd8722] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd8726] 2f07                      move.l    d7,-(a7)
[00fd8728] f3d4                      dc.w      $F3D4 ; inf_what
[00fd872a] 5c8f                      addq.l    #6,a7
[00fd872c] 3b40 35a2                 move.w    d0,13730(a5)
[00fd8730] 3ebc 0008                 move.w    #$0008,(a7)
[00fd8734] 3f3c 0007                 move.w    #$0007,-(a7)
[00fd8738] 2f07                      move.l    d7,-(a7)
[00fd873a] f3d4                      dc.w      $F3D4 ; inf_what
[00fd873c] 5c8f                      addq.l    #6,a7
[00fd873e] 3b40 35a0                 move.w    d0,13728(a5)
[00fd8742] 3ebc 000b                 move.w    #$000B,(a7)
[00fd8746] 3f3c 000a                 move.w    #10,-(a7)
[00fd874a] 2f07                      move.l    d7,-(a7)
[00fd874c] f3d4                      dc.w      $F3D4 ; inf_what
[00fd874e] 5c8f                      addq.l    #6,a7
[00fd8750] 4a40                      tst.w     d0
[00fd8752] 6704                      beq.s     $00FD8758
[00fd8754] 4240                      clr.w     d0
[00fd8756] 6002                      bra.s     $00FD875A
[00fd8758] 7001                      moveq.l   #1,d0
[00fd875a] 3b40 35a6                 move.w    d0,13734(a5)
[00fd875e] 3ebc 0003                 move.w    #$0003,(a7)
[00fd8762] 3f3c 000e                 move.w    #$000E,-(a7)
[00fd8766] 2f07                      move.l    d7,-(a7)
[00fd8768] f540                      dc.w      $F540 ; inf_gindex
[00fd876a] 5c8f                      addq.l    #6,a7
[00fd876c] 3800                      move.w    d0,d4
[00fd876e] 5444                      addq.w    #2,d4
[00fd8770] 3e84                      move.w    d4,(a7)
[00fd8772] f544                      dc.w      $F544 ; app_reschange
[00fd8774] 4a40                      tst.w     d0
[00fd8776] 6704                      beq.s     $00FD877C
[00fd8778] 7001                      moveq.l   #1,d0
[00fd877a] 6002                      bra.s     $00FD877E
[00fd877c] 4240                      clr.w     d0
[00fd877e] f83d                      dc.w      $F83D ; movem.l (a7)+,d4-d7/a5
#endif

	xdef _desk_dfree
_desk_dfree: ds.b 0
#if 0
[00fd8780] 4e56 ffe8                 link      a6,#$FFE8
[00fd8784] 3eae 0008                 move.w    8(a6),(a7)
[00fd8788] 486e fff0                 pea.l     -16(a6)
[00fd878c] 3f3c 0036                 move.w    #$0036,-(a7)
[00fd8790] f0d8                      dc.w      $F0D8 ; trap
[00fd8792] 5c8f                      addq.l    #6,a7
[00fd8794] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd8798] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd879c] 4eb9 00fd d34a            jsr       aeslmul
[00fd87a2] 508f                      addq.l    #8,a7
[00fd87a4] 2d40 ffec                 move.l    d0,-20(a6)
[00fd87a8] 2f2e ffec                 move.l    -20(a6),-(a7)
[00fd87ac] 2f2e fff4                 move.l    -12(a6),-(a7)
[00fd87b0] 4eb9 00fd d34a            jsr       aeslmul
[00fd87b6] 508f                      addq.l    #8,a7
[00fd87b8] 2f00                      move.l    d0,-(a7)
[00fd87ba] 206e 000a                 movea.l   10(a6),a0
[00fd87be] 209f                      move.l    (a7)+,(a0)
[00fd87c0] 2f2e ffec                 move.l    -20(a6),-(a7)
[00fd87c4] 2f2e fff0                 move.l    -16(a6),-(a7)
[00fd87c8] 4eb9 00fd d34a            jsr       aeslmul
[00fd87ce] 508f                      addq.l    #8,a7
[00fd87d0] 2f00                      move.l    d0,-(a7)
[00fd87d2] 206e 000e                 movea.l   14(a6),a0
[00fd87d6] 209f                      move.l    (a7)+,(a0)
[00fd87d8] 7001                      moveq.l   #1,d0
[00fd87da] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd87dc
xfd87dc: ds.b 0
#if 0
[00fd87dc] 4e56 ffde                 link      a6,#$FFDE
[00fd87e0] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fd87e4] 2a6e 0008                 movea.l   8(a6),a5
[00fd87e8] 2079 0000 a788            movea.l   _thedesk,a0
[00fd87ee] 2e28 356a                 move.l    13674(a0),d7
[00fd87f2] 302d 0016                 move.w    22(a5),d0
[00fd87f6] 1d40 fffe                 move.b    d0,-2(a6)
[00fd87fa] 422e ffff                 clr.b     -1(a6)
[00fd87fe] 486e fff0                 pea.l     -16(a6)
[00fd8802] 2f2d 000a                 move.l    10(a5),-(a7)
[00fd8806] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8808] 508f                      addq.l    #8,a7
[00fd880a] 486e fffe                 pea.l     -2(a6)
[00fd880e] 3f3c 0001                 move.w    #1,-(a7)
[00fd8812] 2f07                      move.l    d7,-(a7)
[00fd8814] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd8816] defc 000a                 adda.w    #10,a7
[00fd881a] 486e fff0                 pea.l     -16(a6)
[00fd881e] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd8822] 2f07                      move.l    d7,-(a7)
[00fd8824] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd8826] defc 000a                 adda.w    #10,a7
[00fd882a] 4246                      clr.w     d6
[00fd882c] 4257                      clr.w     (a7)
[00fd882e] 2f07                      move.l    d7,-(a7)
[00fd8830] f4c4                      dc.w      $F4C4
[00fd8832] 588f                      addq.l    #4,a7
[00fd8834] 3d40 ffde                 move.w    d0,-34(a6)
[00fd8838] 486e ffee                 pea.l     -18(a6)
[00fd883c] 3f3c 0001                 move.w    #1,-(a7)
[00fd8840] 2f07                      move.l    d7,-(a7)
[00fd8842] f42c                      dc.w      $F42C ; fs_sget
[00fd8844] defc 000a                 adda.w    #10,a7
[00fd8848] 486e ffe0                 pea.l     -32(a6)
[00fd884c] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd8850] 2f07                      move.l    d7,-(a7)
[00fd8852] f42c                      dc.w      $F42C ; fs_sget
[00fd8854] defc 000a                 adda.w    #10,a7
[00fd8858] 0c6e 0005 ffde            cmpi.w    #$0005,-34(a6)
[00fd885e] 6606                      bne.s     $00FD8866
[00fd8860] 4240                      clr.w     d0
[00fd8862] 6000 01b0                 bra       $00FD8A14
[00fd8866] 0c2e 0020 ffee            cmpi.b    #$20,-18(a6)
[00fd886c] 6706                      beq.s     $00FD8874
[00fd886e] 4a2e ffee                 tst.b     -18(a6)
[00fd8872] 6606                      bne.s     $00FD887A
[00fd8874] 4240                      clr.w     d0
[00fd8876] 6000 019c                 bra       $00FD8A14
[00fd887a] 0c2e 0063 ffee            cmpi.b    #$63,-18(a6)
[00fd8880] 670e                      beq.s     $00FD8890
[00fd8882] 102e ffee                 move.b    -18(a6),d0
[00fd8886] 4880                      ext.w     d0
[00fd8888] 3e80                      move.w    d0,(a7)
[00fd888a] f548                      dc.w      $F548 ; toupper
[00fd888c] 1d40 ffee                 move.b    d0,-18(a6)
[00fd8890] 102e ffee                 move.b    -18(a6),d0
[00fd8894] 4880                      ext.w     d0
[00fd8896] b02e fffe                 cmp.b     -2(a6),d0
[00fd889a] 672c                      beq.s     $00FD88C8
[00fd889c] 2079 0000 a788            movea.l   _thedesk,a0
[00fd88a2] 2668 5a4a                 movea.l   23114(a0),a3
[00fd88a6] 4245                      clr.w     d5
[00fd88a8] 6018                      bra.s     $00FD88C2
[00fd88aa] 302b 0016                 move.w    22(a3),d0
[00fd88ae] 122e ffee                 move.b    -18(a6),d1
[00fd88b2] 4881                      ext.w     d1
[00fd88b4] b041                      cmp.w     d1,d0
[00fd88b6] 6608                      bne.s     $00FD88C0
[00fd88b8] 7a01                      moveq.l   #1,d5
[00fd88ba] 2a4b                      movea.l   a3,a5
[00fd88bc] 6008                      bra.s     $00FD88C6
[00fd88be] 6002                      bra.s     $00FD88C2
[00fd88c0] 2653                      movea.l   (a3),a3
[00fd88c2] 200b                      move.l    a3,d0
[00fd88c4] 66e4                      bne.s     $00FD88AA
[00fd88c6] 6002                      bra.s     $00FD88CA
[00fd88c8] 7a01                      moveq.l   #1,d5
[00fd88ca] 0c6e 0004 ffde            cmpi.w    #$0004,-34(a6)
[00fd88d0] 6612                      bne.s     $00FD88E4
[00fd88d2] 4a45                      tst.w     d5
[00fd88d4] 6704                      beq.s     $00FD88DA
[00fd88d6] 2e8d                      move.l    a5,(a7)
[00fd88d8] f54c                      dc.w      $F54C ; app_free
[00fd88da] 3005                      move.w    d5,d0
[00fd88dc] 6000 0136                 bra       $00FD8A14
[00fd88e0] 6000 0132                 bra       $00FD8A14
[00fd88e4] 4a45                      tst.w     d5
[00fd88e6] 6600 00ec                 bne       $00FD89D4
[00fd88ea] 7c01                      moveq.l   #1,d6
[00fd88ec] 4257                      clr.w     (a7)
[00fd88ee] f350                      dc.w      $F350 ; app_alloc
[00fd88f0] 2840                      movea.l   d0,a4
[00fd88f2] 200c                      move.l    a4,d0
[00fd88f4] 6700 00ce                 beq       $00FD89C4
[00fd88f8] 396d 0004 0004            move.w    4(a5),4(a4)
[00fd88fe] 0c2e 0063 ffee            cmpi.b    #$63,-18(a6)
[00fd8904] 6704                      beq.s     $00FD890A
[00fd8906] 7002                      moveq.l   #2,d0
[00fd8908] 6002                      bra.s     $00FD890C
[00fd890a] 7004                      moveq.l   #4,d0
[00fd890c] 3940 0006                 move.w    d0,6(a4)
[00fd8910] 396d 0008 0008            move.w    8(a5),8(a4)
[00fd8916] 396d 0012 0012            move.w    18(a5),18(a4)
[00fd891c] 397c ffff 0014            move.w    #$FFFF,20(a4)
[00fd8922] 3039 0000 7008            move.w    gl_width,d0
[00fd8928] 48c0                      ext.l     d0
[00fd892a] 81fc 0002                 divs.w    #$0002,d0
[00fd892e] b06d 0018                 cmp.w     24(a5),d0
[00fd8932] 6f14                      ble.s     $00FD8948
[00fd8934] 2079 0000 a788            movea.l   _thedesk,a0
[00fd893a] 3028 35ac                 move.w    13740(a0),d0
[00fd893e] d06d 0018                 add.w     24(a5),d0
[00fd8942] 3940 0018                 move.w    d0,24(a4)
[00fd8946] 6014                      bra.s     $00FD895C
[00fd8948] 302d 0018                 move.w    24(a5),d0
[00fd894c] 2279 0000 a788            movea.l   _thedesk,a1
[00fd8952] 3229 35ac                 move.w    13740(a1),d1
[00fd8956] 9041                      sub.w     d1,d0
[00fd8958] 3940 0018                 move.w    d0,24(a4)
[00fd895c] 3039 0000 6d90            move.w    gl_height,d0
[00fd8962] 9079 0000 6f18            sub.w     $00006F18,d0
[00fd8968] 48c0                      ext.l     d0
[00fd896a] 81fc 0002                 divs.w    #$0002,d0
[00fd896e] b06d 001a                 cmp.w     26(a5),d0
[00fd8972] 6f14                      ble.s     $00FD8988
[00fd8974] 2079 0000 a788            movea.l   _thedesk,a0
[00fd897a] 3028 35ae                 move.w    13742(a0),d0
[00fd897e] d06d 001a                 add.w     26(a5),d0
[00fd8982] 3940 001a                 move.w    d0,26(a4)
[00fd8986] 6014                      bra.s     $00FD899C
[00fd8988] 302d 001a                 move.w    26(a5),d0
[00fd898c] 2279 0000 a788            movea.l   _thedesk,a1
[00fd8992] 3229 35ae                 move.w    13742(a1),d1
[00fd8996] 9041                      sub.w     d1,d0
[00fd8998] 3940 001a                 move.w    d0,26(a4)
[00fd899c] 2079 0000 a788            movea.l   _thedesk,a0
[00fd89a2] 3028 35fe                 move.w    13822(a0),d0
[00fd89a6] d06d 001a                 add.w     26(a5),d0
[00fd89aa] 3940 001a                 move.w    d0,26(a4)
[00fd89ae] 486c 001a                 pea.l     26(a4)
[00fd89b2] 486c 0018                 pea.l     24(a4)
[00fd89b6] 2f2c 0018                 move.l    24(a4),-(a7)
[00fd89ba] f2bc                      dc.w      $F2BC ; app_mtoi
[00fd89bc] defc 000c                 adda.w    #12,a7
[00fd89c0] 2a4c                      movea.l   a4,a5
[00fd89c2] 6010                      bra.s     $00FD89D4
[00fd89c4] 4297                      clr.l     (a7)
[00fd89c6] 2f3c 0001 0023            move.l    #$00010023,-(a7)
[00fd89cc] f0dc                      dc.w      $F0DC ; fill_string
[00fd89ce] 588f                      addq.l    #4,a7
[00fd89d0] 4240                      clr.w     d0
[00fd89d2] 6040                      bra.s     $00FD8A14
[00fd89d4] 102e ffee                 move.b    -18(a6),d0
[00fd89d8] 4880                      ext.w     d0
[00fd89da] 3b40 0016                 move.w    d0,22(a5)
[00fd89de] 486e fff0                 pea.l     -16(a6)
[00fd89e2] 486e ffe0                 pea.l     -32(a6)
[00fd89e6] f39c                      dc.w      $F39C ; streq
[00fd89e8] 508f                      addq.l    #8,a7
[00fd89ea] 4a40                      tst.w     d0
[00fd89ec] 6602                      bne.s     $00FD89F0
[00fd89ee] 7c01                      moveq.l   #1,d6
[00fd89f0] 2e8e                      move.l    a6,(a7)
[00fd89f2] 0697 ffff ffe0            addi.l    #$FFFFFFE0,(a7)
[00fd89f8] f24c                      dc.w      $F24C ; strlen
[00fd89fa] 48c0                      ext.l     d0
[00fd89fc] d08e                      add.l     a6,d0
[00fd89fe] 2040                      movea.l   d0,a0
[00fd8a00] 117c 0040 ffe0            move.b    #$40,-32(a0)
[00fd8a06] 486d 000a                 pea.l     10(a5)
[00fd8a0a] 486e ffe0                 pea.l     -32(a6)
[00fd8a0e] f32c                      dc.w      $F32C ; escani_str
[00fd8a10] 508f                      addq.l    #8,a7
[00fd8a12] 3006                      move.w    d6,d0
[00fd8a14] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef xfd8a16
xfd8a16: ds.b 0
#if 0
[00fd8a16] 4e56 ff44                 link      a6,#$FF44
[00fd8a1a] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fd8a1e] 2a6e 000c                 movea.l   12(a6),a5
[00fd8a22] 2d79 0000 a788 ff48       move.l    _thedesk,-184(a6)
[00fd8a2a] 206e ff48                 movea.l   -184(a6),a0
[00fd8a2e] 2e28 356e                 move.l    13678(a0),d7
[00fd8a32] 206d 000a                 movea.l   10(a5),a0
[00fd8a36] 0c10 002a                 cmpi.b    #$2A,(a0)
[00fd8a3a] 670e                      beq.s     $00FD8A4A
[00fd8a3c] 206d 000a                 movea.l   10(a5),a0
[00fd8a40] 0c10 003f                 cmpi.b    #$3F,(a0)
[00fd8a44] 6704                      beq.s     $00FD8A4A
[00fd8a46] 4240                      clr.w     d0
[00fd8a48] 6002                      bra.s     $00FD8A4C
[00fd8a4a] 7001                      moveq.l   #1,d0
[00fd8a4c] 3d40 ffce                 move.w    d0,-50(a6)
[00fd8a50] 486e fff4                 pea.l     -12(a6)
[00fd8a54] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd8a58] f3b4                      dc.w      $F3B4 ; fmt_str
[00fd8a5a] 508f                      addq.l    #8,a7
[00fd8a5c] 266d 000e                 movea.l   14(a5),a3
[00fd8a60] 3ebc 002e                 move.w    #$002E,(a7)
[00fd8a64] 2f0b                      move.l    a3,-(a7)
[00fd8a66] f480                      dc.w      $F480 ; scasb
[00fd8a68] 588f                      addq.l    #4,a7
[00fd8a6a] 2640                      movea.l   d0,a3
[00fd8a6c] 0c13 002e                 cmpi.b    #$2E,(a3)
[00fd8a70] 6602                      bne.s     $00FD8A74
[00fd8a72] 528b                      addq.l    #1,a3
[00fd8a74] 486e fff0                 pea.l     -16(a6)
[00fd8a78] 2f0b                      move.l    a3,-(a7)
[00fd8a7a] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8a7c] 508f                      addq.l    #8,a7
[00fd8a7e] 486e fff4                 pea.l     -12(a6)
[00fd8a82] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd8a86] 2f07                      move.l    d7,-(a7)
[00fd8a88] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd8a8a] defc 000a                 adda.w    #10,a7
[00fd8a8e] 486e fff0                 pea.l     -16(a6)
[00fd8a92] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd8a96] 2f07                      move.l    d7,-(a7)
[00fd8a98] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd8a9a] defc 000a                 adda.w    #10,a7
[00fd8a9e] 3d6d 0004 ffd6            move.w    4(a5),-42(a6)
[00fd8aa4] 082d 0000 0005            btst      #0,5(a5)
[00fd8aaa] 670e                      beq.s     $00FD8ABA
[00fd8aac] 2047                      movea.l   d7,a0
[00fd8aae] d1fc 0000 00e2            adda.l    #$000000E2,a0
[00fd8ab4] 30bc 0001                 move.w    #1,(a0)
[00fd8ab8] 6022                      bra.s     $00FD8ADC
[00fd8aba] 082d 0003 0005            btst      #3,5(a5)
[00fd8ac0] 670e                      beq.s     $00FD8AD0
[00fd8ac2] 2047                      movea.l   d7,a0
[00fd8ac4] d1fc 0000 0112            adda.l    #$00000112,a0
[00fd8aca] 30bc 0001                 move.w    #1,(a0)
[00fd8ace] 600c                      bra.s     $00FD8ADC
[00fd8ad0] 2047                      movea.l   d7,a0
[00fd8ad2] d1fc 0000 00fa            adda.l    #$000000FA,a0
[00fd8ad8] 30bc 0001                 move.w    #1,(a0)
[00fd8adc] 206e ff48                 movea.l   -184(a6),a0
[00fd8ae0] 3ea8 3598                 move.w    13720(a0),(a7)
[00fd8ae4] f2ec                      dc.w      $F2EC
[00fd8ae6] 2d40 ff4e                 move.l    d0,-178(a6)
[00fd8aea] 3ebc 0020                 move.w    #$0020,(a7)
[00fd8aee] 486e ff52                 pea.l     -174(a6)
[00fd8af2] 2f2e ff4e                 move.l    -178(a6),-(a7)
[00fd8af6] 0697 0000 001d            addi.l    #$0000001D,(a7)
[00fd8afc] f550                      dc.w      $F550 ; strscn
[00fd8afe] 508f                      addq.l    #8,a7
[00fd8b00] 2d40 ff44                 move.l    d0,-188(a6)
[00fd8b04] 206e ff44                 movea.l   -188(a6),a0
[00fd8b08] 4210                      clr.b     (a0)
[00fd8b0a] 486e ffde                 pea.l     -34(a6)
[00fd8b0e] 486e fff4                 pea.l     -12(a6)
[00fd8b12] f430                      dc.w      $F430 ; unfmt_str
[00fd8b14] 508f                      addq.l    #8,a7
[00fd8b16] 206e ff44                 movea.l   -188(a6),a0
[00fd8b1a] 0c28 005c ffff            cmpi.b    #$5C,-1(a0)
[00fd8b20] 660c                      bne.s     $00FD8B2E
[00fd8b22] 486e ff52                 pea.l     -174(a6)
[00fd8b26] 486e ffde                 pea.l     -34(a6)
[00fd8b2a] f404                      dc.w      $F404 ; xstrpcat
[00fd8b2c] 508f                      addq.l    #8,a7
[00fd8b2e] 426e ffcc                 clr.w     -52(a6)
[00fd8b32] 2047                      movea.l   d7,a0
[00fd8b34] d1fc 0000 0082            adda.l    #$00000082,a0
[00fd8b3a] 4250                      clr.w     (a0)
[00fd8b3c] 2047                      movea.l   d7,a0
[00fd8b3e] d1fc 0000 009a            adda.l    #$0000009A,a0
[00fd8b44] 4250                      clr.w     (a0)
[00fd8b46] 2eae ff48                 move.l    -184(a6),(a7)
[00fd8b4a] 0697 0000 76eb            addi.l    #$000076EB,(a7)
[00fd8b50] 486e ff52                 pea.l     -174(a6)
[00fd8b54] f39c                      dc.w      $F39C ; streq
[00fd8b56] 588f                      addq.l    #4,a7
[00fd8b58] 4a40                      tst.w     d0
[00fd8b5a] 6714                      beq.s     $00FD8B70
[00fd8b5c] 2047                      movea.l   d7,a0
[00fd8b5e] d1fc 0000 0082            adda.l    #$00000082,a0
[00fd8b64] 30bc 0001                 move.w    #1,(a0)
[00fd8b68] 3d7c 0001 ffcc            move.w    #1,-52(a6)
[00fd8b6e] 600c                      bra.s     $00FD8B7C
[00fd8b70] 2047                      movea.l   d7,a0
[00fd8b72] d1fc 0000 009a            adda.l    #$0000009A,a0
[00fd8b78] 30bc 0001                 move.w    #1,(a0)
[00fd8b7c] 4257                      clr.w     (a7)
[00fd8b7e] 2f07                      move.l    d7,-(a7)
[00fd8b80] f4c4                      dc.w      $F4C4
[00fd8b82] 588f                      addq.l    #4,a7
[00fd8b84] 3d40 ffd8                 move.w    d0,-40(a6)
[00fd8b88] 3d7c 0001 ffd2            move.w    #1,-46(a6)
[00fd8b8e] 486e ffec                 pea.l     -20(a6)
[00fd8b92] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd8b96] 2f07                      move.l    d7,-(a7)
[00fd8b98] f42c                      dc.w      $F42C ; fs_sget
[00fd8b9a] defc 000a                 adda.w    #10,a7
[00fd8b9e] 3ebc 0003                 move.w    #$0003,(a7)
[00fd8ba2] 3f3c 0009                 move.w    #$0009,-(a7)
[00fd8ba6] 2f07                      move.l    d7,-(a7)
[00fd8ba8] f540                      dc.w      $F540 ; inf_gindex
[00fd8baa] 5c8f                      addq.l    #6,a7
[00fd8bac] 3d40 ffd0                 move.w    d0,-48(a6)
[00fd8bb0] 1d7c 0030 ff4c            move.b    #$30,-180(a6)
[00fd8bb6] 302e ffd0                 move.w    -48(a6),d0
[00fd8bba] 601c                      bra.s     $00FD8BD8
[00fd8bbc] 3d7c 0003 ffd4            move.w    #$0003,-44(a6)
[00fd8bc2] 1d7c 0031 ff4c            move.b    #$31,-180(a6)
[00fd8bc8] 601e                      bra.s     $00FD8BE8
[00fd8bca] 426e ffd4                 clr.w     -44(a6)
[00fd8bce] 6018                      bra.s     $00FD8BE8
[00fd8bd0] 3d7c 0008 ffd4            move.w    #$0008,-44(a6)
[00fd8bd6] 6010                      bra.s     $00FD8BE8
[00fd8bd8] 4a40                      tst.w     d0
[00fd8bda] 67e0                      beq.s     $00FD8BBC
[00fd8bdc] b07c 0001                 cmp.w     #1,d0
[00fd8be0] 67e8                      beq.s     $00FD8BCA
[00fd8be2] b07c 0002                 cmp.w     #$0002,d0
[00fd8be6] 67e8                      beq.s     $00FD8BD0
[00fd8be8] 2047                      movea.l   d7,a0
[00fd8bea] 322e ffd0                 move.w    -48(a6),d1
[00fd8bee] d27c 0009                 add.w     #$0009,d1
[00fd8bf2] c3fc 0018                 muls.w    #24,d1
[00fd8bf6] d1c1                      adda.l    d1,a0
[00fd8bf8] d1fc 0000 000a            adda.l    #$0000000A,a0
[00fd8bfe] 4250                      clr.w     (a0)
[00fd8c00] 0c6e 000e ffd8            cmpi.w    #$000E,-40(a6)
[00fd8c06] 6606                      bne.s     $00FD8C0E
[00fd8c08] 4240                      clr.w     d0
[00fd8c0a] 6000 0168                 bra       $00FD8D74
[00fd8c0e] 0c6e 000d ffd8            cmpi.w    #$000D,-40(a6)
[00fd8c14] 6628                      bne.s     $00FD8C3E
[00fd8c16] 4a6e ffcc                 tst.w     -52(a6)
[00fd8c1a] 6710                      beq.s     $00FD8C2C
[00fd8c1c] 206e ff48                 movea.l   -184(a6),a0
[00fd8c20] 4228 76e8                 clr.b     30440(a0)
[00fd8c24] 206e ff48                 movea.l   -184(a6),a0
[00fd8c28] 4228 76eb                 clr.b     30443(a0)
[00fd8c2c] 4a6e ffce                 tst.w     -50(a6)
[00fd8c30] 6604                      bne.s     $00FD8C36
[00fd8c32] 2e8d                      move.l    a5,(a7)
[00fd8c34] f54c                      dc.w      $F54C ; app_free
[00fd8c36] 6000 0138                 bra       $00FD8D70
[00fd8c3a] 6000 0134                 bra       $00FD8D70
[00fd8c3e] 082e 0004 ffd7            btst      #4,-41(a6)
[00fd8c44] 6706                      beq.s     $00FD8C4C
[00fd8c46] 006e 0010 ffd4            ori.w     #$0010,-44(a6)
[00fd8c4c] 486e ffec                 pea.l     -20(a6)
[00fd8c50] 486e fff0                 pea.l     -16(a6)
[00fd8c54] f39c                      dc.w      $F39C ; streq
[00fd8c56] 508f                      addq.l    #8,a7
[00fd8c58] 4a40                      tst.w     d0
[00fd8c5a] 670c                      beq.s     $00FD8C68
[00fd8c5c] 302e ffd6                 move.w    -42(a6),d0
[00fd8c60] b06e ffd4                 cmp.w     -44(a6),d0
[00fd8c64] 6700 00c2                 beq       $00FD8D28
[00fd8c68] 4a6e ffce                 tst.w     -50(a6)
[00fd8c6c] 676c                      beq.s     $00FD8CDA
[00fd8c6e] 3ebc 0001                 move.w    #1,(a7)
[00fd8c72] f350                      dc.w      $F350 ; app_alloc
[00fd8c74] 2840                      movea.l   d0,a4
[00fd8c76] 200c                      move.l    a4,d0
[00fd8c78] 674e                      beq.s     $00FD8CC8
[00fd8c7a] 426c 0006                 clr.w     6(a4)
[00fd8c7e] 397c ffff 0008            move.w    #$FFFF,8(a4)
[00fd8c84] 2e8e                      move.l    a6,(a7)
[00fd8c86] 0697 ffff ff52            addi.l    #$FFFFFF52,(a7)
[00fd8c8c] f24c                      dc.w      $F24C ; strlen
[00fd8c8e] 48c0                      ext.l     d0
[00fd8c90] d08e                      add.l     a6,d0
[00fd8c92] 2040                      movea.l   d0,a0
[00fd8c94] 117c 0040 ff52            move.b    #$40,-174(a0)
[00fd8c9a] 486c 000a                 pea.l     10(a4)
[00fd8c9e] 486e ff52                 pea.l     -174(a6)
[00fd8ca2] f32c                      dc.w      $F32C ; escani_str
[00fd8ca4] 508f                      addq.l    #8,a7
[00fd8ca6] 2040                      movea.l   d0,a0
[00fd8ca8] 4228 ffff                 clr.b     -1(a0)
[00fd8cac] 397c 0003 0012            move.w    #$0003,18(a4)
[00fd8cb2] 397c 0004 0014            move.w    #$0004,20(a4)
[00fd8cb8] 426c 0016                 clr.w     22(a4)
[00fd8cbc] 426c 0018                 clr.w     24(a4)
[00fd8cc0] 426c 001a                 clr.w     26(a4)
[00fd8cc4] 2a4c                      movea.l   a4,a5
[00fd8cc6] 6012                      bra.s     $00FD8CDA
[00fd8cc8] 4297                      clr.l     (a7)
[00fd8cca] 2f3c 0001 0024            move.l    #$00010024,-(a7)
[00fd8cd0] f0dc                      dc.w      $F0DC ; fill_string
[00fd8cd2] 588f                      addq.l    #4,a7
[00fd8cd4] 4240                      clr.w     d0
[00fd8cd6] 6000 009c                 bra       $00FD8D74
[00fd8cda] 3b6e ffd4 0004            move.w    -44(a6),4(a5)
[00fd8ce0] 4a2e ffec                 tst.b     -20(a6)
[00fd8ce4] 671c                      beq.s     $00FD8D02
[00fd8ce6] 486e ffde                 pea.l     -34(a6)
[00fd8cea] 2f3c 00fe b136            move.l    #$00FEB136,-(a7)
[00fd8cf0] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8cf2] 508f                      addq.l    #8,a7
[00fd8cf4] 486e ffe0                 pea.l     -32(a6)
[00fd8cf8] 486e ffec                 pea.l     -20(a6)
[00fd8cfc] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8cfe] 508f                      addq.l    #8,a7
[00fd8d00] 6004                      bra.s     $00FD8D06
[00fd8d02] 422e ffde                 clr.b     -34(a6)
[00fd8d06] 2e8e                      move.l    a6,(a7)
[00fd8d08] 0697 ffff ffde            addi.l    #$FFFFFFDE,(a7)
[00fd8d0e] f24c                      dc.w      $F24C ; strlen
[00fd8d10] 48c0                      ext.l     d0
[00fd8d12] d08e                      add.l     a6,d0
[00fd8d14] 2040                      movea.l   d0,a0
[00fd8d16] 117c 0040 ffde            move.b    #$40,-34(a0)
[00fd8d1c] 486d 000e                 pea.l     14(a5)
[00fd8d20] 486e ffde                 pea.l     -34(a6)
[00fd8d24] f32c                      dc.w      $F32C ; escani_str
[00fd8d26] 508f                      addq.l    #8,a7
[00fd8d28] 2047                      movea.l   d7,a0
[00fd8d2a] d1fc 0000 0083            adda.l    #$00000083,a0
[00fd8d30] 0810 0000                 btst      #0,(a0)
[00fd8d34] 6732                      beq.s     $00FD8D68
[00fd8d36] 206e ff48                 movea.l   -184(a6),a0
[00fd8d3a] 117c 0030 76e8            move.b    #$30,30440(a0)
[00fd8d40] 206e ff48                 movea.l   -184(a6),a0
[00fd8d44] 116e ff4c 76e9            move.b    -180(a6),30441(a0)
[00fd8d4a] 206e ff48                 movea.l   -184(a6),a0
[00fd8d4e] 117c 0020 76ea            move.b    #$20,30442(a0)
[00fd8d54] 2eae ff48                 move.l    -184(a6),(a7)
[00fd8d58] 0697 0000 76eb            addi.l    #$000076EB,(a7)
[00fd8d5e] 486e ff52                 pea.l     -174(a6)
[00fd8d62] f36c                      dc.w      $F36C ; xstrpcpy
[00fd8d64] 588f                      addq.l    #4,a7
[00fd8d66] 6008                      bra.s     $00FD8D70
[00fd8d68] 206e ff48                 movea.l   -184(a6),a0
[00fd8d6c] 4228 76e8                 clr.b     30440(a0)
[00fd8d70] 302e ffd2                 move.w    -46(a6),d0
[00fd8d74] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfd8d76
xfd8d76: ds.b 0
#if 0
[00fd8d76] 4e56 0000                 link      a6,#0
[00fd8d7a] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd8d7e] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd8d84] 4295                      clr.l     (a5)
[00fd8d86] 426d 7768                 clr.w     30568(a5)
[00fd8d8a] 426d 776a                 clr.w     30570(a5)
[00fd8d8e] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd8d90
xfd8d90: ds.b 0
#if 0
[00fd8d90] 4e56 0000                 link      a6,#0
[00fd8d94] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd8d98] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd8d9e] 41ed 02c8                 lea.l     712(a5),a0
[00fd8da2] 2b48 0348                 move.l    a0,840(a5)
[00fd8da6] f468                      dc.w      $F468
[00fd8da8] 7e04                      moveq.l   #4,d7
[00fd8daa] 6030                      bra.s     $00FD8DDC
[00fd8dac] 200d                      move.l    a5,d0
[00fd8dae] 3207                      move.w    d7,d1
[00fd8db0] 5241                      addq.w    #1,d1
[00fd8db2] c3fc 008c                 muls.w    #$008C,d1
[00fd8db6] d081                      add.l     d1,d0
[00fd8db8] 5880                      addq.l    #4,d0
[00fd8dba] 224d                      movea.l   a5,a1
[00fd8dbc] 3407                      move.w    d7,d2
[00fd8dbe] c5fc 008c                 muls.w    #$008C,d2
[00fd8dc2] d3c2                      adda.l    d2,a1
[00fd8dc4] 2340 0004                 move.l    d0,4(a1)
[00fd8dc8] 204d                      movea.l   a5,a0
[00fd8dca] 3207                      move.w    d7,d1
[00fd8dcc] c3fc 008c                 muls.w    #$008C,d1
[00fd8dd0] d1c1                      adda.l    d1,a0
[00fd8dd2] 217c 0000 0000 0086       move.l    #$00000000,134(a0)
[00fd8dda] 5347                      subq.w    #1,d7
[00fd8ddc] 4a47                      tst.w     d7
[00fd8dde] 6ccc                      bge.s     $00FD8DAC
[00fd8de0] 41ed 0004                 lea.l     4(a5),a0
[00fd8de4] 2b48 02c0                 move.l    a0,704(a5)
[00fd8de8] 42ad 02c4                 clr.l     708(a5)
[00fd8dec] 42ad 0234                 clr.l     564(a5)
[00fd8df0] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd8df2
xfd8df2: ds.b 0
#if 0
[00fd8df2] 4e56 0000                 link      a6,#0
[00fd8df6] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fd8dfa] 3e2e 0008                 move.w    8(a6),d7
[00fd8dfe] 2a6e 000a                 movea.l   10(a6),a5
[00fd8e02] 286e 000e                 movea.l   14(a6),a4
[00fd8e06] 266e 0016                 movea.l   22(a6),a3
[00fd8e0a] 2e8d                      move.l    a5,(a7)
[00fd8e0c] f24c                      dc.w      $F24C ; strlen
[00fd8e0e] d07c 000d                 add.w     #$000D,d0
[00fd8e12] b07c 0079                 cmp.w     #$0079,d0
[00fd8e16] 6d04                      blt.s     $00FD8E1C
[00fd8e18] 4240                      clr.w     d0
[00fd8e1a] 604e                      bra.s     $00FD8E6A
[00fd8e1c] 16c7                      move.b    d7,(a3)+
[00fd8e1e] 16fc 003a                 move.b    #$3A,(a3)+
[00fd8e22] 16fc 005c                 move.b    #$5C,(a3)+
[00fd8e26] 4a15                      tst.b     (a5)
[00fd8e28] 6710                      beq.s     $00FD8E3A
[00fd8e2a] 6002                      bra.s     $00FD8E2E
[00fd8e2c] 16dd                      move.b    (a5)+,(a3)+
[00fd8e2e] 4a15                      tst.b     (a5)
[00fd8e30] 66fa                      bne.s     $00FD8E2C
[00fd8e32] 4a14                      tst.b     (a4)
[00fd8e34] 6704                      beq.s     $00FD8E3A
[00fd8e36] 16fc 005c                 move.b    #$5C,(a3)+
[00fd8e3a] 4a14                      tst.b     (a4)
[00fd8e3c] 6728                      beq.s     $00FD8E66
[00fd8e3e] 6002                      bra.s     $00FD8E42
[00fd8e40] 16dc                      move.b    (a4)+,(a3)+
[00fd8e42] 4a14                      tst.b     (a4)
[00fd8e44] 66fa                      bne.s     $00FD8E40
[00fd8e46] 206e 0012                 movea.l   18(a6),a0
[00fd8e4a] 4a10                      tst.b     (a0)
[00fd8e4c] 6718                      beq.s     $00FD8E66
[00fd8e4e] 16fc 002e                 move.b    #$2E,(a3)+
[00fd8e52] 600a                      bra.s     $00FD8E5E
[00fd8e54] 206e 0012                 movea.l   18(a6),a0
[00fd8e58] 16d0                      move.b    (a0),(a3)+
[00fd8e5a] 52ae 0012                 addq.l    #1,18(a6)
[00fd8e5e] 206e 0012                 movea.l   18(a6),a0
[00fd8e62] 4a10                      tst.b     (a0)
[00fd8e64] 66ee                      bne.s     $00FD8E54
[00fd8e66] 421b                      clr.b     (a3)+
[00fd8e68] 7001                      moveq.l   #1,d0
[00fd8e6a] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfd8e6c
xfd8e6c: ds.b 0
#if 0
[00fd8e6c] 4e56 fff8                 link      a6,#$FFF8
[00fd8e70] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd8e74] 2a6e 0008                 movea.l   8(a6),a5
[00fd8e78] 2d4d fffc                 move.l    a5,-4(a6)
[00fd8e7c] 4a1d                      tst.b     (a5)+
[00fd8e7e] 671e                      beq.s     $00FD8E9E
[00fd8e80] 0c15 003a                 cmpi.b    #$3A,(a5)
[00fd8e84] 6618                      bne.s     $00FD8E9E
[00fd8e86] 538d                      subq.l    #1,a5
[00fd8e88] 1015                      move.b    (a5),d0
[00fd8e8a] 4880                      ext.w     d0
[00fd8e8c] 226e 000c                 movea.l   12(a6),a1
[00fd8e90] 3280                      move.w    d0,(a1)
[00fd8e92] 548d                      addq.l    #2,a5
[00fd8e94] 0c15 005c                 cmpi.b    #$5C,(a5)
[00fd8e98] 6602                      bne.s     $00FD8E9C
[00fd8e9a] 528d                      addq.l    #1,a5
[00fd8e9c] 6012                      bra.s     $00FD8EB0
[00fd8e9e] f46c                      dc.w      $F46C ; dos_gdrv
[00fd8ea0] 3f00                      move.w    d0,-(a7)
[00fd8ea2] 0657 0041                 addi.w    #$0041,(a7)
[00fd8ea6] 206e 000c                 movea.l   12(a6),a0
[00fd8eaa] 309f                      move.w    (a7)+,(a0)
[00fd8eac] 2a6e fffc                 movea.l   -4(a6),a5
[00fd8eb0] 2d4d fff8                 move.l    a5,-8(a6)
[00fd8eb4] 284d                      movea.l   a5,a4
[00fd8eb6] 97cb                      suba.l    a3,a3
[00fd8eb8] 6012                      bra.s     $00FD8ECC
[00fd8eba] 0c15 005c                 cmpi.b    #$5C,(a5)
[00fd8ebe] 6602                      bne.s     $00FD8EC2
[00fd8ec0] 284d                      movea.l   a5,a4
[00fd8ec2] 0c15 002e                 cmpi.b    #$2E,(a5)
[00fd8ec6] 6602                      bne.s     $00FD8ECA
[00fd8ec8] 264d                      movea.l   a5,a3
[00fd8eca] 528d                      addq.l    #1,a5
[00fd8ecc] 4a15                      tst.b     (a5)
[00fd8ece] 66ea                      bne.s     $00FD8EBA
[00fd8ed0] 200b                      move.l    a3,d0
[00fd8ed2] 6602                      bne.s     $00FD8ED6
[00fd8ed4] 264d                      movea.l   a5,a3
[00fd8ed6] 6012                      bra.s     $00FD8EEA
[00fd8ed8] 206e 0010                 movea.l   16(a6),a0
[00fd8edc] 226e fff8                 movea.l   -8(a6),a1
[00fd8ee0] 1091                      move.b    (a1),(a0)
[00fd8ee2] 52ae fff8                 addq.l    #1,-8(a6)
[00fd8ee6] 52ae 0010                 addq.l    #1,16(a6)
[00fd8eea] b9ee fff8                 cmpa.l    -8(a6),a4
[00fd8eee] 66e8                      bne.s     $00FD8ED8
[00fd8ef0] 206e 0010                 movea.l   16(a6),a0
[00fd8ef4] 4210                      clr.b     (a0)
[00fd8ef6] 0c14 005c                 cmpi.b    #$5C,(a4)
[00fd8efa] 6602                      bne.s     $00FD8EFE
[00fd8efc] 528c                      addq.l    #1,a4
[00fd8efe] 600a                      bra.s     $00FD8F0A
[00fd8f00] 206e 0014                 movea.l   20(a6),a0
[00fd8f04] 109c                      move.b    (a4)+,(a0)
[00fd8f06] 52ae 0014                 addq.l    #1,20(a6)
[00fd8f0a] b9cb                      cmpa.l    a3,a4
[00fd8f0c] 66f2                      bne.s     $00FD8F00
[00fd8f0e] 206e 0014                 movea.l   20(a6),a0
[00fd8f12] 4210                      clr.b     (a0)
[00fd8f14] 4a13                      tst.b     (a3)
[00fd8f16] 6712                      beq.s     $00FD8F2A
[00fd8f18] 528b                      addq.l    #1,a3
[00fd8f1a] 600a                      bra.s     $00FD8F26
[00fd8f1c] 206e 0018                 movea.l   24(a6),a0
[00fd8f20] 109b                      move.b    (a3)+,(a0)
[00fd8f22] 52ae 0018                 addq.l    #1,24(a6)
[00fd8f26] b7cd                      cmpa.l    a5,a3
[00fd8f28] 66f2                      bne.s     $00FD8F1C
[00fd8f2a] 206e 0018                 movea.l   24(a6),a0
[00fd8f2e] 4210                      clr.b     (a0)
[00fd8f30] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfd8f32
xfd8f32: ds.b 0
#if 0
[00fd8f32] 4e56 0000                 link      a6,#0
[00fd8f36] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd8f3a] 2a6e 0008                 movea.l   8(a6),a5
[00fd8f3e] 4a95                      tst.l     (a5)
[00fd8f40] 6706                      beq.s     $00FD8F48
[00fd8f42] 2e95                      move.l    (a5),(a7)
[00fd8f44] f3f0                      dc.w      $F3F0 ; dos_free
[00fd8f46] 4295                      clr.l     (a5)
[00fd8f48] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd8f4a
xfd8f4a: ds.b 0
#if 0
[00fd8f4a] 4e56 fffc                 link      a6,#-4
[00fd8f4e] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd8f52] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd8f58] 4a95                      tst.l     (a5)
[00fd8f5a] 662e                      bne.s     $00FD8F8A
[00fd8f5c] f3b8                      dc.w      $F3B8 ; dos_avail
[00fd8f5e] 2e00                      move.l    d0,d7
[00fd8f60] bebc 0000 0028            cmp.l     #$00000028,d7
[00fd8f66] 6d20                      blt.s     $00FD8F88
[00fd8f68] 2e87                      move.l    d7,(a7)
[00fd8f6a] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fd8f6c] 2a80                      move.l    d0,(a5)
[00fd8f6e] 426d 7768                 clr.w     30568(a5)
[00fd8f72] 2f3c 0000 0028            move.l    #$00000028,-(a7)
[00fd8f78] 2f07                      move.l    d7,-(a7)
[00fd8f7a] 4eb9 00fd d39e            jsr       $00FDD39E
[00fd8f80] 508f                      addq.l    #8,a7
[00fd8f82] 3b40 776a                 move.w    d0,30570(a5)
[00fd8f86] 6002                      bra.s     $00FD8F8A
[00fd8f88] 6020                      bra.s     $00FD8FAA
[00fd8f8a] 302d 7768                 move.w    30568(a5),d0
[00fd8f8e] b06d 776a                 cmp.w     30570(a5),d0
[00fd8f92] 6416                      bcc.s     $00FD8FAA
[00fd8f94] 2d55 fffc                 move.l    (a5),-4(a6)
[00fd8f98] 302d 7768                 move.w    30568(a5),d0
[00fd8f9c] c0fc 0028                 mulu.w    #$0028,d0
[00fd8fa0] d0ae fffc                 add.l     -4(a6),d0
[00fd8fa4] 526d 7768                 addq.w    #1,30568(a5)
[00fd8fa8] 6002                      bra.s     $00FD8FAC
[00fd8faa] 4280                      clr.l     d0
[00fd8fac] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd8fae
xfd8fae: ds.b 0
#if 0
[00fd8fae] 4e56 0000                 link      a6,#0
[00fd8fb2] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd8fb6] 2879 0000 a788            movea.l   _thedesk,a4
[00fd8fbc] 4aac 02c0                 tst.l     704(a4)
[00fd8fc0] 6720                      beq.s     $00FD8FE2
[00fd8fc2] 2a6c 02c0                 movea.l   704(a4),a5
[00fd8fc6] 206c 02c0                 movea.l   704(a4),a0
[00fd8fca] 2950 02c0                 move.l    (a0),704(a4)
[00fd8fce] 2aac 02c4                 move.l    708(a4),(a5)
[00fd8fd2] 294d 02c4                 move.l    a5,708(a4)
[00fd8fd6] 426d 0004                 clr.w     4(a5)
[00fd8fda] 42ad 0082                 clr.l     130(a5)
[00fd8fde] 200d                      move.l    a5,d0
[00fd8fe0] 6002                      bra.s     $00FD8FE4
[00fd8fe2] 4280                      clr.l     d0
[00fd8fe4] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfd8fe6
xfd8fe6: ds.b 0
#if 0
[00fd8fe6] 4e56 0000                 link      a6,#0
[00fd8fea] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd8fee] f470                      dc.w      $F470
[00fd8ff0] 2a40                      movea.l   d0,a5
[00fd8ff2] 200d                      move.l    a5,d0
[00fd8ff4] 6728                      beq.s     $00FD901E
[00fd8ff6] 486d 0008                 pea.l     8(a5)
[00fd8ffa] 2f2e 0012                 move.l    18(a6),-(a7)
[00fd8ffe] 2f2e 000e                 move.l    14(a6),-(a7)
[00fd9002] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd9006] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd900a] f474                      dc.w      $F474
[00fd900c] defc 0012                 adda.w    #$0012,a7
[00fd9010] 4a40                      tst.w     d0
[00fd9012] 670a                      beq.s     $00FD901E
[00fd9014] 3b6e 0016 0006            move.w    22(a6),6(a5)
[00fd901a] 200d                      move.l    a5,d0
[00fd901c] 6002                      bra.s     $00FD9020
[00fd901e] 4280                      clr.l     d0
[00fd9020] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd9022
xfd9022: ds.b 0
#if 0
[00fd9022] 4e56 0000                 link      a6,#0
[00fd9026] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd902a] 2a6e 0008                 movea.l   8(a6),a5
[00fd902e] 2679 0000 a788            movea.l   _thedesk,a3
[00fd9034] 2e8d                      move.l    a5,(a7)
[00fd9036] 0697 0000 0082            addi.l    #$00000082,(a7)
[00fd903c] f478                      dc.w      $F478
[00fd903e] 49eb 02c4                 lea.l     708(a3),a4
[00fd9042] 6002                      bra.s     $00FD9046
[00fd9044] 2854                      movea.l   (a4),a4
[00fd9046] bbd4                      cmpa.l    (a4),a5
[00fd9048] 66fa                      bne.s     $00FD9044
[00fd904a] 2895                      move.l    (a5),(a4)
[00fd904c] 2aab 02c0                 move.l    704(a3),(a5)
[00fd9050] 274d 02c0                 move.l    a5,704(a3)
[00fd9054] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfd9056
xfd9056: ds.b 0
#if 0
[00fd9056] 4e56 fffc                 link      a6,#-4
[00fd905a] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fd905e] 2a6e 0008                 movea.l   8(a6),a5
[00fd9062] 286e 000c                 movea.l   12(a6),a4
[00fd9066] 47ed 0012                 lea.l     18(a5),a3
[00fd906a] 41ec 0012                 lea.l     18(a4),a0
[00fd906e] 2d48 fffc                 move.l    a0,-4(a6)
[00fd9072] 302e 0010                 move.w    16(a6),d0
[00fd9076] 6000 0086                 bra       $00FD90FE
[00fd907a] 202c 000e                 move.l    14(a4),d0
[00fd907e] b0ad 000e                 cmp.l     14(a5),d0
[00fd9082] 6f06                      ble.s     $00FD908A
[00fd9084] 7001                      moveq.l   #1,d0
[00fd9086] 6000 008e                 bra       $00FD9116
[00fd908a] 202c 000e                 move.l    14(a4),d0
[00fd908e] b0ad 000e                 cmp.l     14(a5),d0
[00fd9092] 6c06                      bge.s     $00FD909A
[00fd9094] 70ff                      moveq.l   #-1,d0
[00fd9096] 6000 007e                 bra.w     $00FD9116
[00fd909a] 2eae fffc                 move.l    -4(a6),(a7)
[00fd909e] 2f0b                      move.l    a3,-(a7)
[00fd90a0] f47c                      dc.w      $F47C ; strchk
[00fd90a2] 588f                      addq.l    #4,a7
[00fd90a4] 6000 0070                 bra.w     $00FD9116
[00fd90a8] 3ebc 002e                 move.w    #$002E,(a7)
[00fd90ac] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd90b0] f480                      dc.w      $F480 ; scasb
[00fd90b2] 588f                      addq.l    #4,a7
[00fd90b4] 2e80                      move.l    d0,(a7)
[00fd90b6] 3f3c 002e                 move.w    #$002E,-(a7)
[00fd90ba] 2f0b                      move.l    a3,-(a7)
[00fd90bc] f480                      dc.w      $F480 ; scasb
[00fd90be] 5c8f                      addq.l    #6,a7
[00fd90c0] 2f00                      move.l    d0,-(a7)
[00fd90c2] f47c                      dc.w      $F47C ; strchk
[00fd90c4] 588f                      addq.l    #4,a7
[00fd90c6] 3e00                      move.w    d0,d7
[00fd90c8] 6704                      beq.s     $00FD90CE
[00fd90ca] 3007                      move.w    d7,d0
[00fd90cc] 6048                      bra.s     $00FD9116
[00fd90ce] 2eae fffc                 move.l    -4(a6),(a7)
[00fd90d2] 2f0b                      move.l    a3,-(a7)
[00fd90d4] f47c                      dc.w      $F47C ; strchk
[00fd90d6] 588f                      addq.l    #4,a7
[00fd90d8] 603c                      bra.s     $00FD9116
[00fd90da] 3e2c 000c                 move.w    12(a4),d7
[00fd90de] 9e6d 000c                 sub.w     12(a5),d7
[00fd90e2] 4a47                      tst.w     d7
[00fd90e4] 6706                      beq.s     $00FD90EC
[00fd90e6] 3007                      move.w    d7,d0
[00fd90e8] 602c                      bra.s     $00FD9116
[00fd90ea] 6010                      bra.s     $00FD90FC
[00fd90ec] 302c 000a                 move.w    10(a4),d0
[00fd90f0] ea48                      lsr.w     #5,d0
[00fd90f2] 322d 000a                 move.w    10(a5),d1
[00fd90f6] ea49                      lsr.w     #5,d1
[00fd90f8] 9041                      sub.w     d1,d0
[00fd90fa] 601a                      bra.s     $00FD9116
[00fd90fc] 6018                      bra.s     $00FD9116
[00fd90fe] 4a40                      tst.w     d0
[00fd9100] 67cc                      beq.s     $00FD90CE
[00fd9102] b07c 0001                 cmp.w     #1,d0
[00fd9106] 67d2                      beq.s     $00FD90DA
[00fd9108] b07c 0002                 cmp.w     #$0002,d0
[00fd910c] 6700 ff6c                 beq       $00FD907A
[00fd9110] b07c 0003                 cmp.w     #$0003,d0
[00fd9114] 6792                      beq.s     $00FD90A8
[00fd9116] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfd9118
xfd9118: ds.b 0
#if 0
[00fd9118] 4e56 ffd2                 link      a6,#$FFD2
[00fd911c] 48e7 1f04                 movem.l   d3-d7/a5,-(a7)
[00fd9120] 3e2e 0008                 move.w    8(a6),d7
[00fd9124] be7c ffff                 cmp.w     #$FFFF,d7
[00fd9128] 6620                      bne.s     $00FD914A
[00fd912a] 4247                      clr.w     d7
[00fd912c] 2a6e 000a                 movea.l   10(a6),a5
[00fd9130] 6014                      bra.s     $00FD9146
[00fd9132] 3007                      move.w    d7,d0
[00fd9134] c1fc 0028                 muls.w    #$0028,d0
[00fd9138] d0ae 000a                 add.l     10(a6),d0
[00fd913c] 2040                      movea.l   d0,a0
[00fd913e] 214d 0004                 move.l    a5,4(a0)
[00fd9142] 5247                      addq.w    #1,d7
[00fd9144] 2a55                      movea.l   (a5),a5
[00fd9146] 200d                      move.l    a5,d0
[00fd9148] 66e8                      bne.s     $00FD9132
[00fd914a] 4a47                      tst.w     d7
[00fd914c] 6608                      bne.s     $00FD9156
[00fd914e] 202e 000a                 move.l    10(a6),d0
[00fd9152] 6000 01c4                 bra       $00FD9318
[00fd9156] 3807                      move.w    d7,d4
[00fd9158] 48c4                      ext.l     d4
[00fd915a] 89fc 0002                 divs.w    #$0002,d4
[00fd915e] 6000 00f4                 bra       $00FD9254
[00fd9162] 3c04                      move.w    d4,d6
[00fd9164] 6000 00e2                 bra       $00FD9248
[00fd9168] 3a06                      move.w    d6,d5
[00fd916a] 9a44                      sub.w     d4,d5
[00fd916c] 6000 00d2                 bra       $00FD9240
[00fd9170] 206e 000a                 movea.l   10(a6),a0
[00fd9174] 3205                      move.w    d5,d1
[00fd9176] c3fc 0028                 muls.w    #$0028,d1
[00fd917a] 2070 1804                 movea.l   4(a0,d1.l),a0
[00fd917e] 1028 0009                 move.b    9(a0),d0
[00fd9182] 4880                      ext.w     d0
[00fd9184] 3205                      move.w    d5,d1
[00fd9186] d244                      add.w     d4,d1
[00fd9188] c3fc 0028                 muls.w    #$0028,d1
[00fd918c] d2ae 000a                 add.l     10(a6),d1
[00fd9190] 2241                      movea.l   d1,a1
[00fd9192] 2269 0004                 movea.l   4(a1),a1
[00fd9196] 1229 0009                 move.b    9(a1),d1
[00fd919a] 4881                      ext.w     d1
[00fd919c] b340                      eor.w     d1,d0
[00fd919e] c07c 0010                 and.w     #$0010,d0
[00fd91a2] 6722                      beq.s     $00FD91C6
[00fd91a4] 206e 000a                 movea.l   10(a6),a0
[00fd91a8] 3205                      move.w    d5,d1
[00fd91aa] c3fc 0028                 muls.w    #$0028,d1
[00fd91ae] 2070 1804                 movea.l   4(a0,d1.l),a0
[00fd91b2] 0828 0004 0009            btst      #4,9(a0)
[00fd91b8] 6704                      beq.s     $00FD91BE
[00fd91ba] 70ff                      moveq.l   #-1,d0
[00fd91bc] 6002                      bra.s     $00FD91C0
[00fd91be] 7001                      moveq.l   #1,d0
[00fd91c0] 3d40 ffd2                 move.w    d0,-46(a6)
[00fd91c4] 6030                      bra.s     $00FD91F6
[00fd91c6] 2079 0000 a788            movea.l   _thedesk,a0
[00fd91cc] 3ea8 3014                 move.w    12308(a0),(a7)
[00fd91d0] 206e 000a                 movea.l   10(a6),a0
[00fd91d4] 3205                      move.w    d5,d1
[00fd91d6] d244                      add.w     d4,d1
[00fd91d8] c3fc 0028                 muls.w    #$0028,d1
[00fd91dc] 2f30 1804                 move.l    4(a0,d1.l),-(a7)
[00fd91e0] 206e 000a                 movea.l   10(a6),a0
[00fd91e4] 3205                      move.w    d5,d1
[00fd91e6] c3fc 0028                 muls.w    #$0028,d1
[00fd91ea] 2f30 1804                 move.l    4(a0,d1.l),-(a7)
[00fd91ee] f484                      dc.w      $F484
[00fd91f0] 508f                      addq.l    #8,a7
[00fd91f2] 3d40 ffd2                 move.w    d0,-46(a6)
[00fd91f6] 4a6e ffd2                 tst.w     -46(a6)
[00fd91fa] 6f4a                      ble.s     $00FD9246
[00fd91fc] 3005                      move.w    d5,d0
[00fd91fe] c1fc 0028                 muls.w    #$0028,d0
[00fd9202] d0ae 000a                 add.l     10(a6),d0
[00fd9206] 2040                      movea.l   d0,a0
[00fd9208] 2a68 0004                 movea.l   4(a0),a5
[00fd920c] 3005                      move.w    d5,d0
[00fd920e] c1fc 0028                 muls.w    #$0028,d0
[00fd9212] d0ae 000a                 add.l     10(a6),d0
[00fd9216] 2040                      movea.l   d0,a0
[00fd9218] 3205                      move.w    d5,d1
[00fd921a] d244                      add.w     d4,d1
[00fd921c] c3fc 0028                 muls.w    #$0028,d1
[00fd9220] d2ae 000a                 add.l     10(a6),d1
[00fd9224] 2241                      movea.l   d1,a1
[00fd9226] 2169 0004 0004            move.l    4(a1),4(a0)
[00fd922c] 3005                      move.w    d5,d0
[00fd922e] d044                      add.w     d4,d0
[00fd9230] c1fc 0028                 muls.w    #$0028,d0
[00fd9234] d0ae 000a                 add.l     10(a6),d0
[00fd9238] 2040                      movea.l   d0,a0
[00fd923a] 214d 0004                 move.l    a5,4(a0)
[00fd923e] 9a44                      sub.w     d4,d5
[00fd9240] 4a45                      tst.w     d5
[00fd9242] 6c00 ff2c                 bge       $00FD9170
[00fd9246] 5246                      addq.w    #1,d6
[00fd9248] bc47                      cmp.w     d7,d6
[00fd924a] 6d00 ff1c                 blt       $00FD9168
[00fd924e] 48c4                      ext.l     d4
[00fd9250] 89fc 0002                 divs.w    #$0002,d4
[00fd9254] 4a44                      tst.w     d4
[00fd9256] 6e00 ff0a                 bgt       $00FD9162
[00fd925a] 42ae fffc                 clr.l     -4(a6)
[00fd925e] 4bee fffc                 lea.l     -4(a6),a5
[00fd9262] 4246                      clr.w     d6
[00fd9264] 6022                      bra.s     $00FD9288
[00fd9266] 3006                      move.w    d6,d0
[00fd9268] c1fc 0028                 muls.w    #$0028,d0
[00fd926c] d0ae 000a                 add.l     10(a6),d0
[00fd9270] 2040                      movea.l   d0,a0
[00fd9272] 2aa8 0004                 move.l    4(a0),(a5)
[00fd9276] 3006                      move.w    d6,d0
[00fd9278] c1fc 0028                 muls.w    #$0028,d0
[00fd927c] d0ae 000a                 add.l     10(a6),d0
[00fd9280] 2040                      movea.l   d0,a0
[00fd9282] 2a68 0004                 movea.l   4(a0),a5
[00fd9286] 5246                      addq.w    #1,d6
[00fd9288] bc47                      cmp.w     d7,d6
[00fd928a] 6dda                      blt.s     $00FD9266
[00fd928c] 4295                      clr.l     (a5)
[00fd928e] 486e ffd4                 pea.l     -44(a6)
[00fd9292] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd9296] 3f3c 0028                 move.w    #$0028,-(a7)
[00fd929a] f390                      dc.w      $F390 ; movs
[00fd929c] defc 000a                 adda.w    #10,a7
[00fd92a0] 2eae fffc                 move.l    -4(a6),(a7)
[00fd92a4] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd92a8] 3f3c 0028                 move.w    #$0028,-(a7)
[00fd92ac] f390                      dc.w      $F390 ; movs
[00fd92ae] 5c8f                      addq.l    #6,a7
[00fd92b0] 2eae 000a                 move.l    10(a6),(a7)
[00fd92b4] 486e ffd4                 pea.l     -44(a6)
[00fd92b8] 3f3c 0028                 move.w    #$0028,-(a7)
[00fd92bc] f390                      dc.w      $F390 ; movs
[00fd92be] 5c8f                      addq.l    #6,a7
[00fd92c0] 4246                      clr.w     d6
[00fd92c2] 604c                      bra.s     $00FD9310
[00fd92c4] 206e 000a                 movea.l   10(a6),a0
[00fd92c8] 3206                      move.w    d6,d1
[00fd92ca] c3fc 0028                 muls.w    #$0028,d1
[00fd92ce] 2030 1800                 move.l    0(a0,d1.l),d0
[00fd92d2] b0ae 000a                 cmp.l     10(a6),d0
[00fd92d6] 6612                      bne.s     $00FD92EA
[00fd92d8] 3006                      move.w    d6,d0
[00fd92da] c1fc 0028                 muls.w    #$0028,d0
[00fd92de] d0ae 000a                 add.l     10(a6),d0
[00fd92e2] 2040                      movea.l   d0,a0
[00fd92e4] 20ae fffc                 move.l    -4(a6),(a0)
[00fd92e8] 6024                      bra.s     $00FD930E
[00fd92ea] 206e 000a                 movea.l   10(a6),a0
[00fd92ee] 3206                      move.w    d6,d1
[00fd92f0] c3fc 0028                 muls.w    #$0028,d1
[00fd92f4] 2030 1800                 move.l    0(a0,d1.l),d0
[00fd92f8] b0ae fffc                 cmp.l     -4(a6),d0
[00fd92fc] 6610                      bne.s     $00FD930E
[00fd92fe] 3006                      move.w    d6,d0
[00fd9300] c1fc 0028                 muls.w    #$0028,d0
[00fd9304] d0ae 000a                 add.l     10(a6),d0
[00fd9308] 2040                      movea.l   d0,a0
[00fd930a] 20ae 000a                 move.l    10(a6),(a0)
[00fd930e] 5246                      addq.w    #1,d6
[00fd9310] bc47                      cmp.w     d7,d6
[00fd9312] 6db0                      blt.s     $00FD92C4
[00fd9314] 202e 000a                 move.l    10(a6),d0
[00fd9318] f83d                      dc.w      $F83D ; movem.l (a7)+,d4-d7/a5
#endif

	xdef xfd931a
xfd931a: ds.b 0
#if 0
[00fd931a] 4e56 fffc                 link      a6,#-4
[00fd931e] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fd9322] 2a6e 0008                 movea.l   8(a6),a5
[00fd9326] 0c2d 0063 0008            cmpi.b    #$63,8(a5)
[00fd932c] 6604                      bne.s     $00FD9332
[00fd932e] 7a01                      moveq.l   #1,d5
[00fd9330] 6002                      bra.s     $00FD9334
[00fd9332] 4245                      clr.w     d5
[00fd9334] 2679 0000 a788            movea.l   _thedesk,a3
[00fd933a] 426d 0086                 clr.w     134(a5)
[00fd933e] 42ad 0088                 clr.l     136(a5)
[00fd9342] 2e8d                      move.l    a5,(a7)
[00fd9344] 0697 0000 0082            addi.l    #$00000082,(a7)
[00fd934a] f478                      dc.w      $F478
[00fd934c] 99cc                      suba.l    a4,a4
[00fd934e] 4a45                      tst.w     d5
[00fd9350] 6716                      beq.s     $00FD9368
[00fd9352] 3ead 0006                 move.w    6(a5),(a7)
[00fd9356] 2079 0000 a788            movea.l   _thedesk,a0
[00fd935c] 2f28 0348                 move.l    840(a0),-(a7)
[00fd9360] f488                      dc.w      $F488 ; cart_sfirst
[00fd9362] 588f                      addq.l    #4,a7
[00fd9364] 3e00                      move.w    d0,d7
[00fd9366] 601a                      bra.s     $00FD9382
[00fd9368] 2079 0000 a788            movea.l   _thedesk,a0
[00fd936e] 2ea8 0348                 move.l    840(a0),(a7)
[00fd9372] f3f4                      dc.w      $F3F4 ; dos_sdta
[00fd9374] 3ead 0006                 move.w    6(a5),(a7)
[00fd9378] 486d 0008                 pea.l     8(a5)
[00fd937c] f3fc                      dc.w      $F3FC ; dos_sfirst
[00fd937e] 588f                      addq.l    #4,a7
[00fd9380] 3e00                      move.w    d0,d7
[00fd9382] 6000 0092                 bra       $00FD9416
[00fd9386] 2079 0000 a788            movea.l   _thedesk,a0
[00fd938c] 0c28 002e 02e6            cmpi.b    #$2E,742(a0)
[00fd9392] 661a                      bne.s     $00FD93AE
[00fd9394] 2079 0000 a788            movea.l   _thedesk,a0
[00fd939a] 0c28 002e 02e7            cmpi.b    #$2E,743(a0)
[00fd93a0] 6766                      beq.s     $00FD9408
[00fd93a2] 2079 0000 a788            movea.l   _thedesk,a0
[00fd93a8] 4a28 02e7                 tst.b     743(a0)
[00fd93ac] 675a                      beq.s     $00FD9408
[00fd93ae] 2079 0000 a788            movea.l   _thedesk,a0
[00fd93b4] 1028 02dd                 move.b    733(a0),d0
[00fd93b8] 4880                      ext.w     d0
[00fd93ba] c07c 0006                 and.w     #$0006,d0
[00fd93be] 6648                      bne.s     $00FD9408
[00fd93c0] f48c                      dc.w      $F48C
[00fd93c2] 2840                      movea.l   d0,a4
[00fd93c4] 200c                      move.l    a4,d0
[00fd93c6] 660c                      bne.s     $00FD93D4
[00fd93c8] 4247                      clr.w     d7
[00fd93ca] 33fc 0064 0000 6e20       move.w    #$0064,_DOS_AX
[00fd93d2] 6048                      bra.s     $00FD941C
[00fd93d4] 486c 0008                 pea.l     8(a4)
[00fd93d8] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd93de] 0697 0000 02dc            addi.l    #$000002DC,(a7)
[00fd93e4] 3f3c 0017                 move.w    #$0017,-(a7)
[00fd93e8] f390                      dc.w      $F390 ; movs
[00fd93ea] defc 000a                 adda.w    #10,a7
[00fd93ee] 202c 000e                 move.l    14(a4),d0
[00fd93f2] d1ad 0088                 add.l     d0,136(a5)
[00fd93f6] 294c 0004                 move.l    a4,4(a4)
[00fd93fa] 4a6d 0086                 tst.w     134(a5)
[00fd93fe] 6604                      bne.s     $00FD9404
[00fd9400] 2b4c 0082                 move.l    a4,130(a5)
[00fd9404] 526d 0086                 addq.w    #1,134(a5)
[00fd9408] 4a45                      tst.w     d5
[00fd940a] 6706                      beq.s     $00FD9412
[00fd940c] f490                      dc.w      $F490 ; cart_snext
[00fd940e] 3e00                      move.w    d0,d7
[00fd9410] 6004                      bra.s     $00FD9416
[00fd9412] f414                      dc.w      $F414 ; dos_snext
[00fd9414] 3e00                      move.w    d0,d7
[00fd9416] 4a47                      tst.w     d7
[00fd9418] 6600 ff6c                 bne       $00FD9386
[00fd941c] 4a6d 0086                 tst.w     134(a5)
[00fd9420] 6742                      beq.s     $00FD9464
[00fd9422] 2ead 0082                 move.l    130(a5),(a7)
[00fd9426] 3f2d 0086                 move.w    134(a5),-(a7)
[00fd942a] f494                      dc.w      $F494
[00fd942c] 548f                      addq.l    #2,a7
[00fd942e] 2b40 0082                 move.l    d0,130(a5)
[00fd9432] 2d53 fffc                 move.l    (a3),-4(a6)
[00fd9436] 4286                      clr.l     d6
[00fd9438] 3c2b 7768                 move.w    30568(a3),d6
[00fd943c] 2f3c 0000 0028            move.l    #$00000028,-(a7)
[00fd9442] 2f06                      move.l    d6,-(a7)
[00fd9444] 4eb9 00fd d34a            jsr       aeslmul
[00fd944a] 508f                      addq.l    #8,a7
[00fd944c] 2c00                      move.l    d0,d6
[00fd944e] dcae fffc                 add.l     -4(a6),d6
[00fd9452] 9c93                      sub.l     (a3),d6
[00fd9454] 2e86                      move.l    d6,(a7)
[00fd9456] 2f13                      move.l    (a3),-(a7)
[00fd9458] 4267                      clr.w     -(a7)
[00fd945a] 3f3c 004a                 move.w    #$004A,-(a7)
[00fd945e] f0d8                      dc.w      $F0D8 ; trap
[00fd9460] 508f                      addq.l    #8,a7
[00fd9462] 6010                      bra.s     $00FD9474
[00fd9464] 4aad 0082                 tst.l     130(a5)
[00fd9468] 6706                      beq.s     $00FD9470
[00fd946a] 2ead 0082                 move.l    130(a5),(a7)
[00fd946e] f3f0                      dc.w      $F3F0 ; dos_free
[00fd9470] 42ad 0082                 clr.l     130(a5)
[00fd9474] f468                      dc.w      $F468
[00fd9476] 3039 0000 6e20            move.w    _DOS_AX,d0
[00fd947c] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef _fill_string
_fill_string: ds.b 0
#if 0
[00fd947e] 4e56 0000                 link      a6,#0
[00fd9482] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fd9486] 2a79 0000 a7b6            movea.l   $0000A7B6,a5
[00fd948c] 2879 0000 a788            movea.l   _thedesk,a4
[00fd9492] 486c 3552                 pea.l     13650(a4)
[00fd9496] 3f2e 000a                 move.w    10(a6),-(a7)
[00fd949a] 3f3c 0005                 move.w    #$0005,-(a7)
[00fd949e] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fd94a0] 508f                      addq.l    #8,a7
[00fd94a2] 4aae 000c                 tst.l     12(a6)
[00fd94a6] 6712                      beq.s     $00FD94BA
[00fd94a8] 2eae 000c                 move.l    12(a6),(a7)
[00fd94ac] 2f2c 3552                 move.l    13650(a4),-(a7)
[00fd94b0] 2f0d                      move.l    a5,-(a7)
[00fd94b2] f498                      dc.w      $F498 ; merge_str
[00fd94b4] 508f                      addq.l    #8,a7
[00fd94b6] 294d 3552                 move.l    a5,13650(a4)
[00fd94ba] 2eac 3552                 move.l    13650(a4),(a7)
[00fd94be] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd94c2] f49c                      dc.w      $F49C ; form_alert
[00fd94c4] 548f                      addq.l    #2,a7
[00fd94c6] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef _send_msg
_send_msg: ds.b 0
#if 0
[00fd94c8] 4e56 ffec                 link      a6,#$FFEC
[00fd94cc] 3d6e 0008 fff0            move.w    8(a6),-16(a6)
[00fd94d2] 3d79 0000 6db4 fff2       move.w    _gl_apid,-14(a6)
[00fd94da] 426e fff4                 clr.w     -12(a6)
[00fd94de] 3d6e 000c fff6            move.w    12(a6),-10(a6)
[00fd94e4] 3d6e 000e fff8            move.w    14(a6),-8(a6)
[00fd94ea] 3d6e 0010 fffa            move.w    16(a6),-6(a6)
[00fd94f0] 3d6e 0012 fffc            move.w    18(a6),-4(a6)
[00fd94f6] 3d6e 0014 fffe            move.w    20(a6),-2(a6)
[00fd94fc] 486e fff0                 pea.l     -16(a6)
[00fd9500] 3f3c 0010                 move.w    #$0010,-(a7)
[00fd9504] 3f39 0000 6db4            move.w    _gl_apid,-(a7)
[00fd950a] f4a0                      dc.w      $F4A0 ; appl_write
[00fd950c] 508f                      addq.l    #8,a7
[00fd950e] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef _up_allwin
_up_allwin: ds.b 0
#if 0
[00fd9510] 4e56 0000                 link      a6,#0
[00fd9514] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd9518] 3ebc 0001                 move.w    #1,(a7)
[00fd951c] f094                      dc.w      $F094 ; desk_wait
[00fd951e] 7e04                      moveq.l   #4,d7
[00fd9520] 6046                      bra.s     $00FD9568
[00fd9522] 3e87                      move.w    d7,(a7)
[00fd9524] f4a4                      dc.w      $F4A4
[00fd9526] 2a40                      movea.l   d0,a5
[00fd9528] 4a6d 0006                 tst.w     6(a5)
[00fd952c] 6738                      beq.s     $00FD9566
[00fd952e] 4a6e 000c                 tst.w     12(a6)
[00fd9532] 6718                      beq.s     $00FD954C
[00fd9534] 2eae 0008                 move.l    8(a6),(a7)
[00fd9538] 2f2d 0018                 move.l    24(a5),-(a7)
[00fd953c] 5097                      addq.l    #8,(a7)
[00fd953e] f39c                      dc.w      $F39C ; streq
[00fd9540] 588f                      addq.l    #4,a7
[00fd9542] 4a40                      tst.w     d0
[00fd9544] 6704                      beq.s     $00FD954A
[00fd9546] 2e8d                      move.l    a5,(a7)
[00fd9548] f4a8                      dc.w      $F4A8
[00fd954a] 601a                      bra.s     $00FD9566
[00fd954c] 206d 0018                 movea.l   24(a5),a0
[00fd9550] 1028 0008                 move.b    8(a0),d0
[00fd9554] 4880                      ext.w     d0
[00fd9556] 226e 0008                 movea.l   8(a6),a1
[00fd955a] 1211                      move.b    (a1),d1
[00fd955c] 4881                      ext.w     d1
[00fd955e] b041                      cmp.w     d1,d0
[00fd9560] 6604                      bne.s     $00FD9566
[00fd9562] 2e8d                      move.l    a5,(a7)
[00fd9564] f4a8                      dc.w      $F4A8
[00fd9566] 5347                      subq.w    #1,d7
[00fd9568] 4a47                      tst.w     d7
[00fd956a] 66b6                      bne.s     $00FD9522
[00fd956c] 4257                      clr.w     (a7)
[00fd956e] f094                      dc.w      $F094 ; desk_wait
[00fd9570] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd9572
xfd9572: ds.b 0
#if 0
[00fd9572] 4e56 fffc                 link      a6,#-4
[00fd9576] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd957a] 2a6e 0008                 movea.l   8(a6),a5
[00fd957e] 3ebc 0001                 move.w    #1,(a7)
[00fd9582] f094                      dc.w      $F094 ; desk_wait
[00fd9584] 202d 0018                 move.l    24(a5),d0
[00fd9588] 5080                      addq.l    #8,d0
[00fd958a] 2d40 fffc                 move.l    d0,-4(a6)
[00fd958e] 7e04                      moveq.l   #4,d7
[00fd9590] 6024                      bra.s     $00FD95B6
[00fd9592] 3e87                      move.w    d7,(a7)
[00fd9594] f4a4                      dc.w      $F4A4
[00fd9596] 2a40                      movea.l   d0,a5
[00fd9598] 4a6d 0006                 tst.w     6(a5)
[00fd959c] 6716                      beq.s     $00FD95B4
[00fd959e] 2eae fffc                 move.l    -4(a6),(a7)
[00fd95a2] 2f2d 0018                 move.l    24(a5),-(a7)
[00fd95a6] 5097                      addq.l    #8,(a7)
[00fd95a8] f39c                      dc.w      $F39C ; streq
[00fd95aa] 588f                      addq.l    #4,a7
[00fd95ac] 4a40                      tst.w     d0
[00fd95ae] 6704                      beq.s     $00FD95B4
[00fd95b0] 2e8d                      move.l    a5,(a7)
[00fd95b2] f4a8                      dc.w      $F4A8
[00fd95b4] 5347                      subq.w    #1,d7
[00fd95b6] 4a47                      tst.w     d7
[00fd95b8] 66d8                      bne.s     $00FD9592
[00fd95ba] 4257                      clr.w     (a7)
[00fd95bc] f094                      dc.w      $F094 ; desk_wait
[00fd95be] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd95c0
xfd95c0: ds.b 0
#if 0
[00fd95c0] 4e56 fff8                 link      a6,#$FFF8
[00fd95c4] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fd95c8] 2a6e 0008                 movea.l   8(a6),a5
[00fd95cc] 2ead 0018                 move.l    24(a5),(a7)
[00fd95d0] f4ac                      dc.w      $F4AC
[00fd95d2] 3ebc 0001                 move.w    #1,(a7)
[00fd95d6] 3f2d 0006                 move.w    6(a5),-(a7)
[00fd95da] f4b0                      dc.w      $F4B0
[00fd95dc] 548f                      addq.l    #2,a7
[00fd95de] 2e8d                      move.l    a5,(a7)
[00fd95e0] f4b4                      dc.w      $F4B4
[00fd95e2] 42a7                      clr.l     -(a7)
[00fd95e4] 486d 0095                 pea.l     149(a5)
[00fd95e8] 3f3c 0003                 move.w    #$0003,-(a7)
[00fd95ec] 3f2d 0006                 move.w    6(a5),-(a7)
[00fd95f0] f4b8                      dc.w      $F4B8 ; wind_set
[00fd95f2] defc 000c                 adda.w    #12,a7
[00fd95f6] 486e fff8                 pea.l     -8(a6)
[00fd95fa] 3f3c 0004                 move.w    #$0004,-(a7)
[00fd95fe] 3f2d 0006                 move.w    6(a5),-(a7)
[00fd9602] f4bc                      dc.w      $F4BC
[00fd9604] 508f                      addq.l    #8,a7
[00fd9606] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd960a] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd960e] 3f2d 0006                 move.w    6(a5),-(a7)
[00fd9612] 3f39 0000 6db4            move.w    _gl_apid,-(a7)
[00fd9618] 3f3c 0014                 move.w    #$0014,-(a7)
[00fd961c] f4c0                      dc.w      $F4C0 ; send_msg
[00fd961e] defc 000e                 adda.w    #$000E,a7
[00fd9622] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfd9624
xfd9624: ds.b 0
#if 0
[00fd9624] 4e56 ffb2                 link      a6,#$FFB2
[00fd9628] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fd962c] 2a6e 0008                 movea.l   8(a6),a5
[00fd9630] 2079 0000 a788            movea.l   _thedesk,a0
[00fd9636] 2e28 357a                 move.l    13690(a0),d7
[00fd963a] 286d 0018                 movea.l   24(a5),a4
[00fd963e] 2679 0000 a788            movea.l   _thedesk,a3
[00fd9644] d7fc 0000 3016            adda.l    #$00003016,a3
[00fd964a] 2e8b                      move.l    a3,(a7)
[00fd964c] 486c 0008                 pea.l     8(a4)
[00fd9650] f36c                      dc.w      $F36C ; xstrpcpy
[00fd9652] 588f                      addq.l    #4,a7
[00fd9654] 4245                      clr.w     d5
[00fd9656] 6008                      bra.s     $00FD9660
[00fd9658] 0c13 005c                 cmpi.b    #$5C,(a3)
[00fd965c] 6602                      bne.s     $00FD9660
[00fd965e] 5245                      addq.w    #1,d5
[00fd9660] 4a1b                      tst.b     (a3)+
[00fd9662] 66f4                      bne.s     $00FD9658
[00fd9664] ba7c 0008                 cmp.w     #$0008,d5
[00fd9668] 6f12                      ble.s     $00FD967C
[00fd966a] 4297                      clr.l     (a7)
[00fd966c] 2f3c 0001 0017            move.l    #$00010017,-(a7)
[00fd9672] f0dc                      dc.w      $F0DC ; fill_string
[00fd9674] 588f                      addq.l    #4,a7
[00fd9676] 4240                      clr.w     d0
[00fd9678] 6000 00ec                 bra       $00FD9766
[00fd967c] 422e fff4                 clr.b     -12(a6)
[00fd9680] 486e fff4                 pea.l     -12(a6)
[00fd9684] 3f3c 0001                 move.w    #1,-(a7)
[00fd9688] 2f07                      move.l    d7,-(a7)
[00fd968a] f3c8                      dc.w      $F3C8 ; inf_sset
[00fd968c] defc 000a                 adda.w    #10,a7
[00fd9690] 4246                      clr.w     d6
[00fd9692] 4257                      clr.w     (a7)
[00fd9694] 2f07                      move.l    d7,-(a7)
[00fd9696] f4c4                      dc.w      $F4C4
[00fd9698] 588f                      addq.l    #4,a7
[00fd969a] b07c 0002                 cmp.w     #$0002,d0
[00fd969e] 6600 00ba                 bne       $00FD975A
[00fd96a2] 3ebc 0001                 move.w    #1,(a7)
[00fd96a6] f094                      dc.w      $F094 ; desk_wait
[00fd96a8] 486e fff4                 pea.l     -12(a6)
[00fd96ac] 3f3c 0001                 move.w    #1,-(a7)
[00fd96b0] 2f07                      move.l    d7,-(a7)
[00fd96b2] f42c                      dc.w      $F42C ; fs_sget
[00fd96b4] defc 000a                 adda.w    #10,a7
[00fd96b8] 486e ffe6                 pea.l     -26(a6)
[00fd96bc] 486e fff4                 pea.l     -12(a6)
[00fd96c0] f430                      dc.w      $F430 ; unfmt_str
[00fd96c2] 508f                      addq.l    #8,a7
[00fd96c4] 4a2e ffe6                 tst.b     -26(a6)
[00fd96c8] 6700 0090                 beq       $00FD975A
[00fd96cc] 486e ffe6                 pea.l     -26(a6)
[00fd96d0] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd96d6] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd96dc] f3f8                      dc.w      $F3F8
[00fd96de] 508f                      addq.l    #8,a7
[00fd96e0] 2e8e                      move.l    a6,(a7)
[00fd96e2] 0697 ffff ffb4            addi.l    #$FFFFFFB4,(a7)
[00fd96e8] f3f4                      dc.w      $F3F4 ; dos_sdta
[00fd96ea] 3ebc 0016                 move.w    #$0016,(a7)
[00fd96ee] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd96f4] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd96fa] f3fc                      dc.w      $F3FC ; dos_sfirst
[00fd96fc] 588f                      addq.l    #4,a7
[00fd96fe] 4a40                      tst.w     d0
[00fd9700] 671a                      beq.s     $00FD971C
[00fd9702] 4297                      clr.l     (a7)
[00fd9704] 2f3c 0001 0015            move.l    #$00010015,-(a7)
[00fd970a] f0dc                      dc.w      $F0DC ; fill_string
[00fd970c] 588f                      addq.l    #4,a7
[00fd970e] 5340                      subq.w    #1,d0
[00fd9710] 6704                      beq.s     $00FD9716
[00fd9712] 4240                      clr.w     d0
[00fd9714] 6002                      bra.s     $00FD9718
[00fd9716] 7001                      moveq.l   #1,d0
[00fd9718] 3c00                      move.w    d0,d6
[00fd971a] 6030                      bra.s     $00FD974C
[00fd971c] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd9722] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd9728] f410                      dc.w      $F410 ; dos_mkdir
[00fd972a] 0c79 0005 0000 6e20       cmpi.w    #$0005,_DOS_AX
[00fd9732] 660e                      bne.s     $00FD9742
[00fd9734] 4297                      clr.l     (a7)
[00fd9736] 2f3c 0001 0016            move.l    #$00010016,-(a7)
[00fd973c] f0dc                      dc.w      $F0DC ; fill_string
[00fd973e] 588f                      addq.l    #4,a7
[00fd9740] 600a                      bra.s     $00FD974C
[00fd9742] f374                      dc.w      $F374 ; dos_error
[00fd9744] 4a40                      tst.w     d0
[00fd9746] 6704                      beq.s     $00FD974C
[00fd9748] 2e8d                      move.l    a5,(a7)
[00fd974a] f4c8                      dc.w      $F4C8
[00fd974c] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd9752] 0697 0000 3016            addi.l    #$00003016,(a7)
[00fd9758] f424                      dc.w      $F424 ; rep_all
[00fd975a] 4a46                      tst.w     d6
[00fd975c] 6600 ff1e                 bne       $00FD967C
[00fd9760] 4257                      clr.w     (a7)
[00fd9762] f094                      dc.w      $F094 ; desk_wait
[00fd9764] 7001                      moveq.l   #1,d0
[00fd9766] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef xfd9768
xfd9768: ds.b 0
#if 0
[00fd9768] 4e56 fff8                 link      a6,#$FFF8
[00fd976c] 48e7 070c                 movem.l   d5-d7/a4-a5,-(a7)
[00fd9770] 3e2e 0008                 move.w    8(a6),d7
[00fd9774] 2a6e 000a                 movea.l   10(a6),a5
[00fd9778] be7c ffff                 cmp.w     #$FFFF,d7
[00fd977c] 6700 00c6                 beq       $00FD9844
[00fd9780] 486e fff8                 pea.l     -8(a6)
[00fd9784] 486e fffc                 pea.l     -4(a6)
[00fd9788] 486e fffe                 pea.l     -2(a6)
[00fd978c] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd9792] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd9798] 2f2d 0082                 move.l    130(a5),-(a7)
[00fd979c] 486d 0008                 pea.l     8(a5)
[00fd97a0] 4267                      clr.w     -(a7)
[00fd97a2] f4cc                      dc.w      $F4CC
[00fd97a4] defc 001a                 adda.w    #$001A,a7
[00fd97a8] 4a40                      tst.w     d0
[00fd97aa] 6606                      bne.s     $00FD97B2
[00fd97ac] 4240                      clr.w     d0
[00fd97ae] 6000 0096                 bra       $00FD9846
[00fd97b2] be7c 0002                 cmp.w     #$0002,d7
[00fd97b6] 6706                      beq.s     $00FD97BE
[00fd97b8] be7c 0003                 cmp.w     #$0003,d7
[00fd97bc] 665a                      bne.s     $00FD9818
[00fd97be] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd97c4] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd97ca] 2f2d 0082                 move.l    130(a5),-(a7)
[00fd97ce] 486d 0008                 pea.l     8(a5)
[00fd97d2] f4d0                      dc.w      $F4D0
[00fd97d4] 508f                      addq.l    #8,a7
[00fd97d6] 4a40                      tst.w     d0
[00fd97d8] 673a                      beq.s     $00FD9814
[00fd97da] 3c39 0000 a786            move.w    $0000A786,d6
[00fd97e0] 5546                      subq.w    #2,d6
[00fd97e2] 2879 0000 a788            movea.l   _thedesk,a4
[00fd97e8] d9fc 0000 32b6            adda.l    #$000032B6,a4
[00fd97ee] 6008                      bra.s     $00FD97F8
[00fd97f0] 0c14 005c                 cmpi.b    #$5C,(a4)
[00fd97f4] 6602                      bne.s     $00FD97F8
[00fd97f6] 5246                      addq.w    #1,d6
[00fd97f8] 4a1c                      tst.b     (a4)+
[00fd97fa] 66f4                      bne.s     $00FD97F0
[00fd97fc] bc7c 0009                 cmp.w     #$0009,d6
[00fd9800] 6f10                      ble.s     $00FD9812
[00fd9802] 4297                      clr.l     (a7)
[00fd9804] 2f3c 0001 0017            move.l    #$00010017,-(a7)
[00fd980a] f0dc                      dc.w      $F0DC ; fill_string
[00fd980c] 588f                      addq.l    #4,a7
[00fd980e] 4240                      clr.w     d0
[00fd9810] 6034                      bra.s     $00FD9846
[00fd9812] 6004                      bra.s     $00FD9818
[00fd9814] 4240                      clr.w     d0
[00fd9816] 602e                      bra.s     $00FD9846
[00fd9818] 486e fff8                 pea.l     -8(a6)
[00fd981c] 486e fffc                 pea.l     -4(a6)
[00fd9820] 486e fffe                 pea.l     -2(a6)
[00fd9824] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd982a] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd9830] 2f2d 0082                 move.l    130(a5),-(a7)
[00fd9834] 486d 0008                 pea.l     8(a5)
[00fd9838] 3f07                      move.w    d7,-(a7)
[00fd983a] f4cc                      dc.w      $F4CC
[00fd983c] defc 001a                 adda.w    #$001A,a7
[00fd9840] 7001                      moveq.l   #1,d0
[00fd9842] 6002                      bra.s     $00FD9846
[00fd9844] 4240                      clr.w     d0
[00fd9846] fc31                      dc.w      $FC31 ; movem.l (a7)+,d6-d7/a4-a5
#endif

	xdef xfd9848
xfd9848: ds.b 0
#if 0
[00fd9848] 4e56 fffa                 link      a6,#$FFFA
[00fd984c] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd9850] 2a6e 000c                 movea.l   12(a6),a5
[00fd9854] 7eff                      moveq.l   #-1,d7
[00fd9856] 200d                      move.l    a5,d0
[00fd9858] 6700 007a                 beq.w     $00FD98D4
[00fd985c] 302d 0006                 move.w    6(a5),d0
[00fd9860] 6060                      bra.s     $00FD98C2
[00fd9862] 4297                      clr.l     (a7)
[00fd9864] 2f3c 0001 0018            move.l    #$00010018,-(a7)
[00fd986a] f0dc                      dc.w      $F0DC ; fill_string
[00fd986c] 588f                      addq.l    #4,a7
[00fd986e] 4240                      clr.w     d0
[00fd9870] 6000 00ae                 bra       $00FD9920
[00fd9874] 605e                      bra.s     $00FD98D4
[00fd9876] 7e01                      moveq.l   #1,d7
[00fd9878] 605a                      bra.s     $00FD98D4
[00fd987a] 3eae 0010                 move.w    16(a6),(a7)
[00fd987e] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd9884] 0697 0000 5e88            addi.l    #$00005E88,(a7)
[00fd988a] f4d4                      dc.w      $F4D4
[00fd988c] 588f                      addq.l    #4,a7
[00fd988e] 2d40 fffc                 move.l    d0,-4(a6)
[00fd9892] 206e fffc                 movea.l   -4(a6),a0
[00fd9896] 3028 000c                 move.w    12(a0),d0
[00fd989a] c07c 00ff                 and.w     #$00FF,d0
[00fd989e] 2279 0000 a788            movea.l   _thedesk,a1
[00fd98a4] 1340 32b6                 move.b    d0,12982(a1)
[00fd98a8] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd98ae] 0697 0000 32b7            addi.l    #$000032B7,(a7)
[00fd98b4] 2f3c 00fe b15c            move.l    #$00FEB15C,-(a7)
[00fd98ba] f36c                      dc.w      $F36C ; xstrpcpy
[00fd98bc] 588f                      addq.l    #4,a7
[00fd98be] 7e02                      moveq.l   #2,d7
[00fd98c0] 6012                      bra.s     $00FD98D4
[00fd98c2] b07c 0002                 cmp.w     #$0002,d0
[00fd98c6] 67b2                      beq.s     $00FD987A
[00fd98c8] b07c 0003                 cmp.w     #$0003,d0
[00fd98cc] 67a8                      beq.s     $00FD9876
[00fd98ce] b07c 0004                 cmp.w     #$0004,d0
[00fd98d2] 678e                      beq.s     $00FD9862
[00fd98d4] 2eae 0008                 move.l    8(a6),(a7)
[00fd98d8] 3f07                      move.w    d7,-(a7)
[00fd98da] f4d8                      dc.w      $F4D8
[00fd98dc] 548f                      addq.l    #2,a7
[00fd98de] 3d40 fffa                 move.w    d0,-6(a6)
[00fd98e2] 4a6e fffa                 tst.w     -6(a6)
[00fd98e6] 6734                      beq.s     $00FD991C
[00fd98e8] 0c6d 0002 0006            cmpi.w    #$0002,6(a5)
[00fd98ee] 6616                      bne.s     $00FD9906
[00fd98f0] 3ebc 0001                 move.w    #1,(a7)
[00fd98f4] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd98fa] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd9900] f380                      dc.w      $F380 ; up_allwin
[00fd9902] 588f                      addq.l    #4,a7
[00fd9904] 6008                      bra.s     $00FD990E
[00fd9906] 0c6d 0003 0006            cmpi.w    #$0003,6(a5)
[00fd990c] 660e                      bne.s     $00FD991C
[00fd990e] 3ebc 0001                 move.w    #1,(a7)
[00fd9912] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd9916] 5097                      addq.l    #8,(a7)
[00fd9918] f380                      dc.w      $F380 ; up_allwin
[00fd991a] 588f                      addq.l    #4,a7
[00fd991c] 302e fffa                 move.w    -6(a6),d0
[00fd9920] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd9922
xfd9922: ds.b 0
#if 0
[00fd9922] 4e56 fffe                 link      a6,#$FFFE
[00fd9926] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd992a] 2a6e 0010                 movea.l   16(a6),a5
[00fd992e] 286e 0014                 movea.l   20(a6),a4
[00fd9932] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fd9938] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd993e] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd9942] f36c                      dc.w      $F36C ; xstrpcpy
[00fd9944] 588f                      addq.l    #4,a7
[00fd9946] 2679 0000 a788            movea.l   _thedesk,a3
[00fd994c] d7fc 0000 32b6            adda.l    #$000032B6,a3
[00fd9952] 6002                      bra.s     $00FD9956
[00fd9954] 528b                      addq.l    #1,a3
[00fd9956] 0c13 002a                 cmpi.b    #$2A,(a3)
[00fd995a] 66f8                      bne.s     $00FD9954
[00fd995c] 4213                      clr.b     (a3)
[00fd995e] 200d                      move.l    a5,d0
[00fd9960] 6724                      beq.s     $00FD9986
[00fd9962] 0c6d 0001 0006            cmpi.w    #1,6(a5)
[00fd9968] 661c                      bne.s     $00FD9986
[00fd996a] 2e8b                      move.l    a3,(a7)
[00fd996c] 486c 0012                 pea.l     18(a4)
[00fd9970] f36c                      dc.w      $F36C ; xstrpcpy
[00fd9972] 588f                      addq.l    #4,a7
[00fd9974] 2640                      movea.l   d0,a3
[00fd9976] 486b ffff                 pea.l     -1(a3)
[00fd997a] 2f3c 00fe b130            move.l    #_getall,-(a7)
[00fd9980] f36c                      dc.w      $F36C ; xstrpcpy
[00fd9982] 508f                      addq.l    #8,a7
[00fd9984] 600c                      bra.s     $00FD9992
[00fd9986] 2e8b                      move.l    a3,(a7)
[00fd9988] 2f3c 00fe b136            move.l    #$00FEB136,-(a7)
[00fd998e] f404                      dc.w      $F404 ; xstrpcat
[00fd9990] 588f                      addq.l    #4,a7
[00fd9992] 2ebc 0000 634c            move.l    #$0000634C,(a7)
[00fd9998] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd999e] 0697 0000 32b6            addi.l    #$000032B6,(a7)
[00fd99a4] f36c                      dc.w      $F36C ; xstrpcpy
[00fd99a6] 588f                      addq.l    #4,a7
[00fd99a8] 2eae 0008                 move.l    8(a6),(a7)
[00fd99ac] 3f3c 0002                 move.w    #$0002,-(a7)
[00fd99b0] f4d8                      dc.w      $F4D8
[00fd99b2] 548f                      addq.l    #2,a7
[00fd99b4] 3d40 fffe                 move.w    d0,-2(a6)
[00fd99b8] 4a6e fffe                 tst.w     -2(a6)
[00fd99bc] 671c                      beq.s     $00FD99DA
[00fd99be] 3ebc 0001                 move.w    #1,(a7)
[00fd99c2] 2f3c 0000 634c            move.l    #$0000634C,-(a7)
[00fd99c8] f380                      dc.w      $F380 ; up_allwin
[00fd99ca] 588f                      addq.l    #4,a7
[00fd99cc] 3ebc 0001                 move.w    #1,(a7)
[00fd99d0] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd99d4] 5097                      addq.l    #8,(a7)
[00fd99d6] f380                      dc.w      $F380 ; up_allwin
[00fd99d8] 588f                      addq.l    #4,a7
[00fd99da] 302e fffe                 move.w    -2(a6),d0
[00fd99de] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfd99e0
xfd99e0: ds.b 0
#if 0
[00fd99e0] 4e56 fff4                 link      a6,#$FFF4
[00fd99e4] 4297                      clr.l     (a7)
[00fd99e6] 42a7                      clr.l     -(a7)
[00fd99e8] 3f2e 000a                 move.w    10(a6),-(a7)
[00fd99ec] 4267                      clr.w     -(a7)
[00fd99ee] 3f3c 0001                 move.w    #1,-(a7)
[00fd99f2] f4dc                      dc.w      $F4DC
[00fd99f4] defc 000a                 adda.w    #10,a7
[00fd99f8] 2d40 fff8                 move.l    d0,-8(a6)
[00fd99fc] 3eae 0008                 move.w    8(a6),(a7)
[00fd9a00] f2ec                      dc.w      $F2EC
[00fd9a02] 2d40 fffc                 move.l    d0,-4(a6)
[00fd9a06] 2079 0000 a788            movea.l   _thedesk,a0
[00fd9a0c] 2ea8 35a8                 move.l    13736(a0),(a7)
[00fd9a10] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd9a14] 0697 0000 001c            addi.l    #$0000001C,(a7)
[00fd9a1a] f39c                      dc.w      $F39C ; streq
[00fd9a1c] 588f                      addq.l    #4,a7
[00fd9a1e] 4a40                      tst.w     d0
[00fd9a20] 6734                      beq.s     $00FD9A56
[00fd9a22] 206e fff8                 movea.l   -8(a6),a0
[00fd9a26] 3028 0006                 move.w    6(a0),d0
[00fd9a2a] 6016                      bra.s     $00FD9A42
[00fd9a2c] 4297                      clr.l     (a7)
[00fd9a2e] 2f3c 0001 0018            move.l    #$00010018,-(a7)
[00fd9a34] f0dc                      dc.w      $F0DC ; fill_string
[00fd9a36] 588f                      addq.l    #4,a7
[00fd9a38] 601a                      bra.s     $00FD9A54
[00fd9a3a] 3ebc 0005                 move.w    #$0005,(a7)
[00fd9a3e] f0e8                      dc.w      $F0E8 ; form_error
[00fd9a40] 6012                      bra.s     $00FD9A54
[00fd9a42] b07c 0002                 cmp.w     #$0002,d0
[00fd9a46] 67e4                      beq.s     $00FD9A2C
[00fd9a48] b07c 0003                 cmp.w     #$0003,d0
[00fd9a4c] 67ec                      beq.s     $00FD9A3A
[00fd9a4e] b07c 0004                 cmp.w     #$0004,d0
[00fd9a52] 67d8                      beq.s     $00FD9A2C
[00fd9a54] 6014                      bra.s     $00FD9A6A
[00fd9a56] 3eae 000a                 move.w    10(a6),(a7)
[00fd9a5a] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fd9a5e] 206e fffc                 movea.l   -4(a6),a0
[00fd9a62] 2f28 0018                 move.l    24(a0),-(a7)
[00fd9a66] f4e0                      dc.w      $F4E0
[00fd9a68] 508f                      addq.l    #8,a7
[00fd9a6a] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfd9a6c
xfd9a6c: ds.b 0
#if 0
[00fd9a6c] 4e56 fffc                 link      a6,#-4
[00fd9a70] 48e7 030c                 movem.l   d6-d7/a4-a5,-(a7)
[00fd9a74] 3eae 0008                 move.w    8(a6),(a7)
[00fd9a78] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd9a7e] 0697 0000 5e88            addi.l    #$00005E88,(a7)
[00fd9a84] f4d4                      dc.w      $F4D4
[00fd9a86] 588f                      addq.l    #4,a7
[00fd9a88] 2d40 fffc                 move.l    d0,-4(a6)
[00fd9a8c] 206e fffc                 movea.l   -4(a6),a0
[00fd9a90] 3ea8 000c                 move.w    12(a0),(a7)
[00fd9a94] f4e4                      dc.w      $F4E4
[00fd9a96] 4a40                      tst.w     d0
[00fd9a98] 6606                      bne.s     $00FD9AA0
[00fd9a9a] 4240                      clr.w     d0
[00fd9a9c] 6000 009c                 bra       $00FD9B3A
[00fd9aa0] 3ebc 0016                 move.w    #$0016,(a7)
[00fd9aa4] 2f3c 00fe b165            move.l    #$00FEB165,-(a7)
[00fd9aaa] 2f3c 00fe b163            move.l    #$00FEB163,-(a7)
[00fd9ab0] 2f3c 00fe b162            move.l    #$00FEB162,-(a7)
[00fd9ab6] 206e fffc                 movea.l   -4(a6),a0
[00fd9aba] 3f28 000c                 move.w    12(a0),-(a7)
[00fd9abe] f4e8                      dc.w      $F4E8
[00fd9ac0] defc 000e                 adda.w    #$000E,a7
[00fd9ac4] 2840                      movea.l   d0,a4
[00fd9ac6] 200c                      move.l    a4,d0
[00fd9ac8] 676e                      beq.s     $00FD9B38
[00fd9aca] 2e8c                      move.l    a4,(a7)
[00fd9acc] f4ac                      dc.w      $F4AC
[00fd9ace] 4247                      clr.w     d7
[00fd9ad0] 4aac 0082                 tst.l     130(a4)
[00fd9ad4] 675a                      beq.s     $00FD9B30
[00fd9ad6] 2a6c 0082                 movea.l   130(a4),a5
[00fd9ada] 6006                      bra.s     $00FD9AE2
[00fd9adc] 426d 0020                 clr.w     32(a5)
[00fd9ae0] 2a55                      movea.l   (a5),a5
[00fd9ae2] 200d                      move.l    a5,d0
[00fd9ae4] 66f6                      bne.s     $00FD9ADC
[00fd9ae6] 2079 0000 a788            movea.l   _thedesk,a0
[00fd9aec] 317c 0001 5e92            move.w    #1,24210(a0)
[00fd9af2] 4aae 000a                 tst.l     10(a6)
[00fd9af6] 671e                      beq.s     $00FD9B16
[00fd9af8] 2eae 0012                 move.l    18(a6),(a7)
[00fd9afc] 2f2e 000e                 move.l    14(a6),-(a7)
[00fd9b00] 206e 000a                 movea.l   10(a6),a0
[00fd9b04] 2f28 0018                 move.l    24(a0),-(a7)
[00fd9b08] 5097                      addq.l    #8,(a7)
[00fd9b0a] 2f0c                      move.l    a4,-(a7)
[00fd9b0c] f4ec                      dc.w      $F4EC
[00fd9b0e] defc 000c                 adda.w    #12,a7
[00fd9b12] 3e00                      move.w    d0,d7
[00fd9b14] 6010                      bra.s     $00FD9B26
[00fd9b16] 3eae 0016                 move.w    22(a6),(a7)
[00fd9b1a] 2f2e 000e                 move.l    14(a6),-(a7)
[00fd9b1e] 2f0c                      move.l    a4,-(a7)
[00fd9b20] f4e0                      dc.w      $F4E0
[00fd9b22] 508f                      addq.l    #8,a7
[00fd9b24] 3e00                      move.w    d0,d7
[00fd9b26] 2079 0000 a788            movea.l   _thedesk,a0
[00fd9b2c] 4268 5e92                 clr.w     24210(a0)
[00fd9b30] 2e8c                      move.l    a4,(a7)
[00fd9b32] f4f0                      dc.w      $F4F0
[00fd9b34] 4257                      clr.w     (a7)
[00fd9b36] f444                      dc.w      $F444
[00fd9b38] 3007                      move.w    d7,d0
[00fd9b3a] fc21                      dc.w      $FC21 ; movem.l (a7)+,d7/a4-a5
#endif

	xdef xfd9b3c
xfd9b3c: ds.b 0
#if 0
[00fd9b3c] 4e56 fff6                 link      a6,#$FFF6
[00fd9b40] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fd9b44] 3e2e 000a                 move.w    10(a6),d7
[00fd9b48] 3eae 0008                 move.w    8(a6),(a7)
[00fd9b4c] f2ec                      dc.w      $F2EC
[00fd9b4e] 2a40                      movea.l   d0,a5
[00fd9b50] 486e fffa                 pea.l     -6(a6)
[00fd9b54] 486e fffc                 pea.l     -4(a6)
[00fd9b58] 3f07                      move.w    d7,-(a7)
[00fd9b5a] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd9b5e] f2f8                      dc.w      $F2F8
[00fd9b60] defc 000c                 adda.w    #12,a7
[00fd9b64] 2640                      movea.l   d0,a3
[00fd9b66] 4246                      clr.w     d6
[00fd9b68] 605a                      bra.s     $00FD9BC4
[00fd9b6a] 486e fffa                 pea.l     -6(a6)
[00fd9b6e] 486e fff6                 pea.l     -10(a6)
[00fd9b72] 3f06                      move.w    d6,-(a7)
[00fd9b74] 4267                      clr.w     -(a7)
[00fd9b76] f2f8                      dc.w      $F2F8
[00fd9b78] defc 000c                 adda.w    #12,a7
[00fd9b7c] 2840                      movea.l   d0,a4
[00fd9b7e] 0c6c 0003 0006            cmpi.w    #$0003,6(a4)
[00fd9b84] 660e                      bne.s     $00FD9B94
[00fd9b86] 4297                      clr.l     (a7)
[00fd9b88] 2f3c 0001 0014            move.l    #$00010014,-(a7)
[00fd9b8e] f0dc                      dc.w      $F0DC ; fill_string
[00fd9b90] 588f                      addq.l    #4,a7
[00fd9b92] 6030                      bra.s     $00FD9BC4
[00fd9b94] 0c6c 0004 0006            cmpi.w    #$0004,6(a4)
[00fd9b9a] 660e                      bne.s     $00FD9BAA
[00fd9b9c] 4297                      clr.l     (a7)
[00fd9b9e] 2f3c 0001 0018            move.l    #$00010018,-(a7)
[00fd9ba4] f0dc                      dc.w      $F0DC ; fill_string
[00fd9ba6] 588f                      addq.l    #4,a7
[00fd9ba8] 601a                      bra.s     $00FD9BC4
[00fd9baa] 3e87                      move.w    d7,(a7)
[00fd9bac] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fd9bb0] 2f0b                      move.l    a3,-(a7)
[00fd9bb2] 2f0d                      move.l    a5,-(a7)
[00fd9bb4] 3f06                      move.w    d6,-(a7)
[00fd9bb6] f4f4                      dc.w      $F4F4
[00fd9bb8] defc 000e                 adda.w    #$000E,a7
[00fd9bbc] 4a40                      tst.w     d0
[00fd9bbe] 6704                      beq.s     $00FD9BC4
[00fd9bc0] 2e8d                      move.l    a5,(a7)
[00fd9bc2] f4c8                      dc.w      $F4C8
[00fd9bc4] 3e86                      move.w    d6,(a7)
[00fd9bc6] 3f3c 0001                 move.w    #1,-(a7)
[00fd9bca] 2f39 0000 a788            move.l    _thedesk,-(a7)
[00fd9bd0] 0697 0000 5e88            addi.l    #$00005E88,(a7)
[00fd9bd6] f4f8                      dc.w      $F4F8
[00fd9bd8] 5c8f                      addq.l    #6,a7
[00fd9bda] 3c00                      move.w    d0,d6
[00fd9bdc] 668c                      bne.s     $00FD9B6A
[00fd9bde] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfd9be0
xfd9be0: ds.b 0
#if 0
[00fd9be0] 4e56 ffcc                 link      a6,#$FFCC
[00fd9be4] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fd9be8] 2679 0000 a788            movea.l   _thedesk,a3
[00fd9bee] 426e ffd0                 clr.w     -48(a6)
[00fd9bf2] 4297                      clr.l     (a7)
[00fd9bf4] 42a7                      clr.l     -(a7)
[00fd9bf6] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd9bfa] 4267                      clr.w     -(a7)
[00fd9bfc] 3f3c 0001                 move.w    #1,-(a7)
[00fd9c00] f4dc                      dc.w      $F4DC
[00fd9c02] defc 000a                 adda.w    #10,a7
[00fd9c06] 2840                      movea.l   d0,a4
[00fd9c08] 426e fffe                 clr.w     -2(a6)
[00fd9c0c] 6000 014a                 bra       $00FD9D58
[00fd9c10] 486e fffc                 pea.l     -4(a6)
[00fd9c14] 486e fff8                 pea.l     -8(a6)
[00fd9c18] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fd9c1c] 4267                      clr.w     -(a7)
[00fd9c1e] f2f8                      dc.w      $F2F8
[00fd9c20] defc 000c                 adda.w    #12,a7
[00fd9c24] 2a40                      movea.l   d0,a5
[00fd9c26] bbcc                      cmpa.l    a4,a5
[00fd9c28] 6700 012e                 beq       $00FD9D58
[00fd9c2c] 0c6d 0004 0006            cmpi.w    #$0004,6(a5)
[00fd9c32] 6708                      beq.s     $00FD9C3C
[00fd9c34] 0c6d 0003 0006            cmpi.w    #$0003,6(a5)
[00fd9c3a] 6616                      bne.s     $00FD9C52
[00fd9c3c] 4297                      clr.l     (a7)
[00fd9c3e] 2f3c 0001 0010            move.l    #$00010010,-(a7)
[00fd9c44] f0dc                      dc.w      $F0DC ; fill_string
[00fd9c46] 588f                      addq.l    #4,a7
[00fd9c48] 4240                      clr.w     d0
[00fd9c4a] 6000 0128                 bra       $00FD9D74
[00fd9c4e] 6000 0108                 bra       $00FD9D58
[00fd9c52] 302c 0006                 move.w    6(a4),d0
[00fd9c56] 6000 00e8                 bra       $00FD9D40
[00fd9c5a] 4297                      clr.l     (a7)
[00fd9c5c] 2f3c 0001 0011            move.l    #$00010011,-(a7)
[00fd9c62] f0dc                      dc.w      $F0DC ; fill_string
[00fd9c64] 588f                      addq.l    #4,a7
[00fd9c66] 4240                      clr.w     d0
[00fd9c68] 6000 010a                 bra       $00FD9D74
[00fd9c6c] 4297                      clr.l     (a7)
[00fd9c6e] 2f3c 0001 0018            move.l    #$00010018,-(a7)
[00fd9c74] f0dc                      dc.w      $F0DC ; fill_string
[00fd9c76] 588f                      addq.l    #4,a7
[00fd9c78] 4240                      clr.w     d0
[00fd9c7a] 6000 00f8                 bra       $00FD9D74
[00fd9c7e] 6000 00d8                 bra       $00FD9D58
[00fd9c82] 3eae fffe                 move.w    -2(a6),(a7)
[00fd9c86] 486b 5e88                 pea.l     24200(a3)
[00fd9c8a] f4d4                      dc.w      $F4D4
[00fd9c8c] 588f                      addq.l    #4,a7
[00fd9c8e] 2d40 fff0                 move.l    d0,-16(a6)
[00fd9c92] 3eae 0008                 move.w    8(a6),(a7)
[00fd9c96] 486b 5e88                 pea.l     24200(a3)
[00fd9c9a] f4d4                      dc.w      $F4D4
[00fd9c9c] 588f                      addq.l    #4,a7
[00fd9c9e] 2d40 ffec                 move.l    d0,-20(a6)
[00fd9ca2] 206e fff0                 movea.l   -16(a6),a0
[00fd9ca6] 3028 000c                 move.w    12(a0),d0
[00fd9caa] c07c 00ff                 and.w     #$00FF,d0
[00fd9cae] 1d40 ffde                 move.b    d0,-34(a6)
[00fd9cb2] 422e ffdf                 clr.b     -33(a6)
[00fd9cb6] 1d7c 0020 ffe0            move.b    #$20,-32(a6)
[00fd9cbc] 206e ffec                 movea.l   -20(a6),a0
[00fd9cc0] 3028 000c                 move.w    12(a0),d0
[00fd9cc4] c07c 00ff                 and.w     #$00FF,d0
[00fd9cc8] 1d40 ffe1                 move.b    d0,-31(a6)
[00fd9ccc] 422e ffe2                 clr.b     -30(a6)
[00fd9cd0] 0c2e 0042 ffde            cmpi.b    #$42,-34(a6)
[00fd9cd6] 6e18                      bgt.s     $00FD9CF0
[00fd9cd8] 0c2e 0041 ffde            cmpi.b    #$41,-34(a6)
[00fd9cde] 6d10                      blt.s     $00FD9CF0
[00fd9ce0] 0c2e 0042 ffe1            cmpi.b    #$42,-31(a6)
[00fd9ce6] 6e08                      bgt.s     $00FD9CF0
[00fd9ce8] 0c2e 0041 ffe1            cmpi.b    #$41,-31(a6)
[00fd9cee] 6c12                      bge.s     $00FD9D02
[00fd9cf0] 4297                      clr.l     (a7)
[00fd9cf2] 2f3c 0001 0021            move.l    #$00010021,-(a7)
[00fd9cf8] f0dc                      dc.w      $F0DC ; fill_string
[00fd9cfa] 588f                      addq.l    #4,a7
[00fd9cfc] 4240                      clr.w     d0
[00fd9cfe] 6000 0074                 bra.w     $00FD9D74
[00fd9d02] 41ee ffde                 lea.l     -34(a6),a0
[00fd9d06] 2d48 ffd2                 move.l    a0,-46(a6)
[00fd9d0a] 41ee ffe1                 lea.l     -31(a6),a0
[00fd9d0e] 2d48 ffd6                 move.l    a0,-42(a6)
[00fd9d12] 41ee ffe1                 lea.l     -31(a6),a0
[00fd9d16] 2d48 ffda                 move.l    a0,-38(a6)
[00fd9d1a] 486e ffd2                 pea.l     -46(a6)
[00fd9d1e] 2f3c 0002 0012            move.l    #$00020012,-(a7)
[00fd9d24] f0dc                      dc.w      $F0DC ; fill_string
[00fd9d26] 508f                      addq.l    #8,a7
[00fd9d28] b07c 0001                 cmp.w     #1,d0
[00fd9d2c] 6610                      bne.s     $00FD9D3E
[00fd9d2e] 3ebc 00fb                 move.w    #$00FB,(a7)
[00fd9d32] 486e ffde                 pea.l     -34(a6)
[00fd9d36] f4fc                      dc.w      $F4FC ; fc_start
[00fd9d38] 588f                      addq.l    #4,a7
[00fd9d3a] 426e ffd0                 clr.w     -48(a6)
[00fd9d3e] 6018                      bra.s     $00FD9D58
[00fd9d40] b07c 0002                 cmp.w     #$0002,d0
[00fd9d44] 6700 ff3c                 beq       $00FD9C82
[00fd9d48] b07c 0003                 cmp.w     #$0003,d0
[00fd9d4c] 6700 ff0c                 beq       $00FD9C5A
[00fd9d50] b07c 0004                 cmp.w     #$0004,d0
[00fd9d54] 6700 ff16                 beq       $00FD9C6C
[00fd9d58] 3eae fffe                 move.w    -2(a6),(a7)
[00fd9d5c] 3f3c 0001                 move.w    #1,-(a7)
[00fd9d60] 486b 5e88                 pea.l     24200(a3)
[00fd9d64] f4f8                      dc.w      $F4F8
[00fd9d66] 5c8f                      addq.l    #6,a7
[00fd9d68] 3d40 fffe                 move.w    d0,-2(a6)
[00fd9d6c] 6600 fea2                 bne       $00FD9C10
[00fd9d70] 302e ffd0                 move.w    -48(a6),d0
[00fd9d74] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfd9d76
xfd9d76: ds.b 0
#if 0
[00fd9d76] 4e56 fff8                 link      a6,#$FFF8
[00fd9d7a] 48e7 1f1c                 movem.l   d3-d7/a3-a5,-(a7)
[00fd9d7e] 3e2e 0008                 move.w    8(a6),d7
[00fd9d82] 3c2e 000a                 move.w    10(a6),d6
[00fd9d86] 3a2e 000c                 move.w    12(a6),d5
[00fd9d8a] 382e 000e                 move.w    14(a6),d4
[00fd9d8e] 426e fffe                 clr.w     -2(a6)
[00fd9d92] 4a47                      tst.w     d7
[00fd9d94] 6700 00a2                 beq       $00FD9E38
[00fd9d98] 4a46                      tst.w     d6
[00fd9d9a] 6700 0080                 beq       $00FD9E1C
[00fd9d9e] 3e87                      move.w    d7,(a7)
[00fd9da0] f2ec                      dc.w      $F2EC
[00fd9da2] 2a40                      movea.l   d0,a5
[00fd9da4] 3e86                      move.w    d6,(a7)
[00fd9da6] f2ec                      dc.w      $F2EC
[00fd9da8] 2840                      movea.l   d0,a4
[00fd9daa] 2079 0000 a788            movea.l   _thedesk,a0
[00fd9db0] 2ea8 35a8                 move.l    13736(a0),(a7)
[00fd9db4] 486d 001c                 pea.l     28(a5)
[00fd9db8] f39c                      dc.w      $F39C ; streq
[00fd9dba] 588f                      addq.l    #4,a7
[00fd9dbc] 4a40                      tst.w     d0
[00fd9dbe] 6616                      bne.s     $00FD9DD6
[00fd9dc0] 2079 0000 a788            movea.l   _thedesk,a0
[00fd9dc6] 2ea8 35a8                 move.l    13736(a0),(a7)
[00fd9dca] 486c 001c                 pea.l     28(a4)
[00fd9dce] f39c                      dc.w      $F39C ; streq
[00fd9dd0] 588f                      addq.l    #4,a7
[00fd9dd2] 4a40                      tst.w     d0
[00fd9dd4] 670e                      beq.s     $00FD9DE4
[00fd9dd6] 4297                      clr.l     (a7)
[00fd9dd8] 2f3c 0001 0018            move.l    #$00010018,-(a7)
[00fd9dde] f0dc                      dc.w      $F0DC ; fill_string
[00fd9de0] 588f                      addq.l    #4,a7
[00fd9de2] 6036                      bra.s     $00FD9E1A
[00fd9de4] 486e fffc                 pea.l     -4(a6)
[00fd9de8] 486e fff8                 pea.l     -8(a6)
[00fd9dec] 3f04                      move.w    d4,-(a7)
[00fd9dee] 3f06                      move.w    d6,-(a7)
[00fd9df0] f2f8                      dc.w      $F2F8
[00fd9df2] defc 000c                 adda.w    #12,a7
[00fd9df6] 2640                      movea.l   d0,a3
[00fd9df8] 2eae fff8                 move.l    -8(a6),(a7)
[00fd9dfc] 2f0b                      move.l    a3,-(a7)
[00fd9dfe] 2f2c 0018                 move.l    24(a4),-(a7)
[00fd9e02] 5097                      addq.l    #8,(a7)
[00fd9e04] 2f2d 0018                 move.l    24(a5),-(a7)
[00fd9e08] f4ec                      dc.w      $F4EC
[00fd9e0a] defc 000c                 adda.w    #12,a7
[00fd9e0e] 4a40                      tst.w     d0
[00fd9e10] 6708                      beq.s     $00FD9E1A
[00fd9e12] be46                      cmp.w     d6,d7
[00fd9e14] 6704                      beq.s     $00FD9E1A
[00fd9e16] 3e87                      move.w    d7,(a7)
[00fd9e18] f444                      dc.w      $F444
[00fd9e1a] 601a                      bra.s     $00FD9E36
[00fd9e1c] b845                      cmp.w     d5,d4
[00fd9e1e] 660e                      bne.s     $00FD9E2E
[00fd9e20] 4297                      clr.l     (a7)
[00fd9e22] 2f3c 0001 0013            move.l    #$00010013,-(a7)
[00fd9e28] f0dc                      dc.w      $F0DC ; fill_string
[00fd9e2a] 588f                      addq.l    #4,a7
[00fd9e2c] 6008                      bra.s     $00FD9E36
[00fd9e2e] 3e84                      move.w    d4,(a7)
[00fd9e30] 3f07                      move.w    d7,-(a7)
[00fd9e32] f500                      dc.w      $F500
[00fd9e34] 548f                      addq.l    #2,a7
[00fd9e36] 601a                      bra.s     $00FD9E52
[00fd9e38] 4a46                      tst.w     d6
[00fd9e3a] 670a                      beq.s     $00FD9E46
[00fd9e3c] 3e84                      move.w    d4,(a7)
[00fd9e3e] 3f06                      move.w    d6,-(a7)
[00fd9e40] f504                      dc.w      $F504
[00fd9e42] 548f                      addq.l    #2,a7
[00fd9e44] 600c                      bra.s     $00FD9E52
[00fd9e46] b845                      cmp.w     d5,d4
[00fd9e48] 6708                      beq.s     $00FD9E52
[00fd9e4a] 3e84                      move.w    d4,(a7)
[00fd9e4c] f508                      dc.w      $F508
[00fd9e4e] 3d40 fffe                 move.w    d0,-2(a6)
[00fd9e52] 302e fffe                 move.w    -2(a6),d0
[00fd9e56] fe3d                      dc.w      $FE3D ; movem.l (a7)+,d4-d7/a3-a5
#endif

	xdef xfd9e58
xfd9e58: ds.b 0
#if 0
[00fd9e58] 4e56 0000                 link      a6,#0
[00fd9e5c] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd9e60] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd9e66] 7e01                      moveq.l   #1,d7
[00fd9e68] 6026                      bra.s     $00FD9E90
[00fd9e6a] 204d                      movea.l   a5,a0
[00fd9e6c] 3207                      move.w    d7,d1
[00fd9e6e] 5241                      addq.w    #1,d1
[00fd9e70] c3fc 0018                 muls.w    #24,d1
[00fd9e74] d1c1                      adda.l    d1,a0
[00fd9e76] 4a68 5e9c                 tst.w     24220(a0)
[00fd9e7a] 671a                      beq.s     $00FD9E96
[00fd9e7c] 204d                      movea.l   a5,a0
[00fd9e7e] 3207                      move.w    d7,d1
[00fd9e80] 5241                      addq.w    #1,d1
[00fd9e82] c3fc 0018                 muls.w    #24,d1
[00fd9e86] d1c1                      adda.l    d1,a0
[00fd9e88] 4a68 5e9e                 tst.w     24222(a0)
[00fd9e8c] 6708                      beq.s     $00FD9E96
[00fd9e8e] 5247                      addq.w    #1,d7
[00fd9e90] be7c 0005                 cmp.w     #$0005,d7
[00fd9e94] 6dd4                      blt.s     $00FD9E6A
[00fd9e96] be7c 0005                 cmp.w     #$0005,d7
[00fd9e9a] 6c2a                      bge.s     $00FD9EC6
[00fd9e9c] 2f2e 000c                 move.l    12(a6),-(a7)
[00fd9ea0] 2f2e 0008                 move.l    8(a6),-(a7)
[00fd9ea4] 200d                      move.l    a5,d0
[00fd9ea6] 3207                      move.w    d7,d1
[00fd9ea8] 5241                      addq.w    #1,d1
[00fd9eaa] c3fc 0018                 muls.w    #24,d1
[00fd9eae] d081                      add.l     d1,d0
[00fd9eb0] 2f00                      move.l    d0,-(a7)
[00fd9eb2] 0697 0000 5e98            addi.l    #$00005E98,(a7)
[00fd9eb8] f298                      dc.w      $F298 ; r_set
[00fd9eba] defc 000c                 adda.w    #12,a7
[00fd9ebe] 3007                      move.w    d7,d0
[00fd9ec0] 5240                      addq.w    #1,d0
[00fd9ec2] 6004                      bra.s     $00FD9EC8
[00fd9ec4] 6002                      bra.s     $00FD9EC8
[00fd9ec6] 4240                      clr.w     d0
[00fd9ec8] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd9eca
xfd9eca: ds.b 0
#if 0
[00fd9eca] 4e56 0000                 link      a6,#0
[00fd9ece] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fd9ed2] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd9ed8] 2f2e 000e                 move.l    14(a6),-(a7)
[00fd9edc] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd9ee0] 200d                      move.l    a5,d0
[00fd9ee2] 322e 0008                 move.w    8(a6),d1
[00fd9ee6] c3fc 0018                 muls.w    #24,d1
[00fd9eea] d081                      add.l     d1,d0
[00fd9eec] 2f00                      move.l    d0,-(a7)
[00fd9eee] 0697 0000 5e98            addi.l    #$00005E98,(a7)
[00fd9ef4] f298                      dc.w      $F298 ; r_set
[00fd9ef6] defc 000c                 adda.w    #12,a7
[00fd9efa] 204d                      movea.l   a5,a0
[00fd9efc] 322e 0008                 move.w    8(a6),d1
[00fd9f00] c3fc 0018                 muls.w    #24,d1
[00fd9f04] d1c1                      adda.l    d1,a0
[00fd9f06] 3e28 5e8a                 move.w    24202(a0),d7
[00fd9f0a] 6020                      bra.s     $00FD9F2C
[00fd9f0c] 204d                      movea.l   a5,a0
[00fd9f0e] 3207                      move.w    d7,d1
[00fd9f10] c3fc 0018                 muls.w    #24,d1
[00fd9f14] d1c1                      adda.l    d1,a0
[00fd9f16] 3c28 5e88                 move.w    24200(a0),d6
[00fd9f1a] 204d                      movea.l   a5,a0
[00fd9f1c] 3207                      move.w    d7,d1
[00fd9f1e] c3fc 0018                 muls.w    #24,d1
[00fd9f22] d1c1                      adda.l    d1,a0
[00fd9f24] 317c ffff 5e88            move.w    #$FFFF,24200(a0)
[00fd9f2a] 3e06                      move.w    d6,d7
[00fd9f2c] be6e 0008                 cmp.w     8(a6),d7
[00fd9f30] 6eda                      bgt.s     $00FD9F0C
[00fd9f32] 204d                      movea.l   a5,a0
[00fd9f34] 322e 0008                 move.w    8(a6),d1
[00fd9f38] c3fc 0018                 muls.w    #24,d1
[00fd9f3c] d1c1                      adda.l    d1,a0
[00fd9f3e] 70ff                      moveq.l   #-1,d0
[00fd9f40] 3140 5e8c                 move.w    d0,24204(a0)
[00fd9f44] 224d                      movea.l   a5,a1
[00fd9f46] 342e 0008                 move.w    8(a6),d2
[00fd9f4a] c5fc 0018                 muls.w    #24,d2
[00fd9f4e] d3c2                      adda.l    d2,a1
[00fd9f50] 3340 5e8a                 move.w    d0,24202(a1)
[00fd9f54] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfd9f56
xfd9f56: ds.b 0
#if 0
[00fd9f56] 4e56 0000                 link      a6,#0
[00fd9f5a] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd9f5e] 2a79 0000 a788            movea.l   _thedesk,a5
[00fd9f64] 7e06                      moveq.l   #6,d7
[00fd9f66] 6014                      bra.s     $00FD9F7C
[00fd9f68] 204d                      movea.l   a5,a0
[00fd9f6a] 3207                      move.w    d7,d1
[00fd9f6c] c3fc 0018                 muls.w    #24,d1
[00fd9f70] d1c1                      adda.l    d1,a0
[00fd9f72] 0c68 ffff 5e88            cmpi.w    #$FFFF,24200(a0)
[00fd9f78] 6708                      beq.s     $00FD9F82
[00fd9f7a] 5247                      addq.w    #1,d7
[00fd9f7c] be7c 0104                 cmp.w     #$0104,d7
[00fd9f80] 6de6                      blt.s     $00FD9F68
[00fd9f82] be7c 0104                 cmp.w     #$0104,d7
[00fd9f86] 6c52                      bge.s     $00FD9FDA
[00fd9f88] 204d                      movea.l   a5,a0
[00fd9f8a] 3207                      move.w    d7,d1
[00fd9f8c] c3fc 0018                 muls.w    #24,d1
[00fd9f90] d1c1                      adda.l    d1,a0
[00fd9f92] 70ff                      moveq.l   #-1,d0
[00fd9f94] 3140 5e8c                 move.w    d0,24204(a0)
[00fd9f98] 224d                      movea.l   a5,a1
[00fd9f9a] 3407                      move.w    d7,d2
[00fd9f9c] c5fc 0018                 muls.w    #24,d2
[00fd9fa0] d3c2                      adda.l    d2,a1
[00fd9fa2] 3340 5e8a                 move.w    d0,24202(a1)
[00fd9fa6] 3e87                      move.w    d7,(a7)
[00fd9fa8] 3f2e 0008                 move.w    8(a6),-(a7)
[00fd9fac] 2f2d 5e2c                 move.l    24108(a5),-(a7)
[00fd9fb0] f554                      dc.w      $F554 ; objc_add
[00fd9fb2] 5c8f                      addq.l    #6,a7
[00fd9fb4] 2f2e 000e                 move.l    14(a6),-(a7)
[00fd9fb8] 2f2e 000a                 move.l    10(a6),-(a7)
[00fd9fbc] 200d                      move.l    a5,d0
[00fd9fbe] 3207                      move.w    d7,d1
[00fd9fc0] c3fc 0018                 muls.w    #24,d1
[00fd9fc4] d081                      add.l     d1,d0
[00fd9fc6] 2f00                      move.l    d0,-(a7)
[00fd9fc8] 0697 0000 5e98            addi.l    #24216,(a7)
[00fd9fce] f298                      dc.w      $F298 ; r_set
[00fd9fd0] defc 000c                 adda.w    #12,a7
[00fd9fd4] 3007                      move.w    d7,d0
[00fd9fd6] 6004                      bra.s     $00FD9FDC
[00fd9fd8] 6002                      bra.s     $00FD9FDC
[00fd9fda] 4240                      clr.w     d0
[00fd9fdc] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfd9fde
xfd9fde: ds.b 0
#if 0
[00fd9fde] 4e56 0000                 link      a6,#0
[00fd9fe2] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00fd9fe6] 2a79 0000 a7b6            movea.l   $0000A7B6,a5
[00fd9fec] 0c6e 0063 0008            cmpi.w    #$0063,8(a6)
[00fd9ff2] 660a                      bne.s     $00FD9FFE
[00fd9ff4] 4279 0000 742a            clr.w     _DOS_ERR
[00fd9ffa] 7001                      moveq.l   #1,d0
[00fd9ffc] 6066                      bra.s     $00FDA064
[00fd9ffe] 4a6e 0008                 tst.w     8(a6)
[00fda002] 675e                      beq.s     $00FDA062
[00fda004] 1b7c 005c 0100            move.b    #$5C,256(a5)
[00fda00a] 486d 0101                 pea.l     257(a5)
[00fda00e] 2f2e 000a                 move.l    10(a6),-(a7)
[00fda012] f36c                      dc.w      $F36C ; xstrpcpy
[00fda014] 508f                      addq.l    #8,a7
[00fda016] 7e01                      moveq.l   #1,d7
[00fda018] 602c                      bra.s     $00FDA046
[00fda01a] 204d                      movea.l   a5,a0
[00fda01c] 3247                      movea.w   d7,a1
[00fda01e] d1c9                      adda.l    a1,a0
[00fda020] 0c28 0020 0100            cmpi.b    #$20,256(a0)
[00fda026] 670e                      beq.s     $00FDA036
[00fda028] 204d                      movea.l   a5,a0
[00fda02a] 3247                      movea.w   d7,a1
[00fda02c] d1c9                      adda.l    a1,a0
[00fda02e] 0c28 002a 0100            cmpi.b    #$2A,256(a0)
[00fda034] 660e                      bne.s     $00FDA044
[00fda036] 204d                      movea.l   a5,a0
[00fda038] 3247                      movea.w   d7,a1
[00fda03a] d1c9                      adda.l    a1,a0
[00fda03c] 4228 0100                 clr.b     256(a0)
[00fda040] 6010                      bra.s     $00FDA052
[00fda042] 6002                      bra.s     $00FDA046
[00fda044] 5247                      addq.w    #1,d7
[00fda046] 204d                      movea.l   a5,a0
[00fda048] 3247                      movea.w   d7,a1
[00fda04a] d1c9                      adda.l    a1,a0
[00fda04c] 4a28 0100                 tst.b     256(a0)
[00fda050] 66c8                      bne.s     $00FDA01A
[00fda052] 486d 0100                 pea.l     256(a5)
[00fda056] 3f2e 0008                 move.w    8(a6),-(a7)
[00fda05a] 0657 ffbf                 addi.w    #$FFBF,(a7)
[00fda05e] f558                      dc.w      $F558 ; do_cdir
[00fda060] 5c8f                      addq.l    #6,a7
[00fda062] 7001                      moveq.l   #1,d0
[00fda064] f821                      dc.w      $F821 ; movem.l (a7)+,d7/a5
#endif

	xdef xfda066
xfda066: ds.b 0
#if 0
[00fda066] 4e56 fffc                 link      a6,#-4
[00fda06a] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fda06e] 2a79 0000 a788            movea.l   _thedesk,a5
[00fda074] 4a2d 34ce                 tst.b     13518(a5)
[00fda078] 6620                      bne.s     $00FDA09A
[00fda07a] 2e8d                      move.l    a5,(a7)
[00fda07c] 0697 0000 34cf            addi.l    #$000034CF,(a7)
[00fda082] f24c                      dc.w      $F24C ; strlen
[00fda084] 3d40 fffc                 move.w    d0,-4(a6)
[00fda088] 1b40 34ce                 move.b    d0,13518(a5)
[00fda08c] 204d                      movea.l   a5,a0
[00fda08e] 326e fffc                 movea.w   -4(a6),a1
[00fda092] d1c9                      adda.l    a1,a0
[00fda094] 117c 000d 34cf            move.b    #$0D,13519(a0)
[00fda09a] 3ebc 0001                 move.w    #1,(a7)
[00fda09e] f094                      dc.w      $F094 ; desk_wait
[00fda0a0] 2ead 354e                 move.l    13646(a5),(a7)
[00fda0a4] 2f2d 34ca                 move.l    13514(a5),-(a7)
[00fda0a8] 2f2e 0008                 move.l    8(a6),-(a7)
[00fda0ac] 3f3c 0001                 move.w    #1,-(a7)
[00fda0b0] f55c                      dc.w      $F55C ; shel_write
[00fda0b2] defc 000a                 adda.w    #10,a7
[00fda0b6] 3d40 fffe                 move.w    d0,-2(a6)
[00fda0ba] 422d 34ce                 clr.b     13518(a5)
[00fda0be] 0c6e ffff 000c            cmpi.w    #$FFFF,12(a6)
[00fda0c4] 6714                      beq.s     $00FDA0DA
[00fda0c6] 2f2d 343e                 move.l    13374(a5),-(a7)
[00fda0ca] 2f2d 343a                 move.l    13370(a5),-(a7)
[00fda0ce] 2f2e 000c                 move.l    12(a6),-(a7)
[00fda0d2] 4267                      clr.w     -(a7)
[00fda0d4] f560                      dc.w      $F560
[00fda0d6] defc 000e                 adda.w    #$000E,a7
[00fda0da] 302e fffe                 move.w    -2(a6),d0
[00fda0de] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfda0e0
xfda0e0: ds.b 0
#if 0
[00fda0e0] 4e56 fff8                 link      a6,#$FFF8
[00fda0e4] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fda0e8] 3e2e 0008                 move.w    8(a6),d7
[00fda0ec] 486e fff8                 pea.l     -8(a6)
[00fda0f0] 3f3c 0004                 move.w    #$0004,-(a7)
[00fda0f4] 3f07                      move.w    d7,-(a7)
[00fda0f6] f4bc                      dc.w      $F4BC
[00fda0f8] 508f                      addq.l    #8,a7
[00fda0fa] 4a47                      tst.w     d7
[00fda0fc] 670c                      beq.s     $00FDA10A
[00fda0fe] 3e87                      move.w    d7,(a7)
[00fda100] f2ec                      dc.w      $F2EC
[00fda102] 2a40                      movea.l   d0,a5
[00fda104] 3c2d 000a                 move.w    10(a5),d6
[00fda108] 6002                      bra.s     $00FDA10C
[00fda10a] 7c01                      moveq.l   #1,d6
[00fda10c] 3ebc 0001                 move.w    #1,(a7)
[00fda110] 3f3c 0001                 move.w    #1,-(a7)
[00fda114] 4267                      clr.w     -(a7)
[00fda116] 3f3c 0001                 move.w    #1,-(a7)
[00fda11a] 486e fff8                 pea.l     -8(a6)
[00fda11e] 2f3c 0000 700e            move.l    #$0000700E,-(a7)
[00fda124] 4267                      clr.w     -(a7)
[00fda126] 3f06                      move.w    d6,-(a7)
[00fda128] 2079 0000 a788            movea.l   _thedesk,a0
[00fda12e] 2f28 5e2c                 move.l    24108(a0),-(a7)
[00fda132] 3f07                      move.w    d7,-(a7)
[00fda134] f308                      dc.w      $F308
[00fda136] defc 0018                 adda.w    #24,a7
[00fda13a] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfda13c
xfda13c: ds.b 0
#if 0
[00fda13c] 4e56 fff8                 link      a6,#$FFF8
[00fda140] 48e7 070c                 movem.l   d5-d7/a4-a5,-(a7)
[00fda144] 3e2e 0008                 move.w    8(a6),d7
[00fda148] 3c2e 000a                 move.w    10(a6),d6
[00fda14c] 2879 0000 a788            movea.l   _thedesk,a4
[00fda152] 4a47                      tst.w     d7
[00fda154] 6730                      beq.s     $00FDA186
[00fda156] 3e87                      move.w    d7,(a7)
[00fda158] f2ec                      dc.w      $F2EC
[00fda15a] 2a40                      movea.l   d0,a5
[00fda15c] 4a46                      tst.w     d6
[00fda15e] 671e                      beq.s     $00FDA17E
[00fda160] 486e fff8                 pea.l     -8(a6)
[00fda164] 3f3c 0004                 move.w    #$0004,-(a7)
[00fda168] 3f07                      move.w    d7,-(a7)
[00fda16a] f4bc                      dc.w      $F4BC
[00fda16c] 508f                      addq.l    #8,a7
[00fda16e] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fda172] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fda176] 2f0d                      move.l    a5,-(a7)
[00fda178] f564                      dc.w      $F564
[00fda17a] defc 000c                 adda.w    #12,a7
[00fda17e] 396d 000a 3596            move.w    10(a5),13718(a4)
[00fda184] 6006                      bra.s     $00FDA18C
[00fda186] 397c 0001 3596            move.w    #1,13718(a4)
[00fda18c] 3947 3598                 move.w    d7,13720(a4)
[00fda190] fc31                      dc.w      $FC31 ; movem.l (a7)+,d6-d7/a4-a5
#endif

	xdef xfda192
xfda192: ds.b 0
#if 0
[00fda192] 4e56 fff8                 link      a6,#$FFF8
[00fda196] 48e7 0f0c                 movem.l   d4-d7/a4-a5,-(a7)
[00fda19a] 3e2e 0008                 move.w    8(a6),d7
[00fda19e] 49ee fff8                 lea.l     -8(a6),a4
[00fda1a2] 2079 0000 a788            movea.l   _thedesk,a0
[00fda1a8] 2c28 5e2c                 move.l    24108(a0),d6
[00fda1ac] 4a47                      tst.w     d7
[00fda1ae] 670c                      beq.s     $00FDA1BC
[00fda1b0] 3e87                      move.w    d7,(a7)
[00fda1b2] f2ec                      dc.w      $F2EC
[00fda1b4] 2a40                      movea.l   d0,a5
[00fda1b6] 3a2d 000a                 move.w    10(a5),d5
[00fda1ba] 6002                      bra.s     $00FDA1BE
[00fda1bc] 7a01                      moveq.l   #1,d5
[00fda1be] 4297                      clr.l     (a7)
[00fda1c0] 3f3c 0100                 move.w    #$0100,-(a7)
[00fda1c4] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fda1c6] 548f                      addq.l    #2,a7
[00fda1c8] 2e8c                      move.l    a4,(a7)
[00fda1ca] 3f3c 000b                 move.w    #$000B,-(a7)
[00fda1ce] 3f07                      move.w    d7,-(a7)
[00fda1d0] f4bc                      dc.w      $F4BC
[00fda1d2] 588f                      addq.l    #4,a7
[00fda1d4] 603e                      bra.s     $00FDA214
[00fda1d6] 2e8c                      move.l    a4,(a7)
[00fda1d8] 486e 000a                 pea.l     10(a6)
[00fda1dc] f2fc                      dc.w      $F2FC ; rc_intersect
[00fda1de] 588f                      addq.l    #4,a7
[00fda1e0] 4a40                      tst.w     d0
[00fda1e2] 6724                      beq.s     $00FDA208
[00fda1e4] 2e8c                      move.l    a4,(a7)
[00fda1e6] 2f3c 0000 702c            move.l    #$0000702C,-(a7)
[00fda1ec] f2fc                      dc.w      $F2FC ; rc_intersect
[00fda1ee] 588f                      addq.l    #4,a7
[00fda1f0] 4a40                      tst.w     d0
[00fda1f2] 6714                      beq.s     $00FDA208
[00fda1f4] 2f2c 0004                 move.l    4(a4),-(a7)
[00fda1f8] 2f14                      move.l    (a4),-(a7)
[00fda1fa] 3f3c 0008                 move.w    #$0008,-(a7)
[00fda1fe] 3f05                      move.w    d5,-(a7)
[00fda200] 2f06                      move.l    d6,-(a7)
[00fda202] f3a8                      dc.w      $F3A8 ; objc_draw
[00fda204] defc 0010                 adda.w    #$0010,a7
[00fda208] 2e8c                      move.l    a4,(a7)
[00fda20a] 3f3c 000c                 move.w    #12,-(a7)
[00fda20e] 3f07                      move.w    d7,-(a7)
[00fda210] f4bc                      dc.w      $F4BC
[00fda212] 588f                      addq.l    #4,a7
[00fda214] 4a6c 0004                 tst.w     4(a4)
[00fda218] 6706                      beq.s     $00FDA220
[00fda21a] 4a6c 0006                 tst.w     6(a4)
[00fda21e] 66b6                      bne.s     $00FDA1D6
[00fda220] 4297                      clr.l     (a7)
[00fda222] 3f3c 0101                 move.w    #$0101,-(a7)
[00fda226] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fda228] 548f                      addq.l    #2,a7
[00fda22a] fc39                      dc.w      $FC39 ; movem.l (a7)+,d5-d7/a4-a5
#endif

	xdef xfda22c
xfda22c: ds.b 0
#if 0
[00fda22c] 4e56 0000                 link      a6,#0
[00fda230] 48e7 0300                 movem.l   d6-d7,-(a7)
[00fda234] 3e2e 000c                 move.w    12(a6),d7
[00fda238] 206e 000e                 movea.l   14(a6),a0
[00fda23c] 3207                      move.w    d7,d1
[00fda23e] c3fc 0018                 muls.w    #24,d1
[00fda242] d2ae 0008                 add.l     8(a6),d1
[00fda246] 2241                      movea.l   d1,a1
[00fda248] 30a9 0010                 move.w    16(a1),(a0)
[00fda24c] 206e 0012                 movea.l   18(a6),a0
[00fda250] 3207                      move.w    d7,d1
[00fda252] c3fc 0018                 muls.w    #24,d1
[00fda256] d2ae 0008                 add.l     8(a6),d1
[00fda25a] 2241                      movea.l   d1,a1
[00fda25c] 30a9 0012                 move.w    18(a1),(a0)
[00fda260] 206e 0016                 movea.l   22(a6),a0
[00fda264] 3207                      move.w    d7,d1
[00fda266] c3fc 0018                 muls.w    #24,d1
[00fda26a] d2ae 0008                 add.l     8(a6),d1
[00fda26e] 2241                      movea.l   d1,a1
[00fda270] 30a9 0014                 move.w    20(a1),(a0)
[00fda274] 206e 001a                 movea.l   26(a6),a0
[00fda278] 3207                      move.w    d7,d1
[00fda27a] c3fc 0018                 muls.w    #24,d1
[00fda27e] d2ae 0008                 add.l     8(a6),d1
[00fda282] 2241                      movea.l   d1,a1
[00fda284] 30a9 0016                 move.w    22(a1),(a0)
[00fda288] f021                      dc.w      $F021 ; movem.l (a7)+,d7
#endif

	xdef xfda28a
xfda28a: ds.b 0
#if 0
[00fda28a] 4e56 fffc                 link      a6,#-4
[00fda28e] 206e 0008                 movea.l   8(a6),a0
[00fda292] 322e 000c                 move.w    12(a6),d1
[00fda296] c3fc 0018                 muls.w    #24,d1
[00fda29a] 2030 180c                 move.l    12(a0,d1.l),d0
[00fda29e] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfda2a0
xfda2a0: ds.b 0
#if 0
[00fda2a0] 4e56 fff8                 link      a6,#$FFF8
[00fda2a4] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fda2a8] 2a6e 0008                 movea.l   8(a6),a5
[00fda2ac] 286e 000c                 movea.l   12(a6),a4
[00fda2b0] 486e fff8                 pea.l     -8(a6)
[00fda2b4] 3f3c 0004                 move.w    #$0004,-(a7)
[00fda2b8] 4267                      clr.w     -(a7)
[00fda2ba] f4bc                      dc.w      $F4BC
[00fda2bc] 508f                      addq.l    #8,a7
[00fda2be] 3d55 fff8                 move.w    (a5),-8(a6)
[00fda2c2] 302e fff8                 move.w    -8(a6),d0
[00fda2c6] c07c 000f                 and.w     #$000F,d0
[00fda2ca] 3a80                      move.w    d0,(a5)
[00fda2cc] 0c55 0008                 cmpi.w    #$0008,(a5)
[00fda2d0] 6c0c                      bge.s     $00FDA2DE
[00fda2d2] 302e fff8                 move.w    -8(a6),d0
[00fda2d6] c07c fff0                 and.w     #$FFF0,d0
[00fda2da] 3a80                      move.w    d0,(a5)
[00fda2dc] 600e                      bra.s     $00FDA2EC
[00fda2de] 302e fff8                 move.w    -8(a6),d0
[00fda2e2] c07c fff0                 and.w     #$FFF0,d0
[00fda2e6] d07c 0010                 add.w     #$0010,d0
[00fda2ea] 3a80                      move.w    d0,(a5)
[00fda2ec] 3eae fffa                 move.w    -6(a6),(a7)
[00fda2f0] 3f14                      move.w    (a4),-(a7)
[00fda2f2] f45c                      dc.w      $F45C ; max
[00fda2f4] 548f                      addq.l    #2,a7
[00fda2f6] 3880                      move.w    d0,(a4)
[00fda2f8] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfda2fa
xfda2fa: ds.b 0
#if 0
[00fda2fa] 4e56 fff0                 link      a6,#$FFF0
[00fda2fe] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fda302] 3e2e 0008                 move.w    8(a6),d7
[00fda306] 3c2e 000a                 move.w    10(a6),d6
[00fda30a] 3a2e 000c                 move.w    12(a6),d5
[00fda30e] 47ee fff0                 lea.l     -16(a6),a3
[00fda312] 2879 0000 a788            movea.l   _thedesk,a4
[00fda318] 486e 0010                 pea.l     16(a6)
[00fda31c] 486e 000e                 pea.l     14(a6)
[00fda320] f568                      dc.w      $F568
[00fda322] 508f                      addq.l    #8,a7
[00fda324] 486e fff8                 pea.l     -8(a6)
[00fda328] 486e fffa                 pea.l     -6(a6)
[00fda32c] 486e fffc                 pea.l     -4(a6)
[00fda330] 486e fffe                 pea.l     -2(a6)
[00fda334] 3f05                      move.w    d5,-(a7)
[00fda336] 486c 5e88                 pea.l     24200(a4)
[00fda33a] f56c                      dc.w      $F56C
[00fda33c] defc 0016                 adda.w    #$0016,a7
[00fda340] 486b 0006                 pea.l     6(a3)
[00fda344] 486b 0004                 pea.l     4(a3)
[00fda348] 486b 0002                 pea.l     2(a3)
[00fda34c] 2f0b                      move.l    a3,-(a7)
[00fda34e] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fda352] 486c 5e88                 pea.l     24200(a4)
[00fda356] f56c                      dc.w      $F56C
[00fda358] defc 0016                 adda.w    #$0016,a7
[00fda35c] 3013                      move.w    (a3),d0
[00fda35e] d16e fffe                 add.w     d0,-2(a6)
[00fda362] 302b 0002                 move.w    2(a3),d0
[00fda366] d16e fffc                 add.w     d0,-4(a6)
[00fda36a] 204c                      movea.l   a4,a0
[00fda36c] 3205                      move.w    d5,d1
[00fda36e] c3fc 0018                 muls.w    #24,d1
[00fda372] d1c1                      adda.l    d1,a0
[00fda374] 0c68 0018 5e8e            cmpi.w    #24,24206(a0)
[00fda37a] 6606                      bne.s     $00FDA382
[00fda37c] 3d6e 0012 fffa            move.w    18(a6),-6(a6)
[00fda382] 2f2e 0012                 move.l    18(a6),-(a7)
[00fda386] 2f2e 000e                 move.l    14(a6),-(a7)
[00fda38a] 3f2e fff8                 move.w    -8(a6),-(a7)
[00fda38e] 3f2e fffa                 move.w    -6(a6),-(a7)
[00fda392] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fda396] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fda39a] f570                      dc.w      $F570 ; graf_growbox
[00fda39c] defc 0010                 adda.w    #$0010,a7
[00fda3a0] 3ebc 0001                 move.w    #1,(a7)
[00fda3a4] 3f3c 0001                 move.w    #1,-(a7)
[00fda3a8] 4267                      clr.w     -(a7)
[00fda3aa] 3f3c 0001                 move.w    #1,-(a7)
[00fda3ae] 2f0b                      move.l    a3,-(a7)
[00fda3b0] 3f05                      move.w    d5,-(a7)
[00fda3b2] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fda3b6] 2f2c 5e2c                 move.l    24108(a4),-(a7)
[00fda3ba] 3f2c 3598                 move.w    13720(a4),-(a7)
[00fda3be] f2f4                      dc.w      $F2F4
[00fda3c0] defc 0014                 adda.w    #$0014,a7
[00fda3c4] 4a47                      tst.w     d7
[00fda3c6] 6710                      beq.s     $00FDA3D8
[00fda3c8] 2f2e 0012                 move.l    18(a6),-(a7)
[00fda3cc] 2f2e 000e                 move.l    14(a6),-(a7)
[00fda3d0] 3f06                      move.w    d6,-(a7)
[00fda3d2] f574                      dc.w      $F574 ; wind_open
[00fda3d4] defc 000a                 adda.w    #10,a7
[00fda3d8] 3946 359a                 move.w    d6,13722(a4)
[00fda3dc] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef xfda3de
xfda3de: ds.b 0
#if 0
[00fda3de] 4e56 fff8                 link      a6,#$FFF8
[00fda3e2] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fda3e6] 3e2e 0008                 move.w    8(a6),d7
[00fda3ea] 3c2e 000a                 move.w    10(a6),d6
[00fda3ee] 2a79 0000 a788            movea.l   _thedesk,a5
[00fda3f4] 486e fff8                 pea.l     -8(a6)
[00fda3f8] 3f3c 0004                 move.w    #$0004,-(a7)
[00fda3fc] 3f06                      move.w    d6,-(a7)
[00fda3fe] f4bc                      dc.w      $F4BC
[00fda400] 508f                      addq.l    #8,a7
[00fda402] 4a47                      tst.w     d7
[00fda404] 6704                      beq.s     $00FDA40A
[00fda406] 3e86                      move.w    d6,(a7)
[00fda408] f578                      dc.w      $F578
[00fda40a] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fda40e] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fda412] 2f2d 35fc                 move.l    13820(a5),-(a7)
[00fda416] 2f2e 000c                 move.l    12(a6),-(a7)
[00fda41a] f57c                      dc.w      $F57C
[00fda41c] defc 0010                 adda.w    #$0010,a7
[00fda420] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfda422
xfda422: ds.b 0
#if 0
[00fda422] 4e56 ffe8                 link      a6,#$FFE8
[00fda426] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fda42a] 3e2e 0008                 move.w    8(a6),d7
[00fda42e] 4bee fff8                 lea.l     -8(a6),a5
[00fda432] 49ee fff0                 lea.l     -16(a6),a4
[00fda436] 47ee ffe8                 lea.l     -24(a6),a3
[00fda43a] 2e8d                      move.l    a5,(a7)
[00fda43c] 3f3c 0005                 move.w    #$0005,-(a7)
[00fda440] 3f07                      move.w    d7,-(a7)
[00fda442] f4bc                      dc.w      $F4BC
[00fda444] 588f                      addq.l    #4,a7
[00fda446] 2e8c                      move.l    a4,(a7)
[00fda448] 3f3c 0006                 move.w    #$0006,-(a7)
[00fda44c] 3f07                      move.w    d7,-(a7)
[00fda44e] f4bc                      dc.w      $F4BC
[00fda450] 588f                      addq.l    #4,a7
[00fda452] 2e8b                      move.l    a3,(a7)
[00fda454] 3f3c 0007                 move.w    #$0007,-(a7)
[00fda458] 3f07                      move.w    d7,-(a7)
[00fda45a] f4bc                      dc.w      $F4BC
[00fda45c] 588f                      addq.l    #4,a7
[00fda45e] 2e8b                      move.l    a3,(a7)
[00fda460] 2f0d                      move.l    a5,-(a7)
[00fda462] f580                      dc.w      $F580 ; rc_equal
[00fda464] 588f                      addq.l    #4,a7
[00fda466] 4a40                      tst.w     d0
[00fda468] 6726                      beq.s     $00FDA490
[00fda46a] 2f2c 0004                 move.l    4(a4),-(a7)
[00fda46e] 2f14                      move.l    (a4),-(a7)
[00fda470] 3f3c 0005                 move.w    #$0005,-(a7)
[00fda474] 3f07                      move.w    d7,-(a7)
[00fda476] f4b8                      dc.w      $F4B8 ; wind_set
[00fda478] defc 000c                 adda.w    #12,a7
[00fda47c] 2f2b 0004                 move.l    4(a3),-(a7)
[00fda480] 2f13                      move.l    (a3),-(a7)
[00fda482] 2f2c 0004                 move.l    4(a4),-(a7)
[00fda486] 2f14                      move.l    (a4),-(a7)
[00fda488] f57c                      dc.w      $F57C
[00fda48a] defc 0010                 adda.w    #$0010,a7
[00fda48e] 6024                      bra.s     $00FDA4B4
[00fda490] 2f2b 0004                 move.l    4(a3),-(a7)
[00fda494] 2f13                      move.l    (a3),-(a7)
[00fda496] 2f2d 0004                 move.l    4(a5),-(a7)
[00fda49a] 2f15                      move.l    (a5),-(a7)
[00fda49c] f570                      dc.w      $F570 ; graf_growbox
[00fda49e] defc 0010                 adda.w    #$0010,a7
[00fda4a2] 2f2b 0004                 move.l    4(a3),-(a7)
[00fda4a6] 2f13                      move.l    (a3),-(a7)
[00fda4a8] 3f3c 0005                 move.w    #$0005,-(a7)
[00fda4ac] 3f07                      move.w    d7,-(a7)
[00fda4ae] f4b8                      dc.w      $F4B8 ; wind_set
[00fda4b0] defc 000c                 adda.w    #12,a7
[00fda4b4] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfda4b6
xfda4b6: ds.b 0
#if 0
[00fda4b6] 4e56 fffc                 link      a6,#-4
[00fda4ba] 48e7 0f0c                 movem.l   d4-d7/a4-a5,-(a7)
[00fda4be] 2a6e 0008                 movea.l   8(a6),a5
[00fda4c2] 3e2e 000c                 move.w    12(a6),d7
[00fda4c6] 3c2e 000e                 move.w    14(a6),d6
[00fda4ca] 3a2e 0010                 move.w    16(a6),d5
[00fda4ce] 286e 001e                 movea.l   30(a6),a4
[00fda4d2] 3ebc 0001                 move.w    #1,(a7)
[00fda4d6] f094                      dc.w      $F094 ; desk_wait
[00fda4d8] 3ebc 0010                 move.w    #$0010,(a7)
[00fda4dc] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda4e0] 2f2e 0016                 move.l    22(a6),-(a7)
[00fda4e4] 2f2e 0012                 move.l    18(a6),-(a7)
[00fda4e8] 3f05                      move.w    d5,-(a7)
[00fda4ea] f4e8                      dc.w      $F4E8
[00fda4ec] defc 000e                 adda.w    #$000E,a7
[00fda4f0] 2d40 fffc                 move.l    d0,-4(a6)
[00fda4f4] 4aae fffc                 tst.l     -4(a6)
[00fda4f8] 663e                      bne.s     $00FDA538
[00fda4fa] 4297                      clr.l     (a7)
[00fda4fc] 2f3c 0001 0017            move.l    #$00010017,-(a7)
[00fda502] f0dc                      dc.w      $F0DC ; fill_string
[00fda504] 588f                      addq.l    #4,a7
[00fda506] f584                      dc.w      $F584
[00fda508] 2a40                      movea.l   d0,a5
[00fda50a] 200d                      move.l    a5,d0
[00fda50c] 6706                      beq.s     $00FDA514
[00fda50e] 302d 0006                 move.w    6(a5),d0
[00fda512] 6002                      bra.s     $00FDA516
[00fda514] 4240                      clr.w     d0
[00fda516] 2279 0000 a788            movea.l   _thedesk,a1
[00fda51c] 3340 359a                 move.w    d0,13722(a1)
[00fda520] 3ebc 0001                 move.w    #1,(a7)
[00fda524] 2079 0000 a788            movea.l   _thedesk,a0
[00fda52a] 3f28 359a                 move.w    13722(a0),-(a7)
[00fda52e] f4b0                      dc.w      $F4B0
[00fda530] 548f                      addq.l    #2,a7
[00fda532] 6000 0096                 bra       $00FDA5CA
[00fda536] 6006                      bra.s     $00FDA53E
[00fda538] 2b6e fffc 0018            move.l    -4(a6),24(a5)
[00fda53e] 2ead 0018                 move.l    24(a5),(a7)
[00fda542] f4ac                      dc.w      $F4AC
[00fda544] ba7c 0063                 cmp.w     #$0063,d5
[00fda548] 6614                      bne.s     $00FDA55E
[00fda54a] 486d 001c                 pea.l     28(a5)
[00fda54e] 2079 0000 a788            movea.l   _thedesk,a0
[00fda554] 2f28 35a8                 move.l    13736(a0),-(a7)
[00fda558] f36c                      dc.w      $F36C ; xstrpcpy
[00fda55a] 508f                      addq.l    #8,a7
[00fda55c] 6004                      bra.s     $00FDA562
[00fda55e] 2e8d                      move.l    a5,(a7)
[00fda560] f588                      dc.w      $F588
[00fda562] 2e8d                      move.l    a5,(a7)
[00fda564] f4b4                      dc.w      $F4B4
[00fda566] 4297                      clr.l     (a7)
[00fda568] 486d 001c                 pea.l     28(a5)
[00fda56c] 3f3c 0002                 move.w    #$0002,-(a7)
[00fda570] 3f2d 0006                 move.w    6(a5),-(a7)
[00fda574] f4b8                      dc.w      $F4B8 ; wind_set
[00fda576] 508f                      addq.l    #8,a7
[00fda578] 4297                      clr.l     (a7)
[00fda57a] 486d 0095                 pea.l     149(a5)
[00fda57e] 3f3c 0003                 move.w    #$0003,-(a7)
[00fda582] 3f2d 0006                 move.w    6(a5),-(a7)
[00fda586] f4b8                      dc.w      $F4B8 ; wind_set
[00fda588] 508f                      addq.l    #8,a7
[00fda58a] 4a46                      tst.w     d6
[00fda58c] 6f1c                      ble.s     $00FDA5AA
[00fda58e] 2f2c 0004                 move.l    4(a4),-(a7)
[00fda592] 2f14                      move.l    (a4),-(a7)
[00fda594] 3f06                      move.w    d6,-(a7)
[00fda596] 3f2d 0006                 move.w    6(a5),-(a7)
[00fda59a] 3f07                      move.w    d7,-(a7)
[00fda59c] f560                      dc.w      $F560
[00fda59e] defc 000e                 adda.w    #$000E,a7
[00fda5a2] 4a47                      tst.w     d7
[00fda5a4] 6704                      beq.s     $00FDA5AA
[00fda5a6] 2e8d                      move.l    a5,(a7)
[00fda5a8] f58c                      dc.w      $F58C
[00fda5aa] 3ebc 0001                 move.w    #1,(a7)
[00fda5ae] 3f2d 0006                 move.w    6(a5),-(a7)
[00fda5b2] f4b0                      dc.w      $F4B0
[00fda5b4] 548f                      addq.l    #2,a7
[00fda5b6] 4a47                      tst.w     d7
[00fda5b8] 6610                      bne.s     $00FDA5CA
[00fda5ba] 2f2c 0004                 move.l    4(a4),-(a7)
[00fda5be] 2f14                      move.l    (a4),-(a7)
[00fda5c0] 3f2d 0006                 move.w    6(a5),-(a7)
[00fda5c4] f2c0                      dc.w      $F2C0
[00fda5c6] defc 000a                 adda.w    #10,a7
[00fda5ca] 4257                      clr.w     (a7)
[00fda5cc] f094                      dc.w      $F094 ; desk_wait
[00fda5ce] 7001                      moveq.l   #1,d0
[00fda5d0] fc39                      dc.w      $FC39 ; movem.l (a7)+,d5-d7/a4-a5
#endif

	xdef xfda5d2
xfda5d2: ds.b 0
#if 0
[00fda5d2] 4e56 ffc8                 link      a6,#$FFC8
[00fda5d6] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fda5da] 2a6e 000c                 movea.l   12(a6),a5
[00fda5de] 2879 0000 a788            movea.l   _thedesk,a4
[00fda5e4] 486e ffe8                 pea.l     -24(a6)
[00fda5e8] 486e ffea                 pea.l     -22(a6)
[00fda5ec] 486e ffec                 pea.l     -20(a6)
[00fda5f0] 486e ffee                 pea.l     -18(a6)
[00fda5f4] 3f2e 0012                 move.w    18(a6),-(a7)
[00fda5f8] 486c 5e88                 pea.l     24200(a4)
[00fda5fc] f56c                      dc.w      $F56C
[00fda5fe] defc 0016                 adda.w    #$0016,a7
[00fda602] 486e fff0                 pea.l     -16(a6)
[00fda606] 486e fff2                 pea.l     -14(a6)
[00fda60a] 486e fff4                 pea.l     -12(a6)
[00fda60e] 486e fff6                 pea.l     -10(a6)
[00fda612] 3f2c 3596                 move.w    13718(a4),-(a7)
[00fda616] 486c 5e88                 pea.l     24200(a4)
[00fda61a] f56c                      dc.w      $F56C
[00fda61c] defc 0016                 adda.w    #$0016,a7
[00fda620] 302e fff6                 move.w    -10(a6),d0
[00fda624] d16e ffee                 add.w     d0,-18(a6)
[00fda628] 302e fff4                 move.w    -12(a6),d0
[00fda62c] d16e ffec                 add.w     d0,-20(a6)
[00fda630] 302d 0004                 move.w    4(a5),d0
[00fda634] c07c 0002                 and.w     #$0002,d0
[00fda638] 3d40 fffe                 move.w    d0,-2(a6)
[00fda63c] 3d7c 0001 fffc            move.w    #1,-4(a6)
[00fda642] 302d 0004                 move.w    4(a5),d0
[00fda646] c07c 0008                 and.w     #$0008,d0
[00fda64a] 3d40 fffa                 move.w    d0,-6(a6)
[00fda64e] 302d 0004                 move.w    4(a5),d0
[00fda652] c07c 0010                 and.w     #$0010,d0
[00fda656] 3d40 ffc8                 move.w    d0,-56(a6)
[00fda65a] 206d 000a                 movea.l   10(a5),a0
[00fda65e] 0c10 002a                 cmpi.b    #$2A,(a0)
[00fda662] 6716                      beq.s     $00FDA67A
[00fda664] 206d 000a                 movea.l   10(a5),a0
[00fda668] 0c10 003f                 cmpi.b    #$3F,(a0)
[00fda66c] 670c                      beq.s     $00FDA67A
[00fda66e] 206d 000a                 movea.l   10(a5),a0
[00fda672] 4a10                      tst.b     (a0)
[00fda674] 6704                      beq.s     $00FDA67A
[00fda676] 4240                      clr.w     d0
[00fda678] 6002                      bra.s     $00FDA67C
[00fda67a] 7001                      moveq.l   #1,d0
[00fda67c] 3d40 fff8                 move.w    d0,-8(a6)
[00fda680] 4280                      clr.l     d0
[00fda682] 2d40 ffe4                 move.l    d0,-28(a6)
[00fda686] 2640                      movea.l   d0,a3
[00fda688] 422c 344a                 clr.b     13386(a4)
[00fda68c] 422c 34cf                 clr.b     13519(a4)
[00fda690] 7e01                      moveq.l   #1,d7
[00fda692] 4a6e fff8                 tst.w     -8(a6)
[00fda696] 6632                      bne.s     $00FDA6CA
[00fda698] 4a6e 0010                 tst.w     16(a6)
[00fda69c] 662c                      bne.s     $00FDA6CA
[00fda69e] 266d 000a                 movea.l   10(a5),a3
[00fda6a2] 41ec 3016                 lea.l     12310(a4),a0
[00fda6a6] 2d48 ffe4                 move.l    a0,-28(a6)
[00fda6aa] 486c 3016                 pea.l     12310(a4)
[00fda6ae] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda6b2] f36c                      dc.w      $F36C ; xstrpcpy
[00fda6b4] 508f                      addq.l    #8,a7
[00fda6b6] 486c 344a                 pea.l     13386(a4)
[00fda6ba] 2f0b                      move.l    a3,-(a7)
[00fda6bc] f36c                      dc.w      $F36C ; xstrpcpy
[00fda6be] 508f                      addq.l    #8,a7
[00fda6c0] 2eae 0008                 move.l    8(a6),(a7)
[00fda6c4] f58c                      dc.w      $F58C
[00fda6c6] 6000 014c                 bra       $00FDA814
[00fda6ca] 4a6e 0010                 tst.w     16(a6)
[00fda6ce] 6700 00b0                 beq       $00FDA780
[00fda6d2] 4a6e fffa                 tst.w     -6(a6)
[00fda6d6] 675c                      beq.s     $00FDA734
[00fda6d8] 41ec 34cf                 lea.l     13519(a4),a0
[00fda6dc] 2d48 ffe4                 move.l    a0,-28(a6)
[00fda6e0] 2c2c 3566                 move.l    13670(a4),d6
[00fda6e4] 3ebc 0001                 move.w    #1,(a7)
[00fda6e8] 3f3c 0001                 move.w    #1,-(a7)
[00fda6ec] 2f06                      move.l    d6,-(a7)
[00fda6ee] 486e ffca                 pea.l     -54(a6)
[00fda6f2] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda6f6] f3c4                      dc.w      $F3C4
[00fda6f8] defc 000e                 adda.w    #$000E,a7
[00fda6fc] 2ebc 00fe b1ac            move.l    #$00FEB1AC,(a7)
[00fda702] 3f3c 0003                 move.w    #$0003,-(a7)
[00fda706] 2f06                      move.l    d6,-(a7)
[00fda708] f3c8                      dc.w      $F3C8 ; inf_sset
[00fda70a] 5c8f                      addq.l    #6,a7
[00fda70c] 3ebc 0003                 move.w    #$0003,(a7)
[00fda710] 2f06                      move.l    d6,-(a7)
[00fda712] f4c4                      dc.w      $F4C4
[00fda714] 588f                      addq.l    #4,a7
[00fda716] b07c 0004                 cmp.w     #$0004,d0
[00fda71a] 6704                      beq.s     $00FDA720
[00fda71c] 4240                      clr.w     d0
[00fda71e] 6002                      bra.s     $00FDA722
[00fda720] 7001                      moveq.l   #1,d0
[00fda722] 3e00                      move.w    d0,d7
[00fda724] 670e                      beq.s     $00FDA734
[00fda726] 2eae ffe4                 move.l    -28(a6),(a7)
[00fda72a] 3f3c 0003                 move.w    #$0003,-(a7)
[00fda72e] 2f06                      move.l    d6,-(a7)
[00fda730] f42c                      dc.w      $F42C ; fs_sget
[00fda732] 5c8f                      addq.l    #6,a7
[00fda734] 4a47                      tst.w     d7
[00fda736] 6744                      beq.s     $00FDA77C
[00fda738] 47ec 344a                 lea.l     13386(a4),a3
[00fda73c] 302e 0014                 move.w    20(a6),d0
[00fda740] 4880                      ext.w     d0
[00fda742] 1680                      move.b    d0,(a3)
[00fda744] 422b 0001                 clr.b     1(a3)
[00fda748] 2e8b                      move.l    a3,(a7)
[00fda74a] 2f3c 00fe b1ae            move.l    #$00FEB1AE,-(a7)
[00fda750] f404                      dc.w      $F404 ; xstrpcat
[00fda752] 588f                      addq.l    #4,a7
[00fda754] 206e 0016                 movea.l   22(a6),a0
[00fda758] 4a10                      tst.b     (a0)
[00fda75a] 6716                      beq.s     $00FDA772
[00fda75c] 2e8b                      move.l    a3,(a7)
[00fda75e] 2f2e 0016                 move.l    22(a6),-(a7)
[00fda762] f404                      dc.w      $F404 ; xstrpcat
[00fda764] 588f                      addq.l    #4,a7
[00fda766] 2e8b                      move.l    a3,(a7)
[00fda768] 2f3c 00fe b1b1            move.l    #$00FEB1B1,-(a7)
[00fda76e] f404                      dc.w      $F404 ; xstrpcat
[00fda770] 588f                      addq.l    #4,a7
[00fda772] 2e8b                      move.l    a3,(a7)
[00fda774] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda778] f404                      dc.w      $F404 ; xstrpcat
[00fda77a] 588f                      addq.l    #4,a7
[00fda77c] 6000 0096                 bra       $00FDA814
[00fda780] 4297                      clr.l     (a7)
[00fda782] 2f3c 0001 000c            move.l    #$0001000C,-(a7)
[00fda788] f0dc                      dc.w      $F0DC ; fill_string
[00fda78a] 588f                      addq.l    #4,a7
[00fda78c] 3e00                      move.w    d0,d7
[00fda78e] be7c 0003                 cmp.w     #$0003,d7
[00fda792] 6606                      bne.s     $00FDA79A
[00fda794] 4240                      clr.w     d0
[00fda796] 6000 00c4                 bra       $00FDA85C
[00fda79a] be7c 0001                 cmp.w     #1,d7
[00fda79e] 6632                      bne.s     $00FDA7D2
[00fda7a0] 4297                      clr.l     (a7)
[00fda7a2] 3f3c 0100                 move.w    #$0100,-(a7)
[00fda7a6] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fda7a8] 548f                      addq.l    #2,a7
[00fda7aa] 3ebc 0003                 move.w    #$0003,(a7)
[00fda7ae] f590                      dc.w      $F590 ; gsx_escapes
[00fda7b0] 4257                      clr.w     (a7)
[00fda7b2] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda7b6] f594                      dc.w      $F594 ; showfile
[00fda7b8] 588f                      addq.l    #4,a7
[00fda7ba] 3ebc 0002                 move.w    #$0002,(a7)
[00fda7be] f590                      dc.w      $F590 ; gsx_escapes
[00fda7c0] 4297                      clr.l     (a7)
[00fda7c2] 3f3c 0101                 move.w    #$0101,-(a7)
[00fda7c6] f2c4                      dc.w      $F2C4 ; graf_mouse
[00fda7c8] 548f                      addq.l    #2,a7
[00fda7ca] 7001                      moveq.l   #1,d0
[00fda7cc] 6000 008e                 bra       $00FDA85C
[00fda7d0] 6042                      bra.s     $00FDA814
[00fda7d2] 2c2c 358a                 move.l    13706(a4),d6
[00fda7d6] 486c 5e44                 pea.l     24132(a4)
[00fda7da] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda7de] f3b4                      dc.w      $F3B4 ; fmt_str
[00fda7e0] 508f                      addq.l    #8,a7
[00fda7e2] 486c 5e44                 pea.l     24132(a4)
[00fda7e6] 3f3c 0001                 move.w    #1,-(a7)
[00fda7ea] 2f06                      move.l    d6,-(a7)
[00fda7ec] f3c8                      dc.w      $F3C8 ; inf_sset
[00fda7ee] defc 000a                 adda.w    #10,a7
[00fda7f2] 3ebc 0001                 move.w    #1,(a7)
[00fda7f6] f094                      dc.w      $F094 ; desk_wait
[00fda7f8] 2e86                      move.l    d6,(a7)
[00fda7fa] f3cc                      dc.w      $F3CC
[00fda7fc] 3ebc 0001                 move.w    #1,(a7)
[00fda800] 2f2e 001a                 move.l    26(a6),-(a7)
[00fda804] f594                      dc.w      $F594 ; showfile
[00fda806] 588f                      addq.l    #4,a7
[00fda808] 2e86                      move.l    d6,(a7)
[00fda80a] f3ec                      dc.w      $F3EC ; do_finish
[00fda80c] 4257                      clr.w     (a7)
[00fda80e] f094                      dc.w      $F094 ; desk_wait
[00fda810] 4240                      clr.w     d0
[00fda812] 6048                      bra.s     $00FDA85C
[00fda814] 4a47                      tst.w     d7
[00fda816] 6742                      beq.s     $00FDA85A
[00fda818] 200c                      move.l    a4,d0
[00fda81a] d0bc 0000 34cf            add.l     #$000034CF,d0
[00fda820] b0ae ffe4                 cmp.l     -28(a6),d0
[00fda824] 6712                      beq.s     $00FDA838
[00fda826] 4aae ffe4                 tst.l     -28(a6)
[00fda82a] 670c                      beq.s     $00FDA838
[00fda82c] 486c 34cf                 pea.l     13519(a4)
[00fda830] 2f2e ffe4                 move.l    -28(a6),-(a7)
[00fda834] f36c                      dc.w      $F36C ; xstrpcpy
[00fda836] 508f                      addq.l    #8,a7
[00fda838] 4a6e ffc8                 tst.w     -56(a6)
[00fda83c] 6706                      beq.s     $00FDA844
[00fda83e] 197c 00ff 34ce            move.b    #$FF,13518(a4)
[00fda844] 3eae 0012                 move.w    18(a6),(a7)
[00fda848] 3f2c 3598                 move.w    13720(a4),-(a7)
[00fda84c] 3f2e fffc                 move.w    -4(a6),-(a7)
[00fda850] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fda854] f598                      dc.w      $F598
[00fda856] 5c8f                      addq.l    #6,a7
[00fda858] 6002                      bra.s     $00FDA85C
[00fda85a] 4240                      clr.w     d0
[00fda85c] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfda85e
xfda85e: ds.b 0
#if 0
[00fda85e] 4e56 0000                 link      a6,#0
[00fda862] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fda866] 3e2e 0008                 move.w    8(a6),d7
[00fda86a] 2679 0000 a788            movea.l   _thedesk,a3
[00fda870] 3e87                      move.w    d7,(a7)
[00fda872] 486b 5e88                 pea.l     24200(a3)
[00fda876] f4d4                      dc.w      $F4D4
[00fda878] 588f                      addq.l    #4,a7
[00fda87a] 2840                      movea.l   d0,a4
[00fda87c] 3ebc 0001                 move.w    #1,(a7)
[00fda880] f094                      dc.w      $F094 ; desk_wait
[00fda882] 3c2c 000c                 move.w    12(a4),d6
[00fda886] cc7c 00ff                 and.w     #$00FF,d6
[00fda88a] 3e87                      move.w    d7,(a7)
[00fda88c] f59c                      dc.w      $F59C
[00fda88e] 2a40                      movea.l   d0,a5
[00fda890] 200d                      move.l    a5,d0
[00fda892] 6758                      beq.s     $00FDA8EC
[00fda894] 3e86                      move.w    d6,(a7)
[00fda896] f4e4                      dc.w      $F4E4
[00fda898] 4a40                      tst.w     d0
[00fda89a] 674a                      beq.s     $00FDA8E6
[00fda89c] bc7c 0063                 cmp.w     #$0063,d6
[00fda8a0] 670c                      beq.s     $00FDA8AE
[00fda8a2] 2ebc 00fe b1b3            move.l    #$00FEB1B3,(a7)
[00fda8a8] 3f06                      move.w    d6,-(a7)
[00fda8aa] f5a0                      dc.w      $F5A0
[00fda8ac] 548f                      addq.l    #2,a7
[00fda8ae] 200b                      move.l    a3,d0
[00fda8b0] 322d 000a                 move.w    10(a5),d1
[00fda8b4] c3fc 0018                 muls.w    #24,d1
[00fda8b8] d081                      add.l     d1,d0
[00fda8ba] 2e80                      move.l    d0,(a7)
[00fda8bc] 0697 0000 5e98            addi.l    #$00005E98,(a7)
[00fda8c2] 2f3c 00fe b1b7            move.l    #$00FEB1B7,-(a7)
[00fda8c8] 2f3c 00fe b1b5            move.l    #$00FEB1B5,-(a7)
[00fda8ce] 2f3c 00fe b1b4            move.l    #$00FEB1B4,-(a7)
[00fda8d4] 3f06                      move.w    d6,-(a7)
[00fda8d6] 3f07                      move.w    d7,-(a7)
[00fda8d8] 3f3c 0001                 move.w    #1,-(a7)
[00fda8dc] 2f0d                      move.l    a5,-(a7)
[00fda8de] f5a4                      dc.w      $F5A4
[00fda8e0] defc 0016                 adda.w    #$0016,a7
[00fda8e4] 6004                      bra.s     $00FDA8EA
[00fda8e6] 2e8d                      move.l    a5,(a7)
[00fda8e8] f5a8                      dc.w      $F5A8
[00fda8ea] 600c                      bra.s     $00FDA8F8
[00fda8ec] 4297                      clr.l     (a7)
[00fda8ee] 2f3c 0001 000d            move.l    #$0001000D,-(a7)
[00fda8f4] f0dc                      dc.w      $F0DC ; fill_string
[00fda8f6] 588f                      addq.l    #4,a7
[00fda8f8] 4257                      clr.w     (a7)
[00fda8fa] f094                      dc.w      $F094 ; desk_wait
[00fda8fc] 4240                      clr.w     d0
[00fda8fe] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfda900
xfda900: ds.b 0
#if 0
[00fda900] 4e56 fff6                 link      a6,#$FFF6
[00fda904] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fda908] 2a6e 0008                 movea.l   8(a6),a5
[00fda90c] 49ee fff6                 lea.l     -10(a6),a4
[00fda910] 2e8c                      move.l    a4,(a7)
[00fda912] 3f3c 0004                 move.w    #$0004,-(a7)
[00fda916] 3f2d 0006                 move.w    6(a5),-(a7)
[00fda91a] f4bc                      dc.w      $F4BC
[00fda91c] 588f                      addq.l    #4,a7
[00fda91e] 3ebc 0001                 move.w    #1,(a7)
[00fda922] f094                      dc.w      $F094 ; desk_wait
[00fda924] 3eae 000e                 move.w    14(a6),(a7)
[00fda928] f4e4                      dc.w      $F4E4
[00fda92a] 4a40                      tst.w     d0
[00fda92c] 674e                      beq.s     $00FDA97C
[00fda92e] 2eae 0010                 move.l    16(a6),(a7)
[00fda932] 3f2e 000e                 move.w    14(a6),-(a7)
[00fda936] f5a0                      dc.w      $F5A0
[00fda938] 548f                      addq.l    #2,a7
[00fda93a] 2ead 0018                 move.l    24(a5),(a7)
[00fda93e] f4f0                      dc.w      $F4F0
[00fda940] 4a79 0000 742a            tst.w     _DOS_ERR
[00fda946] 6718                      beq.s     $00FDA960
[00fda948] 2d7c 00fe b1b9 0010       move.l    #$00FEB1B9,16(a6)
[00fda950] 2d7c 00fe b1ba 0014       move.l    #$00FEB1BA,20(a6)
[00fda958] 2d7c 00fe b1bc 0018       move.l    #$00FEB1BC,24(a6)
[00fda960] 2e8c                      move.l    a4,(a7)
[00fda962] 2f2e 0018                 move.l    24(a6),-(a7)
[00fda966] 2f2e 0014                 move.l    20(a6),-(a7)
[00fda96a] 2f2e 0010                 move.l    16(a6),-(a7)
[00fda96e] 2f2e 000c                 move.l    12(a6),-(a7)
[00fda972] 4267                      clr.w     -(a7)
[00fda974] 2f0d                      move.l    a5,-(a7)
[00fda976] f5a4                      dc.w      $F5A4
[00fda978] defc 0016                 adda.w    #$0016,a7
[00fda97c] 4257                      clr.w     (a7)
[00fda97e] f094                      dc.w      $F094 ; desk_wait
[00fda980] 4240                      clr.w     d0
[00fda982] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfda984
xfda984: ds.b 0
#if 0
[00fda984] 4e56 ff6e                 link      a6,#$FF6E
[00fda988] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fda98c] 3e2e 0008                 move.w    8(a6),d7
[00fda990] 2679 0000 a788            movea.l   _thedesk,a3
[00fda996] 426e fffe                 clr.w     -2(a6)
[00fda99a] 486e fff6                 pea.l     -10(a6)
[00fda99e] 486e fffa                 pea.l     -6(a6)
[00fda9a2] 3f07                      move.w    d7,-(a7)
[00fda9a4] 3f2b 3598                 move.w    13720(a3),-(a7)
[00fda9a8] f2f8                      dc.w      $F2F8
[00fda9aa] defc 000c                 adda.w    #12,a7
[00fda9ae] 2a40                      movea.l   d0,a5
[00fda9b0] 4a6b 3598                 tst.w     13720(a3)
[00fda9b4] 6606                      bne.s     $00FDA9BC
[00fda9b6] 426e fff8                 clr.w     -8(a6)
[00fda9ba] 6046                      bra.s     $00FDAA02
[00fda9bc] 3eab 3598                 move.w    13720(a3),(a7)
[00fda9c0] f2ec                      dc.w      $F2EC
[00fda9c2] 2840                      movea.l   d0,a4
[00fda9c4] 2eab 35a8                 move.l    13736(a3),(a7)
[00fda9c8] 486c 001c                 pea.l     28(a4)
[00fda9cc] f39c                      dc.w      $F39C ; streq
[00fda9ce] 588f                      addq.l    #4,a7
[00fda9d0] 4a40                      tst.w     d0
[00fda9d2] 6704                      beq.s     $00FDA9D8
[00fda9d4] 7001                      moveq.l   #1,d0
[00fda9d6] 6002                      bra.s     $00FDA9DA
[00fda9d8] 4240                      clr.w     d0
[00fda9da] 33c0 0000 6de0            move.w    d0,$00006DE0
[00fda9e0] 4aae fffa                 tst.l     -6(a6)
[00fda9e4] 671c                      beq.s     $00FDAA02
[00fda9e6] 486e ff6e                 pea.l     -146(a6)
[00fda9ea] 486e ff72                 pea.l     -142(a6)
[00fda9ee] 486e ff7c                 pea.l     -132(a6)
[00fda9f2] 486e fff8                 pea.l     -8(a6)
[00fda9f6] 2f2c 0018                 move.l    24(a4),-(a7)
[00fda9fa] 5097                      addq.l    #8,(a7)
[00fda9fc] f5ac                      dc.w      $F5AC
[00fda9fe] defc 0014                 adda.w    #$0014,a7
[00fdaa02] 200d                      move.l    a5,d0
[00fdaa04] 6700 009c                 beq       $00FDAAA2
[00fdaa08] 302d 0006                 move.w    6(a5),d0
[00fdaa0c] 6000 0080                 bra       $00FDAA8E
[00fdaa10] 2eae fffa                 move.l    -6(a6),(a7)
[00fdaa14] 0697 0000 0012            addi.l    #$00000012,(a7)
[00fdaa1a] 486e ff7c                 pea.l     -132(a6)
[00fdaa1e] 3f2e fff8                 move.w    -8(a6),-(a7)
[00fdaa22] 3f07                      move.w    d7,-(a7)
[00fdaa24] 3f2e fff6                 move.w    -10(a6),-(a7)
[00fdaa28] 2f0d                      move.l    a5,-(a7)
[00fdaa2a] 2f0c                      move.l    a4,-(a7)
[00fdaa2c] f5b0                      dc.w      $F5B0
[00fdaa2e] defc 0012                 adda.w    #$0012,a7
[00fdaa32] 3d40 fffe                 move.w    d0,-2(a6)
[00fdaa36] 606a                      bra.s     $00FDAAA2
[00fdaa38] 4a2e ff7c                 tst.b     -132(a6)
[00fdaa3c] 670e                      beq.s     $00FDAA4C
[00fdaa3e] 486e ff7c                 pea.l     -132(a6)
[00fdaa42] 2f3c 00fe b1be            move.l    #$00FEB1BE,-(a7)
[00fdaa48] f404                      dc.w      $F404 ; xstrpcat
[00fdaa4a] 508f                      addq.l    #8,a7
[00fdaa4c] 486e ff7c                 pea.l     -132(a6)
[00fdaa50] 2f2e fffa                 move.l    -6(a6),-(a7)
[00fdaa54] 0697 0000 0012            addi.l    #$00000012,(a7)
[00fdaa5a] f404                      dc.w      $F404 ; xstrpcat
[00fdaa5c] 508f                      addq.l    #8,a7
[00fdaa5e] 486e ff6e                 pea.l     -146(a6)
[00fdaa62] 486e ff72                 pea.l     -142(a6)
[00fdaa66] 486e ff7c                 pea.l     -132(a6)
[00fdaa6a] 3f2e fff8                 move.w    -8(a6),-(a7)
[00fdaa6e] 3f07                      move.w    d7,-(a7)
[00fdaa70] 2f0c                      move.l    a4,-(a7)
[00fdaa72] f5b4                      dc.w      $F5B4
[00fdaa74] defc 0014                 adda.w    #$0014,a7
[00fdaa78] 6028                      bra.s     $00FDAAA2
[00fdaa7a] 3e87                      move.w    d7,(a7)
[00fdaa7c] f5b8                      dc.w      $F5B8
[00fdaa7e] 6022                      bra.s     $00FDAAA2
[00fdaa80] 4297                      clr.l     (a7)
[00fdaa82] 2f3c 0001 000e            move.l    #$0001000E,-(a7)
[00fdaa88] f0dc                      dc.w      $F0DC ; fill_string
[00fdaa8a] 588f                      addq.l    #4,a7
[00fdaa8c] 6014                      bra.s     $00FDAAA2
[00fdaa8e] b07c 0004                 cmp.w     #$0004,d0
[00fdaa92] 620e                      bhi.s     $00FDAAA2
[00fdaa94] e540                      asl.w     #2,d0
[00fdaa96] 3040                      movea.w   d0,a0
[00fdaa98] d1fc 00fe b198            adda.l    #$00FEB198,a0
[00fdaa9e] 2050                      movea.l   (a0),a0
[00fdaaa0] 4ed0                      jmp       (a0)
[00fdaaa2] 302e fffe                 move.w    -2(a6),d0
[00fdaaa6] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfdaaa8
xfdaaa8: ds.b 0
#if 0
[00fdaaa8] 4e56 fff6                 link      a6,#$FFF6
[00fdaaac] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fdaab0] 3e2e 0008                 move.w    8(a6),d7
[00fdaab4] 2679 0000 a788            movea.l   _thedesk,a3
[00fdaaba] 486e fffe                 pea.l     -2(a6)
[00fdaabe] 486e fffa                 pea.l     -6(a6)
[00fdaac2] 3f07                      move.w    d7,-(a7)
[00fdaac4] 3f2b 3598                 move.w    13720(a3),-(a7)
[00fdaac8] f2f8                      dc.w      $F2F8
[00fdaaca] defc 000c                 adda.w    #12,a7
[00fdaace] 2a40                      movea.l   d0,a5
[00fdaad0] 4a6b 3598                 tst.w     13720(a3)
[00fdaad4] 6708                      beq.s     $00FDAADE
[00fdaad6] 3eab 3598                 move.w    13720(a3),(a7)
[00fdaada] f2ec                      dc.w      $F2EC
[00fdaadc] 2840                      movea.l   d0,a4
[00fdaade] 200d                      move.l    a5,d0
[00fdaae0] 6700 008e                 beq       $00FDAB70
[00fdaae4] 302d 0006                 move.w    6(a5),d0
[00fdaae8] 606e                      bra.s     $00FDAB58
[00fdaaea] 4297                      clr.l     (a7)
[00fdaaec] 2f3c 0001 001a            move.l    #$0001001A,-(a7)
[00fdaaf2] f0dc                      dc.w      $F0DC ; fill_string
[00fdaaf4] 588f                      addq.l    #4,a7
[00fdaaf6] 6000 0078                 bra.w     $00FDAB70
[00fdaafa] 206c 0018                 movea.l   24(a4),a0
[00fdaafe] 1028 0008                 move.b    8(a0),d0
[00fdab02] 4880                      ext.w     d0
[00fdab04] 3e80                      move.w    d0,(a7)
[00fdab06] f4e4                      dc.w      $F4E4
[00fdab08] 4a40                      tst.w     d0
[00fdab0a] 6764                      beq.s     $00FDAB70
[00fdab0c] 3ead 0006                 move.w    6(a5),(a7)
[00fdab10] 2f2e fffa                 move.l    -6(a6),-(a7)
[00fdab14] 2f2c 0018                 move.l    24(a4),-(a7)
[00fdab18] 5097                      addq.l    #8,(a7)
[00fdab1a] f5bc                      dc.w      $F5BC
[00fdab1c] 508f                      addq.l    #8,a7
[00fdab1e] 4a40                      tst.w     d0
[00fdab20] 6704                      beq.s     $00FDAB26
[00fdab22] 2e8c                      move.l    a4,(a7)
[00fdab24] f4c8                      dc.w      $F4C8
[00fdab26] 6048                      bra.s     $00FDAB70
[00fdab28] 3e87                      move.w    d7,(a7)
[00fdab2a] 486b 5e88                 pea.l     24200(a3)
[00fdab2e] f4d4                      dc.w      $F4D4
[00fdab30] 588f                      addq.l    #4,a7
[00fdab32] 2d40 fff6                 move.l    d0,-10(a6)
[00fdab36] 206e fff6                 movea.l   -10(a6),a0
[00fdab3a] 3ea8 000c                 move.w    12(a0),(a7)
[00fdab3e] 0257 00ff                 andi.w    #$00FF,(a7)
[00fdab42] f4e4                      dc.w      $F4E4
[00fdab44] 4a40                      tst.w     d0
[00fdab46] 6728                      beq.s     $00FDAB70
[00fdab48] 206e fff6                 movea.l   -10(a6),a0
[00fdab4c] 3ea8 000c                 move.w    12(a0),(a7)
[00fdab50] 0257 00ff                 andi.w    #$00FF,(a7)
[00fdab54] f5c0                      dc.w      $F5C0
[00fdab56] 6018                      bra.s     $00FDAB70
[00fdab58] 4a40                      tst.w     d0
[00fdab5a] 679e                      beq.s     $00FDAAFA
[00fdab5c] b07c 0001                 cmp.w     #1,d0
[00fdab60] 6798                      beq.s     $00FDAAFA
[00fdab62] b07c 0002                 cmp.w     #$0002,d0
[00fdab66] 67c0                      beq.s     $00FDAB28
[00fdab68] b07c 0003                 cmp.w     #$0003,d0
[00fdab6c] 6700 ff7c                 beq       $00FDAAEA
[00fdab70] 4240                      clr.w     d0
[00fdab72] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfdab74
xfdab74: ds.b 0
#if 0
[00fdab74] 4e56 fff0                 link      a6,#$FFF0
[00fdab78] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fdab7c] 3e2e 0008                 move.w    8(a6),d7
[00fdab80] 2679 0000 a788            movea.l   _thedesk,a3
[00fdab86] 9bcd                      suba.l    a5,a5
[00fdab88] 4a6b 3598                 tst.w     13720(a3)
[00fdab8c] 6620                      bne.s     $00FDABAE
[00fdab8e] 3e87                      move.w    d7,(a7)
[00fdab90] f5c4                      dc.w      $F5C4
[00fdab92] 2d40 fff6                 move.l    d0,-10(a6)
[00fdab96] 486e fffe                 pea.l     -2(a6)
[00fdab9a] 2f2e fff6                 move.l    -10(a6),-(a7)
[00fdab9e] 3f07                      move.w    d7,-(a7)
[00fdaba0] 2f3c 0001 ffff            move.l    #$0001FFFF,-(a7)
[00fdaba6] f4dc                      dc.w      $F4DC
[00fdaba8] defc 000e                 adda.w    #$000E,a7
[00fdabac] 2a40                      movea.l   d0,a5
[00fdabae] 200d                      move.l    a5,d0
[00fdabb0] 674c                      beq.s     $00FDABFE
[00fdabb2] 0c6d 0002 0006            cmpi.w    #$0002,6(a5)
[00fdabb8] 6644                      bne.s     $00FDABFE
[00fdabba] 3e87                      move.w    d7,(a7)
[00fdabbc] 486b 5e88                 pea.l     24200(a3)
[00fdabc0] f4d4                      dc.w      $F4D4
[00fdabc2] 588f                      addq.l    #4,a7
[00fdabc4] 2840                      movea.l   d0,a4
[00fdabc6] 302c 000c                 move.w    12(a4),d0
[00fdabca] c07c 00ff                 and.w     #$00FF,d0
[00fdabce] 1d40 fff0                 move.b    d0,-16(a6)
[00fdabd2] 422e fff1                 clr.b     -15(a6)
[00fdabd6] 41ee fff0                 lea.l     -16(a6),a0
[00fdabda] 2d48 fffa                 move.l    a0,-6(a6)
[00fdabde] 486e fffa                 pea.l     -6(a6)
[00fdabe2] 2f3c 0002 000f            move.l    #$0002000F,-(a7)
[00fdabe8] f0dc                      dc.w      $F0DC ; fill_string
[00fdabea] 508f                      addq.l    #8,a7
[00fdabec] b07c 0001                 cmp.w     #1,d0
[00fdabf0] 660c                      bne.s     $00FDABFE
[00fdabf2] 3ebc 00fc                 move.w    #$00FC,(a7)
[00fdabf6] 486e fff0                 pea.l     -16(a6)
[00fdabfa] f4fc                      dc.w      $F4FC ; fc_start
[00fdabfc] 588f                      addq.l    #4,a7
[00fdabfe] 4240                      clr.w     d0
[00fdac00] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfdac02
xfdac02: ds.b 0
#if 0
[00fdac02] 4e56 fff8                 link      a6,#$FFF8
[00fdac06] 48e7 030c                 movem.l   d6-d7/a4-a5,-(a7)
[00fdac0a] 2a6e 0008                 movea.l   8(a6),a5
[00fdac0e] 2879 0000 a788            movea.l   _thedesk,a4
[00fdac14] 486e fff8                 pea.l     -8(a6)
[00fdac18] 486e fffa                 pea.l     -6(a6)
[00fdac1c] 486e fffc                 pea.l     -4(a6)
[00fdac20] 486e fffe                 pea.l     -2(a6)
[00fdac24] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdac28] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdac2c] f5c8                      dc.w      $F5C8 ; wind_get
[00fdac2e] defc 0014                 adda.w    #$0014,a7
[00fdac32] 204c                      movea.l   a4,a0
[00fdac34] 322d 0008                 move.w    8(a5),d1
[00fdac38] c3fc 0018                 muls.w    #24,d1
[00fdac3c] d1c1                      adda.l    d1,a0
[00fdac3e] 3ea8 5e9a                 move.w    24218(a0),(a7)
[00fdac42] 204c                      movea.l   a4,a0
[00fdac44] 322d 0008                 move.w    8(a5),d1
[00fdac48] c3fc 0018                 muls.w    #24,d1
[00fdac4c] d1c1                      adda.l    d1,a0
[00fdac4e] 3f28 5e98                 move.w    24216(a0),-(a7)
[00fdac52] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdac56] 3f3c 0001                 move.w    #1,-(a7)
[00fdac5a] f5cc                      dc.w      $F5CC
[00fdac5c] 5c8f                      addq.l    #6,a7
[00fdac5e] 2ead 0018                 move.l    24(a5),(a7)
[00fdac62] f4f0                      dc.w      $F4F0
[00fdac64] 2e8d                      move.l    a5,(a7)
[00fdac66] f5a8                      dc.w      $F5A8
[00fdac68] f584                      dc.w      $F584
[00fdac6a] 2a40                      movea.l   d0,a5
[00fdac6c] 200d                      move.l    a5,d0
[00fdac6e] 6706                      beq.s     $00FDAC76
[00fdac70] 302d 0006                 move.w    6(a5),d0
[00fdac74] 6002                      bra.s     $00FDAC78
[00fdac76] 4240                      clr.w     d0
[00fdac78] 3940 359a                 move.w    d0,13722(a4)
[00fdac7c] 3ebc 0001                 move.w    #1,(a7)
[00fdac80] 3f2c 359a                 move.w    13722(a4),-(a7)
[00fdac84] f4b0                      dc.w      $F4B0
[00fdac86] 548f                      addq.l    #2,a7
[00fdac88] 4240                      clr.w     d0
[00fdac8a] fc21                      dc.w      $FC21 ; movem.l (a7)+,d7/a4-a5
#endif

	xdef xfdac8c
xfdac8c: ds.b 0
#if 0
[00fdac8c] 4e56 fff2                 link      a6,#$FFF2
[00fdac90] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fdac94] 2a6e 0008                 movea.l   8(a6),a5
[00fdac98] 47ee fff6                 lea.l     -10(a6),a3
[00fdac9c] 2879 0000 a788            movea.l   _thedesk,a4
[00fdaca2] 2e8b                      move.l    a3,(a7)
[00fdaca4] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdaca8] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdacac] f4bc                      dc.w      $F4BC
[00fdacae] 588f                      addq.l    #4,a7
[00fdacb0] 302b 0004                 move.w    4(a3),d0
[00fdacb4] 48c0                      ext.l     d0
[00fdacb6] 81fc 0002                 divs.w    #$0002,d0
[00fdacba] d053                      add.w     (a3),d0
[00fdacbc] 322c 35fc                 move.w    13820(a4),d1
[00fdacc0] 48c1                      ext.l     d1
[00fdacc2] 83fc 0002                 divs.w    #$0002,d1
[00fdacc6] 9041                      sub.w     d1,d0
[00fdacc8] 3d40 fff4                 move.w    d0,-12(a6)
[00fdaccc] 302b 0006                 move.w    6(a3),d0
[00fdacd0] 48c0                      ext.l     d0
[00fdacd2] 81fc 0002                 divs.w    #$0002,d0
[00fdacd6] d06b 0002                 add.w     2(a3),d0
[00fdacda] 322c 35fe                 move.w    13822(a4),d1
[00fdacde] 48c1                      ext.l     d1
[00fdace0] 83fc 0002                 divs.w    #$0002,d1
[00fdace4] 9041                      sub.w     d1,d0
[00fdace6] 3d40 fff2                 move.w    d0,-14(a6)
[00fdacea] 3eae fff2                 move.w    -14(a6),(a7)
[00fdacee] 3f2e fff4                 move.w    -12(a6),-(a7)
[00fdacf2] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdacf6] 4267                      clr.w     -(a7)
[00fdacf8] f5cc                      dc.w      $F5CC
[00fdacfa] 5c8f                      addq.l    #6,a7
[00fdacfc] 426d 000c                 clr.w     12(a5)
[00fdad00] 426d 000e                 clr.w     14(a5)
[00fdad04] 2eae 0016                 move.l    22(a6),(a7)
[00fdad08] 2f2e 0012                 move.l    18(a6),-(a7)
[00fdad0c] 2f2e 000e                 move.l    14(a6),-(a7)
[00fdad10] 3f2e 000c                 move.w    12(a6),-(a7)
[00fdad14] 4267                      clr.w     -(a7)
[00fdad16] 2f0d                      move.l    a5,-(a7)
[00fdad18] f5b4                      dc.w      $F5B4
[00fdad1a] defc 0010                 adda.w    #$0010,a7
[00fdad1e] 4240                      clr.w     d0
[00fdad20] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfdad22
xfdad22: ds.b 0
#if 0
[00fdad22] 4e56 ff76                 link      a6,#$FF76
[00fdad26] 48e7 071c                 movem.l   d5-d7/a3-a5,-(a7)
[00fdad2a] 2a6e 0008                 movea.l   8(a6),a5
[00fdad2e] 3e2e 000c                 move.w    12(a6),d7
[00fdad32] 4246                      clr.w     d6
[00fdad34] 3ebc 0001                 move.w    #1,(a7)
[00fdad38] f094                      dc.w      $F094 ; desk_wait
[00fdad3a] 486e ff76                 pea.l     -138(a6)
[00fdad3e] 486e ff7a                 pea.l     -134(a6)
[00fdad42] 486e ff84                 pea.l     -124(a6)
[00fdad46] 486e fffe                 pea.l     -2(a6)
[00fdad4a] 2f2d 0018                 move.l    24(a5),-(a7)
[00fdad4e] 5097                      addq.l    #8,(a7)
[00fdad50] f5ac                      dc.w      $F5AC
[00fdad52] defc 0014                 adda.w    #$0014,a7
[00fdad56] 4a47                      tst.w     d7
[00fdad58] 6704                      beq.s     $00FDAD5E
[00fdad5a] 422e ff84                 clr.b     -124(a6)
[00fdad5e] 4a2e ff84                 tst.b     -124(a6)
[00fdad62] 6608                      bne.s     $00FDAD6C
[00fdad64] 2e8d                      move.l    a5,(a7)
[00fdad66] f5d0                      dc.w      $F5D0
[00fdad68] 3c00                      move.w    d0,d6
[00fdad6a] 6042                      bra.s     $00FDADAE
[00fdad6c] 47ee ff84                 lea.l     -124(a6),a3
[00fdad70] 200b                      move.l    a3,d0
[00fdad72] 2840                      movea.l   d0,a4
[00fdad74] 2e8e                      move.l    a6,(a7)
[00fdad76] 0697 ffff ff84            addi.l    #$FFFFFF84,(a7)
[00fdad7c] f24c                      dc.w      $F24C ; strlen
[00fdad7e] 5340                      subq.w    #1,d0
[00fdad80] 48c0                      ext.l     d0
[00fdad82] d7c0                      adda.l    d0,a3
[00fdad84] 6002                      bra.s     $00FDAD88
[00fdad86] 538b                      subq.l    #1,a3
[00fdad88] b7cc                      cmpa.l    a4,a3
[00fdad8a] 6706                      beq.s     $00FDAD92
[00fdad8c] 0c13 005c                 cmpi.b    #$5C,(a3)
[00fdad90] 66f4                      bne.s     $00FDAD86
[00fdad92] 4213                      clr.b     (a3)
[00fdad94] 486e ff76                 pea.l     -138(a6)
[00fdad98] 486e ff7a                 pea.l     -134(a6)
[00fdad9c] 486e ff84                 pea.l     -124(a6)
[00fdada0] 3f2e fffe                 move.w    -2(a6),-(a7)
[00fdada4] 2f0d                      move.l    a5,-(a7)
[00fdada6] f5d4                      dc.w      $F5D4
[00fdada8] defc 0012                 adda.w    #$0012,a7
[00fdadac] 3c00                      move.w    d0,d6
[00fdadae] 4257                      clr.w     (a7)
[00fdadb0] f094                      dc.w      $F094 ; desk_wait
[00fdadb2] 3006                      move.w    d6,d0
[00fdadb4] fe31                      dc.w      $FE31 ; movem.l (a7)+,d6-d7/a3-a5
#endif

	xdef xfdadb6
xfdadb6: ds.b 0
#if 0
[00fdadb6] 4e56 fff4                 link      a6,#$FFF4
[00fdadba] 48e7 0700                 movem.l   d5-d7,-(a7)
[00fdadbe] 302e 0008                 move.w    8(a6),d0
[00fdadc2] 4880                      ext.w     d0
[00fdadc4] b07c 0063                 cmp.w     #$0063,d0
[00fdadc8] 6606                      bne.s     $00FDADD0
[00fdadca] 7001                      moveq.l   #1,d0
[00fdadcc] 6000 0086                 bra       $00FDAE54
[00fdadd0] 3ebc 0001                 move.w    #1,(a7)
[00fdadd4] f094                      dc.w      $F094 ; desk_wait
[00fdadd6] 3ebc 000a                 move.w    #10,(a7)
[00fdadda] f5d8                      dc.w      $F5D8 ; ftrp13
[00fdaddc] 2e00                      move.l    d0,d7
[00fdadde] 302e 0008                 move.w    8(a6),d0
[00fdade2] d07c ffbf                 add.w     #$FFBF,d0
[00fdade6] 3d40 fffe                 move.w    d0,-2(a6)
[00fdadea] 302e fffe                 move.w    -2(a6),d0
[00fdadee] e0a7                      asr.l     d0,d7
[00fdadf0] cebc 0000 0001            and.l     #$00000001,d7
[00fdadf6] 7c01                      moveq.l   #1,d6
[00fdadf8] 4a87                      tst.l     d7
[00fdadfa] 660a                      bne.s     $00FDAE06
[00fdadfc] 3ebc 000f                 move.w    #$000F,(a7)
[00fdae00] f0a4                      dc.w      $F0A4 ; fm_error
[00fdae02] 4246                      clr.w     d6
[00fdae04] 6048                      bra.s     $00FDAE4E
[00fdae06] 302e 0008                 move.w    8(a6),d0
[00fdae0a] 4880                      ext.w     d0
[00fdae0c] 1d40 fff4                 move.b    d0,-12(a6)
[00fdae10] 1d7c 003a fff5            move.b    #$3A,-11(a6)
[00fdae16] 486e fff6                 pea.l     -10(a6)
[00fdae1a] 2f3c 00fe b130            move.l    #_getall,-(a7)
[00fdae20] f36c                      dc.w      $F36C ; xstrpcpy
[00fdae22] 508f                      addq.l    #8,a7
[00fdae24] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fdae2a] 0697 0000 311e            addi.l    #$0000311E,(a7)
[00fdae30] f3f4                      dc.w      $F3F4 ; dos_sdta
[00fdae32] 3ebc 0016                 move.w    #$0016,(a7)
[00fdae36] 486e fff4                 pea.l     -12(a6)
[00fdae3a] f3fc                      dc.w      $F3FC ; dos_sfirst
[00fdae3c] 588f                      addq.l    #4,a7
[00fdae3e] 4a40                      tst.w     d0
[00fdae40] 660c                      bne.s     $00FDAE4E
[00fdae42] 0c79 0012 0000 6e20       cmpi.w    #$0012,_DOS_AX
[00fdae4a] 6702                      beq.s     $00FDAE4E
[00fdae4c] 4246                      clr.w     d6
[00fdae4e] 4257                      clr.w     (a7)
[00fdae50] f094                      dc.w      $F094 ; desk_wait
[00fdae52] 3006                      move.w    d6,d0
[00fdae54] f031                      dc.w      $F031 ; movem.l (a7)+,d6-d7
#endif
