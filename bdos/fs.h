#ifndef FS_H
#define FS_H

#include "bios.h"

/*
 *  code macros
 */

#define rwabs(wrtflg,buf,count,rec,drive) if((rwerr=Rwabs(wrtflg,buf,count,rec,drive))!=0){errdrv=drive;xlongjmp(errbuf,rwerr);}
#define rwabsw(buf,count,rec,drive) if((rwerr=Rwabsw(buf,count,rec,drive))!=0){errdrv=drive;xlongjmp(errbuf,rwerr);}
#define rwabsr(buf,count,rec,drive) if((rwerr=Rwabsr(buf,count,rec,drive))!=0){errdrv=drive;xlongjmp(errbuf,rwerr);}


#define FA_NORM (FA_ARCH|FA_HIDDEN|FA_RDONLY|FA_SYSTEM)


#if BLKDEVNUM > 16
#define DTA_DRIVEMASK   0x0000001fL
#else
#define DTA_DRIVEMASK   0x0000000fL
#endif

/*
 *  OFD - open file descriptor
 *
 *  architectural restriction: for compatibility with FOLDRnnn.PRG,
 *  this structure must not exceed 64 bytes in length
 */

OFD
{
	/*   0 */ OFD   *o_link;		/*	link to next OFD					*/
	/*   4 */ uint16_t o_flag;
					/* the following 3 items must be as in FCB: */
	/*   6 */ _DOSTIME o_td;		/*	creation time/date: little-endian!	*/
	/*  10 */ CLNO  o_strtcl; 		/*	starting cluster number 			*/
	/*  12 */ int32_t  o_fileln;	/*  length of file in bytes			    */

	/*  16 */ DMD   *o_dmd;			/*	link to media descr 				*/
	/*  20 */ DND   *o_dnode; 		/*	link to dir for this file			*/
	/*  24 */ OFD   *o_dirfil;		/*	OFD for dir for this file			*/
	/*  28 */ int32_t  o_dirbyt;	/*  pos in dir of this files fcb (dcnt) */

	/*  32 */ int32_t  o_bytnum;	/* byte pointer within file			    */
	/*  36 */ CLNO  o_curcl;		/* current cluster number for file		*/
	/*  38 */ RECNO o_currec; 		/* current record number for file		*/
	/*  40 */ int16_t o_curbyt;		/* byte pointer within current cluster  */
	/*  42 */ int16_t  o_usecnt;	/* use count for inherited files 	    */
	/*  44 */ OFD   *o_thread;		/* mulitple open thread list			*/
	/*  48 */ uint16_t o_mod; 		/* mode file opened in (see below)	    */
	/*  50 */ 
};


#define MDS_PER_BLOCK 4
MDBLOCK
{
	/*   0 */ MDBLOCK  *o_link;
	/*   4 */ uint8_t x_flag;
	/*   5 */ uint8_t x_user;
	          MD buf[MDS_PER_BLOCK]; /* must be large enough to also hold an OFD structure */
	/*  70 */
};
#define X_USER(dnd) ((char *)(dnd))[-1]


/*
 * bit usage in o_mod
 *
 * bits 8-15 are internal-use only
 * bits 0-7 correspond to bit usage in the Fopen() system call
 * note: bits 4-7 are only used if GEMDOS file-sharing/record-locking
 *       is implemented
 */
#define INH_MODE    0x80    /* bit 7 is inheritance flag (not yet implemented) */
#define MODE_FSM    0x70    /* bits 4-6 are file sharing mode (not yet implemented) */
#define MODE_FAC    0x03    /* bits 0-1 are file access code: (same as O_ACCMODE) */
#define RO_MODE        0	/* Open read-only - same as O_RDONLY */
#define WO_MODE        1	/* Open write-only - same as O_WRONLY */
#define RW_MODE        2	/* Open read/write - same as O_RDWR */
#define VALID_FOPEN_BITS    MODE_FAC    /* currently-valid bits for Fopen() */

#define SEEK_SET     0       /* Seek from beginning of file.  */
#define SEEK_CUR     1       /* Seek from current position.  */
#define SEEK_END     2       /* Seek from end of file.  */

/*
 * O_DIRTY - Dirty Flag
 *
 * T: OFD is dirty, because of chg to startcl, length, time, etc.
 */
#define O_DIRTY         1



/*
 *  FCB - File Control Block
 *
 *  architectural restriction: this is the structure of the
 *  directory entry on disk, compatible with MSDOS etc
 */

FCB
{
	char f_name[11];
	char f_attrib;
	char f_fill[10];
	_DOSTIME f_td;			/* time, date */
	CLNO f_clust;
	int32_t f_fileln;
};


