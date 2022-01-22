/*
* TIMEFIX DEMONSTRATION
* Copyright 2020, RP Instruments
* Author: Arpad Beszedes
* See LICENSE.TXT for details
*/

#include <stdio.h>
#include <osbind.h>
#include "rptime.h"

const char* Rdays[7] = {
	"Sun",
	"Mon",
	"Tue",
	"Wed",
	"Thu",
	"Fri",
	"Sat"
};

short Rmonths[12] = {
  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

typedef struct {
	unsigned short year;
	unsigned char month;
	unsigned char day;
	unsigned char hour;
	unsigned char min;
	unsigned char sec;	
} PDT;

PDT pdt;

void FixMonthDay(PDT* pdt) {
	if (pdt->year<1980 || pdt->year>2235) return;
	if (pdt->year%4==0 && pdt->year!=2100 && pdt->year!=2200)
		Rmonths[1] = 29;
	else
		Rmonths[1] = 28;
	if (pdt->month<1 || pdt->month>12) return;
	if (pdt->day<29 || pdt->day>31) return;
	if (pdt->day>Rmonths[pdt->month-1])
		pdt->day = Rmonths[pdt->month-1];
}

void ConvertGD(PDT* pdt, unsigned short d, unsigned short t) {
	pdt->day = d&0x1F;
	d >>= 5;
	pdt->month = d&0xF;
	d >>= 4;
	pdt->year = (d&0x7F) + 1980;
	pdt->sec = (t&0x1F) * 2;
	t >>= 5;
	pdt->min = t&0x3F;
	t >>= 6;
	pdt->hour = t&0x1F;	
}

void ConvertXB(PDT* pdt, unsigned long dt) {
	unsigned short t, d;

	t = dt&0xFFFF;
	dt >>= 16;
	d = dt&0xFFFF;
	ConvertGD(pdt, d, t);
}

void ConvertRP(PDT* pdt, const RPT* rpt) {
	pdt->year = rpt->year + 1980;
	pdt->month = rpt->month;
	pdt->day = rpt->day;
	pdt->hour = rpt->hour;
	pdt->min = rpt->min;
	pdt->sec = rpt->sec;	
}

unsigned long ConvertToPacked(const PDT* pdt) {
	unsigned long p;
	unsigned char y;

	p = 0;
	y = pdt->year-1980;
	if (y>119)
		y=119;
	p |= y;
	p <<= 4;
	p |= pdt->month;
	p <<= 5;
	p |= pdt->day;
	p <<= 5;
	p |= pdt->hour;
	p <<= 6;
	p |= pdt->min;
	p <<= 5;
	p |= pdt->sec/2;
	
	return p;
}

void SetAllTimes(const PDT* pdt, int bd, int bt) {
	unsigned long packed;
	unsigned long xb;
	RPT* rpt;

	packed = ConvertToPacked(pdt);
	if (bd)
		Tsetdate(packed>>16);
	if (bt)
		Tsettime(packed&0xFFFF);
	
	xb = Gettime();
 	if (bd) {
		xb &= 0xFFFF;
		xb |= (packed&0xFFFF0000);
	}
	if (bt) {
		xb &= 0xFFFF0000;
		xb |= (packed&0xFFFF);
	}	
	Settime(xb);	
	
	if (!Rcheck()) {
		rpt = Rgettime();
		if (bd) {
			rpt->year = pdt->year-1980;
			rpt->month = pdt->month;
			rpt->day = pdt->day;
		}
		if (bt) {
			rpt->hour = pdt->hour;
			rpt->min = pdt->min;
			rpt->sec = pdt->sec;
		}
		Rsettime(rpt);
	}	
}

void SetDate() {
	int n;
	int c;
	unsigned short sh;

	printf("\nSet date (Return to skip)\n");
	if (!Rcheck())
		ConvertRP(&pdt, Rgettime());
	else
		ConvertGD(&pdt, Tgetdate(), Tgettime());

	printf("Year:  ");
	if ((c=getc(stdin))!='\n') {
		ungetc(c,stdin);
		n = fscanf(stdin,"%hd%*c", &sh);
		if (n!=1)
			while(getc(stdin)!='\n') ;
		else
			if (sh>1979 && sh<2236)
				pdt.year=sh;
	}
	printf("\x1BI\x1BlYear:  %4d\n",pdt.year);
	
	printf("Month: ");
	if ((c=getc(stdin))!='\n') {
		ungetc(c,stdin);
		n = fscanf(stdin,"%hd%*c", &sh);
		if (n!=1)
			while(getc(stdin)!='\n') ;
		else
			if (sh>0 && sh<13)
				pdt.month=sh;
	}
	printf("\x1BI\x1BlMonth: %2.2d\n",pdt.month);
	
	printf("Day:   ");
	if ((c=getc(stdin))!='\n') {
		ungetc(c,stdin);
		n = fscanf(stdin,"%hd%*c", &sh);
		if (n!=1)
			while(getc(stdin)!='\n') ;
		else
			if (sh>0 && sh<32) {
				pdt.day=sh;
				FixMonthDay(&pdt);
			}
	}
	printf("\x1BI\x1BlDay:   %2.2d\n",pdt.day);
	
	printf("Esc to cancel, any other key to set...");
	while(!kbhit()) ;
	if (getch()!=27)
		SetAllTimes(&pdt, 1, 0);		
}

void SetTime() {
	int n;
	int c;
	unsigned short sh;

	printf("\nSet time (Return to skip)\n");
	if (!Rcheck())
		ConvertRP(&pdt, Rgettime());
	else
		ConvertGD(&pdt, Tgetdate(), Tgettime());

	printf("Hour:  ");
	if ((c=getc(stdin))!='\n') {
		ungetc(c,stdin);
		n = fscanf(stdin,"%hd%*c", &sh);
		if (n!=1)
			while(getc(stdin)!='\n') ;
		else
			if (sh>=0 && sh<=23)
				pdt.hour=sh;
	}
	printf("\x1BI\x1BlHour:  %2.2d\n",pdt.hour);
	
	printf("Min:   ");
	if ((c=getc(stdin))!='\n') {
		ungetc(c,stdin);
		n = fscanf(stdin,"%hd%*c", &sh);
		if (n!=1)
			while(getc(stdin)!='\n') ;
		else
			if (sh>=0 && sh<=59)
				pdt.min=sh;
	}
	printf("\x1BI\x1BlMin:   %2.2d\n",pdt.min);
	
	printf("Sec:   ");
	if ((c=getc(stdin))!='\n') {
		ungetc(c,stdin);
		n = fscanf(stdin,"%hd%*c", &sh);
		if (n!=1)
			while(getc(stdin)!='\n') ;
		else
			if (sh>=0 && sh<=59)
				pdt.sec=sh;
	}
	printf("\x1BI\x1BlSec:   %2.2d\n",pdt.sec);
	
	printf("Esc to cancel, any other key to set...");
	while(!kbhit()) ;
	if (getch()!=27)
		SetAllTimes(&pdt, 0, 1);		
}

int main() {
	int c;

	printf("\x1B""E\n\n");	
	printf("\x1Bp TIMEFIX Demonstration \x1Bq\n");
	printf("   Copyright \xBD 2020, RP Instruments\n\n");

	printf("\x1BpEsc\x1Bq-exit, \x1Bpd\x1Bq-set date, \x1Bpt\x1Bq-set time...\n\n");
	c=0;
	while (!kbhit() || (c=getch())!=27) {
		ConvertGD(&pdt, Tgetdate(), Tgettime());
		printf("GEMDOS:      %4d.%2.2d.%2.2d %2.2d:%2.2d:%2.2d\n", pdt.year, pdt.month, pdt.day, pdt.hour, pdt.min, pdt.sec);
	
		ConvertXB(&pdt, Gettime());
		printf("IKBD:        %4d.%2.2d.%2.2d %2.2d:%2.2d:%2.2d\n", pdt.year, pdt.month, pdt.day, pdt.hour, pdt.min, pdt.sec);
		
		if (!Rcheck()) {
			ConvertRP(&pdt, Rgettime());
			printf("RPI:    %s, %4d.%2.2d.%2.2d %2.2d:%2.2d:%2.2d\n", Rdays[Rdayweek()], pdt.year, pdt.month, pdt.day, pdt.hour, pdt.min, pdt.sec);
		}
		else {
			printf("RPI:         <not installed>\n");
		}
		if (c=='t') {
			printf("\x1Bj\x1B""e");
			SetTime();
			printf("\x1Bk\x1BJ\x1B""f");
			c=0;
		}		
		else if (c=='d') {
			printf("\x1Bj\x1B""e");
			SetDate();
			printf("\x1Bk\x1BJ\x1B""f");
			c=0;
		}		
		printf("\x1BI\x1BI\x1BI");	
	}
	printf("\n\n");
	return 0;
}
