/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:19:44 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:19:44  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:23:45  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:30:25  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	DOS.H		4/18/84 - 9/07/84	Lee Lorenzen		*/

#define STDIN  0x0000
#define STDOUT 0x0001
#define STDERR 0x0002
#define STDAUX 0x0003
#define STDPRN 0x0004

/*
 *  PC/DOS Error Codes
 */
#define E_BADFUNC 1
#define E_FILENOTFND 2
#define E_PATHNOTFND 3
#define E_NOHANDLES 4
#define E_NOACCESS 5
#define E_BADHANDLE 6
#define E_MEMBLKERR 7
#define E_NOMEMORY 8
#define E_BADMEMBLK 9
#define E_BADENVIR 10
#define E_BADFORMAT 11
#define E_BADACCESS 12
#define E_BADDATA 13
#define E_BADDRIVE 15
#define E_NODELDIR 16
#define E_NOTDEVICE 17
#define E_NOFILES 18

#define F_RDONLY 0x01
#define F_HIDDEN 0x02
#define F_SYSTEM 0x04
#define F_VOLUME 0x08
#define F_SUBDIR 0x10
#define F_ARCHIVE 0x20

#define F_GETMOD 0x0
#define F_SETMOD 0x1


/*
 * GEMDOS error codes
 */
/* Access denied */
#define E_ACCDN  -36
/* No more files: Fsfirst/Fsnext */
#define E_NMFIL  -49
/* File not found */
#define E_FILNF  -33

#ifndef __ASSEMBLER__
typedef struct exec_blk
{
	int16_t		eb_segenv;
	int32_t		eb_pcmdln;
	int32_t		eb_pfcb1;
	int32_t		eb_pfcb2;
} EXEC_BLK;


typedef struct over_blk
{
	int16_t		ob_seglod;
	int16_t		ob_relfac;
} OVER_BLK;
#endif
