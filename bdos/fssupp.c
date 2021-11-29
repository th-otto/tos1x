/*  fssupp.c - GEMDOS file system support routines */

#include "tos.h"
#include <ostruct.h>
#include <toserrno.h>
#include "fs.h"
#include "mem.h"
#include "btools.h"


#define UC(c) (((c) >= 'a' && (c) <= 'z') ? ((c) & 0x5f) : (c))


/*
 *  xsfirst - search first for matching name, into dta
 *
 *	Function 0x4E	Fsfirst
 *
 *	Error returns
 *		EFILNF
 */

/* 306de: 00e1726a */
/* 306us: 00e17210 */
/* 104de: 00fc7c8c */
ERROR xsfirst(P(const char *) name, P(int16_t) att)
PP(const char *name;)
PP(int16_t att;)
{
	return ixsfirst(name, att, run->p_xdta);
}


/*
 *  xcreat -
 *  create file with specified name, attributes
 *
 *	Function 0x3C	Fcreate
 *
 *	Error returns
 *		EPTHNF
 *		EACCDN
 *		ENHNDL
 *
 *	Last modified	SCC	13 May 85
 */

/* 306de: 00e1728c */
/* 306us: 00e17232 */
/* 104de: 00fc7cae */
ERROR xcreat(P(const char *) fname, P(int8_t) attr)
PP(const char *fname;)
PP(int8_t attr;)
{
	if ((attr & FA_DIREC) || ((attr & FA_LABEL) && (attr != FA_LABEL)))
		return E_BADRQ;
	return ixcreat(fname, attr & (FA_RDONLY|FA_HIDDEN|FA_SYSTEM|FA_LABEL|FA_ARCH));
}


/*	
 *  xopen - open a file (path name)
 *
 *  returns
 *	<0 = error
 *	>0 = file handle
 *
 *	Function 0x3D	Fopen
 *
 *	Error returns
 *		EFILNF
 *		opnfil()
 *
 *	Last modified	SCC	5 Apr 85
 */

/* 306de: 00e172c8 */
/* 306us: 00e1726e */
/* 104de: 00fc7cea */
ERROR xopen(P(const char *) fname, P(int16_t) mode)
PP(const char *fname;)
PP(int16_t mode;)
{
	return ixopen(fname, mode);
}



/*
 *  xlog2 -
 *	return log base 2 of n
 */

/* 306de: 00e172e0 */
/* 306us: 00e17286 */
/* 104de: 00fc7d02 */
int xlog2(P(int) n)
PP(int n;)
{
	register int i;

	for (i = 0; n; i++)
		n >>= 1;

	return i - 1;
}


/* 306de: 00e17306 */
/* 306us: 00e172ac */
/* 104de: 00fc7d28 */
VOID xmovs(P(int) n, P(const VOIDPTR) psrc, P(VOIDPTR) pdst)
PP(register int n;)
PP(const VOIDPTR psrc;)
PP(VOIDPTR pdst;)
{
	register const char *src;
	register char *dst;
	src = psrc;
	dst = pdst;
	while (n--)
		*dst++ = *src++;
}


/*
 *  xcmps - utility routine to compare two 11-character strings
 *
 *	Last modified	19 Jul 85	SCC
 */

/* 306de: 00e17330 */
/* 306us: 00e172d6 */
/* 104de: 00fc7d52 */
int xcmps(P(const char *) s, P(const char *) d)
PP(register const char *s;)
PP(register const char *d;)
{
	register int i;

	for (i = 0; i < 11; i++)
		if (uc(*s++) != uc(*d++))
			return 0;
	return 1;
}


/*
 *  match - utility routine to compare file names
 */

/* 306de: 00e1737c */
/* 306us: 00e17322 */
/* 104de: 00fc7d9e */
BOOLEAN match(P(const char *) s1, P(const char *) s2)
PP(register const char *s1;)							/*  name we are checking        */
PP(register const char *s2;)									/*  name in fcb             */
{
	register int i;

	/*
	 *  check for deleted entry.  wild cards don't match deleted entries,
	 *  only specific requests for deleted entries do.
	 */

	if (*s2 == 0xe5)
	{
		if (*s1 == '?')
			return FALSE;
		else if (*s1 == 0xe5)
			return TRUE;
	}

	/*
	 *  compare names
	 */

	for (i = 0; i < 11; i++, s1++, s2++)
		if (*s1 != '?')
			if (UC(*s1) != UC(*s2)) /* ??? why is a macro used here? */
				return FALSE;

	/*
	 *  check attribute match
	 * volume labels and subdirs must be specifically asked for
	 */

 	return (*s2 != 0 || *s1 == FA_LABEL) && (*s1 & *s2) == 0 ? FALSE : TRUE;
}


