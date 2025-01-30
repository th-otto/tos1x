/*
 * resource set indices for fmtde
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        26
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       4
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        26
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          1050
 */

#ifdef RSC_NAME
#undef RSC_NAME
#endif
#ifndef __ALCYON__
#define RSC_NAME "fmtde"
#endif
#ifdef RSC_ID
#undef RSC_ID
#endif
#ifdef fmtde
#define RSC_ID fmtde
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 26
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 4
#define NUM_OBS 26
#define NUM_TREE 1
#endif



#define ADFORMAT                           0 /* form/dialog */
#define FCDRIVE                            2 /* FBOXTEXT in tree ADFORMAT */
#define FCLABEL                            3 /* FBOXTEXT in tree ADFORMAT */
#define FCSIDEBOX                          5 /* IBOX in tree ADFORMAT */
#define FCSINGLE                           7 /* BUTTON in tree ADFORMAT */
#define FCDOUBLE                           8 /* BUTTON in tree ADFORMAT */
#define FCCNCL                             9 /* BUTTON in tree ADFORMAT */
#define FCFORMAT                          10 /* BUTTON in tree ADFORMAT */
#define FCCOPYBOX                         11 /* BOX in tree ADFORMAT */
#define FCEXIT                            15 /* BUTTON in tree ADFORMAT */
#define FCCOPY                            16 /* BUTTON in tree ADFORMAT */
#define FCPROGRESS                        17 /* BOX in tree ADFORMAT */
#define FCCMD                             18 /* STRING in tree ADFORMAT */
#define FCBOXS                            20 /* BOX in tree ADFORMAT */
#define FCBARS                            21 /* BOX in tree ADFORMAT */
#define FCBOXD                            22 /* BOX in tree ADFORMAT */
#define FCBARD                            25 /* BOX in tree ADFORMAT */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD fmtde_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD fmtde_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD fmtde_rsc_free(void);
#endif
