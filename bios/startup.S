/*
 * startup.S - TOS startup module
 *
 * Also contains most of the BIOS functions.
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#include "config.h"
#include "asmdefs.h"
#include "header.h"
#include "tosvars.inc"
#include "biosdefs.h"

#ifndef STEP_RATE
#define STEP_RATE 3
#endif


/* ==== Defines ============================================================== */
cart_base  equ   $00fa0000 /* Base of ROM port cartridge */
GEM_MUPB_MAGIC equ $87654321

#define RR_MAGIC    $12123456
#define RR_CHKSUM   $5678

nlevels  equ 5
save_siz equ nlevels*46+8

/* ==== Definitions ========================================================== */

        xdef  _os_entry
        xdef  _run_cartridge_applications

/* ==== References =========================================================== */

/* BIOS C part */
/*        xref _biosmain     / * BIOS C entry point */

/* Overall memory map */
/*       xref __end         / * end of bss + comm sections (ld generated) */
/*       xref __etext       / * end of text section */
/*       xref __edata       / * end of data section */
        xref _endvdibss    /* end of VDI BSS */
        xref _endgembss    /* end of GEM BSS */
        xref __ebss        /* end of BSS */

		xref _supstk


/* ==== hardware addresses =================================================== */

scu_gp1   equ $FFFF8E09
memconf   equ $FFFF8001
v_syncmod equ $FFFF820A
sndmactl  equ $FFFF8900
mwmask    equ $FFFF8924
mwdata    equ $FFFF8922

v_bas_h   equ $FFFF8201
v_bas_m   equ $FFFF8203
v_bas_l   equ $FFFF820d

vme_mask  equ $FFFF8E0D
sys_mask  equ $FFFF8E01

palette   equ $FFFF8240
v_shf_mod equ $FFFF8260
shift_tt  equ $FFFF8262

spshift   equ $FFFF8266
sppalette equ $FFFF9800

STConfig  equ $FFFF9200

FPStat    equ $FFFFFA40

LcdPControl equ $FFFF827F


STLOW     equ 0
STMED     equ 1
STHIGH    equ 2
FALCONREZ equ 3
TTMED     equ 4
TTHIGH    equ 6
TTLOW     equ 7

/* =========================================================================== */
/* ==== TEXT segment (TOS image) ============================================= */
/* =========================================================================== */

        text


/*
 * OSHEADER
 */

        xdef  _os_beg
        xdef  _os_magic
        xdef  _os_date
        xdef  _os_conf
        xdef  _os_dosdate

        xdef _ui_mupb

        xref  _root
        xref  _run

_os_entry:
    bra.s   _main       /* os_entry, branch to _main */
os_version:
    dc.w    ATOSVERSION  /* os_version, TOS version */
reseth:
    dc.l    _main       /* reseth, pointer to reset handler */
_os_beg:
    dc.l    _os_entry   /* os_beg, base of os = _sysbase */
os_end:
    dc.l    _endvdibss  /* os_end, end of VDI BSS */
os_res1:
    dc.l    _main       /* os_res1, reserved */
_os_magic:
    dc.l    _ui_mupb    /* os_magic, pointer to GEM's MUPB */
_os_date:
    dc.l   OS_DATE      /* os_date, Date of system build */
_os_conf:               /* Flag for PAL version + country */
#ifdef CONF_MULTILANG
    dc.w   OS_CONF_MULTILANG
#else
#if OS_COUNTRY == CTRY_PL
	/* hack for polish version: apparently language code not patched */
    dc.w   (CTRY_UK<<1)+OS_PAL
#else
#if (OS_COUNTRY == CTRY_CZ) & (TOSVERSION == 0x104)
	/* hack for czech version: apparently language code not patched */
    dc.w   (CTRY_DE<<1)+OS_PAL
#else
#if (OS_COUNTRY == CTRY_NL) & (TOSVERSION == 0x104)
	/* hack for dutch version: apparently wrong language code used */
    dc.w   (CTRY_SA<<1)+OS_PAL
#else
    dc.w   (OS_COUNTRY<<1)+OS_PAL
#endif
#endif
#endif
#endif
_os_dosdate:
    dc.w   OS_DOSDATE   /* os_date, Date of system build in GEMDOS format */
os_root:
    dc.l   _root        /* Pointer to the GEMDOS mem pool */
os_kbshift:
    dc.l   _shifty      /* Pointer to the keyboard shift keys states */
os_run:
    dc.l   _run         /* Pointer to a pointer to the actual basepage */
os_dummy:
    dc.l   0            /* _main should start at offset 0x30, shouldn't it? */


        data
_ui_mupb:
        dc.l GEM_MUPB_MAGIC
        dc.l _endgembss
        dc.l gemstart

		text


/*
 * Get in supervisor mode and reset all Hardware
 *
 * The following considerations have been taken into account:
 * 1. for unknown reasons, real Falcons need an access to location $ffff8006
 *    before and after the reset instruction
 * 2. in order to run the same code on systems without a register at $ffff8006,
 *    the bus error vector must be intercepted prior to #1
 * 3. since non-68000 systems use the VBR to point to the start of the exception
 *    vectors, the VBR must be zeroed prior to #2 via MOVEC
 * 4. in order to run the same code on 68000 systems (which don't have MOVEC),
 *    the illegal instruction vector must be intercepted prior to #3.  for this,
 *    it doesn't matter if the VBR is non-zero because, if it is, the MOVEC
 *    instruction must be legal so the trap won't get taken ...
 */

	xdef _main
_main:
/* disable the interrupts */
/* this is useless on cold boot, */
/* but it matters for software reset */
        move    #$2700,sr

#if TP_01 /* KILL_RESET */
		nop
#else
        reset                  /* reset all hardware */
#endif
		SETBASEREG

/*
 * Check for diagnostic cartridge
 */
        cmp.l   #$fa52235f,cart_base    /* magic - is cartridge present? */
        bne.s   nodiag                  /* no -> go on */
        lea     nodiag(pc),a6           /* save return address */
        jmp     cart_base+4             /* execute diagnostic cartridge */
nodiag:

        lea       memcret(pc),a6
        bra       memchk
memcret:
        bne.s     resetvec
        move.b    ABSW(memctrl),ABSW(memconf)  /* initialize memory controller */

resetvec:
/*
 * Check, if we should jump to a reset vector after warmboot
 * The high byte of resvector must be zero,
 * it must be even, and cannot be entirely zero.
 */

        cmpi.l   #$31415926,ABSW(resvalid)  /* Jump to resetvector? */
        bne.s    noreset                /* No --> noreset */
        move.l   ABSW(resvector),d0       /* Yes: old resvec to d0 */
        tst.b    ABSW(resvector)          /* bits 24..31 must be zero */
        bne.s    noreset                /* (they aren't, so punt) */
        btst     #0,d0                  /* Address odd ? */
        bne.s    noreset                /* Yes --> noreset */
        movea.l  d0,a0                  /* resvec */
        lea      resetvec(pc),a6        /* save return address */
/* Note: the return address intentionally points to the resvalid test. */
/* So the reset routine must explicitly clear resvalid before returning */
/* to a6, otherwise there will be an infinite loop. */
        jmp      (a0)                   /* jump to resvec */
noreset:
		SETBASEREG


/*
 * memory configuration
 */

/*
 * do/test memory config and clear it
 *  Initialize PSG output ports.
 *  Make port A and B output-only,
 *  initialize floppy select lines (so
 *  that none are selected)
 */
meminit:

        lea.l     ABSW(psgsel),a0
        move.b    #$07,(a0)  /* select mixer control */
        move.b    #$C0,2(a0) /* Port A+B = output */
        move.b    #$0E,(a0)  /* select Port A */
        move.b    #7,2(a0) /* deselect floppy drives */

        btst      #0,_os_conf+1(pc)         /* check bit: configured for 50hz? */
        beq.s     notpal                    /* (nope -- we're good ol' NTSC) */
        lea       ret_1b(pc),a6
        bra       waitvbl                   /* a short delay for PAL */
ret_1b:
#if TP_02 /* COLOR_60HZ */
        move.b    #0,(v_syncmod).w          /* yes -- twiddle to 60hz */
#else
        move.b    #2,ABSW(v_syncmod)        /* yes -- twiddle to 50hz */
#endif
notpal:

/*
 * next, set up the palette(s)
 */

        lea.l     ABSW(palette),a1
        move.w    #16-1,d0
        lea.l     dflt_pal(pc),a0
initpal:
        move.w    (a0)+,(a1)+
        dbf       d0,initpal

/* set Video screen memory position to 0x10000 */
        move.b    #$01,ABSW(v_bas_h)
        clr.b     ABSW(v_bas_m)

#if TOSVERSION >= 0x106
		clr.b     ABSW(v_bas_l)
#endif

        move.b    ABSW(memctrl),d6                /* d6 = memory controller configuration */

        move.l    ABSW(_phystop),d5               /* d5 -> (possible) top of physical mem */
        lea       memcret2(pc),a6               /* load return address */
        bra       memchk                        /* check if the memory configuration is valid */
memcret2:
        beq       nomemchk

/* First we try to configure the memory controller */

            clr.w     d6
            move.b    #$a,ABSW(memconf)			/* default: setup controller for 2Mb/2Mb */

            movea.w   #$8,a0
            lea       $200008,a1				/* + 2Mb */
            clr.w     d0
chkpatloop: move.w    d0,(a0)+					/* fill 512-8 bytes with a test pattern */
            move.w    d0,(a1)+
            add.w     #$fa54,d0
            cmpa.l    #$200,a0
            bne.s     chkpatloop

			move.l    #$200000,d1				/* 2Mb = maximum size per bank */

chkmemloop: lsr.w     #2,d6						/* shift memory configuration down by a bank (bank 1 is in bits 0..1, bank 0 is in bits 2..3) */

#if TOSVERSION >= 0x106
			movea.l   #$00040008,a0
#else
			movea.w   #$0208,a0
#endif
            lea       chkmem3(pc),a5
            bra       memchk0
chkmem3:    beq.s     chkmem7					/* bank is not working => */

#if TOSVERSION >= 0x106
			movea.l   #$00080008,a0
#else
			movea.w   #$0408,a0
#endif
            lea       chkmem4(pc),a5
            bra       memchk0
chkmem4:    beq.s     chkmem6					/* bank has 512Kb of memory => */

            movea.w   #8,a0						/* + 0 bytes */
            lea       chkmem5(pc),a5
            bra       memchk0
chkmem5:    bne.s     chkmem7					/* bank is empty => */

            addq.w    #4,d6						/* 4+4 = 1000 2Mb bank size */
chkmem6:    addq.w    #4,d6						/* 4   = 0100 512Kb bank size */
chkmem7:    sub.l     #$200000,d1				/* - 2Mb */
            beq.s     chkmemloop
#if TOSVERSION >= 0x106
			SETBASEREG
            move.b    d6,ABSW(memconf)			/* set memory configuration */
#else
            move.b    d6,(memconf).l			/* set memory configuration */
#endif

