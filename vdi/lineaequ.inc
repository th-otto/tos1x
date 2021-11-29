/*
 *******************************  lineaequ.s  *********************************
 *
 * ============================================================================
 * $Author: lozben $	$Date: 91/07/29 14:55:44 $
 * ============================================================================
 *
 * Revision 3.1  91/07/29  14:55:44  lozben
 * Created this file of needed equates for the new multitasking vdi.
 *
 ******************************************************************************
 */

#ifndef LINEAEQU_INC
#define LINEAEQU_INC

#include "devequ.inc"

/*****************************************
 *	Non-Overlayable Variables        *
 *****************************************/
#define angle			-910
#define beg_ang			-908
#define CUR_FONT		-906
#define del_ang			-902
#define deltay			-900
#define deltay1			-898
#define deltay2			-896
#define end_ang			-894
#define fil_intersect		-892
#define fill_maxy		-890
#define fill_miny		-888
#define n_steps			-886
#define odeltay			-884
#define s_begsty		-882
#define s_endsty		-880
#define s_fil_col		-878
#define s_fill_per		-876
#define s_patmsk		-874
#define s_patptr		-872
#define start			-868
#define xc			-866
#define xrad			-864
#define _Y			-862
#define yc			-860
#define yrad			-858


/* define the mouse form storage area */
#define mouse_cdb		-856
/* Mouse hot spot - x coord */
#define m_poshx			-856
/* Mouse hot spot - y coord */
#define m_poshy			-854
/* Mouse planes (reserved, but we used it!) */
#define m_planes		-852
/* Mouse background color as pel value */
#define m_cdb_bg		-850
/* Mouse foreground color as pel value */
#define m_cdb_fg		-848
/* Storage for mouse cursor mask and form */
#define mask_form		-846

#define INQ_TAB			-782
#define DEV_TAB			-692

#define GCURXY			-602
#define GCURX			-602
#define GCURY			-600

#define HIDE_CNT		-598
#define MOUSE_BT		-596
#define REQ_COL			-594
#define SIZ_TAB			-498
#define TERM_CH			-468
#define chc_mode		-466
/* pointer to current works attributes */
#define cur_work		-464
/* pointer to default font head */
#define def_font		-460
#define font_ring		-456
#define ini_font_count		-440
#define line_cw			-438
#define loc_mode		-436
#define num_qc_lines		-434

#if (TOSVERSION >= 0x300) & PLANES8
/* space to save the return address */
#define trap14sav		-432
/* some modes this is ored in VS_COLOR */
#define col_or_mask		-428
/* some modes this is anded in VS_COLOR */
#define col_and_mask		-424
/* space to sav ret adr (for reentrency) */
#define trapb14sav		-420
#define resrvd0			-416
#else
#define q_circle                -432
#endif

#define str_mode		-352
#define val_mode		-350

/*
 * Current mouse status bits
 *	 bits used as follows
 *
 *	 0   LEFT button state
 *	 1   RIGHT button state
 *	 2-4 not used
 *	 5   movement status
 *	 6   LEFT button changed
 *	 7   RIGHT button changed
 */
#define cur_ms_stat		-348
#define resrvd1			-347


#define disab_cnt		-346


/* x,y communication block. */
#define  xydraw			-344
/* Non-zero means draw mouse form on vblank */
#define draw_flag		-340


/* Non-zero if mouse ints disabled */
#define mouse_flag		-339

#define retsav			-338
/* save area for cursor cell coords */
#define sav_cxy			-334
/* save area for cursor cell coords X pos */
#define sav_cx			-334
/* save area for cursor cell coords Y pos */
#define sav_cy			-332

#define save_block		-330
#define save_len		-330
/* screen address of 1st word of plane 0 */
#define save_addr		-328
#define save_stat		-324
/* save up to 4 planes. 16 longwords / plane */
#define save_area		-322

#define tim_addr		-66
#define tim_chain		-62
/* user button vector */
#define user_but		-58
/* user cursor vector */
#define user_cur		-54
/* user motion vector */
#define user_mot		-50

#define v_cel_ht		-46
#define v_celmx			-44
#define v_celmy			-42
/* used in ST blitter code otherwise obsolete */
#define v_cel_wr		-40
#define v_col_bg		-38
#define v_col_fg		-36
#define v_cur_ad		-34
#define v_cur_off		-30
#define v_curcx			-28
#define v_curcy			-26
/* v_cur_tim reload value. */
#define vct_init		-24
#define v_cur_tim		-23
#define v_fnt_ad		-22
#define v_fnt_nd		-18
#define v_fnt_st		-16
#define v_fnt_wr		-14
#define v_hz_rez		-12
#define v_off_ad		-10
#define v_stat_0		-6
#define v_delay			-5
#define v_vt_rez		-4
/* copy of _v_lin_wr for concat. */
#define bytes_lin		-2

/* _lineAvars points here */

/* number of video planes. */
#define v_planes		0
/* number of bytes/video line. */
#define v_lin_wr		2

#define local_pb		4

/* ptr to the CONTRL array. */
#define CONTRL			4
/* ptr to the INTIN array. */
#define INTIN			8
/* ptr to the PTSIN array. */
#define PTSIN			12
/* ptr to the INTOUT array. */
#define INTOUT			16
/* ptr to the PTSOUT array. */
#define PTSOUT			20

