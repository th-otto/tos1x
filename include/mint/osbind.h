/************************************************************************/
/*	OSBIND.H	#defines for GEMDOS,BIOS & XBIOS binding	*/
/* 		started 5/2/85 .. Rob Zdybel				*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

#ifndef __OSBIND_H__
#define __OSBIND_H__ 1

#ifndef __COMPILER_H__
# include <compiler.h>
#endif
#ifndef __OSTRUCT_H__
# include <ostruct.h>
#endif

extern	long bios PROTO((short code, ...));
extern	long xbios PROTO((short code, ...));
extern	long gemdos PROTO((short code, ...));

#ifdef __GNUC__
#ifdef __mc68000__

#define t1_w(n)							\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"addql	#2,%%sp\n\t"					\
	: "=r"(__retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	__retvalue;							\
})

#define t1_ww(n, a)							\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"addql	#4,%%sp"						\
	: "=r"(__retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	__retvalue;							\
})

#define t1_wlw(n, a, b)						\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	short _b = (short)(b);						\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"addql	#8,%%sp"						\
	: "=r"(__retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	__retvalue;							\
})

#define t1_wwll(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%4,sp@-\n\t"					\
		"movl	%3,sp@-\n\t"					\
		"movw	%2,sp@-\n\t"					\
		"movw	%1,sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	sp@(12),sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define t14_wlll(n, a, b, c)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%4,sp@-\n\t"					\
		"movl	%3,sp@-\n\t"					\
		"movl	%2,sp@-\n\t"					\
		"movw	%1,sp@-\n\t"					\
		"trap	#14\n\t"					\
		"lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define t14_wl(n, a)						\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#14\n\t"					\
		"addql	#6,%%sp"						\
	: "=r"(__retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	__retvalue;							\
})

#endif
#endif

#ifndef t1_wwll
#define t1_w gemdos
#define t1_wlw gemdos
#define t1_ww gemdos
#define t1_wwll gemdos
#define t14_wl xbios
#define t14_wlll xbios
#endif


#define VEC_INQUIRE            (-1L)

/*	BIOS	(trap13)	*/
#define	Bconstat(a)	bios(1,a)
#define	Bconin(a)	bios(2,a)
#define	Bconout(a,b)	bios(3,a,b)
#define	Rwabs(a,b,c,d,e)	bios(4,a,b,c,d,e)
#define	Setexc(a,b)	bios(5,a,b)
#define Getbpb(dev)	bios(7,dev)		/* not in original */
#define	Bcostat(a)	bios(8,a)
#define	Mediach(a)	bios(9,a)
#define	Drvmap()	bios(10)
#define	Kbshift(a)	bios(11,a)		/* was Getshift() */

/*	XBIOS	(trap14)	*/
#define	Initmous(a,b,c)	xbios(0,a,b,c)
#define	Physbase()	xbios(2)
#define	Logbase()	xbios(3)
#define	Getrez()	(int)xbios(4)
#define	Setscreen(a,b,c)	xbios(5,a,b,c)
#define Setpalette(a)	xbios(6,a)
#define Setcolor(a,b)	xbios(7,a,b)
#define	Floprd(a,b,c,d,e,f,g)	xbios(8,a,b,c,d,e,f,g)
#define	Flopwr(a,b,c,d,e,f,g)	xbios(9,a,b,c,d,e,f,g)
#define	Flopfmt(a,b,c,d,e,f,g,h,i)	xbios(10,a,b,c,d,e,f,g,h,i)
#define	Midiws(a,b)	xbios(12,a,b)
#define	Mfpint(a,b)	xbios(13,a,b)
#define	Iorec(a)	xbios(14,a)
#define	Rsconf(a,b,c,d,e,f)	xbios(15,a,b,c,d,e,f)
#define	Keytbl(nrml,shft,caps)	(_KEYTAB *)t14_wlll((short)(0x10),(long)(nrml), (long)(shft),(long)(caps))
#define	Random()	xbios(17)
#define	Protobt(a,b,c,d)	xbios(18,a,b,c,d)
#define	Flopver(a,b,c,d,e,f,g)	xbios(19,a,b,c,d,e,f,g)
#define	Cursconf(a,b)	xbios(21,a,b)
#define	Settime(a)	xbios(22,a)
#define	Gettime()	xbios(23)
#define	Bioskeys()	xbios(24)
#define	Ikbdws(a,b)	xbios(25,a,b)
#define	Jdisint(a)	xbios(26,a)
#define	Jenabint(a)	xbios(27,a)
#define	Giaccess(a,b)	xbios(28,a,b)
#define	Offgibit(a)	xbios(29,a)
#define	Ongibit(a)	xbios(30,a)
#define	Xbtimer(a,b,c,d)	xbios(31,a,b,c,d)
#define	Dosound(a)	xbios(32,a)
#define	Setprt(a)	xbios(33,a)
#define	Kbdvbase()	xbios(34)
#define	Kbrate(a,b)	xbios(35,a,b)
#define Prtblk()	xbios(0x24)
#define Vsync()		xbios(0x25)
#define Supexec(fn)	t14_wl(0x26, (long)(fn))
#define Puntaes()	xbios(0x27)	/* not in original */

