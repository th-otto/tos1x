/*
 *************************************************************************
 *                      Revision Control System
 * =======================================================================
 *  $Author: kbad $     $Date: 89/07/29 20:23:22 $
 * =======================================================================
 *
 * Revision 2.3  89/07/29  20:23:22  kbad
 * Removed error messages requiring keyboard input at the start of showfile.
 * Also added uikey() to allow mouse buttons to function like keys during
 * showfile.
 * 
 * Revision 2.2  89/04/26  18:11:42  mui
 * aes30
 * 
 * Revision 2.1  89/02/22  05:22:36  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.3  88/07/01  16:21:10  mui
 * Check port for printing
 *
 * Revision 1.2  88/07/01  15:48:12  mui
 * Take out tab expansion, fix fm_show
 * 
 * Revision 1.1  88/06/02  12:29:59  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*      DESKSHOW.C              5/3/88                  Allan Pratt
 *
 *      
 * show.c: desktop "show file" code.
 *
 * showfile(fname,mode)
 * char *fname;         filename of file to show
 * int mode;            FALSE for printer, TRUE for screen.
 *
 * For screen mode, call this function after the screen is clear and the 
 * cursor is enabled.  When this function returns, the screen needs to
 * be cleared again and the cursor disabled.
 *
 * This code uses BIOS I/O exclusively to avoid ^C handling.
 * It does its own ^S/^Q and ^C handling.
 *
 * ^S/^C get checked every 16 characters or each --more--, whichever comes
 * first.  ^C causes return to the desktop, ^S waits for ^Q (continue) or
 * ^C (quit). 
 *
 * Note that hitting space in the middle of a page makes the "more" come
 * 24 lines from now, rather than having the same effect as waiting
 * for the more and then hitting space.
 *
 * d and D and ^D cause the "more" to come 1/2 page from now; Return
 * makes it come one line from now.
 *
 * q, Q, and ^C cause the output to stop immediately.
 *
 * Line wrap is not modified: if it was no-wrap to begin with, that's
 * what you get.
 *
 * For printer mode, the keyboard gets checked every MAXCHAR characters.
 * q, Q, ^C, and Undo all cause printing to abort.
 * Printer mode, of course, does its own tab expansion.  It only
 * understands TAB, BS, and CR as control characters.  Others will
 * mess up the tab expansion (which means you shouldn't use the desktop
 * print function with wierder files than that).
 */

#include "desktop.h"
#include "toserrno.h"
#include "desksupp.h"
#include "deskstr.h"
/*
 * WTF: need constants from AES resource here
 */
#undef NUM_STRINGS
#undef NUM_FRSTR
#undef NUM_UD
#undef NUM_IMAGES
#undef NUM_BB
#undef NUM_FRIMG
#undef NUM_IB
#undef NUM_CIB
#undef NUM_TI
#undef NUM_OBS
#undef NUM_TREE
#undef SCREEN
#include "gemrsc.h"


#undef Bconstat
#undef Bconin
#undef Bconout

#define Bconstat(d) trp13(1,d)
#define Bconin(d) trp13(2,d)
#define Bconout(d,c) trp13(3,d,c)

#undef Setprt
#define Setprt(a) trp14(0x21, a)

#undef Cconws
#define Cconws(s) trap(9,s)
#undef Cauxout
#define Cauxout(ch) trap(4, ch)
#undef Cprnout
#define Cprnout(ch) trap(5, ch)

#if OLD_SFCODE
#define BUFSIZ 512						/* Malloc this much as a disk buffer */
#else
#define BUFSIZ 4096						/* Malloc this much as a disk buffer */
#endif

							/* #define MAXLINE 24	*//* line interval for --more-- */
#define MAXCHAR 16						/* character interval for checking keyboard */

#define MAXLINES 22

/* ASCII equates */

#define CTLC 3
#define CTLD 4
#define BS 8
#define TAB 9
#define NL 10
#define CR 13
#define CTLQ 17
#define CTLS 19
#define SPACE 32

/*
 * need to redefine some functions for old code,
 * so that we get the correct LineF opcodes
 */
#if LINEF_HACK & OLD_SFCODE
#define rawcon us_rawcon
#define sf_getc us_getc
#define sf_putc us_putc
#define sf_page us_page
#define sf_more us_more
#define sf_newline us_newline
#define cconws us_cconws
#endif


STATIC int sf_inptr; /* input file pointer */
#if !OLD_SFCODE
STATIC int sf_bufsize; /* input buffered size */
STATIC BOOLEAN sf_eof;
#else
STATIC int sf_col;
#endif
STATIC int sf_key;
STATIC int sf_line;

