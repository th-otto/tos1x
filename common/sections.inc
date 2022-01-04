#include "../common/config.h"

/*
 * Definitions for length of text, data and bss
 * of the separate modules.
 *
 * Length of BIOS text segment is different due to some extra
 * code for ALT-scancode mappings.
 *
 * Length of DESKTOP text segment is different due to some
 * differences in fmt_date() and fmt_time() which build
 * a language-specific version of the file date+time
 */

#if TOSVERSION == 0x306

/*
 * length of BIOS text segment of the US version,
 * which does not have any extra code
 */
#define BTLEN_US    $0000641C
#define DTLEN_US    $0000FBCC


#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

#if OS_COUNTRY == CTRY_DE
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

#if OS_COUNTRY == CTRY_FR
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009FA
#define GLUELEN     $00007788
#endif

#if OS_COUNTRY == CTRY_SG
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

#if OS_COUNTRY == CTRY_SF
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009FA
#define GLUELEN     $00007788
#endif

#if OS_COUNTRY == CTRY_UK
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

#if OS_COUNTRY == CTRY_ES
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009C4
#define GLUELEN     $00007730
#endif

#if OS_COUNTRY == CTRY_IT
#define BIOSTLEN    BTLEN_US+$68
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009B6
#define GLUELEN     $000075C4
#endif

#if OS_COUNTRY == CTRY_SE
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $0000095E
#define GLUELEN     $00007658
#endif

#if OS_COUNTRY == CTRY_CZ
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

#if OS_COUNTRY == CTRY_PL
#if BINEXACT
#undef RAMVERSION
#define RAMVERSION 1
#endif
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif


/*
 * these are identical in all language versions
 */
#define BIOSDLEN    $000009D8
#define VDITLEN     $0000D06E
#define VDIDLEN     $00006EFA
#define BDOSTLEN    $000062AC
#define BDOSDLEN    $0000039E
#define AESTLEN     $0000CCD6
#define AESDLEN     $000006D8

#endif /* TOSVERSION == 0x306 */


#if TOSVERSION == 0x305

/*
 * length of BIOS text segment of the US version,
 * which does not have any extra code
 */
#define BTLEN_US    $0000563E
#define DTLEN_US    $0000FBCC


#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

/*
 * these are identical in all language versions
 */
#define BIOSDLEN    $000009D8
#define VDITLEN     $0000D06E
#define VDIDLEN     $00006EFA
#define BDOSTLEN    $000062AC
#define BDOSDLEN    $0000039E
#define AESTLEN     $0000CCD6
#define AESDLEN     $000006D8

#endif /* TOSVERSION == 0x305 */


#if TOSVERSION == 0x206

#define BTLEN_US    $0000603A
#define DTLEN_US    $0000FBCC

#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_PL) | (OS_COUNTRY == CTRY_CZ)
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

#if OS_COUNTRY == CTRY_SG
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

#if OS_COUNTRY == CTRY_SF
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009FA
#define GLUELEN     $00007788
#endif

#if OS_COUNTRY == CTRY_FR
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009FA
#define GLUELEN     $00007788
#endif

#if OS_COUNTRY == CTRY_UK
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

#if OS_COUNTRY == CTRY_ES
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009C4
#define GLUELEN     $00007730
#endif

#if OS_COUNTRY == CTRY_IT
#define BIOSTLEN    BTLEN_US+$68
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009B6
#define GLUELEN     $000075C4
#endif

#if OS_COUNTRY == CTRY_SE
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $0000095E
#define GLUELEN     $00007658
#endif

/*
 * these are identical in all language versions
 */
#define BIOSDLEN    $00000888
#define VDITLEN     $0000999A
#define VDIDLEN     $00002846
#define BDOSTLEN    $000062FC
#define BDOSDLEN    $0000039E
#define AESTLEN     $0000CCD6
#define AESDLEN     $000006D8

#endif /* TOSVERSION == 0x206 */


#if TOSVERSION == 0x208

