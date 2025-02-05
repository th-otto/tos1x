/*
 * header.h - definitions for the TOS header
 */

#ifndef HEADER_H
#define HEADER_H

/*
 * config.h should define TOSVERSION and COUNTRY
 */
#include "config.h"

/* the year used in copyright notices */
#define COPYRIGHT_YEAR "1991"

/*
 * for our purpose, use the dates from the official ROM versions
 * rather than the actual build date:
 * - OS_DATE: the build date in Binary-Coded Decimal MMDDYYYY
 * - OS_DOSDATE: the build date in GEMDOS format
 */

#if TOSVERSION >= 0x100
#undef OS_DATE
#undef OS_DOSDATE
/* unfortunately, that seems to be different */
#if (OS_COUNTRY == CTRY_US) | (OS_COUNTRY == CTRY_UK)
#define OS_DATE $11201985
#define OS_DOSDATE $0B74
#endif
#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_DK) | (OS_COUNTRY == CTRY_FI) | (OS_COUNTRY == CTRY_SG)
#define OS_DATE $02061986
#define OS_DOSDATE $0C46
#endif
#if (OS_COUNTRY == CTRY_FR)
#define OS_DATE $04241986
#define OS_DOSDATE $0C98
#endif
#endif

#if TOSVERSION >= 0x102
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $04221987
#define OS_DOSDATE $0E96
#endif

#if TOSVERSION >= 0x104
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $04061989
#define OS_DOSDATE $1286
#endif

#if TOSVERSION >= 0x106
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $07291989
#define OS_DOSDATE $12FD
#endif

#if TOSVERSION >= 0x162
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $01011990
#define OS_DOSDATE $1421
#endif

#if TOSVERSION >= 0x205
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $12051990
#define OS_DOSDATE $1585
#endif

#if TOSVERSION >= 0x206
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $11141991
#define OS_DOSDATE $176E
#endif

/* TOS version 2.07 is sparrow version */
#if TOSVERSION >= 0x207
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $02291992
#define OS_DOSDATE $185D
#endif

/* TOS version 2.08 is 2.06 for the ST-book */
#if TOSVERSION >= 0x208
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $03101992
#define OS_DOSDATE $186A
#endif

#if TOSVERSION >= 0x300
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $06161990
#define OS_DOSDATE $14D0
#endif

#if TOSVERSION >= 0x301
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $08291990
#define OS_DOSDATE $151D
#endif

#if TOSVERSION >= 0x305
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $12051990
#define OS_DOSDATE $1585
#endif

#if TOSVERSION >= 0x306
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $09241991
#define OS_DOSDATE $1738
#endif

#if TOSVERSION >= 0x404
#undef OS_DATE
#undef OS_DOSDATE
#define OS_DATE $03081993
#define OS_DOSDATE $1A68
#endif


/* the PAL/NTSC flag */
#if (OS_COUNTRY == CTRY_US)
#define OS_PAL 0
#else
#define OS_PAL 1
#endif

#endif /* HEADER_H */