/*	GEMDOS	(trap1)		*/
#define	Pterm0()	gemdos(0x0)
#define	Cconin()	gemdos(0x1)
#define	Cconout(a)	gemdos(0x2,a)
#define	Cauxin()	gemdos(0x3)
#define	Cauxout(a)	gemdos(0x4,a)
#define	Cprnout(a)	gemdos(0x5,a)
#define	Crawio(a)	gemdos(0x6,a)
#define	Crawcin()	gemdos(0x7)
#define	Cnecin()	t1_w(0x08)
#define	Cconws(a)	gemdos(0x9,a)
#define	Cconrs(a)	gemdos(0x0a,a)
#define	Cconis()	(int)gemdos(0x0b)
#define	Dsetdrv(a)	gemdos(0x0e,a)
#define	Cconos()	gemdos(0x10)
#define	Cprnos()	gemdos(0x11)
#define	Cauxis()	gemdos(0x12)
#define	Cauxos()	gemdos(0x13)
#define	Dgetdrv()	(int)gemdos(0x19)
#define	Fsetdta(a)	gemdos(0x1a,a)
#define	Super(a)	gemdos(0x20,a)		/* NOTE:This name may change */
#define	Tgetdate()	(int)gemdos(0x2a)
#define	Tsetdate(a)	gemdos(0x2b,a)
#define	Tgettime()	(int)gemdos(0x2c)
#define	Tsettime(a)	gemdos(0x2d,a)
#define	Fgetdta()	gemdos(0x2f)
#define	Sversion()	(int)gemdos(0x30)
#define	Ptermres(a,b)	gemdos(0x31,a,b)
#define	Dfree(a,b)	gemdos(0x36,a,b)
#define	Dcreate(a)	gemdos(0x39,a)
#define	Ddelete(a)	gemdos(0x3a,a)
#define	Dsetpath(a)	gemdos(0x3b,a)
#define	Fcreate(fn, mode)	t1_wlw(0x3C,(long)(fn),(short)(mode))
#define	Fopen(fn, mode)	t1_wlw(0x3D,(long)(fn),(short)(mode))
#define	Fclose(handle)	t1_ww(0x3E,(short)(handle))
#define	Fread(a,b,c)	gemdos(0x3f,a,b,c)
#define	Fwrite(handle,cnt,buf)	t1_wwll(0x40,(short)(handle), (long)(cnt),(long)(buf))
#define	Fdelete(a)	gemdos(0x41,a)
#define	Fseek(a,b,c)	gemdos(0x42,a,b,c)
#define	Fattrib(a,b,c)	gemdos(0x43,a,b,c)
#define	Mxalloc(a,b)	gemdos(0x44,a,b)
#define	Fdup(a)		gemdos(0x45,a)
#define	Fforce(a,b)	gemdos(0x46,a,b)
#define	Dgetpath(a,b)	gemdos(0x47,a,b)
#define	Malloc(a)	gemdos(0x48,a)
#define	Mfree(a)	gemdos(0x49,a)
#define	Mshrink(a,b)	gemdos(0x4a,0,a,b)	/* NOTE:Null parameter added */
#define	Pexec(a,b,c,d)	gemdos(0x4b,a,b,c,d)
#define	Pterm(a)	gemdos(0x4c,a)
#define	Fsfirst(a,b)	gemdos(0x4e,a,b)
#define	Fsnext()	gemdos(0x4f)
#define	Frename(a,b,c)	gemdos(0x56,a,b,c)
#define	Fdatime(a,b,c)	gemdos(0x57,a,b,c)

#endif /* __OSBIND_H__ */
