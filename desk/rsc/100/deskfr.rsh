/*
 * GEM resource C output of deskfr
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

#include "deskfr.h"

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


static char deskfr_string_0[] = " Bureau ";
static char deskfr_string_1[] = " Fichier ";
static char deskfr_string_2[] = " Visualisation ";
static char deskfr_string_3[] = " Options";
static char deskfr_string_4[] = "  Informations bureau...";
static char deskfr_string_5[] = "------------------------";
static char deskfr_string_6[] = "1";
static char deskfr_string_7[] = "2";
static char deskfr_string_8[] = "3";
static char deskfr_string_9[] = "4";
static char deskfr_string_10[] = "5";
static char deskfr_string_11[] = "6";
static char deskfr_string_12[] = "  Ouvrir";
static char deskfr_string_13[] = "  Informations...";
static char deskfr_string_14[] = "----------------------";
static char deskfr_string_15[] = "  Nouveau dossier...";
static char deskfr_string_16[] = "  Fermer";
static char deskfr_string_17[] = "  Fermer la fen\210tre";
static char deskfr_string_18[] = "----------------------";
static char deskfr_string_19[] = "  Formatage...";
static char deskfr_string_20[] = "";
static char deskfr_string_21[] = "";
static char deskfr_string_22[] = "  Visualisation ic\223nes";
static char deskfr_string_23[] = "  Visualisation textes";
static char deskfr_string_24[] = "------------------------";
static char deskfr_string_25[] = "  Tri par nom";
static char deskfr_string_26[] = "  Tri par date";
static char deskfr_string_27[] = "  Tri par taille";
static char deskfr_string_28[] = "  Tri par type";
static char deskfr_string_29[] = "  Installer une unit\202 disque...";
static char deskfr_string_30[] = "  Installer une application...";
static char deskfr_string_31[] = "-------------------------------";
static char deskfr_string_32[] = "  D\202finir des pr\202f\202rences...";
static char deskfr_string_33[] = "  Sauvegarder le bureau";
static char deskfr_string_34[] = "  Impression de l\'\202cran";
static char deskfr_string_35[] = "INFORMATIONS OBJET";
static char deskfr_string_36[] = "@";
static char deskfr_string_37[] = "Nom:  ________.___";
static char deskfr_string_38[] = "F";
static char deskfr_string_39[] = "@2345678\0No";
static char deskfr_string_40[] = "Nombre d\'octets:  ________";
static char deskfr_string_41[] = "9";
static char deskfr_string_42[] = "@5432";
static char deskfr_string_43[] = "Derni\212re modification:  __/__/__";
static char deskfr_string_44[] = "9";
static char deskfr_string_45[] = "@1234";
static char deskfr_string_46[] = "__:__ __";
static char deskfr_string_47[] = "9999aa";
static char deskfr_string_48[] = "Attributs:";
static char deskfr_string_49[] = "Lecture/Ecriture";
static char deskfr_string_50[] = "Lecture";
static char deskfr_string_51[] = "CONFIRMER";
static char deskfr_string_52[] = "ANNULER";
static char deskfr_string_53[] = "INFORMATIONS DISQUE";
static char deskfr_string_54[] = "@";
static char deskfr_string_55[] = "Nom de l\'unit\202:  _:";
static char deskfr_string_56[] = "A";
static char deskfr_string_57[] = "@2345678901";
static char deskfr_string_58[] = "Nom du disque: ________.___";
static char deskfr_string_59[] = "F";
static char deskfr_string_60[] = "@1234";
static char deskfr_string_61[] = "Nombre de dossiers:     _____";
static char deskfr_string_62[] = "9";
static char deskfr_string_63[] = "@2345";
static char deskfr_string_64[] = "Nombre d\'objets:     _____";
static char deskfr_string_65[] = "9";
static char deskfr_string_66[] = "@7654321";
static char deskfr_string_67[] = "Octets utilis\202s:  ________";
static char deskfr_string_68[] = "9";
static char deskfr_string_69[] = "@1010101";
static char deskfr_string_70[] = "Octets disponibles:  ________";
static char deskfr_string_71[] = "9";
static char deskfr_string_72[] = "CONFIRMER";
static char deskfr_string_73[] = "INFORMATIONS DOSSIER";
static char deskfr_string_74[] = "@2345678999";
static char deskfr_string_75[] = "Nom du dossier: ________.___";
static char deskfr_string_76[] = "F";
static char deskfr_string_77[] = "@ddddd";
static char deskfr_string_78[] = "Cr\202\202 le: __-__-__  ";
static char deskfr_string_79[] = "9";
static char deskfr_string_80[] = "@hhhhh";
static char deskfr_string_81[] = "__:__ __";
static char deskfr_string_82[] = "9999aa";
static char deskfr_string_83[] = "@1234";
static char deskfr_string_84[] = "Nombre de dossiers:     _____";
static char deskfr_string_85[] = "9";
static char deskfr_string_86[] = "@2345";
static char deskfr_string_87[] = "Nombre d\'objets:     _____";
static char deskfr_string_88[] = "9";
static char deskfr_string_89[] = "@7654321";
static char deskfr_string_90[] = "Octets utilis\202s:  ________";
static char deskfr_string_91[] = "9";
static char deskfr_string_92[] = "CONFIRMER";
static char deskfr_string_93[] = "GEM, Graphics Environment Manager";
static char deskfr_string_94[] = "---------------";
static char deskfr_string_95[] = "        TOS";
static char deskfr_string_96[] = "";
static char deskfr_string_97[] = "";
static char deskfr_string_98[] = "All Rights Reserved.";
static char deskfr_string_99[] = "Copyright (c) 1985";
static char deskfr_string_100[] = "Digital Research, Inc.";
static char deskfr_string_101[] = "ATARI CORP.";
static char deskfr_string_102[] = "CONFIRMER";
static char deskfr_string_103[] = "";
static char deskfr_string_104[] = "La corbeille est l\'emplacement";
static char deskfr_string_105[] = "vers lequel vous d\202placez les";
static char deskfr_string_106[] = "objets \205 supprimer de fa\207on";
static char deskfr_string_107[] = "DEFINITIVE.";
static char deskfr_string_108[] = "";
static char deskfr_string_109[] = "CONFIRMER";
static char deskfr_string_110[] = "OUVRIR UNE APPLICATION";
static char deskfr_string_111[] = "@2345678901";
static char deskfr_string_112[] = "Nom:  ________.___";
static char deskfr_string_113[] = "F";
static char deskfr_string_114[] = "@1234567890123456789012345678901234567";
static char deskfr_string_115[] = "______________________________________";
static char deskfr_string_116[] = "X";
static char deskfr_string_117[] = "CONFIRMER";
static char deskfr_string_118[] = "ANNULER";
static char deskfr_string_119[] = "Param\212tres:";
static char deskfr_string_120[] = "INSTALLER UNE UNIT\220 DISQUE";
static char deskfr_string_121[] = "@";
static char deskfr_string_122[] = "Nom de l\'unit\202: _";
static char deskfr_string_123[] = "a";
static char deskfr_string_124[] = "@23456789012";
static char deskfr_string_125[] = "Nom de l\'ic\223ne: ____________";
static char deskfr_string_126[] = "X";
static char deskfr_string_127[] = "";
static char deskfr_string_128[] = "";
static char deskfr_string_129[] = "";
static char deskfr_string_130[] = "Installer";
static char deskfr_string_131[] = "Supprimer";
static char deskfr_string_132[] = "ANNULER";
static char deskfr_string_133[] = "INSTALLER UNE APPLICATION";
static char deskfr_string_134[] = "@2345679012";
static char deskfr_string_135[] = "Nom de l\'application:  ________.___";
static char deskfr_string_136[] = "F";
static char deskfr_string_137[] = "@12\0Type de";
static char deskfr_string_138[] = "Type de document:  ___";
static char deskfr_string_139[] = "F";
static char deskfr_string_140[] = "Type de l\'application:";
static char deskfr_string_141[] = "GEM";
static char deskfr_string_142[] = "TOS";
static char deskfr_string_143[] = "TOS avec param\212tres";
static char deskfr_string_144[] = "CONFIRMER";
static char deskfr_string_145[] = "ANNULER";
static char deskfr_string_146[] = "";
static char deskfr_string_147[] = "COPIER DES DOSSIERS/OBJETS";
static char deskfr_string_148[] = "@234";
static char deskfr_string_149[] = "Dossiers \205 copier:  ____";
static char deskfr_string_150[] = "9";
static char deskfr_string_151[] = "@432";
static char deskfr_string_152[] = "Objets \205 copier:  ____";
static char deskfr_string_153[] = "9";
static char deskfr_string_154[] = "CONFIRMER";
static char deskfr_string_155[] = "ANNULER";
static char deskfr_string_156[] = "SUPPRIMER DES DOSSIERS/OBJETS";
static char deskfr_string_157[] = "@980";
static char deskfr_string_158[] = "Dossiers \205 supprimer:  ____";
static char deskfr_string_159[] = "9";
static char deskfr_string_160[] = "@678";
static char deskfr_string_161[] = "Objets \205 supprimer:  ____";
static char deskfr_string_162[] = "9";
static char deskfr_string_163[] = "CONFIRMER";
static char deskfr_string_164[] = "ANNULER";
static char deskfr_string_165[] = "CONFLIT DE NOM LORS DE LA COPIE";
static char deskfr_string_166[] = "";
static char deskfr_string_167[] = "Nom actuel:  ________.___";
static char deskfr_string_168[] = "F";
static char deskfr_string_169[] = "";
static char deskfr_string_170[] = "Nom de la copie:  ________.___";
static char deskfr_string_171[] = "F";
static char deskfr_string_172[] = "CONFIRMER";
static char deskfr_string_173[] = "ANNULER";
static char deskfr_string_174[] = "NOUVEAU DOSSIER";
static char deskfr_string_175[] = "";
static char deskfr_string_176[] = "Nom:  ________.___";
static char deskfr_string_177[] = "F";
static char deskfr_string_178[] = "CONFIRMER";
static char deskfr_string_179[] = "ANNULER";
static char deskfr_string_180[] = "DEFINIR DES PREFERENCES";
static char deskfr_string_181[] = "Confirmer les suppressions:";
static char deskfr_string_182[] = "OUI";
static char deskfr_string_183[] = "NON";
static char deskfr_string_184[] = "Confirmer les copies:";
static char deskfr_string_185[] = "OUI";
static char deskfr_string_186[] = "NON";
static char deskfr_string_187[] = "";
static char deskfr_string_188[] = "";
static char deskfr_string_189[] = "";
static char deskfr_string_190[] = "";
static char deskfr_string_191[] = "";
static char deskfr_string_192[] = "";
static char deskfr_string_193[] = "CONFIRMER";
static char deskfr_string_194[] = "ANNULER";
static char deskfr_string_195[] = "R\202solution \202cran:";
static char deskfr_string_196[] = "BASSE";
static char deskfr_string_197[] = "MOYENNE";
static char deskfr_string_198[] = "HAUTE";
static char deskfr_string_199[] = " %L octets utilis\202s par %W objets.";
static char deskfr_string_200[] = " ";
static char deskfr_string_201[] = "IMPRIMER";
static char deskfr_string_202[] = "FORMATAGE";
static char deskfr_string_203[] = "COPIE DE DISQUETTE";
static char deskfr_string_204[] = " ";
static char deskfr_string_205[] = "[1][|Seule la visualisation ou|l\'impression de ce document|est possible.][VOIR|IMPRIMER|ANNULER]";
static char deskfr_string_206[] = "[1][Il n\'y a plus de fen\210tres|disponibles sur le Bureau|GEM. Fermez une fen\210tre|inutilis\202e.][CONFIRMER]";
static char deskfr_string_207[] = "[1][|Vous ne pouvez pas ouvrir|l\'ic\223ne de la corbeille.][CONFIRMER]";
static char deskfr_string_208[] = "[3][Le formatage EFFACE toutes|les donn\202es du disque %S:.|Choisissez CONFIRMER pour|Formater.][CONFIRMER|ANNULER]";
static char deskfr_string_209[] = "[1][|Vous pouvez copier seulement|vers un disque, un dossier ou|une fen\210tre.][CONFIRMER]";
static char deskfr_string_210[] = "[1][|Vous ne pouvez pas superposer|cette ic\223ne sur une autre|ic\223ne.][CONFIRMER]";
static char deskfr_string_211[] = "[1][Vous ne pouvez d\202placer un|disque vers la corbeille.|Pour l\'effacer s\202lectionnez|Formatage dans le menu|Fichier.][CONFIRMER]";
static char deskfr_string_212[] = "[3][Copier le disque %S: sur le|disque %S: EFFACE toutes les|donn\202es du disque %S:.|Choisissez CONFIRMER pour|copier.][CONFIRMER|ANNULER]";
static char deskfr_string_213[] = "[1][|Vous ne pouvez pas placer|les objets d\'une fen\210tre sur|le Bureau.][CONFIRMER]";
static char deskfr_string_214[] = "[1][|Vous ne pouvez pas placer|les ic\223nes du Bureau sur une|fen\210tre.][CONFIRMER]";
static char deskfr_string_215[] = "[2][|Il existe d\202j\205 un objet|portant ce nom. Utilisez un|autre nom ou annulez.][ANNULER|RECOMMENCER]";
static char deskfr_string_216[] = "[1][|Ce disque n\'a pas assez de|place pour cette op\202ration.][CONFIRMER]";
static char deskfr_string_217[] = "[2][|Il existe d\202j\205 un fichier|portant ce nom.][ CONFIRMER ]";
static char deskfr_string_218[] = "[3][|Impossible de cr\202er un|nouveau dossier \205 ce niveau|d\'acc\212s du r\202pertoire.][ ANNULER ]";
static char deskfr_string_219[] = "[1][|Vous ne pouvez pas|d\202placer des objets depuis|ou vers la cartouche.][CONFIRMER]";
static char deskfr_string_220[] = " ";
static char deskfr_string_221[] = "[1][|Copie invalide.][ CONFIRMER ]";
static char deskfr_string_222[] = " Bureau ";
static char deskfr_string_223[] = " Bureau ";
static char deskfr_string_224[] = " Bureau ";
static char deskfr_string_225[] = " Bureau ";
static char deskfr_string_226[] = " Bureau ";
static char deskfr_string_227[] = " Bureau ";


static _UBYTE deskfr_IMAGE0[] = {
0x00, 0x00, 0x00, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00,
0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x1B, 0xB0, 0x00, 0x00, 0x3B, 0xB8, 0x00,
0x00, 0x3B, 0xB8, 0x00, 0x00, 0x3B, 0xB8, 0x00, 0x00, 0x3B, 0xB8, 0x00, 0x00, 0x7B, 0xBC, 0x00,
0x00, 0x7B, 0xBC, 0x00, 0x00, 0xFB, 0xBE, 0x00, 0x01, 0xF3, 0x9F, 0x00, 0x03, 0xF3, 0x9F, 0x80,
0x0F, 0xE3, 0x8F, 0xE0, 0x7F, 0xC3, 0x87, 0xFC, 0x7F, 0x83, 0x83, 0xFC, 0x7E, 0x03, 0x80, 0xFC,
0x78, 0x03, 0x80, 0x3C, 0x00, 0x00, 0x00, 0x00, 0x09, 0xF9, 0x0F, 0x8C, 0x1D, 0xFB, 0x8F, 0xCC,
0x1C, 0x63, 0x8C, 0xEC, 0x36, 0x66, 0xCC, 0xEC, 0x36, 0x66, 0xCD, 0xCC, 0x7F, 0x6F, 0xED, 0x8C,
0x7F, 0x6F, 0xED, 0xCC, 0x63, 0x6C, 0x6C, 0xEC, 0x63, 0x6C, 0x6C, 0x6C, 0x00, 0x00, 0x00, 0x00};


static char *rs_frstr[NUM_FRSTR] = {
	deskfr_string_199,
	deskfr_string_200,
	deskfr_string_201,
	deskfr_string_202,
	deskfr_string_203,
	deskfr_string_204,
	deskfr_string_205,
	deskfr_string_206,
	deskfr_string_207,
	deskfr_string_208,
	deskfr_string_209,
	deskfr_string_210,
	deskfr_string_211,
	deskfr_string_212,
	deskfr_string_213,
	deskfr_string_214,
	deskfr_string_215,
	deskfr_string_216,
	deskfr_string_217,
	deskfr_string_218,
	deskfr_string_219,
	deskfr_string_220,
	deskfr_string_221,
	deskfr_string_222,
	deskfr_string_223,
	deskfr_string_224,
	deskfr_string_225,
	deskfr_string_226,
	deskfr_string_227
};


static BITBLK rs_bitblk[NUM_BB] = {
	{ CP deskfr_IMAGE0, 4, 32, 0, 0, 1 }
};


static TEDINFO rs_tedinfo[NUM_TI] = {
	{ deskfr_string_36, deskfr_string_37, deskfr_string_38, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 2,22 }, /* FINAME */
	{ deskfr_string_39, deskfr_string_40, deskfr_string_41, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 12,26 }, /* FISIZE */
	{ deskfr_string_42, deskfr_string_43, deskfr_string_44, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,29 }, /* FIDATE */
	{ deskfr_string_45, deskfr_string_46, deskfr_string_47, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,27 }, /* FITIME */
	{ deskfr_string_54, deskfr_string_55, deskfr_string_56, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 2,22 }, /* DIDRIVE */
	{ deskfr_string_57, deskfr_string_58, deskfr_string_59, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,26 }, /* DIVOLUME */
	{ deskfr_string_60, deskfr_string_61, deskfr_string_62, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,29 }, /* DINFOLDS */
	{ deskfr_string_63, deskfr_string_64, deskfr_string_65, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,27 }, /* DINFILES */
	{ deskfr_string_66, deskfr_string_67, deskfr_string_68, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 9,22 }, /* DIUSED */
	{ deskfr_string_69, deskfr_string_70, deskfr_string_71, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 9,27 }, /* DIAVAIL */
	{ deskfr_string_74, deskfr_string_75, deskfr_string_76, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,26 }, /* FOLNAME */
	{ deskfr_string_77, deskfr_string_78, deskfr_string_79, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 7,20 }, /* FOLDATE */
	{ deskfr_string_80, deskfr_string_81, deskfr_string_82, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 7,9 }, /* FOLTIME */
	{ deskfr_string_83, deskfr_string_84, deskfr_string_85, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,29 }, /* FOLNFOLD */
	{ deskfr_string_86, deskfr_string_87, deskfr_string_88, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 6,27 }, /* FOLNFILE */
	{ deskfr_string_89, deskfr_string_90, deskfr_string_91, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 9,22 }, /* FOLSIZE */
	{ deskfr_string_111, deskfr_string_112, deskfr_string_113, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,20 }, /* APPLNAME */
	{ deskfr_string_114, deskfr_string_115, deskfr_string_116, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 39,39 }, /* APPLPARM */
	{ deskfr_string_121, deskfr_string_122, deskfr_string_123, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 2,19 }, /* DRID */
	{ deskfr_string_124, deskfr_string_125, deskfr_string_126, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 13,25 }, /* DRLABEL */
	{ deskfr_string_134, deskfr_string_135, deskfr_string_136, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,32 }, /* APNAME */
	{ deskfr_string_137, deskfr_string_138, deskfr_string_139, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 12,32 }, /* APDFTYPE */
	{ deskfr_string_148, deskfr_string_149, deskfr_string_150, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,23 }, /* NUMDIR */
	{ deskfr_string_151, deskfr_string_152, deskfr_string_153, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,21 }, /* NUMFILE */
	{ deskfr_string_157, deskfr_string_158, deskfr_string_159, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,25 }, /* DELDIR */
	{ deskfr_string_160, deskfr_string_161, deskfr_string_162, IBM, 0, TE_RIGHT, 0x1100, 0x0, 0, 5,23 }, /* DELFILES */
	{ deskfr_string_166, deskfr_string_167, deskfr_string_168, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 0,0 }, /* FNAME */
	{ deskfr_string_169, deskfr_string_170, deskfr_string_171, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 0,0 }, /* EDFNAME */
	{ deskfr_string_175, deskfr_string_176, deskfr_string_177, IBM, 0, TE_LEFT, 0x1100, 0x0, 0, 0,0 } /* MKNAME */
};


