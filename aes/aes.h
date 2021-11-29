/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:29:04 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:29:04  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:02:47  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.5  89/02/16  18:01:27  kbad
 * Moved M132 define here from flavor.h
 * 
 * Revision 1.4  88/09/08  18:52:58  kbad
 * Moved build-specific stuff to flavor.h
 * 
 *
 * Revision 1.3  88/08/02  13:02:49  kbad
 * Set with parameters of 1.04d 8/1/88 build
 * add DENMARK, fix NORWAY, FINLAND
 *
 * Revision 1.2  88/07/15  16:07:50  mui
 * add flag DOWARNING to do AES startup alert box
 * 
 * Revision 1.1  88/06/02  12:35:52  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	MACHINE.H		09/29/84 - 10/09/84	Lee Lorenzen	
 *	for 68k			10/10/84 - 04/22/85	Lowell Webster	
 *	Update			05/07/85		Derek Mui	
 *	Add more define		07/12/85		Derek Mui	
 *	add MULRES		3/25/86			Derek Mui
 *	add SWISSGER & SWISSFRA defines 8/3/87		Slavik Lozben
 *	add MEXICO defines      9/28/87 		Slavik Lozben
 *	Clean up		11/23/87		Derek Mui
 * 	Added 132 column switch	12/18/87		D.Mui		
 *	add FINLAND		1/8/88			D.Mui	
 */
	

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __STDINT_H__
#include <stdint.h>
#endif

#include "config.h"
#include "aesdefs.h"

#if BINEXACT
#  ifndef __ALCYON__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif

typedef int BOOLEAN;

#ifndef FALSE
#define FALSE 0
#define TRUE  1
#endif


#ifndef UNUSED
#ifdef __ALCYON__
#  define UNUSED(x)
#else
#  define UNUSED(x) ((void)(x))
#endif
#endif

#define I8086	0	/* Intel 8086/8088 */
#define	MC68K	1	/* Motorola 68000 */

#define SINGLAPP  1
#define MULTIAPP  0

#include "struct88.h"
#include "obdefs.h"
#include "gemlib.h"


/*
 * Due to the way the linker works, if we want to create a binary exact image,
 * we have to force symbols that go into the bss section at certain addresses.
 * For this to work, some variables that should be static must be globally
 * visible.
 */
#ifndef STATIC
#if BINEXACT
#  define STATIC
#else
#  define STATIC static
#endif
#endif

/*
 * for functions that are supposed to be static,
 * but must be visible for the line-f trap table
 */
#if LINEF_HACK
#define LINEF_STATIC
#else
#define LINEF_STATIC static
#endif


/*
 * coerce short ptr to low word of long
 */
#define LW(x) ( (int32_t)((uint16_t)(x)) )

/*
 * coerce short ptr to high word of long
 */
#define HW(x) ((int32_t)((uint16_t)(x)) << 16)

/*
 * return low word of	a long value
 */
#define LLOWD(x) ((uint16_t)(x))

/*
 * return high word of a long value
 */
#define LHIWD(x) ((uint16_t)(x >> 16))

/*
 * return high byte of a word value
 * added 12/03/84
 */
#define LLOBT(x) ((char)(x))

/*
 * return 0th byte of a long value given
 * a short pointer to the long value
 * added 12/03/84
 */
#define LHIBT(x) ((char)(x >> 8))

/*
 * return a long address of a short pointer
 */
#define ADDR(x) x

/*
 * return long address of the data seg
 */
#define LLDS() ((int32_t)0)

/*
 * return long address of the code seg
 */
#define LLCS() ((int32_t)0)

/*
 * return a single byte	pointed at by long ptr
 */
#define LBGET(x) ( (char) *((const char * )(x)) )

/*
 * set a single byte pointed at by long ptr, LBSET(lp, bt)
 */
#define LBSET(x, y)  ( *((char *)(x)) = y)

/*
 * return a single word pointed at by long ptr
 */
#define LWGET(x) ( (int16_t) *((int16_t *)(x)) )

/*
 * set a single word pointed at by long ptr, LWSET(lp, bt)
 */
#define LWSET(x, y)  ( *((int16_t *)(x)) = y)

/*
 * return a single long pointed at by long ptr
 */
#define LLGET(x) ( *((int32_t *)(x)))

/*
 * set a single long pointed at by long ptr, LLSET(lp, bt)
 */
#define LLSET(x, y) ( *((int32_t *)(x)) = (intptr_t)(y))

/*
 * return 0th byte of a long value given a short pointer to the long value
 */
#define LBYTE0(x) ( *((x)+3) )

/*
 * return 1st byte of a long value given a short pointer to the long value
 */
#define LBYTE1(x) ( *((x)+2) )

/*
 * return 2nd byte of a long value given a short pointer to the long value
 */
#define LBYTE2(x) ( *((x)+1) )

/*
 * return 3rd byte of a long value given a short pointer to the long value
 */
#define LBYTE3(x) (*(x))


/*
 * Should really be OBJECT *, as it was in the original DRI version.
 * Someone messed it up and declared it as long in the Atari version.
 * Even worse, LPTREE was not even used anymore, and all source
 * files changes instead.
 */
typedef intptr_t LPTREE;


/*
 * large.s
 */