#define BTLEN_US    $00005FEA
#define DTLEN_US    $0000FBCC

#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

#if OS_COUNTRY == CTRY_DE
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

#if OS_COUNTRY == CTRY_FR
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009FA
#define GLUELEN     $00007788
#endif

#if OS_COUNTRY == CTRY_UK
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492
#endif

#if OS_COUNTRY == CTRY_ES
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009C4
#define GLUELEN     $00007730
#endif

#if OS_COUNTRY == CTRY_IT
#define BIOSTLEN    BTLEN_US+$68
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009B6
#define GLUELEN     $000075C4
#endif

#if OS_COUNTRY == CTRY_SE
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $0000095E
#define GLUELEN     $00007658
#endif

#if OS_COUNTRY == CTRY_CZ
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009DE
#define GLUELEN     $00007504
#endif

/*
 * these are identical in all language versions
 */
#define BIOSDLEN    $00000888
#define VDITLEN     $0000999A
#define VDIDLEN     $00002846
#define BDOSTLEN    $000062FC
#define BDOSDLEN    $0000039E
#define AESTLEN     $0000CCD6
#define AESDLEN     $000006D8

#endif /* TOSVERSION == 0x208 */


#if TOSVERSION == 0x104

#define BIOSTBASE   $00FC0000

/*
 * these are identical in almost all language versions
 */
#define BIOSDLEN    $00000256
#define VDITLEN     $000098A2
#define VDIDLEN     $00002846
#define BDOSTLEN    $00005F64
#define BDOSDLEN    $00000396
#define AESTLEN     $00000000 /* included in desk */
#define AESDLEN     $00000000 /* included in desk */


#define BTLEN_US    $0000432E
#define DTLEN_US    $000146CA

#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009E0
#define GLUELEN     $000041C4
#endif

#if OS_COUNTRY == CTRY_DE
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $00004226
#endif

#if OS_COUNTRY == CTRY_FR
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $000044D6
#endif

#if OS_COUNTRY == CTRY_UK
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009E0
#define GLUELEN     $000041C4
#endif

#if OS_COUNTRY == CTRY_ES
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $0000441A
#endif

#if OS_COUNTRY == CTRY_IT
#define BIOSTLEN    BTLEN_US+$68
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $000043B2
#endif

#if OS_COUNTRY == CTRY_SG
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $00004266
#endif

#if OS_COUNTRY == CTRY_SF
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $000044D6
#endif

#if OS_COUNTRY == CTRY_SE
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $00004226
#endif

#if OS_COUNTRY == CTRY_NL
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009E0
#define GLUELEN     $000043CC
/*
 * only version which is 4 bytes shorter,
 * due to 2 small differences in vdi/monout.c
 * and vdi/text.c
 */
#undef VDITLEN
#define VDITLEN     $0000989E
#endif

#if OS_COUNTRY == CTRY_CZ
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$28
#define DESKDLEN    $000009DC
#define GLUELEN     $00004226
#endif

#endif /* TOSVERSION == 0x104 */


#if TOSVERSION == 0x106

#define BIOSTBASE   $00E00000

/*
 * these are identical in almost all language versions
 */
#define BIOSDLEN    $00000256
#define VDITLEN     $000098D6
#define VDIDLEN     $00002846
#define BDOSTLEN    $00005FAA
#define BDOSDLEN    $00000396
#define AESTLEN     $00000000 /* included in desk */
#define AESDLEN     $00000000 /* included in desk */


#define BTLEN_US    $00004514
#define DTLEN_US    $000163E6

#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009DA
#define GLUELEN     $000041C4
#endif

#if OS_COUNTRY == CTRY_DE
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $00004226
#endif

#if OS_COUNTRY == CTRY_FR
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000044D6
#endif

#if OS_COUNTRY == CTRY_UK
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009DA
#define GLUELEN     $000041C4
#endif

#if OS_COUNTRY == CTRY_ES
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $0000441A
#endif

#if OS_COUNTRY == CTRY_IT
#define BIOSTLEN    BTLEN_US+$68
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000043B2
#endif

