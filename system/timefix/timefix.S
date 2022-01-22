#define XBRA_MAGIC $58425241
#define RPIT_MAGIC $52504954

#define _longframe 0x59e

/* only valid for TOS 1.04 */
#define old_tik $1814
#define date    $60be
#define time    $378a

rpt_year  equ 0
rpt_month equ 1
rpt_day   equ 2
rpt_hour  equ 3
rpt_min   equ 4
rpt_sec   equ 5

res_start:
		bra        main

	dc.l RPIT_MAGIC
	dc.l 0
new_tik:
		lea.l      rpt,a1
		bsr.w      setdos
		addq.w     #1,tik_cnt
		cmpi.w     #50,tik_cnt
		bmi.s      new_tik1
		clr.w      tik_cnt
		bsr        inctime
new_tik1:
		move.l     new_tik-4,-(a7)
		rts

setdos:
		lea.l      shifttab,a2
		clr.l      d1
		clr.l      d7
setdos1:
		move.b     0(a2,d1.w),d2
		andi.l     #15,d2
		lsl.l      d2,d7
		move.b     0(a1,d1.w),d0
		andi.l     #255,d0
		or.l       d0,d7
		addq.b     #1,d1
		cmp.b      #5,d1
		bne.s      setdos1
		move.b     0(a2,d1.w),d2
		andi.l     #15,d2
		lsl.l      d2,d7
		move.b     0(a1,d1.w),d0
		andi.l     #255,d0
		lsr.l      #1,d0
		or.l       d0,d7
		move.w     d7,time
		swap       d7
		move.w     d7,date
		rts

calcleap:
		lea.l      rpt,a1
		lea.l      daytab,a2
		move.b     #29,1(a2)
		clr.l      d1
		move.b     rpt_year(a1),d1
		btst       #0,d1
		bne.s      noleap
		btst       #1,d1
		bne.s      noleap
		cmp.b      #2100-1980,d1
		beq.s      noleap
		cmp.b      #2200-1980,d1
		beq.s      noleap
		/* addq.b     #1,1(a2) */
		dc.w 0x062a,0x0001,0x0001 /* XXX */
noleap:
		rts

inctime:
		addq.b     #1,rpt_sec(a1)
		cmpi.b     #60,rpt_sec(a1)
		bne.s      inctime1
		clr.b      rpt_sec(a1)
		addq.b     #1,rpt_min(a1)
		cmpi.b     #60,rpt_min(a1)
		bne.s      inctime1
		clr.b      rpt_min(a1)
		addq.b     #1,rpt_hour(a1)
		cmpi.b     #24,rpt_hour(a1)
		bne.s      inctime1
		clr.b      rpt_hour(a1)
		addq.b     #1,rpt_day(a1)
		lea.l      daytab,a2
		move.b     rpt_month(a1),d1
		move.b     -1(a2,d1.w),d2
		cmp.b      rpt_day(a1),d2
		bne.s      inctime1
		move.b     #1,rpt_day(a1)
		addq.b     #1,rpt_month(a1)
		cmpi.b     #13,rpt_month(a1)
		bne.s      inctime1
		move.b     #1,rpt_month(a1)
		addq.b     #1,rpt_year(a1)
		bra        calcleap
inctime1:
		rts

tik_cnt: ds.w 1
rpt: ds.b 6
shifttab: dc.b 7,4,5,5,6,5
masktab: dc.b 127,15,31,31,63,31

daytab: dc.b 32,29,32,31,32,31,32,32,31,32,31,32

	dc.l XBRA_MAGIC
	dc.l RPIT_MAGIC
	dc.l 0
new_gemdos:
		movea.l    stackptr,a0
		tst.w      (_longframe).w
		beq.s      new_gd1
		move.l     (a7)+,d0
		move.l     d0,-(a0)
		bra.s      new_gd2
new_gd1:
		move.w     (a7)+,d0
		move.w     d0,-(a0)
new_gd2:
		move.l     (a7)+,-(a0)
		movem.l    d1-d7/a1-a7,-(a0)
		move.l     a0,stackptr
		btst       #13,d0
		bne.s      new_gd3
		move.l     usp,a7
new_gd3:
		move.w     (a7),d0
		cmp.w      #43,d0 ; Tsetdate?
		beq.w      tsetdate
		cmp.w      #45,d0 ; Tsettime?
		beq.w      tsettime
		cmp.w      #0x0816,d0
		beq.w      rsettime
		cmp.w      #0x0817,d0
		beq        rgettime
		cmp.w      #0x0818,d0
		beq        rdayweek
new_gd4:
		move.l     new_gemdos-4,oldptr

goold:
		movea.l    stackptr,a0
		movem.l    (a0)+,d1-d7/a1-a7
		move.l     (a0)+,-(a7)
		tst.w      (_longframe).w
		beq.s      goold1
		move.l     (a0)+,-(a7)
		bra.s      goold2
goold1:
		move.w     (a0)+,-(a7)
goold2:
		move.l     a0,stackptr
		movea.l    oldptr,a0
		jmp        (a0)

