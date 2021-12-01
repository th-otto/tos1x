	xdef _gemdos
	text
_gemdos:
	move.l    (a7)+,saveret
	trap      #1
	move.l    saveret,-(a7)
	rts

	bss
	xdef saveret
	comm saveret,4
