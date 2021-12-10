/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:27:54 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:27:54  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:30:18  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:29  lozben
 * Initial revision
 * 
 *************************************************************************
 *
 *       Copyright 1999, Caldera Thin Clients, Inc.
 *       Copyright (C) 2016 The EmuTOS development team
 *
 *       This software is licenced under the GNU Public License.
 *       Please see LICENSE.TXT for further information.
 *
 *                  Historical Copyright
 *       -----------------------------------------------------------
 *       GEM Application Environment Services            Version 2.3
 *       Serial No.  XXXX-0000-654321            All rights Reserved
 *       Copyright (C) 1986                    Digital Research Inc.
 *       -----------------------------------------------------------
 *************************************************************************
 */
/*	GSXDEFS.H	05/06/84 - 12/08/84	Lee Lorenzen		*/

#ifndef GSXDEFS_H
#define GSXDEFS_H 1

#include "ws.h"

#define OPEN_WORKSTATION	1
#define CLOSE_WORKSTATION	2
#define CLEAR_WORKSTATION	3
#define UPDATE_WORKSTATION	4

#define GSX_ESCAPE			5


#define POLYLINE		6
#define POLYMARKER		7
#define TEXT			8
#define FILLED_AREA		9
#define CELL_ARRAY		10

#define GDP			11

#define CHAR_HEIGHT		12
#define CHAR_UP_VECT		13
#define SET_COLOR_REP		14
#define S_LINE_TYPE		15
#define S_LINE_WIDTH		16
#define S_LINE_COLOR		17
#define S_MARK_TYPE		18
#define S_MARK_SCALE		19
#define S_MARK_COLOR		20
#define SET_FONT		21
#define S_TEXT_COLOR		22
#define S_FILL_STYLE		23
#define S_FILL_INDEX		24
#define S_FILL_COLOR		25
#define INQUIRE_COLOR_REP	26
#define INQ_CELL_ARRAY		27

#define LOCATOR_INPUT		28
#define VALUATOR_INPUT		29
#define CHOICE_INPUT		30	
#define STRING_INPUT		31
#define SET_WRITING_MODE	32

#define SET_INPUT_MODE		33
#define VQT_ATTRIBUTES      38

#define OPEN_VWORKSTATION	100
#define CLOSE_VWORKSTATION	101
#define EXTENDED_INQUIRE	102
#define CONTOUR_FILL		103

#define ST_FILLPERIMETER	104
#define ST_TXT_DISPLAY_MODE	105
#define ST_TXT_STYLE		106
#define ST_CH_HEIGHT		107
#define RET_PIXEL_VALUE		108

#define COPY_RASTER_FORM	109
#define TRANSFORM_FORM		110
#define ST_CUR_FORM		111
#define ST_UD_FILL_PATTERN	112
#define ST_UD_LINE_STYLE	113
#define FILL_RECTANGLE		114

#define LOC_MULTIWAIT		115
#define I_TEXT_EXTENT		116
#define I_TEXT_WIDTH		117
#define TIM_VECX		118

#define COPY_ALPHA_TEXT		119
#define ALTER_ALPHA_TEXT	120
#define TRAN_RASTER_FORM	121

#define SHOW_CUR		122
#define HIDE_CUR		123
#define MOUSE_ST		124
#define BUT_VECX		125
#define MOT_VECX		126
#define CUR_VECX		127
#define KEY_SHST		128
#define TEXT_CLIP		129


