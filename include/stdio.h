/*****************************************************************************
*
*                   A T A R I  " C"   H E A D E R   F I L E
*                   ---------------------------------------
*       Copyright 1985 by ATARI CORP.  All rights reserved.
*
*       This is the standard include file for the CP/M C Run Time Library.
*
*****************************************************************************/

#ifndef __STDIO_H__
#define __STDIO_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

#ifdef __ALCYON__
#include <varargs.h>
#else
#include <stdarg.h>
#endif

#ifdef __GNUC__
 #ifndef _LIBC
 #  include_next <stdio.h>
 #  define _NO_FILE
 #endif
#endif


#define SEEK_SET	0	/* Seek from beginning of file.  */
#define SEEK_CUR	1	/* Seek from current position.  */
#define SEEK_END	2	/* Seek from end of file.  */

/****************************************************************************
*       Stream I/O File Definitions
*****************************************************************************/

#ifndef _NO_FILE
#define BUFSIZ          512             /*      Standard (ascii) buf size   */
#define MAXFILES        16              /*      Max # open files ( < 32 )   */
struct _iobuf {
         int _fd;                       /* file descriptor for low level io */
         int _flag;                     /* stream info flags                */
        char *_base;                    /* base of buffer                   */
        char *_ptr;                     /* current r/w pointer              */
         int _cnt;                      /* # chars to be read/have been wrt */
};

#ifndef _NO_IOBUF
extern struct _iobuf _iob[MAXFILES];
#endif
typedef struct _iobuf FILE;

/* flag byte definition */
#define _IOREAD 0x0001                  /* readable file                    */
#define _IOWRT  0x0002                  /* writeable file                   */
#define _IOABUF 0x0004                  /* alloc'd buffer                   */
#define _IONBF  0x0008                  /* no buffer                        */
#define _IOFBF  0x0000					/* fully buffered                   */
#define _IOERR  0x0010                  /* error has occurred               */
#define _IOEOF  0x0020                  /* EOF has occurred                 */
#define _IOLBF  0x0040                  /* handle as line buffer            */
#define _IOSTRI 0x0080                  /* this stream is really a string   */
#define _IOASCI 0x0100                  /* this was opened as an ascii file */
#define _IOWRTN 0x0200                  /* write buffer has been modified   */
#define _IOREDN 0x0400                  /* read buffer has been filled      */

#ifdef __GNUC__
extern FILE *stdin;          /* Standard input stream.  */
extern FILE *stdout;         /* Standard output stream.  */
extern FILE *stderr;         /* Standard error output stream.  */
#else
#define stdin  (&_iob[0])               /* standard input stream            */
#define stdout (&_iob[1])               /*    "     output  "               */
#define stderr (&_iob[2])               /*    "     error   "               */
#endif

#define clearerr(p) ((p)->_flag &= ~_IOERR) /* clear error flag             */
#define feof(p) ((p)->_flag & _IOEOF)   /* EOF encountered on stream        */
#define ferror(p) ((p)->_flag & _IOERR) /* error encountered on stream      */
#define fileno(p) ((p)->_fd)            /* get stream's file descriptor     */
#define getchar() getc(stdin)           /* get char from stdin              */
#define putchar(c) putc(c,stdout)       /* put char to stdout               */
#define putc fputc
#define getc fgetc

#endif

/****************************************************************************/
/*                                                                          */
/*                              M A C R O S                                 */
/*                              -----------                                 */
/*                                                                          */
/*      Define some stuff as macros ....                                    */
/*                                                                          */
/****************************************************************************/

#define MAX(x,y)   (((x) > (y)) ? (x) :  (y))   /* Max function             */
#define MIN(x,y)   (((x) < (y)) ? (x) :  (y))   /* Min function             */
#define max(x,y)   (((x) > (y)) ? (x) :  (y))   /* Max function             */
#define min(x,y)   (((x) < (y)) ? (x) :  (y))   /* Min function             */

#define EOF (-1)		/* End of File marker */

int printf PROTO((const char *fmt, ...));
int fprintf PROTO((FILE *fp, const char *fmt, ...));
int sprintf PROTO((char *str, const char *fmt, ...));

int vprintf PROTO((const char *fmt, va_list args));
int vfprintf PROTO((FILE *fp, const char *fmt, va_list args));
int vsprintf PROTO((char *str, const char *fmt, va_list args));

int fputc PROTO((int c, FILE *stream));
int fgetc PROTO((FILE *stream));
char *fgets PROTO((char *str, int maxc, FILE *sp));
int ungetc PROTO((int c, FILE *stream));
char *gets PROTO((char *str));

int fflush PROTO((FILE *stream));
int puts PROTO((const char * str));
int fputs PROTO((const char *str, FILE *sp));

FILE *fopen PROTO((const char * name, const char *mode));
int fclose PROTO((FILE *stream));
FILE *fdopen PROTO((int, const char *mode));
FILE *freopen PROTO((const char *name, const char *mode, FILE *sp));

long ftell PROTO((FILE *sp));
VOID rewind PROTO((FILE *sp));
int fseek PROTO((FILE *stream, long offset, int whence));
size_t fread PROTO((void *ptr, size_t size, size_t nmemb, FILE *stream));
size_t fwrite PROTO((const void *ptr, size_t size, size_t nmemb, FILE *stream));

int open PROTO((const char *pathname, int flags, ...));
int creat PROTO((const char *pathname, mode_t mode));
int close PROTO((int fd));
off_t lseek PROTO((int fd, off_t offs, int whence));
size_t read PROTO((int fd, VOIDPTR buf, size_t count));
size_t write PROTO((int fd, const VOIDPTR buf, size_t count));
off_t tell PROTO((int fd));

int scanf PROTO((const char *format, ...));
int sscanf PROTO((const char *str, const char *format, ...));
int fscanf PROTO((FILE *stream, const char *format, ...));

int vscanf PROTO((const char *format, va_list args));
int vsscanf PROTO((const char *str, const char *format, va_list args));
int vfscanf PROTO((FILE *stream, const char *format, va_list args));

int rename PROTO((const char *from, const char *to));
VOID setbuf PROTO((FILE *sp, char *buf));
int setvbuf PROTO((FILE *sp, char *buf, int mode, size_t size));

/*
 * non-standard functions
 */
long getl PROTO((FILE *sp));
int getw PROTO((FILE *sp));
long putl PROTO((long lnum, FILE *sp));
int putw PROTO((int lnum, FILE *sp));

int fputn PROTO((const char *buf, int num, FILE *sp));

#endif /* __STDIO_H__ */
