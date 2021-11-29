/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:29:21 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:29:21  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:31:23  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:57  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	OBDEFS.H	03/15/84 - 02/08/85	Gregg Morris		*/
/*	Add 3D definitons		7/7/92	D.Mui			*/
/*	Add another set of 3D definitons	8/1/92	D.Mui		*/
/*	LK3DIND	etc							*/	

#ifndef OBDEFS_H
#define OBDEFS_H

#define ROOT 0
#define NIL (-1)
#define DESK            0				/* Desktop window handle */

/* keyboard states */
#define K_RSHIFT 0x0001
#define K_LSHIFT 0x0002
#define K_CTRL   0x0004
#define K_ALT    0x0008

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

#if 0
/* no longer in effect; we use DRAW3D and ACT3D now: ++ERS 1/12/93 */
/* New Object Drawing Types for the 3D-look (May 22 1992 - ml) */

#define	X_3DIND		1	/* extended type for 3D indicator objects */
#define	X_3DACT		2	/* extended type for 3D action objects */

/* Object types of 3D indicators */
#define I3DBOX		((X_3DIND << 8) | G_BOX)
#define I3DBOXTEXT	((X_3DIND << 8) | G_BOXTEXT)
#define I3DBUTTON	((X_3DIND << 8) | G_BUTTON)
#define I3DBOXCHAR	((X_3DIND << 8) | G_BOXCHAR)
#define I3DFBOXTEXT	((X_3DIND << 8) | G_FBOXTEXT)

/* Object types with 3D actions */
#define A3DBOX		((X_3DACT << 8) | G_BOX)
#define A3DBOXTEXT	((X_3DACT << 8) | G_BOXTEXT)
#define A3DBUTTON	((X_3DACT << 8) | G_BUTTON)
#define A3DBOXCHAR	((X_3DACT << 8) | G_BOXCHAR)
#define A3DFBOXTEXT	((X_3DACT << 8) | G_FBOXTEXT)
#endif

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
	int16_t		ob_next;	/* -> object's next sibling	*/
	int16_t		ob_head;	/* -> head of object's children */
	int16_t		ob_tail;	/* -> tail of object's children */
	uint16_t	ob_type;	/* type of object- BOX, CHAR,...*/
	uint16_t	ob_flags;	/* flags			*/
	uint16_t	ob_state;	/* state- SELECTED, OPEN, ...	*/
	intptr_t	ob_spec;	/* "out"- -> anything else	*/
	int16_t		ob_x;		/* upper left corner of object	*/
	int16_t		ob_y;		/* upper left corner of object	*/
	int16_t		ob_width;	/* width of obj			*/
	int16_t		ob_height;	/* height of obj		*/
} OBJECT;


typedef struct grect
{
	int16_t	g_x;
	int16_t	g_y;
	int16_t	g_w;
	int16_t	g_h;
} GRECT;


typedef struct orect
{
	struct orect *o_link;
	GRECT    o_gr;
} ORECT;


typedef struct text_edinfo
{
	char       *te_ptext;	/* ptr to text (must be 1st)	*/
	char       *te_ptmplt;	/* ptr to template		*/
	char       *te_pvalid;	/* ptr to validation chrs.	*/
	int16_t		te_font;	/* font				*/
	int16_t		te_junk1;	/* junk word			*/
	int16_t		te_just;	/* justification- left, right...*/
	int16_t		te_color;	/* color information word	*/
	int16_t		te_junk2;	/* junk word			*/
	int16_t		te_thickness;	/* border thickness		*/
	int16_t		te_txtlen;	/* length of text string	*/
	int16_t		te_tmplen;	/* length of template string	*/
} TEDINFO;


typedef struct icon_block
{
	int16_t	*ib_pmask;
	int16_t	*ib_pdata;
	char	*ib_ptext;
	int16_t	ib_char;
	int16_t	ib_xchar;
	int16_t	ib_ychar;
	int16_t	ib_xicon;
	int16_t	ib_yicon;
	int16_t	ib_wicon;
	int16_t	ib_hicon;
	int16_t	ib_xtext;
	int16_t	ib_ytext;
	int16_t	ib_wtext;
	int16_t	ib_htext;
} ICONBLK;

