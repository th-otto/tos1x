	xdef _deskmain
_deskmain: ds.b 0
#if 0
[00fdbc88] 4e56 ffb2                 link      a6,#$FFB2
[00fdbc8c] 48e7 3f04                 movem.l   d2-d7/a5,-(a7)
[00fdbc90] 2ebc 0000 776c            move.l    #$0000776C,(a7)
[00fdbc96] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fdbc98] 23c0 0000 a788            move.l    d0,_thedesk
[00fdbc9e] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fdbca4] 4267                      clr.w     -(a7)
[00fdbca6] 3f3c 776c                 move.w    #$776C,-(a7)
[00fdbcaa] f358                      dc.w      $F358 ; bfill
[00fdbcac] 588f                      addq.l    #4,a7
[00fdbcae] 2ebc 0000 0200            move.l    #$00000200,(a7)
[00fdbcb4] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fdbcb6] 23c0 0000 a7b6            move.l    d0,$0000A7B6
[00fdbcbc] 2ebc 0000 03b8            move.l    #$000003B8,(a7)
[00fdbcc2] f3c0                      dc.w      $F3C0 ; dos_alloc
[00fdbcc4] 23c0 0000 a7ba            move.l    d0,$0000A7BA
[00fdbcca] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdbcd0] f668                      dc.w      $F668 ; ap_init
[00fdbcd2] 3ebc 0001                 move.w    #1,(a7)
[00fdbcd6] f66c                      dc.w      $F66C ; wind_update
[00fdbcd8] 486d 3440                 pea.l     13376(a5)
[00fdbcdc] 486d 343e                 pea.l     13374(a5)
[00fdbce0] 486d 343c                 pea.l     13372(a5)
[00fdbce4] 486d 343a                 pea.l     13370(a5)
[00fdbce8] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdbcec] 4267                      clr.w     -(a7)
[00fdbcee] f5c8                      dc.w      $F5C8 ; wind_get
[00fdbcf0] defc 0014                 adda.w    #$0014,a7
[00fdbcf4] 486d 3448                 pea.l     13384(a5)
[00fdbcf8] 486d 3446                 pea.l     13382(a5)
[00fdbcfc] 486d 3444                 pea.l     13380(a5)
[00fdbd00] 486d 3442                 pea.l     13378(a5)
[00fdbd04] 2f2d 343e                 move.l    13374(a5),-(a7)
[00fdbd08] 2f2d 343a                 move.l    13370(a5),-(a7)
[00fdbd0c] 2f3c 0001 ffff            move.l    #$0001FFFF,-(a7)
[00fdbd12] f670                      dc.w      $F670 ; wind_calc
[00fdbd14] defc 001c                 adda.w    #$001C,a7
[00fdbd18] 41ed 344a                 lea.l     13386(a5),a0
[00fdbd1c] 2b48 34ca                 move.l    a0,13514(a5)
[00fdbd20] 41ed 34ce                 lea.l     13518(a5),a0
[00fdbd24] 2b48 354e                 move.l    a0,13646(a5)
[00fdbd28] 41ed 3426                 lea.l     13350(a5),a0
[00fdbd2c] 2b48 3436                 move.l    a0,13366(a5)
[00fdbd30] 3ebc 0001                 move.w    #1,(a7)
[00fdbd34] f094                      dc.w      $F094 ; desk_wait
[00fdbd36] 2ebc 0000 6e6c            move.l    #$00006E6C,(a7)
[00fdbd3c] 3f3c 0001                 move.w    #1,-(a7)
[00fdbd40] f348                      dc.w      $F348 ; rom_ram
[00fdbd42] 548f                      addq.l    #2,a7
[00fdbd44] 486d 35a8                 pea.l     13736(a5)
[00fdbd48] 2f3c 0005 0003            move.l    #$00050003,-(a7)
[00fdbd4e] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fdbd50] 508f                      addq.l    #8,a7
[00fdbd52] 4246                      clr.w     d6
[00fdbd54] 601c                      bra.s     $00FDBD72
[00fdbd56] 200d                      move.l    a5,d0
[00fdbd58] 3206                      move.w    d6,d1
[00fdbd5a] e541                      asl.w     #2,d1
[00fdbd5c] 48c1                      ext.l     d1
[00fdbd5e] d081                      add.l     d1,d0
[00fdbd60] 2e80                      move.l    d0,(a7)
[00fdbd62] 0697 0000 3556            addi.l    #$00003556,(a7)
[00fdbd68] 3f06                      move.w    d6,-(a7)
[00fdbd6a] 4267                      clr.w     -(a7)
[00fdbd6c] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fdbd6e] 588f                      addq.l    #4,a7
[00fdbd70] 5246                      addq.w    #1,d6
[00fdbd72] bc7c 0010                 cmp.w     #$0010,d6
[00fdbd76] 6dde                      blt.s     $00FDBD56
[00fdbd78] f674                      dc.w      $F674 ; read_inf
[00fdbd7a] 4a40                      tst.w     d0
[00fdbd7c] 6608                      bne.s     $00FDBD86
[00fdbd7e] f678                      dc.w      $F678 ; ap_exit
[00fdbd80] 4240                      clr.w     d0
[00fdbd82] 6000 0316                 bra       $00FDC09A
[00fdbd86] f67c                      dc.w      $F67C
[00fdbd88] f680                      dc.w      $F680
[00fdbd8a] 42a7                      clr.l     -(a7)
[00fdbd8c] f4b0                      dc.w      $F4B0
[00fdbd8e] 588f                      addq.l    #4,a7
[00fdbd90] 3ebc 0001                 move.w    #1,(a7)
[00fdbd94] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbd98] f684                      dc.w      $F684 ; menu_bar
[00fdbd9a] 588f                      addq.l    #4,a7
[00fdbd9c] 2ead 3556                 move.l    13654(a5),(a7)
[00fdbda0] f634                      dc.w      $F634
[00fdbda2] 4246                      clr.w     d6
[00fdbda4] 6014                      bra.s     $00FDBDBA
[00fdbda6] 42a7                      clr.l     -(a7)
[00fdbda8] 3f06                      move.w    d6,-(a7)
[00fdbdaa] 0657 001b                 addi.w    #$001B,(a7)
[00fdbdae] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbdb2] f0c4                      dc.w      $F0C4 ; ob_change
[00fdbdb4] defc 000a                 adda.w    #10,a7
[00fdbdb8] 5246                      addq.w    #1,d6
[00fdbdba] bc7c 0007                 cmp.w     #$0007,d6
[00fdbdbe] 6de6                      blt.s     $00FDBDA6
[00fdbdc0] 4257                      clr.w     (a7)
[00fdbdc2] 2f3c 001d 0008            move.l    #$001D0008,-(a7)
[00fdbdc8] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbdcc] f0c4                      dc.w      $F0C4 ; ob_change
[00fdbdce] 508f                      addq.l    #8,a7
[00fdbdd0] f338                      dc.w      $F338 ; isdrive
[00fdbdd2] 4a40                      tst.w     d0
[00fdbdd4] 6610                      bne.s     $00FDBDE6
[00fdbdd6] 4257                      clr.w     (a7)
[00fdbdd8] 2f3c 0029 0008            move.l    #$00290008,-(a7)
[00fdbdde] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbde2] f0c4                      dc.w      $F0C4 ; ob_change
[00fdbde4] 508f                      addq.l    #8,a7
[00fdbde6] 3b7c 001b 359c            move.w    #$001B,13724(a5)
[00fdbdec] 3ebc 0001                 move.w    #1,(a7)
[00fdbdf0] 3f2d 359c                 move.w    13724(a5),-(a7)
[00fdbdf4] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbdf8] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdbdfa] 5c8f                      addq.l    #6,a7
[00fdbdfc] 3b7c 001e 359e            move.w    #$001E,13726(a5)
[00fdbe02] 3ebc 0001                 move.w    #1,(a7)
[00fdbe06] 3f2d 359e                 move.w    13726(a5),-(a7)
[00fdbe0a] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbe0e] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdbe10] 5c8f                      addq.l    #6,a7
[00fdbe12] f608                      dc.w      $F608
[00fdbe14] 2f2d 343e                 move.l    13374(a5),-(a7)
[00fdbe18] 2f2d 343a                 move.l    13370(a5),-(a7)
[00fdbe1c] 4267                      clr.w     -(a7)
[00fdbe1e] f2c0                      dc.w      $F2C0
[00fdbe20] defc 000a                 adda.w    #10,a7
[00fdbe24] 4257                      clr.w     (a7)
[00fdbe26] 3f3c 0001                 move.w    #1,-(a7)
[00fdbe2a] 2f2d 5e2c                 move.l    24108(a5),-(a7)
[00fdbe2e] 3f3c 000e                 move.w    #$000E,-(a7)
[00fdbe32] 4267                      clr.w     -(a7)
[00fdbe34] f4b8                      dc.w      $F4B8 ; wind_set
[00fdbe36] defc 000a                 adda.w    #10,a7
[00fdbe3a] 42a7                      clr.l     -(a7)
[00fdbe3c] f4b0                      dc.w      $F4B0
[00fdbe3e] 588f                      addq.l    #4,a7
[00fdbe40] 426d 359a                 clr.w     13722(a5)
[00fdbe44] f688                      dc.w      $F688
[00fdbe46] 2d6d 3556 fff4            move.l    13654(a5),-12(a6)
[00fdbe4c] 3ebc ffff                 move.w    #$FFFF,(a7)
[00fdbe50] 3f3c 0040                 move.w    #$0040,-(a7)
[00fdbe54] f0ec                      dc.w      $F0EC ; trp14
[00fdbe56] 548f                      addq.l    #2,a7
[00fdbe58] 3a00                      move.w    d0,d5
[00fdbe5a] 0805 0001                 btst      #1,d5
[00fdbe5e] 6754                      beq.s     $00FDBEB4
[00fdbe60] 206e fff4                 movea.l   -12(a6),a0
[00fdbe64] d1fc 0000 0334            adda.l    #$00000334,a0
[00fdbe6a] 30bc 002a                 move.w    #$002A,(a0)
[00fdbe6e] 206e fff4                 movea.l   -12(a6),a0
[00fdbe72] d1fc 0000 03c0            adda.l    #$000003C0,a0
[00fdbe78] 30bc 0029                 move.w    #$0029,(a0)
[00fdbe7c] 3039 0000 6ce2            move.w    _gl_hchar,d0
[00fdbe82] e740                      asl.w     #3,d0
[00fdbe84] 226e fff4                 movea.l   -12(a6),a1
[00fdbe88] d3fc 0000 0346            adda.l    #$00000346,a1
[00fdbe8e] 3280                      move.w    d0,(a1)
[00fdbe90] 3b6d 5c06 35a4            move.w    23558(a5),13732(a5)
[00fdbe96] 3ead 35a4                 move.w    13732(a5),(a7)
[00fdbe9a] 3f3c 002a                 move.w    #$002A,-(a7)
[00fdbe9e] 2f2d 3556                 move.l    13654(a5),-(a7)
[00fdbea2] f5fc                      dc.w      $F5FC ; menu_icheck
[00fdbea4] 5c8f                      addq.l    #6,a7
[00fdbea6] 3ead 35a4                 move.w    13732(a5),(a7)
[00fdbeaa] 3f3c 0040                 move.w    #$0040,-(a7)
[00fdbeae] f0ec                      dc.w      $F0EC ; trp14
[00fdbeb0] 548f                      addq.l    #2,a7
[00fdbeb2] 6032                      bra.s     $00FDBEE6
[00fdbeb4] 206e fff4                 movea.l   -12(a6),a0
[00fdbeb8] d1fc 0000 0334            adda.l    #$00000334,a0
[00fdbebe] 30bc 0028                 move.w    #$0028,(a0)
[00fdbec2] 206e fff4                 movea.l   -12(a6),a0
[00fdbec6] d1fc 0000 03c0            adda.l    #$000003C0,a0
[00fdbecc] 30bc 0022                 move.w    #$0022,(a0)
[00fdbed0] 3039 0000 6ce2            move.w    _gl_hchar,d0
[00fdbed6] c1fc 0006                 muls.w    #$0006,d0
[00fdbeda] 226e fff4                 movea.l   -12(a6),a1
[00fdbede] d3fc 0000 0346            adda.l    #$00000346,a1
[00fdbee4] 3280                      move.w    d0,(a1)
[00fdbee6] 4246                      clr.w     d6
[00fdbee8] 6000 0084                 bra       $00FDBF6E
[00fdbeec] 3046                      movea.w   d6,a0
[00fdbeee] d1c8                      adda.l    a0,a0
[00fdbef0] d1fc 00fe b1fc            adda.l    #$00FEB1FC,a0
[00fdbef6] 3e10                      move.w    (a0),d7
[00fdbef8] 3007                      move.w    d7,d0
[00fdbefa] 5246                      addq.w    #1,d6
[00fdbefc] 4a40                      tst.w     d0
[00fdbefe] 6772                      beq.s     $00FDBF72
[00fdbf00] 5347                      subq.w    #1,d7
[00fdbf02] 486e fffa                 pea.l     -6(a6)
[00fdbf06] 486e fffc                 pea.l     -4(a6)
[00fdbf0a] 3f07                      move.w    d7,-(a7)
[00fdbf0c] 2f2e fff4                 move.l    -12(a6),-(a7)
[00fdbf10] f3ac                      dc.w      $F3AC ; objc_offset
[00fdbf12] defc 000e                 adda.w    #$000E,a7
[00fdbf16] 3007                      move.w    d7,d0
[00fdbf18] c1fc 0018                 muls.w    #24,d0
[00fdbf1c] d0ae fff4                 add.l     -12(a6),d0
[00fdbf20] d0bc 0000 0014            add.l     #$00000014,d0
[00fdbf26] 2040                      movea.l   d0,a0
[00fdbf28] 3d50 fffa                 move.w    (a0),-6(a6)
[00fdbf2c] 302e fffc                 move.w    -4(a6),d0
[00fdbf30] d06e fffa                 add.w     -6(a6),d0
[00fdbf34] 3d40 fff8                 move.w    d0,-8(a6)
[00fdbf38] 302d 343e                 move.w    13374(a5),d0
[00fdbf3c] b06e fff8                 cmp.w     -8(a6),d0
[00fdbf40] 6e2c                      bgt.s     $00FDBF6E
[00fdbf42] 302e fffc                 move.w    -4(a6),d0
[00fdbf46] 906e fff8                 sub.w     -8(a6),d0
[00fdbf4a] d06d 343e                 add.w     13374(a5),d0
[00fdbf4e] 9079 0000 6dce            sub.w     _gl_wchar,d0
[00fdbf54] 3d40 fffc                 move.w    d0,-4(a6)
[00fdbf58] 3007                      move.w    d7,d0
[00fdbf5a] c1fc 0018                 muls.w    #24,d0
[00fdbf5e] d0ae fff4                 add.l     -12(a6),d0
[00fdbf62] d0bc 0000 0010            add.l     #$00000010,d0
[00fdbf68] 2040                      movea.l   d0,a0
[00fdbf6a] 30ae fffc                 move.w    -4(a6),(a0)
[00fdbf6e] 6000 ff7c                 bra       $00FDBEEC
[00fdbf72] 4257                      clr.w     (a7)
[00fdbf74] f66c                      dc.w      $F66C ; wind_update
[00fdbf76] 7813                      moveq.l   #19,d4
[00fdbf78] 4245                      clr.w     d5
[00fdbf7a] 4257                      clr.w     (a7)
[00fdbf7c] f094                      dc.w      $F094 ; desk_wait
[00fdbf7e] 6000 0088                 bra       $00FDC008
[00fdbf82] 486e ffe8                 pea.l     -24(a6)
[00fdbf86] 486e ffea                 pea.l     -22(a6)
[00fdbf8a] 486e ffec                 pea.l     -20(a6)
[00fdbf8e] 486e ffee                 pea.l     -18(a6)
[00fdbf92] 486e fff0                 pea.l     -16(a6)
[00fdbf96] 486e fff2                 pea.l     -14(a6)
[00fdbf9a] 42a7                      clr.l     -(a7)
[00fdbf9c] 2f2d 3436                 move.l    13366(a5),-(a7)
[00fdbfa0] 42a7                      clr.l     -(a7)
[00fdbfa2] 42a7                      clr.l     -(a7)
[00fdbfa4] 42a7                      clr.l     -(a7)
[00fdbfa6] 42a7                      clr.l     -(a7)
[00fdbfa8] 42a7                      clr.l     -(a7)
[00fdbfaa] 2f3c 0001 0001            move.l    #$00010001,-(a7)
[00fdbfb0] 3f3c 0002                 move.w    #$0002,-(a7)
[00fdbfb4] 3f04                      move.w    d4,-(a7)
[00fdbfb6] f2d0                      dc.w      $F2D0 ; evnt_multi
[00fdbfb8] defc 003c                 adda.w    #$003C,a7
[00fdbfbc] 3d40 fffe                 move.w    d0,-2(a6)
[00fdbfc0] 3ebc 0001                 move.w    #1,(a7)
[00fdbfc4] f66c                      dc.w      $F66C ; wind_update
[00fdbfc6] 082e 0004 ffff            btst      #4,-1(a6)
[00fdbfcc] 6704                      beq.s     $00FDBFD2
[00fdbfce] f524                      dc.w      $F524 ; hd_msg
[00fdbfd0] 3a00                      move.w    d0,d5
[00fdbfd2] 082e 0000 ffff            btst      #0,-1(a6)
[00fdbfd8] 6708                      beq.s     $00FDBFE2
[00fdbfda] 3eae ffea                 move.w    -22(a6),(a7)
[00fdbfde] f610                      dc.w      $F610 ; hd_keybd
[00fdbfe0] 3a00                      move.w    d0,d5
[00fdbfe2] 082e 0001 ffff            btst      #1,-1(a6)
[00fdbfe8] 671a                      beq.s     $00FDC004
[00fdbfea] 3eae ffec                 move.w    -20(a6),(a7)
[00fdbfee] 3f2e ffee                 move.w    -18(a6),-(a7)
[00fdbff2] 3f2e fff0                 move.w    -16(a6),-(a7)
[00fdbff6] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fdbffa] 3f2e ffe8                 move.w    -24(a6),-(a7)
[00fdbffe] f68c                      dc.w      $F68C ; hd_button
[00fdc000] 508f                      addq.l    #8,a7
[00fdc002] 3a00                      move.w    d0,d5
[00fdc004] 4257                      clr.w     (a7)
[00fdc006] f66c                      dc.w      $F66C ; wind_update
[00fdc008] 4a45                      tst.w     d5
[00fdc00a] 6700 ff76                 beq       $00FDBF82
[00fdc00e] f618                      dc.w      $F618
[00fdc010] 4257                      clr.w     (a7)
[00fdc012] f61c                      dc.w      $F61C ; save_inf
[00fdc014] 4257                      clr.w     (a7)
[00fdc016] 42a7                      clr.l     -(a7)
[00fdc018] f684                      dc.w      $F684 ; menu_bar
[00fdc01a] 588f                      addq.l    #4,a7
[00fdc01c] 4246                      clr.w     d6
[00fdc01e] 6034                      bra.s     $00FDC054
[00fdc020] 204d                      movea.l   a5,a0
[00fdc022] 3206                      move.w    d6,d1
[00fdc024] c3fc 008c                 muls.w    #$008C,d1
[00fdc028] d1c1                      adda.l    d1,a0
[00fdc02a] 4aa8 0086                 tst.l     134(a0)
[00fdc02e] 6710                      beq.s     $00FDC040
[00fdc030] 204d                      movea.l   a5,a0
[00fdc032] 3206                      move.w    d6,d1
[00fdc034] c3fc 008c                 muls.w    #$008C,d1
[00fdc038] d1c1                      adda.l    d1,a0
[00fdc03a] 2ea8 0086                 move.l    134(a0),(a7)
[00fdc03e] f3f0                      dc.w      $F3F0 ; dos_free
[00fdc040] 204d                      movea.l   a5,a0
[00fdc042] 3206                      move.w    d6,d1
[00fdc044] c3fc 008c                 muls.w    #$008C,d1
[00fdc048] d1c1                      adda.l    d1,a0
[00fdc04a] 217c 0000 0000 0086       move.l    #$00000000,134(a0)
[00fdc052] 5246                      addq.w    #1,d6
[00fdc054] bc7c 0005                 cmp.w     #$0005,d6
[00fdc058] 6dc6                      blt.s     $00FDC020
[00fdc05a] f678                      dc.w      $F678 ; ap_exit
[00fdc05c] 7e01                      moveq.l   #1,d7
[00fdc05e] 4a79 0000 6124            tst.w     $00006124
[00fdc064] 671a                      beq.s     $00FDC080
[00fdc066] f690                      dc.w      $F690 ; set_defdrv
[00fdc068] f338                      dc.w      $F338 ; isdrive
[00fdc06a] 4a40                      tst.w     d0
[00fdc06c] 6710                      beq.s     $00FDC07E
[00fdc06e] f46c                      dc.w      $F46C ; dos_gdrv
[00fdc070] 3e80                      move.w    d0,(a7)
[00fdc072] 0657 0041                 addi.w    #$0041,(a7)
[00fdc076] f4e4                      dc.w      $F4E4
[00fdc078] 33c0 0000 61aa            move.w    d0,$000061AA
[00fdc07e] 4247                      clr.w     d7
[00fdc080] 2eb9 0000 a7b6            move.l    $0000A7B6,(a7)
[00fdc086] f3f0                      dc.w      $F3F0 ; dos_free
[00fdc088] 2eb9 0000 a788            move.l    _thedesk,(a7)
[00fdc08e] f3f0                      dc.w      $F3F0 ; dos_free
[00fdc090] 2eb9 0000 a7ba            move.l    $0000A7BA,(a7)
[00fdc096] f3f0                      dc.w      $F3F0 ; dos_free
[00fdc098] 3007                      move.w    d7,d0
[00fdc09a] f83f                      dc.w      $F83F ; movem.l (a7)+,d3-d7/a5
#endif

	xdef xfdc09c