static OBJECT rs_object[NUM_OBS] = {
/* ADMENU */

	{ -1, 1, 7, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 0,0, 80,25 },
	{ 7, 2, 2, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0x1100L), 0,0, 80,513 },
	{ 1, 3, 6, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 0,0, 40,769 },
	{ 4, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_0), 0,0, 8,769 }, /* DESKMENU */
	{ 5, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_1), 8,0, 9,769 }, /* FILEMENU */
	{ 6, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_2), 17,0, 15,769 }, /* VIEWMENU */
	{ 2, -1, -1, G_TITLE, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_3), 32,0, 8,769 }, /* OPTNMENU */
	{ 0, 8, 36, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 0,769, 80,24 },
	{ 17, 9, 16, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 1,0, 24,8 },
	{ 10, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_4), 0,0, 24,1 }, /* ABOUITEM */
	{ 11, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskfr_string_5), 0,1, 24,1 }, /* L1ITEM */
	{ 12, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_6), 0,2, 24,1 },
	{ 13, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_7), 0,3, 24,1 },
	{ 14, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_8), 0,4, 24,1 },
	{ 15, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_9), 0,5, 24,1 },
	{ 16, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_10), 0,6, 24,1 },
	{ 8, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_11), 0,7, 24,1 },
	{ 28, 18, 27, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 7,0, 22,8 },
	{ 19, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_12), 0,0, 22,1 }, /* OPENITEM */
	{ 20, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_13), 0,1, 22,1 }, /* SHOWITEM */
	{ 21, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskfr_string_14), 0,2, 22,1 },
	{ 22, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_15), 0,3, 22,1 }, /* NEWFITEM */
	{ 23, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_16), 0,4, 22,1 }, /* CLSFITEM */
	{ 24, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_17), 0,5, 22,1 }, /* CLOSWITEM */
	{ 25, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskfr_string_18), 0,6, 22,1 },
	{ 26, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_19), 0,7, 22,1 }, /* FORMITEM */
	{ 27, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_20), 0,8, 22,1 },
	{ 17, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_21), 0,9, 22,1 },
	{ 36, 29, 35, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 9,0, 24,7 },
	{ 30, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_22), 0,0, 24,1 }, /* ICONITEM */
	{ 31, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_23), 0,1, 24,1 }, /* TEXTITEM */
	{ 32, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskfr_string_24), 0,2, 24,1 },
	{ 33, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_25), 0,3, 24,1 }, /* NAMEITEM */
	{ 34, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_26), 0,4, 24,1 }, /* DATEITEM */
	{ 35, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_27), 0,5, 24,1 }, /* SIZEITEM */
	{ 28, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_28), 0,6, 24,1 }, /* TYPEITEM */
	{ 7, 37, 42, G_BOX, OF_NONE, OS_NORMAL, C_UNION(0xFF1100L), 8,0, 31,6 },
	{ 38, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_29), 0,0, 31,1 }, /* IDSKITEM */
	{ 39, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_30), 0,1, 31,1 }, /* IAPPITEM */
	{ 40, -1, -1, G_STRING, OF_NONE, OS_DISABLED, C_UNION(deskfr_string_31), 0,2, 31,1 },
	{ 41, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_32), 0,3, 31,1 }, /* PREFITEM */
	{ 42, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_33), 0,4, 31,1 }, /* SAVEITEM */
	{ 36, -1, -1, G_STRING, OF_LASTOB, OS_NORMAL, C_UNION(deskfr_string_34), 0,5, 31,1 }, /* PRINTITEM */

