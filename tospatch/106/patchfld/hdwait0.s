[00fe0000] 31f9 00e0 001e 60fe       move.w     $00E0001E,($000060FE).w
[00fe0008] 41fa 00a4                 lea.l      $00FE00AE(pc),a0
[00fe000c] 612a                      bsr.s      $00FE0038
[00fe000e] 7a13                      moveq.l    #19,d5
[00fe0010] 41fa 00ae                 lea.l      $00FE00C0(pc),a0
[00fe0014] 6122                      bsr.s      $00FE0038
[00fe0016] 7805                      moveq.l    #5,d4
[00fe0018] 0838 0003 0ebd            btst       #3,($00000EBD).w
[00fe001e] 660e                      bne.s      $00FE002E
[00fe0020] 6130                      bsr.s      $00FE0052
[00fe0022] 6710                      beq.s      $00FE0034
[00fe0024] 611e                      bsr.s      $00FE0044
[00fe0026] 51cc fff0                 dbf        d4,$00FE0018
[00fe002a] 51cd ffe4                 dbf        d5,$00FE0010
[00fe002e] 41fa 0097                 lea.l      $00FE00C7(pc),a0
[00fe0032] 6004                      bra.s      $00FE0038
[00fe0034] 41fa 008c                 lea.l      $00FE00C2(pc),a0
[00fe0038] 2f08                      move.l     a0,-(a7)
[00fe003a] 3f3c 0009                 move.w     #$0009,-(a7) ; Cconws
[00fe003e] 4e41                      trap       #1
[00fe0040] 5c8f                      addq.l     #6,a7
[00fe0042] 4e75                      rts
[00fe0044] 7032                      moveq.l    #50,d0
[00fe0046] d0b8 04ba                 add.l      ($000004BA).w,d0
[00fe004a] b0b8 04ba                 cmp.l      ($000004BA).w,d0
[00fe004e] 62fa                      bhi.s      $00FE004A
[00fe0050] 4e75                      rts
[00fe0052] 43f8 8606                 lea.l      ($FFFF8606).w,a1
[00fe0056] 41f8 8604                 lea.l      ($FFFF8604).w,a0
[00fe005a] 50f8 043e                 st         ($0000043E).w
[00fe005e] 32bc 0088                 move.w     #$0088,(a1)
[00fe0062] 7c04                      moveq.l    #4,d6
[00fe0064] 203c 0000 008a            move.l     #$0000008A,d0
[00fe006a] 6128                      bsr.s      $00FE0094
[00fe006c] 661a                      bne.s      $00FE0088
[00fe006e] 51ce fff4                 dbf        d6,$00FE0064
[00fe0072] 700a                      moveq.l    #10,d0
[00fe0074] 2080                      move.l     d0,(a0)
[00fe0076] 303c 07d0                 move.w     #$07D0,d0
[00fe007a] 611c                      bsr.s      $00FE0098
[00fe007c] 660a                      bne.s      $00FE0088
[00fe007e] 32bc 008a                 move.w     #$008A,(a1)
[00fe0082] 3010                      move.w     (a0),d0
[00fe0084] c07c 00ff                 and.w      #$00FF,d0
[00fe0088] 32bc 0080                 move.w     #$0080,(a1)
[00fe008c] 51f8 043e                 sf         ($0000043E).w
[00fe0090] 4a40                      tst.w      d0
[00fe0092] 4e75                      rts
[00fe0094] 2080                      move.l     d0,(a0)
[00fe0096] 700a                      moveq.l    #10,d0
[00fe0098] d0b8 04ba                 add.l      ($000004BA).w,d0
[00fe009c] 0838 0005 fa01            btst       #5,($FFFFFA01).w
[00fe00a2] 6708                      beq.s      $00FE00AC
[00fe00a4] b0b8 04ba                 cmp.l      ($000004BA).w,d0
[00fe00a8] 62f2                      bhi.s      $00FE009C
[00fe00aa] 70ff                      moveq.l    #-1,d0
[00fe00ac] 4e75                      rts
[00fe00ae] 5761                      subq.w     #3,-(a1)
[00fe00b0] 7274                      moveq.l    #116,d1
[00fe00b2] 6520                      bcs.s      $00FE00D4
[00fe00b4] 6175                      bsr.s      $00FE012B
[00fe00b6] 6620                      bne.s      $00FE00D8
[00fe00b8] 4861                      pea.l      -(a1)
[00fe00ba] 7264                      moveq.l    #100,d1
[00fe00bc] 6469                      bcc.s      $00FE0127
[00fe00be] 736b                      ???
[00fe00c0] 2e00                      move.l     d0,d7
[00fe00c2] 4f4b                      lea.l      (b3),b7 ; apollo only
[00fe00c4] 0d0a 0020                 movep.w    32(a2),d6
[00fe00c8] 6b65                      bmi.s      $00FE012F
[00fe00ca] 696e                      bvs.s      $00FE013A
[00fe00cc] 6520                      bcs.s      $00FE00EE
[00fe00ce] 6461                      bcc.s      $00FE0131
[00fe00d0] 210d                      move.l     a5,-(a0)
[00fe00d2] 0a00 0000                 eori.b     #$00,d0
