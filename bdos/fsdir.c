/*  fsdir - directory routines for the file system			*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>
#include "btools.h"


#if 0 /* old code - no longer used */

VOID freednd PROTO((DND *dn));
int namlen PROTO((const char *s11));
DND *makdnd PROTO((DND *, FCB *b));

/*
 *  makdnd - make a child subdirectory of directory p
 */

DND *makdnd(P(DND *) p, P(FCB *) b)
PP(DND *p;)
PP(FCB *b;)
{
	register DND *p1;
	register DND **prev;
	OFD *fd;
	register int i;
	int in_use;
	fd = p->d_ofd;

	/*
	 *  scavenge a DND at this level if we can find one that has not
	 *  d_left
	 */

	for (prev = &p->d_left; (p1 = *prev) != NULL; prev = &p1->d_right)
	{
		if (!p1->d_left)
		{
			/* check dirtbl[] to see if anyone is using this guy */

			in_use = 0;
			for (i = 1; i < NCURDIR; i++)
				if (diruse[i])
					if (dirtbl[i] == p1)
						in_use = 1;

			if (!in_use && p1->d_files == NULL)
			{
				/* clean out this DND for reuse */

				p1->d_flag = 0;
				p1->d_scan = 0L;
				p1->d_files = (OFD *) 0;
				if (p1->d_ofd)
				{
					oftdel(p1->d_ofd);
				}
				break;
			}
		}
	}

	/* we didn't find one that qualifies, so allocate a new one */

	if (!p1)
	{
		if (!(p1 = MGET(DND)))
			return (DND *) 0;			/* ran out of system memory */

		/* do this init only on a newly allocated DND */
		p1->d_right = p->d_left;
		p->d_left = p1;
		p1->d_parent = p;
	}

	/* complete the initialization */

	p1->d_ofd = (OFD *) 0;
	p1->d_strtcl = b->f_clust;
	swp68((uint16_t *)&p1->d_strtcl);
	p1->d_drv = p->d_drv;
	p1->d_dirfil = fd;
	p1->d_dirpos = fd->o_bytnum - sizeof(FCB);
	p1->d_td.time = b->f_td.time;
	p1->d_td.date = b->f_td.date;
	xmovs(11, (char *) b->f_name, (char *) p1->d_name);

	return p1;
}


/*
 *	namlen -
 *		parameter points to a character string of 11 bytes max
 *
 */

int namlen(P(const char *) s11)
PP(const char *s11;)
{
	int i, len;

	for (i = len = 1; i <= 11; i++, s11++)
		if (*s11 && (*s11 != ' '))
		{
			len++;
			if (i == 9)
				len++;
		}
	return len;
}

/*
 *  freednd - free an allocated and linked-in DND
 *
 */

VOID freednd(P(DND *) dn)
PP(DND *dn;)
{
	DND **prev;

	if (dn->d_ofd)						/* free associated OFD if it's linked */
		xmfreblk(dn->d_ofd);

	for (prev = &(dn->d_parent->d_left); *prev != dn; prev = &((*prev)->d_right))
		;								/* find the predecessor to this DND */
	*prev = dn->d_right;				/* then cut this DND out of the list */

	while (dn->d_left)					/* is this step really necessary? */
		freednd(dn->d_left);

	xmfreblk(dn);				/* finally free this DND */
}

#endif