xfdc09c: ds.b 0
#if 0
[00fdc09c] 4e56 0000                 link      a6,#0
[00fdc0a0] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fdc0a4] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdc0aa] 3b6e 0008 3004            move.w    8(a6),12292(a5)
[00fdc0b0] 3b6e 000a 3014            move.w    10(a6),12308(a5)
[00fdc0b6] 302e 0008                 move.w    8(a6),d0
[00fdc0ba] 6000 008c                 bra       $00FDC148
[00fdc0be] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fdc0c6] 6604                      bne.s     $00FDC0CC
[00fdc0c8] 702b                      moveq.l   #43,d0
[00fdc0ca] 6002                      bra.s     $00FDC0CE
[00fdc0cc] 702d                      moveq.l   #45,d0
[00fdc0ce] c1f9 0000 6dce            muls.w    _gl_wchar,d0
[00fdc0d4] 3b40 3006                 move.w    d0,12294(a5)
[00fdc0d8] 3b79 0000 6ce2 3008       move.w    _gl_hchar,12296(a5)
[00fdc0e0] 0c79 0140 0000 7008       cmpi.w    #$0140,gl_width
[00fdc0e8] 6604                      bne.s     $00FDC0EE
[00fdc0ea] 4240                      clr.w     d0
[00fdc0ec] 600a                      bra.s     $00FDC0F8
[00fdc0ee] 3039 0000 6dce            move.w    _gl_wchar,d0
[00fdc0f4] e340                      asl.w     #1,d0
[00fdc0f6] 5340                      subq.w    #1,d0
[00fdc0f8] 3b40 300a                 move.w    d0,12298(a5)
[00fdc0fc] 3b7c 0002 300c            move.w    #$0002,12300(a5)
[00fdc102] 3b6d 35b2 2ffe            move.w    13746(a5),12286(a5)
[00fdc108] 41ed 35d8                 lea.l     13784(a5),a0
[00fdc10c] 2b48 3000                 move.l    a0,12288(a5)
[00fdc110] 6042                      bra.s     $00FDC154
[00fdc112] 3b6d 35fc 3006            move.w    13820(a5),12294(a5)
[00fdc118] 3b6d 35fe 3008            move.w    13822(a5),12296(a5)
[00fdc11e] 0c79 012c 0000 6d90       cmpi.w    #$012C,gl_height
[00fdc126] 6e04                      bgt.s     $00FDC12C
[00fdc128] 4240                      clr.w     d0
[00fdc12a] 6002                      bra.s     $00FDC12E
[00fdc12c] 7008                      moveq.l   #8,d0
[00fdc12e] 3b40 300a                 move.w    d0,12298(a5)
[00fdc132] 3b7c 0002 300c            move.w    #$0002,12300(a5)
[00fdc138] 3b6d 35b0 2ffe            move.w    13744(a5),12286(a5)
[00fdc13e] 41ed 35b4                 lea.l     13748(a5),a0
[00fdc142] 2b48 3000                 move.l    a0,12288(a5)
[00fdc146] 600c                      bra.s     $00FDC154
[00fdc148] 4a40                      tst.w     d0
[00fdc14a] 67c6                      beq.s     $00FDC112
[00fdc14c] b07c 0001                 cmp.w     #1,d0
[00fdc150] 6700 ff6c                 beq       $00FDC0BE
[00fdc154] 302d 3006                 move.w    12294(a5),d0
[00fdc158] d06d 300a                 add.w     12298(a5),d0
[00fdc15c] 3b40 300e                 move.w    d0,12302(a5)
[00fdc160] 302d 3008                 move.w    12296(a5),d0
[00fdc164] d06d 300c                 add.w     12300(a5),d0
[00fdc168] 3b40 3010                 move.w    d0,12304(a5)
[00fdc16c] 302d 3446                 move.w    13382(a5),d0
[00fdc170] 48c0                      ext.l     d0
[00fdc172] 81ed 300e                 divs.w    12302(a5),d0
[00fdc176] 3b40 3012                 move.w    d0,12306(a5)
[00fdc17a] 6606                      bne.s     $00FDC182
[00fdc17c] 3b7c 0001 3012            move.w    #1,12306(a5)
[00fdc182] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfdc184
xfdc184: ds.b 0
#if 0
[00fdc184] 4e56 fffc                 link      a6,#-4
[00fdc188] 48e7 030c                 movem.l   d6-d7/a4-a5,-(a7)
[00fdc18c] 2879 0000 a788            movea.l   _thedesk,a4
[00fdc192] 41ec 5e88                 lea.l     24200(a4),a0
[00fdc196] 2948 5e2c                 move.l    a0,24108(a4)
[00fdc19a] 2008                      move.l    a0,d0
[00fdc19c] 2d40 fffc                 move.l    d0,-4(a6)
[00fdc1a0] 4247                      clr.w     d7
[00fdc1a2] 6032                      bra.s     $00FDC1D6
[00fdc1a4] 204c                      movea.l   a4,a0
[00fdc1a6] 3207                      move.w    d7,d1
[00fdc1a8] c3fc 0018                 muls.w    #24,d1
[00fdc1ac] d1c1                      adda.l    d1,a0
[00fdc1ae] 317c ffff 5e8a            move.w    #$FFFF,24202(a0)
[00fdc1b4] 204c                      movea.l   a4,a0
[00fdc1b6] 3207                      move.w    d7,d1
[00fdc1b8] c3fc 0018                 muls.w    #24,d1
[00fdc1bc] d1c1                      adda.l    d1,a0
[00fdc1be] 317c ffff 5e88            move.w    #$FFFF,24200(a0)
[00fdc1c4] 204c                      movea.l   a4,a0
[00fdc1c6] 3207                      move.w    d7,d1
[00fdc1c8] c3fc 0018                 muls.w    #24,d1
[00fdc1cc] d1c1                      adda.l    d1,a0
[00fdc1ce] 317c ffff 5e8c            move.w    #$FFFF,24204(a0)
[00fdc1d4] 5247                      addq.w    #1,d7
[00fdc1d6] be7c 0104                 cmp.w     #$0104,d7
[00fdc1da] 6dc8                      blt.s     $00FDC1A4
[00fdc1dc] 486c 5e88                 pea.l     24200(a4)
[00fdc1e0] 2f3c 00fe b168            move.l    #$00FEB168,-(a7)
[00fdc1e6] 3f3c 0018                 move.w    #24,-(a7)
[00fdc1ea] f390                      dc.w      $F390 ; movs
[00fdc1ec] defc 000a                 adda.w    #10,a7
[00fdc1f0] 3eb9 0000 6d90            move.w    gl_height,(a7)
[00fdc1f6] 3f39 0000 7008            move.w    gl_width,-(a7)
[00fdc1fc] 42a7                      clr.l     -(a7)
[00fdc1fe] 486c 5e98                 pea.l     24216(a4)
[00fdc202] f298                      dc.w      $F298 ; r_set
[00fdc204] defc 000a                 adda.w    #10,a7
[00fdc208] 4247                      clr.w     d7
[00fdc20a] 6032                      bra.s     $00FDC23E
[00fdc20c] 200c                      move.l    a4,d0
[00fdc20e] 3207                      move.w    d7,d1
[00fdc210] 5241                      addq.w    #1,d1
[00fdc212] c3fc 0018                 muls.w    #24,d1
[00fdc216] d081                      add.l     d1,d0
[00fdc218] 2e80                      move.l    d0,(a7)
[00fdc21a] 0697 0000 5e88            addi.l    #$00005E88,(a7)
[00fdc220] 2f3c 00fe b180            move.l    #$00FEB180,-(a7)
[00fdc226] 3f3c 0018                 move.w    #24,-(a7)
[00fdc22a] f390                      dc.w      $F390 ; movs
[00fdc22c] 5c8f                      addq.l    #6,a7
[00fdc22e] 3e87                      move.w    d7,(a7)
[00fdc230] 5257                      addq.w    #1,(a7)
[00fdc232] 4267                      clr.w     -(a7)
[00fdc234] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fdc238] f554                      dc.w      $F554 ; objc_add
[00fdc23a] 5c8f                      addq.l    #6,a7
[00fdc23c] 5247                      addq.w    #1,d7
[00fdc23e] be7c 0005                 cmp.w     #$0005,d7
[00fdc242] 6dc8                      blt.s     $00FDC20C
[00fdc244] 42a7                      clr.l     -(a7)
[00fdc246] f600                      dc.w      $F600
[00fdc248] 588f                      addq.l    #4,a7
[00fdc24a] 4247                      clr.w     d7
[00fdc24c] 6040                      bra.s     $00FDC28E
[00fdc24e] 3007                      move.w    d7,d0
[00fdc250] c1fc 00ee                 muls.w    #$00EE,d0
[00fdc254] 2a40                      movea.l   d0,a5
[00fdc256] dbf9 0000 a7ba            adda.l    $0000A7BA,a5
[00fdc25c] 426d 0008                 clr.w     8(a5)
[00fdc260] 426d 0006                 clr.w     6(a5)
[00fdc264] 3ebc 0008                 move.w    #$0008,(a7)
[00fdc268] 200c                      move.l    a4,d0
[00fdc26a] 3207                      move.w    d7,d1
[00fdc26c] c3fc 0088                 muls.w    #$0088,d1
[00fdc270] d081                      add.l     d1,d0
[00fdc272] 2f00                      move.l    d0,-(a7)
[00fdc274] 0697 0000 5c0c            addi.l    #$00005C0C,(a7)
[00fdc27a] 3007                      move.w    d7,d0
[00fdc27c] e740                      asl.w     #3,d0
[00fdc27e] 48c0                      ext.l     d0
[00fdc280] d0bc 0000 7098            add.l     #$00007098,d0
[00fdc286] 2f00                      move.l    d0,-(a7)
[00fdc288] f268                      dc.w      $F268 ; LBCOPY
[00fdc28a] 508f                      addq.l    #8,a7
[00fdc28c] 5247                      addq.w    #1,d7
[00fdc28e] be7c 0004                 cmp.w     #$0004,d7
[00fdc292] 6dba                      blt.s     $00FDC24E
[00fdc294] 2079 0000 a788            movea.l   _thedesk,a0
[00fdc29a] 4268 034c                 clr.w     844(a0)
[00fdc29e] 4279 0000 63c6            clr.w     $000063C6
[00fdc2a4] fc21                      dc.w      $FC21 ; movem.l (a7)+,d7/a4-a5
#endif

	xdef xfdc2a6
