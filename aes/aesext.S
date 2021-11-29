/*
 * These functions are referenced by AES,
 * but are defined elsewhere
 *
 *
 * This file is only used when linking a single module,
 * to get the same addresses as when linking the whole ROM
 */
#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"
#include "sections.inc"

#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif


/* from DESKTOP */
	xdef _infdata
	xdef _XDeselect
	xdef _getcookie
	xdef _scan_2
	xdef _escan_str
	xdef _save_2
	xdef _app_reschange
	xdef _g_name
	xdef _deskmain
	xdef _xbios
	xdef _bios
	xdef _gemdos

#if TOSVERSION == 0x104
_xbios          equ DESKTBASE+(DESKTLEN-DTLEN_US)+$FB9C
_bios           equ DESKTBASE+(DESKTLEN-DTLEN_US)+$FBAC
_gemdos         equ DESKTBASE+(DESKTLEN-DTLEN_US)+$FBBC
_g_name         equ DESKTBASE+(DESKTLEN-DTLEN_US)+$9CE8
_deskmain       equ DESKTBASE+(DESKTLEN-DTLEN_US)+$D6B6 /* 206us:E3005C 206de:E3008C */
_XDeselect      equ 0
_getcookie      equ 0
#endif





	xdef _tosrsc
_tosrsc equ DESKDBASE+DESKDLEN  /* 306us:00E3ECA2 306de:00E3ED2E */
