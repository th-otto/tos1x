#include "config.h"
#include "asmdefs.h"
#include "tosvars.inc"
#include "biosdefs.h"

#	undef ABSW
#	undef ABSW2
#	undef SETBASEREG
#	define ABSW(x) x(a1)
#	define ABSW2(x) x
#   define SETBASEREG suba.l    a1,a1

nvram_rtc_year_offset equ 1980-1968

        xdef ngetdt
        xdef readRTCTime
        xdef writeRTCTime
        xdef checkRTC

        text

/* NVRAM_ADDR_REG  equ $ffff8961 */
/* NVRAM_DATA_REG  equ $ffff8963 */

rtc_sec         equ $fffffc20


#if MSTECLK

/* 206de: 00e01a96 */
/* 104de: 00fc1f4c */
/* 106de: 00e02124 */
ngetdt: bsr.s     checkRTC
        bcs.s     ngetdt2
#if TP_77
        bsr       readRTCTime
#else
        bsr.s     readRTCTime
#endif
        cmp.l     #-1,d0
        beq.s     ngetdt2
		move.w    d0,_time
		swap      d0
		move.w    d0,_date
        moveq     #0,d0
        rts
ngetdt2:
        moveq     #-1,d0
        rts

/* 206de: 00e01aa8 */
/* 104de: 00fc1f70 */
#if TP_77 /* CT_CLOCK */
#include "../tospatch/patches/ctuhrdrv.S"
#else
checkRTC:
#if TP_76 /* ALARM */
#include "../tospatch/patches/uhrpatch.S"
#else
			SETBASEREG
			movea.w   #rtc_sec,a0
            move.l    ABSW(_buserror),d2
            movea.l   sp,a2
            move.l    #chkRTC2,ABSW(_buserror)
            move.b    #9,27(a0) /* select bank 1 */

            move.l    d2,ABSW(_buserror)
            move.w    #$a05,d0 /* write to alarm time minutes */
            movep.w   d0,5(a0)
            movep.w   5(a0),d1 /* read value back */
            and.w     #$f0f,d1
            cmp.w     d0,d1    /* value ok? */
            bne.s     chkRTC3  /* no -> */
            move.b    #1,1(a0) /* set output frequency */
            move.b    #8,27(a0) /* select bank 0 */
            move.b    #0,29(a0) /* clear test register */
            rts
chkRTC2:    movea.l   a2,sp
            move.l    d2,ABSW(_buserror)
chkRTC3:    ori       #1,ccr                    /* RTC not available */
            rts
#endif /* TP_76 */

/* 206de: 00e01af8 */
readRTCTime:bsr.s     checkRTC
            bcs       rdRTCErr
            lea       ABSW2(rtcbufa),a1
            lea       ABSW2(rtcbufb),a2
            bsr       rdRTCMask /* read all values to rtcbufa */
rdRTC2:     exg       a1,a2
            bsr       rdRTCMask /* read all values to rtcbufb */
            moveq     #13-1,d0
rdRTC3:     move.b    (a1,d0.w),d1
            cmp.b     (a2,d0.w),d1
            bne.s     rdRTC2
            dbra      d0,rdRTC3
            moveq     #0,d0
            move.b    11(a1),d0 /* get seconds, tens */
            mulu.w    #10,d0
            add.b     12(a1),d0 /* add seconds, units */
            asr.w     #1,d0     /* shift into place for GEMDOS format */
            move.w    d0,d1
            moveq     #0,d0
            move.b    9(a1),d0  /* get minutes, tens */
            mulu.w    #10,d0
            add.b     10(a1),d0 /* add minutes, units */
            asl.w     #5,d0     /* shift into place for GEMDOS format */
            add.w     d0,d1
            moveq     #0,d0
            move.b    7(a1),d0  /* get hours, tens */
            mulu.w    #10,d0
            add.b     8(a1),d0  /* add hours, units */
            asl.w     #8,d0     /* shift into place for GEMDOS format */
            asl.w     #3,d0
            add.w     d0,d1
            swap      d1        /* save time in upper word */
            moveq     #0,d0
            move.b    4(a1),d0  /* get day, tens */
            mulu.w    #10,d0
            add.b     5(a1),d0  /* add day, units */
            move.w    d0,d1
            moveq     #0,d0
            move.b    2(a1),d0  /* get month, tens */
            mulu.w    #10,d0
            add.b     3(a1),d0  /* add month, units */
            asl.w     #5,d0     /* shift into place for GEMDOS format */
            add.w     d0,d1
            moveq     #0,d0
            move.b    0(a1),d0  /* get year, tens */
            mulu.w    #10,d0
            add.b     1(a1),d0  /* add year, units */
            asl.w     #8,d0     /* shift into place for GEMDOS format */
            asl.w     #1,d0
            add.w     d0,d1     /* date in d1.w now */
            swap      d1

            move.l    d1,d0
            rts

