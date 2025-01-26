typedef unsigned char   undefined;

typedef unsigned char    byte;
typedef unsigned long    dword;
typedef unsigned long long    qword;
typedef signed char    schar;
typedef unsigned char    uchar;
typedef unsigned int    uint;
typedef unsigned long    ulong;
typedef unsigned long long    ulonglong;
typedef unsigned char    undefined1;
typedef unsigned int    undefined2;
typedef unsigned long    undefined4;
typedef unsigned long long    undefined6;
typedef unsigned long long    undefined8;
typedef unsigned short    ushort;
typedef unsigned int    word;
typedef struct _DOSTIME _DOSTIME, *P_DOSTIME;

struct _DOSTIME {
    ushort time;
    ushort date;
};

typedef struct ACCPD ACCPD, *PACCPD;

typedef struct AESPD AESPD, *PAESPD;

typedef struct UDA UDA, *PUDA;

typedef struct CDA CDA, *PCDA;

typedef struct EVB EVB, *PEVB;

typedef short int16_t;

typedef ushort uint16_t;

typedef uint16_t EVSPEC;

typedef ulong uint32_t;

typedef struct CQUEUE CQUEUE, *PCQUEUE;

typedef struct PD PD, *PPD;

typedef long int32_t;

typedef struct DTAINFO DTAINFO, *PDTAINFO;

typedef struct DND DND, *PDND;

typedef ushort CLNO;

typedef struct OFD OFD, *POFD;

typedef struct DMD DMD, *PDMD;

typedef short RECNO;

struct EVB {
    struct EVB *e_nextp;
    struct EVB *e_link;
    struct EVB *e_pred;
    struct PD *e_pd;
    int32_t e_parm;
    int16_t e_flag;
    EVSPEC e_mask;
    int32_t e_return;
};

struct CQUEUE {
    int16_t c_buff[8];
    int16_t c_front;
    int16_t c_rear;
    int16_t c_cnt;
};

struct CDA {
    uint16_t c_flags;
    struct EVB *c_iiowait;
    struct EVB *c_msleep;
    struct EVB *c_bsleep;
    struct CQUEUE c_q;
};

struct UDA {
    int16_t u_insuper;
    uint32_t u_regs[15];
    uint32_t *u_spsuper;
    uint32_t *u_spuser;
    uint32_t u_super[448];
    uint32_t u_supstk;
};

struct PD {
    long p_lowtpa;
    long p_hitpa;
    long p_tbase;
    long p_tlen;
    long p_dbase;
    long p_dlen;
    long p_bbase;
    long p_blen;
    struct DTAINFO *p_xdta;
    struct PD *p_parent;
    long p_flags;
    char *p_env;
    char p_uft[6];
    char p_lddrv;
    char p_curdrv;
    long p_1fill[2];
    byte p_curdir[16];
    byte p_2fill[16];
    long p_3fill[2];
    long p_dreg[1];
    long p_areg[5];
    char p_cmdlin[128];
};

struct AESPD {
    struct AESPD *p_link;
    struct AESPD *p_thread;
    struct UDA *p_uda;
    char p_name[8];
    struct CDA *p_cda;
    long p_ldaddr;
    int16_t p_pid;
    int16_t p_stat;
    EVSPEC p_evbits;
    EVSPEC p_evwait;
    EVSPEC p_evflg;
    struct EVB *p_evlist;
    struct EVB *p_qdq;
    struct EVB *p_qnq;
    char *p_qaddr;
    int16_t p_qindex;
    char p_queue[128];
};

struct ACCPD {
    struct AESPD ac_pd;
    struct UDA ac_uda;
    struct CDA ac_cda;
    struct EVB ac_evb[5];
};

struct DTAINFO { /* Disk Transfer Area */
    char dt_name[12];
    char dt_att_searchUNALIGNED;
    long dt_posUNALIGNED;
    struct DND *dt_dndUNALIGNED;
    char dt_fattr;
    struct _DOSTIME dt_td;
    long dt_fileln;
    char dt_fname[14];
};

