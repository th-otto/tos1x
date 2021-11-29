/*
 * resource set indices for gemusa
 *
 * created by ORCS 2.14
 */

/*
 * Number of Strings:        85
 * Number of Bitblks:        11
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       14
 * Number of Free Strings:   29
 * Number of Free Images:    11
 * Number of Objects:        56
 * Number of Trees:          3
 * Number of Userblks:       0
 * Number of Images:         11
 * Total file size:          5214
 */

#undef RSC_NAME
#define RSC_NAME "gemusa"
#undef RSC_ID
#ifdef gemusa
#define RSC_ID gemusa
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 85
#define NUM_FRSTR 29
#define NUM_UD 0
#define NUM_IMAGES 11
#define NUM_BB 11
#define NUM_FRIMG 11
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 14
#define NUM_OBS 56
#define NUM_TREE 3
#endif



#define SELECTOR           0 /* form/dialog */
#define FLABEL             1 /* TEXT in tree SELECTOR */ /* max len 30 */
#define FDIRECTORY         3 /* FBOXTEXT in tree SELECTOR */ /* max len 37 */
#define FSELECTION         5 /* FBOXTEXT in tree SELECTOR */ /* max len 11 */
#define FSDRIVE            6 /* STRING in tree SELECTOR */
#define FCLSBOX            7 /* BOXCHAR in tree SELECTOR */
#define FTITLE             8 /* BOXTEXT in tree SELECTOR */ /* max len 13 */
#define DRVBOX             9 /* BOX in tree SELECTOR */
#define DRIVEA            10 /* BOXCHAR in tree SELECTOR */
#define DRIVEB            11 /* BOXCHAR in tree SELECTOR */
#define DRIVEC            12 /* BOXCHAR in tree SELECTOR */
#define DRIVED            13 /* BOXCHAR in tree SELECTOR */
#define DRIVEE            14 /* BOXCHAR in tree SELECTOR */
#define DRIVEF            15 /* BOXCHAR in tree SELECTOR */
#define DRIVEG            16 /* BOXCHAR in tree SELECTOR */
#define DRIVEH            17 /* BOXCHAR in tree SELECTOR */
#define DRIVEI            18 /* BOXCHAR in tree SELECTOR */
#define DRIVEJ            19 /* BOXCHAR in tree SELECTOR */
#define DRIVEK            20 /* BOXCHAR in tree SELECTOR */
#define DRIVEL            21 /* BOXCHAR in tree SELECTOR */
#define DRIVEM            22 /* BOXCHAR in tree SELECTOR */
#define DRIVEN            23 /* BOXCHAR in tree SELECTOR */
#define DRIVEO            24 /* BOXCHAR in tree SELECTOR */
#define DRIVEP            25 /* BOXCHAR in tree SELECTOR */
#define FILEBOX           26 /* BOX in tree SELECTOR */
#define F1NAME            27 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F2NAME            28 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F3NAME            29 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F4NAME            30 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F5NAME            31 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F6NAME            32 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F7NAME            33 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F8NAME            34 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define F9NAME            35 /* FBOXTEXT in tree SELECTOR */ /* max len 12 */
#define SCRLBAR           36 /* BOX in tree SELECTOR */
#define FDNAROW           37 /* BOXCHAR in tree SELECTOR */
#define FSVSLID           38 /* BOX in tree SELECTOR */
#define FSVELEV           39 /* BOX in tree SELECTOR */
#define FUPAROW           40 /* BOXCHAR in tree SELECTOR */
#define OK                41 /* BUTTON in tree SELECTOR */
#define CANCEL            42 /* BUTTON in tree SELECTOR */

#define ALERT              1 /* form/dialog */

#define SCREEN             2 /* form/dialog */
#define TITLE              2 /* TEXT in tree SCREEN */ /* max len 4 */

#define STPATH             0 /* Free string */
/* PATH= */

#define ST9VAL             1 /* Free string */
/* 0..9 */

#define STAVAL             2 /* Free string */
/* A..Z Äéèêíôö•µ∂∑∏û¬..‹ */

