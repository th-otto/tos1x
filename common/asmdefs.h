/*
 * asmdefs.h - definitions to include in top of all assembler files
 *
 * Copyright (C) 2001-2015 The EmuTOS development team
 *
 * Authors:
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

/* this symbol will be defined in all ASM source.
 * use it to filter out definitions that would generate syntax
 * errors in asm.
 */
#define ASM_SOURCE

/* generate constants for opcodes that are 68010 and above */
#define CCR_D0        dc.w $42c0            /* move.w ccr,d0 68010-68060 */

#define CACR_Dn(r)    dc.l $4e7a0002+(r<<12)   /* movec cacr,dn 68020-68060 */
#define CACR_D0 CACR_Dn(0)
#define CACR_D1 CACR_Dn(1)
#define CACR_D2 CACR_Dn(2)
#define CACR_D3 CACR_Dn(3)
#define CACR_D4 CACR_Dn(4)
#define CACR_D5 CACR_Dn(5)
#define CACR_D6 CACR_Dn(6)
#define CACR_D7 CACR_Dn(7)

#define PCR_D0        dc.l $4e7a0808        /* movec pcr,d0 68060 */
#define PCR_D1        dc.l $4e7a1808        /* movec pcr,d1 68060 */

#define Dn_CACR(r)    dc.l $4e7b0002+(r<<12)        /* movec dn,cacr 68020-68060 */
#define D0_CACR       Dn_CACR(0)
#define D1_CACR       Dn_CACR(1)
#define D2_CACR       Dn_CACR(2)
#define D3_CACR       Dn_CACR(3)
#define D4_CACR       Dn_CACR(4)
#define D5_CACR       Dn_CACR(5)
#define D6_CACR       Dn_CACR(6)
#define D7_CACR       Dn_CACR(7)

#define D0_VBR        dc.l $4e7b0801        /* movec d0,vbr 68010-68060 */
#define D0_CAAR       dc.l $4e7b0802        /* movec d0,caar 68020-68030 */
#define D0_PCR        dc.l $4e7b0808        /* movec d0,pcr 68060 */

#define D0_TC         dc.l $4e7b0003        /* movec d0,tc 68040-68060 (except 68ec040) */
#define D0_ITT0       dc.l $4e7b0004        /* movec d0,itt0 68040-68060 */
#define D0_ITT1       dc.l $4e7b0005        /* movec d0,itt1 68040-68060 */
#define D0_DTT0       dc.l $4e7b0006        /* movec d0,dtt0 68040-68060 */
#define D0_DTT1       dc.l $4e7b0007        /* movec d0,dtt1 68040-68060 */

#define FROM_TC(addr) dc.l $f0394200,addr   /* pmove tc,addr 68030 (except 68ec030) */

#define TO_TC(addr)   dc.l $f0394000,addr   /* pmove addr,tc 68030 (except 68ec030) */
#define TO_CRP(addr)  dc.l $f0394c00,addr   /* pmove addr,crp 68030 (except 68ec030) */
#define TO_TTR0(addr) dc.l $f0390800,addr   /* pmove addr,ttr0 68030 */
#define TO_TTR1(addr) dc.l $f0390c00,addr   /* pmove addr,ttr1 68030 */

#define TO_TC_A0      dc.l $f0104000        /* pmove (a0),tc */
#define TO_TTR0_A0    dc.l $f0100800        /* pmove (a0),ttr0 */
#define TO_TTR1_A0    dc.l $f0100c00        /* pmove (a0),ttr1 */

#define FNOP                dc.l $f2800000        /* 6888X, 68040-68060 */
#define FSAVE_MINUS_SP      dc.w $f327            /* 6888X, 68040-68060 */
#define FRESTINC            dc.w $f35f            /* frestore (a7)+ 6888X, 68040-68060 */
#define FRESTSP             dc.w $f357            /* frestore (a7) 6888X, 68040-68060 */
#define FRESTORE(addr)      dc.w $f379 \
                            dc.l addr             /* frestore addr 6888X, 68040-68060 */ 

#define FP0_D0              dc.l $f2006000        /* fmove.l fp0,d0 6888X, 68040-68060 */
#define D0_FP0              dc.l $f2004000        /* fmove.l d0,fp0 6888X, 68040-68060 */

#define CINVA_IC            dc.w $f498            /* 68040 */

/*
 * set to 1 if we run on plain 68k only
 */
#define P68000  (TOSVERSION < 0x200)

/*
 * set to 1 if we are on a 68010+ with 8-byte trap exception frames.
 * This will produce slightly better code in the gemdos dispatcher,
 * but won't run on 68000.
 * If 0, _longframe will be checked at runtime.
 */
#define P68010  (TOSVERSION >= 0x300)

/*
 * outcome of the above 2:
 * TOS 1.x: does no checks, and assumes short exception frames
 * TOS 2.x: checks at runtime
 * TOS 3.x: does no checks, and assumes long exception frames
 */

/*
 * set to 1 if we are on a 68030+ (else 0)
 * Used when invalidating caches might be neccessary
 */
#define P68030  0


#if TOSVERSION < 0x200
#	define ABSW(x) x(a5)
#	define ABSW2(x) x
#   define SETBASEREG suba.l    a5,a5
#else
#	define ABSW(x) (x).w
#	define ABSW2(x) (x).w
#   define SETBASEREG
#endif
