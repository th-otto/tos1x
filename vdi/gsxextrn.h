/*
 ********************************  gsxextrn.h  *********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/09/10 19:55:20 $
 * =============================================================================
 *
 * Revision 3.2  91/09/10  19:55:20  lozben
 * Deleted the extern definition for _q_circle.
 * 
 * Revision 3.1  91/07/29  14:38:48  lozben
 * Declared all the needed externals.
 * 
 * Revision 3.0  91/01/03  15:10:20  lozben
 * New generation VDI
 * 
 * Revision 2.3  89/06/30  17:15:46  lozben
 * Adjusted the declaration LINE_STYLE[] the name was spelled
 * different in three different files (we lucked out because
 * it wasn't the first 8 characters, which makeup the symbol name).
 * 
 * Revision 2.2  89/05/16  16:09:30  lozben
 * Added declarations for FG_B_PLANES & REQ_X_COL, deleted
 * declarations for FG_BP_[1,2,3,4].
 * 
 * Revision 2.1  89/02/21  17:23:01  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 *******************************************************************************
 */

#ifndef _GSXEXTRN_H_
#define _GSXEXTRN_H_

/* overlay variables */
extern  int16_t    seed_type;      /* indicates the type of fill               */
#if VIDEL_SUPPORT
extern  int32_t    search_color;   /* the color of the border                  */
#else
extern  int16_t    search_color;   /* the color of the border                  */
#endif
extern  int16_t    Qbottom;        /* the bottom of the Q (zero)               */
#if TOSVERSION >= 0x300
extern  int16_t    Qtop;           /* points top seed + 3                      */
extern  int16_t    *Qptr;	 	   /* points to the active point               */
#else
extern  int16_t    qPtr;	 	   /* points to the active point               */
extern  int16_t    qTmp;
extern  int16_t    qTop;           /* points top seed + 3                      */
#endif
#if TOSVERSION < 0x300
extern  int16_t    qHole;		   /* an empty space in the Q                  */
extern  int16_t    oldy;           /* the previous scan line                   */
extern  int16_t    oldxleft;       /* left end of line at oldy                 */
extern  int16_t    oldxright;      /* right end                                */
extern  int16_t    newxleft;       /* ends of line at oldy +                   */
extern  int16_t    newxright;      /* the current direction                    */
extern  int16_t    xleft;          /* temporary endpoints                      */
extern  int16_t    xright;
extern  int16_t    direction;      /* is next scan line up or down?            */
#endif
extern  int16_t    done;           /* is the seed queue full?                  */
#if TOSVERSION < 0x300
extern  int16_t    gotseed;        /* a seed was put in the Q                  */
extern  int16_t    leftoldy;       /* like _oldy. (new seedfill)               */
extern  int16_t    leftdirection;  /* like _direction. (new seedfill)          */
extern  int16_t    leftseed;       /* like _gotseed. (new seedfill)            */
#endif
extern  int16_t    h_align;
#if TOSVERSION < 0x300
extern  int16_t    leftcollision;  /* like _collision. (new seedfill)          */
#endif
extern  int16_t    v_align;        /* scaler alignments                        */
extern  int16_t    width;
#if TOSVERSION < 0x300
extern  int16_t    collision;      /* seed was removed from Q (new rtn)        */
#endif
extern  int16_t    Q[];            /* storage for the seed points (1280)       */
extern  int16_t    height;         /* extent of string set in dqt_extent       */
extern  int16_t    wordx;
extern  int16_t    wordy;          /* add this to each space for interword     */
extern  int16_t    rmword;         /* the number of pixels left over           */
extern  int16_t    rmwordx;
extern  int16_t    rmwordy;        /* add this to use up remainder             */
extern  int16_t    charx;
extern  int16_t    chary;          /* inter-character distance                 */
extern  int16_t    rmchar;         /* number of pixels left over               */
extern  int16_t    rmcharx;
extern  int16_t    rmchary;        /* add this to use up remainder             */
extern  int16_t    FLIP_Y;         /* Non-zero PTSOUT contains magnitudes      */
extern  int16_t    deftxbu[];      /* scratch buf for 8x16 (276 bytes)         */

#if TOSVERSION >= 0x400
extern const SCREENDEF *const devices[];
#endif

extern FONT_HEAD const f6x6;      /* The small system font                    */
extern FONT_HEAD const f8x16;
extern FONT_HEAD const f8x8;
#if PLANES8
extern FONT_HEAD const f16x32;
#endif
#define first f6x6


extern	FONT_HEAD ram8x16;
extern	FONT_HEAD ram8x8;
#if PLANES8
extern	FONT_HEAD ram16x32;
#endif

