/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:28:16 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:28:16  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:30:27  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.2  88/11/01  11:25:49  mui
 * Fix the err_trap to save the PD's stack pointer
 * 
 * Revision 1.1  88/06/02  12:35:36  lozben
 * Initial revision
 * 
 *************************************************************************
 * 
 *	JBIND.S		 11/27/84 - 05/03/85  LKW
 *			 04/02/85 - 05/23/85  DMM
 *	Fix at the dos_exec for dos_ax return code 08/21/85 Derek Mui
 *	Clean up 	 02/03/88		D.Mui
 *	Change at gosuper, super now inlined	4/11/88
 *	Use MAC to assemble	6/28/90		D.Mui
 *	Add _crt_error semaphore to dispatcher	900731 D.Mui
 * assemble with MAS 900801 kbad (changed 2 clr.w a0 to sub.w a0,a0)
 *	Change in critical error to ignore error -15 3/1/91 D.Mui
 *	Install a desktop critical error handler	4/22/91	D.Mui
 */

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"


/* --Crystal function numbers. */

CRYSTAL1 equ    200                     /* Call Crystal function. */
CRYSTAL2 equ    201                     /* Call dispatch. */
TRP2VEC  equ    $88
/*
 * --DOS.C error flag conventions.
 */
ERROR   equ     1
NOERR   equ     0


        bss
        even

        xdef    _crit_err
        comm _crit_err,4
#if AESVERSION >= 0x140
        xdef    savestk
        comm savestk,4
#endif
        xdef    _SAV2TRP
        comm _SAV2TRP,4
        xdef    _savsup
        comm _savsup,4
        xdef    drawsp
        comm drawsp,4
        xdef    _aesldivr
        comm _aesldivr,4
        xdef    errsave
        comm errsave,4

#if TOSVERSION >= 0x400
ERRSTKSIZE equ 1604
#else
ERRSTKSIZE equ 1028
#endif

        text

/* 306de: 00e25570 */
/* 104de: 00fdd1e2 */
/* 106de: 00e1e7da */
        xdef    _givecpm
_givecpm:
        move.l  _SAV2TRP,ABSW2(TRP2VEC)    /* Restore Trap 2 vector. */
        rts

/*
 * --Grab trap 2 so we can do our own system reset if the program wants to.
 */
/* 306de: 00e2557a */
/* 104de: 00fdd1ee */
/* 106de: 00e1e7e6 */
        xdef    _takecpm
_takecpm:
        move.l  ABSW2(TRP2VEC),_SAV2TRP /* Save current Trap 2 vector. */
        move.l  #_grptrp,ABSW2(TRP2VEC) /* Replace vector with ours. */
        rts
/*
 *      retake gem trap and error trap after execing a program
 */
/* 306de: 00e2558c */
/* 106de: 00e1e7fc */
        xdef    _retake
_retake:
        move.l  #_grptrp,ABSW2(TRP2VEC) /* Replace vector with ours. */
        move.l  #_err_trap,d0           /* set ours */

/*      bra     call_err                 FALL TRHU */



call_err:
        move.l  d0,-(a7)
        move.w  #$101,-(a7)
        move.w  #5,-(a7)
        trap    #13
        addq    #8,a7
        rts

/* 306de: 00e255aa */
/* 104de: 00fdd224 */
/* 106de: 00e1e81c */
        xdef    _giveerr
_giveerr:
        move.l  _crit_err,d0
        bra     call_err

/* 306de: 00e255b2 */
/* 104de: 00fdd22c */
/* 106de: 00e1e824 */
        xdef    _takeerr
_takeerr:
        move.l  #-1,d0                  /* get the old one */
        bsr     call_err
        move.l  d0,_crit_err
        move.l  #_err_trap,d0           /* set ours */
        bra     call_err
        
#if AESVERSION >= 0x200

        bss
        xdef    _dk_err
        comm _dk_err,4
		text
		
        xdef    _deskerr
_deskerr:
        move.l  #-1,d0                  /* get the old one */
        bsr     call_err
        move.l  d0,_dk_err
        move.l  #_dk_trap,d0            /* set ours */
        bra     call_err

        xdef    _desknoerr
_desknoerr:
        move.l  _dk_err,d0
        bra     call_err

_dk_trap:
        cmp.w   #-17,d0                 /* if swap disk, it's OK */
        bne     d_out
        jmp     _err_trap               /* don't return to here */
d_out:  
        rts
#endif
        

/*
 *      ASSUME CALLING PROCESS HAS ENOUGH STACK
 */
/* 306de: 00e255ec */
/* 104de: 00fdd23e */
/* 106de: 00e1e836 */
        xdef  _err_trap
