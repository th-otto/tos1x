/*      DEFINES.H               3/16/89 - 5/14/89       Derek Mui       */
/*      Change the IDTYPE       7/11/92                 D.Mui           */

/* Increased MAXMENU to 31      07/07/92  cjg                           */

/*****************************************************************************/

#include "config.h"
#include "deskdefs.h"
#include "../aes/aes.h"

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __STDINT_H__
#include <stdint.h>
#endif

#include "mobdefs.h"

typedef struct pathnode PNODE;

#include "window.h"

#include "deskrsc.h"
#include "osbind.h"

#ifndef NO_CONST
#  ifdef __GNUC__
#	 define NO_CONST(p) __extension__({ union { const void *cs; void *s; } _x; _x.cs = p; _x.s; })
#  else
#    ifdef __ALCYON__ /* Alcyon parses the cast as function call??? */
#      define NO_CONST(p) p
#    else
#      define NO_CONST(p) ((void *)(p))
#    endif
#  endif
#endif

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
 * Should really be OBJECT *, as it was in the original DRI version.
 * Someone messed it up and declared it as long in the Atari version.
 * Even worse, LPTREE was not even used anymore, and all source
 * files changes instead.
 */
typedef intptr_t LPTREE;

#define CMD_BAT    0xFA
#define CMD_COPY   0xFB
#define CMD_FORMAT 0xFC
#define CMD_PRINT  0xFD
#define CMD_TYPE   0xFE

/* file operation definitions   */
#define OP_COUNT      0
#define OP_DELETE     1
#define OP_COPY       2
#define OP_MOVE       3


/* Set Write Allocate mode, clear both caches,
 * and enable them with burst fill.
 */
#define CACHE_ON        0x00003919L
                                
#define CACHE_OFF       0x00000808L     /* Clear and disable both caches. */

#define XCA_ON          0x00003111L     /* read back the cache on       */
#define XCA_OFF         0x00000000L     /* read back cache off          */

#define FA_RDONLY       0x0001
#define FA_HIDDEN       0x0002
#define FA_SYSTEM       0x0004
#define FA_LABEL        0x0008
#define FA_DIREC        0x0010
#define FA_ARCH         0x0020


/*****  APPLICATION FILE TYPE DEFINES      ******/
/*      -1 means match the type                 */

#define AT_ISFILE   0 /* file                 */
#define AT_ISFOLD   1 /* folder               */
#define AT_ISDISK   2 /* disk or diskette     */
#define AT_ISTRSH   3 /* Trash                */
#define AT_ISCART   4 /* cartridge            */

#define AF_ISCRYS 0x0001			/* is crystal appl.	*/
#define AF_ISGRAF 0x0002			/* is graphic appl.	*/
#define AF_ISDESK 0x0004			/* is placed on desk */
#define AF_ISPARM 0x0008			/* is in need of input */
#define AF_ISFMEM 0x0010			/* is in need of full memory */

#define TOS     0
#define PRG     (AF_ISGRAF|AF_ISCRYS)
#define TTP     AF_ISPARM
#define DISK    7

#define V_ICON  0               /* view as icon */
#define V_TEXT  1               /* view as text */

#define S_NAME  0               /* sort as name */
#define S_DATE  1
#define S_SIZE  2
#define S_TYPE  3
#define S_NO    4               /* no sort      */

#define MAX_OBS 60
#define MAX_LEVEL       8       /* max level of folder  */

#define APP_NODE 48     /* number of user definable file type   */
#define APP_DESK 48     /* number of desktop icon should equal to number of */
                        /* icons in background dialogue         */
        
#define COPYMAXDEPTH 12

#define L_NOEXIT        0       /* desk loop exit code          */
#define L_LAUNCH        1
#define L_CHGRES        2
#define L_READINF       3


#define F1      0x3b00
#define F2      0x3c00
#define F3      0x3d00
#define F4      0x3e00
#define F5      0x3f00
#define F6      0x4000
#define F7      0x4100
#define F8      0x4200
#define F9      0x4300
#define F10     0x4400  
#define F11     0x5400
#define F12     0x5500
#define F13     0x5600
#define F14     0x5700
#define F15     0x5800
#define F16     0x5900
#define F17     0x5A00
#define F18     0x5B00
#define F19     0x5C00
#define F20     0x5D00  

#define ARGULEN 12

#define E_NOFNODES 100
#define E_NOPNODES 101
#define E_NODNODES 102


typedef struct app
{
	/*  0 */ struct app *a_next;    /* app pointer */
	/*  4 */ int16_t a_apptype;
	/*  6 */ int16_t a_type; 		/* file type */
	/*  8 */ int16_t a_obid;		/* object # in desktop tree */
	/* 10 */ char *a_pappl;         /* filename.ext of ap */
	/* 14 */ char *a_pdata; 		/* wildcards of data file */
	/* 18 */ int16_t a_aicon; 		/* application icon # */
	/* 20 */ int16_t a_dicon;       /* data icon # */
	/* 22 */ int16_t a_char;
	/* 24 */ int16_t a_x;
	/* 26 */ int16_t a_y;
	/* 28 */
} APP;

typedef struct _fnode FNODE;

