/*
 **********************************  text.c  ***********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/07/30 15:49:16 $
 * =============================================================================
 *
 * Revision 3.3  91/07/30  15:49:16  lozben
 * Chaged the typecasting of control in loadfont.
 * 
 * Revision 3.2  91/01/22  16:33:12  lozben
 * Made changes so the file can work with the latest include files.
 * 
 * Revision 3.1  91/01/14  18:46:11  lozben
 * Deleted all the extern declarations which are defined in gsxextrn.h.
 * 
 * Revision 3.0  91/01/03  15:19:18  lozben
 * New generation VDI
 * 
 * Revision 2.3  89/06/19  14:38:52  kbad
 * Changed v_gtext() to set FG_B_PLANES (color index) instead of FG_BP_{1,2,3,4},
 * four word that represent the color index.
 * 
 * Revision 2.2  89/06/19  14:34:56  kbad
 * Check underline on all fonts, not just system.
 * 
 * Revision 2.1  89/02/21  17:28:23  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.2  88/03/09  16:27:10  lozben
 * Fixed a bug in vqt_extent; used to return wrong points when string was
 * rotated 270 degrees.
 * 
 * Revision 1.1  87/11/20  15:18:27  lozben
 * Initial revision
 * 
 *******************************************************************************
 */

#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"
#include "gsxdef.h"
#include "gsxextrn.h"


VOID copy_name PROTO((const char *source, char *dest));
VOID make_header PROTO((NOTHING));


/*
 * VDI #8 - v_gtext - Graphic text
 */
