/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:25:25 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:25:25  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:28:23  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.4  89/02/12  01:05:56  kbad
 * reg opt ob_stfn, ob_delit
 * 
 * Revision 1.3  88/11/01  18:02:24  kbad
 * changed ob_center so X coordinate doesn't have to be char aligned
 * 
 * Revision 1.2  88/10/24  10:32:09  mui
 * fix ob_center to count the shadow
 * 
 * Revision 1.1  88/06/02  12:34:34  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMOBED.C	05/29/84 - 02/10/85		Gregg Morris	*/
/*	Reg Opt		03/08/85 - 03/09/85		Derek Mui	*/
/*	1.1		03/21/85 - 04/05/85		Lowell Webster	*/
/*	Redefine del code 	   05/24/85		Derek Mui	*/
/*	Trying 1.2		   10/14/85		Derek Mui	*/
/*	Fix at ob_center	   3/16/87		Derek Mui	*/
/*	Modify rsc constants	   11/25/87		D.Mui		*/
/*	Fix at find_pos		   03/25/88		D.Mui		*/
/*	Inclined code of ob_getsp  03/25/88		D.Mui		*/
/*	Change at ob_center for 3D buttons	7/7/92	D.Mui		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gemrsc.h"

#undef LEFT
#undef RIGHT

#define BACKSPACE 0x0E08				/* backspace        */
#define SPACE 0x3920					/* ASCII <space>    */
#define UP 0x4800						/* up arrow     */
#define DOWN 0x5000						/* down arrow       */
#define LEFT 0x4B00						/* left arrow       */
#define RIGHT 0x4D00					/* right arrow      */
#define DELETE 0x537f					/* keypad delete    */
#define TAB 0x0F09						/* tab          */
#define BACKTAB 0x0F00					/* backtab      */
#define RETURN 0x1C0D					/* carriage return  */
#define ENTER 0x720D					/* enter key on keypad  */
#define ESCAPE 0x011B					/* escape       */

#define BYTESPACE 0x20					/* ascii space in bytes */

#if !BINEXACT
static TEDINFO edblk;
#endif



/* 100de: 00fe8cfc */
LINEF_STATIC VOID ob_getsp(P(LPTREE) tree, P(int16_t) obj, P(TEDINFO *) pted)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(TEDINFO *pted;)
{
	int16_t flags;
	register intptr_t spec;

	flags = LWGET(OB_FLAGS(obj));
	spec = LLGET(OB_SPEC(obj));
	if (flags & INDIRECT)
		spec = LLGET(spec);

	LBCOPY(ADDR(pted), (VOIDPTR)spec, sizeof(TEDINFO));
}


/*
 * AES #54 - form_center - Centre an object on the screen.
 */
/* 306de: 00e1f40e */
/* 104de: 00fe2584 */
/* 106de: 00e245b2 */
/* 100de: 00fe8d4a */
VOID ob_center(P(LPTREE) tree, P(GRECT *)pt)
PP(LPTREE tree;)
PP(GRECT *pt;)
{
	register int16_t xd, yd, wd, hd;
	register intptr_t plong;

	plong = OB_X(ROOT);
	wd = LWGET(plong + 0x04L);
	hd = LWGET(plong + 0x06L);			/* pixel center, no character snap 881101 */
	xd = ((gl_width - wd) / 2) / gl_wchar * gl_wchar;
	yd = gl_hbox + ((gl_height - gl_hbox - hd) / 2);
	LWSET(plong, xd);
	LWSET(plong + 0x02L, yd);

#if AESVERSION >= 0x140
	{
	int16_t iword, th;
	int32_t ilong;
	GRECT rec;
	/* account for outline  */
	if (LWGET(OB_STATE(ROOT)) & OUTLINED)
	{
		xd -= (xd >= 3) ? 3 : xd;		/* don't go off the screen */
		yd -= (yd >= 3) ? 3 : yd;
		wd += 6;
		hd += 6;
	}

	if (LWGET(OB_STATE(ROOT)) & SHADOWED)
	{
		ob_sst(tree, ROOT, &ilong, &iword, &iword, &iword, &rec, &th);
		th = (th > 0) ? th : -th;
		th = 2 * th;
		wd += th;
		hd += th;
	}
	}
#else
	/* account for outline or shadow */
	if (LWGET(OB_STATE(ROOT)) & (OUTLINED /* | SHADOWED */))
	{
		xd -= 3;
		yd -= 3;
		wd += 6;
		hd += 6;
	}
#endif

	r_set(pt, xd, yd, wd, hd);
}