#if OS_COUNTRY == CTRY_SG
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $00004226
#endif

#if OS_COUNTRY == CTRY_SF
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000044D6
#endif

#if OS_COUNTRY == CTRY_SE
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000042DA
#endif

#if OS_COUNTRY == CTRY_NL
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009DA
#define GLUELEN     $000043CC
/*
 * only version which is 2 bytes shorter,
 * due to a difference in vdi/text.c
 */
#undef VDITLEN
#define VDITLEN     $000098D4
#endif

#if OS_COUNTRY == CTRY_CZ
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $00004226
#endif

#endif /* TOSVERSION == 0x106 */


#if TOSVERSION == 0x162

#define BIOSTBASE   $00E00000

/*
 * these are identical in almost all language versions
 */
#define BIOSDLEN    $00000256
#define VDITLEN     $000098D6
#define VDIDLEN     $00002846
#define BDOSTLEN    $00006018
#define BDOSDLEN    $0000039E
#define AESTLEN     $00000000 /* included in desk */
#define AESDLEN     $00000000 /* included in desk */


#define BTLEN_US    $00004514
#define DTLEN_US    $00016464

#if OS_COUNTRY == CTRY_US
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009DA
#define GLUELEN     $000041C4
#endif

#if OS_COUNTRY == CTRY_DE
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $00004226
#endif

#if OS_COUNTRY == CTRY_FR
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000044D6
#endif

#if OS_COUNTRY == CTRY_UK
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009DA
#define GLUELEN     $000041C4
#endif

#if OS_COUNTRY == CTRY_ES
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $0000441A
#endif

#if OS_COUNTRY == CTRY_IT
#define BIOSTLEN    BTLEN_US+$68
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000043B2
#endif

#if OS_COUNTRY == CTRY_SG
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $00004226
#endif

#if OS_COUNTRY == CTRY_SF
#define BIOSTLEN    BTLEN_US+$86
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000044D6
#endif

#if OS_COUNTRY == CTRY_SE
#define BIOSTLEN    BTLEN_US+$78
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $000042DA
#endif

#if OS_COUNTRY == CTRY_NL
#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $000009DA
#define GLUELEN     $000043CC
/*
 * only version which is 2 bytes shorter,
 * due to a difference in vdi/text.c
 */
#undef VDITLEN
#define VDITLEN     $000098D4
#endif

#if OS_COUNTRY == CTRY_CZ
#define BIOSTLEN    BTLEN_US+$5A
#define DESKTLEN    DTLEN_US-$2A
#define DESKDLEN    $000009D6
#define GLUELEN     $00004226
#endif

#endif /* TOSVERSION == 0x162 */


#ifndef BIOSTBASE
#if RAMVERSION
#define BIOSTBASE   $00380000
#else
#define BIOSTBASE   $00E00000
#endif
#endif


/*
 * now calculate addresses from above
 */
#if TOSVERSION >= 0x200
/*
 * The order of all TOS versions is BIOS, VDI, GEMDOS, AES, DESK (+ glued resource files)
 */
#define VDITBASE  BIOSTBASE+BIOSTLEN
#define BDOSTBASE VDITBASE+VDITLEN
#define AESTBASE  BDOSTBASE+BDOSTLEN
#else
/*
 * The order of all TOS versions is BIOS, GEMDOS, VDI, AES+DESK (+ glued resource files)
 */
#define BDOSTBASE BIOSTBASE+BIOSTLEN
#define VDITBASE  BDOSTBASE+BDOSTLEN
#define AESTBASE  VDITBASE+VDITLEN
#endif
#define DESKTBASE AESTBASE+AESTLEN
#define ETEXT     DESKTBASE+DESKTLEN