/* 306de: 00e0a9b2 */
/* 206de: 00e0a114 */
/* 104de: 00fce36e */
VOID d_gtext(NOTHING)
{
	int16_t monotest;
	int16_t count;
	int16_t i, j;
	int16_t startx, starty;
	int16_t xfact, yfact;
	int16_t olin;						/* jde 29aug85   offset for outlined text   */
	int16_t ulin;						/* jde 06sep85   offset for underlined text */
	int16_t tx1, tx2, ty1, ty2;
	int16_t delh, delv;
	int16_t d1, d2;
	int16_t extent[8];
	int16_t *old_ptr;
	int16_t justified;
#if TOSVERSION >= 0x400
	int16_t oldWrtMode;
#endif
	int16_t temp;
	register const struct font_head *fnt_ptr;
	register int16_t *pointer;

	if ((count = NINTIN) > 0)
	{
#if TOSVERSION >= 0x400
		oldWrtMode = LV(WRT_MODE);
#endif

		fnt_ptr = LV(CUR_FONT);				/* Get current font pointer in register */

		if ((justified = (LV(CONTRL)[0] == 11)))
			monotest = -1;
		else
			monotest = LV(STYLE);

		if (LV(STYLE) & THICKEN)
			LV(WEIGHT) = fnt_ptr->thicken;

		if (LV(STYLE) & LIGHT)
			LV(LITEMASK) = fnt_ptr->lighten;

		if (LV(STYLE) & SKEW)
		{
			LV(L_OFF) = fnt_ptr->left_offset;
			LV(R_OFF) = fnt_ptr->right_offset;
			LV(SKEWMASK) = fnt_ptr->skew;
		} else
		{
			LV(L_OFF) = 0;
			LV(R_OFF) = 0;
		}


/*  adjust the origin to the inside of the outlined character		*/
/*  jde 29aug85								*/

		if (LV(STYLE) & OUTLINE)
			olin = 1;
		else
			olin = 0;


/*  oy vey! this code assures that the underline falls within the	*/
/*  character cell (only if system font is selected)			*/
/*  jde 06sep85								*/
/*  Now checks all fonts, not just system.				*/

		if (
#if (TOSVERSION < 0x200) & BINEXACT
			fnt_ptr->font_id == 1 &&
#endif
#if BINEXACT & (TOSVERSION < 0x400)
			/*
			 * strange cast; without it produces
			 *  clr.w d0
			 *  move 48(a5),d0
			 * but comparison is done unsigned anyway
			 */
			(int)fnt_ptr->bottom <= fnt_ptr->ul_size
#else
			fnt_ptr->bottom <= fnt_ptr->ul_size
#endif
			)
		{
			if (LV(SCALE) && (LV(DDA_INC) == 0xFFFF))
				ulin = -1;
			else
				ulin = 0;
		} else
		{
			ulin = 1;
		}

		LV(FBASE) = fnt_ptr->dat_table;
		LV(FWIDTH) = fnt_ptr->form_width;

		monotest |= h_align;

		switch (h_align)
		{
		case 0:						/* left justified   */
			delh = 0;
			break;

		case 1:						/* center justified */
			if (!justified)
			{							/* width pre-set if GDP */
				old_ptr = LV(PTSOUT);
				LV(PTSOUT) = extent;
				dqt_extent();
				LV(PTSOUT) = old_ptr;
				NPTSOUT = 0;
			}
			delh = width / 2 - olin;	/* jde 29aug85      */
			break;

		case 2:						/* right justified  */
			if (!justified)
			{							/* width pre-set if GDP */
				old_ptr = LV(PTSOUT);
				LV(PTSOUT) = extent;
				dqt_extent();
				LV(PTSOUT) = old_ptr;
				NPTSOUT = 0;
			}
			delh = width - (olin << 1);	/* jde 29aug85      */
#if !BINEXACT
			break;
		default:
			/* BUG: undefined values used below */
			delh = 0;
			break;
#endif
		}

		if (LV(STYLE) & SKEW)
		{
			d1 = fnt_ptr->left_offset;
			d2 = fnt_ptr->right_offset;
		} else
		{
			d1 = 0;
			d2 = 0;
		}

		switch (v_align)
		{
		case ALI_BASE:
			delv = fnt_ptr->top;
			delh += d1;
			break;

		case ALI_HALF:
			delv = fnt_ptr->top - fnt_ptr->half;
			delh += (fnt_ptr->half * d2) / fnt_ptr->top;
			break;

		case ALI_ASCENT:
			delv = fnt_ptr->top - fnt_ptr->ascent;
			delh += (fnt_ptr->ascent * d2) / fnt_ptr->top;
			break;

		case ALI_BOTTOM:
			delv = fnt_ptr->top + fnt_ptr->bottom;
			break;

		case ALI_DESCENT:
			delv = fnt_ptr->top + fnt_ptr->descent;
			delh += (fnt_ptr->descent * d1) / fnt_ptr->bottom;
			break;

		case ALI_TOP:
			delv = 0;
			delh += d1 + d2;
			break;
#if !BINEXACT
		default:
			/* BUG: undefined values used below */
			delv = 0;
			break;
#endif
		}


		pointer = LV(PTSIN);
		monotest |= LV(CHUP);

		switch (LV(CHUP))
		{
#if !BINEXACT
		default:
			/* BUG: undefined values used below */
#endif
		case 0:
			startx = LV(DESTX) = *(pointer) - delh - olin;
			starty = (LV(DESTY) = *(pointer + 1) - delv - olin) + fnt_ptr->top + fnt_ptr->ul_size + ulin;
			xfact = 0;
			yfact = 1;
			break;

		case 900:
			startx = (LV(DESTX) = *(pointer) - delv - olin) + fnt_ptr->top + fnt_ptr->ul_size + ulin;
			starty = LV(DESTY) = *(pointer + 1) + delh + olin + 1;	/* +1 jde */
			xfact = 1;
			yfact = 0;
			break;

		case 1800:
			startx = LV(DESTX) = *(pointer) + delh + olin + 1;	/* +1 jde */
			LV(DESTY) = *(pointer + 1) - ((fnt_ptr->top + fnt_ptr->bottom) - delv) - olin;
			starty = (LV(DESTY) + fnt_ptr->bottom) - (fnt_ptr->ul_size + ulin);
			xfact = 0;
			yfact = -1;
			break;

		case 2700:
			LV(DESTX) = *pointer - ((fnt_ptr->top + fnt_ptr->bottom) - delv) - olin;
			startx = (LV(DESTX) + fnt_ptr->bottom) - (fnt_ptr->ul_size + ulin);
			starty = LV(DESTY) = *(pointer + 1) - delh - olin;
			xfact = -1;
			yfact = 0;
			break;
		}


		LV(TEXT_FG) = LV(cur_work)->text_color;

		LV(DELY) = fnt_ptr->form_height;

		if (!((!LV(SCALE)) && (monotest == 0) && (MONOSPACE & fnt_ptr->flags)
			  && (fnt_ptr->max_cell_width == 8) && MONO8XHT()))
		{

			LV(XACC_DDA) = 32767;			/* reinit the horizontal dda */

			for (j = 0; j < count; j++)
			{
				temp = LV(INTIN)[j];

				/* If character is out of range for this font make it a "?" */

				if ((temp < fnt_ptr->first_ade) || (temp > fnt_ptr->last_ade))
					temp = 63;

				temp -= fnt_ptr->first_ade;

				LV(SOURCEX) = fnt_ptr->off_table[temp];
				LV(DELX) = fnt_ptr->off_table[temp + 1] - LV(SOURCEX);

				LV(SOURCEY) = 0;
				LV(DELY) = fnt_ptr->form_height;

#if VIDEL_SUPPORT
				/*
				 * This code was added for pixel packed text blit. In replace
				 * mode we prebuild the character into a buffer if it has some
				 * special effect. When they are skewed in order not to
				 * clobber the previous character we need to blit it in
				 * transparent mode. So we clear out an area for the word
				 * with text background and blit in transparent mode instead
				 * of replace mode.
				 */
				if ((LV(STYLE) & SKEW) && LV(WRT_MODE) == 0 &&
					LV(form_id) == PIXPACKED &&
					LV(CHUP) == 0)
				{
					old_ptr = LV(PTSOUT);
					LV(PTSOUT) = extent;
					dqt_extent();
					LV(PTSOUT) = old_ptr;
					cheat_blit();		/* clear out an area with txt bg */
					LV(WRT_MODE) = 1;		/* make writing mode transparent */
				}
#endif
				TEXT_BLT();

				fnt_ptr = LV(CUR_FONT);		/* restore reg var */

				if (justified)
				{
					LV(DESTX) += charx;
					LV(DESTY) += chary;
					if (rmchar)
					{
						LV(DESTX) += rmcharx;
						LV(DESTY) += rmchary;
						rmchar--;
					}
					if (LV(INTIN)[j] == 32)
					{
						LV(DESTX) += wordx;
						LV(DESTY) += wordy;
						if (rmword)
						{
							LV(DESTX) += rmwordx;
							LV(DESTY) += rmwordy;
							rmword--;
						}
					}
				}
				/* end if justified */
				if (fnt_ptr->flags & HORZ_OFF)
					LV(DESTX) += fnt_ptr->hor_table[temp];

			}							/* for j */

			if (LV(STYLE) & UNDER)
			{
				LV(X1) = startx;
				LV(Y1) = starty;

				if (LV(CHUP) % 1800 == 0)
				{
					LV(X2) = LV(DESTX);
					LV(Y2) = LV(Y1);
				} else
				{
					LV(X2) = LV(X1);
					LV(Y2) = LV(DESTY);
				}
				if (LV(STYLE) & LIGHT)
					LV(LN_MASK) = LV(CUR_FONT)->lighten;
				else
					LV(LN_MASK) = 0xffff;

#if PLANES8
				LV(FG_B_PLANES) = LV(TEXT_FG);
#else
				temp = LV(TEXT_FG);
				LV(FG_BP_1) = temp & 0x01;
				LV(FG_BP_2) = temp & 0x02;
				LV(FG_BP_3) = temp & 0x04;
				LV(FG_BP_4) = temp & 0x08;
#endif

				count = LV(CUR_FONT)->ul_size;
				for (i = 0; i < count; i++)
				{
					if (LV(CLIP))
					{
						tx1 = LV(X1);
						tx2 = LV(X2);
						ty1 = LV(Y1);
						ty2 = LV(Y2);

						if (clip_line())
							ABLINE();

						LV(X1) = tx1;
						LV(X2) = tx2;
						LV(Y1) = ty1;
						LV(Y2) = ty2;
					} else
					{
						ABLINE();
					}
					
					LV(X1) += xfact;
					LV(X2) += xfact;
					LV(Y1) += yfact;
					LV(Y2) += yfact;

					if (LV(LN_MASK) & 1)
						LV(LN_MASK) = (LV(LN_MASK) >> 1) | 0x8000;
					else
						LV(LN_MASK) = LV(LN_MASK) >> 1;
				}
			}
		}
#if TOSVERSION >= 0x400
		LV(WRT_MODE) = oldWrtMode;
#endif
	}
}


