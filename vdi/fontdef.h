/*
 ********************************  fontdef.h  **********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/04 12:24:15 $
 * =============================================================================
 *
 * Revision 3.1  91/01/04  12:24:15  lozben
 * Typedefed structure font_head to FONT_HEAD.
 * 
 * Revision 3.0  91/01/03  15:19:51  lozben
 * New generation VDI
 * 
 *******************************************************************************
 */

#ifndef _FONTDEF_H_
#define _FONTDEF_H_

/* fh_flags   */
#define	DEFAULT 1	/* this is the default font (face and size) */
#define	HORZ_OFF  2	/* there are left and right offset tables */
#define STDFORM  4	/* is the font in standard format */
#define MONOSPACE 8	/* is the font monospaced */

/* style bits */
#define	THICKEN	1
#define	LIGHT	2
#define	SKEW	4
#define	UNDER	8
#define	OUTLINE 16
#define	SHADOW	32

typedef struct font_head {	/* descibes a font */
	int16_t  font_id;
	int16_t  point;
	char name[32];
	uint16_t first_ade;
	uint16_t last_ade;
	uint16_t top;
	uint16_t ascent;
	uint16_t half;
	uint16_t descent;		
	uint16_t bottom;
	uint16_t max_char_width;
	uint16_t max_cell_width;
	uint16_t left_offset;		/* amount character slants left when skewed */
	uint16_t right_offset;		/* amount character slants right */
	uint16_t thicken;			/* number of pixels to smear */
	uint16_t ul_size;			/* size of the underline */
	uint16_t lighten;			/* mask to and with to lighten	*/
	uint16_t skew;				/* mask for skewing */
	uint16_t flags; 		

	const uint8_t *hor_table; 		/* horizontal offsets */
	const uint16_t *off_table;		/* character offsets  */
	const uint16_t *dat_table;		/* character definitions */
	uint16_t form_width;
	uint16_t form_height;

	struct font_head *next_font;/* pointer to next font */
	uint16_t font_seg;
} FONT_HEAD;

#endif