/* return length of string pointed a by long pointer */
int16_t	LSTRLEN PROTO ((const char *));
/* copy n words from src long ptr to dst long ptr */
int16_t	LWCOPY PROTO((VOIDPTR dst, const VOIDPTR src, int cnt));
/* copy n bytes from src long ptr to dst long ptr */
VOID LBCOPY PROTO((VOIDPTR dst, const VOIDPTR src, int cnt));
int16_t	LBWMOV PROTO((VOIDPTR dst, const VOIDPTR src));
int16_t	LSTCPY PROTO((char *dst, const char *src));


/*
 * dosif.S/jbind.S
 */
VOID cli PROTO((NOTHING));
VOID sti PROTO((NOTHING));
VOID takecpm PROTO((NOTHING));
VOID givecpm PROTO((NOTHING));
VOID takeerr PROTO((NOTHING));
VOID giveerr PROTO((NOTHING));
VOID deskerr PROTO((NOTHING));
VOID back PROTO((NOTHING));
VOID retake PROTO((NOTHING));
intptr_t dos_exec PROTO((const char *cmd, int16_t mode, const char *tail));


/*
 * geminit.c
 */
extern intptr_t ad_sysglo;
extern VOIDPTR ad_armice;
extern VOIDPTR ad_hgmice;
extern LPTREE ad_stdesk;
extern char *ad_fsel;
extern intptr_t drawstk;
extern int16_t er_num;						/* for output.s */
extern int16_t no_aes;						/* gembind.s    */
extern BOOLEAN autoexec;					/* autoexec a file ?    */

#if DOWARNING
extern BOOLEAN dowarn;
#endif

VOID gem_main PROTO((NOTHING));
VOID setres PROTO((NOTHING));
VOID pinit PROTO((PD *ppd, CDA *pcda));
int32_t set_cache PROTO((int32_t newcacr));
int16_t pred_dinf PROTO((NOTHING));
BOOLEAN gsx_malloc PROTO((NOTHING));
VOID set_defdrv PROTO((NOTHING));
VOID gsx_xmfset PROTO((MFORM *pmfnew));
VOID gsx_mfset PROTO((MFORM *pmfnew));
VOID gr_mouse PROTO((int16_t mkind, MFORM *grmaddr));


/*
 * optimize.S/function.c
 */
const char *scasb PROTO((const char *p, char b));
VOID r_get PROTO((const GRECT *gr, int16_t *px, int16_t *py, int16_t *pw, int16_t *ph));
VOID r_set PROTO((GRECT *gr, int16_t x, int16_t y, int16_t w, int16_t h));
VOID rc_copy PROTO((const GRECT *src, GRECT *dst));
BOOLEAN inside PROTO((int16_t x, int16_t y, const GRECT *pt));
BOOLEAN rc_equal PROTO((const GRECT *p1, const GRECT *p2));
BOOLEAN rc_intersect PROTO((const GRECT *p1, GRECT *p2));
VOID rc_union PROTO((const GRECT *p1, GRECT *p2));
VOID rc_constrain PROTO((const GRECT *pc, GRECT *pt));
VOID movs PROTO((int16_t num, const VOIDPTR ps, VOIDPTR pd));
int16_t min PROTO((int16_t a, int16_t b));
int16_t max PROTO((int16_t a, int16_t b));
VOID bfill PROTO((int16_t num, char bval, VOIDPTR addr));
#define memset(p, c, s) bfill(s, c, p)
int toupper PROTO((int ch));
size_t strlen PROTO((const char *p1));
BOOLEAN streq PROTO((const char *p1, const char *p2));
/*
 * Original AES had functions named strcpy/strcat that have their arguments
 * reversed as opposed to the standard functions with that name.
 * To avoid confusion, those functions were renamed, and we use a wrapper
 * around it instead.
 * Note however that is still not the standard behaviour: they return
 * the end of the string +1 instead of the destination.
 */
#ifndef strcpy
#define strcpy(dst, src) xstrpcpy(src, dst)
#define strcat(dst, src) xstrpcat(src, dst)
#endif
char *xstrpcpy PROTO((const char *src, char *dst));
char *xstrpcat PROTO((const char *src, char *dst));
char *strscn PROTO((const char *src, char *dst, char stp));
int16_t strchk PROTO((const char *s, const char *t));
VOID fmt_str PROTO((const char *instr, char *outstr));
VOID unfmt_str PROTO((const char *instr, char *outstr));
VOID fs_sset PROTO((LPTREE tree, int16_t obj, char *pstr, char **ptext, int16_t *ptxtlen));
VOID inf_sset PROTO((OBJECT *tree, int16_t obj, const char *pstr));
VOID fs_sget PROTO((LPTREE tree, int16_t obj, char *pstr));
VOID inf_fldset PROTO((LPTREE tree, int16_t obj, uint16_t testfld, uint16_t testbit, uint16_t truestate, uint16_t falsestate));
int16_t inf_gindex PROTO((LPTREE tree, int16_t baseobj, int16_t numobj));
int16_t inf_what PROTO((OBJECT *tree, int16_t ok, int16_t cncl));
VOID merge_str PROTO((char *pdst, const char *ptmp, VOIDPTR parms));
int16_t wildcmp PROTO((const char *pwild, const char *ptest));


/*
 * gemaints.c
 */
VOID signal PROTO((EVB *e));
VOID zombie PROTO((EVB *e));

/*
 * gemaplib.c
 */
