/*  proc.c - process management routines				*/
/*  xexec, xterm, x0term, xtermres					*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>
#include "btools.h"
#include "pghdr.h"

#define	DBGPROC	0


/*
 *  run - ptr to PD for current process
 */

PD *run;


/*
 *  supstk - common sup stack for all procs  
 */

int16_t supstk[SUPSIZ];


/*
 *  bakbuf - longjump buffer
 */

xjmp_buf bakbuf;