xfdc2a6: ds.b 0
#if 0
[00fdc2a6] 4e56 0000                 link      a6,#0
[00fdc2aa] 48e7 031c                 movem.l   d6-d7/a3-a5,-(a7)
[00fdc2ae] 2679 0000 a788            movea.l   _thedesk,a3
[00fdc2b4] 0c6b 0004 034c            cmpi.w    #$0004,844(a3)
[00fdc2ba] 6606                      bne.s     $00FDC2C2
[00fdc2bc] 4280                      clr.l     d0
[00fdc2be] 6000 00b4                 bra       $00FDC374
[00fdc2c2] 3039 0000 63c6            move.w    $000063C6,d0
[00fdc2c8] e740                      asl.w     #3,d0
[00fdc2ca] 48c0                      ext.l     d0
[00fdc2cc] 2840                      movea.l   d0,a4
[00fdc2ce] d9fc 0000 7098            adda.l    #$00007098,a4
[00fdc2d4] 2f2c 0004                 move.l    4(a4),-(a7)
[00fdc2d8] 2f14                      move.l    (a4),-(a7)
[00fdc2da] f694                      dc.w      $F694
[00fdc2dc] 508f                      addq.l    #8,a7
[00fdc2de] 3e00                      move.w    d0,d7
[00fdc2e0] 4a47                      tst.w     d7
[00fdc2e2] 6700 008e                 beq       $00FDC372
[00fdc2e6] 526b 034c                 addq.w    #1,844(a3)
[00fdc2ea] 5279 0000 63c6            addq.w    #1,$000063C6
[00fdc2f0] 3007                      move.w    d7,d0
[00fdc2f2] 5540                      subq.w    #2,d0
[00fdc2f4] c1fc 00ee                 muls.w    #$00EE,d0
[00fdc2f8] 2a40                      movea.l   d0,a5
[00fdc2fa] dbf9 0000 a7ba            adda.l    $0000A7BA,a5
[00fdc300] 426d 0004                 clr.w     4(a5)
[00fdc304] 3b6e 0008 0008            move.w    8(a6),8(a5)
[00fdc30a] 3b47 000a                 move.w    d7,10(a5)
[00fdc30e] 426d 000c                 clr.w     12(a5)
[00fdc312] 426d 000e                 clr.w     14(a5)
[00fdc316] 302c 0004                 move.w    4(a4),d0
[00fdc31a] 48c0                      ext.l     d0
[00fdc31c] 81eb 300e                 divs.w    12302(a3),d0
[00fdc320] 3b40 0010                 move.w    d0,16(a5)
[00fdc324] 302c 0006                 move.w    6(a4),d0
[00fdc328] 48c0                      ext.l     d0
[00fdc32a] 81eb 3010                 divs.w    12304(a3),d0
[00fdc32e] 3b40 0012                 move.w    d0,18(a5)
[00fdc332] 426d 0014                 clr.w     20(a5)
[00fdc336] 426d 0016                 clr.w     22(a5)
[00fdc33a] 2f2b 343e                 move.l    13374(a3),-(a7)
[00fdc33e] 2f2b 343a                 move.l    13370(a3),-(a7)
[00fdc342] 3f3c ffff                 move.w    #$FFFF,-(a7)
[00fdc346] f698                      dc.w      $F698 ; wind_create
[00fdc348] defc 000a                 adda.w    #10,a7
[00fdc34c] 3b40 0006                 move.w    d0,6(a5)
[00fdc350] 2f2c 0004                 move.l    4(a4),-(a7)
[00fdc354] 2f14                      move.l    (a4),-(a7)
[00fdc356] 486d 00e6                 pea.l     230(a5)
[00fdc35a] f298                      dc.w      $F298 ; r_set
[00fdc35c] defc 000c                 adda.w    #12,a7
[00fdc360] 0c6d ffff 0006            cmpi.w    #$FFFF,6(a5)
[00fdc366] 6706                      beq.s     $00FDC36E
[00fdc368] 200d                      move.l    a5,d0
[00fdc36a] 6008                      bra.s     $00FDC374
[00fdc36c] 6004                      bra.s     $00FDC372
[00fdc36e] 2e8d                      move.l    a5,(a7)
[00fdc370] f5a8                      dc.w      $F5A8
[00fdc372] 4280                      clr.l     d0
[00fdc374] fe21                      dc.w      $FE21 ; movem.l (a7)+,d7/a3-a5
#endif

	xdef xfdc376