rdRTCMask:  moveq     #13-1,d0
            moveq     #1,d1
rdRTCMk2:   move.b    (a0,d1.w),d2
            and.b     #$f,d2
            move.b    d2,(a1,d0.w)
            addq.w    #2,d1
            dbra      d0,rdRTCMk2
            rts

rdRTCErr:   moveq  #-1,d0
            rts

writeRTCTime:
#if TP_78 /* CORRECT_DAY */
#include "../tospatch/patches/setwoch.S"
#else
            bsr       checkRTC
            bcs       no_RTC_found
            lea       ABSW2(rtcbufa),a1
            move.w    6(sp),d1    /* get time */
            move.w    d1,d0
            and.l     #$1f,d0     /* extract seconds */
            add.w     d0,d0
            divu.w    #10,d0
            move.b    d0,11(a1)   /* seconds, tens */
            swap      d0
            move.b    d0,12(a1)   /* seconds, units */
            move.w    d1,d0
            lsr.w     #5,d0
            and.l     #$3f,d0     /* extract minutes */
            divu.w    #10,d0
            move.b    d0,9(a1)    /* minutes, tens */
            swap      d0
            move.b    d0,10(a1)   /* minutes, units */
            lsr.w     #8,d1
            lsr.w     #3,d1       /* extract hour */
            ext.l     d1
            divu.w    #10,d1
            move.b    d1,7(a1)    /* hour, tens */
            swap      d1
            move.b    d1,8(a1)    /* hour, units */

            move.w    4(sp),d1    /* get date */
            move.w    d1,d0
            and.l     #$1f,d0     /* extract day */
            divu.w    #10,d0
            move.b    d0,4(a1)    /* day, tens */
            swap      d0
            move.b    d0,5(a1)    /* day, units */
            move.w    d1,d0
            lsr.w     #5,d0
            and.l     #$f,d0      /* extract month */
            divu.w    #10,d0
            move.b    d0,2(a1)    /* month, tens */
            swap      d0
            move.b    d0,3(a1)    /* month, units */
            lsr.w     #1,d1
            lsr.w     #8,d1       /* extract year */
            ext.l     d1
            move.l    d1,d2
            divu.w    #10,d1
            move.b    d1,0(a1)    /* year, tens */
            swap      d1
            move.b    d1,1(a1)    /* year, units */
            divu.w    #4,d2
            swap      d2
			clr.b     6(a1)       /* set day of week to sunday */
			move.b    #2,31(a0)   /* reset clock */
			move.b    #9,27(a0)   /* select bank 1 */
            move.b    #1,21(a0)   /* set 24h mode */
            move.b    d2,23(a0)   /* set leapyear register */
			move.b    #8,27(a0)   /* select bank 0, and start clock */
            moveq     #13-1,d0
            moveq     #1,d1
wrRTC2:     move.b    (a1,d0.w),(a0,d1.w)
            addq.w    #2,d1
            dbra      d0,wrRTC2
            moveq     #0,d0
            rts

no_RTC_found:moveq    #-1,d0
            rts

#endif /* TP_78 */

#endif /* TP_77 */

        bss

        xdef rtcbufa
        comm rtcbufa,13
        xdef rtcbufb
        comm rtcbufb,13

#endif /* MSTECLK */
