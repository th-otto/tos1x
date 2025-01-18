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
/* 100fr: 00fc9bda */
int32_t xgetdate(NOTHING)
{
#if !GEMDOS
	date_time(GET_DATE, &date);			/* allow bios to update date */
#endif
	return (int16_t)date; /* BUG: sign extended */
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
/* 100fr: 00fc9bea */
int32_t xsetdate(P(int16_t) _d)
PP(int16_t _d;)
{
	register int curmo, day;
	register int16_t d;
	
	d = _d;
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
#if TOSVERSION >= 0x102
	xbsettime();						/* tell xbios about new date */
#endif
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
/* 100fr: 00fc9c5c */
int32_t xgettime(NOTHING)
{
#if !GEMDOS
	date_time(GET_TIME, &time);			/* bios may update time if it wishes */
#endif
	return (int16_t)time; /* BUG: sign extended */
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
/* 100fr: 00fc9c6c */
int32_t xsettime(P(int16_t) t)
PP(register int16_t t;)
{
	if ((t & SEC_BM) >= 30)
		return ERR;

	if ((t & MIN_BM) >= (60 << 5))		/* 60 max minutes per hour */
		return ERR;

	if ((int16_t)(t & HRS_BM) >= (int32_t)(24 << 11))		/* max of 24 hours in a day */
		return ERR;

	time = t;
#if GEMDOS
#if TOSVERSION >= 0x102
	xbsettime();						/* tell xbios about new time */
#endif
#else
	date_time(SET_TIME, &time);			/* tell bios about new time */
#endif

	return E_OK;
}