/* 306de: 00e0b094 */
/* 206de: 00e0a82a */
/* 104de: 00fcea8a */
VOID text_init(NOTHING)
{
	int16_t i, j;
	int16_t id_save;
	register const struct font_head *fnt_ptr, **chain_ptr;

	LV(SIZ_TAB)[0] = 32767;
	LV(SIZ_TAB)[1] = 32767;
	LV(SIZ_TAB)[2] = 0;
	LV(SIZ_TAB)[3] = 0;

	/* Initialize the font ring.  font_ring[1] is setup before entering here */
	/* since it contains the font which varies with the screen resolution.   */

	LV(font_ring)[0] = &first;
	LV(font_ring)[2] = NULL;
	LV(font_ring)[3] = NULL;

	id_save = first.font_id;

	chain_ptr = LV(font_ring);
	i = 0;
	j = 0;
	while ((fnt_ptr = *chain_ptr++))
	{
		do
		{
			if (fnt_ptr->flags & DEFAULT)	/* If default save pointer */
				LV(def_font) = fnt_ptr;

			if (fnt_ptr->font_id != id_save)
			{							/* If new font count */
				j++;
				id_save = fnt_ptr->font_id;
			}

			if (fnt_ptr->font_id == 1)
			{							/* Update SIZ_TAB if system font */

				if (LV(SIZ_TAB)[0] > fnt_ptr->max_char_width)
					LV(SIZ_TAB)[0] = fnt_ptr->max_char_width;

				if (LV(SIZ_TAB)[1] > fnt_ptr->top)
					LV(SIZ_TAB)[1] = fnt_ptr->top;

				if (LV(SIZ_TAB)[2] < fnt_ptr->max_char_width)
					LV(SIZ_TAB)[2] = fnt_ptr->max_char_width;

				if (LV(SIZ_TAB)[3] < fnt_ptr->top)
					LV(SIZ_TAB)[3] = fnt_ptr->top;
				i++;					/* Increment count of heights */

			}
			/* end if system font */
			if (!(fnt_ptr->flags & STDFORM))
			{
				LV(FBASE) = fnt_ptr->dat_table;
				LV(FWIDTH) = fnt_ptr->form_width;
				LV(DELY) = fnt_ptr->form_height;
				TRNSFONT();
			}

		} while ((fnt_ptr = fnt_ptr->next_font));
	}

	LV(DEV_TAB)[5] = i;						/* number of sizes */
	LV(ini_font_count) = LV(DEV_TAB)[10] = ++j;	/* number of faces */

	LV(CUR_FONT) = LV(def_font);
}


/*
 * VDI #12 - vst_height - Set character height, absolute mode
 */
