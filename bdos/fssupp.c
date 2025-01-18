/*  fssupp.c - GEMDOS file system support routines */

#include "tos.h"
#include <ostruct.h>
#include <toserrno.h>
#include "fs.h"
#include "mem.h"
#include "btools.h"


#define UC(c) (((c) >= 'a' && (c) <= 'z') ? ((c) & 0x5f) : (c))


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