struct _fnode {
	FNODE    *f_next;
	FNODE    *f_pfndx;
	char     f_junk;				/* to align on even boundaries */
	char     f_attr;
	uint16_t f_time;	/* time */
	uint16_t f_date;	/* date */
	int32_t  f_size;
	char     f_name[LEN_ZFNAME + 1];
	int16_t  f_obid;
	APP      *f_pa;
	BOOLEAN  f_isapp;
};


struct pathnode {
	PNODE *p_next;
	uint16_t p_flags;
	uint16_t p_attr;
	char		p_spec[LEN_ZFPATH];
	FNODE		*p_flist;
	uint16_t	p_count;
	int32_t		p_size;
};

typedef struct idtype
{
	int16_t i_type;
	int16_t i_icon;
	ICONBLK i_iblk;
	const char *i_path;
	char i_name[NAMELEN];
} IDTYPE;

#ifndef NUM_IB
#  define NUM_IB 5
#endif

#define NUM_ADTREES 16 /* actually only 14 (NUM_TREE) */

typedef struct {
	/*     0 */ FNODE *g_favail;
	/*     4 */ PNODE g_plist[NUM_PNODES];
	/*   704 */ PNODE *g_pavail;
	/*   708 */ PNODE *g_phead;
	/*   712 */ char g_wdta[PATHLEN];
	/*   840 */ DTA *a_wdta;
	/*   844 */ short n_winalloc;
	/*   846 */ ICONBLK gl_icons[NUM_SOBS];
	/*  9686 */ int16_t g_index[NUM_SOBS];
	/* 10206 */ USERBLK g_udefs[NUM_SOBS];
	/* 10286 */ short g_num;                /* number of points */
	/* 10288 */ int16_t *g_pxy;             /* outline pts to drag */
	/* 10292 */ short g_iview;              /* current view type */
	/* 10294 */ short g_iwext;              /* w,h of extent of a single item */
	/* 10296 */ short g_ihext;
	/* 10298 */ short g_iwint;              /* w,h of interval between items */
	/* 10300 */ short g_ihint;
	/* 10302 */ short g_iwspc;              /* w,h of space used by a single item */
	/* 10304 */ short g_ihspc;
	/* 10306 */ short g_incol;              /* # of cols in full window */
	/* 12308 */ int16_t g_isort;			/* current sort type */
	/* 12310 */ char g_srcpth[PATHLEN];
	/* 12438 */ char g_dstpth[PATHLEN];
	/* 12566 */ char *g_xbuf;               /* data xfer buffer and */
	/* 12570 */ long g_xlen;                /* length for copying */
	/* 12574 */ DTA g_dtastk[MAX_LEVEL + 1];
	/* 12970 */ int32_t g_nfiles;
	/* 12974 */ int32_t g_ndirs;
	/* 12978 */ int32_t g_size;
	/* 12982 */ char g_tmppth[PATHLEN];
	/* 13310 */ int16_t g_xyobpts[MAX_OBS * 2];
	/* 13350 */ int16_t g_rmsg[8];		    /* general AES message area */
	/* 13366 */ int16_t *p_msgbuf;		
	/* 13378 */ GRECT g_desk;
	/* 13370 */ GRECT g_full;				/* full window size value */
	/* 13386 */ char g_cmd[PATHLEN];
	/* 13514 */ char *g_pcmd;
	/* 13518 */ char g_tail[128];
	/* 13646 */ char *g_ptail;
	/* 13650 */ char *str;				/* rsrc_gaddr result */
	/* 13654 */ OBJECT *g_atree[NUM_ADTREES];	/* resource trees */
	/* 13718 */ int16_t g_croot;        /* current pseudo root */
	/* 13720 */ int16_t g_cwin;         /* current window # */
	/* 13722 */ int16_t g_wlastsel;     /* window holding last selection */
	/* 13724 */ int16_t g_cviewitem;    /* curr. view item chked */
	/* 13726 */ int16_t g_csortitem;    /* curr. sort item chked */
	/* 13728 */ int16_t g_ccopypref;	/* curr. copy pref.	*/
	/* 13730 */ int16_t g_cdelepref;	/* curr. delete pref.	*/
	/* 13732 */ int16_t s_bitblt;
	/* 13734 */ int16_t g_covwrpref;	/* curr. overwrite pref.*/
#if TOSVERSION >= 0x162
	int16_t g_ccachepref;				/* only a guess; not written to DESKTOP.INF */
#endif
	/* 13736 */ char *p_cartname;
	/* 13740 */ int16_t g_icw;
	/* 13742 */ int16_t g_ich;
	/* 13744 */ int16_t g_nmicon;
	/* 13746 */ int16_t g_nmtext;
	/* 13748 */ int16_t g_xyicon[18];
	/* 13784 */ int16_t g_xytext[18];
	/* 13820 */ int16_t g_wicon;		/* desktop icon size */
	/* 13822 */ int16_t g_hicon;
	/* 13824 */ char afile[SIZE_AFILE];
	/* 18016 */ int16_t size_afile;		/* length of recently read desktop.inf */
	/* 18018 */ char appbuf[SIZE_AFILE];
	/* 22210 */ APP *appnode;			/* app buffer array */
	/* 22214 */ APP app[NUM_ANODES];	/* app buffer array */
	/* 23110 */ APP *appfree;			/* app buffer free list */
	/* 23114 */ APP *applist;			/* app buffer list */
	/* 23118 */ ICONBLK iconaddr[NUM_IB + 1];	/* desktop icon dialogue address */
	/* 23322 */ ICONBLK g_iblist[NUM_IB + 1];
	/* 23526 */ int16_t g_ismask[(NUM_IB + 1) * 2];
	/* 23550 */ int16_t sitem_save;		/* saved sort item */
	/* 23552 */ int16_t vitem_save;		/* view item */
	/* 23554 */ BOOLEAN ccopy_save;		/* copy ? */
	/* 23556 */ BOOLEAN cdele_save;		/* delete ? */
	/* 23558 */ BOOLEAN cbit_save;		/* bitblt */
	/* 23560 */ int16_t pref_save;		/* screen pref */
	/* 23562 */ BOOLEAN covwr_save;		/* write ? */
#if TOSVERSION >= 0x162
	int16_t ccache_save;				/* only a guess; not written to DESKTOP.INF */
#endif
	/* 23564 */ WSAVE win_save[NUM_WNODES];	/* window process structure */
	/* 24108 */ OBJECT *g_pscreen;
	/* 24112 */ char ml_files[4];		/* string buffer for # of files BUG: too short */
	/* 24116 */ char ml_dirs[4];		/* string buffer for # of dirs BUG: too short */
	/* 24120 */ char o24120[8];			/* unused, but keep it because buffer above may overflow */
	/* 24128 */ BOOLEAN ml_havebox;
	/* 24130 */ BOOLEAN ml_dlpr;
	/* 24132 */ char printname[26];
	/* 24158 */ char ml_fstr[13];
	/* 24171 */ char ml_ftmp[13];
	/* 24184 */ char o24184[16];		/* unused */
	/* 24200 */ OBJECT g_screen[NUM_SOBS];
	/* 30440 */ char autofile[PATHLEN];
	/* 30568 */ unsigned short g_fnnext;
	/* 30570 */ unsigned short g_fnavail;
	/* 30572 */
	
} THEDSK;

