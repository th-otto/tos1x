/*
 *************************************************************************
 *          Revision Control System
 * =======================================================================
 *  $Author: mui $  $Date: 89/04/26 18:25:38 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:25:38  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:28:31  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:34:38  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*
 *  GEMOBJOP.C
 *
 *  -------------------------------------------------------------
 *  GEM Application Environment Services          Version 1.0
 *  TOS Atari operating system
 *  Copyright (C) 1985   Atari Corp.    Digital Research Inc.
 *  -------------------------------------------------------------
 *  Updates:
 *  rewrite     01/03/87        Mike Schmal
 *      ob_sst  -general poor coding rewrite.
 *      get_par -removed unused var.
 *  remove obaddr   06/10/85        Mike Schmal
 *  Reg Opt     03/08/85 - 03/09/85 Derek Mui
 *  Change at ob_sst for extended type  7/7/92  Minna Lai
 *  Remove extended type stuff  1/12/93 Eric Smith
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"

#define	TED_THICKNESS	22

/*
 * ob_sst	Routine to set the user variables pspec, pstate, ptype,
 *		pflags, pt, pth.
 *
 *		returns object border/text color or the 3byte of the pointer
 *		to a tedinfo structure (isn't this help full).
 *
 */
/* 306de: 00e1fc4c */
char ob_sst(P(LPTREE) tree, P(int16_t) obj, P(intptr_t *) pspec, P(int16_t *) pstate, P(int16_t *) ptype, P(int16_t *) pflags, P(GRECT *) pt, P(int16_t *) pth)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(register intptr_t *pspec;)
PP(int16_t *pstate;)
PP(int16_t *ptype;)
PP(register int16_t *pflags;)
PP(GRECT *pt;)
PP(int16_t *pth;)
{
	register int16_t th;
	register OBJECT *tmp;

	tmp = (OBJECT *)OB_NEXT(obj);

	pt->g_w = tmp->ob_width;			/* set user grect width */
	pt->g_h = tmp->ob_height;			/* set user grect height */
	*pflags = tmp->ob_flags;			/* set user flags variable */
	*pspec = tmp->ob_spec;				/* set user spec variable */
	*pstate = tmp->ob_state;			/* set user state variable */

	*ptype = tmp->ob_type & 0x00ff;		/* set user type variable */

	/* IF indirect then get pointer */
	if (*pflags & INDIRECT)
		*pspec = LLGET(tmp->ob_spec);


	th = 0;								/* border thickness */

	switch (*ptype)
	{
	case G_TITLE:						/* menu title thickness = 1 */
		th = 1;
		break;

	case G_TEXT:						/* for these items tedinfo thickness */
	case G_BOXTEXT:
	case G_FTEXT:
	case G_FBOXTEXT:
		th = LWGET(*pspec + TED_THICKNESS);
		break;

	case G_BOX:							/* for these use object thickness */
	case G_BOXCHAR:
	case G_IBOX:
		th = LBYTE2(((char *) pspec));
		break;

	case G_BUTTON:						/* for a button make thicker */
		th--;
		if (*pflags & EXIT)				/* one thicker ( - (neg) is thicker) */
			th--;
		if (*pflags & DEFAULT)			/* still one more thick */
			th--;
		break;
	}

	if (th > 128)
		th -= 256;						/* clamp it */

	*pth = th;							/* set user variable */

	/*
	 * returns object border/text color
	 * or the 3byte of the pointer to a
	 * tedinfo structure (real helpfull)
	 */
	return LBYTE3(((char *) pspec));
}


/* 306de: 00e1fd18 */
VOID everyobj(P(LPTREE) tree, P(int16_t) this, P(int16_t) last, P(EVERYOBJ_CALLBACK) routine, P(int16_t) startx, P(int16_t) starty, P(int16_t) maxdep)
PP(register LPTREE tree;)
PP(register int16_t this;)
PP(register int16_t last;)
PP(EVERYOBJ_CALLBACK routine;)
PP(int16_t startx;)
PP(int16_t starty;)
PP(int16_t maxdep;)
{
	register int16_t tmp1;
	register int16_t depth;
	int16_t x[MAX_DEPTH], y[MAX_DEPTH]; /* BUG: should be MAX_DEPTH+1, since we start with depth==1 */

	x[0] = startx;
	y[0] = starty;
	depth = 1;
	/* non-recursive tree traversal */
  child:
	/* see if we need to to stop */
	if (this == last)
		return;
	/* do this object */
	x[depth] = x[depth - 1] + LWGET(OB_X(this));
	y[depth] = y[depth - 1] + LWGET(OB_Y(this));
	(*routine) (tree, this, x[depth], y[depth]);
	/* if this guy has kids then do them */
	tmp1 = LWGET(OB_HEAD(this));

	if (tmp1 != NIL)
	{
		if (!(LWGET(OB_FLAGS(this)) & HIDETREE) && (depth <= maxdep)) /* BUG: no check for overflow */
		{
			depth++;
			this = tmp1;
			goto child;
		}
	}
  sibling:
	/*
	 * if this is the root which has no parent
	 * or it is the last then stop else...
	 */
	tmp1 = LWGET(OB_NEXT(this));
	if (tmp1 == last || this == ROOT)
		return;
	/*
	 * if this obj. has a sibling that is not
	 *  his parent, then move to him and do him and his kids
	 */
	if (LWGET(OB_TAIL(tmp1)) != this)
	{
		this = tmp1;
		goto child;
	}
	/*
	 * else move up to the parent and finish off his siblings
	 */
	depth--;
	this = tmp1;
	goto sibling;
}



/*
 * Routine that will find the parent of a given object.  The
 * idea is to walk to the end of our siblings and return
 * our parent.  If object is the root then return NIL as parent.
 */
/* 306de: 00e1fe24 */
int16_t get_par(P(LPTREE) tree, P(int16_t) obj)
PP(register LPTREE tree;)
PP(register int16_t obj;)
{
	register int16_t pobj;

	pobj = obj;

	if (obj == ROOT)
		return NIL;

	do
	{
		obj = pobj;
		pobj = LWGET(OB_NEXT(obj));
	} while (LWGET(OB_TAIL(pobj)) != obj);

	return pobj;
}
