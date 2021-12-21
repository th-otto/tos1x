#ifndef __FCNTL_H__
#define __FCNTL_H__ 1

#ifdef __GNUC__
 #ifndef _LIBC
 #  include_next <fcntl.h>
 #  define _NO_FILE
 #endif
#endif

#ifndef _NO_FILE

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

/* File access modes for `open' and `fcntl'.  */
#ifndef O_RDONLY
#define	O_RDONLY	0x00	/* Open read-only.  */
#define	O_WRONLY	0x01	/* Open write-only.  */
#define	O_RDWR		0x02	/* Open read/write.  */

/* Mask for file access modes.  This is system-dependent in case
   some system ever wants to define some other flavor of access.  */
#define	O_ACCMODE	(O_RDONLY|O_WRONLY|O_RDWR)
#endif

#define O_APPEND    0x0008		/* position at EOF */
#define	O_NONBLOCK	0x0100		/* Non-blocking I/O */
#define O_CREAT 	0x0200		/* create new file if needed */
#define O_TRUNC	    0x0400		/* make file 0 length */
#define O_EXCL  	0x0800		/* error if file exists */
#define O_TEXT      0x1000		/* translate cr/lf */


# ifndef R_OK			/* Verbatim from <unistd.h>.  Ugh.  */
/* Values for the second argument to access.
   These may be OR'd together.  */
#  define R_OK	4		/* Test for read permission.  */
#  define W_OK	2		/* Test for write permission.  */
#  define X_OK	1		/* Test for execute permission.  */
#  define F_OK	0		/* Test for existence.  */
# endif

#endif

#ifndef O_BINARY
#define O_BINARY    0
#endif

#endif /* __FCNTL_H__ */
