#include "config.h"
#include "asmdefs.h"
#include "tosvars.inc"
#include "biosdefs.h"

#ifndef PRNTIMEOUT
#define PRNTIMEOUT 30
#endif

#ifndef CONTERM
#define CONTERM 7
#endif

#define ACIA_IKBD_BASE $fffffc00
#define ACIA_MIDI_BASE $fffffc04

#define ACIA_CTRL 0
#define ACIA_DATA 2

#define SCCA_BASE $FFFF8C81
#define SCCA_CTRL SCCA_BASE+0
#define SCCA_DATA SCCA_BASE+2
#define SCCB_BASE $FFFF8C85
#define SCCB_CTRL SCCB_BASE+0
#define SCCB_DATA SCCN_BASE+2

vme_mask  equ $FFFF8E0D
scu_gp1   equ $FFFF8E09

/* ==== Iorec offsets ======================================================== */

#define buf 0
size    equ 4
head    equ 6
tail    equ 8
low     equ 10
high    equ 12

/* sizeof(IOREC) */
IOREC_SIZE equ 14

rcv       equ 2*IOREC_SIZE+0
wr5       equ 2*IOREC_SIZE+1
highwater equ 2*IOREC_SIZE+2
xoff      equ 2*IOREC_SIZE+3
ctr       equ 2*IOREC_SIZE+4
xonoffc   equ 2*IOREC_SIZE+5
EXTIOREC_SIZE equ 2*IOREC_SIZE+6

BCONMAP_START_HANDLE equ 6

/* ==== Structures =========================================================== */

#define midivec   _kbdvecs+0
#define vkbderr   _kbdvecs+4
#define vmiderr   _kbdvecs+8
#define statvec   _kbdvecs+12
#define mousevec  _kbdvecs+16
#define clockvec  _kbdvecs+20
#define joyvec    _kbdvecs+24
#define midisys   _kbdvecs+28
#define ikbdsys   _kbdvecs+32
#define ikbdstate _kbdvecs+36
#define kbdlength _kbdvecs+37


		text

/**************************************************************************
 *                                                                        *
 * Bcostat function for device 3 (midi)                                   *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       word       midiost()                                             *
 *                                                                        *
 *       returns true/okay to send = -1,  false/not ready = 0             *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02266 */
/* 206de: 00e01f8c */
/* 104de: 00fc326a */
	xdef _bco3stat
_bco3stat:
        moveq.l   #-1,d0
        move.b    ABSW(ACIA_MIDI_BASE+ACIA_CTRL),d2
        btst      #1,d2
        bne.s     bco3sret
retzero:
        moveq.l   #0,d0
bco3sret:
        rts

/**************************************************************************
 *                                                                        *
 * Bconout function for device 3 (midi)                                   *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       void       midiwc(chr)                                           *
 *       word       chr                                                   *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02276 */
/* 206de: 00e01f9c */
	xdef _bcon3out
_bcon3out:
        move.w    6(a7),d1
bcon3o1:
        lea.l     ABSW(ACIA_MIDI_BASE),a1
bcon3o2:
        move.b    ACIA_CTRL(a1),d2
        btst      #1,d2
        beq.s     bcon3o2
        move.b    d1,ACIA_DATA(a1)
        rts


/**************************************************************************
 *                                                                        *
 * XBIOS #12 - Midiws - Write string of characters to the MIDI port.      *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       VOID midiws(uint16_t cnt, const VOIDPTR ptr)                     *
 *       word       size                                                  *
 *       long       ptr                                                   *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e0228c */
/* 206de: 00e01fb2 */
		xdef _midiws
_midiws:
        moveq.l   #0,d3
        move.w    4(a7),d3
        movea.l   6(a7),a2
midiws1:
        move.b    (a2)+,d1
        bsr.s     bcon3o1
        dbf       d3,midiws1
        rts

/**************************************************************************
 *                                                                        *
 * Bconstat function for device 3 (midi)                                  *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       word       midistat()                                            *
 *                                                                        *
 *       -1 signifies true/okay  0 - signifies false/no characters        *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e022a0 */
/* 206de: 00e01fc6 */
	xdef _bcon3stat
_bcon3stat:
        lea.l     ABSW(midiiorec),a0            /* point to midi i/o bufrec */
        lea.l     ABSW(ACIA_MIDI_BASE),a1       /* point to midi register base */
        moveq.l   #-1,d0                        /* set result to true */
        lea.l     head(a0),a2
        lea.l     tail(a0),a3
        cmpm.w    (a3)+,(a2)+                   /* atomic buffer empty test ??? what the hell is atomic here? */
        bne.s     bcon3s1                       /* branch if not, assume d0 is "clr.w"'ed */
        moveq.l   #0,d0                         /* set result to false */
bcon3s1:
        rts

/**************************************************************************
 *                                                                        *
 * Bconin function for device 3 (midi port)                               *
 *                                                                        *
 *       this routine transfers characters from a input queue that is     *
 *       filled by an automatic interrupt routine.  the interrupt         *
 *       routine handles the actual transfer of the character from the    *
 *       i/o port.                                                        *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       long       midiin()                                              *
 *                                                                        *
 *       long data returned represents upper three bytes of time stramp   *
 *       and least significant byte as data                               *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e022ba */
/* 206de: 00e01fe0 */
/* assume that a0/a1 are inited by the midstat call for the rest of */
/* this routine. */
	xdef _bcon3in
_bcon3in:
        bsr.s     _bcon3stat                    /* see if byte available */
        tst.w     d0
        beq.s     _bcon3in                      /* wait until byte comes in */
        move.w    sr,-(a7)                      /* protect this upcoming test */
        ori.w     #$0700,sr
        move.w    head(a0),d1                   /* get current head pointer offset from buffer */
        cmp.w     tail(a0),d1                   /* head=tail? */
        beq.s     bcon3i2                       /* yes */
/* check for wrap of pointer */
        addq.w    #1,d1                         /* i=j+1 */
        cmp.w     size(a0),d1                   /* ? i>= current bufsiz? */
        bcs.s     bcon3i1                       /* no... */
        moveq.l   #0,d1                         /* wrap pointer */
bcon3i1:
        movea.l   buf(a0),a1                    /* get base address of buffer */
        and.l     #$0000FFFF,d1
        move.b    0(a1,d1.l),d0                 /* get character */
        move.w    d1,head(a0)                   /* store new head pointer to buffer record */
bcon3i2:
        move.w    (a7)+,sr
        rts

/**************************************************************************
 *                                                                        *
 * Bconout function for device 0 (parallel i/o port)                      *
 *                                                                        *
 *       this set of routines is for general parallel i/o                 *
 *                                                                        *
 *       entry to listout                                                 *
 *                                                                        *
 *       entry to listin                                                  *
 *                                                                        *
 *       exit from listin                                                 *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e022ee */
/* 206de: 00e02016 */
/* 104de: 00fc32f6 */
	xdef _bcon0out
_bcon0out:
#if BINEXACT
/* BUG: prtconfig is a word, btst will check in the most significant byte */
        btst      #4,ABSW(_prtconfig)           /* Printer configured for output to RS232? */
#else
        btst      #4,(_prtconfig+1).w           /* Printer configured for output to RS232? */
#endif
        bne       _bcon6out
        move.l    ABSW(_hz_200),d2              /* d2 = hz_200 - prt_to */
        sub.l     ABSW(lst_timeout),d2          /* (compute time since last timeout) */
        cmpi.l    #1000,d2                      /* do "fake" timeout if we timed out within */
        bcs.s     bcon0o2                       /* the last five seconds */
        move.l    ABSW(_hz_200),d2              /* d2 = starting time for this char */
bcon0o1:
        bsr       _bco0stat                     /* go get parallel port status */
        tst.w     d0                            /* ...and check for high (busy) */
        bne.s     bcon0o3                       /* port is ready -- print the char */
        move.l    ABSW(_hz_200),d3              /* d3 = hz_200 - d2 */
        sub.l     d2,d3                         /* check for 30 second delta */
        cmpi.l    #PRNTIMEOUT*200,d3
        blt.s     bcon0o1                       /* continue if no timeout */
bcon0o2:
        moveq.l   #0,d0                         /* return value of 0 indicates timeout */
        move.l    ABSW(_hz_200),ABSW(lst_timeout) /* record time of last timeout */
        rts
bcon0o3:
        move.w    sr,d3
        ori.w     #$0700,sr                     /* protect upcoming switching of the port setting */
        moveq.l   #7,d1                         /* get current io enable register contents */
        bsr       gientry
        ori.b     #$80,d0                       /* set port b for output */
        moveq     #$87,d1                       /* set to write to io enable */
        bsr       gientry
        move.w    d3,sr                         /* restore status register */
        move.w    6(a7),d0                      /* retrieve byte to be sent and... */
        moveq     #$8F,d1                       /* write out byte to parallel port */
        bsr       gientry
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        bsr.s     strobeon
        bsr.s     strobeon
        bsr.s     strobeoff
        move.w    (a7)+,sr
        moveq.l   #-1,d0                        /* set d0=-1 for good transfer status */
        rts

strobeoff:
        moveq.l   #32,d2
        bra       onbit

strobeon:
        moveq     #$DF,d2
        bra       offbit


/*
 * Bconin function for device 0 (printer)
 */
/* 306de: 00e02372 */
/* 206de: 00e0209a */
/* 104de: 00fc3372 */
	xdef _bcon0in
_bcon0in:
        moveq.l   #7,d1                         /* get current io enable register contents */
        bsr       gientry
        andi.b    #$7F,d0                       /* set port b for input */
        moveq     #$87,d1                       /* set to write to io enable */
        bsr       gientry
        bsr.s     strobeoff                     /* busy off! */
bcon0in1:
        bsr.s     _bco0stat                     /* go get parallel port status */
        tst.w     d0                            /* ...and check for high (busy) */
        bne.s     bcon0in1                      /* loop till high... */
        bsr.s     strobeon
        moveq.l   #15,d1                        /* init to use gientry routine to read */
        bra       gientry                       /* now get the byte from the parallel port */

/**************************************************************************
 *                                                                        *
 * Bcostat function for device 0 (printer)                                *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02394 */
/* 206de: 00e020bc */
/* 104de: 00fc3392 */
	xdef _bco0stat
_bco0stat:
#if !BINEXACT
/* BUG: there was no test for bit #4 of prtconfig */
        btst      #4,(_prtconfig+1).w           /* Printer configured for output to RS232? */
        bne       _bco6stat
#endif
        lea.l     ABSW2(MFP_GPIP),a0
        moveq.l   #-1,d0
        btst      #0,0(a0)
        beq.s     bco0st1
        moveq.l   #0,d0
bco0st1:
        rts

/**************************************************************************
 *                                                                        *
 * Bconstat function for device 6 (rs232 driven by MFP)                   *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e023a4 */
/* 206de: 00e020cc */
/* 104de: 00fc33a6 */
	xdef _bcon6stat
_bcon6stat:
        lea.l     ABSW2(rs232iorec),a0            /* point to rs-232 buffer record */
bcon6st1:
        moveq.l   #-1,d0
        lea.l     head(a0),a1
        lea.l     tail(a0),a0
        cmpm.w    (a0)+,(a1)+                   /* buffer empty test */
        bne.s     bcon6st2
        moveq.l   #0,d0
bcon6st2:
        rts

/**************************************************************************
 *                                                                        *
 * Bconin function for device 6 (rs232 driven by MFP)                     *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e023ba */
/* 206de: 00e020e2 */
/* 104de: 00fc33be */
	xdef _bcon6in
_bcon6in:
        lea.l     ABSW2(rs232iorec),a0          /* point to rs-232 buffer record */
#if (TOSVERSION >= 0x200) | !BINEXACT
        lea.l     ABSW(MFP_REGS),a2				/* missing in 1.04 but a2 maybe used in bcon6o1 */
#endif
bcon6in1:
        bsr       iorecget
        move.w    d0,-(a7)
        tst.b     ctr(a0)                       /* flow control active? */
        beq.s     bcon6in3                      /* (no) */
        move.w    tail(a0),d0
        sub.w     head(a0),d0
        bpl.s     bcon6in2                      /* underflow? */
        add.w     size(a0),d0
bcon6in2:
        cmp.w     low(a0),d0
        bgt.s     bcon6in3
        tst.b     highwater(a0)                 /* high-water flag already set? */
        beq.s     bcon6in3
        clr.b     highwater(a0)                 /* clear high-water flag */
        btst      #0,ctr(a0)                    /* is the rs232 mode xon/xoff? */
        bne.s     rs232co1                      /* (yes) */
        bsr       rtson
        bra       bcon6in3
rs232co1:
        move.b    #$11,xonoffc(a0)              /* "xon" */
        bsr       bcon6o0
bcon6in3:
        move.w    (a7)+,d0
        rts

/**************************************************************************
 *                                                                        *
 * Bcostat function for device 6 (rs232 driven by MFP)                    *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02406 */
/* 206de: 00e0212e */
/* 104de: 00fc3408 */
	xdef _bco6stat
_bco6stat:
        lea.l     ABSW2(rs232iorec+IOREC_SIZE),a0  /* point to rs-232 output buffer record */
bco6s1:
        move.w    tail(a0),d1
        bsr       wrapin
        moveq.l   #-1,d0
        cmp.w     head(a0),d1
        bne.s     _bco6sret
        moveq.l   #0,d0
_bco6sret:
        rts


/**************************************************************************
 *                                                                        *
 * Bconout function for device 6 (rs232 driven by MFP)                    *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e0241e */
/* 206de: 00e02146 */
/* 104de: 00fc3422 */
	xdef _bcon6out
_bcon6out:
        move.w    6(a7),d0
        lea.l     ABSW2(rs232iorec+IOREC_SIZE),a0  /* point to rs-232 output buffer record */
        bsr       iorecput
bcon6o0:
        lea.l     ABSW2(MFP_REGS),a2
bcon6o1:
        tst.b     MFP_TSR-MFP_REGS(a2)          /* transmitter status */
        bpl.s     bcon6o2                       /* not ready */
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        bsr       iorecout
        move.w    (a7)+,sr
bcon6o2:
        rts


/**************************************************************************
 *                                                                        *
 * Bcostat function for device 4 (keyboard)                               *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       word    ikbdost()                                                *
 *                                                                        *
 *       returns true/okay to send = 1,  false/not ready = 0              *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02446 */
/* 206de: 00e0216e */
/* 104de: 00fc344a */
	xdef _bco4stat
_bco4stat:
        moveq.l   #-1,d0
        move.b    ABSW2(ACIA_IKBD_BASE+ACIA_CTRL),d2 /* grab ikbd status */
        btst      #1,d2
        bne.s     bco4st1                           /* status okay to send */
        moveq.l   #0,d0                             /* status not okay */
bco4st1:
        rts

/**************************************************************************
 *                                                                        *
 * Bconout function for device 4 (keyboard)                               *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       void    ikbdwc(chr)                                              *
 *       word    chr                                                      *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02456 */
/* 206de: 00e0217e */
/* 104de: 00fc345c */
	xdef _bcon4out
_bcon4out:
        move.w    6(a7),d1
    xdef ikbd_writeb
ikbd_writeb:
        lea.l     ABSW2(ACIA_IKBD_BASE),a1      /* point to ikbd register base */
ikbd_wr1:
#if !BINEXACT
        move.b    (a1),d2                       /* grab keyboard status */
#else
        move.b    0(a1),d2                       /* grab keyboard status */
#endif
        btst      #1,d2
        beq.s     ikbd_wr1
		move.w    #$03B6,d2
ikbd_wr2:
		bsr.s     ikbd_wr3
		dbf       d2,ikbd_wr2
        move.b    d1,ACIA_DATA(a1)              /* write char to the ikbd port */
ikbd_wr3:
        rts

/**************************************************************************
 *                                                                        *
 * XBIOS #25 - Ikbdws - write string to keyboard                          *
 *                                                                        *
 *       entry:                                                           *
 *                                                                        *
 *       VOID ikbdws(uint16_t cnt, VOIDPTR ptr);                          *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02474 */
/* 206de: 00e021a6 */
/* 104de: 00fc3480 */
		xdef _ikbdws
_ikbdws:
        moveq.l   #0,d3
        move.w    4(a7),d3
        movea.l   6(a7),a2
        xdef ikbdws1
ikbdws1:
        move.b    (a2)+,d1
        bsr.s     ikbd_writeb
        dbf       d3,ikbdws1
        rts

/*
 * Bconstat function for device 2 (console)
 */
/* 306de: 00e02488 */
/* 206de: 00e021b8 */
/* 404: 00e0258e */
	xdef _bcon2stat
_bcon2stat:
        lea.l     ABSW(ikbdiorec),a0            /* point to ikbd buffer record */
        moveq.l   #-1,d0
        lea.l     head(a0),a2
        lea.l     tail(a0),a3
        cmpm.w    (a3)+,(a2)+                   /* buffer empty test */
        bne.s     bcon2st1
        moveq.l   #0,d0
bcon2st1:
        rts

/*
 * Bconin function for device 2 (console)
 */
/* 306de: 00e0249e */
/* 206de: 00e021ce */
/* 104de: 00fc34aa */
/* 404: 00e025a4 */
	xdef _bcon2in
_bcon2in:
        bsr.s     _bcon2stat                    /* see if key pressed */
        tst.w     d0
        beq.s     _bcon2in                      /* wait until key pressed */
        move.w    sr,-(a7)
        ori.w     #$0700,sr                     /* protect this upcoming test */
        move.w    head(a0),d1                   /* get current head pointer offset */
        cmp.w     tail(a0),d1                   /* head=tail? */
        beq.s     bcon2in2                      /* yes */
/* check for wrap of pointer */
        addq.w    #4,d1                         /* i=h+4 */
        cmp.w     size(a0),d1
        bcs.s     bcon2in1                      /* no... */
        moveq.l   #0,d1                         /* wrap pointer */
bcon2in1:
        movea.l   buf(a0),a1                    /* get base address of buffer */
        and.l     #$0000FFFF,d1
        move.l    0(a1,d1.l),d0                 /* get character */
        move.w    d1,head(a0)                   /* store new head pointer to buffer */
bcon2in2:
        move.w    (a7)+,sr
        rts

/*
 * Bcostat function for device 2 (console)
 */
/* 306de: 00e024d2 */
/* 206de: 00e02202 */
	xdef _bco2stat
_bco2stat:
        moveq.l   #-1,d0
        rts


/*********************************************************
 * VT52 emulator callback for the bell sound
 *********************************************************/
/* 306de: 00e03b86 */
/* 206de: 00e037a4 */
/* 104de: 00fc34e4 */
#if !BINEXACT
		xdef ringbell
