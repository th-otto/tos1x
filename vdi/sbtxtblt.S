*******************************  sbtxtblt.s  **********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/01/29 16:37:07 $
* =============================================================================
*
* Revision 3.2  91/01/29  16:37:07  lozben
* Inserted the line '.include "lineaequ.s"'.
*
* Revision 3.1  91/01/29  16:05:46  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:17:53  lozben
* New generation VDI
*
* Revision 2.5  90/03/06  15:06:02  lozben
* Changed "move.l #$FF,dx" to "moveq.l #-1,dx" at one time it was
* "moveq.l #$FF,dx".
*
* Revision 2.4  90/02/16  12:26:46  lozben
* Fixed some of the code so that it can be assembled with mas.
*
* Revision 2.3  90/01/24  15:45:55  lozben
* Beautified the code to make it more readable.
*
* Revision 2.2  89/06/30  15:17:19  lozben
* Adjusted "nxtword" table (offset to next word in the same plane) so tha
* it also contains the 8 plane case.
*
* Revision 2.1  89/02/21  17:27:13  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"

/* v_planes == 0; stupid as68 does not optimize it */
#define V_PLANES 0

*    conditional assembly switches..
*
*    should all be false for production version

#define test1	0	/* if using very large fonts (else, 8x16) */


*
*    end conditional assembly switches
*


*  Text bit block transfer
*
*
*  inputs:	SOURCEX,SOURCEY -			.w
*		  X,Y coordinate of character relative to UL corner of
*		  font (in pixels)
*
*		DESTX,DESTY -				.w
*		  UL corner of screen area to operate on (in pixels)
*
*		DELX,DELY -				.w
*		  size of area to operate on (in pixels)
*
*		FBASE -					.l
*		  base address of font
*
*		FWIDTH -				.w
*		  Form width of font in bytes
*
*		WRT_MODE -				.w
*		  writing mode operation (0-3) 0-replace  1-transparent
*					       2-XOR      3-inverse transparent
*
*		STYLE -					.w
*		  special effects select (thicken,light,skew,underline,
*		  outline, etc)
*
*		R_OFF,L_OFF -				.w
*		  right & left offset between top & bottom when italicizing
*
*		WEIGHT -				.w
*		  used by thicken (magnitude of thickness?)
*
*		LITEMASK,SKEWMASK -			.w
*		  for lighter letters
*
*		SCALE -				.w
*		  if non-zero make character twice height & width
*
*		CHUP -					.w
*		  rotation tenths of degrees (0,900,1800,or 2700 only)
*
*		CLIP -
*		  if non-zero, clipping bounds (below) in effect
*
*		XMN_CLIP,XMX_CLIP -			.w
*		  clipping region, x coordinate min & max
*
*		YMN_CLIP,YMX_CLIP -			.w
*		  clipping region, y coordinate min & max
*
*		  added Feb 26, '85...
*
*		MONO_ST -
*		  if non-zero (true), thicken effect should not enlarge source
*		XACCC_DDA -
*		  DDA accumulator passed externally
*		DDA_INC -
*		  DDA increment value
*		T_SCLST -
*		  0 if scale down, 1 if enlarge
*
*
*
*
*
*  process:	The main process of textblt does the following:
*		  { load source word (a0.l)
*		    align bits (with destination bit position)
*		    apply writing mode
*		    store into destination (a1.l)  }
*
*		There are several additional considerations
*		1. Most BLTs will be for a character less than
*		   16 pixels wide so a special all-fringe case
*		   can be used
*		2. Masks must be used on the source to prevent
*		   alteration of the destination outside the
*		   fringes.
*


*+
*   Style equates..
*-
THICKM		equ	$1
LIGHTM		equ	$2
SKEWM		equ	$4
UNDERM		equ	$8
OUTLINEM	equ	$10
SHADOWM		equ	$20

*+
*  Change to bit #'s for 68000..
*-
THICKEN		equ	0
LIGHT		equ	1
SKEW		equ	2
UNDER		equ	3
OUTLINE		equ	4
SHADOW		equ	5



*  Big daddy scratch buffer used for rotatin' & replicatin'
*
*  size requirement calculations for this buffer
*
*  font dependent equates (should be found in fonthead)

#if !test1
*  8x16 font data..

#define l_off	2		/* left offset from skew */
#define r_off	6		/* right offset from skew */
#define form_ht	16		/* form height */
#define mxcelwd	8		/* maximum cell width */

#endif


