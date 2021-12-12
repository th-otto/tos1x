#include "config.h"
#include "asmdefs.h"
#include "tosvars.inc"
#include "biosdefs.h"


/*
 * struct dsb {
 *    uint16_t curtrack;
 *    uint16_t seekrate;
 * };
 */
fd_curtrack equ 0
fd_seekrate equ 2
dsb_sizeof equ 4

/*
 * size of a raw sector for flopfmt:
 *    12 gap $00
 * +   3 id mark $f5
 * +   1 address mark $fe
 * +   1 track #
 * +   1 side #
 * +   1 sector #
 * +   1 sector size
 * +   1 checksum $f7
 * +  22 gap $4e
 * +  12 gap $00
 * +   3 id mark
 * +   1 address mark $fb
 * + 512 data
 * +   1 checksum $f7
 * +  40 gap $4e
 * = 612
 */
#define FD_RAWSEC 612
#define FD_RAWTRACK (60 + 18 * FD_RAWSEC + 1401)


        text

/*
 * flopini - initialize floppies
 * int flopini(void *buffer, DSB *dsb, int devno)
 *
 * Returns:       EQ if initialization succeeded (drive attached).
 *                NE if initialization failed (no drive attached).
 */
/* 306de: 00e03ba8 */
/* 206de: 00e037c6 */
/* 104de: 00fc0ef0 */
        xdef _flopini
_flopini:
        lea.l     dsb,a1                        /* get ptr to correct DSB */
        tst.w     12(a7)
        beq.s     flopini1
        lea.l     dsb+dsb_sizeof,a1
flopini1:
        move.w    _seekrate,fd_seekrate(a1)     /* setup default seek rate */
        moveq.l   #-1,d0                        /* (default error) */
        clr.w     fd_curtrack(a1)               /* fake clean drive */
        bsr       floplock                      /* setup parameters */
        bsr       select                        /* select drive and side */
        move.w    #$FF00,fd_curtrack(a1)        /* default = recal drive (it's dirty) */
        bsr       restore                       /* attempt restore */
        beq.s     flopini2                      /* (quick exit if that won) */
        moveq.l   #10,d7                        /* attempt seek to track 10 */
        bsr       hardsee1                      /* (hard seek to 'd7') */
        bne.s     flopini3                      /* (failed: drive unusable) */
        bsr       restore                       /* attempt restore after seek */
flopini2:
        beq       flopok                        /* return OK (on win) */
flopini3:
        bra       flopfail                      /* return failure */


/*
 * XBIOS #8 - Floprd - Read individual sectors from floppy disk.
 *
 * Passed (on the stack):
 *       $14(sp) count
 *       $12(sp) sideno
 *       $10(sp) trackno
 *        $e(sp) sectno
 *        $c(sp) devno
 *        $8(sp) ->DSB
 *        $4(sp) ->buffer
 *        $0(sp) return address
 *
 * Returns       EQ, the read won (on all sectors),
 *               NE, the read failed (on some sector).
 */
/* 306de: 00e03c10 */
/* 206de: 00e03820 */
/* 104de: 00fc0f38 */
        xdef _floprd
_floprd:
        bsr       fdchange                      /* test for disk change */
        moveq.l   #-11,d0                       /* set default error# E_READF */
        bsr       floplock                      /* lock floppies, setup parameters */
floprd1:
        bsr       select                        /* select drive, setup registers */
        bsr       go2track                      /* seek appropriate track */
        bne       floprd6                       /* retry on seek failure */
floprd2:
        move.w    #-1,fd_curerr                 /* set general error# E_ERR */
        move.w    #$0090,(a6)                   /* toggle DMA data direction, */
        move.w    #$0190,(a6)                   /* toggle DMA data direction, */
        move.w    #$0090,(a6)                   /* leave hardware in READ state */
        move.w    #1,ABSW2(DMA_DATA)            /* set sector count register */
        move.w    #$0080,(a6)                   /* startup 1770 "read sector" command */
        move.w    #$0080,d7                     /* (read single) */
        bsr       wrfdcd7
        move.l    #$00040000,d7
/* --- Wait for read completion: */
floprd3:
        btst      #5,ABSW(MFP_GPIP)             /* 1770 done yet? */
        beq.s     floprd4                       /* (yes) */
        subq.l    #1,d7
        bne.s     floprd3

/* ---- check status after read */
        move.w    #-2,ABSW(fd_curerr)           /* set "timeout" error */
        bsr       fdcreset                      /* (clobber 1770) */
        bra.s     floprd6                       /* (go retry) */

/* --- check status after read: */
floprd4:
        move.w    #$0090,(a6)                   /* examine DMA status register */
        move.w    (a6),d0
        btst      #0,d0                         /* bit zero inidcates DMA ERROR */
        beq.s     floprd6                       /* (when its zero -- retry) */

        move.w    #$0080,(a6)                   /* exeamine 1770 status register */
        bsr       rdfdcd0
        and.b     #$1C,d0                       /* check for RNF, checksum, lost-data */
        bne.s     floprd5                       /* (bail on error) */
        move.w    #2,ABSW(fd_retry)             /* reset retry count for next sector */
        addq.w    #1,ABSW(fd_sect)              /* advance sector # */
        addi.l    #SECTOR_SIZE,ABSW(fd_buffer)  /* advance buffer by 512 bytes */
        subq.w    #1,ABSW(fd_scount)            /* decrement sector count */
        beq       flopok                        /* (done) */
        bsr       select1
        bra       floprd2
floprd5:
        bsr.s     fdcerr                        /* set error# from 1770 bits */
floprd6:
        cmpi.w    #1,ABSW(fd_retry)             /* are we on the "middlemost" retry? */
        bne.s     floprd7
        bsr       reseek                        /* yes, home and reseek the head */