#endif
ringbell:
        btst      #2,ABSW(_conterm)             /* console bell enabled? */
        beq.s     soundir8                      /* (no sound) */
        move.l    #_bellsnd,ABSW(_sndtable)     /* sound data for console bell */
        move.b    #0,ABSW(_snddelay)            /* enable sound timer */
soundir8:
        rts

/***********************************************************************************
 *                                                                                 *
 *                routine to set up the general interrupt port registers           *
 *                        (gpip,are,ddr)                                           *
 *                                                                                 *
 *                algorithm to set up the port                                     *
 *                                                                                 *
 *                1.  mask off all interrupts via the imrx register,               *
 *                2.  clear all enable and pending bits in the ierx and iprx       *
 *                         registers                                               *
 *                3.  check the inerrupt in-service registers and loop till        *
 *                         clear                                                   *
 *                4.  init the aer register bits as desired (default = 11111111)   *
 *                5.  init the ddr register bits as desired (default = 10000000)   *
 *                6.  clear the gpip register                                      *
 *                7.  enable all desired interrupt enable bits                     *
 *                8.  mask on all desired interrupt mask bits                      *
 *                                                                                 *
 ***********************************************************************************/
/* 306de: 00e024d6 */
/* 206de: 00e02206 */
/* 104de: 00fc34fc */
	xdef initmfp
initmfp:
        lea.l     ABSW2(MFP_REGS),a0            /* init mfp address pointer */
        moveq.l   #0,d0
        movep.l   d0,0(a0)                      /* clear gpip thru iera */
        movep.l   d0,8(a0)                      /* clear ierb thru isra */
        movep.l   d0,16(a0)                     /* clear isrb thru vr */
        move.b    #$48,MFP_VR-MFP_REGS(a0)      /* set mfp autovector to $100 and s-bit */
        bset      #2,MFP_AER-MFP_REGS(a0)       /* set cts to low to high transition */

/* init the "c" timer */
        move.w    #$1111,ABSW(_tim_c_sieve)     /* setup bitstream for /4 on timer c interrupts */
        move.w    #20,ABSW(_timer_ms)           /* set timer calibration value */

        moveq.l   #2,d0                         /* set to timer C */
        moveq.l   #$50,d1                       /* set to /64 for 200 hz tick */
        move.w    #192,d2                       /* set to 192 */
        bsr       settimer                      /* initialize Timer C (200hz timer) */

        lea.l     timercint,a2                  /* point to the timer C interrupt routine... */
        moveq.l   #5,d0                         /* point to the timer C interrupt number */
        bsr       initint

/* init the "d" timer */
        moveq.l   #3,d0                         /* select the d timer */
        moveq.l   #1,d1                         /* init for /4 for 9600 baud */
        moveq.l   #2,d2                         /* init for 9600 baud */
        bsr       settimer                      /* branch to out timer initialier... */
        move.w    #1,ABSW2(baudrate)            /* baudrate = 9600 */

/* now init the 3 rs232 chip registers */
        move.l    #$00880101,d0
        movep.l   d0,MFP_SCR-MFP_REGS(a0)

initmfp2:

/* initialize the default rs-232 control line settings */
        bsr       dtron
        bsr       rtson

/* initialize the rs-232 buffer record structure */
        lea.l     ABSW(rs232iorec),a0
        lea.l     rs232table,a1
        moveq.l   #EXTIOREC_SIZE-1,d0
        bsr       copymem

        lea.l     ABSW(midiiorec),a0
        lea.l     miditable,a1
        moveq.l   #IOREC_SIZE-1,d0
        bsr       copymem

        move.l    #aciasys2,d0                  /* init ikbd and midi error handler address */
        move.l    d0,ABSW(vkbderr)              /* init keyboard error handler address */
        move.l    d0,ABSW(vmiderr)              /* init midi error handler address */
        move.l    #_midivec,ABSW(midivec)       /* point to system midi interrupt vector */
        move.l    #_midisys,ABSW(midisys)
        move.l    #_ikbdsys,ABSW(ikbdsys)
#if TOSVERSION >= 0x200
        move.l    #_kbdvec,ABSW(kbdvec)
#endif
/* reset midi acia */
        move.b    #$03,ABSW2(ACIA_MIDI_BASE+ACIA_CTRL)     /* init the midi acia via master reset */
/* init the acia to divide by 16x clock, 8 bit data, 1 stop bit, no parity, */
/* rts low, transmitting interrupt disabled, receiving interrupt enabled */
        move.b    #$95,ABSW2(ACIA_MIDI_BASE+ACIA_CTRL)

/* initialize the keyboard acia interrupt vector exception address */
        move.b    #CONTERM,ABSW(_conterm)       /* enabled keyclick, repeat key, bell functions */
        move.l    #_clockvec,ABSW(clockvec)
        move.l    #dummyrts,d0
        move.l    d0,ABSW(statvec)
        move.l    d0,ABSW(mousevec)
        move.l    d0,ABSW(joyvec)
#if TOSVERSION >= 0x200
        bsr       initdevstables
#endif

/* Sound routine initialization */
        moveq.l   #0,d0
        move.l    d0,ABSW(_sndtable)            /* clear sound ptr */
        move.b    d0,ABSW(_snddelay)            /* clear delay timer */
        move.b    d0,ABSW(_sndtmp)              /* clear temp value */
        move.l    d0,ABSW(lst_timeout)          /* init printer timeout to 0 */
        bsr       strobeoff                     /* init strobe to off (line high!) */
        move.b    #$0F,ABSW(kb_initial)
        move.b    #$02,ABSW(kb_repeat)

/* within the mouse relative routine */
/* initialize the ikbd buffer record structure */
        lea.l     ABSW(ikbdiorec),a0
        lea.l     ikbdtable,a1
        moveq.l   #IOREC_SIZE-1,d0
        bsr.s     copymem
        bsr       _bioskeys                     /* point key translation address to the rom based translation tables */

/* reset ikbd acia */
        move.b    #$03,ABSW2(ACIA_IKBD_BASE+ACIA_CTRL) /* init the acia via master Reset */
/* now that the vector is initialized, we can allow interrupts to occur! */
/* init the acia do divide by 64 clock, 8 bit data, 1 stop bit, no parity, */
/* rts low, transmitting interrupt disabled, receiving interrupt enabled */
        move.b    #$96,ABSW2(ACIA_IKBD_BASE+ACIA_CTRL)

        movea.l   #mfpvectr,a3                  /* point to initializing array of exception vec's */
        moveq.l   #3,d1                         /* init branch counter/index */
initmfp3:
        move.l    d1,d2
        move.l    d1,d0                         /* load in interrupt # to setup */
        addi.b    #$09,d0                       /* add constant to point to proper mfp interrupt */
        asl.l     #2,d2
        movea.l   0(a3,d2.w),a2
        bsr       initint                       /* go to service routine */
        dbf       d1,initmfp3
        lea.l     _int_acia,a2
        moveq.l   #6,d0                         /* load in interrupt # to setup */
        bsr       initint                       /* go to service routine */

/* initializing code which sets the enable */
/* and mask bits... */
        lea.l     ctsint,a2                     /* point to the CTS interrupt routine... */
        moveq.l   #2,d0                         /* point to the CTS interrrupt number */
        bsr       initint

#if TTMFP_SUPPORT

		data
ttmfpvectr:
        dc.l tttxerror
        dc.l tttxrint
        dc.l ttrxerror
        dc.l ttrcvrint

/*
 * initial EXT_IOREC for device 8 (modem3)
 */
/* 306de: 00e36744 */
mdm3table:
        dc.l mdm3ibuf
        dc.w SERIAL_BUFSIZE,0,0,128,192
        dc.l mdm3obuf
        dc.w SERIAL_BUFSIZE,0,0,128,192
        dc.b 0,0,0,0,1,0,1,-1
		text

        movea.l   #ttmfpvectr,a3
        movea.w   #TTMFP9,a0
        move.l    (a3)+,(a0)+
        move.l    (a3)+,(a0)+
        move.l    (a3)+,(a0)+
        move.l    (a3)+,(a0)+
        ori.b     #$1E,ABSW(MFP_IERA+(TTMFP_REGS-MFP_REGS))
        ori.b     #$1E,ABSW(MFP_IMRA+(TTMFP_REGS-MFP_REGS))
#endif

dummyrts:
        rts


/* 306de: 00e026b2 */
/* 206de: 00e0237c */
copymem:
        move.b    (a1)+,(a0)+
        dbf       d0,copymem
        rts

ikbdtable:
        dc.l      ikbdbuf
        dc.w      SERIAL_BUFSIZE,0,0,64,192
miditable:
        dc.l      midibuf
        dc.w      128,0,0,32,96


/*
 * initial EXT_IOREC for device 6 (rs232)
 */
rs232table:
        dc.l      rs232ibuf
        dc.w      SERIAL_BUFSIZE,0,0,128,192
        dc.l      rs232obuf
        dc.w      SERIAL_BUFSIZE,0,0,128,192
        dc.b      0,0,0,0,1,0

/* array of exception vector addresses for the above interrupts, including */
/* dummy vectors that point to "rte's". */
mfpvectr:
        dc.l txerror
        dc.l txrint
        dc.l rxerror
        dc.l rcvrint

/***********************************************************************************
 *                                                                                 *
 *                routine to set up a timer                                        *
 *                                                                                 *
 *                algorithm to init a timer                                        *
 *                                                                                 *
 *                1.  determine which timer and set d0.b = to timer's index value  *
 *                    as shown below                                               *
 *                2.  disable the associated interrupt                             *
 *                3.  disable the timer itself via it's timer control register     *
 *                4.  initialize the timer's data register                         *
 *                5.  repeat step #4 until the data register's contents are        *
 *                    verified, per the errata sheet to the 68901 description      *
 *                6.  turn on the timer by using the value that you previously     *
 *                    stored in d1                                                 *
 *                                                                                 *
 *                note:    the interrupt vector for the associated timer           *
 *                         is not set in this routine, so it is the user's         *
 *                         responsiblity to set it if so desired!                  *
 *                                                                                 *
 *                                                                                 *
 *                registers used:          d0-d3/a0-a3                             *
 *                registers saved:         d0-d3/a0-a3                             *
 *                entry:                                                           *
 *                        d0.l - timer to be set                                   *
 *                                0 - timer a                                      *
 *                                1 - timer b                                      *
 *                                2 - timer c                                      *
 *                                3 - timer d                                      *
 *                        d1.b - timer's new control setting                       *
 *                        d2.b - timer's data register data                        *
 *                                                                                 *
 *                exit:   no values to pass                                        *
 *                                                                                 *
 *                        d3   - used and abused by call to mskreg routine         *
 *                        a0.l - set to mfp register base                          *
 *                        a1.l - temporary location for a3                         *
 *                        a2.l - used to pass table address to mskreg routine      *
 *                        a3.l - used to pass table address to mskreg routine      *
 *                                                                                 *
 ***********************************************************************************/
/* 306de: 00e0270a */
/* 206de: 00e023d4 */
/* 104de: 00fc36ac */
settimer:
        movem.l   d0-d4/a0-a3,-(a7)             /* save all registers to be messed with!! */
#if (TOSVERSION >= 0x200) | !BINEXACT
        movea.w   #MFP_REGS,a0                  /* set mfp chip address pointer */
#else
        movea.l   #MFP_REGS,a0                  /* set mfp chip address pointer */
#endif

        movea.l   #imrt,a3                      /* mask off the timer's interrupt maskable bit */
        movea.l   #imrmt,a2
        bsr.s     mskreg

        movea.l   #iert,a3                      /* mask off the timer's interrupt enable bit */
        movea.l   #imrmt,a2
        bsr.s     mskreg

        movea.l   #iprt,a3                      /* mask off the timer's interrupt pending bit */
        movea.l   #imrmt,a2
        bsr.s     mskreg

        movea.l   #isrt,a3                      /* mask off the timer's interrupt inservice bit */
        movea.l   #imrmt,a2
        bsr.s     mskreg

        movea.l   #tcrtab,a3                    /* mask off the timer's control bits */
        movea.l   #tcrmsk,a2
        bsr.s     mskreg

        exg       a3,a1                         /* save address pointer for restoring control */
        lea.l     tdrtab,a3                     /* initialize the timer data register */
        moveq.l   #0,d3                         /* to prevent false effective address generation */
        move.b    0(a3,d0.w),d3
settim1:
        move.b    d2,0(a0,d3.w)
        cmp.b     0(a0,d3.w),d2
        bne.s     settim1
        exg       a3,a1                         /* grab that register address back */
        or.b      d1,(a3)                       /* mask the timer control register value */

        movem.l   (a7)+,d0-d4/a0-a3             /* restore all registers that were saved */
        rts

/***********************************************************************************
 *                generalize mask register bit(s) routine                          *
 *                                                                                 *
 *       entry                                                                     *
 *       static  d0 - contains the timer #                                         *
 *               d3 - used and abused                                              *
 *               d4 - used and abused                                              *
 *       static  a0 - mfp register base                                            *
 *               a3 - points to table of similar timer registers                   *
 *       static  a2 - points to table of similar timer data registers              *
 ***********************************************************************************/
mskreg:
        bsr.s     getmask
        move.b    (a2),d3                       /* grab mask now */
        and.b     d3,(a3)                       /* and have masked off the desired bit(s) */
        rts

getmask:
        moveq.l   #0,d3                         /* to prevent false effective address generation */
        adda.w    d0,a3                         /* have got pointer to mfp register now */
        move.b    (a3),d3                       /* now have the address offset to mfp */
        add.l     a0,d3
        movea.l   d3,a3                         /* now have address pointing to desired mfp reg. */
                                                /* now we get the mask to turn off interrupt */
        adda.w    d0,a2                         /* have got pointer to mask now */
        rts

iert:    dc.b $06,$06,$08,$08
iprt:    dc.b $0a,$0a,$0c,$0c
isrt:    dc.b $0e,$0e,$10,$10
imrt:    dc.b $12,$12,$14,$14
imrmt:   dc.b $df,$fe,$df,$ef
tcrtab:  dc.b $18,$1a,$1c,$1c
tcrmsk:  dc.b $00,$00,$8f,$f8
tdrtab:  dc.b $1e,$20,$22,$24

/***********************************************************************************
 * XBIOS #13 - Mfpint - Set the MFP interrupt number                               *
 *                                                                                 *
 *                entry                                                            *
 *                                                                                 *
 *                void    mfpint(numint,intvec)                                    *
 *                word    numint                                                   *
 *                long    intvec                                                   *
 *                                                                                 *
 * Set the MFP interrupt number 'interno' (0 to 15) to 'vector'.                   *
 * The old vector is written over (and thus unrecoverable).                        *
 *                                                                                 *
 ***********************************************************************************/
/* 306de: 00e027b0 */
/* 206de: 00e0247a */
/* 104de: 00fc3754 */
	xdef _mfpint
_mfpint:
        move.w    4(a7),d0
        movea.l   6(a7),a2
        andi.l    #$0000000F,d0

/***********************************************************************************
 *                                                                                 *
 *                routine to init an mfp associated interrupt vector               *
 *                                                                                 *
 *                algorithm                                                        *
 *                                                                                 *
 *                1.  block the interrupt via it's mask bit                        *
 *                2.  disable the interrupt's enable and pending bits              *
 *                3.  check the interrupt's in-service register and loop till      *
 *                    clear                                                        *
 *                4.  init the interrupt's associated vector                       *
 *                5.  set the interrupt's enable bit                               *
 *                6.  set the interrupt's mask bit                                 *
 *                                                                                 *
 *                entry                                                            *
 *                         d0 - contains interrupt # to aff                        *
 *                         a2 - contains new vector address                        *
 ***********************************************************************************/
initint:
        movem.l   d0-d2/a0-a2,-(a7)             /* save affected registers */
        bsr.s     jdisint1                      /* disable the interrupts */
        move.l    d0,d2                         /* get a copy so as to determine where to... */
        asl.w     #2,d2                         /* place the a2 address into the int. vector */
        addi.l    #$00000100,d2                 /* interrupt vector addr = (4 * int) + $000100 */
        movea.l   d2,a1                         /* transfer the calculated address to a register */
        move.l    a2,(a1)                       /* ...that can act upon it thus<--vector init'ed */
        bsr.s     jenabin1                      /* enable interrupts */
        movem.l   (a7)+,d0-d2/a0-a2             /* restore affected registers */
        rts

/*************************************************************************
 * XBIOS #26 - Jdisint - Disable interrupt number 'intno' on the 68901   *
 *                                                                       *
 *                entry                                                  *
 *                                                                       *
 *                void    jdisint(numint)                                *
 *                word    numint                                         *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e027da */
/* 206de: 00e024a4 */
/* 104de: 00fc377e */
	xdef _jdisint
_jdisint:
        move.w    4(a7),d0
        andi.l    #$0000000F,d0

/*************************************************************************
 *                interrupt disable routine                              *
 *************************************************************************/

jdisint1:
        movem.l   d0-d1/a0-a1,-(a7)             /* save affected registers */
        lea.l     ABSW2(MFP_REGS),a0            /* set mfp chip address pointer */
        lea.l     MFP_IMRA-MFP_REGS(a0),a1      /* set a1 to the mskoff routine */
        bsr.s     bselect                       /* generate the appropriate bit to clear */
        bclr      d1,(a1)                       /* and clear the bit... */
        lea.l     MFP_IERA-MFP_REGS(a0),a1      /* set a1 for another mskoff call */
        bsr.s     bselect
        bclr      d1,(a1)                       /* and clear the bit... */
#if (TOSVERSION >= 0x200) | !BINEXACT
        lea.l     MFP_ISRA-MFP_REGS(a0),a1      /* now set up to check for interrupts in progress */
        bsr.s     bselect                       /* get proper a/b version... */
        move.b    #$FE,d0
        rol.b     d1,d0
        move.b    d0,(a1)
#else
        lea.l     MFP_IPRA-MFP_REGS(a0),a1      /* now set up to check for interrupts in progress */
        bsr.s     bselect                       /* get proper a/b version... */
        bclr      d1,(a1)
        lea.l     MFP_ISRA-MFP_REGS(a0),a1
        bsr.s     bselect
        bclr      d1,(a1)
#endif
        movem.l   (a7)+,d0-d1/a0-a1             /* restore affected registers */
        rts

/*************************************************************************
 * XBIOS #27 - Jenabint - Enable interrupt number 'intno' on the 68901,  *
 *                                                                       *
 *                entry                                                  *
 *                                                                       *
 *                void    jenabint(numint)                               *
 *                word    numint                                         *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e02810 */
