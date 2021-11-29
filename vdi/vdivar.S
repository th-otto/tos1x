/*******************************  vdivar.s  ***********************************
 *
 * ============================================================================
 * $Author: lozben $	$Date: 91/09/10 19:58:36 $
 * ============================================================================
 *
 * Revision 3.4  91/09/10  19:58:36  lozben
 * Deleted the _q_circle declaration from the overlay variable space.
 *
 * Revision 3.3  91/08/06  20:32:02  lozben
 * Added variables _copytran, fringe0, innerLoop, fringe1
 *
 * Revision 3.2  91/07/30  17:44:44  lozben
 * Made some minor adjustments to work with all the vdi files that use this
 * variable space.
 *
 * Revision 3.1  91/01/16  12:13:10  lozben
 * Deleted all the non overlay variables (linea var struct).
 *
 * Revision 3.0  91/01/03  15:23:20  lozben
 * New generation VDI
 *
 ******************************************************************************/

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"

		bss
		even

	xdef _dskbuf
_dskbuf: ds.b OVLSIZE

#define _fill_buffer _dskbuf

SIZE_FONT_HEAD	equ	90	     * size of font_head structure in FONTDEF.H

*****************************************
*	Overlayable Variables               *
*****************************************

		xdef	_FLIP_Y
		xdef	_Q
		xdef	_Qbottom
		xdef	_charx
		xdef	_chary
		xdef	_collision
		xdef	_deftxbu
		xdef	_direction
		xdef	_done
		xdef	_gotseed
		xdef	_h_align
		xdef	_leftoldy
		xdef	_leftdirection
		xdef	_leftseed
		xdef	_leftcollision
		xdef	_newxleft
		xdef	_newxright
		xdef	_oldxleft
		xdef	_oldxright
		xdef	_oldy
		xdef	_rmchar
		xdef	_rmcharx
		xdef	_rmchary
		xdef	_rmword
		xdef	_rmwordx
		xdef	_rmwordy
		xdef	_search_color
		xdef	_seed_type
		xdef	_v_align
		xdef	_wordx
		xdef	_wordy
		xdef	_xleft
		xdef	_xright
		xdef	_copytran
		xdef	ptsin_array
		xdef	fringe0
		xdef	innerLoop
		xdef	fringe1


_seed_type	equ	_fill_buffer+00		; indicates the type of fill
#if !VIDEL_SUPPORT
_search_color	equ	_fill_buffer+02		; the color of the border
#endif
_Qbottom	equ	_fill_buffer+04	 	; the bottom of the Q (zero)
#if TOSVERSION >= 0x300
		xdef	_Qtop
_Qtop		equ	_fill_buffer+06	 	; points top seed +3
		xdef	_Qptr
_Qptr		equ	_fill_buffer+08	 	; points to the active point
#else
		xdef	_qTop
_qTop		equ	_fill_buffer+06	 	; points top seed +3
		xdef	_qPtr
_qPtr		equ	_fill_buffer+08	 	; points to the active point
		xdef	_qTmp
_qTmp		equ	_fill_buffer+10
		xdef	_qHole
_qHole		equ	_fill_buffer+12		; an empty space in the Q
#endif
_oldy		equ	_fill_buffer+14		; the previous scan line
_oldxleft	equ	_fill_buffer+16		; left end of line at oldy
_oldxright	equ	_fill_buffer+18		; right end
_newxleft	equ	_fill_buffer+20		; ends of line at oldy +
_newxright	equ	_fill_buffer+22		;     the current direction
_xleft		equ	_fill_buffer+24		; temporary endpoints
_xright		equ	_fill_buffer+26
_direction	equ	_fill_buffer+28		; is next scan line up or down?
_done		equ	_fill_buffer+30		; is the seed queue full?
_gotseed	equ	_fill_buffer+32		; a seed was put in the Q
_leftoldy	equ	_fill_buffer+34 	; like _oldy. (new seedfill)
_leftdirection	equ	_fill_buffer+36 	; like _direction. (new seedfill)
_leftseed	equ	_fill_buffer+38 	; like _gotseed. (new seedfill)
_h_align	equ	_fill_buffer+40
_leftcollision	equ	_fill_buffer+40 	; like _collision. (new seedfill)
_v_align	equ	_fill_buffer+42		; scaler alignments
#if TOSVERSION >= 0x200
		xdef	_width
