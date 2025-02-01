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

#include "desktop.h"
#include "toserrno.h"
#include "taddr.h"



/* 100de: 00fdd316 */
int16_t ap_init(NOTHING)
{
	/* WTF, that really does not belong into desktop */
	pglobal[0] = AESVERSION;
	/* pglobal[1] = 1; BUG: missing */
	pglobal[4] = rlr->p_pid; /* BUG: wrong index, should be 2 */
	pglobal[20] = gl_nplanes; /* BUG: wrong index, should be 10 */
	pglobal[22] = (int16_t)(intptr_t)&D; /* BUG: wrong index; BUG: truncated to int */
	pglobal[26] = gl_bvdisk; /* BUG: wrong index, should be 13 */
	pglobal[28] = gl_bvhard; /* BUG: wrong index, should be 14 */
	gl_apid = rlr->p_pid;
	return 1; /* BUG: should return gl_apid */
}


/* 100de: 00fdd36c */
int16_t ap_bvset(P(int16_t) bvdisk, P(int16_t) bvhard)
PP(int16_t bvdisk;)
PP(int16_t bvhard;)
{
	gl_bvdisk = bvdisk;
	gl_bvhard = bvhard;
	return TRUE;
}


/* 100de: 00fdd384 */
int16_t ap_exit(NOTHING)
{
	mn_clsda();
	if (rlr->p_qindex)
	{
		ap_rdwr(AQRD, rlr->p_pid, rlr->p_qindex, (int16_t *) D.g_valstr);
	}
	all_run();
	return TRUE;
}


/* 100de: 00fdd3be */
int16_t appl_write(P(int16_t) rwid, P(int16_t) length, P(int16_t *) pbuff)
PP(int16_t rwid;)
PP(int16_t length;)
PP(int16_t *pbuff;)
{
	int16_t ret;

	ret = ap_rdwr(AQWRT, rwid, length, pbuff);
	dsptch();
	return ret;
}


#if AESVERSION < 0x200
typedef uint16_t (*PARMBFUNC) PROTO((PARMBLK *f_data));
uint16_t far_call PROTO((PARMBFUNC f_code, PARMBLK *f_data));
/* 100fr: 00fdd71a */
/* 100de: 00fdd3e2 */
uint16_t far_call(P(PARMBFUNC) fcode, P(PARMBLK *) fdata)
PP(PARMBFUNC fcode;)
PP(PARMBLK *fdata;)
{
	return (*fcode) (fdata);
}
#endif


/* 100de: 00fdd3f4 */
int16_t evnt_multi(
	P(uint16_t) flags, P(uint16_t) bclk, P(uint16_t) bmsk, P(uint16_t) bst,
	P(uint16_t) m1flags, P(uint16_t) m1x, P(uint16_t) m1y, P(uint16_t) m1w, P(uint16_t) m1h,
	P(uint16_t) m2flags, P(uint16_t) m2x, P(uint16_t) m2y, P(uint16_t) m2w, P(uint16_t) m2h,
	P(int16_t *) mepbuff,
	P(uint16_t) tlc, P(uint16_t) thc,
	P(int16_t *) pmx, P(int16_t *) pmy, P(int16_t *) pbut, P(int16_t *) pks, P(int16_t *) pkr, P(int16_t *) pbr)
PP(uint16_t flags;)
PP(uint16_t bclk;)
PP(uint16_t bmsk;)
PP(uint16_t bst;)
PP(uint16_t m1flags;)
PP(uint16_t m1x;)
PP(uint16_t m1y;)
PP(uint16_t m1w;)
PP(uint16_t m1h;)
PP(uint16_t m2flags;)
PP(uint16_t m2x;)
PP(uint16_t m2y;)
PP(uint16_t m2w;)
PP(uint16_t m2h;)
PP(int16_t *mepbuff;)
PP(uint16_t tlc;)
PP(uint16_t thc;)
PP(int16_t *pmx;)
PP(int16_t *pmy;)
PP(int16_t *pbut;)
PP(int16_t *pks;)
PP(int16_t *pkr;)
PP(int16_t *pbr;)
{
	int32_t buparm;
	int32_t tmcount;
	int16_t rets[6];
	int16_t which;

	buparm = HW(bclk);
	buparm += (bmsk << 8) + (bst);
	tmcount = HW(thc);
	tmcount += tlc;

	which = ev_multi(flags, (MOBLK *)&m1flags, (MOBLK *)&m2flags, tmcount, buparm, mepbuff, &rets[0]);
	dsptch();
	*pmx = rets[0];
	*pmy = rets[1];
	*pbut = rets[2];
	*pks = rets[3];
	*pkr = rets[4];
	*pbr = rets[5];
	return which;
}