LINEF_STATIC VOID sf_disp PROTO((int handle, char *buf));
#if OLD_SFCODE
LINEF_STATIC BOOLEAN sf_page PROTO((int handle, char *buf));
#else
LINEF_STATIC VOID sf_page PROTO((int handle, char *buf));
#endif
LINEF_STATIC BOOLEAN sf_newline PROTO((int handle, char *buf));
LINEF_STATIC BOOLEAN sf_putc PROTO((int ch, BOOLEAN centronics));
LINEF_STATIC int sf_more PROTO((NOTHING));
LINEF_STATIC VOID cconws PROTO((const char *s));
#if OLD_SFCODE
LINEF_STATIC VOID sf_cr PROTO((NOTHING));
#endif


/* 100de: 00fed5a0 */
VOID sh_type(P(const char *) fname)
PP(const char *fname;)
{
	showfile(fname, TRUE);
}


/* 100de: 00fed5b2 */
VOID sh_print(P(const char *) fname)
PP(const char *fname;)
{
	showfile(fname, FALSE);
}


#if OLD_SFCODE
LINEF_STATIC int sf_getc(P(int) handle, P(char *) buf)
PP(int handle;)
PP(register char *buf;)
{
	register unsigned int sf_bufsize;

	if (sf_inptr == -1)
		return 0xff;
	if (sf_inptr == BUFSIZ)
	{
		sf_inptr = 0;
		sf_bufsize = dos_read(handle, BUFSIZ, buf);
		if (sf_bufsize != BUFSIZ)
		{
			buf[sf_bufsize] = 0xff;
		}
	}
	return buf[sf_inptr++] & 0xff;
}
#else
/* 100de: 00fed5c2 */
LINEF_STATIC BOOLEAN sf_getc(P(int) handle, P(char *) buf, P(int *) ch)
PP(int handle;)
PP(register char *buf;)
PP(int *ch;)
{
	if (sf_inptr == -1)
		return FALSE;
	if (sf_bufsize == sf_inptr && sf_eof)
		return FALSE;
	if (sf_inptr == BUFSIZ)
	{
		sf_inptr = 0;
		sf_bufsize = dos_read(handle, BUFSIZ, buf);
		if (sf_bufsize != BUFSIZ)
		{
			sf_eof = TRUE;
		}
	}
	*ch = buf[sf_inptr++] & 0xff;
	return TRUE;
}
#endif


/* 306de: 00e331aa */
/* 104de: 00fe66b2 */
/* 106de: 00e28e36 */
/* 100de: 00fed64c */
BOOLEAN showfile(P(const char *)fname, P(int) mode)
PP(const char *fname;)
PP(int mode;)
{
	register int handle;
	register char *buf;
#if OLD_SFCODE
	register int ch;
	int key;
	BOOLEAN cont;
	int prtmode;
	BOOLEAN centronics;
#else
	int ch;
	int key;
	BOOLEAN centronics;
#endif

#if !OLD_SFCODE
	sf_eof = FALSE;
#endif

	handle = dos_open(fname, RMODE_RD);
	if (DOS_ERR)
	{
		return FALSE;
	}
	buf = (char *)dos_alloc((long)BUFSIZ);
#if !OLD_SFCODE
	if (!buf)
	{
		/* BUG: handle leaked */
		return FALSE;
	}
#endif

	sf_inptr = BUFSIZ;
	if (mode)
	{
		/* SCREEN MODE CODE */
#if OLD_SFCODE
		Cconws("\033v"); /* turn on wrap */
#endif
		sf_disp(handle, buf);
	} else
	{
		/* PRINTER MODE CODE */
		/* find out where to send serial or parallel */
#if OLD_SFCODE
		prtmode = Setprt(-1);
		if (prtmode & 0x10)
			centronics = FALSE;
		else
			centronics = TRUE;
		ch = sf_getc(handle, buf);
		cont = TRUE;
		while (ch != 0xff && cont)
		{
			key = toupper(rawcon(255));
			if (key == CTLC || key == 'Q')
			{
				goto alldone;
			} else
			{
				if (!sf_putc(ch, centronics))
					goto alldone;
			}
			ch = sf_getc(handle, buf);
		}
#else
		centronics = (Setprt(-1) & 0x10) ? FALSE : TRUE;
		while (sf_getc(handle, buf, &ch))
		{
			key = toupper(rawcon(255));
			if (key == CTLC)
				goto alldone;
			if (key == 'Q')
				goto alldone;
			if (!sf_putc(ch, centronics))
				goto alldone;
		}
#endif
		sf_putc('\r', centronics);
		sf_putc('\n', centronics);
	}
alldone:
	dos_close(handle);
	dos_free(buf);
	return TRUE;
}


