/*
 * GEM resource C output of deskdk
 *
 * created by ORCS 2.18
 */

#if !defined(__GNUC__) || !defined(__mc68000__)
#include <portab.h>
#endif

#ifndef __STDC__
# ifdef __PUREC__
#  define __STDC__ 1
# endif
#endif

#ifdef OS_WINDOWS
#  include <portaes.h>
#  define SHORT _WORD
#  ifdef __WIN32__
#    define _WORD signed short
#  else
#    define _WORD signed int
 #   pragma option -zE_FARDATA
#  endif
#else
#  ifdef __TURBOC__
#    include <aes.h>
#    define CP (_WORD *)
#  endif
#endif

#ifdef OS_UNIX
#  include <portaes.h>
#  define SHORT _WORD
#else
#  ifdef __GNUC__
#    ifndef __PORTAES_H__
#      if __GNUC__ < 4
#        include <aesbind.h>
#        ifndef _WORD
#          define _WORD int
#        endif
#        define CP (char *)
#      else
#        include <mt_gem.h>
#        ifndef _WORD
#          define _WORD short
#        endif
#        define CP (short *)
#      endif
#      define CW (short *)
#    endif
#  endif
#endif


#ifdef __SOZOBONX__
#  include <xgemfast.h>
#else
#  ifdef SOZOBON
#    include <aes.h>
#  endif
#endif

#ifdef MEGAMAX
#  include <gembind.h>
#  include <gemdefs.h>
#  include <obdefs.h>
#  define _WORD int
#  define SHORT int
#endif

#ifndef _VOID
#  define _VOID void
#endif

#ifndef OS_NORMAL
#  define OS_NORMAL 0x0000
#endif
#ifndef OS_SELECTED
#  define OS_SELECTED 0x0001
#endif
#ifndef OS_CROSSED
#  define OS_CROSSED 0x0002
#endif
#ifndef OS_CHECKED
#  define OS_CHECKED 0x0004
#endif
#ifndef OS_DISABLED
#  define OS_DISABLED 0x0008
#endif
#ifndef OS_OUTLINED
#  define OS_OUTLINED 0x0010
#endif
#ifndef OS_SHADOWED
#  define OS_SHADOWED 0x0020
#endif
#ifndef OS_WHITEBAK
#  define OS_WHITEBAK 0x0040
#endif
#ifndef OS_DRAW3D
#  define OS_DRAW3D 0x0080
#endif

#ifndef OF_NONE
#  define OF_NONE 0x0000
#endif
#ifndef OF_SELECTABLE
#  define OF_SELECTABLE 0x0001
#endif
#ifndef OF_DEFAULT
#  define OF_DEFAULT 0x0002
#endif
#ifndef OF_EXIT
#  define OF_EXIT 0x0004
#endif
#ifndef OF_EDITABLE
#  define OF_EDITABLE 0x0008
#endif
#ifndef OF_RBUTTON
#  define OF_RBUTTON 0x0010
#endif
#ifndef OF_LASTOB
#  define OF_LASTOB 0x0020
#endif
#ifndef OF_TOUCHEXIT
#  define OF_TOUCHEXIT 0x0040
#endif
#ifndef OF_HIDETREE
#  define OF_HIDETREE 0x0080
#endif
#ifndef OF_INDIRECT
#  define OF_INDIRECT 0x0100
#endif
#ifndef OF_FL3DIND
#  define OF_FL3DIND 0x0200
#endif
#ifndef OF_FL3DBAK
#  define OF_FL3DBAK 0x0400
#endif
#ifndef OF_FL3DACT
#  define OF_FL3DACT 0x0600
#endif
#ifndef OF_MOVEABLE
#  define OF_MOVEABLE 0x0800
#endif
#ifndef OF_POPUP
#  define OF_POPUP 0x1000
#endif

#ifndef R_CICONBLK
#  define R_CICONBLK 17
#endif
#ifndef R_CICON
#  define R_CICON 18
#endif

#ifndef G_SWBUTTON
#  define G_SWBUTTON 34
#endif
#ifndef G_POPUP
#  define G_POPUP 35
#endif
#ifndef G_EDIT
#  define G_EDIT 37
#endif
#ifndef G_SHORTCUT
#  define G_SHORTCUT 38
#endif
#ifndef G_SLIST
#  define G_SLIST 39
#endif
#ifndef G_EXTBOX
#  define G_EXTBOX 40
#endif
#ifndef G_OBLINK
#  define G_OBLINK 41
#endif

#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    ifdef __PUREC__
#      define _WORD int
#    else
#      define _WORD short
#    endif
#  endif
#endif

#ifndef _UBYTE
#  define _UBYTE char
#endif

#ifndef _BOOL
#  define _BOOL int
#endif

#ifndef _LONG
#  ifdef LONG
#    define _LONG LONG
#  else
#    define _LONG long
#  endif
#endif

#ifndef _ULONG
#  ifdef ULONG
#    define _ULONG ULONG
#  else
#    define _ULONG unsigned long
#  endif
#endif

#ifndef _LONG_PTR
#  define _LONG_PTR _LONG
#endif

#ifndef C_UNION
#ifdef __PORTAES_H__
#  define C_UNION(x) { (_LONG_PTR)(x) }
#endif
#ifdef __GEMLIB__
#  define C_UNION(x) { (_LONG_PTR)(x) }
#endif
#ifdef __PUREC__
#  define C_UNION(x) { (_LONG_PTR)(x) }
#endif
#ifdef __ALCYON__
#  define C_UNION(x) x
#endif
#endif
#ifndef C_UNION
#  define C_UNION(x) (_LONG_PTR)(x)
#endif

#ifndef SHORT
#  define SHORT short
#endif

#ifndef CP
#  define CP (SHORT *)
#endif

#ifndef CW
#  define CW (_WORD *)
#endif


