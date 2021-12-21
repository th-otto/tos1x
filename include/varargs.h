#ifndef __VARARGS_H__
#define __VARARGS_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

#ifndef __VA_LIST
#define __VA_LIST 1
typedef char *va_list;
#endif

#define va_dcl va_list va_alist;
#define va_start(list) ((list) = (va_list)&va_alist)
#define va_end(list)
#define va_arg(ap, type)    \
    ((sizeof(type) == 1) ? \
    (*(type *)((ap += 2) - 1)) : \
    (*((type *)(ap))++))

#define _va_alist				, va_alist
#define _va_dcl				va_dcl
#define _va_list				va_list
#define _va_start(pvar, prev) va_start(pvar)
#define _va_arg(pvar, type)	va_arg(pvar, type)
#define _va_end(pvar) 		va_end(pvar)

#endif /* __VARARGS_H__ */
