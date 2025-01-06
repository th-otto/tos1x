/*************************************************************************
 *                       Revision Control System
 * =======================================================================
 *  $Author: mui $       $Date: 89/04/26 18:10:36 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:10:36  mui
 * aes30
 *
 * Revision 2.1  89/02/22  05:21:49  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.1  88/06/02  12:29:37  lozben
 * Initial revision
 *
 *************************************************************************
 *       Fix bug at appl_init    3/13/87         Derek Mui
 *       The bug originated from DRI, it's not Landon's fault
 *       Deskif.s                                Landon Dyer
 *       Use MAC to assemble     6/28/90         D.Mui
 *       Release the acc wait at appl_exit       7/13/90 D.Mui
 * assemble with MAS 900801 kbad
 *       Removed far_call        4/8/91          D.Mui
 *       Remove gr_mouse         6/13/91         D.Mui
 */

#include "config.h"
#include "deskdefs.h"
#include "../aes/aesdefs.h"
#include "asmdefs.h"

#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif



#define CCODE 0

	xref _pglobal
	xref _gl_wchar
	xref _gl_hchar
	xref _gl_wbox
	xref _gl_hbox
	xref _gl_handle
	xref _gl_bvdisk
	xref _gl_bvhard


#if CCODE
WORD ap_init(WORD *pglobal)
{
	pglobal[0] = AESVERSION;
	pglobal[1] = MULTITOS ? 0 : 1;
	pglobal[2] = rlr->p_pid;
	pglobal[10] = gl_nplanes;
	LLSET(pglobal + 22, &D);
	LWSET(pglobal + 26, gl_bvdisk);
	LWSET(pglobal + 28, gl_bvhard);
	return rlr->p_pid;
}
#endif
/* 104de: 00fd7988 */
/* 106de: 00e182ec */
	xdef _ap_init
_ap_init:
		lea.l      _pglobal,a1
		move.l     #(1<<16)+$120,(a1) ; BUG: words swapped, wrong version
		movea.l    _rlr,a0
		move.w     28(a0),4(a1) ; rlr->p_pid
		move.w     _gl_nplanes,20(a1)
		move.l     #_D,22(a1)
		move.w     _gl_bvdisk,26(a1)
		move.w     _gl_bvhard,28(a1)
		move.w     28(a0),_gl_apid ; rlr->p_pid
		moveq.l    #1,d0
		rts


/* 104de: 00fd79cc (in deskif.S) */
	xdef _ap_bvset
_ap_bvset:
		move.w    4(a7),_gl_bvdisk
		move.w    6(a7),_gl_bvhard
		moveq.l   #1,d0
		rts


/* 104de: 00fd79e0 */
	xdef _ap_exit
_ap_exit:
		jsr       _mn_clsda
		movea.l   _rlr,a0
		tst.w     54(a0)
		beq.s     ap_exit1
		move.l    #_D+7072,-(a7) ; D.g_valstr
		move.w    54(a0),-(a7)
		move.w    28(a0),-(a7)
		move.w    #1,-(a7)
		jsr       _ap_rdwr
		adda.w    #10,a7
ap_exit1:
		jsr       _all_run
		moveq.l   #1,d0
		rts


#if CCODE
WORD appl_write(WORD rwid, WORD length, int16_t *pbuff)
{
  WORD		ret;
  ret = ap_rdwr( AQWRT, rwid, length, pbuff);
  dsptch();
  return ret;
}
#endif
/* 104de: 00fd7a0c */
	xdef _appl_write
_appl_write:
	link	a6,#0
	move.l	8+4(sp),-(sp)		; ap_rdwr(AQWRT, rwid, length, pbuff)
	move.l	8+4(sp),-(sp)
	move.w	#2,-(sp)
	jsr	_ap_rdwr
dispit:	unlk	a6			; restore A6 and SP
disp1:	move.l	d0,-(sp)		; save return value
	jsr	_dsptch			; dispatch
	move.l	(sp)+,d0		; restore return value
	rts				; ... and return


#if AESVERSION < 0x200
/* 104de: 00fd7a28 */
	xdef _far_call
_far_call:
	move.l    8(a7),-(a7)
	movea.l   8(a7),a0
	jsr       (a0)
	addq.l    #4,a7
	rts
#endif


