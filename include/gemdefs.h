/************************************************************************/
/*	GEMDEFS.H Common GEM definitions and miscellaneous structures.	*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

/*	EVENT Manager Definitions					*/

/* multi flags		*/
#define MU_KEYBD  0x0001	
#define MU_BUTTON 0x0002
#define MU_M1     0x0004
#define MU_M2     0x0008
#define MU_MESAG  0x0010
#define MU_TIMER  0x0020

/* keyboard states	*/
#define K_RSHIFT 0x0001
#define K_LSHIFT 0x0002
#define K_CTRL   0x0004
#define K_ALT    0x0008

/* message values	*/
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

#define CT_UPDATE   50
#define CT_MOVE     51
#define CT_NEWTOP   52

#define SCR_MGR 0x0001			/* pid of the screen manager */

/*	FORM Manager Definitions					*/

/* Form flags		*/
#define FMD_START  0
#define FMD_GROW   1
#define FMD_SHRINK 2
#define FMD_FINISH 3

/*	RESOURCE Manager Definitions					*/

/* data structure types */
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

/* used in RSCREATE.C	*/
typedef struct rshdr
{
	unsigned short		rsh_vrsn;
	unsigned short		rsh_object;
	unsigned short		rsh_tedinfo;
	unsigned short		rsh_iconblk;	/* list of ICONBLKS		*/
	unsigned short		rsh_bitblk;
	unsigned short		rsh_frstr;	
	unsigned short		rsh_string;
	unsigned short		rsh_imdata;	/* image data			*/
	unsigned short		rsh_frimg;	
	unsigned short		rsh_trindex;
	unsigned short		rsh_nobs;	/* counts of various structs	*/
	unsigned short		rsh_ntree;
	unsigned short		rsh_nted;
	unsigned short		rsh_nib;
	unsigned short		rsh_nbb;
	unsigned short		rsh_nstring;
	unsigned short		rsh_nimages;
	unsigned short		rsh_rssize;	/* total bytes in resource	*/
} RSHDR;

/*	WINDOW Manager Definitions.					*/

/* Window Attributes	*/
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

/* wind_calc flags	*/
#define WC_BORDER 0
#define WC_WORK   1

/* wind_get flags	*/
#define WF_KIND		1
#define WF_NAME		2
#define WF_INFO		3
#define WF_WORKXYWH	4
#define WF_CURRXYWH	5
#define WF_PREVXYWH	6
#define WF_FULLXYWH	7
#define WF_HSLIDE	8
#define WF_VSLIDE	9
#define WF_TOP      	10
#define WF_FIRSTXYWH 	11
#define WF_NEXTXYWH 	12
#define WF_RESVD   	13
#define WF_NEWDESK 	14
#define WF_HSLSIZE   	15
#define WF_VSLSIZE   	16
#define WF_SCREEN   	17

/* update flags		*/
#define	END_UPDATE 0
#define	BEG_UPDATE 1
#define	END_MCTRL  2
#define	BEG_MCTRL  3

/* arrow message	*/
#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7

/*	GRAPHICS Manager Definitions					*/

/* Mouse Forms		*/
#define	ARROW	    0
#define	TEXT_CRSR   1
#define	HOURGLASS   2
#define	POINT_HAND  3
#define	FLAT_HAND   4
#define	THIN_CROSS  5
#define	THICK_CROSS 6
#define	OUTLN_CROSS 7
#define	USER_DEF  255
#define M_OFF     256
#define M_ON      257

/*	MISCELLANEOUS Structures					*/

/* Mouse Form Definition Block */
typedef struct mfstr
{
	short	mf_xhot;
	short	mf_yhot;
	short	mf_nplanes;
	short	mf_fg;
	short	mf_bg;
	short	mf_mask[16];
	short	mf_data[16];
} MFORM;

/* Structure for passing menu data */
typedef struct _menu
{
   OBJECT *mn_tree;		/* Object tree of the menu */
   short mn_menu;			/* Parent of the menu items*/
   short mn_item;			/* Starting menu item      */
   short mn_scroll;		/* scroll flag for the menu*/
} MENU;

/* Structure for the Menu Settings */
typedef struct _mn_set
{
   long   Display;		/* The display delay      */
   long   Drag;			/* The drag delay         */
   long   Delay;		/* The Arrow Delay        */
   long   Speed;		/* The scroll speed delay */
   short  Height;		/* The menu scroll height */
} MN_SET;
