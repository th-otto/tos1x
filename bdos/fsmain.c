/*  fsmain.c - GEMDOS file system notes and misc routines		*/
/*  xgetdrv,xsetdrv,xsetdta,xgetdta,uc,usr2xfr,xfr2usr	*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>



/*****************************************************************************
 *
 * F_IOCtl - Function 0x44:  File, character and disk device I/O control
 *
 *	Last modified	SCC	9 Aug 85
 *
 ******************************************************************************
 */

#if !GEMDOS

/*
 *  bios_dev - 
 *	Array of BIOS device handles.  Used by HXFORM macro
 *	to convert BDOS level handle to BIOS level handle.
 */

int16_t bios_dev[] = { BFHPRN, BFHAUX, BFHCON, BFHCLK, BFHMOU };


ERROR F_IOCtl(P(int) fn, P(FH) h, P(int) n, P(VOIDPTR) buf)
PP(int fn;)
PP(FH h;)
PP(int n;)
PP(VOIDPTR buf;)
{
	register long rv;					/* return value         */
	register OFD *pofd;					/* pointer to OFD       */
	BPB *tmp;

	pofd = 0;
	if ((fn != DREADC) && (fn != DWRITEC) && (fn != REMEDIA))
	{									/* If handle,           */
		if (h >= 0)						/* If file handle,      */
		{
			h = syshnd(h);				/* Resolve it           */
			if ((fn != GETINFO) && (fn != INSTAT) && (fn != OUTSTAT))
				return E_INVFN;		/* check subfunction number */
			pofd = sft[h].f_ofd;		/* Resolve OFD pointer      */
		}
	} else if (!Chk_Drv(&h))	/* 'h' is drive number      */  /* Check for valid drive    */
		return E_DRIVE;

	switch (fn)
	{
	case XCVECTOR:						/* Exchange char vector     */
		return Setexc(HXFORM(h), buf);

	case GETINFO:						/* Get device information   */
		if (h >= 0)						/* For disk file:       */
		{
			/* Init rv with drive number */
			rv = h = pofd->o_dmd->m_drvnum;
			if (!DIOCR(h, 0, 0L))		/* 'or' in CONTROL bit      */
				rv |= Does_IOCtl;
			return rv;
		}

		/* else */ /* For character devices:   */
		rv = Is_Character;

		if (h == H_Null)
		{
			rv |= Is_NUL;
		} else
		{
			if (h == H_Console)
				rv |= Is_Console;
			else if (h == H_Clock)
				rv |= Is_Clock;

			if (!CIOCR(HXFORM(h), 0, 0L))
				rv |= Does_IOCtl;
		}

		return rv;

	case CREADC:						/* Read character control   */
		return CIOCR(HXFORM(h), n, buf);

	case CWRITEC:						/* Write character control  */
		return CIOCW(HXFORM(h), n, buf);

	case DREADC:						/* Read disk control string */
		return DIOCR(h, n, buf);

	case DWRITEC:						/* Write disk control string */
		return DIOCW(h, n, buf);

	case INSTAT:						/* Get input status     */
		if (h < 0)						/* For Character Device:    */
		{
			if (h == H_Null)
				return 0;

			return constat(HXFORM(h));
		}

		/* else fall through to common code for disk files      */

	case OUTSTAT:						/* Get output status        */
		if (h < 0)						/* For Character Device:    */
		{
			if (h == H_Null)
				return 0;

			return Bcostat(HXFORM(h));
		}

		/* else */ /* For disk file:       */
		return pofd->o_bytnum != pofd->o_fileln;

	case REMEDIA:						/* Get removeable media sts */
		tmp = Getbpb(h);

		if (tmp == 0)
			return ERR;
		if (tmp < 0)
			return ((ERROR) tmp);

		return !(tmp->b_flags & B_1FAT);

	default:							/* No function 1, etc. yet. */
		return E_INVFN;
	}
}

/******************************************************************************
 *
 * Chk_Drv - Check drive number
 *
 *	Utility routine used by F_IOCtl
 *
 ******************************************************************************
 */

int Chk_Drv(P(int16_t *) d)
PP(int16_t *d;)
{
	int map;

	*d = *d ? *d - 1 : run->p_curdrv;	/* Resolve drive number     */
	map = Drvmap();

	return map & (1 << *d);			/* Check for existence      */
}


#endif


