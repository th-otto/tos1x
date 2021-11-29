/*
 ********************************* attrdef.h ***********************************
 *
 * =============================================================================
 * $Author: lozben $ $Date: 91/01/04 12:20:40 $
 * =============================================================================
 *
 * Revision 3.1	91/01/04  12:20:40	lozben
 * Typedefed structure attribute to ATTRIBUTE.
 * 
 * Revision 3.0	91/01/03  15:05:57	lozben
 * New generation VDI
 * 
 * Revision 2.2	90/04/24  15:51:14	lozben
 * Expanded the user defined pattern array from a 4x16 to an 8x16.
 * 
 * Revision 2.1	89/02/21  17:28:19	kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 *******************************************************************************
 */

#ifndef _ATTRDEF_H_
#define _ATTRDEF_H_

/* Structure to hold data for a virtual workstation */
typedef struct attribute {
	/*   0 */ int16_t chup;				/* Character Up vector			*/
	/*   2 */ int16_t clip;				/* Clipping Flag				*/
	/*   4 */ const FONT_HEAD *cur_font;/* Pointer to current font			*/
	/*   8 */ int16_t dda_inc;			/* Fraction to be added to the DDA		*/
	/*  10 */ int16_t multifill;		/* Multi-plane fill flag			*/
	/*  12 */ int16_t patmsk; 			/* Current pattern mask 			*/
	/*  14 */ const int16_t *patptr;	/* Current pattern pointer			*/
	/*  18 */ int16_t pts_mode;			/* TRUE if height set in points mode	*/
	/*  20 */ int16_t *scrtchp;			/* Pointer to text scratch buffer		*/
	/*  24 */ int16_t scrpt2; 			/* Offset to large text buffer		*/
	/*  26 */ int16_t style;			/* Current text style			*/
	/*  28 */ int16_t t_sclsts;			/* TRUE if scaling up			*/
	/*  30 */ int16_t fill_color; 		/* Current fill color (PEL value)		*/
	/*  32 */ int16_t fill_index; 		/* Current fill index			*/
	/*  34 */ int16_t fill_per;			/* TRUE if fill area outlined		*/
	/*  36 */ int16_t fill_style; 		/* Current fill style			*/
	/*  38 */ int16_t h_align;			/* Current text horizontal alignment	*/
	/*  40 */ int16_t handle; 			/* handle for attribute area		*/
	/*  42 */ int16_t line_beg;			/* Beginning line endstyle			*/
	/*  44 */ int16_t line_color; 		/* Current line color (PEL value)		*/
	/*  46 */ int16_t line_end;			/* Ending line endstyle 			*/
	/*  48 */ int16_t line_index; 		/* Current line style			*/
	/*  50 */ int16_t line_width; 		/* Current line width			*/
	/*  52 */ FONT_HEAD *loaded_fonts;	/* Pointer to first loaded font 		*/
	/*  56 */ int16_t mark_color; 		/* Current marker color (PEL value) 	*/
	/*  58 */ int16_t mark_height;		/* Current marker height			*/
	/*  60 */ int16_t mark_index; 		/* Current marker style 			*/
	/*  62 */ int16_t mark_scale; 		/* Current scale factor for marker data */
	/*  64 */ struct attribute *next_work;	/* Pointer to next virtual workstation	*/
	/*  68 */ int16_t num_fonts;		/* Total number of faces available		*/
	/*  70 */ int16_t scaled; 			/* TRUE if font scaled in any way		*/
	/*  72 */ FONT_HEAD scratch_head; 	/* Holder for the doubled font data 	*/
	/* 162 */ int16_t text_color; 		/* Current text color (PEL value)		*/
	/* 164 */ int16_t ud_ls;			/* User defined linestyle			*/
	/* 166 */ int16_t ud_patrn[MU_PLANES*16];	/* User defined pattern 			*/
	/* 1190/422/294 */ int16_t v_align;			/* Current text vertical alignment		*/
	/* 1192/424/296 */ int16_t wrt_mode;		/* Current writing mode 			    */
	/* 1194/426/298 */ int16_t xfm_mode;		/* Transformation mode requested		*/
	/* 1196/428/300 */ int16_t xmn_clip;		/* Low x point of clipping rectangle	*/
	/* 1198/430/302 */ int16_t xmx_clip;		/* High x point of clipping rectangle	*/
	/* 1200/432/304 */ int16_t ymn_clip;		/* Low y point of clipping rectangle	*/
	/* 1202/434/306 */ int16_t ymx_clip;		/* High y point of clipping rectangle	*/
	/* 1204/436/308 */ 
} ATTRIBUTE;

/* Virtual workstation attributes   */
extern ATTRIBUTE virt_work;

#endif
