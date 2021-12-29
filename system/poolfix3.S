_trap1vec       equ $084      /* Trap #1 (GEMDOS) */
resvalid        equ $426      /* validates resvector, if 0x31415926 */
resvector       equ $42a      /* reset vector */
_sysbase        equ $4f2      /* pointer to start of OS */
_longframe      equ $59e      /* if not 0, then not 68000 - use long stack frames */
_p_cookies      equ $5a0      /* pointer to cookie jar */

/*
 * offset from GEMDOS entry point to an 
 * "move.l    #_pmd(a7)" instruction inside xmalloc()
 */
pmd_offset equ -1796 /* 704 */
/*
 * offset from GEMDOS entry point to an 
 * "movea.l   _ofdlist,a5" instruction inside mgetmd()
 */
ofd_offset equ -1102 /* 44e */


        text


        move.l     4(sp),a6
        move.l     a6,basepage_p
        clr.l      -(sp)
        move.w     #$20,-(sp) ; Super
        trap       #1
        move.w     #$0030,-(a7) ; Sversion
        trap       #1
        addq.w     #2,a7
        lea        not_needed_s(pc),a0
        cmp        #$1500,d0
        bne        error_exit
        lea        strange_TOS_s(pc),a0
        move.l     (_sysbase).w,a1
        move.w     2(a1),d0
        cmp        #$104,d0                ;TOS 1.04 ?
        beq.b      L40
        cmp        #$106,d0                ;TOS 1.06 ?
        bne        error_exit
L40:
        clr.l      -(sp)
        move.l     #'_OOL',-(sp)
        bsr        find_cookie             ;test for own 'cookie'
        addq.l     #4,sp
        lea        already_in_s(pc),a0
        tst        d0
        bne        error_exit
        lea        bad_linkage_s(pc),a0
        move.l     (_sysbase).w,a1
        move.l     8(a1),a1
        move.l     (_trap1vec).w,a2
        move.l     a2,d0
        sub.l      a1,d0
        cmp.l      #$20000,d0
        bhi        error_exit
        lea        strange_TOS_s(pc),a0
        cmpi       #$2EBC,pmd_offset(a2)
        bne        error_exit
        cmpi       #$2A79,ofd_offset(a2)
        bne        error_exit
        clr.l      -(sp)
        move.l     sp,a5
        move.l     a5,-(sp)
        clr.l      -(sp)
        bsr        find_cookie             ;test for free 'cookie'
        addq.l     #4,sp
        /* addi.l     #8,(a5) */
        dc.w 0x0695,0,8 /* XXX */
        move.l     (a5),-(sp)
        move.l     24(a6),d0
        add.l      28(a6),d0
        move.l     d0,-(sp)
        move.l     #0,-(sp)
        move.l     #'_OOL',-(sp)
        bsr        place_cookie
        adda       #16,sp
        moveq      #0,d7
        tst        d0
        bmi.b      LCE
        beq.b      LCE
        move.l     (a5),d7
        asl.l      #3,d7
LCE:
        move.l     (_trap1vec).w,a1
        move.l     pmd_offset+2(a1),a2
        move.l     a2,pmd
        move.l     a2,mds           /* mds[0] = &pmd.mp_mfl */
        addq.l     #4,a2
        move.l     a2,mds+4         /* mds[1] = &pmd.mp_mal */
        move.l     ofd_offset+2(a1),a2
        move.l     a2,ofdlist
        move.l     (_trap1vec).w,newgemdos-4
        move.l     #newgemdos,$84.w
        move.l     #installed_s,-(a7)
        move.w     #9,-(a7) ; Cconws
        trap       #1
        addq.w     #6,a7
        move.l     24(a6),d0
        add.l      28(a6),d0
        add.l      d7,d0
        sub.l      a6,d0
        move.w     #0,-(a7)
        move.l     d0,-(a7)
        move.w     #$0031,-(a7) ; Ptermres
        trap       #1
        addq.w     #8,a7


error_exit:
        move.l     a0,-(sp)
        move.w     #9,-(sp)
        trap       #1
        addq       #6,sp
        move.l     #crnl,-(sp)
        move.w     #9,-(sp)
        trap       #1
        addq       #6,sp
        move.w     #1,-(sp)
        move.w     #$4C,-(sp)
        trap       #1
        dc.w       $4AFC ; illegal


