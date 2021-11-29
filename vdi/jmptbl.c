/*
 ******************* jmptbl.c ********************************************
 *
 * $Author: lozben $
 * =======================================================================
 *
 * $Date: 91/01/18 19:04:53 $
 * =======================================================================
 *
 * Revision 3.2  91/01/18  19:04:53  lozben
 * Changed cur_font to CUR_FONT.
 * 
 * Revision 3.1  91/01/10  17:37:41  lozben
 * Made patptr, patmsk, multifill, scrpt2, and scrtchp uppercase, beacause
 * there was a name conflict with the defines and the attribute structure.
 * 
 * Revision 3.0  91/01/03  15:12:02  lozben
 * New generation VDI
 * 
 * Revision 2.1  89/02/21  17:23:19  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  87/11/20  15:16:00  lozben
 * Initial revision
 * 
 *************************************************************************
 */

#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"
#include "gsxdef.h"
#include "gsxextrn.h"

/* VDI functions 1 - 39 */
/* 306de: 00e3d65e */
/* 104de: 00feade6 */
VOID (*jmptb1[]) PROTO((NOTHING)) =
{
	v_opnwk,
	v_clswk,
	v_clrwk,
	v_nop,
	v_escape,
	v_pline,
	v_pmarker,
	d_gtext,
	v_fillarea,
	v_cellarray,
	v_gdp,
	dst_height,
	dst_rotation,
	vs_color,
	vsl_type,
	vsl_width,
	vsl_color,
	vsm_type,
	vsm_height,
	vsm_color,
	dst_font,
	dst_color,
	vsf_interior,
	vsf_style,
	vsf_color,
	vq_color,
	vq_cellarray,
	v_locator,
	v_valuator,
	v_choice,
	v_string,
	vswr_mode,
	vsin_mode,
	v_nop,
	vql_attributes,
	vqm_attributes,
	vqf_attributes,
	dqt_attributes,
	dst_alignment
};

/* VDI functions 100 - 131 */
/* 306de: 00e3d6fa */
/* 104de: 00feae82 */
VOID (*jmptb2[]) PROTO((NOTHING)) =
{
	d_opnvwk,
	d_clsvwk,
	vq_extnd,
	d_contourfill,
	vsf_perimeter,
	v_get_pixel,
	vst_effects,
	dst_point,
	vsl_ends,
	dro_cpyfm,
	vr_trnfm,
	vsc_form,
	dsf_udpat,
	vsl_udsty,
	dr_recfl,
	vqin_mode,
	dqt_extent,
	dqt_width,
	vex_timv,
	dt_loadfont,
	dt_unloadfont,
	drt_cpyfm,
	v_show_c,
	v_hide_c,
	vq_mouse,
	vex_butv,
	vex_motv,
	vex_curv,
	vq_key_s,
	vs_clip,
	dqt_name,
	dqt_fontinfo
};

/************************************************************************
 *    Screen Driver Entry Point
 ************************************************************************/

/* 306de: 00e07fa2 */
/* 104de: 00fcb684 */
VOID SCREEN(NOTHING)
{
	register int16_t opcode, r, *control;
	register ATTRIBUTE *work_ptr;

	control = LV(CONTRL);
	r = control[6];

	opcode = control[0];

	/* no ints out & no pts out */

	control[2] = 0;
	control[4] = 0;

	FLIP_Y = 0;

	if (opcode != 1 && opcode != 100)
	{
		/* Find the attribute area which matches the handle */

		work_ptr = &virt_work;

		do
		{
			if (r == work_ptr->handle)
				goto found_handle;
		} while ((work_ptr = work_ptr->next_work));

		/* handle is invalid if we fall through, so exit */

		return;

	  found_handle:

		LV(cur_work) = work_ptr;
		LV(INQ_TAB)[19] = LV(CLIP) = work_ptr->clip;
		LV(XMN_CLIP) = work_ptr->xmn_clip;
		LV(YMN_CLIP) = work_ptr->ymn_clip;
		LV(XMX_CLIP) = work_ptr->xmx_clip;
		LV(YMX_CLIP) = work_ptr->ymx_clip;

		LV(WRT_MODE) = work_ptr->wrt_mode;

		LV(patptr) = work_ptr->patptr;
		LV(patmsk) = work_ptr->patmsk;

		if (work_ptr->fill_style == 4)
			LV(multifill) = work_ptr->multifill;
		else
			LV(multifill) = 0;

		LV(font_ring)[2] = work_ptr->loaded_fonts;

		LV(DEV_TAB)[10] = work_ptr->num_fonts;

		LV(DDA_INC) = work_ptr->dda_inc;
		LV(T_SCLSTS) = work_ptr->t_sclsts;
		LV(SCALE) = work_ptr->scaled;

		LV(CUR_FONT) = work_ptr->cur_font;

		LV(MONO_STATUS) = MONOSPACE & LV(CUR_FONT)->flags;
		LV(scrpt2) = work_ptr->scrpt2;
		LV(scrtchp) = work_ptr->scrtchp;
		LV(STYLE) = work_ptr->style;
		h_align = work_ptr->h_align;
		v_align = work_ptr->v_align;
		LV(CHUP) = work_ptr->chup;

	}
	/* end if open work or vwork */
	if (opcode >= 1 && opcode <= 39)
	{
		opcode--;
		(*jmptb1[opcode]) ();
	} else if (opcode >= 100 && opcode <= 131)
	{
		opcode -= 100;
		(*jmptb2[opcode]) ();
	}
}