#define BIOSDBASE ETEXT
#if TOSVERSION >= 0x200
#define VDIDBASE  BIOSDBASE+BIOSDLEN
#define BDOSDBASE VDIDBASE+VDIDLEN
#define AESDBASE  BDOSDBASE+BDOSDLEN
#else
#define BDOSDBASE BIOSDBASE+BIOSDLEN
#define VDIDBASE  BDOSDBASE+BDOSDLEN
#define AESDBASE  VDIDBASE+VDIDLEN
#endif
#define DESKDBASE AESDBASE+AESDLEN
#define EDATA     DESKDBASE+DESKDLEN+GLUELEN

#ifdef __MAKEFILE__

/*
 * The output of this is fed through bc.
 * The magic 24 is the (hexadecimal) size of the cout header
 * of object files generated by alcyon.
 * Its purpose is to get the section sizes and
 * offsets of the various TOS parts available as makefile variables,
 * without the need of using backtick shell commands which usually
 * don't work on SingleTOS.
 * Those sizes are not needed to link the ROM, but only
 * by the "make check" target(s).
 */
ibase=16
obase=10

bios_tbase=BIOSTBASE
bios_tlen=BIOSTLEN
bios_dbase=BIOSDBASE
bios_dlen=BIOSDLEN
vdi_tbase=VDITBASE
vdi_tlen=VDITLEN
vdi_dbase=VDIDBASE
vdi_dlen=VDIDLEN
bdos_tbase=BDOSTBASE
bdos_tlen=BDOSTLEN
bdos_dbase=BDOSDBASE
bdos_dlen=BDOSDLEN
aes_tbase=AESTBASE
aes_tlen=AESTLEN
aes_dbase=AESDBASE
aes_dlen=AESDLEN
desk_tbase=DESKTBASE
desk_tlen=DESKTLEN
desk_dbase=DESKDBASE
desk_dlen=DESKDLEN

gluebase=DESKDBASE+DESKDLEN
edata=EDATA

rombase=BIOSTBASE

print "bios_tbase=", bios_tbase, "\n"
print "bios_toff=", bios_tbase - rombase, "\n"
print "bios_tlen=", bios_tlen, "\n"
print "bios_tleno=", bios_tlen + 24, "\n"
print "bios_dbase=", bios_dbase, "\n"
print "bios_doff=", bios_dbase - rombase, "\n"
print "bios_dlen=", bios_dlen, "\n"
print "vdi_tbase=", vdi_tbase, "\n"
print "vdi_toff=", vdi_tbase - rombase, "\n"
print "vdi_tlen=", vdi_tlen, "\n"
print "vdi_tleno=", vdi_tlen + 24, "\n"
print "vdi_dbase=", vdi_dbase, "\n"
print "vdi_doff=", vdi_dbase - rombase, "\n"
print "vdi_dlen=", vdi_dlen, "\n"
print "bdos_tbase=", bdos_tbase, "\n"
print "bdos_toff=", bdos_tbase - rombase, "\n"
print "bdos_tlen=", bdos_tlen, "\n"
print "bdos_tleno=", bdos_tlen + 24, "\n"
print "bdos_dbase=", bdos_dbase, "\n"
print "bdos_doff=", bdos_dbase - rombase, "\n"
print "bdos_dlen=", bdos_dlen, "\n"
print "aes_tbase=", aes_tbase, "\n"
print "aes_toff=", aes_tbase - rombase, "\n"
print "aes_tlen=", aes_tlen, "\n"
print "aes_tleno=", aes_tlen + 24, "\n"
print "aes_dbase=", aes_dbase, "\n"
print "aes_doff=", aes_dbase - rombase, "\n"
print "aes_dlen=", aes_dlen, "\n"
print "desk_tbase=", desk_tbase, "\n"
print "desk_toff=", desk_tbase - rombase, "\n"
print "desk_tlen=", desk_tlen, "\n"
print "desk_tleno=", desk_tlen + 24, "\n"
print "desk_dbase=", desk_dbase, "\n"
print "desk_doff=", desk_dbase - rombase, "\n"
print "desk_dlen=", desk_dlen, "\n"

print "gluebase=", gluebase, "\n"
print "edata=", edata, "\n"

print "rombase=", rombase, "\n"

quit

#endif
