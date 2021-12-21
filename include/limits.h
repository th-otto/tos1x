/* Copyright (C) 1991, 1992, 1996, 1997, 1998, 1999, 2000, 2005
   Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/*
 *	ISO C99 Standard: 7.10/5.2.4.2.1 Sizes of integer types	<limits.h>
 */

/* Modified for MiNTLib by Guido Flohr <guido@freemint.de>.  */

#ifndef __LIMITS_H__
#define __LIMITS_H__	1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif


/* Maximum length of any multibyte character in any locale.
   We define this value here since the gcc header does not define
   the correct value.  */
#define MB_LEN_MAX	16


/* We don't have #include_next.
   Define ANSI <limits.h> for standard 32-bit words.  */

/* These assume 8-bit `char's, 16-bit `short int's,
   and 32-bit `int's and `long int's.  */

/* Number of bits in a `char'.	*/
#  define CHAR_BIT	8

/* Minimum and maximum values a `signed char' can hold.  */
#  define SCHAR_MIN	(-128)
#  define SCHAR_MAX	127

/* Maximum value an `unsigned char' can hold.  (Minimum is 0.)  */
#  define UCHAR_MAX	255U

/* Minimum and maximum values a `char' can hold.  */
#  ifndef __CHAR_UNSIGNED__
#   if !('\x80' < 0)
#    define __CHAR_UNSIGNED__
#   endif
#  endif
#  ifdef __CHAR_UNSIGNED__
#   define CHAR_MIN	0
#   define CHAR_MAX	UCHAR_MAX
#  else
#   define CHAR_MIN	SCHAR_MIN
#   define CHAR_MAX	SCHAR_MAX
#  endif

/* Minimum and maximum values a `signed short int' can hold.  */
#  define SHRT_MIN	(-32767-1)
#  define SHRT_MAX	32767

/* Maximum value an `unsigned short int' can hold.  (Minimum is 0.)  */
#  define USHRT_MAX	65535U

/* Minimum and maximum values a `signed int' can hold.  */
#  ifdef __MSHORT__
#    define INT_MAX         32767
#  else
#    define INT_MAX	2147483647
#  endif
#  define INT_MIN	(-INT_MAX - 1)

/* Maximum value an `unsigned int' can hold.  (Minimum is 0.)  */
#  ifdef __MSHORT__
#    define UINT_MAX	65535U
#  else
#    define UINT_MAX	4294967295U
#  endif

/* Minimum and maximum values a `signed long int' can hold.  */
#  define LONG_MAX	2147483647L
#  define ULONG_MAX	4294967295L
#  define LONG_MIN	(-LONG_MAX - 1L)

 /* Get the compiler's limits.h, which defines almost all the ISO constants. */
#ifdef __GNUC__
#ifndef _LIBC
/* `_GCC_LIMITS_H_' is what GCC's file defines.  */
 # include_next <limits.h>
#endif
#endif

#endif