/*
 *  DND - Directory Node Descriptor
 *
 *  architectural restriction: for compatibility with FOLDRnnn.PRG,
 *  this structure must not exceed 64 bytes in length
 */

DND /* directory node descriptor */
{
	/*  0 */ char d_name[11];	/*	directory name						*/
	/* 11 */ char d_fill;		/*	to attributes? 						*/
	/* 12 */ uint16_t d_flag;
	/* 14 */ CLNO d_strtcl;		/*	starting cluster number of dir		*/

	/* 16 */ _DOSTIME d_td;		/*	time/date: little-endian!			*/
	/* 20 */ OFD  *d_ofd;		/*	open file descr for this dir		*/
	/* 24 */ DND  *d_parent; 	/*	parent dir (..) 					*/
	/* 28 */ DND  *d_left;		/*	1st child							*/

	/* 32 */ DND  *d_right;		/*	sibling in same dir 				*/
	/* 36 */ DMD  *d_drv;		/*	for drive							*/
	/* 40 */ OFD  *d_dirfil;
	/* 44 */ int32_t d_dirpos;

	/* 48 */ int32_t d_scan; 	/*	current posn in dir for DND tree	*/
	/* 52 */ OFD  *d_files;		/* open files on this node				*/
	/* 56 */ int16_t d_usecount; /*	Fsfirst/Fsnext's in progress		*/
	/* 58 */ 
};

/*
 * FTAB - Open File Table Entry
 */

/* point these at OFDs when needed */
FTAB
{
    OFD *f_ofd;
    PD  *f_own;         /* file owners */
    int16_t f_use;      /* use count */
};


/******************************************
**
** BDOS level character device file handles
**
*******************************************
*/

#if GEMDOS
#define	H_Print		(-3)
#define	H_Aux		(-2)
#define	H_Console	(-1)
#else
#define	H_Null		(-1)		/* not passed through to BIOS	*/
#define	H_Print		(-2)
#define	H_Aux		(-3)
#define	H_Console	(-4)
#define	H_Clock		(-5)
#define	H_Mouse		(-6)
#endif


/****************************************
**
** Character device handle conversion
** (BDOS-type handle to BIOS-type handle)
**
*****************************************
*/

#if GEMDOS
#define HXFORM(h)	((h) + 3)
#else
extern	int16_t	bios_dev[];		/*  in fsfioctl.c		*/
#define HXFORM(h)	bios_dev[-h-2]
#endif

/**********************
 *
 * BIOS function macros
 *
 **********************
*/

#define Getmpb(a)   	trap13(0x00,a)
#define Bconstat(a) 	trap13(0x01,a)		/* Character Input Status   */
#define Bconin(a)		trap13(0x02,a)
#define Bconout(a,b)	trap13(0x03,a,b)
#define Rwabs(wrtflg,buf,count,rec,drive) trap13(0x04,wrtflg,buf,count,rec,drive)
#ifdef __ALCYON__
#define Rwabsw(buf,count,rec,drive) trap13(0x00040001l,buf,count,rec,drive)
#define Rwabsr(buf,count,rec,drive) trap13(0x00040000l,buf,count,rec,drive)
#else
#define Rwabsw(buf,count,rec,drive) Rwabs(1,buf,count,rec,drive)
#define Rwabsr(buf,count,rec,drive) Rwabs(0,buf,count,rec,drive)
#endif
#define Setexc(d,a)		trap13(0x05,d,a)	/* Vector Exchange	    */
#define Tickcal()		trap13(0x06)		/* Timer tick		    */
#define Getbpb(d)		(BPB *)trap13(0x07,d)	/* Get BIOS Parameter Block */
#define Bcostat(a)		trap13(0x08,a)		/* Character Output Status  */
#define Mediach(d)		trap13(0x09,d)
#define	Drvmap()		trap13(0x0A)		/* Get Drive Map	    */
#define Kbshift(a)		trap13(0x0B,a)		/* Shift state		    */
#define CIOCR(d,l,b)	trap13(0x0C,d,l,b)	/* Char IOCtl Read	    */
#define CIOCW(d,l,b)	trap13(0x0D,d,l,b)	/* Char IOCtl Write	    */
#define DIOCR(d,l,b)	trap13(0x0E,d,l,b)	/* Disk IOCtl Read	    */
#define DIOCW(d,l,b)	trap13(0x0F,d,l,b)	/* Disk IOCtl Write	    */


/**********************
 *
 * F_IOCtl subfunctions
 *
 **********************
*/