/* foreground bit_plane #1 value. */
#define FG_BP_1			24
/* foreground bit_plane #2 value. */
#define FG_BP_2			26
/* foreground bit_plane #3 value. */
#define FG_BP_3			28
/* foreground bit_plane #4 value. */
#define FG_BP_4			30
/* 0 > not last line of polyline. */
#define LSTLIN			32
/* line style mask. */
#define LN_MASK			34
/* writing mode. */
#define WRT_MODE		36


/* _X1. */
#define X1			38
/* _Y1. */
#define Y1			40
/* _X2. */
#define X2			42
/* _Y2. */
#define Y2			44
/* ptr to pattern. */
#define patptr			46
/* pattern index. (mask) */
#define patmsk			50
/* multi-plane fill flag. (0 => 1 plane) */
#define multifill		52

/* clipping flag. */
#define CLIP			54
/* x minimum clipping value. */
#define XMN_CLIP		56
/* y minimum clipping value. */
#define YMN_CLIP		58
/* x maximum clipping value. */
#define XMX_CLIP		60
/* y maximum clipping value. */
#define YMX_CLIP		62

/* accumulator for x DDA */
#define XACC_DDA		64
/* the fraction to be added to the DDA */
#define DDA_INC			66
/* scale up or down flag. */
#define T_SCLSTS		68
/* non-zero - cur font is monospaced */
#define MONO_STATUS		70
#define SOURCEX			72
/* upper left of character in font file */
#define SOURCEY			74
#define DESTX			76
/* upper left of destination on screen */
#define DESTY			78
#define DELX			80
/* width and height of character */
#define DELY			82
/* pointer to font data */
#define FBASE			84
/* offset,segment and form with of font */
#define FWIDTH			88
/* special effects */
#define STYLE			90
/* special effects */
#define LITEMASK		92
/* special effects */
#define SKEWMASK		94
/* special effects */
#define WEIGHT			96
#define R_OFF			98
/* skew above and below baseline */
#define L_OFF			100
/* replicate pixels */
#define SCALE			102
/* character rotation vector */
#define CHUP			104
/* text foreground color */
#define TEXT_FG			106
/* pointer to base of scratch buffer */
#define scrtchp			108
/* large buffer base offset */
#define scrpt2			112
/* text background color */
#define TEXT_BG			114
/* copy raster form type flag. (opaque/trans) */
#define COPYTRAN		116
/* ptr to routine for quitting seedfill. */
#define quitfill		118
/* ptr to user routine before dev_init */
#define USERDEVINIT		122
/* ptr to user routine before esc_init */
#define USERESCINIT		126
#define resrvd2                 130

/* pointer to drawing primitives vector list */
#define LA_ROUTINES		162
#if TOSVERSION >= 0x400
/* pointer to current device structure */
#define LA_CURDEV		166
#else
/* drawing primitives done in software   */
#define LA_SOFTROUTINES		166
#endif
#define BLT_MODE		170

#if PLANES8

#define LA_F32			172

/* extended request color array */
#define REQ_X_COL		174

/* points to the proper save block */
#define sv_blk_ptr		1614
/* foreground bit planes flags (bit 0 is plane 0) */
#define FG_B_PLANES		1618

/* foreground bit_plane #5 value. */
#define FG_BP_5			1622
/* foreground bit_plane #6 value. */
#define FG_BP_6			1624
/* foreground bit_plane #7 value. */
#define FG_BP_7			1626
/* foreground bit_plane #8 value. */
#define FG_BP_8			1628

#define sav8_block		1630
#define sav8_len		1630
/* screen address of 1st word of plane 0 */
#define sav8_addr		1632
#define sav8_stat		1636
/* save up to 8 planes. 16 longwords / plane */
#define sav8_area	 	1638

#if !VIDEL_SUPPORT

/* space to build circle coordinates (80 words) */
#define q_circle		2150

#else

/* space to build circle coordinates */
#define q_circle		2662

/* ******************* NEW EQUATES ******************* */

/* number of bytes per pixel (0 if < 1) */
#define byt_per_pix		2822
/* scrn form 2 ST, 1 stndrd, 3 pix */
#define form_id			2824
/* escape background color */
#define vl_col_bg		2826
/* escape foreground color */
#define vl_col_fg		2830
/* either a maping of reg's or true val */
#define pal_map			2834
/* all the vectored primitives (40 ptrs) */
#define V_PRIMITIVES		3858

#endif

#endif

/*
 * Macros for accessing linea variables:
 * LA: load address register with lineavar variable base
 * LV: access through base register
 * PIXLA: load address register with lineavar variable base if MULTI_LINEA, no-op otherwise
 * PIXLV: access through base register if MULTI_LINEA, absolute otherwise
 */
#if MULTI_LINEA
#define LA(r) move.l _lineAVars,r
#define PIXLA(r) LA(r)
#define PIXLV(v,r) v(r)
#else
#define LA(r) lea lineavars,r
#define PIXLA(r)
#define PIXLV(v,r) lineavars+(v)
#endif
#define LV(v,r) v(r)


#if BLITTER_SUPPORT

/* first register of bit blt */
#define BLASTER	$FF8A00

#endif

#endif /* LINEAEQU_INC */
