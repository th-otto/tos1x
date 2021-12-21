/****************************************************************************/
/*									    */
/*				CTYPE					    */
/*				-----					    */
/*									    */
/*   CTYPE.H  -  macros to classify ASCII-coded integers by table lookup.   */
/*									    */
/*									    */
/*	Note:	Integer args are undefined for all int values > 127,	    */
/*		except for macro 'isascii()'.				    */
/*	Assumes:							    */
/*		User will link with standard library functions.		    */
/*		Compiler can handle declarator initializers and		    */
/*		'#defines' with parameters.				    */
/*									    */
/****************************************************************************/

#ifndef __CTYPE_H__
#define __CTYPE_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

#ifdef __GNUC__
 #ifndef _LIBC
 #  include_next <ctype.h>
 #  define _NO_CTYPE
 #endif
#endif


#ifndef _NO_CTYPE

/*
 *	Bit patterns for character class DEFINEs
 */
#define	__C_c	01
#define	__C_p	02
#define	__C_d	04
#define	__C_u	010
#define	__C_l	020
#define	__C_s	040
#define	__C_cs	041
#define	__C_ps	042

extern char const __atab[];

/*
 *	Character Class Testing and Conversion DEFINEs:
 */
#define	isascii(ch) ((ch) < 0200)
#define	isalpha(ch) (__atab[ch] & (__C_u | __C_l))
#define	isupper(ch) (__atab[ch] & __C_u)
#define	islower(ch) (__atab[ch] & __C_l)
#define	isdigit(ch) (__atab[ch] & __C_d)
#define	isalnum(ch) (__atab[ch] & (__C_u | __C_l | __C_d))
#define	isspace(ch) (__atab[ch] & __C_s)
#define	ispunct(ch) (__atab[ch] & __C_p)
#define	isprint(ch) (__atab[ch] & (__C_u | __C_l | __C_d | __C_p))
#define	iscntrl(ch) (__atab[ch] & __C_c)

#define	tolower(ch) (isupper(ch) ? (ch)+('a'-'A') : (ch))
#define	toupper(ch) (islower(ch) ? (ch)+('A'-'a') : (ch))
#define	toascii(ch) ((ch) & 0177)

#endif

#endif /* __CTYPE_H__ */
