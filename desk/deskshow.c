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

#define BUFSIZ 4096						/* Malloc this much as a disk buffer */

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

STATIC int sf_inptr; /* input file pointer */
STATIC int sf_bufsize; /* input buffered size */
STATIC BOOLEAN sf_eof;
STATIC int sf_key;
STATIC int sf_line;

LINEF_STATIC VOID sf_disp PROTO((int handle, char *buf));
LINEF_STATIC VOID sf_page PROTO((int handle, char *buf));
LINEF_STATIC BOOLEAN sf_newline PROTO((int handle, char *buf));
LINEF_STATIC BOOLEAN sf_putc PROTO((int ch, BOOLEAN centronics));
LINEF_STATIC int sf_more PROTO((NOTHING));
LINEF_STATIC VOID cconws PROTO((const char *s));


VOID sh_type(P(const char *) fname)
PP(const char *fname;)
{
	showfile(fname, TRUE);
}


VOID sh_print(P(const char *) fname)
PP(const char *fname;)
{
	showfile(fname, FALSE);
}


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


/* 306de: 00e331aa */
/* 104de: 00fe66b2 */
/* 106de: 00e28e36 */
BOOLEAN showfile(P(const char *)fname, P(int) mode)
PP(const char *fname;)
PP(int mode;)
{
	int ch;
	int key;
	BOOLEAN centronics;
	register int handle;
	register char *buf;

	sf_eof = FALSE;

	handle = dos_open(fname, RMODE_RD);
	if (DOS_ERR)
	{
		return FALSE;
	}
	if (!(buf = (char *)dos_alloc((long)BUFSIZ)))
	{
		/* BUG: handle leaked */
		return FALSE;
	}

	sf_inptr = BUFSIZ;
	if (mode)
	{
		/* SCREEN MODE CODE */
		sf_disp(handle, buf);
	} else
	{
		/* PRINTER MODE CODE */
		/* find out where to send serial or parallel */

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
		sf_putc('\r', centronics);
		sf_putc('\n', centronics);
	}
alldone:
	dos_close(handle);
	dos_free(buf);
	return TRUE;
}


LINEF_STATIC VOID sf_disp(P(int) handle, P(char *)buf)
PP(register int handle;)
PP(register char *buf;)
{
	register BOOLEAN done;
	
	done = FALSE;
	Cconws("\033v"); /* turn on wrap */
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


LINEF_STATIC int sf_more(NOTHING)
{
	cconws(S_MORE);
	while ((sf_key = rawcon(255)) == 0)
		;
	sf_key = toupper(sf_key);
	Cconws("\033l"); /* clear line */
	return sf_key;
}


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


LINEF_STATIC BOOLEAN sf_newline(P(int) handle, P(char *)buf)
PP(int handle;)
PP(char *buf;)
{
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
}


LINEF_STATIC VOID cconws(P(const char *) s)
PP(const char *s;)
{
	while (*s)
		rawcon(*s++);
}


LINEF_STATIC BOOLEAN sf_putc(P(int) ch, P(BOOLEAN) centronics)
PP(register int ch;)
PP(register BOOLEAN centronics;)
{
	int done;
	
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
}
