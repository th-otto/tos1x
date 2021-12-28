OSSTART equ $fc0000
OSDATE  equ $04061989

_lineftrap      equ $02c
_trap1vec       equ $084       /* Trap #1 (GEMDOS) */
_trap14vec      equ $0b8       /* Trap #14 (XBIOS) */
resvector       equ $42a
resvalid        equ $426

patcharea       equ $600

baudrate        equ $a6e      /* internal variable of TOS 1.04 */

MFP_REGS        equ $FFFFFA01
MFP_SCR         equ 38
MFP_UCR         equ 40
MFP_RSR         equ 42
MFP_TSR         equ 44

/* sizeof(IOREC) */
IOREC_SIZE equ 14

rcv       equ 2*IOREC_SIZE+0
wr5       equ 2*IOREC_SIZE+1
highwater equ 2*IOREC_SIZE+2
xoff      equ 2*IOREC_SIZE+3
ctr       equ 2*IOREC_SIZE+4
xonoffc   equ 2*IOREC_SIZE+5

rs232iorec equ $0c70

/* absolute address from TOS 1.04 */
settimer equ $00FC36AC

	.text

entry:
		pea.l      instpat
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.w     #6,a7
		cmp.l      #OSSTART,d0
		beq.s      exit
		cmp.l      #OSDATE,d0
		beq.s      exit
		pea.l      welcomemsg(pc)
		move.w     #9,-(a7) ; Cconws
		trap       #1
		addq.w     #6,a7
exit:
		clr.w      (a7)
		trap       #1

welcomemsg:
		dc.b 10,13,27,'p'
		.ascii '  Rainbow TOS patches loaded.  '
		dc.b 27,'q',10,13
		.ascii ' Copyright ',0xbd,' 1989, Atari Corp. ',10,13
		.ascii ' Version 1.5 ,by K.Isakovic    ',10,13,0
		.even

instpat:
		movea.l    (0x000004F2).w,a0
		movea.l    8(a0),a0
		move.l     #OSSTART,d0   ; correct ROM base?
		cmp.l      a0,d0
		beq.s      instpat1
		rts
instpat1:
		move.l     #OSDATE,d0    ; correct ROM version?
		cmp.l      24(a0),d0
		beq.s      instpat2
		rts
instpat2:
		move.l     (patcharea).w,d0
		cmp.l      #0x0BADC0DE,d0 ; already installed?
		bne.s      instpat3
		rts
instpat3:
/*
 * search for the start of the linef table in ROM.
 * The address differs between language versions.
 * It is located just before the entry point of GEM,
 * and we are looking for the UNLK/RTS opcodes
 * of the routine just before it.
 */
		movea.l    20(a0),a0  ; hdr->os_magic
instpat4:
		cmpi.w     #0x4E75,-(a0) ; RTS opcode
		bne.s      instpat4
		cmpi.w     #0x4E5E,-(a0) ; UNLK opcode
		bne.s      instpat4
		addq.w     #4,a0         ; now have start of linef dispatcher table
		lea.l      getlinef+2(pc),a1
		move.l     a0,(a1)
		tst.b      (_lineftrap).w
		bne.s      instpat5
		move.l     (_lineftrap).w,mylineftrap-4
		lea.l      gooldtrap(pc),a0
		move.l     #$207AFFF0,(a0)+   ; movea.l    mylineftrap-4(pc),a0
		move.w     #$4ED0,(a0)        ; jmp (a0)
instpat5:
		lea.l      patchcode(pc),a0
		lea.l      (patcharea).w,a1
		move.w     #(endpatchcode-patchcode),d0
		lsr.w      #2,d0
instpat6:
		move.l     (a0)+,(a1)+
		dbf        d0,instpat6

/*
 * install an entry in cookie jar
 */
		move.l     ($000005A0).w,d0
		beq.s      nocookie
		movea.l    d0,a0
		clr.l      d0
cookie1:
		tst.l      (a0)
		beq.s      cookie2
		addq.w     #1,d0
		addq.l     #8,a0
		bra.s      cookie1
cookie2:
		cmp.l      4(a0),d0
		bge.s      nocookie
		clr.l      8(a0)
		move.l     4(a0),12(a0)
		move.l     #$54464958,(a0) /* 'TFIX' */
		move.l     #$00010005,4(a0) /* version number */
		