extern int16_t gl_bvdisk;
extern int16_t gl_bvhard;
extern int16_t gl_recd;
extern int16_t gl_rlen;
extern intptr_t gl_rbuf;
extern int16_t gl_play;					/* 3/11/86  */
extern VOIDPTR gl_store;				/* 3/11/86  */
extern int16_t gl_mx;					/* 3/12/86  */
extern int16_t gl_my;					/* 3/12/86  */

int16_t ap_init PROTO((intptr_t pglobal));
int16_t ap_exit PROTO((NOTHING));
int16_t rd_mymsg PROTO((VOIDPTR buffer));
int16_t ap_rdwr PROTO((int16_t code, int16_t id, int16_t length, int16_t *pbuff));
int16_t ap_find PROTO((const char *pname));
VOID ap_tplay PROTO((intptr_t pbuff, int16_t length, int16_t scale));
int16_t ap_trecd PROTO((intptr_t pbuff, int16_t length));


/*
 * gemasync.c
 */
extern int16_t tbutton;
extern int16_t wwait;

EVB *get_evb PROTO((NOTHING));
VOID evinsert PROTO((EVB *e, EVB **root));
VOID takeoff PROTO((EVB *p));
EVSPEC mwait PROTO((EVSPEC mask));
EVSPEC iasync PROTO((int16_t afunc, intptr_t aparm));
uint16_t aret PROTO((EVSPEC mask));
EVSPEC acancel PROTO((EVSPEC m));


/*
 * gembase.c
 */
extern PD *rlr;
extern PD *drl;
extern PD *nrl;
extern EVB *eul;
extern EVB *dlr;
extern EVB *zlr;
extern int32_t elinkoff;
extern char indisp;
extern char infork;
extern int16_t fpt;
extern int16_t fph;
extern int16_t fpcnt;									/* forkq tail, head,    */
extern SPB wind_spb;
extern CDA *cda;
extern int16_t curpid;


/*
 * gembind.c
 */
VOID xif PROTO((intptr_t pcrys_blk));


/*
 * gemcli.c
 */
extern ACCPD *gl_pacc[MAX_ACCS];		/* total of 6 desk acc, 1 from rom  */
extern int16_t gl_naccs;
extern char *gl_adacc[MAX_ACCS];		/* addresses of accessories */
extern char *sys_adacc;
extern const char stacc[];

VOID release PROTO((NOTHING));
VOID all_run PROTO((NOTHING));
VOID ldaccs PROTO((NOTHING));
VOID free_accs PROTO((NOTHING));
BOOLEAN cre_aproc PROTO((NOTHING));

/*
 * gemctrl.c
 */
extern MOBLK gl_ctwait;
extern int16_t appl_msg[8];
#if 0
extern int16_t rets[6];							/* added 2/4/87     */
#endif
extern int16_t ml_ocnt;

VOID ct_msgup PROTO((int16_t message, int16_t owner, int16_t wh, int16_t m1, int16_t m2, int16_t m3, int16_t m4));
VOID hctl_window PROTO((int16_t w_handle, int16_t mx, int16_t my));
VOID hctl_button PROTO((int16_t mx, int16_t my));
VOID hctl_rect PROTO((int16_t mx, int16_t my));
VOID ct_chgown PROTO((PD *ppd, GRECT *pr));
VOID ctlmgr PROTO((NOTHING));
PD *ictlmgr PROTO((int16_t pid));
VOID ctlmouse PROTO((int mon));
VOID take_ownership PROTO((BOOLEAN beg_ownit));


/*
 * gemdisp.c
 */
extern PD *dpd;								/* critical error process   */
extern PD *slr;

BOOLEAN forkq PROTO((FCODE f_code, int32_t f_data));
VOID disp_act PROTO((PD *p));
VOID suspend_act PROTO((PD *p));
VOID forker PROTO((NOTHING));
VOID chkkbd PROTO((NOTHING));
VOID disp PROTO((NOTHING));


/*
 * gemevlib.c
 */
extern int16_t gl_dclick;
extern int16_t gl_ticktime;

VOID ev_rets PROTO((int16_t *rets));
int16_t ev_block PROTO((int16_t code, intptr_t lvalue));
uint16_t ev_keybd PROTO((NOTHING));
uint16_t ev_button PROTO((int16_t bflgclks, uint16_t bmask, uint16_t bstate, int16_t *rets));
uint16_t ev_mouse PROTO((MOBLK *pmo, int16_t *rets));
int16_t ev_mesag PROTO((int16_t *pbuff));
int16_t ev_timer PROTO((int32_t count));
int16_t ev_mchk PROTO((MOBLK *pmo));
int16_t ev_multi PROTO((int16_t flags, MOBLK *pmo1, MOBLK *pmo2, int32_t tmcount, intptr_t buparm, int16_t *mebuff, int16_t *prets));
int16_t ev_dclick PROTO((int16_t rate, int16_t setit));


/*
 * gemflag.c
 */
VOID tchange PROTO((int16_t p1, int16_t p2));
int16_t tak_flag PROTO((SPB *sy));
VOID amutex PROTO((EVB *e, SPB *sy));
VOID unsync PROTO((SPB *sy));
VOID fm_strbrk PROTO((LPTREE tree, const char *palstr, int16_t stroff, int16_t *pcurr_id, int16_t *pnitem, int16_t *pmaxlen));
VOID fm_parse PROTO((LPTREE tree, const char *palstr, int16_t *picnum, int16_t *pnummsg, int16_t *plenmsg, int16_t *pnumbut, int16_t *plenbut));
VOID fm_build PROTO((LPTREE tree, int16_t haveicon, int16_t nummsg, int16_t mlenmsg, int16_t numbut, int16_t mlenbut));
int16_t fm_alert PROTO((int16_t defbut, const char *palstr));


