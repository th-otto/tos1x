/*********************************  allgem.s  ***********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/07/30 16:01:22 $
 * =============================================================================
 *
 *******************************************************************************/

#include "config.h"
#include "vdidefs.h"
#include "asmdefs.h"
#include "tosvars.inc"

#include "lineaequ.inc"


CON		equ	  2
DEV		equ	CON		; source of key press
BIOS		equ	 13
BCONSTAT	equ	  1
BCONIN		equ	  2
SETEXC		equ	  5
TICKCAL		equ	  6
XBIOS		equ	 14
BLITMODE	equ	$40

STAYINDEV equ 1
DEFREZ    equ 2

		text

/*******************************************************************************
 *
 *	GET SHIFT STATE		entry: 		none
 *				exit:		CTL/SHIFT/ALT status in d0
 *				destroys:	nothing
 *
 *******************************************************************************/

/* 306de: 00e06676 */
/* 104de: 00fcb270 */
/* 106de: 00e0b49c */
/* 100de: 00fca4dc */
		xdef	_GSHIFT_S
_GSHIFT_S:	move.b	_shifty,d0	; Get the keyboard state
		andi.w	#$000F,d0	; We only want the low 4 bits

* Reuse a rts for these stubed routines
		xdef	_v_cellarray
_v_cellarray: ds.b 0
		xdef	_v_nop
_v_nop: ds.b 0
		xdef	_vq_cellarray
_vq_cellarray: ds.b 0
		rts

/*******************************************************************************
 *
 *	CLEAR SCREEN		entry: 		none
 *				exit:		none
 *				destroys:	a0/d0
 *
 *******************************************************************************/

/* 306de: 00e06682 */
/* 104de: 00fcb27c */
/* 100de: 00fca4e8 */
		xdef	_v_clrwk
_v_clrwk:
		move.l	_v_bas_ad,a0
		move.w #(32000/4)-1,d0
		moveq #0,d1
v_clrwk1:
		move.l d1,(a0)+
		dbf d0,v_clrwk1
return:
		rts

/*******************************************************************************
 *
 *	INITIALIZE GRAPHICS	entry: 		none
 *				exit:		none
 *				destroys:	see v_clrwk
 *
 *******************************************************************************/

   		xdef	_INIT_G
_INIT_G:	PIXLA(a1)
		move.l	#return,PIXLV(tim_addr,a1)	; Tick points to rts

		move	SR,-(sp)		; Disable interrupts
		ori.w	#$0700,SR

		pea	tick_int		; My timer vector
		move.w	#$100,-(sp)		; 100 is timer vector
		move.w	#5,-(sp)		; exchange exception vector
		trap	#13

		PIXLA(a1)
		addq.l	#8,sp			; clean up stack
		move.l	d0,PIXLV(tim_chain,a1)	; Set up chain before int enabl
		move	(sp)+,SR		; Restore interrupt context

		bsr	mouse_init		; Init the mouse
		bsr	escf			; hide alpha cursor

		bra	_v_clrwk


/*******************************************************************************
 *
 * VDI #118 - vex_timv - Exchange timer interrupt vector
 *
 *   entry: 		new vector in CONTRL[7-8]
 *				exit:		old vector in CONTRL[9-10]
 *				destroys:	a0/a1
 *
 *******************************************************************************/

/* 306de: 00e066e6 */
/* 104de: 00fcb2e0 */
/* 106de: 00e0b50c */
/* 100de: 00fca530 */
   		xdef	_vex_timv
_vex_timv:	PIXLA(a1)
		move.l	PIXLV(CONTRL,a1),a0

		move	SR,-(sp)		; Disable interrupts
		ori.w	#$0700,SR		; THIS IS PARANOID !
		move.l	PIXLV(tim_addr,a1),18(a0)
		move.l	14(a0),PIXLV(tim_addr,a1)
		move	(sp)+,SR

		move.w	#TICKCAL,-(sp)		; Get ms/tick
		trap	#BIOS
		addq.l	#2,sp

		PIXLA(a1)
		move.l	PIXLV(INTOUT,a1),a0
		move.w	d0,(a0)

		rts

/*******************************************************************************/

