********************************  escape.s  ***********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/02/19 15:30:42 $
* =============================================================================
*
* Revision 3.4  91/02/19  15:30:42  lozben
* Made the file work with multiple linea var structures.
*
* Revision 3.3  91/02/12  16:39:49  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.2  91/01/31  11:39:12  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:07:06  lozben
* New generation VDI
*
* Revision 2.7  90/10/10  13:03:23  lozben
* Fixed a bug in set foreground and background (esc b and c) routines.
* The routines subtracted 32 from the input. They no longer do that..
*
* Revision 2.6  90/07/16  16:38:06  lozben
* Added negative clipping in cell_addr().
*
* Revision 2.5  90/03/14  20:33:41  lozben
* Optimized (for speed) the neg_cell() routine.
*
* Revision 2.4  90/02/26  17:39:03  lozben
* Fixed the code to work with turbo assembler.
*
* Revision 2.3  90/02/09  18:37:59  lozben
* We don't use v_cel_wr flag any more. Now the code looks at the
* offset table to determine if cell width is 8 or 16 bits. Also
* fixed a bug in calculating the relative character position in
* the font offset table.
*
* Revision 2.2  90/01/18  15:53:03  lozben
* Moved hb_cell(), hb_scrup(), hb_scrdn(), hb_rect() into another file.
* The idea is to have all the hard blit code in independent files.
* Also Made changes to be able to deal with wordwide monospaced
* font.
*
* Revision 2.1  89/02/21  17:19:03  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"
#include "sections.inc"
#include "asmdefs.h"

ldri_escape	equ	19	; last DRI escape = 19.

#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif

*
*	font header structure equates.
*

FIRST		equ	36
LAST		equ	38
CEL_WD		equ	52
POFF		equ	72
PDAT		equ	76
FRM_WD		equ	80
FRM_HT		equ	82

M_CFLASH	equ	$0001	; cursor flash			0:disabled
F_CFLASH	equ	    0	;				1:enabled
M_CSTATE	equ	$0002	; cursor flash state		0:off
F_CSTATE	equ	    1	; 				1:on

M_CEOL		equ	$0008	; cursor end of line handling	0:overwrite
F_CEOL		equ	    3	;				1:wrap

M_REVID		equ	$0010	; reverse video			0:on
F_REVID		equ	    4	;				1:off

M_SVPOS		equ	$0020	; position saved flag		0:false
F_SVPOS		equ	    5	;				1:true

F_BLINK     equ 6



	text

*******************************************************************************
*                                                                             *
*       _v_escape:                                                            *
*               This routine decodes the escape functions.                    *
*                                                                             *
*               input:  CONTRL[5] = escape function ID.                       *
*                       CONTRL[6] = device handle.                            *
*                       INTIN[]   = array of input parameters.                *
*                       PTSIN[]   = array of input vertices.                  *
*                                                                             *
*               output: CONTRL[2] = number of output vertices.                *
*                       CONTRL[4] = number of output parameters.              *
*                       INTOUT[]  = array of output parameters.               *
*                       PTSOUT[]  = array of output vertices.                 *
*                                                                             *
*               destroys: everything.                                         *
*                                                                             *
*******************************************************************************

/* 306de: 00e07226 */
/* 206de: 00e06094 */
/* 104de: 00fca2ec */
/* 106de: 00e0a518 */
/* 100fr: 00fc414c */
	xdef	_v_escape
_v_escape:
    move.l  _CONTRL,a0
	move.w	10(a0),d0		; d0 <- ID.
	cmp.w	#ldri_escape,d0 	; compare with DRI limit.
	bhi	ce_more			; if ID > last DRI escape, branch.

    asl.w   #1,d0
	move.w	esc_tbl(pc,d0.w),a0	; a0 <- offset to escape code
	adda.l  #esc_base,a0
	jmp	(a0)	; jump to the escape function

esc_tbl:

	dc.w	v_esc_nop-esc_base		; not implemented
	dc.w	vq_chcells-esc_base		; inquire addressable alpha char cells
	dc.w	v_exit_cur-esc_base		; exit alpha mode
	dc.w	v_enter_cur-esc_base	; enter alpha mode
	dc.w	v_curup-esc_base		; alpha cursor up
	dc.w	v_curdown-esc_base		; alpha cursor down
	dc.w	v_curright-esc_base		; alpha cursor right
	dc.w	v_curleft-esc_base		; alpha cursor left
	dc.w	v_curhome-esc_base		; home alpha cursor
	dc.w	v_eeos-esc_base			; erase to end of alpha screen
	dc.w	v_eeol-esc_base			; erase to end of alpha text line
	dc.w	vs_curaddress-esc_base	; direct alpha cursor address
	dc.w	vs_curtext-esc_base		; output cursor addressable alpha text
	dc.w	v_rvon-esc_base			; reverse video on
	dc.w	v_rvoff-esc_base		; reverse video off
	dc.w	vq_curaddress-esc_base	; inquire current alpha cursor address
	dc.w	vq_tabstatus-esc_base	; inquire tablet status
	dc.w	v_hardcopy-esc_base		; hardcopy
	dc.w	v_dspcur-esc_base		; place graphic cursor at location
	dc.w	v_rmcur-esc_base		; remove last graphic cursor


ce_more:

	cmp.w	#101,d0			; function 101: a silly routine that
	beq	v_offset		; sorta offsets the cursor in Y

	cmp.w	#102,d0			; function 102: user defined font
	beq	v_fontinit		; yes, branch.

	rts


/*
 * VDI #5,101 - v_offset - Set screen offset
 */
v_offset:

	bsr	hide_cursor		; INTIN+00 = Y displacement on cursor
	move.l	_INTIN,a0
	move.w	(a0),d0
	mulu	_v_lin_wr,d0
	move.w	d0,_v_cur_off	; d0 <- additional cursor y offset.
	bra	show_cursor		; show cursor.


*    This console out routine doesn't interpret control characters,
*    it just prints them.

/* 306de: 00e07292 */
/* 206de: 00e06100 */
/* 104de: 00fca358 */
/* 106de: 00e0a584 */
/* 100fr: 00fc41be */
	xdef	_asc_out
_asc_out: ds.b 0
/*
 * Bconout function for device 5 (screen)
 */
	xdef	_bcon5out
_bcon5out: ds.b 0

	move.w	6(sp),d1		; Get character from bios call
	andi.w	#$00FF,d1		; Limit to the chars we have
	bra	ascii_out		; go print it.


*    This is the standard console out.

	xdef	_con_out
_con_out: ds.b 0
	xdef	conout
conout: ds.b 0
/*
 * Bconout function for device 2 (console)
 */
