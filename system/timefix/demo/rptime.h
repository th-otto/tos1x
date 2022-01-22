/*
* RPTIME.H: TIMEFIX C interface header
* Copyright 2020, RP Instruments
* Author: Arpad Beszedes
* See LICENSE.TXT for details
*/

#ifndef _RPTIME_H
#define _RPTIME_H

typedef struct {
	unsigned char year;   /* 0-255, 0 means 1980 */
	unsigned char month;  /* 1-12 */
	unsigned char day;    /* 1-[28,29,30,31] depending on month */
	unsigned char hour;   /* 0-24 */
	unsigned char min;    /* 0-59 */
	unsigned char sec;    /* 0-59 */
} RPT;

/* Data is copied from the parameter to the internal structure */
void Rsettime(RPT*);

/* Returns pointer to the internal structure */
RPT* Rgettime(void);

/* Returns 0-6 where 0 means Sunday */
short Rdayweek(void);

/* Returns 0 if TIMEFIX is installed */
int Rcheck(void);

#endif
