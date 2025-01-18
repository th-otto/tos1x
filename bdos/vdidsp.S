/*
 * These 2 functions are referenced by GEMDOS,
 * but are defined elsewhere
 */
#include "config.h"
#include "sections.inc"

	xdef _GSX_ENTRY

#if TOSVERSION == 0x104
_GSX_ENTRY   equ VDITBASE+$0834
#endif

#if TOSVERSION == 0x106
_GSX_ENTRY   equ VDITBASE+$0834
#endif

#if TOSVERSION == 0x162
_GSX_ENTRY   equ VDITBASE+$0834
#endif