floprd7:
        subq.w    #1,ABSW(fd_retry)             /* drop retry count */
        bpl       floprd1                       /* (continue of any retries left) */
        bra       flopfail                      /* fail when we run out of patience */

/*
 * err_bits - set "curr_err" according to 1770 error status
 * Passed:       d0 = 1770 status
 *
 * Returns:      curr_err, containing current error number
 *
 * Uses:         d1
 */
fdcerr:
        moveq.l   #-13,d1                       /* write protect? E_WRPRO */
        btst      #6,d0
        bne.s     fdcerr1
        moveq.l   #-8,d1                        /* record-not-found? E_SEEK */
        btst      #4,d0
        bne.s     fdcerr1
        moveq.l   #-4,d1                        /* CRC error? E_CRC */
        btst      #3,d0
        bne.s     fdcerr1
        move.w    ABSW(fd_deferr),d1            /* use default error# */
fdcerr1:
        move.w    d1,ABSW(fd_curerr)            /* set current error number & return */
        rts


/*
 * XBIOS #9 - Flopwr - Write individual sectors on a floppy disk.
 * flopwr - write sector to floppy
 * Passed (on the stack):
 *       $14(sp) count
 *       $12(sp) sideno
 *       $10(sp) trackno
 *        $e(sp) sectno
 *        $c(sp) devno
 *        $8(sp) ->DSB
 *        $4(sp) ->buffer (unused)
 *        $0(sp) return address
 *
 * Returns:      EQ, the write won (on all sectors),
 *               NE, the write failed (on some sectors).
 */
/* 306de: 00e03d12 */
/* 206de: 00e0391c */
/* 104de: 00fc100a */
        xdef _flopwrt
_flopwrt:
        bsr       fdchange                      /* check for disk swap */
        moveq.l   #-10,d0                       /* set default error number E_WRITF */
        bsr       floplock                      /* lock floppies */
/*
 * If the boot sector is written to,
 * set the media change mode to "unsure".
 * (Kludge, kludge, kludge....)
 */
        move.w    ABSW(fd_sect),d0              /* sector 1 */
        subq.w    #1,d0
        or.w      ABSW(fd_track),d0             /* track 0 */
        or.w      ABSW(fd_side),d0              /* side 0 */
        bne.s     flopwrt1                      /* if not boot sector, then OK */
        moveq.l   #MEDIACHANGE,d0               /* set media change mode to unsure */
        bsr       setdchg                       /* (boy, is this /ugly/) */
flopwrt1:
        bsr       select                        /* select drive */
        bsr       go2track                      /* seek */
        bne       flopwrt6                      /* (retry on seek failure) */
flopwrt2:
        move.w    #-1,ABSW(fd_curerr)             /* set general error# */
        move.w    #$0190,(a6)                   /* toggle DMA chip to clear status */
        move.w    #$0090,(a6)                   /* toggle DMA chip to clear status */
        move.w    #$0190,(a6)                   /* leave in WRITE mode */
        move.w    #1,d7                         /* load sector-count register */
        bsr       wrfdcd7
        move.w    #$0180,(a6)                   /* load "WRITE SECTOR" command */
        move.w    #$00A0,d7                     /* into 1770 cmdreg */
        bsr       wrfdcd7
        move.l    #$00040000,d7
flopwrt3:
        btst      #5,ABSW(MFP_GPIP)             /* done yet? */
        beq.s     flopwrt4                      /* (yes, check status) */
        subq.l    #1,d7
        bne.s     flopwrt3
        bsr       fdcreset                      /* timed out -- reset 1770 */
        bra.s     flopwrt5                      /* and retry */
flopwrt4:
        move.w    #$0180,(a6)                   /* get 1770 status */
        bsr       rdfdcd0
        bsr       fdcerr                        /* compute 1770 error bits */
        btst      #6,d0                         /* if write protected, don't retry */
        bne       flopfail                      /* (can't write, so punt) */
        and.b     #$5C,d0                       /* check WriteProt+RecNtFnd+CHKSUM+LostD */
        bne.s     flopwrt5                      /* retry on error */

        move.w    #2,ABSW(fd_retry)             /* reset retry count */
        addq.w    #1,ABSW(fd_sect)              /* bump sector number */
        addi.l    #SECTOR_SIZE,ABSW(fd_buffer)  /* add DMA pointer for next sector */
        subq.w    #1,ABSW(fd_scount)            /* if(!--count) return OK; */
        beq       flopok
        bsr       select1                       /* setup sector#, DMA pointer */
        bra       flopwrt2                      /* write next (no seek) */
flopwrt5:
        cmpi.w    #1,ABSW(fd_retry)             /* re-seek head in "middle" retry */
        bne.s     flopwrt7                      /* (not middle retry) */
flopwrt6:
        bsr       reseek                        /* home head and seek */
flopwrt7:
        subq.w    #1,ABSW(fd_retry)             /* decrement retry count */
        bpl       flopwrt1                      /* loop if there's still hope */
        bra       flopfail                      /* otherwise return error status */

/*
 * XBIOS #10 - Flopfmt - Format specific tracks on a floppy
 * _flopfmt - format a track
 * Passed (on the stack):
 *       $1a(sp) initial sector data
 *       $16(sp) magic number
 *       $14(sp) interleave
 *       $12(sp) side
 *       $10(sp) track
 *        $e(sp) spt
 *        $c(sp) devno
 *        $8(sp) pointer to state block
 *        $4(sp) dma address
 *        $0(sp) [return]
 *
 * Returns:      EQ: track successfully written.  Zero.W-terminated list of
 *               bad sectors left in buffer (they might /all/ be bad.)
 *
 *               NE: could not write track (write-protected, drive failure,
 *               or something catastrophic happened).
 */