#ifndef __FDB
#define __FDB 1
typedef struct fdbstr
{
	VOIDPTR     fd_addr;
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


extern FDB gl_src;
extern FDB gl_dst;
extern FDB gl_tmp;

/*
 * VDI arrays, not ours..
 */
extern int16_t contrl[];
extern int16_t intin[];
extern int16_t intout[];
extern int16_t ptsin[];
extern int16_t ptsout[10];
extern VOIDPTR ad_intin; /* FAR ptr to intin */



/*
 * gemgsxif.[cS]
 */
/* counting semaphore  == 0 implies ON  >  0 implies OFF    */
extern int gl_moff;
extern long gl_mlen;
extern BOOLEAN gl_graphic;
extern BOOLEAN gl_mouse;					/* mouse on flag        */
extern intptr_t tikaddr;
extern intptr_t tiksav;

VOID gsx_mfree PROTO((NOTHING));
VOID gsx_mret PROTO((VOIDPTR *pmaddr, int32_t *pmlen));


VOID gsx_1code PROTO((int16_t code, int16_t value));
VOID gsx_ncode PROTO((int16_t code, int16_t nptsin, int16_t nintin));
VOID gsx_mxmy PROTO((int16_t *pmx, int16_t *pmy));
#if LINEF_HACK
/* actually same functions, but with different opcode entries in linef dispatcher */
VOID gsx_1acode PROTO((int16_t code, int16_t value));
VOID gsx_acode PROTO((int16_t code, int16_t nptsin, int16_t nintin));
VOID gsx_fmxmy PROTO((int16_t *pmx, int16_t *pmy));
VOID gsx_fmoff PROTO((NOTHING));
#else
#define gsx_acode gsx_ncode
#define gsx_1acode gsx_1code
#define gsx_fmxmy gsx_mxmy
#define gsx_fmoff gsx_moff
#endif
VOID gsx_init PROTO((NOTHING));
VOID gsx_graphic PROTO((BOOLEAN tographic));
VOID gsx_escapes PROTO((int16_t esc_code));
VOID av_hardcopy PROTO((NOTHING));
VOID gsx_wsopen PROTO((NOTHING));
VOID gsx_wsclose PROTO((NOTHING));
VOID ratinit PROTO((NOTHING));
VOID ratexit PROTO((NOTHING));
VOID bb_set PROTO((int16_t sx, int16_t sy, int16_t sw, int16_t sh, int16_t *pts1, int16_t *pts2, FDB *pfd, FDB *psrc, FDB *pdst));
VOID bb_save PROTO((GRECT *ps));
VOID bb_restore PROTO((GRECT *ps));
VOID gsx_resetmb PROTO((NOTHING));
int16_t gsx_tick PROTO((intptr_t tcode, intptr_t *ptsave));
int16_t gsx_button PROTO((NOTHING));
VOID gsx_moff PROTO((NOTHING));
VOID gsx_mon PROTO((NOTHING));

int16_t av_opnwk PROTO((int16_t *pwork_in, int16_t *phandle, int16_t *pwork_out));
VOID av_pline PROTO((int16_t count, int16_t *pxyarray));
VOID avst_clip PROTO((int16_t clip_flag, int16_t pxyarray));
VOID avst_height PROTO((int16_t height, int16_t *pchr_width, int16_t *pchr_height, int16_t *pcell_width, int16_t *pcell_height));
VOID avr_recfl PROTO((int16_t *pxyarray, FDB *pdesMFDB)); /* ??? why MFDB ??? */
VOID avro_cpyfm PROTO((int16_t wr_mode, int16_t *pxyarray, FDB *psrcMFDB, FDB *pdesMFDB));
VOID avrt_cpyfm PROTO((int16_t wr_mode, int16_t *pxyarray, FDB *psrcMFDB, FDB *pdesMFDB, int16_t fgcolor, int16_t bgcolor));
VOID avr_trnfm PROTO((FDB *psrcMFDB, FDB *pdesMFDB));
VOID avsl_width PROTO((int16_t width));

/*
 * apgsxif.[cS]
 */
VOID gsx_fix PROTO((FDB *pfd, int16_t *theaddr, int16_t wb, int16_t h));
VOID gsx_blt PROTO((int16_t *saddr, uint16_t sx, uint16_t sy, uint16_t swb, int16_t *daddr, uint16_t dx, uint16_t dy, uint16_t dwb, uint16_t w, uint16_t h, uint16_t rule, int16_t fgcolor, int16_t bgcolor));

#endif /* GSXDEFS_H */
