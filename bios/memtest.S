#include "config.h"

ZONESIZE equ $20000

/* 306de: 00e05fa4 */
/* 206de: 00e05bb2 */
	xdef memtest
memtest:
        movea.l   memtnext,a0
        move.l    a0,d0
        beq.s     memtes1
        jmp       (a0)
memtes1:
        movea.l   #memthdr1,a0
        bsr       mempstr
        clr.l     memtaddr
        move.l    _phystop,memttop
        move.l    _membot,d0
        add.l     #ZONESIZE-1,d0
        move.l    #ZONESIZE-1,d1
        not.l     d1
        and.l     d1,d0
        move.l    d0,memtbot
        move.l    _memtop,d0
        and.l     d1,d0
        move.l    d0,memtend
        clr.w     memterr
        move.l    #memtes2,memtnext
        bra       memtes16
memtes2:
        bsr       testzone
        move.w    memterr,d1
        or.w      d0,d1
        move.w    d1,memterr
        move.l    memtsize,d0
        sub.l     #ZONESIZE,d0
        move.l    d0,memtsize
        bgt.s     memtes5
        move.l    memtzone,d0
        add.l     d0,memtsize
        tst.w     memterr
        beq.s     memtes3
        move.w    #$0058,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, 'X') */
        addq.w    #6,a7
        bra.s     memtes4
memtes3:
        move.w    #$002D,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '-') */
        addq.w    #6,a7
memtes4:
        clr.w     memterr
memtes5:
        move.l    memtaddr,d0
        cmp.l     memttop,d0
        bne.s     memtes8
        move.l    d7,-(a7)
        moveq.l   #8,d7
memtes6:
        move.w    #$0008,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '\b') */
        addq.w    #6,a7
        dbf       d7,memtes6
        move.l    (a7)+,d7
        move.w    #$0020,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, ' ') */
        addq.w    #6,a7
        move.l    _phystop,d0
        asr.l     #8,d0
        asr.l     #2,d0
        bsr       prtdec
        movea.l   #memtkb,a0
        bsr       mempstr
        move.l    #memtes9,memtnext
memtes8:
        clr.l     d0
        rts
memtes9:
        clr.w     memterr
        move.l    _ramtop,d0
        beq       memtes15
        cmp.l     #$01000000,d0
        beq       memtes15
        move.l    d0,memttop
        move.l    #$01000000,memtaddr
        move.l    memtaddr,memtbot
        move.l    #ZONESIZE-1,d1
        not.l     d1
        and.l     d1,d0
        move.l    d0,memtend
        movea.l   #memthdr2,a0
        bsr       mempstr
        move.l    #memtes9a,memtnext
        bra       memtes16
memtes9a:
        bsr       testzone
        move.w    memterr,d1
        or.w      d0,d1
        move.w    d1,memterr
        move.l    memtsize,d0
        sub.l     #ZONESIZE,d0
        move.l    d0,memtsize
        bgt.s     memtes12
        move.l    memtzone,d0
        add.l     d0,memtsize
        tst.w     memterr
        beq.s     memtes10
        move.w    #$0058,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, 'X') */
        addq.w    #6,a7
        bra.s     memtes11
memtes10:
        move.w    #$002D,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '-') */
        addq.w    #6,a7
memtes11:
        clr.w     memterr
memtes12:
        move.l    memtaddr,d0
        cmp.l     memtend,d0
        bne.s     memtes14
        move.l    d7,-(a7)
        moveq.l   #8,d7
memtes13:
        move.w    #$0008,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '\b') */
        addq.w    #6,a7
        dbf       d7,memtes13
        move.l    (a7)+,d7
        move.w    #$0020,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, ' ') */
        addq.w    #6,a7
        move.l    _ramtop,d0
        sub.l     #$01000000,d0
        asr.l     #8,d0
        asr.l     #2,d0
        bsr       prtdec
        movea.l   #memtkb,a0
        bsr       mempstr
        move.l    #memtes15,memtnext
memtes14:
        clr.l     d0
        rts
memtes15:
        movea.l   #memtcmsg,a0
        bsr       mempstr
        move.l    #memtesa1,memtnext
        clr.l     d0
        rts

/* 306de: 00e061f2 */
	xdef memtestabort
memtestabort:
        tst.l     memtnext
        beq.s     memtesa1
        cmpi.l    #memtesa1,memtnext
        beq.s     memtesa1
        movea.l   #memtamsg,a0
        bsr       mempstr
        move.l    #memtesa1,memtnext
memtesa1:
        moveq.l   #-1,d0
        rts

memtes16:
        move.l    memttop,d0
        sub.l     memtaddr,d0
        cmp.l     #$00100000,d0
        bhi.s     memtes17
#if TOSVERSION >= 0x300
        move.l    d0,-(a7)
        movea.l   #memtsp,a0
        bsr       mempstr
        move.l    (a7)+,d0
memtes17:
#else
        movea.l   #memtsp,a0
        bsr       mempstr
memtes17:
        movea.l   #memtams2,a0
        bsr       mempstr
        move.l    memttop,d0
        sub.l     memtaddr,d0
#endif
        cmp.l     #$00400000,d0
        ble.s     memtes18
        move.l    d0,d2
        lsr.l     #5,d2
        move.l    d2,memtzone
        moveq.l   #32,d2
        bra.s     memtes19
