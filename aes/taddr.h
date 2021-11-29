/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:31:12 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:31:12  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:32:33  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:36:30  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	TADDR.H		04/11/84 - 09/11/84	Gregg Morris		*/

#ifndef TADDR_H
#define TADDR_H 1

#define OB_NEXT(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 0)
#define OB_HEAD(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 12)
#define OB_X(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x) (((intptr_t)(tree)) + (x) * sizeof(OBJECT) + 22)

#endif