/* 206de: 00e024da */
/* 104de: 00fc37b8 */
	xdef _jenabint
_jenabint:
        move.w    4(a7),d0
        andi.l    #$0000000F,d0

/*************************************************************************
 *                enable interrupt routine                               *
 *************************************************************************/
jenabin1:
        movem.l   d0-d1/a0-a1,-(a7)             /* save affected registers */
        lea.l     ABSW2(MFP_REGS),a0            /* set mfp chip address pointer */
        lea.l     MFP_IERA-MFP_REGS(a0),a1      /* set up to enable the interrupt enable bit */
        bsr.s     bselect
        bset      d1,(a1)                       /* and set the bit... */
        lea.l     MFP_IMRA-MFP_REGS(a0),a1      /* set up to enable the interrupt mask bit */
        bsr.s     bselect
        bset      d1,(a1)                       /* and set the bit... */
        movem.l   (a7)+,d0-d1/a0-a1             /* restore affected registers */
        rts

/*************************************************************************
 *                                                                       *
 *       the following routine generates the appropriate bset/bclr #     *
 *       for the interrupt # specified in d0.    valid interrupt #'s are *
 *       0 --> 15 as shown in the 68901 chip specification.  It also     *
 *       selects between the ixra and the ixrb version of the register   *
 *       as is appropriate.                                              *
 *                                                                       *
 *       entry   d0 - contains the interrupt number                      *
 *               a1 - contains the pointer to the "ixra" version of      *
 *                    the interrupt byte to mask                         *
 *       exit            d0 - same as upon entry                         *
 *                       d1 - contains the number of the bit             *
 *************************************************************************/
bselect:
        move.b    d0,d1                         /* copy d0 to d1 for scratch work */
        cmpi.b    #$08,d1                       /* see if desired int # >= 8... */
        blt.s     bselect1                      /* ...and branch if it ain't... */
        subq.w    #8,d1                         /* adjust for using ixrb instead */
        rts
bselect1:
        addq.l    #MFP_IERB-MFP_IERA,a1         /* adjust for using ixrb instead */
        rts

/*************************************************************************
 *
 *               receiver buffer full interrupt routine
 *
 *               grabs data from the rs-232 receiver port
 *
 *************************************************************************/
/* 306de: 00e02848 */
/* 205de: 00e02512 */
/* 104de: 00fc37f2 */
rcvrint:
        movem.l   d0-d1/a0-a2,-(a7)             /* save affected registers */
        lea.l     ABSW2(rs232iorec),a0          /* point to current output buffer record */
        lea.l     ABSW2(MFP_REGS),a2            /* set mfp chip address pointer */
rcvrint1:
        move.b    MFP_RSR-MFP_REGS(a2),rcv(a0)  /* do the required rsr read before the udr read! */
        move.b    MFP_UDR-MFP_REGS(a2),d0       /* get incoming data byte */

        btst      #0,ctr(a0)                    /* is the rs232 mode xon/xoff? */
        beq.s     rcvrint3                      /* no... so process normally */

        cmpi.b    #$13,d0                       /* is the data an "xoff" signal? */
        bne.s     rcvrint2                      /* no...now check for xon */
        move.b    #-1,xoff(a0)                  /* set to halted transmission to host */
        bra.s     rcvrint7
rcvrint2:
        cmpi.b    #$11,d0                       /* is the data an "xon" signal? */
        bne.s     rcvrint3                      /* neither xon/xoff value, must be normal data... */
        clr.b     xoff(a0)                      /* set to normal transmission status */
        bra.s     rcvrint6                      /* abnormal exit condition!! */
rcvrint3:
        move.w    tail(a0),d1                   /* get current tail pointer offset */
        bsr       wrapin                        /* do wrap of input pointer if needed */
        cmp.w     head(a0),d1                   /* head=tail? */
        beq.s     rcvrint7                      /* yes...exit... */
        bsr       iorecput                      /* store data in ring buffer */

/* now check for highwater mark triggering of flow-control */
        tst.b     ctr(a0)                       /* flow control active? */
        beq.s     rcvrint7                      /* no...exit... */
        move.w    tail(a0),d0                   /* current tail pointer */
        sub.w     head(a0),d0                   /* - current head */
        bpl.s     rcvrint4                      /* wrap around? */
        add.w     size(a0),d0                   /* + size to correct the wrap around */
rcvrint4:
        cmp.w     high(a0),d0                   /* high-water mark not reached? */
        blt.s     rcvrint7                      /* correct...exit... */
        tst.b     highwater(a0)                 /* high-water flag already set? */
        bne.s     rcvrint7                      /* yes...exit... */
        move.b    #-1,highwater(a0)             /* set high-water flag */
        btst      #0,ctr(a0)                    /* are we using xon/xoff flow control? */
        bne.s     rcvrint5                      /* yes... */
        bsr       rtsoff                        /* we're ready now for more data...yum! yum! */
        bra.s     rcvrint7
rcvrint5:
        move.b    #$13,xonoffc(a0)              /* xoff */
rcvrint6:
        tst.b     MFP_TSR-MFP_REGS(a2)          /* transmitter status? */
        bpl.s     rcvrint7                      /* not ready */
        bsr       iorecout
rcvrint7:
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$EF,MFP_ISRA-MFP_REGS(a2)
#else
        bclr      #4,MFP_ISRA-MFP_REGS(a2)
#endif
        movem.l   (a7)+,d0-d1/a0-a2             /* restore affected registers */
        rte

/*************************************************************************
 *
 *               transmit buffer empty interrupt routine
 *
 *************************************************************************/
/* 306de: 00e028e2 */
/* 205de: 00e025ac */
/* 104de: 00fc3890 */
txrint:
        movem.l   d0-d1/a0-a2,-(a7)             /* save affected registers */
        lea.l     ABSW2(MFP_REGS),a2            /* set mfp chip address pointer */
#if (TOSVERSION >= 0x200)
        lea.l     ABSW2(rs232iorec),a0          /* point to current output buffer record */
#endif
txrint1:
        bsr       iorecout
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$FB,MFP_ISRA-MFP_REGS(a2)    /* xmit buffer empty */
#else
		bclr      #2,MFP_ISRA-MFP_REGS(a2)
#endif
        movem.l   (a7)+,d0-d1/a0-a2             /* restore affected registers */
        rte

/*************************************************************************
 *
 *               Clear-To-Send interrupt routine
 *
 *************************************************************************/
/* 306de: 00e028fe */
/* 206de: 00e025c8 */
/* 104de: 00fc38aa */
ctsint:
        movem.l   d0-d1/a0-a2,-(a7)             /* save affected registers */
        lea.l     ABSW2(rs232iorec),a0          /* point to current output buffer record */
        lea.l     ABSW2(MFP_REGS),a2            /* set mfp chip address pointer */

        btst      #1,ctr(a0)                    /* are we using CTS/RTS flow control? */
        beq.s     ctsint2                       /* no... */
#if (TOSVERSION >= 0x200) | !BINEXACT
        btst      #2,(a2)                       /* CTS already active? */
#else
        btst      #2,0(a2)                      /* CTS already active? */
#endif
        bne.s     ctsint1                       /* yes... */
        clr.b     xoff(a0)                      /* xon_flag = 0 */
        bset      #2,MFP_AER-MFP_REGS(a2)       /* CTS set */
        tst.b     MFP_TSR-MFP_REGS(a2)          /* transmitter status? */
        bpl.s     ctsint2                       /* not empty... */
        bsr.s     iorecout                      /* send a byte */
        bra.s     ctsint2
ctsint1:
        move.b    #-1,xoff(a0)                  /* xon_flag = -1 */
        bclr      #2,MFP_AER-MFP_REGS(a2)
ctsint2:
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$FB,MFP_ISRB-MFP_REGS(a2)    /* clear CTS */
#else
		bclr      #2,MFP_ISRB-MFP_REGS(a2)
#endif
        movem.l   (a7)+,d0-d1/a0-a2             /* restore affected registers */
        rte


/*************************************************************************
 *               routines to handle tx or rx errors
 *************************************************************************/
/* 306de: 00e02944 */
/* 206de: 00e0260e */
/* 104de: 00fc38f6 */
rxerror:
        movem.l   d0/a0,-(a7)                   /* save all registers */
        lea.l     ABSW2(MFP_REGS),a0            /* set mfp chip address pointer */
rxerror1:
        move.b    MFP_RSR-MFP_REGS(a0),rs232iorec+rcv /* receiver status register */
        move.b    MFP_UDR-MFP_REGS(a0),d0       /* dummy read of data register */
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$F7,MFP_ISRA-MFP_REGS(a0)
#else
		bclr      #3,MFP_ISRA-MFP_REGS(a0)
#endif
        movem.l   (a7)+,d0/a0                   /* restore all registers */
        rte

/* 306de: 00e02964 */
/* 206de: 00e0262e */
/* 104de: 00fc3918 */
txerror:
        move.l    a0,-(a7)
        lea.l     ABSW2(MFP_REGS),a0            /* set mfp chip address pointer */
txerror1:
        move.b    MFP_TSR-MFP_REGS(a0),rs232iorec+wr5  /* transmitter status register */
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$FD,MFP_ISRA-MFP_REGS(a0)
#else
		bclr      #1,MFP_ISRA-MFP_REGS(a0)
#endif
        movea.l   (a7)+,a0                      /* restore all registers */
#if (TOSVERSION >= 0x200) | !BINEXACT
        tst.b     ABSW(MFP_TSR)
#endif
        rte

/*************************************************************************
 * write a character from the ring buffer to the serial port
 *************************************************************************/
/* 306de: 00e02980 */
/* 206de: 00e0264a */
/* 104de: 00fc3932 */
iorecout:
#if (TOSVERSION >= 0x200)
        move.l    a0,-(a7)                      /* save all registers */
#else
        lea.l     ABSW2(rs232iorec),a0          /* point to current output buffer record */
#endif
#if (TOSVERSION < 0x200)
		move.b    ctr(a0),d0
		and.b     xoff(a0),d0
		bne.s     ioreco3
#endif
        move.b    xonoffc(a0),d0                /* send handshake byte pending? */
        beq.s     ioreco1                       /* no... */
        clr.b     xonoffc(a0)                   /* clear handshake byte */
        bra.s     ioreco2                       /* output the handshake byte */
ioreco1:
#if (TOSVERSION >= 0x200)
        move.b    ctr(a0),d0                    /* flow control active? */
        and.b     xoff(a0),d0                   /* and xon-flag */
        bne.s     ioreco3                       /* yes... */
        adda.w    #IOREC_SIZE,a0                /* switch to output ring buffer */
#else
        lea.l     ABSW2(rs232iorec+IOREC_SIZE),a0          /* point to current output buffer record */
#endif
        move.w    head(a0),d0                   /* head-index */
        cmp.w     tail(a0),d0                   /* = tail-index? */
        beq.s     ioreco3                       /* buffer empty? => out */
        bsr.s     iorecget                      /* get next character from the buffer */
ioreco2:
        tst.b     MFP_TSR-MFP_REGS(a2)          /* transmit buffer empty? */
        bpl.s     ioreco2                       /* no...wait... */
        move.b    MFP_TSR-MFP_REGS(a2),rs232iorec+wr5   /* save transmitter status; BUG: should be wr5(a0) */
        move.b    d0,MFP_UDR-MFP_REGS(a2)       /* output the byte */
ioreco3:
#if (TOSVERSION >= 0x200)
        movea.l   (a7)+,a0                      /* restore all registers */
#endif
        rts

/*************************************************************************
 * put a character into the ring buffer
 *************************************************************************/
/* 306de: 00e029be */
/* 206de: 00e02688 */
iorecput:
        move.w    tail(a0),d1
        bsr.s     wrapin
iorecp1:
        cmp.w     head(a0),d1                   /* = head-index? */
        beq.s     iorecp1                       /* buffer full...wait... */
        movea.l   buf(a0),a1                    /* ptr to send buffer */
        and.l     #$0000FFFF,d1                 /* byte into the send buffer */
        move.b    d0,0(a1,d1.l)                 /* update tail-index */
        move.w    d1,tail(a0)
        rts

/*************************************************************************
 * get a character from the ring buffer
 *************************************************************************/
/* 306de: 00e029dc */
/* 206de: 00e026a6 */
iorecget:
        move.w    head(a0),d1
        cmp.w     tail(a0),d1                   /* head-index = tail-index? */
        beq.s     iorecget                      /* empty? wait... */
        bsr.s     wrapin
        movea.l   buf(a0),a1                    /* ptr to receive buffer */
        moveq.l   #0,d0
        and.l     #$0000FFFF,d1
        move.b    0(a1,d1.l),d0                 /* byte from the receive buffer */
        move.w    d1,head(a0)                   /* update head-index */
        rts

/*************************************************************************
 * set RTS signal
 *************************************************************************/
/* 306de: 00e029fc */
/* 206de: 00e026c6 */
/* 104de: 00fc39b6 */
rtson:
        lea.l     ABSW2(psgsel),a1
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        move.b    #$0E,(a1)
        move.b    (a1),d1
        and.b     #$F7,d1                       /* clear bit 3 in port A */
        move.b    d1,2(a1)
        move.w    (a7)+,sr
        rts

/*************************************************************************
 * clear RTS signal
 *************************************************************************/
/* 306de: 00e02a18 */
/* 206de: 00e026e2 */
/* 104de: 00fc39d4 */
rtsoff:
        lea.l     ABSW2(psgsel),a1
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        move.b    #$0E,(a1)
        move.b    (a1),d1
        ori.b     #$08,d1                       /* set bit 3 in port A */
        move.b    d1,2(a1)
        move.w    (a7)+,sr
        rts

/*************************************************************************
 * get next index for ringbuffer into D1
 *************************************************************************/
wrapin:
        addq.w    #1,d1                         /* i=h+1 */
        cmp.w     size(a0),d1                   /* > i => current bufsiz? */
        bcs.s     wrapin1                       /* no... */
        moveq.l   #0,d1                         /* wrap pointer */
wrapin1:
        rts


/*
 * XBIOS #14 - Iorec - Returns pointer to a serial device's input buffer record.
 */
/* 306de: 00e02a40 */
/* 206de: 00e0270a */
/* 104de: 00fc39fe */
	xdef _iorec
_iorec:
        move.w    4(a7),d1             /* device number */
#if TOSVERSION >= 0x200
        beq.s     iorec1               /* for device 0 (rs232), return bconmap configuration */
#endif
        asl.l     #2,d1
        move.l    iorectab(pc,d1.w),d0
        rts
#if TOSVERSION >= 0x200
iorec1:
        move.l    ABSW(bcmap_root+12),d0 /* bcmap_root.iorec */
        rts
#endif
iorectab:
        dc.l rs232iorec                /* RS232 */
        dc.l ikbdiorec                 /* IKBD */
        dc.l midiiorec                 /* MIDI */


/*
 * XBIOS #15 - Rsconf - Configure RS-232 port.
 *
 * If any parameter is -1 ($FFFF), the corresponding hardware register
 * is not set.
 *
 * speed  - the port's baud rate
 * flow   - the flow control
 * ucr    - 68901 register
 * rsr    - 68901 register
 * tsr    - 68901 register
 * scr    - 68901 register
 */
/* 306de: 00e02a60 */
/* 206de: 00e0272a */
/* 104de: 00fc3a16 */
	xdef _rsconf:
_rsconf:
#if TOSVERSION >= 0x200
        movea.l   ABSW(bcmap_root+8),a0 /* bcmap_root.rscon */
        jmp       (a0)

/*
 * Rsconf function for device 6 (rs232 driven by MFP)
 */
/* 306de: 00e02a66 */
/* 206de: 00e02730 */
_rs6conf:
        lea.l     ABSW(rs232iorec),a0           /* point to current output buffer record */
#define mfpareg a2
        lea.l     ABSW(MFP_REGS),mfpareg        /* set mfp chip address pointer */
rs6conf1:
        moveq.l   #0,d0
        cmpi.w    #-2,4(a7)                     /* -2 = return last baudrate */
        bne.s     rs6conf2
        move.b    baudrate(a0),d0               /* last baudrate */
        rts
rs6conf2:
        ori.w     #$0700,sr                     /* no interrupts for now */
/*
 *      first we grab the old ucs,rsr,tsr,scr contents
 */
        movep.l   MFP_UCR-MFP_REGS(mfpareg),d7
        move.w    6(a7),d0                      /* if -1 then don't change */
        cmp.w     #$0003,d0
        bhi.s     rs6conf6
        bne.s     rs6conf3
        moveq.l   #1,d0                         /* set flag for handshake */
rs6conf3:
        cmp.b     ctr(a0),d0                    /* state unchanged? => continue */
        beq.s     rs6conf6
        move.w    d0,-(a7)                      /* save new handshake state */
        tst.b     xoff(a0)                      /* xon flag set? */
        beq.s     rs6conf4
        clr.b     xoff(a0)                      /* clear xon flag */
        bsr       iorecout                      /* transmit xon to continue */
rs6conf4:
        tst.b     highwater(a0)                 /* RTS set? */
        beq.s     rs6conf5                      /* no... */
        bsr       rs232cont                     /* reenable RTS */
rs6conf5:
        move.w    (a7)+,d0                      /* new handshake state */
        move.b    d0,ctr(a0)                    /* set new handshake state */
rs6conf6:
/*  set timer baud rate */
        tst.w     4(a7)                         /* if -1 then don't change */
        bmi.s     rs6conf7
        bclr      #0,MFP_RSR-MFP_REGS(mfpareg)  /* disable receiver */
        bclr      #0,MFP_TSR-MFP_REGS(mfpareg)  /* disable transmitter */
        move.w    4(a7),d1                      /* new baudrate */
        move.b    d1,baudrate(a0)               /* store for later */
        move.b    baudctrl(pc,d1.w),d0          /* get baudrate control register settings mask */
        move.b    bauddata(pc,d1.w),d2          /* get baudrate data register value */
        andi.b    #$70,MFP_TCDCR-MFP_REGS(mfpareg)
        move.b    d2,MFP_TDDR-MFP_REGS(mfpareg) /* set tuner D to new baud rate */
        or.b      d0,MFP_TCDCR-MFP_REGS(mfpareg)
        bset      #0,MFP_RSR-MFP_REGS(mfpareg)  /* enable receiver */
        bset      #0,MFP_TSR-MFP_REGS(mfpareg)  /* enable transmitter */
rs6conf7:
        tst.w     8(a7)                         /* if -1 then don't change */
        bmi.s     rs6conf8
        move.b    9(a7),MFP_UCR-MFP_REGS(mfpareg) /* set ucr */