memtes18:
        move.l    #ZONESIZE,memtzone
        move.l    d0,d2
        clr.w     d2
        swap      d2
        lsr.l     #1,d2
memtes19:
        move.l    d7,-(a7)
        move.l    memtzone,memtsize
        move.l    d2,d7
        move.l    d2,-(a7)
memtes20:
        move.w    #$0020,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, ' ') */
        addq.w    #6,a7
        subq.l    #1,d7
        bne.s     memtes20
        move.l    (a7)+,d7
memtes21:
        move.w    #$0008,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '\b') */
        addq.w    #6,a7
        subq.l    #1,d7
        bne.s     memtes21
        move.l    (a7)+,d7
        clr.l     d0
        rts

memthdr1:
                                     dc.b 'Memory Test:',13,10
                                     dc.b 'ST RAM ',0
memthdr2:                            dc.b 13,10,'TT RAM ',0
memtcmsg:                            dc.b 13,10,'Memory Test Complete.',13,10,0
memtkb:                              dc.b ' KB',27,'q',27,'K',0
memtamsg:                            dc.b 13,10,'Memory Test Aborted.'
                                     dc.b 27,'q',13,10,0
memtams2:                            dc.b 27,'p',0
memtsp:                              dc.b '       ',0
		even

mempstr:
        move.l    a5,-(a7)
        movea.l   a0,a5
mempstr1:
        move.b    (a5)+,d0
        beq.s     mempstr2
        move.w    d0,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13
        addq.w    #6,a7
        bra.s     mempstr1
mempstr2:
        movea.l   (a7)+,a5
        rts

testzone:
        moveq.l   #0,d0
        move.l    memtaddr,d1
        cmp.l     memtbot,d1
        bcs.s     testzon8
        cmp.l     memtend,d1
        bcc.s     testzon8
        move.l    #ZONESIZE/4-1,d0
        move.l    d0,d1
        movea.l   memtaddr,a0
        moveq.l   #-1,d2
testzon1:
        move.l    d2,(a0)+
        dbf       d0,testzon1
        movea.l   memtaddr,a0
        move.l    d1,d0
testzon2:
        cmp.l     (a0)+,d2
        dbne      d0,testzon2
        bne.s     testzon7
        movea.l   memtaddr,a0
        move.l    d1,d0
        moveq.l   #1,d2
testzon3:
        rol.l     #1,d2
        move.l    d2,(a0)+
        dbf       d0,testzon3
        movea.l   memtaddr,a0
        move.l    d1,d0
        moveq.l   #1,d2
testzon4:
        rol.l     #1,d2
        cmp.l     (a0)+,d2
        dbne      d0,testzon4
        bne.s     testzon7
        movea.l   memtaddr,a0
        move.l    d1,d0
        moveq.l   #0,d2
testzon5:
        move.l    d2,(a0)+
        dbf       d0,testzon5
        movea.l   memtaddr,a0
        move.l    d1,d0
testzon6:
        cmp.l     (a0)+,d2
        dbne      d0,testzon6
        bne.s     testzon7
        moveq.l   #0,d0
        bra.s     testzon8
testzon7:
        moveq.l   #-1,d0
testzon8:
        movea.l   memtaddr,a0
        adda.l    #ZONESIZE,a0
        move.l    a0,memtaddr
        rts

prtdec0:
        movem.l   d3-d4,-(a7)
        moveq.l   #1,d4
        bra.s     prtdec1
prtdec:
        movem.l   d3-d4,-(a7)
        clr.l     d4
prtdec1:
        move.l    #10000,d2
        clr.w     d3
        cmp.l     #$00010000,d0
        bne.s     prtdec2
        move.w    #$0036,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '6') */
        addq.w    #6,a7
        move.w    #$0035,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '5') */
        addq.w    #6,a7
        move.w    #$0035,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '5') */
        addq.w    #6,a7
        move.w    #$0033,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '3') */
        addq.w    #6,a7
        move.w    #$0036,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13         /* Bconout(2, '6') */
        addq.w    #6,a7
        bra.s     prtdec6
prtdec2:
        divu.w    d2,d0
        swap      d0
        move.w    d0,d1
        swap      d0
        movem.l   d1-d2,-(a7)
        or.b      d0,d0
        bne.s     prtdec3
        tst.w     d3
        bne.s     prtdec3
        cmpi.l    #1,d2
        beq.s     prtdec3
        tst.w     d4
        bne.s     prtdec5
        move.b    #$20,d0
        bra.s     prtdec4
prtdec3:
        addi.b    #$30,d0
        moveq.l   #1,d3
prtdec4:
        move.w    d0,-(a7)
        move.l    #$00030002,-(a7)
        trap      #13
        addq.w    #6,a7
prtdec5:
        movem.l   (a7)+,d1-d2
        move.l    d1,d0
        moveq.l   #10,d1
        divu.w    d1,d2
        bne.s     prtdec2
prtdec6:
        movem.l   (a7)+,d3-d4
        rts

		bss
		
		xdef memterr
		comm memterr,2
		
		xdef memtbot
		comm memtbot,4
		
		xdef memtnext
		comm memtnext,4
		
		xdef memtzone
		comm memtzone,4
		
		xdef memtsize
		comm memtsize,4

		xdef memtend
		comm memtend,4
		
		xdef memtaddr
		comm memtaddr,4
		
		xdef memttop
		comm memttop,4

#ifdef __GNUC__
		xdef _ldivr
		comm _ldivr,4
#endif
