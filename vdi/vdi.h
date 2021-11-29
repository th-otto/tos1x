#include "vdidefs.h"

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __STDINT_H__
#include <stdint.h>
#endif

#if BINEXACT
#  ifndef __ALCYON__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif

#ifdef __GNUC__
#define unreachable() __builtin_unreachable()
#else
#define unreachable()
#endif

typedef int16_t BOOLEAN;
#define FALSE 0
#define TRUE 1

#ifdef __ALCYON__
#  define UNUSED(x)
#else
#  define UNUSED(x) ((void)(x))
#endif

#include "scrndev.h"

#define	_320x200    0					/* 320x200x4 video mode       */
#define _640x200    1					/* 640x200x2 video mode       */
#define _640x400    2					/* 640x400x1 video mode       */
#define _640x480    4					/* 640x480x4 video mode       */
#define _1280x960   6					/* 1280x960x1 monochrome mode */
#define _320x480    7					/* 320x480x8 video mode       */


/*
 * entry.S
 */
/* PTSIN maximum length */
extern int16_t const MAX_VERT;


/*
 * init.c
 */
VOID init_st_tt_sp PROTO((NOTHING));
VOID InitST PROTO((NOTHING));
VOID InitTT PROTO((NOTHING));
VOID InitSTSpLut PROTO((NOTHING));
VOID Init16Pal PROTO((NOTHING));
VOID Init32Pal PROTO((NOTHING));
VOID InitColReqArray PROTO((NOTHING));
VOID InitTTLut PROTO((NOTHING));


/*
 * isin.c
 */
int16_t Isin PROTO((int16_t ang));
int16_t Icos PROTO((int16_t ang));


/*
 * jmptbl.c
 */
VOID SCREEN PROTO((NOTHING));


/*
 * monobj.c
 */
VOID vsl_type PROTO((NOTHING));          /* VDI #15   */
VOID vsl_width PROTO((NOTHING));         /* VDI #16   */
VOID vsl_color PROTO((NOTHING));         /* VDI #17   */
VOID vsm_type PROTO((NOTHING));          /* VDI #18   */
VOID vsm_height PROTO((NOTHING));        /* VDI #19   */
VOID vsm_color PROTO((NOTHING));         /* VDI #20   */
VOID vsf_interior PROTO((NOTHING));      /* VDI #23   */
VOID vsf_style PROTO((NOTHING));         /* VDI #24   */
VOID vsf_color PROTO((NOTHING));         /* VDI #25   */
VOID v_locator PROTO((NOTHING));         /* VDI #28   */
VOID v_valuator PROTO((NOTHING));        /* VDI #29   */
VOID v_choice PROTO((NOTHING));          /* VDI #30   */
VOID v_string PROTO((NOTHING));          /* VDI #31   */
VOID vswr_mode PROTO((NOTHING));         /* VDI #32   */
VOID vsin_mode PROTO((NOTHING));         /* VDI #33   */
VOID v_show_c PROTO((NOTHING));          /* VDI #122  */
VOID v_hide_c PROTO((NOTHING));          /* VDI #123  */
VOID vq_key_s PROTO((NOTHING));          /* VDI #128  */
VOID vqin_mode PROTO((NOTHING));         /* VDI #115  */
VOID vsf_perimeter PROTO((NOTHING));     /* VDI #104  */
VOID vsl_udsty PROTO((NOTHING));         /* VDI #113  */
VOID vs_clip PROTO((NOTHING));           /* VDI #129  */
VOID dro_cpyfm PROTO((NOTHING));         /* VDI #109  */
VOID drt_cpyfm PROTO((NOTHING));         /* VDI #121  */
VOID vr_trnfm PROTO((NOTHING));          /* VDI #110  */
VOID dr_recfl PROTO((NOTHING));          /* VDI #114  */
VOID vsl_ends PROTO((NOTHING));          /* VDI #108  */
VOID arb_corner PROTO((int16_t *corners, int16_t type));


/*
 * monout.c
 */