/* 306de: 00e03e02 */
/* 206de: 00e03a04 */
/* 104de: 00fc10c6 */
        xdef _flopfmt
_flopfmt:
        cmpi.l    #$87654321,22(a7)             /* check for magic# on stack */
        bne       flopfail                      /* no magic, so we just saved the world */
        bsr       fdchange                      /* check for disk flip */
        moveq.l   #-1,d0                        /* set default error number */
        bsr       floplock
        bsr       select                        /* select drive and side */
        move.w    14(a7),ABSW(fd_spt)           /* save sectors-per-track */
        move.w    20(a7),ABSW(fd_interlv)       /* save interleave factor */
        move.w    26(a7),ABSW(fd_virgin)        /* save initial sector data */
        move.l    8(a7),ABSW(fd_secmap)
/* --- put drive into "changed" mode */
        moveq.l   #MEDIACHANGE,d0               /* d0 = "CHANGED" */
        bsr       setdchg                       /* set media change mode */
/* --- seek to track (hard seek): */
        bsr       hardseek                      /* hard seek to 'ctrack' */
        bne       flopfail                      /* (return error on seek failure) */
        move.w    ABSW(fd_track),fd_curtrack(a1)  /* record current track# */
/* --- format track, then verify it: */
        move.w    #-1,ABSW(fd_curerr)           /* vanilla error mode */
        bsr.s     fmtrack                       /* format track */
        bne       flopfail                      /* (return error on seek failure) */
        move.w    ABSW(fd_spt),ABSW(fd_scount)  /* set number of sectors to verify */
        move.w    #1,ABSW(fd_sect)              /* starting sector# = 1 */
        bsr       verify1                       /* verify sectors */
/* --- if there are any bad sectors, return /that/ error... */
        movea.l   ABSW(fd_buffer),a2            /* a2 -> bad sector list */
        tst.w     (a2)                          /* any bad sectors? */
        beq       flopok                        /* no -- return OK */
        move.w    #-16,ABSW(fd_curerr)          /* set error number E_BADSF */
        bra       flopfail                      /* return error */

/*
 * fmtrack - format a track
 * Passed:       variables setup by _flopfmt
 * Returns:      NE on failure, EQ on success
 * Uses:         almost everything
 * Called-by:    _flopfmt
 *
 */
fmtrack:
        move.w    #-10,ABSW(fd_deferr)          /* set default error number E_WRITF */
        movea.l   ABSW(fd_buffer),a2            /* a2 -> prototyping area */
        movea.l   ABSW(fd_secmap),a3
        move.w    #60-1,d1                      /* 60 x $4e (track leadin) */
        move.b    #$4e,d0
        bsr       wmult
        clr.w     d3                            /* interleave index = table start */
        tst.w     ABSW(fd_interlv)              /* interleave < 0 */
        bmi       fmtrack9                      /* use custom interleave table -> */
        move.w    #1,d3                         /* first sector = 1 */

/* ---- address mark */
fmtrack2:
        move.w    d3,d4                         /* d4 = starting sector (this pass) */
fmtrack3:
        move.w    #12-1,d1                      /* 12 x $00 */
        clr.b     d0
        bsr       wmult
        move.w    #3-1,d1                       /* 3 x $f5 */
        move.b    #$f5,d0
        bsr       wmult
        move.b    #$FE,(a2)+                    /* $fe -- address mark intro */
        move.b    ABSW(fd_track+1),(a2)+        /* track# */
        move.b    ABSW(fd_side+1),(a2)+         /* side# */
        move.b    d4,(a2)+                      /* sector# */
        move.b    #$02,(a2)+                    /* sector size (512) */
        move.b    #$F7,(a2)+                    /* write checksum */
/* --- gap between AM and data: */
        move.w    #22-1,d1                      /* 22 x $4e */
        move.b    #$4e,d0
        bsr       wmult
        move.w    #12-1,d1                      /* 12 x $00 */
        clr.b     d0
        bsr       wmult
        move.w    #3-1,d1                       /* 3 x $f5 */
        move.b    #$f5,d0
        bsr       wmult
/* --- data block: */
        move.b    #$FB,(a2)+                    /* $fb -- data intro */
        move.w    #256-1,d1                     /* 256 x virgin.W (initial sector data) */
fmtrack4:
        move.b    ABSW(fd_virgin),(a2)+         /* copy high byte */
        move.b    ABSW(fd_virgin+1),(a2)+       /* copy low byte */
        dbf       d1,fmtrack4                   /* fill 512 bytes */
        move.b    #$F7,(a2)+                    /* $f7 -- write checksum */
        move.w    #40-1,d1                      /* 40 x $4e */
        move.b    #$4e,d0
        bsr       wmult
        tst.w     ABSW(fd_interlv)              /* interleave < 0 */
        bmi.s     fmtrack9                      /* use custom interleave table -> */
        add.w     ABSW(fd_interlv),d4           /* bump sector# */
        cmp.w     ABSW(fd_spt),d4               /* if(d4 <= spt) then_continue; */
        ble       fmtrack3                      /* proto more sectors this pass */
        addq.w    #1,d3                         /* bump pass start count */
        cmp.w     ABSW(fd_interlv),d3           /* if(d3 <= interlv) then_continue; */
        ble       fmtrack2
/* --- end-of-track */
fmtrack5:
        move.w    #1400,d1                      /* 1401 x $4e -- end of track trailer */
fmtrack6:
        move.b    #$4e,d0
        bsr       wmult
