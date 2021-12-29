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
        bsr        find_os_gemdos
        tst.l      d0
        bmi        error_exit
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
        addq.l     #8,(a5)
        move.l     (a5),-(sp)
        move.l     24(a6),d0
        add.l      28(a6),d0
        move.l     d0,-(sp)
        clr.l      -(sp)
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
		bsr.s      find_os_gemdos
		move.l     a2,a1
        move.l     pmd_offset+2(a1),a2
        move.l     a2,pmd
        move.l     a2,mds           /* mds[0] = &pmd.mp_mfl */
        addq.l     #4,a2
        move.l     a2,mds+4         /* mds[1] = &pmd.mp_mal */
        move.l     ofd_offset+2(a1),ofdlist
        move.l     (_trap1vec).w,newgemdos-4
        move.l     #newgemdos,$84.w
        lea        installed_s(pc),a0
        bsr.s      Cconws_a0
        move.l     24(a6),d0
        add.l      28(a6),d0
        add.l      d7,d0
        sub.l      a6,d0
        clr.w      -(a7)
        move.l     d0,-(a7)
        move.w     #$0031,-(a7) ; Ptermres
        trap       #1
        addq.w     #8,a7


error_exit:
        bsr.s      Cconws_a0
        lea        crnl(pc),a0
        bsr.s      Cconws_a0
        pea        $4C0001.l
        trap       #1
        dc.w       $4AFC ; illegal

Cconws_a0:
        move.l     a0,-(a7)
        move.w     #$0009,-(a7) ; Cconws
        trap       #1
        addq.w     #6,a7
        rts

find_os_gemdos:
        movem.l    d1-d1/a1-a1,-(sp)
        moveq      #0,d0
        move.l     (_trap1vec).w,a2
L130:
        cmpi.l     #'XBRA',-12(a2)
        bne.s      L140
        move.l     -4(a2),a2
        bra.s      L130
L140:
        move.l     a2,d1
        and.l      #$FFFFFF,d1
        move.l     (_sysbase).w,a1
        move.l     8(a1),a1
        sub.l      a1,d1
        bmi.s      L15C
        cmp.l      #$20000,d1
        bmi.s      L15E
L15C:
        moveq      #-1,d0
L15E:
        movem.l    (sp)+,d1-d1/a1-a1
        rts

installed_s:
        ascii   "POOL PATCH OF 19-JAN-90 INSTALLED."
        dc.b    13,10
        ascii   "Improved 27-MAR-90 by Claus Brod"
crnl:
        dc.b    13,10,0
already_in_s:
        ascii   "Pool patch already installed."
        dc.b    0
not_needed_s:
        ascii   "Pool patch not needed in this TOS"
        dc.b    0
bad_linkage_s:
        ascii   "Something linked into the GEMDOS trap"
        dc.b    13,10
        ascii   "without following XBRA rules."
        dc.b    13,10,0
strange_TOS_s:
        ascii   "POOLFIX4 doesn"
        dc.b    39
        ascii   "t recognize this TOS."
        dc.b    0
		even

        dc.l $58425241 /* 'XBRA' */
        dc.l $5f4f4f4c /* '_OOL' */
        dc.l 0
newgemdos:
        tst.b      poolfix_flag
        beq.s      L2A2
        bsr.s      all_sub
L2A2:
        move.l     usp,a0
        btst       #5,(sp)
        beq.s      L2B6
        lea        6(sp),a0
        tst        (_longframe).w
        beq.s      L2B6
        addq.w     #2,a0
L2B6:
        move.w     (a0),d0 ;Pterm0 ?
        beq.s      L2CA
        sub.w      #$31,d0 ;Ptermres ?
        beq.s      L2CA
        sub.w      #$18,d0 ;Mfree ?
        beq.s      L2CA
        subq.w     #3,d0 ;Pterm ?
L2CA:
        seq        poolfix_flag
        move.l     newgemdos-4(pc),a0
        jmp        (a0)


all_sub:
        link       a6,#0
        movem.l    d2-d7/a3-a5,-(sp)
        suba.l     a5,a5
        move.l     ofdlist(pc),a0
        move.l     (a0),a4
        clr        d3
        bra.s      L34A