/*
 * We now need to size the actual memory present.  We test memory,
 * starting at 128K and increasing by 128K each time.  For each area of
 * memory, we start at the current address, and work downwards, storing
 * a series of values; we then verify that the values have been stored
 * correctly.  An invalid value (or a bus error when we try to access a
 * memory location) causes us to stop and size the memory accordingly.
 */

        lea.l     $00008000,a7
        movea.l   (_buserror).l,a4
        lea.l     st_ramsize_done(pc),a0 /* bus error means end of ram */
        move.l    a0,(_buserror).l
        move.w    #$FB55,d3           /* d3.w = difference between adjacent stored values */
        move.l    #$00020000,d7       /* d7 = address of first memory test zone & gap between memory test zones */

        movea.l   d7,a0               /* a0 = address of current test zone */
next_zone:
        movea.l   a0,a1               /* a1 -> memory being tested */
        move.w    d0,d2               /* d2.w = test value */
        moveq.l   #42,d1              /* d1.w = loop count-1 */
store_mem:
        move.w    d2,-(a1)            /* store a value */
        add.w     d3,d2               /* update the value for next time */
        dbf       d1,store_mem        /* rinse & repeat */
/* now check the values we stored */
        movea.l   a0,a1               /* a1 -> test area */
        moveq.l   #42,d1              /* loop count */
check_mem:
        cmp.w     -(a1),d0
        bne.s     st_ramsize_done   /* miscompare, ram invalid, exit */
        clr.w     (a1)                /* else zero it out */
        add.w     d3,d0               /* update for next compare */
        dbf       d1,check_mem        /* until we're done */
        adda.l    d7,a0               /* point to next test area */
        bra.s     next_zone
st_ramsize_done:                    /* bus error or bad ram  */
        suba.l    d7,a0               /* (a0 -> first zone that failed) */
        move.l    a0,d5               /* d5 = st ram size */
        move.l    a4,(_buserror).l

#if TOSVERSION < 0x106
		SETBASEREG
		move.l    d5,d0
		sub.l     #$00008000,d0
		lsr.w     #8,d0
		move.b    d0,ABSW(v_bas_m)
		swap      d0
		move.b    d0,ABSW(v_bas_h)
		movea.l   d5,a0
#endif

/* =========================================================================== */
/* ==== This part is executed only on first boot ============================= */
/* =========================================================================== */

        /* Clear the memory */
#if TOSVERSION >= 0x106
#if TP_04 /* MEM_INIT & !RAMRESET */
        movea.w   #$100,a0
#else
        move.l    #sysvars_start,a0
#endif
        move.l    d5,d4
        moveq.l   #0,d0
clrmem:
		move.l    d0,(a0)+
		move.l    d0,(a0)+
		move.l    d0,(a0)+
		move.l    d0,(a0)+
        cmpa.l    d4,a0
        bne.s     clrmem
#else
#if TP_04 /* MEM_INIT & !RAMRESET */
        move.l    #$100,d4
#else
        move.l    #sysvars_start,d4
#endif
        moveq.l   #0,d0
        moveq.l   #0,d1
        moveq.l   #0,d2
        moveq.l   #0,d3
clrmem:
		movem.l   d0-d3,-(a0)
		movem.l   d0-d3,-(a0)
		movem.l   d0-d3,-(a0)
		movem.l   d0-d3,-(a0)
        cmpa.l    d4,a0
        bne.s     clrmem

		SETBASEREG
#endif

        move.b    d6,ABSW(memctrl)
        move.l  d5,ABSW(_phystop)            /* highest address as phystop */

        move.l    #$752019F3,ABSW(_memvalid) /* set memvalid to ok */
        move.l    #$237698AA,ABSW(_memval2)  /* set memval2 to ok */
        move.l    #$5555AAAA,ABSW(_memval3)  /* set memval3 to ok */

#if TOSVERSION >= 0x106
		clr.l     ABSW2(_ramtop)             /* no FASTRAM available */
		move.l    #$1357BD13,ABSW(_ramvalid) /* ramtop is valid (ramvalid == RAMMAGIC) */
#endif
nomemchk:

		SETBASEREG

#if (TOSVERSION >= 0x106) & TP_06 /* MSTE_CACHE_ON */
		ori.b     #3,($ffff8e21).w /* turn on 16MHz and cache */
#endif

/* clear the remainder of the BSS section */

        movea.l   #__sbss,a0
        movea.l   #$10000,a1
        moveq.l   #0,d0
clrbss:
        move.w    d0,(a0)+
        cmpa.l    a0,a1
        bne.s     clrbss

/* clear screen memory */

scrsize equ ((640*400)/8+$300)

        movea.l   ABSW(_phystop),a0
        suba.l    #scrsize,a0
        move.w    #(scrsize/16)-1,d1
        move.l    a0,ABSW(_v_bas_ad)
        move.b    ABSW(_v_bas_ad+1),ABSW(v_bas_h)
        move.b    ABSW(_v_bas_ad+2),ABSW(v_bas_m)
#if TOSVERSION >= 0x106
        move.b    ABSW(_v_bas_ad+3),ABSW(v_bas_l)
#endif
clrscr:
        move.l    d0,(a0)+
        move.l    d0,(a0)+
        move.l    d0,(a0)+
        move.l    d0,(a0)+
        dbf       d1,clrscr

/* does os_magic indicate GEM in ROM? */
        movea.l   _os_magic(pc),a0
        cmpi.l    #GEM_MUPB_MAGIC,(a0)
        beq.s     gemok
        lea.l     _os_beg(pc),a0
gemok:
        move.l    4(a0),ABSW(_end_os)
        move.l    8(a0),ABSW(_exec_os)

/* =========================================================================== */
/* initialize system variables */
/* =========================================================================== */

/* --- Disk vectors: */
        move.l    #_bhdv_init,ABSW(_hdv_init)
        move.l    #_bhdv_rwabs,ABSW(_hdv_rw)
        move.l    #_bhdv_getbpb,ABSW(_hdv_bpb)
        move.l    #_bhdv_mediach,ABSW(_hdv_mediach)
        move.l    #_bhdv_boot,ABSW(_hdv_boot)

/* --- device vectors: */
        move.l    #_bco0stat,ABSW(_prt_stat)
        move.l    #_bcon0out,ABSW(_prt_vec)
        move.l    #_bco6stat,ABSW(_aux_stat)  /* BIOS device 1 (AUX) defaults to RS232 port */
        move.l    #_bcon6out,ABSW(_aux_vec)   /* BIOS device 1 (AUX) defaults to RS232 port */
        move.l    #_bscr_dump,ABSW(_scr_dmp)

/* --- Randoms: */
        move.l    ABSW(_v_bas_ad),ABSW(_memtop)
        move.l    ABSW(_end_os),ABSW(_membot)          /* set bottom of memory (for DOS) */
        lea       SUPSIZ*2+_supstk,a7
        move.w    #8,ABSW(_nvbls)                    /* default number of vbl queue entries */
        st        ABSW(_fverify)                     /* enable write-verify */
        move.w    #STEP_RATE,ABSW(_seekrate)         /* set default seek-rate */
        move.l    #_dskbuf,ABSW(_dskbufp)            /* set pointer to disk buffer */
        move.w    #-1,ABSW(_dumpflg)                 /* initialize print-count */
        move.l    #_os_entry,ABSW(_sysbase)          /* unnessary; will be overwritten by instoshdr below */
        move.l    #save_beg+save_siz,ABSW(_savptr)   /* register-save pointer for traps 13&14 */
        move.l    #bios_unimpl,ABSW(_swv_vec)        /* ignore monitor changes for now */
        clr.l     ABSW(_drvbits)                     /* remove all drives */
#if TOSVERSION >= 0x106
        move.l    #_do_bell,ABSW(_bell_hook)
        move.l    #_do_keyclick,ABSW(_kcl_hook)
        clr.w     ABSW(sndmactl)
        lea.l     microwtab(pc),a0
        move.w    (a0)+,ABSW(mwmask)
        bra.s     checkmicro
microwtab:
        dc.w      $0ffe  /* value for microwire mask register */
        dc.w      $09d1                     /* 10-011-101000-1 = LCM - Master Volume - 0 db volume (max) - end-bit */
        dc.w      $0aa9                     /* 10-101-010100-1 = LCM - Left channel volume - 0 db volume (max) - end-bit */
        dc.w      $0a29                     /* 10-100-010100-1 = LCM - Right channel volume - 0 db volume (max) - end-bit */
        dc.w      $090d                     /* 10-010-000110-1 = LCM - Trebble control - 0 db (linear) - end-bit */
        dc.w      $088d                     /* 10-001-000110-1 = LCM - Bass control - 0 db (linear) - end-bit */
        dc.w      $0803                     /* 10-000-000001-1 = LCM - Mixer - DMA + YM2149 - end-bit */
        dc.w      0
nextmicro:
        move.w    d0,ABSW(mwdata)
waitmicro:
        tst.w     ABSW(mwdata)
        bne.s     waitmicro
checkmicro:
        move.w    (a0)+,d0
        bne.s     nextmicro
nodmasound:

/* =========================================================================== */
/* initialize cookie jar */
/* =========================================================================== */

        bsr       instoshdr
        lea.l     cookies,a0
        move.l    a0,ABSW(_p_cookies)
        move.l    #$5F435055,(a0)+ /* '_CPU' */
/* detect CPU type */
        moveq.l   #0,d1         /* assume 68000 */
        movea.w   #_illinst,a2
        movea.l   (a2),a3       /* save illegal instruction vector */
        movea.l   a7,a1         /* save SP */
        move.l    #cpuexit,(a2)
        CCR_D0                  /* move.w ccr,d0 legal on 68010+ */
        moveq.l   #10,d1        /* assume 68000 */
        dc.w $49c0              /* extb.l    d0 */
        moveq.l   #20,d1        /* assume 68020 */
        CACR_D0
        bset      #9,d0         /* set an unused bit */
        D0_CACR
        CACR_D0
        bclr      #9,d0
        beq.s     cpuexit
        moveq.l   #30,d1        /* assume 68030 */
        D0_CACR
cpuexit:
        movea.l   a1,a7         /* restore SP */
        move.l    a3,(a2)       /* save illegal instruction vector */
        move.l    d1,(a0)+      /* set _CPU cookie */
        sne       (_longframe+1).l
cooVDO:	move.l    #$5F56444F,(a0)+
		move.l    #$10000,(a0)+             /* 1,0 = STE Shifter */
		move.l    #$5F4D4348,(a0)+			/* '_MCH' */
		move.l    #$10000,(a0)+             /* 1,x = STE (520, 1040, 2080, 4160, Mega STE, ST Book) */
        move.l    #$5F534E44,(a0)+ /* '_SND' */
        moveq.l   #1,d1
		moveq.l   #0,d0
		move.w    ABSW(STConfig),d0
        lsr.w     #8,d0
        btst      #7,d0
        sne       d2
        and.b     #$02,d2
        or.b      d2,d1
        move.l    d1,(a0)+
        move.l    #$5F535749,(a0)+ /* '_SWI' */
		move.l    d0,(a0)+
/* terminate cookie jar */
        clr.l     (a0)+
        move.l    #NCOOKIES,(a0)+

#else
        clr.w     ABSW(_longframe)
        bsr       instoshdr
#endif
		
/* =========================================================================== */
/* initialize exception vectors */
/* =========================================================================== */

        lea.l     just_rte(pc),a3
        lea.l     bios_unimpl(pc),a4
		cmpi.l    #$FA52235F,cart_base
		beq.s     noexc
        lea.l     any_vec(pc),a1            /* default to exception handler displaying bombs */