#undef RSC_STATIC_FILE
#define RSC_STATIC_FILE 1

#include "deskdk.h"

#ifndef RSC_NAMED_FUNCTIONS
#  define RSC_NAMED_FUNCTIONS 0
#endif

#ifndef __ALCYON__
#undef defRSHInit
#undef defRSHInitBit
#undef defRSHInitStr
#ifndef RsArraySize
#define RsArraySize(array) (_WORD)(sizeof(array)/sizeof(array[0]))
#define RsPtrArraySize(type, array) (type *)array, RsArraySize(array)
#endif
#define defRSHInit( aa, bb ) RSHInit( aa, bb, RsPtrArraySize(OBJECT *, rs_trindex), RsArraySize(rs_object) )
#define defRSHInitBit( aa, bb ) RSHInitBit( aa, bb, RsPtrArraySize(BITBLK *, rs_frimg) )
#define defRSHInitStr( aa, bb ) RSHInitStr( aa, bb, RsPtrArraySize(_UBYTE *, rs_frstr) )
#endif

#ifdef __STDC__
#ifndef W_Cicon_Setpalette
extern _BOOL W_Cicon_Setpalette(_WORD *_palette);
#endif
#ifndef hrelease_objs
extern void hrelease_objs(OBJECT *_ob, _WORD _num_objs);
#endif
#ifndef hfix_objs
extern void *hfix_objs(RSHDR *_hdr, OBJECT *_ob, _WORD _num_objs);
#endif
#endif

#ifndef RLOCAL
#  if RSC_STATIC_FILE
#    ifdef LOCAL
#      define RLOCAL LOCAL
#    else
#      define RLOCAL static
#    endif
#  else
#    define RLOCAL
#  endif
#endif


#ifndef N_
#  define N_(x)
#endif


#if RSC_STATIC_FILE
#undef NUM_STRINGS
#undef NUM_BB
#undef NUM_IB
#undef NUM_CIB
#undef NUM_CIC
#undef NUM_TI
#undef NUM_FRSTR
#undef NUM_FRIMG
#undef NUM_OBS
#undef NUM_TREE
#undef NUM_UD
#define NUM_STRINGS 228
#define NUM_BB		1
#define NUM_IB		0
#define NUM_CIB     0
#define NUM_CIC     0
#define NUM_TI		29
#define NUM_FRSTR	29
#define NUM_FRIMG	0
#define NUM_OBS     170
#define NUM_TREE	14
#define NUM_UD		0
#endif


