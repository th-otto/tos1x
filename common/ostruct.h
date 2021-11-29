#ifndef __OSTRUCT_H__
#define __OSTRUCT_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif



#define FA_UPDATE       0x00
#define FA_RDONLY       0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_LABEL        0x08
#ifndef FA_DIREC
#define FA_DIREC        0x10
#endif
#ifndef FA_ARCH
#define FA_ARCH         0x20
#endif

#define MAXPATH   119
#define MAXDRIVE  3
#define MAXDIR    102
#define MAXFILE   9
#define MAXEXT    5

typedef struct
{
    char      d_reserved[21];  /* reserved for GEMDOS   */
    char      d_attrib;        /* file attribut         */
    __int16_t d_time;          /* packed time           */
    __int16_t d_date;          /* packed date           */
    __int32_t d_length;        /* filesize              */
    char      d_fname[14];     /* file name             */
} _DTA;

/*
 *  DOSTIME - the standard layout of time & date
 */
typedef struct
{
    __uint16_t time;         /* Time like Tgettime() */
    __uint16_t date;         /* Date like Tgetdate() */
} _DOSTIME;

/*
 *  BPB - Bios Parameter Block
 */
struct _bpb /* bios parameter block */
{
    __uint16_t recsiz;       /* sector size in bytes */
    __uint16_t clsiz;        /* cluster size in sectors */
    __uint16_t clsizb;       /* cluster size in bytes */
    __uint16_t rdlen;        /* root directory length in records */
    __uint16_t fsiz;         /* FAT size in records */
    __uint16_t fatrec;       /* first FAT record (of last FAT) */
    __uint16_t datrec;       /* first data record */
    __uint16_t numcl;        /* number of data clusters available */
    __uint16_t b_flags;      /* flags (see below) */
};
typedef struct _bpb BPB;

/*
 *  flags for BPB
 */
#define B_16    1       /* device has 16-bit FATs */
#define B_1FAT  2       /* device has only a single FAT */

/* Structure returned by Keytbl() */
typedef struct {
    char *unshift;	/* pointer to unshifted keys */
    char *shift;	/* pointer to shifted keys */
    char *caps;		/* pointer to capslock keys */

    /* Entries below available
     * when _AKP cookie is present.
     */
    char *alt;		/* pointers to alt translation tables */
    char *altshift;
    char *altcaps;

   /* Entry below is available
    * on MilanTOS and as of FreeMiNT 1.16.1
    */
    char *altgr;

} _KEYTAB;

typedef struct
{
	long gem_magic;			/* $87654321 if GEM present */
	long gem_end;			/* End address of OS RAM usage */
	long gem_entry;			/* Execution address of GEM */
} GEM_MUPB;

typedef struct _osheader 
{
    unsigned short	os_entry;   	 /* 0x00  BRA to reset handler	*/
    unsigned short	os_version; 	 /* 0x02  TOS version		*/
    VOID		(*reseth) (NOTHING); /* 0x04 -> reset handler	*/
    struct _osheader	*os_beg;	 /* 0x08 -> base of OS		*/
    VOID		*os_end;	 /* 0x0c -> end of OS ram usage */
    char		*os_rsv1;	 /* 0x10 reserved		*/
	GEM_MUPB	*os_magic;	 /* 0x14 GEM memory usage param */
    long		os_date;	 /* 0x18 Build date 0xMMDDYYYY	*/
    unsigned short	os_conf;	 /* 0x1c OS conf bits		*/
    unsigned short	os_dosdate;	 /* 0x1e DOS format build date  */
    /* the following available on TOS version >= 1.2 */
    char		**p_root;	 /* 0x20 -> base of OS pool	*/
    char		**pkbshift;	 /* 0x24 -> kbd shift state var */
    char		**p_run;	 /* 0x28 -> PID of current proc */
    char		*p_rsv2;	 /* 0x2c reserved		*/
} OSHEADER;

#endif /* __OSTRUCT_H__ */