#if !P68010
		adda.l    #$2000000,a1				/* exception number in top 8 bits of the address */
#endif
#if TP_05 /* SHELL_P */
		clr.l     (_shell_p).w
        lea.l     (2*4).w,a0
        moveq     #64-3,d0
#else
        lea.l     (2*4).l,a0
        move.w    #64-3,d0
#endif
initexc:
        move.l    a1,(a0)+
#if !P68010
		adda.l    #$1000000,a1				/* increment the exception number */
#endif
        dbf       d0,initexc

        move.l    a3,(_zerodiv).l      /* ignore zero divide */
noexc:

        moveq.l   #6,d0
        lea.l     ABSW(_lvl1vec),a1
initauto:
        move.l    #just_rte,(a1)+      /* ignore auto vectors */
        dbf       d0,initauto

        move.l    #int_vbl,ABSW(_lvl4vec)      /* vblank handler */
        move.l    #int_hbl,ABSW(_lvl2vec)      /* hblank handler */
        move.l    a3,ABSW(_trap2vec)           /* ignore GEM trap for now */
        move.l    #_biostrap,ABSW(_trap13vec)  
        move.l    #_xbiostrap,ABSW(_trap14vec)
        move.l    #line1010,ABSW(_lineatrap)
        move.l    a4,ABSW(_etv_timer)          /* no timer yet */
        move.l    #critret,ABSW(_etv_critic)   /* default critical error handler */
        move.l    a4,ABSW(_etv_term)           /* no user defined function */
        lea.l     ABSW(_vbl_list),a0
        move.l    a0,ABSW(_vblqueue)
        move.w    #7,d0
initvbl:
        clr.l     (a0)+
        dbf       d0,initvbl

/* init bios device vectors */
        lea.l     tconstat,a0
        movea.w   #_bconstat_vec,a1
        moveq.l   #31,d0
initcon:
        move.l    (a0)+,(a1)+
        dbf       d0,initcon



/* initialize MFP */
        bsr       initmfp

/* reset IKBD */
        move.l    #ikbdres,-(a7)
        move.w    #$0001,-(a7)
        jsr       _ikbdws
        addq.l    #6,a7
		move.l    #$00007FFF,d0
ikbdwait:
        bsr       nodiskboot
        dbf       d0,ikbdwait

/* Run all boot applications from the application cartridge,
 * before video initialization.
 */
        moveq.l   #2,d0
        bsr       _run_cartridge_applications
		SETBASEREG

/*
 * check monitor type, and set boot resolution
 */
        move.b    ABSW(v_shf_mod),d0
		and.b     #$03,d0
		cmp.b     #$03,d0
		bne.s     shfmodok
		moveq.l   #STHIGH,d0
shfmodok:
		move.b    d0,ABSW(_sshiftmod)  /* .. and also system var */

		move.b    ABSW(MFP_GPIP),d0
		bmi.s     nomonomon
		lea.l     monchkret(pc),a6
		bra       waitvbl
monchkret:
		move.b    #STHIGH,ABSW(v_shf_mod)
		move.b    #STHIGH,ABSW(_sshiftmod)
nomonomon:

        bsr       blittest
        jsr       resetdev                /* linaA blitter/no-blitter table init */
        jsr       esc_init                /* clear screen, initialize cursor */

		cmpi.b    #STMED,ABSW(_sshiftmod)
		bne.s     nomed
		move.w    ABSW(palette+30),ABSW(palette+6)
nomed:

/*
 * initialize video
 */
        move.l    #_main,ABSW(_swv_vec)     /* RESET system on monitor change */
        move.w    #$0001,ABSW(_vblsem)      /* enable vblank processing */

/* Run all boot applications from the application cartridge,
 * after hardware initialization.
 */
        clr.w     d0
        bsr       _run_cartridge_applications

/* Run all boot applications from the application cartridge,
 * with interrupts enabled.
 */
        move.w    #$2300,sr
        moveq.l   #1,d0
        bsr       _run_cartridge_applications

#if TOSVERSION >= 0x106
		move.l    #_int_priv,ABSW(_privvio)
		bra.s     biosinit
		xdef flushCaches
flushCaches:
		move.w    sr,-(a7)
		ori.w     #$0700,sr
		CACR_D0
		or.l      #$00000808,d0     /* clear & disable instruction/data caches on */
		D0_CACR              /*  68020-60 (even though bit usage differs!) */
		move.w     (a7)+,sr
		rts
_int_priv:
		movem.l   d0/a0,-(a7)
		movea.l   10(a7),a0       /* get exception pc */
		move.w    (a0),d0         /* the offending instruction */
		and.w     #$FFC0,d0       /* isolate move from SR opcode */
		cmp.w     #$40C0,d0       /* we don't care where "To" was */
		bne.s     pi_back         /* Not a MOVE SR,XX instruction */
		move.b    #$42,(a0)       /* turn into move ccr,xx */
		movem.l   (a7)+,d0/a0
		rte
pi_back:
		movem.l    (a7)+,d0/a0
		jmp       any_vec+$08000000             /* illegal instruction => _term; $80000000 to get exception number in high byte */
#endif

/*
 * continue with rest of bios initialization
 */
biosinit: ds.b 0
#if TOSVERSION >= 0x106
		nop
#endif
		jsr       _osinit            /* initialize DOS */

/* --- set the current system time and date */
        move.w    _os_dosdate,_date  /* use BIOS time as current time */
        jsr       ngetdt             /* set current time to RTC time */
#if TP_69 /* TIME_SAVE */
        /* swedish/czech versions have the TIME_SAVE patch applied */
        bpl.s     clockdone
#else
        bcc.s     clockdone
#endif
        bsr       igetdt             /* read time from the keyboard controller */
        swap      d0
        tst.b     d0
        beq.s     clockdone
        move.w    d0,_date
        swap      d0
        move.w    d0,_time
clockdone:

/* boot eventually from a block device (floppy or harddisk) */
        bsr       diskboot

/* memory test and attempt to boot from SCSI/ACSI */
        bsr       dmaboot

#if TP_64 /* IDE_BOOT */
/* boot eventually from first IDE device */
		jsr       ideboot
#endif

/* run resident programs */
        bsr       run_reset_resident
        tst.w     _cmdload                     /* load shell from disk? */
        beq.s     nocmd
        bsr       autoexec
        move.l    #_os_entry,_sysbase          /* -> base of OS */
        pea.l     emptystr(pc)                 /* null environment string */
        pea.l     emptystr(pc)                 /* null argument string */
        pea.l     command_prg(pc)              /* push shell filename */
        clr.w     -(a7)                        /* Load&Go */
        bra.s     dopexec
nocmd:
/* --- bring up GEM: */
        bsr       autoexec
        move.l    #_os_entry,_sysbase
/* --- kludge up an enviroment string */
        lea.l     default_env(pc),a0
        movea.l   #gem_env,a1
copyenv:
        cmpi.b    #$23,(a0)                    /* look for drive# character */
        bne.s     nextenvc
        movea.l   a1,a2                        /* remember dest addr of drive character */
nextenvc:
        move.b    (a0)+,(a1)+
        bpl.s     copyenv
#if TP_13
        /* swedish/czech versions have the BOOT_DEV patch applied */
        move.w    _bootdev,d0
#else
        move.b    _bootdev,d0                  /* compute drive#, and shove it (infamous old bug accessing _bootdev as byte) */
#endif
        add.b     #$41,d0
        move.b    d0,(a2)
        pea.l     gem_env                      /* push address of environment string */
        pea.l     emptystr                     /* no arguments */
        pea.l     emptystr(pc)                 /* null shell name (in ROM, after all) */
        move.w    #$0005,-(a7)
        move.w    #$004B,-(a7)
        trap      #1                           /* Pexec(5) Create basepage */
        adda.w    #$000E,a7
        movea.l   d0,a0                        /* get pointer to PSP */
        move.l    _exec_os,8(a0)               /* set p_tbase of created PD */
        pea.l     gem_env
        move.l    a0,-(a7)
        pea.l     emptystr(pc)
        move.w    #$0004,-(a7)
dopexec:
        move.w    #$004B,-(a7)
        trap      #1                           /* Pexec(4) Just go: execute GEM */
        adda.w    #14,a7
/*
 * When startup fails (or if the exec returns,
 * which "cannot happen") fake a system reset:
 */
        jmp       _main

/*
 * Default environment string
 * Cannot be more than 20 chars long without modifying
 * the declaration for gem_env,
 * Any char >= $80 terminates the string (and is included in it)
 * The last '#' character is replaced by the boot drive's name (A, B, ...)
 */
default_env: dc.b 'PATH=',0,'#:',$5c,0,0,$ff
command_prg: dc.b 'COMMAND.PRG',0
gem_prg:     dc.b 'GEM.PRG'

emptystr: dc.b 0,0,0

ikbdres:
        dc.b $80,$01

/* Run all boot applications from the application cartridge.
 * Beware: Hatari features a special cartridge which is used
 * for GEMDOS drive emulation. It will hack drvbits and hook Pexec().
 * It will also hack Line A variables to enable extended VDI video modes.
 */
/* 306de: 00e0098a */
/* 206de: 00e00962 */
/* 104de: 00fc0530 */
/* 106de: 00e00640 */
diskboot:
        moveq.l   #3,d0
        bsr       _run_cartridge_applications
        movea.l   (_hdv_boot).l,a0          /* go through boot vector */
        jsr       (a0)
        tst.w     d0                        /* any errors? */
        bne.s     nodiskboot                /* (yes -- punt) */
        lea.l     _dskbuf,a0
        jsr       (a0)                      /* execute boot sector (it might return) */
nodiskboot:
        rts


#if TP_14 /* CT_HD */
#include "../tospatch/patches/ct_hd.S"
#else

/* 306de: 00e009a2 */
/* 206de: 00e0097a */
/* 104de: 00fc054c */
/* 106de: 00e0065c */
dmaboot:
/* --- boot from DMA device */
dmadone:
	    moveq	  #0,d7     /* d7 = device (ASCI0) */

#if TOSVERSION >= 0x106
		move.l    _hz_200.l,-(a7)
#endif

confdone:
		suba.l    a4,a4
dmadev:
        bsr.s     _dmaread             /* read first sector of this device */
        bne.s     nextdev
        move.l    _dskbufp(a4),a0      /* buf = _dskbufp */
        move.w    #256-1,d1            /* 256 word checksum over the boot sector */
        moveq.l   #0,d0
dmacrc:
        add.w     (a0)+,d0
        dbf       d1,dmacrc
        cmp.w     #$1234,d0            /* checksum == 0x1234? */
        bne.s     nextdev              
        /* execute this valid boot sector */
        move.l    _dskbufp(a4),a0      /* buf = _dskbufp */
        jsr       (a0)                   /* execute boot sector */
nextdev:
        add.b     #$20,d7
        bne.s     confdone
#if TOSVERSION >= 0x106
		addq.l     #4,a7
#endif
        rts

_dmaread:
		moveq.l   #1,d5
