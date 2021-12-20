/*      DESKDISK.C From 1.4     12/7/87 - 12/15/87      Derek.Mui       */
/*      For newdesktop          3/18/89 - 6/15/89       Derek Mui       */
/*      Update and crunch       8/30/89                 D.Mui           */
/*      Change at fc_format     1/29/90                 D.Mui           */
/*      Add high density formatting     2/21/90         D.Mui           */
/*      Change the up_allwin to up_1allwin      11/14/90        D.Mui   */
/*      Change the high density media cookie value      4/26/91 D.Mui   */
/*      Change the setting of FCDOUBLE button           4/30/91 D.Mui   */

/*      Discussion of skew factors
 *       
 *       The optimal skew factor for single/double sided formats is:
 *       7 8 9 1 2 3 4 5 6
 *       5 6 7 8 9 1 2 3 4
 *       ( that is, a skew factor of 2 )
 *
 *       This is because the floppy drive always does a seek-with-verify,
 *       so the controller needs to read sector 9, seek to the next head/side
 *       ( where it's too late to catch the ID of sector 8 ), read the sector
 *       ID of sector 9 ( to verify the seek; now the seek is done ). and
 *       then begin reading with sector 1.
 *
 *       However, some Atari single-sided drives are actually 6ms drives.
 *       They have extra circuitry to convert the 3ms step pulses into 
 *       6ms pulses, but this slows them down enough that the above
 *       skew factor is not enough. Hence, single-sided disks are formatted
 *       with a skew factor of 3 ( or 6, depending ).
 */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"
#include "toserrno.h"

#define MAXTRACK	80					/* maximum number of track      */
#define FC_NUMOBJS	26
#define MAXSPT		9					/* Maximum sector / track       */
#define	SECSIZE		512
#define	TRKSIZE		0x1200				/* (bytesPerSector) * (sectorsPerTrack) */
#define RSECTS		2					/* |= 0x02 so mediach state is not checked */
#define WSECTS		3

#define FSIZE		0x2000L				/* format buffer size (8k)     */
#define	VIRGIN		0xe5e5				/* FORMAT value to write to new sectors */
#define	MAGIC		0x87654321L
#define INTERLV		-1					/* neg, so use skew table for format    */
#define SINGLESKEW	3					/* amount of SKEW for a single sided and high density disk */
#define	DOUBLESKEW	2					/* amount of skew between sides     */

#define	BADSECT		-16
#define MAXBAD		16					/* max number of bad sector allowed */

#include "../bios/bpb.h"


/* The DSB location is returned by getbpb (Xbios 7) and is defined in
 *	gemdos/rwabs.c.  We use it to determine the # of sides for
 *	fc_copy, since it's easier to call getbpb and use the
 *	system data structures than to read the boot sector
 *	ourselves. getbpb actually returns a pointer to
 *	this global system structure.
 *	(kbad 880830)
 */

#define DSB	struct dsb					/* Device Status Block (BLKDEV in bios.h) */
DSB
{
	BPB b;								/* BIOS Parameter Block     */

	int16_t tracks;						/* #tracks (cylinders) on dev   */
	int16_t sides;						/* #sides per cylinder      */
	int16_t spc;						/* #sectors/cylinder        */
	int16_t spt;						/* #sectors/track       */
	int16_t hidden;						/* #hidden tracks       */
	uint8_t serial[3];					/* 24-bit volume serial number  */
};

/*
 * sigh, why use trp13/trp14 from AES here?
 */
#undef Getbpb
#undef Rwabs
#undef Flopfmt
#undef Protobt
#define Getbpb(devno) trp13(7, devno)
#define Rwabs(a,b,c,d,e) trp13(4, a, b, c, d, e)
#define Flopfmt(a,b,c,d,e,f,g,h,i) trp14(10, a, b, c, d, e, f, g, h, i)
#define Protobt(a,b,c,d) trp14(18, a, b, c, d)


BOOLEAN fc_format PROTO((OBJECT *obj));
VOID fc_copy PROTO((OBJECT *obj));
int16_t fc_rwsec PROTO((int16_t op, VOIDPTR buf, int16_t nsect, int16_t sect, int16_t dev));
LINEF_STATIC VOID fc_clfix PROTO((uint16_t cl, uint16_t *fat));
VOID fc_bar PROTO((OBJECT *obj, int16_t which));
VOID fc_draw PROTO((OBJECT *obj, int16_t which));