_width		equ	_fill_buffer+44
#endif
_collision	equ	_fill_buffer+42  	; seed was removed from Q (new rtn)
#if VIDEL_SUPPORT
_search_color	equ	_fill_buffer+44		; the color of the border
_Q		equ	_fill_buffer+48	 	; storage for the seed points (1280)
#else
_Q		equ	_fill_buffer+44	 	; storage for the seed points (1280)
#endif
#if TOSVERSION >= 0x200
		xdef	_height
_height		equ	_fill_buffer+46		; extent of string set in dqt_extent
#endif
_wordx		equ	_fill_buffer+48
_wordy		equ	_fill_buffer+50		; add this to each space for interword
_rmword		equ	_fill_buffer+52		; the number of pixels left over
_rmwordx	equ	_fill_buffer+54
_rmwordy	equ	_fill_buffer+56		; add this to use up remainder
_charx		equ	_fill_buffer+58
_chary		equ	_fill_buffer+60	 	; inter-character distance
_rmchar		equ	_fill_buffer+62		; number of pixels left over
_rmcharx	equ	_fill_buffer+64
_rmchary	equ	_fill_buffer+66		; add this to use up remainder
_FLIP_Y		equ	_fill_buffer+68		; Non-zero PTSOUT contains magnitudes
_copytran	equ	_fill_buffer+72		;
#if TOSVERSION >= 0x300
ptsin_array	equ	_fill_buffer+250	; copy of ptsin[] (4096 bytes)
fringe0		equ	_fill_buffer+1000	; area to compile routines in
innerLoop	equ	_fill_buffer+2000	; area to compile routines in
fringe1		equ	_fill_buffer+3000	; area to compile routines in
_deftxbu	equ	_fill_buffer+4500	; scratch buf for 8x16 (276 bytes)
#else
ptsin_array	equ	_fill_buffer+768	; copy of ptsin[] (4096 bytes)
fringe0		equ	_fill_buffer+1000	; area to compile routines in
innerLoop	equ	_fill_buffer+2000	; area to compile routines in
fringe1		equ	_fill_buffer+3000	; area to compile routines in
_deftxbu	equ	_fill_buffer+236	; scratch buf for 8x16 (276 bytes)
#endif

	xdef _vdivars
_vdivars: ds.b 910 ; space for negative linea vars
    xdef lineavars
lineavars:
#if TOSVERSION >= 0x400
	ds.b 4018
#else
#if TOSVERSION >= 0x300
	ds.b 2310
#else
#if TOSVERSION >= 0x200
	ds.b 172
#else
	ds.b 172
#endif
#endif
#endif

#if LINEA_HACK

	xdef _angle
_angle: equ lineavars+(angle)
	xdef _beg_ang
_beg_ang: equ lineavars+(beg_ang)
	xdef _CUR_FONT
_CUR_FONT: equ lineavars+(CUR_FONT)
	xdef _del_ang
_del_ang: equ lineavars+(del_ang)
	xdef _deltay
_deltay: equ lineavars+(deltay)
	xdef _deltay1
_deltay1: equ lineavars+(deltay1)
	xdef _deltay2
_deltay2: equ lineavars+(deltay2)
	xdef _end_ang
_end_ang: equ lineavars+(end_ang)
	xdef _fil_intersect
_fil_intersect: equ lineavars+(fil_intersect)
	xdef _fill_maxy
_fill_maxy: equ lineavars+(fill_maxy)
	xdef _fill_miny
_fill_miny: equ lineavars+(fill_miny)
	xdef _n_steps
_n_steps: equ lineavars+(n_steps)
	xdef _odeltay
_odeltay: equ lineavars+(odeltay)
	xdef _s_begsty
_s_begsty: equ lineavars+(s_begsty)
	xdef _s_endsty
_s_endsty: equ lineavars+(s_endsty)
	xdef _s_fil_col
_s_fil_col: equ lineavars+(s_fil_col)
	xdef _s_fill_per
_s_fill_per: equ lineavars+(s_fill_per)
	xdef _s_patmsk
_s_patmsk: equ lineavars+(s_patmsk)
	xdef _s_patptr
_s_patptr: equ lineavars+(s_patptr)
	xdef _start
_start: equ lineavars+(start)
	xdef _xc
_xc: equ lineavars+(xc)
	xdef _xrad
_xrad: equ lineavars+(xrad)
	xdef __Y
__Y: equ lineavars+(_Y)
	xdef _yc
_yc: equ lineavars+(yc)
	xdef _yrad
_yrad: equ lineavars+(yrad)
	xdef _m_poshx