#if CCODE
WORD evnt_multi(UWORD flags, UWORD bclk, UWORD bmsk, UWORD bst,
	UWORD m1flags, UWORD m1x, UWORD m1y, UWORD m1w, UWORD m1h,
	UWORD m2flags, UWORD m2x, UWORD m2y, UWORD m2w, UWORD m2h,
	int16_t *mepbuff,
	UWORD tlc, UWORD thc,
	int16_t *pmx, int16_t *pmy, int16_t *pbut, int16_t *pks, int16_t *pkr, int16_t *pbr)
{
  LONG		buparm, tmcount;
  WORD		rets[6];
  WORD		which;

  buparm = ( (LONG)(bclk) << 16);
  buparm += (bmsk << 8) + (bst);
  tmcount = ( (LONG)(thc) << 16);
  tmcount += tlc;

  which = ev_multi(flags, &m1flags, &m2flags, tmcount, buparm, mepbuff, &rets[0]);
  dsptch();
  *pmx = rets[0];
  *pmy = rets[1];
  *pbut = rets[2];
  *pks = rets[3];
  *pkr = rets[4];
  *pbr = rets[5];
  return( which);
}
#endif
/* 104de: 00fd7a36 */
	xdef _evnt_multi
_evnt_multi:
	link	a6,#-26

	moveq	#0,d0			; d0 = bclk<<16
	move.w	10(a6),d0
	swap	d0
	moveq	#0,d1			; d1 = bmsk<<8 + btst
	move.w	12(a6),d1
	lsl	#8,d1
	add	14(a6),d1
	add.l	d1,d0			; d0 = (bclk<<16) + (bmsk<<8) + btst

	moveq	#0,d1			; d1 = thc<<16
	move.w	42(a6),d1
	swap	d1
	moveq	#0,d2			; d2 = tlc
	move.w	40(a6),d2
	add.l	d2,d1			; d1 = (thc<<16) + tlc

	pea	-20(a6)			; &rets[?]
	move.l	36(a6),-(sp)		; mepbuff
	move.l	d0,-(sp)		; buparm (D0)
	move.l	d1,-(sp)		; tmcount (D1)
	pea	26(a6)			; &m2flags
	pea	16(a6)			; &m1flags
	move.w	8(a6),-(sp)		; flags
	jsr	_ev_multi		; ev_multi(...)
	lea	44(a6),a2		; array copy to ptrs in user space
	lea	-20(a6),a1
	moveq	#6-1,d1

cplp:	move.l	(a2)+,a0		; get pointer from pointer vector
	move.w	(a1)+,(a0)		; copy word to pointer's ref
	dbra	d1,cplp			; loop for more pointers
	bra	dispit			; dispatch, unlk, return D0 to caller


#if CCODE
WORD evnt_button(WORD clicks, UWORD mask, UWORD state, WORD *pmx, WORD *pmy, WORD *pmw, WORD *pmh)
{
  WORD		mrect[4];
  WORD		ret;

  ret = ev_button(clicks, mask, state, &mrect);
  dsptch();
  *pmx = mrect[0];
  *pmy = mrect[1];
  *pmw = mrect[2];
  *pmh = mrect[3];
  return(ret);
}
#endif
/* 104de: 00fd7a8e */
	xdef _evnt_button
_evnt_button:
	link	a6,#-8
	pea	-8(a6)
	move.w	12(a6),-(sp)
	move.w	10(a6),-(sp)
	move.w	8(a6),-(sp)
	jsr	_ev_button
	lea	14(a6),a2		; a2 -> vector of addrs to stuff
cplp4a:	lea	-8(a6),a1		; a1 -> vector of words
cplp4:	moveq	#4-1,d1			; d1 = count
	bra	cplp