/* 100de: 00fed722 */
LINEF_STATIC VOID sf_disp(P(int) handle, P(char *)buf)
PP(register int handle;)
PP(register char *buf;)
{
	register BOOLEAN done;
	
	done = FALSE;
#if !OLD_SFCODE
	Cconws("\033v"); /* turn on wrap */
#endif
	sf_page(handle, buf);
	do
	{
		if (sf_inptr == -1)
		{
			while (rawcon(255) == 0)
				;
			done = TRUE;
		} else
		{
			switch (sf_more())
			{
			case CTLC:
			case 'Q':
				done = TRUE;
				break;
			case ' ':
				sf_page(handle, buf);
				break;
			case '\r':
				sf_newline(handle, buf);
				/* break; */
			}
		}
	} while (!done);
}


/* 100de: 00fed79c */
LINEF_STATIC int sf_more(NOTHING)
{
	cconws(S_MORE);
	while ((sf_key = rawcon(255)) == 0)
		;
	sf_key = toupper(sf_key);
#if OLD_SFCODE
	for (sf_col = 8; sf_col-- != 0; )
		rawcon('\b');
	 /* clear to end-of-line */
	rawcon('\033');
	rawcon('K');
#else
	Cconws("\033l"); /* clear line */
#endif
	return sf_key;
}


#if OLD_SFCODE
LINEF_STATIC BOOLEAN sf_page(P(int) handle, P(char *)buf)
PP(int handle;)
PP(char *buf;)
{
	for (sf_line = MAXLINES; sf_line-- != 0; )
	{
		if (sf_newline(handle, buf))
			return TRUE;
	}
	return FALSE;
}
#else
/* 100de: 00fed7da */
LINEF_STATIC VOID sf_page(P(int) handle, P(char *)buf)
PP(int handle;)
PP(char *buf;)
{
	for (sf_line = MAXLINES; sf_line-- != 0; )
	{
		if (sf_newline(handle, buf))
			;
		else
			break;
	}
}
#endif


/* 100de: 00fed80e */
LINEF_STATIC BOOLEAN sf_newline(P(int) handle, P(char *)buf)
PP(int handle;)
PP(char *buf;)
{
#if OLD_SFCODE
	register int ch;
	
	while ((ch = sf_getc(handle, buf)) != 0xff)
	{
		ch &= 0x7f;
		rawcon(ch);
		if (ch == '\n')
			break;
	}
	if (ch != 0xff)
	{
		return FALSE;
	} else
	{
		sf_cr();
		cconws(S_EOF);
		sf_inptr = -1;
		return TRUE;
	}
#else
	int ch;
	BOOLEAN more;
	
	more = TRUE;
	while ((more = sf_getc(handle, buf, &ch)))
	{
		Bconout(2, ch); /* ugly mix of GEMDOS and BIOS output here */
		if (ch == '\n')
			break;
	}
	if (more == TRUE)
		return TRUE;
	rawcon('\r');
	rawcon('\n');
	cconws(S_EOF);
	sf_inptr = -1;
	return FALSE;
#endif
}


/* 100de: 00fed874 */
LINEF_STATIC VOID cconws(P(const char *) s)
PP(const char *s;)
{
	while (*s)
		rawcon(*s++);
}


#if OLD_SFCODE
LINEF_STATIC VOID sf_cr(NOTHING)
{
	rawcon('\r');
	rawcon('\n');
}
#endif


/* 100de: 00fed894 */
LINEF_STATIC BOOLEAN sf_putc(P(int) ch, P(BOOLEAN) centronics)
PP(register int ch;)
PP(register BOOLEAN centronics;)
{
	int done;
	
#if OLD_SFCODE
	if (!centronics)
	{
		Cauxout(ch);
		return TRUE;
	}
	done = FALSE;
	while (!done)
	{
		done = prt_chr(ch);
		if (done)
			break;
		/* device not responding */
		done = fm_show(ALRT04CRT, 0, 1); /* BUG: 2nd parameter is pointer */
		desk_wait(TRUE);
		if (done != 1)
			done = 0;
		else
			done = 99;
	}
	if (done == 99)
		done = FALSE;
	return done;
#else
	if (centronics)
	{
		done = FALSE;
		while (!done)
		{
			if ((done = Cprnout(ch)))
				break;
			/* device not responding */
			done = fm_show(ALRT04CRT, 0, 1); /* BUG: 2nd parameter is pointer */
			desk_wait(TRUE);
			done = done != 1 ? 0 : 99;
		}
		if (done == 99)
			done = FALSE;
		return done;
	} else
	{
		Cauxout(ch);
		return TRUE;
	}
#endif
}
