/*	GEMOBLIB.C	03/15/84 - 02/08/85	Gregg Morris		*/
/*	to 68k		03/09/85 - 04/05/85	Lowell Webster		*/
/*	Reg Opt		03/11/85		Derek Mui		*/
/*	Clean up	09/19/85		Derek Mui		*/
/*	Trying 1.2	10/11/85		Derek Mui		*/
/*	removed one variable from get_par	01/03/87 Mike Schmal	*/
/*	Fix at ob_draw of get_par	3/9/87	Derek Mui		*/
/*	Restore back into C language from Ver 3.01	8/29/90	D.Mui	*/
/*	Added 3D and color icon			7/7/92	D.Mui		*/
/*	Folded in new 3D codes			8/1/92	D.Mui		*/
/*	Various 3D button & 256 color fixes,				*/
/*	new call ob_gclip()			8/6/92	kbad		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gsxdefs.h"


#define ASM_HACKS 0
#ifdef __ALCYON__
#if (TOSVERSION <= 0x106)
#undef ASM_HACKS
#define ASM_HACKS 1
#endif
#endif

/*
 * Note on the assembler snippets below:
 * - some of them just look as if the optimize pass has
 *   not been run. However, for other parts it is clearly
 *   needed.
 * - I don't know how it was achieved originally (maybe
 *   just using the generated assembly and hand-optimizing
 *   that), but it is clear (at least in some places),
 *   that the final code was not produced by the compiler
 * - In some cases the "optimization" is even worse as what
 *   would been produced by the compiler, eg. some adda.l
 *   have not been changed into adda.w
 * - changes that are done mostly are:
 *   - move.l An,-(a7) -> pea (An)
 *   - postponing stack corrections for several function
 *     calls until after the last one
 *   - accessing two consecutive shorts as a long
 */



#if BINEXACT
STATIC TEDINFO edblk;
STATIC BITBLK bi; /* WTF */
STATIC ICONBLK ib;
#endif

typedef uint16_t (*PARMBFUNC) PROTO((PARMBLK *f_data));

uint16_t far_call PROTO((PARMBFUNC f_code, PARMBLK *f_data));

#if AESVERSION >= 0x200
/* 306de: 00e232d0 */
uint16_t far_call(P(PARMBFUNC) fcode, P(PARMBLK *) fdata)
PP(PARMBFUNC fcode;)
PP(PARMBLK *fdata;)
{
	return (*fcode) (fdata);
}
#endif



/*
 *	Routine to take an unformatted raw string and based on a
 *	template string build a formatted string.
 */
/* 306de: 00e232e4 */
/* 104de: 00fe2ce2 */
/* 106de: 00e24df0 */
asm("    .globl _ob_fformat");
asm("_ob_fformat: .text");
VOID ob_format(P(int16_t) just, P(char *) raw_str, P(char *) tmpl_str, P(char *) fmtstr)
PP(int16_t just;)
PP(char *raw_str;)
PP(char *tmpl_str;)
PP(char *fmtstr;)
{
	register char *pfbeg, *ptbeg, *prbeg;
#if BINEXACT
	char *pfend;
#endif
	char *ptend, *prend;
	register int16_t inc, ptlen, prlen;

	if (*raw_str == '@')
	{
#if ASM_HACKS
		/* WTF? */
		asm("clr.b      (a0)");
#else
		*raw_str = '\0';
#endif
	}

	pfbeg = fmtstr;
	ptbeg = tmpl_str;
	prbeg = raw_str;

	ptlen = strlen(tmpl_str);
	prlen = strlen(raw_str);

	inc = 1;
	pfbeg[ptlen] = '\0';
	if (just == TE_RIGHT)
	{
		inc = -1;
		pfbeg = pfbeg + ptlen - 1;
		ptbeg = ptbeg + ptlen - 1;
		prbeg = prbeg + prlen - 1;
	}

#if BINEXACT
	pfend = pfbeg + (inc * ptlen);
#endif
	ptend = ptbeg + (inc * ptlen);
	prend = prbeg + (inc * prlen);

	while (ptbeg != ptend)
	{
		if (*ptbeg != '_')
		{
			*pfbeg = *ptbeg;
		} else
		{
			if (prbeg != prend)
			{
				*pfbeg = *prbeg;
				prbeg += inc;
			} else
				*pfbeg = '_';
		}
		pfbeg += inc;
		ptbeg += inc;
	}
}


/*
 *	Routine to load up and call a user defined object draw or change 
 *	routine.
 */
/* 306de: 00e2339a */
/* 104de: 00fe2d84 */
/* 106de: 00e24ea2 */
LINEF_STATIC int16_t ob_user(P(LPTREE) tree, P(int16_t) obj, P(GRECT *) pt, P(intptr_t) userblk, P(int16_t) curr_state, P(int16_t) new_state)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(GRECT *pt;)
PP(intptr_t userblk;)
PP(int16_t curr_state;)
PP(int16_t new_state;)
{
	PARMBLK pb;

	pb.pb_tree = (OBJECT *)tree;
	pb.pb_obj = obj;
#if ASM_HACKS
	asm("move.l     22(a6),-24(a6)");
	asm("pea.l      -20(a6)");
	asm("move.l     14(a6),-(a7)");
	asm("jsr        _rc_copy");
	asm("pea.l      -12(a6)");
	asm("jsr        _gsx_gclip");
	asm("movea.l    18(a6),a0");
	asm("move.l     4(a0),-4(a6)");
	asm("pea.l      -30(a6)");
	asm("movea.l    18(a6),a0");
	asm("move.l     (a0),-(a7)");
	asm("jsr        _far_call");
	asm("adda.w     #20,a7");
#else
	pb.pb_prevstate = curr_state;
	pb.pb_currstate = new_state;
	rc_copy(pt, (GRECT *)&pb.pb_x);
	gsx_gclip((GRECT *)&pb.pb_xc);
	pb.pb_parm = LLGET(userblk + 4);
	return far_call((PARMBFUNC)(intptr_t)LLGET(userblk), ADDR(&pb));
#endif
}



