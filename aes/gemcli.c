/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:21:22 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:21:22  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:25:02  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:31:09  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	Crunch at ldaccs	3/18/88			D.Mui		*/
/*	Take out sysacc define		2/11/88		D.Mui		*/
/*	Fix at ldaccs .. load accessory from root  10/23/85 D.Mui	*/
/*	Fix at ldaccs for *.acc file	09/09/85	Derek Mui	*/
/*	Fix at ldaccs for no disk 	08/28/85	Derek Mui	*/
/*	Change ldaccs	07/15/85 - 07/16/85	Derek Mui		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	to 68k		02/22/85 - 05/20/85	LKW			*/
/*	GEMCLI.C	1/28/84 - 02/02/85	Lee Jay Lorenzen	*/
/*	Make used_acc as global	7/16/90		D.Mui			*/
/*	Start the process in to be suspended state 8/9/90	D.Mui	*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "gemrsc.h"


ACCPD *gl_pacc[MAX_ACCS];		/* total of 6 desk acc, 1 from rom  */
int16_t gl_naccs;
char *gl_adacc[MAX_ACCS];		/* addresses of accessories */
char *sys_adacc;
#if AESVERSION >= 0x200
STATIC int16_t used_acc;		/* currently number of acc  */
#endif


#if AESVERSION >= 0x200
/*
 * Make sure everybody is on the suspend list before going on
 */
/* 306de: 00e1adde */
VOID release(NOTHING)
{
	register PD *p;

	while (TRUE)
	{
		if (!rlr)						/* make sure everyone is finished its stuff */
			break;

		if (((!rlr->p_pid) || (rlr->p_pid == 1)) && (!rlr->p_link))
			break;

		dsptch();
	}

	p = slr;

	while (p)
	{
		p->p_stat = PS_MWAIT;
		p = p->p_link;
	}

	if (!nrl)							/* append all the processes to  */
		nrl = slr;						/* the end of the waiting list  */
	else
	{
		p = nrl;

		while (p)
		{
			if (!p->p_link)
			{
				p->p_link = slr;
				break;
			} else
				p = p->p_link;
		}
	}

	slr = (PD *) 0;
}
#endif


#if AESVERSION >= 0x200
/*
 * Give everyone a chance to run, at least once
 */
/* 306de: 00e1ae70 */
VOID all_run(NOTHING)
{
	int16_t i;

	for (i = 0; i < used_acc; i++)
		dsptch();
	/* then get in the wait line */
	wm_update(BEG_UPDATE);
	wm_update(END_UPDATE);
}
#endif


/*
 *	Routine to load program file pointed at by pfilespec, then
 *	create new process context for it.  This uses the load overlay
 *	function of DOS.  The room for accessories variable will be
 *	decremented by the size of the accessory image.  If the
 *	accessory is too big to fit it will be not be loaded.
 */
/* 306de: 00e1aea6 */
/* 106de: 00e1f0a4 */
/* 100de: 00fe3842 */
LINEF_STATIC int16_t sndcli(P(char *) pfilespec, P(int16_t) acc)
PP(register char *pfilespec;)
PP(int16_t acc;)
{
	register int16_t handle;
	int16_t err_ret;
	intptr_t ldaddr;
#if AESVERSION >= 0x200
	PD *p;
#endif

	strcpy(D.s_cmd, pfilespec);
	handle = dos_open(ad_shcmd, RMODE_RD);
	if (!DOS_ERR)
	{									/* allocate PD memory for accessory */
		if (acc != 0)
			err_ret = cre_aproc();
		else
			err_ret = TRUE;

		if (err_ret)
		{
			err_ret = pgmld(handle, &D.s_cmd[0], &ldaddr);	/*, paccroom); */
			dos_close(handle);
			/* create process to execute it */
			if (err_ret != -1)
			{
				if (acc == 0)
					sys_adacc = (char *)ldaddr;
				else
					gl_adacc[gl_naccs] = (char *)ldaddr;	/* save acc address */

#if AESVERSION >= 0x200
				p = pstart(gotopgm, pfilespec, ldaddr);
				p->p_stat |= PS_TRYSUSPEND;
#else
				pstart(gotopgm, pfilespec, ldaddr);
#endif
				return TRUE;
			}
		}
		return FALSE;
	} else
	{
		return FALSE;
	}
}


