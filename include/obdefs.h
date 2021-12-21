/************************************************************************/
/*	OBDEFS.H Common OBJECT definitions and structures.		*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

#define ROOT 0
#define NIL (-1)
#define DESK            0				/* Desktop window handle */

/* max depth of search or draw for objects */
#define MAX_DEPTH 8

/* inside patterns */
#define IP_HOLLOW 0
#define IP_1PATT 1
#define IP_2PATT 2
#define IP_3PATT 3
#define IP_4PATT 4
#define IP_5PATT 5
#define IP_6PATT 6
#define IP_SOLID 7

/* gsx modes */
#define MD_REPLACE 1
#define MD_TRANS   2
#define MD_XOR     3
#define MD_ERASE   4

/* gsx styles */
#define FIS_HOLLOW  0
#define FIS_SOLID   1
#define FIS_PATTERN 2
#define FIS_HATCH   3
#define FIS_USER    4

/* bit blt rules */
#define ALL_WHITE  0
#define S_AND_D    1
#define S_AND_NOTD 2
#define S_ONLY     3
#define NOTS_AND_D 4
#define	D_ONLY     5
#define S_XOR_D    6
#define S_OR_D     7
#define	NOT_SORD   8
#define	NOT_SXORD  9
#define D_INVERT  10
#define	NOT_D     10
#define	S_OR_NOTD 11
#define NOT_S     12
#define NOTS_OR_D 13
#define	NOT_SANDD 14
#define ALL_BLACK 15

/* font types */
#define IBM   3
#define SMALL 5

/* Graphic types of obs	*/
#define G_BOX     20
#define G_TEXT    21
#define G_BOXTEXT 22
#define G_IMAGE   23
#define G_USERDEF 24
#define G_IBOX    25
#define G_BUTTON  26
#define G_BOXCHAR 27
#define G_STRING  28
#define G_FTEXT   29
#define G_FBOXTEXT 30
#define G_ICON    31
#define G_TITLE   32
#define G_CICON	  33

/* Object flags */
#define NONE       0x0
#define SELECTABLE 0x1
#define DEFAULT    0x2
#define EXIT       0x4
#define EDITABLE   0x8
#define RBUTTON   0x10
#define LASTOB    0x20
#define TOUCHEXIT 0x40
#define HIDETREE  0x80
#define INDIRECT 0x100
#define IS3DOBJ	 0x200		/* set for any 3D object */
#define IS3DACT	 0x400		/* 0 for indicator, 1 for activator */
#define SUBMENU	 0x800

/* Object states */
#define NORMAL    0x0
#define SELECTED  0x1
#define CROSSED   0x2
#define CHECKED   0x4
#define DISABLED  0x8
#define OUTLINED 0x10
#define SHADOWED 0x20
#define WHITEBAK 0x40
#define DRAW3D	 0x80

/* Object colors */
#define WHITE    0
#define BLACK    1
#define RED      2
#define GREEN    3
#define BLUE     4
#define CYAN     5
#define YELLOW   6
#define MAGENTA  7
#define LWHITE   8
#define LBLACK   9
#define LRED     10
#define LGREEN   11
#define LBLUE    12
#define LCYAN    13
#define LYELLOW  14
#define LMAGENTA 15

/* 7-30-92 - ml.    3D objects */

#define	LK3DIND	    1	/* change look of 3D indicators */
#define	LK3DACT	    2	/* change look of 3D action objects */
#define	INDBUTCOL   3	/* change color of buttons */
#define	ACTBUTCOL   4	/* change color of buttons */
#define	ALRTCOL	    5	/* change color of alert background */
#define AD3DVALUE   6	/* get pixel adjustment for 3D objects */

/* scrp_read return values */
#define SC_FTCSV 0x0001
#define SC_FTTXT 0x0002
#define SC_FTGEM 0x0004
#define SC_FTIMG 0x0008
#define SC_FTDCA 0x0010
#define SC_FTUSR 0x8000

/* editable text field definitions */
#define EDSTART 0
#define EDINIT  1
#define EDCHAR  2
#define EDEND   3

/* editable text justification */
#define TE_LEFT  0
#define TE_RIGHT 1
#define TE_CNTR  2

/*
 * Structure Definitions
 */

typedef struct object
{
	short		ob_next;	/* -> object's next sibling	*/
	short		ob_head;	/* -> head of object's children */
	short		ob_tail;	/* -> tail of object's children */
	unsigned short	ob_type;	/* type of object- BOX, CHAR,...*/
	unsigned short	ob_flags;	/* flags			*/
	unsigned short	ob_state;	/* state- SELECTED, OPEN, ...	*/
	long		ob_spec;	/* "out"- -> anything else	*/
	short		ob_x;		/* upper left corner of object	*/
	short		ob_y;		/* upper left corner of object	*/
	short		ob_width;	/* width of obj			*/
	short		ob_height;	/* height of obj		*/
} OBJECT;


typedef struct orect
{
	struct orect *o_link;
	short	o_x;
	short	o_y;
	short	o_w;
	short	o_h;
} ORECT;


typedef struct grect
{
	short	g_x;
	short	g_y;
	short	g_w;
	short	g_h;
} GRECT;


typedef struct text_edinfo
{
	char       *te_ptext;	/* ptr to text (must be 1st)	*/
	char       *te_ptmplt;	/* ptr to template		*/
	char       *te_pvalid;	/* ptr to validation chrs.	*/
	short		te_font;	/* font				*/
	short		te_junk1;	/* junk word			*/
	short		te_just;	/* justification- left, right...*/
	short		te_color;	/* color information word	*/
	short		te_junk2;	/* junk word			*/
	short		te_thickness;	/* border thickness		*/
	short		te_txtlen;	/* length of text string	*/
	short		te_tmplen;	/* length of template string	*/
} TEDINFO;


typedef struct icon_block
{
	VOIDPTR ib_pmask;
	VOIDPTR ib_pdata;
	VOIDPTR ib_ptext;
	short	ib_char;
	short	ib_xchar;
	short	ib_ychar;
	short	ib_xicon;
	short	ib_yicon;
	short	ib_wicon;
	short	ib_hicon;
	short	ib_xtext;
	short	ib_ytext;
	short	ib_wtext;
	short	ib_htext;
} ICONBLK;

typedef struct bit_block
{
	VOIDPTR bi_pdata;		/* ptr to bit forms data	*/
	short	bi_wb;			/* width of form in bytes	*/
	short	bi_hl;			/* height in lines		*/
	short	bi_x;			/* source x in bit form		*/
	short	bi_y;			/* source y in bit form		*/
	short	bi_color;		/* fg color of blt 		*/
} BITBLK;

typedef struct user_blk
{
	long	ub_code;
	long	ub_parm;
} USERBLK;

typedef struct parm_blk
{
	OBJECT *pb_tree;
	short	pb_obj;
	short	pb_prevstate;
	short	pb_currstate;
	short	pb_x, pb_y, pb_w, pb_h;
	short	pb_xc, pb_yc, pb_wc, pb_hc;
	long	pb_parm;
} PARMBLK;
