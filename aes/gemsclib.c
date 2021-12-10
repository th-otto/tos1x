/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:26:50 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:26:50  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:29:27  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:07  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMSCLIB.C	07/10/84 - 02/02/85	Lee Lorenzen		*/
/*	to 68k		03/08/85		Lowell Webster		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"


/*
 * AES #80 - scrp_read - Scrap read
 */
/* 306de: 00e20b2e */
/* 104de: 00fe3f9e */
/* 106de: 00e262fc */
VOID sc_read(P(char *) pscrap)
PP(char *pscrap;)
{
	LSTCPY(pscrap, &D.g_scrap[0]);
}


/*
 * AES #81 - scrp_write - Scrap write
 */
/* 306de: 00e20b48 */
/* 104de: 00fe3fb2 */
/* 106de: 00e26316 */
VOID sc_write(P(const char *) pscrap)
PP(const char *pscrap;)
{
	LSTCPY(&D.g_scrap[0], pscrap);
}