/* ADFILEIN */

	{ -1, 1, 11, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 39,13 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_35), 1,1, 16,1 }, /* INFTITLE */
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[0]), 19,3, 19,1 }, /* FINAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[1]), 7,4, 26,1 }, /* FISIZE */
	{ 5, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[2]), 1,5, 32,1 }, /* FIDATE */
	{ 6, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[3]), 25,6, 8,1 }, /* FITIME */
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_48), 4,7, 11,1 },
	{ 10, 8, 9, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 19,7, 23,3 },
	{ 9, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_49), 0,0, 17,1 }, /* FIRWRITE */
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_50), 0,2, 10,1 }, /* FIRONLY */
	{ 11, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_51), 9,11, 10,1 }, /* FIOK */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskfr_string_52), 25,11, 8,1 }, /* FICNCL */

/* ADDISKIN */

	{ -1, 1, 8, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,12 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_53), 3,1, 16,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[4]), 7,3, 27,1 }, /* DIDRIVE */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[5]), 8,4, 29,1 }, /* DIVOLUME */
	{ 5, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[6]), 3,5, 29,1 }, /* DINFOLDS */
	{ 6, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[7]), 6,6, 26,1 }, /* DINFILES */
	{ 7, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[8]), 5,7, 27,1 }, /* DIUSED */
	{ 8, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[9]), 2,8, 30,1 }, /* DIAVAIL */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskfr_string_72), 26,10, 10,1 }, /* DIOK */