xfdc376: ds.b 0
#if 0
[00fdc376] 4e56 0000                 link      a6,#0
[00fdc37a] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fdc37e] 2a6e 0008                 movea.l   8(a6),a5
[00fdc382] 0c6d ffff 0006            cmpi.w    #$FFFF,6(a5)
[00fdc388] 6706                      beq.s     $00FDC390
[00fdc38a] 3ead 0006                 move.w    6(a5),(a7)
[00fdc38e] f69c                      dc.w      $F69C ; wind_delete
[00fdc390] 2079 0000 a788            movea.l   _thedesk,a0
[00fdc396] 3028 034c                 move.w    844(a0),d0
[00fdc39a] 2279 0000 a788            movea.l   _thedesk,a1
[00fdc3a0] 5369 034c                 subq.w    #1,844(a1)
[00fdc3a4] 426d 0006                 clr.w     6(a5)
[00fdc3a8] 426d 0008                 clr.w     8(a5)
[00fdc3ac] 3ebc 0001                 move.w    #1,(a7)
[00fdc3b0] 3f2d 000a                 move.w    10(a5),-(a7)
[00fdc3b4] 2079 0000 a788            movea.l   _thedesk,a0
[00fdc3ba] 2f28 5e2c                 move.l    24108(a0),-(a7)
[00fdc3be] f6a0                      dc.w      $F6A0 ; objc_order
[00fdc3c0] 5c8f                      addq.l    #6,a7
[00fdc3c2] 4297                      clr.l     (a7)
[00fdc3c4] 42a7                      clr.l     -(a7)
[00fdc3c6] 3f2d 000a                 move.w    10(a5),-(a7)
[00fdc3ca] f388                      dc.w      $F388
[00fdc3cc] 5c8f                      addq.l    #6,a7
[00fdc3ce] 5379 0000 63c6            subq.w    #1,$000063C6
[00fdc3d4] 3ebc 0008                 move.w    #$0008,(a7)
[00fdc3d8] 486d 00e6                 pea.l     230(a5)
[00fdc3dc] 3039 0000 63c6            move.w    $000063C6,d0
[00fdc3e2] e740                      asl.w     #3,d0
[00fdc3e4] 48c0                      ext.l     d0
[00fdc3e6] d0bc 0000 7098            add.l     #$00007098,d0
[00fdc3ec] 2f00                      move.l    d0,-(a7)
[00fdc3ee] f268                      dc.w      $F268 ; LBCOPY
[00fdc3f0] 508f                      addq.l    #8,a7
[00fdc3f2] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfdc3f4
xfdc3f4: ds.b 0
#if 0
[00fdc3f4] 4e56 0000                 link      a6,#0
[00fdc3f8] 48e7 0300                 movem.l   d6-d7,-(a7)
[00fdc3fc] 4247                      clr.w     d7
[00fdc3fe] 6026                      bra.s     $00FDC426
[00fdc400] 2079 0000 a7ba            movea.l   $0000A7BA,a0
[00fdc406] 3207                      move.w    d7,d1
[00fdc408] c3fc 00ee                 muls.w    #$00EE,d1
[00fdc40c] 3030 1806                 move.w    6(a0,d1.l),d0
[00fdc410] b06e 0008                 cmp.w     8(a6),d0
[00fdc414] 660e                      bne.s     $00FDC424
[00fdc416] 3007                      move.w    d7,d0
[00fdc418] c1fc 00ee                 muls.w    #$00EE,d0
[00fdc41c] d0b9 0000 a7ba            add.l     $0000A7BA,d0
[00fdc422] 600a                      bra.s     $00FDC42E
[00fdc424] 5247                      addq.w    #1,d7
[00fdc426] be7c 0004                 cmp.w     #$0004,d7
[00fdc42a] 6dd4                      blt.s     $00FDC400
[00fdc42c] 4280                      clr.l     d0
[00fdc42e] f021                      dc.w      $F021 ; movem.l (a7)+,d7
#endif

	xdef xfdc430
xfdc430: ds.b 0
#if 0
[00fdc430] 4e56 fffe                 link      a6,#$FFFE
[00fdc434] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fdc438] 2a6e 0008                 movea.l   8(a6),a5
[00fdc43c] 3ebc ffff                 move.w    #$FFFF,(a7)
[00fdc440] 3f2d 000a                 move.w    10(a5),-(a7)
[00fdc444] 2079 0000 a788            movea.l   _thedesk,a0
[00fdc44a] 2f28 5e2c                 move.l    24108(a0),-(a7)
[00fdc44e] f6a0                      dc.w      $F6A0 ; objc_order
[00fdc450] 5c8f                      addq.l    #6,a7
[00fdc452] 486d 001c                 pea.l     28(a5)
[00fdc456] 2079 0000 a788            movea.l   _thedesk,a0
[00fdc45c] 2f28 35a8                 move.l    13736(a0),-(a7)
[00fdc460] f39c                      dc.w      $F39C ; streq
[00fdc462] 508f                      addq.l    #8,a7
[00fdc464] 4a40                      tst.w     d0
[00fdc466] 6610                      bne.s     $00FDC478
[00fdc468] 486d 0020                 pea.l     32(a5)
[00fdc46c] 102d 001d                 move.b    29(a5),d0
[00fdc470] 4880                      ext.w     d0
[00fdc472] 3f00                      move.w    d0,-(a7)
[00fdc474] f5a0                      dc.w      $F5A0
[00fdc476] 5c8f                      addq.l    #6,a7
[00fdc478] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfdc47a
xfdc47a: ds.b 0
#if 0
[00fdc47a] 4e56 0000                 link      a6,#0
[00fdc47e] 48e7 030c                 movem.l   d6-d7/a4-a5,-(a7)
[00fdc482] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdc488] 3e2d 5e8c                 move.w    24204(a5),d7
[00fdc48c] 204d                      movea.l   a5,a0
[00fdc48e] 3207                      move.w    d7,d1
[00fdc490] c3fc 0018                 muls.w    #24,d1
[00fdc494] d1c1                      adda.l    d1,a0
[00fdc496] 4a68 5e9c                 tst.w     24220(a0)
[00fdc49a] 6746                      beq.s     $00FDC4E2
[00fdc49c] 204d                      movea.l   a5,a0
[00fdc49e] 3207                      move.w    d7,d1
[00fdc4a0] c3fc 0018                 muls.w    #24,d1
[00fdc4a4] d1c1                      adda.l    d1,a0
[00fdc4a6] 4a68 5e9e                 tst.w     24222(a0)
[00fdc4aa] 6736                      beq.s     $00FDC4E2
[00fdc4ac] 3007                      move.w    d7,d0
[00fdc4ae] 5540                      subq.w    #2,d0
[00fdc4b0] c1fc 00ee                 muls.w    #$00EE,d0
[00fdc4b4] 2840                      movea.l   d0,a4
[00fdc4b6] d9f9 0000 a7ba            adda.l    $0000A7BA,a4
[00fdc4bc] 486c 001c                 pea.l     28(a4)
[00fdc4c0] 2f2d 35a8                 move.l    13736(a5),-(a7)
[00fdc4c4] f39c                      dc.w      $F39C ; streq
[00fdc4c6] 508f                      addq.l    #8,a7
[00fdc4c8] 4a40                      tst.w     d0
[00fdc4ca] 6610                      bne.s     $00FDC4DC
[00fdc4cc] 486c 0020                 pea.l     32(a4)
[00fdc4d0] 102c 001d                 move.b    29(a4),d0
[00fdc4d4] 4880                      ext.w     d0
[00fdc4d6] 3f00                      move.w    d0,-(a7)
[00fdc4d8] f5a0                      dc.w      $F5A0
[00fdc4da] 5c8f                      addq.l    #6,a7
[00fdc4dc] 200c                      move.l    a4,d0
[00fdc4de] 6004                      bra.s     $00FDC4E4
[00fdc4e0] 6002                      bra.s     $00FDC4E4
[00fdc4e2] 4280                      clr.l     d0
[00fdc4e4] fc21                      dc.w      $FC21 ; movem.l (a7)+,d7/a4-a5
#endif

	xdef xfdc4e6
xfdc4e6: ds.b 0
#if 0
[00fdc4e6] 4e56 0000                 link      a6,#0
[00fdc4ea] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fdc4ee] 3e2e 0008                 move.w    8(a6),d7
[00fdc4f2] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdc4f8] 3c2d 5e8a                 move.w    24202(a5),d6
[00fdc4fc] 600e                      bra.s     $00FDC50C
[00fdc4fe] 204d                      movea.l   a5,a0
[00fdc500] 3206                      move.w    d6,d1
[00fdc502] c3fc 0018                 muls.w    #24,d1
[00fdc506] d1c1                      adda.l    d1,a0
[00fdc508] 3c28 5e88                 move.w    24200(a0),d6
[00fdc50c] 3007                      move.w    d7,d0
[00fdc50e] 5347                      subq.w    #1,d7
[00fdc510] 4a40                      tst.w     d0
[00fdc512] 66ea                      bne.s     $00FDC4FE
[00fdc514] 3006                      move.w    d6,d0
[00fdc516] 5540                      subq.w    #2,d0
[00fdc518] c1fc 00ee                 muls.w    #$00EE,d0
[00fdc51c] d0b9 0000 a7ba            add.l     $0000A7BA,d0
[00fdc522] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfdc524
xfdc524: ds.b 0
#if 0
[00fdc524] 4e56 0000                 link      a6,#0
[00fdc528] 48e7 0f1c                 movem.l   d4-d7/a3-a5,-(a7)
[00fdc52c] 2a6e 0008                 movea.l   8(a6),a5
[00fdc530] 2679 0000 a788            movea.l   _thedesk,a3
[00fdc536] 4246                      clr.w     d6
[00fdc538] 206d 0018                 movea.l   24(a5),a0
[00fdc53c] 2868 0082                 movea.l   130(a0),a4
[00fdc540] 600a                      bra.s     $00FDC54C
[00fdc542] 397c ffff 0020            move.w    #$FFFF,32(a4)
[00fdc548] 5246                      addq.w    #1,d6
[00fdc54a] 2854                      movea.l   (a4),a4
[00fdc54c] 200c                      move.l    a4,d0
[00fdc54e] 66f2                      bne.s     $00FDC542
[00fdc550] bc6b 3012                 cmp.w     12306(a3),d6
[00fdc554] 6c04                      bge.s     $00FDC55A
[00fdc556] 3006                      move.w    d6,d0
[00fdc558] 6004                      bra.s     $00FDC55E
[00fdc55a] 302b 3012                 move.w    12306(a3),d0
[00fdc55e] 3b40 0014                 move.w    d0,20(a5)
[00fdc562] 3006                      move.w    d6,d0
[00fdc564] 48c0                      ext.l     d0
[00fdc566] 81eb 3012                 divs.w    12306(a3),d0
[00fdc56a] 3b40 0016                 move.w    d0,22(a5)
[00fdc56e] 3006                      move.w    d6,d0
[00fdc570] 48c0                      ext.l     d0
[00fdc572] 81eb 3012                 divs.w    12306(a3),d0
[00fdc576] 4840                      swap      d0
[00fdc578] 4a40                      tst.w     d0
[00fdc57a] 6704                      beq.s     $00FDC580
[00fdc57c] 526d 0016                 addq.w    #1,22(a5)
[00fdc580] 4a6d 0016                 tst.w     22(a5)
[00fdc584] 6604                      bne.s     $00FDC58A
[00fdc586] 526d 0016                 addq.w    #1,22(a5)
[00fdc58a] 4a6d 0014                 tst.w     20(a5)
[00fdc58e] 6604                      bne.s     $00FDC594
[00fdc590] 526d 0014                 addq.w    #1,20(a5)
[00fdc594] 4a6e 000c                 tst.w     12(a6)
[00fdc598] 6604                      bne.s     $00FDC59E
[00fdc59a] 526e 000c                 addq.w    #1,12(a6)
[00fdc59e] 3ead 0014                 move.w    20(a5),(a7)
[00fdc5a2] 3f2e 000c                 move.w    12(a6),-(a7)
[00fdc5a6] f330                      dc.w      $F330 ; min
[00fdc5a8] 548f                      addq.l    #2,a7
[00fdc5aa] 3b40 0010                 move.w    d0,16(a5)
[00fdc5ae] 3a00                      move.w    d0,d5
[00fdc5b0] 6004                      bra.s     $00FDC5B6
[00fdc5b2] 536d 000c                 subq.w    #1,12(a5)
[00fdc5b6] 302d 0014                 move.w    20(a5),d0
[00fdc5ba] 906d 000c                 sub.w     12(a5),d0
[00fdc5be] ba40                      cmp.w     d0,d5
[00fdc5c0] 6ef0                      bgt.s     $00FDC5B2
[00fdc5c2] 4a6e 000e                 tst.w     14(a6)
[00fdc5c6] 6604                      bne.s     $00FDC5CC
[00fdc5c8] 526e 000e                 addq.w    #1,14(a6)
[00fdc5cc] 3ead 0016                 move.w    22(a5),(a7)
[00fdc5d0] 3f2e 000e                 move.w    14(a6),-(a7)
[00fdc5d4] f330                      dc.w      $F330 ; min
[00fdc5d6] 548f                      addq.l    #2,a7
[00fdc5d8] 3b40 0012                 move.w    d0,18(a5)
[00fdc5dc] 3a00                      move.w    d0,d5
[00fdc5de] 6004                      bra.s     $00FDC5E4
[00fdc5e0] 536d 000e                 subq.w    #1,14(a5)
[00fdc5e4] 302d 0016                 move.w    22(a5),d0
[00fdc5e8] 906d 000e                 sub.w     14(a5),d0
[00fdc5ec] ba40                      cmp.w     d0,d5
[00fdc5ee] 6ef0                      bgt.s     $00FDC5E0
[00fdc5f0] 3e2d 000e                 move.w    14(a5),d7
[00fdc5f4] cfeb 3012                 muls.w    12306(a3),d7
[00fdc5f8] de6d 000c                 add.w     12(a5),d7
[00fdc5fc] 206d 0018                 movea.l   24(a5),a0
[00fdc600] 2868 0082                 movea.l   130(a0),a4
[00fdc604] 6002                      bra.s     $00FDC608
[00fdc606] 2854                      movea.l   (a4),a4
[00fdc608] 3007                      move.w    d7,d0
[00fdc60a] 5347                      subq.w    #1,d7
[00fdc60c] 4a40                      tst.w     d0
[00fdc60e] 6704                      beq.s     $00FDC614
[00fdc610] 200c                      move.l    a4,d0
[00fdc612] 66f2                      bne.s     $00FDC606
[00fdc614] 206e 0010                 movea.l   16(a6),a0
[00fdc618] 208c                      move.l    a4,(a0)
[00fdc61a] fe39                      dc.w      $FE39 ; movem.l (a7)+,d5-d7/a3-a5
#endif

	xdef xfdc61c