/* 306de: 00e0729e */
/* 206de: 00e0610c */
/* 104de: 00fca364 */
/* 106de: 00e0a590 */
/* 100fr: 00fc41ca */
	xdef _bcon2out
_bcon2out: ds.b 0

	move.w	6(sp),d1		; Get character from bios call


*    VDI entry point: d1 contains ascii code

	xdef	gsx_conout
gsx_conout:
	andi.w	#$00FF,d1		; Limit to the chars we have
	move.l	con_state,a0		; based on our state goto the correct
	jmp	(a0)			; stub routine


/* 306de: 00e072b4 */
/* 206de: 00e06122 */
/* 104de: 00fca37a */
	xdef	normal_ascii
normal_ascii:

	cmp.w	#$20,d1			; If the character is printable ascii
	bge	ascii_out		; go print it.


*   We handle the following control characters as special.
*   All others are thrown away.
*
*	 7 = bell
*	 8 = backspace
*	 9 = Horizontal tab
*	10 = Line feed
*	11 = Vertical tab	(Treated as line feed)
*	12 = Form Feed		(Treated as line feed)
*	13 = Carriage Return
*	27 = Escape		(Begin command sequence)


	cmp.b	#27,d1			; control characters are handled
	bne	handle_control		; immediately

	move.l #esc_ch1,con_state		; wait for the next character
	rts		; in the escape sequence.


handle_control:

	subq.w	#7,d1			; Range check the character against
	bmi	exit_conout		; the ones we handle, and exit if out
	cmp.w	#6,d1			; of range.
	bgt	exit_conout

	lsl.w      #1,d1		; d1 <- offset to the offset
	move.w	ctrl_tbl(pc,d1.w),a0	; d1 <- offset to the control routine
	add.l #ctrl_base,a0
	jmp	(a0)


ctrl_tbl:

	dc.w	 do_bell-ctrl_base	; ^G  Bell
	dc.w	    escD-ctrl_base	; ^H  Backspace
	dc.w	  do_tab-ctrl_base	; ^I  Horizontal Tab
	dc.w	ascii_lf-ctrl_base	; ^J  Line Feed
	dc.w	ascii_lf-ctrl_base	; ^K  Vertical Tab
	dc.w	ascii_lf-ctrl_base	; ^L  Form Feed
	dc.w	ascii_cr-ctrl_base	; ^M  Carriage Return

/* base for A2M table */
atm_base: ds.b 0

exit_conout: ds.b 0
	rts

/* base for ctrl table */
ctrl_base: ds.b 0

do_bell: ds.b 0

	bra.w ringbell


do_tab:

	move.w	_v_curcx,d0		; d0 <- cursor cell X
	andi.w	#$FFF8,d0		; d0 <- previous 8 cell boundry
	addq.w	#8,d0			; d0 <- next 8 cell boundry
	move.w	_v_curcy,d1		; d1 <- cursor cell Y
	bra	move_cursor




* Handle the first character of an escape sequence

esc_ch1:

	move.l #normal_ascii,con_state	; Most functions only use 1 additional
			/* character so default to normal ascii */
	sub.w	#$41,d1			; state.  Bias by lowest character
	bmi	exit_conout		; value. Exit if invalid.

	cmp.w	#12,d1			; If in the range A-M go handle
	ble		range_A2M

	cmp.w	#24,d1			; <esc> Y is direct cursor addressing
	bne	check_low_case		; and takes 2 additional characters

	move.l #get_row,con_state		; 1st, fetch the cell Y

	rts




get_row:

	sub.w	#$20,d1			; Remove space bias

	move.w	d1,_save_row		; and save until command complete
	move.l #get_column,con_state	; now, fetch the cell X
	rts


get_column:

	sub.w	#$20,d1			; Remove space bias
	/* range check done in move_cursor */
	move.w	d1,d0			; d0 <- cell X
	move.w	_save_row,d1	; d1 <- cell Y

	move.l #normal_ascii,con_state	; we have what we need.
	bra	move_cursor		; move cursor


check_low_case:

	sub.w	#$21,d1			; see if b to w range
	bmi	exit_conout

	cmp.w	#21,d1
	ble	range_b2w

	rts


range_A2M:

	lsl.w      #1,d1
	move.w	A2M_tbl(pc,d1.w),a0
	adda.l #exit_conout,a0
	jmp	(a0)


range_b2w:

	lsl.w      #1,d1
	move.w	b2w_tbl(pc,d1.w),a0
	adda.l #exit_conout,a0
	jmp	(a0)


*******************************************************************************
**	escape b.
**			     Set Foreground Color.
*******************************************************************************

get_fg_col:
		move.l #set_fg_col,con_state
		rts		; Next char is the FG color

set_fg_col:
		move.l #normal_ascii,con_state
		sub.w     #$0020,d1
		move.w     d1,d0
		bra set_fgcol	; set the foreground color.


*******************************************************************************
**	escape c.
**			     Set Background Color.
*******************************************************************************

get_bg_col:
		move.l #set_bg_col,con_state	; Next char is the BG color
		rts


set_bg_col:
		move.l #normal_ascii,con_state
		sub.w     #$0020,d1
		move.w     d1,d0
		bra set_bgcol	; set the foreground color.



A2M_tbl:

	dc.w	       escA-atm_base	; <Esc> A  Cursor Up
	dc.w	       escB-atm_base	; <Esc> B  Cursor Down
	dc.w	       escC-atm_base	; <Esc> C  Cursor Right
	dc.w	       escD-atm_base	; <Esc> D  Cursor Left
	dc.w	       escE-atm_base	; <Esc> E  Clear and Home
	dc.w	exit_conout-atm_base	; <Esc> F  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> G  *** not supported
	dc.w	       escH-atm_base	; <Esc> H  Home
	dc.w	       escI-atm_base	; <Esc> I  Reverse Line Feed
	dc.w	       escJ-atm_base	; <Esc> J  Erase to End of Screen
	dc.w	       escK-atm_base	; <Esc> K  Erase to End of Line
	dc.w	       escL-atm_base	; <Esc> L  Insert Line
	dc.w	       escM-atm_base	; <Esc> M  Delete Line


