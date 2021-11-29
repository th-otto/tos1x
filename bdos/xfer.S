		xdef _usr2xfr
		xdef _xfr2usr
		text
		
_usr2xfr:
	movea.l   6(a7),a1
	movea.l   10(a7),a0
	bra.s     xfr
_xfr2usr:
	movea.l   6(a7),a0
	movea.l   10(a7),a1
xfr:
	move.w    4(a7),d0
	btst      #0,d0
	bne.s     dobyte
	move.w    a0,d1
	move.w    a1,d2
	or.w      d2,d1
	btst      #0,d1
	bne.s     dobyte
	move.w    d0,d1
	asr.w     #2,d1
	bra.s     dolong
copylong:
	move.l    (a0)+,(a1)+
dolong:
	dbf       d1,copylong
	and.w     #$0003,d0
	beq.s     done
	move.w    (a0)+,(a1)+
done:
	rts
copybyte:
	move.b    (a0)+,(a1)+
dobyte:
	dbf       d0,copybyte
	rts