VOID vq_extnd PROTO((NOTHING));          /* VDI #102  */
VOID v_clswk PROTO((NOTHING));           /* VDI #2    */
VOID v_pline PROTO((NOTHING));           /* VDI #6    */
VOID v_pmarker PROTO((NOTHING));         /* VDI #7    */
VOID v_fillarea PROTO((NOTHING));        /* VDI #9    */
VOID v_gdp PROTO((NOTHING));             /* VDI #11   */
VOID vql_attributes PROTO((NOTHING));    /* VDI #35   */
VOID vqm_attributes PROTO((NOTHING));    /* VDI #36   */
VOID vqf_attributes PROTO((NOTHING));    /* VDI #37   */
VOID pline PROTO((NOTHING));
BOOLEAN clip_line PROTO((NOTHING));
VOID plygn PROTO((NOTHING));
VOID gdp_rbox PROTO((NOTHING));
VOID gdp_arc PROTO((NOTHING));
VOID clc_nsteps PROTO((NOTHING));
VOID gdp_ell PROTO((NOTHING));
VOID clc_arc PROTO((NOTHING));
VOID Calc_pts PROTO((int16_t j));
VOID st_fl_ptr PROTO((NOTHING));
VOID cir_dda PROTO((NOTHING));
VOID wline PROTO((NOTHING));
VOID perp_off PROTO((int16_t *px,int16_t *py));
VOID quad_xform PROTO((int quad, int x, int y, int16_t *tx, int16_t *ty));
VOID do_circ PROTO((int16_t cx, int16_t cy));
VOID s_fa_attr PROTO((NOTHING));
VOID r_fa_attr PROTO((NOTHING));
VOID do_arrow PROTO((NOTHING));
VOID arrow PROTO((int16_t *xy,int16_t inc));
VOID init_wk PROTO((NOTHING));
VOID d_opnvwk PROTO((NOTHING));          /* VDI #100  */
VOID d_clsvwk PROTO((NOTHING));          /* VDI #101  */
VOID dsf_udpat PROTO((NOTHING));         /* VDI #112  */
VOID vq_color PROTO((NOTHING));          /* VDI #26   */
VOID vs_color PROTO((NOTHING));          /* VDI #14   */


/*
 * opnwk.c
 */
VOID v_opnwk PROTO((NOTHING));           /* VDI #1    */
#if TOSVERSION >= 0x400
const SCREENDEF *FindDevice PROTO((int16_t devId));
VOID SetCurDevice PROTO((int16_t curRez));
VOID InitFonts PROTO((NOTHING));
VOID InitDevTabInqTab PROTO((NOTHING));
#else
int16_t FindDevice PROTO((NOTHING)); /* in allgem.S */
#endif


/*
 * seedfill.c
 */
VOID d_contourfill PROTO((NOTHING));     /* VDI #103  */
VOID v_get_pixel PROTO((NOTHING));       /* VDI #105  */


/*
 * spcolor.c
 */
VOID sp_vs_color PROTO((NOTHING));
VOID sp_vq_color PROTO((NOTHING));


/*
 * text.c
 */
VOID d_gtext PROTO((NOTHING));           /* VDI #8    */
VOID text_init PROTO((NOTHING));
VOID dst_height PROTO((NOTHING));        /* VDI #12   */
VOID dst_point PROTO((NOTHING));         /* VDI #107  */
VOID vst_effects PROTO((NOTHING));       /* VDI #106  */
VOID dst_rotation PROTO((NOTHING));      /* VDI #13   */
VOID dst_font PROTO((NOTHING));          /* VDI #21   */
VOID dst_color PROTO((NOTHING));         /* VDI #22   */
VOID dqt_attributes PROTO((NOTHING));    /* VDI #38   */
VOID dst_alignment PROTO((NOTHING));     /* VDI #39   */
VOID dqt_extent PROTO((NOTHING));        /* VDI #116  */
VOID dqt_width PROTO((NOTHING));         /* VDI #117  */
VOID dqt_name PROTO((NOTHING));          /* VDI #130  */
VOID dqt_fontinfo PROTO((NOTHING));      /* VDI #131  */
VOID d_justified PROTO((NOTHING));
VOID dt_loadfont PROTO((NOTHING));       /* VDI #119  */
VOID dt_unloadfont PROTO((NOTHING));     /* VDI #120  */


/*
 * trucolor.c
 */
VOID vs_32_color PROTO((NOTHING));
VOID vq_32_color PROTO((NOTHING));
VOID vs_16_color PROTO((NOTHING));
VOID vq_16_color PROTO((NOTHING));


/*
 * ttcolor.c
 */
VOID tt_vs_color PROTO((NOTHING));
VOID tt_vq_color PROTO((NOTHING));


/*
 * spcolor.c
 */
VOID sp_vs_color PROTO((NOTHING));
VOID sp_vq_color PROTO((NOTHING));


/*
 * 
 */
int16_t MONO8XHT PROTO((NOTHING));


/*
 * xfrmform.S
 */
VOID TRAN_FM PROTO((NOTHING));
