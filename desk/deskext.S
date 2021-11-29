/*
 * These functions are referenced by DESKTOP,
 * but are defined elsewhere
 *
 *
 * This file is only used when linking a single module,
 * to get the same addresses as when linking the whole ROM
 */
#define __ASSEMBLER__ 1

#include "config.h"
#include "../aes/aesdefs.h"
#include "deskdefs.h"
#include "asmdefs.h"
#include "sections.inc"


#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif


/* from AES */

	xdef _xstrpcpy
	xdef _xstrpcat
	xdef _scasb
	xdef _strscn
	xdef _strlen
	xdef _streq
	xdef _fmt_str
	xdef _unfmt_str
	xdef _inf_sset
	xdef _fs_sget
	xdef _inf_gindex
	xdef _inf_what
	xdef _merge_str
	xdef _wildcmp
	xdef _bfill
	xdef _min
	xdef _max
	xdef _rc_copy
	xdef _rc_equal
	xdef _rc_intersect
	xdef _rc_union
	xdef _rc_constrain
	xdef _inside
	xdef _LBCOPY
	xdef _strchk
	xdef _cart_init
	xdef _cart_sfirst
	xdef _c_sfirst
	xdef _cart_snext
	xdef _toupper
	xdef _isdrive
	xdef _rom_ram
	xdef _trap
	xdef _trp14
	xdef _trp14int
	xdef _trp13
	xdef _desknoerr
	xdef _mediach
	
	xdef _dsptch
	xdef _wm_new
	xdef _wm_close
	xdef _wm_delete
	xdef _wm_find
	xdef _wm_update
	xdef _wm_create
	xdef _wm_open
	xdef _wm_get
	xdef _wm_set
	xdef _wm_calc
	xdef _ap_init
	xdef _ap_exit
	xdef _ap_rdwr
	xdef _fs_input
	xdef _rs_sglobe
	xdef _rs_load
	xdef _rs_free
	xdef _rs_obfix
	xdef _rs_gaddr
	xdef _mn_bar
	xdef _do_chg
	xdef _ob_offset
	xdef _ob_order
	xdef _ob_find
	xdef _ob_add
	xdef _ob_draw
	xdef _ob_change
	xdef _ob_center
	xdef _gr_mouse
	xdef _gr_mkstate
	xdef _gr_growbox
	xdef _gr_shrinkbox
	xdef _gr_rubbox
	xdef _ev_multi
	xdef _ev_button
	xdef _ev_dclick
	xdef _fm_do
	xdef _fm_dial
	xdef _fm_alert
	xdef _fm_error
	xdef _sh_get
	xdef _sh_put
	xdef _sh_write
	
	xdef _gsx_sclip
	xdef _gsx_attr
	xdef _gsx_xline
	xdef _avro_cpyfm
	xdef _gsx_ncode
	xdef _av_hardcopy
	
	xdef lmul
	xdef ldiv
	
_trap           equ AESTBASE+$0186
_rom_ram        equ AESTBASE+$6AB4
_cart_init      equ AESTBASE+$9914
_cart_sfirst    equ AESTBASE+$99BE
_c_sfirst       equ AESTBASE+$9AF8
_cart_snext     equ AESTBASE+$99D4
_desknoerr      equ AESTBASE+$BE46
_isdrive        equ AESTBASE+$C204
_LBCOPY         equ AESTBASE+$C4DA
_rc_copy        equ AESTBASE+$C526
_inside         equ AESTBASE+$C532
_rc_equal       equ AESTBASE+$C568
_rc_intersect   equ AESTBASE+$C57E
_rc_union       equ AESTBASE+$C5E8
_rc_constrain   equ AESTBASE+$C640
_min            equ AESTBASE+$C69E
_max            equ AESTBASE+$C6AA
_bfill          equ AESTBASE+$C6BA
_toupper        equ AESTBASE+$C6D0
_strlen         equ AESTBASE+$C6E8
_streq          equ AESTBASE+$C6F8
_xstrpcpy       equ AESTBASE+$C714
_strscn         equ AESTBASE+$C720
_xstrpcat       equ AESTBASE+$C736
_scasb          equ AESTBASE+$C74A
_strchk         equ AESTBASE+$C75E
_fmt_str        equ AESTBASE+$C780
_unfmt_str      equ AESTBASE+$C7B4
_inf_sset       equ AESTBASE+$C812
_fs_sget        equ AESTBASE+$C834
_inf_gindex     equ AESTBASE+$C86E
_inf_what       equ AESTBASE+$C894
_merge_str      equ AESTBASE+$C8C8
_wildcmp        equ AESTBASE+$C982
_trp13          equ AESTBASE+$CB80
_trp14          equ AESTBASE+$CB90
_mediach        equ AESTBASE+$CBDC
_trp14int       equ _trp14
	