dmaread1:
		lea.l     $ffff8606(a4),a6
		lea.l     $ffff8604(a4),a5
		st        _flock(a4)
		move.l    _dskbufp(a4),-(a7)
		move.b    3(a7),$ffff860d(a4)
		move.b    2(a7),$ffff860b(a4)
		move.b    1(a7),$ffff8609(a4)
		addq.w    #4,a7
		move.w    #$0098,(a6)
		move.w    #$0198,(a6)
		move.w    #$0098,(a6)
		move.w    #$0001,(a5)
		move.w    #$0088,(a6)
		move.b    d7,d0
		or.b      #$08,d0
		swap      d0
		move.w    #$008A,d0
#if TOSVERSION >= 0x106
		move.l     #2000,d1
		sub.l      _hz_200.l,d1
		moveq.l    #10,d2
		cmp.l      d2,d1
		bgt.s      dmaread5
		move.l     d2,d1
dmaread5:
		move.l     d1,d2
#endif
		bsr.s     acsistat
		bne.s     dmaread3
		moveq.l   #3,d6
		lea.l     acmdtab(pc),a0
dmaread2:
		move.l    (a0)+,d0
#if TOSVERSION >= 0x106
		move.l     d2,d1
#endif
		bsr.s     acsistat
		bne.s     dmaread3
		dbf       d6,dmaread2
		move.l    #$0000000A,(a5)
#if TOSVERSION >= 0x106
		move.l     #8000,d1
		sub.l      _hz_200.l,d1
		move.l     #$00000190,d2
		cmp.l      d2,d1
		bgt.s      dmaread6
		move.l     d2,d1
dmaread6: ds.b 0
#else
		move.w    #$0190,d1
#endif
		bsr.s     acsista0
		bne.s     dmaread3
		move.w    #$008A,(a6)
		move.w    (a5),d0
		and.w     #$00FF,d0
		beq.s     dmaread4
		dbf       d5,dmaread1
dmaread3:
		moveq.l   #-1,d0
dmaread4:
		move.w    #$0080,(a6)
		tst.b     d0
		sf        _flock(a4)
		rts
acmdtab:
		dc.l      $0000008a,$0000008A,$0000008a,$0001008A
acsistat:
		move.l    d0,(a5)
#if TOSVERSION < 0x106
		moveq.l   #10,d1
#endif
acsista0:
		add.l     _hz_200(a4),d1
acsista1:
		btst      #5,MFP_GPIP(a4)
		beq.s     acsista2
		cmp.l     _hz_200(a4),d1
#if TOSVERSION >= 0x106
		bhi.s     acsista1
#else
		bne.s     acsista1
#endif
		moveq.l   #-1,d1
acsista2:
		rts

#endif /* TP_14 */


/*
 * void run_cartridge_applications(WORD typebit);
 *
 * Run all cartridge applications of the specified type.
 *
 * typebit(d0): application type bit number which must be set to 1 to match
 */
/* 306de: 00e00bbc */
/* 206de: 00e00b68 */
/* 104de: 00fc0628 */
/* 106de: 00e0076a */
_run_cartridge_applications:
        lea     cart_base,a0
cartext2:
        cmp.l   #$ABCDEF42,(a0)+        /* is cartridge present? */
        bne.s   cartover                /* no -> cartover */
testtype:
        btst    d0,4(a0)                /* What type? */
        beq.s   nextapp

        movem.l d0-d7/a0-a6,-(sp)       /* save registers */
        move.l  4(a0),a0                /* d0 = address of cartridge init */
        jsr     (a0)                    /* execute app in cartridge */
        movem.l (sp)+,d0-d7/a0-a6       /* restore registers */
nextapp:
        tst.l   (a0)                    /* another application? */
        move.l  (a0),a0
        bne.s   testtype
cartover:
        rts

/* 306de: 00e00bee */
/* 206de: 00e00b9a */
/* 104de: 00fc0652 */
bios_unimpl:
		rts

/*
 * memchk - check pattern written to memory
 *       Passed:         d1.l = offset
 *                       a0 = base of pattern ($1f8 bytes long)
 *                       a5 -> return address
 *
 *       Returns:        EQ: the pattern matched
 *                       NE: the pattern didn't match
 *
 *       Uses:           d0.w, a1
 *       Called-by:      Coldstart memory-sizing routine.
 */
memchk0:
/* 306: unused */
        adda.l    d1,a0         /* a0 -> memory to check */
        clr.w     d0            /* zap pattern seed */
        lea.l     504(a0),a1    /* a1 -> ending address */
memchk1:
        cmp.w     (a0)+,d0      /* match? */
        bne.s     memchk2       /* (no -- return NE) */
        add.w     #$FA54,d0     /* yes -- bump pattern */
        cmpa.l    a0,a1         /* matched entire pattern? */
        bne.s     memchk1       /* (no) */
memchk2:
        jmp       (a5)          /* "return" to caller */

/*
 * test memory configuration validation
 *  Passed:      a6 -> return addressd
 *  Returns:     a5 -> 0 (quick zeropage)
 *               EQ: memory setup OK
 *               NE: memory never configured succesfully
 *
 */
/* 306de: 00e00c06 */
/* 206de: 00e00bb2 */
/* 104de: 00fc066a */
memchk:
		SETBASEREG
        cmpi.l    #$752019F3,ABSW(_memvalid)     /* test memory configuration validation, check first magic number */
        bne.s     memchk3                      /* (mismatched -- return NE) */
        cmpi.l    #$237698AA,ABSW(_memval2)      /* check one more (for paranoia) */
        bne.s     memchk3                      /* (mismatched -- return NE) */
        cmpi.l    #$5555AAAA,ABSW(_memval3)      /* check a third time (for more paranoia) */
memchk3:
        jmp       (a6)                         /* return EQ/NE */

/*
 * Default palette assignments.
 *  Sort of corresponding to the GSX spec.
 */
/* 306de: 00e00c24 */
/* 206de: 00e00bd0 */
/* 104de: 00fc068a */
/* 106de: 00e007cc */
dflt_pal:
#if TOSVERSION >= 0x106
		dc.w $0fff     /* 0 white */
		dc.w $0f00     /* 1 red */
		dc.w $00f0     /* 2 green */
		dc.w $0ff0     /* 3 yellow */
		dc.w $000f     /* 4 blue */
		dc.w $0f0f     /* 5 magenta */
		dc.w $00ff     /* 6 cyan */
		dc.w $0555     /* 7 "low white" */
		dc.w $0333     /* 8 grey */
		dc.w $0f33     /* 9 light red */
		dc.w $03f3     /* 10 light green */
		dc.w $0ff3     /* 11 light yellow */
		dc.w $033f     /* 12 light blue */
		dc.w $0f3f     /* 13 light magenta */
		dc.w $03ff     /* 14 light cyan */
		dc.w $0000     /* 15 black */
#else
		dc.w $0777     /* 0 white */
		dc.w $0700     /* 1 red */
		dc.w $0070     /* 2 green */
		dc.w $0770     /* 3 yellow */
		dc.w $0007     /* 4 blue */
		dc.w $0707     /* 5 magenta */
		dc.w $0077     /* 6 cyan */
		dc.w $0555     /* 7 "low white" */
		dc.w $0333     /* 8 grey */
		dc.w $0733     /* 9 light red */
		dc.w $0373     /* 10 light green */
		dc.w $0773     /* 11 light yellow */
		dc.w $0337     /* 12 light blue */
		dc.w $0737     /* 13 light magenta */
		dc.w $0377     /* 14 light cyan */
		dc.w $0000     /* 15 black */
#endif

/*
 * Int 0x68 - HBL interrupt
 * hbl - force caller to IPL
 * Oh-well:      "Yeah, it sucks, but it works" (--lt)
 *
 * Note:         Hacks caller's IPL to 3 (if it was 0). This is
 *               a kludge against fascist programs and certain
 *               debuggers that insist on starting processes up
 *               at IPL 0.
 *
 */
/* 306de: 00e00c44 */
/* 206de: 00e00bf0 */
/* 104de: 00fc06aa */
/* 404: 00e00c9a */
int_hbl:
        move.w    d0,-(a7)            /* save d0 */
        move.w    2(a7),d0            /* get status register from stack */
        and.w     #$0700,d0           /* isolate just IPL-mask from sr */
        bne.s     is_ipl              /* if IPL is nonzero, then end */
        ori.w     #$0300,2(a7)        /* else set IPL3 in status register */
is_ipl:
        move.w    (a7)+,d0            /* restore d0 */
        rte

/*
 * int_vbl - Int 0x70 - VBL interrupt
 *
 * no video resolution change is done.
 */
/* 306de: 00e00c5a */
/* 206de: 00e00c06 */
/* 208de: 00e00baa */
/* 104de: 00fc06c0 */
/* 404: 00e00cb0 */
int_vbl:
        addq.l    #1,_frclock         /* increase num of happened ints */
        subq.w    #1,_vblsem          /* check vbl semaphore */
        bmi       vbl_end             /* if VBl routine disabled -> end */
        movem.l   d0-d7/a0-a6,-(a7)   /* save registers */
        addq.l    #1,_vbclock         /* count number of VBL interrupts */
		SETBASEREG

#if TOSVERSION >= 0x106
		move.w     sr,-(a7)
		ori.w      #$0700,sr
moncheck:
		move.b     ABSW(sndmactl+1),d0
        move.b    ABSW(MFP_GPIP),d1
        btst      #7,d1
        sne       d1
        move.b    ABSW(MFP_GPIP),d2
        btst      #7,d2
        sne       d2
        cmp.b     d1,d2
        bne.s     moncheck
        cmp.b     ABSW(sndmactl+1),d0
        bne.s     moncheck
        move.w    (a7)+,sr
        btst      #0,d0
        beq.s     nomoncheck
        not.b     d1
nomoncheck:
#else
        move.b    ABSW(MFP_GPIP),d1
#endif
        move.b    ABSW(v_shf_mod),d0
		and.b     #3,d0
		cmp.b     #STHIGH,d0
		bge.s     vbl_wasmono
        btst      #7,d1
        bne.s     vbl_nomonchg
		move.w    #2000,d0
vblloop:
		dbf       d0,vblloop

		move.b    #STHIGH,d0
        bra.s     vbl_monchg
vbl_wasmono:
        btst      #7,d1
        beq.s     vbl_nomonchg
        move.b    ABSW(_defshiftmod),d0
		cmp.b     #STHIGH,d0
		blt.s     vbl_monchg
        clr.b     d0 /* STLOW */
vbl_monchg:
        move.b    d0,ABSW(_sshiftmod)
		move.b    d0,ABSW(v_shf_mod)
        movea.l   ABSW(_swv_vec),a0
        jsr       (a0)

vbl_nomonchg:

        jsr       blink								/* blink cursor */
		SETBASEREG

/* --- reload color palettes */

        tst.l     ABSW(_colorptr)						/* reload color palettes, if(colorptr != NULL).... */
        beq.s     vbl_no_palette
        movea.l   ABSW(_colorptr),a0					/* a0 -> user's color base */
        lea.l     ABSW(palette),a1					/* a1 -> hardware palette base */
        move.w    #16-1,d0								/* d0 = count */
vbl_palette_loop:
        move.w    (a0)+,(a1)+
        dbf       d0,vbl_palette_loop
        clr.l     ABSW(_colorptr)
vbl_no_palette:
/* --- reload display base register */
        tst.l     ABSW(_screenpt)
        beq.s     vbl_no_screenpt
        move.l    ABSW(_screenpt),ABSW(_v_bas_ad)
