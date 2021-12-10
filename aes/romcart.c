/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:30:35 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:30:35  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:32:18  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:36:19  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	ROMCART.C		2/26/85 - 04/14/85	Lowell Webster	*/
/*	remove cart_start	06/10/85		Mike Schmal	*/
/*	Fix the cart_exe	07/09/85		Derek Mui	*/
/*	Fix the cart_app	3/21/86			Derek Mui	*/
/*	Added sh_rom at cart_find	3/21/86		Derek Mui	*/
/*	Comment out cart_app	7/2/86			Derek Mui	*/
/*	Take out sh_rom		7/2/86			Derek Mui	*/
/*	Clean up		1/21/88			D.Mui		*/
/*	Added c_sfirst()	6/18/90			D.Mui		*/


#include "aes.h"
#include "gemlib.h"
#include "dos.h"


#define CART_BASE 0xFA0000L
#define CART_START 0xFA0004L
#define CART_MAGIC 0xABCDEF42L
#define CA_ISCRYS 0x40000000L
#define CA_ISPARM 0x80000000L
#define TEXTBASE 8

#define CARTNODE struct cartnode
CARTNODE
{
	CARTNODE *c_next;
	intptr_t c_init;
	intptr_t c_code;
	int16_t c_time;
	int16_t c_date;
	int32_t c_size;
	char c_name[14];
};

STATIC CARTNODE *cart_ptr;
STATIC char *cart_dta;


CARTNODE *cart_find PROTO((BOOLEAN fill));



/* 306de: 00e230a4 */
/* 104de: 00fe652a */
/* 106de: 00e28c5c */
BOOLEAN cart_init(NOTHING)
{
	cart_ptr = ((CARTNODE *) CART_BASE);
	if (cart_ptr->c_next == (CARTNODE *)CART_MAGIC)
	{
		cart_ptr = ((CARTNODE *) CART_START);
		return TRUE;
	} else
	{
		cart_ptr = NULL;
		return FALSE;
	}
}


/* 306de: 00e230de */
/* 104de: 00fe6562 */
/* 106de: 00e28c96 */
CARTNODE *cart_find(P(BOOLEAN) fill)
PP(BOOLEAN fill;)
{
	register char *pdta;
	register CARTNODE *pcart;

	if (cart_ptr)
	{
		if (fill)
		{
			pdta = cart_dta;
			bfill(42, 0, pdta);		/* zero it out  */
			pdta[21] = F_RDONLY;		/* fill time,date,size,name */
			LBCOPY(&pdta[22], &cart_ptr->c_time, 21);
		}
		pcart = cart_ptr;
		cart_ptr = cart_ptr->c_next;	/* point to next    */
		return pcart;
	}
	return NULL;
}


/* 306de: 00e2314e */
/* 104de: 00fe65c2 */
/* 106de: 00e28d06 */
BOOLEAN cart_sfirst(P(char *) pdta, P(int16_t) attr)
PP(char *pdta;)
PP(int16_t attr;)
{
	UNUSED(attr);
	cart_dta = pdta;
	cart_init();
	return cart_snext();
}


/* 306de: 00e23164 */
/* 104de: 00fe65d4 */
/* 106de: 00e28d1c */
BOOLEAN cart_snext(NOTHING)
{
	if (cart_find(TRUE))
		return TRUE;
	else
	{
		DOS_AX = E_NOFILES;
		return FALSE;
	}
}


/* 306de: 00e23188 */
/* 104de: 00fe65f4 */
/* 106de: 00e28d40 */
int16_t ld_cartacc(NOTHING)
{
	register char *psp;
	register CARTNODE *pcart;
	register int16_t num_load;

	cart_init();
	num_load = 0;
	while ((pcart = cart_find(FALSE)))
	{
		if (wildcmp("*.ACC", pcart->c_name))
		{
			if (cre_aproc())			/* create PD    */
			{
				num_load++;
				psp = (char *)dos_exec("", 5, "");	/* create psp   */
				LLSET(&psp[TEXTBASE], pcart->c_code);
				pstart(gotopgm, pcart->c_name, (intptr_t)psp);	/* go for it    */
			} else
				break;
		}
	}
	return num_load;
}


/* 306de: 00e2320a */
/* 104de: 00fe665a */
/* 106de: 00e28dc2 */
BOOLEAN cart_exec(P(const char *) pcmd, P(const char *) ptail)
PP(const char *pcmd;)
PP(const char *ptail;)
{
	register char *psp;
	register CARTNODE *pcart;

	cart_init();

	while ((pcart = cart_find(FALSE)))
	{
		if (streq(pcmd, pcart->c_name))
			break;
	}
	psp = (char *)dos_exec("", 5, ptail);
	LLSET(&psp[TEXTBASE], pcart->c_code);
	dos_exec("", 4, psp);
#if AESVERSION >= 0x200
	/* free the env */
	dos_free(*(char **) (&psp[0x2c]));
#endif
	dos_free(psp);
	return TRUE;
}


#if AESVERSION >= 0x200
/* 306de: 00e23288 */
BOOLEAN c_sfirst(P(const char *) path)
PP(const char *path;)
{
	const char *file;
	CARTNODE *pcart;

	file = g_name(path);
	cart_init();
	while ((pcart = cart_find(FALSE)))
	{
		if (streq(file, pcart->c_name))
			return TRUE;
	}

	return FALSE;
}
#endif