/*
 * gemfmlib.c
 */
int16_t fm_keybd PROTO((LPTREE tree, int16_t obj, int16_t *pchar, int16_t *pnew_obj));
int16_t fm_button PROTO((LPTREE tree, int16_t new_obj, int16_t clks, int16_t *pnew_obj));
int16_t fm_do PROTO((LPTREE tree, int16_t start_fld));
VOID fm_dial PROTO((int16_t fmd_type, GRECT *pi, GRECT *pt));
int16_t fm_show PROTO((int16_t string, VOIDPTR pwd, int16_t level));
int16_t eralert PROTO((int16_t n, int16_t d));
BOOLEAN fm_error PROTO((int16_t n));


/*
 * gemfslib.c
 */
int16_t fs_input PROTO((char *pipath, char *pisel, int16_t *pbutton, char *lstring));


/*
 * gemglobe.c
 */
extern THEGLO D;
int16_t size_theglo PROTO((NOTHING));


/*
 * geminput.c
 */

extern int16_t button;
extern int16_t xrat;
extern int16_t yrat;
extern int16_t kstate;
extern int16_t mclick;
extern int16_t mtrans;

extern int16_t pr_button;
extern int16_t pr_xrat;
extern int16_t pr_yrat;
extern int16_t pr_mclick;

extern PD *gl_mowner;		/* current mouse owner  */
extern PD *gl_kowner;		/* current keybd owner  */
extern PD *gl_cowner;		/* current control rect. owner */
extern PD *ctl_pd;
extern GRECT ctrl;
extern int16_t gl_bclick;
extern int16_t gl_bpend;
#if AESVERSION >= 0x330
extern int16_t gl_button;
#endif
extern int16_t gl_bdesired;
extern int16_t gl_btrue;
extern int16_t gl_bdelay;

PD *mowner PROTO((int16_t new));
uint16_t dq PROTO((CQUEUE *qptr));
VOID fq PROTO((NOTHING));
VOID evremove PROTO((EVB *e, uint16_t ret));
VOID kchange PROTO((int16_t ch, int16_t kstat));
VOID post_keybd PROTO((PD *p, uint16_t ch));
VOID bchange PROTO((int16_t new, int16_t clicks));
int16_t downorup PROTO((int16_t new, intptr_t buparm));
VOID post_button PROTO((PD * p, int16_t new, int16_t clks));
VOID mchange PROTO((int16_t rx1, int16_t ry1));
VOID post_mouse PROTO((PD *p, int16_t grx, int16_t gry));
int16_t inorout PROTO((EVB *e, int16_t rx, int16_t ry));


/*
 * gemmnlib.c
 */
extern LPTREE gl_mntree;
/* BUG: accessed as short, but allocated as long */
#if !BINEXACT
/* for BINEXACT, can't be declared here or we get redeclaration errors */
extern int16_t gl_mnpid;
#endif
extern GRECT gl_rmnactv;
extern char *desk_acc[MAX_ACCS];
extern int16_t desk_pid[MAX_ACCS];
extern int16_t gl_dacnt;
extern int16_t gl_dabase;
extern int16_t gl_dabox;

uint16_t do_chg PROTO((LPTREE tree, int16_t iitem, uint16_t chgvalue, int16_t dochg, int16_t dodraw, int16_t chkdisabled));
int16_t mn_do PROTO((int16_t *ptitle, int16_t *pitem));
VOID mn_bar PROTO((LPTREE tree, int16_t showit));
VOID mn_clsda PROTO((NOTHING));
int16_t mn_register PROTO((int16_t pid, char *pstr));
VOID ch_wrect PROTO((GRECT *r, GRECT *n));


/*
 * gemobed.c
 */
VOID ob_center PROTO((LPTREE tree, GRECT *pt));
int16_t ob_edit PROTO((LPTREE tree, int16_t obj, int16_t in_char, int16_t *idx, int16_t kind));


/*
 * gemobjop.c
 */
char ob_sst PROTO((LPTREE tree, int16_t obj, intptr_t *pspec, int16_t *pstate, int16_t *ptype, int16_t *pflags, GRECT *pt, int16_t *pth));
typedef VOID (*EVERYOBJ_CALLBACK) PROTO((LPTREE tree, int16_t obj, int16_t sx, int16_t sy));
VOID everyobj PROTO((LPTREE tree, int16_t this, int16_t last, EVERYOBJ_CALLBACK routine, int16_t startx, int16_t starty, int16_t maxdep));
int16_t get_par PROTO((LPTREE tree, int16_t obj));


/*
 * gemoblib.c
 */
#if BINEXACT
extern TEDINFO edblk;
extern BITBLK bi;
extern ICONBLK ib;
#endif