#if TOSVERSION >= 0x106
        move.b    ABSW(_v_bas_ad+3),ABSW(v_bas_l)
#endif
        move.b    ABSW(_v_bas_ad+2),ABSW(v_bas_m)
        move.b    ABSW(_v_bas_ad+1),ABSW(v_bas_h)
vbl_no_screenpt:

/* ------ Call deferred interrupt vectors */
        bsr       _flopvbl

/* vblqueue */
        move.w    _nvbls,d7                 /* d7 = # of deferred vblank vectors */
        beq.s     vbl_no_queue              /* (punt if no vectors) */
        subq.l    #1,d7                     /* turn into DBRA count */
        movea.l   _vblqueue,a0              /* a0 -> vectors */
vbl_loop:
        movea.l   (a0)+,a1                  /* a1 -> deferred vector */
        cmpa.l    #$0000,a1                 /* if(a1 == NULL) continue; */
        beq.s     vbl_next
        movem.l   d7/a0,-(a7)               /* save registers */
        jsr       (a1)                      /* call routine */
        movem.l   (a7)+,d7/a0               /* restore registers */
vbl_next:
        dbf       d7,vbl_loop               /* loop for more vectors */

vbl_no_queue:
		SETBASEREG
/* screen hardcopy */
        tst.w     ABSW(_dumpflg)						/* monitor screen dump flag - printscreen active? */
        bne.s     vbl_no_dump
        bsr       _scrdmp
vbl_no_dump:
        movem.l   (a7)+,d0-d7/a0-a6					/* restore registers & return (and a handy RTE) */
vbl_end:
        addq.w    #1,_vblsem						/* V(vblsem) [release vblank] */

/* 306de: 00e00d78 */
/* 206de: 00e00d1a */
/* 104de: 00fc07a0 */
just_rte:
        rte

/*
 * XBIOS #37 - Vsync - wait for next vblank
 */
/* 306de: 00e00d7a */
/* 206de: 00e00d1c */
/* 104de: 00fc07a2 */
_vsync:
        move.w    sr,-(a7)
        andi.w    #$F8FF,sr							/* enable vbl interrupts */
        move.l    _frclock,d0						/* d0 = frame clock */
vsyncwait:
        cmp.l     _frclock,d0						/* wait for clock to change */
        beq.s     vsyncwait
        move.w    (a7)+,sr
        rts

/*
 * _callcrit - critical error handler binding for C
 * Falls-into:   critret
 * (screwy way to save two bytes....)
 *
 */
/* 306de: 00e00d92 */
/* 206de: 00e00d34 */
/* 104de: 00fc07ba */
		xdef _callcrit
_callcrit:
        move.l    _etv_critic,-(a7)
/*
 * critret - default critical error handler
 * Loads -1 into D0 and returns
 *
 */
critret:
        moveq.l   #-1,d0
        rts

/*
 * trp13h - GEMDOS BIOS trap handler (trap 13)
 * trp14h - Atari BIOS extensions (trap 14)
 * traph  - trap handler
 *
 * On the stack:
 *       From super-             From user
 *       visor mode:             mode:
 *       -----------             ------------
 *       N(sp) args              N(usp) args
 *       6(sp) func#             6(usp) func#
 *       2(sp) ret               2(ssp) ret
 *        (sp) SR                 (ssp) SR
 *
 * Returns:      anything in D0
 * Uses:         d0-d2/a0-a2
 * Keeps:        C registers
 *
 * Notes         BIOS traps are re-entrant to 'nlevels' (declared near the
 *               beginning of this file).  Attempts to recurse more than
 *               'nlevels' will probably result in a crash.
 *
 *               BIOS calls may be made from user mode.  (This differs from
 *               the current GEMDOS spec, which states that BIOS traps are
 *               available from supervisor mode only).
 *
 */
/* ==== Trap 14 - XBIOS entry point ========================================= */

/* 306de: 00e00d9c */
/* 206de: 00e00d3e */
/* 104de: 00fc07c4 */
/* 404: 00e00d76 */
_xbiostrap:
        lea.l     xbios_vecs(pc),a0
        bra.s     biosxbios

/* ==== Trap 13 - BIOS entry point ========================================== */

/* 306de: 00e00da2 */
/* 206de: 00e00d44 */
/* 104de: 00fc07ca */
/* 404: 00e00d7c */
_biostrap:
        lea.l     bios_vecs(pc),a0

/* ==== Trap 13+14 handler ================================================== */
biosxbios:
        movea.l   _savptr,a1
        move.w    (a7)+,d0               /* Status register -> d0 */
        move.w    d0,-(a1)               /* and save in save_area */
        move.l    (a7)+,-(a1)            /* save return address */
#if !P68000
#if !P68010 | !BINEXACT
        tst.w     ABSW2(_longframe)
        beq.s     traph2
#endif
        tst.w     (a7)+                  /* skip format word */
#endif
traph2: 
#if TOSVERSION >= 0x106
        nop
#endif
        movem.l   d3-d7/a3-a7,-(a1)      /* regs, including stack pointer */
        move.l    a1,_savptr
        btst      #13,d0                 /* were we in supervisor mode? */
        bne.s     bx_sp_ok               /* yes, the sp already points to the arguments */
        move.l    usp,a7                 /* no, the arguments were on the user stack */
bx_sp_ok:
        move.w    (a7)+,d0               /* remove the function number from stack */
        cmp.w     (a0)+,d0               /* Higher than highest number? */
        bge.s     bx_ret                 /* if not implemented, returns the func number */
        lsl.w     #2,d0                  /* function table is 1 LW per number so multiply function number by 4 */
        move.l    0(a0,d0.w),d0          /* get function address */
        movea.l   d0,a0                  /* (quick and dirty test-for-negative) */
        bpl.s     bx_notindirect         /* points to code */
        movea.l   (a0),a0                /* call indirect through system variable */
bx_notindirect:
        SETBASEREG                       /* a5 -> zero page */
        jsr       (a0)                   /* call BIOS/XBIOS function */
bx_ret:
        movea.l   _savptr,a1
        movem.l   (a1)+,d3-d7/a3-a7      /* Get regs back, including sp */
#if !P68000
#if !P68010 | !BINEXACT
        tst.w     ABSW2(_longframe)
        beq.s     trph3
#endif
        clr.w     -(a7)                  /* push NULL format word */
#endif
trph3:
#if TOSVERSION >= 0x106
        nop
#endif
        move.l    (a1)+,-(a7)            /* return adress */
        move.w    (a1)+,-(a7)            /* sr */
        move.l    a1,_savptr
        rte                              /* return with return value in D0 */

/* ------ jump table for BIOS functions: */
/* 306de: 00e00dfa */
/* 206de: 00e00da4 */
/* 104de: 00fc0818 */
/* 106de: 00e009a6 */
#define INDIRECT $80000000
bios_vecs:
        dc.w 12
        dc.l _getmpb
        dc.l _bbconstat
        dc.l _bbconin
        dc.l _bbconout
        dc.l _hdv_rw+INDIRECT /* Rwabs */
        dc.l _setexc
        dc.l _tickcal
        dc.l _hdv_bpb+INDIRECT /* Getbpb */
        dc.l _bbcostat
        dc.l _hdv_mediach+INDIRECT /* Mediach */
        dc.l _drvmap
        dc.l _kbshift

/* ------ jump table for XBIOS functions: */
/* 306de: 00e00e2c */
/* 206de: 00e00dd6 */
/* 104de: 00fc084a */
/* 106de: 00e009d8 */
xbios_vecs:
        dc.w (xbvecsend-xbios_vecs)/4
        dc.l _initmouse
        dc.l bios_unimpl /* Ssbrk */
        dc.l _physbase
        dc.l _logbase
        dc.l _getrez
        dc.l _vsetscreen
        dc.l _setpalette
        dc.l _setcolor
        dc.l _floprd
        dc.l _flopwrt
        dc.l _flopfmt
        dc.l _dbmsg
        dc.l _midiws
        dc.l _mfpint
        dc.l _iorec
        dc.l _rsconf
        dc.l _keytbl
        dc.l _random
        dc.l _protobt
        dc.l _flopver
        dc.l _scrdmp
        dc.l _cursconf
        dc.l _settime
        dc.l _gettime
        dc.l _bioskeys
        dc.l _ikbdws
        dc.l _jdisint
        dc.l _jenabint
        dc.l _giaccess
        dc.l _offgibit
        dc.l _ongibit
        dc.l _xbtimer
        dc.l _dosound
        dc.l _setprt
        dc.l _kbdvbase
        dc.l _kbrate
        dc.l _prtblk
        dc.l _vsync
        dc.l _supexec
        dc.l _puntaes
        dc.l bios_unimpl
        dc.l _floprate
#if TP_64 /* IDE_BOOT */
        dc.l dmaread
#else
        dc.l bios_unimpl
#endif
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l bios_unimpl
        dc.l _blitmode
xbvecsend:



/*
 * XBIOS #26 - Supexec - Start routine in supervisor-mode.
 *
 * 'codeptr' points to a piece of code, ending in an RTS, that is
 * executed in supervisor mode. The executed code cannot perform
 * BIOS or GEMDOS calls. This function is meant to allow programs
 * to hack hardware and protected locations without having to fiddle
 * with GEMDOS get/set supervisor mode call.
 */
/* 306de: 00e00fd0 */
/* 206de: 00e00edc */
/* 104de: 00fc0950 */
_supexec:
        movea.l   4(a7),a0
        jmp       (a0)


/*
 * Character device I/O
 *
 * No check is made for "bogus" device numbers.  A wierd device
 * number will result in a crash.
 *
 */

/*
 * BIOS #1 - Bconstat - Status of input device
 *
 * Arguments:
 *   handle - device handle (0:PRT 1:AUX 2:CON)
 *
 *
 * Returns status in D0.L:
 *  -1  device is ready
 *   0  device is not ready
 */
/* 306de: 00e00fd6 */
/* 206de: 00e00ee2 */
/* 104de: 00fc0956 */
_bbconstat:
        lea.l     ABSW(_bconstat_vec),a0
        bra.s     doxconxx

/*
 * BIOS #2 - Bconin  - Get character from device
 *
 * Arguments:
 *   handle - device handle (0:PRT 1:AUX 2:CON)
 *
 * This function does not return until a character has been
 * input.  It returns the character value in D0.L, with the
 * high word set to zero.  For CON:, it returns the GSX 2.0
 * compatible scan code in the low byte of the high word, &
 * the ASCII character in the lower byte, or zero in the
 * lower byte if the character is non-ASCII.  For AUX:, it
 * returns the character in the low byte.
 */
/* 306de: 00e00fde */
/* 206de: 00e00eea */
/* 104de: 00fc095c */
_bbconin:
        lea.l     ABSW(_bconin_vec),a0
        bra.s     doxconxx

/*
 * BIOS #8 - Bcostat - Read status of output device
 *
 * Returns status in D0.L:
 * -1   device is ready
 * 0    device is not ready
 */
/* 306de: 00e00fe6 */
/* 206de: 00e00ef2 */
/* 104de: 00fc0962 */
_bbcostat:
        lea.l     ABSW(_bcostat_vec),a0
        bra.s     doxconxx

/*
 * BIOS #3 - Bconout - Print character to output device
 */