_err_trap:
#if AESVERSION >= 0x140
#if AESVERSION >= 0x200
        move.w  #1,_crt_error           /* set flag for dispatcher */
#endif
        move.l  _rlr,a0                 /* get the current rlr */
        move.l  8(a0),a0                /* get the UDA */
        move.l  62(a0),savestk          /* save the stack (u_spsuper) */
#endif

        move.w  4(a7),d0                /* error */
#if AESVERSION >= 0x200
        cmp.w   #-15,d0
        beq     er_1                    /* ignore */
#endif

        move.w  6(a7),d1                /* drive */
        jsr     cli
        move.l  a7,errsave              /* save stack */
        move.l  #errstk+ERRSTKSIZE-4,a7         /* switch stack */
        jsr     sti
        movem.l d3-d7/a3-a6,-(a7)
        move.l  #_err_tbl,a1
        move.w  d0,-(a7)                /* save error */
        bne     err1                    /* not 0 */
        move.w  #0,a0
        bra     eok
err1:
        not.w   d0                      /* one's comp */
        move.w  d0,a0
        cmp.w   #17,d0
        ble     eok
        move.w  #0,a0
eok:
        move.b  0(a0,a1.l),d0
        move.w  d1,-(a7)                /* drive,0 rel */
        move.w  d0,-(a7)                /* alert number */
        /* jsr     _eralert */
        dc.w 0x4eb9
        dc.l _eralert
        addq.l  #4,a7
        move.w  (a7)+,d1                /* get back error num */
        ext.l   d1
        cmp.w   #0,d0
        beq     eabrt                   /* abort */
        move.l  #$10000,d1              /* retry */
eabrt:
        move.l  d1,d0                   /* error num or code */
        movem.l (a7)+,d3-d7/a3-a6
        move.l  errsave,a7
er_1:
#if AESVERSION >= 0x140 /* BUG: missing in older versions */
        move.l  _rlr,a0                 /* get the current rlr */
        move.l  8(a0),a0                /* get the UDA */
        move.l  savestk,62(a0)          /* restore the stack */
#endif
#if AESVERSION >= 0x200
        clr.w   _crt_error              /* so dispatcher knows we're done */
#endif
        rts                             /* off we go */
        

/*
 *
 *      EXEC a program
 *      dos_exec(pspec, segenv, pcmdln)
 *              LONG    pspec;
 *              WORD    segenv;
 *              LONG    pcmdln;
 *
 * tho: really belongs into jdos.S
 *
 *      set DOS_ERR 
 */
/* 306de: 00e2568e */
/* 104de: 00fdd2cc */
/* 106de: 00e1e8c4 */
        xdef    _dos_exec
_dos_exec:
        jsr     cli
        move.l  _rlr,a0
        move.l  8(a0),a0                /* get uda (pd->uda) */
        move.l  62(a0),_savsup          /* save uda->supstk */
        move.l  a7,a1                   /* get current a7 */
#if AESVERSION >= 0x200
        suba.w  #128,a1                 /* give up some space */
#else
        suba.l  #64,a1                  /* give up some space */
#endif
        move.l  a1,62(a0)               /* make uda->supstk below GEM's ssp */
        jsr     sti

        move.l  a7,a1
        move.l  #0,-(a7)                /*  NULLPTR */
        move.l  10(a1),-(a7)            /*  pcmdln */
        move.l  4(a1),-(a7)             /*  pspec */
        move.w  8(a1),-(a7)             /*  segenv       (3) */
        move.w  #$4B,-(a7)              /*  command */
        trap    #1
#if (AESVERSION >= 0x200) | !BINEXACT
        adda.w  #16,a7
#else
        adda.l  #16,a7
#endif

        jsr     cli
        move.l  _rlr,a0
        move.l  8(a0),a0
        move.l  _savsup,62(a0)          /* restore uda->supstk */
        jsr     sti
        move.w  #0,_DOS_ERR
        cmp.w   #0,d0
        beq     exok
        move.w  #1,_DOS_ERR             /* set error condition */
        move.w  d0,_DOS_AX              /* error code changed */
exok:
        rts

/*
 *
 * ========================================================
 * ==                                                    
 * ==    long multiply routine without floating point    ==
 * ==  call with:                                        ==
 * ==            two long values on stack                ==
 * ==  returns:                                          ==
 * ==            long value in d0                        ==
 * ==                                                    ==
 * == warning:  no overflow checking or indication!!!!   ==
 * ==                                                    
 * ========================================================
 *
 */
#ifndef __GNUC__
        xdef    lmul
        xdef    _lmul
lmul:
_lmul:
        link    a6,#-4
        clr.w   d2
        tst.l   8(a6)           /*is first arg negative? */
        bge     L2
        neg.l   8(a6)           /*yes, negate it */
        addq.w  #1,d2           /*increment sign flag */
