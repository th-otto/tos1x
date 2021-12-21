/************************************************************************/
/*									*/
/*	math.h		written by John Feagans		16 Apr 86	*/
/*	copyright 1986 by Atari Corp.					*/
/*									*/
/*	for use with Alcyon C as distributed in ST developers package.	*/
/*									*/
/************************************************************************/

#ifndef __MATH_H__
#define __MATH_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

extern	double	atan PROTO((double x));		/* arc tangent function 		*/
extern	double	atof PROTO((const char *buf));		/* ascii to floating			*/
extern	int	atoi PROTO((const char *buf));		/* ascii to integer			*/
extern	long	atol PROTO((const char *buf));		/* ascii to long integer		*/
extern	double	ceil PROTO((double x));		/* ceiling function			*/
extern	double	cos PROTO((double x));		/* cosine				*/
extern	double	sin PROTO((double x));		/* sine					*/
char *ftoa PROTO((double fp, char *buf, int prec));		/* floating to string			*/
char *etoa PROTO((double fp, char *buf, int prec));		/* floating to string			*/
char *gtoa PROTO((double fp, char *buf, int prec));		/* floating to string			*/
extern	double	exp PROTO((double x));		/* exponent base e			*/
extern	double	fabs PROTO((double x));		/* floating absolute val		*/
extern	double	floor PROTO((double x));	/* floor function			*/
extern	double	fmod PROTO((double x, double y));		/* modulus(remainder)			*/
extern	double	log PROTO((double x));		/* log bas e				*/
extern	double	pow PROTO((double x, double y));		/* power function			*/
extern	double	sinh PROTO((double x));		/* hyperbolic sine			*/
extern	double	tanh PROTO((double x));		/* hyperbolic tangent			*/
extern	double	sqrt PROTO((double x));		/* square root				*/
extern	double	tan PROTO((double x));		/* tangent				*/

#endif /* __MATH_H__ */