/*
 *	Routine to load in desk accessory's.  Files by the name of *.ACC
 *	will be loaded, if there is sufficient room for them in the system.
 *	If SYSTEM.ACC is not zero, it is treated as the beginning of a
 *	desk accessory in system rom and is executed.
 *	The cartridge is searched for *.ACC and each one is executed.
 *	If there is any space left, *.ACC etc. are then loaded from disk.
 *	It will first try the hard disk, if there is no acc files then it
 *	will go back to the boot drive.
 */
/* 306de: 00e1af76 */
/* 106de: 00e1f166 */
/* 100de: 00fe38ee */
VOID ldaccs(NOTHING)
{
	register int16_t i;
	int16_t ret;
#if AESVERSION < 0x200
	int16_t used_acc;		/* currently number of acc  */
#endif
	char *psp;
	int16_t defdrv;
	char *tempadds;
	char *name;

	UNUSED(psp);
	
	gl_naccs = 0;
	used_acc = 0;

	if (cart_init())
		used_acc += ld_cartacc();

	if (isdrive() && diskin)
	{
		defdrv = dos_gdrv();			/* save the default drive   */
		tempadds = dos_alloc(50L);
		name = tempadds;
		dos_sdta(tempadds);					/* set the DMA address      */

		if (isdrive() & 0x04)
			dos_sdrv(0x02);				/* set the hard disk    */
		/* search the file  */
		dos_chdir("\\");				/* always at root   */
		ret = dos_sfirst("\\*.ACC", 0);
		if (!ret)
			dos_sdrv(defdrv);			/* if not at the hard   */
		/* disk go back to defa */

		dos_chdir("\\");				/* always at root   */
		ret = dos_sfirst("\\*.ACC", 0);

		name += 0x1EL;

		for (i = 0; i < MAX_ACCS && used_acc < MAX_ACCS && ret; i++)
		{
			ret = sndcli(name, used_acc);
			if (ret)
				used_acc++;

			ret = dos_snext();
		}
		dos_free(tempadds);
	}
}


/* 306de: 00e1b084 */
/* 106de: 00e1f26a */
/* 100de: 00fe39d0 */
VOID free_accs(NOTHING)
{
	register int16_t i;
	register char *ptmp;

	if (sys_adacc)
	{
		dos_free((VOIDPTR)LLGET(sys_adacc + 0x2c));	/* free environment string */
		dos_free(sys_adacc);
	}

	for (i = 0; i < gl_naccs; i++)
	{
		ptmp = gl_adacc[i];
		dos_free((VOIDPTR)LLGET(ptmp + 0x2c));	/* free environment string */
		dos_free(ptmp);					/* free acc's memory        */
		dos_free(gl_pacc[i]);			/* free process descriptors */
	}
}


/* 306de: 00e1b0fe */
/* 106de: 00e1f2e4 */
/* 100de: 00fe3a2e */
BOOLEAN cre_aproc(NOTHING)
{
	register PD *ppd;
	UDA *puda;
	CDA *pcda;
	register EVB *pevb;
	register ACCPD *paccpd;
	register int16_t i;

	paccpd = (ACCPD *) dos_alloc((uint32_t) sizeof(ACCPD));
	if (paccpd)
	{
#if AESVERSION >= 0x200
		bfill(sizeof(ACCPD), 0, paccpd);
#endif
		gl_pacc[gl_naccs] = paccpd;
		ppd = &paccpd->ac_pd;
		puda = &paccpd->ac_uda;
		pcda = &paccpd->ac_cda;
		pevb = paccpd->ac_evb;

		pinit(ppd, pcda);
		ppd->p_uda = puda;
		puda->u_spsuper = &puda->u_supstk;
		for (i = 0; i < EVB_PROC; i++)
		{
			pevb[i].e_nextp = eul;
			eul = &pevb[i];
		}
		return TRUE;
	}
	return FALSE;
}