rs6conf8:
        tst.w     10(a7)                        /* if -1 then don't change */
        bmi.s     rs6conf9
        move.b    11(a7),MFP_RSR-MFP_REGS(mfpareg) /* set rsr */
rs6conf9:
        tst.w     12(a7)                        /* if -1 then don't change */
        bmi.s     rs6con10
        move.b    13(a7),MFP_TSR-MFP_REGS(mfpareg) /* set tsr */
rs6con10:
        tst.w     14(a7)                        /* if -1 then don't change */
        bmi.s     rs6con11
        move.b    15(a7),MFP_SCR-MFP_REGS(mfpareg) /* set scr */
rs6con11:
        move.l    d7,d0                         /* move old contents of rs-232 registers to d0.l */
        rts
#undef mfpareg

#else

/*
 * Rsconf function for device 6 (rs232 driven by MFP)
 */
        cmpi.w    #-2,4(a7)                     /* -2 = return last baudrate */
        bne.s     rs6conf2
        move.w    ABSW2(baudrate),d0            /* last baudrate */
        rts
rs6conf2:
        ori.w     #$0700,sr                     /* no interrupts for now */
        lea.l     ABSW2(rs232iorec),a0          /* point to current output buffer record */
#define mfpareg a1
        lea.l     ABSW2(MFP_REGS),mfpareg       /* set mfp chip address pointer */
/*
 *      first we grab the old ucs,rsr,tsr,scr contents
 */
        movep.l   MFP_UCR-MFP_REGS(mfpareg),d7
        move.w    6(a7),d0                      /* if -1 then don't change */
        cmp.w     #-1,d0
        beq.s     rs6conf6
        move.b    d0,ctr(a0)
        beq.s     rs6conf5
		and.b     #$FD,d0
        beq.s     rs6conf5
		move.b    #1,d0
rs6conf5:
        move.b    d0,ctr(a0)                    /* set new handshake state */
rs6conf6:
/*  set timer baud rate */
        tst.w     4(a7)                         /* if -1 then don't change */
        bmi.s     rs6conf7
		moveq.l   #0,d0
        move.b    d0,MFP_RSR-MFP_REGS(mfpareg)  /* disable receiver */
        move.b    d0,MFP_TSR-MFP_REGS(mfpareg)  /* disable transmitter */
        move.w    4(a7),d1                      /* new baudrate */
        move.w    d1,baudrate                   /* store for later */
        lea       baudctrl,a2
        move.b    0(a2,d1.w),d0                 /* get baudrate control register settings mask */
        lea       bauddata,a2
        move.b    0(a2,d1.w),d2                 /* get baudrate data register value */
		move.l    d0,d1
		moveq.l   #3,d0
		bsr       settimer
		moveq.l   #1,d0
        move.b    d0,MFP_RSR-MFP_REGS(mfpareg)  /* enable receiver */
        move.b    d0,MFP_TSR-MFP_REGS(mfpareg)  /* enable transmitter */
rs6conf7:
        tst.w     8(a7)                         /* if -1 then don't change */
        bmi.s     rs6conf8
        move.b    9(a7),MFP_UCR-MFP_REGS(mfpareg) /* set ucr */
rs6conf8:
        tst.w     10(a7)                        /* if -1 then don't change */
        bmi.s     rs6conf9
        move.b    11(a7),MFP_RSR-MFP_REGS(mfpareg) /* set rsr */
rs6conf9:
        tst.w     12(a7)                        /* if -1 then don't change */
        bmi.s     rs6con10
        move.b    13(a7),MFP_TSR-MFP_REGS(mfpareg) /* set tsr */
rs6con10:
        tst.w     14(a7)                        /* if -1 then don't change */
        bmi.s     rs6con11
        move.b    15(a7),MFP_SCR-MFP_REGS(mfpareg) /* set scr */
rs6con11:
        move.l    d7,d0                         /* move old contents of rs-232 registers to d0.l */
        rts
#endif

#undef mfpareg

/* baudrate table - control register setting */
baudctrl: dc.b $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02
/* baudrate table - data register setting */
bauddata: dc.b $01,$02,$04,$05,$08,$0a,$0b,$10,$20,$40,$60,$80,$8f,$af,$40,$60


#if TOSVERSION >= 0x200
/*
 * initial values for 4 extra MAPTAB structures
 */
/* 306de: 00e02b4a */
/* 206de: 00e02814 */
bcondevs:
        dc.l      _bcon6stat                    /* Dev 6: "Modem 1" - ST MFP */
        dc.l      _bcon6in
        dc.l      _bco6stat
        dc.l      _bcon6out
        dc.l      _rs6conf
        dc.l      rs232iorec

        dc.l      _bcon7stat                    /* Dev 7: "Modem 2" - SCC Channel B */
        dc.l      _bcon7in
        dc.l      _bco7stat
        dc.l      _bcon7out
        dc.l      _rs7conf
        dc.l      mdm2iorec

#if TTMFP_SUPPORT
        dc.l      _bcon8stat                    /* Dev 8: "Serial 1" - TT MFP */
        dc.l      _bcon8in
        dc.l      _bco8stat
        dc.l      _bcon8out
        dc.l      _rs8conf
        dc.l      mdm3iorec
#endif

        dc.l      _bcon9stat                    /* Dev 8/9: "Serial 2" - SCC Channel A */
        dc.l      _bcon9in
        dc.l      _bco9stat
        dc.l      _bcon9out
        dc.l      _rs9conf
        dc.l      mdm4iorec

/*
 * XBIOS #44 - Bconmap - Select a default port.
 */
/* 306de: 00e02baa */
	xdef _bconmap
_bconmap:
        moveq.l   #0,d0
        move.w    4(a7),d1
        move.w    ABSW(bcmap_root+6),d0 /* bcmap_root.auxnr */
        cmp.w     #-1,d1
        beq.s     bconmap1
        move.l    #bcmap_root,d0
        cmp.w     #-2,d1
        beq.s     bconmap1
        moveq.l   #0,d0
        subq.w    #BCONMAP_START_HANDLE,d1
        bmi.s     bconmap1
        cmp.w     ABSW(bcmap_root+4),d1 /* bcmap_root.maptabsize */
        bcc.s     bconmap1
        move.w    ABSW(bcmap_root+6),d1 /* bcmap_root.auxnr */
        subq.w    #BCONMAP_START_HANDLE,d1
        asl.w     #3,d1 /* calculate d1 * 24 */
        move.w    d1,d2
        add.w     d1,d1
        add.w     d1,d2 /* d2 now sizeof(MAPTAB) */
        movea.l   ABSW(bcmap_root),a0 /* bcmap_root.maptab */
        adda.w    d2,a0
/* build active MAPTAB from system variables for device 1 (aux) */
        lea.l     ABSW(_bconstat_vec+1*4),a1
        move.l    (a1),(a0)+
        move.l    32(a1),(a0)+
        move.l    64(a1),(a0)+
        move.l    96(a1),(a0)+
        move.l    bcmap_root+8,(a0)+ /* bcmap_root.rscon */
        move.l    ABSW(bcmap_root+12),(a0)+ /* bcmap_root.iorec */
        move.w    4(a7),d1
        subq.w    #BCONMAP_START_HANDLE,d1
        asl.w     #3,d1
        move.w    d1,d2
        add.w     d1,d1
        add.w     d1,d2
        movea.l   ABSW(bcmap_root),a0 /* bcmap_root.maptab */
        adda.w    d2,a0
/* update system variables for device 1 (aux) */
        move.l    (a0)+,(a1)
        move.l    (a0)+,32(a1)
        move.l    (a0)+,64(a1)
        move.l    (a0)+,96(a1)
        move.l    (a0)+,ABSW(bcmap_root+8) /* bcmap_root.rscon */
        move.l    (a0)+,ABSW(bcmap_root+12) /* bcmap_root.iorec */
        move.w    ABSW(bcmap_root+6),d0 /* bcmap_root.auxnr */
        move.w    4(a7),ABSW(bcmap_root+6)
bconmap1:
        rts
#endif


#if TOSVERSION >= 0x200
/* 306de: 00e02c38 */
/* 206de: 00e028ea */
initdevstables:
        lea.l     ABSW(bcmap_devs),a0
        move.l    a0,ABSW(bcmap_root+0)     /* bcmap_root.maptab */
        move.w    #rs232devs,ABSW(bcmap_root+4) /* bcmap_root.maptabsize */
#if !TTMFP_SUPPORT
        moveq     #1,d0                         /* only MFP RS232 is available */
        movea.l   sp,a1
        movea.l   ABSW(_buserror),a2
        move.l    #initdevnoscc,ABSW(_buserror)
        tst.b     ABSW(scu_gp1)
        move.w    #3,d0                         /* also 2 SCC RS232 are available */
initdevnoscc:
        movea.l  a1,sp
        move.l    a2,ABSW(_buserror)
        move.w    d0,ABSW(bcmap_root+4)
#endif
        lea.l     bcondevs(pc),a1
        move.w    #rs232devs*6-1,d0
initdev1:
        move.l    (a1)+,(a0)+
        dbf       d0,initdev1
        move.w    #6,ABSW(bcmap_root+6)         /* Device 6 is mapped into device 1 (Aux) */
/* install device 6 vectors also in system variables for device 1 (aux) */
        lea.l     bcondevs,a1
        lea.l     ABSW(_bconstat_vec+1*4),a0    /* Map MFP RS232 to dev 1 */
        move.l    (a1)+,(a0)                    /* Fix tconstat for dev 1 */
        move.l    (a1)+,32(a0)                  /* Fix tconin for dev 1 */
        move.l    (a1)+,64(a0)                  /* Fix tcostat for dev 1 */
        move.l    (a1)+,96(a0)                  /* Fix tconout for dev 1 */
        move.l    (a1)+,ABSW(bcmap_root+8)      /* Fix rsconf for RS232 */
        move.l    (a1)+,ABSW(bcmap_root+12)     /* Fix Iorec for RS232 */
        rts
#endif

#if TTMFP_SUPPORT
/*
 * Bconstat function for device 8 (TTMFP serial port)
 */
_bcon8stat:
        lea.l     ABSW(mdm3iorec),a0
        bra       bcon6st1

/*
 * Bconin function for device 8 (TTMFP serial port)
 */
_bcon8in:
        lea.l     ABSW(mdm3iorec),a0
        lea.l     ABSW(TTMFP_REGS),a2
        bra       bcon6in1

/*
 * Bcostat function for device 8 (TTMFP serial port)
 */
_bco8stat:
        lea.l     ABSW(mdm3iorec+IOREC_SIZE),a0
        bra       bco6s1


/*
 * Bconout function for device 8 (TTMFP serial port)
 */
_bcon8out:
        move.w    6(a7),d0
        lea.l     ABSW(mdm3iorec+IOREC_SIZE),a0
        bsr       iorecput
        lea.l     ABSW(mdm3iorec),a0
        lea.l     ABSW(TTMFP_REGS),a2
        bra       bcon6o1

/*************************************************************************
 * receiver buffer full interrupt routine for TTMFP
 *************************************************************************/
/* 306de: 00e02cb0 */
ttrcvrint:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(mdm3iorec),a0
        lea.l     ABSW(TTMFP_REGS),a2
        bra       rcvrint1

/*************************************************************************
 * transmit buffer empty interrupt routine fo TTFMP
 *************************************************************************/
tttxrint:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(TTMFP_REGS),a2
        lea.l     ABSW(mdm3iorec),a0
        bra       txrint1

/*************************************************************************
 * routines to handle tx or rx errors for TTMFP
 *************************************************************************/
ttrxerror:
        movem.l   d0/a0,-(a7)
        lea.l     ABSW(TTMFP_REGS),a0
        bra       rxerror1

tttxerror:
        move.l    a0,-(a7)
        lea.l     ABSW(TTMFP_REGS),a0
        bra       txerror1

/*
 * Rsconf function for device 8 (TTMFP serial port)
 */
/* 306de: 00e02ce6 */
_rs8conf:
        lea.l     ABSW(mdm3iorec),a0
        lea.l     ABSW(TTMFP_REGS),a2
        bra       rs6conf1
#endif


#if TOSVERSION >= 0x200
/* 206de: 00e02950 */
sccinit:
        move.b    (a1)+,d0                      /* SCC register number */
        bmi.s     sccinit1                      /* end of the register list? => exit */
        move.b    d0,(a0)                       /* select register */
        move.b    (a1)+,(a0)                    /* write into register */
        bra.s     sccinit
sccinit1:
        rts

/* SCC initialization */
scctbl:
        dc.b $04,$44            /* x16 clock mode, 1 stop bit, no parity */
        dc.b $01,$04            /* 'parity is special condition' */
        dc.b $02,$60            /* interrupt vector #s start at 0x60 (lowmem 0x180) */
        dc.b $03,$c0            /* Rx 8 bits/char, disabled */
        dc.b $05,$e2            /* Tx 8 bits/char, disabled, DTR, RTS */
        dc.b $06,$00            /* SDLC (n/a) */
        dc.b $07,$00            /* SDLC (n/a) */
        dc.b $09,$01            /* status low, vector includes status */
        dc.b $0a,$00            /* misc flags */
        dc.b $0b,$50            /* Rx/Tx clocks from baudrate generator output */
        dc.b $0c,$18            /* time const low = 24 | so rate = (24+2)*2/BR clock period */
        dc.b $0d,$00            /* time const hi = 0   | = 52/(8053976/16) => 9680 bps */
        dc.b $0e,$02            /* baudrate generator source = PCLK (8MHz) */
        dc.b $0e,$03            /* ditto + enable baudrate generator */
        dc.b $03,$c1            /* Rx 8 bits/char, enabled */
        dc.b $05,$ea            /* Tx 8 bits/char, enabled, DTR, RTS */
        dc.b $0f,$20            /* CTS interrupt enable */
        dc.b $00,$10            /* reset external/status interrupts */
        dc.b $00,$10            /* reset again (necessary, see manual) */
        dc.b $01,$17            /* interrupts for Rx, Tx, special condition; parity is special */
        dc.b $09,$09            /* status low, master interrupt enable */
        dc.b $ff,$00            /* end of table */


/* disconnect LAN from port a */
nolan:
        move.w    sr,d1
        ori.w     #$0700,sr
        move.b    #$0E,ABSW(psgsel)
        move.b    ABSW(psgsel),d0
        bset      #7,d0
        move.b    #$0E,ABSW(psgsel)
        move.b    d0,ABSW(psgwr)
        move.w    d1,sr
        rts

/* 306de: 00e02d4c */
/* 206de: 00e029aa */
initscc:
        movea.l   ABSW(_buserror),a0
        movea.l   a7,a1
        move.l    #initscc2,ABSW(_buserror)
        tst.b     ABSW(SCCA_DATA)
        move.l    a0,ABSW(_buserror)
        lea.l     ABSW($00000180),a0
        lea.l     sccvect(pc),a1
        moveq.l   #4*4-1,d0
initscc1:
        move.l    (a1)+,(a0)+
        dbf       d0,initscc1
        bsr.s     nolan
        lea.l     ABSW(mdm4iorec),a0
        lea.l     mdm2table(pc),a1
        moveq.l   #EXTIOREC_SIZE+1,d0 /* BUG: should be -1; overwrites first 2 bytes of mdm2ibuf */
        bsr       copymem
        lea.l     ABSW(mdm2iorec),a0
        lea.l     mdm2table(pc),a1
        moveq.l   #EXTIOREC_SIZE+1,d0 /* BUG: should be -1; overwrites fd_retry */
        bsr       copymem
        move.l    #mdm2ibuf,ABSW(mdm2iorec)
        move.l    #mdm2obuf,ABSW(mdm2iorec+IOREC_SIZE)
        lea.l     ABSW(SCCA_BASE),a2
        move.b    #$09,(a2)
        move.b    #$C0,(a2)
        move.w    #$0104,d0                     /* Delay Mode, /4 Prescale, data = 4 (about 6us delay) */
        jsr       mfpdelay
        lea.l     ABSW(SCCA_BASE),a0
        lea.l     scctbl(pc),a1
        bsr       sccinit
        lea.l     ABSW(SCCB_BASE),a0
        lea.l     scctbl(pc),a1
        bsr       sccinit
        bset      #5,ABSW(vme_mask)             /* Enable IRQ5 from VMEBUS/SCC */
        rts
initscc2:
        move.l    a0,ABSW(_buserror)
        movea.l   a1,a7
        rts

/**************************************************************************
 *                                                                        *
 *                 Z85C30 SCC interrupt vectors                           *
 *                                                                        *
 **************************************************************************/

/*************************************************************************
 * transmit buffer empty interrupt routine for SCC channel B
 *************************************************************************/
sccbempty:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCB_BASE),a2
        lea.l     ABSW(mdm2iorec),a0
        bra       sccempty

/*************************************************************************
 * status interrupt routine for SCC channel B
 *************************************************************************/
sccbstat:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCB_BASE),a2
        lea.l     ABSW(mdm2iorec),a0
        bra       sccstat

/*************************************************************************
 * receiver buffer full interrupt routine for SCC channel B
 *************************************************************************/
sccbrxint:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCB_BASE),a2
        lea.l     ABSW(mdm2iorec),a0
        bra.s     sccrxint

/*************************************************************************
 * RX/TX error interrupt routine for SCC channel B (unused)
 *************************************************************************/
sccbrxerr:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCB_BASE),a2
        lea.l     mdm2iorec,a0
        bra       sccrxerr

/*************************************************************************
 * transmit buffer empty interrupt routine for SCC channel A
 *************************************************************************/
sccaempty:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCA_BASE),a2
        lea.l     ABSW(mdm4iorec),a0
        bra       sccempty

/*************************************************************************
 * status interrupt routine for SCC channel A
 *************************************************************************/
sccastat:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCA_BASE),a2
        lea.l     ABSW(mdm4iorec),a0
        bra       sccstat

/*************************************************************************
 * receiver buffer full interrupt routine for SCC channel A
 *************************************************************************/
sccarxint:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCA_BASE),a2
        lea.l     ABSW(mdm4iorec),a0
        bra.s     sccrxint

/*************************************************************************
 * RX/TX error interrupt routine for SCC channel A (unused)
 *************************************************************************/
sccarxerr:
        movem.l   d0-d1/a0-a2,-(a7)
        lea.l     ABSW(SCCA_BASE),a2
        lea.l     mdm4iorec,a0
        bra       sccrxerr

/*************************************************************************
 * receiver buffer full interrupt routine for SCC
 *************************************************************************/