static char deskdk_string_0[] = " DESK ";
static char deskdk_string_1[] = " ARKIV ";
static char deskdk_string_2[] = "INDHOLD";
static char deskdk_string_3[] = " \262VRIGT ";
static char deskdk_string_4[] = "  Desktop Info...";
static char deskdk_string_5[] = "---------------------";
static char deskdk_string_6[] = "  1";
static char deskdk_string_7[] = "  2";
static char deskdk_string_8[] = "  3";
static char deskdk_string_9[] = "  4";
static char deskdk_string_10[] = "  5";
static char deskdk_string_11[] = "  6";
static char deskdk_string_12[] = "  \217bne";
static char deskdk_string_13[] = "  Vise info...";
static char deskdk_string_14[] = "---------------";
static char deskdk_string_15[] = "  Ny mappe";
static char deskdk_string_16[] = "  Lukke";
static char deskdk_string_17[] = "  Lukke vindue";
static char deskdk_string_18[] = "---------------";
static char deskdk_string_19[] = "  Formatere...";
static char deskdk_string_20[] = "";
static char deskdk_string_21[] = "";
static char deskdk_string_22[] = "  Ikoner";
static char deskdk_string_23[] = "  Tekst";
static char deskdk_string_24[] = "-Sort\212r efter-";
static char deskdk_string_25[] = "  Navn..";
static char deskdk_string_26[] = "  Dato..";
static char deskdk_string_27[] = "  St\263rrelse..";
static char deskdk_string_28[] = "  Type..";
static char deskdk_string_29[] = "  Instal. Diskdrev";
static char deskdk_string_30[] = "  Instal. program";
static char deskdk_string_31[] = "-------------------";
static char deskdk_string_32[] = "  Systemops\221tning";
static char deskdk_string_33[] = "  Sk\221rmsikring";
static char deskdk_string_34[] = "  Udskrift";
static char deskdk_string_35[] = "FIL INFO: ";
static char deskdk_string_36[] = "@";
static char deskdk_string_37[] = "Navn:  ________.___";
static char deskdk_string_38[] = "F";
static char deskdk_string_39[] = "@2345678\0By";
static char deskdk_string_40[] = "Bytes:  ________";
static char deskdk_string_41[] = "9";
static char deskdk_string_42[] = "@5432";
static char deskdk_string_43[] = "fra:  __/__/__";
static char deskdk_string_44[] = "9";
static char deskdk_string_45[] = "@1234";
static char deskdk_string_46[] = "__:__ __";
static char deskdk_string_47[] = "9999aa";
static char deskdk_string_48[] = " Status:";
static char deskdk_string_49[] = "L\221se og skrive ";
static char deskdk_string_50[] = "Kun l\221se ";
static char deskdk_string_51[] = "OK";
static char deskdk_string_52[] = "AFBRYD ";
static char deskdk_string_53[] = "DISK-INFO";
static char deskdk_string_54[] = "@";
static char deskdk_string_55[] = "    Identitet:  _:";
static char deskdk_string_56[] = "A";
static char deskdk_string_57[] = "@2345678901";
static char deskdk_string_58[] = "Disknavn: ________.___";
static char deskdk_string_59[] = "F";
static char deskdk_string_60[] = "@1234";
static char deskdk_string_61[] = "Mapper:     _____";
static char deskdk_string_62[] = "9";
static char deskdk_string_63[] = "@2345";
static char deskdk_string_64[] = "  Filer:     _____";
static char deskdk_string_65[] = "9";
static char deskdk_string_66[] = "@7654321";
static char deskdk_string_67[] = "       Brugt:  ________";
static char deskdk_string_68[] = "9";
static char deskdk_string_69[] = "@1010101";
static char deskdk_string_70[] = "   Tilbage:  ________";
static char deskdk_string_71[] = "9";
static char deskdk_string_72[] = "OK";
static char deskdk_string_73[] = "MAPPE-INFO ";
static char deskdk_string_74[] = "@2345678999";
static char deskdk_string_75[] = "Mappe navn: ________.___";
static char deskdk_string_76[] = "F";
static char deskdk_string_77[] = "@ddddd";
static char deskdk_string_78[] = "fra: __-__-__  ";
static char deskdk_string_79[] = "9";
static char deskdk_string_80[] = "@hhhhh";
static char deskdk_string_81[] = "__:__ __";
static char deskdk_string_82[] = "9999aa";
static char deskdk_string_83[] = "@1234";
static char deskdk_string_84[] = "Mapper:     _____";
static char deskdk_string_85[] = "9";
static char deskdk_string_86[] = "@2345";
static char deskdk_string_87[] = "  Filer:     _____";
static char deskdk_string_88[] = "9";
static char deskdk_string_89[] = "@7654321";
static char deskdk_string_90[] = "       Brugt:  ________";
static char deskdk_string_91[] = "9";
static char deskdk_string_92[] = "OK";
static char deskdk_string_93[] = "GEM, Graphics Environment Manager";
static char deskdk_string_94[] = "---------------";
static char deskdk_string_95[] = "        TOS";
static char deskdk_string_96[] = "";
static char deskdk_string_97[] = "";
static char deskdk_string_98[] = "All Rights Reserved.";
static char deskdk_string_99[] = "Copyright (c) 1985";
static char deskdk_string_100[] = "Digital Research, Inc.";
static char deskdk_string_101[] = "ATARI CORP.";
static char deskdk_string_102[] = "OK";
static char deskdk_string_103[] = "PAPIRKURV INFORMATION ";
static char deskdk_string_104[] = "Det som skal slettes PER- ";
static char deskdk_string_105[] = "MANENT, kan du flytte til ";
static char deskdk_string_106[] = "papirkurven.             ";
static char deskdk_string_107[] = "";
static char deskdk_string_108[] = "";
static char deskdk_string_109[] = "OK";
static char deskdk_string_110[] = "\217BNE PROGRAM    ";
static char deskdk_string_111[] = "@2345678901";
static char deskdk_string_112[] = "Navn:  ________.___";
static char deskdk_string_113[] = "F";
static char deskdk_string_114[] = "@1234567890123456789012345678901234567";
static char deskdk_string_115[] = "______________________________________";
static char deskdk_string_116[] = "X";
static char deskdk_string_117[] = "OK";
static char deskdk_string_118[] = "AFBRYD ";
static char deskdk_string_119[] = "Parametre:";
static char deskdk_string_120[] = "INSTALLERE DREV";
static char deskdk_string_121[] = "@";
static char deskdk_string_122[] = "    Identitet: _";
static char deskdk_string_123[] = "a";
static char deskdk_string_124[] = "@23456789012";
static char deskdk_string_125[] = "Ikon navn: ____________";
static char deskdk_string_126[] = "X";
static char deskdk_string_127[] = "";
static char deskdk_string_128[] = "";
static char deskdk_string_129[] = "";
static char deskdk_string_130[] = " INSTAL.";
static char deskdk_string_131[] = " FJERN ";
static char deskdk_string_132[] = "AFBRYD ";
static char deskdk_string_133[] = "INSTALLERE PROGRAM";
static char deskdk_string_134[] = "@2345679012";
static char deskdk_string_135[] = "Navn:  ________.___";
static char deskdk_string_136[] = "F";
static char deskdk_string_137[] = "@12\0Dok.Typ";
static char deskdk_string_138[] = "Dok.Type:  ___";
static char deskdk_string_139[] = "F";
static char deskdk_string_140[] = " Program Type:";
static char deskdk_string_141[] = "GEM";
static char deskdk_string_142[] = "TOS";
static char deskdk_string_143[] = "TOS-med paremetre    ";
static char deskdk_string_144[] = "OK";
static char deskdk_string_145[] = "AFBRYD ";
static char deskdk_string_146[] = "";
static char deskdk_string_147[] = "KOPIERE MAPPER/FILER   ";
static char deskdk_string_148[] = "@234";
static char deskdk_string_149[] = "Mapper at kopiere:  ____";
static char deskdk_string_150[] = "9";
static char deskdk_string_151[] = "@432";
static char deskdk_string_152[] = "  Filer at kopiere:  ____";
static char deskdk_string_153[] = "9";
static char deskdk_string_154[] = "OK";
static char deskdk_string_155[] = "AFBRYD ";
static char deskdk_string_156[] = "SLETTE MAPPER/FILER   ";
static char deskdk_string_157[] = "@980";
static char deskdk_string_158[] = " Mapper at slette:  ____";
static char deskdk_string_159[] = "9";
static char deskdk_string_160[] = "@678";
static char deskdk_string_161[] = "   Filer at slette:  ____";
static char deskdk_string_162[] = "9";
static char deskdk_string_163[] = "OK";
static char deskdk_string_164[] = "AFBRYD ";
static char deskdk_string_165[] = "NAVN FINDES P\217 DISK  ";
static char deskdk_string_166[] = "";
static char deskdk_string_167[] = "  Nuv\221rende navn:  ________.___";
static char deskdk_string_168[] = "F";
static char deskdk_string_169[] = "";
static char deskdk_string_170[] = "  Kopiens navn:  ________.___";
static char deskdk_string_171[] = "F";
static char deskdk_string_172[] = "OK";
static char deskdk_string_173[] = "AFBRYD ";
static char deskdk_string_174[] = "NY MAPPE    ";
static char deskdk_string_175[] = "";
static char deskdk_string_176[] = "Navn:  ________.___";
static char deskdk_string_177[] = "F";
static char deskdk_string_178[] = "OK";
static char deskdk_string_179[] = "AFBRYD ";
static char deskdk_string_180[] = "GRUNDINDSTIL. ";
static char deskdk_string_181[] = "Bekr\221ft sletning:";
static char deskdk_string_182[] = "JA";
static char deskdk_string_183[] = "NEJ ";
static char deskdk_string_184[] = "Bekr\221ft kopiering:";
static char deskdk_string_185[] = "JA";
static char deskdk_string_186[] = "NEJ ";
static char deskdk_string_187[] = "";
static char deskdk_string_188[] = "";
static char deskdk_string_189[] = "";
static char deskdk_string_190[] = "";
static char deskdk_string_191[] = "";
static char deskdk_string_192[] = "";
static char deskdk_string_193[] = "OK";
static char deskdk_string_194[] = "AFBRYD ";
static char deskdk_string_195[] = "     Sk\221rmopl\263sning:";
static char deskdk_string_196[] = " LAV  ";
static char deskdk_string_197[] = "MIDDEL";
static char deskdk_string_198[] = "H\262J ";
static char deskdk_string_199[] = " %L Bytes i %W Filer.   ";
static char deskdk_string_200[] = " ";
static char deskdk_string_201[] = "PRINT ";
static char deskdk_string_202[] = "FORMATERE  ";
static char deskdk_string_203[] = "DISKKOPI ";
static char deskdk_string_204[] = " ";
static char deskdk_string_205[] = "[1][Dokumentet kan enten vises|p\206 sk\221rmen eller udskrives.    ][VIS|UDSKRIV|AFBRYD]";
static char deskdk_string_206[] = "[1][Der kan ikke \206bnes flere|vinduer. Luk et af de|vinduer som ikke anvendes.|  ][ OK ]";
static char deskdk_string_207[] = "[1][Du kan ikke \206bne|papirkurvens ikon.    ][  OK  ]";
static char deskdk_string_208[] = "[3][Formatering vil slette alle|data p\206 disk %S:.    ][ OK |AFBRYD]";
static char deskdk_string_209[] = "[1][Du kan kun kopiere til en|disk, mappe eller et vindue.    ][ OK ]";
static char deskdk_string_210[] = "[1][Denne ikon kan ikke placeres|over en anden ikon.      ][  OK  ]";
static char deskdk_string_211[] = "[1][Du kan ikke flytte en|disk til papirkurven.|V\221lg \'Formatere..\'|fra menuen.][ OK ]";
static char deskdk_string_212[] = "[3][Kopiering af diskette %S: til|diskette %S:, vil slette alle|informationer p\206 diskette %S:.][ OK |AFBRYD]";
static char deskdk_string_213[] = "[1][Du kan ikke flytte objekter|fra et vindue til DESKTOP.][ OK ]";
static char deskdk_string_214[] = "[1][Du kan ikke flytte ikoner|til et vindue. ][ OK ]";
static char deskdk_string_215[] = "[2][Navnet findes allerede.|V\221lg et andet navn|eller afbryd.       |        ][AFBRYD|NYT FORS\262G]";
static char deskdk_string_216[] = "[1][Der er ikke plads nok|til denne operation.][  OK  ]";
static char deskdk_string_217[] = "[2][En fil med dette navn|eksisterer.      ][ OK ]";
static char deskdk_string_218[] = "[3][Du kan ikke oprette eller|\206bne en mappe s\206 langt inde|i kataloget.             ][  OK  ]";
static char deskdk_string_219[] = "[1][Du kan ikke flytte objekter|til eller fra en kapsel.][  OK  ]";
static char deskdk_string_220[] = " ";
static char deskdk_string_221[] = "[1][Fejlagtig kopi operation.  ][  OK  ]";
static char deskdk_string_222[] = " DESK ";
static char deskdk_string_223[] = " DESK ";
static char deskdk_string_224[] = " DESK ";
static char deskdk_string_225[] = " DESK ";
static char deskdk_string_226[] = " DESK ";
static char deskdk_string_227[] = " DESK ";


