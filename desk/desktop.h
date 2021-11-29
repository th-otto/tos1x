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

#define CMD_FORMAT  0
#define CMD_COPY    1

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

#define PROGRAM   0
#define FOLDER    1
#define DRIVE     2
#define TRASHCAN  3
#define CARTICON  4

#define TOS     0
#define PRG     3               /* or icon type         */
#define TTP     8
#define DISK    7

#define S_ICON  0               /* view as icon */
#define S_TEXT  1               /* view as text */

#define S_NAME  0               /* sort as name */
#define S_DATE  1
#define S_SIZE  2
#define S_TYPE  3
#define S_NO    4               /* no sort      */

#define MAX_LEVEL       8       /* max level of folder  */

#define DESKICON        0
#define WINICON         1

#define APP_NODE 48     /* number of user definable file type   */
#define APP_DESK 48     /* number of desktop icon should equal to number of */
                        /* icons in background dialogue         */
        
#define OP_DELETE       0       /* file operation definitions   */
#define OP_COPY         1
#define OP_MOVE         2
#define OP_COUNT        3

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

typedef struct	app
{
	/*  0 */ struct app *a_next;     /* app pointer */
	/*  4 */ int16_t a_apptype;
	/*  6 */ int16_t a_type; 		/* file type */
	/*  8 */ char a_unused2[2];
#define a_doc a_unused2  /* tmp hack until desktop source has been completed */
	/* 10 */ char *a_path;
	/* 14 */ char *a_name; 			/* app name */
	/* 18 */ int16_t a_icon; 		/* icon number */
	/* 20 */ int16_t a_flags;
	/* 22 */ int16_t a_char;
	/* 24 */ int16_t a_x;
	/* 26 */ int16_t a_y;
	/* 28 */
} APP;

typedef struct idtype
{
	int16_t i_type;
	int16_t i_icon;
	ICONBLK i_iblk;
	const char *i_path;
	char i_name[NAMELEN];
} IDTYPE;


typedef struct {
	/*     0 */ char unused1[13350];
	/* 13350 */ int16_t *msgbuf[8];		
	/* 13366 */ int16_t *p_msgbuf;		
	/* 13370 */ GRECT full;				/* full window size value */
	/*     0 */ char unused2[272];
	/* 13650 */ char *str;				/* rsrc_gaddr result */
	/* 13654 */ OBJECT *rtree[16];		/* resource trees */
	/* 13718 */ char unused6[18];
	/* 13736 */ GRECT r_dicon;			/* real time desktop icon size */
	/* 13744 */ int16_t o13744;
	/* 13746 */ int16_t o13746;
	/* 13748 */ int16_t o13748[9];
	/* 13766 */ int16_t o13766[9];
	/* 13784 */ int16_t o13784[5];
	/* 13794 */ int16_t o13794;
	/* 13796 */ int16_t o13796;
	/* 13798 */ int16_t o13798;
	/* 13800 */ char unused3[16];
	/* 13816 */ GRECT dicon;			/* desktop icon size */
	/* 13824 */ char afile[SIZE_AFILE];
	/* 18016 */ int16_t size_afile;		/* length of recently read desktop.inf */
	/* 18018 */ char appbuf[SIZE_AFILE];
	/* 22210 */ APP *appnode;			/* app buffer array */
	/* 22214 */ APP app[NUM_ANODES];	/* app buffer array */
	/* 23110 */ APP *appfree;			/* app buffer free list */
	/* 23114 */ APP *applist;			/* app buffer list */
	/* 23118 */ ICONBLK iconaddr[NUM_IB + 1];	/* desktop icon dialogue address */
	/* 23322 */ ICONBLK icona2[NUM_IB + 1];
	/* 23526 */ char unused4[24];
	/* 23550 */ int16_t s_sort;			/* sort item */
	/* 23552 */ int16_t s_view;			/* view item */
	/* 23554 */ BOOLEAN ccopy_save;		/* copy ? */
	/* 23556 */ BOOLEAN cdele_save;		/* delete ? */
	/* 23558 */ BOOLEAN cbit_save;		/* bitblt */
	/* 23560 */ int16_t pref_save;		/* screen pref */
	/* 23562 */ BOOLEAN write_save;		/* write ? */
	/* 23564 */ DESKWIN winpd[MAXWIN];	/* window process structure */
	/* 24652 */ char unused5[6332];
	/* 30440 */ char autofile[PATHLEN];
	/* 30568 */
	
} THEDSK;

