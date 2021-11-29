/*      DESKMEM.C               7/18/89 - 10/4/89       D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"

char *lp_start;
STATIC char *lp_mid;
STATIC char *lp_end;

#define LMSIZE	0x1000L

uint16_t apsize;


/*
 * Init the application buffer
 */
/* 306de: 00e2da38 */
BOOLEAN apbuf_init(NOTHING)
{
	register uint16_t i;
	register APP *app, *app1;
	APP *appsave;

	apsize += APP_NODE;

	if (!(app = (APP *)Malloc((int32_t) (sizeof(APP) * apsize))))
		return FALSE;

	for (i = 0; i < apsize; i++)		/* set up linked array    */
		app[i].a_next = &app[i + 1];

	app[i - 1].a_next = (APP *) 0;

	if (thedesk->applist)						/* we already has an app buffer */
	{									/* then copy the old stuff  */
		app1 = app;
		while (thedesk->applist)
		{								/* save the link list   */
			appsave = app1->a_next;
			*app1 = *thedesk->applist;
			app1->a_next = appsave;
			thedesk->applist = thedesk->applist->a_next;
			if (!thedesk->applist)
			{							/* new free app starts at   */
				thedesk->appfree = app1->a_next;
				app1->a_next = (APP *) 0;
			} else
			{
				app1 = app1->a_next;
			}
		}

		thedesk->applist = app;					/* new using list       */
	} else
	{
		thedesk->appfree = app;
	}
	
	if (thedesk->appnode)
		Mfree(thedesk->appnode);

	thedesk->appnode = app;						/* new app buffer       */

	return TRUE;
}


/*
 * Initalize some memory buffer
 */
/* 306de: 00e2db42 */
BOOLEAN mem_init(NOTHING)
{
	/* Allocate write string buffer */

	if (!(lp_mid = lp_start = (char *)Malloc(LMSIZE)))	/* 2 k memory  */
	{
	m_1:
		do1_alert(FCNOMEM);
		return FALSE;
	}

	lp_end = lp_mid + LMSIZE;

	if (!apbuf_init())
	{
		Mfree(lp_start);				/* free the write buffer    */
		goto m_1;
	}

	return TRUE;
}




/*
 * Fill the path into buffer
 */
/* 306de: 00e2dba8 */
const char *lp_fill(P(const char *) path, P(const char **) buf)
PP(register const char *path;)
PP(const char **buf;)
{
	register char *ptr;
	char *ptr1;

	if (!lp_start)						/* No memory    */
		goto lp_1;

	ptr1 = ptr = lp_mid;

	do
	{
		if (ptr >= lp_end)				/* end of buffer */
		{
		lp_1:
			*buf = NULL;
			return path;
		}

		if (*path == '@')
		{
			*ptr++ = 0;
			path++;
			break;
		}

		*ptr++ = *path;

	} while (*path++);

	lp_mid = ptr;
	*buf = ptr1;
	return path;
}


/*
 * Do the garbage collection of the buffer
 */
/* 306de: 00e2dc08 */
BOOLEAN lp_collect(NOTHING)
{
	register int16_t i;
	char *addr;
	register OBJECT *obj;
	register APP *app;

	addr = (char *)Malloc(LMSIZE);				/* 2 k memory   */
	if (!addr)
	{
		do1_alert(STNOMEM);
		return FALSE;
	}

	obj = background;

	lp_mid = addr;

	lp_end = lp_mid + LMSIZE;

	for (i = 1; i <= obj[0].ob_tail; i++)
	{
		if (obj[i].ob_flags != HIDETREE)
		{
			if (backid[i].i_path)
				lp_fill(backid[i].i_path, &backid[i].i_path);
		}
	}

	app = thedesk->applist;

	while (app)
	{
		lp_fill(app->a_name, &app->a_name);
		app = app->a_next;
	}

	Mfree(lp_start);
	lp_start = addr;
	return TRUE;
}
