/*
 *********************************  gsxdef.h  **********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/07/29 14:30:19 $
 * =============================================================================
 *
 * Revision 3.1  91/07/29  14:30:19  lozben
 * Created ABS() macro.
 * 
 * Revision 3.0  91/01/03  15:10:14  lozben
 * New generation VDI
 * 
 * Revision 2.5  90/04/03  13:55:13  lozben
 * Added a "#define BLTPRFRM". The number reflects (not really) the blit
 * performance.
 * 
 * Revision 2.4  90/03/01  12:20:30  lozben
 * Added a comment to look for on the line which is system dependent.
 * 
 * Revision 2.3  89/07/28  21:28:14  lozben
 * Dleted "#define MAX_COL", not used any more.
 * 
 * Revision 2.2  89/04/13  20:28:03  lozben
 * Added define MAX_PAL (size of the palette)
 * 
 * Revision 2.1  89/02/21  17:22:56  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 *******************************************************************************
 */
#ifndef _GSXDEF_H_
#define _GSXDEF_H_

/*
 * Blit perfomance:
 * TT 16 mghz = 5000 (assume cache is on)
 * ST  8 mghz = 1000 (software performance)
 */
#if TOSVERSION >= 0x300
#define BLTPRFRM	5000
#else
#define BLTPRFRM	1000
#endif

#define MX_LN_STYLE		7
#define MX_LN_WIDTH		40
#define MAX_MARK_INDEX		6
#define MAX_FONT		1
#define MX_FIL_STYLE		4
#define MX_FIL_HAT_INDEX	12
#define	MX_FIL_PAT_INDEX	24
#define MAX_MODE		3
#define MIN_ARC_CT		32	/* minimum # of points on circle    */
#define MAX_ARC_CT		128	/* maximum # of points on circle    */

#define LLUR 0
#define ULLR 1

#define SQUARED 0
#define ARROWED 1
#define CIRCLED 2

#define xres		LV(DEV_TAB)[0]
#define yres		LV(DEV_TAB)[1]
#define xsize		LV(DEV_TAB)[3]
#define ysize		LV(DEV_TAB)[4]

#define	DEF_LWID	LV(SIZ_TAB)[4]
#define	DEF_CHHT	LV(SIZ_TAB)[1]
#define	DEF_CHWT	LV(SIZ_TAB)[0]
#define DEF_MKWD	LV(SIZ_TAB)[8]
#define DEF_MKHT	LV(SIZ_TAB)[9]
#define MAX_MKWD	LV(SIZ_TAB)[10]
#define MAX_MKHT	LV(SIZ_TAB)[11]

#define TA_LEFT           0 /* horizontal */
#define TA_CENTER         1
#define TA_RIGHT          2
#define TA_BASE           0 /* vertical */
#define TA_HALF           1
#define TA_ASCENT         2
#define TA_BOTTOM         3
#define TA_DESCENT        4
#define TA_TOP            5

#define ALI_LEFT         TA_LEFT
#define ALI_CENTER       TA_CENTER
#define ALI_RIGHT        TA_RIGHT
#define ALI_BASE         TA_BASE
#define ALI_HALF         TA_HALF
#define ALI_ASCENT       TA_ASCENT
#define ALI_BOTTOM       TA_BOTTOM
#define ALI_DESCENT      TA_DESCENT
#define ALI_TOP          TA_TOP

#define ABS(x) ((x) >= 0 ? (x) : -(x))

typedef struct fdb {
	int16_t    *data;			/* pointer to image data		*/
	int16_t    width;			/* image width in pixels		*/
	int16_t    height;			/* image height in pixels		*/
	int16_t    wordWidth;		/* image width in words 		*/
	int16_t    formatId;		/* 0 mchn, 1 stnd, 2 intrlvd, 3 px	*/
	int16_t    planes;			/* # of color bit planes		*/
	int16_t    reserved[3]; 	/* reserved for future use		*/
} FDB;

#endif