/* ADFOLDIN */

	{ -1, 1, 8, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,11 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_73), 1,1, 18,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[10]), 6,3, 30,1 }, /* FOLNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[11]), 10,4, 20,1 }, /* FOLDATE */
	{ 5, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[12]), 29,4, 8,1 }, /* FOLTIME */
	{ 6, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[13]), 1,5, 30,1 }, /* FOLNFOLD */
	{ 7, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[14]), 5,6, 26,1 }, /* FOLNFILE */
	{ 8, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[15]), 5,7, 26,1 }, /* FOLSIZE */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskfr_string_92), 26,9, 10,1 }, /* FOLOK */

/* ADDINFO */

	{ -1, 1, 11, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,16 },
	{ 2, -1, -1, G_IMAGE, OF_NONE, OS_NORMAL, C_UNION(&rs_bitblk[0]), 1040,5, 8192,16384 },
	{ 3, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_93), 3,1, 32,1 },
	{ 4, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_94), 11,4, 7,1 },
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_95), 9,3, 16,1 },
	{ 6, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_96), 15,5, 16,1 },
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_97), 9,6, 29,1 },
	{ 8, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_98), 11,12, 22,1 },
	{ 9, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_99), 11,9, 10,1 },
	{ 10, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_100), 10,11, 0,1 },
	{ 11, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_101), 15,10, 42,1 },
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskfr_string_102), 15,14, 10,1 }, /* DEOK */

