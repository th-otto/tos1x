#ifndef __SGTTY_H__
#define __SGTTY_H__ 1

/* sgtty.h - tty control information */
/*	Note reduced contents for CP/M implementation... */
struct sgttyb{
	char	sg_ispeed;	/* ignored */
	char	sg_ospeed;	/* ignored */
	char	sg_erase;	/* ignored */
	char	sg_kill;	/* ignored */
	int	sg_flags;	

};
#define XTABS	0006000
#define RAW	0000040
#define CRMOD	0000020
#define ECHO	0000010
#define LCASE	0000004
#define CBREAK	0000002

int stty PROTO((int fd, const struct sgttyb *argp));
int gtty PROTO((int fd, struct sgttyb *argp));

#endif /* __SGTTY_H__ */
