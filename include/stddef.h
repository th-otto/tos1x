#ifndef __STDDEF_H__
#define __STDDEF_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

/* hmmm... that should work even for non-ANSI compiler, but is miscompiled by Alcyon-C */

#ifndef __ALCYON__
/* Offset of member MEMBER in a struct of type TYPE. */
#define offsetof(TYPE, MEMBER) ((size_t)&(((TYPE *)0)->MEMBER))
#endif

#endif /* __STDDEF_H__ */
