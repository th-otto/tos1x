	xdef _do1_alert
_do1_alert: ds.b 0
#if 0
[00fe74a6] 4e56 fffc                 link      a6,#$FFFC
[00fe74aa] 4297                      clr.l     (a7)
[00fe74ac] 3f2e 0008                 move.w    8(a6),-(a7)
[00fe74b0] 3f3c 0001                 move.w    #1,-(a7)
[00fe74b4] f0dc                      dc.w      $F0DC ; fill_string
[00fe74b6] 588f                      addq.l    #4,a7
[00fe74b8] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef xfe74ba
xfe74ba: ds.b 0
#if 0
[00fe74ba] 4e56 0000                 link      a6,#0
[00fe74be] 48e7 070c                 movem.l   d5-d7/a4-a5,-(a7)
[00fe74c2] 3e2e 000c                 move.w    12(a6),d7
[00fe74c6] 4a47                      tst.w     d7
[00fe74c8] 6704                      beq.s     $00FE74CE
[00fe74ca] 7e16                      moveq.l   #22,d7
[00fe74cc] 6002                      bra.s     $00FE74D0
[00fe74ce] 7e14                      moveq.l   #20,d7
[00fe74d0] 3007                      move.w    d7,d0
[00fe74d2] c1fc 0018                 muls.w    #$0018,d0
[00fe74d6] 2a40                      movea.l   d0,a5
[00fe74d8] dbee 0008                 adda.l    8(a6),a5
[00fe74dc] dbfc 0000 0014            adda.l    #$00000014,a5
[00fe74e2] 3007                      move.w    d7,d0
[00fe74e4] c1fc 0018                 muls.w    #$0018,d0
[00fe74e8] 2840                      movea.l   d0,a4
[00fe74ea] d9ee 0008                 adda.l    8(a6),a4
[00fe74ee] d9fc 0000 000c            adda.l    #$0000000C,a4
[00fe74f4] 3c15                      move.w    (a5),d6
[00fe74f6] dc79 0000 6be2            add.w     $00006BE2,d6
[00fe74fc] bc79 0000 6be4            cmp.w     $00006BE4,d6
[00fe7502] 6c04                      bge.s     $00FE7508
[00fe7504] 3006                      move.w    d6,d0
[00fe7506] 6006                      bra.s     $00FE750E
[00fe7508] 3039 0000 6be4            move.w    $00006BE4,d0
[00fe750e] 3c00                      move.w    d0,d6
[00fe7510] 3a86                      move.w    d6,(a5)
[00fe7512] 28bc 00ff 1121            move.l    #$00FF1121,(a4)
[00fe7518] 3e87                      move.w    d7,(a7)
[00fe751a] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe751e] f440                      dc.w      $F440
[00fe7520] 588f                      addq.l    #4,a7
[00fe7522] 28bc 00ff 1101            move.l    #$00FF1101,(a4)
[00fe7528] fc31                      dc.w      $FC31 ; movem.l (a7)+,d6-d7/a4-a5
#endif

	xdef xfe752a
xfe752a: ds.b 0
#if 0
[00fe752a] 4e56 fff4                 link      a6,#$FFF4
[00fe752e] 3ebc 0004                 move.w    #$0004,(a7)
[00fe7532] 302e 000c                 move.w    12(a6),d0
[00fe7536] c1fc 0018                 muls.w    #$0018,d0
[00fe753a] d0ae 0008                 add.l     8(a6),d0
[00fe753e] 2f00                      move.l    d0,-(a7)
[00fe7540] 0697 0000 0010            addi.l    #$00000010,(a7)
[00fe7546] 486e fff8                 pea.l     -8(a6)
[00fe754a] f1ac                      dc.w      $F1AC ; LWCOPY
[00fe754c] 508f                      addq.l    #8,a7
[00fe754e] 486e fffa                 pea.l     -6(a6)
[00fe7552] 486e fff8                 pea.l     -8(a6)
[00fe7556] 3f2e 000c                 move.w    12(a6),-(a7)
[00fe755a] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe755e] f3ac                      dc.w      $F3AC ; objc_offset
[00fe7560] defc 000e                 adda.w    #$000E,a7
[00fe7564] 2f2e fffc                 move.l    -4(a6),-(a7)
[00fe7568] 5457                      addq.w    #2,(a7)
[00fe756a] 2f2e fff8                 move.l    -8(a6),-(a7)
[00fe756e] 3f3c 0008                 move.w    #$0008,-(a7)
[00fe7572] 3f2e 000c                 move.w    12(a6),-(a7)
[00fe7576] 2f2e 0008                 move.l    8(a6),-(a7)
[00fe757a] f3a8                      dc.w      $F3A8 ; objc_draw
[00fe757c] defc 0010                 adda.w    #$0010,a7
[00fe7580] f001                      dc.w      $F001 ; movem.l (a7)+,#0
#endif

	xdef _fm_draw
_fm_draw: ds.b 0

	xdef _g_name
_g_name: ds.b 0