struct DMD { /* Drive Media Block */
    RECNO m_recoff[3];
    short m_drvnum;
    RECNO m_fsiz;
    RECNO m_clsiz;
    short m_clsizb;
    short m_recsiz;
    CLNO m_numcl;
    short m_clrlog;
    short m_clrm;
    short m_rblog;
    short m_rbm;
    short m_clblog; /* Moved */
    struct OFD *m_fatofd; /* Moved */
    short m_1fat;
    CLNO m_fatrec;
    struct DND *m_dtl;
    short m_16; /* Moved */
    short m_unused;
};

struct DND { /* Directory Node Descriptor */
    char d_name[11];
    char d_fill;
    ushort d_flag;
    CLNO d_strtcl;
    struct _DOSTIME d_td;
    struct OFD *d_ofd;
    struct DND *d_parent;
    struct DND *d_left;
    struct DND *d_right;
    struct DMD *d_drv;
    struct OFD *d_dirfil;
    ulong d_dirpos;
    long d_scan;
    struct OFD *d_files;
    ushort d_usecount;
};

struct OFD {
    struct OFD *o_link;
    ushort o_flag;
    struct _DOSTIME o_td;
    short o_strtcl;
    ulong o_fileln;
    void *o_dmd;
    void *o_dnode;
    struct OFD *o_dirfil;
    long o_dirbyt;
    long o_bytnum;
    short o_curcl;
    short o_currec;
    short o_curbyt;
    short o_usecnt;
    struct OFD *o_thread;
    short o_mod;
};

typedef struct AESPB AESPB, *PAESPB;

struct AESPB {
    int16_t *control;
    int16_t *global;
    int16_t *intin;
    int16_t *intout;
    void **addrin;
    void **addrout;
};

typedef struct APP APP, *PAPP;

struct APP {
    struct APP *a_next;
    short a_apptype;
    short a_type;
    short a_obid;
    char *a_pappl;
    char *a_pdata;
    short a_aicon;
    short a_dicon;
    short a_char;
    short a_x;
    short a_y;
};

typedef struct ATTRIBUTE ATTRIBUTE, *PATTRIBUTE;

typedef struct FONT_HEAD FONT_HEAD, *PFONT_HEAD;

struct FONT_HEAD {
    short font_id;
    short point;
    char name[32];
    ushort first_ade;
    ushort last_ade;
    ushort top;
    ushort ascent;
    ushort half;
    ushort descent;
    ushort bottom;
    ushort max_char_width;
    ushort max_cell_width;
    ushort left_offset;
    ushort right_offset;
    ushort thicken;
    ushort ul_size;
    ushort lighten;
    ushort skew;
    ushort flags;
    byte *hor_table;
    ushort *off_table;
    ushort *dat_table;
    ushort form_width;
    ushort form_height;
    struct FONT_HEAD *next_font;
    ushort font_seg;
};

struct ATTRIBUTE { /* Virtual workstation attributes */
    short chup;
    short clip;
    struct FONT_HEAD *cur_font;
    short dda_inc;
    short multifill;
    short patmsk;
    ushort *patptr;
    short pts_mode;
    short *scrtchp;
    short scrpt2;
    short style;
    short t_sclsts;
    short fill_color;
    short fill_index;
    short fill_per;
    short fill_style;
    short h_align;
    short handle;
    short line_beg;
    short line_color;
    short line_end;
    short line_index;
    short line_width;
    struct FONT_HEAD *loaded_fonts;
    short mark_color;
    short mark_height;
    short mark_index;
    short mark_scale;
    struct ATTRIBUTE *next_work;
    short num_fonts;
    short scaled;
    struct FONT_HEAD scratch_head;
    short text_color;
    short ud_ls;
    short ud_patrn[64];
    short v_align;
    short wrt_mode;
    short xfm_mode;
    short xmn_clip;
    short xmx_clip;
    short ymn_clip;
    short ymx_clip;
};

typedef struct BCB BCB, *PBCB;

struct BCB { /* Buffer Control Block */
    struct BCB *b_link;
    short b_bufdrv;
    short b_buftyp;
    RECNO b_bufrec;
    short b_dirty;
    struct DMD *b_dm;
    char *b_bufr;
};