installed_s:
        dc.b    'POOL PATCH OF 19-JAN-90 INSTALLED.'
crnl:
        dc.b    13,10,0
already_in_s:
        dc.b    'The pool patch is already installed.',0
not_needed_s:
        dc.b    'The pool patch is not needed in this TOS',0
bad_linkage_s:
        dc.b    'The pool patch must run first in the',13,10
        dc.b    '\AUTO\ folder (before any program',13,10
        dc.b    'links into the GEMDOS (trap 1) vector).',0
strange_TOS_s:
        dc.b    'This GEMDOS needs the pool patch, but',13,10
        dc.b    "this program doesn't recognize this TOS.",0


basepage_p:     dc.l    0


        dc.l 0x58425241 /* 'XBRA' */
        dc.l 0x5f4f4f4c /* '_OOL' */
        dc.l 0
newgemdos:
        tst.b      poolfix_flag
        beq        L2A2
        bsr        all_sub
L2A2:
        move.w     usp,a0
        btst       #5,(sp)
        beq.b      L2B6
        lea        6(sp),a0
        tst        (_longframe).w
        beq.b      L2B6
        addq.l     #2,a0
L2B6:
        move.w     (a0),d0 ;Pterm0 ?
        beq.b      L2CA
        cmp        #$49,d0 ;Mfree ?
        beq.b      L2CA
        cmp        #$31,d0 ;Ptermres ?
        beq.b      L2CA
        cmp        #$4C,d0 ;Pterm ?
* NB: Error of POOLFIX3: Mshrink is ignored !!!
* NB: Yet, it too can free RAM for compaction
L2CA:
        seq        poolfix_flag
        move.l     newgemdos-4,a0
        jmp        (a0)


all_sub:
        link       a6,#0
        movem.l    d2-d7/a3-a5,-(sp)
        suba.l     a5,a5
        move.l     ofdlist,a0
        move.l     (a0),a4
        clr        d3
        bra        L34A

L2F0:
        tst.b      4(a4)
        ble        L348
        clr        d4
        clr        d5
        lea        6(a4),a3
        bra        L328

L304:
        cmpi.l     #1,12(a3)
        bne        L31E
        /* add        #1,d4 */
        dc.w 0xd87c,1 /* XXX */
        move.l     a5,d0
        bne        L31E
        move.l     a4,a5
        move.w     d5,d6
L31E:
        /* add        #1,d5 */
        dc.w 0xda7c,1 /* XXX */
        adda.l     #16,a3
L328:
        cmp        #4,d5
        blt.b      L304
        cmp        #4,d4
        bne        L346
        clr.b      4(a4)
        cmp.l      a4,a5
        bne        L342
        suba.l     a5,a5
L342:
        bra        L348

L346:
        add        d4,d3
L348:
        move.l     (a4),a4
L34A:
        move.l     a4,d0
        bne.b      L2F0
        cmp        #4,d3
        blt        L566
        move.l     a5,a4
        move.w     d6,d7
L35A:
        /* add        #1,d7 */
        dc.w 0xde7c,1 /* XXX */
        cmp        #4,d7
        beq        L36E
        tst.b      4(a4)
        bgt        L372
L36E:
        clr        d7
        move.l     (a4),a4
L372:
        move.l     a4,d0
        beq        L392
        tst.b      4(a4)
        ble.b      L35A
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        beq.b      L35A
L392:
        bra        L55A

L396:
        bra        L41C

L39A:
        lea        6(a5),a3
        cmpi.l     #1,12(a3)
        bne        L418
        cmpi.l     #1,28(a3)
        bne        L418
        cmpi.l     #1,44(a3)
        bne        L418
        cmpi.l     #1,60(a3)
        bne        L418
        clr.b      4(a5)
        move.w     #3,d6
L3D6:
        /* add        #1,d6 */
        dc.w 0xdc7c,1 /* XXX */
        cmp        #4,d6
        beq        L3EA
        tst.b      4(a5)
        bgt        L3EE
