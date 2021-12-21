#ifndef	__TIME_H__
#define __TIME_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

typedef long time_t;

struct tm
{
  int tm_sec;			/* Seconds.	[0-60] (1 leap second) */
  int tm_min;			/* Minutes.	[0-59] */
  int tm_hour;			/* Hours.	[0-23] */
  int tm_mday;			/* Day.		[1-31] */
  int tm_mon;			/* Month.	[0-11] */
  int tm_year;			/* Year	- 1900.  */
  int tm_wday;			/* Day of week.	[0-6] */
  int tm_yday;			/* Days in year.[0-365]	*/
  int tm_isdst;			/* DST.		[-1/0/1]*/

  long int tm_gmtoff;		/* Seconds east of UTC.  */
  const char *tm_zone;		/* Timezone abbreviation.  */
};

extern long timezone;
extern int daylight;


VOID tzset PROTO((NOTHING));

time_t time PROTO((time_t *__timer));
time_t mktime PROTO((struct tm *__tp));
struct tm *gmtime PROTO((const time_t *__timer));
struct tm *localtime PROTO((const time_t *__timer));
char *asctime PROTO((const struct tm *__tp));
char *ctime PROTO((const time_t *__timer));

#endif /* __TIME_H__ */
