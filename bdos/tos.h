#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __STDINT_H__
#include <stdint.h>
#endif

#include "config.h"
#include "bdosdefs.h"



#ifdef __GNUC__
#define unreachable() __builtin_unreachable()
#else
#define unreachable()
#endif

typedef int16_t BOOLEAN;
#define FALSE 0
#define TRUE 1

/* ERROR - error return code */
typedef	int32_t ERROR;
 
#define    ERR      -1L    /* basic, fundamental error     0xffffffff      */

#ifdef __ALCYON__
#  define UNUSED(x)
#else
#  define UNUSED(x) ((void)(x))
#endif

typedef int16_t CLNO;              /* cluster number */ /* BUG: should be unsigned */
typedef int16_t RECNO;             /* record number  */ /* BUG: should be unsigned */
typedef int32_t LRECNO;            /* record number  */ /* BUG: should be unsigned, but Alcyon does not support unsigned long */

VOID _osinit PROTO((NOTHING));
VOID osinit PROTO((NOTHING));
VOID gouser PROTO((NOTHING));

VOID kprintf PROTO((const char *fmt, ...));

typedef int32_t xjmp_buf[3];

extern xjmp_buf errbuf;		/*  in sup.c			*/

int32_t xsetjmp PROTO((xjmp_buf buf));
VOID xlongjmp PROTO((xjmp_buf buf, int32_t rc));


/*
 * compiler support routines for long integer multiply/divide
 */
long lmul PROTO((long l1, long l2));
long ldiv PROTO((long l1, long l2));


#define STATIC