/* 306de: 00e02e62 */
/* 206de: 00e02abc */
sccrxint:
        move.b    #$08,(a2)                     /* select scc register #8 */
        move.b    (a2),d0                       /* read "Receive Data register" */
        and.b     datamask(a0),d0
        btst      #0,ctr(a0)
        beq.s     sccrxin2
        cmp.b     #$13,d0
        bne.s     sccrxin1
        st        xoff(a0)
        bra.s     sccrxin6
sccrxin1:
        cmp.b     #$11,d0
        bne.s     sccrxin2
        tst.b     xoff(a0)
        sf        xoff(a0)
        bne.s     sccrxin5
sccrxin2:
        move.w    tail(a0),d1
        bsr       wrapin
        cmp.w     head(a0),d1
        beq.s     sccrxin6
        bsr       iorecput
        tst.b     ctr(a0)
        beq.s     sccrxin6
        tst.b     highwater(a0)
        bne.s     sccrxin6
        move.w    tail(a0),d0
        sub.w     head(a0),d0
        bpl.s     sccrxin3
        add.w     size(a0),d0
sccrxin3:
        cmp.w     high(a0),d0
        blt.s     sccrxin6
        st        highwater(a0)
        btst      #0,ctr(a0)
        bne.s     sccrxin4
        move.b    wr5(a0),d0
        bclr      #1,d0                         /* clear RTS bit */
        move.b    d0,wr5(a0)
        move.b    #$05,(a2)                     /* select scc register #5 */
        move.b    d0,(a2)                       /* write "Transmit Parameters and Controls" register */
        bra.s     sccrxin6
sccrxin4:
        move.b    #$13,xonoffc(a0)
sccrxin5:
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    (a2),d0                       /* read register #0 */
        btst      #2,d0                         /* Tx Buffer Empty? */
        beq.s     sccrxin6
        bsr.s     sccout
sccrxin6:
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    #$38,(a2)                     /* write "Reset Highest IUS Command" - clear pending interrupt */
        movem.l   (a7)+,d0-d1/a0-a2
        rte

/*************************************************************************
 * RX/TX error interrupt routine for SCC
 *************************************************************************/
sccrxerr:
        move.b    #$01,(a2)                     /* select scc register #1 */
        move.b    (a2),d0                       /* read special receive condition status bits */
        move.b    #$08,(a2)                     /* select scc register #8 */
        move.b    (a2),d0                       /* read "Receive Data register" */
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    #$30,(a2)                     /* write "Error Reset Command" - clear error condition */
        bra.s     sccrxin6

/*************************************************************************
 * write a character from the ring buffer to the SCC
 *************************************************************************/
/* 306de: 00e02f1a */
/* 206de: 00e02b74 */
sccout:
        move.l    a0,-(a7)
        tst.b     xonoffc(a0)
        bne.s     sccout1
#if STBOOK
            btst      #0,ctr(a0)
            beq.s     scc18
            tst.b     xoff(a0)
            bne.s     sccout4
scc18:      btst      #1,ctr(a0)
            beq.s     sccout1
            move.b    #0,(a2)                   /* select scc register #0 */
            move.b    (a2),d0                   /* read register #0 */
            btst      #5,d0                     /* CTS? */
            beq.s     sccout4
#else
        move.b    ctr(a0),d0
        and.b     xoff(a0),d0
        bne.s     sccout4
#endif
sccout1:
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    (a2),d0                       /* read register #0 */
        btst      #2,d0                         /* Tx Buffer Empty? */
        beq.s     sccout4
        move.b    xonoffc(a0),d0
        beq.s     sccout2
        clr.b     xonoffc(a0)
        bra.s     sccout3
sccout2:
        adda.w    #$000E,a0
        move.w    head(a0),d0
        cmp.w     tail(a0),d0
        beq.s     sccout4
        bsr       iorecget
sccout3:
        move.b    #$08,(a2)                     /* select scc register #8 */
        move.b    d0,(a2)                       /* write transmit buffer */
sccout4:
        movea.l   (a7)+,a0
        rts

/*************************************************************************
 * transmit buffer empty interrupt routine for SCC
 *************************************************************************/
/* 306de: 00e02f60 */
/* 206de: 00e02bba */
sccempty:
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    #$28,(a2)                     /* write "Reset Tx Int Pending" */
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    #$38,(a2)                     /* write "Reset Highest IUS Command" - clear pending interrupt */
        bsr.s     sccout
        movem.l   (a7)+,d0-d1/a0-a2
        rte

/*************************************************************************
 * status interrupt routine for SCC
 *************************************************************************/
/* 306de: 00e02f78 */
/* 206de: 00e02bd2 */
sccstat:
        btst      #1,ctr(a0)
        beq.s     sccstat1
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    (a2),d0                       /* read register #0 */
        btst      #5,d0                         /* CTS? */
        seq       xoff(a0)
        beq.s     sccstat1
#if STBOOK
        bsr       sccout
#else
        bsr.s     sccout
#endif
sccstat1:
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    #$10,(a2)                     /* write "Reset Ext/Status Interrupts" */
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    #$38,(a2)                     /* write "Reset Highest IUS Command" - clear pending interrupt */
        movem.l   (a7)+,d0-d1/a0-a2
        rte

/**************************************************************************
 *                                                                        *
 *                  scc BIOS callbacks                                    *
 *                                                                        *
 **************************************************************************/
/*
 * Bconstat function for device 7 (SCC channel B)
 */
/* 306de: 00e02fa8 */
/* 206de: 00e02c02 */
_bcon7stat:
        lea.l     ABSW(mdm2iorec),a0
        lea.l     ABSW(SCCB_BASE),a2
        bra.s     sccistat

/*
 * Bconin function for device 7 (SCC channel B)
 */
/* 306de: 00e02fb2 */
/* 206de: 00e02c0c */
_bcon7in:
        lea.l     ABSW(mdm2iorec),a0
        lea.l     ABSW(SCCB_BASE),a2
        bra.s     sccin

/*
 * Bcostat function for device 7 (SCC channel B)
 */
/* 306de: 00e02fbc */
/* 206de: 00e02c16 */
_bco7stat:
        lea.l     ABSW(mdm2iorec),a0
        lea.l     ABSW(SCCB_BASE),a2
        bra.s     sccostat

/*
 * Bconout function for device 7 (SCC channel B)
 */
/* 306de: 00e02fc6 */
/* 206de: 00e02c20 */
_bcon7out:
        lea.l     ABSW(mdm2iorec),a0
        lea.l     ABSW(SCCB_BASE),a2
        bra       sccxout

/*
 * Bconstat function for device 9 (SCC channel A)
 */
/* 306de: 00e02fd2 */
/* 206de: 00e02c2c */
_bcon9stat:
        lea.l     ABSW(mdm4iorec),a0
        lea.l     ABSW(SCCA_BASE),a2
        bra.s     sccistat

/*
 * Bconin function for device 9 (SCC channel A)
 */
/* 306de: 00e02fdc */
/* 206de: 00e02c36 */
_bcon9in:
        lea.l     ABSW(mdm4iorec),a0
        lea.l     ABSW(SCCA_BASE),a2
        bra.s     sccin

/*
 * Bcostat function for device 9 (SCC channel A)
 */
/* 306de: 00e02fe6 */
/* 206de: 00e02c40 */
_bco9stat:
        lea.l     ABSW(mdm4iorec),a0
        lea.l     ABSW(SCCA_BASE),a2
        bra.s     sccostat

/*
 * Bconout function for device 9 (SCC channel A)
 */
/* 306de: 00e02ff0 */
/* 206de: 00e02c4a */
_bcon9out:
        lea.l     ABSW(mdm4iorec),a0
        lea.l     ABSW(SCCA_BASE),a2
        bra.s     sccxout

/**************************************************************************
 *                                                                        *
 *                  scc port input status routine                         *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e02ffa */
/* 206de: 00e02c52 */
sccistat:
        moveq.l   #0,d0                         /* set result to false */
        lea.l     head(a0),a1
        lea.l     tail(a0),a0
        cmpm.w    (a0)+,(a1)+                   /* buffer empty test */
        beq.s     sccist1
        moveq.l   #-1,d0
sccist1:
        rts

/**************************************************************************
 *                                                                        *
 *                  scc port output status routine                        *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e0300c */
/* 206de: 00e02c66 */
sccostat:
        move.w    tail(a0),d1
        bsr       wrapin
        cmp.w     head(a0),d1
        beq.s     sccost1
        moveq.l   #-1,d0
        rts
sccost1:
        moveq.l   #0,d0
        rts

/**************************************************************************
 *                                                                        *
 *                  scc input routine                                     *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e03022 */
/* 206de: 00e02c7c */
sccin:
        bsr       iorecget
        move.w    d0,-(a7)
        tst.b     ctr(a0)                       /* flow control active? */
        beq.s     sccin2                        /* (no) */
        tst.b     highwater(a0)                 /* high-water flag already set? */
        beq.s     sccin2                        /* no...exit... */
        move.w    tail(a0),d0
        sub.w     head(a0),d0
        bpl.s     sccin1                        /* underflow? */
        add.w     size(a0),d0                   /* + size */
sccin1:
        cmp.w     low(a0),d0
        bgt.s     sccin2
        bsr.s     scccont
sccin2:
        move.w    (a7)+,d0
        rts

scccont:
        clr.b     highwater(a0)                 /* clear high-water flag */
        btst      #0,ctr(a0)                    /* is the rs232 mode xon/xoff? */
        beq.s     scccont1
        move.b    #$11,xonoffc(a0)              /* "xon" */
        bra.s     sccxout0
scccont1:
        move.b    wr5(a0),d0
        bset      #1,d0                         /* set RTS */
        move.b    d0,wr5(a0)
        move.b    #$05,(a2)                     /* select scc register #5 */
        move.b    d0,(a2)                       /* write "Transmit Parameters and Controls" register */
        rts

/**************************************************************************
 *                                                                        *
 *                  scc output routine                                    *
 *                                                                        *
 **************************************************************************/
/* 306de: 00e03076 */
/* 206de: 00e02cd0 */
sccxout:
        move.w    6(a7),d0                      /* get data */
        adda.w    #IOREC_SIZE,a0                /* switch to output buffer */
        bsr       iorecput                      /* exit via rs-232 output routine */
        suba.w    #IOREC_SIZE,a0                /* switch back to input buffer */
sccxout0:
        move.b    #$00,(a2)                     /* select scc register #0 */
        move.b    (a2),d0                       /* read register #0 */
        btst      #2,d0                         /* Tx Buffer Empty? */
        beq.s     sccxout1                      /* not ready */
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        bsr       sccout
        move.w    (a7)+,sr
sccxout1:
        rts


/**************************************************************************
 *                                                                        *
 *                  scc rsconf() routine                                  *
 *                                                                        *
 **************************************************************************/
/*
 * Rsconf function for device 9 (SCC channel A)
 */
/* 306de: 00e030a0 */
/* 206de: 00e02cfa */
_rs9conf:
        lea.l     ABSW(mdm4iorec),a0            /* point to current output buffer record */
        lea.l     ABSW(SCCA_BASE),a2
        bra.s     sccconf

/*
 * Rsconf function for device 7 (SCC channel B)
 */
/* 306de: 00e030aa */
/* 206de: 00e02d04 */
_rs7conf:
        lea.l     ABSW(mdm2iorec),a0            /* point to current output buffer record */
        lea.l     ABSW(SCCB_BASE),a2
sccconf:
        moveq.l   #0,d0
        cmpi.w    #-2,4(a7)                     /* -2 = return last baudrate */
        bne.s     sccconf1
        move.b    baudrate(a0),d0               /* last baudrate */
        rts
sccconf1:
        ori.w     #$0700,sr                     /* no interrupts for now */
/*      first we grab the old ucs,rsr,tsr,scr contents */
        moveq.l   #0,d7
        move.b    rcv(a0),d7
        asl.w     #8,d7
        swap      d7
        move.b    wr5(a0),d7
        lsr.b     #1,d7
        and.b     #$04,d7
        asl.w     #8,d7
/*      set flow control mode(s) */
        move.w    6(a7),d0                      /* if -1 then don't change */
        cmp.w     #$0003,d0
        bhi.s     sccconf5
        bne.s     sccconf2
        moveq.l   #1,d0                         /* set flag for handshake */
sccconf2:
        cmp.b     ctr(a0),d0                    /* state unchanged? => continue */
        beq.s     sccconf5
        tst.b     xoff(a0)                      /* xon flag set? */
        beq.s     sccconf3
        clr.b     xoff(a0)                      /* clear xon flag */
        bsr       sccout
sccconf3:
        tst.b     highwater(a0)                 /* RTS set? */
        beq.s     sccconf4                      /* no... */
        move.w    d0,-(a7)                      /* save new handshake state */
        bsr       scccont                       /* reenable RTS */
        move.w    (a7)+,d0                      /* new handshake state */
sccconf4:
        move.b    d0,ctr(a0)                    /* set new handshake state */
sccconf5:
/*      set timer baud rate */
        move.w    4(a7),d0                      /* new baudrate */
        cmp.w     #$000F,d0                     /* if -1 (out of range 0..15) then don't change */
        bhi.s     sccconf6
        move.b    d0,baudrate(a0)               /* new baudrate */
        asl.w     #1,d0
        lea.l     sccbaudtab,a1
        move.w    0(a1,d0.w),d0
        move.b    #$0C,(a2)                     /* select scc register #12 */
        move.b    d0,(a2)                       /* write "Lower Byte of Baud Rate Generator Time Constant" register */
        lsr.w     #8,d0
        move.b    #$0D,(a2)                     /* select scc register #13 */
        move.b    d0,(a2)                       /* write "Upper Byte of Baud Rate Generator Time Constant" register */
sccconf6:
/*      set rs-232 registers */
        move.w    8(a7),d0                      /* if -1 then don't change */
        bmi.s     scccon11
        move.b    d0,rcv(a0)
        move.b    d0,d1
        and.b     #$60,d1
        lsr.b     #5,d1
        moveq.l   #-1,d2
        lsr.b     d1,d2
        move.b    d2,datamask(a0)
        move.b    d0,d1
        and.b     #$60,d1
        beq.s     sccconf7
        cmp.b     #$60,d1
        bne.s     sccconf8
sccconf7:
        eori.b    #$60,d1
sccconf8:
        move.b    wr5(a0),d2
        and.b     #$9F,d2
        or.b      d1,d2
        move.b    d2,wr5(a0)
        move.b    #$05,(a2)                     /* select scc register #5 */
        move.b    d2,(a2)                       /* write "Transmit Parameters and Controls" register */
        asl.b     #1,d1
        or.b      #$01,d1                       /* "Rx Enable" */
        move.b    #$03,(a2)                     /* select scc register #3 */
        move.b    d1,(a2)                       /* write "Receive Parameters and Control" register */
        move.b    d0,d1
        and.b     #$1E,d1
        lsr.b     #1,d1                         /* mask stop bits (bit 2..3) and parity (bit 0..1) */
        bclr      #1,d1
        sne       d2
        bclr      #0,d1                         /* disable parity */
        bne.s     sccconf9
        bclr      #1,d2                         /* "odd parity" */
        bra.s     scccon10
sccconf9:
        bset      #1,d2                         /* "even parity" */
scccon10:
        and.b     #$03,d2                       /* mask parity bits */
        or.b      d2,d1
        or.b      #$40,d1                       /* "X16 Clock Mode" */
        move.b    #$04,(a2)                     /* select scc register #4 */
        move.b    d1,(a2)                       /* write "Transmit/Receive Mis- cellaneous Parameters and Modes" register */
scccon11:
#if (TOSVERSION >= 0x300) | !BINEXACT
        move.w    10(a7),d0                     /* if -1 then don't change */
#else
        move.w    12(a7),d0                     /* ?? bug in 2.06 maybe */
#endif
        bmi.s     scccon13
        btst      #3,d0
        beq.s     scccon12
        bset      #4,wr5(a0)                    /* set "Tx Enable" */
        bne.s     scccon13
        move.b    #$05,(a2)                     /* select scc register #5 */
        move.b    wr5(a0),(a2)                  /* write "Transmit Parameters and Controls" register */
        bra.s     scccon13
scccon12:
        bclr      #4,wr5(a0)                    /* clear "Tx Enable" */
        beq.s     scccon13
        move.b    #$05,(a2)                     /* select scc register #5 */
        move.b    wr5(a0),(a2)                  /* write "Transmit Parameters and Controls" register */
scccon13:
        move.l    d7,d0                         /* move old contents of rs-232 registers to d0.l */
        rts

/* 306de: 00e031e4 */
/* 206de: 00e02e3e */
sccbaudtab: dc.w $000b,$0018,$0032,$0044,$0067,$007c,$008a,$00d0
            dc.w $01a1,$0345,$04e8,$068c,$074d,$08ee,$0d1a,$13a8


/*
 * interrupt vectors for SCC A&B copied to 0x180
 */
sccvect:
       dc.l      sccbempty
       dc.l      0
       dc.l      sccbstat
       dc.l      0
       dc.l      sccbrxint
       dc.l      0
       dc.l      sccbrxint
       dc.l      0
       dc.l      sccaempty
       dc.l      0
       dc.l      sccastat
       dc.l      0
       dc.l      sccarxint
       dc.l      0
       dc.l      sccarxint
       dc.l      0

/*
 * initial EXT_IOREC for device 7 (modem2) & device 9 (modem4)
 */
mdm2table:
        dc.l mdm4ibuf
        dc.w SERIAL_BUFSIZE,0,0,128,192
        dc.l mdm4obuf
        dc.w SERIAL_BUFSIZE,0,0,128,192
        dc.b 8,$ea,0,0,1,0,1,$ff

#endif /* SCC support */


/*************************************************************************
 * receiver buffer full interrupt handler for IKBD/MIDI ACIA
 *************************************************************************/
/* 306de: 00e03268 */
/* 206de: 00e02ec2 */
/* 104de: 00fc3aec */
/* 106de: 00e03ca0 */
/* 162de: 00e03ca0 */
_int_acia:
#if TOSVERSION >= 0x200
        movem.l   d0-d3/a0-a3,-(a7)
#else
        movem.l   d0-d3/a0-a3/a5,-(a7)
#endif
        SETBASEREG
intacia1:
        movea.l   ABSW(midisys),a2
        jsr       (a2)
        movea.l   ABSW(ikbdsys),a2
        jsr       (a2)
        btst      #4,ABSW(MFP_GPIP)    /* ACIA receiver buffer empty? */
        beq.s     intacia1             /* no, read more bytes */
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$BF,ABSW(MFP_ISRB)  /* clear in-service bit */
#else
        bclr      #6,ABSW(MFP_ISRB)    /* clear in-service bit */
