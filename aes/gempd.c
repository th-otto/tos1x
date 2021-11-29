/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:26:10 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:26:10  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:29:02  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:34:49  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMPD.C		1/27/84 - 02/09/85	Lee Jay Lorenzen	*/
/*	pstart bugs	2/12/85 - 03/22/85	LKW			*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Move insert_process to GEMDISP	07/12/85	Derek Mui	*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"


BOOLEAN fapd PROTO((const char *pname, int16_t pid, PD *ppd));
PD *getpd PROTO((NOTHING));


/* 306de: 00e1fe68 */
BOOLEAN fapd(P(const char *) pname, P(int16_t) pid, P(PD *) ppd)
PP(const char *pname;)
PP(int16_t pid;)
PP(register PD *ppd;)
{
	register BOOLEAN ret;
	char temp[9];

	ret = FALSE;
	temp[8] = 0;
	if (pname != NULL)
	{
		movs(8, ppd->p_name, temp);
		ret = streq(pname, temp);
	} else
	{
		ret = (ppd->p_pid == pid);
	}
	return ret;
}


/* 306de: 00e1fec8 */
PD *fpdnm(P(const char *) pname, P(uint16_t) pid)
PP(const char *pname;)
PP(uint16_t pid;)
{
	register int16_t i;
	PD *ppd;

	UNUSED(ppd);
	for (i = 0; i < NUM_PDS; i++)
	{
		if (fapd(pname, pid, &D.g_pd[i]))
			return &D.g_pd[i];
	}
	for (i = 0; i < gl_naccs; i++)
	{
		if (fapd(pname, pid, &gl_pacc[i]->ac_pd))
			return &gl_pacc[i]->ac_pd;
	}
	return NULL;
}


/* 306de: 00e1ff64 */
PD *getpd(NOTHING)
{
	PD *p;

	if (curpid < NUM_PDS)				/* get a new PD     */
	{
		p = &D.g_pd[curpid];
		p->p_pid = curpid++;
	} else								/* otherwise get it     */
	{									/* accessory's PD list  */
		p = &gl_pacc[gl_naccs]->ac_pd;
		p->p_pid = NUM_PDS + gl_naccs++;
	}
	/* initialize his DS&SS registers so stproc works   */
	/* setdsss(p->p_uda);   */
/*	setdsss(puda)
*		UDA	*puda;
*
*	set "segment " into u_ssuper and u_ssuser
*	and set u_insuper to TRUE
*
*	in 68k u_ssuper and u_ssuser do not exist
*/

	p->p_uda->u_insuper = 1;
	/* return the pd we got */
	return p;
}


/* 306de: 00e1ffde */
VOID p_nameit(P(PD *) p, P(const char *) pname)
PP(PD *p;)
PP(const char *pname;)
{
	bfill(8, ' ', p->p_name);
	strscn(pname, p->p_name, '.');
}


/* 306de: 00e20018 */
PD *pstart(P(VOIDPTR) pcode, P(const char *) pfilespec, P(intptr_t) ldaddr)
PP(VOIDPTR pcode;)
PP(const char *pfilespec;)
PP(intptr_t ldaddr;)
{
	register PD *px;

	/* create process to execute it */
	px = getpd();
	px->p_ldaddr = ldaddr;
	/* copy in name of file */
	p_nameit(px, pfilespec);
	/* cs, ip, use 0 flags  */
	psetup(px, pcode);
	/* link him up */
	px->p_stat = PS_RUN;
	px->p_link = drl;
	drl = px;

	return px;
}
