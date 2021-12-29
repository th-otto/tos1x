[00fc2080] 6100 feee                 bsr        $00FC1F70
[00fc2084] 65f6                      bcs.s      $00FC207C
[00fc2086] 43f8 0a54                 lea.l      ($00000A54).w,a1
[00fc208a] 2f2f 0004                 move.l     4(a7),-(a7)
[00fc208e] 6134                      bsr.s      $00FC20C4
[00fc2090] 588f                      addq.l     #4,a7
[00fc2092] 0202 0003                 andi.b     #$03,d2
[00fc2096] 117c 0002 001f            move.b     #$02,31(a0)
[00fc209c] 08e8 0000 001b            bset       #0,27(a0)
[00fc20a2] 117c 0001 0015            move.b     #$01,21(a0)
[00fc20a8] 1142 0017                 move.b     d2,23(a0)
[00fc20ac] 08a8 0000 001b            bclr       #0,27(a0)
[00fc20b2] 700c                      moveq.l    #12,d0
[00fc20b4] 7201                      moveq.l    #1,d1
[00fc20b6] 11a1 1000                 move.b     -(a1),0(a0,d1.w)
[00fc20ba] 5441                      addq.w     #2,d1
[00fc20bc] 51c8 fff8                 dbf        d0,$00FC20B6
[00fc20c0] 7000                      moveq.l    #0,d0
[00fc20c2] 4e75                      rts
[00fc20c4] 322f 0004                 move.w     4(a7),d1
[00fc20c8] 3001                      move.w     d1,d0
[00fc20ca] e248                      lsr.w      #1,d0
[00fc20cc] e048                      lsr.w      #8,d0
[00fc20ce] 3400                      move.w     d0,d2
[00fc20d0] 6166                      bsr.s      $00FC2138
[00fc20d2] 3001                      move.w     d1,d0
[00fc20d4] ea48                      lsr.w      #5,d0
[00fc20d6] c07c 000f                 and.w      #$000F,d0
[00fc20da] 615c                      bsr.s      $00FC2138
[00fc20dc] 3001                      move.w     d1,d0
[00fc20de] c07c 001f                 and.w      #$001F,d0
[00fc20e2] 6154                      bsr.s      $00FC2138
[00fc20e4] ea49                      lsr.w      #5,d1
[00fc20e6] 0241 000f                 andi.w     #$000F,d1
[00fc20ea] 5241                      addq.w     #1,d1
[00fc20ec] 3002                      move.w     d2,d0
[00fc20ee] 0c41 0003                 cmpi.w     #$0003,d1
[00fc20f2] 6206                      bhi.s      $00FC20FA
[00fc20f4] d27c 000c                 add.w      #$000C,d1
[00fc20f8] 5340                      subq.w     #1,d0
[00fc20fa] c2fc 001a                 mulu.w     #$001A,d1
[00fc20fe] 82fc 000a                 divu.w     #$000A,d1
[00fc2102] d240                      add.w      d0,d1
[00fc2104] e448                      lsr.w      #2,d0
[00fc2106] d240                      add.w      d0,d1
[00fc2108] 302f 0004                 move.w     4(a7),d0
[00fc210c] 0240 001f                 andi.w     #$001F,d0
[00fc2110] d240                      add.w      d0,d1
[00fc2112] 5441                      addq.w     #2,d1
[00fc2114] 48c1                      ext.l      d1
[00fc2116] 82fc 0007                 divu.w     #$0007,d1
[00fc211a] 4841                      swap       d1
[00fc211c] 12c1                      move.b     d1,(a1)+
[00fc211e] 322f 0006                 move.w     6(a7),d1
[00fc2122] 3001                      move.w     d1,d0
[00fc2124] e048                      lsr.w      #8,d0
[00fc2126] e648                      lsr.w      #3,d0
[00fc2128] 610e                      bsr.s      $00FC2138
[00fc212a] 3001                      move.w     d1,d0
[00fc212c] ea48                      lsr.w      #5,d0
[00fc212e] 6104                      bsr.s      $00FC2134
[00fc2130] 3001                      move.w     d1,d0
[00fc2132] d040                      add.w      d0,d0
[00fc2134] c07c 003f                 and.w      #$003F,d0
[00fc2138] 48c0                      ext.l      d0
[00fc213a] 80fc 000a                 divu.w     #$000A,d0
[00fc213e] 12c0                      move.b     d0,(a1)+
[00fc2140] 4840                      swap       d0
[00fc2142] 12c0                      move.b     d0,(a1)+
[00fc2144] 4e75                      rts
[00fc2146] ffff ffff ffff ffff
[00fc214e] ffff ffff ffff ffff
[00fc2156] ffff ffff ffff
