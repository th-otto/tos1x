#ifndef PD_H
#define PD_H 1

#ifndef __OSTRUCT_H__
#include <ostruct.h>
#endif

#define NUMSTD      6       /* number of standard files */

/*
 * DTAINFO - Information stored in the dta by srch-frst for use by srch-nxt.
 * bytes 0-20 are reserved by o/s, and are used by sfirst/snext.  beyond
 * that, contents are published in programmer's guide.
 */
#define DTAINFO struct DtaInfo
DTAINFO
{
    char  dt_name[12];          /*  file name: filename.typ     00-11   */
    int32_t dt_offset_drive;    /*  dir position                12-15   */
	int16_t dt_curbyt;			/* byte pointer within current cluster 16-17 */
	CLNO  dt_curcl;				/* current cluster number for file	   18-19 */
    char  dt_attr;              /*  attributes of file          20      */
                                /*  --  below must not change -- [1]    */
    char  dt_fattr;             /*  attrib from fcb             21      */
    _DOSTIME dt_td;             /*  time, date fields from fcb  22-25   */
    int32_t  dt_fileln;         /*  file length field from fcb  26-29   */
    char  dt_fname[14];         /*  file name from fcb          30-43   */
};                              /*    includes null terminator          */

/*
 *  PD - Process Descriptor
 */

#define PDCLSIZE    0x80           /*  size of command line in bytes  */
#define NUMCURDIR   BLKDEVNUM      /* number of entries in curdir array */

typedef struct _pd PD;
struct _pd
{
	/*   0 */ int32_t    p_lowtpa;		/* pointer to start of TPA */
	/*   4 */ int32_t    p_hitpa; 		/* pointer to end of TPA+1 */
	/*   8 */ int32_t    p_tbase; 		/* pointer to base of text segment */
	/*  12 */ int32_t    p_tlen;		/* length of text segment */
	/*  16 */ int32_t    p_dbase; 		/* pointer to base of data segment */
	/*  20 */ int32_t    p_dlen;		/* length of data segment */
	/*  24 */ int32_t    p_bbase; 		/* pointer to base of bss segment */
	/*  28 */ int32_t    p_blen;		/* length of bss segment */
	/*  32 */ DTAINFO 	*p_xdta;
	/*  36 */ PD		*p_parent;		/* parent PD */
	/*  40 */ int32_t    p_flags;
	/*  44 */ char	    *p_env; 		/* pointer to environment string */
	/*  48 */ int8_t	 p_uft[NUMSTD];	/* index into sys file table for std files */
	/*  54 */ int8_t	 p_lddrv;
	/*  55 */ int8_t	 p_curdrv;
	/*  56 */ int32_t    p_1fill[2];
	/*  64 */ int8_t	 p_curdir[NUMCURDIR];	  /* index into sys dir table */
	/*  80 */ int8_t	 p_2fill[32-NUMCURDIR];
	/*  96 */ int32_t    p_3fill[2];
	/* 104 */ int32_t    p_dreg[1];		/* dreg[0] */
	/* 108 */ int32_t    p_areg[5];		/* areg[3..7] */
	/* 128 */ char	     p_cmdlin[PDCLSIZE]; 	/* command line image */
	/* 256 */
};

/* p_flags values: */
#define PF_FASTLOAD     0x0001
#define PF_LOADTTRAM    0x0002 /* PF_TTRAMLOAD; renamed because of 8-char identifier limit */
#define PF_ALLOCTTRAM   0x0004 /* PF_TTRAMMEM; renamed because of 8-char identifier limit */

extern PD *run; /* Pointer to the basepage of the current process */

#endif /* PD_H */
