/*	time.c

GEMDOS time and date functions

 */

#include "tos.h"
#include "fs.h"
#include <toserrno.h>
#include "bios.h"


/****************************/
/* Function 0x2A:  Tgetdate */
/****************************/

/* 306de: 00e196a4 */
/* 306us: 00e1964a */
/* 104de: 00fca200 */
int32_t xgetdate(NOTHING)
{
#if !GEMDOS
	date_time(GET_DATE, &date);			/* allow bios to update date */
#endif
	return date;
}


/****************************/
/* Function 0x2B:  Tsetdate */
/****************************/


#define	DAY_BM		0x001F
#define	MTH_BM		0x01E0
#define	YRS_BM		0xFE00

/* 306de: 00e196b4 */
/* 306us: 00e1965a */
/* 104de: 00fca210 */
int32_t xsetdate(P(int16_t) d)
PP(int16_t d;)
{
	register int curmo, day;

	curmo = ((d >> 5) & 0x0F);
	day = d & DAY_BM;

	if ((d >> 9) > 119)					/* Warranty expires 12/31/2099 */
		return ERR;

	if (curmo > 12)						/* 12 months a year */
		return ERR;

	if ((curmo == 2) && !(d & 0x0600))	/* Feb && Leap */
	{
		if (day > 29)
			return ERR;
	} else if (day > nday[curmo])
		return ERR;

	date = d;							/* ok, assign that value to date */
#if GEMDOS
	xbsettime();						/* tell xbios about new date */
#else
	date_time(SET_DATE, &date);			/* tell bios about new date */
#endif

	return E_OK;
}


/****************************/
/* Function 0x2C:  Tgettime */
/****************************/

/* 306de: 00e19732 */
/* 306us: 00e196d8 */
/* 104de: 00fca28e */
int32_t xgettime(NOTHING)
{
#if !GEMDOS
	date_time(GET_TIME, &time);			/* bios may update time if it wishes */
#endif
	return time;
}


/****************************/
/* Function 0x2D:  Tsettime */
/****************************/


/* Bit masks for the various fields in the time variable. */
#define	SEC_BM		0x001F
#define	MIN_BM		0x07E0
#define	HRS_BM		0xF800

/* 306de: 00e19742 */
/* 306us: 00e196e8 */
/* 104de: 00fca29e */
int32_t xsettime(P(int16_t) t)
PP(int16_t t;)
{
	if ((t & SEC_BM) >= 30)
		return ERR;

	if ((t & MIN_BM) >= (60 << 5))		/* 60 max minutes per hour */
		return ERR;

	if ((uint16_t)(t & HRS_BM) >= (uint16_t)(24 << 11))		/* max of 24 hours in a day */
		return ERR;

	time = t;
#if GEMDOS
	xbsettime();						/* tell xbios about new time */
#else
	date_time(SET_TIME, &time);			/* tell bios about new time */
#endif

	return E_OK;
}
