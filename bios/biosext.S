/*
 * These functions are referenced by BIOS,
 * but are defined elsewhere
 *
 *
 * This file is only used when linking a single module,
 * to get the same addresses as when linking the whole ROM
 */
#include "config.h"
#include "sections.inc"

/* from VDI */
		xdef line1010
		xdef _SETBLT
		xdef _GETBLT
		xdef esc_init
		xdef resetdev
		xdef blink
		xdef _cursconf
		xdef _bcon5out
		xdef _bcon2out

/* from GEMDOS */
		xdef _osinit
		xdef bdoslmul

line1010    equ VDITBASE+$08AA
_SETBLT     equ VDITBASE+$1318
_GETBLT     equ VDITBASE+$1340
esc_init    equ VDITBASE+$1236
resetdev    equ VDITBASE+$12C0
blink       equ VDITBASE+$0402
_cursconf   equ VDITBASE+$0434
_bcon5out   equ VDITBASE+$006C
_bcon2out   equ VDITBASE+$0078

_osinit   equ BDOSTBASE+$5240
bdoslmul  equ BDOSTBASE+$510A

/* from AES */
		xdef gemstart

gemstart  equ AESTBASE