/* --- setup to write the track: */
        move.b    ABSW(fd_buffer+3),ABSW($FFFF860D) /* load dma pointer */
        move.b    ABSW(fd_buffer+2),ABSW($FFFF860B)
        move.b    ABSW(fd_buffer+1),ABSW($FFFF8609)
        move.w    #$0190,(a6)                   /* toggle R/W flag */
        move.w    #$0090,(a6)                   /* toggle R/W flag */
        move.w    #$0190,(a6)                   /* select sector-count register */
        move.w    #31,d7                        /* (absurd sector count) */
        bsr       wrfdcd7
        move.w    #$0180,(a6)                   /* select 1770 cmd register */
        move.w    #$00F0,d7                     /* write format_track command */
        bsr       wrfdcd7
        move.l    #$00040000,d7
/* --- wait for 1770 complete: */
fmtrack7:
        btst      #5,ABSW(MFP_GPIP)             /* is 1770 done? */
        beq.s     fmtrac10                      /* (yes) */
        subq.l    #1,d7
        bne.s     fmtrack7
        bsr       fdcreset                      /* timed out -- reset 1770 */
fmtrack8:
        moveq.l   #1,d7                         /* return NE (error status) */
        rts
fmtrack9:
        cmp.w     ABSW(fd_spt),d3               /* last sector reached? */
        beq       fmtrack5                      /* yes -> end of track */
        move.w    d3,d6
        add.w     d6,d6
        move.w    0(a3,d6.w),d4                 /* pick new sector number from the table */
        addq.w    #1,d3                         /* increment interleave index */
        bra       fmtrack3
/* --- see if the write-track won: */
fmtrac10:
        move.w    #$0190,(a6)                   /* check DMA status bit */
        move.w    (a6),d0
        btst      #0,d0                         /* if its zero, there was a DMA error */
        beq.s     fmtrack8                      /* (so return NE) */
        move.w    #$0180,(a6)                   /* get 1770 status */
        bsr       rdfdcd0
        bsr       fdcerr                        /* set 1770 error bits */
        and.b     #$44,d0                       /* check for writeProtect & lostData */
        rts                                     /* return NE on 1770 error */

/* ----- write 'D1+1' copies of D0.B into A2, A2+1, ... */
wmult:
        move.b    d0,(a2)+                      /* record byte in proto buffer */
        dbf       d1,wmult                      /* (do it again) */
        rts


/*
 * XBIOS #19 - Flopver - Verify sectors of a floppy disk.
 * _flopver - verify sectors on a track
 *       $14(sp) count
 *       $12(sp) sideno
 *       $10(sp) trackno
 *        $e(sp) sectno
 *        $c(sp) devno
 *        $8(sp) ->DSB
 *        $4(sp) ->buffer (at least 1K long)
 *        $0(sp) return address
 *
 * Returns:      NULL.W-terminated list of bad sectors in the buffer if D0 == 0,
 *               OR some kind of error (D0 < 0).
 *
 */
/* 306de: 00e03ffe */
/* 206de: 00e03bfe */
/* 104de: 00fc1286 */
        xdef _flopver
_flopver:
        bsr       fdchange
        moveq.l   #-11,d0       /* set default error: E_READF */
        bsr       floplock      /* lock floppies, setup parameters */
        bsr       select        /* select floppy */
        bsr       go2track      /* go to track */
        bne       flopfail      /* fail if error */
        bsr.s     verify1       /* do actual verify */
        bra       flopok        /* done */

/*
 * verify1 - verify sectors on a single track
 * Passed:       csect = starting sector#
 *               ccount = number of sectors to verify
 *               cdma -> 1K buffer (at least)
 *
 * Returns:      NULL.W-terminated list of bad sectors (in the buffer)
 *               (buffer+$200..buffer+$3ff used as DMA buffer)
 *
 * Enviroment:   Head seeked to correct track
 *               Drive and side already selected
 *               Motor should be spinning (go2track and fmttrack do this).
 *
 * Uses:         Almost everything.
 *
 * Called-by:    _flopfmt, _flopver
 *
 */
verify1:
        move.w    #-11,ABSW(fd_deferr)       /* set default error: E_READF */
        movea.l   ABSW(fd_buffer),a2         /* a2 -> start of bad sector list */
        addi.l    #SECTOR_SIZE,ABSW(fd_buffer) /* skip bad sector list */
verify2:
        move.w    #2,ABSW(fd_retry)          /* init sector-retry count */
        move.w    #$0084,(a6)
        move.w    ABSW(fd_sect),d7           /* set FDC sector register */
        bsr       wrfdcd7
verify3:
        move.b    ABSW(fd_buffer+3),ABSW($FFFF860D) /* set DMA address */
        move.b    ABSW(fd_buffer+2),ABSW($FFFF860B)
        move.b    ABSW(fd_buffer+1),ABSW($FFFF8609)
        move.w    #$0090,(a6)                   /* toggle R/W (leave in W state) */
        move.w    #$0190,(a6)                   /* toggle R/W (leave in W state) */
        move.w    #$0090,(a6)                   /* setup for DMA read */
        move.w    #$0001,d7                     /* set DMA sector count to 1 */
        bsr       wrfdcd7
        move.w    #$0080,(a6)                   /* write READ SECTOR command */
        move.w    #$0080,d7
        bsr       wrfdcd7
        move.l    #$00040000,d7
*--- wait for command completion
verify4:
        btst      #5,ABSW(MFP_GPIP)             /* test for 1770 done */
        beq.s     verify5                       /* (yes, it completed) */
        subq.l    #1,d7
        bne.s     verify4
        bsr       fdcreset                      /* reset controller and return error */
        bra.s     verify7
