/* common supervisor stack size (in words) (also defined in bdosdefs.h) */
#ifndef SUPSIZ
#define SUPSIZ 1024
#endif

#define NUMFLOPPIES 2

/* standard for floppy, hard disk */
#define SECTOR_SIZE     512

#define SERIAL_BUFSIZE 256

/* number of sectors for media change detection */
#define BPBSECT 1

/* media def has not changed */
#define MEDIANOCHANGE    0
/* media may have changed */
#define MEDIAMAYCHANGE   1
/* media def has changed */
#define MEDIACHANGE      2

#define NCOOKIES 8

#define MSTECLK (TOSVERSION >= 0x104)

/*
 * used to mark some strange looking code segments
 * that are needed to create a binary equivalent image
 * of the TOS ROMs
 */
#ifndef BINEXACT
#define BINEXACT 1
#endif
