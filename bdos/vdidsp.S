/*
 * These 2 functions are referenced by GEMDOS,
 * but are defined elsewhere
 */
#include "config.h"
#include "sections.inc"

	xdef _zeromem
	xdef _GSX_ENTRY

#if TOSVERSION == 0x104
_zeromem     equ BIOSTBASE+$1EE0
_GSX_ENTRY   equ VDITBASE+$0834
	xdef checkRTC
checkRTC     equ BIOSTBASE+$1f70
	xdef readRTCTime
readRTCTime  equ BIOSTBASE+$1fc2
#endif

#if TOSVERSION == 0x106
_zeromem     equ BIOSTBASE+$20B8
_GSX_ENTRY   equ VDITBASE+$0834
	xdef checkRTC
checkRTC     equ BIOSTBASE+$1f70
	xdef readRTCTime
readRTCTime  equ BIOSTBASE+$1fc2
#endif

#if TOSVERSION == 0x162
_zeromem     equ BIOSTBASE+$20B8
_GSX_ENTRY   equ VDITBASE+$0834
	xdef checkRTC
checkRTC     equ BIOSTBASE+$1f70
	xdef readRTCTime
readRTCTime  equ BIOSTBASE+$1fc2
#endif
