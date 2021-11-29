/*
 ********************************  vdidefs.h  *********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/03 15:22:56 $
 * =============================================================================
 *
 * Revision 3.0  91/01/03  15:22:56  lozben
 * New generation VDI
 * 
 * Revision 2.2  90/03/01  13:32:58  lozben
 * *** Initial Revision ***
 * 
 *******************************************************************************
 */

#ifndef __VDIDEFS_H__
#define __VDIDEFS_H__ 1

#include "config.h"

#if TOSVERSION >= 0x206
#define	MAX_PAL		4096	/* palette size                     */
#else
#define MAX_PAL		512	    /* palette size                     */
#endif

/*
 * set to 1 for supporting pixel-packed VIDEL modes, including hicolor and truecolor
 */
#define VIDEL_SUPPORT (TOSVERSION >= 0x400)

/*
 * set to 1 for supporting hardware accelerated blitter routines
 */
#define BLITTER_SUPPORT ((TOSVERSION < 0x300) | (TOSVERSION >= 0x400))

/*
 * set to 1 for supporting 8 planes interleaved video modes
 * (and corresponding 256 entries color palette)
 */
#define PLANES8 0

/*
 * used to mark some strange looking code segments
 * that are needed to create a binary equivalent image
 * of the TOS ROMs
 */
#ifndef BINEXACT
#define BINEXACT 1
#endif

/*
 * used to mark code changes due to
 * multiple linea variable structures feature
 */
#define MULTI_LINEA (TOSVERSION >= 0x400)

/*
 * see lineavar.h for explanation
 */
#define LINEA_HACK (BINEXACT & (!MULTI_LINEA))


#if VIDEL_SUPPORT
#define MU_PLANES 32
#else
#if PLANES8
#define MU_PLANES 8
#else
#define MU_PLANES 4
#endif
#endif


/*
 * size of the "overlay" area
 */
#if TOSVERSION >= 0x300
#define OVLSIZE 7730
#else
#define OVLSIZE 3890
#endif

/*
 * PTSIN maximum length
 */
#if TOSVERSION >= 0x300
#define MAX_PTSIN 1024
#else
#define MAX_PTSIN 512
#endif

#endif /* __VDIDEFS_H__ */