b2w_tbl:

	dc.w	 get_fg_col-atm_base	; <Esc> b  Set fore color (1 more char)
	dc.w	 get_bg_col-atm_base	; <Esc> c  Set back color (1 more char)
	dc.w	       escd-atm_base	; <Esc> d  Erase from beginning of page
	dc.w	       esce-atm_base	; <Esc> e  Cursor On
	dc.w	       escf-atm_base	; <Esc> f  Cursor Off
	dc.w	exit_conout-atm_base	; <Esc> g  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> h  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> i  *** not supported
	dc.w	       escj-atm_base	; <Esc> j  Save Cursor Position
	dc.w	       esck-atm_base	; <Esc> h  Restore Cursor position
	dc.w	       escl-atm_base	; <Esc> i  Erase line
	dc.w	exit_conout-atm_base	; <Esc> m  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> n  *** not supported
	dc.w	       esco-atm_base	; <Esc> o  Erase from Beginning of Line
	dc.w	       escp-atm_base	; <Esc> p  Reverse Video On
	dc.w	       escq-atm_base	; <Esc> q  Reverse Video Off
	dc.w	exit_conout-atm_base	; <Esc> r  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> s  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> t  *** not supported
	dc.w	exit_conout-atm_base	; <Esc> u  *** not supported
	dc.w	       escv-atm_base	; <Esc> v  Wrap at End of Line
	dc.w	       escw-atm_base	; <Esc> w  Overwrite at End of Line



*******************************************************************************
**	VDI #5,1 - vq_chcells - Inquire Addressable Alpha Character Cells.
*******************************************************************************

/* 306de: 00e073e6 */
/* 206de: 00e0625a */
/* 104de: 00fca4b6 */
/* 106de: 00e0a6e2 */
vq_chcells:
		move.l	_CONTRL,a0		; a0 -> CONTRL array.
		move.w	#2,8(a0)		; 2 integers are returned.

		move.l	_INTOUT,a0		; a0 -> INTOUT array.
		move.w	_v_celmx,d0		; d0 <- cell Xmax (zero based)
		addq.w	#1,d0			; d0 <- number of columns
		move.w	d0,2(a0)
		move.w	_v_celmy,d0		; d0 <- cell Ymax (zero based)
		addq.w	#1,d0			; d0 <- number of rows
		move.w	d0,(a0)

/* base address for the escape table */
esc_base:

/* 306de: 00e07406 */
/* 206de: 00e0627e */
/* 104de: 00fca4d6 */
/* 106de: 00e0a702 */
v_esc_nop:
esc_exit:
		rts


*******************************************************************************
**	VDI #5,17 - v_hardcopy - Hardcopy.
*******************************************************************************

/* 306de: 00e07408 */
/* 206de: 00e06280 */
/* 104de: 00fca4d8 */
/* 106de: 00e0a704 */
v_hardcopy:
		move.w	#20,-(sp)		; Invoke bios
		trap	#14

		addq.l	#2,sp			; clean up stack
		rts


*******************************************************************************
**	VDI #5,3 - v_enter_cur - Enter Alpha Mode.
*******************************************************************************

/* 306de: 00e07412 */
/* 206de: 00e0628a */
/* 104de: 00fca4e2 */
v_enter_cur:
		bsr	escE			; clear and home.
		bra	esce			; show cursor regardless of cnt


*******************************************************************************
**	VDI #5,2 - v_exit_cur - Exit Alpha Mode.
*******************************************************************************

/* 306de: 00e07418 */
/* 206de: 00e06290 */
/* 104de: 00fca4e8 */
v_exit_cur:
		bsr	hide_cursor		; cursor hidden upon exit
*						; fall through to clr and home


*******************************************************************************
**	escape E.
**			 Clear Screen and Home Cursor.
*******************************************************************************

escE:
		bsr	escH			; home cursor.
		bra	escJ			; clear screen.


*******************************************************************************
**	escape A.
**	VDI #5,4 - v_curup - Alpha Cursor Up.
*******************************************************************************

/* 306de: 00e07420 */
/* 206de: 00e06298 */
/* 104de: 00fca4f0 */
escA:
v_curup:
		move.w	_v_curcy,d1		; d1 <- current cursor Y
		beq	esc_exit		; if top of screen, do nothing

up_cursor:
		subq.w	#1,d1			; d1 <- Y of previous line
		move.w	_v_curcx,d0		; d0 <- current cursor X
		bra	move_cursor		; update cursor pos and globals


*******************************************************************************
**	escape B.
**	VDI #5,5 - v_curdown - Alpha Cursor Down.
*******************************************************************************

/* 306de: 00e07430 */
/* 306de: 00e062a8 */
/* 104de: 00fca500 */
escB:
v_curdown:
down_cursor:
		move.w	_v_curcy,d1		; d1 <- current cursor Y
		cmp.w	_v_celmy,d1
		beq	esc_exit		; if bottom of scrn, do nothing

		addq.w	#1,d1			; d1 <- Y of next line
		move.w	_v_curcx,d0		; d0 <- current cursor X
		bra	move_cursor		; update cursor pos and globals


*******************************************************************************
**	escape C.
**	VDI #5,6 - v_curright - Alpha Cursor Right.
*******************************************************************************

/* 306de: 00e07444 */
/* 206de: 00e062bc */
/* 104de: 00fca514 */
escC:
v_curright:

	move.w	_v_curcx,d0		; d0 <- current cursor X.
	cmp.w	_v_celmx,d0
	beq	esc_exit		; if right edge of screen, do nothing.

	addq.w	#1,d0			; d0 <- next X position right
	move.w	_v_curcy,d1		; d1 <- current cursor Y.
	bra	move_cursor		; update cursor position and globals.


*******************************************************************************
**	escape D.
**	VDI #5,7 - v_curleft - Alpha Cursor Left.
*******************************************************************************

/* 306de: 00e07458 */
/* 206de: 00e062d0 */
/* 104de: 00fca528 */
escD:
v_curleft:

	move.w	_v_curcx,d0		; d0 <- current cursor X.
	beq	esc_exit		; if left edge of screen, do nothing.

	subq.w	#1,d0			; d0 <- next X position left
	move.w	_v_curcy,d1		; d1 <- current cursor Y.
	bra	move_cursor		; update cursor position and globals.


*******************************************************************************
**	escape H.
**	VDI #5,8 - v_curhome - Home Alpha Cursor.
*******************************************************************************

/* 306de: 00e07468 */
/* 206de: 00e062e0 */
/* 104de: 00fca538 */
escH:
v_curhome:
	moveq.l    #0,d0		; d0 <- home X
	move.w     d0,d1		; d1 <- home Y
	bra	move_cursor


*******************************************************************************
**	escape J.
**	VDI #5,9 - v_eeos - Erase to End of Screen.
*******************************************************************************

/* 306de: 00e07470 */
/* 206de: 00e062e8 */
/* 104de: 00fca540 */
escJ:
v_eeos:

	bsr	escK		 	; erase to end of line.

*  on return:
*
*    d1 <- current cursor Y
*    d2 <- maximum cursor X

	move.w  _v_curcy,d1
	cmp.w	_v_celmy,d1			; if already on last line, exit.
	beq	esc_exit

	addq.w	#1,d1			; d1 <- Y of next line down
	swap       d1
	move.w	#0,d1			; d0 <- region Xmin
	move.w	_v_celmy,d2
	swap       d2
	move.w	_v_celmx,d2
	bra	erase_region