int16_t ob_sysvar PROTO((uint16_t mode, uint16_t which, uint16_t inval1, uint16_t inval2, int16_t *outval1, int16_t *outval2));
VOID ob_format PROTO((int16_t just, char *raw_str, char *tmpl_str, char *fmt_str));
VOID ob_draw PROTO((LPTREE tree, int16_t obj, int16_t depth));
int16_t ob_find PROTO((LPTREE tree, int16_t currobj, int16_t depth, int16_t mx, int16_t my));
VOID ob_add PROTO((LPTREE tree, int16_t parent, int16_t child));
VOID ob_delete PROTO((LPTREE tree, int16_t obj));
VOID ob_order PROTO((LPTREE tree, int16_t mov_obj, int16_t new_pos));
VOID ob_change PROTO((LPTREE tree, int16_t obj, int16_t new_state, int16_t redraw));
uint16_t ob_fs PROTO((LPTREE tree, int16_t ob, int16_t *pflag));
VOID ob_actxywh PROTO((LPTREE tree, int16_t obj, GRECT *pt));
VOID ob_relxywh PROTO((LPTREE tree, int16_t obj, GRECT *pt));
VOID ob_setxywh PROTO((LPTREE tree, int16_t obj, GRECT *pt));
VOID ob_offset PROTO((LPTREE tree, int16_t obj, int16_t *pxoff, int16_t *pyoff));
VOID ob_dxywh PROTO((LPTREE tree, int16_t obj, int16_t *pdx, int16_t *pdy, int16_t *pdw, int16_t *pdh));
VOID ob_gclip PROTO((LPTREE tree, int16_t obj, int16_t *pxoff, int16_t *pyoff, int16_t *pxcl, int16_t *pycl, int16_t *pwcl, int16_t *phcl));
int16_t get_prev PROTO((LPTREE tree, int16_t parent, int16_t obj));
CICON *match_planes PROTO((CICON *iconlist, int planes));
CICON *find_eq_or_less PROTO((CICON *iconlist, int planes));
VOID gr_cicon PROTO((int16_t state, int16_t *pmask, int16_t *pdata, const char *ptext, int16_t ch, int16_t chx, int16_t chy, GRECT *pi, GRECT *pt, CICONBLK *cicon));
VOID gsx_cblt PROTO((int16_t *saddr, uint16_t sx, uint16_t sy, uint16_t swb, int16_t *daddr, uint16_t dx, uint16_t dy, uint16_t dwb, uint16_t w, uint16_t h, uint16_t rule, int16_t numplanes));
VOID get_color_rsc PROTO((CICONBLK **cicondata));
VOID free_cicon PROTO((CICONBLK **carray));


/*
 * apgrlib.[cS]
 */
VOID gr_inside PROTO((GRECT *pt, int16_t th));
VOID gr_rect PROTO((uint16_t icolor, uint16_t ipattern, GRECT *pt));
int16_t gr_just PROTO((int16_t just, int16_t font, const char *ptext, int16_t w, int16_t h, GRECT *pt));
/* wrong declaration: gr_gtext does not have tmode parameter */
VOID gr_gtext PROTO((int16_t just, int16_t font, const char *ptext, GRECT *pt, int16_t tmode));
VOID gr_crack PROTO((uint16_t color, int16_t *pbc, int16_t *ptc, int16_t *pip, int16_t *pic, int16_t *pmd));
VOID gr_gicon PROTO((int16_t state, int16_t *pmask, int16_t *pdata, const char *ptext, int16_t ch, int16_t chx, int16_t chy, GRECT *pi, GRECT *pt));
VOID gr_box PROTO((int16_t x, int16_t y, int16_t w, int16_t h, int16_t th));


/*
 * gemgrlib.[cS]
 */
VOID gr_stepcalc PROTO((int16_t orgw, int16_t orgh, GRECT *pt, int16_t *pcx, int16_t *pcy, int16_t *pcnt, int16_t *pxstep, int16_t *pystep));
VOID gr_growbox PROTO((GRECT *po, GRECT *pt));
VOID gr_shrinkbox PROTO((GRECT *po, GRECT *pt));
VOID gr_xor PROTO((int16_t clipped, int16_t cnt, int16_t cx, int16_t cy, int16_t cw, int16_t ch, int16_t xstep, int16_t ystep, int16_t dowdht));
VOID gr_movebox PROTO((int16_t w, int16_t h, int16_t srcx, int16_t srcy, int16_t dstx, int16_t dsty));
VOID gr_scale PROTO((int16_t xdist, int16_t ydist, int16_t *pcnt, int16_t *pxstep, int16_t *pystep));
int16_t gr_watchbox PROTO((OBJECT *tree, int16_t obj, int16_t instate, int16_t outstate));
BOOLEAN gr_stilldn PROTO((int16_t out, int16_t x, int16_t y, int16_t w, int16_t h));
VOID gr_draw PROTO((int16_t have2box, GRECT *po, GRECT *poff));
int16_t gr_wait PROTO((GRECT *po, GRECT *poff, int16_t mx, int16_t my));
VOID gr_setup PROTO((int16_t color));
VOID gr_rubbox PROTO((int16_t xorigin, int16_t yorigin, int16_t wmin, int16_t hmin, int16_t *pwend, int16_t *phend));
VOID gr_rubwind PROTO((int16_t xorigin, int16_t yorigin, int16_t wmin, int16_t hmin, GRECT *poff, int16_t *pwend, int16_t *phend));
VOID gr_dragbox PROTO((int16_t w, int16_t h, int16_t sx, int16_t sy, GRECT *pc, int16_t *pdx, int16_t *pdy));
VOID gr_clamp PROTO((int16_t xorigin, int16_t yorigin, int16_t wmin, int16_t hmin, int16_t *pneww, int16_t *pnewh));
int16_t gr_slidebox PROTO((LPTREE tree, int16_t parent, int16_t obj, int16_t isvert));
int16_t gr_mkstate PROTO((int16_t *pmx, int16_t *pmy, int16_t *pmstat, int16_t *pkstat));

