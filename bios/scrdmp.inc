		text
/*
 * XBIOS #20 - Scrdmp - Dump screen to printer.
 */
/* 306de: 00e01450 */
/* 206de: 00e0130c */
/* 104de: 00fc0cfa */
        xdef _scrdmp
_scrdmp:
        movea.l   _scr_dmp,a0
        jsr       (a0)
        move.w    #-1,_dumpflg
        rts

/*
 * default function for system variable scr_dmp/dump_vec
 */
/* 306de: 00e01462 */
/* 206de: 00e0131e */
/* 104de: 00fc0d0c */
	xdef _bscr_dump
_bscr_dump:
        SETBASEREG
	move.l    ABSW(_v_bas_ad),ABSW(_pbdef)      /* pbdef.pb_pb_scrptr */
        clr.w     ABSW(_pbdef+4)                  /* pbdef.pb_offset */
        clr.w     d0
        move.b    ABSW(_sshiftmod),d0
        move.w    d0,ABSW(_pbdef+14)              /* pbdef.pb_screz */
        add.w     d0,d0
        lea.l     pbdeftab(pc),a0
        move.w    0(a0,d0.w),ABSW(_pbdef+6)       /* pbdef.pb_width */
        move.w    6(a0,d0.w),ABSW(_pbdef+8)       /* pbdef.pb_height */
        clr.w     ABSW(_pbdef+10)                 /* pbdef.pb_left */
        clr.w     ABSW(_pbdef+12)                 /* pbdef.pb_right */
#if (TOSVERSION < 0x200) & BINEXACT
        move.l    #$00FF8240,ABSW(_pbdef+18)        /* pbdef.pb_colptr */
#else
        move.l    #palette,ABSW(_pbdef+18)        /* pbdef.pb_colptr */
#endif
        clr.w     ABSW(_pbdef+26)                 /* pbdef.pb_mask; BUG: pb_mask is long (pointer) */
/* draft or final mode */
        move.w    ABSW(_prtconfig),d1
        lsr.w     #3,d1
        and.w     #$0001,d1
        move.w    d1,ABSW(_pbdef+16)              /* pbdef.pb_prrez */
/* printer or rs232 port */
        move.w    ABSW(_prtconfig),d1
        move.w    d1,d0
        lsr.w     #4,d0
        and.w     #$0001,d0
        move.w    d0,ABSW(_pbdef+24)              /* pbdef.pb_prport */
/* select printer flavor */
        and.w     #$0007,d1
        move.b    pbprtype(pc,d1.w),d0
        move.w    d0,(_pbdef+22)                /* pbdef.pb_prtype */
/* do it */
        pea.l     ABSW(_pbdef)
        move.w    #$0001,ABSW(_dumpflg)
        bsr       _prtblk
        move.w    #-1,_dumpflg
        addq.w    #4,a7
        rts

/* ---- screen resolution table (pixel) for printScreen */
/* BUG: bogus screen resolution table which is too short */
pbdeftab:
        dc.w 320,640,640
        dc.w 200,200,400
/* --- printer flavors (based on low 3 bits of pconfig) */
pbprtype:                            dc.b      0,2,1,-1,3,-1,-1,-1