*******************************************************************************
**	VT52 escape K.
**	VDI #5,10 - v_eeol - Erase to End of Line.
*******************************************************************************

/* 306de: 00e07482 */
/* 206de: 00e062fa */
/* 104de: 00fca552 */
escK:
v_eeol:
		bclr       #F_CEOL,_v_stat_0
		move.w     sr,-(a7)
		bsr        escf
		bsr        escj
		move.w     _v_curcx,d1
		btst       #0,d1
		beq.s      v_eeol1
		cmp.w      _v_celmx,d1
		beq.s      v_eeol4
		move.w     #' ',d1
		bsr        ascii_out
		move.w     _v_curcx,d1
v_eeol1:
		swap       d1
		move.w     _v_curcy,d1
		move.w     d1,d2
		swap       d1
		swap       d2
		move.w     _v_celmx,d2
		bsr        erase_region
v_eeol2:
		move.w     (a7)+,ccr
		beq.s      v_eeol3
		bset       #F_CEOL,_v_stat_0
v_eeol3:
		bsr        esck
		bra        show_cursor
v_eeol4:
		move.w     #' ',d1
		bsr        ascii_out
		bra.s      v_eeol2


*******************************************************************************
**	VDI #5,11 - vs_curaddress - Set Cursor Position.
*******************************************************************************

/* 306de: 00e07494 */
/* 206de: 00e0630c */
/* 104de: 00fca564 */
vs_curaddress:

	move.l	_INTIN,a0		; a0 -> INTIN array
	move.w	(a0),d1			; d1 <- row number
	subq.w	#1,d1			; d1 <- Y (zero origin)
	move.w	2(a0),d0		; d0 <- column number
	subq.w	#1,d0			; d0 <- X (zero origin)
	bra	move_cursor


*******************************************************************************
**	VDI #5,12 - v_curtext - Output Text.
*******************************************************************************

/* 306de: 00e074a6 */
/* 206de: 00e0631e */
/* 104de: 00fca576 */
vs_curtext:

	move.l	_CONTRL,a0		; a0 -> CONTRL array.
	move.w	6(a0),d0		; d0 <- character count.
	move.l	_INTIN,a0		; a0 -> character array.
	bra	ef12_lend

ef12_loop:

	move.w	(a0)+,d1		; d1 <- next character from array.

	movem.l	d0/a0,-(sp)
	bsr	gsx_conout		; output character to console.
	movem.l	(sp)+,d0/a0

ef12_lend:

	dbra	d0,ef12_loop
	rts


*******************************************************************************
**	VT52 escape p.
**	VDI #5,13 - v_rvon - Reverse Video On.
*******************************************************************************

/* 306de: 00e074c8 */
/* 206de: 00e06340 */
/* 104de: 00fca598 */
escp:
v_rvon:
		bset.b	#F_REVID,_v_stat_0	 ; set reverse bit in v_stat_0
		rts


*******************************************************************************
**	escape q.
**	VDI #5,14 - v_rvoff - Reverse Video Off.
*******************************************************************************

/* 306de: 00e074ce */
/* 206de: 00e06346 */
/* 104de: 00fca59e */
escq:
v_rvoff:
		bclr.b	#F_REVID,_v_stat_0		; clr reverse bit in v_stat_0
		rts


*******************************************************************************
**	VDI #5,15 - vq_curaddress - Inquire Cursor Position.
*******************************************************************************

/* 306de: 00e074d4 */
/* 206de: 00e0634c */
/* 104de: 00fca5a4 */
vq_curaddress:

	move.l	_CONTRL,a0		; a0 -> CONTRL array.
	move.w	#2,8(a0)		; 2 integers are returned.
	move.l	_INTOUT,a0		; a0 -> INTOUT array.
	move.w	_v_curcy,d0		; d0 <- cell Y (zero based)
	addq.w	#1,d0			; d0 <- row number
	move.w	d0,(a0)			; return row number.
	move.w	_v_curcx,d0		; d0 <- cell X (zero based)
	addq.w	#1,d0			; d0 <- column number
	move.w	d0,2(a0)		; return column number.
	rts


*******************************************************************************
**	VDI #5,16 - vq_tabstatus - Inquire Tablet Status.
*******************************************************************************

/* 306de: 00e074f4 */
/* 206de: 00e0636c */
/* 104de: 00fca5c4 */
vq_tabstatus:

	move.l	_CONTRL,a0		; a0 -> CONTRL array.
	move.w	#1,8(a0)		; 1 integer is returned.
	move.l	_INTOUT,a0		; a0 -> INTOUT array.
	move.w	#1,(a0)			; 1 => there is a mouse.
	rts


*******************************************************************************
**	VDI #5,18 - v_dspcur - Place Graphic Cursor.
*******************************************************************************

/* 306de: 00e07506 */
/* 206de: 00e0637e */
/* 104de: 00fca5d6 */
v_dspcur:

	movea.l	_INTIN,a0		; a0 -> INTIN array.
	move.w	#0,(a0)			; INTIN(0)<- 0 =>  show regardless.
	jmp	_v_show_c		; show graphic cursor.


*******************************************************************************
**	VDI #5,19 - v_rmcur - Remove Graphic Cursor.
*******************************************************************************

/* 306de: 00e07512 */
/* 206de: 00e0638a */
/* 104de: 00fca5e2 */
v_rmcur:

	jmp	_v_hide_c		; hide graphic cursor.




*  The following routines are for VT-52 terminal emulation.


*******************************************************************************
*	VT52 escape I.
*				 Reverse Index.
*******************************************************************************

escI:

	move.w	_v_curcy,d1		; d1 <- current cursor Y
	bne	up_cursor		; if not at top, move cursor up 1 line
	move.w _v_curcx,-(a7)
	bsr.s escL		; blank the top line
	move.w (a7)+,d0
	moveq.l    #0,d1
	bra	move_cursor


*******************************************************************************
**	escape L.
**				 Insert Line.
*******************************************************************************

escL:

	bsr	hide_cursor
	move.w	_v_curcy,d1		; d1 <- Ymin of scroll region
	bsr sb_scrdn			; scroll down 1 line. insert blank line

start_o_line:

	clr.w	d0			; d0 <- X of beginning of line
	move.w	_v_curcy,d1		; d1 <- current Y
	bsr	move_cursor
	bra	show_cursor


*******************************************************************************
**	escape M.
**				 Delete Line.
*******************************************************************************

escM:

	bsr	hide_cursor		; hide cursor.
	move.w	_v_curcy,d1		; line to begin scrolling up.
	bsr sb_scrup
	bra	start_o_line