/*
 * Falcon TOS uses C function,
 * with a device table
 */
		xdef _FindDevice

/*
 * old Version for ST compatible modes only
 */
/* 206de: 00e070b8 */
/* 104de: 00fcb310 */
/* 106de: 00e0b53c */
/* 100de: 00fca560 */
_FindDevice:
		move.w    #$0004,-(a7)
        trap      #14         /* Getrez() */
        addq.l    #2,a7
        move.b    d0,d2
        cmp.b     #2,d2                         /* current res = mono? */
#if BINEXACT
        dc.w 0x6700,FindDev5-*-2                /* branch offset of 128 not optimized */
#else
        beq.s     FindDev5                      /* yes, can't be changed */
#endif
		PIXLA(a2)
        move.l    PIXLV(INTIN,a2),a0
        move.w    (a0),d0
        cmp.w     #STAYINDEV,d0
        bne.s     FindDev1
        tst.b     d2
        beq.s     FindDev2
        bra.s     FindDev4
FindDev1:
        cmp.w     #3,d0                         /* switch to medium res? */
        beq.s     FindDev3                      /* yes */
        tst.b     d2                            /* current res = low? */
        beq.s     FindDev2                      /* yes, no need to change */
/* switch to low resolution */
        clr.w     -(a7)
        move.l    #-1,-(a7)
        move.l    #-1,-(a7)
        move.w    #5,-(a7)                      /* Setscreen(-1, -1, 0) */
        trap      #14
        adda.l    #12,a7
FindDev2:
        pea.l     paltab16
        move.w    #6,-(a7)
        trap      #14                           /* Setpalette */
        addq.l    #6,a7
        moveq.l   #1,d0
        rts
/* switch to medium resolution */
FindDev3:
        cmp.b     #1,d2                         /* current res == medium? */
        beq.s     FindDev4                      /* yes, no need to change */
        move.w    #1,-(a7)
        move.l    #-1,-(a7)
        move.l    #-1,-(a7)
        move.w    #5,-(a7)
        trap      #14                           /* Setscreen(-1, -1, 1) */
        adda.l    #12,a7
FindDev4:
        pea.l     paltab4
        move.w    #6,-(a7)
        trap      #14                           /* Setpalette */
        addq.l    #6,a7
        moveq.l   #2,d0
        rts
FindDev5:
        pea.l     paltab4
        move.w    #6,-(a7)
        trap      #14                           /* Setpalette */
        addq.l    #6,a7
        moveq.l   #3,d0
        rts

#if TOSVERSION >= 0x106
paltab4:  dc.w $0fff
          dc.w $0f00
          dc.w $00f0
          dc.w $0000
paltab16: dc.w $0fff
          dc.w $0f00
          dc.w $00f0
          dc.w $0ff0
          dc.w $000f
          dc.w $0f0f
          dc.w $00ff
          dc.w $0555
          dc.w $0333
          dc.w $0f33
          dc.w $03f3
          dc.w $0ff3
          dc.w $033f
          dc.w $0f3f
          dc.w $03ff
          dc.w $0000
#else
paltab4:  dc.w $0777
          dc.w $0700
          dc.w $0070
          dc.w $0000
paltab16: dc.w $0777
          dc.w $0700
          dc.w $0070
          dc.w $0770
          dc.w $0007
          dc.w $0707
          dc.w $0077
          dc.w $0555
          dc.w $0333
          dc.w $0733
          dc.w $0373
          dc.w $0773
          dc.w $0337
          dc.w $0737
          dc.w $0377
          dc.w $0000
#endif

/*******************************************************************************
 *
 *	Timer interrupt routine	entry: 		none
 *				exit:		none
 *				destroys:	none
 *
 *******************************************************************************/

/* 306de: 00e067ee */
/* 104de: 00fcb3c6 */
/* 106de: 00e0b5f2 */
/* 100de: 00fca62a */
tick_int:
		movem.l	d0-d7/a0-a6,-(sp)
		PIXLA(a1)
		move.l	PIXLV(tim_addr,a1),a0		; Invoke user routine
		jsr	(a0)
		movem.l	(sp)+,d0-d7/a0-a6
		move.l	PIXLV(tim_chain,a1),-(sp)	; store chained routine
		rts				; jump to next routine in chain