#endif
#if TOSVERSION >= 0x200
        movem.l   (a7)+,d0-d3/a0-a3
#else
        movem.l   (a7)+,d0-d3/a0-a3/a5
#endif
        rte

_midisys:
        lea.l     ABSW(midiiorec),a0
        lea.l     ABSW(ACIA_MIDI_BASE),a1
        movea.l   ABSW(vmiderr),a2
        bra.s     _aciasys
_ikbdsys:
        lea.l     ABSW(ikbdiorec),a0
        lea.l     ABSW2(ACIA_IKBD_BASE),a1
        movea.l   ABSW(vkbderr),a2
_aciasys:
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    (a1),d2
#else
        move.b    0(a1),d2
#endif
        btst      #7,d2        /* interrupt request? */
        beq.s     aciasys2     /* no, ignore */
        btst      #0,d2        /* receiver data full? */
        beq.s     aciasys1     /* no, skip processing */
        movem.l   d2/a0-a2,-(a7)
        bsr.s     aciaread
        movem.l   (a7)+,d2/a0-a2
aciasys1:
        andi.b    #$20,d2      /* receiver overrun? */
        beq.s     aciasys2     /* no, we are done */
        move.b    ACIA_DATA(a1),d0     /* read data byte */
        jmp       (a2)         /* yes, call error function */
aciasys2:
        rts


/*
 * ==== IKBD stuff ================
 *
 * Packets received from the IKBD are accumulated into the kbdbuf buffer.
 * The packet header (F6 to FF) determines the packet length and the
 * action to be taken once the packet has been received completely.
 * During the reception of a packet, variable ikbdstate contains the
 * action number, and variable kbdlength contains the number of bytes
 * not received yet.
 *
 * action <--whole IKBD packet-->  Comment
 * number    <-given to routine->
 *
 *  1     F6 a1 a2 a3 a4 a5 a6 a7 (miscellaneous, 7 bytes)
 *  2     F7 0b xh xl yh yl       (absolute mouse)
 *  3     F8 dx dy                (relative mouse, no button)
 *  3     F9 dx dy                (relative mouse, button 1)
 *  3     FA dx dy                (relative mouse, button 2)
 *  3     FB dx dy                (relative mouse, both buttons)
 *  4     FC yy MM dd hh mm ss    (date and time)
 *  5     FD j0 j1                (both joysticks)
 *  6     FE bj                   (joystick 0)
 *  7     FF bj                   (joystick 1)
 */
/* 306de: 00e032cc */
/* 206de: 00e02f26 */
/* 104de: 00fc3b56 */
/* 106de: 00e03d0a */
/* 162de: 00e03d0a */
aciaread:
        move.b    ACIA_DATA(a1),d0      /* read data byte */
        cmpa.l    #ikbdiorec,a0
        bne       midiread
        tst.b     ABSW(ikbdstate)       /* inside a multi-byte packet? */
        bne.s     in_packet             /* ikbdstate != 0 => go and add to the packet */
        cmpi.b    #$F6,d0               /* is byte a packet header? */
#if TOSVERSION >= 0x200
        bcc.s     begin_packet          /* byte >= 0xf6 => go begin receiving a packet */
        move.l    ABSW(kbdvec),-(a7)    /* ordinary key byte in d0. jump in vector */
        rts
#else
        bcs       _kbdvec               /* byte < 0xf6 => go begin receiving a key */
#endif
begin_packet:
        subi.b    #$F6,d0               /* generate table index */
        andi.l    #$000000FF,d0
        lea.l     ikbd_state_table,a3
        move.b    0(a3,d0.w),ABSW(ikbdstate) /* set ikbd state */
        lea.l     kbd_length_table,a3
        move.b    0(a3,d0.w),ABSW(kbdlength) /* set number expected bytes to follow */
        addi.w    #$00F6,d0             /* reconstruct input byte */
        cmpi.b    #$F8,d0               /* mouse position record? */
        blt.s     begin_p1              /* no */
        cmpi.b    #$FB,d0               /* mouse position record? */
        bgt.s     begin_p1              /* no */
        move.b    d0,ABSW(relmbuf)      /* store first byte with button states */
        rts
begin_p1:
        cmpi.b    #$FD,d0               /* joystick record? */
        blt.s     begin_p2              /* no */
        move.b    d0,ABSW(joybuf)       /* store joystick byte */
begin_p2:
        rts

                                        /* 0 1 2 3 4 5 6 7 8 9 */
ikbd_state_table:                     dc.b 1,2,3,3,3,3,4,5,6,7
kbd_length_table:                     dc.b 7,5,2,2,2,2,6,2,1,1

in_packet:
        cmpi.b    #$06,ABSW(ikbdstate) /* joystick packet? */
        bcc       kbd_joy             /* yes, handle separately */
        lea.l     ikbdbaddr,a2
        moveq.l   #0,d2
        move.b    ABSW(ikbdstate),d2
        subq.b    #1,d2
        asl.w     #1,d2
        add.b     ABSW(ikbdstate),d2
        subq.b    #1,d2
        asl.w     #2,d2               /* d2 now (ikbdstate - 1) * 12 */
        movea.l   0(a2,d2.w),a0       /* get start of buffer */
        movea.l   4(a2,d2.w),a1       /* get end of buffer */
        movea.l   8(a2,d2.w),a2       /* get packet handler address */
        movea.l   (a2),a2             /* get packet handler */
        moveq.l   #0,d2
        move.b    ABSW(kbdlength),d2
        suba.l    d2,a1
        move.b    d0,(a1)             /* store input byte */
        subq.b    #1,ABSW(kbdlength)  /* decrement the number of bytes in the package */
        tst.b     ABSW(kbdlength)     /* packet complete? */
        bne.s     in_pack2            /* no */
in_pack1:
        move.l    a0,-(a7)
        jsr       (a2)                /* call packet handler */
        addq.w    #4,a7
        clr.b     ABSW(ikbdstate)     /* reset ikbd state */
in_pack2:
        rts

ikbdbaddr:
        dc.l kbdbuf,kbdbuf+7,statvec
        dc.l mousebuf,mousebuf+5,mousevec
        dc.l relmbuf,relmbuf+3,mousevec
        dc.l clockbuf,clockbuf+6,clockvec
        dc.l joybuf,joybuf+2,joyvec

/* handle joystick packet $FE,$FF */
kbd_joy:
        move.l    #joybuf+1,d1
        add.b     ABSW(ikbdstate),d1           /* ikbdstate reflects joy0 or joy1 state */
        subq.b    #6,d1
        movea.l   d1,a2
        move.b    d0,(a2)
        movea.l   ABSW(joyvec),a2              /* get user defined handler */
        lea.l     ABSW(joybuf),a0
        bra.s     in_pack1                     /* and go call it */

/********************************
 * handler for ordinary keys
 ********************************/
/* 306de: 00e033ea */
/* 206de: 00e03044 */
/* 104de: 00fc3c70 */
_kbdvec:
        move.b    ABSW(_shifty),d1              /* get current shift state */
        cmpi.b    #$2A,d0                       /* left shift pressed? */
        bne.s     kbdvec1
        bset      #1,d1
        bra       kbdvec10
kbdvec1:
        cmpi.b    #$AA,d0                       /* left shift released? */
        bne.s     kbdvec2
        bclr      #1,d1
        bra       kbdvec10
kbdvec2:
        cmpi.b    #$36,d0                       /* right shift pressed? */
        bne.s     kbdvec3
        bset      #0,d1
        bra.s     kbdvec10
kbdvec3:
        cmpi.b    #$B6,d0                       /* right shift released? */
        bne.s     kbdvec4
        bclr      #0,d1
        bra.s     kbdvec10
kbdvec4:
        cmpi.b    #$1D,d0                       /* control pressed? */
        bne.s     kbdvec5
        bset      #2,d1
        bra.s     kbdvec10
kbdvec5:
        cmpi.b    #$9D,d0                       /* control released? */
        bne.s     kbdvec6
        bclr      #2,d1
        bra.s     kbdvec10
kbdvec6:
        cmpi.b    #$38,d0                       /* ALT pressed? */
        bne.s     kbdvec7
        bset      #3,d1
        bra.s     kbdvec10
kbdvec7:
        cmpi.b    #$B8,d0                       /* ALT released? */
        bne.s     kbdvec8
        bclr      #3,d1
#if TOSVERSION >= 0x200
        tst.w     kb_altnum                     /* ascii code via numpad active? */
        bmi.s     kbdvec10
        move.b    d1,ABSW(_shifty)
        move.l    a0,-(a7)
        moveq.l   #0,d1                         /* clear ascii code reg */
        move.w    d1,d0
        move.b    kb_altnum+1,d0                /* get entered ascii code */
        move.w    #-1,kb_altnum
        bra       kbdvec44
#else
        bra       kbdvec10
#endif
kbdvec8:
        cmpi.b    #$3A,d0                       /* CAPS LOCK pressed? */
        bne.s     kbdvec11
        btst      #0,ABSW(_conterm)             /* should click sound be produced? */
        beq.s     kbdvec9
#if TOSVERSION >= 0x200
        movem.l   d0-d2/a0-a2,-(a7)
        movea.l   ABSW(_kcl_hook),a0
        jsr       (a0)
        movem.l   (a7)+,d0-d2/a0-a2
#else
        move.l    #_clicksnd,ABSW(_sndtable)
        move.b    #$00,ABSW(_snddelay)
#endif
kbdvec9:
        bchg      #4,d1                         /* toggle CAPS LOCK state */
kbdvec10:
        move.b    d1,ABSW(_shifty)              /* store new shift state */
        rts
kbdvec11:
        btst      #7,d0                         /* was key released? */
        bne.s     kbdvec12
        move.b    d0,ABSW(kb_key_last)          /* save for key repeat */
        move.b    kb_initial,ABSW(kb_ticks)
        move.b    kb_repeat,ABSW(kb_delay)
        bra.s     kbdvec15
kbdvec12:
        move.b    d0,d1
        bclr      #7,d1
        cmp.b     ABSW(kb_key_last),d1
        bne.s     kbdvec13
        moveq.l   #0,d1
        move.b    d1,ABSW(kb_key_last)
        move.b    d1,ABSW(kb_ticks)
        move.b    d1,ABSW(kb_delay)
kbdvec13:
        cmpi.b    #$C7,d0                       /* was it HOME? */
        beq.s     kbdvec14
        cmpi.b    #$D2,d0                       /* was it INSERT? */
        bne       kbdvec47
kbdvec14:
        btst      #3,ABSW(_shifty)              /* ... and ALT active? */
        beq       kbdvec47
kbdvec15:
        btst      #0,ABSW(_conterm)             /* should click sound be produced? */
        beq.s     kbdvec16
#if TOSVERSION >= 0x200
        movem.l   d0-d2/a0-a2,-(a7)
        movea.l   ABSW(_kcl_hook),a1
        jsr       (a1)
        movem.l   (a7)+,d0-d2/a0-a2
#else
        move.l    #_clicksnd,ABSW(_sndtable)
        move.b    #$00,ABSW(_snddelay)
#endif
kbdvec16:
        move.l    a0,-(a7)                      /* store ikbdiorec pointer */
        moveq.l   #0,d1
        move.b    d0,d1
        movea.l   ABSW(_curkeytbl),a0
        andi.w    #$007F,d0
        btst      #4,ABSW(_shifty)              /* caps-lock active? */
        beq.s     kbdvec17
        movea.l   ABSW(_curkeytbl+8),a0         /* use caps-lock table */
kbdvec17:
        btst      #0,ABSW(_shifty)              /* left shift active? */
        bne.s     kbdvec18
        btst      #1,ABSW(_shifty)              /* right shift active? */
        beq.s     kbdvec20
kbdvec18:
        cmpi.b    #$3B,d0                       /* was it a function key? */
        bcs.s     kbdvec19                      /* no */
        cmpi.b    #$44,d0
        bhi.s     kbdvec19                      /* no */
        addi.w    #$0019,d1                     /* add to change to GSX standard */
        moveq.l   #0,d0
        bra       kbdvec44
kbdvec19:
        movea.l   ABSW(_curkeytbl+4),a0         /* use the shift table */
kbdvec20:
        move.b    0(a0,d0.w),d0                 /* get ascii code from key table */
        btst      #2,ABSW(_shifty)              /* control active? */
        beq.s     kbdvec27
        cmpi.b    #$0D,d0                       /* control-CR, convert to LF */
        bne.s     kbdvec21
        moveq.l   #10,d0
        beq.s     kbdvec24
kbdvec21:
        cmpi.b    #$47,d1                       /* convert CONTROL-home to gsx standard */
        bne.s     kbdvec22
        addi.w    #$0030,d1
        bra       kbdvec44
kbdvec22:
        cmpi.b    #$4B,d1                       /* convert CONTROL-left arrow to gsx standard */
        bne.s     kbdvec23
        moveq.l   #$73,d1
        moveq.l   #0,d0
        bra       kbdvec44
kbdvec23:
        cmpi.b    #$4D,d1                       /* convert CONTROL-right arrow to gsx standard */
        bne.s     kbdvec24
        moveq.l   #$74,d1
        moveq.l   #0,d0
        bra       kbdvec44
kbdvec24:
        cmpi.b    #$32,d0                       /* convert control-shift-down arrow to gsx standard */
        bne.s     kbdvec25
        moveq.l   #0,d0
        bra       kbdvec44
kbdvec25:
        cmpi.b    #$36,d0                       /* convert control-shift-right arrow to gsx standard */
        bne.s     kbdvec26
        moveq.l   #$1e,d0
        bra       kbdvec44
kbdvec26:
        cmpi.b    #$2D,d0                       /* convert control-shift-kp-minus to gsx standard */
        bne.s     kbdvec27
        moveq.l   #$1f,d0
        bra       kbdvec44
kbdvec27:
        btst      #3,ABSW(_shifty)              /* is alt active? */
        beq       kbdvec42
#if TOSVERSION >= 0x200
        cmp.b     #$67,d1                       /* keypad key 0 - 9? */
        bcs.s     kbdvec29                      /* no */
        cmp.b     #$70,d1
        bhi.s     kbdvec29                      /* no */
        move.w    kb_altnum,d0
        bpl.s     kbdvec28
        moveq.l   #0,d0
kbdvec28:
        mulu.w    #$000A,d0
        ext.w     d1
        move.b    0(a0,d1.w),d1                 /* get ascii code of keypad key */
        sub.b     #$30,d1
        add.b     d1,d0
        move.w    d0,kb_altnum                  /* store as new number code */
        movea.l   (a7)+,a0
        rts
kbdvec29:
#endif

/*
 * Country-dependent key translations
 */
/* 306any: 00e035e0 */
/* 206any: 00e0323a */
/* 205any: 00e028a0 */
/* 104any: 00fc3e10 */
/* 106any: 00e03fc4 */
/* 162any: 00e03fc4 */
#if OS_COUNTRY == CTRY_US
/* nothing to do */
#endif

#if OS_COUNTRY == CTRY_DE
        cmpi.b    #$1A,d1                       /* convert ALT-udiaresis to @ or backslash */
        bne.s     kbdde1
        move.b    #$40,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$5C,d0
        bra       kbdvec42
kbdde1:
        cmpi.b    #$27,d1                       /* convert ALT-odiaresis to [ or { */
        bne.s     kbdde2
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdde2:
        cmpi.b    #$28,d1                       /* convert ALT-adiaresis to ] or } */
        bne.s     kbdde3
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdde3:
#endif

#if OS_COUNTRY == CTRY_SF
        cmpi.b    #$1A,d1                       /* convert ALT-udiaresis to @ or backslash */
        bne.s     kbdsf1
        move.b    #$40,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$5C,d0
        bra       kbdvec42
kbdsf1:
        cmpi.b    #$27,d1                       /* convert ALT-odiaresis to [ or { */
        bne.s     kbdsf2
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdsf2:
        cmpi.b    #$28,d1                       /* convert ALT-adiaresis to ] or } */
        bne.s     kbdsf3
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdsf3:
        cmpi.b    #$1b,d1                       /* convert ALT-? to # */
        bne.s     kbdsf4
        move.b    #$23,d0
        bra       kbdvec42
kbdsf4:
        cmpi.b    #$2b,d1                       /* convert ALT-? to tilde or | */
        bne.s     kbdsf5
        move.b    #$7e,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7c,d0
        bra       kbdvec42
kbdsf5:
#endif

#if OS_COUNTRY == CTRY_SG
        cmpi.b    #$1A,d1                       /* convert ALT-udiaresis to @ or backslash */
        bne.s     kbdsg1
        move.b    #$40,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$5C,d0
        bra       kbdvec42
kbdsg1:
        cmpi.b    #$27,d1                       /* convert ALT-odiaresis to [ or { */
        bne.s     kbdsg2
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdsg2:
        cmpi.b    #$28,d1                       /* convert ALT-adiaresis to ] or } */
        bne.s     kbdsg3
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdsg3:
        cmpi.b    #$1b,d1                       /* convert ALT-? to # */
        bne.s     kbdsg4
        move.b    #$23,d0
        bra       kbdvec42
kbdsg4:
        cmpi.b    #$2b,d1                       /* convert ALT-? to tilde or | */
        bne.s     kbdsg5
        move.b    #$7e,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7c,d0
        bra       kbdvec42
kbdsg5:
#endif

#if OS_COUNTRY == CTRY_FR
        cmpi.b    #$1A,d1                       /* convert ALT-^ to [ or { */
        bne.s     kbdfr1
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdfr1:
        cmpi.b    #$1B,d1                       /* convert ALT-$ to ] or } */
        bne.s     kbdfr2
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdfr2:
        cmpi.b    #$28,d1                       /* convert ALT-u to backslash or 0 */
        bne.s     kbdfr3
        move.b    #$5C,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$00,d0
        bra       kbdvec42
kbdfr3:
        cmpi.b    #$2B,d1                       /* convert ALT-# to @ or tilde */
        bne.s     kbdfr4
        move.b    #$40,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7E,d0
        bra       kbdvec42
kbdfr4:
#endif

#if OS_COUNTRY == CTRY_UK
/* nothing to do */
#endif

#if OS_COUNTRY == CTRY_ES
        cmpi.b    #$1A,d1                       /* convert ALT-' to [ or { */
        bne.s     kbdes1
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdes1:
        cmpi.b    #$1B,d1                       /* convert ALT-` to ] or } */
        bne.s     kbdes2
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdes2:
        cmpi.b    #$2B,d1                       /* convert ALT-? to # or @ */
        bne.s     kbdes3
        move.b    #$23,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$40,d0
        bra       kbdvec42