set_fgcol:
	and.w      #15,d0
	move.w	d0,_v_col_fg	; set the foreground color.
	rts

set_bgcol:
	and.w      #15,d0
	move.w	d0,_v_col_bg	; set the background color.
setbg_exit:
	rts

*******************************************************************************
**	escape d.
**			Erase from Beginning of Page.
*******************************************************************************

escd:
	bsr esco			; erase from beginning of line
	move.w	_v_curcy,d2		; if were on the first line...
	beq	setbg_exit          ; return

	subq.w	#1,d2			; d2 <- Ymax (line above the cursor)
	swap d2
	move.w	_v_celmx,d2		; d2 <- Xmax (right side of screen)
	moveq	#0,d0			; d0 <- Xmin (left sideof screen)

	bra	erase_region		; erase screen above cursor


*******************************************************************************
**	escape e.
**			Enable Cursor (always).
*******************************************************************************

	xdef	esce
esce:
	tst.w	_disab_cnt		; if cursor is already displayed,
	beq	setbg_exit		; we're done
	clr.w	_disab_cnt	; set up for cursor redisplay
esce1:
    lea     _v_stat_0,a0
    btst    #F_CFLASH,(a0)
    bne     esce2
    bset    #2,(a0)
    
enable_it:
	move.l	_v_cur_ad,a1		; a1 -> current cursor position
	bra	neg_cell

esce2:
	bsr enable_it
	bset #F_CSTATE,(a0)
	bset #2,(a0)
	rts

*******************************************************************************
**			Enable Cursor (counted depth).
*******************************************************************************

/* 306de: 00e07562 */
/* 206de: 00e063de */
/* 104de: 00fca636 */
/* 106de: 00e0a862 */
show_cursor:

	tst.w	_disab_cnt	; old count=0  =>  cursor is visible
	beq	setbg_exit

	subq.w	#1,_disab_cnt	; new count=0  =>  redisplay cursor
	beq	esce1

	rts


*******************************************************************************
**	escape f.
**			  Disable Cursor (counted depth).
*******************************************************************************

	xdef	escf
escf:

/* 306de: 00e07592 */
/* 206de: 00e0640e */
/* 104de: 00fca666 */
hide_cursor:

	addq.w	#1,_disab_cnt	; increment the disable counter.

	lea _v_stat_0,a0	; a0 -> v_stat_0
	bclr.b	#2,(a0)
	beq setbg_exit
	btst #F_CFLASH,(a0)
	beq	enable_it		; exit if cursor is currently invisible
	bclr #F_CSTATE,(a0)
	bne enable_it		; turn cursor off and return
	rts

*******************************************************************************
**	escape j.
**			     Save Cursor Position.
*******************************************************************************

escj:
		bset.b	#F_SVPOS,_v_stat_0	; set "pos saved" status bit.
		lea _sav_cxy,a0
		move.w _v_curcx,(a0)+
		move.w _v_curcy,(a0)

		rts


*******************************************************************************
**	escape k.
**			    Restore Cursor Position.
*******************************************************************************

esck:

	bclr.b	#F_SVPOS,_v_stat_0		; clear "position saved" status bit
	beq	escH			; if (X,Y) was not saved, home cursor

	lea _sav_cxy,a0
	move.w	(a0)+,d0		; d0 <- saved X
	move.w	(a0),d1		; d1 <- saved Y
	bra	move_cursor		; move cursor to saved position.


*******************************************************************************
**	escape l.
**				Erase Entire Line.
*******************************************************************************

escl:
	bsr	hide_cursor

	move.w	_v_curcy,d1
	move.w	d1,d2
	swap	d1
	clr.w	d1
	swap	d2
	move.w	_v_celmx,d2
	bsr	erase_region		; blank whole line.

	bra	start_o_line		; (d0,d1) is X,Y of beginning of line


*******************************************************************************
**	escape o.
**			  Erase from Beginning of Line.
*******************************************************************************

esco:
		bsr        hide_cursor
		bsr        escj
		move.w     _v_curcx,d2
		beq.s      esco3
		btst       #0,d2
		bne.s      esco1
		move.w     #' ',d1
		bsr        ascii_out
		move.w     _v_curcx,d2
		subq.w     #2,d2
esco1:
		swap       d2
		move.w     _v_curcy,d2
		move.w     d2,d1
		swap       d2
		swap       d1
		clr.w      d1
		bsr        erase_region
esco2:
		bsr.s      esck
		bra        show_cursor
esco3:
		move.w     #' ',d1
		bsr        ascii_out
		bra.s      esco2


*******************************************************************************
**	escape v.
**			      Wrap at End of Line.
*******************************************************************************

escv:

	bset.b	#F_CEOL,_v_stat_0	; set the eol handling bit in v_stat_0
	rts


*******************************************************************************
**	escape w.
**			    Overwrite at End of Line.
*******************************************************************************

escw:

	bclr.b	#F_CEOL,_v_stat_0		; clear the eol bit in v_stat_0
	rts


*******************************************************************************
**				Carriage Return.
*******************************************************************************

/* 306de: 00e075f8 */
/* 206de: 00e06474 */
/* 104de: 00fca6cc */
ascii_cr:

	move.w	_v_curcy,d1		; d1 <- current Y
	clr.w	d0			; d0 <- X of beginning of line
	bra	move_cursor		; move_cursor does CRITICAL SECTION


*******************************************************************************
**				  Line Feed.
*******************************************************************************

/* 306de: 00e07602 */
/* 206de: 00e0647e */
/* 104de: 00fca6d6 */
ascii_lf:

	move.w	_v_curcy,d0		; d1 <- current cursor y.
	cmp.w	_v_celmy,d0		; at bottom of screen?
	bne	down_cursor		; no, move cursor down one line

	bsr	hide_cursor
	clr.w	d1			; scroll region starts at top of screen
	bsr sb_scrup		; scroll up 1 line & blank bottom line.
	bra	show_cursor


*******************************************************************************
**			cursor blink interrupt routine.
*******************************************************************************

*   If dsply_cnt is non-zero, the cursor is not processed
*
*   F_CFLASH indicates whether the cursor is static or flashing.
*   Setting the flag enables flashing cursor.
*   Clearing the flag enables static cursor.
*
*   CSTATE reflects the actual state of the alpha cursor. When main line
*   code erases the cursor, this flag should reflect the change.
*
*   Main line code should NOT redisplay the cursor. The interrupt routine
*   has sole responsibility for displaying the cursor whether flashing
*   or static.
*
*   Code segments that remove the Alpha cursor form from the screen
*   should supress possible interference from the cursor interrupt routine
*   by incrementing the disab_cnt word and clearing the F_CSTATE flag at the
*   outset. Upon leaving the critical section, disab_cnt is decremented.
*   If the count becomes zero, arrangements must be made to redisplay the
*   cursor.
*
*   To cause the cursor to be redisplayed, the main routine should load
*   v_curct with the value in v_delay. CSTATE flag should be clear. The
*   cursor will be displayed only after there has been no activity for at
*   least v_delay-1 frames. Thus, excessive redisplaying of the cursor is
*   avoided.