nocookie:
		move.w     sr,-(a7)
		ori.w      #0x0700,sr
* install new line-f trap handler
		move.l     #(mylineftrap-patchcode)+patcharea,(_lineftrap).w
* install new xbios handler
		lea        (_trap14vec).w,a0
		lea        ((newxbios-4-patchcode)+patcharea).w,a1
		move.l     (a0),(a1)+
		move.l     a1,(a0)
* install new gemdos handler
		lea        (_trap1vec).w,a0
		lea        ((newgemdos-4-patchcode)+patcharea).w,a1
		move.l     (a0),(a1)+
		move.l     a1,(a0)
* install new reset vector
		lea        (resvector).w,a0
		lea        ((myresvec-4-patchcode)+patcharea).w,a1
		move.l     (a0),(a1)+
		move.l     a1,(a0)
* save old resvalid
		lea        (resvalid).w,a0
		move.l     (a0),(oldresvalid-patchcode+patcharea).w
* make new reset vector valid
		move.l     #0x31415926,(a0)
		move.w     (a7)+,sr
		rts

/*
 * start of actual code
 */

patchcode:
	dc.l 0x0BADC0DE
oldresvalid:
	dc.l 0
	dc.l 0x58425241 /* 'XBRA' */
	dc.l 0x54464958 /* 'TFIX' */
	dc.l 0
myresvec:
		clr.l      (patcharea).w
		move.l     myresvec-4(pc),(resvector).w
		move.l     oldresvalid(pc),(resvalid).w
		jmp        (a6)

	dc.l 0x58425241 /* 'XBRA' */
	dc.l 0x54464958 /* 'TFIX' */
	dc.l 0
newxbios:
#if 0
		btst       #13,(a7)                 /* were we in supervisor mode? */
#else
		dc.w       0x0817,0x000d  /* assemblers may choke on the invalid #13 above */
#endif
		beq.s      bx_user
		lea.l      6(a7),a0                 /* yes, arguments are on stack */
		bra.s      bx_sp_ok
bx_user:
		move.l     usp,a0                   /* arguments are on user stack */
bx_sp_ok:
		cmpi.w     #15,(a0)                 /* Rsconf call? */
		beq.s      rsconf
		move.l     newxbios-4(pc),a0
		jmp        (a0)
rsconf:
		cmpi.w     #-2,2(a0)                /* -2 = return last baudrate */
		bne.s      rs6conf2
		move.w     (baudrate).w,d0          /* last baudrate */
		rte
rs6conf2:
		ori.w      #0x0700,sr               /* no interrupts for now */
		lea.l      (MFP_REGS).w,a1          /* set mfp chip address pointer */
		lea.l      retvalue+2(pc),a2
		movep.l    MFP_UCR(a1),d0           /* grab the old ucs,rsr,tsr,scr contents */
		move.l     d0,(a2)                  /* patch return value */
		move.w     4(a0),d0                 /* get new flow control */
		bmi        rs6conf6
		andi.b     #3,d0
		cmp.b      #3,d0                    /* valid values are 0-3 */
		bne.s      rs6conf3
		moveq.l    #1,d0                    /* set flag for handshake */
rs6conf3:
		move.b     d0,(rs232iorec+ctr).w    /* set new handshake state */
rs6conf6:
		tst.w      2(a0)                    /* change baudrate? */
		bmi.s      rs6conf7
		moveq.l    #0,d0
		move.b     d0,MFP_RSR(a1)           /* disable receiver */
		move.b     d0,MFP_TSR(a1)           /* disable transmitter */
		move.w     2(a0),d1                 /* new baudrate */
		move.w     d1,(baudrate).w          /* store for later */
		lea.l      baudctrl(pc),a2          
		move.b     0(a2,d1.w),d0            /* get baudrate control register settings mask */
		lea.l      bauddata(pc),a2
		move.b     0(a2,d1.w),d2            /* get baudrate data register value */
		move.l     d0,d1
		moveq.l    #3,d0
		jsr        settimer.l
		moveq.l    #1,d0
		move.b     d0,MFP_RSR(a1)           /* enable receiver */
		move.b     d0,44(a1)                /* enable transmitter */