/*
 * Symbolic "drive letter" for the cartridge.
 * Must be lowercase. This is only handled by
 * the desktop, not by GEMDOS.
 */
#define CHAR_FOR_CARTRIDGE 'c'


extern char const getall[];
extern char const wilds[];
extern int16_t gl_kstate;

/*
 * deskwin.c
 */
extern GRECT g_winsave[NUM_WNODES];
extern DESKWIN *g_wlist;				/* head of window list      */

VOID winfo PROTO((DESKWIN *win));
DESKWIN *w_gnext PROTO((NOTHING));
DESKWIN *w_gfirst PROTO((NOTHING));
VOID up_allwin PROTO((const char *path, BOOLEAN full));
VOID up_win PROTO((DESKWIN *win));
VOID bottop PROTO((NOTHING));
BOOLEAN path_alloc PROTO((int16_t level));
VOID free_path PROTO((NOTHING));
VOID clr_allwin PROTO((NOTHING));
VOID clr_xwin PROTO((DESKWIN *win, BOOLEAN infoupdate));
VOID srl_verbar PROTO((DESKWIN *win, uint16_t pos));
VOID srl_hzbar PROTO((DESKWIN *win, uint16_t pos));
VOID win_slide PROTO((int16_t handle, uint16_t pos, BOOLEAN vertical));
VOID srl_row PROTO((DESKWIN *win, int16_t row, int16_t dir));
VOID srl_col PROTO((DESKWIN *win, int16_t col, int16_t dir));
VOID blt_window PROTO((DESKWIN *win, int16_t mode, int16_t size));
VOID view_adjust PROTO((DESKWIN *win));
VOID sort_show PROTO((int16_t mode, BOOLEAN view));
VOID view_fixmode PROTO((DESKWIN *win));
VOID make_top PROTO((DESKWIN *win));
VOID ini_windows PROTO((NOTHING));
DESKWIN *alloc_win PROTO((NOTHING));
DESKWIN *get_win PROTO((int16_t handle));
VOID open_window PROTO((int16_t handle));
int16_t create_window PROTO((NOTHING));
DESKWIN *get_top PROTO((NOTHING));
VOID free_windows PROTO((NOTHING));
DESKWIN *win_ith PROTO((int level));
VOID up_1win PROTO((DESKWIN *win));
VOID win_sname PROTO((DESKWIN *pw));
VOID win_sinfo PROTO((DESKWIN *pw));
VOID win_top PROTO((DESKWIN *thewin));
DESKWIN *win_alloc PROTO((int16_t obid));
VOID win_free PROTO((DESKWIN *thewin));
VOID win_bdall PROTO((NOTHING));
VOID win_arrow PROTO((int16_t wh, int16_t arrow_type));
VOID win_start PROTO((NOTHING));
DESKWIN *win_ontop PROTO((NOTHING));
VOID win_bldview PROTO((DESKWIN *pwin, int16_t x, int16_t y, int16_t w, int16_t h));
int16_t win_isel PROTO((OBJECT *olist, int16_t root, int16_t curr));
DESKWIN *win_find PROTO((int16_t wh));
char *win_iname PROTO((int16_t curr));
VOID men_update PROTO((LPTREE tree));
VOID win_view PROTO((int16_t vtype, int16_t isort));