/* 306de: 00e0761a */
/* 206de: 00e06496 */
/* 104de: 00fca6ee */
/* 106de: 00e0a91a */
	xdef blink
blink:

	lea _v_stat_0,a0
	btst #F_BLINK,(a0)
	bne	bl_exit			  ; if cursor is hidden, exit
	btst #2,(a0)
	beq	bl_exit			  ; if cursor is hidden, exit
	btst #F_CFLASH,(a0)
	beq	bl_exit			  ; if cursor is not flashing, exit
	
	lea _v_cur_tim,a1
	subq.b	#1,(a1)	  ; decrement cursor activity timer.
	bne	bl_exit			  ; if <> 0, do not process.

	move.b	_vct_init,(a1) ; reset timer with flash count

	bchg	#F_CSTATE,(a0)	  ; toggle cursor state in v_stat_0

	move.l	_v_cur_ad,a1		  ; fetch cursor address
	bra	neg_cell		  ; XOR cursor. return from there

bl_exit:

	rts				  ; otherwise, exit.


/*
 * XBIOS #21 - Cursconf - Sets the working of the VT52 cursor
 */
/* 306de: 00e0764c */
/* 206de: 00e064c8 */
/* 104de: 00fca720 */
/* 106de: 00e0a94c */
	xdef _cursconf
_cursconf:
	move.w	4(sp),d0		; fetch function number.
	bmi	bl_exit			; yes, exit.
	cmp.w	#5,d0			; above 5?
	bgt	bl_exit			; yes, exit.

	asl.w	#1,d0			; d0 <- offset to the offset
	lea conf_base,a0
	adda.w	conf_tbl(pc,d0.w),a0 	; d0 <- offset to the function
	jmp	(a0)	; execute the function

conf_tbl:

	dc.w 	bra_escf-conf_base	; hide
	dc.w    bra_esce-conf_base	; forced show
	dc.w	 onblink-conf_base	; turn on blinking
	dc.w	offblink-conf_base	; turn off blinking
	dc.w	 setrate-conf_base	; set blink rate
	dc.w	 getrate-conf_base	; get blink rate
#if TOSVERSION >= 0x102
	dc.w	setdelay-conf_base	; set delay value
	dc.w	getdelay-conf_base	; get delay value
#endif

/* base for conf table */
conf_base:

bra_escf:
	bra escf

bra_esce:
	bra esce


onblink:
    bsr hide_cursor
	bset.b	#F_CFLASH,_v_stat_0(a5)	; a4 -> v_stat_0 (enable blinking)
	bra show_cursor

offblink:
    bsr hide_cursor
	bclr.b	#F_CFLASH,_v_stat_0(a5)	; a4 -> v_stat_0 (disable blinking)
	bra show_cursor

setrate:

	move.b	7(sp),_vct_init(a5)	; set the blink rate.
	rts

getrate:

	moveq.l	#0,d0			; clear hi byte of lo word
	move.b	_vct_init(a5),d0		; get the blink rate.
	rts

#if TOSVERSION >= 0x102
setdelay:

	move.b	7(sp),d0
	move.b	d0,_v_delay		; set the delay period
	rts

getdelay:

	moveq.l	#0,d0			; clear hi byte of lo word
	move.b	_v_delay,d0		; get the delay period
	rts
#endif


*******************************************************************************
*
* name:	ascii_out
*
* purpose:	this routine interfaces with the BIOS.
*		it prints an ascii character on the screen as if
*		there was a dumb terminal in here
*
* in:	d1.w	ascii code for character
*	V_CELL pointer to desired version of cell display routine
*
*******************************************************************************

get_addr_font:
	move.w	_v_fnt_st,d3		; test against minimum
	cmp.w d3,d1
	bcs	out_of_bounds

	cmp.w	_v_fnt_nd,d1		; test against maximum
	bhi	out_of_bounds


	move.l	_v_off_ad,a0		; a0 -> offset table.
	add.w	d1,d1			; d1 <- word offset into table
	move.w	(a0,d1.w),d1		; d1 <- pixel offset into font data
	lsr.w	#3,d1			; d1 <- byte offset into font data

	move.l	_v_fnt_ad,a0
	add.w	d1,a0			; a0 -> alpha source
	clr.w   d3
	rts

out_of_bounds:
	moveq.l    #1,d3
	rts

/* 306de: 00e076a4 */
/* 206de: 00e06520 */
/* 104de: 00fca778 */
/* 106de: 00e0a9a4 */
ascii_out:
	bsr get_addr_font
	beq addr_ok
	rts
addr_ok:
	move.l	_v_cur_ad,a1		; a1 -> the destination
	move.w	_v_col_bg,d7		; d7 <- background color
	swap    d7
	move.w	_v_col_fg,d7		; d6 <- foreground color
	btst.b	#F_REVID,_v_stat_0	; test reverse video flag in v_stat_0
	beq	put_char
	swap d7			; reverse fore and background colours

put_char:
	bclr.b	#2,_v_stat_0	; <<< BEGIN CRITICAL SECTION >>>
	
	move.w     sr,-(a7)

	bsr sb_cell		; a5 -> to the desired routine


*   update cursor position to next cell position
*   perform carriage return and line feed if necessary

	move.l	_v_cur_ad,a1		; a1 -> the destination
	move.w	_v_curcx,d0
	move.w	_v_curcy,d1

	bsr     f_wrap
	beq     save_it

	move.w	_v_cel_wr,d0
	mulu.w	d1,d0
	move.l	_v_bas_ad,a1		; a1 -> base of screen
	add.l	d0,a1			; a1 -> beginning of last line

	clr.w	d0			; d0 <- X of first cell in line
	cmp.w	_v_celmy,d1		; is it time to scroll ?
	bcc	do_scroll
	add.w	_v_cel_wr,a1
	addq.w  #1,d1
	bra     save_it
	
do_scroll:

	movem.l    d0-d1/a1,-(a7)
	moveq.l    #0,d1
	bsr sb_scrup
	movem.l    (a7)+,d0-d1/a1
	
