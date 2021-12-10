/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:28:39 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:28:39  mui
 * TT
 *
 * Revision 2.1  89/02/22  05:30:41  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.3  88/07/01  16:22:43  mui
 * move dos_space C code to deskinf.c
 *
 * Revision 1.2  88/07/01 15:50:13  mui
 * comment out dos_space
 *
 * Revision 1.1  88/06/02  12:35:45  lozben
 * Initial revision
 *
 *************************************************************************
 *	.title	'GEMDOS Bindings for AES/Desktop'
 *	Bug fixed 2/5/87
 *	Added global definition	11/30/87	D.Mui
 *	Add do_cdir		1/28/88		D.Mui
 *	Use MAC to assemble	6/29/90		D.Mui
 * assemble with MAS 900801 kbad

 *----------------
 *
 *  Edit History
 *
 *  2-Feb-1987 lmd	Converted from stupid C code.  Original size
 *			was $57E text, $2 data.
 *  ...
 *     and now its $660 text, 8 bss, and thats better??
 */

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"
#include "dos.h"


#define CCODE 0

/*----------------
 *
 *  Exports
 */

	xdef	_DOS_AX
	xdef	_DOS_ERR
	comm _DOS_AX,2
	comm _DOS_ERR,2


/*----------------
 *
 *  Dos function numbers
 */
X_TABOUT	equ $02
X_PRTOUT	equ $05
X_RAWCON	equ $06
X_SETDRV	equ $0E
X_GETDRV	equ $19
X_SETDTA	equ $1A
X_GETFREE	equ $36
X_MKDIR		equ $39
X_RMDIR		equ $3A
X_CHDIR		equ $3B
X_CREAT		equ $3C
X_OPEN		equ $3D
X_CLOSE		equ $3E
X_READ		equ $3F
X_WRITE		equ $40
X_UNLINK	equ $41
X_LSEEK		equ $42
X_CHMOD		equ $43
X_GETDIR	equ $47
X_MALLOC	equ $48
X_MFREE		equ $49
X_SETBLOCK	equ $4A
X_EXEC		equ $4B
X_SFIRST	equ $4E
X_SNEXT		equ $4F
X_RENAME	equ $56
X_GSDTOF	equ $57
*	.LIST


/*----------------
 *
 *  I know what this does, but I don't
 *  know why it's supposed to do it.
 */
/* 306de: 00e25994 */
/* 104de: 00fdcf4e */
/* 106de: 00e1e546 */
	xdef	_isdrive
_isdrive:
	bsr	dos_gdrv		; get current drive number
	move.w	d0,-(sp)		; and make it the current
	bsr	dos_sdrv		;    drive again...
	addq	#2,sp
	rts


nullstr: dc.b	0,0			; an empty string, for _pgmld()

/*----------------
 *
 *  Local jump-to-trap-handler
 */
jtrap:	jmp	_trap			; jump to _trap



#if CCODE
  WORD pgmld(WORD handle, const char *pname, LONG **ldaddr)
  {
  	LONG	length;
  	LONG	*temp;

  	*ldaddr = trap(X_EXEC,3,pname,"",NULLPTR);
  	if (!DOS_ERR)
  	{			 /* code+data+bss lengths */
  	  temp = *ldaddr;
  	  length = temp[3] + temp[5] + temp[7] + 0x100;
  	  trap(X_SETBLOCK,0, *ldaddr, length);
  	  if (!DOS_ERR)
  	    return(TRUE);
  	  else
  	    return(-1);
  	}
  	else
  	  return(-1);
  }
#endif
/*
 *		4       6       $a
 *	.cargs .handle .pname.l .ldaddr.l
 */
/* 306de: 00e259aa */
/* 106de: 00e1e55c */
	xdef	_pgmld