/* ADPINFO */

	{ -1, 1, 7, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,11 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_103), 1,1, 23,1 },
	{ 3, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_104), 1,3, 23,1 },
	{ 4, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_105), 1,4, 23,1 },
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_106), 1,5, 23,1 },
	{ 6, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_107), 1,6, 23,1 },
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_108), 1,7, 23,1 },
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskfr_string_109), 26,9, 10,1 }, /* APDOK */

/* ADOPENAP */

	{ -1, 1, 6, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 40,9 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_110), 3,1, 16,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[16]), 7,3, 19,1 }, /* APPLNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[17]), 1,5, 38,1 }, /* APPLPARM */
	{ 5, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_117), 9,7, 10,1 }, /* APPLOK */
	{ 6, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskfr_string_118), 25,7, 8,1 }, /* APPLCNCL */
	{ 0, -1, -1, G_STRING, OF_LASTOB, OS_NORMAL, C_UNION(deskfr_string_119), 1,4, 12,1 },

/* ADINSDIS */

	{ -1, 1, 10, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_120), 3,1, 18,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[18]), 5,3, 20,1 }, /* DRID */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[19]), 5,4, 32,1 }, /* DRLABEL */
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_127), 8,6, 10,1 },
	{ 6, -1, -1, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 18,6, 24,1 },
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_128), 1,0, 8,1 },
	{ 8, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_129), 10,0, 8,1 },
	{ 9, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskfr_string_130), 2,6, 10,1 }, /* DROK */
	{ 10, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskfr_string_131), 14,6, 10,1 }, /* DRREMOVE */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskfr_string_132), 26,6, 8,1 }, /* DRCANCEL */

