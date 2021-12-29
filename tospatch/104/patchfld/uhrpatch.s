[00fc1f70] 43f8 0008                 lea.l      ($00000008).w,a1
[00fc1f74] 41f8 fc20                 lea.l      ($FFFFFC20).w,a0
[00fc1f78] 2411                      move.l     (a1),d2
[00fc1f7a] 244f                      movea.l    a7,a2
[00fc1f7c] 22bc 00fc 1fb8            move.l     #$00FC1FB8,(a1)
[00fc1f82] 0028 0009 001b            ori.b      #$09,27(a0)
[00fc1f88] 2282                      move.l     d2,(a1)
[00fc1f8a] 0308 0005                 movep.w    5(a0),d1
[00fc1f8e] 303c 0a06                 move.w     #$0A06,d0
[00fc1f92] 0188 0005                 movep.w    d0,5(a0)
[00fc1f96] 0508 0005                 movep.w    5(a0),d2
[00fc1f9a] 0388 0005                 movep.w    d1,5(a0)
[00fc1f9e] 0242 0f0f                 andi.w     #$0F0F,d2
[00fc1fa2] b440                      cmp.w      d0,d2
[00fc1fa4] 6616                      bne.s      $00FC1FBC
[00fc1fa6] 117c 0001 0001            move.b     #$01,1(a0)
[00fc1fac] 08a8 0000 001b            bclr       #0,27(a0)
[00fc1fb2] 4228 001d                 clr.b      29(a0)
[00fc1fb6] 4e75                      rts
[00fc1fb8] 2e4a                      movea.l    a2,a7
[00fc1fba] 2282                      move.l     d2,(a1)
[00fc1fbc] 003c 0001                 ori.b      #$01,ccr
[00fc1fc0] 4e75                      rts
