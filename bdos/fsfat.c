/*  fsfat.c - fat mgmt routines for file system				*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>
#include "../bios/biosdefs.h"

#undef min
#define min(a,b) (((a) < (b)) ? (a) : (b))

/*
 *  dirtbl - default directories.
 * Each entry points to the DND for someone's default directory.
 * They are linked to each process by the p_curdir entry in the PD.
 * The first entry (dirtbl[0]) is not used, as p_curdir[i]==0
 * means 'none set yet'.
 */

DND *dirtbl[NCURDIR];

/*
 *  diruse - use count 
 *  drvsel - mask of drives selected since power up
 */

char diruse[NCURDIR];

drvmask drvsel;



#if GEMDOS >= 0x18
/* 306de: 00e144d2 */
/* 306us: 00e14478 */
static VOID invalidate(P(int) drv)
PP(register int drv;)
{
	register BCB *b;
	register BCB **bp;
	
	for (bp = bufl; bp < &bufl[2]; bp++)
	{
		for (b = *bp; b != NULL; b = b->b_link)
		{
			if (b->b_bufdrv == drv && !b->b_dirty)
				b->b_bufdrv = -1;
		}
	}
}


/*
 *  flush - flush all modified disk buffers for drive
 *
 *	Last modified	SCC	10 Apr 85
 *
 *	NOTE:	rwabs() is a macro that includes a longjmp() which is executed 
 *		if the BIOS returns an error, therefore flush() does not need 
 *		to return any error codes.
 */

/* 306de: 00e14516 */
/* 306us: 00e144bc */
static VOID flush(P(BCB *) b)
PP(register BCB *b;)
{
	register DMD *dm;				/*  media descr for buffer  */
	register int typ;
	register int drv;
	int n;
	
	dm = b->b_dm;
	typ = b->b_buftyp;
	drv = b->b_bufdrv;
	n = typ != BT_DATA ? BI_FAT : BI_DATA;

	for (b = bufl[n]; b != NULL; b = b->b_link)
	{
		if (b->b_bufdrv == drv && b->b_dirty)
		{
			typ = b->b_buftyp;
			b->b_bufdrv = -1;					/* invalidate in case of error */
			rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[typ], drv);
			
			/* flush to both fats */
			if (typ == BT_FAT 
#if FAT1_SUPPORT
				&& !dm->m_1fat
#endif
				)
				rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[BT_FAT] - dm->m_fsiz, drv);

			b->b_bufdrv = drv;					/* re-validate */
			b->b_dirty = 0;
		}
	}
}


/* 306de: 00e14624 */
/* 306us: 00e145ca */
VOID flushall(NOTHING)
{
	register int drv;
	register int typ;
	register BCB *b;
	
	for (drv = 0; drv < BLKDEVNUM; drv++)
	{
		for (typ = BI_DIR; typ >= BI_FAT; typ--)
		{
			for (b = bufl[typ]; b != NULL; b = b->b_link)
				if (b->b_bufdrv == drv && b->b_dirty)
				{
					flush(b);
					break;
				}
		}
	}
}


#endif
