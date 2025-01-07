/*
 * resource set indices for deskde
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        216
 * Number of Bitblks:        1
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       29
 * Number of Free Strings:   29
 * Number of Free Images:    0
 * Number of Objects:        169
 * Number of Trees:          14
 * Number of Userblks:       0
 * Number of Images:         1
 * Total file size:          8578
 */

#ifdef RSC_NAME
#undef RSC_NAME
#endif
#ifndef __ALCYON__
#define RSC_NAME "deskde"
#endif
#ifdef RSC_ID
#undef RSC_ID
#endif
#ifdef deskde
#define RSC_ID deskde
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 216
#define NUM_FRSTR 29
#define NUM_UD 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 29
#define NUM_OBS 169
#define NUM_TREE 14
#endif



#define ADMENU             0 /* form/dialog */
#define DESKMENU           3 /* TITLE in tree ADMENU */
#define FILEMENU           4 /* TITLE in tree ADMENU */
#define VIEWMENU           5 /* TITLE in tree ADMENU */
#define OPTNMENU           6 /* TITLE in tree ADMENU */
#define ABOUITEM           9 /* STRING in tree ADMENU */
#define L1ITEM            10 /* STRING in tree ADMENU */
#define OPENITEM          18 /* STRING in tree ADMENU */
#define SHOWITEM          19 /* STRING in tree ADMENU */
#define NEWFITEM          21 /* STRING in tree ADMENU */
#define CLSFITEM          22 /* STRING in tree ADMENU */
#define CLOSWITEM         23 /* STRING in tree ADMENU */
#define FORMITEM          25 /* STRING in tree ADMENU */
#define ICONITEM          29 /* STRING in tree ADMENU */
#define TEXTITEM          30 /* STRING in tree ADMENU */
#define NAMEITEM          32 /* STRING in tree ADMENU */
#define DATEITEM          33 /* STRING in tree ADMENU */
#define SIZEITEM          34 /* STRING in tree ADMENU */
#define TYPEITEM          35 /* STRING in tree ADMENU */
#define IDSKITEM          37 /* STRING in tree ADMENU */
#define IAPPITEM          38 /* STRING in tree ADMENU */
#define PREFITEM          40 /* STRING in tree ADMENU */
#define SAVEITEM          41 /* STRING in tree ADMENU */
#define PRINTITEM         42 /* STRING in tree ADMENU */

#define ADFILEIN           1 /* form/dialog */
#define INFTITLE           1 /* STRING in tree ADFILEIN */
#define FINAME             2 /* FBOXTEXT in tree ADFILEIN */
#define FIBYTES            3 /* FBOXTEXT in tree ADFILEIN */
#define FIDATE             4 /* FBOXTEXT in tree ADFILEIN */
#define FITIME             5 /* FBOXTEXT in tree ADFILEIN */
#define FIRWRITE           8 /* BUTTON in tree ADFILEIN */
#define FIRONLY            9 /* BUTTON in tree ADFILEIN */
#define FIOK              10 /* BUTTON in tree ADFILEIN */
#define FICNCL            11 /* BUTTON in tree ADFILEIN */

#define ADDISKIN           2 /* form/dialog */
#define DIDRIVE            2 /* FBOXTEXT in tree ADDISKIN */
#define DIVOLUME           3 /* FBOXTEXT in tree ADDISKIN */
#define DINFOLDS           4 /* FBOXTEXT in tree ADDISKIN */
#define DINFILES           5 /* FBOXTEXT in tree ADDISKIN */
#define DIUSED             6 /* FBOXTEXT in tree ADDISKIN */
#define DIAVAIL            7 /* FBOXTEXT in tree ADDISKIN */
#define DIOK               8 /* BUTTON in tree ADDISKIN */

#define ADFINFO            3 /* form/dialog */
#define FONAME             2 /* FBOXTEXT in tree ADFINFO */
#define FODATE             3 /* FBOXTEXT in tree ADFINFO */
#define FOTIME             4 /* FBOXTEXT in tree ADFINFO */
#define FONFOLDS           5 /* FBOXTEXT in tree ADFINFO */
#define FONFILES           6 /* FBOXTEXT in tree ADFINFO */
#define FOUSED             7 /* FBOXTEXT in tree ADFINFO */
#define FOOK               8 /* BUTTON in tree ADFINFO */

#define ADDINFO            4 /* form/dialog */
#define DEOK              11 /* BUTTON in tree ADDINFO */