save_it:

	move.l	a1,_v_cur_ad		; update cursor address
	move.w	d0,_v_curcx		; update the cursor X coordinate
	move.w	d1,_v_curcy		; update the cursor Y coordinate
	move.w  (a7)+,ccr
	beq.s   set_hide

	bsr neg_cell	
	bset #F_CSTATE,_v_stat_0	; <<< END CRITICAL SECTION >>>
	bset #2,_v_stat_0

set_hide:

	rts

erase_region:
		sub.l      d1,d2
		move.w     d1,d0
		swap       d1
		bsr        cell_addr
		asr.w      #1,d2
		move.w     _v_planes,d3
		cmpi.w     #4,d3
		bne        erase1
		subq.w     #1,d3
erase1:
		move.w     d2,d1
		addq.w     #1,d1
		asl.w      d3,d1
		movea.w    _v_lin_wr,a2
		suba.w     d1,a2
		move.w     d2,d1
		swap       d2
		addq.w     #1,d2
		mulu.w     _v_cel_ht,d2
		subq.w     #1,d2
		clr.l      d0
		move.w     _v_col_bg,d5
		cmpi.w     #2,_v_planes
		bmi        erase8
		beq        erase5
		asr.w      #1,d5
		negx.w     d0
		swap       d0
		asr.w      #1,d5
		negx.w     d0
		clr.l      d3
		asr.w      #1,d5
		negx.w     d3
		swap       d3
		asr.w      #1,d5
		negx.w     d3
erase2:
		move.w     d1,d5
erase3:
		move.l     d0,(a1)+
		move.l     d3,(a1)+
		dbf        d5,erase3
		adda.l     a2,a1
erase4:
		dbf        d2,erase2
		rts
erase5:
		asr.w      #1,d5
		negx.w     d0
		swap       d0
		asr.w      #1,d5
		negx.w     d0
erase6:
		move.w     d1,d5
erase7:
		move.l     d0,(a1)+
		dbf        d5,erase7
		adda.l     a2,a1
		dbf        d2,erase6
		rts
erase8:
		asr.w      #1,d5
		negx.w     d0
erase9:
		move.w     d1,d5
erase10:
		move.w     d0,(a1)+
		dbf        d5,erase10
		adda.l     a2,a1
		dbf        d2,erase9
		rts

#include "hbescape.inc"

*******************************************************************************
*
* name:		cell_addr
*
*
* purpose:	convert cell X,Y to a screen address. also clip cartesian
*          	coordinates to the limits of the current screen.
*
*
* in:		d0.w	cell X
*		d1.w	cell Y
*
*
* out:		a1	points to first byte of cell
*		d0	X (clipped)
*		d1	Y (clipped)
*
*
* munged:	d2-d5
*
*******************************************************************************

* check bounds against screen limits

cell_addr:
		move.w	_v_celmx,d3
		cmp.w	d0,d3
		bpl	x_clipped
		move.w	d3,d0			; d0 <- clipped x

x_clipped:
		move.w	_v_celmy,d3
		cmp.w	d1,d3
		bpl	y_clipped
		move.w	d3,d1			; d1 <- clipped Y

y_clipped:
		move	_v_planes,d3	; d2 <- offset in bytes to X
		move.w	d0,d5			; d5 <- clipped X
		bclr.l	#0,d5			; d5 <- word boundry X
		mulu	d5,d3			; d3 <- offset in bytes to X
		btst       #0,d0
		beq        cell1
		addq.l     #1,d3
cell1:
		move.w	_v_cel_wr,d5
		mulu    d1,d5

		move.l	_v_bas_ad,a1
		add.l	d5,a1			; a1 -> cell (X,Y)
		add.l	d3,a1
		add.w	_v_cur_off,a1	; another silly offset
		rts


/*******************************************************************************
 *
 * name: sb_cell (soft blt version)
 *
 * purpose:  This routine performs a byte aligned block transfer for the
 *           purpose of manipulating monospaced byte-wide text. the routine
 *           maps an single plane arbitrarilly long byte-wide image to a
 *           multi-plane bit map. all transfers are byte/word aligned.
 *
 * in:	a0.l	points to contiguous source block (1 byte wide)
 *	a1.l	points to destination (1st plane, top of block)
 *	d6.w	foreground
 *	d7.w	background
 *
 * damaged:	a2-a3/a5/d0-d7
 *
 *******************************************************************************/


/* 306de: 00e0da98 */
/* 206de: 00e0e45c */
/* 104de: 00fd25bc */
/* 106de: 00e1281c */
		xdef sb_cell
sb_cell:
		movea.w    _v_fnt_wr,a2
		movea.w    _v_lin_wr,a3
		move.w     _v_cel_ht,d4
		subq.w     #1,d4
		move.w     _v_planes,d6
		subq.w     #1,d6
sb_cell1:
		move.w     d4,d5
		movea.l    a0,a4
		movea.l    a1,a5
		asr.l      #1,d7
		btst       #15,d7
		beq        sb_cell2
		bcc        sb_cell5
		moveq.l    #-1,d3
		bra        sb_cell3
sb_cell2:
		bcs        sb_cell4
		moveq.l    #0,d3
sb_cell3:
		move.b     d3,(a5)
		adda.w     a3,a5
		dbf        d5,sb_cell3
		addq.w     #2,a1
		dbf        d6,sb_cell1
		rts
sb_cell4:
		move.b     (a4),(a5)
		adda.w     a3,a5
		adda.w     a2,a4
		dbf        d5,sb_cell4
		addq.w     #2,a1
		dbf        d6,sb_cell1
		rts
sb_cell5:
		move.b     (a4),d3
		not.b      d3
		move.b     d3,(a5)
		adda.w     a3,a5
		adda.w     a2,a4
		dbf        d5,sb_cell5
		addq.w     #2,a1
		dbf        d6,sb_cell1
		rts

*******************************************************************************
*
* move_cursor:	go to the proper negate alpha cell routine
*
* purpose:	move the cursor and update global parameters
*		erase the old cursor (if necessary) and draw new
*		cursor (if necessary)
*
* in:	d0.w	new cell X coordinate
*		d1.w	new cell Y coordinate
*
*******************************************************************************
/* 306de: 00e077f6 */
/* 206de: 00e06826 */
/* 104de: 00fcaa7e */
move_cursor:
        cmp.w _v_celmx,d0
        bls.s col_ok
        move.w _v_celmx,d0
col_ok:
        cmp.w _v_celmy,d1
        bls.s row_ok
        move.w _v_celmy,d1
row_ok:
        move.w d0,_v_curcx
        move.w d1,_v_curcy
        
        lea _v_stat_0,a0
		btst       #2,(a0)
		beq        move3
		btst       #F_CFLASH,(a0)
		beq        move1
		bclr       #2,(a0)
		btst       #F_CSTATE,(a0)
		beq        move2