L2F0:
        tst.b      4(a4)
        ble.s      L348
        clr        d4
        clr        d5
        lea        6(a4),a3
        bra.s      L328

L304:
        cmpi.l     #1,12(a3)
        bne.s      L31E
        addq.w     #1,d4
        move.l     a5,d0
        bne.s      L31E
        move.l     a4,a5
        move.w     d5,d6
L31E:
        addq.w     #1,d5
        adda.w     #16,a3
L328:
        cmp        #4,d5
        blt.s      L304
        cmp        #4,d4
        bne.s      L346
        clr.b      4(a4)
        cmp.l      a4,a5
        bne.s      L342
        suba.l     a5,a5
L342:
        bra.s      L348

L346:
        add        d4,d3
L348:
        move.l     (a4),a4
L34A:
        move.l     a4,d0
        bne.s      L2F0
        cmp        #4,d3
        blt        L566
        move.l     a5,a4
        move.w     d6,d7
L35A:
        addq.w     #1,d7
        cmp        #4,d7
        beq.s      L36E
        tst.b      4(a4)
        bgt.s      L372
L36E:
        clr        d7
        move.l     (a4),a4
L372:
        move.l     a4,d0
        beq.s      L392
        tst.b      4(a4)
        ble.s      L35A
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        beq.s      L35A
L392:
        bra        L55A

L396:
        bra.s      L41C

L39A:
        lea        6(a5),a3
        cmpi.l     #1,12(a3)
        bne.s      L422
        cmpi.l     #1,28(a3)
        bne.s      L422
        cmpi.l     #1,44(a3)
        bne.s      L422
        cmpi.l     #1,60(a3)
        bne.s      L422
        clr.b      4(a5)
        moveq      #3,d6
L3D6:
        addq.w     #1,d6
        cmp        #4,d6
        beq.s      L3EA
        tst.b      4(a5)
        bgt.s      L3EE
L3EA:
        clr        d6
        move.l     (a5),a5
L3EE:
        move.l     a5,d0
        beq.s      L40E
        tst.b      4(a5)
        ble.s      L3D6
        move.w     d6,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a5,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        bne.s      L3D6
L40E:
        move.l     a5,d0
        beq        L566

L41C:
        tst        d6
        beq.s      L39A
L422:
        bra.s      L4A4

L426:
        lea        6(a4),a3
        cmpi.l     #1,12(a3)
        beq.s      L4AA
        cmpi.l     #1,28(a3)
        beq.s      L4AA
        cmpi.l     #1,44(a3)
        beq.s      L4AA
        cmpi.l     #1,60(a3)
        beq.s      L4AA
        moveq      #3,d7
L45E:
        addq.w     #1,d7
        cmp        #4,d7
        beq.s      L472
        tst.b      4(a4)
        bgt.s      L476
L472:
        clr        d7
        move.l     (a4),a4
L476:
        move.l     a4,d0
        beq.s      L496
        tst.b      4(a4)
        ble.s      L45E
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        beq.s      L45E
L496:
        move.l     a4,d0
        beq        L566

L4A4:
        tst        d7
        beq.s      L426
L4AA:
        cmp.l      a5,a4
        beq.s      L522
        move.w     d6,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a5,d0
        move.l     d0,(sp)
        addq.l     #6,(sp)
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,-(sp)
        addq.l     #6,(sp)
        bsr        block_sub
        addq.l     #4,sp
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        move.l     #1,18(a0)
L4EA:
        addq.w     #1,d6
        cmp        #4,d6
        beq.s      L4FE
        tst.b      4(a5)
        bgt.s      L502
L4FE:
        clr        d6
        move.l     (a5),a5
L502:
        move.l     a5,d0
        beq.s      L522
        tst.b      4(a5)
        ble.s      L4EA
        move.w     d6,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a5,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        bne.s      L4EA
L522:
        addq.w     #1,d7
        cmp        #4,d7
        beq.s      L536
        tst.b      4(a4)
        bgt.s      L53A
L536:
        clr        d7
        move.l     (a4),a4