/*
 * apgsxif.[cS]
 */
#define ORGADDR 0x0L

#define vsf_interior( x )	gsx_1code(S_FILL_STYLE, x)
#define vsl_type( x )		gsx_1code(S_LINE_TYPE, x)
#define vsf_style( x )		gsx_1code(S_FILL_INDEX, x)
#define vsf_color( x )		gsx_1code(S_FILL_COLOR, x)
#define vsl_udsty( x )		gsx_1code(ST_UD_LINE_STYLE, x)

extern int16_t gl_nplanes;					/* number of planes in current res */
extern int16_t gl_width;
extern int16_t gl_height;
extern int16_t gl_nrows;
extern int16_t gl_ncols;
extern int16_t gl_wchar;
extern int16_t gl_hchar;
extern int16_t gl_wschar;
extern int16_t gl_hschar;
extern int16_t gl_wptschar;
extern int16_t gl_hptschar;
extern int16_t gl_wsptschar;
extern int16_t gl_hsptschar;
extern int16_t gl_wbox;
extern int16_t gl_hbox;
extern int16_t gl_xclip;
extern int16_t gl_yclip;
extern int16_t gl_wclip;
extern int16_t gl_hclip;
extern int16_t gl_handle;
extern int16_t gl_mode;
extern int16_t gl_mask; /* unused */
extern int16_t gl_tcolor;
extern int16_t gl_lcolor;
extern int16_t gl_fis;
extern int16_t gl_patt;
extern int16_t gl_font;
extern GRECT gl_rscreen;
extern GRECT gl_rfull;
extern GRECT gl_rzero;
extern GRECT gl_rcenter;
extern GRECT gl_rmenu;

VOID gsx_sclip PROTO((const GRECT *pt));
VOID gsx_gclip PROTO((GRECT *pt));
BOOLEAN gsx_chkclip PROTO((GRECT *pt));
VOID gsx_pline PROTO((int16_t offx, int16_t offy, int16_t cnt, const int16_t *pts));
VOID gsx_cline PROTO((uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2));
VOID gsx_attr PROTO((uint16_t text, uint16_t mode, uint16_t color));
VOID gsx_bxpts PROTO((GRECT *pt));
VOID gsx_box PROTO((GRECT *pt));
VOID bb_screen PROTO((int16_t scrule, int16_t scsx, int16_t scsy, int16_t scdx, int16_t scdy, int16_t scw, int16_t sch));
VOID gsx_trans PROTO((int16_t *saddr, uint16_t swb, int16_t *daddr, uint16_t dwb, uint16_t h));
VOID gsx_start PROTO((NOTHING));
VOID bb_fill PROTO((int16_t mode, int16_t fis, int16_t patt, int16_t hx, int16_t hy, int16_t hw, int16_t hh));
VOID gsx_tcalc PROTO((int16_t font, const char *ptext, int16_t *ptextw, int16_t *ptexth, int16_t *pnumchs));
VOID gsx_tblt PROTO((int16_t tb_f, int16_t x, int16_t y, int16_t tb_nc));
VOID gsx_xbox PROTO((GRECT *pt));
VOID gsx_xcbox PROTO((GRECT *pt));
VOID gsx_xline PROTO((int16_t ptscount, int16_t *ppoints));
uint16_t ch_width PROTO((int16_t fn));
uint16_t ch_height PROTO((int16_t fn));


/*
 * optimize.S
 */
unsigned int reverse PROTO((int index));
VOID expand_data PROTO((int16_t *saddr, int16_t *daddr, int16_t *mask, int splanes, int dplanes, int w, int h));


/*
 * gempd.c
 */
PD *fpdnm PROTO((const char *pname, uint16_t pid));
VOID p_nameit PROTO((PD *p, const char *pname));
PD *pstart PROTO((VOIDPTR pcode, const char *pfilespec, intptr_t ldaddr));
VOID insert_process PROTO((PD *pi, PD **root));


/*
 * gemqueue.c
 */
VOID aqueue PROTO((BOOLEAN isqwrite, EVB *e, int32_t lm));


/*
 * gemrlist.c
 */
BOOLEAN delrect PROTO((RLIST *rp, VOIDPTR rlist));
RLIST *genrlist PROTO((uint16_t handle, uint16_t area));


/*
 * gemrom.c
 */
int16_t rom_ram PROTO((int which, intptr_t pointer));
VOID rsc_free PROTO((NOTHING));
BOOLEAN rsc_read PROTO((NOTHING));


/*
 * gemrslib.c
 */
extern RSHDR *rs_hdr;
extern intptr_t rs_global;

VOID rs_sglobe PROTO((intptr_t pglobal)); /* also referenced by DESKTOP */
int16_t rs_obfix PROTO((LPTREE tree, int16_t curob));
char *rs_str PROTO((int16_t stnum));
int16_t rs_free PROTO((intptr_t pglobal));
int16_t rs_gaddr PROTO((intptr_t pglobal, uint16_t rtype, uint16_t rindex, VOIDPTR *rsaddr));
int16_t rs_saddr PROTO((intptr_t pglobal, uint16_t rtype, uint16_t rindex, VOIDPTR rsaddr));
VOID do_rsfix PROTO((intptr_t hdr, int16_t size));
VOID rs_fixit PROTO((intptr_t pglobal));
int16_t rs_load PROTO((intptr_t pglobal, const char *rsfname));