kbdes3:
        cmpi.b    #$28,d1                       /* convert ALT-; to # or @ */
        bne.s     kbdes4
        move.b    #$81,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$00,d0
        bra       kbdvec42
kbdes4:
        cmpi.b    #$27,d1                       /* convert ALT-n to 0 */
        bne.s     kbdes5
        move.b    #$00,d0
        bra       kbdvec42
kbdes5:
#endif

#if OS_COUNTRY == CTRY_IT
        cmpi.b    #$1A,d1                       /* convert ALT-e to [ or { */
        bne.s     kbdit1
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdit1:
        cmpi.b    #$1B,d1                       /* convert ALT-+ to ] or } */
        bne.s     kbdit2
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdit2:
        cmpi.b    #$2B,d1                       /* convert ALT-\ to degree or tilde */
        bne.s     kbdit3
        move.b    #$F8,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7E,d0
        bra       kbdvec42
kbdit3:
        cmpi.b    #$60,d1
        bne.s     kbdit4
        move.b    #$60,d0
        bra       kbdvec42
kbdit4:
#endif

#if OS_COUNTRY == CTRY_SE
        cmpi.b    #$1A,d1                       /* convert ALT-a to [ or { */
        bne.s     kbdsv1
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdsv1:
        cmpi.b    #$1B,d1                       /* convert ALT-u to ] or } */
        bne.s     kbdsv2
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdsv2:
        cmpi.b    #$28,d1                       /* convert ALT-a to grave accent or tilde */
        bne.s     kbdsv3
        move.b    #$60,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7e,d0
        bra       kbdvec42
kbdsv3:
        cmpi.b    #$2B,d1                       /* convert ALT-\ to ^ or @ */
        bne.s     kbdsv4
        move.b    #$5E,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$40,d0
        bra       kbdvec42
kbdsv4:
#endif

#if OS_COUNTRY == CTRY_PL
        cmpi.b    #$1A,d1                       /* convert ALT-udiaresis to @ or backslash */
        bne.s     kbdpl1
        move.b    #$40,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$5C,d0
        bra       kbdvec42
kbdpl1:
        cmpi.b    #$27,d1                       /* convert ALT-odiaresis to [ or { */
        bne.s     kbdpl2
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdpl2:
        cmpi.b    #$28,d1                       /* convert ALT-adiaresis to ] or } */
        bne.s     kbdpl3
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdpl3:
#endif

#if OS_COUNTRY == CTRY_CZ
        cmpi.b    #$1A,d1                       /* convert ALT-udiaresis to @ or backslash */
        bne.s     kbdcz1
        move.b    #$40,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$5C,d0
        bra       kbdvec42
kbdcz1:
        cmpi.b    #$27,d1                       /* convert ALT-odiaresis to [ or { */
        bne.s     kbdcz2
        move.b    #$5B,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7B,d0
        bra       kbdvec42
kbdcz2:
        cmpi.b    #$28,d1                       /* convert ALT-adiaresis to ] or } */
        bne.s     kbdcz3
        move.b    #$5D,d0
        move.b    ABSW(_shifty),d2
        andi.b    #$03,d2
        beq       kbdvec42
        move.b    #$7D,d0
        bra       kbdvec42
kbdcz3:
#endif

/* 206de: 00e03294 */
/* 306de: 00e0363a */
/* 104de: 00fc3e6a */

/*
 * end of country specific key handling
 */

        cmpi.b    #$62,d1                       /* is it an "alt help" signal to dump the screen? */
        bne.s     kbdvec33
        addq.w    #1,ABSW(_dumpflg)
        movea.l   (a7)+,a0
        bra       kbdvec47
kbdvec33:
        lea.l     mousekey,a2                   /* get pointer to first alt. mouse scancode table */
        moveq.l   #3,d2
kbdvec34:
        cmp.b     0(a2,d2.w),d1
        beq       keymouse
        dbf       d2,kbdvec34
        cmpi.b    #$48,d1                       /* is it an up arrow? */
        bne.s     kbdvec35
        move.b    #$00,d1
        move.b    #-$08,d2
        move.b    ABSW(_shifty),d0
        andi.b    #$03,d0
        beq       keymous4
        move.b    #-1,d2
        bra       keymous4
kbdvec35:
        cmpi.b    #$4B,d1                       /* is it an left arrow? */
        bne.s     kbdvec36
        move.b    #$00,d2
        move.b    #-$08,d1
        move.b    ABSW(_shifty),d0
        andi.b    #$03,d0
        beq       keymous4
        move.b    #-1,d1
        bra       keymous4
kbdvec36:
        cmpi.b    #$4D,d1                       /* is it an right arrow? */
        bne.s     kbdvec37
        move.b    #$08,d1
        move.b    #$00,d2
        move.b    ABSW(_shifty),d0
        andi.b    #$03,d0
        beq       keymous4
        move.b    #$01,d1
        bra       keymous4
kbdvec37:
        cmpi.b    #$50,d1                       /* is it an down arrow? */
        bne.s     kbdvec38
        move.b    #$00,d1
        move.b    #$08,d2
        move.b    ABSW(_shifty),d0
        andi.b    #$03,d0
        beq       keymous4
        move.b    #$01,d2
        bra       keymous4
kbdvec38:
        btst      #2,ABSW(_shifty)              /* is control active? */
        bne.s     kbdvec43                      /* yes, skip */
        cmpi.b    #$02,d1                       /* is scancode between '1' key and '=' key? */
        bcs.s     kbdvec39
        cmpi.b    #$0D,d1
        bhi.s     kbdvec39
        addi.b    #$76,d1
        bra.s     kbdvec40
kbdvec39:
        cmpi.b    #$41,d0                       /* is it an ascii character 'A' -'Z'? */
        bcs.s     kbdvec41
        cmpi.b    #$5A,d0
        bhi.s     kbdvec41
kbdvec40:
        moveq.l   #0,d0
        bra.s     kbdvec44
kbdvec41:
        cmpi.b    #$61,d0                       /* is it an ascii character 'a' -'z'? */
        bcs.s     kbdvec44
        cmpi.b    #$7A,d0
        bhi.s     kbdvec44
        bra.s     kbdvec40
kbdvec42:
        btst      #2,ABSW(_shifty)
        beq.s     kbdvec44
kbdvec43:
        andi.w    #$001F,d0
kbdvec44:
        asl.w     #8,d1                         /* put scancode to high byte */
        add.w     d1,d0                         /* insert ascii code */
        movea.l   (a7)+,a0
        move.w    tail(a0),d1
        addq.w    #4,d1
        cmp.w     size(a0),d1                   /* room for 4 bytes? */
        bcs.s     kbdvec45
        moveq.l   #0,d1
kbdvec45:
        cmp.w     head(a0),d1                   /* keyboard buffer full? */
        beq.s     kbdvec47                      /* yes, drop it */
        movea.l   buf(a0),a2
        swap      d0                            /* put shift state to high word */
#if !BINEXACT
        clr.w     d0
#else
        move.w    #0,d0
#endif
        move.b    ABSW(_shifty),d0
        swap      d0
        lsl.l     #8,d0
        lsr.w     #8,d0
        move.l    d0,d2                         /* save keycode for tests */
        bclr      #28,d2                        /* clear capslock state */
        swap      d2
        cmp.w     #$0C53,d2                     /* control+alt+delete? */
        beq       _main                         /* yes, reset */
        cmp.w     #$0D53,d2                     /* control+alt+leftshift-delete? */
        beq       coldboot
        btst      #3,ABSW(_conterm)
        bne.s     kbdvec46
        andi.l    #$00FFFFFF,d0
kbdvec46:
        and.l     #$0000FFFF,d1
        move.l    d0,0(a2,d1.l)
        move.w    d1,tail(a0)
kbdvec47:
        rts

#if TOSVERSION >= 0x200
/*
 * default function for system variable kcl_hook
 */
/* 306de: 00e0378a */
/* 206de: 00e033e4 */
	xdef _do_keyclick
_do_keyclick:
        move.l    #_clicksnd,ABSW(_sndtable)
        move.b    #$00,ABSW(_snddelay)
        rts
#endif

/* 306de: 00e0379a */
midiread:
        movea.l   ABSW(midivec),a2              /* get contents of midivec for indirect branch */
        jmp       (a2)                          /* jump to midi interrupt handler */

/* 306de: 00e037a0 */
/* 206de: 00e033fa */
/* 104de: 00fc3fc4 */
/* 106de: 00e04188 */
/* 162de: 00e04188 */
_midivec:
        move.w    tail(a0),d1                   /* get current tail pointer offset */
        addq.w    #1,d1                         /* index = tail + 1 */
        cmp.w     size(a0),d1                   /* check to see if buffer should wrap */
        bcs.s     midivec1                      /* no... */
        moveq.l   #0,d1                         /* wrap pointer */
midivec1:
        cmp.w     head(a0),d1                   /* head=tail? */
        beq.s     midivec2                      /* yes */
        movea.l   buf(a0),a2                    /* get buffer pointer */
        and.l     #$0000FFFF,d1
        move.b    d0,0(a2,d1.l)                 /* store the data */
        move.w    d1,tail(a0)                   /* store the new buftail pointer */
midivec2:
        rts


/* 306de: 00e037c6 */
/* 206de: 00e03420 */
keymouse:
        moveq.l   #5,d3                         /* pre-init to "keyboard" right mouse button */
        btst      #4,d1                         /* see if it is a left or right button... */
        beq.s     keymous1                      /* it's a right button ($47/$c7) */
        moveq.l   #6,d3                         /* it's a left button ($52/$d2) */
keymous1:
        btst      #7,d1                         /* see if it is a make or break action */
        beq.s     keymous2                      /* it's a set button action (make code) */
        bclr      d3,ABSW(_shifty)              /* it's a clear button action (break code) */
        bra.s     keymous3                      /* go to further pre-init action... */
keymous2:
        bset      d3,ABSW(_shifty)              /* it's a set button action (set code) */
keymous3:
        moveq.l   #0,d1
        moveq.l   #0,d2
/* finish up at the actual pseudo mouse routine */
keymous4:
        lea.l     ABSW(buttonbuf),a0            /* point to key-emulating mouse buffer */
        movea.l   ABSW(mousevec),a2             /* grab mouse interrupt vector */
        clr.l     d0
        move.b    ABSW(_shifty),d0              /* get current button status */
        lsr.b     #5,d0                         /* shift right button bit to 'd0' */
        addi.b    #$F8,d0                       /* add relative mouse header */
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    d0,(a0)                       /* store in first byte of record header */
#else
        move.b    d0,0(a0)                      /* store in first byte of record header */
#endif
        move.b    d1,1(a0)                      /* store x value in second byte of record buffer */
        move.b    d2,2(a0)                      /* store y value in third byte of record buffer */
        jsr       (a2)
        movea.l   (a7)+,a0                      /* restore ikbdiorec pointer */
        rts

/* scancode that send mouse packets */
mousekey:  dc.b      $47,$c7,$52,$d2


/* 306de: 00e0380c */
/* 206de: 00e03466 */
/* 404: 00e0398c */
	xdef coldboot
coldboot:
        move.w    #$2700,sr                 /* disable all IRQSR */

			lea       coldboor(pc),a0
			move.w    #16-1,d0
			movea.w   #$0008,a1
coldboo1:	move.l    (a0)+,(a1)+				/* copy erase routine to $000c... */
			dbra      d0,coldboo1
			SETBASEREG
			jmp       ABSW($0008)

coldboor:	lea       coldbooe(pc),a0
			move.l    a0,ABSW(_buserror)
			lea       coldbend(pc),a0
			moveq     #0,d0
			move.l    d0,d1
			move.l    d0,d2
			move.l    d0,d3
			move.l    d0,d4
			move.l    d0,d5
			move.l    d0,d6
			move.l    d0,d7
coldbool:	movem.l   d0-d7,(a0)
			adda.w    #$0020,a0
			bra.s     coldbool
coldbooe:   move.l    ABSW(4),a0
            jmp       (a0)
coldbend:   dc.w 0


/*************************************************************************
 * XBIOS #28 - Giaccess - Permit access to the registers of the GI       *
 *       sound chip.                                                     *
 *                                                                       *
 *       protocol for accessing a gi sound chip register                 *
 *                                                                       *
 *       this bios call must be accessed in supervisor state             *
 *       because it affects the 'sr' register                            *
 *                                                                       *
 *       entry                                                           *
 *                                                                       *
 *       word    giaccess(data,register)                                 *
 *       word    data,register                                           *
 *                                                                       *
 *               data -- data register read/write date                   *
 *               register -- chip register to select                     *
 *               d1 = #$0000     selects read operation of the register  *
 *               d1 = #$80 .or .xx       selects write xx to register    *
 *               example write to portb - $80 .or. $0f = $8f             *
 *                                                                       *
 *       exit                                                            *
 *       read operations                                                 *
 *       d0.b -- data register contains byte of date                     *
 *       write operations                                                *
 *       d0.b -- data register contains a verification of written data   *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e0387e */
/* 206de: 00e03498 */
/* 104de: 00fc407e */
	xdef _giaccess
_giaccess:
        move.w    4(a7),d0
        move.w    6(a7),d1
gientry:
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        movem.l   d1-d2/a0,-(a7)                /* save affected registers */
        lea.l     ABSW2(psgsel),a0              /* init desired gi register addr */
        move.b    d1,d2                         /* make a copy to test for read or write */
        andi.b    #$0F,d1                       /* turn off any extraneous bits */
        move.b    d1,(a0)                       /* select register */
        asl.b     #1,d2                         /* shift once for carry bit detection */
        bcc.s     giacces1                      /* carry clear, so do a read operation */
        move.b    d0,2(a0)                      /* init the memory location */
giacces1:
        moveq.l   #0,d0                         /* clear our register */
        move.b    (a0),d0                       /* grab the data from the gi register */
        movem.l   (a7)+,d1-d2/a0                /* restore affected registers */
        move.w    (a7)+,sr
        rts


/*********************************************************************
 *       routine to turn on the dtr signal                           *
 *********************************************************************/
dtron:
        moveq     #$EF,d2
        bra.s     offbit

/*********************************************************************
 * XBIOS #30 - Ongibit - Set individual bits in the port A register  *
 * of the GI sound chip.                                             *
 *                                                                   *
 *       routine to set any bit in the gi port a area                *
 *                                                                   *
 *       entry                                                       *
 *                                                                   *
 *       word    ongibit(bitnum)                                     *
 *       word    bitnum                                              *
 *                                                                   *
 *               bitnum - byte size mask with desired bit set to "1" *
 *                                                                   *
 *********************************************************************/
/* 306de: 00e038b6 */
/* 206de: 00e034d0 */
/* 104de: 00fc40b6 */
	xdef _ongibit
_ongibit:
        moveq.l   #0,d2
        move.w    4(a7),d2
onbit:
        movem.l   d0-d2,-(a7)
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        moveq.l   #14,d1                        /* get ready to read in the port a contents */
        move.l    d2,-(a7)
        bsr.s     gientry                       /* go get it... */
        move.l    (a7)+,d2
        or.b      d2,d0                         /* set bit(s) on */
        moveq     #$8E,d1                       /* setup to write to port a */
        bsr.s     gientry                       /* go set it and return */
        move.w    (a7)+,sr
        movem.l   (a7)+,d0-d2
        rts


/*********************************************************************
 * XBIOS #29 - Offgibit - Clear individual bits in the port A        *
 * register of the GI sound chip.                                    *
 *                                                                   *
 *       routine to clear any bit in the gi port a area              *
 *                                                                   *
 *       entry                                                       *
 *                                                                   *
 *       word    offgibit(bitnum)                                    *
 *       word    bitnum                                              *
 *                                                                   *
 *               bitnum - byte size mask with desired bit set to "0" *
 *                                                                   *
 *********************************************************************/
/* 306de: 00e038de */
/* 206de: 00e034f8 */
/* 104de: 00fc40dc */
	xdef _offgibit
_offgibit:
        moveq.l   #0,d2
        move.w    4(a7),d2
offbit:
        movem.l   d0-d2,-(a7)
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        moveq.l   #14,d1                        /* get ready to read in the port a contents */
        move.l    d2,-(a7)
        bsr.s     gientry                       /* go get it... */
        move.l    (a7)+,d2
        and.b     d2,d0                         /* turn bit(s) off */
        moveq     #$8E,d1                       /* setup to write to port a */
        bsr.s     gientry                       /* go set it and return */
        move.w    (a7)+,sr
        movem.l   (a7)+,d0-d2
        rts


/*************************************************************************
 * XBIOS #0 - Initmouse - Initializes the mouse handler.                 *
 *                                                                       *
 *               EXTENDED RBP BIOS TIMER INIT CALL                       *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       word    initmous(type,param,intvec)                             *
 *       word    type                                                    *
 *       long    param,initvec                                           *
 *                                                                       *
 *               type - key/abs/rel/off  mouse function requested        *
 *                       4/  2/  1/  0   value                           *
 *               param - address of parameter block                      *
 *               intvec - mouse interrupt vector                         *
 *                                                                       *
 *                                                                       *
 *       parameter block definition:                                     *
 *                                                                       *
 *       byte 0 - y=0 at top/bottom if non-zero then y=0 at bottom       *
 *               otherwise y=0 at top                                    *
 *       byte 1 - parameter for set mouse buttons command                *
 *       byte 2 - x threshold/scale/delta parameter                      *
 *       byte 3 - y threshold/scale/delta parameter                      *
 *                                                                       *
 *       the following bytes are required for the absolute mode only     *
 *                                                                       *
 *       byte 4 - xmsb for absolute mouse maximum position               *
 *       byte 5 - xlsb for absolute mouse maximum position               *
 *       byte 6 - ymsb for absolute mouse maximum position               *
 *       byte 7 - ylsb for absolute mouse maximum position               *
 *       byte 8 - xmsb for absolute mouse initial position               *
 *       byte 9 - xlsb for absolute mouse initial position               *
 *       byte a - ymsb for absolute mouse initial position               *
 *       byte b - ylsb for absolute mouse initial position               *
 *                                                                       *
 *************************************************************************/

/* 306de: 00e03906 */
/* 206de: 00e03520 */
/* 104de: 00fc4102 */
/* first we determine if the init is for a absolute, relative or keycode */
/* mouse action. */
	xdef _initmouse
_initmouse:
        tst.w     4(a7)                         /* turn mouse off? */
        beq.s     initmou1                      /* yes...disable mouse */
        move.l    10(a7),ABSW(mousevec)         /* init the mouse interrupt vector */
        movea.l   6(a7),a3
        cmpi.w    #1,4(a7)                      /* relative mouse request? */
        beq.s     initmou2                      /* yes... */
        cmpi.w    #2,4(a7)                      /* absolute mouse request? */
        beq.s     initmou3                      /* yes... */
        cmpi.w    #4,4(a7)                      /* keycode mouse request? */
        beq.s     initmou4                      /* yes... */
        moveq.l   #0,d0                         /* error condition returned -- improper request */
        rts