/*
 * deskact.c
 */
extern BOOLEAN back_update;						/* update background */

BOOLEAN ch_obj PROTO((int16_t mx, int16_t my, DESKWIN **win, int16_t *item, int16_t *type));
BOOLEAN ch_undo PROTO((NOTHING));
VOID file_op PROTO((const char *dest, int16_t mode));
BOOLEAN build_rect PROTO((OBJECT *obj, GRECT *rect, int16_t w, int16_t h));
VOID r_box PROTO((int16_t id, DESKWIN *win));
VOID hd_down PROTO((int16_t sitem, int16_t stype, DESKWIN *swin));
int16_t make_icon PROTO((int16_t drive, int16_t icon, int16_t type, const char *text));


/*
 * deskapp1.c
 */
extern char const infdata[];

BOOLEAN app_reschange PROTO((int16_t res)); /* also referenced by AES */
VOID app_free PROTO((APP *app));
APP *app_alloc PROTO((BOOLEAN atend));


/*
 * deskbind.c
 */
VOID wind_new PROTO((NOTHING));
int16_t fsel_exinput PROTO((char *path, char *selec, int16_t *button, const char *label));
int16_t rsrc_load PROTO((const char *name));
int16_t rsrc_obfix PROTO((LPTREE tree, int16_t obj));
int16_t menu_popup PROTO((MENU *menu, int16_t x, int16_t y, MENU *mdata));
int16_t menu_istart PROTO((int16_t code, OBJECT *mtree, int16_t mmenu, int16_t start));
VOID graf_mouse PROTO((int16_t style, MFORM *grmaddr));

VOID dv_show_c PROTO((BOOLEAN reset));
VOID gsx_ncode PROTO((int16_t code, int16_t n, int16_t m));
VOID dv_hide_c PROTO((NOTHING));
VOID dv_exit_cur PROTO((NOTHING));
VOID dv_enter_cur PROTO((NOTHING));
VOID dvs_clip PROTO((BOOLEAN clip_flag, const int16_t *pxyarray));


/*
 * deskif.S
 */
int16_t appl_bvset PROTO((int16_t bvdisk, int16_t bvhard));
int16_t appl_write PROTO((int16_t rwid, int16_t length, int16_t *pbuff));
#ifndef __ALCYON__ /* macro line too long for this prototype... sigh */
int16_t evnt_multi PROTO((uint16_t flags, uint16_t bclk, uint16_t bmsk, uint16_t bst,
	uint16_t m1flags, uint16_t m1x, uint16_t m1y, uint16_t m1w, uint16_t m1h,
	uint16_t m2flags, uint16_t m2x, uint16_t m2y, uint16_t m2w, uint16_t m2h,
	int16_t *mepbuff,
	uint16_t tlc, uint16_t thc,
	int16_t *pmx, int16_t *pmy, int16_t *pbut, int16_t *pks, int16_t *pkr, int16_t *pbr));