/* 306de: 00e00fee */
/* 206de: 00e00efa */
/* 104de: 00fc0968 */
/* 106de: 00e00af6 */
_bbconout:
        lea.l     ABSW(_bconout_vec),a0

doxconxx:
        move.w    4(a7),d0            /* get device number */
        lsl.w     #2,d0             /* turn into longword index */
        movea.l   0(a0,d0.w),a0     /* get address of handler */
        jmp       (a0)              /* jump to it */


/*
 * Jump tables for
 *       0 - lst: (printer)
 *       1 - aux: (rs232)
 *       2 - con: (screen)
 *       3 - Atari midi
 *       4 - Atari keyboard (output only)
 *       5 - raw console output (bypass vt52 pressure cooker)
 *
 * No range checking is performed.  If a bogus device number
 * is passed to the BIOS' character I/O handler, the system
 * will crash to become funky duex.
 *
 */
/* 306de: 00e01024 */
/* 206de: 00e00f30 */
/* 104de: 00fc0978 */
/* 106de: 00e00b06 */
/* 404: 00e00e56 */
tconstat:
        dc.l      bios_unimpl
        dc.l      _bcon6stat    /* BIOS device 1 (AUX) defaults to RS232 port */
        dc.l      _bcon2stat
        dc.l      _bcon3stat
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      _bcon0in
        dc.l      _bcon6in      /* BIOS device 1 (AUX) defaults to RS232 port */
        dc.l      _bcon2in
        dc.l      _bcon3in
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      _bco0stat
        dc.l      _bco6stat     /* BIOS device 1 (AUX) defaults to RS232 port */
        dc.l      _bco2stat
        dc.l      _bco4stat     /* BUG compatibility with early TOS versions: MIDI(3) and KBD(4) are swapped */
        dc.l      _bco3stat
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      bios_unimpl
        dc.l      _bcon0out
        dc.l      _bcon6out     /* BIOS device 1 (AUX) defaults to RS232 port */
        dc.l      _bcon2out
        dc.l      _bcon3out
        dc.l      _bcon4out
        dc.l      _bcon5out
        dc.l      bios_unimpl
        dc.l      bios_unimpl

/*
 * BIOS #10 - Drvmap - Read drive bitmap
 *
 * Returns a long containing a bit map of logical drives on the system,
 * with bit 0, the least significant bit, corresponding to drive A.
 * Note that if the BIOS supports logical drives A and B on a single
 * physical drive, it should return both bits set if a floppy drive is
 * present.
 */
/* 306de: 00e010a4 */
/* 206de: 00e00fb0 */
/* 104de: 00fc09f8 */
/* 106de: 00e00b86 */
_drvmap:
        move.l    ABSW(_drvbits),d0
        rts

/*
 *  BIOS #11 - Kbshift - Shift Key mode get/set.
 *
 *  two descriptions:
 *      o       If 'mode' is non-negative, sets the keyboard shift bits
 *              accordingly and returns the old shift bits.  If 'mode' is
 *              less than zero, returns the IBM0PC compatible state of the
 *              shift keys on the keyboard, as a bit vector in the low byte
 *              of D0
 *      o       The flag parameter is used to control the operation of
 *              this function.  If flag is not -1, it is copied into the
 *              state variable(s) for the shift, control and alt keys,
 *              and the previous key states are returned in D0.L.  If
 *              flag is -1, then only the inquiry is done.
 */
/* 306de: 00e010aa */
/* 206de: 00e00fb6 */
/* 104de: 00fc09fe */
/* 106de: 00e00b8c */
_kbshift:
        moveq.l   #0,d0
        move.b    ABSW(_shifty),d0
        move.w    4(a7),d1
        bmi.s     kbshift1
        move.b    d1,ABSW(_shifty)
kbshift1:
        rts

/*
 * BIOS #0 - Getmpb - Load Memory parameter block
 *
 * Returns values of the initial memory parameter block, which contains the
 * start address and the length of the TPA.
 * Just executed one time, before GEMDOS is loaded.
 *
 * Arguments:
 *   mpb - first memory descriptor, filled from BIOS
 *
 */
/* 306de: 00e010bc */
/* 206de: 00e00fc8 */
/* 104de: 00fc0a10 */
/* 106de: 00e00b9e */
_getmpb:
        movea.l   4(a7),a0
        lea.l     ABSW(_themd),a1
/* --- initialize MPB: */
        move.l    a1,(a0)            /* mp_mfl = &themd; */
        clr.l     4(a0)              /* mp_mal = NULL; */
        move.l    a1,8(a0)           /* mp_rover = &themd; */
/* ---- initialize MD: */
        clr.l     (a1)               /* themd.m_link = NULL; */
        move.l    ABSW(_membot),4(a1)  /* themd.m_start = membot; */
        move.l    ABSW(_memtop),d0
        sub.l     ABSW(_membot),d0
        move.l    d0,8(a1)           /* themd.m_length = memtop - membot; */
        clr.l     12(a1)             /* themd.m_own = NULL; */

        rts

/*
 * BIOS #5 - Setexc - set exception vector
 * Synopsis:     setexc(vecno, addr)
 *               If 'addr' < 0, the vector is not set.
 *
 *               Extended vectors ($100 though $107) are located in the
 *               first eight longwords of BSS, at $400. This is for
 *               convienience -- they could really be located anywhere.
 *
 * Returns:      D0.L = original vector value
 *
 */
/* 306de: 00e01124 */
/* 206de: 00e00ff4 */
/* 104de: 00fc0a3c */
/* 106de: 00e00bca */
_setexc:
        move.w    4(a7),d0          /* d0 = vector # */
        lsl.w     #2,d0             /* turn into longword index */
        suba.l    a0,a0
        lea.l     0(a0,d0.w),a0     /* a0 -> vector */
        move.l    (a0),d0           /* d0 = current vector address */
        move.l    6(a7),d1          /* d1 = what_to_change_it_to */
        bmi.s     setexc1           /* punt if (d1 < 0) */
        move.l    d1,(a0)           /* set vector address */
setexc1:
        rts

/*
 * BIOS #6 - Tickcal - return system timer calibration value (in ms)
 */
/* 306de: 00e0113c */
/* 206de: 00e0100c */
/* 104de: 00fc0a54 */
/* 106de: 00e00be2 */
_tickcal:
        moveq.l   #0,d0
        move.w    ABSW(_timer_ms),d0
        rts

/*
 * XBIOS #2 - Physbase - Get the screen's physical base address
 *
 * (at the beginning of the next vblank).
 */
/* 306de: 00e01144 */
/* 206de: 00e01014 */
/* 104de: 00fc0a5c */
/* 106de: 00e00bea */
_physbase:
        moveq.l   #0,d0             /* cleanup pointer-to-be */
        move.b    ABSW(v_bas_h),d0    /* load and shift bits 16..23 */
        lsl.w     #8,d0
        move.b    ABSW(v_bas_m),d0    /* load and shift bits 8..15 */
        lsl.l     #8,d0
#if TOSVERSION >= 0x106
        move.b    ABSW(v_bas_l),d0    /* load bits 0..7 */
#endif
        rts

/*
 * XBIOS #3 - Logbase - Get the screen's logical base, right away.
 *
 * This is the location that GSX uses when drawing to the screen.
 */
/* 306de: 00e01160 */
/* 206de: 00e01030 */
/* 104de: 00fc0a6c */
/* 106de: 00e00bfe */
_logbase:
        move.l    ABSW(_v_bas_ad),d0
        rts

/*
 * XBIOS #4 - Getrez - Get the screen's current resolution
 *
 * Returns 0, 1, 2, 4, 5 or 6.
 */
/* 306de: 00e01166 */
/* 206de: 00e01036 */
/* 104de: 00fc0a72 */
/* 106de: 00e00c0a */
_getrez:
        moveq.l   #0,d0
		move.b    ABSW(v_shf_mod),d0          /* get screen rezolution */
        and.b     #3,d0                     /* strip garbage bits */
        rts

/*
 * XBIOS #5 - Setscreen/VsetScreen - Set the screen locations
 *
 * Set the logical screen location (logLoc), the physical screen location
 * (physLoc), and the physical screen resolution. Negative parameters are
 * ignored (making it possible, for instance, to set screen resolution without
 * changing anything else). When resolution is changed, the screen is cleared,
 * the cursor is homed, and the VT52 terminal emulator state is reset.
 */
/* 306de: 00e01172 */
/* 206de: 00e01042 */
/* 104de: 00fc0a7e */
/* 106de: 00e00c10 */
_vsetscreen:
/* --- set logical location: */
        tst.l     4(a7)                      /* if(logloc < 0) then ignore it */
        bmi.s     nosetl
        move.l    4(a7),ABSW(_v_bas_ad)
nosetl:
/* --- set physical location: */
        tst.l     8(a7)                      /* if(physloc < 0) then ignore it */
        bmi.s     nosetp
        move.b    9(a7),ABSW(v_bas_h)
        move.b    10(a7),ABSW(v_bas_m)
#if TOSVERSION >= 0x106
        move.b    11(a7),ABSW(v_bas_l)
#endif
nosetp:
/* --- set screen resolution (clears the screen, clobbers the cursor): */
        tst.w     12(a7)                     /* if(rez < 0) then ignore it */
        bmi.s     nosetr
        move.b    13(a7),ABSW(_sshiftmod)      /* set software shadow */
        bsr       _vsync
        move.b    ABSW(_sshiftmod),ABSW(v_shf_mod) /* set hardware location */
        clr.w     ABSW(_vblsem)                /* disable vblank processing */
        jsr       esc_init                   /* re-initialize glass tty routines */
        move.w    #1,ABSW(_vblsem)             /* re-enable vblanks */
nosetr:
        rts

/*
 * XBIOS #6 - Setpalette - Set the contents of the hardware palette register
 *
 * (all 16 color entries) from the 16 words pointed to by 'palettePtr'.
 * 'paletteptr' MUST be on a word boundary. The palette assignment takes
 * place at the beginning of the next vertical blank interrupt.
 */
/* 306de: 00e011c8 */
/* 206de: 00e0108e */
/* 104de: 00fc0ac4 */
/* 106de: 00e00c5c */
_setpalette:
        move.l    4(a7),ABSW(_colorptr)     /* next VBL will do this */
        rts

/*
 * XBIOS #7 - Setcolor - Set the palette number
 *
 * Set the palette number 'colorNum' in the hardware palette table to the
 * specified 'color'. If 'color' is negative, the hardware register is not
 * changed.
 *
 * Return the old color.
 */
/* 306de: 00e011d0 */
/* 206de: 00e01096 */
/* 104de: 00fc0acc */
/* 106de: 00e00c64 */
_setcolor:
        move.w    4(a7),d1                   /* get color number */
        add.w     d1,d1                      /* turn into word index */
        and.w     #$001F,d1                  /* force color range (prevent buserr) */
        lea.l     ABSW(palette),a0             /* a0 -> base of palette memory */
        move.w    0(a0,d1.w),d0              /* return old color */
#if TOSVERSION >= 0x106
        and.w     #$0FFF,d0                  /* mask dirty bits */
#else
        and.w     #$0777,d0                  /* mask dirty bits */
#endif
        tst.w     6(a7)                      /* if new color is <0, don't set it */
        bmi.s     setcol3                    /* (punt) */
        move.w    6(a7),0(a0,d1.w)           /* set new color */
