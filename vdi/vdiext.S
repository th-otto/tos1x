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
		text
#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif

#if BINEXACT


#else

       xdef _memcpy
_memcpy equ BIOSTBASE+2
	   xdef _shifty
_shifty equ $e1b

#endif