#define STNVAL             3 /* Free string */
/* 0..9A..Z Äéèêíôö•µ∂∑∏û¬..‹ */

#define STPVAL             4 /* Free string */
/* 0..9a..zA..ZÄ..ˇ\?*:._^$~!#%&-{}()@'`+[]<>|;=," */

#define STLPVAL            5 /* Free string */
/* 0..9a..zA..ZÄ..ˇ\:_^$~!#%&-{}()@'`+[]<>|;=," */

#define STFVAL             6 /* Free string */
/* a..z0..9A..ZÄ..ˇ:?*_^$~!#%&-{}()@'`+[]<>|;=," */

#define STLFVAL            7 /* Free string */
/* a..z0..9A..ZÄ..ˇ_^$~!#%&-{}()@'`+[]<>|;=," */

#define STLAVAL            8 /* Free string */
/* a..zA..Z Ä..ˇ */

#define STLNVAL            9 /* Free string */
/* 0..9a..zA..Z Ä..ˇ */

#define STRNG11           10 /* Free string */
/*  */

#define STRNG12           11 /* Free string */
/*  */

#define STRNG13           12 /* Free string */
/*  */

#define FSTRING           13 /* Free string */
/* FILE SELECTOR */

#define ALRT00CRT         14 /* Alert string */
/* [1][The disk in drive %S: is|physically write-protected.][Cancel| Retry ] */

#define ALRT01CRT         15 /* Alert string */
/* [2][Drive %S: is not responding.|Please check the disk drive,|or insert a disk.][Cancel|Retry] */

#define ALRT02CRT         16 /* Alert string */
/* [1][Data on the disk in drive|%S: may be damaged.][Cancel|Retry] */

#define ALRT03CRT         17 /* Alert string */
/* [2][This application cannot read|data on the disk in drive %S:.][Cancel|Retry] */

#define ALRT04CRT         18 /* Alert string */
/* [1][Your output device is not|receiving data.][Cancel|Retry] */

#define ALRT05CRT         19 /* Alert string */
/* [3][GEM error.][Cancel] */

#define ALRT18ERR         20 /* Alert string */
/* [2][This application cannot|find the folder or file|you just tried to access.][  OK  ] */

#define ALRT04ERR         21 /* Alert string */
/* [1][This application does not|have room to open another|document. To make room,|close any document that|you do not need.][  OK  ] */

#define ALRT05ERR         22 /* Alert string */
/* [1][An item with this name|already exists in the|directory, or this item|is set to Read Only status.][  OK  ] */

#define ALRT15ERR         23 /* Alert string */
/* [1][The drive you specified|does not exist.][Cancel] */

#define ALRT08ERR         24 /* Alert string */
/* [1][There is not enough memory|in your computer for the|application you just tried|to run.][  OK  ] */

#define ALRTXXERR         25 /* Alert string */
/* [3][TOS error #%W.][Cancel] */

#define ALRTNOFUNC        26 /* Alert string */
/* [3][Illegal AES function call.][Cancel] */

#define ALRTDSWAP         27 /* Alert string */
/* [3][Please insert disk %S|into drive A:.][  OK  ] */

#define NOMEMORY          28 /* Alert string */
/* [1][The system does not have |enough memory for this|directory.][  OK  ] */

#define NOTEBB             0 /* Free image */

#define QUESBB             1 /* Free image */

#define STOPBB             2 /* Free image */

/* ARROW */
#define MICE0              3 /* Mouse cursor */

/* TEXT_CRSR */
#define MICE1              4 /* Mouse cursor */

/* HOURGLASS */
#define MICE2              5 /* Mouse cursor */

/* POINT_HAND */
#define MICE3              6 /* Mouse cursor */

/* FLAT_HAND */
#define MICE4              7 /* Mouse cursor */

/* THIN_CROSS */
#define MICE5              8 /* Mouse cursor */

/* THICK_CROSS */
#define MICE6              9 /* Mouse cursor */

/* OUTLN_CROSS */
#define MICE7             10 /* Mouse cursor */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD gemusa_rsc_load(void);
extern _WORD gemusa_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD gemusa_rsc_free(void);
#endif