#endif
int16_t evnt_button PROTO((int16_t clicks, uint16_t mask, uint16_t state, int16_t *pmx, int16_t *pmy, int16_t *pmw, int16_t *pmh));
int16_t evnt_dclick PROTO((int16_t rate, int16_t setit));
int16_t form_do PROTO((OBJECT *form, int16_t start));
int16_t form_dial PROTO((int16_t dtype, int16_t ix, int16_t iy, int16_t iw, int16_t ih, int16_t x, int16_t y, int16_t w, int16_t h));
int16_t form_alert PROTO((int16_t defbut, const char *astring));
int16_t form_error PROTO((int16_t errnum));
int16_t form_center PROTO((OBJECT *tree, int16_t *pcx, int16_t *pcy, int16_t *pcw, int16_t *pch));
int16_t graf_handle PROTO((int16_t *gwchar, int16_t *ghchar, int16_t *gwbox, int16_t *ghbox));
VOID graf_rubbox PROTO((int16_t xorigin, int16_t yorigin, int16_t wmin, int16_t hmin, int16_t *pwend, int16_t *phend));
int16_t graf_mkstate PROTO((int16_t *pmx, int16_t *pmy, int16_t *pmstate, int16_t *pkstate));
VOID graf_growbox PROTO((int16_t orgx, int16_t orgy, int16_t orgw, int16_t orgh, int16_t x, int16_t y, int16_t w, int16_t h));
VOID graf_shrinkbox PROTO((int16_t orgx, int16_t orgy, int16_t orgw, int16_t orgh, int16_t x, int16_t y, int16_t w, int16_t h));
int16_t menu_tnormal PROTO((OBJECT *mlist, int16_t dlist, int16_t normal));
int16_t menu_bar PROTO((OBJECT *tree, int16_t showit));
int16_t menu_icheck PROTO((OBJECT *mlist, int16_t dlist, int16_t check));
int16_t menu_ienable PROTO((OBJECT *mlist, int16_t dlist, int16_t enable));
int16_t objc_offset PROTO((OBJECT *tree, int16_t obj, int16_t *poffx, int16_t *poffy));
int16_t objc_order PROTO((OBJECT *tree, int16_t mov_obj, int16_t newpos));
int16_t objc_find PROTO((OBJECT *tree, int16_t startob, int16_t depth, int16_t mx, int16_t my));
int16_t objc_add PROTO((OBJECT *tree, int16_t parent, int16_t child));
int16_t objc_draw PROTO((OBJECT *tree, int16_t drawob, int16_t depth, int16_t xc, int16_t yc, int16_t wc, int16_t hc));
int16_t objc_change PROTO((OBJECT *tree, int16_t drawob, int16_t depth, int16_t xc, int16_t yc, int16_t wc, int16_t hc, int16_t newstate, BOOLEAN redraw));
int16_t rsrc_free PROTO((NOTHING));
int16_t rsrc_gaddr PROTO((int16_t rstype, int16_t rsid, VOIDPTR *paddr));
int16_t shel_get PROTO((char *pbuffer, int16_t len));
int16_t shel_put PROTO((const char *pdata, int16_t len));
int16_t shel_write PROTO((int16_t doex, int16_t isgr, int16_t iscr, const char *pcmd, const char *ptail));
int16_t wind_close PROTO((int16_t handle));
int16_t wind_delete PROTO((int16_t handle));
int16_t wind_find PROTO((int16_t mx, int16_t my));
int16_t wind_update PROTO((int16_t beg_update));
int16_t wind_create PROTO((uint16_t kind, int16_t wx, int16_t wy, int16_t ww, int16_t wh));
int16_t wind_open PROTO((int16_t handle, int16_t wx, int16_t wy, int16_t ww, int16_t wh));
int16_t wind_get PROTO((int16_t w_handle, int16_t w_field, int16_t *pw1, int16_t *pw2, int16_t *pw3, int16_t *pw4));
int16_t wind_set PROTO((int16_t w_handle, int16_t w_field, ...));
int16_t wind_calc PROTO((int16_t wctype, uint16_t kind, int16_t x, int16_t y, int16_t w, int16_t h, int16_t *px, int16_t *py, int16_t *pw, int16_t *ph));


/*
 * deskdir.c
 */
extern int f_level;							/* the current depth of the directory path */

BOOLEAN dofiles PROTO((const char *s, const char *d, int16_t code, int32_t *ndirs, int32_t *nfiles, int32_t *tsize, int16_t type, BOOLEAN multiple));
BOOLEAN doright PROTO((int flag));
BOOLEAN d_doop PROTO((int op, OBJECT *tree, char *psrc_path, char *pdst_path, uint16_t *pfcnt, uint16_t *pdcnt));
BOOLEAN fun_op PROTO((int op, PNODE *pspath));
BOOLEAN dir_op PROTO((int op, const char *psrc_path, FNODE *pflist, char *pdst_path, uint16_t *pfcnt, uint16_t *pdcnt, uint32_t *psize));
BOOLEAN par_chk PROTO((const char *psrc_path, FNODE *pflist, char *pdst_path));
BOOLEAN fun_wdst PROTO((PNODE *pspath, APP *app, int obid));
BOOLEAN fun_file2win PROTO((PNODE *pn_src, char *spec, APP *app, FNODE *fn_dest));
VOID fun_win2desk PROTO((int16_t wh, int16_t obj));
BOOLEAN fun_f2any PROTO((int16_t sobj, DESKWIN *wn_dest, APP *an_dest, FNODE *fn_dest, int16_t dobj));
VOID fun_desk2win PROTO((int16_t wh, int16_t obj));
BOOLEAN fun_d2desk PROTO((int16_t dobj));
BOOLEAN desk1_drag PROTO((int16_t wh, int16_t dest_wh, int16_t sobj, int16_t dobj));
VOID add_fname PROTO((char *path, const char *name));
VOID del_fname PROTO((char *path));
VOID del_fname PROTO((char *path));
VOID get_fname PROTO((const char *pstr, char *newstr));
BOOLEAN dos_error PROTO((NOTHING));
VOID add_path PROTO((char *path, const char *name));


/*
 * deskobj.c
 */
extern OBJECT const gl_sampob[2];

int16_t obj_walloc PROTO((int16_t x, int16_t y, int16_t w, int16_t h));
VOID obj_wfree PROTO((int16_t obj, int16_t x, int16_t y, int16_t w, int16_t h));
int16_t obj_ialloc PROTO((int16_t wparent, int16_t x, int16_t y, int16_t w, int16_t h));


/*
 * deskdisk.c
 */
VOID fc_start PROTO((const char *source, int16_t op));


/*
 * deskfun.c
 */
extern char *g_buffer;					/* merge string buffer  */

BOOLEAN newfolder PROTO((DESKWIN *win));


/*
 * deskinf.c
 */
extern THEDSK *thedesk;

