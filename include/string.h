/************************************************************************/
/*									*/
/*	string.h	written by John Feagans		16 Apr 86	*/
/*	copyright 1986 by Atari Corp.					*/
/*									*/
/*	for use with Alcyon C as distributed in ST developers package.	*/
/*									*/
/************************************************************************/

#ifndef __STRING_H__
#define __STRING_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

#ifdef __GNUC__
 #include_next <string.h>
#endif

char *strchr PROTO((const char *str, int c));	/* locate first occurence	*/
char *strrchr PROTO((const char *str, int c));	/* locate last occurence	*/
char *mktemp PROTO((char *template));	/* create temp file name	*/
char *strcat PROTO((char *dst, const char *src));	/* concat whole			*/
char *strncat PROTO((char *dst, const char *src, size_t len));	/* concat number specified.	*/
char *strcpy PROTO((char *dst, const char *src));	/* copy whole string		*/
char *strncpy PROTO((char *dst, const char *src, size_t len));	/* copy specified length	*/
size_t strlen PROTO((const char *str));	/* return length of string	*/
int strcmp PROTO((const char *, const char *));
int strncmp PROTO((const char *, const char *, size_t));
int strcasecmp PROTO((const char *, const char *));

char *strpbrk PROTO((const char *s1, const char *s2));

char *strlwr PROTO ((char *str));
char *strupr PROTO ((char *str));

VOIDPTR memset PROTO((VOIDPTR ptr, int c, size_t bytes));
int memcmp PROTO((const VOIDPTR __s1, const VOIDPTR __s2, size_t __n));

char *strerror PROTO((int err_no));

int lmemcmp PROTO((const VOIDPTR __s1, const VOIDPTR __s2, long __n));

#endif /* __STRING_H__ */
