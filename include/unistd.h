#ifndef __UNISTD_H__
#define __UNISTD_H__

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

/* Values for the second argument to access.
   These may be OR'd together.  */
#ifndef F_OK
#define	R_OK	4		/* Test for read permission.  */
#define	W_OK	2		/* Test for write permission.  */
#define	X_OK	1		/* Test for execute permission.  */
#define	F_OK	0		/* Test for existence.  */
#endif

extern char **environ;

int isatty PROTO((int fd));
int isdev PROTO((int fd));
char *ttyname PROTO((int fd));
int dup PROTO((int oldfd));
int dup2 PROTO((int oldfd, int newfd));
int access PROTO((const char *fname, int mode));
int chown PROTO((const char *name, uid_t owner, gid_t group));
pid_t getpid PROTO((NOTHING));
pid_t getppid PROTO((NOTHING));
int unlink PROTO((const char *filename));
int link PROTO((const char *oldpath, const char *newpath));

int execl PROTO((const char *path, const char *arg, ...));
int execlp PROTO((const char *file, const char *arg, ...));
int execle PROTO((const char *path, const char *arg, ... /* , char *const envp[] */));
int execv PROTO((const char *path, char *const argv[]));
int execvp PROTO((const char *file, char *const argv[]));
int execvpe PROTO((const char *file, char *const argv[], char *const envp[]));

char *getpass PROTO((const char *prompt));	/* get password function */
VOID swab PROTO((VOIDPTR from, VOIDPTR to, ssize_t n));

#endif /* __UNISTD_H__ */
