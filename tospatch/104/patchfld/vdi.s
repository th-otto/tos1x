[00fcee2a] 4878 0134                 pea.l      ($00000134).w
[00fcee2e] 3f3c 0048                 move.w     #$0048,-(a7) ; Malloc
[00fcee32] 4e41                      trap       #1
[00fcee34] 5c8f                      addq.l     #6,a7
[00fcee36] 4a80                      tst.l      d0
[00fcee38] 660a                      bne.s      $00FCEE44
[00fcee3a] 2078 2ae0                 movea.l    ($00002AE0).w,a0
[00fcee3e] 4268 000c                 clr.w      12(a0)
[00fcee42] 4e75                      rts
[00fcee44] 2240                      movea.l    d0,a1
[00fcee46] 7001                      moveq.l    #1,d0
[00fcee48] 7400                      moveq.l    #0,d2
[00fcee4a] 45f8 3baa                 lea.l      ($00003BAA).w,a2
[00fcee4e] 600c                      bra.s      $00FCEE5C
[00fcee50] 5240                      addq.w     #1,d0
[00fcee52] 240a                      move.l     a2,d2
[00fcee54] 222a 0040                 move.l     64(a2),d1
[00fcee58] 670e                      beq.s      $00FCEE68
[00fcee5a] 2441                      movea.l    d1,a2
[00fcee5c] b06a 0028                 cmp.w      40(a2),d0
[00fcee60] 67ee                      beq.s      $00FCEE50
[00fcee62] 4a82                      tst.l      d2
[00fcee64] 6702                      beq.s      $00FCEE68
[00fcee66] 2442                      movea.l    d2,a2
[00fcee68] 236a 0040 0040            move.l     64(a2),64(a1)
[00fcee6e] 2549 0040                 move.l     a1,64(a2)
[00fcee72] 21c9 290c                 move.l     a1,($0000290C).w
[00fcee76] 2078 2ae0                 movea.l    ($00002AE0).w,a0
[00fcee7a] 3140 000c                 move.w     d0,12(a0)
[00fcee7e] 3340 0028                 move.w     d0,40(a1)
[00fcee82] 6000 fd96                 bra        $00FCEC1A
[00fcee86] ffff ffff ffff ffff
[00fcee8e] ffff ffff ffff ffff
[00fcee96] ffff ffff ffff ffff
[00fcee9e] ffff ffff ffff ffff
[00fceea6] ffff ffff ffff ffff
[00fceeae] ffff ffff ffff ffff
[00fceeb6] ffff ffff ffff
