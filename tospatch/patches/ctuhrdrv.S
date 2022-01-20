checkRTC:
		clr.l      d0
		rts
FC1F74:
		lea.l      FC2134(pc),a0
		lea.l      $00FEFF00,a3
		lea.l      238(a3),a1
		moveq.l    #24,d1
		moveq.l    #10,d4
		move.w     #$2700,sr
		tst.b      (a1)
		tst.b      (a1)
		tst.b      (a1)
		rts

writeRTCTime:
		move.w     sr,-(a7)
		movem.l    d1-d5/a1-a3,-(a7)
		bsr.s      FC1F74
		lea.l      (a3),a1
		lea.l      96(a3),a2
FC2090:
		moveq.l    #0,d5
		move.l     38(a7),d3
		move.b     (a0)+,d5
		bne.s      FC209C
		asl.b      #1,d3
FC209C:
		lsr.l      d5,d3
		and.b      5(a0),d3
		ext.w      d3
		ext.l      d3
		divu.w     d4,d3
		bsr.s      FC20B4
		swap       d3
		bsr.s      FC20B4
		tst.w      d1
		bpl.s      FC2090
		bra.s      FC20FA
FC20B4:
		cmp.w      d4,d1
		bne.s      FC20BC
		or.b       #8,d3
FC20BC:
		lsl.b      #1,d3
		move.b     0(a1,d1.w),d2
		move.b     0(a2,d1.w),d2
		move.b     32(a3,d3.w),d3
		bra.s      FC2122


readRTCTime:
		move.w     sr,-(a7)
		movem.l    d1-d5/a1-a3,-(a7)
		bsr        FC1F74
		lea.l      128(a3),a1
		lea.l      224(a3),a2
		moveq.l    #0,d0
FC20E0:
		bsr.s      FC2106
		mulu.w     d4,d2
		moveq.l    #0,d3
		move.b     d2,d3
		bsr.s      FC2106
		add.b      d3,d2
		move.b     (a0)+,d3
		bne.s      FC20F2
		lsr.b      #1,d2
FC20F2:
		lsl.l      d3,d2
		or.l       d2,d0
		tst.w      d1
		bpl.s      FC20E0
FC20FA:
		tst.b      $00FE0000
		movem.l    (a7)+,d1-d5/a1-a3
		rte
FC2106:
		moveq.l    #0,d2
		move.b     0(a1,d1.w),d2
		move.b     0(a2,d1.w),d2
		move.b     192(a3),d2
		move.b     192(a3),d2
		not.b      d2
		cmp.w      d4,d1
		bne.s      FC2122
		and.b      #7,d2
FC2122:
		move.b     30(a1),d5
		move.b     238(a3),d5
		subq.w     #2,d1
		cmpi.w     #12,d1
		beq.s      FC2122
		rts
FC2134:
		dc.b $19,$15,$10,$0B,$05,$00,$7F,$0F,$1F,$1F,$3F,$1F