initmou1:
        moveq.l   #$12,d1                       /* disable mouse */
        bsr       ikbd_writeb
        move.l    #imrts,ABSW(mousevec)         /* re-init the mouse interrupt vector */
        bra.s     initmou5
initmou2:
        lea.l     ABSW(initmbuf),a2             /* set transfer buffer pointer */
        move.b    #$08,(a2)+                    /* set to relative mouse */
        move.b    #$0B,(a2)+                    /* set relative mouse threshold x,y */
        bsr.s     setmouse
        moveq.l   #6,d3                         /* set length of the string -1 to transfer */
        lea.l     ABSW(initmbuf),a2             /* set transfer buffer pointer */
        bsr       ikbdws1                       /* do transfer to ikbd */
        bra.s     initmou5

initmou3:
        lea.l     ABSW(initmbuf),a2             /* set transfer buffer pointer */
        move.b    #$09,(a2)+                    /* set to absolute mouse */
        move.b    4(a3),(a2)+                   /* set xmsb max */
        move.b    5(a3),(a2)+                   /* set xlsb max */
        move.b    6(a3),(a2)+                   /* set ymsb max */
        move.b    7(a3),(a2)+                   /* set ylsb max */
        move.b    #$0C,(a2)+                    /* set absolute mouse scale */
        bsr.s     setmouse
        move.b    #$0E,(a2)+                    /* load initial absolute mouse position */
        move.b    #$00,(a2)+                    /* filler load */
        move.b    8(a3),(a2)+                   /* initial xmsb absolute mouse position */
        move.b    9(a3),(a2)+                   /* initial xlsb absolute mouse position */
        move.b    10(a3),(a2)+                  /* initial ymsb absolute mouse position */
        move.b    11(a3),(a2)+                  /* initial ylsb absolute mouse position */
        moveq.l   #16,d3                        /* set length of string -1 to transfer */
        lea.l     ABSW(initmbuf),a2             /* set transfer buffer pointer */
        bsr       ikbdws1                       /* do transfer to ikbd */
        bra.s     initmou5

initmou4:
        lea.l     ABSW(initmbuf),a2             /* set transfer buffer pointer */
        move.b    #$0A,(a2)+                    /* set to mouse keycode mode */
        bsr.s     setmouse
        moveq.l   #5,d3                         /* set length of string -1 to transfer */
        lea.l     ABSW(initmbuf),a2             /* set transfer buffer pointer */
        bsr       ikbdws1                       /* do transfer to ikbd */
initmou5:
        moveq.l   #-1,d0                        /* set to true to indicate good init */
        rts

setmouse:
        move.b    2(a3),(a2)+                   /* set x threshold/scale/delta */
        move.b    3(a3),(a2)+                   /* set y threshold/scale/delta */
        moveq.l   #16,d1                        /* setup to determine if top/bottom */
#if (TOSVERSION >= 0x200) | !BINEXACT
        sub.b     (a3),d1                       /* set y=0 at ? */
#else
        sub.b     0(a3),d1                      /* set y=0 at ? */
#endif
        move.b    d1,(a2)+
        move.b    #$07,(a2)+                    /* set mouse button action */
        move.b    1(a3),(a2)+                   /* mouse button parameter */
        rts

/*************************************************************************
 * XBIOS #31 - Xbtimer - Initialize the timer in the MFP chip.           *
 *                                                                       *
 *               EXTENDED RBP BIOS TIMER INIT CALL                       *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       void    xbtimer(id,control,data,intvec)                         *
 *       word    id,control,data                                         *
 *       long    intvec                                                  *
 *                                                                       *
 *               intvec - timer interrupt vector                         *
 *               control - timer's control setting                       *
 *               data - timer's data register setting                    *
 *               id - timer id   a-0, b-1, c-2, d-3                      *
 *                                                                       *
 *       Special Note:                                                   *
 *                                                                       *
 *       In the interest of preserving as many features for the user     *
 *       in the future, timer A should be reserved for the end-user      *
 *       or independent software vendor's application program.  System   *
 *       software or those application needing just a "tick" should      *
 *       constrain themselves to timer C, which is adequate for delay    *
 *       and other timing uses.  Future hardware may or may not bring    *
 *       out the timer A input line out...giving software developers     *
 *       another useful aspect of the machine to utilize.                *
 *                                                                       *
 *       The recommended usage of the timers is as follows:              *
 *                                                                       *
 *       Timer A - Reserved for end-users and stand-alone applications.  *
 *       Timer B - Reserved for screen graphics, primarily.              *
 *       Timer C - Reserved for system timing (GSX,GEM,DESKTOP,ET.AL).   *
 *       Timer D - Reserved for baud rate control of RS-232 port,        *
 *                the interrupt vector is available to anyone.           *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e039ce */
/* 206de: 00e035e8 */
/* 104de: 00fc41cc */
	xdef _xbtimer
_xbtimer:
        moveq.l   #0,d0
        moveq.l   #0,d1
        moveq.l   #0,d2
        move.w    4(a7),d0
        move.w    6(a7),d1
        move.w    8(a7),d2
        bsr       settimer                      /* setup the timer */
        tst.l     10(a7)                        /* if <0 then skip and exit */
        bmi.s     imrts
        movea.l   10(a7),a2                     /* setup for initint call */
        moveq.l   #0,d1                         /* clear long */
        lea.l     xbtimtab(pc),a1               /* point to timer -> interrupt # translation tab */
        andi.l    #$000000FF,d0                 /* mask off the highest three bytes in register */
        move.b    0(a1,d0.w),d0                 /* setup for initint call */
        bsr       initint
imrts:
        rts

xbtimtab:  dc.b 13,8,5,4


/*************************************************************************
 * XBIOS #16 - Keytbl - Define the mapping table for the keyboard        *
 * scancodes to key-codes.                                               *
 *                                                                       *
 *               KEYBOARD TRANSLATION TABLE CHANGE CALL                  *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       long    keytrans(unshift,shift,capslock)                        *
 *       long    unshift,shift,capslock                                  *
 *                                                                       *
 *               -1 signifies no change to vector                        *
 *                                                                       *
 *       exit:                                                           *
 *               d0.l - returns pointer to beginning of                  *
 *                       key translation address pointers                *
 *               order of pointers is:                                   *
 *               unshifted,shifted,caps-locked                           *
 *               Note:  buffer space for each table should $80!!         *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e03a08 */
/* 206de: 00e03622 */
/* 104de: 00fc4206 */
/* 404: 00e03b64 */
	xdef _keytbl
_keytbl:
        tst.l     4(a7)
        bmi.s     _keytbl1
        move.l    4(a7),ABSW(_curkeytbl)
_keytbl1:
        tst.l     8(a7)
        bmi.s     _keytbl2
        move.l    8(a7),ABSW(_curkeytbl+4)
_keytbl2:
        tst.l     12(a7)
        bmi.s     _keytbl3
        move.l    12(a7),ABSW(_curkeytbl+8)
_keytbl3:
        move.l    #_curkeytbl,d0
        rts


/*************************************************************************
 * XBIOS #24 - Bioskeys - Reinitialize keyboard.                         *
 *                                                                       *
 *               RESTORE BIOS KEYBOARD TRANSLATION TABLE                 *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       void    bioskeys()                                              *
 *                                                                       *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e03a08 */
/* 206de: 00e0364e */
/* 104de: 00fc4232 */
	xdef _bioskeys
_bioskeys:
        move.l    #_keytblnorm,ABSW(_curkeytbl)
        move.l    #_keytblshift,ABSW(_curkeytbl+4)
        move.l    #_keytblcaps,ABSW(_curkeytbl+8)
        rts

/*************************************************************************
 *                                                                       *
 * XBIOS #32 - Dosound - Program the sound generator (PSG).              *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       void    dosound(ptr)                                            *
 *       long    ptr     points to start of sound interpreter table      *
 *                                                                       *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e03a4e */
/* 206de: 00e0366c */
/* 104de: 00fc424c */
	xdef _dosound
_dosound:
        move.l    ABSW(_sndtable),d0            /* return current status in D0.L */
        move.l    4(a7),d1                      /* if new ptr < 0, then just return */
        bmi.s     dosound1                      /* (invalid ptr, so return) */
        move.l    d1,ABSW(_sndtable)            /* setup new sound ptr */
        clr.b     ABSW(_snddelay)               /* zap sound timer register */
dosound1:
        rts


/*************************************************************************
 *                                                                       *
 * XBIOS #33 - Setprt - Initialize the printer.                          *
 *                                                                       *
 *               SET/RETURN PRINTER CONFIGURATION WORD                   *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       word    setptr(pconfig)                                         *
 *       word    pconfig sets/gets printer information word              *
 *                                                                       *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e03a62 */
/* 206de: 00e03680 */
/* 104de: 00fc4260 */
	xdef _setprt
_setprt:
        move.w    ABSW(_prtconfig),d0           /* get current config word before we change it */
        tst.w     4(a7)                         /* see if we don't change the word */
        bmi.s     setprt1                       /* don't set printer word */
        move.w    4(a7),ABSW(_prtconfig)        /* set printer config word */
setprt1:
        rts


/*************************************************************************
 *                                                                       *
 * XBIOS #35 - Kbrate - Set the auto-repeat rate of the keyboard.        *
 *                                                                       *
 *               SET/RETURN KEY REPEAT VALUES                            *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       word    kbrate(initial,repeat)                                  *
 *       word    initial,repeat                                          *
 *                                                                       *
 *       initial determines the number of 50 hz cycles to wait before    *
 *       a keyrepeat is to commence.  repeat determines the interval     *
 *       between keyrepeats after the initial pause.                     *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e03a74 */
/* 206de: 00e03692 */
/* 104de: 00fc4272 */
	xdef _kbrate
_kbrate:
        move.w    ABSW(kb_initial),d0           /* get current initial/repeat values */
        tst.w     4(a7)                         /* see if we don't change the word */
        bmi.s     kbrate1                       /* don't set key repeat values */
        move.w    4(a7),d1                      /* set key repeat values */
        move.b    d1,ABSW(kb_initial)           /* set initial delay */
        tst.w     6(a7)                         /* see if we don't change the word */
        bmi.s     kbrate1                       /* don't set key repeat values */
        move.w    6(a7),d1                      /* set key repeat values */
        move.b    d1,ABSW(kb_repeat)            /* set subsequent delay */
kbrate1:
        rts


/*************************************************************************
 *                                                                       *
 * XBIOS #34 - Kbdvbase - Return a pointer to the IKBD (intelligent      *
 *      keyboard), and MIDI interrupt vectors.                           *
 *                                                                       *
 *               RETURN POINTER TO IKBD/MIDI INTERRUPT VECTORS           *
 *                                                                       *
 *       entry:                                                          *
 *                                                                       *
 *       long    ikbdvecs()                                              *
 *               returns a pointer to the midi interrupt vector and      *
 *               ikbd subsystem interrupt vector table.  the table       *
 *               structure is as follows:                                *
 *                                                                       *
 *       midivec         ds.l    1       midi interrupt handler vector   *
 *       vkbderr         ds.l    1       keyboard error handler address  *
 *       vmiderr         ds.l    1       midi error handler address      *
 *       statintvec      ds.l    1       ikbd status interrupt vector    *
 *       msintvec        ds.l    1       mouse interrupt vector          *
 *       clkintvec       ds.l    1       realtime clk interrupt vector   *
 *       joyintvec       ds.l    1       joystick interrupt vector       *
 *                                                                       *
 *       note:   msintvec is modified via the initmouse system function  *
 *               call.  since gem uses this vector, modifying it can be  *
 *               fatal while running under gem.  clkintvec is used by    *
 *               gemdos.  its pre-inited vector must be restored for     *
 *               proper gemdos operation.  Caveat hacker!                *
 *                                                                       *
 *                                                                       *
 *************************************************************************/
/* 306de: 00e03a96 */
/* 206de: 00e036b4 */
/* 104de: 00fc4294 */
	xdef _kbdvbase
_kbdvbase:
        move.l    #midivec,d0
        rts

/*************************************************************************
 *                                                                       *
 *       C Timer interrupt routine to process the PSG sound table        *
 *                                                                       *
 *************************************************************************/
/* (lmd)
 * timercint - timer c interrupt handler
 * divide 200 Hz interrupt frequency to 50 hz, and do:
 *       sound handler processing
 *       key-repeat processing
 *       control-g bell and keyclick if enabled via sound handler
 *       system timer-tick handoff
 *       updates:        tc_rot (every tick)
 *
 *       imports:        etv_timer (timer handoff vector)
 *                       _timr_ms (timer calibration value)
 *
 */
/* 306de: 00e03a9e */
/* 206de: 00e036bc */
/* 104de: 00fc429c */
timercint:
        addq.l    #1,_hz_200                    /* increment raw tick counter */
        rol.w     _tim_c_sieve                  /* rotate divisor bits */
        bpl.s     timerci3                      /* if not 4th interrupt, then return */
        movem.l   d0-d7/a0-a6,-(a7)
		SETBASEREG
		
        bsr.s     soundirq                      /* process sounds */

        btst      #1,ABSW(_conterm)             /* check for key repeat enabled */
        beq.s     timerci2                      /* not enabled */

/* process for repeat key function first because it can affect the sound */
/* table if enabled and the user is 'using'... */
        tst.b     ABSW(kb_key_last)
        beq.s     timerci2
        tst.b     ABSW(kb_ticks)
        beq.s     timerci1
        subq.b    #1,ABSW(kb_ticks)
        bne.s     timerci2
timerci1:
        subq.b    #1,ABSW(kb_delay)
        bne.s     timerci2
        move.b    ABSW(kb_repeat),ABSW(kb_delay)
        move.b    ABSW(kb_key_last),d0
        lea.l     ABSW(ikbdiorec),a0
        bsr       kbdvec15                      /* repeat key stroke and stuff into buffer */
/* (lmd)
 * Call system timer vector
 * (first guy in the system daisy-chain)
 */
timerci2:
        move.w    ABSW(_timer_ms),-(a7)         /* push #ms/tick */
        movea.l   ABSW(_etv_timer),a0           /* get vector */
        jsr       (a0)                          /* call it */
        addq.w    #2,a7                         /* cleanup stack */
        movem.l   (a7)+,d0-d7/a0-a6
timerci3:
#if (TOSVERSION >= 0x200) | !BINEXACT
        move.b    #$DF,ABSW(MFP_ISRB)           /* clear the interrupt channel */
#else
        bclr      #5,ABSW2(MFP_ISRB)            /* clear the interrupt channel */
#endif
        rte

/*********************************************************
 *
 *  Quick & dirty sound stuff
 *
 *
 *  Programmed by Dave Staugas
 *                14 Mar 1985
 *
 *
 *
 *
 *********************************************************
 *
 *
 *
 *
 *  To start a sound, load the 32-bit address of the
 *                       byte stream for that sound in 32-bit
 *                       "cursnd", & zero the 8-bit "timer"
 *
 *
 *
 *
 *   Sound interrupt routine
 *   Called from timer C irq
 */
soundirq:
        movem.l   d0-d1/a0,-(a7)
        move.l    ABSW(_sndtable),d0            /* get current sound ptr */
        beq.s     soundir7                      /* br to exit if zero, inactive */
        movea.l   d0,a0                         /* ptr to a0 */
        move.b    ABSW(_snddelay),d0            /* check delay timer */
        beq.s     soundir1                      /* br over delay timer update if not on */

        subq.b    #1,d0                         /* tick off delay timer */
        move.b    d0,ABSW(_snddelay)            /* save new */
        bra.s     soundir7                      /* skip sound update this time */
soundir1:
        move.b    (a0)+,d0                      /* pick up next sound command */
        bmi.s     soundir3                      /* if minus, go do special */

        move.b    d0,ABSW(psgsel)               /* else, register load command--select this */
        cmpi.b    #$07,d0                       /* reg. 7 selected? */
        bne.s     soundir2                      /* br if no */

        move.b    (a0)+,d1                      /* get data to write to reg 7 */
        andi.b    #$3F,d1                       /* always leave i/o port settings alone */
        move.b    ABSW(psgsel),d0               /* get mixer contents */
        andi.b    #$C0,d0                       /* mask off non-useful info... */
        or.b      d1,d0                         /* generate new setting */
        move.b    d0,ABSW(psgwr)                /* write data */
        bra.s     soundir1                      /* go for next command */

soundir2:
        move.b    (a0)+,ABSW(psgwr)             /* write next byte as data directly to reg */
        bra.s     soundir1                      /* go for next command */
/*  special case command */
soundir3:
        addq.b    #1,d0                         /* was command 255? */
        bpl.s     soundir5                      /* br if yes--set delay timer */

        cmpi.b    #$81,d0                       /* was command 128 (before increment) */
        bne.s     soundir4                      /* br if not */
/*  command 128 */
        move.b    (a0)+,ABSW(_sndtmp)           /* 128--set aux data from next byte in stream */
        bra.s     soundir1                      /* go for next command */
/*  command > 128 */
soundir4:
        cmpi.b    #$82,d0                       /* command greater than 129 */
        bne.s     soundir5                      /* br if yes--must be set timer */
/*  command 129 */
        move.b    (a0)+,ABSW(psgsel)            /* 129--select register */
        move.b    (a0)+,d0                      /* get increment step (signed) */
        add.b     d0,ABSW(_sndtmp)              /* add to aux data */
        move.b    (a0)+,d0                      /* terminating value */
        move.b    ABSW(_sndtmp),ABSW(psgwr)     /* load reg from data in auxd */
        cmp.b     ABSW(_sndtmp),d0              /* reached end of cycle? */
        beq.s     soundir6                      /* br if so */
/*  still within loop, reset sound pointer to iterate for next irq */
        subq.w    #4,a0                         /* back up sound ptr to repeat this command */
        bra.s     soundir6                      /* update ptr & exit */
/*  set delay timer */
soundir5:
        move.b    (a0)+,ABSW(_snddelay)         /* set delay timer from next byter in stream */
        bne.s     soundir6                      /* if non-zero real delay here */
        movea.w   #0,a0                         /* else, sound terminator--set ptr to null */
soundir6:
        move.l    a0,ABSW(_sndtable)            /* update sound ptr */
soundir7:
        movem.l   (a7)+,d0-d1/a0                /* pop stack & exit */
        rts