/* 100de: 00fdd49e */
int16_t evnt_button(P(int16_t) clicks, P(uint16_t) mask, P(uint16_t) state, P(int16_t *) pmx, P(int16_t *) pmy, P(int16_t *) pmw, P(int16_t *) pmh)
PP(int16_t clicks;)
PP(uint16_t mask;)
PP(uint16_t state;)
PP(int16_t *pmx;)
PP(int16_t *pmy;)
PP(int16_t *pmw;)
PP(int16_t *pmh;)
{
	int16_t mrect[4];
	int16_t ret;

	ret = ev_button(clicks, mask, state, mrect);
	dsptch();
	*pmx = mrect[0];
	*pmy = mrect[1];
	*pmw = mrect[2];
	*pmh = mrect[3];
	return ret;
}


/* 100de: 00fdd4e2 */
int16_t evnt_dclick(P(int16_t) rate, P(int16_t) setit)
PP(int16_t rate;)
PP(int16_t setit;)
{
	int16_t ret;

	ret = ev_dclick(rate, setit);
	dsptch();
	return ret;
}


/* 100de: 00fdd4fe */
int16_t form_do(P(OBJECT *) form, P(int16_t) start)
PP(OBJECT *form;)
PP(int16_t start;)
{
	int16_t ret;

#if AESVERSION >= 0x140
	desk_wait(FALSE);
#endif
	ret = fm_do((LPTREE)form, start);
	dsptch();
	return ret;
}


/* 100de: 00fdd51a */
int16_t form_dial(P(int16_t) dtype, P(int16_t) ix, P(int16_t) iy, P(int16_t) iw, P(int16_t) ih, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t dtype;)
PP(int16_t ix;)
PP(int16_t iy;)
PP(int16_t iw;)
PP(int16_t ih;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
#if BINEXACT
	int16_t ret;

	ret = fm_dial(dtype, (GRECT *)&ix, (GRECT *)&x); /* BUG: fm_dial does not return anything */
	dsptch();
	return ret;
#else
	fm_dial(dtype, (GRECT *)&ix, (GRECT *)&x);
	dsptch();
	return TRUE;
#endif
}


/* 100de: 00fdd542 */
int16_t form_alert(P(int16_t) defbut, P(const char *) astring)
PP(int16_t defbut;)
PP(const char *astring;)
{
	int16_t ret;

	ret = fm_alert(defbut, astring);
	dsptch();
	return ret;
}


/* 100de: 00fdd55e */
int16_t form_error(P(int16_t) errnum)
PP(int16_t errnum;)
{
	int16_t ret;

	ret = fm_error(errnum);
	dsptch();
	return ret;
}


/* 100de: 00fdd574 */
int16_t form_center(P(OBJECT *) tree, P(int16_t *) pcx, P(int16_t *) pcy, P(int16_t *) pcw, P(int16_t *) pch)
PP(OBJECT *tree;)
PP(int16_t *pcx;)
PP(int16_t *pcy;)
PP(int16_t *pcw;)
PP(int16_t *pch;)
{
	int16_t ret;
	GRECT pt;

#if BINEXACT
	ret = ob_center((LPTREE)tree, &pt); /* BUG: ob_center does not return anything */
#else
	ob_center((LPTREE)tree, &pt);
	ret = TRUE;
#endif
	*pcx = pt.g_x;
	*pcy = pt.g_y;
	*pcw = pt.g_w;
	*pch = pt.g_h;
	dsptch();
	return ret;
}


/* 100de: 00fdd5b4 */
VOID graf_mouse(P(int16_t) style, P(MFORM *) grmaddr)
PP(register int16_t style;)
PP(MFORM *grmaddr;)
{
	/* WTF: that code is just duplicated from AES */
	if (style > USER_DEF)
	{
		if (style == M_OFF)
			gsx_moff();
		if (style == M_ON)
			gsx_mon();
	} else
	{
		VOIDPTR maddr;
		
		if (style != USER_DEF)			/* set new mouse form   */
		{
			/* BUG: gsx_mfset will crash if this fails because number is out of range... */
			rs_gaddr(ad_sysglo, R_BIPDATA, 3 /* MICE0 */ + style, &maddr);
			maddr = (MFORM *)LLGET((intptr_t)maddr);
		} else
		{
			maddr = grmaddr;
		}

		gsx_mfset(maddr);
	}
	dsptch();
}