/*******************************************************************************
 *
 *	DEINITIALIZE GRAPHICS	entry: 		none
 *				exit:		none
 *				destroys:	a1 + see dinit_mouse, v_clrwk,
 *						esce
 *
 *******************************************************************************/

/* 306de: 00e06806 */
/* 104de: 00fcb3de */
/* 100de: 00fca642 */
   		xdef	_DINIT_G
_DINIT_G:	PIXLA(a1)
		move.l	PIXLV(tim_chain,a1),-(sp)	; reset timer vector
		move.w	#$100,-(sp)
		move.w	#SETEXC,-(sp)
		trap	#BIOS
		addq.l	#8,sp

		bsr	dinit_mouse
		bsr	_v_clrwk
		bsr	esce			; Show the alpha cursor. return
		rts


/*******************************************************************************
 *
 *
 *	GCHC_KEY	get choice for choice input: NOT IMPLEMENTED
 *
 *			exit:	d0:   0	 nothing happened
 *				      1	 choice value
 *				      2	 button pressed
 *
 *				TERM_CH	 16 bit char info
 *
 *******************************************************************************/

/* 100de: 00fca662 */
   		xdef	_GCHC_KEY
_GCHC_KEY:	PIXLA(a1)
		moveq.l	#1,d0			; indicate choice value
		move.w	d0,PIXLV(TERM_CH,a1)		; return dummy choice per 8086
		rts


/*******************************************************************************
 *
 *	GCHR_KEY	get char for string input
 *			entry: none
 *			exit:  d0=1	key pressed
 *			       d0=0	nothing happened
 *
 *			TERM_CH		16 bit char info
 *
 *******************************************************************************/

/* 306de: 00e0687e */
/* 104de: 00fcb456 */
/* 100de: 00fca66c */
   		xdef	_GCHR_KEY
_GCHR_KEY:	move.w	#DEV,-(sp)	; see if a character present
		move.w	#BCONSTAT,-(sp)
		trap	#BIOS

		tst.w	d0		; d0=0 => no character
		beq	no_char

		move.w	#BCONIN,(sp)	; get the character
		trap	#BIOS
		addq.l	#4,sp

		move.l	d0,d1
		swap	d1
		lsl.w	#8,d1		; d0<07:00> <- ascii code
		or.w	d1,d0		; d0<15:08> <- scan code

		PIXLA(a1)
		move.w	d0,PIXLV(TERM_CH,a1)	; store character
		moveq.l	#1,d0		; indicate character present
		rts
no_char:
		addq.l	#4,sp
		moveq.l	#0,d0		; indicate no character present
		rts

/*******************************************************************************
 *
 *  INITIALIZE MOUSE
 *
 *  on entry:
 *
 *     GCURXY	initial XY position of mouse cursor
 *
 *******************************************************************************/

/* 306de: 00e068ac */
/* 104de: 00fcb484 */
/* 106de: 00e0b6b0 */
/* 100de: 00fca69a */
mouse_init:
		PIXLA(a1)
		lea	user_init,a0		; button and motion vectors
		move.l	a0,PIXLV(user_but,a1)		; default to no action (rts)
		move.l	a0,PIXLV(user_mot,a1)
		move.l	#_MOV_CUR,PIXLV(user_cur,a1)	; set up link to vblank display

* Initialize the default mouse form (presently the arrow)

		move.l	PIXLV(INTIN,a1),-(sp)		; Save the intin pointer and
		move.l	#arrow_cdb,PIXLV(INTIN,a1)		; make it point to the arrow
		bsr	_vsc_form		; a1 gets clobbered here
		PIXLA(a1)

		move.l	(sp)+,PIXLV(INTIN,a1)	; Restore INTIN pointer

* initialize mouse/draw status and semaphores

		moveq.l	#0,d0
		move.w	d0,PIXLV(MOUSE_BT,a1)	; clear mouse button state
		move.b	d0,PIXLV(cur_ms_stat,a1)	; clear current mouse status
		move.b	d0,PIXLV(mouse_flag,a1)	; mouse_cdb is unlocked
*		move.b	#1,PIXLV(HIDE_CNT,a1)	; don't display cursor form yet