_m_poshx: equ lineavars+(m_poshx)
	xdef _m_poshy
_m_poshy: equ lineavars+(m_poshy)
	xdef _m_planes
_m_planes: equ lineavars+(m_planes)
	xdef _m_cdb_bg
_m_cdb_bg: equ lineavars+(m_cdb_bg)
	xdef _m_cdb_fg
_m_cdb_fg: equ lineavars+(m_cdb_fg)
	xdef _mask_form
_mask_form: equ lineavars+(mask_form)
	xdef _INQ_TAB
_INQ_TAB: equ lineavars+(INQ_TAB)
	xdef _DEV_TAB
_DEV_TAB: equ lineavars+(DEV_TAB)
	xdef _GCURX
_GCURX: equ lineavars+(GCURX)
	xdef _GCURY
_GCURY: equ lineavars+(GCURY)
	xdef _HIDE_CNT
_HIDE_CNT: equ lineavars+(HIDE_CNT)
	xdef _MOUSE_BT
_MOUSE_BT: equ lineavars+(MOUSE_BT)
	xdef _REQ_COL
_REQ_COL: equ lineavars+(REQ_COL)
	xdef _SIZ_TAB
_SIZ_TAB: equ lineavars+(SIZ_TAB)
	xdef _TERM_CH
_TERM_CH: equ lineavars+(TERM_CH)
	xdef _chc_mode
_chc_mode: equ lineavars+(chc_mode)
	xdef _cur_work
_cur_work: equ lineavars+(cur_work)
	xdef _def_font
_def_font: equ lineavars+(def_font)
	xdef _font_ring
_font_ring: equ lineavars+(font_ring)
	xdef _ini_font_count
_ini_font_count: equ lineavars+(ini_font_count)
	xdef _line_cw
_line_cw: equ lineavars+(line_cw)
	xdef _loc_mode
_loc_mode: equ lineavars+(loc_mode)
	xdef _num_qc_lines
_num_qc_lines: equ lineavars+(num_qc_lines)
#if TOSVERSION >= 0x300
	xdef _trap14sav
_trap14sav: equ lineavars+(trap14sav)
	xdef _col_or_mask
_col_or_mask: equ lineavars+(col_or_mask)
	xdef _col_and_mask
_col_and_mask: equ lineavars+(col_and_mask)
	xdef _trapb14sav
_trapb14sav: equ lineavars+(trapb14sav)
	xdef _resrvd0
_resrvd0: equ lineavars+(resrvd0)
#else
	xdef _q_circle
_q_circle: equ lineavars+(q_circle)
#endif
	xdef _str_mode
_str_mode: equ lineavars+(str_mode)
	xdef _val_mode
_val_mode: equ lineavars+(val_mode)
	xdef _cur_ms_stat
_cur_ms_stat: equ lineavars+(cur_ms_stat)
	xdef _resrvd1
_resrvd1: equ lineavars+(resrvd1)
	xdef _disab_cnt
_disab_cnt: equ lineavars+(disab_cnt)
	xdef _xydraw
_xydraw: equ lineavars+(xydraw)
	xdef _draw_flag
_draw_flag: equ lineavars+(draw_flag)
	xdef _mouse_flag
_mouse_flag: equ lineavars+(mouse_flag)
	xdef _retsav
_retsav: equ lineavars+(retsav)
	xdef _sav_cxy
_sav_cxy: equ lineavars+(sav_cxy)
	xdef _save_len
_save_len: equ lineavars+(save_len)
	xdef _save_addr
_save_addr: equ lineavars+(save_addr)
	xdef _save_stat
_save_stat: equ lineavars+(save_stat)
	xdef _save_area
_save_area: equ lineavars+(save_area)
	xdef _tim_addr
_tim_addr: equ lineavars+(tim_addr)
	xdef _tim_chain
_tim_chain: equ lineavars+(tim_chain)
	xdef _user_but
_user_but: equ lineavars+(user_but)
	xdef _user_cur
_user_cur: equ lineavars+(user_cur)
	xdef _user_mot
_user_mot: equ lineavars+(user_mot)
	xdef _v_cel_ht
_v_cel_ht: equ lineavars+(v_cel_ht)
	xdef _v_celmx
_v_celmx: equ lineavars+(v_celmx)
	xdef _v_celmy
_v_celmy: equ lineavars+(v_celmy)
	xdef _v_cel_wr
_v_cel_wr: equ lineavars+(v_cel_wr)
	xdef _v_col_bg
