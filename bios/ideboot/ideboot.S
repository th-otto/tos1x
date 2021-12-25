/*
 *
 * IDE Autoboot for TOS 1.04, 1.06, 1.62 : Allows TOS to boot from IDE master 0.
 * Code to be compiled with GNU as and patched into TOS ROMs with TOSPatch.
 *
 * Copyright (c) 2020-2021, Christian Zietz <czietz@gmx.net>
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *
 * NOTE: The license only applies to this code. Patched TOS ROMs containing this
 * code are still subject to copyright by Atari and MUST NOT be distributed!
 *
 */

#include "config.h"


#define IDEDATA		(A2)
#define FEATURES	0x5(A2)
#define	SECTORCNT	0x9(A2)
#define SECTORNO	0xD(A2)
#define CYLLOW		0x11(A2)
#define CYLHIGH		0x15(A2)
#define HEAD		0x19(A2)
#define CMDSTAT		0x1D(A2)
#define IDECONTROL	0x39(A2)

#define hz200		0x4BA.w
#define diskbuf		0x4C6.w

#define LBAMODE		(1<<6)
#define READ_SECTOR	0x20
#define DRQ			3

#define DMAr		0x444D4172
#define EUNDEV		-15

/* TEST code */
#ifdef TEST
_START:
	pea		ideboot(PC)
	move.w	#38,-(SP)
	trap	#14
	addq.l	#6,SP
	move.w	#0,-(SP)
	trap	#1
#endif


/* Provides implementation of XBIOS call #42, DMAread.
 * Only supports device 16 (=IDE master 0).
 * To be hooked at address HOOK3
 */
dmaread:
	moveq	#EUNDEV,D0
	cmp.w	#16,14(SP)	/* IDE device 0 */
	bne.s	doreadout

doread1:
	move.l	4(SP),D3	/* Sector no */
	move.w	8(SP),D4	/* Count */
	move.l	10(SP),A0	/* Buffer */
	subq	#1,D4		/* Because of DBRA */
doread2:
	move.l	D3,D0
	bsr.s	ideread
	bne.s	doreadout
	addq	#1,D3		/* Next sector */
	dbra	D4,doread2
doreadout:
	/* D0 = 0 if everything was OK */
	/* D0 = -1 (ERROR, unspecifed) if there was an error in ideread */
	rts


/* Try to boot from IDE device 0.
 */
ideboot:
	move.l	diskbuf,A0
	moveq	#0,D0	/* root sector */
	bsr.s	ideread
	bne.s	noboot	/* ideread also sets condition codes */
	cmp.w	#0x1234,D1
	bne.s	noboot

	move.l	diskbuf,A0
	move.l	#DMAr,D3
	moveq	#16,D4	/* IDE device 0 */
	moveq	#0,D5	/* bootpref */
	jsr		(A0)
noboot:
	rts


/* Read one sector from IDE device 0
 * Input: Sector no. in D0, buffer address in A0
 * Output: Status in D0 (and condition codes), checksum in D1
 * Modifies: D0,D1,D2,A0,A1,A2 (A0 points to end of buffer on return)
 */
ideread:
	lea		0xFFF00000,A2

	/* check for IDE */
	move.l	0x8.w,D1		/* old bus error */
	lea		berr(PC),A1
	move.l	A1,0x8.w
	move.l	SP,A1
	tst.w	(A2)
	move.l	D1,0x8.w
	
	/* select device and wait for DRDY */
	move.l	hz200,D1
	add.l	#100,D1
	move.b	#0,HEAD
	clr.b	IDECONTROL
waitdrdy:
	move.b	CMDSTAT,D2
	and.b	#0xC9,D2
	cmp.b	#0x40,D2
	beq.s	ready
	cmp.l	hz200,D1
	bpl.s	waitdrdy
	bra.s	errout

ready:
	/* setup IDE registers */
	move.b	#1,SECTORCNT	/* one sector */
	move.b	D0,SECTORNO
	lsr.l	#8,D0
	move.b	D0,CYLLOW
	lsr.l	#8,D0
	move.b	D0,CYLHIGH
	move.b	#LBAMODE,HEAD	/* device 0, LBA mode */
	move.b	#READ_SECTOR,CMDSTAT

	/* wait for DRQ */
	move.l	hz200,D1
	add.l	#400,D1
waitdrq:
	btst	#DRQ,CMDSTAT
	bne.s	readsect
	cmp.l	hz200,D1
	bpl.s	waitdrq
	bra.s	errout

berr:
	/* bus error: no IDE interface */
	move.l	D1,0x8.w
	move.l	A1,SP
errout:
	moveq	#-1,D0
okout:
	rts

	/* read a sector, calculating checksum in D1 */
readsect:
	clr.w	D1
	moveq	#127,D2
readnext:
	move.w	IDEDATA,D0
	add.w	D0,D1
	move.w	D0,(A0)+
	move.w	IDEDATA,D0
	add.w	D0,D1
	move.w	D0,(A0)+
	dbra	D2,readnext
	moveq	#0,D0
	bra.s	okout