L3EA:
        clr        d6
        move.l     (a5),a5
L3EE:
        move.l     a5,d0
        beq        L40E
        tst.b      4(a5)
        ble.b      L3D6
        move.w     d6,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a5,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        bne.b      L3D6
L40E:
        move.l     a5,d0
        beq        L566
        bra        L41C

L418:
        bra        L422

L41C:
        tst        d6
        beq        L39A
L422:
        bra        L4A4

L426:
        lea        6(a4),a3
        cmpi.l     #1,12(a3)
        beq        L4A0
        cmpi.l     #1,28(a3)
        beq        L4A0
        cmpi.l     #1,44(a3)
        beq        L4A0
        cmpi.l     #1,60(a3)
        beq        L4A0
        move.w     #3,d7
L45E:
        /* add        #1,d7 */
        dc.w 0xde7c,1 /* XXX */
        cmp        #4,d7
        beq        L472
        tst.b      4(a4)
        bgt        L476
L472:
        clr        d7
        move.l     (a4),a4
L476:
        move.l     a4,d0
        beq        L496
        tst.b      4(a4)
        ble.b      L45E
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        beq.b      L45E
L496:
        move.l     a4,d0
        beq        L566
        bra        L4A4

L4A0:
        bra        L4AA

L4A4:
        tst        d7
        beq        L426
L4AA:
        cmp.l      a5,a4
        beq        L522
        move.w     d6,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a5,d0
        move.l     d0,(sp)
        /* addi.l     #6,(sp) */
        dc.w 0x0697,0,6 /* XXX */
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,-(sp)
        /* addi.l     #6,(sp) */
        dc.w 0x0697,0,6 /* XXX */
        jsr        block_sub
        addq.l     #4,sp
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        move.l     #1,18(a0)
L4EA:
        /* add        #1,d6 */
        dc.w 0xdc7c,1 /* XXX */
        cmp        #4,d6
        beq        L4FE
        tst.b      4(a5)
        bgt        L502
L4FE:
        clr        d6
        move.l     (a5),a5
L502:
        move.l     a5,d0
        beq        L522
        tst.b      4(a5)
        ble.b      L4EA
        move.w     d6,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a5,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        bne.b      L4EA
L522:
        /* add        #1,d7 */
        dc.w 0xde7c,1 /* XXX */
        cmp        #4,d7
        beq        L536
        tst.b      4(a4)
        bgt        L53A
L536:
        clr        d7
        move.l     (a4),a4
L53A:
        move.l     a4,d0
        beq        L55A
        tst.b      4(a4)
        ble.b      L522
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        beq.b      L522
L55A:
        move.l     a5,d0
        beq        L566
        move.l     a4,d0
        bne        L396
L566:
        tst.l      (sp)+
        movem.l    (sp)+,d3-d7/a3-a5
        unlk       a6
        rts


block_sub:
        link       a6,#-4
        movem.l    d6-d7/a3-a5,-(sp)
        move.l     8(a6),a5
        clr        d7
        bra        L5AE

L582:
        move.w     d7,a0
        adda.l     a0,a0
        adda.l     a0,a0
        adda.l     #mds,a0
        move.l     (a0),-4(a6)
        move.l     -4(a6),a3
        move.l     (a3),a4
        bra        L5A6

L59C:
        cmp.l      a5,a4
        beq        L5BC
        move.l     a4,a3
        move.l     (a3),a4
L5A6:
        move.l     a4,d0
        bne.b      L59C
        /* add        #1,d7 */
        dc.w 0xde7c,1 /* XXX */
L5AE:
        cmp        #2,d7
        blt.b      L582
        move.w     #1,d0
        bra        L5F0

L5BC:
        move.l     pmd,a0
        cmp.l      8(a0),a5
        bne        L5D6
        move.l     pmd,a0
        move.l     12(a6),8(a0)
L5D6:
        move.l     12(a6),a0
        move.l     a5,a1
        move.w     #7,d1
L5E0:
        move.w     (a1)+,(a0)+
        dbf        d1,L5E0
        move.l     12(a6),(a3)
        clr        d0
        bra.w      L5F0