/*
 *	Routine to scan thru a string looking for the occurrence of
 *	the specified character.  IDX is updated as we go based on
 *	the '_' characters that are encountered.  The reason for
 *	this routine is so that if a user types a template character
 *	during field entry the cursor will jump to the first 
 *	raw string underscore after that character.
 */
/* 104de: 00fe2674 */
/* 106de: 00e246b2 */
/* 100de: 00fe8dd6 */
LINEF_STATIC int16_t scan_to_end(P(char *) pstr, P(int16_t) idx, P(char) chr)
PP(register char *pstr;)
PP(register int16_t idx;)
PP(char chr;)
{
	while (*pstr && *pstr != chr)
	{
		if (*pstr++ == '_')
			idx++;
	}
	return idx;
}


/*
 *	Routine to insert a character in a string by
 */
/* 104de: 00fe26a0 */
/* 106de: 00e246e6 */
/* 100de: 00fe8e02 */
VOID ins_char(P(char *) str, P(int16_t) pos, P(char) chr, P(int16_t) tot_len)
PP(register char *str;)
PP(int16_t pos;)
PP(char chr;)
PP(register int16_t tot_len;)
{
	register int16_t ii, len;

	len = strlen(str);

	for (ii = len; ii > pos; ii--)
		str[ii] = str[ii - 1];
	str[ii] = chr;
	if (len + 1 < tot_len)
		str[len + 1] = '\0';
	else
		str[tot_len - 1] = '\0';
}


/*
 *       Routine that returns a format/template string relative number
 *       for the position that was input (in raw string relative numbers).
 *       The returned position will always be right before an '_'.
 */
/* 104de: 00fe26fc */
/* 106de: 00e2474e */
/* 100de: 00fe8e5e */
LINEF_STATIC int16_t find_pos(P(char *) str, P(int16_t) pos)
PP(register char *str;)
PP(register int16_t pos;)
{
	register int16_t i;

	for (i = 0; pos > 0; i++)
	{
		if (str[i] == '_')
			pos--;
	}
	/* skip to first one    */
	while ((str[i]) && (str[i] != '_'))
		i++;
#if AESVERSION >= 0x140
/* here we may have come to the end of the string without finding a field
	backup to the last position where there was one and advance one
	position past it...						*/

	if (str[i] == 0)
	{
		while ((str[i] != '_') && i >= 0)
			i--;
		if (str[i])
			i++;
	}
#endif
	return i;
}


/* 104de: 00fe2764 */
/* 106de: 00e247be */
/* 100de: 00fe8ea0 */
LINEF_STATIC VOID pxl_rect(P(LPTREE) tree, P(int16_t) obj, P(int16_t) ch_pos, P(GRECT *) pt)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(int16_t ch_pos;)
PP(register GRECT *pt;)
{
	GRECT o;
	int16_t numchs;

	ob_actxywh(tree, obj, &o);
	numchs = gr_just(edblk.te_just, edblk.te_font, edblk.te_ptmplt, o.g_w, o.g_h, &o);
	pt->g_x = o.g_x + (ch_pos * gl_wchar);
	pt->g_y = o.g_y;
	pt->g_w = gl_wchar;
	pt->g_h = gl_hchar;
	UNUSED(numchs);
}


/*
 *	Routine to redraw the cursor or the field being editted.
 */
/* 104de: 00fe27d2 */
/* 106de: 00e2483c */
/* 100de: 00fe8f12 */
LINEF_STATIC VOID curfld(P(LPTREE) tree, P(int16_t) obj, P(int16_t) new_pos, P(int16_t) dist)
PP(LPTREE tree;)
PP(int16_t obj;)
PP(int16_t new_pos;)
PP(int16_t dist;)
{
	GRECT oc, t;

	pxl_rect(tree, obj, new_pos, &t);
	if (dist)
	{
		t.g_w += (dist - 1) * gl_wchar
		/* the "+1" is necessary or the cursor isn't always redrawn properly ++ERS 1/19/93 */
#if AESVERSION >= 0x330
		 + 1
#endif
		 ;
	} else
	{
		gsx_attr(FALSE, MD_XOR, BLACK);
		t.g_y -= 3;
		t.g_h += 6;
	}
	/* set the new clip rect */
	gsx_gclip(&oc);
	gsx_sclip(&t);
	/* redraw the field */
	if (dist)
		ob_draw(tree, obj, 0);
	else
		gsx_cline(t.g_x, t.g_y, t.g_x, t.g_y + t.g_h - 1);
	/* turn on cursor in new position */
	gsx_sclip(&oc);
}