/*
 * Symbolic "drive letter" for the cartridge.
 * Must be lowercase. This is only handled by
 * the desktop, not by GEMDOS.
 */
#define CHAR_FOR_CARTRIDGE 'c'


/*
 * deskupda.c
 */
extern char *q_addr;							/* Inf file address */
extern BOOLEAN q_change;						/* Inf file is changed */

VOID q_inf PROTO((NOTHING));
VOID q_sea PROTO((char *old, char *new));
VOID q_write PROTO((NOTHING));


/*
 * deskwin.c
 */
VOID winfo PROTO((DESKWIN *win));
DESKWIN *w_gnext PROTO((NOTHING));
DESKWIN *w_gfirst PROTO((NOTHING));
VOID up_allwin PROTO((const char *path, BOOLEAN full));
BOOLEAN up_win PROTO((DESKWIN *win, BOOLEAN mediac));
VOID bottop PROTO((NOTHING));
BOOLEAN path_alloc PROTO((int16_t level));
VOID free_path PROTO((NOTHING));
VOID clr_allwin PROTO((NOTHING));
VOID clr_xwin PROTO((DESKWIN *win, BOOLEAN infoupdate));
VOID srl_verbar PROTO((DESKWIN *win, uint16_t pos));
VOID srl_hzbar PROTO((DESKWIN *win, uint16_t pos));
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
VOID close_window PROTO((int16_t handle, BOOLEAN closeit));
VOID free_windows PROTO((NOTHING));
VOID do_redraw PROTO((int16_t handle, GRECT *pc, int16_t which));
VOID do_xyfix PROTO((GRECT *pc));


/*
 * deskact.c
 */
extern BOOLEAN back_update;						/* update background    */

BOOLEAN ch_obj PROTO((int16_t mx, int16_t my, DESKWIN **win, int16_t *item, int16_t *type));
BOOLEAN ch_undo PROTO((NOTHING));
VOID file_op PROTO((const char *dest, int16_t mode));
BOOLEAN build_rect PROTO((OBJECT *obj, GRECT *rect, int16_t w, int16_t h));
VOID r_box PROTO((int16_t id, DESKWIN *win));
VOID hd_down PROTO((int16_t sitem, int16_t stype, DESKWIN *swin));
int16_t make_icon PROTO((int16_t drive, int16_t icon, int16_t type, const char *text));


/*
 * deskapp.c
 */
extern int16_t const ftab[];

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
VOID graf_rubbox PROTO((int16_t xorigin, int16_t yorigin, int16_t wmin, int16_t hmin, int16_t *pwend, int16_t phend));
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
int16_t wind_calc PROTO((int16_t wctype, uint16_t kind, int16_t x, int16_t y, int16_t w, int16_t h, int16_t px, int16_t py, int16_t pw, int16_t ph));


/*
 * deskbutt.c
 */
int16_t av_icon PROTO((NOTHING));
VOID clr_dicons PROTO((NOTHING));
VOID hd_button PROTO((int16_t clicks, int16_t kstate, int16_t mx, int16_t my));


/*
 * deskdir.c
 */
extern int f_level;							/* the current depth of the directory path */
extern int d_display;						/* display copy box or not      */
extern int f_rename;

BOOLEAN dofiles PROTO((const char *s, const char *d, int16_t code, int32_t *ndirs, int32_t *nfiles, int32_t *tsize, int16_t type, BOOLEAN multiple));
BOOLEAN doright PROTO((int flag));


/*
 * deskdisk.c
 */
VOID fc_start PROTO((const char *source, int16_t op));


/*
 * deskfile.c
 */
VOID pri_win PROTO((NOTHING));
VOID newfolder PROTO((DESKWIN *win));
VOID sort_file PROTO((DESKWIN *win, int16_t mode));
VOID set_newview PROTO((int16_t index, DESKWIN *win));
int16_t read_files PROTO((DESKWIN *win, int16_t attr));


/*
 * deskinf.c
 */
extern THEDSK *thedesk;

char *escan_str PROTO((const char *pcurr, char *ppstr)); /* also referenced by AES */
char *scan_2 PROTO((const char *pcurr, int16_t *pwd)); /* also referenced by AES */
char *save_2 PROTO((char *pcurr, uint16_t wd)); /* also referenced by AES */
char *save_sstr PROTO((char *pcurr, const char *pstr));
BOOLEAN read_inf PROTO((NOTHING));
VOID save_inf PROTO((BOOLEAN todisk));
VOID app_posicon PROTO((int16_t colx, int16_t coly, int16_t *px, int16_t *py));
VOID app_mtoi PROTO((int16_t newx, int16_t newy, int16_t *px, int16_t *py));