typedef struct BITBLK BITBLK, *PBITBLK;

struct BITBLK {
    void *bi_pdata;
    short bi_wb;
    short bi_hl;
    short bi_x;
    short bi_y;
    short bi_color;
};

typedef struct BLKDEV BLKDEV, *PBLKDEV;

typedef struct BPB BPB, *PBPB;

typedef struct GEOMETRY GEOMETRY, *PGEOMETRY;

struct GEOMETRY {
    short tracks;
    short sides;
    short spc;
    short spt;
    short hidden;
};

struct BPB { /* BIOS Parameters Block */
    short recsiz;
    short clsiz;
    short clsizb;
    short rdlen;
    short fsiz;
    short fatrec;
    short datrec;
    short numcl;
    short b_flags;
};

struct BLKDEV { /* Block Device */
    struct BPB bpb;
    struct GEOMETRY geometry;
    byte serial[3];
    byte filler;
};

typedef struct DESKWIN DESKWIN, *PDESKWIN;

typedef struct PNODE PNODE, *PPNODE;

typedef struct FNODE FNODE, *PFNODE;

struct FNODE { /* filenode in desktop */
    struct FNODE *f_next;
    struct FNODE *f_pfndx;
    uchar f_junk;
    uchar f_attr;
    uint16_t f_time;
    uint16_t f_date;
    long f_size;
    char f_name[14];
    short f_obid;
    struct APP *f_pa;
    short f_isapp;
};

struct DESKWIN {
    struct DESKWIN *w_next;
    int16_t w_flags;
    int16_t w_id;
    int16_t w_obid;
    int16_t w_root;
    int16_t w_cvcol;
    int16_t w_cvrow;
    int16_t w_pncol;
    int16_t w_pnrow;
    int16_t w_vncol;
    int16_t w_vnrow;
    struct PNODE *w_path;
    char w_name[121];
    char w_info[81];
};

struct PNODE { /* pathnode in desktop */
    struct PNODE *p_next;
    uint16_t p_flags;
    uint16_t p_attr;
    char p_spec[122];
    struct FNODE *p_flist;
    uint16_t p_count;
    long p_size;
};

typedef struct DIRFILE DIRFILE, *PDIRFILE;

struct DIRFILE {
    uchar d_junk;
    char d_att;
    uint16_t d_time;
    uint16_t d_date;
    long d_size;
    char d_name[14];
};

typedef struct DISKINFO DISKINFO, *PDISKINFO;

struct DISKINFO {
    ulong b_free;
    ulong b_total;
    ulong b_secsiz;
    ulong b_clsiz;
};

typedef struct dsb dsb, *Pdsb;

struct dsb { /* disk... */
    ushort curtrack;
    ushort seekrate;
};

typedef struct DTA DTA, *PDTA;

struct DTA {
    char reserved[20];
    struct DIRFILE dirfile;
};

typedef long ERROR;

typedef struct EXT_IOREC EXT_IOREC, *PEXT_IOREC;

typedef struct IOREC IOREC, *PIOREC;

struct IOREC { /* Input/Output Records */
    byte *buf;
    short size;
    short head;
    short tail;
    short low;
    short high;
};

struct EXT_IOREC {
    struct IOREC irec;
    struct IOREC orec;
    uchar rcv;
    uchar tsr;
    char highwater;
    char xoff;
    uchar ctr;
    char xonxoffc;
};

typedef struct FCB FCB, *PFCB;

struct FCB { /* File Control Block */
    char f_name[11];
    char f_attrib;
    char f_fill[10];
    struct _DOSTIME f_td;
    CLNO f_clust;
    long f_fileln;
};

typedef short FH;

typedef struct FND FND, *PFND;

struct FND {
    void *fncall;
    ushort fntyp;
};

typedef struct FPD FPD, *PFPD;

struct FPD {
    void *f_code;
    long f_data;
};

typedef struct FTAB FTAB, *PFTAB;

struct FTAB { /* Open File Table Entry */
    struct OFD *f_ofd;
    void *f_own;
    short f_use;
};

typedef struct GEM_MUPB GEM_MUPB, *PGEM_MUPB;

