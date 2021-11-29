#include <portab.h>
#include <toserrno.h>

#define MEDIANOCHANGE   0              /*  media def has not changed   */
#define MEDIAMAYCHANGE  1              /*  media may have changed      */
#define MEDIACHANGE     2              /*  media def has changed       */

extern BYTE drv_stat[2];    /* 306: 0x17CE; 404: 0x1682 */
extern LONG  drv_clock[2];   /* 306: 0x17D0; 404: 0x1684 */
extern BYTE flop_stat[2];   /* 306: 0x5B86; 404: 0x8896 */
extern LONG flp_next_check;  /* 306: 0x5B7A; 404: 0x8892 */
extern LONG _frclock; /* 0x466 */

WORD CDECL bios_hdv_mediach(P(WORD, dev))
PP(WORD, dev;)
{
	register WORD unit;
	register BYTE *stat;
	
	if (dev >= 2)
		return E_UNDEV;
	unit = dev;
	stat = &flop_stat[unit];
	if (*stat == MEDIACHANGE)
		return MEDIACHANGE;
	if (*(drv_stat + unit) != 0)
		*stat = MEDIAMAYCHANGE;
	if (_frclock - drv_clock[unit] < flp_next_check)
		return MEDIANOCHANGE;
	return *stat;
}


/*
bios_hdv_mediach:
[00e058ae] 4e56 0000                 link      a6,#$0000
[00e058b2] 48e7 0304                 movem.l   d6-d7/a5,-(a7)
[00e058b6] 0c6e 0002 0008            cmpi.w    #$0002,8(a6)
[00e058bc] 6d04                      blt.s     $00E058C2
[00e058be] 70f1                      moveq.l   #-15,d0 ; E_UNDEV
[00e058c0] 604c                      bra.s     $00E0590E
[00e058c2] 3e2e 0008                 move.w    8(a6),d7
[00e058c6] 3a47                      move.w    d7,a5
[00e058c8] dbfc 0000 5b86            adda.l    #$00005B86,a5
[00e058ce] 0c15 0002                 cmpi.b    #$02,(a5)
[00e058d2] 6604                      bne.s     $00E058D8
[00e058d4] 7002                      moveq.l   #2,d0
[00e058d6] 6036                      bra.s     $00E0590E
[00e058d8] 207c 0000 17ce            move.l    #$000017CE,a0
[00e058de] 4a30 7000                 tst.b     0(a0,d7.w)
[00e058e2] 6704                      beq.s     $00E058E8
[00e058e4] 1abc 0001                 move.b    #$01,(a5)
[00e058e8] 2039 0000 0466            move.l    $00000466,d0
[00e058ee] 3247                      move.w    d7,a1
[00e058f0] d3c9                      adda.l    a1,a1
[00e058f2] d3c9                      adda.l    a1,a1
[00e058f4] d3fc 0000 17d0            adda.l    #$000017D0,a1
[00e058fa] 2211                      move.l    (a1),d1
[00e058fc] 9081                      sub.l     d1,d0
[00e058fe] b0b9 0000 5b7a            cmp.l     $00005B7A,d0
[00e05904] 6c04                      bge.s     $00E0590A
[00e05906] 4240                      clr.w     d0
[00e05908] 6004                      bra.s     $00E0590E
[00e0590a] 1015                      move.b    (a5),d0
[00e0590c] 4880                      ext.w     d0
[00e0590e] 4a9f                      tst.l     (a7)+
[00e05910] 4cdf 2080                 movem.l   (a7)+,d7/a5
[00e05914] 4e5e                      unlk      a6
[00e05916] 4e75                      rts       
 */