char *escan_str PROTO((const char *pcurr, char *ppstr)); /* also referenced by AES */
char *escani_str PROTO((const char *pcurr, char **ppstr));
char *scan_2 PROTO((const char *pcurr, int16_t *pwd)); /* also referenced by AES */
char *save_2 PROTO((char *pcurr, uint16_t wd)); /* also referenced by AES */
char *save_sstr PROTO((char *pcurr, const char *pstr));
BOOLEAN read_inf PROTO((NOTHING));
VOID save_inf PROTO((BOOLEAN todisk));
VOID app_posicon PROTO((int16_t colx, int16_t coly, int16_t *px, int16_t *py));
VOID app_mtoi PROTO((int16_t newx, int16_t newy, int16_t *px, int16_t *py));
VOID inf_setsize PROTO((const VOIDPTR p1, char *buf, OBJECT *tree, int16_t obj, BOOLEAN flag));


/*
 * deskins.c
 */
VOID cp_iblk PROTO((const ICONBLK *src_iblk, ICONBLK *dest_iblk));
VOID rm_icons PROTO((NOTHING));
BOOLEAN ins_disk PROTO((APP *app));
VOID cl_delay PROTO((NOTHING));
BOOLEAN ins_app PROTO((char *name, APP *app));


/*
 * deskfpd.c
 */
VOID pn_init PROTO((NOTHING));
VOID fpd_parse PROTO((const char *pspec, int16_t *pdrv, char *ppath, char *pname, char *pext));
PNODE *pn_open PROTO((int16_t drive, const char *path, const char *name, const char *ext, uint16_t attr));
VOID pn_free PROTO((PNODE *thepath));
FNODE *pn_sort PROTO((int16_t lstcnt, FNODE *pflist));
int pn_folder PROTO((PNODE *thepath));


/*
 * deskmenu.c
 */
VOID menu_verify PROTO((NOTHING));
BOOLEAN do_viewmenu PROTO((int16_t item));
BOOLEAN do_filemenu PROTO((int16_t item));
BOOLEAN do_optnmenu PROTO((int16_t item));
BOOLEAN hd_msg PROTO((NOTHING));
VOID actions PROTO((NOTHING));
int32_t av_mem PROTO((NOTHING));
VOID av_desk PROTO((NOTHING));
VOID cnx_put PROTO((NOTHING));
VOID cnx_get PROTO((NOTHING));
BOOLEAN hd_button PROTO((int16_t clicks, int16_t mx, int16_t my, int16_t bstate, int16_t kstate));
BOOLEAN hd_keybd PROTO((uint16_t key));
BOOLEAN hd_menu PROTO((int16_t title, int16_t item));


/*
 * rainbow.S
 */
VOID rb_start PROTO((NOTHING));
VOID rb_stop PROTO((NOTHING));


/*
 * deskmisc.c
 */
int16_t m_sfirst PROTO((const char *path, int16_t att));
int16_t c_path_alloc PROTO((const char *path));
BOOLEAN hit_disk PROTO((int16_t drive));
ICONBLK *get_icon PROTO((int16_t item));
OBJECT *get_tree PROTO((int16_t item));
char *get_fstring PROTO((int16_t item));
char *get_string PROTO((int16_t item));
DIR *get_dir PROTO((DESKWIN *win, int16_t item));
VOID up_1 PROTO((DESKWIN *win));
VOID up_2 PROTO((DESKWIN *win));
char *put_name PROTO((DESKWIN *win, const char *name));
BOOLEAN in_parent PROTO((OBJECT *obj, int16_t child));
VOID xinf_sset PROTO((OBJECT *obj, int16_t item, const char *buf1));
VOID mice_state PROTO((int16_t state));
VOID desk_wait PROTO((BOOLEAN state));
VOID drawfld PROTO((OBJECT *obj, int16_t which));
VOID drawclip PROTO((OBJECT *obj, int16_t which));
BOOLEAN getcookie PROTO((int32_t cookie, int32_t *p_value)); /* also referenced by AES */
VOID f_str PROTO((OBJECT *obj, int16_t item, int32_t value));
int16_t ch_level PROTO((const char *path));
VOID fm_draw PROTO((LPTREE tree));
VOID do_finish PROTO((OBJECT *obj));
int16_t xform_do PROTO((OBJECT *obj, int16_t which));
VOID fmdodraw PROTO((OBJECT *tree, int16_t item));
VOID lbintoasc PROTO((int32_t longval, char *buffer));
char *r_slash PROTO((const char *path));
BOOLEAN xcut_path PROTO((char *path, char *buffer, int16_t cut));
BOOLEAN cut_path PROTO((char *path));
VOID cat_path PROTO((char *name, char *path));
VOID rep_path PROTO((const char *name, char *path));
int16_t do1_alert PROTO((int16_t item));
VOID rc_center PROTO((GRECT *rec1, GRECT *rec2));
VOID my_itoa PROTO((uint16_t number, char *pnumstr));
VOID fmt_time PROTO((uint16_t time, char *ptime));
VOID fmt_date PROTO((uint16_t date, char *pdate));
long bldstring PROTO((intptr_t dir, char *dst));
char *g_name PROTO((const char *file)); /* also referenced by AES */
VOID save_ext PROTO((const char *path, char *buffer));
VOID save_mid PROTO((char *path, char *buffer));
BOOLEAN chk_par PROTO((const char *srcptr, const char *dstptr));
int16_t fun_alert PROTO((int16_t button, int16_t item, VOIDPTR parms));
BOOLEAN asctobin PROTO((char *ptr, int32_t *value));
VOID wait_msg PROTO((NOTHING));
VOID send_msg PROTO((int16_t type, int16_t whom, int16_t w3, int16_t w4, int16_t w5, int16_t w6, int16_t w7));


