#ifndef MEM_H
#define MEM_H 1

/*  mem.h - header file for memory and process management routines	*/


/* allowed values for Mxalloc mode: */
#define MX_STRAM 0
#define MX_TTRAM 1
#define MX_PSTRAM 2  /* MX_PREFSTRAM; renamed because of 8-char identifier limit */
#define MX_PTTRAM 3  /* MX_PREFTTRAM; renamed because of 8-char identifier limit */

#define MGET(x) ((x *) xmgetblk((sizeof(x) + 15) >> 4))


/*
 *  externals
 */

extern MPB pmd;
extern int osmlen;

VOID xminit PROTO((NOTHING));
VOID osminit PROTO((NOTHING));
#if ALTRAM_SUPPORT
MD *ffit PROTO((long amount, MPB *mp, int16_t mode));
#else
MD *ffit PROTO((long amount, MPB *mp));
#endif
VOID freeit PROTO((MD *m, MPB *mp));
VOID xmakeres PROTO((PD *p));
VOID xmfreall PROTO((PD *r));
VOID xmsetown PROTO((VOIDPTR addr, PD *own));
VOIDPTR xmgetblk PROTO((int size));
VOID xmfreblk PROTO((VOIDPTR m));
VOID foldermsg PROTO((NOTHING));
OFD *oftdel PROTO((OFD *ofd));


/*
 *  process management
 */

extern xjmp_buf bakbuf;
extern int16_t supstk[];

#endif