/*
 * gemsclib.c
 */
VOID sc_read PROTO((char *pscrap));
VOID sc_write PROTO((const char *pscrap));


/*
 * gemshlib.c
 */

extern int16_t sh_doexec;
extern int16_t sh_isgem;
extern int16_t sh_gem;
extern char *ad_envrn;
extern char *ad_shcmd;
extern char *ad_shtail;
extern BOOLEAN sh_iscart;
extern char *ad_path;

int16_t sh_read PROTO((char *pcmd, char *ptail));
int16_t sh_write PROTO((int16_t doex, int16_t isgem, int16_t isover, const char *pcmd, const char *ptail));
int16_t sh_get PROTO((char *pbuffer, uint16_t len));
int16_t sh_put PROTO((const char *pdata, int16_t len));
BOOLEAN sh_tographic PROTO((NOTHING));
BOOLEAN sh_toalpha PROTO((NOTHING));
VOID sh_draw PROTO((char *lcmd, int16_t start, int16_t depth));
char *sh_name PROTO((char *ppath));
int16_t sh_envrn PROTO((char **ppath, const char *psrch));
typedef VOID (*SHFIND_PROC) PROTO((const char *path));
int16_t sh_find PROTO((char *pspec, SHFIND_PROC routine));
VOID sh_main PROTO((NOTHING));


/*
 * gemwmlib.c
 */
extern LPTREE gl_newdesk;
extern int16_t gl_newroot;							/* root object of new DESKTOP */
extern int16_t gl_wtop;
extern SPB *ad_windspb;

VOID wm_init PROTO((NOTHING));
int16_t wm_create PROTO((uint16_t kind, GRECT *rect));
int16_t wm_find PROTO((int mx, int my));
VOID wm_min PROTO((int16_t kind, int16_t *ow, int16_t *oh));
#define srchwp(handle) (&D.w_win[handle])
VOID wm_open PROTO((int16_t handle, GRECT *rect));
VOID wm_close PROTO((int16_t handle));
VOID wm_delete PROTO((int16_t handle));
VOID wm_set PROTO((int16_t handle, int16_t field, int16_t *iw));
VOID wm_calc PROTO((int16_t type, int16_t kind, int16_t ix, int16_t iy, int16_t iw, int16_t ih, int16_t *ox, int16_t *oy, int16_t *ow, int16_t *oh));
VOID w_drawdesk PROTO((GRECT *dirty));
VOID w_update PROTO((int16_t bottom, GRECT *pt, int16_t top, BOOLEAN moved));
BOOLEAN wm_start PROTO((NOTHING));
VOID wm_get PROTO((int16_t handle, int16_t field, int16_t *ow));
VOID wm_update PROTO((int code));
VOID wm_new PROTO((NOTHING));
VOID w_setactive PROTO((NOTHING));
VOID ap_sendmsg PROTO((int16_t *ap_msg, int16_t type, int16_t towhom, int16_t w3, int16_t w4, int16_t w5, int16_t w6, int16_t w7));

extern int16_t gl_wtop;
extern OBJECT *gl_awind;
VOID w_getsize PROTO((int16_t which, int16_t w_handle, GRECT *pt));
VOID w_bldactive PROTO((int16_t w_handle));
 

/*
 * gemwrect.c
 */
extern ORECT *rul;

ORECT *get_orect PROTO((NOTHING));
VOID newrect PROTO((LPTREE tree, int16_t wh, int16_t junkx, int16_t junky));


/*
 * jdos.S
 */
extern BOOLEAN DOS_ERR;
extern int16_t DOS_AX;
extern BOOLEAN diskin;

int dos_sfirst PROTO((const char *name, int attrib));
int dos_snext PROTO((NOTHING));
int dos_open PROTO((const char *name, int mode));
int dos_read PROTO((int fd, size_t size, VOIDPTR buf));
int dos_write PROTO((int fd, size_t size, VOIDPTR buf));
long dos_lseek PROTO((int fd, int whence, long offset));
int dos_gdir PROTO((int drive, char *pdrvpath));
int dos_mkdir PROTO((const char *path, int attr));
int dos_set PROTO((int h, uint16_t time, uint16_t date));
int dos_label PROTO((int drive, const char *name));
int dos_space PROTO((int drive, int32_t *total, int32_t *avail));
int dos_rename PROTO((const char *oldname, const char *newname));
VOIDPTR dos_alloc PROTO((long size));
intptr_t dos_avail PROTO((NOTHING));
int chrout PROTO((int c));
int rawcon PROTO((int c));
int prt_chr PROTO((int c));
int dos_sdta PROTO((VOIDPTR dta));
int dos_gdrv PROTO((NOTHING));
int dos_close PROTO((int fd));
int dos_chdir PROTO((const char *path));
int dos_sdrv PROTO((int drv));
int dos_chmod PROTO((const char *path, int attr));
int dos_delete PROTO((const char *path));
int dos_free PROTO((VOIDPTR ptr));
int do_cdir PROTO((int drv, const char *path));
int isdrive PROTO((NOTHING)); /* BUG: should be declared as returning LONG */
long trap PROTO((short code, ...));


/*
 * mn_index.c
 */
VOID mn_new PROTO((NOTHING));
VOID mn_free PROTO((int16_t id));


/*
 * mn_mbar.c
 */
