******************************** routines.s ***********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:18:47 $
* =============================================================================
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"


		xdef	_STHardList		; orig ST routines blitter
_STHardList: ds.b 0
#if BLITTER_SUPPORT
		dc.l	hb_cell
		dc.l	hb_scrup
		dc.l	hb_scrdn
		dc.l	hb_blank
		dc.l	hb_bitblt
		dc.l	hb_mono
		dc.l	hb_rect
		dc.l	hb_vline
		dc.l	hb_hline
		dc.l	hb_text
#else
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
		dc.l	hb_nop
#endif

		xdef	_STSoftList		; orig ST routines no blitter
_STSoftList:	ds.b 0
		dc.l	sb_cell			; cell_xfer subroutine
		dc.l	sb_scrup		; p_sc_up   subroutine
		dc.l	sb_scrdn		; p_sc_dn   subroutine
		dc.l	sb_blank		; blank_it  subroutine
		dc.l	sb_bitblt		; bitblt    subroutine
		dc.l	sb_mono			; mono8xh   subroutine
		dc.l	sb_rect			; rect_fill subroutine
		dc.l	sb_vline		; vline     subroutine
		dc.l	sb_hline		; _HABLINE  subroutine
		dc.l	sb_text			; textblt   subroutine

#if !BLITTER_SUPPORT
hb_nop: rts
#endif
