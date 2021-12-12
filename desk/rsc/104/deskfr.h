/*
 * resource set indices for deskfr
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        238
 * Number of Bitblks:        1
 * Number of Iconblks:       5
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       30
 * Number of Free Strings:   37
 * Number of Free Images:    0
 * Number of Objects:        177
 * Number of Trees:          14
 * Number of Userblks:       0
 * Number of Images:         11
 * Total file size:          11878
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "deskfr"
#endif
#undef RSC_ID
#ifdef deskfr
#define RSC_ID deskfr
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 238
#define NUM_FRSTR 37
#define NUM_UD 0
#define NUM_IMAGES 11
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 5
#define NUM_CIB 0
#define NUM_TI 30
#define NUM_OBS 177
#define NUM_TREE 14
#endif



#define ADMENU             0 /* menu */
#define DESKMENU           3 /* TITLE in tree ADMENU */
#define FILEMENU           4 /* TITLE in tree ADMENU */
#define VIEWMENU           5 /* TITLE in tree ADMENU */
#define OPTNMENU           6 /* TITLE in tree ADMENU */
#define ABOUITEM           9 /* STRING in tree ADMENU */
#define OPENITEM          18 /* STRING in tree ADMENU */
#define SHOWITEM          19 /* STRING in tree ADMENU */
#define NEWFITEM          21 /* STRING in tree ADMENU */
#define CLSFITEM          22 /* STRING in tree ADMENU */
#define CLSWITEM          23 /* STRING in tree ADMENU */
#define FORMITEM          25 /* STRING in tree ADMENU */
#define ICONITEM          27 /* STRING in tree ADMENU */
#define TEXTITEM          28 /* STRING in tree ADMENU */
#define NAMEITEM          30 /* STRING in tree ADMENU */
#define DATEITEM          31 /* STRING in tree ADMENU */
#define SIZEITEM          32 /* STRING in tree ADMENU */
#define TYPEITEM          33 /* STRING in tree ADMENU */
#define IDSKITEM          35 /* STRING in tree ADMENU */
#define IAPPITEM          36 /* STRING in tree ADMENU */
#define PREFITEM          38 /* STRING in tree ADMENU */
#define SAVEITEM          39 /* STRING in tree ADMENU */
#define PRINTITEM         40 /* STRING in tree ADMENU */
#define BITBLT            42 /* STRING in tree ADMENU */

#define ADFILEIN           1 /* form/dialog */
#define INFTITLE           1 /* TEXT in tree ADFILEIN */
#define FINAME             2 /* FTEXT in tree ADFILEIN */
#define FISIZE             3 /* FTEXT in tree ADFILEIN */
#define FIDATE             4 /* FTEXT in tree ADFILEIN */
#define FITIME             5 /* FTEXT in tree ADFILEIN */
#define FINFOLDS           6 /* FTEXT in tree ADFILEIN */
#define FINFILES           7 /* FTEXT in tree ADFILEIN */
#define FIRONLY            8 /* BUTTON in tree ADFILEIN */
#define FIRWRITE           9 /* BUTTON in tree ADFILEIN */
#define FIOK              11 /* BUTTON in tree ADFILEIN */
#define FICNCL            12 /* BUTTON in tree ADFILEIN */

#define ADDISKIN           2 /* form/dialog */
#define DIDRIVE            1 /* FTEXT in tree ADDISKIN */
#define DIVOLUME           2 /* FTEXT in tree ADDISKIN */
#define DINFOLDS           3 /* FTEXT in tree ADDISKIN */
#define DINFILES           4 /* FTEXT in tree ADDISKIN */
#define DIUSED             5 /* FTEXT in tree ADDISKIN */
#define DIAVAIL            6 /* FTEXT in tree ADDISKIN */
#define DIOK               7 /* BUTTON in tree ADDISKIN */

#define ADDINFO            3 /* form/dialog */
#define DEOK               9 /* BUTTON in tree ADDINFO */

#define ADOPENAP           4 /* form/dialog */
#define APPLNAME           1 /* FTEXT in tree ADOPENAP */
#define APPLPARM           3 /* FTEXT in tree ADOPENAP */
#define APPLOK             4 /* BUTTON in tree ADOPENAP */
#define APPLCNCL           5 /* BUTTON in tree ADOPENAP */

#define ADINSDIS           5 /* form/dialog */
#define DRID               1 /* FTEXT in tree ADINSDIS */
#define DRLABEL            2 /* FTEXT in tree ADINSDIS */
#define DROK               3 /* BUTTON in tree ADINSDIS */
#define DRREMOVE           4 /* BUTTON in tree ADINSDIS */
#define DRCANCEL           5 /* BUTTON in tree ADINSDIS */

#define ADINSAPP           6 /* form/dialog */
#define APNAME             2 /* FTEXT in tree ADINSAPP */
#define APDFTYPE           3 /* FTEXT in tree ADINSAPP */
#define AUTOBOX            5 /* BUTTON in tree ADINSAPP */
#define NORMALBOX          6 /* BUTTON in tree ADINSAPP */
#define APGEM              9 /* BUTTON in tree ADINSAPP */
#define APDOS             10 /* BUTTON in tree ADINSAPP */
#define APPARMS           11 /* BUTTON in tree ADINSAPP */
#define APOK              12 /* BUTTON in tree ADINSAPP */
#define APREMOVE          13 /* BUTTON in tree ADINSAPP */
#define APCANCEL          14 /* BUTTON in tree ADINSAPP */