/* 306de: 00e0b1c8 */
/* 206de: 00e0a95e */
/* 104de: 00fcebbe */
VOID dst_height(NOTHING)
{
	const struct font_head **chain_ptr;
	register const struct font_head *test_font, *single_font;
	register int16_t *pointer, font_id, test_height;

	font_id = LV(CUR_FONT)->font_id;
	LV(cur_work)->pts_mode = FALSE;

	/* Find the smallest font in the requested face */

	chain_ptr = LV(font_ring);

	while ((test_font = *chain_ptr++))
	{
		do
		{
			if (test_font->font_id == font_id)
				goto find_height;
		} while ((test_font = test_font->next_font));
	}

  find_height:

	single_font = test_font;
	test_height = LV(PTSIN)[1];
	if (LV(cur_work)->xfm_mode == 0)		/* If NDC transformation, swap y coordinate */
		test_height = LV(DEV_TAB)[1] + 1 - test_height;

	/* Traverse the chains and find the font closest to the size requested. */

	do
	{
		while ((test_font->top <= test_height) && (test_font->font_id == font_id))
		{

			single_font = test_font;
			if (!(test_font = test_font->next_font))
				break;
		}
	} while ((test_font = *chain_ptr++));

	/* Set up environment for this font in the non-scaled case */

	LV(cur_work)->cur_font = LV(CUR_FONT) = single_font;
	LV(cur_work)->scaled = FALSE;

	if (single_font->top != test_height)
	{

		LV(DDA_INC) = LV(cur_work)->dda_inc = CLC_DDA(single_font->top, test_height);
		LV(cur_work)->t_sclsts = LV(T_SCLSTS);
		make_header();
		single_font = LV(CUR_FONT);
	}

	NPTSOUT = 2;

	pointer = LV(PTSOUT);
	*pointer++ = single_font->max_char_width;
	*pointer++ = test_height = single_font->top;
	*pointer++ = single_font->max_cell_width;
	*pointer++ = test_height + single_font->bottom + 1;
	FLIP_Y = 1;
}


/* 306de: 00e0b2e6 */
/* 206de: 00e0aa7c */
/* 104de: 00fcecdc */
VOID copy_name(P(const char *) source, P(char *) dest)
PP(const char *source;)
PP(char *dest;)
{
	register int16_t i;
	register const char *sptr;
	register char *dptr;

	sptr = source;
	dptr = dest;

	for (i = 0; i < 32; i++)
		*dptr++ = *sptr++;
}


/* 306de: 00e0b30e */
/* 206de: 00e0aaa4 */
/* 104de: 00fced04 */
VOID make_header(NOTHING)
{
	register ATTRIBUTE *work_ptr;
	register const FONT_HEAD *source_font;
	register FONT_HEAD *dest_font;

	work_ptr = LV(cur_work);
	source_font = work_ptr->cur_font;
	dest_font = &work_ptr->scratch_head;

	dest_font->font_id = source_font->font_id;
	dest_font->point = source_font->point * 2;

	copy_name(&source_font->name[0], &dest_font->name[0]);

	dest_font->first_ade = source_font->first_ade;
	dest_font->last_ade = source_font->last_ade;


/*  compressed code jde 10-sep-85					*/
/*									*/
#if 0
    if(LV(DDA_INC) == 0xFFFF)
	{
		dest_font->top            = source_font->top * 2 + 1;
		dest_font->ascent         = source_font->ascent * 2 + 1;
		dest_font->half           = source_font->half * 2 + 1;
		dest_font->descent        = source_font->descent * 2;		
		dest_font->bottom         = source_font->bottom * 2;
		dest_font->max_char_width = source_font->max_char_width * 2;
		dest_font->max_cell_width = source_font->max_cell_width * 2;
		dest_font->left_offset    = source_font->left_offset * 2;
		dest_font->right_offset   = source_font->right_offset * 2;
		dest_font->thicken        = source_font->thicken * 2;
		dest_font->ul_size        = source_font->ul_size * 2;
    } else
    {
		dest_font->top            = ACT_SIZ( source_font->top );
		dest_font->ascent         = ACT_SIZ( source_font->ascent );
		dest_font->half           = ACT_SIZ( source_font->half );
		dest_font->descent        = ACT_SIZ( source_font->descent );
		dest_font->bottom         = ACT_SIZ( source_font->bottom );
		dest_font->max_char_width = ACT_SIZ( source_font->max_char_width );
		dest_font->max_cell_width = ACT_SIZ( source_font->max_cell_width );
		dest_font->left_offset    = ACT_SIZ( source_font->left_offset );
		dest_font->right_offset   = ACT_SIZ( source_font->right_offset );
		dest_font->thicken        = ACT_SIZ( source_font->thicken );
		dest_font->ul_size        = ACT_SIZ( source_font->ul_size );
    }
#endif

	if (LV(DDA_INC) == 0xFFFF)
	{
		dest_font->top = source_font->top * 2 + 1;
		dest_font->ascent = source_font->ascent * 2 + 1;
		dest_font->half = source_font->half * 2 + 1;
	} else
	{
		dest_font->top = ACT_SIZ(source_font->top);
		dest_font->ascent = ACT_SIZ(source_font->ascent);
		dest_font->half = ACT_SIZ(source_font->half);
	}


	dest_font->descent = ACT_SIZ(source_font->descent);
	dest_font->bottom = ACT_SIZ(source_font->bottom);
	dest_font->max_char_width = ACT_SIZ(source_font->max_char_width);
	dest_font->max_cell_width = ACT_SIZ(source_font->max_cell_width);
	dest_font->left_offset = ACT_SIZ(source_font->left_offset);
	dest_font->right_offset = ACT_SIZ(source_font->right_offset);
	dest_font->thicken = ACT_SIZ(source_font->thicken);
	dest_font->ul_size = ACT_SIZ(source_font->ul_size);

	dest_font->lighten = source_font->lighten;
	dest_font->skew = source_font->skew;
	dest_font->flags = source_font->flags;

	dest_font->hor_table = source_font->hor_table;
	dest_font->off_table = source_font->off_table;
	dest_font->dat_table = source_font->dat_table;

	dest_font->form_width = source_font->form_width;
	dest_font->form_height = source_font->form_height;

	work_ptr->scaled = TRUE;
	work_ptr->cur_font = LV(CUR_FONT) = dest_font;
}


