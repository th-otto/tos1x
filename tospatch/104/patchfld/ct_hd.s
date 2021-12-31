[00fc054c] 9dce                      suba.l     a6,a6
[00fc054e] 4bf9 ffff 8604            lea.l      $FFFF8604,a5
[00fc0554] 49ed 0002                 lea.l      2(a5),a4
[00fc0558] 7801                      moveq.l    #1,d4
[00fc055a] 7a00                      moveq.l    #0,d5
[00fc055c] 3c3c 00c8                 move.w     #$00C8,d6
[00fc0560] 3e3c 00ca                 move.w     #$00CA,d7
[00fc0564] 50ee 043e                 st         1086(a6)
[00fc0568] 303c 0064                 move.w     #$0064,d0
[00fc056c] 3887                      move.w     d7,(a4)
[00fc056e] 3abc 0080                 move.w     #$0080,(a5)
[00fc0572] 51c8 fffe                 dbf        d0,$00FC0572
[00fc0576] 3a85                      move.w     d5,(a5)
[00fc0578] 3886                      move.w     d6,(a4)
[00fc057a] 51c8 fffe                 dbf        d0,$00FC057A
[00fc057e] 246e 04c6                 movea.l    1222(a6),a2
[00fc0582] d5fc 0000 0200            adda.l     #$00000200,a2
[00fc0588] 6120                      bsr.s      $00FC05AA
[00fc058a] 51ee 043e                 sf         1086(a6)
[00fc058e] 4a40                      tst.w      d0
[00fc0590] 6616                      bne.s      $00FC05A8
[00fc0592] 43d2                      lea.l      (a2),a1
[00fc0594] 323c 00ff                 move.w     #$00FF,d1
[00fc0598] 7000                      moveq.l    #0,d0
[00fc059a] d05a                      add.w      (a2)+,d0
[00fc059c] 51c9 fffc                 dbf        d1,$00FC059A
[00fc05a0] 0c40 1234                 cmpi.w     #$1234,d0
[00fc05a4] 6602                      bne.s      $00FC05A8
[00fc05a6] 4e91                      jsr        (a1)
[00fc05a8] 4e75                      rts
[00fc05aa] 6164                      bsr.s      $00FC0610
[00fc05ac] 41fa 0074                 lea.l      $00FC0622(pc),a0
[00fc05b0] 7405                      moveq.l    #5,d2
[00fc05b2] 7600                      moveq.l    #0,d3
[00fc05b4] 6136                      bsr.s      $00FC05EC
[00fc05b6] 662c                      bne.s      $00FC05E4
[00fc05b8] 1618                      move.b     (a0)+,d3
[00fc05ba] 3a83                      move.w     d3,(a5)
[00fc05bc] 51ca fff6                 dbf        d2,$00FC05B4
[00fc05c0] 223c 0000 1770            move.l     #$00001770,d1
[00fc05c6] 6126                      bsr.s      $00FC05EE
[00fc05c8] 47d2                      lea.l      (a2),a3
[00fc05ca] 343c 01ff                 move.w     #$01FF,d2
[00fc05ce] 611c                      bsr.s      $00FC05EC
[00fc05d0] 6612                      bne.s      $00FC05E4
[00fc05d2] 3015                      move.w     (a5),d0
[00fc05d4] 16c0                      move.b     d0,(a3)+
[00fc05d6] 51ca fff6                 dbf        d2,$00FC05CE
[00fc05da] 6110                      bsr.s      $00FC05EC
[00fc05dc] 3015                      move.w     (a5),d0
[00fc05de] 0240 00ff                 andi.w     #$00FF,d0
[00fc05e2] 4a40                      tst.w      d0
[00fc05e4] 38bc 0080                 move.w     #$0080,(a4)
[00fc05e8] 4a40                      tst.w      d0
[00fc05ea] 4e75                      rts
[00fc05ec] 727f                      moveq.l    #127,d1
[00fc05ee] 3887                      move.w     d7,(a4)
[00fc05f0] 3a84                      move.w     d4,(a5)
[00fc05f2] 3886                      move.w     d6,(a4)
[00fc05f4] d2ae 04ba                 add.l      1210(a6),d1
[00fc05f8] 3015                      move.w     (a5),d0
[00fc05fa] c044                      and.w      d4,d0
[00fc05fc] 660c                      bne.s      $00FC060A
[00fc05fe] b2ae 04ba                 cmp.l      1210(a6),d1
[00fc0602] 66f4                      bne.s      $00FC05F8
[00fc0604] 6114                      bsr.s      $00FC061A
[00fc0606] 70ff                      moveq.l    #-1,d0
[00fc0608] 4e75                      rts
[00fc060a] 610e                      bsr.s      $00FC061A
[00fc060c] 7000                      moveq.l    #0,d0
[00fc060e] 4e75                      rts
[00fc0610] 3887                      move.w     d7,(a4)
[00fc0612] 3abc 0002                 move.w     #$0002,(a5)
[00fc0616] 3886                      move.w     d6,(a4)
[00fc0618] 3a85                      move.w     d5,(a5)
[00fc061a] 3887                      move.w     d7,(a4)
[00fc061c] 3a85                      move.w     d5,(a5)
[00fc061e] 3886                      move.w     d6,(a4)
[00fc0620] 4e75                      rts
[00fc0622] 0800 0000                 btst       #0,d0
[00fc0626] 0101                      btst       d0,d1