static _UBYTE deskdk_IMAGE0[] = {
0x00, 0x00, 0x00, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00,
0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x3B, 0xB8, 0x00,
0x00, 0x3B, 0xB8, 0x00, 0x00, 0x3B, 0xB8, 0x00, 0x00, 0x3B, 0xB8, 0x00, 0x00, 0x7B, 0xBC, 0x00,
0x00, 0x7B, 0xBC, 0x00, 0x00, 0xFB, 0xBE, 0x00, 0x01, 0xF3, 0x9F, 0x00, 0x03, 0xF3, 0x9F, 0x80,
0x0F, 0xE3, 0x8F, 0xE0, 0x7F, 0xC3, 0x87, 0xFC, 0x7F, 0x83, 0x83, 0xFC, 0x7E, 0x03, 0x80, 0xFC,
0x78, 0x03, 0x80, 0x3C, 0x00, 0x00, 0x00, 0x00, 0x09, 0xF9, 0x0F, 0x8C, 0x1D, 0xFB, 0x8F, 0xCC,
0x1C, 0x63, 0x8C, 0xEC, 0x36, 0x66, 0xCC, 0xEC, 0x36, 0x66, 0xCD, 0xCC, 0x7F, 0x6F, 0xED, 0x8C,
0x7F, 0x6F, 0xED, 0xCC, 0x63, 0x6C, 0x6C, 0xEC, 0x63, 0x6C, 0x6C, 0x6C, 0x00, 0x00, 0x00, 0x00};