/*
 * VDI #107 - vst_point - Set character height, points mode
 */
/* 306de: 00e0b45e */
/* 206de: 00e0abf4 */
/* 104de: 00fcee54 */
VOID dst_point(NOTHING)
{
	int16_t font_id;
	const struct font_head **chain_ptr, *double_font;
	register const struct font_head *test_font, *single_font;
	register int16_t *pointer, test_height, Height;

	font_id = LV(CUR_FONT)->font_id;
	LV(cur_work)->pts_mode = TRUE;

	/* Find the smallest font in the requested face */

	chain_ptr = LV(font_ring);

	while ((test_font = *chain_ptr++))
	{
		do
		{
			if (test_font->font_id == font_id)
				goto find_height;
		} while ((test_font = test_font->next_font));
	}

  find_height:

	double_font = single_font = test_font;
	test_height = LV(INTIN)[0];

	/* Traverse the chains and find the font closest to the size requested */
	/* and closest to half the size requested.                 */

	do
	{
		while (((Height = test_font->point) <= test_height) && (test_font->font_id == font_id))
		{
			single_font = test_font;
			if (Height * 2 <= test_height)
				double_font = test_font;

			if (!(test_font = test_font->next_font))
				break;
		}
	} while ((test_font = *chain_ptr++));

	/* Set up environment for this font in the non-scaled case */

	LV(CUR_FONT) = LV(cur_work)->cur_font = single_font;
	LV(cur_work)->scaled = FALSE;

	if (single_font->point != test_height)
	{
		Height = double_font->point * 2;

		if ((Height > single_font->point) && (Height <= test_height))
		{
			LV(DDA_INC) = LV(cur_work)->dda_inc = 0xFFFF;
			LV(cur_work)->t_sclsts = 1;
			LV(cur_work)->cur_font = double_font;
			make_header();
			single_font = LV(CUR_FONT);
		}
	}

	pointer = LV(CONTRL);
	*(pointer + 4) = 1;
	*(pointer + 2) = 2;

	LV(INTOUT)[0] = single_font->point;

	pointer = LV(PTSOUT);
	*pointer++ = single_font->max_char_width;
	*pointer++ = test_height = single_font->top;
	*pointer++ = single_font->max_cell_width;
	*pointer++ = test_height + single_font->bottom + 1;
	FLIP_Y = 1;
}


/*
 * VDI #106 - vst_effects - Set graphic text special effects
 */
/* 306de: 00e0b5a4 */
/* 206de: 00e0ad3a */
/* 104de: 00fcef9a */
VOID vst_effects(NOTHING)
{
	LV(INTOUT)[0] = LV(cur_work)->style = LV(INTIN)[0] & LV(INQ_TAB)[2];
	NINTOUT = 1;
}


/*
 * VDI #39 - vst_alignment - Set graphic text alignment
 */
/* 306de: 00e0b5d8 */
/* 206de: 00e0ad6e */
/* 104de: 00fcefce */
VOID dst_alignment(NOTHING)
{
	register int16_t a, *int_out, *int_in;
	register ATTRIBUTE *work_ptr;
	register int unused;
	
	UNUSED(unused);
	work_ptr = LV(cur_work);
	int_in = LV(INTIN);
	int_out = LV(INTOUT);
	a = *int_in++;
	if (a < 0 || a > 2)
		a = 0;
	work_ptr->h_align = *int_out++ = a;

	a = *int_in;
	if (a < 0 || a > 5)
		a = 0;
	work_ptr->v_align = *int_out = a;

	NINTOUT = 2;
}


/*
 * VDI #13 - vst_rotation - Set character baseline vector
 */
/* 306de: 00e0b634 */
/* 206de: 00e0adca */
/* 104de: 00fcf02a */
VOID dst_rotation(NOTHING)
{
	LV(INTOUT)[0] = LV(cur_work)->chup = ((LV(INTIN)[0] + 450) / 900) * 900;
	NINTOUT = 1;
}


/*
 * VDI #21 - vst_font - Set text face
 */
/* 306de: 00e0b66e */
/* 206de: 00e0ae04 */
/* 104de: 00fcf064 */
VOID dst_font(NOTHING)
{
	int16_t *old_intin, point, *old_ptsout, dummy[4], *old_ptsin;
	register int16_t face;
	register const struct font_head *test_font, **chain_ptr;

	test_font = LV(CUR_FONT);
	point = test_font->point;
	dummy[1] = test_font->top;
	face = LV(INTIN)[0];

	chain_ptr = LV(font_ring);

	while ((test_font = *chain_ptr++))
	{
		do
		{
			if (test_font->font_id == face)
				goto find_height;
		} while ((test_font = test_font->next_font));
	}

	/* If we fell through the loop, we could not find the face. */
	/* Default to the system font.                  */

	test_font = &first;

  find_height:

	/* Call down to the set text height routine to get the proper size */

	LV(cur_work)->cur_font = LV(CUR_FONT) = test_font;

	old_intin = LV(INTIN);
	old_ptsin = LV(PTSIN);
	old_ptsout = LV(PTSOUT);
	LV(INTIN) = &point;
	LV(PTSIN) = LV(PTSOUT) = dummy;

	if (LV(cur_work)->pts_mode)
		dst_point();
	else
		dst_height();

	LV(INTIN) = old_intin;
	LV(PTSIN) = old_ptsin;
	LV(PTSOUT) = old_ptsout;

	NPTSOUT = 0;
	NINTOUT = 1;
	LV(INTOUT)[0] = LV(CUR_FONT)->font_id;
}


