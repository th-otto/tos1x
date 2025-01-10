#ifndef AESDEFS_H
#define AESDEFS_H

#if TOSVERSION >= 0x100
#undef AESVERSION
#define AESVERSION 0x120
#endif

#if TOSVERSION >= 0x104
#undef AESVERSION
#define AESVERSION 0x140
#endif

#if TOSVERSION >= 0x201
#undef AESVERSION
#define AESVERSION 0x310
#endif

#if TOSVERSION >= 0x206
#undef AESVERSION
#define AESVERSION 0x320
#endif

#if TOSVERSION >= 0x301
#undef AESVERSION
#define AESVERSION 0x300
#endif

#if TOSVERSION >= 0x306
#undef AESVERSION
#define AESVERSION 0x320
#endif

#define NUM_ACCS 1			/* for atari in rom		*/
#define NUM_PDS (NUM_ACCS + 2)		/* acc's + ctrlpd + dos appl.	*/
#define NUM_EVBS (NUM_PDS * 5)		/* 5 * the number of PDs	*/
#define MAX_ACCS 6			/* for atari, from disk		*/
#define EVB_PROC 5			/* for atari, number of EVB per process */

#define KBD_SIZE 8

#define CARTRIDGE	1	/* if rom cartridge exists */

#define DOWARNING	0	/* Do we need initial warning box ?  */

#ifndef BINEXACT
#define BINEXACT 1
#endif

#define	MAXOBJ	    19		/* maximum number of objects in a window */

#define	NUM_WIN	8		/* # window structures per block of memory */

#define STACK_SIZE  448
#define STACK2_SIZE 300
#define STACK3_SIZE 350
#define NFORKS      32
#if AESVERSION >= 0x200
#define QUEUE_SIZE 108
#else
#define QUEUE_SIZE 128
#endif

#define CMDLEN 128

#ifdef __GNUC__
#define LINEF_HACK 0
#else
#define LINEF_HACK (TOSVERSION <= 0x104)
#endif

#endif /* AESDEFS_H */
