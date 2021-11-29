/*
 * Flush instruction and data cache (68020+)
 */
	xdef flushCaches
flushCaches:
        move.w    sr,-(a7)
        ori.w     #$0700,sr
        CACR_D0
        or.l      #$00000808,d0           /* CI (Clear Instruction Cache), DI (Clear Data Cache) */
        D0_CACR
        move.w    (a7)+,sr
        rts

/*
 * _int_priv - privileged instruction handler
 *
 * Convert a privileged 'MOVE SR,...' to 'MOVE CCR,...'
 */
/* 306de: 00e0060a */
/* 206de: 00e00638 */
/* 404: 00E00872 */
_int_priv:
        movem.l   d0-d2,-(a7)      /* saving some registers while we test */
        move.l    a1,-(a7)
        move.l    a0,-(a7)
        movea.l   22(a7),a0        /* the offending address */
        move.w    (a0),d0          /* the offending instruction */
        move.w    d0,d1            /* save for later tests */
        and.w     #$FFC0,d0        /* isolate move from SR opcode */
        cmp.w     #$40C0,d0        /* we don't care where "To" was */
        bne       pi_back          /* Not a MOVE SR,XX instruction */
        move.l    #$30004E71,privinst.w   /* move.w d0,d0; nop */
        move.l    #$4E714E75,(privinst+4).w /* nop; rts */
        move.w    d1,d0
        and.w     #$0007,d0        /* <ea> register (bit 0..2) */
        lsl.w     #8,d0
        lsl.w     #1,d0            /* move into bit 9..11 of the destination <ea> */
        or.w      d0,privinst.w    /* insert the destination register */
        move.w    d1,d0
        and.w     #$0038,d0        /* <ea> mode (bit 3..5) */
        lsl.w     #3,d0
        or.w      d0,privinst.w    /* insert the destination addressing mode */
        moveq.l   #2,d2            /* skip that many instruction bytes */
        cmp.w     #$0180,d0        /* is it indexed? */
        beq       pi_back          /* not supported -> _term */
        tst.w     d0               /* is it data-register direct? */
        beq.s     int_p4           /* yes go execute it */
        cmp.w     #$0140,d0        /* is it d(An)? */
        beq.s     int_p2           /* yes */
        cmp.w     #$01C0,d0        /* is it absolute? */
        bne.s     int_p3
/* <ea> = (xxx).l or (xxx).w */
        and.w     #$0007,d1        /* is it absolute short? */
        beq.s     int_p1           /* yes, skip */
        addq.w    #2,d2            /* 2 more bytes of instruction */
        move.w    4(a0),(privinst+4).w /* copy lower 16 bits of address */
int_p1:
        addq.w    #2,d2            /* 2 more bytes of instruction */
        move.w    2(a0),(privinst+2).w /* copy remaining 16 bits of address */
        bra.s     int_p5
/* <ea> = d16(An) */
int_p2:
        addq.w    #2,d2            /* 2 more bytes of instruction */
        move.w    2(a0),(privinst+2).w /* copy displacement */
int_p3:
        and.w     #$0007,d1        /* is USP affected? */
        cmp.w     #$0007,d1
        bne.s     int_p5           /* no -> regular destination ea */
/* <ea> = d16(A7) or d8(A7,Dn) */
/* Special case because A7 has to be the USP, instead of the current SSP (in A7) */
        move.l    usp,a1           /* have to use the USP, otherwise we wouldn't have gotten the exception */
        andi.w    #$F3FF,privinst.w /* convert A7-relative into A1-relative destination <ea> */
        add.l     d2,22(a7)        /* pc += opcode size */
#if TOSVERSION >= 0x300
        bsr       flushCaches
#endif
        move.w    20(a7),d0        /* d0 = SR */
        jsr       privinst.w       /* execute: MOVE D0,d(A1,Dn); NOP; RTS or MOVE D0,d(A1); NOP; RTS */
        move.l    a1,usp           /* restore USP, but shouldn't have changed anyway */
        movea.l   (a7)+,a0
        movea.l   (a7)+,a1
        movem.l   (a7)+,d0-d2
        rte
/* <ea> = Dn */
int_p4:
        add.l     d2,22(a7)           /* adjust return PC by number of bytes to skip */
        ori.w     #$0010,privinst.w   /* source ea = (A0) */
#if TOSVERSION >= 0x300
        bsr       flushCaches
#endif
        lea.l     20(a7),a0           /* a0 = address of SR from stack frame */
        movem.l   8(a7),d0-d2
        jsr       privinst.w          /* execute: MOVE (A0),Dn; NOP; NOP; RTS */
        movea.l   (a7)+,a0
        movea.l   (a7)+,a1
        adda.w    #$000C,a7           /* skip d0-d2, because they have already been restored */
        rte
int_p5:
        add.l     d2,22(a7)           /* adjust return PC by number of bytes to skip */
#if TOSVERSION >= 0x300
        bsr       flushCaches
#endif
        movea.l   (a7)+,a0
        movea.l   (a7)+,a1
        move.w    12(a7),d0
        jsr       privinst.w          /* execute: MOVE D0,<ea>; ...; RTS */
        movem.l   (a7)+,d0-d2
        rte
pi_back:
        movea.l   (a7)+,a0
        movea.l   (a7)+,a1
        movem.l   (a7)+,d0-d2
#if TOSVERSION < 0x300
        jmp       any_vec+$08000000             /* illegal instruction => _term; $80000000 to get exception number in high byte */
#else
        jmp       any_vec            /* illegal instruction => _term */
#endif