/* ADINSAPP */

	{ -1, 1, 11, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,13 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_133), 3,1, 19,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[20]), 1,3, 35,1 }, /* APNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[21]), 5,4, 26,1 }, /* APDFTYPE */
	{ 5, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_140), 8,5, 17,1 },
	{ 9, 6, 8, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 1,7, 40,4 },
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_141), 0,0, 5,1 }, /* APGEM */
	{ 8, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_142), 7,0, 5,1 }, /* APDOS */
	{ 5, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_143), 14,0, 22,1 }, /* APPARMS */
	{ 10, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskfr_string_144), 16,11, 10,1 }, /* APOK */
	{ 11, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_145), 28,11, 8,1 }, /* APCANCEL */
	{ 0, -1, -1, G_BUTTON, 0x31, OS_NORMAL, C_UNION(deskfr_string_146), 13,2, 22,1 },

/* CPBOX */

	{ -1, 1, 5, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 34,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_147), 3,1, 20,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[22]), 3,3, 26,1 }, /* NUMDIR */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[23]), 6,4, 23,1 }, /* NUMFILE */
	{ 5, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_154), 11,6, 10,1 }, /* OKCP */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskfr_string_155), 23,6, 8,1 }, /* CCANCEL */

/* DELBOX */

	{ -1, 1, 5, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 32,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_156), 2,1, 23,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[24]), 1,3, 28,1 }, /* DELDIR */
	{ 4, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[25]), 2,4, 27,1 }, /* DELFILES */
	{ 5, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskfr_string_163), 7,6, 10,1 }, /* DELOK */
	{ 0, -1, -1, G_BUTTON, 0x27, OS_NORMAL, C_UNION(deskfr_string_164), 19,6, 8,1 }, /* DELCNCL */