xfdc61c: ds.b 0
#if 0
[00fdc61c] 4e56 0000                 link      a6,#0
[00fdc620] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fdc624] 2a6e 0008                 movea.l   8(a6),a5
[00fdc628] 486d 0026                 pea.l     38(a5)
[00fdc62c] 486d 0012                 pea.l     18(a5)
[00fdc630] 3f3c ffff                 move.w    #$FFFF,-(a7)
[00fdc634] 082d 0004 0009            btst      #4,9(a5)
[00fdc63a] 6706                      beq.s     $00FDC642
[00fdc63c] 3f3c 0001                 move.w    #1,-(a7)
[00fdc640] 6002                      bra.s     $00FDC644
[00fdc642] 4267                      clr.w     -(a7)
[00fdc644] 4267                      clr.w     -(a7)
[00fdc646] f4dc                      dc.w      $F4DC
[00fdc648] defc 000e                 adda.w    #$000E,a7
[00fdc64c] 2b40 0022                 move.l    d0,34(a5)
[00fdc650] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfdc652
xfdc652: ds.b 0
#if 0
[00fdc652] 4e56 ffea                 link      a6,#$FFEA
[00fdc656] 48e7 3f1c                 movem.l   d2-d7/a3-a5,-(a7)
[00fdc65a] 2a6e 0008                 movea.l   8(a6),a5
[00fdc65e] 2679 0000 a788            movea.l   _thedesk,a3
[00fdc664] 2f2e 0010                 move.l    16(a6),-(a7)
[00fdc668] 2f2e 000c                 move.l    12(a6),-(a7)
[00fdc66c] 3f2d 000a                 move.w    10(a5),-(a7)
[00fdc670] f388                      dc.w      $F388
[00fdc672] defc 000a                 adda.w    #10,a7
[00fdc676] 486e fffc                 pea.l     -4(a6)
[00fdc67a] 302e 0012                 move.w    18(a6),d0
[00fdc67e] 48c0                      ext.l     d0
[00fdc680] 81eb 3010                 divs.w    12304(a3),d0
[00fdc684] 3f00                      move.w    d0,-(a7)
[00fdc686] 302e 0010                 move.w    16(a6),d0
[00fdc68a] 48c0                      ext.l     d0
[00fdc68c] 81eb 300e                 divs.w    12302(a3),d0
[00fdc690] 3f00                      move.w    d0,-(a7)
[00fdc692] 2f0d                      move.l    a5,-(a7)
[00fdc694] f6a4                      dc.w      $F6A4
[00fdc696] defc 000c                 adda.w    #12,a7
[00fdc69a] 286e fffc                 movea.l   -4(a6),a4
[00fdc69e] 3ead 0014                 move.w    20(a5),(a7)
[00fdc6a2] 302d 000c                 move.w    12(a5),d0
[00fdc6a6] 9157                      sub.w     d0,(a7)
[00fdc6a8] 3f2d 0010                 move.w    16(a5),-(a7)
[00fdc6ac] 5257                      addq.w    #1,(a7)
[00fdc6ae] f330                      dc.w      $F330 ; min
[00fdc6b0] 548f                      addq.l    #2,a7
[00fdc6b2] 3d40 fffa                 move.w    d0,-6(a6)
[00fdc6b6] 3ead 0016                 move.w    22(a5),(a7)
[00fdc6ba] 302d 000e                 move.w    14(a5),d0
[00fdc6be] 9157                      sub.w     d0,(a7)
[00fdc6c0] 3f2d 0012                 move.w    18(a5),-(a7)
[00fdc6c4] 5257                      addq.w    #1,(a7)
[00fdc6c6] f330                      dc.w      $F330 ; min
[00fdc6c8] 548f                      addq.l    #2,a7
[00fdc6ca] 3d40 fff8                 move.w    d0,-8(a6)
[00fdc6ce] 4243                      clr.w     d3
[00fdc6d0] 3803                      move.w    d3,d4
[00fdc6d2] 6000 0196                 bra       $00FDC86A
[00fdc6d6] 3004                      move.w    d4,d0
[00fdc6d8] c1eb 3010                 muls.w    12304(a3),d0
[00fdc6dc] 3d40 ffee                 move.w    d0,-18(a6)
[00fdc6e0] 3003                      move.w    d3,d0
[00fdc6e2] c1eb 300e                 muls.w    12302(a3),d0
[00fdc6e6] 3d40 fff0                 move.w    d0,-16(a6)
[00fdc6ea] 2f2b 3006                 move.l    12294(a3),-(a7)
[00fdc6ee] 3f2b 300c                 move.w    12300(a3),-(a7)
[00fdc6f2] 302e ffee                 move.w    -18(a6),d0
[00fdc6f6] d157                      add.w     d0,(a7)
[00fdc6f8] 3f2b 300a                 move.w    12298(a3),-(a7)
[00fdc6fc] 302e fff0                 move.w    -16(a6),d0
[00fdc700] d157                      add.w     d0,(a7)
[00fdc702] 3f2d 000a                 move.w    10(a5),-(a7)
[00fdc706] f38c                      dc.w      $F38C
[00fdc708] defc 000a                 adda.w    #10,a7
[00fdc70c] 3e00                      move.w    d0,d7
[00fdc70e] 4a47                      tst.w     d7
[00fdc710] 6700 0274                 beq       $00FDC986
[00fdc714] 3947 0020                 move.w    d7,32(a4)
[00fdc718] 204b                      movea.l   a3,a0
[00fdc71a] 3207                      move.w    d7,d1
[00fdc71c] c3fc 0018                 muls.w    #24,d1
[00fdc720] d1c1                      adda.l    d1,a0
[00fdc722] 317c 0040 5e92            move.w    #$0040,24210(a0)
[00fdc728] 204b                      movea.l   a3,a0
[00fdc72a] 3207                      move.w    d7,d1
[00fdc72c] c3fc 0018                 muls.w    #24,d1
[00fdc730] d1c1                      adda.l    d1,a0
[00fdc732] 4268 5e90                 clr.w     24208(a0)
[00fdc736] 302b 3004                 move.w    12292(a3),d0
[00fdc73a] 6000 00fa                 bra       $00FDC836
[00fdc73e] 204b                      movea.l   a3,a0
[00fdc740] 3207                      move.w    d7,d1
[00fdc742] c3fc 0018                 muls.w    #24,d1
[00fdc746] d1c1                      adda.l    d1,a0
[00fdc748] 317c 0018 5e8e            move.w    #24,24206(a0)
[00fdc74e] 200b                      move.l    a3,d0
[00fdc750] 3207                      move.w    d7,d1
[00fdc752] e741                      asl.w     #3,d1
[00fdc754] 48c1                      ext.l     d1
[00fdc756] d081                      add.l     d1,d0
[00fdc758] d0bc 0000 27de            add.l     #$000027DE,d0
[00fdc75e] 224b                      movea.l   a3,a1
[00fdc760] 3407                      move.w    d7,d2
[00fdc762] c5fc 0018                 muls.w    #24,d2
[00fdc766] d3c2                      adda.l    d2,a1
[00fdc768] 2340 5e94                 move.l    d0,24212(a1)
[00fdc76c] 204b                      movea.l   a3,a0
[00fdc76e] 3207                      move.w    d7,d1
[00fdc770] e741                      asl.w     #3,d1
[00fdc772] 48c1                      ext.l     d1
[00fdc774] d1c1                      adda.l    d1,a0
[00fdc776] 2179 0000 666a 27de       move.l    $0000666A,10206(a0)
[00fdc77e] 224b                      movea.l   a3,a1
[00fdc780] 3407                      move.w    d7,d2
[00fdc782] e742                      asl.w     #3,d2
[00fdc784] 48c2                      ext.l     d2
[00fdc786] d3c2                      adda.l    d2,a1
[00fdc788] 41ec 0009                 lea.l     9(a4),a0
[00fdc78c] 2348 27e2                 move.l    a0,10210(a1)
[00fdc790] 2e8c                      move.l    a4,(a7)
[00fdc792] f6a8                      dc.w      $F6A8
[00fdc794] 6000 00ae                 bra       $00FDC844
[00fdc798] 204b                      movea.l   a3,a0
[00fdc79a] 3207                      move.w    d7,d1
[00fdc79c] c3fc 0018                 muls.w    #24,d1
[00fdc7a0] d1c1                      adda.l    d1,a0
[00fdc7a2] 317c 001f 5e8e            move.w    #$001F,24206(a0)
[00fdc7a8] 2e8c                      move.l    a4,(a7)
[00fdc7aa] f6a8                      dc.w      $F6A8
[00fdc7ac] 4a6c 0026                 tst.w     38(a4)
[00fdc7b0] 670a                      beq.s     $00FDC7BC
[00fdc7b2] 206c 0022                 movea.l   34(a4),a0
[00fdc7b6] 3028 0012                 move.w    18(a0),d0
[00fdc7ba] 6008                      bra.s     $00FDC7C4
[00fdc7bc] 206c 0022                 movea.l   34(a4),a0
[00fdc7c0] 3028 0014                 move.w    20(a0),d0
[00fdc7c4] 3d40 fff6                 move.w    d0,-10(a6)
[00fdc7c8] 204b                      movea.l   a3,a0
[00fdc7ca] 3247                      movea.w   d7,a1
[00fdc7cc] d3c9                      adda.l    a1,a1
[00fdc7ce] d1c9                      adda.l    a1,a0
[00fdc7d0] 316e fff6 25d6            move.w    -10(a6),9686(a0)
[00fdc7d6] 200b                      move.l    a3,d0
[00fdc7d8] 3207                      move.w    d7,d1
[00fdc7da] c3fc 0022                 muls.w    #$0022,d1
[00fdc7de] d081                      add.l     d1,d0
[00fdc7e0] d0bc 0000 034e            add.l     #$0000034E,d0
[00fdc7e6] 224b                      movea.l   a3,a1
[00fdc7e8] 3407                      move.w    d7,d2
[00fdc7ea] c5fc 0018                 muls.w    #24,d2
[00fdc7ee] d3c2                      adda.l    d2,a1
[00fdc7f0] 2340 5e94                 move.l    d0,24212(a1)
[00fdc7f4] 200b                      move.l    a3,d0
[00fdc7f6] 3207                      move.w    d7,d1
[00fdc7f8] c3fc 0022                 muls.w    #$0022,d1
[00fdc7fc] d081                      add.l     d1,d0
[00fdc7fe] 2e80                      move.l    d0,(a7)
[00fdc800] 0697 0000 034e            addi.l    #$0000034E,(a7)
[00fdc806] 200b                      move.l    a3,d0
[00fdc808] 322e fff6                 move.w    -10(a6),d1
[00fdc80c] c3fc 0022                 muls.w    #$0022,d1
[00fdc810] d081                      add.l     d1,d0
[00fdc812] 2f00                      move.l    d0,-(a7)
[00fdc814] 0697 0000 5b1a            addi.l    #$00005B1A,(a7)
[00fdc81a] 3f3c 0022                 move.w    #$0022,-(a7)
[00fdc81e] f390                      dc.w      $F390 ; movs
[00fdc820] 5c8f                      addq.l    #6,a7
[00fdc822] 224b                      movea.l   a3,a1
[00fdc824] 3407                      move.w    d7,d2
[00fdc826] c5fc 0022                 muls.w    #$0022,d2
[00fdc82a] d3c2                      adda.l    d2,a1
[00fdc82c] 41ec 0012                 lea.l     18(a4),a0
[00fdc830] 2348 0356                 move.l    a0,854(a1)
[00fdc834] 600e                      bra.s     $00FDC844
[00fdc836] 4a40                      tst.w     d0
[00fdc838] 6700 ff5e                 beq       $00FDC798
[00fdc83c] b07c 0001                 cmp.w     #1,d0
[00fdc840] 6700 fefc                 beq       $00FDC73E
[00fdc844] 2854                      movea.l   (a4),a4
[00fdc846] 5243                      addq.w    #1,d3
[00fdc848] b66e fffa                 cmp.w     -6(a6),d3
[00fdc84c] 661c                      bne.s     $00FDC86A
[00fdc84e] 5244                      addq.w    #1,d4
[00fdc850] 4243                      clr.w     d3
[00fdc852] 3c2d 0014                 move.w    20(a5),d6
[00fdc856] 9c6e fffa                 sub.w     -6(a6),d6
[00fdc85a] 6002                      bra.s     $00FDC85E
[00fdc85c] 2854                      movea.l   (a4),a4
[00fdc85e] 3006                      move.w    d6,d0
[00fdc860] 5346                      subq.w    #1,d6
[00fdc862] 4a40                      tst.w     d0
[00fdc864] 6704                      beq.s     $00FDC86A
[00fdc866] 200c                      move.l    a4,d0
[00fdc868] 66f2                      bne.s     $00FDC85C
[00fdc86a] b66e fffa                 cmp.w     -6(a6),d3
[00fdc86e] 6c0c                      bge.s     $00FDC87C
[00fdc870] b86e fff8                 cmp.w     -8(a6),d4
[00fdc874] 6c06                      bge.s     $00FDC87C
[00fdc876] 200c                      move.l    a4,d0
[00fdc878] 6600 fe5c                 bne       $00FDC6D6
[00fdc87c] 3d6d 0006 ffec            move.w    6(a5),-20(a6)
[00fdc882] 3ead 0014                 move.w    20(a5),(a7)
[00fdc886] 3f3c 03e8                 move.w    #$03E8,-(a7)
[00fdc88a] 3f2d 0010                 move.w    16(a5),-(a7)
[00fdc88e] f234                      dc.w      $F234 ; mul_div
[00fdc890] 588f                      addq.l    #4,a7
[00fdc892] 3d40 ffea                 move.w    d0,-22(a6)
[00fdc896] 4257                      clr.w     (a7)
[00fdc898] 42a7                      clr.l     -(a7)
[00fdc89a] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fdc89e] 3f3c 000f                 move.w    #$000F,-(a7)
[00fdc8a2] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fdc8a6] f4b8                      dc.w      $F4B8 ; wind_set
[00fdc8a8] defc 000a                 adda.w    #10,a7
[00fdc8ac] 486e fff4                 pea.l     -12(a6)
[00fdc8b0] 486e fff4                 pea.l     -12(a6)
[00fdc8b4] 486e fff4                 pea.l     -12(a6)
[00fdc8b8] 486e ffea                 pea.l     -22(a6)
[00fdc8bc] 3f3c 000f                 move.w    #$000F,-(a7)
[00fdc8c0] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fdc8c4] f5c8                      dc.w      $F5C8 ; wind_get
[00fdc8c6] defc 0014                 adda.w    #$0014,a7
[00fdc8ca] 302d 0014                 move.w    20(a5),d0
[00fdc8ce] b06d 0010                 cmp.w     16(a5),d0
[00fdc8d2] 6f1a                      ble.s     $00FDC8EE
[00fdc8d4] 3ead 0014                 move.w    20(a5),(a7)
[00fdc8d8] 302d 0010                 move.w    16(a5),d0
[00fdc8dc] 9157                      sub.w     d0,(a7)
[00fdc8de] 3f3c 03e8                 move.w    #$03E8,-(a7)
[00fdc8e2] 3f2d 000c                 move.w    12(a5),-(a7)
[00fdc8e6] f234                      dc.w      $F234 ; mul_div
[00fdc8e8] 588f                      addq.l    #4,a7
[00fdc8ea] 3a00                      move.w    d0,d5
[00fdc8ec] 6002                      bra.s     $00FDC8F0
[00fdc8ee] 4245                      clr.w     d5
[00fdc8f0] 4257                      clr.w     (a7)
[00fdc8f2] 42a7                      clr.l     -(a7)
[00fdc8f4] 3f05                      move.w    d5,-(a7)
[00fdc8f6] 3f3c 0008                 move.w    #$0008,-(a7)
[00fdc8fa] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fdc8fe] f4b8                      dc.w      $F4B8 ; wind_set
[00fdc900] defc 000a                 adda.w    #10,a7
[00fdc904] 3ead 0016                 move.w    22(a5),(a7)
[00fdc908] 3f3c 03e8                 move.w    #$03E8,-(a7)
[00fdc90c] 3f2d 0012                 move.w    18(a5),-(a7)
[00fdc910] f234                      dc.w      $F234 ; mul_div
[00fdc912] 588f                      addq.l    #4,a7
[00fdc914] 3d40 ffea                 move.w    d0,-22(a6)
[00fdc918] 4257                      clr.w     (a7)
[00fdc91a] 42a7                      clr.l     -(a7)
[00fdc91c] 3f2e ffea                 move.w    -22(a6),-(a7)
[00fdc920] 3f3c 0010                 move.w    #$0010,-(a7)
[00fdc924] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fdc928] f4b8                      dc.w      $F4B8 ; wind_set
[00fdc92a] defc 000a                 adda.w    #10,a7
[00fdc92e] 486e fff4                 pea.l     -12(a6)
[00fdc932] 486e fff4                 pea.l     -12(a6)
[00fdc936] 486e fff4                 pea.l     -12(a6)
[00fdc93a] 486e ffea                 pea.l     -22(a6)
[00fdc93e] 3f3c 0010                 move.w    #$0010,-(a7)
[00fdc942] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fdc946] f5c8                      dc.w      $F5C8 ; wind_get
[00fdc948] defc 0014                 adda.w    #$0014,a7
[00fdc94c] 302d 0016                 move.w    22(a5),d0
[00fdc950] b06d 0012                 cmp.w     18(a5),d0
[00fdc954] 6f1a                      ble.s     $00FDC970
[00fdc956] 3ead 0016                 move.w    22(a5),(a7)
[00fdc95a] 302d 0012                 move.w    18(a5),d0
[00fdc95e] 9157                      sub.w     d0,(a7)
[00fdc960] 3f3c 03e8                 move.w    #$03E8,-(a7)
[00fdc964] 3f2d 000e                 move.w    14(a5),-(a7)
[00fdc968] f234                      dc.w      $F234 ; mul_div
[00fdc96a] 588f                      addq.l    #4,a7
[00fdc96c] 3a00                      move.w    d0,d5
[00fdc96e] 6002                      bra.s     $00FDC972
[00fdc970] 4245                      clr.w     d5
[00fdc972] 4257                      clr.w     (a7)
[00fdc974] 42a7                      clr.l     -(a7)
[00fdc976] 3f05                      move.w    d5,-(a7)
[00fdc978] 3f3c 0009                 move.w    #$0009,-(a7)
[00fdc97c] 3f2e ffec                 move.w    -20(a6),-(a7)
[00fdc980] f4b8                      dc.w      $F4B8 ; wind_set
[00fdc982] defc 000a                 adda.w    #10,a7
[00fdc986] fe3f                      dc.w      $FE3F ; movem.l (a7)+,d3-d7/a3-a5
#endif

	xdef xfdc988