/*
 * deskins.c
 */
VOID cp_iblk PROTO((const ICONBLK *src_iblk, ICONBLK *dest_iblk));
VOID rm_icons PROTO((NOTHING));
VOID ins_icons PROTO((NOTHING));
VOID cl_delay PROTO((NOTHING));
VOID ins_app PROTO((NOTHING));


/*
 * deskmem.c
 */
extern char *lp_start;
extern uint16_t apsize;

BOOLEAN apbuf_init PROTO((NOTHING));
BOOLEAN mem_init PROTO((NOTHING));
const char *lp_fill PROTO((const char *path, const char **buf));
BOOLEAN lp_collect PROTO((NOTHING));


/*
 * deskmenu.c
 */
extern int16_t d_exit;		/* desktop exit flag	*/
extern BOOLEAN o_status;							/* for o_select */
extern DESKWIN *o_win;
extern int16_t o_type;
extern int16_t o_item;

VOID menu_verify PROTO((NOTHING));
VOID do_view PROTO((int16_t msgbuff));
VOID do_file PROTO((int16_t msgbuff));
VOID hd_msg PROTO((int16_t *msgbuff));
VOID actions PROTO((NOTHING));
int32_t av_mem PROTO((NOTHING));
VOID av_desk PROTO((NOTHING));


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
BOOLEAN getcookie PROTO((int32_t cookie, int32_t *p_value)); /* also referenced by AES */
VOID f_str PROTO((OBJECT *obj, int16_t item, int32_t value));
int16_t ch_level PROTO((const char *path));
OBJECT *fm_draw PROTO((int16_t item));
VOID do_finish PROTO((OBJECT *obj));
int16_t xform_do PROTO((OBJECT *obj, int16_t which));
int16_t fmdodraw PROTO((int16_t item, int16_t which));
VOID lbintoasc PROTO((int32_t longval, char *buffer));
char *r_slash PROTO((const char *path));
BOOLEAN xcut_path PROTO((char *path, char *buffer, int16_t cut));
BOOLEAN cut_path PROTO((char *path));
VOID cat_path PROTO((char *name, char *path));
VOID rep_path PROTO((const char *name, char *path));
VOID rep_all PROTO((char *path));
int16_t do_alert PROTO((int16_t button, int16_t item));
BOOLEAN dos_error PROTO((int16_t button, int16_t item));
int16_t do1_alert PROTO((int16_t item));
VOID rc_center PROTO((GRECT *rec1, GRECT *rec2));
VOID my_itoa PROTO((uint16_t number, char *pnumstr));
VOID fmt_time PROTO((uint16_t time, char *ptime));
VOID fmt_date PROTO((uint16_t date, char *pdate));
char * bldstring PROTO((DIR *dir, char *dst));
const char *g_name PROTO((const char *file)); /* also referenced by AES */
VOID save_ext PROTO((const char *path, char *buffer));
VOID save_mid PROTO((char *path, char *buffer));
BOOLEAN chk_par PROTO((const char *srcptr, const char *dstptr));
int16_t fill_string PROTO((int16_t button, int16_t item, VOIDPTR parms));
BOOLEAN asctobin PROTO((char *ptr, int32_t *value));
VOID wait_msg PROTO((NOTHING));


/*
 * deskpref.c
 */
VOID desk_pref PROTO((NOTHING));


/*
 * deskopen.c
 */
VOID open_def PROTO((NOTHING));
VOID ch_path PROTO((DESKWIN *win));
BOOLEAN open_subdir PROTO((DESKWIN *win, int16_t icon, BOOLEAN opendisk, BOOLEAN init, BOOLEAN redraw));
VOID show_item PROTO((NOTHING));
VOID close_path PROTO((DESKWIN *win));
VOID close_top PROTO((NOTHING));
VOID open_item PROTO((int16_t item, int16_t type, DESKWIN *win));
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
extern BOOLEAN x_status;			/* for x_select         */
extern int16_t x_type;				/* ditto            */
extern DESKWIN *x_win;				/* ditto            */
extern int16_t d_dir;				/* count how many folders are selected inside the window */

VOID x_del PROTO((NOTHING));
BOOLEAN o_select PROTO((NOTHING));
BOOLEAN x_select PROTO((NOTHING));
BOOLEAN x_next PROTO((const char **name, int16_t *type));
BOOLEAN x_first PROTO((const char **name, int16_t *type));
BOOLEAN i_find PROTO((int16_t mx, int16_t my, DESKWIN **winout, int16_t *item, int16_t *type));
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
BOOLEAN showfile PROTO((const char *fname, int mode));