static char *rs_frstr[NUM_FRSTR] = {
	deskdk_string_199,
	deskdk_string_200,
	deskdk_string_201,
	deskdk_string_202,
	deskdk_string_203,
	deskdk_string_204,
	deskdk_string_205,
	deskdk_string_206,
	deskdk_string_207,
	deskdk_string_208,
	deskdk_string_209,
	deskdk_string_210,
	deskdk_string_211,
	deskdk_string_212,
	deskdk_string_213,
	deskdk_string_214,
	deskdk_string_215,
	deskdk_string_216,
	deskdk_string_217,
	deskdk_string_218,
	deskdk_string_219,
	deskdk_string_220,
	deskdk_string_221,
	deskdk_string_222,
	deskdk_string_223,
	deskdk_string_224,
	deskdk_string_225,
	deskdk_string_226,
	deskdk_string_227
};


static BITBLK rs_bitblk[NUM_BB] = {
	{ CP deskdk_IMAGE0, 4, 32, 0, 0, 1 }
};


static TEDINFO rs_tedinfo[NUM_TI] = {
	{ deskdk_string_36, deskdk_string_37, deskdk_string_38, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 2,22 }, /* FINAME */
	{ deskdk_string_39, deskdk_string_40, deskdk_string_41, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 12,26 }, /* FISIZE */
	{ deskdk_string_42, deskdk_string_43, deskdk_string_44, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,29 }, /* FIDATE */
	{ deskdk_string_45, deskdk_string_46, deskdk_string_47, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,27 }, /* FITIME */
	{ deskdk_string_54, deskdk_string_55, deskdk_string_56, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 2,22 }, /* DIDRIVE */
	{ deskdk_string_57, deskdk_string_58, deskdk_string_59, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,26 }, /* DIVOLUME */
	{ deskdk_string_60, deskdk_string_61, deskdk_string_62, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,29 }, /* DINFOLDS */
	{ deskdk_string_63, deskdk_string_64, deskdk_string_65, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,27 }, /* DINFILES */
	{ deskdk_string_66, deskdk_string_67, deskdk_string_68, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 9,22 }, /* DIUSED */
	{ deskdk_string_69, deskdk_string_70, deskdk_string_71, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 9,27 }, /* DIAVAIL */
	{ deskdk_string_74, deskdk_string_75, deskdk_string_76, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,26 }, /* FOLNAME */
	{ deskdk_string_77, deskdk_string_78, deskdk_string_79, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 7,20 }, /* FOLDATE */
	{ deskdk_string_80, deskdk_string_81, deskdk_string_82, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 7,9 }, /* FOLTIME */
	{ deskdk_string_83, deskdk_string_84, deskdk_string_85, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,29 }, /* FOLNFOLD */
	{ deskdk_string_86, deskdk_string_87, deskdk_string_88, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,27 }, /* FOLNFILE */
	{ deskdk_string_89, deskdk_string_90, deskdk_string_91, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 9,22 }, /* FOLSIZE */
	{ deskdk_string_111, deskdk_string_112, deskdk_string_113, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,20 }, /* APPLNAME */
	{ deskdk_string_114, deskdk_string_115, deskdk_string_116, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 39,39 }, /* APPLPARM */
	{ deskdk_string_121, deskdk_string_122, deskdk_string_123, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 2,19 }, /* DRID */
	{ deskdk_string_124, deskdk_string_125, deskdk_string_126, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 13,25 }, /* DRLABEL */
	{ deskdk_string_134, deskdk_string_135, deskdk_string_136, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,32 }, /* APNAME */
	{ deskdk_string_137, deskdk_string_138, deskdk_string_139, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,32 }, /* APDFTYPE */
	{ deskdk_string_148, deskdk_string_149, deskdk_string_150, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,23 }, /* NUMDIR */
	{ deskdk_string_151, deskdk_string_152, deskdk_string_153, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,21 }, /* NUMFILE */
	{ deskdk_string_157, deskdk_string_158, deskdk_string_159, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,25 }, /* DELDIR */
	{ deskdk_string_160, deskdk_string_161, deskdk_string_162, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,23 }, /* DELFILES */
	{ deskdk_string_166, deskdk_string_167, deskdk_string_168, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 0,0 }, /* FNAME */
	{ deskdk_string_169, deskdk_string_170, deskdk_string_171, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 0,0 }, /* EDFNAME */
	{ deskdk_string_175, deskdk_string_176, deskdk_string_177, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 0,0 } /* MKNAME */
};


