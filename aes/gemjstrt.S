/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:24:52 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:24:52  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:28:00  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.7  88/10/10  18:36:19  kbad
 * left out xdef declaration for gemstart label.  Urk.
 * 
 * Revision 1.6  88/09/20  12:39:21  kbad
 * Added gemstart: label for start of AES (for new partial-link build)
 * 
 * Revision 1.5  88/09/09  17:09:01  kbad
 * Added environment setting compatibility mode
 * 
 * Revision 1.3  88/07/29  16:14:37  kbad
 * Added conditional assembly for `dowarn'
 * 
 * Revision 1.2  88/07/15  16:08:13  mui
 * initialize dowarn flag
 * 
 * Revision 1.1  88/06/02  12:34:22  lozben
 * Initial revision
 * 
 *************************************************************************
 *	GEMSTART.S	9/29/84 - 05/07/85	Lowell Webster
 *	Ram based system	04/30/85	Derek Mui
 *	Added one more variable diskin  08/28/85	Derek Mui
 *	Clear sh_rom to read cart once only	7/1/86	Derek Mui
 *	Take out sh_rom				7/2/86	Derek Mui
 *	Init the g_wsend 			3/11/87	Derek Mui
 *	Added autoexec				12/23/87 D.Mui
 *	Clean up				1/14/88	 D.Mui
 *	Take out s_menu		1/28/88			D.Mui
 *	Crunch			2/3/88		D.Mui
 *	Take out sh_up		2/11/88		D.Mui
 *	Take out gl_respref	2/25/88		D.Mui
 *	Take out system_acc	3/15/88		D.Mui
 *	initalize sh variables	04/29/88	D.Mui
 *       Start up aes/desktop as process
 *	fix Super calls at startup		900702 kbad
 *	Add GEMDOS version check for Pexec 7	900719 kbad
 * 	assemble with MAS 900801 kbad
 *	Change the uda_size	7/16/92		D.Mui
 *	Added default res for sparrow 7/21/92	D.Mui
 */

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

	text

uda_size	equ	74+4*STACK_SIZE
/* 0 relative */
/* BUG: init_size is not quite right, it should point to uda.u_supstk, which is -4 from end of structure,
   but harmless because only memory below that is accessed.
   Most likely wrong port from x86 version where u_supstk is 2 bytes
*/
init_size	equ	uda_size
fsize		equ	100		* size of linef handler in bytes+ a little fat




/*
 *
 *  Must be first object file in link statement
 *
 *	Do setblock call to free up memory
 */
/* 104de: 00fd3b8e */
/* 106de: 00e13dee */
/* 100de: 00fd8e98 */
	xdef	_gemstart
_gemstart:
	move.l	a7,a5		/* save stack */
	move.l	#ustak+128,a7	/* switch stacks, dos needs a user stack  */
	move.l	4(a5),a5	/* basepage address */
#if 0
	or.l	#7,$28(a5)	/* prgflags in basepage */
#endif
	move.l	12(a5),d0	/* textlen */
	add.l	20(a5),d0	/* datalen */
	add.l	28(a5),d0	/* bsslen */
	add.l	#$100,d0	/* skip los pageos baseos */
	move.l	d0,-(a7)	/* size */
	move.l	a5,-(a7)	/* basepage */
	move	d0,-(a7)	/* junk word */
	move	#$4a,-(a7)	/* Mshrink */
	trap	#1
	adda.l	#12,a7

	move.l	a7,-(a7)	/* use same stacks for now */
	move.w	#32,-(a7)	/* drdos get sup mode */
	trap	#1
	addq	#6,a7

	move.l	44(a5),_ad_envrn		/* save the environment pointer */
	move.w	#0,_gl_rschange		/* Clear out resolution globals */
	move.w	#1,_gl_restype
	move.w	#1,_gl_nextrez
	move.l  #0,_xxaddr

#if DOWARNING
	clr.w	_dowarn			/* This variable may or may not exist */
#endif
/*
 *		 LINE "F"
 */
#if LINEF_HACK
	move.b	ABSW2($2c),d0
	beq	nolinef		/* linef vector already installed */
	move.l	#fsize,-(a7)
	move.w	#$48,-(a7)
	trap	#1		/* dos_allocate */
	addq.l	#6,a7
	movea.l	d0,a0
	move.w	#((fsize/2)-1),d1
	movea.l	#linefhandler,a1
lop:
	move.w	(a1)+,(a0)+	/* move linef code to ram */
	dbf	d1,lop
	move.l	d0,ABSW2($2c)		/* install ram linef vector */
nolinef:
	nop
#endif

	jsr _rsc_read       /* read in resource */
	move.w  #1,_diskin	/* added 08/28/85 */


/*	bra begin */

begin:

	jsr	_size_theglo	/* returns sizeof(THEGLO) in words */
	move.l	#_D,a0		/* zero out static unitialized data */
	clr.l	d1

beg1:
	move.w	d1,(a0)+
	dbmi.w	d0,beg1		/* THIS MUST BE CHANGED TO DBRA!!! */

	lea		_justretf,a0	/* initialize some bss pointers */
	move.l	a0,_drwaddr
	lea		_tikcod,a0
	move.l	a0,_tikaddr
	lea		_far_draw,a0
	move.l	a0,_drawaddr

/* initialize first stack pointer in first uda */

	move.l	#_D,a6		/* base of uda */
	move.l	a6,a5
	adda.l	#init_size,a6	/* add sizeof uda */
	move.l	a6,62(a5)	/* initialize stack pointer in uda */
	move.l	a6,a7

	jsr	_gem_main

/*
 * never get here
 */

	bra	begin		/* forever */


/* 306de: 00e19916 */
	xdef	_trap
_trap:	
	move.l	(sp)+,retsava
	move.w	#0,_DOS_ERR
	move.w	#0,_DOS_AX
	trap	#1
	move.w  d0,_DOS_AX	/* set return code ( error proc only ) */
	cmp.l	#0,d0		/* be careful ! */
	bge 	oktrap
	move.w	#1,_DOS_ERR

oktrap:
	move.l	retsava,-(sp)
	rts

	bss

	xdef retsava
	comm retsava,4

/* screen resolution 1=default, 2=320x200, 3=640x200, 4=640x400 */

	xdef	_gl_restype
	comm	_gl_restype,2
	xdef	_gl_rschange
	comm	_gl_rschange,2
	xdef	_gl_nextrez
	comm	_gl_nextrez,2
	xdef ustak
	comm ustak,132
	xdef	_diskin		/* added 08/2/8/85 */
	comm _diskin,2	/* added */
	xdef _xxaddr
	comm _xxaddr,4
