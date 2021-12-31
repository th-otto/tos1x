[00e02258] 6100 feee                 bsr        $00E02148
[00e0225c] 65f6                      bcs.s      $00E02254
[00e0225e] 43f8 0a94                 lea.l      ($00000A94).w,a1
[00e02262] 2f2f 0004                 move.l     4(a7),-(a7)
[00e02266] 6134                      bsr.s      $00E0229C
[00e02268] 588f                      addq.l     #4,a7
[00e0226a] 0202 0003                 andi.b     #$03,d2
[00e0226e] 117c 0002 001f            move.b     #$02,31(a0)
[00e02274] 08e8 0000 001b            bset       #0,27(a0)
[00e0227a] 117c 0001 0015            move.b     #$01,21(a0)
[00e02280] 1142 0017                 move.b     d2,23(a0)
[00e02284] 08a8 0000 001b            bclr       #0,27(a0)
[00e0228a] 700c                      moveq.l    #12,d0
[00e0228c] 7201                      moveq.l    #1,d1
[00e0228e] 11a1 1000                 move.b     -(a1),0(a0,d1.w)
[00e02292] 5441                      addq.w     #2,d1
[00e02294] 51c8 fff8                 dbf        d0,$00E0228E
[00e02298] 7000                      moveq.l    #0,d0
[00e0229a] 4e75                      rts
[00e0229c] 322f 0004                 move.w     4(a7),d1
[00e022a0] 3001                      move.w     d1,d0
[00e022a2] e248                      lsr.w      #1,d0
[00e022a4] e048                      lsr.w      #8,d0
[00e022a6] 3400                      move.w     d0,d2
[00e022a8] 6166                      bsr.s      $00E02310
[00e022aa] 3001                      move.w     d1,d0
[00e022ac] ea48                      lsr.w      #5,d0
[00e022ae] c07c 000f                 and.w      #$000F,d0
[00e022b2] 615c                      bsr.s      $00E02310
[00e022b4] 3001                      move.w     d1,d0
[00e022b6] c07c 001f                 and.w      #$001F,d0
[00e022ba] 6154                      bsr.s      $00E02310
[00e022bc] ea49                      lsr.w      #5,d1
[00e022be] 0241 000f                 andi.w     #$000F,d1
[00e022c2] 5241                      addq.w     #1,d1
[00e022c4] 3002                      move.w     d2,d0
[00e022c6] 0c41 0003                 cmpi.w     #$0003,d1
[00e022ca] 6206                      bhi.s      $00E022D2
[00e022cc] d27c 000c                 add.w      #$000C,d1
[00e022d0] 5340                      subq.w     #1,d0
[00e022d2] c2fc 001a                 mulu.w     #$001A,d1
[00e022d6] 82fc 000a                 divu.w     #$000A,d1
[00e022da] d240                      add.w      d0,d1
[00e022dc] e448                      lsr.w      #2,d0
[00e022de] d240                      add.w      d0,d1
[00e022e0] 302f 0004                 move.w     4(a7),d0
[00e022e4] 0240 001f                 andi.w     #$001F,d0
[00e022e8] d240                      add.w      d0,d1
[00e022ea] 5441                      addq.w     #2,d1
[00e022ec] 48c1                      ext.l      d1
[00e022ee] 82fc 0007                 divu.w     #$0007,d1
[00e022f2] 4841                      swap       d1
[00e022f4] 12c1                      move.b     d1,(a1)+
[00e022f6] 322f 0006                 move.w     6(a7),d1
[00e022fa] 3001                      move.w     d1,d0
[00e022fc] e048                      lsr.w      #8,d0
[00e022fe] e648                      lsr.w      #3,d0
[00e02300] 610e                      bsr.s      $00E02310
[00e02302] 3001                      move.w     d1,d0
[00e02304] ea48                      lsr.w      #5,d0
[00e02306] 6104                      bsr.s      $00E0230C
[00e02308] 3001                      move.w     d1,d0
[00e0230a] d040                      add.w      d0,d0
[00e0230c] c07c 003f                 and.w      #$003F,d0
[00e02310] 48c0                      ext.l      d0
[00e02312] 80fc 000a                 divu.w     #$000A,d0
[00e02316] 12c0                      move.b     d0,(a1)+
[00e02318] 4840                      swap       d0
[00e0231a] 12c0                      move.b     d0,(a1)+
[00e0231c] 4e75                      rts
[00e0231e] ffff ffff ffff ffff
[00e02326] ffff ffff ffff ffff
[00e0232e] ffff ffff ffff
