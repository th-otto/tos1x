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
#include <compiler.h>

#if TOSVERSION >= 0x106
#define	MAX_PAL		4096	/* palette size                     */
#else
#define MAX_PAL		512	    /* palette size                     */
#endif

/*
 * set to 1 for supporting hardware accelerated blitter routines
 */
#define BLITTER_SUPPORT (TOSVERSION >= 0x104)

/*
 * used to mark some strange looking code segments
 * that are needed to create a binary equivalent image
 * of the TOS ROMs
 */
#ifndef BINEXACT
#define BINEXACT 1
#endif

/*
 * see lineavar.h for explanation
 */
#ifdef __ALCYON__
#define LINEA_HACK 1
#else
#define LINEA_HACK 0
#endif


#define MU_PLANES 4


/*
 * size of the "overlay" area
 */
#define OVLSIZE 3890

/*
 * PTSIN maximum length
 */
#define MAX_PTSIN 512

#endif /* __VDIDEFS_H__ */