move1:
		movea.l    _v_cur_ad,a1
		bsr        neg_cell
		bsr        cell_addr
		move.l     a1,_v_cur_adr
		bsr        neg_cell
		bset       #2,_v_stat_0
		rts
move2:
		bsr        cell_addr
		move.l     a1,_v_cur_ad
		bset       #2,(a0)
		rts
move3:
		bsr        cell_addr
		move.l     a1,_v_cur_ad
		rts
		
*******************************************************************************
*
* neg_cell:	go to the proper negate alpha cell routine
*
* purpose:	This routine negates the contents of an arbitrarily tall
*		byte/word wide cell composed of an arbitrary number of
*		(atari styled) bit-planes. cursor display can be
*		acomplished via this procedure. since a second
*		negation restores the original cell condition, there is
*		no need to save	the contents beneath the cursor block.
*
* in:		a1.l	  points to destination (1st plane, top of block)
*
*
* out:		destroyed:	d4-d7/a0-a2
*
*******************************************************************************


	xdef	neg_cell
neg_cell:
		move.w	_v_lin_wr,a2
		move.w	_v_cel_ht,d4
		subq.w	#1,d4			; for dbra.
		move.w	_v_planes,d6
		subq.w	#1,d6			; for dbra.
		bset #F_BLINK,_v_stat_0
		
plane_loop:
		move.w	d4,d5			; reset cell length counter
		move.l	a1,a4			; a2 -> top of curr dest plane

neg_byte:
		not.b	(a4)
		add.w	a2,a4
		dbra	d5,neg_byte

		addq.w	#2,a1			; a1 -> top of block nxt plane
		dbra	d6,plane_loop
		bclr #F_BLINK,_v_stat_0
		rts

f_wrap:
		cmp.w      _v_celmx,d0
		bne        f_wrap2
		btst       #F_CEOL,_v_stat_0
		bne       f_wrap1
		clr.w      d3
		rts
f_wrap1:
		moveq.l    #1,d3
		rts
f_wrap2:
		addq.w     #1,d0
		btst       #0,d0
		beq        f_wrap3
		addq.w     #1,a1
		clr.w      d3
		rts
f_wrap3:
		move.w     _v_planes,d3
		asl.w      #1,d3
		subq.w     #1,d3
		adda.w     d3,a1
		clr.w      d3
		rts

/*******************************************************************************
 *
 * title:	 Scroll
 *
 *
 * author:	jim eisenstein
 *
 *
 *   Scroll copies a source region as wide as the screen to an overlapping
 *   destination region on a one cell-height offset basis.  Two entry points
 *   are provided:  Partial-lower scroll-up, partial-lower scroll-down.
 *   Partial-lower screen operations require cell y # indicating the top line
 *   where scrolling will take place.
 *
 *   After the copy is performed, any non-overlapping area of the previous
 *   source region is "erased" by filling with the background color.
 *
 *
 *  in:  d1.w	   cell Y of region top
 *	v_celmy   cell Y of region bottom
 *
 *
 *  munged:	d0-d7/a2-a3
 *
 *
 *******************************************************************************/

/* 306de: 00e0db90 */
/* 206de: 00e0e4da */
/* 104de: 00fd263a */
/* 106de: 00e1289a */
		xdef sb_scrup
sb_scrup:
		movea.l    _v_bas_ad,a3
		move.w     _v_cel_wr,d3
		mulu.w     d1,d3
		lea.l      0(a3,d3.w),a3
		neg.w      d1
		add.w      _v_celmy,d1
		move.w     _v_cel_wr,d3
		lea.l      0(a3,d3.w),a2
		mulu.w     d1,d3
		asr.w      #2,d3
		bra.s      sb_scru2
sb_scru1:
		move.l     (a2)+,(a3)+
sb_scru2:
		dbf        d3,sb_scru1
		move.w     _v_celmy,d1
sb_scru3:
		move.w     d1,d2
		swap       d1
		swap       d2
		clr.w      d1
		move.w     _v_celmx,d2
		bra        erase_region

/* 306de: 00e0dbd4 */
/* 206de: 00e0e51e */
/* 104de: 00fd267e */
/* 106de: 00e128de */
		xdef sb_scrdn
sb_scrdn:
		movea.l    _v_bas_ad,a3
		move.w     _v_celmy,d3
		mulu.w     _v_cel_wr,d3
		lea.l      0(a3,d3.w),a3
		move.w     _v_cel_wr,d3
		lea.l      0(a3,d3.w),a2
		move.w     d1,d0
		neg.w      d0
		add.w      _v_celmy,d0
		mulu.w     d0,d3
		asr.w      #2,d3
		bra.s      sb_scrd2
sb_scrd1:
		move.l     -(a3),-(a2)
sb_scrd2:
		dbf        d3,sb_scrd1
		bra.s      sb_scru3

*******************************************************************************
**	VDI #5,102 - v_fontinit - Init system font
**
**		          Install User Defined Font
*******************************************************************************

/* 306de: 00e07858 */
/* 104de: 00fcaac4 */
v_fontinit:
		move.l	_INTIN,a0
		move.l	(a0),a0			; a0 -> font header.

* fall through to initialization sequence

*******************************************************************************
**		     Font Globals Initialization Routine
**
**			  a0 -> system font header
*******************************************************************************

/* 306de: 00e0785e */
/* 104de: 00fcaaca */
	xdef	gl_f_init
gl_f_init: ds.b 0
		move.w	FRM_HT(a0),d0		; fetch form height.
		move.w	d0,_v_cel_ht		; init cell height.
		move.w	_v_lin_wr,d1	; fetch bytes/line.
		mulu	d0,d1
		move.w	d1,_v_cel_wr		; init cell wrap. (obsolete)
		moveq.l	#0,d1			; clear the hi word of dividend
		move.w	_v_vt_rez,d1		; fetch vertical res.
		divu	d0,d1			; vertical res/cell height.
		subq.w	#1,d1			; 0 origin.
		move.w	d1,_v_celmy		; init cell max y.
		moveq.l	#0,d1			; clear the hi word of dividend
		move.w	_v_hz_rez,d1		; fetch horizontal res.
		divu	CEL_WD(a0),d1		; horizontal res/cell width.
		subq.w	#1,d1			; 0 origin.
		move.w	d1,_v_celmx		; init cell max x.
		move.w	FRM_WD(a0),_v_fnt_wr	; init font wrap.
		move.w	FIRST(a0),_v_fnt_st	; init font start ADE.
		move.w	LAST(a0),_v_fnt_nd	; init font end ADE.
		move.l	PDAT(a0),_v_fnt_ad	; init font data ptr.
		move.l	POFF(a0),_v_off_ad	; init font offset ptr.

		rts
