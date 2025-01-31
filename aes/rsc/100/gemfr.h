/*
 * resource set indices for gemfr
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        82
 * Number of Bitblks:        12
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       13
 * Number of Free Strings:   30
 * Number of Free Images:    11
 * Number of Objects:        38
 * Number of Trees:          3
 * Number of Userblks:       0
 * Number of Images:         12
 * Total file size:          4810
 */

#ifdef RSC_NAME
#undef RSC_NAME
#endif
#ifndef __ALCYON__
#define RSC_NAME "gemfr"
#endif
#ifdef RSC_ID
#undef RSC_ID
#endif
#ifdef gemfr
#define RSC_ID gemfr
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 82
#define NUM_FRSTR 30
#define NUM_UD 0
#define NUM_IMAGES 12
#define NUM_BB 12
#define NUM_FRIMG 11
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 13
#define NUM_OBS 38
#define NUM_TREE 3
#endif



#define SELECTOR                           0 /* form/dialog */
#define FLABEL                             1 /* STRING in tree SELECTOR */
#define FDIRECTORY                         2 /* FBOXTEXT in tree SELECTOR */
#define FSELECTION                         3 /* FBOXTEXT in tree SELECTOR */
#define FCLSBOX                            4 /* BOXCHAR in tree SELECTOR */
#define FTITLE                             5 /* BOXTEXT in tree SELECTOR */
#define FILEBOX                            6 /* BOX in tree SELECTOR */
#define F1NAME                            12 /* FBOXTEXT in tree SELECTOR */
#define F2NAME                            13 /* FBOXTEXT in tree SELECTOR */
#define F3NAME                            14 /* FBOXTEXT in tree SELECTOR */
#define F4NAME                            15 /* FBOXTEXT in tree SELECTOR */
#define F5NAME                            16 /* FBOXTEXT in tree SELECTOR */
#define F6NAME                            17 /* FBOXTEXT in tree SELECTOR */
#define F7NAME                            18 /* FBOXTEXT in tree SELECTOR */
#define F8NAME                            19 /* FBOXTEXT in tree SELECTOR */
#define F9NAME                            20 /* FBOXTEXT in tree SELECTOR */
#define SCRLBAR                            7 /* BOX in tree SELECTOR */
#define FUPAROW                            8 /* BOXCHAR in tree SELECTOR */
#define FDNAROW                            9 /* BOXCHAR in tree SELECTOR */
#define FSVSLID                           10 /* BOX in tree SELECTOR */
#define FSVELEV                           11 /* BOX in tree SELECTOR */
#define FSOK                              21 /* BUTTON in tree SELECTOR */
#define FSCANCEL                          22 /* BUTTON in tree SELECTOR */

#define ALERT                              1 /* form/dialog */

#define SCREEN                             2 /* unknown form */
#define TITLE                              2 /* TEXT in tree SCREEN */

#define STPATH                             0 /* Free string */

#define STDESKTOP                          1 /* Free string */

#define STAPP                              2 /* Free string */

#define STACC                              3 /* Free string */

#define ST9VAL                             4 /* Free string */

#define STAVAL                             5 /* Free string */

#define STNVAL                             6 /* Free string */

#define STPVAL                             7 /* Free string */

#define STLPVAL                            8 /* Free string */

#define STFVAL                             9 /* Free string */

#define STLFVAL                           10 /* Free string */

#define STLAVAL                           11 /* Free string */

#define STLNVAL                           12 /* Free string */

#define ALRT00CRT                         13 /* Alert string */

#define ALRT01CRT                         14 /* Alert string */

#define ALRT02CRT                         15 /* Alert string */

#define ALRT03CRT                         16 /* Alert string */

#define ALRT04CRT                         17 /* Alert string */

#define ALRT05CRT                         18 /* Alert string */

#define ALRT18ERR                         19 /* Alert string */

#define STRNG11                           20 /* Free string */

#define ALRT04ERR                         21 /* Alert string */

#define ALRT05ERR                         22 /* Alert string */

#define ALRT15ERR                         23 /* Alert string */

#define ALRT16ERR                         24 /* Free string */

#define ALRT08ERR                         25 /* Alert string */

#define ALRTXXERR                         26 /* Alert string */

#define ALRTNOFUNC                        27 /* Alert string */

#define STRNG13                           28 /* Free string */

#define ALRTDSWAP                         29 /* Alert string */

#define NOTEBB                             0 /* Free image */

#define QUESBB                             1 /* Free image */

#define STOPBB                             2 /* Free image */

#define MICE0                              3 /* Mouse cursor */

#define MICE1                              4 /* Mouse cursor */

#define MICE2                              5 /* Mouse cursor */

#define MICE3                              6 /* Mouse cursor */

#define MICE4                              7 /* Mouse cursor */

#define MICE5                              8 /* Mouse cursor */

#define MICE6                              9 /* Mouse cursor */

#define MICE7                             10 /* Mouse cursor */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD gemfr_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD gemfr_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD gemfr_rsc_free(void);
#endif