/* --- got "done" interrupt, check DMA status: */
verify5:
        move.w    #$0090,(a6)                   /* read DMA error status */
        move.w    (a6),d0
        btst      #0,d0                         /* if DMA_ERROR is zero, then retry */
        beq.s     verify7
/* --- check 1770 completion status (see if it's happy): */
        move.w    #$0080,(a6)                   /* read 1770 status register */
        bsr       rdfdcd0
        bsr       fdcerr                        /* set error# */
        and.b     #$1C,d0                       /* check for record-not-found, crc-error, and lost data */
        bne.s     verify7
/* --- read next sector (or return if done) */
verify6:
        addq.w    #1,ABSW(fd_sect)              /* bump sector count */
        subq.w    #1,ABSW(fd_scount)            /* while(--count) read_another; */
        bne       verify2
        subi.l    #SECTOR_SIZE,ABSW(fd_buffer)  /* readjust DMA pointer */
        clr.w     (a2)                          /* terminate bad sector list */
        rts                                     /* and return EQ */
*--- read failure: retry or record bad sector
verify7:
        cmpi.w    #1,ABSW(fd_retry)             /* re-seek head? */
        bne.s     verify8                       /* (no) */
        bsr       reseek                        /* yes: back to home and then back */
verify8:
        subq.w    #1,ABSW(fd_retry)             /* to the current track... */
        bpl       verify3
        move.w    ABSW(fd_sect),(a2)+           /* record bad sector */
        bra.s     verify6                       /* do next sector */

/*
 * _flopvbl - floppy vblank handler
 * Deselects floppies after the motor stops
 */
/* 306de: 00e04106 */
/* 206de: 00e03cfe */
/* 104de: 00fc1360 */
        xdef _flopvbl
_flopvbl:
        SETBASEREG
        lea.l     ABSW(DMA_CTRL),a6             /* a6 -> DMA_CTRL */
        st        ABSW(fd_motoron)              /* assume motor is on */
        tst.w     ABSW(_flock)                  /* floppies locked? */
        bne.s     flopvbl5                      /* (yes, so don't touch them) */
/* --- write-protect monitor: */
        move.l    ABSW(_frclock),d0             /* check a drive every 8 jiffies */
        move.b    d0,d1                         /* (save jiffy count) */
        and.b     #$07,d1                       /* time yet? */
        bne.s     flopvbl2                      /* (no) */
        move.w    #$0080,(a6)                   /* select 1770 command/status register */
/* --- select drive, record it's WP status: */
        lsr.b     #3,d0                         /* use bit 4 as drive# to check */
        and.w     #$0001,d0
        lea.l     ABSW(_fd_wp),a0
        adda.w    d0,a0
        cmp.w     ABSW(_nflops),d0
        bne.s     flopvbl1
        clr.w     d0
flopvbl1:
        addq.b    #1,d0
        lsl.b     #1,d0                         /* (magic shift left) */
        eori.b    #$07,d0                       /* invert select bits, select side 0 */
        bsr       setporta                      /* set port A (d2 = old bits) */
        move.w    ABSW(DMA_DATA),d0             /* read diskctl into d0 */
        btst      #6,d0                         /* test Write-Protect status bit */
        sne       (a0)                          /* set WP status to $00 or $FF. */
        move.b    d2,d0                         /* restore old drive-select bits */
        bsr       setporta
flopvbl2:
        move.w    ABSW(_fd_wp),d0               /* or _wpstatus into _wplatch */
        or.w      d0,ABSW(_fd_latch)            /* (catch any WP transitions) */
/* --- floppy deselect test */
        tst.w     ABSW(fd_desel)                /* floppies already deselected? */
        bne.s     flopvbl4                      /* (yes, so don't do it again) */
        bsr       rdfdcd0                       /* read 1770 status register */
        btst      #7,d0                         /* is the motor still on? */
        bne.s     flopvbl5                      /* (yes, so don't deselect) */
flopvbl3:
        move.b    #$07,d0                       /* deselect both drives */
        bsr       setporta                      /* (set bits 0..2 in portA of PSG) */
        move.w    #1,ABSW(fd_desel)             /* indicate floppies deselected */
flopvbl4:
        clr.w     ABSW(fd_motoron)              /* indicate motor is OFF */
flopvbl5:
        rts


/*
 * floplock - lock floppies and setup floppy parameters
 *
 * Passed (on the stack):
 *       $18(sp) - count.W (sector count)
 *       $16(sp) - side.W (side#)
 *       $14(sp) - track.W (track#)
 *       $12(sp) - sect.W (sector#)
 *       $10(sp) - dev.W (device#)
 *        $c(sp) - obsolete.L
 *         8(sp) - dma.L (dma pointer)
 *         4(sp) - ret1.L (caller's return address)
 *         0(sp) - ret.L (floplock's return address)
 *
 * Passed:       D0.W = default error number
 */
/* 306de: 00e04196 */
/* 206de: 00e03d86 */
/* 104de: 00fc13dc */
floplock:
        movem.l   d3-d7/a3-a6,flopsregs         /* save C registers */
        SETBASEREG
        lea.l     ABSW(DMA_CTRL),a6             /* a6 -> DMA_CTRL */
        st        ABSW(fd_motoron)              /* kludge motor state = ON */
        move.w    d0,ABSW(fd_deferr)            /* set default error number */
        move.w    d0,ABSW(fd_curerr)            /* set current error number */
        move.w    #$0001,ABSW(_flock)           /* tell vbl not to touch floppies */
        move.l    8(a7),ABSW(fd_buffer)         /* cdma -> /even/ DMA address */
        move.w    16(a7),ABSW(fd_dev)           /* save devide# (0 . 1) */
        move.w    18(a7),ABSW(fd_sect)          /* save sector# (1 . 9, usually) */
        move.w    20(a7),ABSW(fd_track)         /* save track# (0 . 39 .  79   ) */
        move.w    22(a7),ABSW(fd_side)          /* save side# (0 . 1) */
        move.w    24(a7),ABSW(fd_scount)        /* save sector count (1..spt) */
        move.w    #2,ABSW(fd_retry)             /* setup retry count */