/* SAMENAME */

	{ -1, 1, 5, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 37,8 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_165), 3,1, 25,1 }, /* SNAME */
	{ 3, -1, -1, G_FBOXTEXT, OF_NONE, OS_NORMAL, C_UNION(&rs_tedinfo[26]), 7,3, 27,1 }, /* FNAME */
	{ 4, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[27]), 2,4, 31,1 }, /* EDFNAME */
	{ 5, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_172), 11,6, 10,1 }, /* COPY */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskfr_string_173), 23,6, 8,1 }, /* QUIT */

/* ADMKDBOX */

	{ -1, 1, 4, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 27,7 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_174), 3,1, 10,1 },
	{ 3, -1, -1, G_FBOXTEXT, OF_EDITABLE, OS_NORMAL, C_UNION(&rs_tedinfo[28]), 3,3, 19,1 }, /* MKNAME */
	{ 4, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_178), 4,5, 10,1 }, /* MKOK */
	{ 0, -1, -1, G_BUTTON, 0x25, OS_NORMAL, C_UNION(deskfr_string_179), 16,5, 8,1 }, /* MKCNCL */

/* ADSETPREF */

	{ -1, 1, 20, G_BOX, OF_NONE, OS_OUTLINED, C_UNION(0x21100L), 0,0, 38,17 },
	{ 2, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_180), 3,1, 16,1 },
	{ 3, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_181), 4,3, 16,1 },
	{ 6, 4, 5, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 13,5, 12,1 },
	{ 5, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_182), 0,0, 5,1 }, /* SPCDYES */
	{ 3, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_183), 7,0, 5,1 }, /* SPCDNO */
	{ 7, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_184), 4,7, 15,1 },
	{ 17, 8, 16, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 13,9, 12,1 },
	{ 9, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_185), 0,0, 5,1 }, /* SPCCYES */
	{ 10, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_186), 7,0, 5,1 }, /* SPCCNO */
	{ 11, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_187), 4,7, 19,1 },
	{ 12, -1, -1, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 3,8, 31,2 },
	{ 13, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_188), 0,0, 7,1 },
	{ 14, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_189), 9,0, 3,1 },
	{ 15, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_190), 14,0, 3,1 },
	{ 16, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_191), 19,0, 3,1 },
	{ 7, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_192), 24,0, 7,1 },
	{ 18, -1, -1, G_BUTTON, 0x7, OS_NORMAL, C_UNION(deskfr_string_193), 4,15, 10,1 }, /* SPOK */
	{ 19, -1, -1, G_BUTTON, 0x5, OS_NORMAL, C_UNION(deskfr_string_194), 27,15, 8,1 }, /* SPCANCEL */
	{ 20, -1, -1, G_STRING, OF_NONE, OS_NORMAL, C_UNION(deskfr_string_195), 4,10, 31,2 },
	{ 0, 21, 23, G_IBOX, OF_NONE, OS_NORMAL, C_UNION(0x0L), 3,12, 31,2 },
	{ 22, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_196), 3,0, 6,1 }, /* SPLOW */
	{ 23, -1, -1, G_BUTTON, 0x11, OS_NORMAL, C_UNION(deskfr_string_197), 12,0, 8,1 }, /* SPMEDIUM */
	{ 20, -1, -1, G_BUTTON, 0x31, OS_NORMAL, C_UNION(deskfr_string_198), 23,0, 6,1 } /* SPHIGH */
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
_WORD deskfr_rsc_load(_WORD wchar, _WORD hchar)
#else
_WORD deskfr_rsc_load(wchar, hchar)
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
_WORD deskfr_rsc_gaddr(_WORD type, _WORD idx, void *gaddr)
#else
_WORD deskfr_rsc_gaddr(type, idx, gaddr)
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
_WORD deskfr_rsc_free(void)
#else
_WORD deskfr_rsc_free()
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

char rs_name[] = "deskfr.rsc";

_WORD _rsc_format = 2; /* RSC_FORM_SOURCE2 */
#endif
#endif /* RSC_STATIC_FILE */