struct GEM_MUPB { /* GEM Memory Usage Parameter Block */
    ulong gm_magic;
    void *gm_end;
    void *gm_init;
};

typedef struct GRECT GRECT, *PGRECT;

struct GRECT {
    short g_x;
    short g_y;
    short g_w;
    short g_h;
};

typedef struct ICONBLK ICONBLK, *PICONBLK;

struct ICONBLK {
    void *ib_pmask;
    void *ib_pdata;
    char *ib_ptext;
    short ib_char;
    short ib_xchar;
    short ib_ychar;
    short ib_xicon;
    short ib_yicon;
    short ib_wicon;
    short ib_hicon;
    short ib_xtext;
    short ib_ytext;
    short ib_wtext;
    short ib_htext;
};

typedef struct KEYTAB KEYTAB, *PKEYTAB;

struct KEYTAB { /* Keyboard Tables */
    byte *unshift;
    byte *shift;
    byte *capslock;
};

typedef struct Mcdb Mcdb, *PMcdb;

struct Mcdb {
    short xhot;
    short yhot;
    short planes;
    short bg_col;
    short fg_col;
    ushort maskdata[32];
};

typedef struct MD MD, *PMD;

struct MD {
    struct MD *m_link;
    char *m_start;
    long m_length;
    void *m_own;
};

typedef struct MDBLOCK MDBLOCK, *PMDBLOCK;

typedef uchar uint8_t;

struct MDBLOCK { /* Memory Descriptor Block */
    struct MDBLOCK *o_link;
    uint8_t x_flag;
    uint8_t x_user;
    struct MD buf[4];
};

typedef struct MFDB MFDB, *PMFDB;

struct MFDB {
    void *fd_addr;
    short fd_w;
    short fd_h;
    short fd_wdwidth;
    short fd_stand;
    short fd_nplanes;
    short fd_r1;
    short fd_r2;
    short fd_r3;
};

typedef struct MFORM MFORM, *PMFORM;

struct MFORM { /* Mouse pointer */
    short mf_xhot;
    short mf_yhot;
    short mf_nplanes;
    short mf_fg;
    short mf_bg;
    short mf_mask[16];
    short mf_data[16];
};

typedef struct MOBLK MOBLK, *PMOBLK;

struct MOBLK {
    short m_out;
    short m_x;
    short m_y;
    short m_w;
    short m_h;
};

typedef struct MPB MPB, *PMPB;

struct MPB { /* Memory Partition Block */
    struct MD *mp_mfl;
    struct MD *mp_mal;
    struct MD *mp_rover;
};

typedef struct OBJECT OBJECT, *POBJECT;

struct OBJECT {
    int16_t ob_next;
    int16_t ob_head;
    int16_t ob_tail;
    uint16_t ob_type;
    uint16_t ob_flags;
    uint16_t ob_state;
    int32_t ob_spec;
    int16_t ob_x;
    int16_t ob_y;
    int16_t ob_width;
    int16_t ob_height;
};

typedef struct ORECT ORECT, *PORECT;

struct ORECT {
    struct ORECT *o_link;
    short o_x;
    short o_y;
    short o_w;
    short o_h;
};

typedef struct OSHEADER OSHEADER, *POSHEADER;

struct OSHEADER {
    ushort os_entry;
    ushort os_version;
    void *reseth;
    struct OSHEADER *os_beg;
    byte *os_end;
    void *os_rsvl;
    struct GEM_MUPB *os_magic;
    ulong os_date;
    ushort os_conf;
    ushort os_dosdate;
};

typedef struct PARMBLK PARMBLK, *PPARMBLK;

struct PARMBLK {
    struct OBJECT *pb_tree;
    short pb_obj;
    short pb_prevstate;
    short pb_currstate;
    short pb_x;
    short pb_y;
    short pb_w;
    short pb_h;
    short pb_xc;
    short pb_yc;
    short pb_wc;
    short pb_hc;
    long pb_parm;
};

typedef struct PBDEF PBDEF, *PPBDEF;

