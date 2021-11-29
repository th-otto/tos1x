/*      DESKAPP.C               3/18/89 - 9/18/89       Derek Mui       */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"


int16_t x_wildcmp PROTO((const char *source, const char *dest));


/* 306de: 00e27fb4 */
int16_t x_wildcmp(P(const char *) source, P(const char *) dest)
PP(const char *source;)
PP(const char *dest;)
{
	if (*source)
	{
		if (*scasb(source, '*'))
			return wildcmp(source, g_name(dest));
		else
			return streq(source, dest);
	}
	return FALSE;
}


int16_t const ftab[] = {
	0, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10,
	F11, F12, F13, F14, F15, F16, F17, F18, F19, F20
};
