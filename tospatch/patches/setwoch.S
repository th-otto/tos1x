/* writeRTCTime: */
		bsr        checkRTC
		bcs.s      rdRTCErr
		lea.l      (rtcbufa).w,a1
		move.l     4(a7),-(a7)
		bsr.s      FC20C4
		addq.l     #4,a7
		andi.b     #3,d2
		move.b     #2,31(a0)
		bset       #0,27(a0)
		move.b     #1,21(a0)
		move.b     d2,23(a0)
		bclr       #0,27(a0)
		moveq.l    #12,d0
		moveq.l    #1,d1
FC20B6:
		move.b     -(a1),0(a0,d1.w)
		addq.w     #2,d1
		dbf        d0,FC20B6
		moveq.l    #0,d0
		rts
FC20C4:
		move.w     4(a7),d1
		move.w     d1,d0
		lsr.w      #1,d0
		lsr.w      #8,d0
		move.w     d0,d2
		bsr.s      FC2138
		move.w     d1,d0
		lsr.w      #5,d0
		and.w      #15,d0
		bsr.s      FC2138
		move.w     d1,d0
		and.w      #31,d0
		bsr.s      FC2138
		lsr.w      #5,d1
		andi.w     #15,d1
		addq.w     #1,d1
		move.w     d2,d0
		cmpi.w     #3,d1
		bhi.s      FC20FA
		add.w      #$000C,d1
		subq.w     #1,d0
FC20FA:
		mulu.w     #26,d1
		divu.w     #10,d1
		add.w      d0,d1
		lsr.w      #2,d0
		add.w      d0,d1
		move.w     4(a7),d0
		andi.w     #31,d0
		add.w      d0,d1
		addq.w     #2,d1
		ext.l      d1
		divu.w     #7,d1
		swap       d1
		move.b     d1,(a1)+
		move.w     6(a7),d1
		move.w     d1,d0
		lsr.w      #8,d0
		lsr.w      #3,d0
		bsr.s      FC2138
		move.w     d1,d0
		lsr.w      #5,d0
		bsr.s      FC2134
		move.w     d1,d0
		add.w      d0,d0
FC2134:
		and.w      #63,d0
FC2138:
		ext.l      d0
		divu.w     #10,d0
		move.b     d0,(a1)+
		swap       d0
		move.b     d0,(a1)+
		rts