_v_col_bg: equ lineavars+(v_col_bg)
	xdef _v_col_fg
_v_col_fg: equ lineavars+(v_col_fg)
	xdef _v_cur_ad
_v_cur_ad: equ lineavars+(v_cur_ad)
	xdef _v_cur_off
_v_cur_off: equ lineavars+(v_cur_off)
	xdef _v_curcx
_v_curcx: equ lineavars+(v_curcx)
	xdef _v_curcy
_v_curcy: equ lineavars+(v_curcy)
	xdef _vct_init
_vct_init: equ lineavars+(vct_init)
	xdef _v_cur_tim
_v_cur_tim: equ lineavars+(v_cur_tim)
	xdef _v_fnt_ad
_v_fnt_ad: equ lineavars+(v_fnt_ad)
	xdef _v_fnt_nd
_v_fnt_nd: equ lineavars+(v_fnt_nd)
	xdef _v_fnt_st
_v_fnt_st: equ lineavars+(v_fnt_st)
	xdef _v_fnt_wr
_v_fnt_wr: equ lineavars+(v_fnt_wr)
	xdef _v_hz_rez
_v_hz_rez: equ lineavars+(v_hz_rez)
	xdef _v_off_ad
_v_off_ad: equ lineavars+(v_off_ad)
	xdef _v_stat_0
_v_stat_0: equ lineavars+(v_stat_0)
	xdef _v_delay
_v_delay: equ lineavars+(v_delay)
	xdef _v_vt_rez
_v_vt_rez: equ lineavars+(v_vt_rez)
	xdef _bytes_lin
_bytes_lin: equ lineavars+(bytes_lin)
	xdef _v_planes
_v_planes: equ lineavars+(v_planes)
	xdef _v_lin_wr
_v_lin_wr: equ lineavars+(v_lin_wr)
	xdef _CONTRL
_CONTRL: equ lineavars+(CONTRL)
	xdef _INTIN
_INTIN: equ lineavars+(INTIN)
	xdef _PTSIN
_PTSIN: equ lineavars+(PTSIN)
	xdef _INTOUT
_INTOUT: equ lineavars+(INTOUT)
	xdef _PTSOUT
_PTSOUT: equ lineavars+(PTSOUT)
	xdef _FG_BP_1
_FG_BP_1: equ lineavars+(FG_BP_1)
	xdef _FG_BP_2
_FG_BP_2: equ lineavars+(FG_BP_2)
	xdef _FG_BP_3
_FG_BP_3: equ lineavars+(FG_BP_3)
	xdef _FG_BP_4
_FG_BP_4: equ lineavars+(FG_BP_4)
	xdef _LSTLIN
_LSTLIN: equ lineavars+(LSTLIN)
	xdef _LN_MASK
_LN_MASK: equ lineavars+(LN_MASK)
	xdef _WRT_MODE
_WRT_MODE: equ lineavars+(WRT_MODE)
	xdef _X1
_X1: equ lineavars+(X1)
	xdef _Y1
_Y1: equ lineavars+(Y1)
	xdef _X2
_X2: equ lineavars+(X2)
	xdef _Y2
_Y2: equ lineavars+(Y2)
	xdef _patptr
_patptr: equ lineavars+(patptr)
	xdef _patmsk
_patmsk: equ lineavars+(patmsk)
	xdef _multifill
_multifill: equ lineavars+(multifill)
	xdef _CLIP
_CLIP: equ lineavars+(CLIP)
	xdef _XMN_CLIP
_XMN_CLIP: equ lineavars+(XMN_CLIP)
	xdef _YMN_CLIP
_YMN_CLIP: equ lineavars+(YMN_CLIP)
	xdef _XMX_CLIP
_XMX_CLIP: equ lineavars+(XMX_CLIP)
	xdef _YMX_CLIP
_YMX_CLIP: equ lineavars+(YMX_CLIP)
	xdef _XACC_DDA
_XACC_DDA: equ lineavars+(XACC_DDA)
	xdef _DDA_INC
_DDA_INC: equ lineavars+(DDA_INC)
	xdef _T_SCLSTS
_T_SCLSTS: equ lineavars+(T_SCLSTS)
	xdef _MONO_STATUS
_MONO_STATUS: equ lineavars+(MONO_STATUS)
	xdef _SOURCEX
_SOURCEX: equ lineavars+(SOURCEX)
	xdef _SOURCEY
_SOURCEY: equ lineavars+(SOURCEY)
	xdef _DESTX