#define	XCVECTOR	-1			/* Exchange vector	    */
#define	GETINFO		0			/* Get device info	    */
#define	SETINFO		1			/* NOT IMPLEMENTED	    */
#define	CREADC		2			/* Character read control   */
#define	CWRITEC		3			/* Character write control  */
#define	DREADC		4			/* Disk read control	    */
#define	DWRITEC		5			/* Disk write control	    */
#define	INSTAT		6			/* Input status		    */
#define	OUTSTAT		7			/* Output status	    */
#define	REMEDIA		8			/* Removeable indication    */

/*************************
 *
 * Device information bits
 *
 *************************
*/

#define	Is_Console	0x0003			/* Both stdin & stdout	    */
#define	Is_NUL		0x0004
#define	Is_Clock	0x0008
#define	Is_Character	0x00C0			/* Character is binary now  */
#define Does_IOCtl	0x4000


typedef	ERROR (*PFE) PROTO((NOTHING));			/* ptr to func ret err */
typedef	int32_t (*PFL) PROTO((NOTHING));		/* ptr to func ret long */

/*******************************
 *
 *  External Declarations
 *
 *******************************
*/

/* External Declarations */


extern DND *dirtbl[NCURDIR];
extern DMD *drvtbl[BLKDEVNUM];
extern char diruse[];
extern drvmask drvsel;
extern int16_t const logmsk[];
extern FTAB sft[OPNFILES - NUMSTD];
extern ERROR rwerr;
extern int16_t errdrv;
extern uint16_t time, date;
extern xjmp_buf errbuf;
extern int const nday[];
extern char fill[3];
extern BOOLEAN dirlock;
extern char osuser;
extern int8_t const stddev[NUMSTD];

/********************************
 *
 *  Forward Declarations
 *
 ********************************
*/

int32_t trap13 PROTO((int16_t, ...));
ERROR oscall PROTO((int16_t, ...));
VOID swp68 PROTO((uint16_t *p));
VOID swp68l PROTO((int32_t *p));

ERROR ixcreat PROTO((const char *fname, int8_t attr));
ERROR ixopen PROTO((const char *fname, int16_t mode));



ERROR ixsfirst PROTO((const char *name, int16_t att, DTAINFO *addr));
FCB *dirinit PROTO((DND *dn));
VOID builds PROTO((const char *src, char *dst));
char *dopath PROTO((DND *p, char *buf));
DND *findit PROTO((const char *name, const char **sp, int dflag));
int getpath PROTO((const char *p, char *d, int dirspec));
BOOLEAN match PROTO((const char *s1, const char *s2));
int xcmps PROTO((const char *s, const char *d));
#if GEMDOS >= 0x18
VOID flushall PROTO((NOTHING));
#else
VOID flushbcb PROTO((BCB *b));
#endif

char *getrec PROTO((RECNO recno, DMD *dm, int wrtflg));
char *packit PROTO((const char *s, char *d));

ERROR ckdrv PROTO((int d));
DMD *getdmd PROTO((int drv));
int xlog2 PROTO((int n));

#if 0
RECNO cl2rec PROTO((CLNO cl, DMD *dm));
#else
#define cl2rec(cl, dm) ((cl) * (dm)->m_clsiz)
#endif

VOID clfix PROTO((CLNO cl, CLNO link, DMD *dm));
CLNO getcl PROTO((CLNO cl, DMD *dm));
int nextcl PROTO((OFD *p, int wrtflg));

ERROR ixforce PROTO((FH std, FH h, PD *p));
FH syshnd PROTO((FH h));
VOID ixdirdup PROTO((FH h, int16_t dn, PD *p));
FH ffhndl PROTO((NOTHING));

typedef VOID (*xfer) PROTO((int, char *, char *));

ERROR xrw PROTO((int wrtflg, OFD *p, long len, char *ubufr, xfer bufxfr));
ERROR ixlseek PROTO((OFD *p, long n));
ERROR ixread PROTO((OFD *p, long len, VOIDPTR ubufr));
ERROR ixwrite PROTO((OFD *p, long len, VOIDPTR ubufr));

VOID xfr2usr PROTO((int, char *, char *));
VOID usr2xfr PROTO((int, char *, char *));
int uc PROTO((char c));
OFD *makofd PROTO((DND *p));
OFD *getofd PROTO((FH h));
#if 0
int16_t divmod PROTO((int16_t *modp, int32_t divdnd, int16_t divsor));
#define DIVMOD(res, modp, divdnd, divsor) res = divmod(&(modp), (int32_t)(divdnd), divsor)
#else
#define DIVMOD(res, modp, divdnd, divsor) modp = (int32_t)(divdnd) & logmsk[divsor], res = (int32_t)(divdnd) >> (divsor)
#endif

