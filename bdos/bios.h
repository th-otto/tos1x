/* bios.h - bios defines */
#ifndef BIOS_H
#define BIOS_H 1

/*
 *
 * MODIFICATION HISTORY
 * 14 Oct 85 KTB create from fs.h
 *
 *
 * NAMES
 *
 * SCC Steve C. Cavender
 * KTB Karl T. Braun (kral)
 */

/*
 *  Type declarations
 */

#define FTAB    struct _ftab
#define OFD     struct _ofd
#define MDBLOCK struct _mdblock
#define FCB     struct _fcb
#define DND     struct _dnd
#define FH      int16_t    /*  file handle    */
#define DMD     struct _dmd
#define BCB     struct _bcb


#define SLASH '\\'


#if BLKDEVNUM > 16
#define drvmask int32_t
#define DRVMASK(d) (1L << (d))
#else
#define drvmask int16_t
#define DRVMASK(d) (1 << (d))
#endif

#ifndef PD_H
#include "pd.h"
#endif


/*
 * Bios Function Numbers
 */

#define B_MDCHG  9      /* media change */

/*
 * BIOS level character device handles
 */

#define BFHPRN  0
#define BFHAUX  1
#define BFHCON  2
#define BFHKBD  3
#define BFHMIDI 4
#define BFHSCR  5
#define BFHMDM1 6
#define BFHMDM2 7
#define BFHMDM3 8
#define BFHMDM4 9
#define BFHCLK -1
#define BFHMOU -2


/*
 * return codes
 */

#define DEVREADY        -1L    /* device ready */
#define DEVNOTREADY      0L    /* device not ready */

/*
 * bios data types
 */


/*
 * ISR - Interrupt Service Routines.
 * These routines currently do not return anything important. In
 * future versions, they will return boolean values that indicate
 * whether a dispatch should occurr (TRUE) or not.
 */

typedef BOOLEAN ISR;                    /* interrupt service routine */
typedef ISR (*PISR) PROTO((NOTHING));   /* pointer to isr routines */

/*
 * SSN - Sequential Sector Numbers
 * At the outermost level of support, the disks look like an
 * array of sequential logical sectors.  The range of SSNs are
 * from 0 to n-1, where n is the number of logical sectors on
 * the disk.  (logical sectors do not necessarilay have to be
 * the same size as a physical sector.
 */

typedef int32_t SSN;


/*
 * Data Structures
 */

#include "../bios/bpb.h"

ERROR login PROTO((BPB *b, int drv));



/*
 *  DMD - Drive Media Block
 */

/*  records == logical sectors  */

DMD /* drive media block */
{
	/*  0 */ RECNO	m_recoff[3]; /* record offsets for fat,dir,data		 */
	/*  6 */ int16_t m_drvnum;	 /* drive number for this media			 */
	/*  8 */ CLNO m_fatrec;		 /* first fat record (of last fat)       */
	/* 10 */ RECNO m_fsiz;		 /* fat size in records					 */
	/* 12 */ RECNO m_clsiz;		 /* cluster size in records				 */
	/* 14 */ int16_t m_clsizb;	 /* cluster size in bytes				 */	/* BUG: should be unsigned */
	/* 16 */ int16_t m_recsiz;	 /* record size in bytes				 */	/* BUG: should be unsigned */

	/* 18 */ CLNO	m_numcl;	 /*  total number of clusters in data	 */
	/* 20 */ int16_t m_clrlog;	 /* log (base 2) of clsiz in records	 */
	/* 22 */ int16_t m_clrm; 	 /* clsiz in rec, mask					 */
	/* 24 */ int16_t m_rblog;	 /* log (base 2) of recsiz in bytes 	 */
	/* 26 */ int16_t m_rbm;		 /* recsiz in bytes, mask				 */
	/* 28 */ int16_t m_clblog;	 /* log (base 2) of clsiz in bytes		 */
	/* 30 */ OFD    *m_fatofd;	 /* OFD for 'fat file'					 */
	/* 34 */ uint16_t m_1fat;	 /* 1 FAT only ?						 */
	/* 36 */ uint16_t m_unused;
	/* 38 */ DND 	*m_dtl; 	 /* root of directory tree list 		 */
	/* 42 */ uint16_t m_16;		 /* 16 bit fat ?						 */
	/* 44 */
};