/*
 * VDI #22 - vst_color - Set graphic text color index
 */
/* 306de: 00e0b752 */
/* 206de: 00e0aee8 */
/* 104de: 00fcf148 */
VOID dst_color(NOTHING)
{
	register int16_t r;

	r = LV(INTIN)[0];
	if ((r >= LV(DEV_TAB)[13]) || (r < 0))
		r = 1;

	NINTOUT = 1;
	LV(INTOUT)[0] = r;

	LV(cur_work)->text_color = MAP_COL[r];
}


/*
 * VDI #38 - vqt_attributes - Inquire current graphic text attributes
 */
/* 306de: 00e0b7a2 */
/* 206de: 00e0af38 */
/* 104de: 00fcf198 */
VOID dqt_attributes(NOTHING)
{
	register int16_t *pointer, temp;
	register const FONT_HEAD *fnt_ptr;
	register ATTRIBUTE *work_ptr;

	work_ptr = LV(cur_work);
	fnt_ptr = LV(CUR_FONT);

	pointer = LV(INTOUT);
	*pointer++ = fnt_ptr->font_id;		/* INTOUT[0] */
	*pointer++ = REV_MAP_COL[work_ptr->text_color];	/* INTOUT[1] */
	*pointer++ = work_ptr->chup;		/* INTOUT[2] */
	*pointer++ = work_ptr->h_align;		/* INTOUT[3] */
	*pointer++ = work_ptr->v_align;		/* INTOUT[4] */
	*pointer = work_ptr->wrt_mode;		/* INTOUT[5] */

	pointer = LV(PTSOUT);
	*pointer++ = fnt_ptr->max_char_width;
	*pointer++ = temp = fnt_ptr->top;
	*pointer++ = fnt_ptr->max_cell_width;
	*pointer = temp + fnt_ptr->bottom + 1;

	pointer = LV(CONTRL);
	*(pointer + 2) = 2;
	*(pointer + 4) = 6;

	FLIP_Y = 1;
}


/*
 * VDI #116 - vqt_extent - Inquire text extent
 */
/* 306de: 00e0b81c */
/* 206de: 00e0afb2 */
/* 104de: 00fcf212 */
VOID dqt_extent(NOTHING)
{
	register int16_t i, chr, table_start;
	register int16_t *pointer;
	register const struct font_head *fnt_ptr;

	int16_t cnt;

	fnt_ptr = LV(CUR_FONT);
	pointer = LV(INTIN);

	width = 0;
	table_start = fnt_ptr->first_ade;
	cnt = NINTIN;

	for (i = 0; i < cnt; i++)
	{
		chr = *pointer++ - table_start;
		width += fnt_ptr->off_table[chr + 1] - fnt_ptr->off_table[chr];
	}


	if (LV(SCALE))
	{
		if (LV(DDA_INC) == 0xFFFF)
			width *= 2;
		else
			width = ACT_SIZ(width);
	}
	
	if ((LV(STYLE) & THICKEN) && !(fnt_ptr->flags & MONOSPACE))
		width += cnt * fnt_ptr->thicken;

	if (LV(STYLE) & SKEW)
		width += fnt_ptr->left_offset + fnt_ptr->right_offset;


	height = fnt_ptr->top + fnt_ptr->bottom + 1;


	if (LV(STYLE) & OUTLINE)
	{									/* include OUTLINE in calculations. jde 23aug85 */
		width += cnt * 2;				/* OUTLINE is always a one pixel outline        */
		height += 2;
	}


	NPTSOUT = 4;

	pointer = LV(PTSOUT);
	switch (LV(CHUP))
	{
	case 0:
		*pointer++ = 0;
		*pointer++ = 0;
		*pointer++ = width;
		*pointer++ = 0;
		*pointer++ = width;
		*pointer++ = height;
		*pointer++ = 0;
		*pointer = height;
		break;

	case 900:
		*pointer++ = height;
		*pointer++ = 0;
		*pointer++ = height;
		*pointer++ = width;
		*pointer++ = 0;
		*pointer++ = width;
		*pointer++ = 0;
		*pointer = 0;
		break;

	case 1800:
		*pointer++ = width;
		*pointer++ = height;
		*pointer++ = 0;
		*pointer++ = height;
		*pointer++ = 0;
		*pointer++ = 0;
		*pointer++ = width;
		*pointer = 0;
		break;

	case 2700:
		*pointer++ = 0;
		*pointer++ = width;
		*pointer++ = 0;
		*pointer++ = 0;
		*pointer++ = height;
		*pointer++ = 0;
		*pointer++ = height;
		*pointer = width;
		break;
	}
	FLIP_Y = 1;
}


