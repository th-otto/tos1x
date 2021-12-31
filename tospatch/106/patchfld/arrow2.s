[00fddf0e] 7600                      moveq.l    #0,d3
[00fddf10] 1639 0000 6dae            move.b     $00006DAE,d3
[00fddf16] 5383                      subq.l     #1,d3
[00fddf18] ef83                      asl.l      #7,d3
[00fddf1a] 87f9 0000 6e18            divs.w     $00006E18,d3
[00fddf20] 48c3                      ext.l      d3
[00fddf22] d6b9 0000 6b1e            add.l      $00006B1E,d3
[00fddf28] 2a6d 0002                 movea.l    2(a5),a5
[00fddf2c] 4a6d 0036                 tst.w      54(a5)
[00fddf30] 6e1c                      bgt.s      $00FDDF4E
[00fddf32] 4267                      clr.w      -(a7)
[00fddf34] 42a7                      clr.l      -(a7)
[00fddf36] 3f2e ffee                 move.w     -18(a6),-(a7)
[00fddf3a] 3f07                      move.w     d7,-(a7)
[00fddf3c] 3f2d 001c                 move.w     28(a5),-(a7)
[00fddf40] 3f04                      move.w     d4,-(a7)
[00fddf42] 4879 0000 701a            pea.l      $0000701A
[00fddf48] f710                      dc.w       $F710 ; ap_sendmsg
[00fddf4a] defc 0012                 adda.w     #$0012,a7
[00fddf4e] f084                      dc.w       $F084 ; dsptch
[00fddf50] 0839 0000 0000 a84d       btst       #0,$0000A84D
[00fddf58] 670a                      beq.s      $00FDDF64
[00fddf5a] b6b9 0000 6b1e            cmp.l      $00006B1E,d3
[00fddf60] 64ec                      bcc.s      $00FDDF4E
[00fddf62] 60c8                      bra.s      $00FDDF2C