typedef struct bit_block
{
	int16_t *bi_pdata;		/* ptr to bit forms data	*/
	int16_t	bi_wb;			/* width of form in bytes	*/
	int16_t	bi_hl;			/* height in lines		*/
	int16_t	bi_x;			/* source x in bit form		*/
	int16_t	bi_y;			/* source y in bit form		*/
	int16_t	bi_color;		/* fg color of blt 		*/
} BITBLK;

typedef struct user_blk
{
	intptr_t	ub_code;
	intptr_t	ub_parm;
} USERBLK;

typedef struct parm_blk
{
	OBJECT  *pb_tree;
	int16_t	pb_obj;
	int16_t	pb_prevstate;
	int16_t	pb_currstate;
	int16_t	pb_x, pb_y, pb_w, pb_h;
	int16_t	pb_xc, pb_yc, pb_wc, pb_hc;
	intptr_t pb_parm;
} PARMBLK;

typedef struct cicon_data {
    int16_t num_planes;
    int16_t *col_data;
    int16_t *col_mask;
    int16_t *sel_data;
    int16_t *sel_mask;
    struct cicon_data *next_res;
} CICON;

typedef struct cicon_blk {
    ICONBLK monoblk;
    CICON *mainlist;	/* list of color icons for different res */
} CICONBLK;


/*
 * RESOURCE Manager Definitions
 */
/*
 * data structure types:
 * type definitions for use by an application when calling
 * rsrc_gaddr and rsrc_saddr
 */
#define R_TREE     0
#define R_OBJECT   1
#define R_TEDINFO  2
#define R_ICONBLK  3
#define R_BITBLK   4
#define R_STRING   5		/* gets pointer to free strings	*/
#define R_IMAGEDATA 6		/* gets pointer to free images	*/
#define R_OBSPEC   7
#define R_TEPTEXT  8		/* sub ptrs in TEDINFO	*/
#define R_TEPTMPLT 9
#define R_TEPVALID 10
#define R_IBPMASK  11		/* sub ptrs in ICONBLK	*/
#define R_IBPDATA  12
#define R_IBPTEXT  13
#define R_BIPDATA  14		/* sub ptrs in BITBLK	*/
#define R_FRSTR    15		/* gets addr of ptr to free strings	*/
#define R_FRIMG    16		/* gets addr of ptr to free images	*/

/* must same order as RT_ */
typedef struct rshdr
{
	uint16_t		rsh_vrsn;
	uint16_t		rsh_object;
	uint16_t		rsh_tedinfo;
	uint16_t		rsh_iconblk;	/* list of ICONBLKS */
	uint16_t		rsh_bitblk;
	uint16_t		rsh_frstr;	
	uint16_t		rsh_string;
	uint16_t		rsh_imdata;		/* image data */
	uint16_t		rsh_frimg;	
	uint16_t		rsh_trindex;
	uint16_t		rsh_nobs;		/* counts of various structs */
	uint16_t		rsh_ntree;
	uint16_t		rsh_nted;
	uint16_t		rsh_nib;
	uint16_t		rsh_nbb;
	uint16_t		rsh_nstring;
	uint16_t		rsh_nimages;
	uint16_t		rsh_rssize;		/* total bytes in resource */
} RSHDR;



/*
 * WINDOW Manager Definitions.
 */

/* wind_calc flags */
#define WC_BORDER   0
#define WC_WORK     1

/* wind_get flags */
#define WF_KIND         1
#define WF_NAME         2
#define WF_INFO         3
#define WF_WORKXYWH     4
#define WF_CURRXYWH     5
#define WF_PREVXYWH     6
#define WF_FULLXYWH     7
#define WF_HSLIDE       8
#define WF_VSLIDE       9
#define WF_TOP          10
#define WF_FIRSTXYWH    11
#define WF_NEXTXYWH     12
#define WF_RESVD        13
#define WF_NEWDESK      14
#define WF_HSLSIZE      15
#define WF_VSLSIZE      16
#define WF_SCREEN       17
/* window color settings added 900227 - kbad */
#define WF_COLOR        18  /* set window element by handle */
#define WF_DCOLOR       19  /* set default element */
#define WF_OWNER        20  /* added Jul 23 91 for menu bar in window - ml. */

