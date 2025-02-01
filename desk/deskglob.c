#include "desktop.h"

intptr_t drawstk;

/* 100de: 00fee7dc */
VOID desk_alloc(NOTHING)
{
	/* initialize libraries	*/
	thedesk = (THEDSK *)dos_alloc(((long)sizeof(THEDSK)) & 0xffffL); /* careful: sizeof(THEDSK) is >32k and would be sign-extended */
	bfill(sizeof(THEDSK), 0, thedesk);
	g_buffer = dos_alloc(512L);
	g_wlist = (DESKWIN *)dos_alloc(NUM_WNODES * (long)sizeof(DESKWIN));
	/*
	 * no check for allocation failure here...
	 * why not allocate that static? its never changed
	 */
	drawstk = (intptr_t)dos_alloc(0x00000400L);     /* draw stack is 1K */
	drawstk += 0x00000400L;			/* init to top */
}


/* 100de: 00fee834 */
VOID desk_free(NOTHING)
{
	dos_free((VOIDPTR)thedesk->a_buffstart);
	dos_free((VOIDPTR)thedesk->icondata);
	rsrc_free();						/* free up resource */
	drawstk -= 0x00000400L;				/* reset to bottom  */
	dos_free((VOIDPTR)drawstk);
	dos_free(g_buffer);
	dos_free(thedesk);
	dos_free(g_wlist);
}