L2:
        tst.l   12(a6)          /*is second arg negative? */
        bge     L3
        neg.l   12(a6)          /*yes, make it positive */
        addq.w  #1,d2           /*increment sign flag */
L3:
        move.w  10(a6),d0       /*arg1.loword */
        mulu.w  14(a6),d0       /*arg2.loword */
        move.l  d0,-4(a6)       /*save in temp */
        move.w  8(a6),d0        /*arg1.hiword */
        mulu.w  14(a6),d0       /*arg2.loword */
        move.w  12(a6),d1       /*arg2.hiword */
        mulu.w  10(a6),d1       /*arg1.loword */
        add.w   d1,d0           /*form the sum of 2 lo-hi products */
        add.w   -4(a6),d0       /*add to temp hiword */
        move.w  d0,-4(a6)       /*store back in temp hiword */
        move.l  -4(a6),d0       /*long results */
        btst    #0,d2           /*test sign flag */
        beq     L4
        neg.l   d0              /*complement the results */
L4:
        unlk    a6
        rts
/*
 *
 * ========================================================
 * ==                                                    ==
 * ==                    Long Divide                     ==
 * ==                                                    ==
 * ========================================================
 */
        xdef    ldiv
        xdef    _ldiv
ldiv:
_ldiv:
        link    a6,#-2
        movem.l d2-d7,-(sp)
        clr.w   d3
        clr.l   d5
        move.l  8(a6),d7
        move.l  12(a6),d6
        bne     La2
        move.l  #$80000000,_aesldivr
        move.l  #$80000000,d0
        divs.w  #0,d0                   /* div by zero trap */
        bra.w   La1
La2:
        bge     La3
        neg.l   d6
        addq.w  #1,d3
La3:
        tst.l   d7
        bge     La4
        neg.l   d7
        addq.w  #1,d3
La4:
        cmp.l   d7,d6
        bgt     La6
        bne     La7
        moveq.l #1,d5
        clr.l   d7
        bra     La6
La7:
        cmp.l   #$10000,d7
        bge     La9
        divu.w  d6,d7
        move.w  d7,d5
        swap.w  d7
        ext.l   d7
        bra     La6
La9:
        moveq.l #1,d4
La12:
        cmp.l   d6,d7
        bcs     La11
        asl.l   #1,d6
        asl.l   #1,d4
        bra     La12
La11:
        tst.l   d4
        beq     La6
        cmp.l   d6,d7
        bcs     La15
        or.l    d4,d5
        sub.l   d6,d7
La15:
        lsr.l   #1,d4
        lsr.l   #1,d6
        bra     La11
La6:
        cmp     #1,d3
        bne     La16
        neg.l   d7
        move.l  d7,_aesldivr
        move.l  d5,d0
        neg.l   d0
        bra     La1
La16:
        move.l  d7,_aesldivr
        move.l  d5,d0
La1:
        tst.l   (sp)+
        movem.l (sp)+,d3-d7
        unlk    a6
        rts
#endif

/*
 *
 * ****************************************
 *       Trap 2 interrupt handler
 * ****************************************
 *
 * This handler is looking for the BDOS system reset function
 * so that a system reset is not done, rather a return to the 
 * calling program can be done.
 */
/* 306de: 00e257f8 */
/* 104de: 00fdd43c */
/* 106de: 00e1ea34 */
_grptrp:
        cmpi.w   #0,d0                  /* Is function number system reset ? */
        beq     _back

        cmpi.w  #CRYSTAL1,d0            /* Trying to get to Crystal? */
        beq     _gosuper
        cmpi.w  #CRYSTAL2,d0            /* Trying to just do a dispatch? */
        beq     _gosuper
/*
 * Not a system reset or Crystal call, so go to orginal interrupt.
 */
        move.l  _SAV2TRP,-(sp)
        rts


**********************************************
* Return here when loaded program is finished.
**********************************************

        xdef    _back
_back:  move.w  #0,-(sp)
        move.w  #$4c,-(sp)
        trap    #1
/*
 *
 * *********************************************
 *              Call Crystal
 * *********************************************
 */
_gosuper:

        jsr     cli                     /* interrupts off */

        move.l  usp,a0
        movem.l d1-d7/a0-a6,-(a0)       /* save regs of caller on users stack */
        move.l  a0,usp
        movea.l _rlr,a6                 /* rlr is a pointer to pd structure. */
        movea.l 8(a6),a6                /* get address of uda structure. */

/* Set parameters in uda structure */

        move.w  #1,(a6)                 /* u_insuper flag. */
        move.l  a0,66(a6)               /* save current user stack pointer to u_spuser */
        move.l  a7,70(a6)               /* save current super stack ptr */
        movea.l 62(a6),a7               /* get super stack from uda.u_spsuper */

        jsr     sti                     /* interrupts on */