static OBJECT rs_object[NUM_OBS] = {
/* ADMENU */

	{ -1, 1, 7, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 0,0, 80,25 },
	{ 7, 2, 2, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0x1100L), 0,0, 80,513 },
	{ 1, 3, 6, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 2,0, 28,769 },
	{ 4, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_0), 0,0, 6,769 }, /* DESKMENU */
	{ 5, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_1), 6,0, 7,769 }, /* FILEMENU */
	{ 6, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_2), 13,0, 7,769 }, /* VIEWMENU */
	{ 2, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_3), 20,0, 8,769 }, /* OPTNMENU */
	{ 0, 8, 36, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 0,769, 80,24 },
	{ 17, 9, 16, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 2,0, 21,8 },
	{ 10, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_4), 0,0, 21,1 }, /* ABOUITEM */
	{ 11, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskdk_string_5), 0,1, 21,1 }, /* L1ITEM */
	{ 12, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_6), 0,2, 21,1 },
	{ 13, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_7), 0,3, 21,1 },
	{ 14, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_8), 0,4, 21,1 },
	{ 15, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_9), 0,5, 21,1 },
	{ 16, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_10), 0,6, 21,1 },
	{ 8, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_11), 0,7, 21,1 },
	{ 28, 18, 27, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 8,0, 15,10 },
	{ 19, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_12), 0,0, 15,1 }, /* OPENITEM */
	{ 20, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_13), 0,1, 15,1 }, /* SHOWITEM */
	{ 21, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskdk_string_14), 0,2, 15,1 }, /* L2ITEM */
	{ 22, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_15), 0,3, 15,1 }, /* NEWFITEM */
	{ 23, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_16), 0,4, 15,1 }, /* CLSFITEM */
	{ 24, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_17), 0,5, 15,1 }, /* CLSWITEM */
	{ 25, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskdk_string_18), 0,6, 15,1 }, /* L3ITEM */
	{ 26, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_19), 0,7, 15,1 }, /* FORMITEM */
	{ 27, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_20), 0,8, 15,1 }, /* OUTPITEM */
	{ 17, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_21), 0,9, 15,1 }, /* QUITITEM */
	{ 36, 29, 35, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 15,0, 14,7 },
	{ 30, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_22), 0,0, 14,1 }, /* ICONITEM */
	{ 31, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_23), 0,1, 14,1 }, /* TEXTITEM */
	{ 32, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskdk_string_24), 0,2, 14,1 }, /* L4ITEM */
	{ 33, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_25), 0,3, 14,1 }, /* NAMEITEM */
	{ 34, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_26), 0,4, 14,1 }, /* DATEITEM */
	{ 35, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_27), 0,5, 14,1 }, /* SIZEITEM */
	{ 28, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_28), 0,6, 14,1 }, /* TYPEITEM */
	{ 7, 37, 42, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 16,0, 19,6 },
	{ 38, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_29), 0,0, 19,1 }, /* IDSKITEM */
	{ 39, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_30), 0,1, 19,1 }, /* IAPPITEM */
	{ 40, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskdk_string_31), 0,2, 19,1 }, /* L5ITEM */
	{ 41, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_32), 0,3, 19,1 }, /* PREFITEM */
	{ 42, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_33), 0,4, 19,1 }, /* SAVEITEM */
	{ 36, -1, -1, G_STRING, OF_LASTOB, OS_NORMAL, C_UNION(deskdk_string_34), 0,5, 19,1 }, /* PRINTITEM */

/* ADFILEIN */

	{ -1, 1, 11, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,13 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_35), 1,1, 16,1 }, /* INFTITLE */
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[0]), 12,3, 19,1 }, /* FINAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[1]), 2,4, 25,1 }, /* FISIZE */
	{ 5, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[2]), 1,5, 26,1 }, /* FIDATE */
	{ 6, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[3]), 28,5, 8,1 }, /* FITIME */
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_48), 9,7, 11,1 },
	{ 10, 8, 9, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 19,7, 23,3 },
	{ 9, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_49), 0,0, 16,1 }, /* FIRWRITE */
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_50), 0,2, 10,1 }, /* FIRONLY */
	{ 11, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_51), 9,11, 8,1 }, /* FIOK */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskdk_string_52), 25,11, 8,1 }, /* FICNCL */

/* ADDISKIN */

	{ -1, 1, 8, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,12 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_53), 1,1, 16,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[4]), 8,3, 25,1 }, /* DIDRIVE */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[5]), 13,4, 23,1 }, /* DIVOLUME */
	{ 5, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[6]), 4,5, 28,1 }, /* DINFOLDS */
	{ 6, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[7]), 4,6, 28,1 }, /* DINFILES */
	{ 7, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[8]), 4,7, 28,1 }, /* DIUSED */
	{ 8, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[9]), 6,8, 26,1 }, /* DIAVAIL */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskdk_string_72), 26,10, 8,1 }, /* DIOK */

/* ADFOLDIN */

	{ -1, 1, 8, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,11 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_73), 1,1, 18,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[10]), 8,3, 26,1 }, /* FOLNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[11]), 15,4, 22,1 }, /* FOLDATE */
	{ 5, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[12]), 29,4, 8,1 }, /* FOLTIME */
	{ 6, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[13]), 1,5, 28,1 }, /* FOLNFOLD */
	{ 7, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[14]), 3,6, 26,1 }, /* FOLNFILE */
	{ 8, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[15]), 1,7, 28,1 }, /* FOLSIZE */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskdk_string_92), 26,9, 8,1 }, /* FOLOK */

/* ADDINFO */

	{ -1, 1, 11, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,16 },
	{ 2, -1, -1, G_IMAGE, OF_NONE, OS_NORMAL, C_UNION(&rs_bitblk[0]), 1040,5, 8192,16384 },
	{ 3, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_93), 3,1, 32,1 },
	{ 4, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_94), 11,4, 7,1 },
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_95), 9,3, 16,1 },
	{ 6, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_96), 15,5, 16,1 },
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_97), 9,6, 29,1 },
	{ 8, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_98), 11,12, 22,1 },
	{ 9, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_99), 11,9, 10,1 },
	{ 10, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_100), 10,11, 0,1 },
	{ 11, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_101), 15,10, 42,1 },
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskdk_string_102), 15,14, 8,1 }, /* DEOK */

/* ADPINFO */

	{ -1, 1, 7, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,11 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_103), 3,1, 23,1 },
	{ 3, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_104), 3,3, 23,1 },
	{ 4, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_105), 3,4, 23,1 },
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_106), 3,5, 23,1 },
	{ 6, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_107), 3,6, 23,1 },
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_108), 3,7, 23,1 },
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskdk_string_109), 26,9, 8,1 }, /* APDOK */

/* ADOPENAP */

	{ -1, 1, 6, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 40,9 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_110), 3,1, 16,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[16]), 6,3, 19,1 }, /* APPLNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[17]), 1,5, 38,1 }, /* APPLPARM */
	{ 5, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_117), 9,7, 8,1 }, /* APPLOK */
	{ 6, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskdk_string_118), 25,7, 8,1 }, /* APPLCNCL */
	{ 0, -1, -1, G_STRING, OF_LASTOB, OS_NORMAL, C_UNION(deskdk_string_119), 1,4, 12,1 },