ERROR F_IOCtl PROTO((int fn, FH h, int n, VOIDPTR buf));
int Chk_Drv PROTO((int16_t *d));

FCB *scan PROTO((DND *dnd, const char *n, int16_t att, int32_t *posp));

ERROR opnfil PROTO((const FCB *f, DND *dn, int16_t mod));
ERROR makopn PROTO((const FCB *f, DND *dn, FH h, int16_t mod));
ERROR ixclose PROTO((OFD *fd, int part));
ERROR ixdel PROTO((DND *dn, FCB *f, long pos));

VOID tabout PROTO((FH h, int ch));
int32_t constat PROTO((FH h));
int32_t conin PROTO((FH h));
int cgets PROTO((FH h, int maxlen, char *buf));

int contains_dots PROTO((const char *name, char ill));

/********************************
 *
 *  DOS entry points
 *
 ********************************
*/

ERROR xcreat PROTO((const char *fname, int8_t attr));
ERROR xopen PROTO((const char *fname, int16_t mode));
ERROR xmkdir PROTO((const char *s));
ERROR xrmdir PROTO((const char *p));
ERROR xchmod PROTO((const char *p, int16_t wrt, char mod));
ERROR xsfirst PROTO((const char *name, int16_t att));
ERROR xsnext PROTO((NOTHING));
ERROR xgsdtof PROTO((uint16_t *buf, FH h, int16_t wrt));
ERROR xrename PROTO((int16_t n, const char *p1, const char *p2));
ERROR xchdir PROTO((const char *p));
ERROR xgetdir PROTO((char *buf, int16_t drv));
ERROR xgetfree PROTO((int32_t *buf, int16_t drv));
ERROR xforce PROTO((FH std, FH h));
ERROR xdup PROTO((FH h));
ERROR xlseek PROTO((long n, FH h, int16_t flg));
ERROR xread PROTO((FH h, long len, VOIDPTR ubufr));
ERROR xwrite PROTO((FH h, long len, VOIDPTR ubufr));
DTAINFO *xgetdta PROTO((NOTHING));
VOID xsetdta PROTO((DTAINFO *addr));
ERROR xsetdrv PROTO((int16_t drv));
ERROR xgetdrv PROTO((NOTHING));
ERROR xclose PROTO((FH h));
ERROR xunlink PROTO((const char *name));
ERROR xexec PROTO((int16_t flg, char *s, char *t, char *v));
VOID x0term PROTO((NOTHING));
VOID xterm PROTO((uint16_t rc));
VOID xtermres PROTO((int32_t blkln, int16_t rc));
int32_t xgetdate PROTO((NOTHING));
int32_t xsetdate PROTO((int16_t d));
int32_t xgettime PROTO((NOTHING));
int32_t xsettime PROTO((int16_t t));
int32_t xconstat PROTO((NOTHING));
int32_t xconostat PROTO((NOTHING));
int32_t xprtostat PROTO((NOTHING));
int32_t xauxistat PROTO((NOTHING));
int32_t xauxostat PROTO((NOTHING));
VOID xtabout PROTO((int16_t ch));
int16_t xauxout PROTO((int16_t ch));
int32_t xprtout PROTO((int16_t ch));
int32_t x7in PROTO((NOTHING));
int32_t xconin PROTO((NOTHING));
int32_t x8in PROTO((NOTHING));
int32_t xauxin PROTO((NOTHING));
int32_t rawconio PROTO((int16_t parm));
VOID xprt_line PROTO((const char *p));
VOID readline PROTO((char *p));
ERROR xmalloc PROTO((int32_t amount));
ERROR xmfree PROTO((int32_t addr));
ERROR xsetblk PROTO((int16_t n, VOIDPTR blk, int32_t len));
ERROR xmaddalt PROTO((char *start, int32_t len));
ERROR xmxalloc PROTO((int32_t amount, int16_t mode));



/*
 * FAT chain defines
 */
#define FREECLUSTER     0x0000
#define ENDOFCHAIN      0xffff                  /* our end-of-chain marker */
#ifdef EMUTOS
#define endofchain(a)   (((a)&0xfff8)==0xfff8)  /* in case file was created by someone else */
#else
#define endofchain(a) ((a) == ENDOFCHAIN)
#endif
#define ERASE_MARKER 0xe5

/* Misc. defines */
                    /* the following are used for the second arg to ixclose() */
#define CL_DIR  0x0002      /* this is a directory file, flush, do not free */
#define CL_FULL 0x0004      /* even though it's a directory, full close */


#endif /* FS_H */