/*
 *	Routine to check to see if given character is in the desired 
 *	range.  The character ranges are
 *	stored as enumerated characters (xyz) or ranges (x..z)
 */
/* 104de: 00fe285c */
/* 106de: 00e248e2 */
/* 100de: 00fe8fa6 */
LINEF_STATIC int16_t instr(P(char) chr, P(const char *) str)
PP(register char chr;)
PP(register char *str;)
{
	register char test1, test2;

	while (*str)
	{
		test1 = test2 = *str++;
		if ((*str == '.') && (*(str + 1) == '.'))
		{
			str += 2;
			test2 = *str++;
		}
		if ((chr >= test1) && (chr <= test2))
			return TRUE;
	}
	return FALSE;
}


/*
 *	Routine to verify that the character matches the validation
 *	string.  If necessary, upshift it.
 */
/* 104de: 00fe289c */
/* 106de: 00e2492a */
/* 100de: 00fe8fe6 */
LINEF_STATIC BOOLEAN check(P(char *) in_char, P(char) valchar)
PP(register char *in_char;)
PP(char valchar;)
{
	register int16_t upcase;
	register int16_t rstr;

	upcase = TRUE;
	rstr = -1;
	switch (valchar)
	{
	case '9':							/* 0..9         */
		rstr = ST9VAL;
		upcase = FALSE;
		break;
	case 'A':							/* A..Z, <space>    */
		rstr = STAVAL;
		break;
	case 'N':							/* 0..9, A..Z, <SPACE>  */
		rstr = STNVAL;
		break;
	case 'P':							/* DOS pathname + '\', '?', '*', ':','.' */
		rstr = STPVAL;
		break;
	case 'p':							/* DOS pathname + '\` + ':' */
		rstr = STLPVAL;
		break;
	case 'F':							/* DOS filename + ':', '?' + '*'    */
		rstr = STFVAL;
		break;
	case 'f':							/* DOS filename */
		rstr = STLFVAL;
		break;
	case 'a':							/* a..z, A..Z, <SPACE>  */
		rstr = STLAVAL;
		upcase = FALSE;
		break;
	case 'n':							/* 0..9, a..z, A..Z,<SP> */
		rstr = STLNVAL;
		upcase = FALSE;
		break;
	case 'x':							/* anything, but upcase */
		*in_char = toupper(*in_char);
		return TRUE;
	case 'X':							/* anything     */
		return TRUE;
	}
	if (rstr != -1)
	{
		if (instr(*in_char, rs_str(rstr)))
		{
			if (upcase)
				*in_char = toupper(*in_char);
			return TRUE;
		}
	}

	return FALSE;
}


/*
 *	Find STart and FiNish of a raw string relative to the template
 *	string.  The start is determined by the InDeX position given.
 */
/* 104de: 00fe2938 */
/* 106de: 00e249dc */
/* 100de: 00fe9082 */
LINEF_STATIC VOID ob_stfn(P(int16_t) idx, P(int16_t *) Pstart, P(int16_t *) pfinish)
PP(int16_t idx;)
PP(int16_t *Pstart;)
PP(int16_t *pfinish;)
{
	*Pstart = find_pos(&D.g_tmpstr[0], idx);
	*pfinish = find_pos(&D.g_tmpstr[0], strlen(&D.g_rawstr[0]));
}


/* 104de: 00fe2978 */
/* 106de: 00e24a2c */
/* 100de: 00fe90ba */
LINEF_STATIC int16_t ob_delit(P(int16_t) idx)
PP(int16_t idx;)
{
	if (D.g_rawstr[idx])
	{
		strcpy(&D.g_rawstr[idx], &D.g_rawstr[idx + 1]);
		return FALSE;
	}
	return TRUE;
}


/*
 * AES #46 - objc_edit - Edit text in an editable text object.
 */