new_gd5:
		movea.l    stackptr,a0
		movem.l    (a0)+,d1-d7/a1-a7
		move.l     (a0)+,-(a7)
		tst.w      (_longframe).w
		beq.s      new_gd6
		move.l     (a0)+,-(a7)
		bra.s      new_gd7
new_gd6:
		move.w     (a0)+,-(a7)
new_gd7:
		move.l     a0,stackptr
		rte

tsettime:
		move.w     2(a7),d0
		bsr        calctime
		bra.s      new_gd4

tsetdate:
		move.w     2(a7),d0
		bsr        calcdate
		bra.s      new_gd4

rsettime:
		movea.l    2(a7),a0
		lea.l      rpt,a1
		move.l     0(a0),0(a1)
		move.w     4(a0),4(a1)
		bsr        calcleap
		bra.s      new_gd5

rgettime:
		move.l     #rpt,d0
		bra.s      new_gd5

rdayweek:
		lea.l      rpt,a0
		clr.l      d0
		clr.l      d1
		clr.l      d2
		move.b     rpt_year(a0),d1
		move.b     rpt_month(a0),d2
		subq.b     #2,d2
		bmi.w      rdayw2
		lea.l      daytab,a1
rdayw1:
		move.b     0(a1,d2.w),d0
		add.w      d0,d1
		subq.w     #1,d1
		dbf        d2,rdayw1
rdayw2:
		move.b     rpt_day(a0),d0
		add.w      d0,d1
		move.b     rpt_year(a0),d0
		addq.w     #3,d0
		divu.w     #4,d0
		andi.l     #0x0000FFFF,d0
		add.w      d0,d1
		cmpi.b     #2200-1980,rpt_year(a0)
		bls.s      rdayw3
		subq.w     #1,d1
rdayw3:
		cmpi.b     #2100-1980,rpt_year(a0)
		bls.s      rdayw4
		subq.w     #1,d1
rdayw4:
		addq.w     #1,d1
		divu.w     #7,d1
		swap       d1
		move.w     d1,d0
		bra        new_gd5

calctime:
		lea.l      rpt,a1
		lea.l      shifttab,a2
		lea.l      masktab,a3
		move.l     #6-1,d1
calct1:
		move.l     d0,d7
		andi.l     #255,d7
		and.b      0(a3,d1.w),d7
		move.b     d7,0(a1,d1.w)
		move.b     0(a2,d1.w),d2
		andi.l     #15,d2
		lsr.l      d2,d0
		subq.b     #1,d1
		cmp.b      #3,d1
		bmi.s      calct2
		bra.s      calct1
calct2:
		move.b     5(a1),d7
		lsl.l      #1,d7
		move.b     d7,5(a1)
		rts

calcdate:
		lea.l      rpt,a1
		lea.l      shifttab,a2
		lea.l      masktab,a3
		move.l     #2-0,d1
calcd1:
		move.l     d0,d7
		andi.l     #255,d7
		and.b      0(a3,d1.w),d7
		move.b     d7,0(a1,d1.w)
		move.b     0(a2,d1.w),d2
		andi.l     #15,d2
		lsr.l      d2,d0
		subq.b     #1,d1
		tst.b      d1
		bmi        calcleap
		bra.s      calcd1


	dc.l XBRA_MAGIC
	dc.l RPIT_MAGIC
	dc.l 0
new_xbios:
		movea.l    stackptr,a0
		tst.w      (_longframe).w
		beq.s      new_xb1
		move.l     (a7)+,d0
		move.l     d0,-(a0)
		bra.s      new_xb2
new_xb1:
		move.w     (a7)+,d0
		move.w     d0,-(a0)
new_xb2:
		move.l     (a7)+,-(a0)
		movem.l    d1-d7/a1-a7,-(a0)
		move.l     a0,stackptr
		btst       #13,d0
		bne.s      new_xb3
		move.l     usp,a7
new_xb3:
		move.w     (a7),d0
		cmp.w      #22,d0 ; Settime call?
		beq.w      dosettime
		cmp.w      #23,d0 ; Gettime call?
		beq.w      dogettime
new_xb4:
		move.l     new_xbios-4,oldptr
		bra        goold

dosettime:
		move.l     2(a7),d0
		move.l     #25-0,d1
		lsr.l      d1,d0
		cmp.w      #20,d0 ; year > 20?
		bge.s      doset1
		bra.s      new_xb4
doset1:
		cmp.w      #68,d0
		bge.s      doset2
		addi.w     #60,d0
		bra.s      doset3
doset2:
		move.w     #127,d0
doset3:
		lsl.l      d1,d0
		andi.l     #0x01FFFFFF,2(a7)
		or.l       d0,2(a7)
		bra.s      new_xb4

dogettime:
		tst.w      (_longframe).w
		beq.s      doget1
		move.w     #0x00B8,-(a7)
doget1:
		move.l     #doget2,-(a7)
		move.w     sr,-(a7)
		movea.l    new_xbios-4,a0
		jmp        (a0)
