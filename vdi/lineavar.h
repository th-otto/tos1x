/*
 ******************************  lineavar.h  **********************************
 * 
 * ============================================================================
 * $Author: lozben $	$Date: 91/09/10 19:55:56 $
 * ============================================================================
 *
 * Revision 3.2  91/09/10  19:55:56  lozben
 * Added "int16_t qCircle[80]" to the linea structure.
 * 
 * Revision 3.1  91/07/29  16:52:14  lozben
 * Definition of the line1010 variable structure.
 * 
 ******************************************************************************
 */

#ifndef _LINEAVAR_H_
#define _LINEAVAR_H_

/*
 * we should be able to do a
 *    #define LV(v) vdivars.v
 * however this sometimes produces strange code, ie. for reqCol
 * generates code like
 *   ... (calculate offset)
 *   move.l offset,r
 *   add.l  #lineavars,r
 *   add.l  offsetof(linevars.reqCol),r
 * instead of
 *   ... (calculate offset)
 *   move.l offset,r
 *   add.l  #lineavars+offsetof(linevars.reqCol),r
 * Similar, simple variables used in comparisons are sometimes
 * fetched in the opposite order (the function harder() in
 * the code generators canon.c is reponsible for this).
 * so in order to produce the same code as found in the ROM
 * we have no choice but declare all the members of the LINEA
 * structure as separate variables.
 * Note that without this workaround the compiler does not produce
 * wrong code, its just not identical.
 */