/* --- pick a DSB */
        lea.l     ABSW(dsb),a1
        tst.w     ABSW(fd_dev)
        beq.s     floploc1
        lea.l     ABSW(dsb+dsb_sizeof),a1
/* --- recalibrate drive (if it needs it) */
floploc1:
        tst.w     fd_curtrack(a1)               /* if (curtrack < 0) recalibrate() */
        bpl.s     floploc3
        bsr       select                        /* select drive & side */
        clr.w     fd_curtrack(a1)
        bsr       restore                       /* attempt restore */
        beq.s     floploc3                      /* (it won) */
        moveq.l   #10,d7                        /* attempt seek to track 10 */
        bsr.s     hardsee1
        bne.s     floploc2                      /* (failed) */
        bsr       restore                       /* attempt restore again */
        beq.s     floploc3                      /* (it won) */
floploc2:
        move.w    #$FF00,fd_curtrack(a1)        /* complete failure (what can we do?) */
floploc3:
        rts

/*
 * flopfail - unlock floppies and return error.
 */
/* 306de: 00e04216 */
/* 206de: 00e03e06 */
/* 104de: 00fc145c */
flopfail:
        moveq.l   #MEDIAMAYCHANGE,d0            /* disk change mode = unsure */
        bsr       setdchg                       /* set media change mode */
        move.w    ABSW(fd_curerr),d0            /* get current error number */
        ext.l     d0                            /* extent to long */
        bra.s     flopok1                       /* clobber floppy lock & return */

/*
 * flopok - unlock floppies and return success status:
 */
flopok:
        clr.l     d0                            /* return 0 (success) */
flopok1:
        move.l    d0,-(a7)                      /* (save return value) */
#if P68030
        bsr       flushCaches
#endif
        move.w    #$0086,(a6)                   /* force WP to real-time mode */
        move.w    fd_curtrack(a1),d7            /* dest-track = current track */
        bsr       wrfdcd7
        move.w    #$0010,d6                     /* cmd = seek w/o verify */
        bsr       flopcmds                      /* do it */

        move.w    ABSW(fd_dev),d0               /* set last-access time for 'cdev' */
        lsl.w     #2,d0
        lea.l     ABSW(_fd_lastacc),a0
        move.l    ABSW(_frclock),0(a0,d0.w)
        cmpi.w    #1,ABSW(_nflops)              /* if (nflops == 1) set other time, too */
        bne.s     flopok2
        move.l    ABSW(_frclock),4(a0)          /* set last-access time for floppy 1 */
flopok2:
        move.l    (a7)+,d0                      /* restore return value */
        movem.l   ABSW(flopsregs),d3-d7/a3-a6   /* restore C registers */
        clr.w     _flock                        /* unlock floppies */
        rts

/*
 * hseek  - seek to 'ctrack' without verify
 * hseek1 - seek to 'd7' without verify
 * hseek2 - seek to 'd7' without verify, keep current error number
 *
 * Returns:      NE on seek failure ("cannot happen"?)
 *               EQ if seek wins
 *
 * Uses:         d7, d6, ...
 * Jumps-to:     flopcmds
 * Called-by:    _flopfmt, _flopinit
 *
 */
hardseek:
        move.w    fd_track,d7                   /* dest track = 'ctrack' */
hardsee1:
        move.w    #-6,fd_curerr                 /* possible error = "seek error" E_SEEK */
        move.w    #$0086,(a6)                   /* write destination track# to data reg */
        bsr       wrfdcd7
        move.w    #$0010,d6                     /* execute "seek" command */
        bra       flopcmds                      /* (without verify...) */

/*
 * reseek - home head, then reseek track
 * Returns:      EQ/NE on success/failure
 * Falls-into:   go2track
 *
 */
reseek:
        move.w    #-6,fd_curerr                 /* set "seek error" E_SEEK */
        bsr.s     restore                       /* restore head */
        bne.s     go2trret                      /* (punt if home fails) */
        clr.w     fd_curtrack(a1)               /* current track = 0 */
        move.w    #$0082,(a6)                   /* set "current track" reg on 1770 */
        clr.w     d7
        bsr       wrfdcd7

        move.w    #$0086,(a6)                   /* seek out to track five */
        move.w    #5,d7
        bsr       wrfdcd7                       /* dest track = 5 */
        move.w    #$0010,d6
        bsr.s     flopcmds                      /* seek */
        bne.s     go2trret                      /* return error on seek failure */
        move.w    #5,fd_curtrack(a1)            /* set current track# */

/*
 * go2track - seek proper track
 * Passed:       Current floppy parameters (ctrack, et al.)
 * Returns:      EQ/NE on success/failure
 * Calls:        flopcmds
 */
go2track:
go2trac1:
        move.w    #-6,fd_curerr                 /* set "seek error" E_SEEK */
        move.w    #$0086,(a6)                   /* set destination track# in */
        move.w    ABSW(fd_track),d7             /* 1770's data register */
        bsr       wrfdcd7                       /* (write track#) */
#if OS_COUNTRY == CTRY_CZ
		/* czech version has the FASTLOAD patch applied */
        moveq.l   #$10,d6                       /* execute 1770 "seek" */
#else
        moveq.l   #$14,d6                       /* execute 1770 "seek" */