/* 306de: 00e1f8e0 */
/* 104de: 00fe29c4 */
/* 106de: 00e24a84 */
/* 100de: 00fe9108 */
int16_t ob_edit(P(LPTREE) tree, P(int16_t) obj, P(int16_t) in_char, P(int16_t *) idx, P(int16_t) kind)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(int16_t in_char;)
PP(register int16_t *idx;)							/* rel. to raw data */
PP(int16_t kind;)
{
	register int16_t dist;
	register int16_t tmp_back, cur_pos;
	int16_t pos, len, flags;
	int16_t unused;
	GRECT t, c;
	char *pstr;
	int16_t ii, no_redraw, start;
	int16_t finish, nstart, nfinish;
	char bin_char;
	long unused2;
	register THEGLO *DGLO;

	UNUSED(unused);
	UNUSED(unused2);
	UNUSED(c);
	UNUSED(t);
	UNUSED(flags);
	UNUSED(pstr);

	DGLO = &D;

	if ((kind == EDSTART) || (obj <= 0))
		return TRUE;

	/* copy TEDINFO struct to local struct  */
	ob_getsp(tree, obj, &edblk);

	/* copy passed in strs to local strs */
	LSTCPY(&DGLO->g_tmpstr[0], edblk.te_ptmplt);
	LSTCPY(&DGLO->g_rawstr[0], edblk.te_ptext);
	len = ii = LSTCPY(&DGLO->g_valstr[0], edblk.te_pvalid);
	/* expand out valid str */
	while ((ii > 0) && (len < edblk.te_tmplen))
		DGLO->g_valstr[len++] = DGLO->g_valstr[ii - 1];
	DGLO->g_valstr[len] = '\0';
	/* init formatted string */
	ob_format(edblk.te_just, &DGLO->g_rawstr[0], &DGLO->g_tmpstr[0], &DGLO->g_fmtstr[0]);
	switch (kind)
	{
	case EDINIT:
		*idx = strlen(&DGLO->g_rawstr[0]);
		break;
	case EDCHAR:
		/*
		 * at this point, DGLO->g_fmtstr has already been formatted--
		 * it has both template & data. now update DGLO->g_fmtstr
		 * with in_char; return it; strip out junk & update
		 *   ptext string.
		 */
		no_redraw = TRUE;
		/* find cursor & turn it off */
		ob_stfn(*idx, &start, &finish);
		/* turn cursor off  */
		cur_pos = start;
		curfld(tree, obj, cur_pos, 0);

		switch (in_char)
		{
		case BACKSPACE:
			if (*idx > 0)
			{
				*idx -= 1;
				no_redraw = ob_delit(*idx);
			}
			break;
		case ESCAPE:
			*idx = 0;
			DGLO->g_rawstr[0] = '\0';
			no_redraw = FALSE;
			break;
		case DELETE:
			if (*idx <= (edblk.te_txtlen - 2))
				no_redraw = ob_delit(*idx);
			break;
		case LEFT:
			if (*idx > 0)
				*idx -= 1;
			break;
		case RIGHT:
			if (*idx < (int)strlen(&DGLO->g_rawstr[0]))
				*idx += 1;
			break;
		default:
			tmp_back = FALSE;
			if (*idx > (edblk.te_txtlen - 2))
			{
				cur_pos--;
				start = cur_pos;
				tmp_back = TRUE;
				*idx -= 1;
			}
			bin_char = in_char & 0x00ff;

			if (bin_char)
			{
				/* make sure char is in specified set */
				if (check(&bin_char, DGLO->g_valstr[*idx]))
				{
					ins_char(&DGLO->g_rawstr[0], *idx, bin_char, edblk.te_txtlen);
					*idx += 1;
					no_redraw = FALSE;
				} else
				{
					/* see if we can skip ahead */
					if (tmp_back)
					{
						*idx += 1;
						cur_pos++;
					}
					pos = scan_to_end(&DGLO->g_tmpstr[0] + cur_pos, *idx, bin_char);

					if (pos < (edblk.te_txtlen - 2))
					{
#if BINEXACT
						/* SPACE is a key, not a char... */
						bfill(pos - *idx, SPACE, &DGLO->g_rawstr[*idx]);
#else
						bfill(pos - *idx, ' ', &DGLO->g_rawstr[*idx]);
#endif
						DGLO->g_rawstr[pos] = '\0';
						*idx = pos;
						no_redraw = FALSE;
					}
				}
			}
			break;
		}

		LSTCPY(edblk.te_ptext, &DGLO->g_rawstr[0]);

		if (!no_redraw)
		{
			ob_format(edblk.te_just, &DGLO->g_rawstr[0], &DGLO->g_tmpstr[0], &DGLO->g_fmtstr[0]);
			ob_stfn(*idx, &nstart, &nfinish);
			start = min(start, nstart);
			dist = max(finish, nfinish) - start;
			if (dist)
				curfld(tree, obj, start, dist);
		}
		break;
	case EDEND:
		/* break */
		;
	}
	/* draw/erase the cursor */
	cur_pos = find_pos(&DGLO->g_tmpstr[0], *idx);
	curfld(tree, obj, cur_pos, 0);
	return TRUE;
}