*  since a character cell may be rotated 90 or 270 deg, the cell height & width
*  may be interchanged.  The width must be word multiples (ie, 3 pixel widths
*  require the 1 word minimum of 16 bits), but the height needn't be rounded
*  up in a similiar fashion (since it represents # of rows).  Cell width is
*  determined when used as width or height, & cell height determined for both
*  cases also.
*
*
*
*  Text Cell buffer dimension calculations..

#define cell_ww	(((2*(l_off+r_off+mxcelwd))+3+15)/16)*2
#define cell_wh	(2*(l_off+r_off+mxcelwd))+2
#define cell_hh	(2*form_ht)+2
#define cell_hw	(((2*form_ht)+3+15)/16)*2

#define cell_sz0	cell_ww*cell_hh		/* doubled cell size, no rotation */
#define cell_sz9	cell_wh*cell_hw		/* doubled cell size, 90 deg rot. */

*  pick the maximum for our buffer..

#if cell_sz0 >= cell_sz9
#define cell_siz	cell_sz0
#else
#define cell_siz	cell_sz9
#endif

*  determine maximum horizontal line (from width or height)
*  which is needed by the Outline function as a buffer (+2 bytes)for
*  worst case.
*
#if cell_ww >= cell_hw
#define out_add	(cell_ww+2)
#else
#define out_add	(cell_hw+2)
#endif

*  Total buffer requirements are cel_siz + cel2_siz + out_add

#define buf_siz	cell_siz+cell_siz+out_add	/* total byte requirement */


*  for other fonts, above formulae examples should be used
*  to determine  cell_siz  &  buf_siz to allocate a scratch buffer
*
*  _TEXT_BLT expects variables scratchp & scrpt2 to be initialized as follows:
*
*   scrtchp	is a long word pointer to the base of a buffer with at least
*				buf_siz bytes available for scratch use
*
*   scrpt2	is a word offset within the buffer partitioning it into a small
*				and a large segments.  Should be set to cel_siz
*
*	NOTE: scrtchp & scrpt2 must be initilized to an even pointer
*	      and an even offset respectively.


_scrpt1		equ	0

*	Local Variables..

buffree		equ	-2	; currently free buffer (0 or cell_siz)
sform		equ	-6	; start of source form
dform		equ	-10	; start of destination form
s_next		equ	-12	; width of source form (formerly s_width)
d_next		equ	-14	; width of dest form (new, formerly v_lin_wr)
width		equ	-16	; width of area in pixels
height		equ	-18	; height of area in pixels
tsdad		equ	-20	; SRC dot addr (pix address, 0-15 word offset)
tddad		equ	-22	; destination dot address
dest_wrd	equ	-24	; # full words 'tween fringes (DST)
src_wrd		equ	-26	; # full words 'tween fringes (SRC, prethicken)
thk_msk		equ	-28	; right fringe mask, before thicken
rite_msk	equ	-30
left_msk	equ	-32	; fringes of destination to be affected
rota_msk	equ	-34	; overlap between words in inner loop
shif_cnt	equ	-36	; shift count for use by lf/rt shift routines

*    Indirect jump vectors for threaded BLT

blttype		equ	-38	; vector for inner BLT loop (sgl, dbl, etc)

*  Vectors that may contain a toptable entry..

logicop		equ	-40	; vector for pixel operation routine
special		equ	-42	; vector for logic op / special FX (sgl or dbl)
specwf		equ	-44	; vector for word special effects - fringe case
thknjmp		equ	-46	; vector for function after thicken
litejmp		equ	-48	; vector for function after light
skewjmp		equ	-50	; vector for function after skew
thknjpwf	equ	-52	; vector for word fringe function after thicken
litejpwf	equ	-54	; vector for word fringe function after light

*  Vectors that may contain twoptable entries...

specw		equ	-56	; vector for word special EFX (multi_lf or _rt)
thknjpw		equ	-58	; vector for word function after thicken
litejpw		equ	-60	; vector for word function after light

*  Masks..

smear		equ	-62	; amount to increase width
lite_msk	equ	-64	; AND with this to get light effect
skew_msk	equ	-66	; rotate this to check shift
thknover	equ	-68	; overflow for word thicken

*  color temp & # of planes

forecol		equ	-70	; foreground color temp
backcol		equ	-72	; background color temp
nbrplane	equ	-74	; # of planes
nextwrd		equ	-76	; offset to next word in same

*  arbitrary scale of text temps..

tmp_delx	equ	-78	; temp DELX used by arbitrary scale of text
tmp_dely	equ	-80	; temp DELY
swap_tmps	equ	-82	; Non zero if we had to swap temps
tmp_xacc	equ	-84	; XACC_DDA temp
ramlen		equ	-84

		text


*******************************************************************************
*
*
*   "software only" text blt entry point..
*
*   in:
*	a6	pointer to "lineavar" variable base
*	a5-a6	saved on stack upon entry
*
*******************************************************************************

/* 306de: 00e0e236 */
/* 206de: 00e0eaec */
/* 104de: 00fd2c4c */
/* 106de: 00e12eac */
#if BLITTER_SUPPORT
#define fp a5
	xdef	sb_text
sb_text:
#else
#define fp a6
	xdef	_TEXT_BLT
_TEXT_BLT:
#endif
		link	fp,#ramlen		; allocate local block of ram

		clr.w	swap_tmps(fp)		; temps not swapped yet
		move.w	LV(STYLE,a6),-(sp)
		move.w	LV(WRT_MODE,a6),-(sp)
		move.w	LV(SKEWMASK,a6),-(sp)

		move.w	LV(DESTX,a6),d0
		move.w	LV(DESTY,a6),d2
		move.w	LV(DELX,a6),d1
		move.w	LV(DELY,a6),d3

		move.w	LV(L_OFF,a6),d6
		add.w	LV(R_OFF,a6),d6		; we never use them separately

		movem.w	d0-d3,-(sp)
		clr.w	buffree(fp)		; indicate low buffer is free
		tst.w	LV(SCALE,a6)		;  doubling?
		beq	adr_nodb		; br if no

		move.w	d0,-(sp)		; push DESTX
		move.w	d2,-(sp)		; push DESTY
		move.w	d1,-(sp)		; push DELX
		move.w	d3,-(sp)		; pass DELY to ACT_SIZ on stack
		bsr	_ACT_SIZ
		move.w	(sp)+,d3		; restore 1 level of stack
		move.w	d0,d3			; set new DELY
		move.w	d0,tmp_dely(fp)		; save in temp for replication use
		move.w	(sp)+,d2		; DELX to d2
		move.w	LV(XACC_DDA,a6),d1	; get xacc_dda to d1
		move.w	LV(DDA_INC,a6),d0		; dda_inc to d0
		move.w	d3,-(sp)		; save new DELY
		moveq	#0,d3			; d3 = 0
		bra	clc_n_su

doub_wid:	add.w	d0,d1
		bcc	no_db_wd
		addq.w	#1,d3

no_db_wd:	btst.b	#0,LV((T_SCLSTS)+1,a6)
		beq	clc_n_su
		addq.w	#1,d3

clc_n_su:	dbra	d2,doub_wid

		move.w	d1,tmp_xacc(fp)		; save this value

		move.w	d3,d1
		move.w	d3,tmp_delx(fp)
		move.w	(sp)+,d3
		move.w	(sp)+,d2
		move.w	(sp)+,d0
#if TOSVERSION >= 0x102
		tst.w	d1
		beq	upda_dst
#endif

adr_nodb:	clr.w	smear(fp)		; in case no thicken init
		btst.b	#THICKEN,LV((STYLE)+1,a6)
		beq	adr_notk
		move.w	LV(WEIGHT,a6),d4
		bne	adr_th1
		and.w	#$FFFF-THICKM,LV(STYLE,a6) ; cancel thicken if WEIGHT=0

adr_th1:	tst.w	LV(MONO_STATUS,a6)	; skip source expand
		bne	adr_notk		; if monospaced font

		add.w	d4,d1			; we'll smear this amount (DELX=DELX+WEIGHT)

adr_notk:	btst.b	#SKEW,LV((STYLE)+1,a6)	; skewin'?
		beq	adr_nosk		; skip DELX adjust if not

		add.w	d6,d1			; DELX = DELX + L_OFF + R_OFF

adr_nosk:	btst.b	#OUTLINE,LV((STYLE)+1,a6)	; outlinin'?
		beq	adr_nout
		addq.w	#2,d1			; outline is 2 wider
		addq.w	#2,d3			; and 2 taller

adr_nout:	move.w	LV(CHUP,a6),d4		; get rotate degree-tenths
		beq	chk_clip		; skip rotate adjust if not rotatin'
*
*  rotatin'
*
add90:		cmp.w	#900,d4			; 90 degrees?
		bne	add180			; br if no
*
*  90 degrees
*
		sub.w	d1,d2			; move up by DELX
		move.w	d2,LV(DESTY,a6)		; DESTY = DESTY - DELX
		exg	d1,d3			; DELX <-> DELY (swap x & y to check clipping)
		bra	chk_clip

add180:		cmp.w	#1800,d4		; 180 degrees?
		bne	add270			; br if no

*
*  180 degrees
*
		sub.w	d1,d0			; DESTX = DESTX - DELX (move right by DELX)
		move.w	d0,LV(DESTX,a6)
		bra	chk_clip

*
*  270 degrees (assumed if not 0, 90, or 180)
*
add270:		exg	d1,d3			; DELX <-> DELY

**************************************
*   Check_clip
*
*     trivial accept and reject and set up buffer
*     blt if char must be clipped
*
*
chk_clip:	moveq	#0,d5			; clear clip flag (assume no clip)
		tst.w	LV(CLIP,a6)		; clip requested?
		beq	clp_done		; no, skip over clip-stuff

*
*  y -coord clip check..
*
		cmp.w	LV(YMN_CLIP,a6),d2		; top edge >= Y-MIN?
		bge	chk_ymx			; br if so, min ok

*
*  partially above clip window, check if totally above..
*
		add.w	d3,d2			; DESTY = DESTY + DELY
		addq.w	#1,d5			; set clip indicator
		cmp.w	LV(YMN_CLIP,a6),d2	; bottom edge > Y-MIN?
		bgt	chk_xmn			; br to x check if so, still got a piece in window
		bra	upda_dst		; else, skip further ado & exit, its gone

chk_ymx:	cmp.w	LV(YMX_CLIP,a6),d2	; top edge > Y-MAX?
		bgt	upda_dst		; br to exit if so, its totally off window

		add.w	d3,d2			; DESTY = DESTY + DELY
		subq.w	#1,d2			; DESTY 0 based
		sub.w	LV(YMX_CLIP,a6),d2	; bottom edge <= Y-MAX
		ble	chk_xmn			; br if so, y-coord wholly within window
*
*  partial clipping of bottom portion..
*
		addq.w	#1,d5			; set clip indicator

*
*  x - coord clip check..
*
chk_xmn:	cmp.w	LV(XMN_CLIP,a6),d0		; left edge >= X-MIN?
		bge	chk_xmx			; br if so, go check X-MAX

*
*  partially to left of clip window, check if totally left..
*
		add.w	d1,d0			; DESTX = DESTX + DELX
		addq.w	#1,d5			; must clip in x
		cmp.w	LV(XMN_CLIP,a6),d0		; right edge > X-MIN?
		bgt	clp_done		; br if so, some stuff still in window
		bra	upda_dst		; else, totally off screen, exit

chk_xmx:	cmp.w	LV(XMX_CLIP,a6),d0		; left edge > X-MAX?
		bgt	upda_dst		; br to exit if so, its totally off window

		add.w	d1,d0			; DESTX = DESTX + DELX
		subq.w	#1,d0			; DESTX 0 based
		cmp.w	LV(XMX_CLIP,a6),d0	; right edge <= X-MAX?
		ble	clp_done		; br if so, no x-clip
		addq.w	#1,d5			; set clip indicator
*
*  clip check done..
*
clp_done:	move.w	LV(FWIDTH,a6),s_next(fp)	; add this to go down one line
		move.l	LV(FBASE,a6),sform(fp)	; start of font
		tst.w	LV(SCALE,a6)		; scaling goin' on
		beq	chk_skw			; br to skip if not
		movem.l	d0-d7,-(sp)		; perform scaling 1st
		bsr	replicat		; so other special effects
		movem.l	(sp)+,d0-d7		; look better

chk_skw:	move.w	LV(STYLE,a6),d1
		andi.w	#SKEWM+THICKM+OUTLINEM,d1 ; skew, thicken, or outline special effects
		beq	chk_rota		; br if not, skip preblt into buffer
*
*  thicken or skew or outline in effect..
*
chk_chup:	tst.w	LV(CHUP,a6)		; we may have to preblt into buffer
		bne	preblt			; br to preblt if rotation in effect

		btst	#SKEW,d1		; skew bit set in STYLE?
		beq	preskew			; br if not, skip clip test
		tst.w	d5			; did we clip
		bne	preblt			; br to preblt if yes

preskew:	btst	#OUTLINE,d1		; outlining?
		beq	skw_nrot		; br if not, no preblt
*
*  preblt into buffer..
*
preblt:		move.w	LV(SOURCEX,a6),d0
		move.w	d0,d2
		andi.w	#$000F,d2
		move.w	d2,tsdad(fp)		; save source dot address

		lsr.w	#4,d0			; make byte address
		lsl.w	#1,d0			; make even-byte address (word aligned)

		move.w	LV(SOURCEY,a6),d2		; d2 <- source y
		move.w	LV(DELY,a6),height(fp)
		add.w	height(fp),d2		; d2 <- bottom of source + 1
		subq.w	#1,d2			; d2 <- bottom of source     (0 based)

		mulu	s_next(fp),d2		; d2 <- offset to bottom of font form
		neg.w	s_next(fp)		; use negative increment to move up
		add.w	d0,d2			; d2 -> font source for top of char
		movea.l	sform(fp),a0		; 04 nov 87  HANDLE FONT FORMS > 32k
		lea.l   0(a0,d2.w),a0			; a0 -> font source for bottom of char

		move.w	LV(DELX,a6),d0		; char width
		move.w	LV(WEIGHT,a6),d1		; thicken amount

		btst.b	#THICKEN,LV((STYLE)+1,a6)	; smear?
		beq	no_smear		; br if no

		add.w	d1,d0			; add adjusted WEIGHT to DELX
		move.w	d1,smear(fp)		; save smear

*+
*  outline code..
*-
no_smear:	clr.w	tddad(fp)
		move.w	LV(DELY,a6),d1
		move.w	LV(STYLE,a6),d2
		btst	#OUTLINE,d2		; check for outline mode
		beq	no_out
		addq.w	#3,d0			; add 3 pixels to delx (1 left, 2 right)
		addq.w	#1,tddad(fp)		; make leftmost column blank
		addq.w	#2,LV(DELY,a6)		; add 2 rows (outline adds 2 to ht & wd)
		addq.w	#3,d1			; add 3 rows for buffer clear (line buf)

*+
*  end additions
*-
no_out:		move.w	d0,width(fp)
		add.w	d6,d0			; we moved to d6

		move.w	d0,LV(DELX,a6)		; now the char is bigger
		lsr.w	#4,d0
		lsl.w	#1,d0
		addq.w	#2,d0			; this is the dest width in bytes
		neg.w	d0
		move.w	d0,d_next(fp)		; move upward in buffer
		neg.w	d0
		subq.w	#1,d1			; start of bottom line
		mulu	d1,d0

		bsr	getdest			; get destination ptr in a1
		move.l	a1,-(sp)		; save for later

		btst	#OUTLINE,d2
		bne	do_clear
		btst	#SKEW,d2
		beq	no_clear

*+
*  clear buffer first..
*-
do_clear:	move.l	a1,-(sp)
		move.w	d0,d3
		sub.w	d_next(fp),d3		; count the bottom line
		lsr.w	#1,d3			; bytes to words
		moveq	#0,d1
		bra	replp1

replp:		move.w	d1,(a1)+		; clear out buffer for skew

replp1:		dbra	d3,replp
		move.l	(sp)+,a1

		btst	#OUTLINE,d2
		beq	no_clear
		subq.w	#3,width(fp)
		subq.w	#1,LV(DELX,a6)
		add.w	d_next(fp),d0

*+
*  buffer now clear..
*-
no_clear:	adda.w	d0,a1			; start at the bottom

		move.w	LV(WRT_MODE,a6),-(sp)
		move.w	LV(STYLE,a6),-(sp)

		move.w	#7,LV(WRT_MODE,a6)	; replace mode for this blt

		move.w	#1,forecol(fp)		; foreground 1 for this blt
		clr.w	backcol(fp)		; background 0 for this blt
		move.w	#1,nbrplane(fp)		; 1 plane, natch
		move.w	#2,nextwrd(fp)		; plane offset is 2
		andi.w	#SKEWM+THICKM,LV(STYLE,a6)	; only do thicken & skew

		bsr	norm_blt		; blt source into buffer

		move.w	(sp)+,LV(STYLE,a6)
		move.w	(sp)+,LV(WRT_MODE,a6)

		move.l	(sp)+,a1		; reget old destination ptr

no_mode:	move.w	d_next(fp),d7		; reset the source to the buffer
		neg.w	d7
		move.w	d7,s_next(fp)

		move.l	a1,a0			; use source ptr
		move.l	a0,sform(fp)

*+
*  outline additions
*-
		btst.b	#OUTLINE,LV((STYLE)+1,a6)	; check outline
		beq	skip_out		; br to skip outline code

		ext.l	d7
		add.l	d7,sform(fp)		; use 2nd down for buffer top (top is temp buf)
		bsr	outlin			; outline buffer please

*+
*  end additions
*-
skip_out:	clr.w	LV(SOURCEX,a6)
		clr.w	LV(SOURCEY,a6)
		andi.w	#$FFFF-(SKEWM+THICKM),LV(STYLE,a6)	; cancel effects
*
*  Preblt is done
*
skw_nrot:
chk_rota:	tst.w	LV(CHUP,a6)
		beq	chk_db

		bsr	rotation		; perform rotation if 90, 180, or 270

chk_db:
do_clip1:

*************************************************
*  clipping
*	change SOURCEX, SOURCEY, DELX, DELY
*	based on DESTX, DESTY (UL corner of destination)
*
do_clip:	btst.b	#THICKEN,LV((STYLE)+1,a6)
		beq	no_thik
		move.w	LV(WEIGHT,a6),d0
		tst.w	LV(MONO_STATUS,a6)
		bne	do_cl_nt
		add.w	d0,LV(DELX,a6)

do_cl_nt:	move.w	d0,smear(fp)

no_thik:	tst.w	LV(CLIP,a6)		; clip requested?
		beq	scrn_blt		; br to skip clip if not

		move.w	LV(DESTY,a6),d0
		cmp.w	LV(YMN_CLIP,a6),d0
		bge	ymn_fine
		add.w	LV(DELY,a6),d0
		cmp.w	LV(YMN_CLIP,a6),d0
		ble	upda_dst

mn_clipy:	sub.w	LV(YMN_CLIP,a6),d0
		move.w	LV(DELY,a6),d1
		move.w	d0,LV(DELY,a6)
		sub.w	d0,d1
		add.w	d1,LV(SOURCEY,a6)
		move.w	LV(YMN_CLIP,a6),d0
		move.w	d0,LV(DESTY,a6)

ymn_fine:	cmp.w	LV(YMX_CLIP,a6),d0
		bgt	upda_dst

mx_clipy:	add.w	LV(DELY,a6),d0
		subq.w	#1,d0			; make 0 relative
		cmp.w	LV(YMX_CLIP,a6),d0
		ble	ymx_fine

*+
* clip y
*-
		sub.w	LV(YMX_CLIP,a6),d0
		sub.w	d0,LV(DELY,a6)

ymx_fine:	move.w	LV(DESTX,a6),d0
		cmp.w	LV(XMN_CLIP,a6),d0
		bge	xmn_fine
		add.w	LV(DELX,a6),d0
		cmp.w	LV(XMN_CLIP,a6),d0
		ble	upda_dst
*+
* clip x
*-
mn_clipx:	sub.w	LV(XMN_CLIP,a6),d0
		move.w	LV(DELX,a6),d1
		move.w	d0,LV(DELX,a6)
		sub.w	d0,d1
		add.w	d1,LV(SOURCEX,a6)
		move.w	LV(XMN_CLIP,a6),d0
		move.w	d0,LV(DESTX,a6)

xmn_fine:	cmp.w	LV(XMX_CLIP,a6),d0
		bgt	upda_dst

mx_clipx:	add.w	LV(DELX,a6),d0
		subq.w	#1,d0			; make 0 relative
		cmp.w	LV(XMX_CLIP,a6),d0
		ble	xmx_fine
*+
* clip x
*-
		sub.w	LV(XMX_CLIP,a6),d0
		sub.w	d0,LV(DELX,a6)

xmx_fine:	bra	scrn_blt

*+
*  Offset to next word in same plane
*-
nxtword:	dc.b	2,4,0,8

**************************************************
*
*
*  screen blt
*	put a block defined by s_form, SOURCEX, SOURCEY, DELX, DELY
*	out to screen
*
/* 206de: 00e0ee5a */
scrn_blt:	move.w	LV(TEXT_FG,a6),forecol(fp) ; copy foreground color to temp
		move.w	LV(TEXT_BG,a6),backcol(fp) ; likewise for background
		move.w	LV(V_PLANES,a6),d0	; d0 <- # of planes
		move.w	d0,nbrplane(fp)		; save locally
		move.b	nxtword-1(pc,d0.w),d0	; d0 <- offset  (assumed:hi byte=0)
		move.w	d0,nextwrd(fp)		; save locally

		move.w	LV(SOURCEX,a6),d0		; d0 <- character X
		move.w	d0,d2
		andi.w	#$0F,d2			; d2 <- offset within word to character
		move.w	d2,tsdad(fp)		; save source dot address
		lsr.w	#3,d0
		andi.w  #$FFFE,d0			; d0 <- word alligned offset to char

		move.w	LV(SOURCEY,a6),d2		; d2 <- source Y + del Y
		move.w	LV(DELY,a6),height(fp)		; height <- del Y
		add.w	height(fp),d2
		subq.w	#1,d2			; d2 <- Y offset to bottom of char
		mulu	s_next(fp),d2		; d2 <- byte offset to bottom of char

		neg.w	s_next(fp)		; traverse form from bottom to top

		add.w	d0,d2			; a0 -> top of character
		movea.l	sform(fp),a0		; HANDLE FONT FORMS > 32k
		adda.w	d2,a0			; a0 -> bottom of character

		move.w	LV(DELX,a6),width(fp)

		move.w	LV(DESTY,a6),d1
		add.w	LV(DELY,a6),d1
		subq.w	#1,d1			; we draw from bottom up

		move.w	LV(DESTX,a6),d0

		jsr	concat			; get memory address & dot address
*+
* d1.w is screen offset of destination
*-
		move.l	_v_bas_ad,a1
		adda.w	d1,a1			; CONCAT returns d1.l

		move.w	d0,tddad(fp)		; save dot address

		move.w	LV(v_lin_wr,a6),d0
		neg.w	d0
		move.w	d0,d_next(fp)

		bsr	norm_blt

upda_dst:	movem.w	(sp)+,d0-d3
		move.w	d0,LV(DESTX,a6)
		move.w	d1,LV(DELX,a6)
		move.w	d2,LV(DESTY,a6)
		move.w	d3,LV(DELY,a6)		; may have changed these for clipping

		move.w	(sp)+,LV(SKEWMASK,a6)
		move.w	(sp)+,LV(WRT_MODE,a6)
		move.w	(sp)+,LV(STYLE,a6)

		tst.w	LV(SCALE,a6)		; set up dest address
		beq	upda_ndb

		move.w	tmp_xacc(fp),LV(XACC_DDA,a6) ; save new XACC_DDA

		move.w	tmp_delx(fp),d1		;get actual char width
		move.w	tmp_dely(fp),d3		;get actual char height

		tst.w	swap_tmps(fp)		; are we swapped
		beq	upda_ndb		; if yes swap back
		exg	d1,d3

*+
* end additions
*-
upda_ndb:	btst.b	#OUTLINE,LV((STYLE)+1,a6)	; adjust new horz position
		beq	upda_not		; by expanded outline form
		addq.w	#2,d1			; if outline in effect
		addq.w	#2,d3

upda_not:	btst.b	#THICKEN,LV((STYLE)+1,a6)
		beq	upda_ntk
		tst.w	LV(MONO_STATUS,a6)
		bne	upda_ntk
		add.w	LV(WEIGHT,a6),d1		; we smeared this amount

upda_ntk:	move.w	LV(CHUP,a6),d0
		bne	ck90
		add.w	d1,LV(DESTX,a6)		; move left by DELX
		bra	blt_done

ck90:		cmpi.w	#900,d0
		bne	ck180
		sub.w	d1,LV(DESTY,a6)		; move up by DELX
		bra	blt_done

ck180:		cmpi.w	#1800,d0
		bne	ck270
		sub.w	d1,LV(DESTX,a6)		; move right by DELX
		bra	blt_done

ck270:		add.w	d1,LV(DESTY,a6)		; move down by DELX


blt_done:	unlk	fp
#if BLITTER_SUPPORT
		movem.l	(sp)+,a5-a6		; restore pre-saved registers
#endif
		rts				; return to "C"


***********************************************
*
*   normal blt routine
*		uses:	a0.l - starting source address
*			a1.l - starting destination address
*		 tsdad,tddad - address within word
*		       STYLE - special effects mask
*		width,height - width & length of area to copy
*		      s_next - add this to get to next line in source
*		      d_next - add this to get to next line in destination
*
*
*
*
norm_blt:	move.w	tddad(fp),d1		; get destination offset
		sub.w	tsdad(fp),d1		; subtract source offset -> d1
		move.w	d1,d0			; copy to d0
		bpl	do_rot			; br if tsdad =< tddad & rotate right
*+
*  rotate left
*-
		neg.w	d1			; form 2's cmpliment for positive shift/count
		ori.w	#$8000,d1		; fake a negative (stripped by ROR or ROL)
		addi.w	#16,d0			; make word_mask_table index positive

do_rot:		move.w	d1,shif_cnt(fp)		; save shift count (bit15=1 if ROL, else ROR)
		lsl.w	#1,d0			; x2 for index
		lea	lf_tab,a2		; get base addr of mask table
		move.w	(a2,d0.w),d0		; set the overlap for middle words
		not.w	d0
		move.w	d0,rota_msk(fp)		; save as rotate mask

*+
*    Set up fringe masks..
*-
get_mask:	move.w	tddad(fp),d0		; get destination dot address
		lsl.w	#1,d0			; x2 for index in d0
		move.w	(a2,d0.w),left_msk(fp)	; get mask for destination dot address

		lsr.w	#1,d0			; d0 back to tddad
		add.w	width(fp),d0		; add to form right side

		move.w	d0,d2			; copy possibly thickened width to temp d2
		sub.w	smear(fp),d2		; get original before thickened
		andi.w	#$F,d2
		lsl.w	#1,d2
		move.w	(a2,d2.w),d2
		not.w	d2
		move.w	d2,thk_msk(fp)
		clr.w	d4
		move.w	#$8000,skew_msk(fp)
		moveq.l	#-1,d3			; assume sgl_loop

		cmpi.w	#$10,d0			; more than a word?
		bhi	doub_des		; br if  => $10, needs more than 1 word

*+
*  Fits in one word
*-
		lsl.w	#1,d0			; x2 for index
		move.w	(a2,d0.w),d1
		not.w	d1
		and.w	d1,left_msk(fp)		; put the two masks together

		move.w	#sgl_loop-cs,blttype(fp) ; set blttype vector ***change
		bra	msk_done		; exit mask stuff

*+
*  Two fringe masks needed..
*-
doub_des:
		move.w	#dbl_loop-cs,blttype(fp) ; set blttype vector for double
		move.w	d0,d1			; get tddad +DELX to d1
		lsr.w	#4,d1			; divide by 16
		subq.w	#1,d1
		move.w	d1,d3			; number of words to write for middle
		bne	mlt_dest		; br if # of words is non-zero

*+
*  # of middle words is zero
*-
		move.w	tsdad(fp),d1
		add.w	width(fp),d1
		cmpi.w	#$20,d1
		bcs	do_ritem		; br if source fits in two words too

mlt_dest:	move.w	#mlt_rite-cs,blttype(fp)
		tst.w	shif_cnt(fp)		; check sign of shift count
		bpl	do_ritem
		move.w	#mlt_left-cs,blttype(fp)

do_ritem:	andi.w	#$000F,d0
		bne	not_null
		subq.w	#1,d3			; last word is full so its a fringe
		move.w	#$10,d0

not_null:	lsl	#1,d0
		move.w	(a2,d0.w),d4
		not.w	d4

msk_done:	move.w	d3,dest_wrd(fp)
		move.w	d4,rite_msk(fp)
		addq.w	#2,d3
		cmp.w	d2,d4
		bcs	msk0
		addq.w	#1,d3

msk0:		move.b	d3,src_wrd(fp)
		move.b	d3,src_wrd+1(fp)

plane_lp:	move.w	LV(WRT_MODE,a6),d0	; d0 = 00000000 000xxxxx ,WRT_MODE
		lsr.w	forecol(fp)		; this plane's foreground bit -> cy
		roxl.w	#1,d0
		lsr.w	backcol(fp)
		roxl.w	#1,d0

*
*  d0.w is index
*
sp1:		move.b	wrmappin(pc,d0.w),d0
		move.w	toptable(pc,d0.w),a2
		move.w	a2,logicop(fp)		; call this address to do tlogicop
		move.w	a2,special(fp)		; logicop or special effects
		move.w	a2,specwf(fp)		; word fringe special effects
		move.w	twoptble(pc,d0.w),specw(fp) ; logicop or special effects for words
*
*  Do special effects..
*
		move.w	LV(STYLE,a6),d0		; special effects mask
		bne	do_specl
		bra	no_specl

toptable:
	dc.w	top0-cs,top1-cs,top2-cs,top3-cs,top4-cs,top5-cs,top6-cs,top7-cs
	dc.w	top8-cs,top9-cs,topa-cs,topb-cs,topc-cs,topd-cs,tope-cs,topf-cs

twoptble:
	dc.w	twop0-cs,twop1-cs,twop2-cs,twop3-cs,twop4-cs,twop5-cs,twop6-cs,twop7-cs
	dc.w	twop8-cs,twop9-cs,twopa-cs,twopb-cs,twopc-cs,twopd-cs,twope-cs,twopf-cs

op0	equ	2*0
op1	equ	2*1
op2	equ	2*2
op3	equ	2*3
op4	equ	2*4
op5	equ	2*5
op6	equ	2*6
op7	equ	2*7
op8	equ	2*8
op9	equ	2*9
opA	equ	2*10
opB	equ	2*11
opC	equ	2*12
o_D	equ	2*13
opE	equ	2*14
opF	equ	2*15

*  writing mode mapping tables:
*
*
*	fb=	00  01  10  11
wrmappin:	dc.b	op0,op0,op3,op3		; replace mode
		dc.b	op4,op4,op7,op7		; transparent mode
		dc.b	op6,op6,op6,op6		; XOR mode
		dc.b	op1,op1,o_D,o_D		; inverse transparent mode

		dc.b	op0,opF,op0,opF		; mode 0  D' = 0
		dc.b	op0,opE,op1,opF		; mode 1  D' = S and D
		dc.b	op0,o_D,op2,opF		; mode 2  D' = S and [not D]
		dc.b	op0,opC,op3,opF		; mode 3  D' = S	(replace)
		dc.b	op0,opB,op4,opF		; mode 4  D' = [not S] and D
		dc.b	op0,opA,op5,opF		; mode 5  D' = D
		dc.b	op0,op9,op6,opF		; mode 6  D' = S xor D (XOR mode)
		dc.b	op0,op8,op7,opF		; mode 7  D' = S or D  (OR mode)
		dc.b	op0,op7,op8,opF		; mode 8  D' = not [S or D]
		dc.b	op0,op6,op9,opF		; mode 9  D' = not [S xor D]
		dc.b	op0,op5,opA,opF		; mode A  D' = not D
		dc.b	op0,op4,opB,opF		; mode B  D' = S or [not D]
		dc.b	op0,op3,opC,opF		; mode C  D' = not S
		dc.b	op0,op2,o_D,opF		; mode D  D' = [not s] or D
		dc.b	op0,op1,opE,opF		; mode E  D' = not [S and D]
		dc.b	op0,op0,opF,opF		; mode F  D' = 1


/* easteregg alert... */
blt_adj:
#if (TOSVERSION == 0x100) & (OS_COUNTRY == CTRY_FI)
		.ascii "  Translated by origo qt, NORWAY"
#else
		move.l	-(a0),d0
		neg.w	-(a1)
		moveq.l	#$65,d3
		movea.l	(a3),a0
		moveq.l	#$61,d2
		subq.w	#2,-(a7)
#if BINEXACT
		dc.w $6173,$206c,$6f76,$6573,$2042,$6561,$2048,$6162,$6c69,$6720
#else
		bsr.s	blt_adj+$81
		movea.l	$6F76(a4),a0
		bcs.s	blt_adj+$87
		movea.l	d2,a0
		bcs.s	blt_adj+$79
		movea.l	a0,a0
		bsr.s	blt_adj+$7E
		bge.s	blt_adj+$87
		beq.s	blt_adj+$40
#endif
#endif
		rts


do_specl:	btst.l	#LIGHT,d0
		beq	no_lite

*+
*  Light special effect..
*-
		move.w	LV(LITEMASK,a6),lite_msk(fp)	; reload the mask for this char
		move.w	special(fp),litejmp(fp)	; endpoint of light routine
		move.w	#liteop-cs,special(fp)	; insert this in the loop

		move.w	specwf(fp),litejpwf(fp)	; endpoint of light routine
		move.w	#liteopwf-cs,specwf(fp)	; insert this in the loop

		move.w	specw(fp),litejpw(fp)	; endpoint of light routine
		move.w	#liteopw-cs,specw(fp)	; insert this in the loop

no_lite:	btst.l	#THICKEN,d0
		beq	no_thick

*+
*  Thicken special effect..
*-
		clr.w	thknover(fp)

		move.w	special(fp),thknjmp(fp)	; endpoint of thicken routine
		move.w	#thknop-cs,special(fp)	; insert routine into the loop

		move.w	specwf(fp),thknjpwf(fp)	; endpoint of light routine
		move.w	#thknopwf-cs,specwf(fp)	; insert routine into loop

		move.w	specw(fp),thknjpw(fp)	; endpoint of light routine
		move.w	#thknopw-cs,specw(fp)	; insert routine into the loop

no_thick:	btst.l	#SKEW,d0
		beq	no_skew

*+
*  Skew special effect..
*-
		move.w	LV(SKEWMASK,a6),skew_msk(fp)	; reload mask for this char
		move.w	special(fp),skewjmp(fp)
		move.w	#skewop-cs,special(fp)

		cmpi.w	#sgl_loop-cs,blttype(fp)
		bne	not_sngl
		clr.w	dest_wrd(fp)
		move.w	#dbl_loop-cs,blttype(fp)
		bra	no_skew

not_sngl:	cmpi.w	#dbl_loop-cs,blttype(fp)
		bne	mlt_skew
		cmpi.w	#$10,width(fp)
		bls	no_skew			; br if source is at most two words

		move.w	#mlt_rite-cs,blttype(fp)
		tst.w	shif_cnt(fp)

		bpl	mlt_skew		; br if mlt_rite assumption correct
		move.w	#mlt_left-cs,blttype(fp)

mlt_skew:
no_skew:
no_specl:	move.w	left_msk(fp),d2		; get the first mask
		move.w	height(fp),d3		; set loop count
		move.l	#cs,a3			; base address of BLT threads

		move.w	blttype(fp),a4
		movem.l	a0-a1,-(sp)		; save source/ destination ptrs
		jsr	0(a3,a4.w)		; do the fastest one
		movem.l	(sp)+,a0-a1		; reget source/ destination pts
		addq.l	#2,a1			; advance destination plane
		subq.w	#1,nbrplane(fp)		; decrement plane count
		bne	more_pl			; loop for next plane

*+
*  else, no more planes
*-
		rts				; back to norm_blt caller

more_pl:	btst.b	#SKEW,LV((STYLE)+1,a6)	; only skew screws up other planes
		beq	plane_lp		; br to short init if not skew
		bra	norm_blt		; else, do big init

*+
*   Base address (code segment) for indirect jump routines
*-
cs:
*+
*  blttype routines:  sgl_loop, dbl_loop, mlt_left, mlt_rite
*-
***********************************************
*   Single loop: destination is a single word
***********************************************
sgl_lp:		move.w	(a1),d4			; get dest
		move.l	(a0),d0			; get 2 src wrds (may only use 1)
		move.w	shif_cnt(fp),d1
		bmi	left_rol
		lsr.l	d1,d0
		bra	end_ro

left_rol:	lsl.l	d1,d0

end_ro:		swap	d0
		move.w	d0,d1
		swap	d0
		move.w	special(fp),a4
		jsr	0(a3,a4.w)		; do special effect or just logicop

		move.w	d1,(a1)			; store the result

		adda.w	s_next(fp),a0		; get to next line above in font
		adda.w	d_next(fp),a1		;  and on screen

*+
*  Entry point for single loop...
*-
sgl_loop:	dbra	d3,sgl_lp
		rts

************************************************
*  Double loop
************************************************
dbl_lp:		move.w	(a1),d4			; get dest
		move.l	(a0),d0			; do a line (two fringes)

		move.w	shif_cnt(fp),d1
		bmi	dbleft
		lsr.l	d1,d0			; align source & destination
		bra	dblendr

dbleft:		lsl.l	d1,d0

dblendr:	swap	d0
		move.w	d0,d1
		swap	d0

		move.w	left_msk(fp),d2		; get the first one back

		move.w	special(fp),a4		; call special
		jsr	0(a3,a4.w)

		move.w	d1,(a1)			; save the result
		move.w	d0,d1			; get the other half (it got shifted in)
		move.w	nextwrd(fp),d5		; get offset to next word
		move.w	(a1,d5.w),d4		; get next destination word

		move.w	rite_msk(fp),d2		; use right mask

		move.w	logicop(fp),a4		; call logic op
		jsr	0(a3,a4.w)

		move.w	d1,(a1,d5.w)		; save the result

		adda.w	s_next(fp),a0		; get to next line above in font
		adda.w	d_next(fp),a1		;  and on screen
*
*  Entry point for double loop...
*
dbl_loop:	dbra	d3,dbl_lp
		rts

*************************************************
*    Multi - Left
*************************************************
mlt_left:	movem.l	a0-a1,-(sp)		; save source/destination registers
		move.w	dest_wrd(fp),d7		; # of full words between fringes
		move.l	(a0)+,d0		; get two words of source

		move.w	(a1),d4			; get destination word

		move.w	shif_cnt(fp),d1
		lsl.l	d1,d0

		swap	d0
		move.w	d0,d1
		swap	d0			; source aligned to destination

		move.w	left_msk(fp),d2		; get the mask for left fringe

		move.w	specwf(fp),a4		; call specialwf
		jsr	0(a3,a4.w)		; to do special effect or just logicop

		move.w	d1,(a1)			; store the result
		adda.w	nextwrd(fp),a1		; advance destination ptr to next word

		move.w	rota_msk(fp),d2		; get mask for inner full words
*
*  inner loop for non-fringe words..
*
word_lef:	move.w	d0,d4			; save what's left of this word
		and.w	d2,d4			; clear out garbage at end of word
		move.w	(a0)+,d0		; get next source word
		swap	d0
		move.w	d1,d0			; pack d0
		swap	d0

		move.w	shif_cnt(fp),d1
		lsl.l	d1,d0

		swap	d0
		move.w	d0,d1
		swap	d0			; source aligned to destination

		not.w	d2
		and.w	d2,d1			; strip off garbage
		not.w	d2
		eor.w	d4,d1			; put left-overs in front of word

		move.w	(a1),d4			; get another destination word

		tst.w	d7			; "jcxz"
		beq	lef_don			; br if we have to mask the last word

		move.w	specw(fp),a4		; call specialw
		jsr	0(a3,a4.w)

		move.w	d1,(a1)			; store the result
		adda.w	nextwrd(fp),a1		; advance destination to next word

		subq.w	#1,d7			; decrement inner loop count
		bra	word_lef		; go for more

lef_don:	move.w	rite_msk(fp),d2		; load the mask we need

		move.w	specwf(fp),a4		; call specialwf
		jsr	0(a3,a4.w)		; feature - this clears thickenover

		move.w	d1,(a1)			; store the result

		movem.l	(sp)+,a0-a1		; pop source/destination ptrs

		adda.w	s_next(fp),a0		; get to next line above in font
		adda.w	d_next(fp),a1		;   and on screen

		clr.w	thknover(fp)

		subq.w	#1,d3			; decrement # of lines to move
		beq	ldone			; exit if finished

		rol.w	lite_msk(fp)

		btst.b	#SKEW,LV((STYLE)+1,a6)
		bne	skewopw
		bra	mlt_left

ldone:		rts

*************************************************
*   Multi - right
*************************************************
mlt_rite:	movem.l	a0-a1,-(sp)		; save source/destination registers
		move.w	dest_wrd(fp),d7		; # of full words between fringes
		move.w	(a0)+,d0		; get one word of source
		swap	d0			; put in hi word

		move.w	(a1),d4			; get destination word

		move.w	shif_cnt(fp),d1
		lsr.l	d1,d0			; align source & destination
		swap	d0
		move.w	d0,d1
		swap	d0			; source aligned to destination

		move.w	left_msk(fp),d2		; get the mask for left fringe

		move.w	specwf(fp),a4		; call specialwf
		jsr	0(a3,a4.w)		; to do special effect or just logicop

		move.w	d1,(a1)			; store the result
		adda.w	nextwrd(fp),a1		; advance destination ptr to next word

		move.w	rota_msk(fp),d2		; get mask for inner full words
*
*  inner loop for non-fringe words..
*
word_rit:	move.w	d0,d4			; save what's left of this word
		and.w	d2,d4			; clear out garbage at end of word
		swap	d0
		move.w	(a0)+,d0		; get next source word
		swap	d0

		move.w	shif_cnt(fp),d1
		lsr.l	d1,d0			; align source & destination
		swap	d0
		move.w	d0,d1
		swap	d0			; source aligned to destination

		not.w	d2
		and.w	d2,d1			; strip off garbage
		not.w	d2
		eor.w	d4,d1			; put left-overs in front of word

		move.w	(a1),d4			; get another destination word

		tst.w	d7			; "jcxz"
		beq	rite_don		; br if we have to mask the last word

		move.w	specw(fp),a4		; call specialw
		jsr	0(a3,a4.w)

		move.w	d1,(a1)			; store the result
		adda.w	nextwrd(fp),a1		; advance destination to next word

		subq.w	#1,d7			; decrement inner loop count
		bra	word_rit		; go for more

rite_don:	move.w	rite_msk(fp),d2		; load the mask we need

		move.w	specwf(fp),a4		; call specialwf
		jsr	0(a3,a4.w)		; feature - this clears thickenover

		move.w	d1,(a1)			; store the result

		movem.l	(sp)+,a0-a1		; pop source/destination ptrs
		adda.w	s_next(fp),a0		; get to next line above in font
		adda.w	d_next(fp),a1		;   and on screen

		clr.w	thknover(fp)

		subq.w	#1,d3			; decrement # of lines to move
		beq	rdone			; exit if finished

		rol.w	lite_msk(fp)

		btst.b	#SKEW,LV((STYLE)+1,a6)
		bne	skewopw
		bra	mlt_rite

rdone:		rts

**************************************************************
*	Writing Mode Operations using fringe mask
**************************************************************
top0:		not.w	d2		; mode 0	D' = 0
		and.w	d2,d4
		not.w	d2
		move.w	d4,d1
		rts

top1:		not.w	d2		; mode 1	D' = S and D
		or.w	d2,d1
		not.w	d2
		and.w	d4,d1
		rts

top2:		not.w	d1		; mode 2	D' = S and [not D]
		and.w	d2,d1
		or.w	d4,d1
		eor.w	d2,d1
		rts

top3:		eor.w	d4,d1		; mode 3	D' = S (replace mode)
		and.w	d2,d1
		eor.w	d4,d1
		rts

top4:		and.w	d2,d1		; mode 4	D' = [not S] and D
		not.w	d1
		and.w	d4,d1
		rts

top5:		move.w	d4,d1		; mode 5	D' = D
		rts

top6:		and.w	d2,d1		; mode 6	D' = S xor D (xor mode)
		eor.w	d4,d1
		rts

top7:		and.w	d2,d1		; mode 7	D' = S or D (or mode)
		or.w	d4,d1
		rts

top8:		and.w	d2,d1		; mode 8	D' = not [S or D]
		or.w	d4,d1
		eor.w	d2,d1
		rts

top9:		and.w	d2,d1		; mode 9	D' = not [S xor D]
		eor.w	d4,d1
		eor.w	d2,d1
		rts

topa:		move.w	d4,d1		; mode 10 	D' = not D
		eor.w	d2,d1
		rts

topb:		eor.w	d2,d4		; mode 11	D' = S or [not D]
		and.w	d2,d1
		or.w	d4,d1
		rts

topc:		eor.w	d4,d1		; mode 12	D' = not S
		and.w	d2,d1
		eor.w	d4,d1
		eor.w	d2,d1
		rts

topd:		not.w	d1		; mode 13	D' = [not S] or D
		and.w	d2,d1
		or.w	d4,d1
		rts

tope:		not.w	d1		; mode 14	D' = not [S and D]
		and.w	d2,d1
		eor.w	d2,d4
		or.w	d4,d1
		rts

topf:		or.w	d2,d4		; mode 15	D' = 1
		move.w	d4,d1
		rts

**************************************************************
*	Word Writing Mode Operations
**************************************************************
twop0:		moveq.l	#0,d1		; mode 0	D' = 0
		rts

twop1:		and.w	d4,d1		; mode 1	D' = S and D
		rts

twop2:		not.w	d4		; mode 2	D' = S and [not D]
		and.w	d4,d1
		rts

twop3:		rts			; mode 3	D' = S (replace mode)

twop4:		not.w	d1		; mode 4	D' = [not S] and D
		and.w	d4,d1
		rts

twop5:		move.w	d4,d1		; mode 5	D' = D
		rts

twop6:		eor.w	d4,d1		; mode 6	D' = S xor D
		rts

twop7:		or.w	d4,d1		; mode 7	D' = S or D
		rts

twop8:		or.w	d4,d1		; mode 8	D' = not [S or D]
		not.w	d1
		rts

twop9:		eor.w	d4,d1		; mode 9	D' = not [S xor D]
		not.w	d1
		rts

twopa:		move.w	d4,d1		; mode 10	D' = not D
		not.w	d1
		rts

twopb:		not.w	d4		; mode 11	D' = S or [not D]
		or.w	d4,d1
		rts

twopc:		not.w	d1		; mode 12	D' = not S
		rts

twopd:		not.w	d1		; mode 13	D' = [not S] or D
		or.w	d4,d1
		rts

twope:		and.w	d4,d1		; mode 14	D' = not [S and D]
		not.w	d1
		rts

twopf:		moveq.l	#-1,d1		; mode 15	D' = 1
		rts

*************************************************
*    special effect THICKEN
*	on entry	d1.w	source word
*			d0.w	next source word
*			d2.w	current mask
*
*	on exit
*			d1.w	thickened source
*			d0.w	thickened next source
*
*	destroyed:	d5.w
*			d6.w
*			d7.w
*
thknop:		and.w	d2,d1
		move.w	thk_msk(fp),d6
		btst.b	#0,skew_msk+1(fp)	; was a skew performed?
		beq	thk00			; br if not
		ori.b	#$10,ccr
		roxr.w	#1,d6
		bcc	thk01
		move.w	#$8000,d6

thk01:		move.w	d6,thk_msk(fp)

thk00:		tst.w	dest_wrd(fp)
		bmi	thk0
		cmp.w	rite_msk(fp),d6
		bcc	thk0
		and.w	d6,d0
		bra	thk1

thk0:		clr.w	d0
		and.w	d6,d1

thk1:		move.w	smear(fp),d6
		move.w	d2,d5
		swap	d5
		move.w	rite_msk(fp),d5
		lsl.l	d6,d5

		swap	d5
		move.w	d5,d7
		swap	d5

		and.w	d7,d1
		and.w	d5,d0
		swap	d1
		move.w	d0,d1
		bra	thklpe

thkoplp:	move.l	d1,d0
		lsr.l	#1,d0
		or.l	d0,d1

thklpe:		dbra	d6,thkoplp
		move.w	d1,d0
		swap	d1
		move.w	thknjmp(fp),a4
		jmp	(a3,a4.w)

*************************************************
*    special effect THICKEN
*	on entry	d1.w	hi source word
*
*	on exit
*			d1.w	thickened hi source
*			thknover	bits that spill out
*
*	destroyed:	d5.w
*			d6.w
*
thknopw:	subq.b	#1,src_wrd+1(fp)
		bne	thk2
		and.w	thk_msk(fp),d1

thk2:		move.w	smear(fp),d6
		swap	d1
		clr.w	d1
		move.l	d1,d5
		bra	thkopwe

thkopwlp:	lsr.l	#1,d5
		or.l	d5,d1

thkopwe:	dbra	d6,thkopwlp
		move.w	d1,d5
		swap	d1
		or.w	thknover(fp),d1
		move.w	d5,thknover(fp)
		move.w	thknjpw(fp),a4
		jmp	(a3,a4.w)


*************************************************
*    special effect THICKEN
*	on entry	d1.w	hi source word
*
*	on exit
*			d1.w	thickened hi source
*			thknover	bits that spill out
*
*	destroyed:	d5.w
*			d6.w
*			d7.hi w
*
thknopwf:	move.w	thk_msk(fp),d6
		subq.b	#1,src_wrd+1(fp)
		bmi	thk3
		beq	thk4

*+
*  starting left fringe, do left mask only
*-
		subq.b	#1,src_wrd+1(fp)
		bne	thk11
		and.w	d6,d1

thk11:		and.w	left_msk(fp),d1
		bra	thk7

*+
* right fringe, source data invalid, erase..
*-
thk3:		clr.w	d1
		bra	thk5

*+
* right fringe, source data AND'd with source mask..
*-
thk4:		and.w	d6,d1

*+
* compute mask & count for next line..
*-
thk5:		tst.w	skew_msk(fp)
		bmi	thk6
		move.w	dest_wrd(fp),d5
		addq.w	#2,d5
		swap	d7
		move.w	rite_msk(fp),d7
		ori.b	#$10,ccr
		roxr.w	#1,d7
		bcc	thk33
		move.w	#$8000,d7
		addq.w	#1,d5

thk33:		cmpi.w	#1,left_msk(fp)
		bne	thk34
		subq.w	#1,d5

thk34:		ori.b	#$10,ccr
		roxr.w	#1,d6
		bcc	thk31
		move.w	#$8000,d6

thk31:		cmp.w	d6,d7
		bcs	thk35
		addq.w	#1,d5

thk35:		swap	d7
		move.w	d6,thk_msk(fp)
		move.b	d5,src_wrd(fp)

thk6:		move.b	src_wrd(fp),src_wrd+1(fp)

thk7:		move.w	smear(fp),d6
		swap	d1
		clr.w	d1
		move.l	d1,d5
		bra	thkopwfe

thkopwl:	lsr.l	#1,d5
		or.l	d5,d1

thkopwfe:	dbra	d6,thkopwl
		move.w	d1,d5
		swap	d1
		or.w	thknover(fp),d1
		move.w	d5,thknover(fp)
		and.w	d2,d1
		move.w	thknjpwf(fp),a4
		jmp	(a3,a4.w)

****************************************************
*   special effect LIGHT
*	on entry,	d1.w	hi source word
*			d0.w	lo source word
*
*	on exit,	d1.w	hi lite source word
*			d0.w	lo lite source word
*
*
liteop:		and.w	lite_msk(fp),d1
		and.w	lite_msk(fp),d0
		rol.w	lite_msk(fp)
		move.w	litejmp(fp),a4
		jmp	(a3,a4.w)

liteopw:	and.w	lite_msk(fp),d1
		move.w	litejpw(fp),a4
		jmp	(a3,a4.w)

liteopwf:	and.w	lite_msk(fp),d1
		move.w	litejpwf(fp),a4
		jmp	(a3,a4.w)

****************************************************
*   special effect SKEW
*
*	on entry,	d1.w	hi source word
*			d0.w	lo source word
*			d2.w	mask
*
*
*	on exit,	d1.w	hi skewized source word
*			d0.w	lo skewized source word
*			left_msk, rite_msk = rotated masks
*
*
skewop:		rol.w	skew_msk(fp)
		bcc	no_shift

		swap	d1
		move.w	d0,d1			; pack source words into long one (d1)
		lsr.l	#1,d1

		swap	d2
		move.w	rite_msk(fp),d2		; pack mask words into long one (d2)
		lsr.l	#1,d2
		move.w	d2,rite_msk(fp)
		swap	d2			; unpack mask words
		move.w	d2,left_msk(fp)
		beq	nxt_word
		move.w	shif_cnt(fp),d0
		bmi	dec_rol

ror_add:	addq.w	#1,d0

new_shif:	move.w	d0,shif_cnt(fp)
		move.w	d1,d0			; unpack skewized source words
		swap	d1

no_shift:	move.w	skewjmp(fp),a4
		jmp	(a3,a4.w)

dec_rol:	tst.b	d0
		beq	begn_ror
		subq.w	#1,d0
		bra	new_shif

begn_ror:	clr.w	d0
		bra	ror_add
*
*  we crossed a word boundary..
*
nxt_word:	move.w	d2,rite_msk(fp)		; 0h to right mask
		swap	d2
		move.w	d2,left_msk(fp)		; move right mask to left mask
		adda.w	nextwrd(fp),a1		; bump next destination address
		move.w	(a1),d4			; get the word we're really doing

		move.w	#15,d0
		sub.w	shif_cnt(fp),d0
		ori.w	#$8000,d0
		move.w	d0,shif_cnt(fp)
		bra	no_shift

********************************************************
*    special effect SKEW for words
*    recomputes rotation and jumps to proper routine to finish char
*
*
skewopw:	rol.w	skew_msk(fp)
		bcc	do_shift

		tst.w	shif_cnt(fp)
		bmi	mlt_left
		bra	mlt_rite

do_shift:	ori	#$10,ccr		; set x bit
		roxr.w	rota_msk(fp)		; one more bit into next word

		move.w	rite_msk(fp),d0
		cmp.w	#$FFFF,d0		; if mask is full on
		beq	inc_rite

		ori	#$10,ccr		; set x bit
		roxr.w	#1,d0			; rotate in a 1
		move.w	d0,rite_msk(fp)

do_left:	move.w	shif_cnt(fp),d0
		tst.b	d0
		bne	no_rota
		move.w	#$8000,rota_msk(fp)	; these are the bits that are good

no_rota:	move.w	left_msk(fp),d1
		lsr.w	#1,d1			; rotate in a 0
		beq	wnxt_wrd		; br if mask inoperative, inc addr

		move.w	d1,left_msk(fp)

		tst.w	d0
		bmi	wdec_rol
		addq.w	#1,shif_cnt(fp)
		bra	mlt_rite

wdec_rol:	tst.b	d0
		beq	set_msk
		subq.w	#1,shif_cnt(fp)		; do 1 less rol
		bra	mlt_left

set_msk:	move.w	#1,shif_cnt(fp)
		bra	mlt_rite

inc_rite:	addq.w	#1,dest_wrd(fp)		; spilled out of a word to get here
		move.w	#$8000,rite_msk(fp)
		bra	do_left			; go back & finish up

wnxt_wrd:	move.w	#$FFFF,left_msk(fp)	; ran out of word

		subq.w	#1,dest_wrd(fp)		; so more is in the fringe
		adda.w	nextwrd(fp),a1		; bump next destination address

		move.w	#15,d2
		sub.w	d0,d2			; d0 has old shif_cnt(fp)
		ori.w	#$8000,d2
		move.w	d2,shif_cnt(fp)

		bra	mlt_left


*************************************************
*
*	rotation in 90 degree increments
*
rotation:	move.w	LV(SOURCEX,a6),d1
		move.w	d1,d2
		andi.w	#$0F,d2
		move.w	d2,tsdad(fp)		; save source dot address
		lsr.w	#4,d1			; make byte address
		lsl.w	#1,d1

		movea.l	sform(fp),a0
		adda.w	d1,a0			; a0 -> source

		move.w	LV(DELX,a6),width(fp)
		move.w	LV(SOURCEY,a6),d0		; d0
		move.w	LV(DELY,a6),d1		; d1
		move.w	d1,height(fp)
		move.w	s_next(fp),d2		; d2

		bsr	getdest			; get destination in a1

		move.w	LV(CHUP,a6),d6		; keep CHUP around for a while
		cmpi.w	#1800,d6
		beq	upsd_dwn

rot90:		cmpi.w	#900,d6
		beq	top_src

		neg.w	s_next(fp)		; go up 1 line
		subq.w	#1,d1
		add.w	d1,d0			; start at bottom
		mulu	d2,d0			; get mem address of start corner
		adda.w	d0,a0			; 04 Nov 86   HANDLE FORMS > 32k

top_src:	move.w	LV(DELY,a6),d0
		lsr.w	#4,d0
		lsl.w	#1,d0
		addq.w	#2,d0			; form width is height / 8 + 1
		move.w	d0,d_next(fp)

		move.l	a1,-(sp)		; save destination ptr

		cmpi.w	#2700,d6		; cmp CHUP
		beq	top_dwn			; top down is good programmin'

		neg.w	d_next(fp)		; bottom working up
		move.w	LV(DELX,a6),d1		; d1 <- height
		subq.w	#1,d1			; d1 <- height -1
		mulu	d1,d0			; d0 <- offset to bottom of char dst
		adda.w	d0,a1			; HANDLE DST > 32k


top_dwn:	move.w	tsdad(fp),d2
		move.w	#$8000,d3		; d3
		move.w	d3,d4			; d4 1st bit of scratch area
		lsr.w	d2,d3
		moveq	#0,d0			; d0
		move.w	width(fp),d2		; d2 pixels in source row
		move.w	s_next(fp),d6
		bra	rot_nsrc

rot_ylp:	move.w	height(fp),d1
		movem.l	a0-a1/d4,-(sp)
		bra	rot_srt

rot_xlp:	move.w	(a0),d7
		and.w	d3,d7
		beq	rot_nor
		or.w	d4,d0

rot_nor:	ror.w	#1,d4
		bcc	rot_isrc

rot_ndst:	move.w	d0,(a1)
		addq.l	#2,a1
		moveq	#0,d0

rot_isrc:	adda.w	d6,a0			; add source_next to source ptr

rot_srt:	dbra	d1,rot_xlp
		move.w	d0,(a1)
		moveq	#0,d0
		movem.l	(sp)+,a0-a1/d4
		adda.w	d_next(fp),a1
		ror.w	#1,d3
		bcc	rot_nsrc
		addq.l	#2,a0

rot_nsrc:	dbra	d2,rot_ylp


rot_done:	move.l	(sp)+,a1		; reget former destination ptr

		move.w	LV(DELX,a6),d0
		move.w	LV(DELY,a6),d1
		move.w	d1,width(fp)
		move.w	d1,LV(DELX,a6)
		move.w	d0,height(fp)
		move.w	d0,LV(DELY,a6)

		move.w	tmp_dely(fp),d0	; Must swap tmps too RJG 4/13/85
		move.w	tmp_delx(fp),tmp_dely(fp)
		move.w	d0,tmp_delx(fp)
		move.w	#1,swap_tmps(fp)

		move.w	d_next(fp),d0
		cmpi.w	#900,LV(CHUP,a6)
		bne	rot_nneg
		neg.w	d0

rot_nneg:	move.w	d0,s_next(fp)

repexit:	clr.w	LV(SOURCEX,a6)

		clr.w	LV(SOURCEY,a6)
		move.l	a1,sform(fp)
		rts

upsd_dwn:	move.w	LV(DELX,a6),d0		; a0 -> top of source
		add.w	tsdad(fp),d0
		subq.w	#1,d0			; make width instead of address
		lsr.w	#4,d0
		lsl.w	#1,d0			; make it even byte address
		addq.w	#2,d0			; form width is DELX / 8 + 1
		move.w	d0,d_next(fp)

		move.w	d0,d2
		lsr.w	#1,d2			; d2 <- words to move per line
		subq.w	#1,d2			; for dbra, my sweetie
		mulu	d1,d0			; d0 <- offset to bottom of new form

		move.l	a1,-(sp)		; save destination ptr

		adda.w	d0,a1			; a1 -> last word in form
		bra	strtflip

upsd_lp:	movea.l	a0,a2			; use a2 as working source
		move.w	d2,d3			; copy words per line to temp

line_lp:	move.w	(a2)+,d0
		moveq	#0,d5
		move.w	#15,d4

flip_lp:	lsr.w	#1,d0
		roxl.w	#1,d5
		dbra	d4,flip_lp

		move.w	d5,-(a1)		; store in buffer pre-decrement
		dbra	d3,line_lp

		adda.w	s_next(fp),a0		; dest (a2) is already updated

strtflip:	dbra	d1,upsd_lp

		move.w	d_next(fp),s_next(fp)

		move.l	(sp)+,a1		; reget former destination ptr

		move.l	a1,sform(fp)
		move.w	LV(SOURCEX,a6),d0
		add.w	LV(DELX,a6),d0
		neg.w	d0
		andi.w	#$F,d0			; location of last bit in original
		move.w	d0,LV(SOURCEX,a6)
		clr.w	LV(SOURCEY,a6)
		rts

*************************************************
*
*	replication by two
*
*
replicat:	move.w	LV(SOURCEX,a6),d0
		move.w	d0,d4
		andi.w	#$0F,d0			; d0 <- source dot address
		move.w	d0,tsdad(fp)

		lsr.w	#4,d4
		lsl.w	#1,d4			; d4 <- offset to 1st word of char

		move.w	LV(SOURCEY,a6),d0
		mulu	s_next(fp),d0		; d0 <- offset to bottom of form

		add.w	d4,d0
		movea.l	sform(fp),a0		; HANDLE FORMS > 32k
		adda.w	d0,a0			; a0 -> bottom of character

		move.w	tsdad(fp),d2		;
		move.w	#$8000,d3		; d3
		move.w	d3,d4			; d4
		lsr.w	d2,d3

		move.w	LV(DELY,a6),d2
		move.w	LV(DELX,a6),d1

		move.w	d2,height(fp)		; d2 <- # of rows to duplicate
		move.w	d1,width(fp)

		bsr	getdest			; get destination ptr in a1

*
*  outlining, expand buffer size all around perimeter
*
noline:		lsr.w	#3,d1
		lsl.w	#1,d1
		addq.w	#2,d1

noline1:	move.w	d1,d_next(fp)
		move.l	a1,a3			; save for use later

		move.w	LV(T_SCLSTS,a6),d7
		roxr.l	#1,d7
		moveq	#0,d7
		roxr.l	#1,d7

		move.w	s_next(fp),d7
		move.w	LV(DDA_INC,a6),d2
		move.w	height(fp),d5
		subq.w	#1,d5
		move.w	#32767,d6
		tst.l	d7
		bmi	rep_ylop

y_dwn_lp:	add.w	d2,d6
		bcc	y_no_drw
		bsr	yloop

y_no_drw:	adda.w	d7,a0
		dbra	d5,y_dwn_lp
		bra	y_rep_don

rep_ylop:	add.w	d2,d6
		bcc	y_no_rep
		bsr	yloop

y_no_rep:	bsr	yloop
		adda.w	d7,a0
		dbra	d5,rep_ylop

y_rep_don:	move.w	LV(DELX,a6),d2
		move.w	LV(XACC_DDA,a6),d1
		move.w	LV(DDA_INC,a6),d0
		moveq	#0,d3
		bra	nrpndoub		; enter at end of dbra.

repwidcl:	add.w	d0,d1
		bcc	nrepdoub
		addq.w	#1,d3

nrepdoub:	tst.l	d7
		bpl	nrpndoub
		addq.w	#1,d3

nrpndoub:	dbra	d2,repwidcl
		move.w	d1,LV(XACC_DDA,a6)
		move.w	d3,LV(DELX,a6)
		move.w	tmp_dely(fp),LV(DELY,a6)
		move.w	d_next(fp),d1
		move.w	d1,s_next(fp)

repexit1:	move.l	LV(scrtchp,a6),a1		; this one guaranteed former dest
		bra	repexit

***************************************************
*
*  yloop routine
*
*
*  entry:	d1 = d_next		preserved
*		d2 = DDA_INC		preserved
*		d3 = source bitmask	destroyed
*		d4 = dest bitmask	destroyed
*
*		a0 = source ptr		preserved
*		a1 = destination ptr	adjusted for next
*
*  reg use:  	d0 = grafix build
*		d1 = d_next
*		d2 = DDA_INC
*		d3 = source bitmask
*		d4 = dest bitmask
*		d5 = width
*		d6 = temp
*		d7 = XACC_DDA
*
*		a0 = source ptr
*		a1 = destination ptr
*		a2 = source data temp
*
*
*
yloop:		movem.l	a0-a1/d3-d7,-(sp)	; save some regs
		moveq	#0,d0			; clear grafix
		move.w	width(fp),d5
		subq.w	#1,d5			; adjust for dbra

		move.w	LV(XACC_DDA,a6),d7
		bra	nextsrc

innerlp:	ror.w	#1,d3
		bcc	reploop

nextsrc:	movea.w	(a0)+,a2

reploop:	move.w	a2,d6
		and.w	d3,d6
		bne	nrepnor

repnor:		tst.l	d7
		bmi	repnorup
		add.w	d2,d7
		bcc	incsrc
		bra	ordone

repnorup:	add.w	d2,d7
		bcc	ordone
		ror.w	#1,d4
		bcc	ordone
		move.w	d0,(a1)+
		moveq	#0,d0

		bra	ordone

nrepnor:	add.w	d2,d7
		bcc	o_no_rep

		or.w	d4,d0
		ror.w	#1,d4

		bcc	o_no_rep
		move.w	d0,(a1)+
		moveq	#0,d0

o_no_rep:	tst.l	d7
		bpl	incsrc

		or.w	d4,d0

ordone:		ror.w	#1,d4
		bcc	incsrc

nextdst:	move.w	d0,(a1)+
		moveq	#0,d0

incsrc:		dbra	d5,innerlp

repdone:	move.w	d0,(a1)
		movem.l	(sp)+,a0-a1/d3-d7
		adda.w	d1,a1
		rts

******************************************************
*
*   Get new destination ptr
*
*  entry:	none
*  exit:	a1 -> free buffer
*
*	buffree(fp) is updated to be offset to other buffer, to become free
*	all other regs preserved
*
getdest:	move.w	d7,-(sp)
		move.l	LV(scrtchp,a6),a1
		move.w	buffree(fp),d7
		beq	getdest1

		adda.w	d7,a1
		clr.w	buffree(fp)
		bra	getdest2

getdest1:	move.w	LV(scrpt2,a6),buffree(fp)

getdest2:	move.w	(sp)+,d7
		rts


******************************************************
*
*   Outline the contents of buffer
*
*
*
*
*  a0 -> top line of buffer (to be used as temp line buffer, assumed cleared)
*  d6 = # of vertical lines
*  d7 = form width in bytes (must be even)
*
outlin:		lea	(a0,d7.w),a1	; bump mid line to "real" top line

outlin1:	lea	(a1,d7.w),a2	; set up a2 to point to 1 line below current
		lsr.w	#1,d7		; # of words in horz line
		subq.w	#1,d7		; for "dbra" sweetie
		move.w	LV(DELY,a6),d6	; # of vertical lines
		bra.w	srt_lin

out_edge:	movem.l	a0-a2/d6-d7,-(sp) ; save ptrs & counters
		moveq	#0,d5
		moveq	#0,d6
		move.l	(a2),d1		; get bottom line/left edge grafix data
		lsr.l	#1,d1		; clear left-most bit too
*
*  within line loop entry point..
*
out_loop:	move.l	(a0),d0		; get next top line grafix data
		move.b	d5,d0		; put bit to left of current data in bit 0
		ror.l	#1,d0		; now its L 15 14 13 ... 1 0 R X X X...

		move.l	(a1),d2		; get current line data
		move.b	d6,d2		; same trick
		move.l	d2,d3		; d2 is left-shifted current
		ror.l	#1,d3		; d3 is 0 shifted current
		move.l	d3,d4
		ror.l	#1,d4		; d4 is right-shifted current

		move.l	d0,d5		; get copy of top line
		move.l	d0,d6		; get 2nd copy
		eor.l	d2,d0		; exclusive neighbor #1
		eor.l	d3,d5		; exclusive neighbor #2
		eor.l	d4,d6		; exclusive neighbor #3
		rol.l	#1,d5		; adjust 0 shifted for final
		rol.l	#2,d6		; adjust right shifted too
		or.l	d5,d0		; form exclusive accumulator
		or.l	d6,d0

		move.l	d1,d5		; now start with a copy of bottom line
		move.l	d1,d6		; need second copy
		eor.l	d2,d1		; exclusive neighbor #4
		eor.l	d3,d5		; exclusive neighbor #5
		eor.l	d4,d6		; exclusive neighbor #6
		rol.l	#1,d5		; adjust 0 shifted for final
		rol.l	#2,d6		; adjust right shifted too
		or.l	d1,d0
		or.l	d5,d0
		or.l	d6,d0

		eor.l	d3,d2		; exclusive neighbor #7
		eor.l	d3,d4		; exclusive neighbor #8
		rol.l	#2,d4
		or.l	d2,d0
		or.l	d4,d0
		swap	d0

		move.w	(a1),d6
		move.w	d6,d5
		eor.w	d0,d5
		and.w	d0,d5

		addq.l	#2,a2		; advance bottom line to next word
		move.l	(a2),d1		; get next bottom line grafix data
		move.b	-1(a2),d1	; same trick as with top line
		ror.l	#1,d1		; now its L 15 14 13 ... 1 0 R X X X...

		move.w	d5,(a1)+
		move.w	(a0),d5
		move.w	d6,(a0)+

		dbra	d7,out_loop	; finish rest of line

		movem.l	(sp)+,a0-a2/d6-d7	; save ptrs & counters
		move.l	a2,a1
		adda.w	s_next(fp),a2
		cmpi.w	#1,d6
		bne	srt_lin
		move.l	a1,a2

srt_lin:	dbra	d6,out_edge
		rts