#endif
        bsr.s     flopcmds                      /* (include seek-rate bits) */
        bne.s     go2trret                      /* return error on seek failure */
        move.w    ABSW(fd_track),fd_curtrack(a1)  /* update current track number */
        and.b     #$18,d7
go2trret:
        rts

/*
 * restore - home head
 * Passed:       nothing
 * Returns:      EQ/NE on success/failure
 * Falls-into:   flopcmds
 */
/* 104de: fc1528 */
restore:
        clr.w     d6                            /* $00 = 1770 "restore" command */
        bsr.s     flopcmds                      /* do restore */
        bne.s     restore1                      /* punt on timeout */
        btst      #2,d7                         /* test TRK00 bit */
        eori.b    #$04,ccr                      /* flip Z bit (return NE if bit is zero) */
        bne.s     restore1                      /* (punt if didn't win) */
        clr.w     fd_curtrack(a1)               /* set current track# */
restore1:
        rts


/*
 * flopcmds - floppy command (on-in seek speed bits from database)
 * Passed:       d6.w = 1770 command
 * Sets-up:      seek bits (bits 0 and 1) in d6.w
 * Falls-into:   flopcmds
 * Returns:      EQ/NE on success/failure
 */
/* 104de: fc153e */
flopcmds:
        move.w    fd_seekrate(a1),d0            /* get floppy's seek rate bits */
        and.b     #3,d0                         /* OR into command */
flopcms1:
        or.b      d0,d6

/*
 * flopcmd - execute 1770 command (with timeout)
 * Passed:       d6.w = 1770 command
 *
 * Returns:      CS on timeout
 *               EQ/NE on success/failure
 *               d7 = 1770 status bits
 *
 */
flopcmd:
        move.l    #$00040000,d7
        move.w    #$0080,(a6)                   /* select 1770 command register */
        bsr       rdfdcd0                       /* read it to clobber READY status */
        btst      #7,d0                         /* is motor on? */
        bne.s     flopcmd1                      /* (yes, keep short timeout) */
        move.l    #$00060000,d7
flopcmd1:
        bsr       wrfdcd6                       /* write command (in d6) */
flopcmd2:
        subq.l    #1,d7
        beq.s     flopcmd3
        btst      #5,ABSW2(MFP_GPIP)            /* 1770 completion? */
        bne.s     flopcmd2                      /* (not yet, so wait some more) */
        bsr       rdfdcd7                       /* return EQ + 1770 status in d7 */
        clr.w     d6
        rts
flopcmd3:
        bsr.s     fdcreset                      /* bash controller */
        moveq.l   #1,d6
        rts

/*
 * reset1770 - reset disk controller after a catastrophe
 * Passed:       nothing
 * Returns:      nothing
 * Uses:         d7
 */
fdcreset:
            move.w    #$0080,(a6)               /* execute 1770 "reset" command */
            move.w    #$00D0,d7
            bsr       wrfdcd7
            move.w    #16-1,d7
r1770a:
            dbf       d7,r1770a
            bsr.w     rdfdcd7                   /* return 1770 status in d7 */
            rts

/*
 * select - setup drive select, 1770 and DMA registers
 * Passed:       cside, cdev
 * Returns:      appropriate drive and side select
 */
/* 306de: 00e043c4 */
/* 206de: 00e03fcc */
select:
            clr.w     ABSW(fd_desel)            /* floppies NOT deselected */
            move.w    ABSW(fd_dev),d0           /* get device number */
            addq.b    #1,d0                     /* add and shift to get select bits */
            lsl.b     #1,d0                     /* into bits 1 and 2 */
            or.w      ABSW(fd_side),d0          /* or-in side number (bit 0) */
            eori.b    #$07,d0                   /* negate bits for funky hardware select */
            and.b     #$07,d0                   /* strip anything else out there */
            bsr.s     setporta                  /* do drive select */
            move.w    #$0082,(a6)               /* setup 1770 track register */
            move.w    fd_curtrack(a1),d7        /* for current track number */
            bsr.s     wrfdcd7
            clr.b     ABSW(lastacstm)
select1:
            move.w    #$0084,(a6)               /* setup requested sector_number from */
            move.w    ABSW(fd_sect),d7          /* caller's parameters */
            bsr.s     wrfdcd7
            move.b    ABSW(fd_buffer+3),ABSW($FFFF860D) /* setup DMA chip's DMA pointer */
            move.b    ABSW(fd_buffer+2),ABSW($FFFF860B)
            move.b    ABSW(fd_buffer+1),ABSW($FFFF8609)
            rts

/*
 * setporta - set floppy select bits in PORT A on the sound chip
 * Passed:       d0.b (low three bits)
 * Returns:      d1 = value written to port A
 *               d2 = old value read from port A
 * Uses:         d1
 */
/* 306de: 00e04406 */
/* 206de: 00e0400e */
setporta:
            move.w    sr,-(a7)                  /* save our IPL */
            ori.w     #$0700,sr                 /* start critical section */
            move.b    #14,ABSW2(psgsel)         /* select port on GI chip */
            move.b    ABSW2(psgrd),d1           /* get current bits */
            move.b    d1,d2                     /* save old bits for caller */
            and.b     #$F8,d1                   /* strip low three bits there */
            or.b      d0,d1                     /* or-in our new bits */
            move.b    d1,ABSW2(psgwr)           /* and write 'em back out there */
            move.w    (a7)+,sr                  /* restore IPL to terminate CS, return */
            rts

/*
 * Primitives to read/write 1770 controller chip (DISKCTL register).
 *
 * The 1770 can't keep up with full-tilt CPU access, so
 * we have to surround read and writes with delay loops.
 * This is not really as slow as it sounds.
 *
 */