/*
 * deskstor.c
 */
extern char dr[];						/* drives flag          */
extern BOOLEAN p_timedate;				/* preserve time and date   */
extern int16_t d_nrows;					/* number of rows used by show  */
extern int16_t d_level;					/* window path level        */
extern char *d_path;					/* window path buffer       */
extern int16_t d_xywh[18];				/* disk icon pline points   */
extern int16_t f_xywh[18];				/* file icon pline points   */
extern OBJECT *background;				/* desktop object address   */
extern int16_t maxicon;					/* max number of desktop icons  */
extern intptr_t gh_buffer;				/* ghost icon outline buffer address */
extern IDTYPE *backid;					/* background icon type definition  */
extern DTA dtabuf;						/* dta buffer   */
extern uint16_t windspec;				/* window pattern   */
extern char path1[PATHLEN];				/* utility path     */
extern char path2[PATHLEN];
extern char *path3;
extern char inf_path[PATHLEN];			/* store the inf path   */
extern char *g_buffer;					/* merge string buffer  */
extern char comtail[PATHLEN];			/* comtail tail buffer */
extern DESKWIN *winhead;				/* head of window list      */
extern GRECT fobj;						/* file object  */
extern char const getall[];
extern char const bckslsh[];
extern char const curall[];
extern char const baklvl[];
extern char const wildext[];
extern char const wilds[];
extern char const noext[];
extern char const Nostr[];
extern char const infdata[];
extern char const infpath[];
extern char const Nextline[];


/*
 * desktop.c
 */
extern BOOLEAN m_st;						/* machine type flag    */
extern int16_t m_cpu;						/* cpu type     */
extern int16_t numicon;						/* the number of icon in the resource   */
extern char restable[];						/* resolution table */
extern int16_t d_maxcolor;
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
#if AESVERSION >= 0x200
extern BOOLEAN ctldown;
#endif
extern int16_t gl_restype;
extern BOOLEAN gl_rschange;
extern int16_t gl_ncols;
extern int16_t gl_nrows;
extern BOOLEAN sh_iscart;
extern int16_t gl_bvdisk;
extern int16_t gl_bvhard;
extern int16_t gl_width;

#if TOSVERSION >= 0x400
extern uint16_t d_rezword;
#endif


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
VOID merge_str PROTO((char *pdst, const char *ptmp, VOIDPTR parms));
int16_t wildcmp PROTO((const char *pwild, const char *ptest));
VOID bfill PROTO((int16_t num, char bval, VOIDPTR addr));
int16_t min PROTO((int16_t a, int16_t b));
int16_t max PROTO((int16_t a, int16_t b));
VOID rc_copy PROTO((const GRECT *src, GRECT *dst));
BOOLEAN rc_equal PROTO((const GRECT *p1, const GRECT *p2));
BOOLEAN rc_intersect PROTO((const GRECT *p1, GRECT *p2));
VOID rc_union PROTO((const GRECT *p1, GRECT *p2));
VOID rc_constrain PROTO((const GRECT *pc, GRECT *pt));
BOOLEAN inside PROTO((int16_t x, int16_t y, const GRECT *pt));
VOID LBCOPY PROTO((VOIDPTR dst, const VOIDPTR src, int cnt));
int16_t strchk PROTO((const char *s, const char *t));
BOOLEAN cart_init PROTO((NOTHING));
BOOLEAN cart_sfirst PROTO((char *pdta, int16_t attr));
BOOLEAN c_sfirst PROTO((const char *path));
BOOLEAN cart_snext PROTO((NOTHING));
int toupper PROTO((int ch));
int isdrive PROTO((NOTHING));
int16_t rom_ram PROTO((int which, intptr_t pointer));
int16_t inf_what PROTO((OBJECT *tree, int16_t ok, int16_t cncl));

int32_t trap PROTO((short code, ...));
int32_t trp14 PROTO((short code, ...));
int16_t trp14int PROTO((short code, ...));
int32_t trp13 PROTO((short code, ...));

VOID mediach PROTO((int16_t drv));

VOID gsx_attr PROTO((uint16_t text, uint16_t mode, uint16_t color));
VOID gsx_xline PROTO((int16_t ptscount, int16_t *ppoints));
VOID avro_cpyfm PROTO((int16_t wr_mode, int16_t *pxyarray, FDB *psrcMFDB, FDB *pdesMFDB));
VOID av_hardcopy PROTO((NOTHING));