#define CPBOX              7 /* form/dialog */
#define NUMDIR             1 /* FTEXT in tree CPBOX */
#define NUMFILE            2 /* FTEXT in tree CPBOX */
#define CPDIR              3 /* FTEXT in tree CPBOX */
#define CPFILE             4 /* FTEXT in tree CPBOX */
#define OKCP               5 /* BUTTON in tree CPBOX */
#define CCANCEL            6 /* BUTTON in tree CPBOX */
#define TITLE              7 /* TEXT in tree CPBOX */

#define SAMENAME           8 /* form/dialog */
#define FNAME              1 /* FTEXT in tree SAMENAME */
#define EDFNAME            2 /* FTEXT in tree SAMENAME */
#define COPY               3 /* BUTTON in tree SAMENAME */
#define QUIT               4 /* BUTTON in tree SAMENAME */
#define SKIP               5 /* BUTTON in tree SAMENAME */
#define SNAME              6 /* TEXT in tree SAMENAME */

#define ADMKDBOX           9 /* form/dialog */
#define MKNAME             1 /* FTEXT in tree ADMKDBOX */
#define MKOK               2 /* BUTTON in tree ADMKDBOX */
#define MKCNCL             3 /* BUTTON in tree ADMKDBOX */

#define ADSETPREF         10 /* form/dialog */
#define SPCDYES            4 /* BUTTON in tree ADSETPREF */
#define SPCDNO             5 /* BUTTON in tree ADSETPREF */
#define SPCCYES            7 /* BUTTON in tree ADSETPREF */
#define SPCCNO             8 /* BUTTON in tree ADSETPREF */
#define YWRITE            10 /* BUTTON in tree ADSETPREF */
#define NWRITE            11 /* BUTTON in tree ADSETPREF */
#define SPLOW             14 /* BUTTON in tree ADSETPREF */
#define SPMEDIUM          15 /* BUTTON in tree ADSETPREF */
#define SPHIGH            16 /* BUTTON in tree ADSETPREF */
#define SPOK              17 /* BUTTON in tree ADSETPREF */
#define SPCANCEL          18 /* BUTTON in tree ADSETPREF */

#define ADFORMAT          11 /* form/dialog */
#define FCBOX4             1 /* BOX in tree ADFORMAT */
#define FCBOXC             2 /* BOX in tree ADFORMAT */
#define SRCDRA             4 /* BOXCHAR in tree ADFORMAT */
#define SRCDRB             5 /* BOXCHAR in tree ADFORMAT */
#define DESTDR             6 /* BOXCHAR in tree ADFORMAT */
#define FCCOPY             7 /* BUTTON in tree ADFORMAT */
#define FCBOXF             9 /* BOX in tree ADFORMAT */
#define ADRIVE            11 /* BOXCHAR in tree ADFORMAT */
#define BDRIVE            12 /* BOXCHAR in tree ADFORMAT */
#define FCLABEL           13 /* FTEXT in tree ADFORMAT */
#define FCSINGLE          16 /* BUTTON in tree ADFORMAT */
#define FCDOUBLE          17 /* BUTTON in tree ADFORMAT */
#define FCFORMAT          18 /* BUTTON in tree ADFORMAT */
#define FCBARA            20 /* BOX in tree ADFORMAT */
#define FCBARB            22 /* BOX in tree ADFORMAT */
#define FCOK              23 /* BUTTON in tree ADFORMAT */
#define FCCNCL            24 /* BUTTON in tree ADFORMAT */

#define ADICON            12 /* free form */
#define IDISK              1 /* ICON in tree ADICON */
#define IDIR               2 /* ICON in tree ADICON */
#define ITRASHCAN          3 /* ICON in tree ADICON */
#define IPRG               4 /* ICON in tree ADICON */
#define IFILE              5 /* ICON in tree ADICON */

#define PRINTFIL          13 /* free form */
#define PFILE              1 /* FTEXT in tree PRINTFIL */

#define STISTR             0 /* Free string */

#define STMORE             1 /* Free string */

#define STENDFILE          2 /* Free string */

#define STCART             3 /* Free string */

#define STCPYSTR           4 /* Free string */

#define STDELSTR           5 /* Free string */

#define STFILEINFO         6 /* Free string */

#define STFOLDINFO         7 /* Free string */

#define STMOVESTR          8 /* Free string */

#define STREADERROR        9 /* Free string */

#define STCANTOPEN        10 /* Free string */

#define STNOMEM           11 /* Free string */

#define STNOAPPL          12 /* Alert string */

#define STNOWIND          13 /* Alert string */

#define STNOOPEN          14 /* Alert string */

#define STFORMAT          15 /* Alert string */

#define STNODRAG          16 /* Alert string */

#define STNOBIN           17 /* Alert string */

#define STCOPY            18 /* Alert string */

#define STNOWIN           19 /* Alert string */

#define STNOBIN2          20 /* Alert string */

#define STFOEXISTS        21 /* Alert string */

#define STDISKFULL        22 /* Alert string */

#define STFOF8DEE         23 /* Alert string */

#define STNOROM           24 /* Alert string */

#define STILLCOPY         25 /* Alert string */

#define TRSINFO           26 /* Alert string */

#define FCNOMEM           27 /* Alert string */

#define FCFAIL            28 /* Alert string */

#define FCSIZE            29 /* Alert string */

#define FCNOTYPE          30 /* Alert string */

#define SAVETOP           31 /* Alert string */

#define PRINTTOP          32 /* Alert string */

#define FCDISKONLY        33 /* Alert string */

#define ABORTCON          34 /* Alert string */

#define NOICON            35 /* Alert string */

#define NOAPP             36 /* Alert string */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD deskfr_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD deskfr_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD deskfr_rsc_free(void);
#endif