xfdc988: ds.b 0
#if 0
[00fdc988] 4e56 ffe2                 link      a6,#$FFE2
[00fdc98c] 48e7 1f0c                 movem.l   d3-d7/a4-a5,-(a7)
[00fdc990] 2a6e 0008                 movea.l   8(a6),a5
[00fdc994] 3e2e 000e                 move.w    14(a6),d7
[00fdc998] 49ee ffea                 lea.l     -22(a6),a4
[00fdc99c] 4a47                      tst.w     d7
[00fdc99e] 6f04                      ble.s     $00FDC9A4
[00fdc9a0] 3007                      move.w    d7,d0
[00fdc9a2] 6002                      bra.s     $00FDC9A6
[00fdc9a4] 4240                      clr.w     d0
[00fdc9a6] 3e00                      move.w    d0,d7
[00fdc9a8] 4a6e 000c                 tst.w     12(a6)
[00fdc9ac] 6724                      beq.s     $00FDC9D2
[00fdc9ae] 3e87                      move.w    d7,(a7)
[00fdc9b0] 3f2d 0016                 move.w    22(a5),-(a7)
[00fdc9b4] 302d 0012                 move.w    18(a5),d0
[00fdc9b8] 9157                      sub.w     d0,(a7)
[00fdc9ba] f330                      dc.w      $F330 ; min
[00fdc9bc] 548f                      addq.l    #2,a7
[00fdc9be] 3e00                      move.w    d0,d7
[00fdc9c0] 3d6d 0012 fffe            move.w    18(a5),-2(a6)
[00fdc9c6] 3c07                      move.w    d7,d6
[00fdc9c8] 9c6d 000e                 sub.w     14(a5),d6
[00fdc9cc] dd6d 000e                 add.w     d6,14(a5)
[00fdc9d0] 6022                      bra.s     $00FDC9F4
[00fdc9d2] 3e87                      move.w    d7,(a7)
[00fdc9d4] 3f2d 0014                 move.w    20(a5),-(a7)
[00fdc9d8] 302d 0010                 move.w    16(a5),d0
[00fdc9dc] 9157                      sub.w     d0,(a7)
[00fdc9de] f330                      dc.w      $F330 ; min
[00fdc9e0] 548f                      addq.l    #2,a7
[00fdc9e2] 3e00                      move.w    d0,d7
[00fdc9e4] 3d6d 0010 fffe            move.w    16(a5),-2(a6)
[00fdc9ea] 3c07                      move.w    d7,d6
[00fdc9ec] 9c6d 000c                 sub.w     12(a5),d6
[00fdc9f0] dd6d 000c                 add.w     d6,12(a5)
[00fdc9f4] 4a46                      tst.w     d6
[00fdc9f6] 6606                      bne.s     $00FDC9FE
[00fdc9f8] 4240                      clr.w     d0
[00fdc9fa] 6000 015e                 bra       $00FDCB5A
[00fdc9fe] 2e8c                      move.l    a4,(a7)
[00fdca00] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdca04] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdca08] f4bc                      dc.w      $F4BC
[00fdca0a] 588f                      addq.l    #4,a7
[00fdca0c] 2f2c 0004                 move.l    4(a4),-(a7)
[00fdca10] 2f14                      move.l    (a4),-(a7)
[00fdca12] 2f0d                      move.l    a5,-(a7)
[00fdca14] f564                      dc.w      $F564
[00fdca16] defc 000c                 adda.w    #12,a7
[00fdca1a] 486e ffe2                 pea.l     -30(a6)
[00fdca1e] 2f0c                      move.l    a4,-(a7)
[00fdca20] f250                      dc.w      $F250 ; rc_copy
[00fdca22] 508f                      addq.l    #8,a7
[00fdca24] 486e ffe2                 pea.l     -30(a6)
[00fdca28] 2f3c 0000 700e            move.l    #$0000700E,-(a7)
[00fdca2e] f2fc                      dc.w      $F2FC ; rc_intersect
[00fdca30] 508f                      addq.l    #8,a7
[00fdca32] 486e ffe2                 pea.l     -30(a6)
[00fdca36] 2f0c                      move.l    a4,-(a7)
[00fdca38] f580                      dc.w      $F580 ; rc_equal
[00fdca3a] 508f                      addq.l    #8,a7
[00fdca3c] 4a40                      tst.w     d0
[00fdca3e] 6700 010a                 beq       $00FDCB4A
[00fdca42] 4a46                      tst.w     d6
[00fdca44] 6d04                      blt.s     $00FDCA4A
[00fdca46] 4240                      clr.w     d0
[00fdca48] 6002                      bra.s     $00FDCA4C
[00fdca4a] 7001                      moveq.l   #1,d0
[00fdca4c] 3d40 fff4                 move.w    d0,-12(a6)
[00fdca50] 6706                      beq.s     $00FDCA58
[00fdca52] 3006                      move.w    d6,d0
[00fdca54] 4440                      neg.w     d0
[00fdca56] 3c00                      move.w    d0,d6
[00fdca58] bc6e fffe                 cmp.w     -2(a6),d6
[00fdca5c] 6c00 00ec                 bge       $00FDCB4A
[00fdca60] 4a6e 000c                 tst.w     12(a6)
[00fdca64] 672e                      beq.s     $00FDCA94
[00fdca66] 4240                      clr.w     d0
[00fdca68] 3d40 fffc                 move.w    d0,-4(a6)
[00fdca6c] 3a00                      move.w    d0,d5
[00fdca6e] 3806                      move.w    d6,d4
[00fdca70] 2079 0000 a788            movea.l   _thedesk,a0
[00fdca76] 3004                      move.w    d4,d0
[00fdca78] c1e8 3010                 muls.w    12304(a0),d0
[00fdca7c] 3800                      move.w    d0,d4
[00fdca7e] 426e fffa                 clr.w     -6(a6)
[00fdca82] 3d6c 0004 fff8            move.w    4(a4),-8(a6)
[00fdca88] 302c 0006                 move.w    6(a4),d0
[00fdca8c] 9044                      sub.w     d4,d0
[00fdca8e] 3d40 fff6                 move.w    d0,-10(a6)
[00fdca92] 602c                      bra.s     $00FDCAC0
[00fdca94] 3a06                      move.w    d6,d5
[00fdca96] 2079 0000 a788            movea.l   _thedesk,a0
[00fdca9c] 3005                      move.w    d5,d0
[00fdca9e] c1e8 300e                 muls.w    12302(a0),d0
[00fdcaa2] 3a00                      move.w    d0,d5
[00fdcaa4] 426e fffc                 clr.w     -4(a6)
[00fdcaa8] 4240                      clr.w     d0
[00fdcaaa] 3d40 fffa                 move.w    d0,-6(a6)
[00fdcaae] 3800                      move.w    d0,d4
[00fdcab0] 302c 0004                 move.w    4(a4),d0
[00fdcab4] 9045                      sub.w     d5,d0
[00fdcab6] 3d40 fff8                 move.w    d0,-8(a6)
[00fdcaba] 3d6c 0006 fff6            move.w    6(a4),-10(a6)
[00fdcac0] 4a6e fff4                 tst.w     -12(a6)
[00fdcac4] 671c                      beq.s     $00FDCAE2
[00fdcac6] 3d45 fff2                 move.w    d5,-14(a6)
[00fdcaca] 3a2e fffc                 move.w    -4(a6),d5
[00fdcace] 3d6e fff2 fffc            move.w    -14(a6),-4(a6)
[00fdcad4] 3d44 fff2                 move.w    d4,-14(a6)
[00fdcad8] 382e fffa                 move.w    -6(a6),d4
[00fdcadc] 3d6e fff2 fffa            move.w    -14(a6),-6(a6)
[00fdcae2] 2e8c                      move.l    a4,(a7)
[00fdcae4] f0c0                      dc.w      $F0C0 ; gsx_sclip
[00fdcae6] 3eae fff6                 move.w    -10(a6),(a7)
[00fdcaea] 3f2e fff8                 move.w    -8(a6),-(a7)
[00fdcaee] 3f2c 0002                 move.w    2(a4),-(a7)
[00fdcaf2] 302e fffa                 move.w    -6(a6),d0
[00fdcaf6] d157                      add.w     d0,(a7)
[00fdcaf8] 3f14                      move.w    (a4),-(a7)
[00fdcafa] 302e fffc                 move.w    -4(a6),d0
[00fdcafe] d157                      add.w     d0,(a7)
[00fdcb00] 3f04                      move.w    d4,-(a7)
[00fdcb02] 302c 0002                 move.w    2(a4),d0
[00fdcb06] d157                      add.w     d0,(a7)
[00fdcb08] 3f05                      move.w    d5,-(a7)
[00fdcb0a] 3014                      move.w    (a4),d0
[00fdcb0c] d157                      add.w     d0,(a7)
[00fdcb0e] 3f3c 0003                 move.w    #$0003,-(a7)
[00fdcb12] f6ac                      dc.w      $F6AC ; bb_screen
[00fdcb14] defc 000c                 adda.w    #12,a7
[00fdcb18] 4a6e 000c                 tst.w     12(a6)
[00fdcb1c] 6718                      beq.s     $00FDCB36
[00fdcb1e] 4a6e fff4                 tst.w     -12(a6)
[00fdcb22] 6608                      bne.s     $00FDCB2C
[00fdcb24] 302e fff6                 move.w    -10(a6),d0
[00fdcb28] d16c 0002                 add.w     d0,2(a4)
[00fdcb2c] 302e fff6                 move.w    -10(a6),d0
[00fdcb30] 916c 0006                 sub.w     d0,6(a4)
[00fdcb34] 6014                      bra.s     $00FDCB4A
[00fdcb36] 4a6e fff4                 tst.w     -12(a6)
[00fdcb3a] 6606                      bne.s     $00FDCB42
[00fdcb3c] 302e fff8                 move.w    -8(a6),d0
[00fdcb40] d154                      add.w     d0,(a4)
[00fdcb42] 302e fff8                 move.w    -8(a6),d0
[00fdcb46] 916c 0004                 sub.w     d0,4(a4)
[00fdcb4a] 2f2c 0004                 move.l    4(a4),-(a7)
[00fdcb4e] 2f14                      move.l    (a4),-(a7)
[00fdcb50] 3f2d 0006                 move.w    6(a5),-(a7)
[00fdcb54] f2c0                      dc.w      $F2C0
[00fdcb56] defc 000a                 adda.w    #10,a7
[00fdcb5a] fc3d                      dc.w      $FC3D ; movem.l (a7)+,d4-d7/a4-a5
#endif

	xdef xfdcb5c
