[00e02148] 43f8 0008                 lea.l      ($00000008).w,a1
[00e0214c] 41f8 fc20                 lea.l      ($FFFFFC20).w,a0
[00e02150] 2411                      move.l     (a1),d2
[00e02152] 244f                      movea.l    a7,a2
[00e02154] 22bc 00fc 1fb8            move.l     #$00FC1FB8,(a1)
[00e0215a] 0028 0009 001b            ori.b      #$09,27(a0)
[00e02160] 2282                      move.l     d2,(a1)
[00e02162] 0308 0005                 movep.w    5(a0),d1
[00e02166] 303c 0a06                 move.w     #$0A06,d0
[00e0216a] 0188 0005                 movep.w    d0,5(a0)
[00e0216e] 0508 0005                 movep.w    5(a0),d2
[00e02172] 0388 0005                 movep.w    d1,5(a0)
[00e02176] 0242 0f0f                 andi.w     #$0F0F,d2
[00e0217a] b440                      cmp.w      d0,d2
[00e0217c] 6616                      bne.s      $00E02194
[00e0217e] 117c 0001 0001            move.b     #$01,1(a0)
[00e02184] 08a8 0000 001b            bclr       #0,27(a0)
[00e0218a] 4228 001d                 clr.b      29(a0)
[00e0218e] 4e75                      rts
[00e02190] 2e4a                      movea.l    a2,a7
[00e02192] 2282                      move.l     d2,(a1)
[00e02194] 003c 0001                 ori.b      #$01,ccr
[00e02198] 4e75                      rts
