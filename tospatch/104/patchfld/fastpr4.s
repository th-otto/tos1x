[00fc3300] 2638 04ba                 move.l     ($000004BA).w,d3
[00fc3304] 2403                      move.l     d3,d2
[00fc3306] 96b8 0ea0                 sub.l      ($00000EA0).w,d3
[00fc330a] 0c83 0000 03e8            cmpi.l     #$000003E8,d3
[00fc3310] 6512                      bcs.s      $00FC3324
[00fc3312] 6178                      bsr.s      $00FC338C
[00fc3314] 6b18                      bmi.s      $00FC332E
[00fc3316] 2638 04ba                 move.l     ($000004BA).w,d3
[00fc331a] 9682                      sub.l      d2,d3
[00fc331c] 0c83 0000 1770            cmpi.l     #$00001770,d3
[00fc3322] 6dee                      blt.s      $00FC3312
[00fc3324] 21f8 04ba 0ea0            move.l     ($000004BA).w,($00000EA0).w
[00fc332a] 7000                      moveq.l    #0,d0
[00fc332c] 4e75                      rts
[00fc332e] 40c3                      move.w     sr,d3
[00fc3330] 007c 0700                 ori.w      #$0700,sr
[00fc3334] 41f8 8800                 lea.l      ($FFFF8800).w,a0
[00fc3338] 7207                      moveq.l    #7,d1
[00fc333a] 70c0                      moveq.l    #-64,d0
[00fc333c] 611c                      bsr.s      $00FC335A
[00fc333e] 6124                      bsr.s      $00FC3364
[00fc3340] 10bc 000f                 move.b     #$0F,(a0)
[00fc3344] 116f 0007 0002            move.b     7(a7),2(a0)
[00fc334a] 610c                      bsr.s      $00FC3358
[00fc334c] 46c3                      move.w     d3,sr
[00fc334e] 70ff                      moveq.l    #-1,d0
[00fc3350] 4e75                      rts
[00fc3352] 41f8 8800                 lea.l      ($FFFF8800).w,a0
[00fc3356] 720e                      moveq.l    #14,d1
[00fc3358] 7020                      moveq.l    #32,d0
[00fc335a] 1081                      move.b     d1,(a0)
[00fc335c] 8010                      or.b       (a0),d0
[00fc335e] 1140 0002                 move.b     d0,2(a0)
[00fc3362] 4e75                      rts
[00fc3364] 720e                      moveq.l    #14,d1
[00fc3366] 70df                      moveq.l    #-33,d0
[00fc3368] 1081                      move.b     d1,(a0)
[00fc336a] c010                      and.b      (a0),d0
[00fc336c] 1140 0002                 move.b     d0,2(a0)
[00fc3370] 4e75                      rts
[00fc3372] 41f8 8800                 lea.l      ($FFFF8800).w,a0
[00fc3376] 7207                      moveq.l    #7,d1
[00fc3378] 707f                      moveq.l    #127,d0
[00fc337a] 61ec                      bsr.s      $00FC3368
[00fc337c] 61d8                      bsr.s      $00FC3356
[00fc337e] 610c                      bsr.s      $00FC338C
[00fc3380] 6bfc                      bmi.s      $00FC337E
[00fc3382] 61e2                      bsr.s      $00FC3366
[00fc3384] 10bc 000f                 move.b     #$0F,(a0)
[00fc3388] 1010                      move.b     (a0),d0
[00fc338a] 4e75                      rts
[00fc338c] 0238 00fe fa05            andi.b     #$FE,($FFFFFA05).w
[00fc3392] 7000                      moveq.l    #0,d0
[00fc3394] 0138 fa01                 btst       d0,($FFFFFA01).w
[00fc3398] 6602                      bne.s      $00FC339C
[00fc339a] 70ff                      moveq.l    #-1,d0
[00fc339c] 4e75                      rts
[00fc339e] ffff ffff ffff ffff
