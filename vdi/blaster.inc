#ifndef B_OFF

/*
 *    Some of Jim Eisenstein's bloody blastman code came in handy here
 *
 *
 *  offsets into the BLASTER register block for the new blit ST
 *
 *  note:  base address = BLASTER+B_OFF
 *
 *	because the SKEW register may be accessed via an
 *	"address register indirect" instruction rather than an
 *	"address register indirect with displacement" instruction,
 *	4 cycles are saved per access
 * tho: too bad that the assembler didn't optimize it lol
 */

#define B_OFF		 60

B_PATTERN	equ	-60 		/* pattern register file */
B_S_NXWD	equ	-28 		/* offset to next src word */
B_S_WRAP	equ	-26 		/* wrap from end of one src line to next */
B_S_ADDR	equ	-24 		/* initial src address */
B_F1_MSK	equ	-20 		/* 1st fringe mask	0:old 1:new */
B_CT_MSK	equ	-18 		/* center mask		0:old 1:new */
B_F2_MSK	equ	-16 		/* 2nd fringe mask	0:old 1:new */
B_D_NXWD	equ	-14 		/* offset to next dst word */
B_D_WRAP	equ	-12 		/* wrap from end of one dst line to next */
B_D_ADDR	equ	-10 		/* initial dst address */
B_D_SPAN	equ	-6 		/* span in words of dst block */
B_HEIGHT	equ	-4 		/* pixel height of block */
B_LOGOP		equ	-2 		/* ctrl word: src^pat combo & logic op # */
B_SKEW		equ	 0		/* ctrl word: flags, pat index & skew */


BF_PAT		equ  	8		/* combo flag: 0:all ones  1:pattern */
BF_SRC		equ  	9		/* combo flag: 0:all ones  1:source */
BM_PAT		equ  	$0100		/* combo mask: 0:all ones  1:pattern */
BM_SRC		equ  	$0200		/* combo mask: 0:all ones  1:source */


BF_GO		equ  	15		/* execution flag        0:false 1:true */
BF_HOG		equ  	14		/* hog dma flag		 0:false 1:true */
BF_SM		equ  	13		/* smudge flag		 0:false 1:true */
BF_PF		equ  	7		/* pre-fetch flag  	 0:false 1:true */
BF_FQ		equ  	6		/* flush queue flag 	 0:false 1:true */
BM_GO		equ  	$8000		/* execution mask */
BM_HOG		equ  	$4000		/* hog dma mask */
BM_SM		equ  	$2000		/* smudge mask */
BM_PF		equ  	$0080		/* pre-fetch mask */
BM_FQ		equ  	$0040		/* flush queue mask */

#endif
