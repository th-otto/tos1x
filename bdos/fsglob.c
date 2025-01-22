/*  fsglob.c - global variables for the file system			*/

#include "tos.h"
#include "fs.h"
#include "bios.h"

/*
 *  drvtbl -
 */

DMD *drvtbl[BLKDEVNUM];


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
