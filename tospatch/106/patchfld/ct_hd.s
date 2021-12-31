[00fc065c] 9dce                      suba.l     a6,a6
[00fc065e] 4bf9 ffff 8604            lea.l      $FFFF8604,a5
[00fc0664] 49ed 0002                 lea.l      2(a5),a4
[00fc0668] 7801                      moveq.l    #1,d4
[00fc066a] 7a00                      moveq.l    #0,d5
[00fc066c] 3c3c 00c8                 move.w     #$00C8,d6
[00fc0670] 3e3c 00ca                 move.w     #$00CA,d7
[00fc0674] 50ee 043e                 st         1086(a6)
[00fc0678] 303c 0064                 move.w     #$0064,d0
[00fc067c] 3887                      move.w     d7,(a4)
[00fc067e] 3abc 0080                 move.w     #$0080,(a5)
[00fc0682] 51c8 fffe                 dbf        d0,$00FC0682
[00fc0686] 3a85                      move.w     d5,(a5)
[00fc0688] 3886                      move.w     d6,(a4)
[00fc068a] 51c8 fffe                 dbf        d0,$00FC068A
[00fc068e] 246e 04c6                 movea.l    1222(a6),a2
[00fc0692] d5fc 0000 0200            adda.l     #$00000200,a2
[00fc0698] 6120                      bsr.s      $00FC06BA
[00fc069a] 51ee 043e                 sf         1086(a6)
[00fc069e] 4a40                      tst.w      d0
[00fc06a0] 6616                      bne.s      $00FC06B8
[00fc06a2] 43d2                      lea.l      (a2),a1
[00fc06a4] 323c 00ff                 move.w     #$00FF,d1
[00fc06a8] 7000                      moveq.l    #0,d0
[00fc06aa] d05a                      add.w      (a2)+,d0
[00fc06ac] 51c9 fffc                 dbf        d1,$00FC06AA
[00fc06b0] 0c40 1234                 cmpi.w     #$1234,d0
[00fc06b4] 6602                      bne.s      $00FC06B8
[00fc06b6] 4e91                      jsr        (a1)
[00fc06b8] 4e75                      rts
[00fc06ba] 6164                      bsr.s      $00FC0720
[00fc06bc] 41fa 0074                 lea.l      $00FC0732(pc),a0
[00fc06c0] 7405                      moveq.l    #5,d2
[00fc06c2] 7600                      moveq.l    #0,d3
[00fc06c4] 6136                      bsr.s      $00FC06FC
[00fc06c6] 662c                      bne.s      $00FC06F4
[00fc06c8] 1618                      move.b     (a0)+,d3
[00fc06ca] 3a83                      move.w     d3,(a5)
[00fc06cc] 51ca fff6                 dbf        d2,$00FC06C4
[00fc06d0] 223c 0000 1770            move.l     #$00001770,d1
[00fc06d6] 6126                      bsr.s      $00FC06FE
[00fc06d8] 47d2                      lea.l      (a2),a3
[00fc06da] 343c 01ff                 move.w     #$01FF,d2
[00fc06de] 611c                      bsr.s      $00FC06FC
[00fc06e0] 6612                      bne.s      $00FC06F4
[00fc06e2] 3015                      move.w     (a5),d0
[00fc06e4] 16c0                      move.b     d0,(a3)+
[00fc06e6] 51ca fff6                 dbf        d2,$00FC06DE
[00fc06ea] 6110                      bsr.s      $00FC06FC
[00fc06ec] 3015                      move.w     (a5),d0
[00fc06ee] 0240 00ff                 andi.w     #$00FF,d0
[00fc06f2] 4a40                      tst.w      d0
[00fc06f4] 38bc 0080                 move.w     #$0080,(a4)
[00fc06f8] 4a40                      tst.w      d0
[00fc06fa] 4e75                      rts
[00fc06fc] 727f                      moveq.l    #127,d1
[00fc06fe] 3887                      move.w     d7,(a4)
[00fc0700] 3a84                      move.w     d4,(a5)
[00fc0702] 3886                      move.w     d6,(a4)
[00fc0704] d2ae 04ba                 add.l      1210(a6),d1
[00fc0708] 3015                      move.w     (a5),d0
[00fc070a] c044                      and.w      d4,d0
[00fc070c] 660c                      bne.s      $00FC071A
[00fc070e] b2ae 04ba                 cmp.l      1210(a6),d1
[00fc0712] 66f4                      bne.s      $00FC0708
[00fc0714] 6114                      bsr.s      $00FC072A
[00fc0716] 70ff                      moveq.l    #-1,d0
[00fc0718] 4e75                      rts
[00fc071a] 610e                      bsr.s      $00FC072A
[00fc071c] 7000                      moveq.l    #0,d0
[00fc071e] 4e75                      rts
[00fc0720] 3887                      move.w     d7,(a4)
[00fc0722] 3abc 0002                 move.w     #$0002,(a5)
[00fc0726] 3886                      move.w     d6,(a4)
[00fc0728] 3a85                      move.w     d5,(a5)
[00fc072a] 3887                      move.w     d7,(a4)
[00fc072c] 3a85                      move.w     d5,(a5)
[00fc072e] 3886                      move.w     d6,(a4)
[00fc0730] 4e75                      rts
[00fc0732] 0800 0000                 btst       #0,d0
[00fc0736] 0101                      btst       d0,d1