setcol3:
        rts

/*
 * XBIOS #27 - Puntaes - Throws away the AES, freeing up any memory it used.
 *
 * If the AES is still resident, it will be discarded and the system
 * will reboot. If the AES is not resident (if it was discarded earlier)
 * the function will return.
 */
/* 306de: 00e01202 */
/* 206de: 00e010c8 */
/* 104de: 00fc0af0 */
_puntaes:
        movea.l   _os_magic(pc),a0           /* get pointer to magic */
        cmpi.l    #$87654321,(a0)            /* is the magic still there? */
        bne.s     puntaes1                   /* no -- just return */
        cmpa.l    ABSW(_phystop),a0            /* is it in ROM? */
        bge.s     puntaes1                   /* yes -- we can't do anything about it */
        clr.l     (a0)                       /* clobber AES! */
        bra       _main                      /* restart the system */
puntaes1:
        rts


/*
 * _term - terminate current process
 * Called-by:    Uncaught traps (bus errors, and so on)
 * Saves:        processor state (in a bailout area)
 */
/* 306de: 00e0121c */
/* 206de: 00e010e2 */
/* 104de: 00fc0b0a */
any_vec:
#if P68000 | (TOSVERSION < 0x200)
		bsr.s     savp_2                     /* stack PC */
		nop
savp_2:
		SETBASEREG
		move.l    (sp)+,ABSW(_proc_enum)       /* save bogus PC + exception number */
#else
#if !P68010
		jsr       savp_2                     /* stack PC */
savp_2:
		SETBASEREG
		move.l    (sp)+,ABSW(_proc_enum)       /* save bogus PC + exception number */
#endif
#endif
/* dump the registers, including SSP */
        movem.l   d0-d7/a0-a7,ABSW(_proc_dregs)
#if P68010
        move.l    2(a7),ABSW(_proc_enum)
/* get the exception number from the format word */
        move.w    6(a7),d0
        and.w     #$0FFF,d0
        asr.w     #2,d0
/* dump the exception number */
        move.b    d0,ABSW(_proc_enum)
#endif
/* dump the correct value for USP */
        move.l    usp,a0
        move.l    a0,ABSW(_proc_usp)
/* dump 16 words from the stack */
        moveq.l   #15,d0
        lea.l     ABSW(_proc_stk),a0
        movea.l   a7,a1
any_vec1:
        move.w    (a1)+,(a0)+
        dbf       d0,any_vec1
/* magic value */
        move.l    #$12345678,ABSW(_proc_lives)

/* --- draw an appropriate number of 'shrooms on the screen: */
        moveq.l   #0,d1
        move.b    ABSW(_proc_enum),d1
        subq.w    #1,d1
        bsr.s     drawbombs
/* restore a sane stack (should have probably been done before calling subroutine above) */
        move.l    #save_beg+save_siz,ABSW(_savptr)        /* clobber BIOS top level */
        move.w    #-1,-(a7)                             /* "error" return condition */
        move.w    #$004C,-(a7)                          /* Pterm */
        trap      #1
        bra       _main

/*
 * do_shroom - draw little mushroom clouds on the screen
 *  Passed:      d1.w = #shrooms to draw (DBRA count)
 *  Returns:     some shrooms on display
 *  Uses:        d0-d7/a0-a2
 *
 *  Discussion:  The graphics ain't all that great.   And this is silly.
 *
 */
/* 104de: 00fc0b56 */
/* 106de: 00e00cee */
drawbombs:
        move.b    ABSW(v_shf_mod),d7
        and.w     #3,d7
        add.w     d7,d7                      /* d7 = rez index */
        moveq.l   #0,d0
        move.b    ABSW(v_bas_h),d0
        lsl.w     #8,d0
        move.b    ABSW(v_bas_m),d0
        lsl.l     #8,d0
#if TOSVERSION >= 0x106
        move.b    ABSW(v_bas_l),d0
#endif
drawbo1:
        movea.l   d0,a0                      /* a0 -> base of mem to draw at */
        adda.w    bofftab(pc,d7.w),a0
drawbo3:
        lea.l     bombimage,a1               /* a1 -> source from */
        move.w    #$000F,d6                  /* d6 = scanline count */
drawbo4:
        move.w    d1,d2                      /* d2 = # to draw on this line */
        movea.l   a0,a2                      /* safe ptr to beg of line */
drawbo5:
        move.w    dplanetab(pc,d7.w),d5      /* d5 = #words to replicate */
drawbo6:
        move.w    (a1),(a0)+
        dbf       d5,drawbo6
        dbf       d2,drawbo5                 /* another, on the same line */
        addq.w    #2,a1                      /* next source word */
        adda.w    dwidthtab(pc,d7.w),a2      /* next dest line */
        movea.l   a2,a0
        dbf       d6,drawbo4
        rts
bofftab:
		dc.w      ((320*200*4)/8)/2,((640*200*2)/8)/2,((640*400)/8)/2,((640*400)/8)/2
dplanetab:        /* number of planes - 1, indexed by resolution */
        dc.w      3,1,0,0
dwidthtab:        /* number of bytes per screen line, indexed by resolution */
        dc.w      320*4/8,640*2/8,640/8,640/8


/*
 * _fastcpy - "fast" 512-byte copy
 * Synopsis:     void cpy512(const void *src, void *dst)
 *
 *               Used by _rwabs to fake disk DMA to odd addresses.  Therefore,
 *               disk I/O on odd addresses is very slow.  Lose, lose.
 *
 */
		xdef _cpy512
_cpy512:
        movea.l   4(a7),a0
        movea.l   8(a7),a1
        move.w    #(512/8)-1,d0
cpy512l:
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        move.b    (a0)+,(a1)+
        dbf       d0,cpy512l
        rts


/*
 * call the routine installed in system vector hdv_init.
 * By default, this will be bhdv_init
 */
		xdef _chdv_init
_chdv_init:
        move.l    _hdv_init,-(a7)
        rts

autopath:                      dc.b $5c,'AUTO',$5c
autoname:                      dc.b '*.PRG',0
        dc.l $12345678,$9abcdef0


/*
 * _auto - exec auto-startup files in the appropriate subdirectory
 * _auto1 - exec (with filename args)
 * Passed:       a0 -> full filespec (pathname)
 *               a1 -> filename part of filespec
 *               _drvbits: bit vector of active drives
 *               _bootdev: contains device to exec from
 *
 * Returns:      nothing
 *
 * Note:         If _drvbits%%_bootdev is zero, _auto simply quits (since
 *               the device isn't active....)
 *
 * Uses:         everything
 */
/* 306de: 00e0133c */
/* 206de: 00e011f6 */
/* 104de: 00fc0bf4 */
/* 106de: 00e00d90 */
autoexec:
        lea.l     autopath(pc),a0
        lea.l     autoname(pc),a1
_auto1: move.l    (a7)+,savepc              /* return addr (used by execlr) */
		SETBASEREG
        move.l    a0,ABSW(execpath)
        move.l    a1,ABSW(execname)
        move.l    ABSW(_drvbits),d0           /* d0 - active dev vector */
        move.w    _bootdev,d1               /* d1 - dev# to exec from */
        btst      d1,d0                     /* is the dev alive? */
        beq.s     autoexe1                  /* (no -- so punt) */
        lea.l     emptystr(pc),a0
        move.l    a0,-(a7)                  /* null environment */
        move.l    a0,-(a7)                  /* null command tail */
        move.l    a0,-(a7)                  /* null shell name */
        move.w    #$0005,-(a7)
        move.w    #$004B,-(a7)
        trap      #1                        /* Pexec(5) Create basepage */
        adda.w    #16,a7
        movea.l   d0,a0
        move.l    #autoscan,8(a0)           /* set bp->p_tbase */
        move.l    a3,-(a7)                  /* null environment */
        move.l    d0,-(a7)                  /* -> PSP */
        move.l    a3,-(a7)                  /* null shell name */
        move.w    #$0004,-(a7)
        move.w    #$004B,-(a7)
        trap      #1                        /* Pexec(Just go), execute the autoscan routine */
        adda.w    #16,a7
autoexe1:
        move.l    savepc,-(a7)
autoexe2:
        rts

/*
 * fauto - exec'd by _auto to do autostartup
 *
 * Passed:       pathname -> path part of filespec
 *               filename -> file path of filespec
 *
 */
autoscan:
        clr.l     -(a7)
        move.w    #$0020,-(a7)
        trap      #1              /* Super */
        addq.w    #6,a7
        movea.l   d0,a4

/* ---- free up some memory */
        movea.l   4(a7),a5                      /* get ptr to Basepage */
        lea.l     256(a5),a7                    /* set stack to end of commandline */
        move.l    #$00000100,-(a7)              /* sizeof(PD) */
        move.l    a5,-(a7)
        clr.w     -(a7)
        move.w    #$004A,-(a7)                  /* Mshrink to basepage only */
        trap      #1
#if TP_15
        /* swedish/czech versions have the STACK_POINTER patch applied */
		adda.w    #12,a7
        tst.w     d0
        bne.s     autosca4                      /* if Mshrink failed, done */
        move.w    #7,-(a7)
        move.l    (execpath).w,-(a7)
#else
        addq.w    #6,a7
        tst.w     d0
        bne.s     autosca4                      /* if Mshrink failed, done */
        move.w    #7,-(a7)                      /* find r/o+hidden+system files */
        move.l    execpath,-(a7)                /* -> filename (on input) */
#endif
        move.w    #$004E,-(a7)                  /* Fsfirst */
        moveq.l   #8,d7
autosca1:
        pea.l     execdta                       /* setup DTA (for search) */
        move.w    #$001A,-(a7)
        trap      #1                            /* Fsetdta */
        addq.w    #6,a7
        trap      #1
        adda.w    d7,a7
        tst.w     d0                            /* Path found? */
        bne.s     autosca4                      /* no, done */
/* copy path of autofolder, and append found name to it */
        movea.l   execpath,a0
        movea.l   execname,a2
        lea.l     execfname,a1
autosca2:
        move.b    (a0)+,(a1)+
        cmpa.l    a0,a2
        bne.s     autosca2
        lea.l     execdta+30,a0
autosca3:
        move.b    (a0)+,(a1)+
        bne.s     autosca3
/* execute the program */
        pea.l     emptystr(pc)                  /* null enviroment */
        pea.l     emptystr(pc)                  /* no command tail */
        pea.l     execfname                     /* -> file to exec */
        clr.w     -(a7)
        move.w    #$004B,-(a7)
        trap      #1                            /* Pexec(Load&Go) */
        adda.w    #$0010,a7
        moveq.l   #2,d7
        move.w    #$004F,-(a7)                  /* Fsnext */
        bra.s     autosca1

/*
 * The first GEMDOS process can never terminate.
 * This is not a good feature.
 * Kludge around it - re-initialize the stack
 * and return to the guy who called us to begin with.
 *
 */
autosca4:
        lea.l     SUPSIZ*2+_supstk,a7          /* setup supervisor stack */
        move.l    savepc,-(a7)                 /* get return addr */
        rts


#include "scrdmp.inc"
		text