/*
 * BCB - Buffer Control Block
 */

/*
 *  BCB - Buffer Control Block
 *
 *  note that this is part of the TOS API, via the pointers to BCB
 *  chains at bufl[2].  for compatibility with existing programs
 *  (such as CACHEnnn.PRG and HDDRIVER), the length must be 20 bytes,
 *  and the fields marked (API) below must remain the same (contents,
 *  size, and offset within structure).
 */

BCB
{
    /*  0 */ BCB     *b_link;    /*  next bcb (API)              */
    /*  4 */ int16_t b_bufdrv;   /*  unit for buffer (API)       */
#ifdef EMUTOS
    /*  6 */ LRECNO  b_bufrec;   /*  record number               */
    /* 10 */ uint8_t b_buftyp;   /*  buffer type                 */
    /* 11 */ uint8_t b_dirty;    /*  true if buffer dirty        */
#else
    /*  6 */ int16_t b_buftyp;   /*  buffer type                 */
    /*  8 */ RECNO   b_bufrec;   /*  record number               */
    /* 10 */ int16_t b_dirty;    /*  true if buffer dirty        */
#endif
    /* 12 */ DMD     *b_dm;      /*  ptr to drive media block    */
    /* 16 */ char    *b_bufr;    /*  pointer to buffer (API)     */
    /* 20 */
};


/*
 * buffer type values
 */

#define BT_FAT		0		/*	fat buffer			*/
#define BT_ROOT 	1		/*	root dir buffer 	*/
#define BT_DATA 	2		/*	data/dir buffer 	*/

/*
 * buffer list indexes
 */

#define BI_FAT		0		/*	fat buffer list 	*/
#define BI_ROOT 	1		/*	root dir buffer list	*/
#define BI_DIR		1		/*	other dir buffer list	*/
#define BI_DATA 	1		/*	data buffer list		*/

extern BCB bcbx[4];
extern char secbuf[4][512];

/*
 * MD - Memory Descriptor
 */

#define MD struct _md
MD
{
	MD *m_link;
	intptr_t m_start;
	intptr_t m_length;
	PD *m_own;
};

/*
 * fields in Memory Descriptor
 */

#define MF_FREE ((PD *)1)


/*
 * MPB - Memory Partition Block
 */

#define MPB struct _mpb
MPB
{
	MD *mp_mfl;
	MD *mp_mal;
	MD *mp_rover;
};




/* For BIOS calls... */

#define date_time(op,var)	trap13(0x11,(op),(var))
#define GET_TIME	0
#define SET_TIME	1
#define GET_DATE	2
#define SET_DATE	3



/*
 * VME/10 machine dependent stuff.
 */

#define IVNKBD	0x42		/*	keyboard interrupt vector number	*/
#define IVNDSK	0x44		/*	disk controller interrupt vec no	*/
#define IVNSER	0x45		/*	serial port interrupt vector number */

#define IVNABT	0x4e		/*	abort button interrupt vector no	*/


/*
 * system variables provides by BIOS.
 * In GEMDOS, most of them are documented at fixed addresses.
 */
extern int16_t bootdev;
extern BCB *bufl[2];

extern int32_t glbkbchar[3][KBBUFSZ];	/* The actual typeahead buffer */
extern int32_t *buptr[3];
extern int32_t *beptr[3];


VOID xbsettime PROTO((NOTHING));
VOID xbgettime PROTO((NOTHING));
VOID indcall PROTO((intptr_t addr));

#endif /* BIOS_H */