#if CCODE
WORD evnt_dclick(WORD rate, WORD setit)
{
  WORD		ret;
  ret = ev_dclick(rate,setit);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7ab0 */
	xdef _evnt_dclick
_evnt_dclick:
#if TP_48 /* ARROWFIX */
	rts
#else
	move.l	4(sp),-(sp)
	jsr	_ev_dclick
	addq.l	#4,sp
	bra	disp1
#endif


#if CCODE
WORD form_do(OBJECT *form, WORD start)
{
  WORD		ret;

  desk_wait( FALSE );
  ret = fm_do(form,start);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7abc */
	xdef _form_do
_form_do:
	clr	-(sp)
	jsr	_desk_wait
	move.w	10(sp),(sp)			; CS from 8(sp)
	move.l	6(sp),-(sp)
	jsr	_fm_do
	addq.l	#6,sp
	bra	disp1


#if CCODE
WORD form_dial(WORD dtype, WORD ix, WORD iy, WORD iw, WORD ih, WORD x, WORD y, WORD w, WORD h)
{
  WORD		ret;
  ret = fm_dial(dtype, &ix, &x);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7ad0 */
	xdef _form_dial
_form_dial:
	pea	14(sp)			; &x
	pea	6+4(sp)			; &ix
	move.w	4+8(sp),-(sp)		; dtype
	jsr	_fm_dial
	lea	10(sp),sp
	bra	disp1


#if CCODE
WORD form_alert(WORD defbut, const char *astring)
{
  WORD		ret;
  ret = fm_alert(defbut, astring);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7ae6 */
	xdef _form_alert
_form_alert:
	move.l	6(sp),-(sp)
	move.w	4+4(sp),-(sp)
	jsr	_fm_alert
	addq.l	#6,sp
	bra	disp1


#if CCODE
WORD form_error(WORD errnum)
{
  WORD		ret;
  ret = fm_error(errnum);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7af6 */
	xdef _form_error
_form_error:
	move.w	4(sp),-(sp)
	jsr	_fm_error
	addq.l	#2,sp
	bra	disp1


#if CCODE
WORD form_center(OBJECT *tree, WORD *pcx, WORD *pcy, WORD *pcw, WORD *pch)
{
  WORD		ret;
  GRECT		pt;
  ret = ob_center(tree, &pt);
  *pcx = pt.g_x;
  *pcy = pt.g_y;
  *pcw = pt.g_w;
  *pch = pt.g_h;
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7b02 */
	xdef _form_center
_form_center:
	link	a6,#-8			; space for GRECT
	pea	-8(a6)			; &rect
	move.l	8(a6),-(sp)		; tree
	jsr	_ob_center		; ob_center(tree, &rect)
	lea	12(a6),a2		; copy coords back
	lea	-8(a6),a1
	bra	cplp4

#if AESVERSION < 0x200
/* WTF: that code is just duplicated from AES */
/* 104de: 00fd7b1a */
	xdef _graf_mouse
_graf_mouse:
	link      a6,#-4
	movem.l   d6-d7,-(a7)
	move.w    8(a6),d7
	cmp.w     #255,d7
	ble.s     grmo3
	cmp.w     #256,d7
	bne.s     grmo1
	jsr       _gsx_moff
grmo1:
	cmp.w     #257,d7
	bne.s     grmo2
	jsr _gsx_mon
grmo2:
	bra.s     grmo6
grmo3:
	cmp.w     #255,d7
	beq.s     grmo4
	move.l    a6,(a7)
	subq.l    #4,(a7)
	move.w    d7,-(a7)
	addq.w    #3,(a7)
	move.w    #14,-(a7)
	move.l    _ad_sysglo,-(a7)
	jsr _rs_gaddr
	addq.l    #8,a7
	movea.l   -4(a6),a0
	move.l    (a0),-4(a6)
	bra.s     grmo5
grmo4:
	move.l    10(a6),-4(a6)
grmo5:
	move.l    -4(a6),(a7)
	jsr _gsx_mfset
grmo6:
	jsr _dsptch
	tst.l     (a7)+
	movem.l   (a7)+,d7
	unlk      a6
	rts
#endif


#if CCODE
WORD graf_handle(WORD *gwchar, WORD *ghchar, WORD *gwbox, WORD *ghbox)
{
  *gwchar = gl_wchar;
  *ghchar = gl_hchar;
  *gwbox = gl_wbox;
  *ghbox = gl_hbox;
  return gl_handle;
}
#endif
/* actually unused */
#if BINEXACT
/* 104de: 00fd7b7c */
	xdef _graf_handle
_graf_handle:
	lea	4(sp),a1
	move.l	(a1)+,a0
	move.w	_gl_wchar,(a0)
	move.l	(a1)+,a0
	move.w	_gl_hchar,(a0)
	move.l	(a1)+,a0
	move.w	_gl_wbox,(a0)
	move.l	(a1)+,a0
	move.w	_gl_hbox,(a0)
	move.w	_gl_handle,d0
	rts
#endif


#if CCODE
VOID graf_rubbox(WORD xorigin, WORD yorigin, WORD wmin, WORD hmin, WORD *pwend, WORD phend)
{
  gr_rubbox(xorigin, yorigin, wmin, hmin, pwend, phend);
  dsptch();
}
#endif
/* 104de: 00fd7ba8 */
	xdef _graf_rubbox
_graf_rubbox:
	lea	_gr_rubbox,a0		; a0 -> routine to call
	bra.b	copy16			; use common code to copy args


#if CCODE
WORD graf_mkstate(WORD *pmx, WORD *pmy, WORD *pmstate, WORD *pkstate)
{
  WORD		ret;
  ret = gr_mkstate(pmx, pmy, pmstate, pkstate);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7bb0 */
	xdef _graf_mkstate
_graf_mkstate:
	lea	_gr_mkstate,a0		; a0 -> routine to call

copy16:	moveq	#4-1,d0			; copy 16 bytes of args
mkslab:	move.l	16(sp),-(sp)
	dbra	d0,mkslab
	jsr	(a0)			; call routine
	add.w	#16,sp
	bra	disp1


#if CCODE
VOID graf_growbox(WORD orgx, WORD orgy, WORD orgw, WORD orgh, WORD x, WORD y, WORD w, WORD h)
{
  gr_growbox(&orgx, &x);
  dsptch();
}
#endif
/* 104de: 00fd7bca */
	xdef _graf_growbox
_graf_growbox:
	lea	_gr_growbox,a0
grafx:	pea	12(sp)
	pea	4+4(sp)
	jsr	(a0)
	addq	#8,sp
	bra	disp1


#if CCODE
VOID graf_shrinkbox(WORD orgx, WORD orgy, WORD orgw, WORD orgh, WORD x, WORD y, WORD w, WORD h)
{
  gr_shrinkbox(&orgx, &x);
  dsptch();
}
#endif
/* 104de: 00fd7be0 */
	xdef _graf_shrinkbox
_graf_shrinkbox:
	lea	_gr_shrinkbox,a0
	bra	grafx


#if CCODE
WORD menu_tnormal(OBJECT *mlist, WORD dlist, WORD normal)
{
  WORD		ret;
  ret = do_chg(mlist, dlist, SELECTED, !normal, TRUE, TRUE);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7be8 */
	xdef _menu_tnormal
_menu_tnormal:
	move.l	#$00010001,-(sp)	; TRUE, TRUE
	moveq	#1,d1
	tst.w	10+4(sp)		; !normal
	seq	d0
	and.w	d1,d0
	move.w	d0,-(sp)
	move.w	d1,-(sp)		; SELECTED
menx1:	move.w	8+8(sp),-(sp)		; dlist
menx:	move.l	4+10(sp),-(sp)		; mlist *CS*
	jsr	_do_chg
	add.w	#14,sp
	bra	disp1


#if CCODE
WORD menu_bar(OBJECT *tree, WORD showit)
{
  WORD		ret;
  ret = mn_bar(tree, showit);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c0e */
	xdef _menu_bar
_menu_bar:
	move.w	8(sp),-(sp)		; showit
	move.l	4+2(sp),-(sp)		; tree
	jsr	_mn_bar
	addq	#6,sp
	bra	disp1


#if CCODE
WORD menu_icheck(OBJECT *mlist, WORD dlist, WORD check)
{
  WORD		ret;
  ret = do_chg(mlist, dlist, CHECKED, check, FALSE, FALSE);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c1e */
	xdef _menu_icheck
_menu_icheck:
	clr.l	-(sp)			; FALSE FALSE		0
	move.w	10+4(sp),-(sp)		; check			4
	move.w	#4,-(sp)		; CHECKED		6
	bra	menx1


#if CCODE
WORD menu_ienable(OBJECT *mlist, WORD dlist, WORD enable)
{
  WORD		ret;
  ret = do_chg(mlist, (dlist & 0x7fff), DISABLED, !enable,
	       ((dlist & 0x8000) != 0x0), FALSE);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c2a */
	xdef _menu_ienable
_menu_ienable:
	moveq	#1,d2			; (mask for bools)
	clr.w	-(sp)			; FALSE				+2
	move.w	8+2(sp),d0
	smi	d0
	and.w	d2,d0
	move.w	d0,-(sp)		; (bool)!(dlist & 0x8000)	+4
	tst.w	10+4(sp)
	seq	d0
	and.w	d2,d0
	move.w	d0,-(sp)		; !enable			+6
	move.w	#8,-(sp)		; DISABLED			+8
	move.w	8+8(sp),d0
	and.w	#$7fff,d0
	move.w	d0,-(sp)		; dlist & 0x7fff		+10
	bra	menx


#if CCODE
WORD objc_offset(OBJECT *tree, WORD obj, WORD *poffx, WORD *poffy)
{
  WORD		ret;
  ret = ob_offset(tree, obj, poffx, poffy);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c52 */
	xdef _objc_offset
_objc_offset:
	lea	_ob_offset,a0
	bra	copy16


#if CCODE
WORD objc_order(OBJECT *tree, WORD mov_obj, WORD newpos)
{
  WORD		ret;
  ret = ob_order(tree, mov_obj, newpos);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c5c */
	xdef _objc_order
_objc_order:
	lea	_ob_order,a0
	bra	copy16


#if CCODE
WORD objc_find(OBJECT *tree, WORD startob, WORD depth, WORD mx, WORD my)
{
  WORD		ret;
  ret = ob_find(tree, startob, depth, mx, my);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c66 */
	xdef _objc_find
_objc_find:
	lea	_ob_find,a0
	bra	copy16


#if CCODE
WORD objc_add(OBJECT *tree, WORD parent, WORD child)
{
  WORD		ret;
  ret = ob_add(tree, parent, child);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c70 */
	xdef _objc_add
_objc_add:
	lea	_ob_add,a0
	bra	copy16


#if CCODE
WORD objc_draw(OBJECT *tree, WORD drawob, WORD depth, WORD xc, WORD yc, WORD wc, WORD hc)
{
  WORD		ret;
  gsx_sclip(&xc);
  ret = ob_draw(tree, drawob, depth);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c7a */
	xdef _objc_draw
_objc_draw:
	pea	12(sp)
	jsr	_gsx_sclip
	addq	#4,sp
	lea	_ob_draw,a0
	bra	copy16


#if CCODE
WORD objc_change(OBJECT *tree, WORD drawob, WORD depth, WORD xc, WORD yc, WORD wc, WORD hc, WORD newstate, WORD redraw)
{
  WORD		ret;
  gsx_sclip(&xc);
  ret = ob_change( tree, drawob, newstate, redraw);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7c8c */
	xdef _objc_change
_objc_change:
	pea	12(sp)			;				+4
	jsr	_gsx_sclip
	move.l	20+4(sp),-(sp)		; newstate, redraw		+8
	move.w	8+8(sp),-(sp)		; drawob			+10
	move.l	4+10(sp),-(sp)		; tree				+14
	jsr	_ob_change
	add.w	#14,sp
	bra	disp1


#if CCODE
WORD rsrc_free(NOTHING)
{
  WORD		ret;
  ret = rs_free( pglobal);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7ca8 */
	xdef _rsrc_free
_rsrc_free:
	pea	_pglobal
	jsr	_rs_free
	addq	#4,sp
	bra	disp1


#if CCODE
WORD rsrc_gaddr(WORD rstype, WORD rsid, VOIDPTR *paddr)
{
  WORD		ret;
  ret = rs_gaddr( pglobal, rstype, rsid, paddr);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7cb6 */
	xdef _rsrc_gaddr
_rsrc_gaddr:
	move.l	8(sp),-(sp)		; paddr				+4
	move.l	4+4(sp),-(sp)		; rstype, rsid			+4
	pea	_pglobal		; &pglobal			+4
	jsr	_rs_gaddr
	add.w	#12,sp
	bra	disp1


#if CCODE
WORD shel_write(WORD doex, WORD isgr, WORD iscr, char *pcmd, char *ptail)
{
  WORD		ret;
  ret = sh_write(doex, isgr, iscr, pcmd, ptail);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7cce */
	xdef _shel_write
_shel_write:
	lea	_sh_write,a0
	bra	copy16


#if CCODE
WORD shel_get(char *pbuffer, WORD len)
{
  WORD		ret;
  ret = sh_get(pbuffer, len);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7cd8 */
	xdef _shel_get
_shel_get:
	lea	_sh_get,a0
	bra	copy16


#if CCODE
WORD shel_put(const char *pdata, WORD len)
{
  WORD		ret;
  ret = sh_put(pdata, len);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7ce */
	xdef _shel_put
_shel_put:
	lea	_sh_put,a0
	bra	copy16


#if CCODE
WORD wind_close(WORD handle)
{
  WORD		ret;
  ret = wm_close(handle);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7cec */
	xdef _wind_close
_wind_close:
	lea	_wm_close,a0
	bra	copy16


#if CCODE
WORD wind_delete(WORD handle)
{
  WORD		ret;
  ret = wm_delete(handle);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7cf6 */
	xdef _wind_delete
_wind_delete:
	lea	_wm_delete,a0
	bra	copy16


#if CCODE
WORD wind_find(WORD mx, WORD my)
{
  WORD		ret;
  ret = wm_find(mx,my);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7d00 */
	xdef _wind_find
_wind_find:
	lea	_wm_find,a0
	bra	copy16


#if CCODE
WORD wind_update(WORD beg_update)
{
  WORD		ret;
  ret = wm_update(beg_update);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7d0a */
	xdef _wind_update
_wind_update:
	lea	_wm_update,a0
	bra	copy16


#if CCODE
WORD wind_create(UWORD kind, WORD wx, WORD wy, WORD ww, WORD wh)
{
  WORD		ret;
  ret = wm_create(kind, &wx);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7d14 */
	xdef _wind_create
_wind_create:
	lea	_wm_create,a0
windx:	pea	6(sp)			; &wx				+4
	move.w	4+4(sp),-(sp)		; kind				+4
	jsr	(a0)
	addq	#6,sp
	bra	disp1


#if CCODE
WORD wind_open(WORD handle, WORD wx, WORD wy, WORD ww, WORD wh)
{
  WORD		ret;
  ret = wm_open( handle, &wx);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7d2a */
	xdef _wind_open
_wind_open:
	lea	_wm_open,a0
	bra	windx


#if CCODE
WORD wind_get(WORD w_handle, WORD w_field, WORD *pw1, WORD *pw2, WORD *pw3, WORD *pw4)
{
  WORD		wm_ox[4];
  WORD		ret;

  ret = wm_get(w_handle, w_field, &wm_ox);
  dsptch();
  *pw1 = wm_ox[0];
  *pw2 = wm_ox[1];
  *pw3 = wm_ox[2];
  *pw4 = wm_ox[3];
  return(ret);
}
#endif
/* 104de: 00fd7d32 */
	xdef _wind_get
_wind_get:
	link	a6,#-8
	pea	-8(a6)
	move.l	8(a6),-(sp)		; w_handle, w_field
	jsr	_wm_get
	lea	12(a6),a2		; -> vector of ptrs
	bra	cplp4a			; go copy 4 integers


#if CCODE
WORD wind_set(WORD w_handle, WORD w_field, WORD w2, WORD w3, WORD w4, WORD w5)
{
  WORD		ret;
  ret = wm_set( w_handle, w_field, &w2);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7d48 */
	xdef _wind_set
_wind_set:
	pea	8(sp)			; &w2
	move.l	4+4(sp),-(sp)		; w_handle, w_field
	jsr	_wm_set
	addq.l	#8,sp
	bra	disp1


#if CCODE
WORD wind_calc(WORD wctype, UWORD kind, WORD x, WORD y, WORD w, WORD h, WORD *px, WORD *py, WORD *pw, WORD *ph)
{
  WORD		ret;
  ret = wm_calc(wctype, kind, x, y, w, h, px, py, pw, ph);
  dsptch();
  return(ret);
}
#endif
/* 104de: 00fd7d58 */
	xdef _wind_calc
_wind_calc:
	moveq	#7-1,d0			; copy 7 longs of args
wndcp:	move.l	28(sp),-(sp)
	dbra	d0,wndcp
	jsr	_wm_calc
#if AESVERSION < 0x200
	adda.l	#28,sp
#else
	adda.w	#28,sp
#endif
	bra	disp1


#if !BINEXACT & (AESVERSION >= 0x200)
	xdef _inq_cache
_inq_cache:
	move.l 4(a7),d1
	CACR_D0
	cmp.l #-1,d1
	beq _inqc1
	D1_CACR
_inqc1:
	CACR_D0
	rts
#endif