#if LINEA_HACK
#define LAEXT extern
#else
#define LAEXT
typedef struct vdiVars {
#endif
	LAEXT int16_t        angle;
	LAEXT int16_t        beg_ang;
	LAEXT const FONT_HEAD   *CUR_FONT;           /* pointer to current font              */
	LAEXT int16_t        del_ang;
	LAEXT int16_t        deltay;
	LAEXT int16_t        deltay1;
	LAEXT int16_t        deltay2;
	LAEXT int16_t        end_ang;
	LAEXT int16_t        fil_intersect;
	LAEXT int16_t        fill_maxy;
	LAEXT int16_t        fill_miny;
	LAEXT int16_t        n_steps;
	LAEXT int16_t        odeltay;
	LAEXT int16_t        s_begsty;
	LAEXT int16_t        s_endsty;
	LAEXT int16_t        s_fil_col;
	LAEXT int16_t        s_fill_per;
	LAEXT int16_t        s_patmsk;
	LAEXT const int16_t *s_patptr;
	LAEXT int16_t        start;
	LAEXT int16_t        xc;
	LAEXT int16_t        xrad;
	LAEXT int16_t        _Y;
	LAEXT int16_t        yc;
	LAEXT int16_t        yrad;

	LAEXT int16_t        m_poshx;	         /* Mouse hot spot - x coord             */
	LAEXT int16_t        m_poshy;	         /* Mouse hot spot - y coord             */
	LAEXT int16_t        m_planes;           /* Ms planes (reserved, but we used it) */
	LAEXT int16_t        m_cdb_bg;           /* Mouse background color as pel value  */
	LAEXT int16_t        m_cdb_fg;           /* Mouse foreground color as pel value  */
	LAEXT int16_t        mask_form[32];      /* Storage for ms cursor mask and form  */

	LAEXT int16_t        INQ_TAB[45];        /* info returned by vq_extnd VDI call   */
	LAEXT int16_t        DEV_TAB[45];        /* info returned by v_opnwk VDI call    */

	LAEXT int16_t        GCURX;              /* current mouse cursor X position      */
	LAEXT int16_t        GCURY;              /* current mouse cursor Y position      */

	LAEXT int16_t        HIDE_CNT;           /* depth at which the ms is hidden      */
	LAEXT int16_t        MOUSE_BT;           /* current mouse button status          */
	LAEXT int16_t        REQ_COL[16][3];     /* internal data for vq_color           */
	LAEXT int16_t        SIZ_TAB[15];        /* size in device coordinates           */
	LAEXT int16_t        TERM_CH;            /* 16 bit character info                */
	LAEXT int16_t        chc_mode;           /* the mode of the Choice device        */
	LAEXT ATTRIBUTE     *cur_work;           /* pointer to current works attributes  */
	LAEXT const FONT_HEAD   *def_font;       /* pointer to default font head         */
	LAEXT const FONT_HEAD   *font_ring[4];   /* ptrs to link list of fnt hdrs        */
	LAEXT int16_t        ini_font_count;     /* # of fonts in the FONT_RING lists    */
	LAEXT int16_t        line_cw;            /* current line width                   */
	LAEXT int16_t        loc_mode;           /* the mode of the Locator device       */
	LAEXT int16_t        num_qc_lines;       /* # of line in the quarter circle      */

#if (TOSVERSION >= 0x300) & PLANES8
	LAEXT int32_t        trap14sav;	         /* space to save the return address     */
	LAEXT int32_t        col_or_mask;        /* some modes this is ored in VS_COLOR  */
	LAEXT int32_t        col_and_mask;       /* some modes this is anded in VS_COLOR */
	LAEXT int32_t	     trapb14sav;	     /* space to sav ret adr (for reentrency)*/
	LAEXT int16_t	     resrvd0[32];	     /* reserved				    */
#else
	LAEXT int16_t	q_circle[40];	         /* space to build circle coordinates    */
#endif

	LAEXT int16_t        str_mode;           /* the mode of the String device        */
	LAEXT int16_t        val_mode;           /* the mode of the Valuator device      */
	LAEXT char           cur_ms_stat;        /* Current mouse status                 */
	LAEXT char           resrvd1;            /* reserved                             */
	LAEXT int16_t        disab_cnt;          /* hide depth of alpha cursor           */


	/*
	 * the next 5 bytes are used as a communication
	 * block to the vblank cursor draw routine.
	 * They must be contiguous!!!!!!
	 */
	LAEXT int16_t        xydraw[2];          /* x,y communication block.             */
	LAEXT char           draw_flag;          /* Non-zero means draw ms frm on vblank */

	LAEXT char           mouse_flag;         /* Non-zero if mouse ints disabled      */

	LAEXT int32_t        retsav;             /* space to save return address         */
	LAEXT int16_t        sav_cxy[2];         /* save area for cursor cell coords.    */

	LAEXT int16_t        save_len;           /* height of saved form                 */
	LAEXT int16_t        *save_addr;         /* screen addr of 1st word of plane 0   */
	LAEXT int16_t        save_stat;          /* cursor save status                   */
	LAEXT int32_t        save_area[64];      /* save up to 4 planes. 16 longs/plane  */

	LAEXT int16_t        (*tim_addr) PROTO((NOTHING));       /* ptr to user installed routine        */
	LAEXT int16_t        (*tim_chain) PROTO((NOTHING));      /* jmps here when done with above       */

	LAEXT int16_t        (*user_but) PROTO((NOTHING));       /* user button vector                   */
	LAEXT int16_t        (*user_cur) PROTO((NOTHING));       /* user cursor vector                   */
	LAEXT int16_t        (*user_mot) PROTO((NOTHING));       /* user motion vector                   */

	LAEXT int16_t        v_cel_ht;	         /* height of character cell             */
	LAEXT int16_t        v_celmx;	         /* maximum horizontal cell index        */
	LAEXT int16_t        v_celmy;            /* maximum vertical cell index          */
	LAEXT int16_t        v_cel_wr;           /* screen width (bytes) * cel_ht        */
	LAEXT int16_t        v_col_bg;           /* character cell text background color */
	LAEXT int16_t        v_col_fg;           /* character cell text foreground color */
	LAEXT int16_t        *v_cur_ad;          /* cursor address                       */
	LAEXT int16_t        v_cur_off;          /* byte offset to cursor from screen base  */
	LAEXT int16_t        v_curcx;            /* cursor cell X position               */
	LAEXT int16_t        v_curcy;            /* cursor cell Y position               */
	LAEXT char           vct_init;           /* v_cur_tim reload value.              */
	LAEXT char           v_cur_tim;          /* cursor blink rate (# of vblanks)     */
	LAEXT int16_t        *v_fnt_ad;          /* address of monospaced font data      */
	LAEXT int16_t        v_fnt_nd;           /* last ASCII code in font              */
	LAEXT int16_t        v_fnt_st;           /* first ASCII code in font             */
	LAEXT int16_t        v_fnt_wr;           /* width of font form in bytes          */
	LAEXT int16_t        v_hz_rez;           /* horizontal pixel resolution          */
	LAEXT const int16_t  *v_off_ad;          /* address of font offset table         */

/*
 *              bit 0	cursor flash		0:disabled  1:enabled
 *		bit 1	flash state		0:off       1:on
 *  not used    bit 2   cursor visibility       0:invisible 1:visible
 *		bit 3	end of line		0:overwrite 1:wrap
 *		bit 4	reverse video		0:on        1:off
 *		bit 5	cursor position	saved	0:false	    1:true
 *  not used	bit 6	critical section	0:false	    1:true
 */
	LAEXT char           v_stat_0;           /* cursor display mode (look above)     */

	LAEXT char           v_delay;            /* cursor redisplay period              */
	LAEXT int16_t        v_vt_rez;           /* vertical resolution of the screen    */
	LAEXT int16_t        bytes_lin;	         /* copy of v_lin_wr for concat          */

/*
 * the lineavars point here:
 * 404: 3e86
 * 306: 3a1a
 * 206: 2904
 * 104: 2adc
 */
	LAEXT int16_t        v_planes;	         /* number of video planes               */
	LAEXT int16_t        v_lin_wr;	         /* number of bytes/video line           */

	LAEXT int16_t        *CONTRL;            /* ptr to the CONTRL array              */
	LAEXT int16_t        *INTIN;             /* ptr to the INTIN array               */
	LAEXT int16_t        *PTSIN;             /* ptr to the PTSIN array               */
	LAEXT int16_t        *INTOUT;            /* ptr to the INTOUT array              */
	LAEXT int16_t        *PTSOUT;            /* ptr to the PTSOUT array              */

    /*
     * The following 4 variables are accessed by the line-drawing
     * routines as an array (to allow post-increment addressing).
     * THEY MUST BE CONTIGUOUS !!
     */
	LAEXT int16_t        FG_BP_1;            /* foreground bit plane #1 value        */
	LAEXT int16_t        FG_BP_2;            /* foreground bit plane #2 value        */
	LAEXT int16_t        FG_BP_3;            /* foreground bit plane #3 value        */
	LAEXT int16_t        FG_BP_4;            /* foreground bit plane #4 value        */

	LAEXT int16_t        LSTLIN;             /* 0 => not last line of polyline       */
	LAEXT int16_t        LN_MASK;            /* line style mask.                     */
	LAEXT int16_t        WRT_MODE;	         /* writing mode.                        */


	LAEXT int16_t        X1;                 /* X1 coordinate                        */
	LAEXT int16_t        Y1;                 /* Y1 coordinate                        */
	LAEXT int16_t        X2;                 /* X2 coordinate                        */
	LAEXT int16_t        Y2;                 /* Y2 coordinate                        */

	LAEXT const int16_t  *patptr;            /* ptr to pattern.                      */
	LAEXT int16_t        patmsk;             /* pattern index. (mask)                */
	LAEXT int16_t        multifill;          /* multiplane fill flag. (0 => 1 plane) */

	LAEXT int16_t        CLIP;               /* clipping flag.                       */
	LAEXT int16_t        XMN_CLIP;           /* x minimum clipping value.            */
	LAEXT int16_t        YMN_CLIP;           /* y minimum clipping value.            */
	LAEXT int16_t        XMX_CLIP;           /* x maximum clipping value.            */
	LAEXT int16_t        YMX_CLIP;           /* y maximum clipping value.            */

	LAEXT int16_t        XACC_DDA;           /* accumulator for x DDA                */
	LAEXT int16_t        DDA_INC;            /* the fraction to be added to the DDA  */
	LAEXT int16_t        T_SCLSTS;           /* scale up or down flag.               */
	LAEXT int16_t        MONO_STATUS;        /* non-zero - cur font is monospaced    */
	LAEXT int16_t        SOURCEX;            /* X coord of character in font         */
	LAEXT int16_t        SOURCEY;            /* Y coord of character in font         */
	LAEXT int16_t        DESTX;              /* X coord of character on screen       */
	LAEXT int16_t        DESTY;              /* Y coord of character on screen       */
	LAEXT int16_t        DELX;               /* width of character                   */
	LAEXT int16_t        DELY;               /* height of character                  */
	LAEXT const uint16_t *FBASE;             /* pointer to font data                 */
	LAEXT int16_t        FWIDTH;             /* offset,segment and form with of font */
	LAEXT int16_t        STYLE;              /* special effects                      */
	LAEXT int16_t        LITEMASK;           /* special effects                      */
	LAEXT int16_t        SKEWMASK;           /* special effects                      */
	LAEXT int16_t        WEIGHT;             /* special effects                      */
	LAEXT int16_t        R_OFF;	             /* Skew offset above baseline           */
	LAEXT int16_t        L_OFF;	             /* Skew offset below baseline           */
	LAEXT int16_t        SCALE;              /* replicate pixels                     */
	LAEXT int16_t        CHUP;               /* character rotation vector            */
	LAEXT int16_t        TEXT_FG;            /* text foreground color                */
	LAEXT int16_t        *scrtchp;           /* pointer to base of scratch buffer    */
	LAEXT int16_t        scrpt2;             /* large buffer base offset             */
	LAEXT int16_t        TEXT_BG;            /* text background color                */
	LAEXT int16_t        COPYTRAN;           /* cp rstr frm type flag (opaque/trans) */
	LAEXT int16_t        (*quitfill) PROTO((NOTHING));      /* ptr to routine for quitting seedfill */
	LAEXT int16_t	(*USERDEVINIT) PROTO((NOTHING));          /* ptr to user routine before dev_init  */
	LAEXT int16_t	(*USERESCINIT) PROTO((NOTHING));          /* ptr to user routine before esc_init  */
	LAEXT int32_t	resrvd2[8];		         /* reserved				    */

#if TOSVERSION >= 0x400
	LAEXT VOID (**LA_ROUTINES) PROTO((NOTHING));     /* ptr to primitives vector list	    */
	LAEXT const SCREENDEF   *LA_CURDEV;	     /* ptr to a current device structure    */
#else
	LAEXT VOID (**LA_ROUTINES) PROTO((NOTHING)); /* hardware assisted drawing primitives  */
	LAEXT VOID (**LA_SOFTROUTINES) PROTO((NOTHING)); /* drawing primitives done in software   */
#endif
	LAEXT int16_t        BLT_MODE;           /* 0: soft BiT BLiT 1: hard BiT BLiT    */

#if PLANES8

    /*
     * Stuff for 8 plane VDI
     */
	LAEXT int16_t        LA_F32;             /* reserved; if set, TOS 3.0x uses 16x32 as system font in TT-High */

	LAEXT int16_t        REQ_X_COL[240][3];  /* extended request color array         */

	LAEXT int16_t        *sv_blk_ptr;        /* points to the proper save block      */
	LAEXT int32_t        FG_B_PLANES;        /* fg bit plns flags (bit 0 is plane 0) */

    /*
     * The following 4 variables are accessed by the line-drawing routines
     * as an array (to allow post-increment addressing).
     * THEY MUST BE CONTIGUOUS !!
     */
	LAEXT int16_t        FG_BP_5;            /* foreground bitPlane #5 value.        */
	LAEXT int16_t        FG_BP_6;            /* foreground bitPlane #6 value.        */
	LAEXT int16_t        FG_BP_7;            /* foreground bitPlane #7 value.        */
	LAEXT int16_t        FG_BP_8;            /* foreground bitPlane #8 value.        */

    /*
     * we don't get rid of the old area for compatibility reasons
     */
	LAEXT int16_t        sav8_len;           /* height of saved form                 */
	LAEXT int16_t        *sav8_addr;         /* screen addr of 1st word of plane 0   */
	LAEXT int16_t        sav8_stat;          /* cursor save status                   */
#if VIDEL_SUPPORT
	LAEXT int32_t        sav8_area[256];     /* save up to 8 planes. 16 longs/plane  */
#else
	LAEXT int16_t        sav8_area[256];     /* save up to 8 planes. 16 words/plane  */
#endif
	LAEXT int16_t	q_circle[80];	         /* space to build circle coordinates    */

/*============================== NEW STUFF =================================*/

#if VIDEL_SUPPORT
	LAEXT int16_t	byt_per_pix;	           /* number of bytes per pixel (0 if < 1) */
	LAEXT int16_t	form_id;		           /* scrn form 2 ST, 1 stndrd, 3 pix      */
	LAEXT int32_t	vl_col_bg;	               /* escape background color (long value) */
	LAEXT int32_t	vl_col_fg;	               /* escape foreground color (long value) */
	LAEXT int32_t	pal_map[256];	           /* either a mapping of reg's or true val */
	LAEXT int16_t	(*V_PRIMITIVES[40]) PROTO((NOTHING));	   /* space to copy vectors into	    */
#endif

#endif /* PLANES8 */

#if !LINEA_HACK
} VDIVARS;
#endif

#undef LAEXT


#if TOSVERSION >= 0x400

/* line_a variable structure */
/*
 * That does not make much sense.
 * la is an initialized variable, thus part of the data segment
 * and thus in ROM and can never be changed.
 * These indirect accesses just produce quite some more code
 * and take extra time.
 */
extern VDIVARS *la;

#define LV(v) la->v

#else

#if LINEA_HACK

#define LV(v) v

#else

/* line_a variable structure */
extern VDIVARS vdivars;

#define LV(v) vdivars.v

#endif

#endif

#define NPTSIN  LV(CONTRL)[1]
#define NPTSOUT LV(CONTRL)[2]
#define NINTIN  LV(CONTRL)[3]
#define NINTOUT LV(CONTRL)[4]

#endif /* _LINEAVAR_H_ */
