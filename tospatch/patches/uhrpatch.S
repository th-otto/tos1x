		lea.l      (_buserror).w,a1
		lea.l      ($FFFFFC20).w,a0
		move.l     (a1),d2
		lea        chkRTC2(pc),a2
		move.l     a2,(a1)
		movea.l    a7,a2
		ori.b      #9,27(a0)
		move.l     d2,(a1)
		movep.w    5(a0),d1
		move.w     #$0A06,d0
		movep.w    d0,5(a0)
		movep.w    5(a0),d2
		movep.w    d1,5(a0)
		andi.w     #$0F0F,d2
		cmp.w      d0,d2
		bne.s      chkRTC3
		move.b     #1,1(a0)
		bclr       #0,27(a0)
		clr.b      29(a0)
		rts
chkRTC2:
		movea.l    a2,a7
		move.l     d2,(a1)
chkRTC3:
		ori.b      #1,ccr
		rts