/*
 * --Set up to call super() in xif.c
 *
 *      move.l  d1,-(a7)                ; Address of Crystal parameter block.
 *      clr.w   -(a7)                   ; Unused parameter.
 *      move.w  d0,-(a7)                ; Crystal function number.
 *
 * --Go to super().
 *
 *      move.l  #_super,a0
 *      jsr     (a0)                    ; super expects jsr
 *
 *      Supervisor entry point.  Stack frame must be exactly like
 *      this if supret is to work.
 *
 *      VOID
 *      d0,          d1         
 *super(cx, ifunc, pcrys_blk)
 *      WORD            cx, ifunc;
 *      LONG            pcrys_blk;
 *{
 *      if( cx == 200 )
 *        xif(pcrys_blk);
 *
 *        dsptch();
 *
 *      supret(0);
 *}
 */
#if AESVERSION >= 0x140
        cmp.w   #CRYSTAL1,d0
        bne     super1             /* if CRYSTAL2, fall into dsptch (same as appl_yield() for PC-GEM) */
        move.l  d1,-(sp)
        jsr     xif
        addq.l  #4,sp
super1:
        jsr     dsptch
        clr.w   d0      
#else
		move.l  d1,-(a7)
		move.w  #0,-(a7)
		move.w  d0,-(a7)
		move.l  #_super,a0
		jsr     (a0)
/*
 *
 * *********************************************
 *      Return from Crystal call 
 * *********************************************
 */
        xdef    _supret
_supret:
        move.w  4(a7),d0                /* Get return passed from super(). */
#endif

        jsr     cli
#if AESVERSION < 0x140
		/* restore stack: */
		/* - 8 bytes arguments pushed above */
		/* - 4 bytes pc from jsr super */
		/* - 8 bytes from LINK in super */
		/* - 4 bytes pc from jsr supret */
        add.l   #24,a7
#endif
        movea.l _rlr,a0
        movea.l 8(a0),a0                /* Get address of UDA. */
        clr.w   (a0)                    /* clear u_insuper flag. */
        move.l  a7,62(a0)               /* reset supers stack */
        movea.l 70(a0),a7               /* restore caller's super stack. */
        move.l  66(a0),a0               /* restore caller's user stack. */
        movem.l (a0)+,d1-d7/a0-a6       /* restore user's regs */
        move.l  a0,usp

        jsr     sti
        rte


/*
 * ==========================================
 *
 *      Call dr_code with its own stack
 *
 * ==========================================
 */
#if AESVERSION < 0x200
/* 104de: 00fdd4ce */
        xdef    _far_draw
_far_draw:
        move.l  4(a7),d0                /* get addr of pb */
        move.l  a7,drawsp
        movea.l _drawstk,a7             /* allocated by deskglob */
        move.l  d0,-(a7)                /* pass addr of pb to dr_code */
        jsr     _dr_code
        movea.l drawsp,a7
        rts
        bss
        xdef _drawaddr
        comm _drawaddr,4
        xdef drawsp
        comm drawsp,4
#endif


        data
        even
	xdef _err_tbl
_err_tbl:
		dc.b 4 /* -1 (ERROR) -> ALRT04CRT (Your output device is not receiving data) */
		dc.b 1 /* -2 (EDRVNR) -> ALRT01CRT (drive is not responding) */
		dc.b 1 /* -3 (EUNCMD) -> ALRT01CRT (drive is not responding) */
		dc.b 2 /* -4 (E_CRC) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 1 /* -5 (EBADRQ) -> ALRT01CRT (drive is not responding) */
		dc.b 1 /* -6 (E_SEEK) -> ALRT01CRT (drive is not responding) */
		dc.b 2 /* -7 (EMEDIA) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 2 /* -8 (ESECNF) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 4 /* -9 (EPAPER) -> ALRT04CRT (Your output device is not receiving data) */
		dc.b 2 /* -10 (EWRITF) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 2 /* -11 (EREADF) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 2 /* -12 (EGENRL) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 0 /* -13 (EWRPRO) -> ALRT00CRT (disk is write-protected) */
		dc.b 3 /* -14 (E_CHNG) -> ALRT03CRT (cannot read data on the disk) */
		dc.b 4 /* -15 (EUNDEV) -> ALRT04CRT (Your output device is not receiving data) */
		dc.b 2 /* -16 (EBADSF) -> ALRT02CRT (Data on the disk may be damaged) */
		dc.b 6 /* -17 (EOTHER) -> ALRTDSWAP (Please insert disk B into drive A) */

        bss
        even

        xdef errstk
        comm errstk,ERRSTKSIZE
