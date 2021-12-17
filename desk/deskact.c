/*	DESKACT.C	06/11/84 - 09/05/85		Lee Lorenzen	*/
/*	merged source	5/18/87 - 5/28/87		mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985 - 1987		Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "desktop.h"

/* 104de: 00fd5bfe */
/* 106de: 00e161a0 */
LINEF_STATIC int16_t gr_obfind PROTO((OBJECT *tree, int16_t root, int16_t mx, int16_t my));


/* 104de: 00fd5c50 */
/* 106de: 00e16200 */
LINEF_STATIC VOID move_drvicon PROTO((OBJECT *tree, int16_t root, int16_t x, int16_t y, int16_t *pts));


/* 104de: 00fd5d7c */
/* 106de: 00e16340 */
LINEF_STATIC VOID gr_extent PROTO((int16_t numpts, int16_t *xylnpts, GRECT *pt));


/* 104de: 00fd5e3a */
/* 106de: 00e1640a */
LINEF_STATIC VOID gr_plns PROTO((int16_t x, int16_t y, int16_t numpts, int16_t *xylnpts, int16_t numobs, int16_t *xyobpts));


/* 104de: 00fd5e9a */
/* 106de: 00e1647e */
LINEF_STATIC int16_t gr_bwait PROTO((GRECT *po, int16_t mx, int16_t my, int16_t numpts, int16_t *xylnpts, int16_t numobs, int16_t *xyobpts));


/* 104de: 00fd5f34 */
/* 106de: 00e16528 */
LINEF_STATIC VOID gr_drgplns PROTO((int16_t in_mx, int16_t in_my, GRECT *pc, int16_t numpts, int16_t *xylnpts, int16_t numobs, int16_t *xyobpts, int16_t *pdulx, int16_t *pduly, int16_t *pdwh, int16_t *pdobj));


/* 104de: 00fd6228 */
/* 106de: 00e16852 */
LINEF_STATIC int16_t act_chkobj PROTO((OBJECT *tree, int16_t root, int16_t obj, int16_t mx, int16_t my, int16_t w, int16_t h));


/* 104de: 00fd637e */
/* 106de: 00e169cc */
BOOLEAN act_chg PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t obj, GRECT *pc, uint16_t chgvalue, int16_t dochg, int16_t dodraw, int16_t chkdisabled));


/* 104de: 00fd6452 */
/* 106de: 00e16ab8 */
VOID act_allchg PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t ex_obj, GRECT *pt, GRECT *pc, int16_t chgvalue, BOOLEAN dochg, BOOLEAN dodraw, BOOLEAN dox));


/* 104de: 00fd65ba */
/* 106de: 00e16c46 */
VOID act_bsclick PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t mx, int16_t my, int16_t keystate, GRECT *pc, int16_t dclick));


/* 104de: 00fd66ba */
/* 106de: 00e16d56 */
int16_t act_bdown PROTO((int16_t wh, OBJECT *tree, int16_t root, int16_t *in_mx, int16_t *in_my, int16_t keystate, GRECT *pc, int16_t *pdobj));