L53A:
        move.l     a4,d0
        beq.s      L55A
        tst.b      4(a4)
        ble.s      L522
        move.w     d7,d0
        ext.l      d0
        asl.l      #4,d0
        add.l      a4,d0
        move.l     d0,a0
        cmpi.l     #1,18(a0)
        beq.s      L522
L55A:
        move.l     a5,d0
        beq.s      L566
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
        bra.s      L5AE

L582:
        move.w     d7,a0
        adda.l     a0,a0
        adda.l     a0,a0
        adda.l     #mds,a0
        move.l     (a0),-4(a6)
        move.l     -4(a6),a3
        move.l     (a3),a4
        bra.s      L5A6

L59C:
        cmp.l      a5,a4
        beq.s      L5BC
        move.l     a4,a3
        move.l     (a3),a4
L5A6:
        move.l     a4,d0
        bne.s      L59C
        addq.w     #1,d7
L5AE:
        cmp        #2,d7
        blt.s      L582
        move.w     #1,d0
        bra.s      L5F0

L5BC:
        move.l     pmd(pc),a0
        cmp.l      8(a0),a5
        bne.s      L5D6
        move.l     pmd(pc),a0
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
        moveq      #0,d7
        move.l     #1,-(sp)
        move.w     #$20,-(sp) ; Super
        trap       #1
        tst.l      d0
        bne.s      L62A
        clr.l      2(sp)
        move.w     #$20,(sp) ; Super
        trap       #1
        move.l     d0,d7
L62A:
        addq.l     #6,sp
        move.l     (_p_cookies).w,a0
        move.l     a0,d0
        beq.s      L654
L636:
        move.l     (a0),d0
        cmp.l      d0,d6
        beq.s      L648
        tst.l      d0
        beq.s      L654
        addq.l     #8,a0
        bra.s      L636

L648:
        move.l     a6,d0
        beq.s      L652
        move.l     4(a0),(a6)
L652:
        moveq      #1,d0
L654:
        move.l     d0,d6
        tst.l      d7
        beq.s      L666
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
        moveq      #1,d7
        move.l     d7,-(sp)
        moveq      #0,d7
        move.w     #$20,-(sp) ; Super
        trap       #1
        tst.l      d0
        bne.s      L698
        clr.l      2(sp)
        move.w     #$20,(sp) ; Super
        trap       #1
        move.l     d0,d7
L698:
        addq.l     #6,sp
        move.l     (_p_cookies).w,a0
        move.l     a0,d0
        beq.s      L6D4
        moveq      #0,d0
L6A6:
        addq.l     #1,d0
        tst.l      (a0)
        beq.s      L6B2
        addq.l     #8,a0
        bra.s      L6A6

L6B2:
        cmp.l      4(a0),d0
        beq.s      L732
        move.l     4(a0),12(a0)
        clr.l      8(a0)
        move.l     8(a6),(a0)
        move.l     12(a6),4(a0)
        moveq      #0,d0
        bra        L768

L6D4:
        cmpi.l     #2,20(a6)
        blt.s      L766
        lea        oldresvector(pc),a0
        move.l     (resvector).w,(a0)+
        move.l     (resvalid).w,(a0)
        move.l     #L71C,(resvector).w
        move.l     #$31415926,(resvalid).w
        move.l     16(a6),a0
        move.l     a0,(_p_cookies).w
        move.l     8(a6),(a0)+
        move.l     12(a6),(a0)+
        clr.l      (a0)+
        move.l     20(a6),(a0)
        moveq      #1,d0
        bra.s      L768

L71C:
        clr.l      (_p_cookies).w
        move.l     oldresvalid(pc),(resvalid).w
        move.l     oldresvector(pc),(resvector).w
        jmp        (a6)
L732:
        cmp.l      20(a6),d0
        ble.s      L766
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
        bra.s      L768
L766:
        moveq      #-1,d0
L768:
        tst.l      d7
        beq.s      L780
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

basepage_p:     ds.l    1
mds:            ds.l    2
pmd:            ds.l    1
ofdlist:        ds.l    1
poolfix_flag:   ds.w    1
oldresvector:   ds.l    1
oldresvalid:    ds.l    1
