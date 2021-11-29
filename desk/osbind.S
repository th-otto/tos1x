	xdef _xbios
	text
_xbios:
	move.l    (a7)+,saveret
	trap      #14
	move.l    saveret,-(a7)
	rts

	xdef _bios
	text
_bios:
	move.l    (a7)+,saveret
	trap      #13
	move.l    saveret,-(a7)
	rts

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