struct PBDEF {
    char *pb_scrptr;
    ushort pb_offset;
    ushort pb_width;
    ushort pb_height;
    ushort pb_left;
    ushort pb_right;
    ushort pb_screz;
    ushort pb_prrez;
    ushort *pb_colptr;
    ushort pb_prtype;
    ushort pb_prport;
    char *pb_mask;
};

typedef struct UDA2 UDA2, *PUDA2;

struct UDA2 {
    int16_t u_insuper;
    uint32_t u_regs[15];
    uint32_t *u_spsuper;
    uint32_t *u_spuser;
    uint32_t u_super[300];
    uint32_t u_supstk;
};

typedef struct UDA3 UDA3, *PUDA3;

struct UDA3 {
    int16_t u_insuper;
    uint32_t u_regs[15];
    uint32_t *u_spsuper;
    uint32_t *u_spuser;
    uint32_t u_super[350];
    uint32_t u_supstk;
};

typedef struct QPB QPB, *PQPB;

struct QPB {
    short qpb_pid;
    short qpb_cnt;
    void *qpb_buf;
};

typedef struct RSHDR RSHDR, *PRSHDR;

struct RSHDR {
    ushort rsh_vrsn;
    ushort rsh_object;
    ushort rsh_tedinfo;
    ushort rsh_iconblk;
    ushort rsh_bitblk;
    ushort rsh_frstr;
    ushort rsh_string;
    ushort rsh_imdata;
    ushort rsh_frimg;
    ushort rsh_trindex;
    ushort rsh_nobs;
    ushort rsh_ntree;
    ushort rsh_nted;
    ushort rsh_nib;
    ushort rsh_nbb;
    ushort rsh_nstring;
    ushort rsh_nimages;
    ushort rsh_rssize;
};

typedef struct SPB SPB, *PSPB;

struct SPB {
    short sy_tas;
    struct AESPD *sy_owner;
    struct EVB *sy_wait;
};

typedef struct struct rominfo struct rominfo, *Pstruct rominfo;

struct struct rominfo {
    void *data;
    ushort size;
};

typedef struct TEDINFO TEDINFO, *PTEDINFO;

struct TEDINFO {
    char *te_ptext;
    char *te_ptmplt;
    char *te_pvalid;
    short te_font;
    short te_junk1;
    short te_just;
    short te_color;
    short te_junk2;
    short te_thickness;
    short te_textlen;
    short te_tmplen;
};

typedef struct THEDSK THEDSK, *PTHEDSK;

typedef struct USERBLK USERBLK, *PUSERBLK;

typedef struct WSAVE WSAVE, *PWSAVE;

struct USERBLK {
    void *ub_code;
    long ub_parm;
};

struct WSAVE {
    struct GRECT gr_save;
    short hsl_save;
    short vsl_save;
    short obid_save;
    char pth_save[122];
};

