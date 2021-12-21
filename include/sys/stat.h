#ifndef __SYS_STAT_H__
#define __SYS_STAT_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <sys/types.h>
#endif

/*  index record flags -- same as on the disk */
/*   0777 - owner, group, and public access bits */

#define		S_IFDIR		0100000		/* directory */
#define		S_IFCHR		0040000		/* char special file */
#define		S_IFBLK		0020000		/* block special file */
#define		S_IFIFO		0010000		/* named pipe (fifo) file */
#define     S_IFLNK     0160000     /* Symbolic link.  */
#define     S_IFREG     0000000     /* regular file */
#define		S_ISUID		0004000		/* set user id upon execution */
#define		S_ISGID		0002000		/* set group id upon execution */
#define		S_ISVTX		0001000		/* Save swapped text after use (sticky bit).  This is pretty well obsolete. */

#define	S_IFMT	(S_IFDIR|S_IFBLK|S_IFCHR|S_IFIFO)

/* Test macros for file types.	*/

#define	__S_ISTYPE(mode, mask)	(((mode) & S_IFMT) == (mask))

#define	S_ISDIR(mode)	 __S_ISTYPE((mode), S_IFDIR)
#define	S_ISCHR(mode)	 __S_ISTYPE((mode), S_IFCHR)
#define	S_ISBLK(mode)	 __S_ISTYPE((mode), S_IFBLK)
#define	S_ISREG(mode)	 __S_ISTYPE((mode), S_IFREG)
#ifdef S_IFIFO
# define S_ISFIFO(mode)	 __S_ISTYPE((mode), S_IFIFO)
#endif
#ifdef S_IFLNK
# define S_ISLNK(mode)	 __S_ISTYPE((mode), S_IFLNK)
#endif


#define S_IREAD		S_IRUSR
#define S_IWRITE	S_IWUSR
#define S_IEXEC		S_IXUSR

#define S_IRUSR         0000400
#define S_IWUSR         0000200
#define S_IXUSR         0000100
#define S_IRGRP         0000040
#define S_IWGRP         0000020
#define S_IXGRP         0000010
#define S_IROTH         0000004
#define S_IWOTH         0000002
#define S_IXOTH         0000001

#define	S_IRWXU	(S_IRUSR|S_IWUSR|S_IXUSR)
#define	S_IRWXG	(S_IRWXU >> 3)
#define	S_IRWXO	(S_IRWXG >> 3)

#define ACCESSPERMS (S_IRWXU|S_IRWXG|S_IRWXO) /* 0777 */
#define ALLPERMS (S_ISUID|S_ISGID|S_ISVTX|S_IRWXU|S_IRWXG|S_IRWXO)/* 07777 */
#define DEFFILEMODE (S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH)/* 0666*/

#define S_BLKSIZE	512	/* Block size for `st_blocks'.  */

struct stat {
	off_t	st_size;		/* file size */
	uid_t	st_uid;			/* file owner id */
	gid_t	st_gid;			/* group id of file */
	int		st_nlink;		/* file reference count */
	long	st_mtime;		/* file modification date and time */
	long	st_atime;		/* file access date and time */
	long	st_ctime;		/* Time of last status change. */
	mode_t	st_mode;		/* file type and access mode */
	int		st_rdev;		/* device for character and block devs */
	int		st_dev;			/* device number where file resides */
	long    st_ino;         /* file serial number. */
	long    st_blksize;     /* Optimal block size for I/O. */
	long    st_blocks;      /* Number 512-byte blocks allocated. */
};

int stat PROTO((const char *path, struct stat *st));
int fstat PROTO((int fd, struct stat *st));

int chmod PROTO((const char *path, mode_t mode));

#endif