_DESTX: equ lineavars+(DESTX)
	xdef _DESTY
_DESTY: equ lineavars+(DESTY)
	xdef _DELX
_DELX: equ lineavars+(DELX)
	xdef _DELY
_DELY: equ lineavars+(DELY)
	xdef _FBASE
_FBASE: equ lineavars+(FBASE)
	xdef _FWIDTH
_FWIDTH: equ lineavars+(FWIDTH)
	xdef _STYLE
_STYLE: equ lineavars+(STYLE)
	xdef _LITEMASK
_LITEMASK: equ lineavars+(LITEMASK)
	xdef _SKEWMASK
_SKEWMASK: equ lineavars+(SKEWMASK)
	xdef _WEIGHT
_WEIGHT: equ lineavars+(WEIGHT)
	xdef _R_OFF
_R_OFF: equ lineavars+(R_OFF)
	xdef _L_OFF
_L_OFF: equ lineavars+(L_OFF)
	xdef _SCALE
_SCALE: equ lineavars+(SCALE)
	xdef _CHUP
_CHUP: equ lineavars+(CHUP)
	xdef _TEXT_FG
_TEXT_FG: equ lineavars+(TEXT_FG)
	xdef _scrtchp
_scrtchp: equ lineavars+(scrtchp)
	xdef _scrpt2
_scrpt2: equ lineavars+(scrpt2)
	xdef _TEXT_BG
_TEXT_BG: equ lineavars+(TEXT_BG)
	xdef _COPYTRAN
_COPYTRAN: equ lineavars+(COPYTRAN)
	xdef _quitfill
_quitfill: equ lineavars+(quitfill)
	xdef _USERDEVINIT
_USERDEVINIT: equ lineavars+(USERDEVINIT)
	xdef _USERESCINIT
_USERESCINIT: equ lineavars+(USERESCINIT)
	xdef _resrvd2
_resrvd2: equ lineavars+(resrvd2)
#if TOSVERSION >= 0x400
	xdef _LA_ROUTINES
_LA_ROUTINES: equ lineavars+(LA_ROUTINES)
	xdef _CUR_DEV
_CUR_DEV: equ lineavars+(CUR_DEV)
#else
	xdef _LA_ROUTINES
_LA_ROUTINES: equ lineavars+(LA_ROUTINES)
	xdef _LA_SOFTROUTINES
_LA_SOFTROUTINES: equ lineavars+(LA_SOFTROUTINES)
#endif
	xdef _BLT_MODE
_BLT_MODE: equ lineavars+(BLT_MODE)

#if PLANES8

	xdef _LA_F32
_LA_F32: equ lineavars+(LA_F32)
	xdef _REQ_X_COL
_REQ_X_COL: equ lineavars+(REQ_X_COL)
	xdef _sv_blk_ptr
_sv_blk_ptr: equ lineavars+(sv_blk_ptr)
	xdef _FG_B_PLANES
_FG_B_PLANES: equ lineavars+(FG_B_PLANES)
	xdef _FG_BP_5
_FG_BP_5: equ lineavars+(FG_BP_5)
	xdef _FG_BP_6
_FG_BP_6: equ lineavars+(FG_BP_6)
	xdef _FG_BP_7
_FG_BP_7: equ lineavars+(FG_BP_7)
	xdef _FG_BP_8
_FG_BP_8: equ lineavars+(FG_BP_8)
	xdef _sav8_len
_sav8_len: equ lineavars+(sav8_len)
	xdef _sav8_addr
_sav8_addr: equ lineavars+(sav8_addr)
	xdef _sav8_stat
_sav8_stat: equ lineavars+(sav8_stat)
	xdef _sav8_area
_sav8_area: equ lineavars+(sav8_area)
	xdef _q_circle
_q_circle: equ lineavars+(q_circle)
#if VIDEL_SUPPORT
	xdef _byt_per_pix
_byt_per_pix: equ lineavars+(byt_per_pix)
	xdef _form_id
_form_id: equ lineavars+(form_id)
	xdef _vl_col_bg
_vl_col_bg: equ lineavars+(vl_col_bg)
	xdef _vl_col_fg
_vl_col_fg: equ lineavars+(vl_col_fg)
	xdef _pal_map
_pal_map: equ lineavars+(pal_map)
	xdef _V_PRIMITIVES
_V_primitives: equ lineavars+(V_PRIMITIVES)
#endif /* VIDEL_SUPPORT */

#endif /* PLANES8 */

#endif /* LINEA_HACK */
