/*
 *     dmaboot.s
 *
 *        Neuer DMA-Bootloader im ROM fuer OMTI-Kontroller
 *        Die Routine dmaboot ($fc04a8 dt. ROMTOS) wird gegen
 *        folgende ausgetauscht.
 *        Es wird ein besonders langes Timeout von 30 Sekunden
 *        benutzt, damit langsam anlaufende Platten auch bedient
 *        werden. Der Bootsektor muss in den zweiten Teil des
 *        1KByte grossen Diskbuffer geladen werden, da der erste
 *        Teil durch 'hdbios' zerstoert wird. 
 *
 *     26.01.88  Achim Freimann
 */

_read     equ     8               /* read sector(s) */
steprate  equ     1               /* 10 mikrosec. */

diskctl   equ     $ffff8604       /* controller access */
fifo      equ     $ffff8606       /* DMA control register */


		text

dmaboot:
		suba.l     a6,a6          /* for short adressing */
		lea.l      diskctl.l,a5
		lea.l      2(a5),a4       /* A4 = fifo */
		moveq.l    #1,d4
		moveq.l    #0,d5
		move.w     #$00C8,d6
		move.w     #$00CA,d7
		st         _flock(a6)     /* lock floppy VBL */

/*
 *      reset controller
 */
		move.w     #100,d0        /* ~ 125 usek. delay */
		move.w     d7,(a4)
		move.w     #$0080,(a5)    /* set reset line */
res_loop:
		dbf        d0,res_loop
		move.w     d5,(a5)        /* ... and reset */
		move.w     d6,(a4)
res_lp:
		dbf        d0,res_lp

		movea.l    _dskbufp(a6),a2
		adda.l     #$00000200,a2
		bsr.s      ctdmaread      /* read boot sector */
		sf         _flock(a6)     /* unlock floppy VBL */
		tst.w      d0
		bne.s      bootfail

		lea.l      (a2),a1        /* start of boot sector */
		move.w     #256-1,d1      /* 256 words */
		moveq.l    #0,d0
checksum:
		add.w      (a2)+,d0       /* calculate checksum */
		dbf        d1,checksum
		cmpi.w     #$1234,d0      /* 'magic' checksum */
		bne.s      bootfail       /* boot sector not executable */
		jsr        (a1)           /* call boot program */
bootfail:
		rts

/*
 *       Bootsektor lesen (Zylinder 0, Kopf 0, Sektor 0)
 *
 *       Ziel: zweiter Diskbuffer (_dskbufp zeigt auf einen
 *             1 KByte grossen Buffer)
 *
 *       dmaread()
 *          D0  = 0 ,falls o.k.
 *          D0 != 0 ,falls k.o. (KlockOut?)
 */
ctdmaread:
		bsr.s      select
		lea.l      cmd_tab(pc),a0  /* start command table */
		moveq.l    #5,d2
		moveq.l    #0,d3
ctsend:
		bsr.s      ct_wait_req
		bne.s      rd_err          /* -> timeout */
		move.b     (a0)+,d3
		move.w     d3,(a5)
		dbf        d2,ctsend
		move.l     #30*200,d1      /* 30 sec. timeout */
		bsr.s      wait_l
		lea.l      (a2),a3         /* 2nd disk buffer */
		move.w     #512-1,d2       /* byte counter */
rd_byte:
		bsr.s      ct_wait_req
		bne.s      rd_err          /* -> timeout */
		move.w     (a5),d0
		move.b     d0,(a3)+
		dbf        d2,rd_byte

/*
 *      read status byte
 */
		bsr.s      ct_wait_req
		move.w     (a5),d0
		andi.w     #$00FF,d0
		tst.w      d0

rd_err:
		move.w     #$0080,(a4)     /* DMA to floppy again */
		tst.w      d0
		rts


/*
 *       Auf Uebertragungsanforderung warten
 *
 *         wait_req: max. 1/10 Sekunde warten
 *         wait_l:   max. D1.l * 1/200 Sekunden warten
 *
 *         -> timeout : D0.l = -1
 *            ok      : D0.l = 0
 */
ct_wait_req:
		moveq.l    #127,d1

wait_l:
/*       Status-/Resetport waehlen */
		move.w     d7,(a4)
		move.w     d4,(a5)
		move.w     d6,(a4)
		add.l      _hz_200(a6),d1
_wait:
		move.w     (a5),d0
		and.w      d4,d0           /* test REQ bit */
		bne.s      wait_ok         /* set = NE */
		cmp.l      _hz_200(a6),d1  /* timeout? */
		bne.s      _wait
		bsr.s      d_port          /* select data port */
		moveq.l    #-1,d0
		rts
wait_ok:
		bsr.s      d_port          /* select data port */
		moveq.l    #0,d0
		rts

/*
 *      select controller
 */
select:
		move.w     d7,(a4)
		move.w     #2,(a5)
		move.w     d6,(a4)
		move.w     d5,(a5)         /* select */

/*
 *      select data port
 */
d_port:
		move.w     d7,(a4)
		move.w     d5,(a5)
		move.w     d6,(a4)
		rts

/*
 *      commands for controller
 */
cmd_tab:
		dc.b    _read           /* command */
        dc.b    0               /* head */
        dc.b    0               /* sector number */
        dc.b    0               /* cylinder */
        dc.b    1               /* number of sectors */
        dc.b    steprate        /* control byte */