/* write d6 to selected FDC register */
/* 306de: 00e04426 */
/* 206de: 00e0402e */
wrfdcd6:
            bsr.s     rwdelay                   /* delay */
            move.w    d6,ABSW2(DMA_DATA)        /* write d6 to diskctl */
            bra.s     rwdelay

/* write d7 to selected FDC register */
/* 306de: 00e0442e */
/* 206de: 00e04036 */
wrfdcd7:
            bsr.s     rwdelay                   /* delay */
            move.w    d7,ABSW2(DMA_DATA)        /* write d7 to diskctl */
            bra.s     rwdelay

/* read selected FDC register into d7 */
/* 306de: 00e04436 */
/* 206de: 00e0403e */
rdfdcd7:
            bsr.s     rwdelay                   /* delay */
            move.w    ABSW2(DMA_DATA),d7        /* read diskctl into d7 */
            bra.s     rwdelay

/* read selected FDC register into d0 */
/* 306de: 00e0443e */
/* 206de: 00e04046 */
rdfdcd0:
            bsr.s     rwdelay                   /* delay */
            move.w    ABSW2(DMA_DATA),d0        /* read diskctl into d0 */
        /* fall through into rwdelay again */

rwdelay:
            move.w    sr,-(a7)
            move.w    d7,-(a7)
            move.w    #32,d7
rwdly1:     dbf       d7,rwdly1
            move.w    (a7)+,d7
            move.w    (a7)+,sr
            rts

/*
 * fdchange - check to see if the "right" floppy bas been inserted
 * On the stack:
 *       $10(sp) - dev.W (device#)
 *        $c(sp) - dsb.L (pointer to Device State Block)
 *         8(sp) - dma.L (dma pointer)
 *         4(sp) - ret1.L (caller's return address)
 *         0(sp) - ret.L (change's return address)
 *
 * Returns:      both media "might have changed" condition
 *
 * Uses:         C registers
 *
 */
/* 306de: 00e04454 */
/* 206de: 00e0406a */
/* 104de: 00fc1640 */
fdchange:
            cmpi.w    #1,_nflops                /* if there are zero or two floppies */
            bne.s     fdchang2                  /* then do nothing (return OK) */
            move.w    16(a7),d0                 /* if cdev == _curflop */
            cmp.w     _curflop,d0               /* (...current disk == current drive?) */
            beq.s     fdchang1                  /* then return OK (but use drive #0) */
/* --- ask the user to stick in the other floppy (via critical error handler) */
            move.w    d0,-(a7)
            move.w    #-17,-(a7)                /* push "INSERT_A_DISK" error number */
            bsr       _callcrit                 /* use critical error handler and */
            addq.w    #4,a7                     /* hope somebody handles it */
            move.w    #$FFFF,_fd_latch          /* set "might have changed" on both drives */
            lea.l     _fd_lastacc,a0
            clr.l     (a0)+
            clr.l     (a0)
            move.w    16(a7),_curflop           /* set current disk# */
fdchang1:
            clr.w     16(a7)                    /* use drive 0 */
fdchang2:
            rts

/*
 * setdmode - set drive-change mode
 * Passed:         d0.b = mode to put current drive in (0, 1, 2)
 * Uses:           a0
 */
setdchg:
            lea.l     ABSW(_drivechange),a0     /* a0 -> disk mode table */
            move.b    d0,-(a7)                  /* (save mode) */
            move.w    ABSW(fd_dev),d0           /* d0.w = drive# (index into table) */
            move.b    (a7)+,0(a0,d0.w)          /* set drive's mode */
            rts


/*
 * XBIOS #41 - Floprate - Read or set the seek rate of a floppy drive.
 * floprate - sets the seek rate of the specified floppy drive
 * On the stack:
 *         6(sp) - rate.w (0: 6ms, 1: 12ms, 2:2ms, 3:3ms)
 *         4(sp) - dev.W (device#)
 *         0(sp) - return address
 *
 * Returns:      prior seek rate for the specified drive
 *
 */
/* 306de: 00e044b6 */
/* 206de: 00e040cc */
/* 104de: 00fc1692 */
        xdef _floprate
_floprate:
/* --- pick a DSB */
            lea.l     dsb,a0
            tst.w     4(a7)
            beq.s     floprat1
            lea.l     dsb+dsb_sizeof,a0
floprat1:
            move.w    fd_seekrate(a0),d0        /* current rate */
            move.w    6(a7),d1                  /* new seek rate */
            cmp.w     #-1,d1                    /* new seek rate == -1 */
            beq.s     floprat2                  /* (just return the current rate) */
            move.w    d1,fd_seekrate(a0)        /* set new seek rate in dsb */
floprat2:
            ext.l     d0
            rts

    bss

    xdef fd_spt
    comm fd_spt,2

    xdef fd_desel
    comm fd_desel,2
    
    xdef fd_sect
    comm fd_sect,2
    
    xdef fd_curerr
    comm fd_curerr,2
    
    xdef fd_virgin
    comm fd_virgin,2
    
    xdef fd_motoron
    comm fd_motoron,2
    
    xdef fd_scount
    comm fd_scount,2

    xdef fd_retry
    comm fd_retry,2
    
    xdef fd_interlv
    comm fd_interlv,2
    
    xdef flopsregs
    comm flopsregs,2
    
    xdef fd_side
    comm fd_side,2
    
    xdef fd_dev
    comm fd_dev,2
    
    xdef fd_secmap
    comm fd_secmap,4
    
    xdef fd_track
    comm fd_track,2
    
    xdef fd_buffer
    comm fd_buffer,4
    
    xdef fd_deferr
    comm fd_deferr,2
