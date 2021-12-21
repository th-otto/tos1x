#ifndef __STDARG_H__
#define __STDARG_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

#ifdef __cplusplus
#  define __USE_STDARG 1
#endif
#ifdef __STDC__
#  define __USE_STDARG 1
#endif

#ifndef __USE_STDARG
#define __USE_VARARGS 1
/* ..it was a lie */
#include <varargs.h>
#else

#ifdef __GNUC__
 #include_next <stdarg.h>
#else

#ifndef __VA_LIST
#define __VA_LIST 1
typedef char *va_list;
#endif


/* Define the standard macros for the user,
   if this invocation was from the user program.  */
#define va_start(ap, parmN) ((ap) = (va_list)...)
#define va_arg(ap, type)    \
    ((sizeof(type) == 1) ? \
    (*(type *)((ap += 2) - 1)) : \
    (*((type *)(ap))++))
#define va_end(ap)

#endif /* __GNUC__ */

#define _va_alist				, ...
#define _va_dcl
#define _va_list				va_list
#define _va_start(pvar, prev) va_start(pvar, prev)
#define _va_arg(pvar, type)	va_arg(pvar, type)
#define _va_end(pvar) 		va_end(pvar)

#endif /* __USE_STDARG */

#endif /* __STDARG_H__ */
