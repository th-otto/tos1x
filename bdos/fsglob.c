/*  fsglob.c - global variables for the file system			*/

#include "tos.h"
#include "fs.h"
#include "bios.h"

/*
 *  drvtbl -
 */

DMD *drvtbl[BLKDEVNUM];


/*
 *  logmsk -
 *	log values of:
 *        1, 2, 4, 8, 16, 32, 64, 128  256, 512, 1024, 2048 ... 
 */

int16_t const logmsk[] = { 0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047,
	4095, 8191, 16383, 32767
};


/*
 *  sft -
 */

FTAB sft[OPNFILES - NUMSTD];


/*
 *  rwerr -  hard error number currently in progress 
 */

ERROR rwerr;

/*
 *  errdrv -  drive on which error occurred 
 */

int16_t errdrv;


/*
 *  time - , date - who knows why this is here?
 */

uint16_t time, date;
