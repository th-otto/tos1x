/*  fsopnclo.c - open/close/create/delete routines for file system	*/

#include "tos.h"
#include <ostruct.h>
#include <toserrno.h>
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include "btools.h"

ERROR xrendir PROTO((DND *dn, const char *name, const char *to));


#if GEMDOS >= 0x15
/* 306de: 00e16c48 */
/* 306us: 00e16bee */
/* 104de: 00fc766a */
ERROR xrendir(P(DND *) dn, P(const char *) name, P(const char *) to)
PP(DND *dn;)
PP(const char *name;)
PP(const char *to;)
{
	char buf[20];
	const char *s1;
	DND *dn1;
	register int i;
	
	UNUSED(i);
	
	if (contains_dots(to, 0))
		return E_BADRQ;

	if ((dn1 = findit(name, &s1, 1)) == NULL)
		return E_PTHNF;
	builds(to, buf);
	xmovs(11, buf, dn1->d_name);
	ixlseek(dn1->d_dirfil, dn1->d_dirpos);
	ixwrite(dn1->d_dirfil, 11L, buf);
	return ixclose(dn1->d_dirfil, CL_DIR);
}
#endif


#if 0 /* old code no longer in use */

FTAB *sftsrch PROTO((int field, VOIDPTR ptr));

/*
 *  used in calls to sftsrch to distinguish which field we are matching on
 */

#define	SFTOFD		0
#define	SFTOWNER	1

/*
 *  SFTOFDSRCH - search sft for entry with matching OFD ptr
 *	call sftsrch with correct parms
 */

#define	SFTOFDSRCH(o)	sftsrch( SFTOFD , (char *) o )

/*
 *  SFTOWNSRCH - search sft for entry with matching PD
 *	call sftsrch with correct parms
 */

#define	SFTOWNSRCH(p)	sftsrch( SFTOWN , (char *) p )


/*
 *  sftsrch - search the sft for an entry with the specified OFD
 *  returns:
 *	ptr to the matching sft, or
 *	NULL
 */

FTAB *sftsrch(P(int) field, P(VOIDPTR) ptr)
PP(int field;)								/*  which field to match on     */
PP(VOIDPTR ptr;)								/*  ptr to match on         */
{
	register FTAB *sftp;						/*  scan ptr for sft            */
	register int i;
	register OFD *ofd;
	register PD *pd;

	switch (field)
	{
	case SFTOFD:
		for (i = 0, sftp = sft, ofd = (OFD *) ptr; i < OPNFILES && sftp->f_ofd != ofd; ++i, ++sftp)
			;
		break;
	case SFTOWNER:
		for (i = 0, sftp = sft, pd = (PD *) ptr; i < OPNFILES && sftp->f_own != pd; ++i, ++sftp)
			;
		break;
	default:
		i = OPNFILES;					/* setup for null return  */
	}
	return i >= OPNFILES ? (FTAB *) NULL : sftp;
}

/*
**  sftdel - delete an entry from the sft
**	delete the entry from the sft.  If no other entries in the sft
**	have the same ofd, free up the OFD, also.
*/

VOID sftdel(P(FTAB *) sftp)
PP(FTAB *sftp;)
{
	register FTAB *s;
	register OFD *ofd;

	/*  clear out the entry  */

	ofd = (s = sftp)->f_ofd;

	s->f_ofd = 0;
	s->f_own = 0;
	s->f_use = 0;

	/*  if no other sft entries with same OFD, delete ofd  */

	if (SFTOFDSRCH(ofd) == NULL)	/* M01.01.1023.03 */
		xmfreblk(ofd);
}

#endif