* Initialize communication packet between mouse interrupt service routine
* and vblank cursor display routine. Insert vblank draw routine into front
* of vblank queue.

		lea	PIXLV(xydraw,a1),a0		; init the draw parameter block

		move.w	d0,(a0)+	; to the initial position
		move.w	d0,(a0)+
		move.b	d0,(a0)			; mark data invalid for update

		move.l	_vblqueue,a0		; insert the display routine
		move.l	#vb_draw,(a0)		; at the head of the queue

* Activate mouse interrupt processing

		pea	mouse_rel	; mouse packet interrupt handler
		pea	rel_pblock	; mouse configuration parameter block
		move.w	#1,-(sp)	; enable mouse, in relative mode
		clr.w	-(sp)		; Initmouse()
		trap	#XBIOS
		adda.l #12,sp

user_init:	rts



/*******************************************************************************
 *
 *	DEINITIALIZE MOUSE	entry: 		none
 *				exit:		none
 *				destroys:	a0/d0
 *
 *******************************************************************************/

/* 306de: 00e06932 */
/* 104de: 00fcb50a */
/* 100de: 00fca718 */
dinit_mouse:	move.l	_vblqueue,a0	; remove draw routine from vblank queue
		clr.l	(a0)

		move.l	#-1,-(sp)	; discontinue mouse processing
		move.l	#-1,-(sp)
		clr.l	-(sp)		; type=0: disable mouse
		trap	#XBIOS		; INITMOUSE
		adda.l #12,sp

		rts


/*******************************************************************************
 *
 * title:	_GLOC_KEY
 *
 * purpose:	Note which buttons have had a state change and whether
 *		the mouse has been moved since the previous envocation of
 *		this routine. If the button states havn't changed, check
 *		for a key press from the console device.
 *
 * output:
 *
 *	d0	0	- nothing
 *
 *		1	- button or key pressed
 *
 *  			   TERM_CH = 16 bit char info
 *
 *		2 	- new coordinates
 *
 *			   X1 = new X
 *			   Y1 = new Y
 *
 *		3	- button or key pressed and new coordinates
 *
 *			   TERM_CH = 16 bit char info
 *			   X1 = new X
 *			   Y1 = new Y
 *
 * 	NOTE:	THIS ROUTINE REPORTS THE LAST CHANGE IN BUTTON STATE
 *		RATHER THAN REPORTING THE BUTTON STATE ITSELF. THE
 *		BUTTON STATE CHANGE FLAGS AND MOTION FLAG ARE CLEARED
 *		ON EXIT SO THAT SUBSEQUENT CALLS TO THE ROUTINE WILL NOT
 *		YIELD DUPLICATE REPORTS OF THE SAME EVENT. WHEN USING THIS
 *		ROUTINE TO POLL THE MOUSE FOR A PARTICULAR CONDITION, THE
 *		FIRST CALL MAY NOT RETURN CURRENT BUTTON CHANGE STATE DATA
 *		BUT IT WILL INITIALIZE THE SYSTEM FOR SUBSEQUENT CALLS.
 *
 *******************************************************************************/

/* 306de: 00e06830 */
/* 104de: 00fcb408 */
/* 100de: 00fca738 */
		xdef	_GLOC_KEY
_GLOC_KEY:	PIXLA(a1)

		move.b	LV(cur_ms_stat,a1),d0
		move.b	d0,d1		/* save state */
		andi.b	#$c0,d0	/* mask out all but button status bits */
		beq	key_stat	/* nothing go check key stat */
		move.b     d1,d0
		btst       #6,d0
		beq clr_bt1
		move.w	#$20,LV(TERM_CH,a1)	/* send terminator code for left key */
		bra clr_bt_stat
clr_bt1:
		move.w	#$21,LV(TERM_CH,a1)	/* send terminator code for left key */
clr_bt_stat:
		andi.b	#$23,d0		/* clear mouse button status */
		move.b	d0,LV(cur_ms_stat,a1)	/* store cleared state */
		move.w	#1,d0		/* set button pressed flag */
		rts

key_stat:
		move.w	#2,-(sp)	/* see if a character present at aux port */
		move.w	#1,-(sp)
		trap	#13

		tst.w	d0
		bne	key_cont	/* no char */
		addq.l	#4,sp
		bra mov_stat
