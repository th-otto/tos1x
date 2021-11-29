/*
 * These functions are referenced by VDI,
 * but are defined elsewhere
 *
 *
 * This file is only used when linking a single module,
 * to get the same addresses as when linking the whole ROM
 */
#define __ASSEMBLER__ 1

#include "config.h"
#include "vdidefs.h"
#include "sections.inc"

/* from BIOS */
		xdef _zeromem
		text
#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif

#if BINEXACT

#if TOSVERSION == 0x306
_zeromem equ BIOSTBASE+$1680
#endif

#if TOSVERSION == 0x206
_zeromem equ BIOSTBASE+$1548
#endif

#if TOSVERSION == 0x208
_zeromem equ BIOSTBASE+$148E
#endif

#if TOSVERSION == 0x104
_zeromem equ BIOSTBASE+$1EE0
#endif

#if TOSVERSION == 0x106
_zeromem equ BIOSTBASE+$1EE0
#endif

#if TOSVERSION == 0x162
_zeromem equ BIOSTBASE+$1EE0
#endif

#else

_zeromem equ BIOSTBASE+$1548
       xdef _memcpy
_memcpy equ BIOSTBASE+2
       xdef ringbell
ringbell equ BIOSTBASE+4
	   xdef _shifty
_shifty equ $10bb

#endif
