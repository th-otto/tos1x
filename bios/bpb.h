/*
 * BPB - Bios Parameter Block
 */
#ifndef BPB_H
#define BPB_H 1

#define BPB struct _bpb_t
BPB /* bios parameter block */
{
	/*  0 */ int16_t recsiz; 	/* sector size in bytes */
	/*  2 */ int16_t clsiz;		/* cluster size in sectors */
	/*  4 */ int16_t clsizb; 	/* cluster size in bytes */
	/*  6 */ int16_t rdlen;		/* root directory length in records */
	/*  8 */ int16_t fsiz;		/* fat size in records */
	/* 10 */ int16_t fatrec; 	/* first fat record (of last fat) */
	/* 12 */ int16_t datrec; 	/* first data record */
	/* 14 */ int16_t numcl;		/* number of data clusters available */
	/* 16 */ int16_t b_flags;
	/* 18 */ 
};

/*
 * bit usage in b_flags for BPB
 */

#undef B_16 /* also defined in ostruct.h */
#undef B_1FAT
#undef B_XHDI
#define B_16        1		/* device has 16-bit FATs */
#define B_1FAT      2		/* device has only a single FAT */
#define B_XHDI      4       /* extended BPB returned by XHDI drivers */
#define DND_LOCKED  0x8000  /* DND may not be scavenged (see     */
                            /* free_available_dnds() in fsdir.c) */
#endif
