#ifndef __STDLIB_H__
#define __STDLIB_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

#define	EXIT_FAILURE	1	/* Failing exit status.  */
#define	EXIT_SUCCESS	0	/* Successful exit status.  */

#ifdef __GNUC__
 #include <stdint.h>
 #define ldiv std_ldiv
 #include_next <stdlib.h>
 #undef RAND_MAX
 #undef ldiv
#endif

/* The largest number rand will return (same as INT_MAX).  */
#define	RAND_MAX	32767


VOIDPTR malloc PROTO((size_t size));
VOID free PROTO((VOIDPTR));
VOIDPTR realloc PROTO((VOIDPTR ptr, size_t size));
VOIDPTR calloc PROTO((size_t nmemb, size_t size));

int atoi PROTO((const char *s));
long atol PROTO((const char *s));
long strtol PROTO((const char *s, char **end, int base));

/* Absolute value function */
int abs PROTO((int));
long int labs PROTO((long int));


int	rand PROTO((NOTHING));		/* random function			*/
VOID srand PROTO((unsigned int seed));	/* seed random generator		*/

__EXITING abort PROTO((NOTHING)) __NORETURN;
__EXITING _exit PROTO((int status)) __NORETURN;
__EXITING exit PROTO((int status)) __NORETURN;

VOIDPTR sbrk PROTO((int increment)); /* should be ptrdiff_t */
int brk PROTO((VOIDPTR addr));

#ifndef __COMPAR_FN_T
# define __COMPAR_FN_T
typedef int (*__compar_fn_t) PROTO((const void *, const void *));
#endif
VOID qsort PROTO((VOIDPTR bas, size_t num, size_t siz, __compar_fn_t cmp));

char *mktemp PROTO((char *template));

char *getenv PROTO((const char *name));

VOIDPTR lsbrk PROTO((long increment)); /* should be ptrdiff_t */

VOIDPTR lmalloc PROTO((long size));
VOID lfree PROTO((VOIDPTR));
VOIDPTR lrealloc PROTO((VOIDPTR ptr, long size));

#ifdef __GNUC__
 # ifndef _LIBC
 #  define lmalloc(size) malloc(size)
 #  define lrealloc(ptr, size) realloc(ptr, size)
 #  define lfree(ptr) free(ptr)
 # endif
#endif

#endif /* __STDLIB_H__ */