/* unused */
/* 100de: 00fdd60e */
int16_t graf_handle(P(int16_t *) gwchar, P(int16_t *) ghchar, P(int16_t *) gwbox, P(int16_t *) ghbox)
PP(int16_t *gwchar;)
PP(int16_t *ghchar;)
PP(int16_t *gwbox;)
PP(int16_t *ghbox;)
{
	*gwchar = gl_wchar;
	*ghchar = gl_hchar;
	*gwbox = gl_wbox;
	*ghbox = gl_hbox;
	return gl_handle;
}


/* 100de: 00fdd642 */
VOID graf_rubbox(P(int16_t) xorigin, P(int16_t) yorigin, P(int16_t) wmin, P(int16_t) hmin, P(int16_t *) pwend, P(int16_t *) phend)
PP(int16_t xorigin;)
PP(int16_t yorigin;)
PP(int16_t wmin;)
PP(int16_t hmin;)
PP(int16_t *pwend;)
PP(int16_t *phend;)
{
	gr_rubbox(xorigin, yorigin, wmin, hmin, pwend, phend);
	dsptch();
}


/* 100de: 00fdd66a */
int16_t graf_mkstate(P(int16_t *) pmx, P(int16_t *) pmy, P(int16_t *) pmstate, P(int16_t *) pkstate)
PP(int16_t *pmx;)
PP(int16_t *pmy;)
PP(int16_t *pmstate;)
PP(int16_t *pkstate;)
{
	int16_t ret;

	ret = gr_mkstate(pmx, pmy, pmstate, pkstate);
	dsptch();
	return ret;
}


/* 100de: 00fdd692 */
VOID graf_growbox(P(int16_t) orgx, P(int16_t) orgy, P(int16_t) orgw, P(int16_t) orgh, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t orgx;)
PP(int16_t orgy;)
PP(int16_t orgw;)
PP(int16_t orgh;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	gr_growbox((GRECT *)&orgx, (GRECT *)&x);
	dsptch();
}


/* 100de: 00fdd6aa */
VOID graf_shrinkbox(P(int16_t) orgx, P(int16_t) orgy, P(int16_t) orgw, P(int16_t) orgh, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t orgx;)
PP(int16_t orgy;)
PP(int16_t orgw;)
PP(int16_t orgh;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	gr_shrinkbox((GRECT *)&orgx, (GRECT *)&x);
	dsptch();
}


/* 100de: 00fdd6c2 */
int16_t menu_tnormal(P(OBJECT *) mlist, P(int16_t) dlist, P(int16_t) normal)
PP(OBJECT *mlist;)
PP(int16_t dlist;)
PP(int16_t normal;)
{
	int16_t ret;

	ret = do_chg((LPTREE)mlist, dlist, SELECTED, !normal, TRUE, TRUE);
	dsptch();
	return ret;
}


