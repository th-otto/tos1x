[00fe0000] 31f9 00fc 001e 60be       move.w     $00FC001E,($000060BE).w
[00fe0008] 0c78 0002 0446            cmpi.w     #$0002,($00000446).w
[00fe000e] 6448                      bcc.s      $00FE0058
[00fe0010] 6166                      bsr.s      $00FE0078
[00fe0012] 6744                      beq.s      $00FE0058
[00fe0014] 41fa 00df                 lea.l      $00FE00F5(pc),a0
[00fe0018] 6142                      bsr.s      $00FE005C
[00fe001a] 2a38 04ba                 move.l     ($000004BA).w,d5
[00fe001e] 7c14                      moveq.l    #20,d6
[00fe0020] dabc 0000 00c8            add.l      #$000000C8,d5
[00fe0026] 41fa 00c8                 lea.l      $00FE00F0(pc),a0
[00fe002a] 6130                      bsr.s      $00FE005C
[00fe002c] 2806                      move.l     d6,d4
[00fe002e] 88fc 000a                 divu.w     #$000A,d4
[00fe0032] 6134                      bsr.s      $00FE0068
[00fe0034] 4844                      swap       d4
[00fe0036] 6130                      bsr.s      $00FE0068
[00fe0038] 2f3c 000b ffff            move.l     #$000BFFFF,-(a7)
[00fe003e] 4e4d                      trap       #13
[00fe0040] 588f                      addq.l     #4,a7
[00fe0042] c03c 0003                 and.b      #$03,d0
[00fe0046] 5700                      subq.b     #3,d0
[00fe0048] 670e                      beq.s      $00FE0058
[00fe004a] 612c                      bsr.s      $00FE0078
[00fe004c] 670a                      beq.s      $00FE0058
[00fe004e] bab8 04ba                 cmp.l      ($000004BA).w,d5
[00fe0052] 62e4                      bhi.s      $00FE0038
[00fe0054] 5346                      subq.w     #1,d6
[00fe0056] 6ac8                      bpl.s      $00FE0020
[00fe0058] 41fa 00ee                 lea.l      $00FE0148(pc),a0
[00fe005c] 2f08                      move.l     a0,-(a7)
[00fe005e] 3f3c 0009                 move.w     #$0009,-(a7) ; Cconws
[00fe0062] 4e41                      trap       #1
[00fe0064] 5c8f                      addq.l     #6,a7
[00fe0066] 4e75                      rts
[00fe0068] 7030                      moveq.l    #48,d0
[00fe006a] d044                      add.w      d4,d0
[00fe006c] 3f00                      move.w     d0,-(a7)
[00fe006e] 3f3c 0002                 move.w     #$0002,-(a7) ; Cconout
[00fe0072] 4e41                      trap       #1
[00fe0074] 588f                      addq.l     #4,a7
[00fe0076] 4e75                      rts
[00fe0078] 50f8 043e                 st         ($0000043E).w
[00fe007c] 41f8 8604                 lea.l      ($FFFF8604).w,a0
[00fe0080] 43e8 0002                 lea.l      2(a0),a1
[00fe0084] 283c 0080 0088            move.l     #$00800088,d4
[00fe008a] 243c 0000 008a            move.l     #$0000008A,d2
[00fe0090] 203c 0080 008a            move.l     #$0080008A,d0
[00fe0096] 3284                      move.w     d4,(a1)
[00fe0098] 2084                      move.l     d4,(a0)
[00fe009a] 2084                      move.l     d4,(a0)
[00fe009c] 0838 0005 fa01            btst       #5,($FFFFFA01).w
[00fe00a2] 6724                      beq.s      $00FE00C8
[00fe00a4] 2080                      move.l     d0,(a0)
[00fe00a6] 6130                      bsr.s      $00FE00D8
[00fe00a8] 661e                      bne.s      $00FE00C8
[00fe00aa] 7603                      moveq.l    #3,d3
[00fe00ac] 2082                      move.l     d2,(a0)
[00fe00ae] 6128                      bsr.s      $00FE00D8
[00fe00b0] 6616                      bne.s      $00FE00C8
[00fe00b2] 51cb fff8                 dbf        d3,$00FE00AC
[00fe00b6] 2082                      move.l     d2,(a0)
[00fe00b8] 203c 0000 0320            move.l     #$00000320,d0
[00fe00be] 611a                      bsr.s      $00FE00DA
[00fe00c0] 6606                      bne.s      $00FE00C8
[00fe00c2] 3010                      move.w     (a0),d0
[00fe00c4] c07c 00ff                 and.w      #$00FF,d0
[00fe00c8] 3284                      move.w     d4,(a1)
[00fe00ca] 2084                      move.l     d4,(a0)
[00fe00cc] 32bc 0080                 move.w     #$0080,(a1)
[00fe00d0] 51f8 043e                 sf         ($0000043E).w
[00fe00d4] 4a40                      tst.w      d0
[00fe00d6] 4e75                      rts
[00fe00d8] 7014                      moveq.l    #20,d0
[00fe00da] d0b8 04ba                 add.l      ($000004BA).w,d0
[00fe00de] 0838 0005 fa01            btst       #5,($FFFFFA01).w
[00fe00e4] 6708                      beq.s      $00FE00EE
[00fe00e6] b0b8 04ba                 cmp.l      ($000004BA).w,d0
[00fe00ea] 62f2                      bhi.s      $00FE00DE
[00fe00ec] 70ff                      moveq.l    #-1,d0
[00fe00ee] 4e75                      rts
[00fe00f0] 1b48 0a20                 dc.b 27,'H',10,32,0
[00fe00f5] 1b 450a                   dc.b 27,'E',10
                                     ascii " .. Warte auf DMA ?"
                                     dc.b 13,10
                                     ascii " Platten-Warter "
                                     dc.b $bd
                                     ascii "'92 by EWK
                                     dc.b 13,10,10,32,27,'p'
                                     ascii " Shift+Shift = Abbruch "
                                     dc.b 27,'q',0
[00fe0148] 1b45 0000                 dc.b 27,'E',0