_dsptch         equ AESTBASE+$C11A
_wm_create      equ AESTBASE+$8FB2
_wm_open        equ AESTBASE+$90B4
_wm_close       equ AESTBASE+$90CE
_wm_delete      equ AESTBASE+$90E8
_wm_get         equ AESTBASE+$9106
_wm_set         equ AESTBASE+$9224
_wm_find        equ AESTBASE+$9472
_wm_update      equ AESTBASE+$9494
_wm_calc        equ AESTBASE+$94F0
_wm_new         equ AESTBASE+$95A6
_ap_init        equ AESTBASE+$026C
_ap_exit        equ AESTBASE+$02E2
_ap_rdwr        equ AESTBASE+$036E
_fs_input       equ AESTBASE+$3762
_rs_sglobe      equ AESTBASE+$70EE
_rs_load        equ AESTBASE+$7370
_rs_free        equ AESTBASE+$7110
_rs_obfix       equ AESTBASE+$6CEC
_rs_gaddr       equ AESTBASE+$7144
_mn_bar         equ AESTBASE+$5908
_do_chg         equ AESTBASE+$54AA
_ob_offset      equ AESTBASE+$A90A
_ob_order       equ AESTBASE+$A60C
_ob_find        equ AESTBASE+$A3C2
_ob_add         equ AESTBASE+$A4F2
_ob_draw        equ AESTBASE+$A322
_ob_change      equ AESTBASE+$A6EA
_ob_center      equ AESTBASE+$5C7E
_gr_mouse       equ AESTBASE+$4E80
_gr_mkstate     equ AESTBASE+$B8AC
_gr_growbox     equ AESTBASE+$B402
_gr_shrinkbox   equ AESTBASE+$B446
_gr_rubbox      equ AESTBASE+$B6D8
_ev_multi       equ AESTBASE+$26E2
_ev_button      equ AESTBASE+$25C2
_ev_dclick      equ AESTBASE+$2A28
_fm_do          equ AESTBASE+$33D8
_fm_dial        equ AESTBASE+$3550
_fm_alert       equ AESTBASE+$2F38
_fm_error       equ AESTBASE+$368A
_sh_get         equ AESTBASE+$7458
_sh_put         equ AESTBASE+$7478
_sh_write       equ AESTBASE+$7408

_gsx_sclip      equ AESTBASE+$AC70
_gsx_attr       equ AESTBASE+$AD6E
_gsx_xline      equ AESTBASE+$B32C
_avro_cpyfm     equ AESTBASE+$BCAE
_gsx_ncode      equ AESTBASE+$B8FA
_av_hardcopy    equ AESTBASE+$B98E

lmul            equ AESTBASE+$BF78
ldiv            equ AESTBASE+$BFCC


#if !BINEXACT
		xdef _gl_wchar
		comm _gl_wchar,2
		xdef _gl_hchar
		comm _gl_hchar,2
		xdef _gl_wbox
		comm _gl_wbox,2
		xdef _gl_hbox
		comm _gl_hbox,2
		xdef _gl_handle
		comm _gl_handle,2
		xdef _gl_btrue
		comm _gl_btrue,2
		xdef _gl_ncols
		comm _gl_ncols,2
		xdef _gl_nrow
		comm _gl_nrows,2
		xdef _sh_iscart
		comm _sh_iscart,2
#if AESVERSION >= 0x200
		xdef _ctldown
		comm _ctldown,2
#endif
		xdef _gl_restype
		comm _gl_restype,2
		xdef _gl_rschange
		comm _gl_rschange,2
		xdef _gl_bvdisk
		comm _gl_bvdisk,2
		xdef _gl_bvhard
		comm _gl_bvhard,2
		xdef _intin
		comm _intin,256
		xdef _contrl
		comm _contrl,24
		xdef _intout
		comm _intout,256
		xdef _ptsin
		comm _ptsin,40
		xdef _rlr
		comm _rlr,4
		xdef _gl_ws
		comm _gl_ws,4
#endif
