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
#if TOSVERSION >= 0x400
		dc.l	_st_vq_color
		dc.l	_st_vs_color
		dc.l	_init_st_tt_sp
		dc.l	st_cur_display	; show mouse cursor
		dc.l	st_cur_replace	; hide mouse cursor
		dc.l	st_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor	; move cursor to X,Y pos
		dc.l	ST_ABLINE
		dc.l	ST_HABLINE
		dc.l	ST_RECTFILL
		dc.l	ST_PUTPIX		; output pixel out to screen
		dc.l	ST_GETPIX		; get pixel value at X,Y
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
#if TOSVERSION >= 0x400
		dc.l	_st_vq_color
		dc.l	_st_vs_color
		dc.l	_init_st_tt_sp
		dc.l	st_cur_display	; show mouse cursor
		dc.l	st_cur_replace	; hide mouse cursor
		dc.l	st_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor	; move cursor to X,Y pos
		dc.l	ST_ABLINE
		dc.l	ST_HABLINE
		dc.l	ST_RECTFILL
		dc.l	ST_PUTPIX		; output pixel out to screen
		dc.l	ST_GETPIX		; get pixel value at X,Y
#endif

#if !BLITTER_SUPPORT
hb_nop: rts
#endif

#if VIDEL_SUPPORT
		xdef	_PixHardList	; pixel packed routines
		xdef	_PixSoftList	; pixel packed routines
_PixHardList: ds.b 0
_PixSoftList: ds.b 0
		dc.l	spx_cell		; done
		dc.l	spx_scrup		; done  changed 9/2/92
		dc.l	spx_scrdn		; done  changed 9/2/92
		dc.l	spx_blank		; done
		dc.l	spx_bitblt		; done
		dc.l	spx_mono		; done
		dc.l	sb_rect			; done (look PX_RECTFILL)
		dc.l	spx_vline		; done
		dc.l	spx_hline		; done
		dc.l	spx_text
		dc.l	_vq_32_color
		dc.l	_vs_32_color
		dc.l	_Init32Pal		; init sparrow virtual pal
		dc.l	px_cur_display	; show mouse cursor
		dc.l	px_cur_replace	; hide mouse cursor
		dc.l	spx_neg_cell	; negates alpha cursor
		dc.l	st_move_cursor	; move cursor to X,Y pos
		dc.l	PX_ABLINE		; done
		dc.l	PX_HABLINE		; done
		dc.l	PX_RECTFILL		; done
		dc.l	PX_PUTPIX		; output pixel out to screen
		dc.l	PX_GETPIX		; get pixel value at X,Y
#endif

#if VIDEL_SUPPORT
		xdef	_SPPixSoftList	; SPARROW routines (hard blit)
_SPPixSoftList:
		dc.l	spx_cell		; done
		dc.l	spx_scrup		; done
		dc.l	spx_scrdn		; done
		dc.l	spx_blank		; done
		dc.l	spx_bitblt		; done
		dc.l	spx_mono		; done
		dc.l	0				; done (look PX_RECTFILL)
		dc.l	spx_vline		; done
		dc.l	spx_hline		; done
		dc.l	spx_text
		dc.l	_vq_16_color
		dc.l	_vs_16_color
		dc.l	_Init16Pal		; init sparrow virtual pal
		dc.l	px_cur_display	; show mouse cursor
		dc.l	px_cur_replace	; hide mouse cursor
		dc.l	spx_neg_cell	; negates alpha cursor
		dc.l	st_move_cursor	; move cursor to X,Y pos
		dc.l	PX_ABLINE		; done
		dc.l	PX_HABLINE		; done
		dc.l	PX_RECTFILL		; done
		dc.l	PX_PUTPIX		; output pixel out to screen
		dc.l	PX_GETPIX		; get pixel value at X,Y
#endif

#if VIDEL_SUPPORT
		xdef	_SPPixHardList		; SPARROW routines (hard blit)
_SPPixHardList:
		dc.l	spx_cell		; done
		dc.l	spx_scrup		; done
		dc.l	spx_scrdn		; done
		dc.l	spx_blank		; done
		dc.l	hpx_bitblt		; done
		dc.l	spx_mono		; done
		dc.l	0				; done (look PX_RECTFILL)
		dc.l	spx_vline		; done
		dc.l	spx_hline		; done
		dc.l	spx_text
		dc.l	_vq_16_color
		dc.l	_vs_16_color
		dc.l	_Init16Pal		; init sparrow virtual pal
		dc.l	px_cur_display	; show mouse cursor
		dc.l	px_cur_replace	; hide mouse cursor
		dc.l	spx_neg_cell	; negates alpha cursor
		dc.l	st_move_cursor	; move cursor to X,Y pos
		dc.l	PX_ABLINE		; done
		dc.l	PX_HABLINE		; done
		dc.l	PX_RECTFILL		; done
		dc.l	PX_PUTPIX		; output pixel out to screen
		dc.l	PX_GETPIX		; get pixel value at X,Y
#endif