#define ADPINFO            5 /* form/dialog */
#define APDOK              7 /* BUTTON in tree ADPINFO */

#define ADOPENAP           6 /* form/dialog */
#define APPLNAME           2 /* FBOXTEXT in tree ADOPENAP */
#define APPLPARM           3 /* FBOXTEXT in tree ADOPENAP */
#define APPLOK             4 /* BUTTON in tree ADOPENAP */
#define APPLCNCL           5 /* BUTTON in tree ADOPENAP */

#define ADINSDIS           7 /* form/dialog */
#define DRID               2 /* FBOXTEXT in tree ADINSDIS */
#define DRLABEL            3 /* FBOXTEXT in tree ADINSDIS */
#define DROK               8 /* BUTTON in tree ADINSDIS */
#define DRREMOVE           9 /* BUTTON in tree ADINSDIS */
#define DRCANCEL          10 /* BUTTON in tree ADINSDIS */

#define ADINSAPP           8 /* form/dialog */

#define CPBOX              9 /* form/dialog */
#define NUMDIR             2 /* FBOXTEXT in tree CPBOX */
#define NUMFILE            3 /* FBOXTEXT in tree CPBOX */
#define OKCP               4 /* BUTTON in tree CPBOX */
#define CCANCEL            5 /* BUTTON in tree CPBOX */

#define DELBOX            10 /* form/dialog */
#define DELDIR             2 /* FBOXTEXT in tree DELBOX */
#define DELFILES           3 /* FBOXTEXT in tree DELBOX */
#define DELOK              4 /* BUTTON in tree DELBOX */
#define DELCNCL            5 /* BUTTON in tree DELBOX */

#define SAMENAME          11 /* form/dialog */
#define SNAME              1 /* STRING in tree SAMENAME */
#define FNAME              2 /* FBOXTEXT in tree SAMENAME */
#define EDFNAME            3 /* FBOXTEXT in tree SAMENAME */
#define COPY               4 /* BUTTON in tree SAMENAME */
#define QUIT               5 /* BUTTON in tree SAMENAME */

#define ADMKDBOX          12 /* form/dialog */
#define MKNAME             2 /* FBOXTEXT in tree ADMKDBOX */
#define MKOK               3 /* BUTTON in tree ADMKDBOX */
#define MKCNCL             4 /* BUTTON in tree ADMKDBOX */

#define ADSETPREF         13 /* form/dialog */
#define SPCDYES            4 /* BUTTON in tree ADSETPREF */
#define SPCDNO             5 /* BUTTON in tree ADSETPREF */
#define SPCCYES            8 /* BUTTON in tree ADSETPREF */
#define SPCCNO             9 /* BUTTON in tree ADSETPREF */
#define SPOK              17 /* BUTTON in tree ADSETPREF */
#define SPCANCEL          18 /* BUTTON in tree ADSETPREF */
#define SPLOW             21 /* BUTTON in tree ADSETPREF */
#define SPMEDIUM          22 /* BUTTON in tree ADSETPREF */
#define SPHIGH            23 /* BUTTON in tree ADSETPREF */

#define STINFOST           0 /* Free string */

#define STR002             1 /* Free string */

#define STTPRINT           2 /* Free string */

#define STTFORMAT          3 /* Free string */

#define STTCOPY            4 /* Free string */

#define STR006             5 /* Free string */

#define STNOAPPL           6 /* Alert string */

#define STNOWIND           7 /* Alert string */

#define STNOOPEN           8 /* Alert string */

#define STFORMAT           9 /* Alert string */

#define STNO2DRAG         10 /* Alert string */

#define STNODRAG          11 /* Alert string */

#define STNOBIN           12 /* Alert string */

#define STCOPY            13 /* Alert string */

#define STNOWIN           14 /* Alert string */

#define STNOIMAGE         15 /* Alert string */

#define STSAMENAME        16 /* Alert string */

#define FCNOMEM           17 /* Alert string */

#define STEXISTS          18 /* Alert string */

#define STDEEP            19 /* Alert string */

#define STROMRDONLY       20 /* Alert string */

#define STR022            21 /* Free string */

#define STILLCOPY         22 /* Alert string */

#define STACC1            23 /* Free string */

#define STACC2            24 /* Free string */

#define STACC3            25 /* Free string */

#define STACC4            26 /* Free string */

#define STACC5            27 /* Free string */

#define STACC6            28 /* Free string */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD deskde_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD deskde_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD deskde_rsc_free(void);
#endif