L5F0:
        tst.l      (sp)+
        movem.l    (sp)+,d7-d7/a3-a5
        unlk       a6
        rts


* int find_cookie(long id, void **ptr)
find_cookie:
        movem.l    d6-d7/a6-a6,-(sp)
        move.l     16(sp),d6
        move.l     20(sp),a6
        clr.l      d7
        move.l     #1,-(sp)
        move.w     #$20,-(sp) ; Super
        trap       #1
        tst.l      d0
        bne        L62A
        move.l     #0,2(sp)
        move.w     #$20,(sp) ; Super
        trap       #1
        move.l     d0,d7
L62A:
        addq.l     #6,sp
        move.l     (_p_cookies).w,a0
        move.l     a0,d0
        beq        L654
L636:
        move.l     (a0),d0
        cmp.l      d0,d6
        beq        L648
        tst.l      d0
        beq        L654
        addq.l     #8,a0
        bra.b      L636

L648:
        move.l     a6,d0
        beq        L652
        move.l     4(a0),(a6)
L652:
        moveq      #1,d0
L654:
        move.l     d0,d6
        tst.l      d7
        beq        L666
        move.l     d7,-(sp)
        move.w     #$20,-(sp) ; Super
        trap       #1
        addq.l     #6,sp
L666:
        move.l     d6,d0
        movem.l    (sp)+,d6-d7/a6-a6
        rts


place_cookie:
        link       a6,#0
        move.l     d7,-(sp)
        moveq      #0,d7
        move.l     #1,-(sp)
        move.w     #$20,-(sp) ; Super
        trap       #1
        tst.l      d0
        bne        L698
        move.l     #0,2(sp)
        move.w     #$20,(sp) ; Super
        trap       #1
        move.l     d0,d7
L698:
        addq.l     #6,sp
        move.l     (_p_cookies).w,a0
        move.l     a0,d0
        beq        L6D4
        moveq      #0,d0
L6A6:
        addq.l     #1,d0
        tst.l      (a0)
        beq        L6B2
        addq.l     #8,a0
        bra.b      L6A6

L6B2:
        cmp.l      4(a0),d0
        beq        L732
        move.l     4(a0),12(a0)
        clr.l      8(a0)
        move.l     8(a6),(a0)
        move.l     12(a6),4(a0)
        moveq      #0,d0
        bra        L768

L6D4:
        cmpi.l     #2,20(a6)
        blt        L766
        move.l     (resvector).w,oldresvector
        move.l     (resvalid).w,oldresvalid
        move.l     #L71C,(resvector).w
        move.l     #$31415926,(resvalid).w
        move.l     16(a6),a0
        move.l     a0,(_p_cookies).w
        move.l     8(a6),(a0)+
        move.l     12(a6),(a0)+
        clr.l      (a0)+
        move.l     20(a6),(a0)
        moveq      #1,d0
        bra        L768

L71C:
        clr.l      (_p_cookies).w
        move.l     oldresvalid,(resvalid).w
        move.l     oldresvector,(resvector).w
        jmp        (a6)
L732:
        cmp.l      20(a6),d0
        ble        L766
        move.l     d0,d1
        subq.l     #2,d1
        move.l     (_p_cookies).w,a0
        move.l     16(a6),a1
        move.l     a1,(_p_cookies).w
L74A:
        move.l     (a0)+,(a1)+
        move.l     (a0)+,(a1)+
        dbf        d1,L74A
        move.l     8(a6),(a1)+
        move.l     12(a6),(a1)+
        clr.l      (a1)+
        move.l     20(a6),(a1)
        moveq      #1,d0
        bra        L768
L766:
        moveq      #-1,d0
L768:
        tst.l      d7
        beq        L780
        move.l     d0,8(a6)
        move.l     d7,-(sp)
        move.w     #$20,-(sp) ; Super
        trap       #1
        addq.l     #6,sp
        move.l     8(a6),d0
L780:
        move.l     (sp)+,d7
        unlk       a6
        rts


        bss

mds:            ds.l    2
pmd:            ds.l    1
ofdlist:        ds.l    1
poolfix_flag:   ds.w    1
oldresvector:   ds.l    1
oldresvalid:    ds.l    1