BOOLEAN mn_hdo PROTO((int16_t *ptitle, LPTREE *ptree, int16_t *pmenu, int16_t *pitem, int16_t *keyret));


/*
 * mn_menu.c
 */
VOID mn_init PROTO((NOTHING));


/*
 * romcart.c
 */
BOOLEAN cart_init PROTO((NOTHING));
BOOLEAN cart_exec PROTO((const char *pcmd, const char *ptail));
BOOLEAN c_sfirst PROTO((const char *path));
int16_t ld_cartacc PROTO((NOTHING));
BOOLEAN cart_sfirst PROTO((char *pdta, int16_t attr)); /* also referenced by DESKTOP */
BOOLEAN cart_snext PROTO((NOTHING)); /* also referenced by DESKTOP */


/*
 * jdispa.S
 */
VOID cli PROTO((NOTHING));
VOID hcli PROTO((NOTHING));
VOID sti PROTO((NOTHING));
VOID hsti PROTO((NOTHING));
VOID dsptch PROTO((NOTHING));
VOID savestate PROTO((NOTHING));
VOID switchto PROTO((NOTHING));
VOID gotopgm PROTO((NOTHING));
VOID psetup PROTO((PD *pd, VOIDPTR pcode));
int16_t pgmld PROTO((int16_t handle, const char *pname, intptr_t *ldaddr));


/*
 * ratrbp.S
 */
extern VOIDPTR drwaddr;
extern int32_t CMP_TICK;
extern int32_t NUM_TICK;

VOID drawrat PROTO((int16_t x, int16_t y));
VOID justretf PROTO((NOTHING));
VOID b_delay PROTO((int16_t amnt));
VOID delay PROTO((int32_t ticks));


/*
 * gsx2.S
 */
VOID gsx2 PROTO((NOTHING));
VOID i_ptsin PROTO((int16_t *));
VOID i_intin PROTO((int16_t *));
VOID i_ptsout PROTO((int16_t *));
VOID i_intout PROTO((int16_t *));
VOID i_ptr PROTO((VOIDPTR));
VOID i_lptr1 PROTO((VOIDPTR, ...));
VOID i_ptr2 PROTO((VOIDPTR));
VOID m_lptr2 PROTO((VOIDPTR *));
int16_t mul_div PROTO((int16_t mul1, int16_t mul2, int16_t divis));


/*
 * trap14.S
 */
VOID getmouse PROTO((NOTHING));
VOID putmouse PROTO((NOTHING));
int32_t trp13 PROTO((short code, ...));
int32_t trp14 PROTO((short code, ...));
int32_t gemdos PROTO((short code, ...));
int32_t bios PROTO((short code, ...));


/*
 * gemjstrt.S
 */
extern BOOLEAN gl_rschange;
extern int16_t gl_restype;


/*
 * someone messed it up and called functions from desktop here...
 */
extern char const infdata[]; /* "DESKTOP.INF" */

#if AESVERSION >= 0x330
extern BOOLEAN do_once; /* used by desktop only */
#endif

VOID XDeselect PROTO((OBJECT *tree, int16_t obj));
BOOLEAN getcookie PROTO((int32_t cookie, int32_t *val));
char *scan_2 PROTO((const char *pcurr, int16_t *pwd));
char *escan_str PROTO((const char *pcurr, char *ppstr));
char *save_2 PROTO((char *pcurr, uint16_t wd));
BOOLEAN app_reschange PROTO((int16_t res));
const char *g_name PROTO((const char *file));
BOOLEAN deskmain PROTO((NOTHING));



#if LINEF_HACK
/* actually same functions, but with different opcode entries in linef dispatcher */
VOID ob_fformat PROTO((int16_t just, char *raw_str, char *tmpl_str, char *fmt_str));
VOID ob_foffset PROTO((LPTREE tree, int16_t obj, int16_t *pxoff, int16_t *pyoff));
VOID gr_fmovebox PROTO((int16_t w, int16_t h, int16_t srcx, int16_t srcy, int16_t dstx, int16_t dsty));
VOID gr_fdragbox PROTO((int16_t w, int16_t h, int16_t sx, int16_t sy, GRECT *pc, int16_t *pdx, int16_t *pdy));
VOID gsx_fcline PROTO((uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2));
VOID gsx_ftblt PROTO((int16_t tb_f, int16_t x, int16_t y, int16_t tb_nc));
int dos_ffree PROTO((VOIDPTR ptr));
VOID rc_fconstrain PROTO((const GRECT *pc, GRECT *pt));
BOOLEAN rc_fequal PROTO((const GRECT *p1, const GRECT *p2));
int16_t inf_fgindex PROTO((LPTREE tree, int16_t baseobj, int16_t numobj));
VOID feveryobj PROTO((LPTREE tree, int16_t this, int16_t last, EVERYOBJ_CALLBACK routine, int16_t startx, int16_t starty, int16_t maxdep));
int32_t trp13int PROTO((short code, ...));
int32_t trp143int PROTO((short code, ...));
#else
#define ob_fformat ob_format
#define ob_foffset ob_offset
#define gr_fmovebox gr_movebox
#define gr_fdragbox gr_dragbox
#define gsx_fcline gsx_cline
#define gsx_ftblt gsx_tblt
#define dos_ffree dos_free
#define rc_fconstrain rc_constrain
#define rc_fequal rc_equal
#define inf_fgindex inf_gindex
#define feveryobj everyobj
#define trp13int trp13
#define trp14int trp14
#endif