key_cont:
		move.w	#2,(sp)	/* from auxin */
		trap	#13
		addq.l	#4,sp
		move.l	d0,d1
		swap	d1
		lsl.w	#8,d1
		or.w	d1,d0
		move.w	d0,LV(TERM_CH,a1)	/* store char */
		move.l	#1,d0
		rts
mov_stat:
		bclr.l	#5,d1		/* test and clear mouse motion flag  */
		beq	no_chg

		move.b	d1,LV(cur_ms_stat,a1)	/* save mouse stat */
		move.w	LV(GCURX,a1),LV(X1,a1)	/* set _X1 = _GCURX */
		move.w	LV(GCURY,a1),LV(Y1,a1)	/* set _Y1 = _GCURY */
		move.l	#2,d0
		rts

no_chg:		move.l	#0,d0
		rts


/*******************************************************************************
 *			    escape initialization
 *******************************************************************************/

/* 306de: 00e0694a */
/* 206de: 00e072ca */
/* 104de: 00fcb522 */
/* 106de: 00e0b74e */
/* 100de: 00fca7c4 */
		xdef	esc_init
		xdef	_esc_init
esc_init:
_esc_init:
        move.b    _sshiftmod,d0
        and.w     #3,d0
        cmp.w     #3,d0
        bne.s     esc0
        move.w    #2,d0
esc0:
		move.w    d0,-(a7)
#if BINEXACT
        dc.w 0x6100,rezinit-*-2             /* branch offset of 126 not optimized */
#else
        bsr       rezinit
#endif
        move.w    (a7)+,d0
        lea.l     _f8x8,a0
        cmp.w     #2,d0
        bne.s     esc1
        lea.l     _f8x16,a0
esc1:
        bsr       gl_f_init
        move.w    #-1,LV(v_col_fg,a1)
        moveq     #0,d0
        move.w    d0,PIXLV(v_col_bg,a1)		; background color is all zeroes
        move.w    d0,PIXLV(v_curcx,a1)
        move.w    d0,PIXLV(v_curcy,a1)
        move.w    d0,PIXLV(v_cur_off,a1)
        move.l    _v_bas_ad,a0
        move.l    a0,PIXLV(v_cur_ad,a1)	; home cursor.
        move.b    #1,PIXLV(v_stat_0,a1)		; flash, nowrap, normal video.
        move.b    #30,PIXLV(v_cur_tim,a1)	;.5 sec blink rate (@60 Hz vbl)
        move.b    #30,PIXLV(vct_init,a1)		;.5 sec blink rate (@60 Hz vbl)
        move.w    #1,PIXLV(disab_cnt,a1)	; cursor disabled 1 level deep.
        move.w    #(32000/4)-1,d1
esc2:
        move.l     d0,(a0)+
        dbf        d1,esc2
        move.l    #normal_ascii,con_state
        rts

/* 306de: 00e069f4 */
/* 206de: 00e07354 */
/* 104de: 00fcb5ac */
/* 100de: 00fca85a */
		xdef resetdev
resetdev:
#if BLITTER_SUPPORT
        move.l    #_STSoftList,PIXLV(LA_SOFTROUTINES,a1)
        move.l    #_STHardList,PIXLV(LA_HARDROUTINES,a1)
        jmp       _SETBLT
#endif

rezinit:
        moveq.l   #0,d1
        move.b    reztab(pc,d0.w),d1
        move.w    d1,PIXLV(v_planes,a1)
        move.b    rezltab(pc,d0.w),d1
        move.w    d1,PIXLV(v_lin_wr,a1)
        move.w    d1,PIXLV(bytes_lin,a1)
        asl.w     #1,d0
        move.w    rezhtab(pc,d0.w),d1
        move.w    d1,PIXLV(v_vt_rez,a1)
        move.w    rezwtab(pc,d0.w),d1
        move.w    d1,PIXLV(v_hz_rez,a1)
        rts

reztab:
		dc.b 4,2,1
rezltab:
		dc.b 160,160,80
rezhtab:
		dc.w 200,200,400
rezwtab:
		dc.w 320,640,640