/*
 * VDI #117 - vqt_width - Inquire character cell width
 */
/* 306de: 00e0b9d8 */
/* 206de: 00e0b16e */
/* 104de: 00fcf3ce */
VOID dqt_width(NOTHING)
{
	register int16_t k;
	register int16_t *pointer;
	register const struct font_head *fnt_ptr;

	fnt_ptr = LV(CUR_FONT);
	pointer = LV(PTSOUT);

	/* Set that there is no horizontal offset */

	*(pointer + 2) = 0;
	*(pointer + 4) = 0;

	k = LV(INTIN)[0];
	if ((k < fnt_ptr->first_ade) || (k > fnt_ptr->last_ade))
	{
		LV(INTOUT)[0] = -1;
	} else
	{
		LV(INTOUT)[0] = k;
		k -= fnt_ptr->first_ade;
		*(pointer) = fnt_ptr->off_table[k + 1] - fnt_ptr->off_table[k];
		if (LV(SCALE))
		{
			if (LV(DDA_INC) == 0xFFFF)
				*pointer *= 2;
			else
				*pointer = ACT_SIZ(*pointer);
		}
		
		if (fnt_ptr->flags & HORZ_OFF)
		{
			*(pointer + 2) = fnt_ptr->hor_table[k * 2];
			*(pointer + 4) = fnt_ptr->hor_table[(k * 2) + 1];
		}
	}

	pointer = LV(CONTRL);
	*(pointer + 2) = 3;
	*(pointer + 4) = 1;
	FLIP_Y = 1;
}


/*
 * VDI #130 - vqt_name - Inquire face name and index
 */
/* 306de: 00e0bab0 */
/* 206de: 00e0b246 */
/* 104de: 00fcf4a6 */
VOID dqt_name(NOTHING)
{
	register int16_t i, element;
	register const char *name;
	register int16_t *int_out;
	register const struct font_head *tmp_font;
	int16_t font_id;
	const struct font_head **chain_ptr;

	element = LV(INTIN)[0];
	chain_ptr = LV(font_ring);
	i = 0;
	font_id = -1;

	while ((tmp_font = *chain_ptr++))
	{
		do
		{
			if (tmp_font->font_id != font_id)
			{
				font_id = tmp_font->font_id;
				if ((++i) == element)
					goto found_element;
			}
		} while ((tmp_font = tmp_font->next_font));
	}

	/* The element is out of bounds use the system font */

	tmp_font = &first;

  found_element:

	int_out = LV(INTOUT);
	*int_out++ = tmp_font->font_id;
	for (i = 1, name = tmp_font->name; (*int_out++ = *name++); i++)
		;
	while (i < 33)
	{
		*int_out++ = 0;
		i++;
	}
	NINTOUT = 33;
}


/*
 * VDI #131 - vqt_fontinfo - Inquire current face information
 */
/* 306de: 00e0bb40 */
/* 206de: 00e0b2d6 */
/* 104de: 00fcf536 */
VOID dqt_fontinfo(NOTHING)
{
	register int16_t *pointer;
	register const struct font_head *fnt_ptr;

	fnt_ptr = LV(CUR_FONT);

	pointer = LV(INTOUT);
	*pointer++ = fnt_ptr->first_ade;
	*pointer = fnt_ptr->last_ade;

	pointer = LV(PTSOUT);
	*pointer++ = fnt_ptr->max_cell_width;
	*pointer++ = fnt_ptr->bottom;

	if (LV(STYLE) & THICKEN)
		*pointer++ = fnt_ptr->thicken;
	else
		*pointer++ = 0;

	*pointer++ = fnt_ptr->descent;

	if (LV(STYLE) & SKEW)
	{
		*pointer++ = fnt_ptr->left_offset;
		*pointer++ = fnt_ptr->half;
		*pointer++ = fnt_ptr->right_offset;
	} else
	{
		*pointer++ = 0;
		*pointer++ = fnt_ptr->half;
		*pointer++ = 0;
	}

	*pointer++ = fnt_ptr->ascent;
	*pointer++ = 0;
	*pointer = fnt_ptr->top;

	pointer = LV(CONTRL);
	*(pointer + 2) = 5;
	*(pointer + 4) = 2;
	FLIP_Y = 1;
}


/*
 * VDI #11,10 - v_justified - Justified graphics text
 */