/*
 * desksupp.c
 */
BOOLEAN pro_chdir PROTO((int drv, const char *ppath));
int pro_run PROTO((int16_t isgraf, int16_t iscr, int16_t wh, int16_t curr));
VOID desk_clear PROTO((int16_t wh));
VOID desk_verify PROTO((int16_t wh, BOOLEAN changed));
VOID do_wredraw PROTO((int16_t handle, int16_t x, int16_t y, int16_t w, int16_t h));
VOID get_xywh PROTO((OBJECT *olist, int16_t obj, int16_t *px, int16_t *py, int16_t *pw, int16_t *ph));
ICONBLK *get_spec PROTO((OBJECT *tree, int obid));
VOID do_xyfix PROTO((int16_t *px, int16_t *py));
VOID do_wopen PROTO((BOOLEAN new_win, int16_t wh, int16_t curr, int16_t x, int16_t y, int16_t w, int16_t h));
VOID zoom_closed PROTO((BOOLEAN close, int16_t w_id, int16_t xicon, int16_t yicon));
VOID do_wfull PROTO((int16_t wh));
BOOLEAN do_diropen PROTO((DESKWIN *pw, BOOLEAN new_win, int16_t curr_icon, int16_t drv, const char *ppath, const char *pname, const char *pext, GRECT *pt));
BOOLEAN do_aopen PROTO((DESKWIN *win, APP *pa, BOOLEAN isapp, int16_t curr, int16_t drv, const char *path, const char *name));
BOOLEAN do_dopen PROTO((int16_t curr));
BOOLEAN do_fopen PROTO((DESKWIN *pw, int16_t curr, int16_t drv, const char *ppath, const char *pname, const char *pext));
BOOLEAN open_item PROTO((int16_t curr));
BOOLEAN show_item PROTO((int16_t curr));
BOOLEAN do_format PROTO((int16_t curr));
BOOLEAN true_closewnd PROTO((DESKWIN *pw));
BOOLEAN w_setpath PROTO((DESKWIN *pw, int drv, const char *path, const char *name, const char *ext));
BOOLEAN close_window PROTO((DESKWIN *pw, BOOLEAN trueclose));
BOOLEAN pro_chroot PROTO((int drive));



/*
 * deskpref.c
 */
BOOLEAN desk_pref PROTO((NOTHING));


/*
 * deskopen.c
 */
VOID open_def PROTO((NOTHING));
VOID ch_path PROTO((DESKWIN *win));
BOOLEAN open_subdir PROTO((DESKWIN *win, int16_t icon, BOOLEAN opendisk, BOOLEAN init, BOOLEAN redraw));
VOID close_path PROTO((DESKWIN *win));
VOID close_top PROTO((NOTHING));
VOID open_file PROTO((DESKWIN *win, int16_t item, const char *tail));
BOOLEAN open_disk PROTO((int16_t icon, const char *path, BOOLEAN init));
VOID do_box PROTO((DESKWIN *win, int16_t item, int16_t desk, int16_t open, BOOLEAN openfull));
BOOLEAN ch_drive PROTO((int16_t id));
VOID upfdesk PROTO((char *s, char *new));
VOID xvq_chcells PROTO((int16_t *num));


/*
 * deskpref.c
 */


/*
 * desksele.c
 */
BOOLEAN x_select PROTO((NOTHING));
BOOLEAN x_next PROTO((const char **name, int16_t *type));
BOOLEAN x_first PROTO((const char **name, int16_t *type));
APP *i_find PROTO((int16_t wh, int16_t item, FNODE **ppf, BOOLEAN *pisapp));
BOOLEAN i_next PROTO((int16_t start, OBJECT *obj, int16_t *itemout));


/*
 * deskshel.c
 */
BOOLEAN ch_tail PROTO((const char *ptr, char *tail));
VOID launch_pref PROTO((NOTHING));
BOOLEAN set_dir PROTO((const char *path));
VOID exec_file PROTO((const char *infile, DESKWIN *win, int16_t item, const char *intail));
VOID run_it PROTO((const char *file, char *tail, BOOLEAN graphic, BOOLEAN setdir));


/*
 * deskshow.c
 */
VOID showfile PROTO((const char *fname, int mode));


/*
 * deskact.c
 */
#define LEN_FNODE 45
#define MIN_HINT 2

BOOLEAN act_chg PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t obj, GRECT *pc, uint16_t chgvalue, int16_t dochg, int16_t dodraw, int16_t chkdisabled));
VOID act_bsclick PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t mx, int16_t my, int16_t keystate, GRECT *pc, int16_t dclick));
int16_t act_bdown PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t mx, int16_t my, GRECT *pc, int16_t *pdobj));
VOID act_allchg PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t ex_obj, GRECT *pt, GRECT *pc, int16_t chgvalue, BOOLEAN dochg, BOOLEAN dodraw, BOOLEAN dox));


/*
 * deskapp3.c
 */
VOID app_blddesk PROTO((NOTHING));
APP *app_afind PROTO((BOOLEAN isdesk, int16_t a_type, int16_t obid, char *pname, BOOLEAN *pisapp));