#ifdef NEWCODE
#define	isnotdelim(x)	((x) && (x!='*') && (x!=SLASH) && (x!='.') && (x!=' '))

#define	MAXFNCHARS	8


/*
 *  builds - build a directory style file spec from a portion of a path name
 *	the string at 's1' is expected to be a path spec in the form of
 *	(xxx/yyy/zzz).  *builds* will take the string and crack it
 *	into the form 'ffffffffeee' where 'ffffffff' is a non-terminated
 *	string of characters, padded on the right, specifying the filename
 *	portion of the file spec.  (The file spec terminates with the first
 *	occurrence of a SLASH or EOS, the filename portion of the file spec
 *	terminates with SLASH, EOS, PERIOD or WILDCARD-CHAR).  'eee' is the
 *	file extension portion of the file spec, and is terminated with
 *	any of the above.  The file extension portion is left justified into
 *	the last three characters of the destination (11 char) buffer, but is
 *	padded on the right.  The padding character depends on whether or not
 *	the filename or file extension was terminated with a separator
 *	(EOS, SLASH, PERIOD) or a WILDCARD-CHAR.
 *
 */

VOID builds(P(const char *) s1, P(char *) s2)
PP(register char *s1;)							/*  source          */
PP(register char *s2;)									/*  s2 dest         */
{
	register int i;
	register char c;

	/*
	 * copy filename part of pathname to destination buffer until a
	 * delimiter is found
	 */

	for (i = 0; (i < MAXFNCHARS) && isnotdelim(*s1); i++)
		*s2++ = uc(*s1++);

	/*
	 *  if we have reached the max number of characters for the filename
	 * part, skip the rest until we reach a delimiter
	 */

	if (i == MAXFNCHARS)
		while (*s1 && (*s1 != '.') && (*s1 != SLASH))
			s1++;

	/*
	 *  if the current character is a wildcard character, set the padding
	 * char with a "?" (wildcard), otherwise replace it with a space
	 */

	c = (*s1 == '*') ? '?' : ' ';


	if (*s1 == '*')						/*  skip over wildcard char */
		s1++;

	if (*s1 == '.')						/*  skip over extension delim   */
		s1++;

	/*
	 *  now that we've parsed out the filename part, pad out the
	 * destination with "?" wildcard chars
	 */

	for (; i < MAXFNCHARS; i++)
		*s2++ = c;

	/*
	 *  copy extension part of file spec up to max number of characters
	 * or until we find a delimiter
	 */

	for (i = 0; i < 3 && isnotdelim(*s1); i++)
		*s2++ = uc(*s1++);

	/*
	 *  if the current character is a wildcard character, set the padding
	 * char with a "?" (wildcard), otherwise replace it with a space
	 */

	c = ((*s1 == '*') ? '?' : ' ');

	/*
	 *  pad out the file extension
	 */

	for (; i < 3; i++)
		*s2++ = c;
}

#else

/*
 *  builds -
 *
 *	Last modified	LTG	23 Jul 85
 */

/* 306de: 00e17424 */
/* 306us: 00e173ca */
/* 104de: 00fc7e46 */
VOID builds(P(const char *) s1, P(char *) s2)
PP(register char *s1;)							/*  source          */
PP(register char *s2;)									/*  s2 dest         */
{
	register int i;
	register char c;

	for (i = 0; (i < 8) && (*s1) && (*s1 != '*') && (*s1 != SLASH) && (*s1 != '.') && (*s1 != ' '); i++)
		*s2++ = uc(*s1++);

	if (i == 8)
		while (*s1 && (*s1 != '.') && (*s1 != SLASH))
			s1++;

	c = ((*s1 == '*') ? '?' : ' ');

	if (*s1 == '*')
		s1++;

	if (*s1 == '.')
		s1++;

	for (; i < 8; i++)
		*s2++ = c;

	for (i = 0; (i < 3) && (*s1) && (*s1 != '*') && (*s1 != SLASH) && (*s1 != '.') && (*s1 != ' '); i++)
		*s2++ = uc(*s1++);

	c = ((*s1 == '*') ? '?' : ' ');

	for (; i < 3; i++)
		*s2++ = c;
}