struct THEDSK {
    struct FNODE g_flist[400];
    struct FNODE *g_favail;
    struct PNODE g_plist[5];
    struct PNODE *g_pavail;
    struct PNODE *g_phead;
    char g_wspec[122];
    char *a_wspec;
    char g_wdta[128];
    struct DTA *a_wdta;
    short n_winalloc;
    struct ICONBLK gl_icons[128];
    short g_index[128];
    struct USERBLK g_udefs[128];
    short g_num;
    short *g_pxy;
    short g_iview;
    short g_iwext;
    short g_ihext;
    short g_iwint;
    short g_ihint;
    short g_iwspc;
    short g_ihspc;
    short g_incol;
    short g_isort;
    char g_srcpth[128];
    char g_dstpath[128];
    char *g_xbuf;
    ushort g_xlen;
    struct DTA g_dtastk[9];
    long g_nfiles;
    long g_ndirs;
    long g_size;
    char g_tmppth[128];
    short g_xyobpts[120];
    short g_rmsg[8];
    short *p_msgbuf;
    struct GRECT g_desk;
    struct GRECT g_full;
    char g_cmd[128];
    char *g_pcmd;
    char g_tail[128];
    char *g_ptail;
    char g_fcb1[36];
    char *a_fcb1;
    char g_fcb2[36];
    char *a_fcb2;
    char *a_alert;
    struct OBJECT *g_atree[14];
    short g_croot;
    short g_cwin;
    short g_wlastsel;
    short g_cviewitem;
    short g_csortitem;
    short g_ccopypref;
    short g_cdelepref;
    short g_cdclkpref;
    short g_icw;
    short g_ich;
    short g_nmicon;
    short g_nmtext;
    short g_xyicon[18];
    short g_xytext[18];
    short gl_wicon;
    short gl_hicon;
    char afile[2048];
    short size_afile;
    char appbuf[2048];
    char *g_pbuff;
    struct APP app[32];
    struct APP *appfree;
    struct APP *applist;
    struct ICONBLK iconaddr[6];
    struct ICONBLK g_iblist[6];
    short g_ismask[12];
    short g_cnxsave.sitem_save;
    short g_cnxsave.vitem_save;
    short g_cnxsave.ccopy_save;
    short g_cnxsave.cdele_save;
    short g_cnxsave.cdclk_save;
    short g_cnxsave.pref_save;
    struct WSAVE g_cnxsave.win_save[4];
    void *icondata;
    void *a_buffstart;
    struct OBJECT *g_pscreen;
    char ml_files[4];
    char ml_dirs[4];
    short ml_dlfi;
    short ml_dlfo;
    short ml_dlok;
    short ml_dlcn;
    short ml_dpr;
    short ml_havebox;
    char ml_fsrc[13];
    char ml_fdst[13];
    char ml_fstr[13];
    char ml_ftmp[13];
    char gl_lngstr[16];
    struct FNODE *ml_pfndx[400];
    struct OBJECT g_screen[133];
};

typedef struct THEGLO THEGLO, *PTHEGLO;

typedef struct WINDOW WINDOW, *PWINDOW;

struct WINDOW {
    short w_flags;
    struct AESPD *w_owner;
    short w_kind;
    char *w_pname;
    char *w_pinfo;
    struct GRECT w_full;
    struct GRECT w_work;
    struct GRECT w_prev;
    short w_hslide;
    short w_vslide;
    short w_hslsize;
    short w_vslsize;
    struct ORECT *w_rlist;
    struct ORECT *w_rnext;
};

struct THEGLO {
    struct UDA g_uda;
    struct UDA2 g_2uda;
    struct UDA3 g_3uda;
    struct AESPD g_pd[3];
    struct CDA g_cda[3];
    struct EVB g_evb[15];
    struct FPD g_fpdx[32];
    struct ORECT g_olist[80];
    char g_rawstr[81];
    char g_tmpstr[81];
    char g_valstr[81];
    char g_fmtstr[81];
    char g_loc1[256];
    char g_loc2[256];
    char g_scrap[164];
    char g_dir[82];
    uint16_t g_sysglo[15];
    char s_cmd[128];
    char s_save[2048];
    char s_tail[128];
    struct WINDOW w_win[8];
};

typedef struct VDIPB VDIPB, *PVDIPB;

struct VDIPB {
    short *control;
    short *intin;
    short *ptsin;
    short *intout;
    short *ptsout;
};

typedef struct WS WS, *PWS;

struct WS {
    short ws_xres;
    short ws_yres;
    short ws_noscale;
    short ws_wpixel;
    short ws_hpixel;
    short ws_ncheights;
    short ws_nlntypes;
    short ws_nlnwidths;
    short ws_nmktypes;
    short ws_nmksizes;
    short ws_nfaces;
    short ws_npatts;
    short ws_nhatchs;
    short ws_ncolors;
    short ws_ngdps;
    short ws_supgdps[10];
    short ws_attgdps[10];
    short ws_color;
    short ws_rotate;
    short ws_fill;
    short ws_cell;
    short ws_npals;
    short ws_nloc;
    short ws_nval;
    short ws_nchoice;
    short ws_nstring;
    short ws_type;
    short ws_pts0;
    short ws_chminh;
    short ws_pts2;
    short ws_chmaxh;
    short ws_lnminw;
    short ws_pts5;
    short ws_lnmaxw;
    short ws_pts7;
    short ws_pts8;
    short ws_mkminw;
    short ws_pts10;
    short ws_mkmaxw;
};

typedef long xjmp_buf[3];
