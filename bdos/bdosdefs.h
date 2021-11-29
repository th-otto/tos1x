/* major.minor */
#if TOSVERSION >= 0x0100
#undef GEMDOS
#define GEMDOS 0x0013
#endif
#if TOSVERSION >= 0x0103
#undef GEMDOS
#define GEMDOS 0x0014
#endif
#if TOSVERSION >= 0x0104
#undef GEMDOS
#define GEMDOS 0x0015
#endif
#if TOSVERSION >= 0x0162
#undef GEMDOS
#define GEMDOS 0x0017
#endif
#if TOSVERSION >= 0x0201
#undef GEMDOS
#define GEMDOS 0x0019
#endif
#if TOSVERSION >= 0x0206
#undef GEMDOS
#define GEMDOS 0x0020
#endif
#if TOSVERSION >= 0x0300
#undef GEMDOS
#define GEMDOS 0x0018
#endif
#if TOSVERSION >= 0x0301
#undef GEMDOS
#define GEMDOS 0x0019
#endif
#if TOSVERSION >= 0x0306
#undef GEMDOS
#define GEMDOS 0x0020
#endif
#if TOSVERSION >= 0x0400
#undef GEMDOS
#define GEMDOS 0x0030
#endif


/* common supervisor stack size (in words) (also defined in biosdefs.h) */
#ifndef SUPSIZ
#define SUPSIZ 1024
#endif
/* max open files in system */
#define OPNFILES 81
/* max current directories in use in system */
#define NCURDIR 40
/* number of block devices supported: A: ... Z: */
#define BLKDEVNUM 16
/* size of typeahead buffer */
#define KBBUFSZ 80
/* for compatibility with older versions: size of root array */
#define MAXQUICK 5

/*
 * support for filesystems with 1 fat only
 */
#define FAT1_SUPPORT (GEMDOS >= 0x18)

/*
 * support for alternate ram
 */
#define ALTRAM_SUPPORT (GEMDOS >= 0x18)