/* 100de: 00fdd6fc */
int16_t menu_bar(P(OBJECT *) tree, P(int16_t) showit)
PP(OBJECT *tree;)
PP(int16_t showit;)
{
	int16_t ret;

#if BINEXACT
 	ret = mn_bar((LPTREE)tree, showit); /* BUG: mn_bar does not return anything */
#else
 	mn_bar((LPTREE)tree, showit);
 	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd718 */
int16_t menu_icheck(P(OBJECT *) mlist, P(int16_t) dlist, P(int16_t) check)
PP(OBJECT *mlist;)
PP(int16_t dlist;)
PP(int16_t check;)
{
	int16_t ret;

	ret = do_chg((LPTREE)mlist, dlist, CHECKED, check, FALSE, FALSE);
	dsptch();
	return ret;
}


/* 100de: 00fdd744 */
int16_t menu_ienable(P(OBJECT *) mlist, P(int16_t) dlist, P(int16_t) enable)
PP(OBJECT *mlist;)
PP(int16_t dlist;)
PP(int16_t enable;)
{
	int16_t ret;

	ret = do_chg((LPTREE)mlist, (dlist & 0x7fff), DISABLED, !enable, ((dlist & 0x8000) != 0x0), FALSE);
	dsptch();
	return ret;
}


/* 100de: 00fdd78e */
int16_t objc_offset(P(OBJECT *) tree, P(int16_t) obj, P(int16_t *) poffx, P(int16_t *) poffy)
PP(OBJECT *tree;)
PP(int16_t obj;)
PP(int16_t *poffx;)
PP(int16_t *poffy;)
{
	int16_t ret;

#if BINEXACT
	ret = ob_offset((LPTREE)tree, obj, poffx, poffy); /* BUG: ob_offset does not return anything */
#else
	ob_offset((LPTREE)tree, obj, poffx, poffy);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd7b6 */
int16_t objc_order(P(OBJECT *) tree, P(int16_t) mov_obj, P(int16_t) newpos)
PP(OBJECT *tree;)
PP(int16_t mov_obj;)
PP(int16_t newpos;)
{
	int16_t ret;

#if BINEXACT
	ret = ob_order((LPTREE)tree, mov_obj, newpos); /* BUG: ob_order does not return anything */
#else
	ob_order((LPTREE)tree, mov_obj, newpos);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd7d6 */
int16_t objc_find(P(OBJECT *) tree, P(int16_t) startob, P(int16_t) depth, P(int16_t) mx, P(int16_t) my)
PP(OBJECT *tree;)
PP(int16_t startob;)
PP(int16_t depth;)
PP(int16_t mx;)
PP(int16_t my;)
{
	int16_t ret;

	ret = ob_find((LPTREE)tree, startob, depth, mx, my);
	dsptch();
	return ret;
}


/* 100de: 00fdd802 */
int16_t objc_add(P(OBJECT *) tree, P(int16_t) parent, P(int16_t) child)
PP(OBJECT *tree;)
PP(int16_t parent;)
PP(int16_t child;)
{
	int16_t ret;

#if BINEXACT
	ret = ob_add((LPTREE)tree, parent, child); /* BUG: ob_add does not return anything */
#else
	ob_add((LPTREE)tree, parent, child);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd822 */
int16_t objc_draw(P(OBJECT *) tree, P(int16_t) drawob, P(int16_t) depth, P(int16_t) xc, P(int16_t) yc, P(int16_t) wc, P(int16_t) hc)
PP(OBJECT *tree;)
PP(int16_t drawob;)
PP(int16_t depth;)
PP(int16_t xc;)
PP(int16_t yc;)
PP(int16_t wc;)
PP(int16_t hc;)
{
	int16_t ret;

	gsx_sclip((GRECT *)&xc);
#if BINEXACT
	ret = ob_draw((LPTREE)tree, drawob, depth); /* BUG: ob_draw does not return anything */
#else
	ob_draw((LPTREE)tree, drawob, depth);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd84c */
int16_t objc_change(P(OBJECT *) tree, P(int16_t) drawob, P(int16_t) depth, P(int16_t) xc, P(int16_t) yc, P(int16_t) wc, P(int16_t) hc, P(int16_t) newstate, P(int16_t) redraw)
PP(OBJECT *tree;)
PP(int16_t drawob;)
PP(int16_t depth;)
PP(int16_t xc;)
PP(int16_t yc;)
PP(int16_t wc;)
PP(int16_t hc;)
PP(int16_t newstate;)
PP(int16_t redraw;)
{
	int16_t ret;

	gsx_sclip((GRECT *)&xc);
#if BINEXACT
	ret = ob_change((LPTREE)tree, drawob, newstate, redraw); /* BUG: ob_change does not return anything */
#else
	ob_change((LPTREE)tree, drawob, newstate, redraw);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd87a */
int16_t rsrc_free(NOTHING)
{
	int16_t ret;

	ret = rs_free((intptr_t)pglobal);
	dsptch();
	return ret;
}


/* 100de: 00fdd892 */
int16_t rsrc_gaddr(P(int16_t) rstype, P(int16_t) rsid, P(VOIDPTR *) paddr)
PP(int16_t rstype;)
PP(int16_t rsid;)
PP(VOIDPTR *paddr;)
{
	int16_t ret;

	ret = rs_gaddr((intptr_t)pglobal, rstype, rsid, paddr);
	dsptch();
	return ret;
}


/* 100de: 00fdd8b8 */
int16_t shel_write(P(int16_t) doex, P(int16_t) isgr, P(int16_t) iscr, P(const char *) pcmd, P(const char *) ptail)
PP(int16_t doex;)
PP(int16_t isgr;)
PP(int16_t iscr;)
PP(char *pcmd;)
PP(char *ptail;)
{
	int16_t ret;

	ret = sh_write(doex, isgr, iscr, pcmd, ptail);
	dsptch();
	return ret;
}


/* 100de: 00fdd8e4 */
int16_t shel_get(P(char *) pbuffer, P(int16_t) len)
PP(char *pbuffer;)
PP(int16_t len;)
{
	int16_t ret;

	ret = sh_get(pbuffer, len);
	dsptch();
	return ret;
}


/* 100de: 00fdd900 */
int16_t shel_put(P(const char *) pdata, P(int16_t) len)
PP(const char *pdata;)
PP(int16_t len;)
{
	int16_t ret;

	ret = sh_put(pdata, len);
	dsptch();
	return ret;
}


/* 100de: 00fdd91c */
int16_t wind_close(P(int16_t) handle)
PP(int16_t handle;)
{
	int16_t ret;

#if BINEXACT
	ret = wm_close(handle); /* BUG: wm_close does not return anything */
#else
	wm_close(handle);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd932 */
int16_t wind_delete(P(int16_t) handle)
PP(int16_t handle;)
{
	int16_t ret;

#if BINEXACT
	ret = wm_delete(handle); /* BUG: wm_delete does not return anything */
#else
	wm_delete(handle);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd948 */
int16_t wind_find(P(int16_t) mx, P(int16_t) my)
PP(int16_t mx;)
PP(int16_t my;)
{
	int16_t ret;

	ret = wm_find(mx, my);
	dsptch();
	return ret;
}


/* 100de: 00fdd964 */
int16_t wind_update(P(int16_t) beg_update)
PP(int16_t beg_update;)
{
	int16_t ret;

#if BINEXACT
	ret = wm_update(beg_update); /* BUG: wm_update does not return anything */
#else
	wm_update(beg_update);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd97a */
int16_t wind_create(P(uint16_t) kind, P(int16_t) wx, P(int16_t) wy, P(int16_t) ww, P(int16_t) wh)
PP(uint16_t kind;)
PP(int16_t wx;)
PP(int16_t wy;)
PP(int16_t ww;)
PP(int16_t wh;)
{
	int16_t ret;

	ret = wm_create(kind, (GRECT *)&wx);
	dsptch();
	return ret;
}


/* 100de: 00fdd99a */
int16_t wind_open(P(int16_t) handle, P(int16_t) wx, P(int16_t) wy, P(int16_t) ww, P(int16_t) wh)
PP(int16_t handle;)
PP(int16_t wx;)
PP(int16_t wy;)
PP(int16_t ww;)
PP(int16_t wh;)
{
	int16_t ret;

#if BINEXACT
	ret = wm_open(handle, (GRECT *)&wx); /* BUG: wm_open does not return anything */
#else
	wm_open(handle, (GRECT *)&wx);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdd9ba */
int16_t wind_get(P(int16_t) w_handle, P(int16_t) w_field, P(int16_t *) pw1, P(int16_t *) pw2, P(int16_t *) pw3, P(int16_t *) pw4)
PP(int16_t w_handle;)
PP(int16_t w_field;)
PP(int16_t *pw1;)
PP(int16_t *pw2;)
PP(int16_t *pw3;)
PP(int16_t *pw4;)
{
	int16_t wm_ox[4];
	int16_t ret;

#if BINEXACT
	ret = wm_get(w_handle, w_field, wm_ox); /* BUG: wm_get does not return anything */
#else
	wm_get(w_handle, w_field, wm_ox);
	ret = TRUE;
#endif
	dsptch();
	*pw1 = wm_ox[0];
	*pw2 = wm_ox[1];
	*pw3 = wm_ox[2];
	*pw4 = wm_ox[3];
	return ret;
}


/* 100de: 00fdd9fa */
int16_t wind_set(P(int16_t) w_handle, P(int16_t) w_field, P(int16_t) w2, P(int16_t) w3, P(int16_t) w4, P(int16_t) w5)
PP(int16_t w_handle;)
PP(int16_t w_field;)
PP(int16_t w2;)
PP(int16_t w3;)
PP(int16_t w4;)
PP(int16_t w5;)
{
	int16_t ret;

#if BINEXACT
	ret = wm_set(w_handle, w_field, &w2); /* BUG: wm_set does not return anything */
#else
	wm_set(w_handle, w_field, &w2);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}


/* 100de: 00fdda1e */
int16_t wind_calc(P(int16_t) wctype, P(uint16_t) kind, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h, P(int16_t *) px, P(int16_t *) py, P(int16_t *) pw, P(int16_t *) ph)
PP(int16_t wctype;)
PP(uint16_t kind;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
PP(int16_t *px;)
PP(int16_t *py;)
PP(int16_t *pw;)
PP(int16_t *ph;)
{
	int16_t ret;

#if BINEXACT
	ret = wm_calc(wctype, kind, x, y, w, h, px, py, pw, ph); /* BUG: wm_calc does not return anything */
#else
	wm_calc(wctype, kind, x, y, w, h, px, py, pw, ph);
	ret = TRUE;
#endif
	dsptch();
	return ret;
}