doget2:
		move.l     d0,d2
		move.l     #25-0,d1
		lsr.l      d1,d0
		cmp.w      #20,d0
		bge.s      doget3
		move.l     d2,d0
		bra        new_gd5
doget3:
		cmp.w      #48,d0
		bge.s      doget4
		bra.s      doget5
doget4:
		cmp.w      #128,d0
		bge.s      doget5
		subi.w     #28,d0
		bra.s      doget6
doget5:
		clr.l      d0
doget6:
		lsl.l      d1,d0
		andi.l     #0x01FFFFFF,d2
		or.l       d2,d0
		bra        new_gd5

oldptr: ds.l 1
stackptr: ds.l 1

stack: ds.b 384
stackend:

res_end:

main:
		move.l     #stackend,stackptr
		clr.w      tik_cnt
#ifdef UNINST
		bra.s      douninst
#endif
		pea.l      Rcheck
		move.w     #38,-(a7) ; Supexec
		trap       #14
		move.l     d0,d0
		bne.s      main1
		addq.l     #6,a7
		lea.l      already_installed,a1
		bsr        printstr
		bra.s      quit
main1:
		addq.l     #6,a7
		bsr        gettime
		pea.l      install
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		bsr        settime
		lea.l      copyright,a1
		bsr        printstr
		move.w     #0,-(a7)
		move.l     #res_end-res_start+0x100,-(a7)
		move.w     #49,-(a7) ; Ptermres
		trap       #1
		addq.l     #8,a7

douninst:
		pea.l      uninstall
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		lea.l      unistalled,a1
		bsr        printstr
quit:
		move.w     #0,-(a7) ; Pterm0
		trap       #1
		addq.l     #2,a7

uninstall:
		bsr.w      Rcheck
		bne.w      uninst1
		movea.l    old_tik,a0
		move.l     -4(a0),d0
		move.l     d0,old_tik
		bsr.w      uninst_gemdos
		bsr        uninst_xbios
uninst1:
		rts

Rcheck:
		movea.l    old_tik,a0
		move.l     -8(a0),d0
		sub.l      new_tik-8,d0
		rts

install:
		move.l     old_tik,new_tik-4
		move.l     #new_tik,old_tik
		bsr.w      inst_gemdos
		bsr.w      inst_xbios
		rts

inst_gemdos:
		move.l     #-1,-(a7)
		move.w     #33,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		move.l     d0,new_gemdos-4
		move.l     #new_gemdos,-(a7)
		move.w     #33,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		rts

uninst_gemdos:
		move.l     #-1,-(a7)
		move.w     #33,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		movea.l    d0,a0
		move.l     -4(a0),d0
		move.l     d0,-(a7)
		move.w     #33,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		rts

inst_xbios:
		move.l     #-1,-(a7)
		move.w     #46,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		move.l     d0,new_xbios-4
		move.l     #new_xbios,-(a7)
		move.w     #46,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		rts

uninst_xbios:
		move.l     #-1,-(a7)
		move.w     #46,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		movea.l    d0,a0
		move.l     -4(a0),d0
		move.l     d0,-(a7)
		move.w     #46,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		rts

gettime:
		move.w     #42,-(a7) ; Tgetdate
		trap       #1
		addq.l     #2,a7
		swap       d0
		move.l     d0,d3
		move.w     #44,-(a7) ; Tgettime
		trap       #1
		addq.l     #2,a7
		move.w     d0,d3
		move.l     d3,d0
		bsr        calctime
		bsr        calcdate
		rts

settime:
		move.w     #42,-(a7) ; Tgetdate
		trap       #1
		addq.l     #2,a7
		swap       d0
		move.l     d0,d3
		move.w     #44,-(a7) ; Tgettime
		trap       #1
		addq.l     #2,a7
		move.w     d0,d3
		move.l     d3,-(a7)
		move.w     #22,-(a7) ; Settime
		trap       #14
		addq.l     #6,a7
		rts

printstr:
		movea.l    a1,a3
		lea.l      banner,a1
printst1:
		move.b     (a1)+,d0
		beq.w      printst2
		bsr.w      printc
		bra.s      printst1
printst2:
		movea.l    a3,a1
printst3:
		move.b     (a1)+,d0
		beq.w      printst4
		bsr.w      printc
		bra.s      printst3
printst4:
		rts

printc:
		move.l     a1,-(a7)
		andi.w     #0x00FF,d0
		move.w     d0,-(a7)
		move.w     #2,-(a7) ; Cconout
		trap       #1
		addq.l     #4,a7
		movea.l    (a7)+,a1
		rts


banner:
		dc.b 13,10,27,'p'
		ascii ' TIMEFIX v1.3         (for TOS 1.04) '
        dc.b 27,'q',13,10,0
copyright:
		ascii '  Copyright '
		dc.b 0xbd
		ascii ' 2020, RP Instruments'
		dc.b 13,10,0
already_installed:
		ascii '  Already installed ... Aborted!'
		dc.b 13,10,0
unistalled:
		ascii '  Uninstalled!'
		dc.b 13,10,0
		dc.b 0x90
		even
