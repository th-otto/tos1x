/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:23:20 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:23:20  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:26:46  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:33:58  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMGLOBE.C 	4/23/84 - 01/29/85	Lee Lorenzen		*/
/*	to 68k		4/08/85			Lowell Webster		*/
/*	Update		1/15/88			D.Mui			*/


/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"

THEGLO D;

/*
 *	return size in words of struct THEGLO
 */
int16_t size_theglo(NOTHING)
{
	return sizeof(THEGLO) / 2;
}