#define WF_TATTRB 18	/* PC-GEM */
#define WF_SIZTOP 19	/* PC-GEM */
#define WF_COTOP  20	/* For ViewMAX */

/* added Feb 25 92 to allow bottoming window - ml. */
#define WF_BEVENT	24
#define	WF_BOTTOM	25

/* arrow message */
#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7

/* Bit mask for window components */
#define NAME    0x0001
#define CLOSER  0x0002
#define FULLER  0x0004
#define MOVER   0x0008
#define INFO    0x0010
#define SIZER   0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE  0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE  0x0800
/* Added Jul 23 91 for new window manager - ml. */
#define MENUBAR 0x1000
#define HOTCLOSE 0x1000               /* added 11/12/85       LKW             */

/* wind_update flags */
#define END_UPDATE  0
#define BEG_UPDATE  1
#define END_MCTRL   2
#define BEG_MCTRL   3
#define BEG_CHECK   0x100   /* prevent the application from blocking */


/*
 * FORM Manager Definitions
 */
/* Form flags */
#define FMD_START  0
#define FMD_GROW   1
#define FMD_SHRINK 2
#define FMD_FINISH 3

/*
 * GRAPHICS Manager Definitions
 */
/* Mouse Forms */
#define ARROW	          0
#define TEXT_CRSR         1
#define HOURGLASS         2
#define BUSY_BEE          HOURGLASS
#define BUSYBEE           HOURGLASS
#define POINT_HAND        3
#define FLAT_HAND         4
#define THIN_CROSS        5
#define THICK_CROSS       6
#define OUTLN_CROSS       7

#define USER_DEF  255
#define M_OFF     256
#define M_ON      257
#define M_SAVE    258
#define M_RESTORE 259
#define M_PREV    260 


/*
 * EVENT Manager Definitions
 */

/* message values */
#define MN_SELECTED 10

#define WM_REDRAW   20
#define WM_TOPPED   21
#define WM_CLOSED   22
#define WM_FULLED   23
#define WM_ARROWED  24
#define WM_HSLID    25
#define WM_VSLID    26
#define WM_SIZED    27
#define WM_MOVED    28
#define WM_NEWTOP   29
#define WM_UNTOPPED	30
#define WM_ONTOP	31
#define WM_BOTTOM	33

#define AC_OPEN     40
#define AC_CLOSE    41
#define WM_USER	    0

#define CT_UPDATE   50
#define CT_MOVE     51
#define CT_NEWTOP   52

/* multi flags */
#define MU_KEYBD  0x0001	
#define MU_BUTTON 0x0002
#define MU_M1     0x0004
#define MU_M2     0x0008
#define MU_MESAG  0x0010
#define MU_TIMER  0x0020

typedef struct moblk
{
	int16_t		m_out;
	int16_t		m_x;
	int16_t		m_y;
	int16_t		m_w;
	int16_t		m_h;
} MOBLK;

#ifndef __FDB
#define __FDB 1
/*
 * MISCELLANEOUS Structures
 */
/* Memory Form Definition Block */
typedef struct fdbstr
{
	VOIDPTR	    fd_addr;
	int16_t		fd_w;
	int16_t		fd_h;
	int16_t		fd_wdwidth;
	int16_t		fd_stand;
	int16_t		fd_nplanes;
	int16_t		fd_r1;
	int16_t		fd_r2;
	int16_t		fd_r3;
} FDB;
#endif

#ifndef __MENU
#define __MENU 1
/* Structure for passing menu data */
typedef struct _menu
{
	OBJECT *mn_tree;					/* Object tree of the menu */
	int16_t mn_menu;					/* Parent of the menu items */
	int16_t mn_item;					/* Starting menu item      */
	int16_t mn_scroll;					/* scroll flag for the menu */
	int16_t mn_keystate;				/* Key State           */
} MENU;
#endif

#endif