extern int16_t scrtsiz;
extern int16_t const ROM_DEV_TAB[];  /* initial intout array for open work       */
extern int16_t const ROM_SIZ_TAB[];  /* initial ptsout array for open work       */
extern int16_t const ROM_INQ_TAB[];  /* extended inquire values */
extern int16_t const MAP_COL[];
extern int16_t const REV_MAP_COL[];
extern int16_t const LINE_STYLE[];
extern int16_t const DITHER[];
extern int16_t const HAT_0_MSK;
extern int16_t const HAT_1_MSK;
extern int16_t const HATCH0[];
extern int16_t const HATCH1[];
extern int16_t const OEMPAT[];
extern int16_t ROM_UD_PATRN[];
extern int16_t const SOLID[];
extern int16_t const HOLLOW[];
extern int16_t const DITHRMSK;
extern int16_t const OEMMSKPAT;
extern int16_t const m_dot[];
extern int16_t const m_plus[];
extern int16_t const m_star[];
extern int16_t const m_square[];
extern int16_t const m_cross[];
extern int16_t const m_dmnd[];
extern int16_t const tplane_mask[];
extern const int16_t *const markhead[];
#if VIDEL_SUPPORT
extern int32_t const colors[];
#else
#if PLANES8
extern int16_t const colors[];
#endif
#endif

/*
 * gsxasm1.S
 */
VOID ABLINE PROTO((NOTHING));
VOID HABLINE PROTO((NOTHING));
int16_t	vec_len PROTO((int16_t, int16_t));


/*
 * gsxasm2.S
 */
int32_t	vtrap1 PROTO((int16_t, ...));
int32_t	vtrap14 PROTO((int16_t, ...));
int32_t	vtrap14b PROTO((int16_t, ...));
int16_t	end_pts PROTO((int16_t xstart, int16_t ystart, int16_t *lptr, int16_t *rptr));
VOID fill_line PROTO((int16_t, int16_t, int16_t));
#if VIDEL_SUPPORT
int32_t	get_pix PROTO((NOTHING));
#else
int16_t	get_pix PROTO((NOTHING));
#endif
VOID TRNSFONT PROTO((NOTHING));


/*
 * allgem.S
 */
VOID v_nop PROTO((NOTHING));             /* VDI #0    */
VOID v_clrwk PROTO((NOTHING));           /* VDI #3    */
VOID v_updwk PROTO((NOTHING));           /* VDI #4    */
VOID v_cellarray PROTO((NOTHING));       /* VDI #10   */
VOID vq_cellarray PROTO((NOTHING));      /* VDI #27   */
VOID INIT_G PROTO((NOTHING));
VOID DINIT_G PROTO((NOTHING));
VOID CLC_FLIT PROTO((NOTHING));
int16_t SMUL_DIV PROTO((int16_t, int16_t, int16_t));
int16_t GSHIFT_S PROTO((NOTHING));
VOID st_fl_p PROTO((NOTHING));

int16_t GCHC_KEY PROTO((NOTHING));
VOID HIDE_CU PROTO((NOTHING));
int16_t GLOC_KEY PROTO((NOTHING));
int16_t GCHR_KEY PROTO((NOTHING));
VOID XFM_UNDL PROTO((NOTHING));
VOID COPY_RFM PROTO((NOTHING));
VOID RECTFILL PROTO((NOTHING));
VOID esc_init PROTO((NOTHING));
VOID vex_timv PROTO((NOTHING));          /* VDI #118  */


/*
 * escape.S
 */
VOID v_escape PROTO((NOTHING));          /* VDI #5    */


/*
 * mouse.S
 */
VOID DIS_CUR PROTO((NOTHING));
VOID HIDE_CUR PROTO((NOTHING));
VOID SET_CUR PROTO((int16_t newx, int16_t newy));
VOID vq_mouse PROTO((NOTHING));          /* VDI #124  */
VOID vsc_form PROTO((NOTHING));          /* VDI #111  */
VOID vex_butv PROTO((NOTHING));          /* VDI #125  */
VOID vex_motv PROTO((NOTHING));          /* VDI #126  */
VOID vex_curv PROTO((NOTHING));          /* VDI #127  */


/*
 * line1010.S
 */
BOOLEAN	retfalse PROTO((NOTHING));


/*
 * pxtform.S
 */
VOID PX_AND_INT_TRAN_FM PROTO((NOTHING));


/*
 * spxtxtbl.S
 */
VOID cheat_blit PROTO((NOTHING));


/*
 * blitinit.S
 */
int16_t GETBLT PROTO((NOTHING));


/*
 * textblt.S
 */
VOID TEXT_BLT PROTO((NOTHING));
int16_t	ACT_SIZ PROTO((int16_t));
int16_t	CLC_DDA PROTO((int16_t, int16_t));


/* C Support routines */
VOID text_init PROTO((NOTHING));
int16_t screen PROTO((NOTHING));
int16_t VEC_LEN PROTO((NOTHING));


/* device specific drawing primitives */
extern VOID (*STHardList[]) PROTO((NOTHING));	    /* orig ST routines blitter		    */
extern VOID (*STSoftList[]) PROTO((NOTHING));	    /* orig ST routines no blitter	    */
#if VIDEL_SUPPORT
extern VOID (*PixHardList[]) PROTO((NOTHING));	    /* pixel packed routines		    */
extern VOID (*PixSoftList[]) PROTO((NOTHING));	    /* pixel packed routines		    */
extern VOID (*SPPixSoftList[]) PROTO((NOTHING));    /* pixel packed routines		    */
extern VOID (*SPPixHardList[]) PROTO((NOTHING));    /* SPARROW routines (hard blit)	    */
#endif

#endif
