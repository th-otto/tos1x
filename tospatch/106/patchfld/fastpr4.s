[00e034d8] 2638 04ba                 move.l     ($000004BA).w,d3
[00e034dc] 2403                      move.l     d3,d2
[00e034de] 96b8 0ee0                 sub.l      ($00000EE0).w,d3
[00e034e2] 0c83 0000 03e8            cmpi.l     #$000003E8,d3
[00e034e8] 6512                      bcs.s      $00E034FC
[00e034ea] 6178                      bsr.s      $00E03564
[00e034ec] 6b18                      bmi.s      $00E03506
[00e034ee] 2638 04ba                 move.l     ($000004BA).w,d3
[00e034f2] 9682                      sub.l      d2,d3
[00e034f4] 0c83 0000 1770            cmpi.l     #$00001770,d3
[00e034fa] 6dee                      blt.s      $00E034EA
[00e034fc] 21f8 04ba 0ee0            move.l     ($000004BA).w,($00000EE0).w
[00e03502] 7000                      moveq.l    #0,d0
[00e03504] 4e75                      rts
[00e03506] 40c3                      move.w     sr,d3
[00e03508] 007c 0700                 ori.w      #$0700,sr
[00e0350c] 41f8 8800                 lea.l      ($FFFF8800).w,a0
[00e03510] 7207                      moveq.l    #7,d1
[00e03512] 70c0                      moveq.l    #-64,d0
[00e03514] 611c                      bsr.s      $00E03532
[00e03516] 6124                      bsr.s      $00E0353C
[00e03518] 10bc 000f                 move.b     #$0F,(a0)
[00e0351c] 116f 0007 0002            move.b     7(a7),2(a0)
[00e03522] 610c                      bsr.s      $00E03530
[00e03524] 46c3                      move.w     d3,sr
[00e03526] 70ff                      moveq.l    #-1,d0
[00e03528] 4e75                      rts
;new strobeoff:
[00e0352a] 41f8 8800                 lea.l      ($FFFF8800).w,a0
[00e0352e] 720e                      moveq.l    #14,d1
[00e03530] 7020                      moveq.l    #32,d0
[00e03532] 1081                      move.b     d1,(a0)
[00e03534] 8010                      or.b       (a0),d0
[00e03536] 1140 0002                 move.b     d0,2(a0)
[00e0353a] 4e75                      rts
[00e0353c] 720e                      moveq.l    #14,d1
[00e0353e] 70df                      moveq.l    #-33,d0
[00e03540] 1081                      move.b     d1,(a0)
[00e03542] c010                      and.b      (a0),d0
[00e03544] 1140 0002                 move.b     d0,2(a0)
[00e03548] 4e75                      rts
; new bco0in:
[00e0354a] 41f8 8800                 lea.l      ($FFFF8800).w,a0
[00e0354e] 7207                      moveq.l    #7,d1
[00e03550] 707f                      moveq.l    #127,d0
[00e03552] 61ec                      bsr.s      $00E03540
[00e03554] 61d8                      bsr.s      $00E0352E
[00e03556] 610c                      bsr.s      $00E03564
[00e03558] 6bfc                      bmi.s      $00E03556
[00e0355a] 61e2                      bsr.s      $00E0353E
[00e0355c] 10bc 000f                 move.b     #$0F,(a0)
[00e03560] 1010                      move.b     (a0),d0
[00e03562] 4e75                      rts
; new bco0stat:
[00e03564] 0238 00fe fa05            andi.b     #$FE,($FFFFFA05).w
[00e0356a] 7000                      moveq.l    #0,d0
[00e0356c] 0138 fa01                 btst       d0,($FFFFFA01).w
[00e03570] 6602                      bne.s      $00E03574
[00e03572] 70ff                      moveq.l    #-1,d0
[00e03574] 4e75                      rts
[00e03576] ffff ffff ffff ffff