#endif


/*
 *  getpath - get a path element
 *	The buffer pointed to by 'd' must be at least the size of the file
 *	spec buffer in a directory entry (including file type), and will
 *	be filled with the directory style format of the path element if
 *	no error has occurred.
 *
 *  returns
 *	-1 if '.'
 *	-2 if '..'
 *	 0 if p => name of a file (no trailing SLASH or !dirspec)
 *	>0 (nbr of chars in path element (up to SLASH)) && buffer 'd' filled.
 *
 */

/* 306de: 00e17508 */
/* 306us: 00e174ae */
/* 104de: 00fc7f2a */
int getpath(P(const char *) p, P(char *) d, P(int) dirspec)
PP(register const char *p;)								/*  start of path element to crack  */
PP(char *d;)									/*  ptr to destination buffer       */
PP(int dirspec;)							/*  true = no file name, just dir path  */
{
	register int i, i2;
	register const char *p1;

	for (i = 0, p1 = p; *p1; p1++, i++)
		if (*p1 == SLASH)
			break;

	/*
	 *  If the string we have just scanned over is a directory name, it
	 * will either be terminated by a SLASH, or 'dirspec' will be set
	 * indicating that we are dealing with a directory path only
	 * (no file name at the end).
	 */

	if (*p1 != '\0' || dirspec)
	{									/*  directory name  */
		if ((i2 = contains_dots(p, *p1)) < 0)
			return i2;
		if (i)							/*  if not null path el */
			builds(p, d);				/*  d => dir style fn   */

		return i;						/*  return nbr chars    */
	}

	return 0;							/*  if string is a file name        */
}


/*
 *  packit - pack into user buffer
 */

/* 306de: 00e17568 */
/* 306us: 00e1750e */
/* 104de: 00fc7f8a */
char *packit(P(const char *) s, P(char *) d)
PP(const char *s;)
PP(char *d;)
{
	register const char *s0;
	register int i;

	if (!(*s))
		goto pakok;

	s0 = s;
	for (i = 0; (i < 8) && (*s) && (*s != ' '); i++)
		*d++ = *s++;

	if (*s0 == '.')
		goto pakok;

	s = s0 + 8;							/* ext */

	if (*s != ' ')
		*d++ = '.';
	else
		goto pakok;

	for (i = 0; (i < 3) && (*s) && (*s != ' '); i++)
		*d++ = *s++;
  pakok:*d = 0;
	return d;
}


/*
 *  dopath -
 *
 */

/* 306de: 00e1761a */
/* 306us: 00e175c0 */
/* 104de: 00fc803c */
char *dopath(P(DND *) p, P(char *) buf)
PP(DND *p;)
PP(char *buf;)
{
	if (p->d_parent)
		buf = dopath(p->d_parent, buf);

	buf = packit(p->d_name, buf);
	*buf++ = SLASH;
	return buf;
}


/* 306de: 00e17662 */
/* 306us: 00e17608 */
/* 104de: 00fc8084 */
int contains_dots(P(const char *) name, P(char) ill)
PP(register const char *name;)
PP(char ill;)
{
	register int i;
	
	if (*name == '\0')
		return 1;
	for (i = 0; --i > -3; )
	{
		if (*name++ != '.')
			break;
		if (*name == ill)
			return i;
	}
	return 0;
}


/*
 *  ncmps -  compare two text strings.
 */

/* 306de: 00e176a4 */
/* 306us: 00e1764a */
/* 104de: 00fc80c6 */
int ncmps(P(int) n, P(const char *) s, P(const char *) d)
PP(register int n;)
PP(register const char *s;)
PP(register const char *d;)
{
	while (n--)
		if (*s++ != *d++)
			return 0;

	return 1;
}


#if 0 /* no longer used */

BOOLEAN match1 PROTO((const char *ref, const char *test));

/*
 *  match1 - check for bad chars in path name
 *	check thru test string to see if any character in the ref str is found
 *	(utility routine for ixcreat())
 *	by scc
 */

BOOLEAN match1(P(const char *) ref, P(const char *) test)
PP(register const char *ref;)
PP(const char *test;)
{
	register const char *t;

	while (*ref)
	{
		for (t = test; *t; t++)
			if (*t == *ref)
				return TRUE;
		ref++;
	}

	return FALSE;
}

#endif