/*
 *	Routine to draw an object from an object tree.
 */
/* 306de: 00e233f2 */
/* 104de: 00fe2dc6 */
/* 106de: 00e24ef2 */
LINEF_STATIC VOID just_draw(P(LPTREE) tree, P(int16_t) obj, P(int16_t) sx, P(int16_t) sy)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(register int16_t sx;)
PP(register int16_t sy;)
{
	int16_t bcol, tcol, ipat, icol, tmode, th;
	int16_t state, obtype, len, flags;
	intptr_t spec;
	int16_t tmpx, tmpy, tmpth;
	char ch;
	GRECT t, c;
	register GRECT *pt;
#if !BINEXACT
	BITBLK bi;
	ICONBLK ib;
	TEDINFO edblk;
#endif

	pt = &t;

#if ASM_HACKS
	/* WTF code even worse than before */
	asm("pea.l      -12(a6)");
	asm("move.l     a5,-(a7)");
	asm("pea.l      -20(a6)");
	asm("pea.l      -16(a6)");
	asm("pea.l      -14(a6)");
	asm("pea.l      -24(a6)");
	asm("move.w     d6,-(a7)");
	asm("move.l     d7,-(a7)");
	asm("jsr        _ob_sst");
	asm("adda.l     #30,a7");
	asm("move.b     d0,-32(a6)");
#else
	ch = ob_sst(tree, obj, &spec, &state, &obtype, &flags, pt, &th);
#endif

	if ((flags & HIDETREE) || (spec == -1L))
		return;

	pt->g_x = sx;
	pt->g_y = sy;

	/*
	 * do trivial reject with full extent including, outline, shadow,
	 * & thickness
	 * BUG: this rejects USERDEFs which draw more than a 3 border outline.
	 * It also rejects TEDINFOs with an outline thickness of more than 3 pixels.
	 */
	if (gl_wclip && gl_hclip)
	{
#if ASM_HACKS
		asm("pea.l      -48(a6)");
		asm("pea.l      (a5)");
		asm("jsr        _rc_copy");
		asm("moveq.l    #-3,d0");
		asm("btst       #4,-13(a6)");
		asm("bne.s      L9801");
		asm("move.w     -12(a6),d1");
		asm("bge.s      L9800");
		asm("moveq.l    #3,d0");
		asm("L9800:");
		asm("muls.w     d1,d0");
		asm("L9801:");
		asm("move.w     d0,(a7)");
		asm("pea.l      -48(a6)");
		asm("jsr        _gr_inside");
		asm("pea.l      -48(a6)");
		asm("jsr        _gsx_chkclip");
		asm("adda.w     #16,a7");
		asm("tst.w      d0");
		asm("beq        L9999");
#else
		rc_copy(pt, &c);
		if (state & OUTLINED)
			gr_inside(&c, -3);
		else
			gr_inside(&c, ((th < 0) ? (3 * th) : (-3 * th)));
		if (!(gsx_chkclip(&c)))
			return;
#endif
	}
	
	/*
	 * for all tedinfo types get copy of ted and crack the
	 * color word and set the text color
	 */
	if (obtype != G_STRING)
	{
#if ASM_HACKS
		asm("move.w     -12(a6),d0");
		asm("bge.s      L9810");
		asm("clr.w      d0");
		asm("L9810:");
		asm("move.w     d0,-30(a6)");
#else
		tmpth = (th < 0) ? 0 : th;
#endif
		tmode = MD_REPLACE;
		tcol = BLACK;

		switch (obtype)
		{
		case G_BOXTEXT:
		case G_FBOXTEXT:
		case G_TEXT:
		case G_FTEXT:
#if ASM_HACKS
			asm("move.w     #28,(a7)");
			asm("move.l     -24(a6),-(a7)");
			asm("move.l     #_edblk,-(a7)");
			asm("jsr        _LBCOPY");
			asm("pea.l      -10(a6)");
			asm("pea.l      -8(a6)");
			asm("pea.l      -6(a6)");
			asm("pea.l      -4(a6)");
			asm("pea.l      -2(a6)");
			asm("move.w     _edblk+18,-(a7)");
			asm("jsr        _gr_crack");
			asm("adda.l     #30,a7");
#else
			LBCOPY(&edblk, (VOIDPTR)spec, sizeof(TEDINFO));
			gr_crack(edblk.te_color, &bcol, &tcol, &ipat, &icol, &tmode);
#endif
			break;
		}
		
		/*
		 * for all box types crack the color if not ted and
		 * draw the box with border
		 */
		switch (obtype)
		{
		case G_BOX:
		case G_BOXCHAR:
		case G_IBOX:
#if ASM_HACKS
			asm("pea.l      -10(a6)");
			asm("pea.l      -8(a6)");
			asm("pea.l      -6(a6)");
			asm("pea.l      -4(a6)");
			asm("pea.l      -2(a6)");
			asm("move.l     -24(a6),d0");
			asm("move.w     d0,-(a7)");
			asm("jsr        _gr_crack");
			asm("adda.l     #22,a7");
#else
			gr_crack(LLOWD(spec), &bcol, &tcol, &ipat, &icol, &tmode);
#endif
			/* fall through */
		case G_BUTTON:
			if (obtype == G_BUTTON)
			{
				bcol = BLACK;

				{
#if ASM_HACKS
					asm("clr.l      -8(a6)");
#else
					ipat = IP_HOLLOW;
					icol = WHITE;
#endif
				}

			}
			/* fall through */
		case G_BOXTEXT:
		case G_FBOXTEXT:
			/* draw box's border */
			if (th != 0)
			{
#if ASM_HACKS
				asm("move.w     -2(a6),(a7)");
				asm("move.l     #1,-(a7)");
				asm("jsr        _gsx_attr");
				asm("move.w     -12(a6),(a7)");
				asm("move.l     4(a5),-(a7)");
				asm("move.l     (a5),-(a7)");
				asm("jsr        _gr_box");
				asm("adda.w     #12,a7");
#else
				gsx_attr(FALSE, MD_REPLACE, bcol);
				gr_box(pt->g_x, pt->g_y, pt->g_w, pt->g_h, th);
#endif
			}
			/* draw filled box  */
			if (obtype != G_IBOX)		/* 8/1/92 */
			{
#if ASM_HACKS
				asm("move.w     -30(a6),(a7)");
				asm("move.l     a5,-(a7)");
				asm("jsr        _gr_inside");
				asm("move.l     a5,(a7)");
				asm("move.l     -8(a6),-(a7)");
				asm("jsr        _gr_rect");
				asm("move.w     -30(a6),d0");
				asm("neg.w      d0");
				asm("move.w     d0,(a7)");
				asm("move.l     a5,-(a7)");
				asm("jsr        _gr_inside");
				asm("adda.w     #12,a7");
#else
				gr_inside(pt, tmpth);

				gr_rect(icol, ipat, pt);
				gr_inside(pt, -tmpth);
#endif
			}
			break;
		}

		gsx_attr(TRUE, tmode, tcol);
		
		/* do whats left for all the other types */
		switch (obtype)
		{
		case G_FTEXT:
		case G_FBOXTEXT:
#if ASM_HACKS
			asm("move.l     _edblk,(a7)");
			asm("move.l     #_D+6910,-(a7)"); /* D.g_rawstr */
			asm("jsr        _LSTCPY");
			asm("move.l     _edblk+4,(a7)");
			asm("move.l     #_D+6991,-(a7)"); /* D.g_tmpstr */
			asm("jsr        _LSTCPY");
			asm("move.l     #_D+7153,(a7)"); /* D.g_fmtstr */
			asm("move.l     #_D+6991,-(a7)"); /* D.g_tmpstr */
			asm("move.l     #_D+6910,-(a7)"); /* D.g_rawstr */
			asm("move.w     _edblk+16,-(a7)");
			asm("jsr        _ob_format");
			asm("adda.l     #18,a7");
#else
			LSTCPY(&D.g_rawstr[0], edblk.te_ptext);
			LSTCPY(&D.g_tmpstr[0], edblk.te_ptmplt);
			ob_format(edblk.te_just, D.g_rawstr, D.g_tmpstr, D.g_fmtstr);
#endif
			/* fall thru to gr_gtext */
		case G_BOXCHAR:
			edblk.te_ptext = D.g_fmtstr;
			if (obtype == G_BOXCHAR)
			{
				D.g_fmtstr[0] = ch;
				D.g_fmtstr[1] = '\0';
				edblk.te_just = TE_CNTR;
				edblk.te_font = IBM;
			}
			/* fall thru to gr_gtext */
		case G_TEXT:
		case G_BOXTEXT:
#if ASM_HACKS
			asm("move.w     -30(a6),(a7)");
			asm("pea.l      (a5)");
			asm("jsr        _gr_inside");
			asm("move.w     -10(a6),(a7)");
			asm("pea.l      (a5)");
			asm("move.l     _edblk,-(a7)");
			asm("move.w     _edblk+12,-(a7)");
			asm("move.w     _edblk+16,-(a7)");
			asm("jsr        _gr_gtext");
			asm("move.w     -30(a6),d0");
			asm("neg.w      d0");
			asm("move.w     d0,(a7)");
			asm("pea.l      (a5)");
			asm("jsr        _gr_inside");
			asm("adda.l     #20,a7");
#else
			gr_inside(pt, tmpth);

			/* July 30 1992 - ml.  Draw text of 3D objects */ /* 8/1/92 */
			gr_gtext(edblk.te_just, edblk.te_font, edblk.te_ptext, pt, tmode);
			gr_inside(pt, -tmpth);
#endif
			break;
		case G_IMAGE:
#if ASM_HACKS
			asm("move.w     #14,(a7)");
			asm("move.l     -24(a6),-(a7)");
			asm("move.l     #_bi,-(a7)");
			asm("jsr        _LBCOPY");
			asm("clr.w      (a7)");
			asm("move.w     _bi+12,-(a7)");
			asm("move.w     #2,-(a7)");
			asm("move.w     _bi+6,-(a7)");
			asm("move.w     _bi+4,d0");
			asm("asl.w      #3,d0");
			asm("move.w     d0,-(a7)");
			asm("move.w     _gl_width,d0");
			asm("ext.l      d0");
			asm("divs.w     #8,d0");
			asm("move.w     d0,-(a7)");
			asm("move.l     (a5),-(a7)");
			asm("clr.l      -(a7)");
			asm("move.w     _bi+4,-(a7)");
			asm("move.l     _bi+8,-(a7)");
			asm("move.l     _bi,-(a7)");
			asm("jsr        _gsx_blt");
			asm("adda.l     #36,a7");
#else
			LBCOPY(&bi, (VOIDPTR)spec, sizeof(BITBLK));
			gsx_blt(bi.bi_pdata, bi.bi_x, bi.bi_y, bi.bi_wb,
					0x0L, pt->g_x, pt->g_y, gl_width / 8, bi.bi_wb * 8, bi.bi_hl, MD_TRANS, bi.bi_color, WHITE);
#endif
			break;
		case G_ICON:
#if ASM_HACKS
			asm("move.w     #34,(a7)");
			asm("move.l     -24(a6),-(a7)");
			asm("move.l     #_ib,-(a7)");
			asm("jsr        _LBCOPY");
			asm("move.l     (a5),d0");
			asm("add.l      d0,_ib+18");
			asm("add.l      d0,_ib+26");
			asm("move.l     #_ib+26,(a7)");
			asm("move.l     #_ib+18,-(a7)");
			asm("move.w     _ib+16,-(a7)");
			asm("move.l     _ib+12,-(a7)");
			asm("move.l     _ib+8,-(a7)");
			asm("move.l     _ib+4,-(a7)");
			asm("move.l     _ib+0,-(a7)");
			asm("move.w     -14(a6),-(a7)");
			asm("jsr        _gr_gicon");
			asm("adda.l     #32,a7");
#else
			LBCOPY(&ib, (VOIDPTR)spec, sizeof(ICONBLK));
			ib.ib_xicon += pt->g_x;
			ib.ib_yicon += pt->g_y;
			ib.ib_xtext += pt->g_x;
			ib.ib_ytext += pt->g_y;
			gr_gicon(state, ib.ib_pmask, ib.ib_pdata, ib.ib_ptext,
					 ib.ib_char, ib.ib_xchar, ib.ib_ychar, (GRECT *)&ib.ib_xicon, (GRECT *)&ib.ib_xtext);
#endif
			state &= ~SELECTED;
			break;
		case G_USERDEF:
#if ASM_HACKS
			/* WTF code even worse than before */
			asm("move.w     -14(a6),(a7)");
			asm("move.w     -14(a6),-(a7)");
			asm("move.l     -24(a6),-(a7)");
			asm("pea.l      (a5)");
			asm("move.w     d6,-(a7)");
			asm("move.l     d7,-(a7)");
			asm("jsr        _ob_user");
			asm("adda.l     #16,a7");
			asm("move.w     d0,-14(a6)");
#else
			state = ob_user(tree, obj, pt, spec, state, state);
#endif
			break;
		}
	}
	if (obtype == G_STRING ||			/* 8/1/92 */
		obtype == G_TITLE ||
		obtype == G_BUTTON)
	{
		len = LBWMOV(ad_intin, (VOIDPTR)spec);
		if (len)
		{								/* 8/3/92 */
			gsx_attr(TRUE, MD_TRANS, BLACK);

			tmpy = pt->g_y + ((pt->g_h - gl_hchar) / 2);
			if (obtype == G_BUTTON)
			{
				tmpx = pt->g_x + ((pt->g_w - (len * gl_wchar)) / 2);
			} else
			{
				tmpx = pt->g_x;
			}

			gsx_tblt(IBM, tmpx, tmpy, len);
		}
	}

	if (state)
	{
		if (state & OUTLINED)
		{
			{
#if ASM_HACKS
				asm("move.w     #1,(a7)");
				asm("move.l     #1,-(a7)");
				asm("jsr        _gsx_attr");
				asm("move.w     #1,(a7)");
				asm("move.l     4(a5),-(a7)");
				asm("addi.l     #0x00060006,(a7)");
				asm("move.l     (a5),-(a7)");
				asm("subi.l     #0x00030003,(a7)");
				asm("jsr        _gr_box");
				asm("clr.w      (a7)");
				asm("move.l     #1,-(a7)");
				asm("jsr        _gsx_attr");
				asm("move.w     #2,(a7)");
				asm("move.l     4(a5),-(a7)");
				asm("addi.l     #0x00040004,(a7)");
				asm("move.l     (a5),-(a7)");
				asm("subi.l     #0x00020002,(a7)");
				asm("jsr        _gr_box");
				asm("adda.w     #24,a7");
#else
				gsx_attr(FALSE, MD_REPLACE, BLACK);
				gr_box(pt->g_x - 3, pt->g_y - 3, pt->g_w + 6, pt->g_h + 6, 1);
				gsx_attr(FALSE, MD_REPLACE, WHITE);
				gr_box(pt->g_x - 2, pt->g_y - 2, pt->g_w + 4, pt->g_h + 4, 2);
#endif
			}
		}

		if (th > 0)
		{
			gr_inside(pt, th);
		} else
		{
#if ASM_HACKS
			asm("neg.w      -12(a6)");
#else
			th = -th;
#endif
		}

		if ((state & SHADOWED) && th)
		{
#if ASM_HACKS
			asm("move.w     -2(a6),(a7)");
			asm("move.w     #25,-(a7)");
			asm("jsr        _gsx_1code");
			asm("move.w     -12(a6),d0");
			asm("asl.w      #1,d0");
			asm("move.w     d0,(a7)");
			asm("move.w     4(a5),-(a7)");
			asm("move.w     -12(a6),d0");
			asm("add.w      d0,(a7)");
			asm("move.w     2(a5),-(a7)");
			asm("move.w     6(a5),d0");
			asm("add.w      d0,(a7)");
			asm("move.w     -12(a6),d0");
			asm("add.w      d0,(a7)");
			asm("move.w     (a5),-(a7)");
			asm("clr.w      -(a7)");
			asm("move.l     #0x00010001,-(a7)");
			asm("jsr        _bb_fill");
			asm("move.w     -12(a6),d0");
			asm("muls.w     #3,d0");
			asm("move.w     d0,(a7)");
			asm("move.w     6(a5),d0");
			asm("add.w      d0,(a7)");
			asm("move.w     -12(a6),d0");
			asm("asl.w      #1,d0");
			asm("move.w     d0,-(a7)");
			asm("move.l     (a5),-(a7)");
			asm("move.w     4(a5),d0");
			asm("add.w      d0,(a7)");
			asm("move.w     -12(a6),d0");
			asm("add.w      d0,(a7)");
			asm("clr.w      -(a7)");
			asm("move.l     #0x00010001,-(a7)");
			asm("jsr        _bb_fill");
			asm("adda.w     #26,a7");
#else
			vsf_color(bcol);
			/* draw the vertical line */
			bb_fill(MD_REPLACE, FIS_SOLID, IP_HOLLOW, pt->g_x, pt->g_y + pt->g_h + th, pt->g_w + th, 2 * th);
			/* draw the horizontal line */
			bb_fill(MD_REPLACE, FIS_SOLID, IP_HOLLOW, pt->g_x + pt->g_w + th, pt->g_y, 2 * th, pt->g_h + (3 * th));
#endif
		}

		if (state & CHECKED)
		{
#if ASM_HACKS
			asm("move.w     #1,(a7)");
			asm("move.l     #0x00010002,-(a7)");
			asm("jsr        _gsx_attr");
			asm("move.w     #8,_intin");
			asm("move.w     #1,(a7)");
			asm("move.l     (a5),-(a7)");
			asm("addi.l     #0x00020000,(a7)");
			asm("move.w     #3,-(a7)");
			asm("jsr        _gsx_tblt");
			asm("adda.w     #10,a7");
#else
			gsx_attr(TRUE, MD_TRANS, BLACK);
			intin[0] = 0x08;			/* a check mark */
			gsx_tblt(IBM, pt->g_x + 2, pt->g_y, 1);
#endif
		}

		if (state & CROSSED)
		{
#if ASM_HACKS
			asm("clr.w      (a7)");
			asm("move.l     #2,-(a7)");
			asm("jsr        _gsx_attr");
			asm("move.l     (a5),-(a7)");
			asm("move.l     4(a5),d0");
			asm("sub.l      #0x00010001,d0");
			asm("add.l      d0,(a7)");
			asm("move.l     (a5),-(a7)");
			asm("jsr        _gsx_cline");
			asm("move.w     2(a5),(a7)");
			asm("move.l     (a5),d1");
			asm("move.l     4(a5),d0");
			asm("sub.l      #0x00010001,d0");
			asm("add.l      d0,d1");
			asm("swap       d1");
			asm("move.l     d1,-(a7)");
			asm("move.w     (a5),-(a7)");
			asm("jsr        _gsx_cline");
			asm("adda.w     #18,a7");
#else
			gsx_attr(FALSE, MD_TRANS, WHITE);
			gsx_cline(pt->g_x, pt->g_y, pt->g_x + pt->g_w - 1, pt->g_y + pt->g_h - 1);
			gsx_cline(pt->g_x, pt->g_y + pt->g_h - 1, pt->g_x + pt->g_w - 1, pt->g_y);
#endif
		}

		if (state & DISABLED)
		{
#if ASM_HACKS
			asm("move.l     #0x00190000,-(a7)");
			asm("jsr        _gsx_1code");
			asm("move.l     4(a5),-(a7)");
			asm("move.l     (a5),-(a7)");
			asm("move.w     #4,-(a7)");
			asm("move.l     #0x00020002,-(a7)");
			asm("jsr        _bb_fill");
			asm("adda.l     #18,a7");
#else
			vsf_color(WHITE);

			bb_fill(MD_TRANS, FIS_PATTERN, IP_4PATT, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
#endif
		}

		if ((state & SELECTED))
		{
#if ASM_HACKS
			asm("move.l     4(a5),-(a7)");
			asm("move.l     (a5),-(a7)");
			asm("move.w     #7,-(a7)");
			asm("move.l     #0x00030001,-(a7)");
			asm("jsr        _bb_fill");
			asm("adda.l     #14,a7");
#else
			bb_fill(MD_XOR, FIS_SOLID, IP_SOLID, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
#endif
		}
		/* July 30 1992 - ml */ /* 8/1/92 */
	}
#if ASM_HACKS
	asm("L9999:");
#endif
}



/*
 * AES #42 - objc_draw - Draw an AES object tree.
 *
 *	Object draw routine that walks tree and draws appropriate objects.
 */
/* 306de: 00e23ab2 */
/* 104de: 00fe3366 */
/* 106de: 00e25544 */
VOID ob_draw(P(LPTREE) tree, P(int16_t) obj, P(int16_t) depth)
PP(register LPTREE tree;)
PP(int16_t obj;)
PP(int16_t depth;)
{
	int16_t last, pobj;
	int16_t sx, sy;

#if ASM_HACKS
	asm("movea.l    d7,a0");
	asm("move.w     12(a6),d1");
	asm("bne.s      L9700");
	asm("move.w     #-1,-2(a6)");
	asm("bra.s      L9701");
	asm("L9700:")
	asm("muls.w     #24,d1");
	asm("adda.l     d1,a0");
	asm("move.w     (a0),-2(a6)");
	asm("L9701:")
	asm("move.w     12(a6),(a7)");
	asm("move.l     d7,-(a7)");
	asm("jsr        _get_par");
	asm("addq.l     #4,a7");
	asm("move.w     d0,-4(a6)");
	asm("cmp.w      #-1,d0");
	asm("beq.s      L9702");
	asm("pea.l      -8(a6)");
	asm("pea.l      -6(a6)");
	asm("move.w     -4(a6),-(a7)");
	asm("move.l     d7,-(a7)");
	asm("jsr        _ob_foffset");
	asm("adda.l     #14,a7");
	asm("bra.s      L9703");
	asm("L9702:")
	asm("clr.l      -8(a6)");
	asm("L9703:")
	
#else
	last = (obj == ROOT) ? NIL : LWGET(OB_NEXT(obj));
	pobj = get_par(tree, obj);

	if (pobj != NIL)
		ob_offset(tree, pobj, &sx, &sy);
	else
		sx = sy = 0;
#endif

	gsx_moff();
#if ASM_HACKS
	asm("move.w     14(a6),(a7)");
	asm("move.w     -8(a6),-(a7)");
	asm("move.w     -6(a6),-(a7)");
	asm("move.l     #_just_draw,-(a7)");
	asm("move.w     -2(a6),-(a7)");
	asm("move.w     12(a6),-(a7)");
	asm("move.l     d7,-(a7)");
	asm("jsr        _everyobj");
	asm("adda.l     #16,a7");
#else
	everyobj(tree, obj, last, just_draw, sx, sy, depth);
#endif
	gsx_mon();
}


/*
 * AES #43 - objc_find - Find which object that lies at the specified screen position.
 *
 *	Routine to find out which object a certain mx,my value is
 *	over.  Since each parent object contains its children the
 *	idea is to walk down the tree, limited by the depth parameter,
 *	and find the last object the mx,my location was over.
 */
/************************************************************************/
/* o b _ f i n d                                                        */
/************************************************************************/
/* 306de: 00e23b52 */
/* 104de: 00fe33e6 */
/* 106de: 00e255de */
int16_t ob_find(P(LPTREE) tree, P(int16_t) currobj, P(int16_t) depth, P(int16_t) mx, P(int16_t) my)
PP(register LPTREE tree;)
PP(register int16_t currobj;)
PP(register int16_t depth;)
PP(int16_t mx;)
PP(int16_t my;)
{
	int16_t lastfound;
	int16_t dosibs;
	BOOLEAN done;
	GRECT t, o;
	int16_t parent, childobj, flags;
	register GRECT *pt;

	pt = &t;

	lastfound = NIL;

	if (currobj == 0)
	{
#if ASM_HACKS
		asm("clr.l      -(a7)");
		asm("clr.l      -(a7)");
		asm("pea.l      -22(a6)");
		asm("jsr        _r_set");
		asm("adda.l     #12,a7");
#else
		r_set(&o, 0, 0, 0, 0);
#endif
	} else
	{
#if ASM_HACKS
		asm("move.w     d6,(a7)");
		asm("move.l     d7,-(a7)");
		asm("jsr        _get_par");
		asm("move.w     d0,-24(a6)");
		asm("pea.l      -22(a6)");
		asm("move.w     -24(a6),-(a7)");
		asm("move.l     d7,-(a7)");
		asm("jsr        _ob_factxywh");
		asm("adda.w     #14,a7");
#else
		parent = get_par(tree, currobj);
		ob_actxywh(tree, parent, &o);
#endif
	}

#if ASM_HACKS
	asm("clr.l      -6(a6)");
#else
	done = FALSE;
	dosibs = FALSE;
#endif

	while (!done)
	{
		/* if inside this obj, might be inside a child, so check */

		{
			ob_relxywh(tree, currobj, pt);
			pt->g_x += o.g_x;
			pt->g_y += o.g_y;
		}
		
		flags = LWGET(OB_FLAGS(currobj));
		if (inside(mx, my, pt) && !(flags & HIDETREE))
		{
			lastfound = currobj;

			childobj = LWGET(OB_TAIL(currobj));
			if ((childobj != NIL) && depth)
			{
				currobj = childobj;
				depth--;
				o.g_x = pt->g_x;
				o.g_y = pt->g_y;
				dosibs = TRUE;
			} else
			{
				done = TRUE;
			}
		} else
		{
			if (dosibs && lastfound != NIL)
			{
				currobj = get_prev(tree, lastfound, currobj);
				if (currobj == NIL)
					done = TRUE;
			} else
			{
				done = TRUE;
			}
		}
	}
	/* if no one was found this will return NIL */
	return lastfound;
}


/*
 * AES #40 - objc_add - Insert object in an object tree.
 *
 *	Routine to add a child object to a parent object.  The child
 *	is added at the end of the parent's current sibling list.
 *	It is also initialized.
 */
/* 306de: 00e23c82 */
/* 104de: 00fe34f8 */
/* 106de: 00e2570a */
VOID ob_add(P(LPTREE) tree, P(int16_t) parent, P(int16_t) child)
PP(register LPTREE tree;)
PP(register int16_t parent;)
PP(register int16_t child;)
{
	register int16_t lastkid;
	register LPTREE ptail;

	if (parent != NIL && child != NIL)
	{
		/* initialize child */
		LWSET(OB_NEXT(child), parent);

		lastkid = LWGET(ptail = OB_TAIL(parent));
		if (lastkid == NIL)
			/* this is parent's 1st kid, so both head and tail pt to it  */
			LWSET(OB_HEAD(parent), child);
		else
			/* add kid to end of kid list */
			LWSET(OB_NEXT(lastkid), child);
		LWSET(ptail, child);
	}
}


/*
 * AES #41 - objc_delete - Remove object from an object tree.
 *
 *	Routine to delete an object from the tree.
 */
/* 306de: 00e23cee */
/* 104de: 00fe355c */
/* 106de: 00e25776 */
/* BUG: doesnt return FALSE as documented */
asm("  .globl _ob_fdelete");
asm("_ob_fdelete: .text");
VOID ob_delete(P(LPTREE) tree, P(int16_t) obj)
PP(register LPTREE tree;)
PP(register int16_t obj;)
{
	register int16_t parent;
	int16_t prev, nextsib;
	register LPTREE ptail, phead;

	if (obj != ROOT)
	{
		nextsib = LWGET(OB_NEXT(obj));
		parent = get_par(tree, obj);
	} else
		return;

	if (LWGET(phead = OB_HEAD(parent)) == obj)
	{
		/* this is head child in list */
		if (LWGET(ptail = OB_TAIL(parent)) == obj)
		{
			/* this is only child in list, so fix head & tail ptrs */
			nextsib = NIL;
			LWSET(ptail, NIL);
		}
		/* move head ptr to next child in list */
		LWSET(phead, nextsib);
	} else
	{
		/* it's somewhere else, so move pnext around it */
		prev = get_prev(tree, parent, obj);
		LWSET(OB_NEXT(prev), nextsib);
		if (LWGET(ptail = OB_TAIL(parent)) == obj)
			/* this is last child in list, so move tail ptr to prev child in list*/
			LWSET(ptail, prev);
	}
}


/*
 * AES #45 - objc_order - Alter order of object in object tree.
 *
 *	Routine to change the order of an object relative to its
 *	siblings in the tree.  0 is the head of the list and NIL
 *	is the tail of the list.
 */
/* 306de: 00e23d9c */
/* 104de: 00fe35fc */
/* 106de: 00e25824 */
/* BUG: doesnt return FALSE as documented */
VOID ob_order(P(LPTREE) tree, P(int16_t) mov_obj, P(int16_t) new_pos)
PP(register LPTREE tree;)
PP(register int16_t mov_obj;)
PP(int16_t new_pos;)
{
	register int16_t parent;
	int16_t chg_obj, ii;
	register int32_t phead, pnext, pmove;

	if (mov_obj != ROOT)
		parent = get_par(tree, mov_obj);
	else
		return;

	ob_fdelete(tree, mov_obj);
	chg_obj = LWGET(phead = OB_HEAD(parent));
	pmove = OB_NEXT(mov_obj);
	if (new_pos == 0)
	{
		/* put mov_obj at head of list        */
		LWSET(pmove, chg_obj);
		LWSET(phead, mov_obj);
	} else
	{
		/* find new_pos     */
		if (new_pos == NIL)
		{
			chg_obj = LWGET(OB_TAIL(parent));
		} else
		{
			for (ii = 1; ii < new_pos; ii++)
				chg_obj = LWGET(OB_NEXT(chg_obj));
		}
		/* now add mov_obj after chg_obj */
		LWSET(pmove, LWGET(pnext = OB_NEXT(chg_obj)));
		LWSET(pnext, mov_obj);
	}
	if (LWGET(pmove) == parent)
		LWSET(OB_TAIL(parent), mov_obj);
}



/************************************************************************/
/* o b _ e d i t                                                        */
/************************************************************************/
/* see OBED.C */

/*
 * AES #47 - objc_change - Alter display of an object within specified limits.
 *
 *	Routine to change the state of an object and redraw that
 *	object using the current clip rectangle.
 */
/* 306de: 00e23e7a */
/* 104de: 00fe36cc */
/* 106de: 00e25902 */
/* BUG: doesnt return FALSE as documented */
VOID ob_change(P(LPTREE) tree, P(int16_t) obj, P(int16_t) new_state, P(int16_t) redraw)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(uint16_t new_state;)
PP(int16_t redraw;)
{
	int16_t flags, obtype, th;
	GRECT t;
	int16_t curr_state;
	intptr_t spec;
	register GRECT *pt;

	pt = &t;

#if BINEXACT
	asm("pea.l      -6(a6)");
	asm("pea.l      (a5)");
	asm("pea.l      -2(a6)");
	asm("pea.l      -4(a6)");
	asm("pea.l      -16(a6)");
	asm("pea.l      -20(a6)");
	asm("move.w     d6,-(a7)");
	asm("move.l     d7,-(a7)");
	asm("jsr        _ob_sst");
	asm("adda.l     #30,a7");
#else
	ob_sst(tree, obj, &spec, &curr_state, &obtype, &flags, pt, &th);
#endif
	
#if ASM_HACKS
	asm("clr.w      d0");
	asm("move.w     -16(a6),d0");
	asm("cmp.w      14(a6),d0");
	asm("beq        L9699");
	asm("cmpi.l     #-1,-20(a6)");
	asm("beq        L9699");
#else
	if ((curr_state == new_state) || (spec == -1L))
		return;
#endif

	LWSET(OB_STATE(obj), new_state);

	if (redraw)
	{
#if BINEXACT & (AESVERSION < 0x200)
		asm("move.l     a5,(a7)");
		asm("addq.l     #2,(a7)");
		asm("move.l     a5,-(a7)");
		asm("move.w     d6,-(a7)");
		asm("move.l     d7,-(a7)");
		asm("jsr        _ob_foffset");
		asm("adda.l     #10,a7");
#else
		ob_offset(tree, obj, &pt->g_x, &pt->g_y);
#endif

		gsx_moff();

		th = (th < 0) ? 0 : th;

		if (obtype == G_USERDEF)
		{
#if BINEXACT & (AESVERSION < 0x200)
			asm("move.w     14(a6),(a7)");
			asm("move.w     -16(a6),-(a7)");
			asm("move.l     -20(a6),-(a7)");
			asm("move.l     a5,-(a7)");
			asm("move.w     d6,-(a7)");
			asm("move.l     d7,-(a7)");
			asm("bsr        _ob_user");
			asm("adda.l     #16,a7");
#else
			ob_user(tree, obj, pt, spec, curr_state, new_state);
#endif
			redraw = FALSE;
		} else
		{
#if BINEXACT & (AESVERSION < 0x200)
		asm("cmpi.w     #31,-4(a6)");
		asm("beq.s      L9601");
		asm("clr.w      d0");
		asm("move.w     14(a6),d0");
		asm("clr.w      d1");
		asm("move.w     -16(a6),d1");
		asm("eor.w      d1,d0");
		asm("and.w      #1,d0");
		asm("beq.s      L9601");
#else
		if (obtype != G_ICON && ((new_state ^ curr_state) & SELECTED))
#endif
			/* For non-icon objects, see if we can toggle selection by XOR.
			 * G_IMAGE objects must be DEselected by XOR draw, *and*
			 * the image must be redrawn by just_draw().  If they're selected,
			 * just_draw() does the XOR box before redrawing the image.
			 */
			{
#if BINEXACT & (AESVERSION < 0x200)
				asm("move.w     6(a5),(a7)");
				asm("move.w     -6(a6),d0");
				asm("asl.w      #1,d0");
				asm("sub.w      d0,(a7)");
				asm("move.w     4(a5),-(a7)");
				asm("move.w     -6(a6),d0");
				asm("asl.w      #1,d0");
				asm("sub.w      d0,(a7)");
				asm("move.l     (a5),-(a7)");
				asm("move.w     -6(a6),d0");
				asm("swap       d0");
				asm("move.w     -6(a6),d0");
				asm("add.l      d0,(a7)");
				asm("move.w     #7,-(a7)");
				asm("move.l     #0x00030001,-(a7)");
				asm("jsr        _bb_fill");
				asm("adda.l     #12,a7");
#else
				bb_fill(MD_XOR, FIS_SOLID, IP_SOLID, pt->g_x + th,
						pt->g_y + th, pt->g_w - (2 * th), pt->g_h - (2 * th));
#endif
				redraw = FALSE;
			}
		}
#if BINEXACT & (AESVERSION < 0x200)
		asm("L9601:");
#endif

		if (redraw)
			just_draw(tree, obj, pt->g_x, pt->g_y);

		gsx_mon();
	}
#if ASM_HACKS
	asm("L9699:");
#endif
}


/* 306de: 00e23fb6 */
/* 104de: 00fe37f4 */
/* 106de: 00e25a48 */
uint16_t ob_fs(P(LPTREE) tree, P(int16_t) ob, P(int16_t *) pflag)
PP(LPTREE tree;)
PP(int16_t ob;)
PP(int16_t *pflag;)
{
	*pflag = LWGET(OB_FLAGS(ob));
	return LWGET(OB_STATE(ob));
}


/************************************************************************/
/* o b _ a c t x y w h                                                  */
/************************************************************************/
/* 306de: 00e23fea */
/* 104de: 00fe3826 */
/* 106de: 00e25a7c */
asm("  .globl _ob_factxywh");
asm("_ob_factxywh: .text");
VOID ob_actxywh(P(LPTREE) tree, P(int16_t) obj, P(GRECT *) pt)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(register GRECT *pt;)
{
#if BINEXACT & (AESVERSION < 0x200)
	asm("move.l     a5,(a7)");
	asm("addq.l     #2,(a7)");
	asm("move.l     a5,-(a7)");
	asm("move.w     d6,-(a7)");
	asm("move.l     d7,-(a7)");
	asm("bsr        _ob_foffset");
	asm("adda.l     #10,a7");
#else
	ob_offset(tree, obj, &pt->g_x, &pt->g_y);
#endif
	pt->g_w = LWGET(OB_WIDTH(obj));
	pt->g_h = LWGET(OB_HEIGHT(obj));
}


/************************************************************************/
/* o b _ r e l x y w h                                                  */
/************************************************************************/
/* 306de: 00e24042 */
/* 104de: 00fe3876 */
/* 106de: 00e25ad6 */
VOID ob_relxywh(P(LPTREE) tree, P(int16_t) obj, P(GRECT *)pt)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(GRECT *pt;)
{
	LWCOPY(ADDR(pt), (VOIDPTR)OB_X(obj), sizeof(GRECT) / 2);
}


VOID ob_setxywh(P(LPTREE) tree, P(int16_t) obj, P(GRECT *) pt)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(GRECT *pt;)
{
	LWCOPY((VOIDPTR)OB_X(obj), ADDR(pt), sizeof(GRECT) / 2);
}


/*
 * AES #44 - objc_offset - Calculate the true position of an object on the screen.
 *
 *	Routine to find the x,y offset of a particular object relative
 *	to the physical screen.  This involves accumulating the offsets
 *	of all the objects parents up to and including the root.
 */
/* 306de: 00e2409a */
/* 104de: 00fe38c2 */
/* 106de: 00e25b2e */
asm("  .globl _ob_foffset");
asm("_ob_foffset: .text");
VOID ob_offset(P(LPTREE) tree, P(int16_t) obj, P(int16_t *) pxoff, P(int16_t *) pyoff)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(register int16_t *pxoff;)
PP(register int16_t *pyoff;)
{
	*pxoff = *pyoff = 0;
	do
	{
		/* have our parent-- add in his x, y */
		*pxoff += LWGET(OB_X(obj));
		*pyoff += LWGET(OB_Y(obj));
		obj = get_par(tree, obj);
	} while (obj != NIL);
}


/*
 *	Routine to find the object that is previous to us in the
 *	tree.  The idea is we get our parent and then walk down
 *	his list of children until we find a sibling who points to
 *	us.  If we are the first child or we have no parent then
 *	return NIL.
 */
/* 306de: 00e240fe */
/* 104de: 00fe391a */
/* 106de: 00e25b92 */
int16_t get_prev(P(LPTREE) tree, P(int16_t) parent, P(int16_t) obj)
PP(register LPTREE tree;)
PP(int16_t parent;)
PP(register int16_t obj;)
{
	register int16_t prev, nobj, pobj;

	UNUSED(prev);
	pobj = LWGET(OB_HEAD(parent));
	if (pobj != obj)
	{
		while (TRUE)
		{
			nobj = LWGET(OB_NEXT(pobj));
			if (nobj != obj)
				pobj = nobj;
			else
				return pobj;
		}
	} else
		return NIL;
}