/* 306de: 00e0bbce */
/* 206de: 00e0b364 */
/* 104de: 00fcf5c4 */
VOID d_justified(NOTHING)
{
	int16_t spaces;
	int16_t expand, sav_cnt;
	int16_t interword, interchar;
	int16_t cnt, *old_intin, *old_ptsout, extent[8], max_x;
	register int16_t i, ddirection, delword, delchar;
	register int16_t *pointer;

	pointer = &NINTIN;
	cnt = *pointer = (sav_cnt = *pointer) - 2;

	pointer = LV(INTIN);
	interword = *pointer++;
	interchar = *pointer++;

	old_intin = LV(INTIN);
	LV(INTIN) = pointer;
	old_ptsout = LV(PTSOUT);
	LV(PTSOUT) = extent;

	for (i = 0, spaces = 0; i < cnt; i++)
		if (*(pointer++) == 32)
			spaces++;

	dqt_extent();
	NPTSOUT = 0;

	max_x = LV(PTSIN)[2];

	if (interword && spaces)
	{
		delword = (max_x - width) / spaces;
		rmword = (max_x - width) % spaces;

		if (rmword < 0)
		{
			ddirection = -1;
			rmword = 0 - rmword;
		} else
		{
			ddirection = 1;
		}
		
		if (interchar)
		{
			expand = LV(CUR_FONT)->max_cell_width / 2;
			if (delword > expand)
			{
				delword = expand;
				rmword = 0;
			}
			if (delword < (0 - expand))
			{
				delword = 0 - expand;
				rmword = 0;
			}
			width += (delword * spaces) + (rmword * ddirection);
		}

		switch (LV(CHUP))
		{
		case 0:
			wordx = delword;
			wordy = 0;
			rmwordx = ddirection;
			rmwordy = 0;
			break;
		case 900:
			wordx = 0;
			wordy = 0 - delword;
			rmwordx = 0;
			rmwordy = 0 - ddirection;
			break;
		case 1800:
			wordx = 0 - delword;
			wordy = 0;
			rmwordx = 0 - ddirection;
			rmwordy = 0;
			break;
		case 2700:
			wordx = 0;
			wordy = delword;
			rmwordx = 0;
			rmwordy = ddirection;
			break;
#if BINEXACT
			asm("ds.b 0"); /* prevent superfluous bra from being removed */
#endif
		}
	} else
	{
		wordx = 0;
		wordy = 0;
		rmword = 0;
	}

	if (interchar && cnt > 1)
	{
		delchar = (max_x - width) / (cnt - 1);
		rmchar = (max_x - width) % (cnt - 1);

		if (rmchar < 0)
		{
			ddirection = -1;
			rmchar = 0 - rmchar;
		} else
		{
			ddirection = 1;
		}
		
		switch (LV(CHUP))
		{
		case 0:
			charx = delchar;
			chary = 0;
			rmcharx = ddirection;
			rmchary = 0;
			break;
		case 900:
			charx = 0;
			chary = 0 - delchar;
			rmcharx = 0;
			rmchary = 0 - ddirection;
			break;
		case 1800:
			charx = 0 - delchar;
			chary = 0;
			rmcharx = 0 - ddirection;
			rmchary = 0;
			break;
		case 2700:
			charx = 0;
			chary = delchar;
			rmcharx = 0;
			rmchary = ddirection;
			break;
#if BINEXACT
			asm("ds.b 0"); /* prevent superfluous bra from being removed */
#endif
		}
	} else
	{
		charx = 0;
		chary = 0;
		rmchar = 0;
	}

	width = max_x;

	d_gtext();

	NPTSOUT = sav_cnt;
	LV(PTSOUT) = old_ptsout;
	LV(INTIN) = old_intin;
}


/*
 * VDI #119 - vst_load_fonts - Load fonts
 */
/* 306de: 00e0beea */
/* 206de: 00e0b680 */
/* 104de: 00fcf8e0 */
VOID dt_loadfont(NOTHING)
{
	register int16_t id, count, *control;
	register FONT_HEAD *first_font;
	register ATTRIBUTE *work_ptr;

	/* Init some common variables */

	work_ptr = LV(cur_work);
	control = LV(CONTRL);
	*(control + 4) = 1;

	/* You only get one chance to load fonts.  If fonts are linked in, exit  */

	if (work_ptr->loaded_fonts)
	{
		LV(INTOUT)[0] = 0;
		return;
	}

	/* The inputs to this routine are :         */
	/*     CONTRL[7-8]   = Pointer to scratch buffer    */
	/*     CONTRL[9]     = Offset to buffer 2       */
	/*     CONTRL[10-11] = Pointer to first font    */

	/* Init the global structures           */

	work_ptr->scrpt2 = *(control + 9);
	work_ptr->scrtchp = *((int16_t **) (control + 7));

	work_ptr->loaded_fonts = first_font = *((FONT_HEAD **) (control + 10));

	/* Find out how many distinct font id numbers have just been linked in. */

	id = -1;
	count = 0;

	do
	{

		/* Update the count of font id numbers, if necessary. */

		if (first_font->font_id != id)
		{
			id = first_font->font_id;
			count++;
		}

		/* Make sure the font is in device specific format. */

		if (!(first_font->flags & STDFORM))
		{
			LV(FBASE) = first_font->dat_table;
			LV(FWIDTH) = first_font->form_width;
			LV(DELY) = first_font->form_height;
			TRNSFONT();
			first_font->flags ^= STDFORM;
		}
	} while ((first_font = first_font->next_font));

	/* Update the device table count of faces. */

	work_ptr->num_fonts += count;
	LV(INTOUT)[0] = count;
}


/*
 * VDI #120 - vst_unload_fonts - Unload fonts
 */
/* 306de: 00e0bf7e */
/* 206de: 00e0b714 */
/* 104de: 00fcf974 */
VOID dt_unloadfont(NOTHING)
{
	register ATTRIBUTE *work_ptr;

	/* Since we always unload all fonts, this is easy. */

	work_ptr = LV(cur_work);
	work_ptr->loaded_fonts = NULL;		/* No fonts installed */

	work_ptr->scrpt2 = scrtsiz;			/* Reset pointers to default buffers */
	work_ptr->scrtchp = deftxbu;

	work_ptr->num_fonts = LV(ini_font_count);	/* Reset font count to default */
}