/*
 * desktop.c
 */
extern int16_t pglobal[];
extern int16_t gl_apid;

BOOLEAN deskmain PROTO((NOTHING));
VOID ch_cache PROTO((BOOLEAN set));



/*
 * extern references from AES
 */
extern int16_t gl_wchar;
extern int16_t gl_hchar;
extern int16_t gl_wbox;
extern int16_t gl_hbox;
extern int16_t gl_handle;
extern int16_t contrl[];
extern int16_t intin[];
extern int16_t intout[];
extern int16_t ptsin[];
extern int16_t gl_btrue;
extern int16_t gl_restype;
extern BOOLEAN gl_rschange;
extern int16_t gl_ncols;
extern int16_t gl_nrows;
extern BOOLEAN sh_iscart;
extern int16_t gl_bvdisk;
extern int16_t gl_bvhard;
extern int16_t gl_width;
extern VOIDPTR ad_intin;



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

const char *scasb PROTO((const char *p, char b));
char *strscn PROTO((const char *src, char *dst, char stp));
size_t strlen PROTO((const char *p1));
BOOLEAN streq PROTO((const char *p1, const char *p2));
VOID fmt_str PROTO((const char *instr, char *outstr));
VOID unfmt_str PROTO((const char *instr, char *outstr));
VOID inf_sset PROTO((OBJECT *tree, int16_t obj, const char *pstr));
VOID fs_sget PROTO((LPTREE tree, int16_t obj, char *pstr));
int16_t inf_gindex PROTO((LPTREE tree, int16_t baseobj, int16_t numobj));
VOID merge_str PROTO((char *pdst, const char *ptmp, const VOIDPTR parms));
int16_t wildcmp PROTO((const char *pwild, const char *ptest));
VOID bfill PROTO((int16_t num, char bval, VOIDPTR addr));
int16_t min PROTO((int16_t a, int16_t b));
int16_t max PROTO((int16_t a, int16_t b));
VOID rc_copy PROTO((const GRECT *src, GRECT *dst));
#define RC_COPY(src, dst) LWCOPY(dst, src, 4)
BOOLEAN rc_equal PROTO((const GRECT *p1, const GRECT *p2));
BOOLEAN rc_intersect PROTO((const GRECT *p1, GRECT *p2));
VOID rc_union PROTO((const GRECT *p1, GRECT *p2));
VOID rc_constrain PROTO((const GRECT *pc, GRECT *pt));
BOOLEAN inside PROTO((int16_t x, int16_t y, const GRECT *pt));
VOID LBCOPY PROTO((VOIDPTR dst, const VOIDPTR src, int cnt));
int16_t strchk PROTO((const char *s, const char *t));
BOOLEAN cart_init PROTO((NOTHING));
BOOLEAN cart_sfirst PROTO((char *pdta, int16_t attr));
BOOLEAN cart_snext PROTO((NOTHING));
int toupper PROTO((int ch));
int isdrive PROTO((NOTHING));
int16_t rom_ram PROTO((int which, intptr_t pointer, uint16_t len));
int16_t inf_what PROTO((OBJECT *tree, int16_t ok, int16_t cncl));
BOOLEAN inf_file PROTO((char *ppath, FNODE *info, BOOLEAN isdir));
BOOLEAN inf_disk PROTO((char drv_id));


int32_t trap PROTO((short code, ...));
int16_t trp14 PROTO((short code, ...));
int32_t trp13 PROTO((short code, ...));

int mediach PROTO((int16_t drv));

VOID gsx_attr PROTO((uint16_t text, uint16_t mode, uint16_t color));
VOID gsx_xline PROTO((int16_t ptscount, int16_t *ppoints));
VOID avro_cpyfm PROTO((int16_t wr_mode, int16_t *pxyarray, FDB *psrcMFDB, FDB *pdesMFDB));
VOID av_hardcopy PROTO((NOTHING));
int16_t wind_grget PROTO((short handle, short field, GRECT *gr));
int16_t ap_bvset PROTO((int16_t bvdisk, int16_t bvhard));


int16_t dr_code PROTO((PARMBLK *parm));

#if LINEF_HACK
int16_t hex_dig PROTO((char achar));
char uhex_dig PROTO((int16_t wd));
const char *inf_xdesk PROTO((const char *pcurr, APP *app));
VOID app_reverse PROTO((NOTHING));
BOOLEAN inf_fifo PROTO((OBJECT *tree, int16_t foldersidx, int16_t filesidx, char *ppath));
VOID inf_dttmsz PROTO((OBJECT *tree, FNODE *info, int16_t dateidx, int16_t timeidx, int16_t sizeidx, int32_t *size));
VOID fn_init PROTO((NOTHING));
BOOLEAN fpd_bldspec PROTO((int16_t drive, const char *ppath, const char *pname, const char *pext, char *pspec));
VOID fn_pfree PROTO((VOIDPTR *ptr));
FNODE *fn_alloc PROTO((NOTHING));
PNODE *pn_alloc PROTO((NOTHING));
int pn_fcomp PROTO((FNODE *pf1, FNODE *pf2, int which));
#endif
