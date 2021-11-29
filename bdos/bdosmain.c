/* bdosmain.c - 'front end' to bdos.  This is OEM definable module	*/


#include "tos.h"
#include "fs.h"
#include "bios.h"

BCB bcbx[4];
BOOLEAN dirlock;
char secbuf[4][512];


/*
 *  TIMESTAMP - set to 1 if it's okay for the bdos to print the time
 *	stamp string at init time.  Otherwise, set to 0.
 */

#define	TIMESTAMP	0


/*
 *  bufl - buffer lists
 *	two lists:  fat,dir / data
 *	these lists should be initialized by the bios.
 *	(vme bios does this in biosc.c)
 */

BCB *bufl[2];


/*
 *  osinit - the bios calls this routine to initialize the os
 */

/* 306de: 00e18a6c */
/* 306us: 00e18a12 */
/* 104de: 00fc95c8 */
VOID osinit(NOTHING)
{
	/* set up sector buffers */
	bcbx[0].b_link = &bcbx[1];
	bcbx[2].b_link = &bcbx[3];

	/*  
	 *  invalidate BCBs
	 */

	bcbx[0].b_bufdrv = -1;
	bcbx[1].b_bufdrv = -1;
	bcbx[2].b_bufdrv = -1;
	bcbx[3].b_bufdrv = -1;

	/*
	 *  initialize buffer pointers in BCBs
	 */

	bcbx[0].b_bufr = &secbuf[0][0];
	bcbx[1].b_bufr = &secbuf[1][0];
	bcbx[2].b_bufr = &secbuf[2][0];
	bcbx[3].b_bufr = &secbuf[3][0];

	/*
	 *  initialize the buffer list pointers
	 */

	bufl[BI_FAT] = &bcbx[0]; 			/* fat buffers */
	bufl[BI_DATA] = &bcbx[2]; 			/* dir/data buffers */

	_osinit();							/*  real routine in bdos.arc    */
	
	xsetdrv(bootdev);
}
