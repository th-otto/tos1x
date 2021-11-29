#ifndef __LINEA_H__
#define __LINEA_H__

                 /*   (lineavars-$38e)    reserved long */
#define CUR_FONT      (lineavars-$38a)	/* long */
                 /*   (lineavars-$386)    23 reserved words */
#define M_POS_HX      (lineavars-$358)	/* word */
#define M_POS_HY      (lineavars-$356)	/* word */
#define M_PLANES      (lineavars-$354)	/* word */
#define M_CDB_BG      (lineavars-$352)	/* word */
#define M_CDB_FG      (lineavars-$350)	/* word */
#define MASK_FORM     (lineavars-$34e)	/* 32 words */
#define INQ_TAB       (lineavars-$30e)	/* 45 words */
#define DEV_TAB       (lineavars-$2b4)	/* 45 words */
#define GCURX         (lineavars-$25a)	/* word */
#define GCURY         (lineavars-$258)	/* word */
#define M_HID_CNT     (lineavars-$256)	/* word */
#define MOUSE_BT      (lineavars-$254)	/* word */
#define REQ_COL       (lineavars-$252)	/* 16 * 3 words */
#define SIZ_TAB       (lineavars-$1F2)	/* 15 words */
#define TERM_CH       (lineavars-$1d4)	/* word */
#define CHC_MOD       (lineavars-$1d2)	/* word */
#define CUR_WORK      (lineavars-$1d0)	/* long */
#define DEF_FONT      (lineavars-$1cc)	/* long */
#define FONT_RING     (lineavars-$1c8)	/* 4 longs */
#define FONT_COUNT    (lineavars-$1b8)	/* word */
#define LINE_CW       (lineavars-$1b6)	/* word */
#define LOC_MODE      (lineavars-$1b4)	/* word */
#define NUM_QC_LIN    (lineavars-$1b2)	/* word */
#define TRAP14SAV     (lineavars-$1b0)	/* long */
#define COL_OR_MASK   (lineavars-$1ac)	/* long */
#define COL_AND_MASK  (lineavars-$1a8)	/* long */
#define TRAP14BSAV    (lineavars-$1a4)	/* long */
                 /*   (lineavars-$1a0)    32 reserved words */
#define STR_MODE      (lineavars-$160)	/* word */
#define VAL_MODE      (lineavars-$15e)	/* word */
#define CUR_MS_STAT   (lineavars-$15c)	/* byte */
#define V_HID_CNT     (lineavars-$15a)	/* word */
#define CUR_X         (lineavars-$158)	/* word */
#define CUR_Y         (lineavars-$156)	/* word */
#define CUR_FLAG      (lineavars-$154)	/* byte */
#define MOUSE_FLAG    (lineavars-$153)	/* byte */
#define RETSAV        (lineavars-$152)	/* long */
#define SAV_CUR_X     (lineavars-$14e)	/* word */
#define SAV_CUR_Y     (lineavars-$14c)	/* word */
#define SAVE_LEN      (lineavars-$14a)	/* word */
#define SAVE_ADDR     (lineavars-$148)	/* long */
#define SAVE_STAT     (lineavars-$144)	/* word */
#define SAVE_AREA     (lineavars-$142)	/* 64 longs */
#define USER_TIM      (lineavars-$042)	/* long */
#define NEXT_TIM      (lineavars-$03e)	/* long */
#define USER_BUT      (lineavars-$03a)	/* long */
#define USER_CUR      (lineavars-$036)	/* long */
#define USER_MOT      (lineavars-$032)	/* long */
#define V_CEL_HT      (lineavars-$02e)	/* word */
#define V_CEL_MX      (lineavars-$02c)	/* word */
#define V_CEL_MY      (lineavars-$02a)	/* word */
#define V_CEL_WR      (lineavars-$028)	/* word */
#define V_COL_BG      (lineavars-$026)	/* word */
#define V_COL_FG      (lineavars-$024)	/* word */
#define V_CUR_AD      (lineavars-$022)	/* long */
#define V_CUR_OF      (lineavars-$01e)	/* word */
#define V_CUR_XY      (lineavars-$01c)	/* 2 words X,Y */
#define V_PERIOD      (lineavars-$018)	/* byte */
#define V_CUR_CT      (lineavars-$017)	/* byte */
#define V_FNT_AD      (lineavars-$016)	/* long */
#define V_FNT_ND      (lineavars-$012)	/* word */
#define V_FNT_ST      (lineavars-$010)	/* word */
#define V_FNT_WD      (lineavars-$00e)	/* word */
#define V_REZ_HZ      (lineavars-$00c)	/* word */
#define V_OFF_AD      (lineavars-$00a)	/* long */
#define V_STAT_0      (lineavars-$006)	/* byte */
#define V_DELAY       (lineavars-$005)	/* byte */
#define V_REZ_VT      (lineavars-$004)	/* word */
#define V_BYTES_LIN   (lineavars-$002)	/* word */

/* 404: $3e86 */
/* 306: $3a1a */
/* 206: $2904 */
/* 104: $2adc */
#define LA_PLANES     (lineavars+$000)	/* word */
#define LA_LIN_WR     (lineavars+$002)	/* word */
#define LA_CONTROL    (lineavars+$004)	/* long */
#define LA_INTIN      (lineavars+$008)	/* long */
#define LA_PTSIN      (lineavars+$00c)	/* long */
#define LA_INTOUT     (lineavars+$010)	/* long */
#define LA_PTSOUT     (lineavars+$014)	/* long */
#define LA_FG_BP_1    (lineavars+$018)	/* word */
#define LA_FG_BP_2    (lineavars+$01a)	/* word */
#define LA_FG_BP_3    (lineavars+$01c)	/* word */
#define LA_FG_BP_4    (lineavars+$01e)	/* word */
#define LA_LSTLIN     (lineavars+$020)	/* word */
#define LA_LN_MASK    (lineavars+$022)	/* word */
#define LA_WRT_MODE   (lineavars+$024)	/* word */
#define LA_X1         (lineavars+$026)	/* word */
#define LA_Y1         (lineavars+$028)	/* word */
#define LA_X2         (lineavars+$02a)	/* word */
#define LA_Y2         (lineavars+$02c)	/* word */
#define LA_PATPTR     (lineavars+$02e)	/* long */
#define LA_PATMSK     (lineavars+$032)	/* word */
#define LA_MULTIFILL  (lineavars+$034)	/* word */
#define LA_CLIP       (lineavars+$036)	/* word */
#define LA_XMN_CLIP   (lineavars+$038)	/* word */
#define LA_YMN_CLIP   (lineavars+$03a)	/* word */
#define LA_XMX_CLIP   (lineavars+$03c)	/* word */
#define LA_YMX_CLIP   (lineavars+$03e)	/* word */
#define LA_XACC_DDA   (lineavars+$040)	/* word */
#define LA_DDA_INC    (lineavars+$042)	/* word */
#define LA_T_SCLSTS   (lineavars+$044)	/* word */
#define LA_MONO_STAT  (lineavars+$046)	/* word */
#define LA_SOURCEX    (lineavars+$048)	/* word */
#define LA_SOURCEY    (lineavars+$04a)	/* word */
#define LA_DESTX      (lineavars+$04c)	/* word */
#define LA_DESTY      (lineavars+$04e)	/* word */
#define LA_DELX       (lineavars+$050)	/* word */
#define LA_DELY       (lineavars+$052)	/* word */
#define LA_FBASE      (lineavars+$054)	/* long */
#define LA_FWIDTH     (lineavars+$058)	/* word */
#define LA_STYLE      (lineavars+$05a)	/* word */
#define LA_LITEMASK   (lineavars+$05c)	/* word */
#define LA_SKEWMASK   (lineavars+$05e)	/* word */
#define LA_WEIGHT     (lineavars+$060)	/* word */
#define LA_R_OFF      (lineavars+$062)	/* word */
#define LA_L_OFF      (lineavars+$064)	/* word */
#define LA_DOUBLE     (lineavars+$066)	/* word */
#define LA_CHUP       (lineavars+$068)	/* word */
#define LA_TEXT_FG    (lineavars+$06a)	/* word */
#define LA_SCRTCHP    (lineavars+$06c)	/* long */
#define LA_SCRPT2     (lineavars+$070)	/* word */
#define LA_TEXT_BG    (lineavars+$072)	/* word */
#define LA_COPYTRAN   (lineavars+$074)	/* word */
#define LA_FILL_ABORT (lineavars+$076)	/* long */

/*
 * variables below were never documented, and
 * may differ depending on TOS version used.
 * The layout is below is maybe valid for MULTITOS only.
 */
#define LA_USERDEVINIT (lineavars+$07a)	/* long */
#define LA_USERESCINIT (lineavars+$07e)	/* long */
#define LA_RSRD2       (lineavars+$082)	/* 8 longs */
#define LA_ROUTINES    (lineavars+$0a2)	/* long */
#define LA_CURDEV      (lineavars+$0a6)	/* long */
#define LA_BLTMODE     (lineavars+$0aa)	/* word */
#define LA_RSRD3       (lineavars+$0ac)	/* word */
/* TOS 4.04 only: */
#define LA_REGQXCOL    (lineavars+$0ae)	/* 24$3 words */
#define LA_SVBLKPTR    (lineavars+$64e)	/* long */
#define LA_FG_B_PLANES (lineavars+$652)	/* long */
#define LA_FG_BP_5     (lineavars+$656)	/* word */
#define LA_FG_BP_6     (lineavars+$658)	/* word */
#define LA_FG_BP_7     (lineavars+$65a)	/* word */
#define LA_FG_BP_8     (lineavars+$65c)	/* word */
#define LA_SAVLEN      (lineavars+$65e)	/* word */
#define LA_SAVADDR     (lineavars+$660)	/* long */
#define LA_SAVSTAT     (lineavars+$664)	/* word */
#define LA_SAVAREA     (lineavars+$666)	/* 256 longs */
#define LA_QCIRCLE     (lineavars+$a66)	/* 80 words */
#define LA_BYTPERPIX   (lineavars+$b06)	/* word */
#define LA_FORMID      (lineavars+$b08)	/* word */
#define LA_VLCOLBG     (lineavars+$b0a)	/* long */
#define LA_VLCOLFG     (lineavars+$b0e)	/* long */
#define LA_PALMAP      (lineavars+$b12)	/* 256 longs */
#define LA_PRIMITIVES  (lineavars+$f12)	/* 40 longs */

#define LA_END         (lineavars+$fb2)

#define SIZEOF_FONT_HDR 90

#endif /* __LINEA_H__ */
