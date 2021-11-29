/*  btools.h - header file for routines which call the block oriented tools */


#define	bzero( s , n ) 		bfill( s , 0 , n )


VOID xmovs PROTO((int n, const VOIDPTR src, VOIDPTR dst));
VOID lbmove PROTO((const VOIDPTR src, VOIDPTR dst, uint32_t cnt));
VOID bfill PROTO((VOIDPTR dst, uint8_t val, uint16_t size));
VOID zeromem PROTO((VOIDPTR start, VOIDPTR end));
int ncmps PROTO((int n, const char *s, const char *d));