/* ADINSDIS */

	{ -1, 1, 10, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_120), 3,1, 18,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[18]), 4,3, 25,1 }, /* DRID */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[19]), 8,4, 29,1 }, /* DRLABEL */
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_127), 8,6, 10,1 },
	{ 6, -1, -1, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 18,6, 24,1 },
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_128), 1,0, 8,1 },
	{ 8, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_129), 10,0, 8,1 },
	{ 9, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskdk_string_130), 6,6, 8,1 }, /* DROK */
	{ 10, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskdk_string_131), 16,6, 8,1 }, /* DRREMOVE */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskdk_string_132), 26,6, 8,1 }, /* DRCANCEL */

/* ADINSAPP */

	{ -1, 1, 11, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,13 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_133), 3,1, 19,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[20]), 13,3, 21,1 }, /* APNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[21]), 9,4, 19,1 }, /* APDFTYPE */
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_140), 4,5, 17,1 },
	{ 9, 6, 8, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 1,7, 40,4 },
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_141), 0,0, 5,1 }, /* APGEM */
	{ 8, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_142), 6,0, 5,1 }, /* APDOS */
	{ 5, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_143), 13,0, 23,1 }, /* APPARMS */
	{ 10, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskdk_string_144), 18,11, 8,1 }, /* APOK */
	{ 11, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_145), 28,11, 8,1 }, /* APCANCEL */
	{ 0, -1, -1, G_BUTTON, 0x31, OS_NORMAL, C_UNION(deskdk_string_146), 13,2, 22,1 },

/* CPBOX */

	{ -1, 1, 5, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 34,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_147), 3,1, 20,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[22]), 2,3, 30,1 }, /* NUMDIR */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[23]), 3,4, 29,1 }, /* NUMFILE */
	{ 5, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_154), 13,6, 8,1 }, /* OKCP */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskdk_string_155), 23,6, 8,1 }, /* CCANCEL */

/* DELBOX */

	{ -1, 1, 5, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 30,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_156), 3,1, 23,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[24]), 1,3, 28,1 }, /* DELDIR */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[25]), 2,4, 27,1 }, /* DELFILES */
	{ 5, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskdk_string_163), 9,6, 8,1 }, /* DELOK */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskdk_string_164), 19,6, 8,1 }, /* DELCNCL */

/* SAMENAME */

	{ -1, 1, 5, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 34,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_165), 3,1, 28,1 }, /* SNAME */
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[26]), 2,3, 31,1 }, /* FNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[27]), 4,4, 29,1 }, /* EDFNAME */
	{ 5, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_172), 13,6, 8,1 }, /* COPY */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskdk_string_173), 23,6, 8,1 }, /* QUIT */

/* ADMKDBOX */

	{ -1, 1, 4, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 27,7 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_174), 3,1, 10,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[28]), 3,3, 19,1 }, /* MKNAME */
	{ 4, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_178), 6,5, 8,1 }, /* MKOK */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskdk_string_179), 16,5, 8,1 }, /* MKCNCL */

/* ADSETPREF */

	{ -1, 1, 20, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,13 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_180), 3,1, 16,1 },
	{ 3, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_181), 4,3, 16,1 },
	{ 6, 4, 5, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 22,3, 12,1 },
	{ 5, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_182), 0,0, 5,1 }, /* SPCDYES */
	{ 3, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_183), 7,0, 5,1 }, /* SPCDNO */
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_184), 3,5, 15,1 },
	{ 17, 8, 16, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 22,5, 12,1 },
	{ 9, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_185), 0,0, 5,1 }, /* SPCCYES */
	{ 10, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_186), 7,0, 5,1 }, /* SPCCNO */
	{ 11, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_187), 2,7, 19,1 },
	{ 12, -1, -1, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 3,9, 31,2 },
	{ 13, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_188), 0,0, 7,1 },
	{ 14, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_189), 9,0, 3,1 },
	{ 15, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_190), 14,0, 3,1 },
	{ 16, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_191), 19,0, 3,1 },
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_192), 24,0, 7,1 },
	{ 18, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskdk_string_193), 5,11, 8,1 }, /* SPOK */
	{ 19, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskdk_string_194), 27,11, 8,1 }, /* SPCANCEL */
	{ 20, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskdk_string_195), 1,7, 31,2 },
	{ 0, 21, 23, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 3,9, 31,2 },
	{ 22, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_196), 4,0, 8,1 }, /* SPLOW */
	{ 23, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskdk_string_197), 15,0, 7,1 }, /* SPMEDIUM */
	{ 20, -1, -1, G_BUTTON, 0x31, OS_NORMAL, C_UNION(deskdk_string_198), 25,0, 5,1 } /* SPHIGH */
};


static OBJECT *rs_trindex[NUM_TREE] = {
	&rs_object[0], /* ADMENU */
	&rs_object[43], /* ADFILEIN */
	&rs_object[55], /* ADDISKIN */
	&rs_object[64], /* ADFOLDIN */
	&rs_object[73], /* ADDINFO */
	&rs_object[85], /* ADPINFO */
	&rs_object[93], /* ADOPENAP */
	&rs_object[100], /* ADINSDIS */
	&rs_object[111], /* ADINSAPP */
	&rs_object[123], /* CPBOX */
	&rs_object[129], /* DELBOX */
	&rs_object[135], /* SAMENAME */
	&rs_object[141], /* ADMKDBOX */
	&rs_object[146] /* ADSETPREF */
};





#if RSC_STATIC_FILE