_pgmld:
	clr.l	-(sp)			; null env string (inherit parent's)
	pea	nullstr(pc)		; empty command tail
	move.l	6+8(sp),-(sp)		; &filename
	move.l	#$004b0003,-(sp)	; Pexec(3, ...): load, no-go
	bsr	jtrap
	add.w	#16,sp
	bne.b	pg_fal			; punt on load failure

	move.l	$a(sp),a0		; *ldaddr = &basepage
	move.l	d0,(a0)
	move.l	d0,a0			; a0 -> basepage

	move.l	#$100,d0		; compute size of program we loaded
	add.l	3*4(a0),d0
	add.l	5*4(a0),d0
	add.l	7*4(a0),d0

	move.l	d0,-(sp)		; = size to keep
	move.l	a0,-(sp)		; = address of block
	move.l	#$004a0000,-(sp)	; Mshrink(0, ...)
	bsr	jtrap
	add.w	#12,sp
	/* BUG: should also adjust p_hitpa in the basepage */
	beq.b	rettrue			; return OK on shrink success

pg_fal:	moveq	#-1,d0			; return -1L
	rts


/*----------------
 *
 *  Return 0 (FALSE)
 */
retfalse:	moveq	#0,d0
	rts


/*----------------
 *
 *  Return 1 (TRUE)
 */
rettrue:	moveq	#1,d0
	rts


/*----------------
 *
 *  Print a bell on the console (hard BIOS console)
 */
#if 0
	xdef	_bellout
_bellout:
	move.w	#7,-(sp)			; Bconout(CON, 7)
	move.l	#$00030002,-(sp)
	trap	#13
	addq	#6,sp
	rts
#endif



#if CCODE
  WORD dos_sfirst(const char *name, int attrib)
  {
  	REG LONG		ret;
  	ret = trap(X_SFIRST,pspec,attr);
  	if (!ret)
  	  return(TRUE);
  	if ( ret == E_NMFIL || ret == E_FILNF )
  	{
  	  DOS_AX = E_NOFILES;
  	  return(FALSE);
  	}
  	else
  	  return(FALSE);
  }
#endif
/*
 *		4	 8
 *	 .cargs .pspec.l .attr.w	; ->name, =searchAttributes
 */
/* 306de: 00e259fa */
/* 106de: 00e1e5ac */
	xdef	_dos_sfirst
_dos_sfirst:
	move.w	8(sp),-(sp)		; push attributes
	move.l	4+2(sp),-(sp)		; push &name
	move.w	#$4e,-(sp)		; push function#
	bsr	jtrap			; Fsfirst(...)
	addq	#8,sp

sfsn:	tst.w	d0			; if (d0 == 0) return TRUE;
	beq	rettrue

	cmp.w	#E_NMFIL,d0		; if (d0 == E_NMFIL ||
	beq.b	sf_1
	cmp.w	#E_FILNF,d0		;     d0 == E_FILNF)
	bne.b	sf_2
sf_1:	move.w	#E_NOFILES,_DOS_AX	;    DOS_AX = E_NOFILES;
sf_2:	bra	retfalse			; return FALSE



#if CCODE
  WORD dos_snext()
  {
  	REG LONG		ret;
  	ret = trap(X_SNEXT);
  	if (!ret)
  	  return(TRUE);
  	if ( ret == E_NMFIL || ret == E_FILNF )
  	{
  	  DOS_AX = E_NOFILES;
  	  return(FALSE);
  	}
  	else
  	  return(FALSE);
  }
#endif
/* 306de: 00e25a24 */
/* 106de: 00e1e5d6 */
	xdef	_dos_snext
_dos_snext:
	move.w	#X_SNEXT,-(sp)		; Fsnext()
	bsr	jtrap
	addq	#2,sp
	bra	sfsn			; [common sfirst/snext return handler]


#if CCODE
  WORD  dos_open(const char *pname, int access)
  {
  	LONG		ret;

  	ret = trap(X_OPEN,pname,access);
  	if (ret == E_FILNF)
  	  DOS_AX = E_FILENOTFND;
  	if (DOS_ERR)
  	  return(FALSE);
  	else
  	  return((UWORD)ret);
  }
#endif
/*
 *		4	 8
 *	 .cargs .pname.l .access.w
 */
/* 306de: 00e25a30 */
/* 106de: 00e1e5e2 */
	xdef	_dos_open
_dos_open:
	move.w	8(sp),-(sp)
	move.l	4+2(sp),-(sp)
	move.w	#X_OPEN,-(sp)
	bsr	jtrap
	addq	#8,sp

	cmp.w	#E_FILNF,d0
	bne.b	open_1
	move.w	#E_FILENOTFND,_DOS_AX

open_1:	tst.w	d1
	bne	retfalse
	rts



#if CCODE
  WORD dos_read(int handle, size_t cnt, void *pbuffer)
  {
  	LONG		ret;
  	ret = trap(X_READ,handle,(ULONG)cnt,pbuffer);
  	return((UWORD)ret);
  }

  WORD dos_write(int handle, size_t cnt, const void *pbuffer)
  {
  	LONG		ret;
  	ret = trap(X_WRITE,handle,(ULONG)cnt,pbuffer);
  	return( (UWORD)ret);
  }
#endif
/* 306de: 00e25a56 */
	xdef	_dos_read
_dos_read:	moveq	#X_READ,d1
		bra.b	rw

	xdef	_dos_write
_dos_write:	moveq	#X_WRITE,d1

/*
 *		4         6        8
 *	.cargs	.handle.w .count.w .pbuffer.l
 */
rw:
	move.l	8(sp),-(sp)		; pbuffer
	moveq	#0,d0
	move.w	6+4(sp),d0		; count
	move.l	d0,-(sp)
	move.w	4+8(sp),-(sp)		; handle
	move.w	d1,-(sp)		; X_READ or X_WRITE
	bsr	jtrap			; do trap
	add.w	#12,sp
	rts



#if CCODE
  LONG dos_lseek(int handle, int smode, long sofst)
  {
  	return( trap(X_LSEEK,sofst, handle, smode) );
  }
#endif
/*
 *		4       6       8
 *	 .cargs .handle .smode .sofst.l
 */
	xdef	_dos_lseek
_dos_lseek:
	move.l	4(sp),-(sp)		; handle & smode
	move.l	4+8(sp),-(sp)		; softst
	move.w	#X_LSEEK,-(sp)
	bsr	jtrap
	add.w	#10,sp
	rts



#if CCODE
  WORD dos_gdir(int drive, char *pdrvpath)
  {
  	return(trap(X_GETDIR,pdrvpath,drive));
  }
#endif
/*
 *		4        6
 *	 .cargs .drive.w .pdrvpath.l
 */
	xdef	_dos_gdir
_dos_gdir:
	move.w	4(sp),-(sp)		; drive
	move.l	6+2(sp),-(sp)		; pdrvpath
	move.w	#X_GETDIR,-(sp)
	bsr	jtrap
	addq	#8,sp
	rts


/* 306de: 00e25aa2 (unused) */
#if CCODE
  WORD dos_mkdir(const char *path, int attr)
  {
  	LONG	ret;

  	ret = trap(X_MKDIR,path);
  	if (ret == E_ACCDN)
  	  DOS_AX = E_NOACCESS;
  	return( !DOS_ERR );
  }
#endif
/*
 *		4       8
 *	 .cargs .path.l .attr
 */
	xdef	_dos_mkdir
_dos_mkdir:
	move.l	4(sp),-(sp)		; path
	move.w	#X_MKDIR,-(sp)
	bsr	jtrap
	addq	#6,sp

	cmp.w	#E_ACCDN,d0
	bne.b	mkd_1
	move.w	#E_NOACCESS,_DOS_AX
mkd_1:	move.w	d1,d0			; return (!DOS_ERR)
	eor.w	#1,d0
	rts


/* 306de: 00e25ac6 (unused) */
#if CCODE
  WORD dos_set(int h, unsigned short time, unsigned short date)
  {
  	UWORD	buf[2];

  	buf[0] = time;
  	buf[1] = date;
  	return( trap(X_GSDTOF,&buf[0],h,TRUE) );
  }
#endif
/*
 *		4   6    8
 *	 .cargs .h .time .date
 */
	xdef	_dos_set
_dos_set:
	move.w	#$0001,-(sp)		; TRUE
	move.w	4+2(sp),-(sp)		; h
	pea	6+4(sp)			; &time+date
	move.w	#X_GSDTOF,-(sp)
	bsr	jtrap
	add.w	#10,sp
	rts


/* 306de: 00e25ae0 (unused) */
#if CCODE
  WORD dos_label(int drive, const char *plabel)
  {
  	BYTE	buf[50];		/* 44 bytes used	*/
  	BYTE	path[8];
  	WORD	ret;

  	bfill(50,NULL,&buf[0]);
  	trap(X_SETDTA,&buf[0]);
  	path[0] = (drive + 'A') - 1;
  	path[1] = ':';
  	path[2] = '\\';
  	path[3] = '*';
  	path[4] = '.';
  	path[5] = '*';
  	path[6] = 0;
  	ret = trap(X_SFIRST,path,0x08);
  	if (!ret)
  	{
  	  xstrpcpy(&buf[30],plabel);
  	  return(TRUE);
  	}
  	else
  	{
  	  DOS_ERR = DOS_AX = TRUE;
  	  return(FALSE);
  	}
  }
#endif
/*
 *		    8	    10
 *	 .cargs #8, .drive .plabel
 */
la_buf	equ	-(44)
la_path	equ	-(44+8)
	xdef	_dos_label
_dos_label:
	link	a6,#la_path		; make room for args

	pea	la_buf(a6)		; Setdta #la_buf
	move.w	#X_SETDTA,-(sp)
	trap	#1
	addq	#6,sp

	lea	la_path(a6),a0
	move.b	8+1(a6),d0		; drive
	add.b	#$40,d0			; 'A' - 1
	move.b	d0,(a0)+
	lea	la_string(pc),a1
la_1:	move.b	(a1)+,(a0)+
	bne.b	la_1

	move.w	#$08,-(sp)
	pea	la_path(a6)
	move.w	#X_SFIRST,-(sp)
	bsr	jtrap
	addq	#8,sp

	tst.w	d0
	bne.b	la_err
	lea	la_buf+30(a6),a1
	move.l	10(a6),a0		; plabel
la_2:	move.b	(a1)+,(a0)+
	bne.b	la_2
	unlk	a6
	bra	rettrue

la_err:	moveq	#1,d0
	move.w	d0,_DOS_ERR
	move.w	d0,_DOS_AX
	unlk	a6
	bra	retfalse

la_string:	dc.b	':\*.*',0
		even



/*
 *   This conversion assumes no more than 65535 sectors on a media
 *   (which is "good enough" given our current state of affairs)
 */
#if CCODE
  WORD dos_space(int drv, long *ptotal, long *pavail)
  {
  	LONG	buf[4];
  	LONG	mult;

  	trap(X_GETFREE,buf,drv);	/* changed  0=A for gemdos	*/
  	mult = buf[3] * buf[2];
  	*ptotal = mult * buf[1];
  	*pavail = mult * buf[0];
  	return(TRUE);
  }
#endif
/*
 *		   8      10        14
 *	.cargs #8, .drv.w .ptotal.l .pavail.l
 *
 *sp_buf	=	-16
 */
#if 0
	xdef	_dos_space
_dos_space:
	link	a6,#sp_buf
	move.w	8(a6),-(sp)		; drv
	pea	sp_buf(a6)
	move.w	#X_GETFREE,-(sp)
	trap	#1
	addq	#8,sp

	move.w	sp_buf+14(a6),d0	; d0 = buf[3] * buf[2]
	mulu	sp_buf+10(a6),d0
	move.w	d0,d1

	movem.l	10(a6),a0-a1		; a0 = ptotal, a1 = pavail
	mulu	4+sp_buf+2(a6),d0	; *ptotal = d0 * buf[1]
	move.l	d0,(a0)
	mulu	sp_buf+2(a6),d1		; *pavail = d0 * buf[0]
	move.l	d1,(a1)

	moveq	#1,d0			; return TRUE
	unlk	a6
	rts
#endif


/* 306de: 00e25b48 (unused) */
#if CCODE
  WORD dos_rename(const char *p1, const char *p2)
  	BYTE	*p1;
  	BYTE	*p2;
  {
  	return(trap(X_RENAME,0x0,p1,p2) );
  }
#endif
	xdef	_dos_rename
_dos_rename:
	move.l	(sp)+,retaddr
	move.l	#$00560000,-(sp)	; X_RENAME + $0000
	bsr	jtrap
	addq	#4,sp
	move.l	retaddr,a0
	jmp	(a0)


/* 306de: 00e25b62 */
/* 106de: 00e1e714 */
#if CCODE
  LONG dos_alloc(long nbytes)
  {
  	LONG		ret;

  	if (nbytes & 1)
  	  nbytes += 1;			/* get on boundary	*/
  	ret = trap(X_MALLOC,nbytes);
  	if (ret == 0 )
  	{
  	  DOS_ERR = TRUE;
  	  return(0);
  	}
  	if (ret & 0x1L )
  	  ret += 1;
  	return(ret);
  }
#endif
	xdef	_dos_alloc
_dos_alloc:
	move.l	4(sp),d0		; nbytes
	btst	#0,d0
	beq.b	al_1
	addq.l	#1,d0

al_1:	move.l	d0,-(sp)
	move.w	#X_MALLOC,-(sp)
	trap	#1
	addq	#6,sp

	tst.l	d0
	bne.b	al_2
	move.w	#1,_DOS_ERR
	rts

al_2:	btst	#0,d0
	beq.b	al_3
	addq.l	#1,d0
al_3:	rts


#if CCODE
  LONG dos_avail()
  {
  	return( trap( X_MALLOC, -1L) );
  }
#endif
	xdef	_dos_avail
_dos_avail:
	moveq	#-1,d0
	move.l	d0,-(sp)
	move.w	#X_MALLOC,-(sp)
	trap	#1
	addq	#6,sp
	rts


/*----------------
 *
 *  "Generic" calls
 *  where we make a GEMDOS trap with the
 *  arguments on the stack unchanged.
 */
	xdef	_chrout
_chrout:	moveq	#X_TABOUT,d1
		bra.b	generic

	xdef	_rawcon
_rawcon:	moveq	#X_RAWCON,d1
		bra.b	generic

	xdef	_prt_chr
_prt_chr:
		moveq	#X_PRTOUT,d1
		bra.b	generic

	xdef	_dos_gdrv
_dos_gdrv:
dos_gdrv:
		moveq	#X_GETDRV,d1
		bra.b	generic

	xdef	_dos_sdta
_dos_sdta:	moveq	#X_SETDTA,d1
		bra.b	generic

	xdef	_dos_close
_dos_close:	moveq	#X_CLOSE,d1
		bra.b	generic

	xdef	_dos_chdir
_dos_chdir:	moveq	#X_CHDIR,d1
		bra.b	generic

	xdef	_dos_sdrv
_dos_sdrv:
dos_sdrv:
		moveq	#X_SETDRV,d1
		bra.b	generic

	xdef	_dos_chmod
_dos_chmod:	moveq	#X_CHMOD,d1
		bra.b	generic

	xdef	_dos_delete
_dos_delete:	moveq	#X_UNLINK,d1
		bra.b	generic

	xdef	_dos_rmdir
_dos_rmdir:	moveq	#X_RMDIR,d1
		bra.b	generic

	xdef	_dos_create
_dos_create:	moveq	#X_CREAT,d1
		bra.b	generic

	xdef	_dos_free
_dos_free: ds.b 0
	xdef	_dos_ffree
_dos_ffree: ds.b 0
	moveq	#X_MFREE,d1

generic:
	move.l	(sp)+,retaddr		; save return address
	move.w	d1,-(sp)		; push trap
	bsr	jtrap			; trap to GEMDOS
	addq	#2,sp			; cleanup function#
	move.l	retaddr,a0		; load return address
	jmp	(a0)			; ... anvd return

	bss
	xdef retaddr
	comm retaddr,4		; saved return address
	text



/*----------------
 *
 *  GEMDOS Trap binding
 *
 *    Returns:	EQ+D1=0, no "dos error"
 *		NE+D1=1, "dos error" condition
 *
 *	xdef	_trap		; replace old trap() call
 */
_trap:
	move.l	(sp)+,tr_retsave	; save return address
	trap	#1			; do GEMDOS trap
	moveq	#0,d1			; assume no error
	move.w	d0,_DOS_AX		; save WORD return value
	tst.l	d0			; 2/5/87
	bge.b	tr_1			; >=0 means no error
	moveq	#1,d1			; we guessed wrong, set error flag
tr_1:	move.w	d1,_DOS_ERR		; copy error condition to global var.
	move.l	tr_retsave,a0		; return to caller
	jmp	(a0)


/*
 *	do_cdir(WORD drive, char *path)
 */
	xdef	_do_cdir
_do_cdir:
	move.w	4(sp),-(sp)		; change the drive first
	move.w	#X_SETDRV,-(sp)
	jsr 	jtrap
	/* BUG: does a Dsetpath even if Dsetdrv() fails */
	move.l	10(sp),-(sp)		; change the directory
	move.w	#X_CHDIR,-(sp)
	jsr	jtrap
	add	#10,sp
	rts



    bss
    xdef tr_retsave
	comm tr_retsave,4