rs6conf7:
		tst.w      6(a0)                    /* if -1 then don't change */
		bmi.s      rs6conf8
		move.b     7(a0),MFP_UCR(a1)
rs6conf8:
		tst.w      8(a0)                    /* if -1 then don't change */
		bmi.s      rs6conf9
		move.b     9(a0),MFP_RSR(a1)
rs6conf9:
		tst.w      10(a0)
		bmi.s      rs6con10
		move.b     11(a0),MFP_TSR(a1)
rs6con10:
		tst.w      12(a0)
		bmi.s      retvalue
		move.b     13(a0),MFP_SCR(a1)
retvalue:
		move.l     #0x00BC614E,d0
		rte

/* baudrate table - control register setting */
baudctrl: dc.b $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02
/* baudrate table - data register setting */
bauddata: dc.b $01,$02,$04,$05,$08,$0a,$0b,$10,$20,$40,$60,$80,$8f,$af,$40,$60


	dc.l 0x58425241 /* 'XBRA' */
	dc.l 0x54464958 /* 'TFIX' */
	dc.l 0
mylineftrap:
		movea.l    2(a7),a0                 /* fetch caller pc */
		cmpi.w     #$F5DC,(a0)              /* sh_name call? */
		beq.s      linef1
/*
 * will be patched above if a different linef trap handler was already installed
 */
gooldtrap:
		nop
		nop
		nop
linef1:
		move.w     (a7)+,d2                 /* fetch sr */
		movea.l    (a7)+,a0                 /* fetch caller pc */
		move.w     (a0)+,d1                 /* fetch opcode */
		btst       #0,d1
		bne.s      linefh1
		move.w     d2,sr
		move.l     a0,-(a7)
		cmp.w      #$F5DC,d1                /* sh_name call? */
		beq.s      sh_name
		andi.w     #$0FFF,d1
getlinef:
		move.l     #0x00123456,a0
		movea.l    0(a0,d1.w),a0
		jmp        (a0)
linefh1:
		andi.w     #$0FFE,d1                /* were any registers saved? */
		beq.s      linefh2                  /* -> no */
		lsl.w      #2,d1                    /* correct the mask */
		ori.w      #$0700,sr                /* block interrupts since we might be called from the timer interrupt */
		lea.l      movinst+2(pc),a0
		move.w     d1,(a0)
		/* if any registers were saved, the epilogue would contain a tst.l (a7)+ instruction */
		addq.l     #4,a7
movinst:
		movem.l    (a7)+,d0
linefh2:
		move.w     d2,sr                    /* restore interrupts */
		unlk       a6                       /* perform the unlk that was removed from epilogue */
		rts                                 /* perform the rts that was removed from epilogue */

/* char *sh_name(char *ppath) */
sh_name:
		movea.l    4(a7),a1
		movea.l    a1,a2
sh_name1:
		tst.b      (a1)+
		bne.s      sh_name1
sh_name2:
		move.b     -(a1),d0
		cmpa.l     a2,a1
		bcs.s      sh_name3
		cmp.b      #$5C,d0
		beq.s      sh_name3
		cmp.b      #$3A,d0
		bne.s      sh_name2
sh_name3:
		addq.l     #1,a1
		move.l     a1,d0
		rts


	dc.l 0x58425241 /* 'XBRA' */
	dc.l 0x54464958 /* 'TFIX' */
	dc.l 0
/*
 * fix for Mshrink(0)
 */
newgemdos:
#if 0
		btst       #13,(a7)                 /* were we in supervisor mode? */
#else
		dc.w       0x0817,0x000d  /* assemblers may choke on the invalid #13 above */
#endif
		beq.s      newgemd1
		lea.l      6(a7),a0                 /* yes, arguments are on stack */
		bra.s      newgemd2
newgemd1:
		move.l     usp,a0                   /* arguments are on user stack */
newgemd2:
		cmpi.w     #$004A,(a0)              /* Mshrink call? */
		bne.s      newgemd3
		tst.l      8(a0)                    /* size == 0? */
		bne.s      newgemd3
		move.l     4(a0),d0                 /* get pointer */
		move.l     d0,2(a0)                 /* put in position */
		move.w     #$0049,(a0)              /* modify call to Mfree */
newgemd3:
		movea.l    newgemdos-4(pc),a0
		jmp        (a0)

endpatchcode:
		.text