#if RSC_NAMED_FUNCTIONS
#ifdef __STDC__
_WORD deskdk_rsc_load(_WORD wchar, _WORD hchar)
#else
_WORD deskdk_rsc_load(wchar, hchar)
_WORD wchar;
_WORD wchar;
#endif
{
#ifndef RSC_HAS_PALETTE
#  define RSC_HAS_PALETTE 0
#endif
#ifndef RSC_USE_PALETTE
#  define RSC_USE_PALETTE 0
#endif
#if RSC_HAS_PALETTE || RSC_USE_PALETTE
	W_Cicon_Setpalette(&rgb_palette[0][0]);
#endif
#if NUM_OBS != 0
	{
		OBJECT *tree;
		for (tree = rs_object; tree < &rs_object[NUM_OBS]; tree++)
		{
			tree->ob_x = wchar * (tree->ob_x & 0xff) + (tree->ob_x >> 8);
			tree->ob_y = hchar * (tree->ob_y & 0xff) + (tree->ob_y >> 8);
			tree->ob_width = wchar * (tree->ob_width & 0xff) + (tree->ob_width >> 8);
			tree->ob_height = hchar * (tree->ob_height & 0xff) + (tree->ob_height >> 8);
		}
		hfix_objs(NULL, rs_object, NUM_OBS);
	}
#endif
	return 1;
}


#ifdef __STDC__
_WORD deskdk_rsc_gaddr(_WORD type, _WORD idx, void *gaddr)
#else
_WORD deskdk_rsc_gaddr(type, idx, gaddr)
_WORD type;
_WORD idx;
void *gaddr;
#endif
{
	switch (type)
	{
#if NUM_TREE != 0
	case R_TREE:
		if (idx < 0 || idx >= NUM_TREE)
			return 0;
		*((OBJECT **)gaddr) = rs_trindex[idx];
		break;
#endif
#if NUM_OBS != 0
	case R_OBJECT:
		if (idx < 0 || idx >= NUM_OBS)
			return 0;
		*((OBJECT **)gaddr) = &rs_object[idx];
		break;
#endif
#if NUM_TI != 0
	case R_TEDINFO:
		if (idx < 0 || idx >= NUM_TI)
			return 0;
		*((TEDINFO **)gaddr) = &rs_tedinfo[idx];
		break;
#endif
#if NUM_IB != 0
	case R_ICONBLK:
		if (idx < 0 || idx >= NUM_IB)
			return 0;
		*((ICONBLK **)gaddr) = &rs_iconblk[idx];
		break;
#endif
#if NUM_BB != 0
	case R_BITBLK:
		if (idx < 0 || idx >= NUM_BB)
			return 0;
		*((BITBLK **)gaddr) = &rs_bitblk[idx];
		break;
#endif
#if NUM_FRSTR != 0
	case R_STRING:
		if (idx < 0 || idx >= NUM_FRSTR)
			return 0;
		*((char **)gaddr) = (char *)(rs_frstr[idx]);
		break;
#endif
#if NUM_FRIMG != 0
	case R_IMAGEDATA:
		if (idx < 0 || idx >= NUM_FRIMG)
			return 0;
		*((BITBLK **)gaddr) = rs_frimg[idx];
		break;
#endif
#if NUM_OBS != 0
	case R_OBSPEC:
		if (idx < 0 || idx >= NUM_OBS)
			return 0;
		*((_LONG_PTR **)gaddr) = &rs_object[idx].ob_spec.index;
		break;
#endif
#if NUM_TI != 0
	case R_TEPTEXT:
		if (idx < 0 || idx >= NUM_TI)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_tedinfo[idx].te_ptext);
		break;
#endif
#if NUM_TI != 0
	case R_TEPTMPLT:
		if (idx < 0 || idx >= NUM_TI)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_tedinfo[idx].te_ptmplt);
		break;
#endif
#if NUM_TI != 0
	case R_TEPVALID:
		if (idx < 0 || idx >= NUM_TI)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_tedinfo[idx].te_pvalid);
		break;
#endif
#if NUM_IB != 0
	case R_IBPMASK:
		if (idx < 0 || idx >= NUM_IB)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_iconblk[idx].ib_pmask);
		break;
#endif
#if NUM_IB != 0
	case R_IBPDATA:
		if (idx < 0 || idx >= NUM_IB)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_iconblk[idx].ib_pdata);
		break;
#endif
#if NUM_IB != 0
	case R_IBPTEXT:
		if (idx < 0 || idx >= NUM_IB)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_iconblk[idx].ib_ptext);
		break;
#endif
#if NUM_BB != 0
	case R_BIPDATA:
		if (idx < 0 || idx >= NUM_BB)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_bitblk[idx].bi_pdata);
		break;
#endif
#if NUM_FRSTR != 0
	case R_FRSTR:
		if (idx < 0 || idx >= NUM_FRSTR)
			return 0;
		*((char ***)gaddr) = (char **)(&rs_frstr[idx]);
		break;
#endif
#if NUM_FRIMG != 0
	case R_FRIMG:
		if (idx < 0 || idx >= NUM_FRIMG)
			return 0;
		*((BITBLK ***)gaddr) = &rs_frimg[idx];
		break;
#endif
	default:
		return 0;
	}
	return 1;
}


#ifdef __STDC__
_WORD deskdk_rsc_free(void)
#else
_WORD deskdk_rsc_free()
#endif
{
#if NUM_OBS != 0
	hrelease_objs(rs_object, NUM_OBS);
#endif
	return 1;
}

#endif /* RSC_NAMED_FUNCTIONS */

#else /* !RSC_STATIC_FILE */
#if 0
_WORD rs_numstrings = 228;
_WORD rs_numfrstr = 29;

_WORD rs_nuser = 0;
_WORD rs_numimages = 1;
_WORD rs_numbb = 1;
_WORD rs_numfrimg = 0;
_WORD rs_numib = 0;
_WORD rs_numcib = 0;
_WORD rs_numti = 29;
_WORD rs_numobs = 170;
_WORD rs_numtree = 14;

char rs_name[] = "deskdk.rsc";

_WORD _rsc_format = 2; /* RSC_FORM_SOURCE2 */
#endif
#endif /* RSC_STATIC_FILE */
