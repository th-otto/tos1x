/*  pghdr.h - header file for program loaders, 'size' pgms, etc.	*/
/*  PGMHDR01 */


#define	PGMHDR01	struct	pgmhdr01
PGMHDR01
{
	int16_t h01_magic;  	/* magic number                 */
	int32_t	h01_tlen;		/* length of text segment		*/
	int32_t	h01_dlen;		/* length of data segment		*/
	int32_t	h01_blen;		/* length of bss  segment		*/
	int32_t	h01_slen;		/* length of symbol table		*/
	int32_t	h01_res1;		/* reserved - always zero		*/
	int32_t	h01_ldflags;	/* program load flags           */
	int16_t	h01_abs;		/* not zero if no relocation	*/
};