xfdcb5c: ds.b 0
#if 0
[00fdcb5c] 4e56 fff0                 link      a6,#$FFF0
[00fdcb60] 48e7 0104                 movem.l   d7/a5,-(a7)
[00fdcb64] 3eae 0008                 move.w    8(a6),(a7)
[00fdcb68] f2ec                      dc.w      $F2EC
[00fdcb6a] 2a40                      movea.l   d0,a5
[00fdcb6c] 4a6e 000c                 tst.w     12(a6)
[00fdcb70] 6714                      beq.s     $00FDCB86
[00fdcb72] 3d6d 0016 fff8            move.w    22(a5),-8(a6)
[00fdcb78] 3d6d 0012 fff6            move.w    18(a5),-10(a6)
[00fdcb7e] 3d7c 0010 fff2            move.w    #$0010,-14(a6)
[00fdcb84] 6012                      bra.s     $00FDCB98
[00fdcb86] 3d6d 0014 fff8            move.w    20(a5),-8(a6)
[00fdcb8c] 3d6d 0010 fff6            move.w    16(a5),-10(a6)
[00fdcb92] 3d7c 000f fff2            move.w    #$000F,-14(a6)
[00fdcb98] 486e fff4                 pea.l     -12(a6)
[00fdcb9c] 486e fff4                 pea.l     -12(a6)
[00fdcba0] 486e fff4                 pea.l     -12(a6)
[00fdcba4] 486e fff0                 pea.l     -16(a6)
[00fdcba8] 3f2e fff2                 move.w    -14(a6),-(a7)
[00fdcbac] 3f2e 0008                 move.w    8(a6),-(a7)
[00fdcbb0] f5c8                      dc.w      $F5C8 ; wind_get
[00fdcbb2] defc 0014                 adda.w    #$0014,a7
[00fdcbb6] 3ebc 03e8                 move.w    #$03E8,(a7)
[00fdcbba] 3f2e fff8                 move.w    -8(a6),-(a7)
[00fdcbbe] 302e fff6                 move.w    -10(a6),d0
[00fdcbc2] 9157                      sub.w     d0,(a7)
[00fdcbc4] 3f2e 000a                 move.w    10(a6),-(a7)
[00fdcbc8] f234                      dc.w      $F234 ; mul_div
[00fdcbca] 588f                      addq.l    #4,a7
[00fdcbcc] 3d40 fffc                 move.w    d0,-4(a6)
[00fdcbd0] 3eae fffc                 move.w    -4(a6),(a7)
[00fdcbd4] 3f2e 000c                 move.w    12(a6),-(a7)
[00fdcbd8] 2f0d                      move.l    a5,-(a7)
[00fdcbda] f6b0                      dc.w      $F6B0
[00fdcbdc] 5c8f                      addq.l    #6,a7
[00fdcbde] f801                      dc.w      $F801 ; movem.l (a7)+,a5
#endif

	xdef xfdcbe0
xfdcbe0: ds.b 0
#if 0
[00fdcbe0] 4e56 0000                 link      a6,#0
[00fdcbe4] 48e7 0704                 movem.l   d5-d7/a5,-(a7)
[00fdcbe8] 3eae 0008                 move.w    8(a6),(a7)
[00fdcbec] f2ec                      dc.w      $F2EC
[00fdcbee] 2a40                      movea.l   d0,a5
[00fdcbf0] 7e01                      moveq.l   #1,d7
[00fdcbf2] 302e 000a                 move.w    10(a6),d0
[00fdcbf6] 6050                      bra.s     $00FDCC48
[00fdcbf8] 3c2d 000e                 move.w    14(a5),d6
[00fdcbfc] 9c6d 0012                 sub.w     18(a5),d6
[00fdcc00] 605a                      bra.s     $00FDCC5C
[00fdcc02] 3c2d 000e                 move.w    14(a5),d6
[00fdcc06] dc6d 0012                 add.w     18(a5),d6
[00fdcc0a] 6050                      bra.s     $00FDCC5C
[00fdcc0c] 3c2d 000e                 move.w    14(a5),d6
[00fdcc10] 5346                      subq.w    #1,d6
[00fdcc12] 6048                      bra.s     $00FDCC5C
[00fdcc14] 3c2d 000e                 move.w    14(a5),d6
[00fdcc18] 5246                      addq.w    #1,d6
[00fdcc1a] 6040                      bra.s     $00FDCC5C
[00fdcc1c] 3c2d 000c                 move.w    12(a5),d6
[00fdcc20] 9c6d 0010                 sub.w     16(a5),d6
[00fdcc24] 4247                      clr.w     d7
[00fdcc26] 6034                      bra.s     $00FDCC5C
[00fdcc28] 3c2d 000c                 move.w    12(a5),d6
[00fdcc2c] dc6d 0010                 add.w     16(a5),d6
[00fdcc30] 4247                      clr.w     d7
[00fdcc32] 6028                      bra.s     $00FDCC5C
[00fdcc34] 3c2d 000c                 move.w    12(a5),d6
[00fdcc38] 5346                      subq.w    #1,d6
[00fdcc3a] 4247                      clr.w     d7
[00fdcc3c] 601e                      bra.s     $00FDCC5C
[00fdcc3e] 3c2d 000c                 move.w    12(a5),d6
[00fdcc42] 5246                      addq.w    #1,d6
[00fdcc44] 4247                      clr.w     d7
[00fdcc46] 6014                      bra.s     $00FDCC5C
[00fdcc48] b07c 0007                 cmp.w     #$0007,d0
[00fdcc4c] 620e                      bhi.s     $00FDCC5C
[00fdcc4e] e540                      asl.w     #2,d0
[00fdcc50] 3040                      movea.w   d0,a0
[00fdcc52] d1fc 00fe b2e6            adda.l    #$00FEB2E6,a0
[00fdcc58] 2050                      movea.l   (a0),a0
[00fdcc5a] 4ed0                      jmp       (a0)
[00fdcc5c] 3e86                      move.w    d6,(a7)
[00fdcc5e] 3f07                      move.w    d7,-(a7)
[00fdcc60] 2f0d                      move.l    a5,-(a7)
[00fdcc62] f6b0                      dc.w      $F6B0
[00fdcc64] 5c8f                      addq.l    #6,a7
[00fdcc66] f831                      dc.w      $F831 ; movem.l (a7)+,d6-d7/a5
#endif

	xdef xfdcc68
