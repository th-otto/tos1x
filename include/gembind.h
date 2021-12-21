#ifndef __COMPILER_H__
#include <compiler.h>
#endif

extern short gl_apid;
extern short _app;

extern short global[];


short appl_exit PROTO((NOTHING));
short appl_find PROTO((const char *pname));
short appl_init PROTO((NOTHING));
short appl_read PROTO((short rwid, short length, VOIDPTR pbuff));
short appl_tplay PROTO((VOIDPTR tbuffer, short tlength, short tscale));
short appl_trecord PROTO((VOIDPTR tbuffer, short tlength));
short appl_write PROTO((short rwid, short length, const VOIDPTR pbuff));
short appl_getinfo PROTO((short type, short *out1, short *out2, short *out3, short *out4));

short evnt_button PROTO((short clicks, short mask, short state, short *pmx, short *pmy, short *pmb, short *pks));
short evnt_dclick PROTO((short rate, short setit));
short evnt_keybd PROTO((NOTHING));
short evnt_mesag PROTO((short *pbuff));
short evnt_mouse PROTO((short flags, short x, short y, short width, short height, short *pmx, short *pmy, short *pmb, short *pks));
#ifdef __ALCYON__ /* macro argument too long.. sigh */
short evnt_multi ();
#else
short evnt_multi PROTO((short flags, short bclk, short bmsk, short bst,
	short m1flags, short m1x, short m1y, short m1w, short m1h,
	short m2flags, short m2x, short m2y, short m2w, short m2h,
	short *mepbuff,
	short tlc, short thc,
	short *pmx, short *pmy, short *pmb, short *pks, short *pkr, short *pbr));
#endif
short evnt_timer PROTO((short locnt, short hicnt));

short form_alert PROTO((short defbut, const char *astring));
short form_center PROTO((OBJECT *tree, short *pcx, short *pcy, short *pcw, short *pch));
short form_dial PROTO((short dtype, short ix, short iy, short iw, short ih, short x, short y, short w, short h));
short form_do PROTO((OBJECT *form, short start));
short form_error PROTO((short errnum));
short form_keybd PROTO((OBJECT *tree, short obj, short next, short kchar, short *nxtobj, short *nxtchar));
short form_button PROTO((OBJECT *tree, short obj, short clicks, short *nxtobj));
short form_popup PROTO((OBJECT *tree, short x, short y));

short fsel_input PROTO((char *pipath, char *pisel, short *pbutton));
short fsel_exinput PROTO((char *pipath, char *pisel, short *pbutton, const char *label));

short graf_dragbox PROTO((short w, short h, short sx, short sy, short xc, short yc, short wc, short hc, short *pdx, short *pdy));
short graf_growbox PROTO((short orgx, short orgy, short orgw, short orgh, short x, short y, short w, short h));
short graf_handle PROTO((short *pwchar, short *phchar, short *pwbox, short *phbox));
short graf_mbox PROTO((short w, short h, short srcx, short srcy, short dstx, short dsty));
short graf_mkstate PROTO((short *pmx, short *pmy, short *pmstate, short *pkstate));
short graf_mouse PROTO((short m_number, const MFORM *m_addr));
short graf_rubbox PROTO((short xorigin, short yorigin, short wmin, short hmin, short *pwend, short *phend));
short graf_shrinkbox PROTO((short orgx, short orgy, short orgw, short orgh, short x, short y, short w, short h));
short graf_slidebox PROTO((OBJECT *tree, short parent, short obj, short isvert));
short graf_watchbox PROTO((OBJECT *tree, short obj, short instate, short outstate));

short menu_bar PROTO((OBJECT *tree, short showit));
short menu_icheck PROTO((OBJECT *tree, short itemnum, short checkit));
short menu_ienable PROTO((OBJECT *tree, short itemnum, short enableit));
short menu_register PROTO((short pid, const char *pstr));
short menu_text PROTO((OBJECT *tree, short inum, const char *ptext));
short menu_tnormal PROTO((OBJECT *tree, short titlenum, short normalit));
short menu_popup PROTO((MENU *menu, short xpos, short ypos, MENU *mdata));
short menu_attach PROTO((short flag, OBJECT *tree, short item, MENU *menu));
short menu_istart PROTO((short flag, OBJECT *tree, short menu, short item));
short menu_settings PROTO((short flag, MN_SET * values));

short objc_add PROTO((OBJECT *tree, short parent, short child));
short objc_change PROTO((OBJECT *tree, short drawob, short depth, short xc, short yc, short wc, short hc, short newstate, short redraw));
short objc_delete PROTO((OBJECT *tree, short delob));
short objc_draw PROTO((OBJECT *tree, short drawob, short depth, short xc, short yc, short wc, short hc));
short objc_edit PROTO((OBJECT *tree, short obj, short inchar, short *idx, short kind));
short objc_find PROTO((OBJECT *tree, short startob, short depth, short mx, short my));
short objc_offset PROTO((OBJECT *tree, short obj, short *poffx, short *poffy));
short objc_order PROTO((OBJECT *tree, short mov_obj, short newpos));
short objc_sysvar PROTO((short mode, short which, short inval1, short inval2, short *outval1, short *outval2));

short rsrc_free PROTO((NOTHING));
short rsrc_gaddr PROTO((short rstype, short rsid, VOIDPTR paddr));
short rsrc_load PROTO((const char *rsname));
short rsrc_obfix PROTO((OBJECT *tree, short obj));
short rsrc_rcfix PROTO((RSHDR *header));
short rsrc_saddr PROTO((short rstype, short rsid, VOIDPTR lngval));

short scrp_read PROTO((char *pscrap));
short scrp_write PROTO((const char *pscrap));

short shel_envrn PROTO((char **ppath, const char *psrch));
short shel_find PROTO((char *ppath));
short shel_get PROTO((char *pbuffer, short len));
short shel_put PROTO((const char *pdata, short len));
short shel_read PROTO((char *pcmd, char *ptail));
short shel_write PROTO((short doex, short isgr, short iscr, const VOIDPTR pcmd, const char *ptail));

short wind_calc PROTO((short wctype, short kind, short x, short y, short w, short h, short *px, short *py, short *pw, short *ph));
short wind_close PROTO((short handle));
short wind_create PROTO((short kind, short wx, short wy, short ww, short wh));
short wind_delete PROTO((short handle));
short wind_find PROTO((short mx, short my));
short wind_get PROTO((short w_handle, short w_field, short *pw1, short *pw2, short *pw3, short *pw4));
short wind_open PROTO((short handle, short wx, short wy, short ww, short wh));
short wind_set PROTO((short w_handle, short w_field, short w2, short w3, short w4, short w5));
#ifndef __ALCYON__
short wind_set_str PROTO((short w_handle, short w_field, const char *str));
#endif
short wind_update PROTO((short beg_update));
VOID wind_new PROTO((NOTHING));

#undef min
#undef max
short min PROTO((short a, short b));
short max PROTO((short a, short b));

short rc_equal PROTO((const GRECT *p1, const GRECT *p2));
VOID rc_copy PROTO((const GRECT *src, GRECT *dst));
short rc_intersect PROTO((const GRECT *r1, GRECT *r2));
VOID rc_union PROTO((const GRECT *r1, GRECT *r2));
short umul_div PROTO((unsigned short m1, unsigned short m2, unsigned short d1));

short appl_xgetinfo PROTO((short type, short *out1, short *out2, short *out3, short *out4));