/* --- what it is: */
/* 306de: 00e014f6 */
/* 206de: 00e013b2 */
/* 104de: 00fc0da2 */
/* 106de: 00e00f3e */
bombimage:
#if TP_16 == 0 /* Bomb */
        dc.b $06,$00,$29,$00,$00,$80,$48,$40,$11,$f0,$01,$f0,$07,$fc,$0f,$fe
        dc.b $0d,$fe,$1f,$ff,$1f,$ef,$0f,$ee,$0f,$de,$07,$fc,$03,$f8,$00,$e0
#endif
#if TP_16 == 1 /* PILZE */
        dc.b $07,$c0,$1f,$f0,$3b,$f8,$77,$f4,$b7,$fa,$bb,$fa,$df,$f6,$66,$fc
        dc.b $32,$88,$02,$80,$04,$40,$04,$40,$05,$40,$05,$20,$09,$20,$09,$20
#endif
#if TP_16 == 2 /* Atari logo */
		dc.b $00,$00,$05,$a0,$05,$a0,$05,$a0,$05,$a0,$05,$a0,$05,$a0,$0d,$b0
		dc.b $0d,$b0,$1d,$b8,$3d,$bc,$f9,$9f,$f9,$9f,$f1,$8f,$e1,$87,$00,$00
#endif
#if TP_16 == 3 /* Pfeifenkopf */
		dc.b $07,$f0,$0f,$f8,$1f,$ec,$18,$04,$18,$04,$10,$04,$1e,$3c,$17,$54
		dc.b $11,$04,$0b,$28,$0d,$d8,$06,$28,$07,$d0,$2e,$10,$39,$e0,$38,$00
#endif
#if TP_16 == 4 /* Stinkefinger */
		dc.b $0c,$00,$12,$00,$11,$00,$09,$00,$09,$f0,$04,$a8,$1c,$a4,$26,$54
		dc.b $22,$04,$28,$04,$3c,$04,$44,$02,$40,$02,$30,$02,$0e,$02,$01,$01
#endif
#if TP_16 == 5 /* Skull */
		dc.b $07,$E0,$08,$10,$16,$68,$16,$68,$10,$08,$09,$90,$08,$10,$0B,$D0
		dc.b $04,$20,$33,$CC,$2C,$34,$13,$C8,$0C,$30,$13,$C8,$2C,$34,$30,$0C
#endif

/*
 * waitvbl - wait for the beam inside the vertical blank area
 */
/* 206de: 00e013d2 */
/* 104de: 00fc0dc2 */
/* 106de: 00e00f5e */
waitvbl:    lea       MFP_TBDR,a0           /* a0 -> timer B data register */
            lea       MFP_TBCR,a1           /* a1 -> timer B control register */
            move.b    #$10,(a1)             /* reset timer B */
            moveq     #1,d4                 /* wait for the timer to expire */
            move.b    #0,(a1)               /* stop timer B */
            move.b    #$f0,(a0)             /* event every 240 scan lines */
            move.b    #8,MFP_TBCR           /* timer b: event count mode (HBL) */
waitvbl2:   move.b    (a0),d0
            cmp.b     d4,d0                 /* wait for HBL 239 scan lines to pass */
            bne.s     waitvbl2
waitvbl3:   move.b    (a0),d4
            move.w    #615,d3               /* wait till we are inside the vbl area */
waitvbl4:   cmp.b     (a0),d4
            bne.s     waitvbl3
            dbra      d3,waitvbl4
            move.b    #$10,(a1)             /* timer b: reset */
            jmp       (a6)


/*
 * run_reset_resident - run "reset-resident" code
 *
 * "Reset-resident" code is code that has been loaded into RAM prior
 * to a warm boot.  It has a special header with a magic number, it
 * is 512 bytes long (aligned on a 512-byte boundary), and it has a
 * specific checksum (calculated on a word basis).
 *
 * Note: this is an undocumented feature of TOS that exists in all
 * versions of Atari TOS.
 */
/* 306de: 00e01530 */
/* 206de: 00e01408 */
/* 104de: 00fc0dfe */
/* 106de: 00e00f9a */
run_reset_resident:
        movea.l   _phystop,a0                   /* start at the top of the address space */
run_res1:
        suba.w    #$0200,a0
        cmpa.l    #$0400,a0                     /* reach the lower bottom? */
        beq.s     run_res3                      /* (bail out) */
        cmpi.l    #RR_MAGIC,(a0)                /* check for magic */
        bne.s     run_res1                      /* (no magic -> next block) */
        cmpa.l    4(a0),a0                      /* second long is equal the base address of the block? */
        bne.s     run_res1                      /* (no -> next block) */
        clr.w     d0
        movea.l   a0,a1
        move.w    #$00FF,d1                     /* checksum over 256 words */
run_res2:
        add.w     (a1)+,d0
        dbf       d1,run_res2
        cmp.w     #RR_CHKSUM,d0                 /* magic checksum? */
        bne.s     run_res1                      /* (no -> next block) */
        move.l    a0,-(a7)                      /* save current address */
        jsr       8(a0)                         /* call code block */
        movea.l   (a7)+,a0                      /* continue with next block */
        bra.s     run_res1
run_res3:
        rts

/*
 * XBIOS #17 - Gettime - Gets intelligent keyboard's time and date
 *
 * Returns that value (in DOS format) as a 32-bit word.
 * (Time in the low word, date in the high word).
 */
/* 306de: 00e0156e */
/* 206de: 00e01446 */
/* 104de: 00fc0e3e */
/* 106de: 00e00fda */
_gettime:
        lea.l     readRTCTime,a3
        lea.l     igetdt,a4
        bra.s     gsettime

/*
 * XBIOS #16 - Settime - Sets the intelligent keyboard's time and date.
 *
 * 'datetime' is a 32-bit DOS-format date and time (time in the low word,
 * date in the high word).
 */
/* 306de: 00e0157c */
/* 206de: 00e01454 */
/* 104de: 00fc0e4c */
/* 106de: 00e00fe8 */
_settime:
#if TP_17 /* LOCK_CLOCK */
        lea.l     retzero,a3
#else
        lea.l     writeRTCTime,a3
#endif
        lea.l     isetdt,a4
gsettime:
        bsr       checkRTC
        bcc.s     gsettim1
        movea.l   a4,a3
gsettim1:
        jmp       (a3)


/*
 * copy sysbase into memory and patch it
 */
/* 306de: 00e015a2 */
/* 206de: 00e0147a */
/* 104de: 00fc0e62 */
/* 106de: 00e00ffe */
instoshdr:
        lea.l     _os_entry(pc),a0
        lea.l     oshdr+6,a1
        moveq.l   #47,d0
instos1:
        move.b    0(a0,d0.w),0(a1,d0.w)
        dbf       d0,instos1
        move.w    jmpop(pc),-6(a1)              /* copy JMP instruction just before */
        move.l    4(a1),-4(a1)                  /* copy ROM reseth into this JMP */
        move.w    braop(pc),(a1)                /* patch BRA at the beginning of sysbase copy to hit the JMP */
        move.w    30(a1),28(a1)                 /* copy os_date into os_conf WTF? */
        move.l    a1,_sysbase                   /* set new sysbase pointer */
        rts
jmpop:
        jmp       $00000000.l
braop:
        bra.s     jmpop


/*
 * XBIOS #40 - Blitmode
 *
 * Returns: d0.w - bit 0 - blitter enabled
 *                 bit 1 - blitter available
 */
/* 306de: 00e015dc */
/* 206de: 00e014b4 */
/* 104de: 00fc0e9e */
/* 106de: 00e0103a */
_blitmode:
        bsr.s     blittest                      /* test if blitter is installed */
        move.w    d0,d4                         /* d4 = blitter status */
        move.w    d0,d5
        lsr.w     #1,d5
        or.w      #$FFFE,d5                     /* d5 = blitter enable mask */
        jsr       _GETBLT
        move.w    d0,d3                         /* d3 = blitter active */
        move.w    4(a7),d0                      /* new blitter status */
        bmi.s     blitmod1                      /* <0 just return the status */
        and.w     d5,d0                         /* mask blitter status out */
        or.w      d4,d0                         /* or'd blitter available status */
        jsr       _SETBLT                       /* disable/enable blitter */
blitmod1:
        move.w    d3,d0
        rts

/*
 * blittest - test if the blitter is installed
 */
/* 306de: 00e01604 */
/* 206de: 00e014dc */
/* 104de: 00fc0ec6 */
/* 106de: 00e01062 */
blittest:
        move.w    sr,d1
        move.w    #0,d0                         /* d0 = 0 -> blitter not installed */
        suba.l    a0,a0
        movea.l   a7,a2
        ori.w     #$0700,sr
        movea.l   _buserror(a0),a1
        move.l    #noblitter,_buserror(a0)
        tst.w     $ffff8a00(a0)
        moveq.l   #2,d0                         /* d0 = 2 -> blitter installed */
noblitter:
        move.l    a1,_buserror(a0)
        move.w    d1,sr
        movea.l   a2,a7
        rts

#if TP_64
#include "ideboot/ideboot.S"
#endif

		text

		bss

		xdef gem_env
		comm gem_env,12

		xdef save_beg
		comm save_beg,save_siz

		xdef oshdr
		comm oshdr,70 /* 6+48+16 */

#if TOSVERSION >= 0x106
		xdef cookies
		comm cookies,NCOOKIES*2*4
#endif

		xdef _pbdef
		comm _pbdef,30

		xdef midiiorec
		comm midiiorec,14
		xdef midibuf
		comm midibuf,SERIAL_BUFSIZE

		xdef ikbdiorec
		comm ikbdiorec,14
		xdef ikbdbuf
		comm ikbdbuf,128

		xdef _kbdvecs
		comm _kbdvecs,42

		xdef execname
		comm execname,4

		xdef execpath
		comm execpath,4

		xdef execfname
		comm execfname,32

		xdef _tim_c_sieve
		comm _tim_c_sieve,2
		
		xdef _shifty
		comm _shifty,1

		xdef execdta
		comm execdta,44

		xdef _sndtmp
		comm _sndtmp,1
		
		xdef _snddelay
		comm _snddelay,1
		
		xdef _sndtable
		comm _sndtable,4
		
		xdef _prtconfig
		comm _prtconfig,2
		
		xdef _bootpref
		comm _bootpref,2

		xdef dsb
		comm dsb,16

		xdef kbdbuf
		comm kbdbuf,7
		xdef mousebuf
		comm mousebuf,5
		xdef relmbuf
		comm relmbuf,3
		xdef clockbuf
		comm clockbuf,6
		xdef joybuf
		comm joybuf,3
		xdef buttonbuf
		comm buttonbuf,3
		xdef initmbuf
		comm initmbuf,17
		xdef kb_key_last
		comm kb_key_last,1
		xdef kb_ticks
		comm kb_ticks,1
		xdef kb_delay
		comm kb_delay,1
		xdef kb_initial
		comm kb_initial,1
		xdef kb_repeat
		comm kb_repeat,1
		
		xdef savepc
		comm savepc,4

		xdef lst_timeout
		comm lst_timeout,4
		
		xdef rs232ibuf
		comm rs232ibuf,SERIAL_BUFSIZE
		xdef rs232obuf
		comm rs232obuf,SERIAL_BUFSIZE
		xdef rs232iorec
		comm rs232iorec,36

		xdef _curkeytbl
		comm _curkeytbl,12