xfdcc68: ds.b 0
#if 0
[00fdcc68] 4e56 fff8                 link      a6,#$FFF8
[00fdcc6c] 48e7 070c                 movem.l   d5-d7/a4-a5,-(a7)
[00fdcc70] 2a79 0000 a788            movea.l   _thedesk,a5
[00fdcc76] 4247                      clr.w     d7
[00fdcc78] 6042                      bra.s     $00FDCCBC
[00fdcc7a] 3007                      move.w    d7,d0
[00fdcc7c] c1fc 00ee                 muls.w    #$00EE,d0
[00fdcc80] d0b9 0000 a7ba            add.l     $0000A7BA,d0
[00fdcc86] 2040                      movea.l   d0,a0
[00fdcc88] 3c28 0006                 move.w    6(a0),d6
[00fdcc8c] 4a46                      tst.w     d6
[00fdcc8e] 672a                      beq.s     $00FDCCBA
[00fdcc90] 486e fff8                 pea.l     -8(a6)
[00fdcc94] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdcc98] 3f06                      move.w    d6,-(a7)
[00fdcc9a] f4bc                      dc.w      $F4BC
[00fdcc9c] 508f                      addq.l    #8,a7
[00fdcc9e] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fdcca2] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fdcca6] 3007                      move.w    d7,d0
[00fdcca8] c1fc 00ee                 muls.w    #$00EE,d0
[00fdccac] d0b9 0000 a7ba            add.l     $0000A7BA,d0
[00fdccb2] 2f00                      move.l    d0,-(a7)
[00fdccb4] f564                      dc.w      $F564
[00fdccb6] defc 000c                 adda.w    #12,a7
[00fdccba] 5247                      addq.w    #1,d7
[00fdccbc] be7c 0004                 cmp.w     #$0004,d7
[00fdccc0] 6db8                      blt.s     $00FDCC7A
[00fdccc2] 7e04                      moveq.l   #4,d7
[00fdccc4] 603a                      bra.s     $00FDCD00
[00fdccc6] 3e87                      move.w    d7,(a7)
[00fdccc8] f4a4                      dc.w      $F4A4
[00fdccca] 2840                      movea.l   d0,a4
[00fdcccc] 4a6c 0006                 tst.w     6(a4)
[00fdccd0] 672c                      beq.s     $00FDCCFE
[00fdccd2] 486e fff8                 pea.l     -8(a6)
[00fdccd6] 3f3c 0004                 move.w    #$0004,-(a7)
[00fdccda] 3f2c 0006                 move.w    6(a4),-(a7)
[00fdccde] f4bc                      dc.w      $F4BC
[00fdcce0] 508f                      addq.l    #8,a7
[00fdcce2] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fdcce6] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fdccea] 3f2c 0006                 move.w    6(a4),-(a7)
[00fdccee] 3f39 0000 6db4            move.w    _gl_apid,-(a7)
[00fdccf4] 3f3c 0014                 move.w    #$0014,-(a7)
[00fdccf8] f4c0                      dc.w      $F4C0 ; send_msg
[00fdccfa] defc 000e                 adda.w    #$000E,a7
[00fdccfe] 5347                      subq.w    #1,d7
[00fdcd00] 4a47                      tst.w     d7
[00fdcd02] 66c2                      bne.s     $00FDCCC6
[00fdcd04] fc31                      dc.w      $FC31 ; movem.l (a7)+,d6-d7/a4-a5
#endif

	xdef xfdcd06
xfdcd06: ds.b 0
#if 0
[00fdcd06] 4e56 0000                 link      a6,#0
[00fdcd0a] 48e7 0700                 movem.l   d5-d7,-(a7)
[00fdcd0e] 3e2e 000c                 move.w    12(a6),d7
[00fdcd12] 3c2e 000e                 move.w    14(a6),d6
[00fdcd16] 4a46                      tst.w     d6
[00fdcd18] 6612                      bne.s     $00FDCD2C
[00fdcd1a] 3007                      move.w    d7,d0
[00fdcd1c] c1fc 0018                 muls.w    #24,d0
[00fdcd20] d0ae 0008                 add.l     8(a6),d0
[00fdcd24] 2040                      movea.l   d0,a0
[00fdcd26] 3c28 0002                 move.w    2(a0),d6
[00fdcd2a] 600e                      bra.s     $00FDCD3A
[00fdcd2c] 3006                      move.w    d6,d0
[00fdcd2e] c1fc 0018                 muls.w    #24,d0
[00fdcd32] d0ae 0008                 add.l     8(a6),d0
[00fdcd36] 2040                      movea.l   d0,a0
[00fdcd38] 3c10                      move.w    (a0),d6
[00fdcd3a] 6026                      bra.s     $00FDCD62
[00fdcd3c] 3006                      move.w    d6,d0
[00fdcd3e] c1fc 0018                 muls.w    #24,d0
[00fdcd42] d0ae 0008                 add.l     8(a6),d0
[00fdcd46] 2040                      movea.l   d0,a0
[00fdcd48] 0828 0000 000b            btst      #0,11(a0)
[00fdcd4e] 6704                      beq.s     $00FDCD54
[00fdcd50] 3006                      move.w    d6,d0
[00fdcd52] 6014                      bra.s     $00FDCD68
[00fdcd54] 3006                      move.w    d6,d0
[00fdcd56] c1fc 0018                 muls.w    #24,d0
[00fdcd5a] d0ae 0008                 add.l     8(a6),d0
[00fdcd5e] 2040                      movea.l   d0,a0
[00fdcd60] 3c10                      move.w    (a0),d6
[00fdcd62] bc47                      cmp.w     d7,d6
[00fdcd64] 6ed6                      bgt.s     $00FDCD3C
[00fdcd66] 4240                      clr.w     d0
[00fdcd68] f031                      dc.w      $F031 ; movem.l (a7)+,d6-d7
#endif

	xdef xfdcd6a
xfdcd6a: ds.b 0
#if 0
[00fdcd6a] 4e56 fff4                 link      a6,#$FFF4
[00fdcd6e] 302e 0008                 move.w    8(a6),d0
[00fdcd72] c1fc 0018                 muls.w    #24,d0
[00fdcd76] d0b9 0000 a788            add.l     _thedesk,d0
[00fdcd7c] 2040                      movea.l   d0,a0
[00fdcd7e] 2d68 5e94 fffc            move.l    24212(a0),-4(a6)
[00fdcd84] 206e fffc                 movea.l   -4(a6),a0
[00fdcd88] 2d68 0008 fff8            move.l    8(a0),-8(a6)
[00fdcd8e] 202e fff8                 move.l    -8(a6),d0
[00fdcd92] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfdcd94
xfdcd94: ds.b 0
#if 0
[00fdcd94] 4e56 fffa                 link      a6,#$FFFA
[00fdcd98] 48e7 010c                 movem.l   d7/a4-a5,-(a7)
[00fdcd9c] 2a6e 0008                 movea.l   8(a6),a5
[00fdcda0] 2879 0000 a788            movea.l   _thedesk,a4
[00fdcda6] 206d 0018                 movea.l   24(a5),a0
[00fdcdaa] 2d68 0088 fffa            move.l    136(a0),-6(a6)
[00fdcdb0] 206d 0018                 movea.l   24(a5),a0
[00fdcdb4] 3d68 0086 fffe            move.w    134(a0),-2(a6)
[00fdcdba] 486c 3552                 pea.l     13650(a4)
[00fdcdbe] 4267                      clr.w     -(a7)
[00fdcdc0] 3f3c 0005                 move.w    #$0005,-(a7)
[00fdcdc4] f0e0                      dc.w      $F0E0 ; rsrc_gaddr
[00fdcdc6] 508f                      addq.l    #8,a7
[00fdcdc8] 2eac 3552                 move.l    13650(a4),(a7)
[00fdcdcc] 2f39 0000 a7b6            move.l    $0000A7B6,-(a7)
[00fdcdd2] f118                      dc.w      $F118 ; LSTCPY
[00fdcdd4] 588f                      addq.l    #4,a7
[00fdcdd6] 486e fffa                 pea.l     -6(a6)
[00fdcdda] 2f39 0000 a7b6            move.l    $0000A7B6,-(a7)
[00fdcde0] 486d 0095                 pea.l     149(a5)
[00fdcde4] f498                      dc.w      $F498 ; merge_str
[00fdcde6] defc 000c                 adda.w    #12,a7
[00fdcdea] fc01                      dc.w      $FC01 ; movem.l (a7)+,a4-a5
#endif

	xdef xfdcdec
xfdcdec: ds.b 0
#if 0
[00fdcdec] 4e56 0000                 link      a6,#0
[00fdcdf0] 48e7 011c                 movem.l   d7/a3-a5,-(a7)
[00fdcdf4] 2a6e 0008                 movea.l   8(a6),a5
[00fdcdf8] 286d 0018                 movea.l   24(a5),a4
[00fdcdfc] 508c                      addq.l    #8,a4
[00fdcdfe] 47ed 001c                 lea.l     28(a5),a3
[00fdce02] 16fc 0020                 move.b    #$20,(a3)+
[00fdce06] 6002                      bra.s     $00FDCE0A
[00fdce08] 16dc                      move.b    (a4)+,(a3)+
[00fdce0a] 4a14                      tst.b     (a4)
[00fdce0c] 6706                      beq.s     $00FDCE14
[00fdce0e] 0c14 002a                 cmpi.b    #$2A,(a4)
[00fdce12] 66f4                      bne.s     $00FDCE08
[00fdce14] 16fc 0020                 move.b    #$20,(a3)+
[00fdce18] 4213                      clr.b     (a3)
[00fdce1a] fe01                      dc.w      $FE01 ; movem.l (a7)+,a3-a5
#endif

	xdef xfdce1c
xfdce1c: ds.b 0
#if 0
[00fdce1c] 4e56 fffc                 link      a6,#-4
[00fdce20] 2eae 000c                 move.l    12(a6),(a7)
[00fdce24] 5c97                      addq.l    #6,(a7)
[00fdce26] 2f2e 000c                 move.l    12(a6),-(a7)
[00fdce2a] 5897                      addq.l    #4,(a7)
[00fdce2c] 2f2e 000c                 move.l    12(a6),-(a7)
[00fdce30] 5497                      addq.l    #2,(a7)
[00fdce32] 2f2e 000c                 move.l    12(a6),-(a7)
[00fdce36] 2f2e 0008                 move.l    8(a6),-(a7)
[00fdce3a] f5c8                      dc.w      $F5C8 ; wind_get
[00fdce3c] defc 0010                 adda.w    #$0010,a7
[00fdce40] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif
