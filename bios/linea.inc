               ds.l 1        /*   (lineavars-$38e)    reserved long */
               xdef CUR_FONT
CUR_FONT:      ds.l 1      (lineavars-$38a)	/* long */
               ds.w 23       /*   (lineavars-$386)    23 reserved words */
               xdef M_POS_HX
M_POS_HX:      ds.w 1      (lineavars-$358)	/* word */
               xdef M_POS_HY
M_POS_HY:      ds.w 1      (lineavars-$356)	/* word */
               xdef M_PLANES
M_PLANES:      ds.w 1      (lineavars-$354)	/* word */
               xdef M_CDB_BG
M_CDB_BG:      ds.w 1      (lineavars-$352)	/* word */
               xdef M_CDB_FG
M_CDB_FG:      ds.w 1      (lineavars-$350)	/* word */
               xdef MASK_FORM
MASK_FORM:     ds.w 32     (lineavars-$34e)	/* 32 words */
               xdef INQ_TAB
INQ_TAB:       ds.w 45     (lineavars-$30e)	/* 45 words */
               xdef DEV_TAB
DEV_TAB:       ds.w 45     (lineavars-$2b4)	/* 45 words */
               xdef GCURX
GCURX:         ds.w 1      (lineavars-$25a)	/* word */
               xdef GCURY
GCURY:         ds.w 1      (lineavars-$258)	/* word */
               xdef M_HID_CNT
M_HID_CNT:     ds.w 1      (lineavars-$256)	/* word */
               xdef MOUSE_BT
MOUSE_BT:      ds.w 1      (lineavars-$254)	/* word */
               xdef REQ_COL
REQ_COL:       ds.w 16*3   (lineavars-$252)	/* 16 * 3 words */
               xdef SIZ_TAB
SIZ_TAB:       ds.w 15     (lineavars-$1F2)	/* 15 words */
               xdef TERM_CH
TERM_CH:       ds.w 1      (lineavars-$1d4)	/* word */
               xdef CHC_MOD
CHC_MOD:       ds.w 1      (lineavars-$1d2)	/* word */
               xdef CUR_WORK
CUR_WORK:      ds.l 1      (lineavars-$1d0)	/* long */
               xdef DEF_FONT
DEF_FONT:      ds.l 1      (lineavars-$1cc)	/* long */
               xdef FONT_RING
FONT_RING:     ds.l 4      (lineavars-$1c8)	/* 4 longs */
               xdef FONT_COUNT
FONT_COUNT:    ds.w 1      (lineavars-$1b8)	/* word */
               xdef LINE_CW
LINE_CW:       ds.w 1      (lineavars-$1b6)	/* word */
               xdef LOC_MODE
LOC_MODE:      ds.w 1      (lineavars-$1b4)	/* word */
               xdef NUM_QC_LIN
NUM_QC_LIN:    ds.w 1      (lineavars-$1b2)	/* word */
               xdef TRAP14SAV
TRAP14SAV:     ds.l 1      (lineavars-$1b0)	/* long */
               xdef COL_OR_MASK
COL_OR_MASK:   ds.l 1      (lineavars-$1ac)	/* long */
               xdef COL_AND_MASK
COL_AND_MASK:  ds.l 1      (lineavars-$1a8)	/* long */
               xdef TRAP14BSAV
TRAP14BSAV:    ds.l 1      (lineavars-$1a4)	/* long */
               ds.w 32       /*   (lineavars-$1a2)    32 reserved words */
               xdef STR_MODE
STR_MODE:      ds.w 1      (lineavars-$160)	/* word */
               xdef VAL_MODE
VAL_MODE:      ds.w 1      (lineavars-$15e)	/* word */
               xdef CUR_MS_STAT
CUR_MS_STAT:   ds.b 1      (lineavars-$15c)	/* byte */
               ds.b 1                           /* padding */
               xdef V_HID_CNT
V_HID_CNT:     ds.w 1      (lineavars-$15a)	/* word */
               xdef CUR_X
CUR_X:         ds.w 1      (lineavars-$158)	/* word */
               xdef CUR_Y
CUR_Y:         ds.w 1      (lineavars-$156)	/* word */
               xdef CUR_FLAG
CUR_FLAG:      ds.b 1      (lineavars-$154)	/* byte */
               xdef MOUSE_FLAG
MOUSE_FLAG:    ds.b 1      (lineavars-$153)	/* byte */
               xdef RETSAV
RETSAV:        ds.l 1      (lineavars-$152)	/* long */
               xdef SAV_CURX
SAV_CURX:      ds.w 1      (lineavars-$14e)	/* word */
               xdef SAV_CURY
SAV_CURY:      ds.w 1      (lineavars-$14c)	/* word */
               xdef SAVE_LEN
SAVE_LEN:      ds.w 1      (lineavars-$14a)	/* word */
               xdef SAVE_ADDR
SAVE_ADDR:     ds.l 1      (lineavars-$148)	/* long */
               xdef SAVE_STAT
SAVE_STAT:     ds.w 1      (lineavars-$144)	/* word */
               xdef SAVE_AREA
SAVE_AREA:     ds.l 64      (lineavars-$142)	/* 64 longs */
               xdef USER_TIM
USER_TIM:      ds.l 1      (lineavars-$042)	/* long */
               xdef NEXT_TIM
NEXT_TIM:      ds.l 1      (lineavars-$03e)	/* long */
               xdef USER_BUT
USER_BUT:      ds.l 1      (lineavars-$03a)	/* long */
               xdef USER_CUR
USER_CUR:      ds.l 1      (lineavars-$036)	/* long */
               xdef USER_MOT
USER_MOT:      ds.l 1      (lineavars-$032)	/* long */
               xdef V_CEL_HT
V_CEL_HT:      ds.w 1      (lineavars-$02e)	/* word */
               xdef V_CEL_MX
V_CEL_MX:      ds.w 1      (lineavars-$02c)	/* word */
               xdef V_CEL_MY
V_CEL_MY:      ds.w 1      (lineavars-$02a)	/* word */
               xdef V_CEL_WR
V_CEL_WR:      ds.w 1      (lineavars-$028)	/* word */
               xdef V_COL_BG
V_COL_BG:      ds.w 1      (lineavars-$026)	/* word */
               xdef V_COL_FG
V_COL_FG:      ds.w 1      (lineavars-$024)	/* word */
               xdef V_CUR_AD
V_CUR_AD:      ds.l 1      (lineavars-$022)	/* long */
               xdef V_CUR_OF
V_CUR_OF:      ds.w 1      (lineavars-$01e)	/* word */
               xdef V_CUR_XY
V_CUR_XY:      ds.w 2      (lineavars-$01c)	/* 2 words X,Y */
               xdef V_PERIOD
V_PERIOD:      ds.b 1      (lineavars-$018)	/* byte */
               xdef V_CUR_CT
V_CUR_CT:      ds.b 1      (lineavars-$017)	/* byte */
               xdef V_FNT_AD
V_FNT_AD:      ds.l 1      (lineavars-$016)	/* long */
               xdef V_FNT_ND
V_FNT_ND:      ds.w 1      (lineavars-$012)	/* word */
               xdef V_FNT_ST
V_FNT_ST:      ds.w 1      (lineavars-$010)	/* word */
               xdef V_FNT_WD
V_FNT_WD:      ds.w 1      (lineavars-$00e)	/* word */
               xdef V_REZ_HZ
V_REZ_HZ:      ds.w 1      (lineavars-$00c)	/* word */
               xdef V_OFF_AD
V_OFF_AD:      ds.l 1      (lineavars-$00a)	/* long */
               xdef V_STAT_0
V_STAT_0:      ds.b 1      (lineavars-$006)	/* byte */
               xdef V_DELAY
V_DELAY:       ds.b 1      (lineavars-$005)	/* byte */
               xdef V_REZ_VT
V_REZ_VT:      ds.w 1      (lineavars-$004)	/* word */
               xdef V_BYTES_LIN
V_BYTES_LIN:   ds.w 1      (lineavars-$002)	/* word */

/* 404: $3e86 */
/* 306: $3a1a */
/* 206: $2904 */
/* 104: $2adc */
               xdef lineavars
lineavars:     ds.b 0
               xdef LA_PLANES
LA_PLANES:     ds.w 1      (lineavars+$000)	/* word */
               xdef LA_LIN_WR
LA_LIN_WR:     ds.w 1      (lineavars+$002)	/* word */
               xdef LA_CONTROL
LA_CONTROL:    ds.l 1      (lineavars+$004)	/* long */
               xdef LA_INTIN
LA_INTIN:      ds.l 1      (lineavars+$008)	/* long */
               xdef LA_PTSIN
LA_PTSIN:      ds.l 1      (lineavars+$00c)	/* long */
               xdef LA_INTOUT
LA_INTOUT:     ds.l 1      (lineavars+$010)	/* long */
               xdef LA_PTSOUT
LA_PTSOUT:     ds.l 1      (lineavars+$014)	/* long */
               xdef LA_FG_1
LA_FG_1:       ds.w 1      (lineavars+$018)	/* word */
               xdef LA_FG_2
LA_FG_2:       ds.w 1      (lineavars+$01a)	/* word */
               xdef LA_FG_3
LA_FG_3:       ds.w 1      (lineavars+$01c)	/* word */
               xdef LA_FG_4
LA_FG_4:       ds.w 1      (lineavars+$01e)	/* word */
               xdef LA_LSTLIN
LA_LSTLIN:     ds.w 1      (lineavars+$020)	/* word */
               xdef LA_LN_MASK
LA_LN_MASK:    ds.w 1      (lineavars+$022)	/* word */
               xdef LA_WRT_MODE
LA_WRT_MODE:   ds.w 1      (lineavars+$024)	/* word */
               xdef LA_X1
LA_X1:         ds.w 1      (lineavars+$026)	/* word */
               xdef LA_Y1
LA_Y1:         ds.w 1      (lineavars+$028)	/* word */
               xdef LA_X2
LA_X2:         ds.w 1      (lineavars+$02a)	/* word */
               xdef LA_Y2
LA_Y2:         ds.w 1      (lineavars+$02c)	/* word */
               xdef LA_PATPTR
LA_PATPTR:     ds.l 1      (lineavars+$02e)	/* long */
               xdef LA_PATMSK
LA_PATMSK:     ds.w 1      (lineavars+$032)	/* word */
               xdef LA_MULTIFILL
LA_MULTIFILL:  ds.w 1      (lineavars+$034)	/* word */
               xdef LA_CLIP
LA_CLIP:       ds.w 1      (lineavars+$036)	/* word */
               xdef LA_XMN_CLIP
LA_XMN_CLIP:   ds.w 1      (lineavars+$038)	/* word */
               xdef LA_YMN_CLIP
LA_YMN_CLIP:   ds.w 1      (lineavars+$03a)	/* word */
               xdef LA_XMX_CLIP
LA_XMX_CLIP:   ds.w 1      (lineavars+$03c)	/* word */
               xdef LA_YMX_CLIP
LA_YMX_CLIP:   ds.w 1      (lineavars+$03e)	/* word */
               xdef LA_XACC_DDA
LA_XACC_DDA:   ds.w 1      (lineavars+$040)	/* word */
               xdef LA_DDA_INC
LA_DDA_INC:    ds.w 1      (lineavars+$042)	/* word */
               xdef LA_T_SCLSTS
LA_T_SCLSTS:   ds.w 1      (lineavars+$044)	/* word */
               xdef LA_MONO_STAT
LA_MONO_STAT:  ds.w 1      (lineavars+$046)	/* word */
               xdef LA_SRCX
LA_SRCX:       ds.w 1      (lineavars+$048)	/* word */
               xdef LA_SRCY
LA_SRCY:       ds.w 1      (lineavars+$04a)	/* word */
               xdef LA_DESTX
LA_DESTX:      ds.w 1      (lineavars+$04c)	/* word */
               xdef LA_DESTY
LA_DESTY:      ds.w 1      (lineavars+$04e)	/* word */
               xdef LA_DELX
LA_DELX:       ds.w 1      (lineavars+$050)	/* word */
               xdef LA_DELY
LA_DELY:       ds.w 1      (lineavars+$052)	/* word */
               xdef LA_FBASE
LA_FBASE:      ds.l 1      (lineavars+$054)	/* long */
               xdef LA_FWIDTH
LA_FWIDTH:     ds.w 1      (lineavars+$058)	/* word */
               xdef LA_STYLE
LA_STYLE:      ds.w 1      (lineavars+$05a)	/* word */
               xdef LA_LITEMASK
LA_LITEMASK:   ds.w 1      (lineavars+$05c)	/* word */
               xdef LA_SKEWMASK
LA_SKEWMASK:   ds.w 1      (lineavars+$05e)	/* word */
               xdef LA_WEIGHT
LA_WEIGHT:     ds.w 1      (lineavars+$060)	/* word */
               xdef LA_R_OFF
LA_R_OFF:      ds.w 1      (lineavars+$062)	/* word */
               xdef LA_L_OFF
LA_L_OFF:      ds.w 1      (lineavars+$064)	/* word */
               xdef LA_DOUBLE
LA_DOUBLE:     ds.w 1      (lineavars+$066)	/* word */
               xdef LA_CHUP
LA_CHUP:       ds.w 1      (lineavars+$068)	/* word */
               xdef LA_TEXTFG
LA_TEXTFG:     ds.w 1      (lineavars+$06a)	/* word */
               xdef LA_SCRTCHP
LA_SCRTCHP:    ds.l 1      (lineavars+$06c)	/* long */
               xdef LA_SCRPT2
LA_SCRPT2:     ds.w 1      (lineavars+$070)	/* word */
               xdef LA_TEXTBG
LA_TEXTBG:     ds.w 1      (lineavars+$072)	/* word */
               xdef LA_COPYTRAN
LA_COPYTRAN:   ds.w 1      (lineavars+$074)	/* word */
               xdef LA_FILL_ABORT
LA_FILL_ABORT: ds.l 1      (lineavars+$076)	/* long */

/*
 * variables below were never documented, and
 * may differ depending on TOS version used.
 * The layout below is maybe valid for MULTITOS only.
 */
               xdef LA_USERDEVINIT
LA_USERDEVINIT:ds.l 1      (lineavars+$07a)	/* long */
               xdef LA_USERESCINIT
LA_USERESCINIT:ds.l 1      (lineavars+$07e)	/* long */
               xdef LA_RSRD2
LA_RSRD2:      ds.l 8      (lineavars+$082)	/* 8 longs */
               xdef LA_ROUTINES
LA_ROUTINES:   ds.l 1      (lineavars+$0a2)	/* long */
               xdef LA_CURDEV
LA_CURDEV:     ds.l 1      (lineavars+$0a6)	/* long */
               xdef LA_BLTMODE
LA_BLTMODE:    ds.w 1      (lineavars+$0aa)	/* word */
               xdef LA_RSRD3
LA_RSRD3:      ds.w 1      (lineavars+$0ac)	/* word */
#if TOSVERSION >= 0x404
/* TOS 4.04 only: */
               xdef LA_REGQXCOL
LA_REGQXCOL:   ds.w 240*3  (lineavars+$0ae)	/* 240*3 words */
               xdef LA_SVBLKPTR
LA_SVBLKPTR:   ds.l 1      (lineavars+$64e)	/* long */
               xdef LA_FG_B_PLANES
LA_FG_B_PLANES: ds.l 1     (lineavars+$652)	/* long */
               xdef LA_FG_5
LA_FG_5:       ds.w 1      (lineavars+$656)	/* word */
               xdef LA_FG_6
LA_FG_6:       ds.w 1      (lineavars+$658)	/* word */
               xdef LA_FG_7
LA_FG_7:       ds.w 1      (lineavars+$65a)	/* word */
               xdef LA_FGP_8
LA_FG_8:       ds.w 1      (lineavars+$65c)	/* word */
               xdef LA_SAVLEN
LA_SAVLEN:     ds.w 1      (lineavars+$65e)	/* word */
               xdef LA_SAVADDR
LA_SAVADDR:    ds.l 1      (lineavars+$660)	/* long */
               xdef LA_SAVSTAT
LA_SAVSTAT:    ds.w 1      (lineavars+$664)	/* word */
               xdef LA_SAVAREA
LA_SAVAREA:    ds.l 256    (lineavars+$666)	/* 256 longs */
               xdef LA_QCIRCLE
LA_QCIRCLE:    ds.w 80     (lineavars+$a66)	/* 80 words */
               xdef LA_BYTPERPIX
LA_BYTPERPIX:  ds.w 1      (lineavars+$b06)	/* word */
               xdef LA_FORMID
LA_FORMID:     ds.w 1      (lineavars+$b08)	/* word */
               xdef LA_VCOLBG
LA_VCOLBG:     ds.l 1      (lineavars+$b0a)	/* long */
               xdef LA_VCOLFG
LA_VCOLFG:     ds.l 1      (lineavars+$b0e)	/* long */
               xdef LA_PALMAP
LA_PALMAP:     ds.l 256    (lineavars+$b12)	/* 256 longs */
               xdef LA_PRIMITIVES
LA_PRIMITIVES: ds.l 40     (lineavars+$f12)	/* 40 longs */
#endif

               xdef LA_END
LA_END:        ds.b 0      (lineavars+$fb2)
