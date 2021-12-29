[00fe0000] 41ef 0004                 lea.l      4(a7),a0
[00fe0004] 48e7 1318                 movem.l    d3/d6-d7/a3-a4,-(a7)
[00fe0008] 3e18                      move.w     (a0)+,d7
[00fe000a] 6a00 0086                 bpl        $00FE0092
[00fe000e] 3c10                      move.w     (a0),d6
[00fe0010] 21cf 6676                 move.l     a7,($00006676).w
[00fe0014] 4ff8 6a7a                 lea.l      ($00006A7A).w,a7
[00fe0018] 3207                      move.w     d7,d1
[00fe001a] 4641                      not.w      d1
[00fe001c] b27c 0011                 cmp.w      #$0011,d1
[00fe0020] 6e3e                      bgt.s      $00FE0060
[00fe0022] 43f9 00fe b306            lea.l      $00FEB306,a1
[00fe0028] 1631 1000                 move.b     0(a1,d1.w),d3
[00fe002c] 4883                      ext.w      d3
[00fe002e] d643                      add.w      d3,d3
[00fe0030] 49fa 009c                 lea.l      $00FE00CE(pc),a4
[00fe0034] d8f4 3000                 adda.w     0(a4,d3.w),a4
[00fe0038] 6162                      bsr.s      $00FE009C
[00fe003a] b67c 000c                 cmp.w      #$000C,d3
[00fe003e] 6724                      beq.s      $00FE0064
[00fe0040] 49fa 017a                 lea.l      $00FE01BC(pc),a4
[00fe0044] 6156                      bsr.s      $00FE009C
[00fe0046] 617a                      bsr.s      $00FE00C2
[00fe0048] 0880 0005                 bclr       #5,d0
[00fe004c] b03c 0041                 cmp.b      #$41,d0
[00fe0050] 671e                      beq.s      $00FE0070
[00fe0052] b03c 0049                 cmp.b      #$49,d0
[00fe0056] 6724                      beq.s      $00FE007C
[00fe0058] b03c 004e                 cmp.b      #$4E,d0
[00fe005c] 6718                      beq.s      $00FE0076
[00fe005e] 60e0                      bra.s      $00FE0040
[00fe0060] 70ff                      moveq.l    #-1,d0
[00fe0062] 602e                      bra.s      $00FE0092
[00fe0064] 49fa 0178                 lea.l      $00FE01DE(pc),a4
[00fe0068] 6132                      bsr.s      $00FE009C
[00fe006a] 6156                      bsr.s      $00FE00C2
[00fe006c] 7600                      moveq.l    #0,d3
[00fe006e] 601a                      bra.s      $00FE008A
[00fe0070] 3607                      move.w     d7,d3
[00fe0072] 48c3                      ext.l      d3
[00fe0074] 6008                      bra.s      $00FE007E
[00fe0076] 7601                      moveq.l    #1,d3
[00fe0078] 4843                      swap       d3
[00fe007a] 6002                      bra.s      $00FE007E
[00fe007c] 7600                      moveq.l    #0,d3
[00fe007e] 3f00                      move.w     d0,-(a7)
[00fe0080] 2f3c 0003 0002            move.l     #$00030002,-(a7)
[00fe0086] 4e4d                      trap       #13
[00fe0088] 5c8f                      addq.l     #6,a7
[00fe008a] 47fa 012d                 lea.l      $00FE01B9(pc),a3
[00fe008e] 6114                      bsr.s      $00FE00A4
[00fe0090] 2003                      move.l     d3,d0
[00fe0092] 2e78 6676                 movea.l    ($00006676).w,a7
[00fe0096] 4cdf 18c8                 movem.l    (a7)+,d3/d6-d7/a3-a4
[00fe009a] 4e75                      rts
[00fe009c] 47fa 003e                 lea.l      $00FE00DC(pc),a3
[00fe00a0] 6102                      bsr.s      $00FE00A4
[00fe00a2] 264c                      movea.l    a4,a3
[00fe00a4] 101b                      move.b     (a3)+,d0
[00fe00a6] 6718                      beq.s      $00FE00C0
[00fe00a8] b03c 0025                 cmp.b      #$25,d0
[00fe00ac] 6604                      bne.s      $00FE00B2
[00fe00ae] 7041                      moveq.l    #65,d0
[00fe00b0] d006                      add.b      d6,d0
[00fe00b2] 3f00                      move.w     d0,-(a7)
[00fe00b4] 2f3c 0003 0002            move.l     #$00030002,-(a7)
[00fe00ba] 4e4d                      trap       #13
[00fe00bc] 5c8f                      addq.l     #6,a7
[00fe00be] 60e4                      bra.s      $00FE00A4
[00fe00c0] 4e75                      rts
[00fe00c2] 2f3c 0002 0002            move.l     #$00020002,-(a7)
[00fe00c8] 4e4d                      trap       #13
[00fe00ca] 588f                      addq.l     #4,a7
[00fe00cc] 4e75                      rts
[00fe00ce] 0012 003e                 ori.b      #$3E,(a2)
[00fe00d2] 0061 007e                 ori.w      #$007E,-(a1)
[00fe00d6] 00a4 00c4 00c5            ori.l      #$00C400C5,-(a4)
[00fe00dc] 1b6c 2000 4469            move.b     8192(a4),17513(a5)
[00fe00e2] 736b                      ???
[00fe00e4] 2069 6e20                 movea.l    28192(a1),a0
[00fe00e8] 4c61 7566                 divu.l     -(a1),d6:d7 ; 68020+ only
[00fe00ec] 7765                      ???
[00fe00ee] 726b                      moveq.l    #107,d1
[00fe00f0] 2025                      move.l     -(a5),d0
[00fe00f2] 3a20                      move.w     -(a0),d5
[00fe00f4] 6973                      bvs.s      $00FE0169
[00fe00f6] 7420                      moveq.l    #32,d2
[00fe00f8] 7363                      ???
[00fe00fa] 6872                      bvc.s      $00FE016E
[00fe00fc] 6569                      bcs.s      $00FE0167
[00fe00fe] 6267                      bhi.s      $00FE0167
[00fe0100] 6573                      bcs.s      $00FE0175
[00fe0102] 6368                      bls.s      $00FE016C
[00fe0104] 8174 7a74                 or.w       d0,116(a4,d7.l*2) ; 68020+ only
[00fe0108] 2e0d                      move.l     a5,d7
[00fe010a] 0a00 466c                 eori.b     #$6C,d0
[00fe010e] 6f70                      ble.s      $00FE0180
[00fe0110] 7079                      moveq.l    #121,d0
[00fe0112] 2025                      move.l     -(a5),d0
[00fe0114] 3a20                      move.w     -(a0),d5
[00fe0116] 616e                      bsr.s      $00FE0186
[00fe0118] 7477                      moveq.l    #119,d2
[00fe011a] 6f72                      ble.s      $00FE018E
[00fe011c] 7465                      moveq.l    #101,d2
[00fe011e] 7420                      moveq.l    #32,d2
[00fe0120] 6e69                      bgt.s      $00FE018B
[00fe0122] 6368                      bls.s      $00FE018C
[00fe0124] 7420                      moveq.l    #32,d2
[00fe0126] 283f                      move.l     ???,d4
[00fe0128] 292e 2e2e                 move.l     11822(a6),-(a4)
[00fe012c] 0d0a 0044                 movep.w    68(a2),d6
[00fe0130] 6174                      bsr.s      $00FE01A6
[00fe0132] 656e                      bcs.s      $00FE01A2
[00fe0134] 2061                      movea.l    -(a1),a0
[00fe0136] 7566                      ???
[00fe0138] 2044                      movea.l    d4,a0
[00fe013a] 6973                      bvs.s      $00FE01AF
[00fe013c] 6b20                      bmi.s      $00FE015E
[00fe013e] 253a 2064                 move.l     $00FE21A4(pc),-(a2)
[00fe0142] 6566                      bcs.s      $00FE01AA
[00fe0144] 656b                      bcs.s      $00FE01B1
[00fe0146] 743f                      moveq.l    #63,d2
[00fe0148] 200d                      move.l     a5,d0
[00fe014a] 0a00 416e                 eori.b     #$6E,d0
[00fe014e] 7765                      ???
[00fe0150] 6e64                      bgt.s      $00FE01B6
[00fe0152] 756e                      ???
[00fe0154] 6720                      beq.s      $00FE0176
[00fe0156] 6b61                      bmi.s      $00FE01B9
[00fe0158] 6e6e                      bgt.s      $00FE01C8
[00fe015a] 2044                      movea.l    d4,a0
[00fe015c] 6973                      bvs.s      $00FE01D1
[00fe015e] 6b20                      bmi.s      $00FE0180
[00fe0160] 253a 206e                 move.l     $00FE21D0(pc),-(a2)
[00fe0164] 6963                      bvs.s      $00FE01C9
[00fe0166] 6874                      bvc.s      $00FE01DC
[00fe0168] 206c 6573                 movea.l    25971(a4),a0
[00fe016c] 656e                      bcs.s      $00FE01DC
[00fe016e] 2e0d                      move.l     a5,d7
[00fe0170] 0a00 4175                 eori.b     #$75,d0
[00fe0174] 7367                      ???
[00fe0176] 6162                      bsr.s      $00FE01DA
[00fe0178] 6567                      bcs.s      $00FE01E1
[00fe017a] 6572                      bcs.s      $00FE01EE
[00fe017c] 8474 2061                 or.w       97(a4,d2.w),d2
[00fe0180] 6e74                      bgt.s      $00FE01F6
[00fe0182] 776f                      ???
[00fe0184] 7274                      moveq.l    #116,d1
[00fe0186] 6574                      bcs.s      $00FE01FC
[00fe0188] 206e 6963                 movea.l    26979(a6),a0
[00fe018c] 6874                      bvc.s      $00FE0202
[00fe018e] 210d                      move.l     a5,-(a0)
[00fe0190] 0a00 0042                 eori.b     #$42,d0
[00fe0194] 6974                      bvs.s      $00FE020A
[00fe0196] 7465                      moveq.l    #101,d2
[00fe0198] 2044                      movea.l    d4,a0
[00fe019a] 6973                      bvs.s      $00FE020F
[00fe019c] 6b20                      bmi.s      $00FE01BE
[00fe019e] 253a 2069                 move.l     $00FE2209(pc),-(a2)
[00fe01a2] 6e20                      bgt.s      $00FE01C4
[00fe01a4] 4c61 7566                 divu.l     -(a1),d6:d7 ; 68020+ only
[00fe01a8] 7765                      ???
[00fe01aa] 726b                      moveq.l    #107,d1
[00fe01ac] 2041                      movea.l    d1,a0
[00fe01ae] 3a20                      move.w     -(a0),d5
[00fe01b0] 6569                      bcs.s      $00FE021B
[00fe01b2] 6e6c                      bgt.s      $00FE0220
[00fe01b4] 6567                      bcs.s      $00FE021D
[00fe01b6] 656e                      bcs.s      $00FE0226
[00fe01b8] 210d                      move.l     a5,-(a0)
[00fe01ba] 0a00 4129                 eori.b     #$29,d0
[00fe01be] 6262                      bhi.s      $00FE0222
[00fe01c0] 7275                      moveq.l    #117,d1
[00fe01c2] 6368                      bls.s      $00FE022C
[00fe01c4] 2c20                      move.l     -(a0),d6
[00fe01c6] 4e29 6f63 686d            cmpiw.l    #$6F63,26733(a1) ; apollo only
[00fe01cc] 616c                      bsr.s      $00FE023A
[00fe01ce] 2c20                      move.l     -(a0),d6
[00fe01d0] 4929 676e                 chk.l      26478(a1),d4 ; 68020+ only
[00fe01d4] 6f72                      ble.s      $00FE0248
[00fe01d6] 6965                      bvs.s      $00FE023D
[00fe01d8] 7265                      moveq.l    #101,d1
[00fe01da] 6e3f                      bgt.s      $00FE021B
[00fe01dc] 2000                      move.l     d0,d0
[00fe01de] 5461                      addq.w     #2,-(a1)
[00fe01e0] 7374                      ???
[00fe01e2] 652e                      bcs.s      $00FE0212
[00fe01e4] 2e2e 0000                 move.l     0(a6),d7
