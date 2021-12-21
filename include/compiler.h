#ifndef __COMPILER_H__
#define __COMPILER_H__ 1

#ifndef __GNUC__
# ifndef __PUREC__
#   ifndef __TURBOC__
#     ifndef LATTICE
#       define __ALCYON__ 1
#     endif
#   endif
# endif
#endif

#ifdef __ALCYON__
#define VOID int					/* Void function return	   */
#define VOIDPTR char *
#define NOTHING                     /* no parameters */
#define PROTO(p) ()
#define P(t)
#define PP(v) v
#define volatile
#define const
#define signed
#define __MSHORT__ 1
#define __SHORT_EXTERNAL_NAMES
#else
#define NOTHING void                /* no parameters */
#define PROTO(p) p
#define P(t) t
#define PP(v)
#endif

#ifdef __TURBOC__
#define CDECL cdecl
#define __MSHORT__ 1
#endif

#ifdef __PUREC__
#ifndef __AHCC__
#define __MSHORT__ 1
#endif
#endif

#ifndef VOID
#define VOID	void					/* Void function return	   */
#endif

#ifndef VOIDPTR
#define VOIDPTR	void *
#endif

#ifndef CDECL
#define CDECL
#endif
#ifndef __CDECL
#define __CDECL CDECL
#endif

#ifndef __attribute__
#  ifndef __GNUC__
#    define __attribute__(x)
#  endif
#endif

#ifdef __GNUC__
# ifdef __GNUC_MINOR__
#  define __GNUC_PREREQ(maj, min) ((__GNUC__ << 16) + __GNUC_MINOR__ >= ((maj) << 16) + (min))
# endif
#endif
#ifndef __GNUC_PREREQ
# define __GNUC_PREREQ(maj, min) 0
#endif

#if __GNUC_PREREQ(3, 3)
# define __CLOBBER_RETURN(a) 
#else
# define __CLOBBER_RETURN(a) a,
#endif

#if __GNUC_PREREQ(2, 6)
#define AND_MEMORY , "memory"
#define ONLY_MEMORY "memory"
#else
#define AND_MEMORY
#define ONLY_MEMORY
#endif

#if __GNUC_PREREQ(2, 5)
#define __EXITING void
#else
#define __EXITING volatile VOID
#endif
#ifndef __NORETURN
#define __NORETURN __attribute__ ((noreturn))
#endif

#define __EXTERN extern

#define	NULL	((VOIDPTR)0)			/*	Null pointer value	    */

#endif /* __COMPILER_H__ */
