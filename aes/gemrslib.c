/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:26:37 $
 * =======================================================================
 *
 * Revision 2.3  89/04/26  18:26:37  mui
 * TT
 * 
 * Revision 2.2  89/04/01  03:12:36  kbad
 * Change to rs_readit to allow sh_find to look for files in the directory
 * from which a program was launched.  rs_readit now uses a local buffer
 * to store the filename instead of ad_shcmd, therefore ad_shcmd is intact
 * ; contains the full pathname of the last shel_written program; and can
 * be used by shel_find.
 * 
 * Revision 2.1  89/02/22  05:29:18  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:03  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*  	GEMRSLIB.C	5/14/84 - 04/09/85	Lowell Webster		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	Fix the get_addr for imagedata	4/16/86	Derek Mui		*/
/*	Unfix the get_addr		10/24/86	Derek Mui	*/
/*	Replace LSTRLEN as strlen	3/15/88		D.Mui		*/
/*	Fix rs_load to include new resource type	7/10/92	D.Mui	*/
/*	Fix rs_readit, if extended format is invalid, ignore it		*/
/*	Fix at dos_lseek and if not extended format make sure the word 	*/
/*	is zero				7/13/92		D.Mui		*/
/*	Check the RT_VRSN make sure it is greater or equal to RS_SIZE	*/

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


#define X_READ	0x3F

#define NUM_OBS LWGET((intptr_t)rs_hdr + 2*RT_NOBS)
#define NUM_TREE LWGET((intptr_t)rs_hdr + 2*RT_NTREE)
#define NUM_TI LWGET((intptr_t)rs_hdr + 2*RT_NTED)
#define NUM_IB LWGET((intptr_t)rs_hdr + 2*RT_NICON)
#define NUM_BB LWGET((intptr_t)rs_hdr + 2*RT_NBITBLK)
#define NUM_FRSTR LWGET((intptr_t)rs_hdr + 2*RT_NSTRING)
#define NUM_FRIMG LWGET((intptr_t)rs_hdr + 2*RT_IMAGES)

#define ROB_TYPE ((intptr_t)psubstruct + 6)		/* Long pointer in OBJECT   */
#define ROB_SPEC (psubstruct + 12)		/* Long pointer in OBJECT   */

#define RTE_PTEXT ((intptr_t)psubstruct + 0)		/* Long pointers in TEDINFO */
#define RTE_PTMPLT ((intptr_t)psubstruct + 4)
#define RTE_PVALID ((intptr_t)psubstruct + 8)
#define RTE_TXTLEN ((intptr_t)psubstruct + 24)
#define RTE_TMPLEN ((intptr_t)psubstruct + 26)

#define RIB_PMASK ((intptr_t)psubstruct + 0)		/* Long pointers in ICONBLK */
#define RIB_PDATA ((intptr_t)psubstruct + 4)
#define RIB_PTEXT ((intptr_t)psubstruct + 8)

#define RBI_PDATA ((intptr_t)psubstruct + 0)		/* Long pointer in BITBLK   */
#define RBI_WB ((intptr_t)psubstruct + 4)
#define RBI_HL ((intptr_t)psubstruct + 6)

/* in global array      */
#define APP_LOPNAME ((intptr_t)rs_global + 10)
#define APP_LO1RESV ((intptr_t)rs_global + 14)
#define APP_LO2RESV ((intptr_t)rs_global + 18)

RSHDR *rs_hdr;
intptr_t rs_global;
uint16_t hdr_buff[HDR_LENGTH / 2];


LINEF_STATIC int16_t fix_ptr PROTO((int16_t type, int16_t index));
LINEF_STATIC int16_t fix_long PROTO((intptr_t plong));




/*
 *	Fix up a character position, from offset,row/col to a pixel value.
 *	If column or width is 80 then convert to rightmost column or 
 *	full screen width. 
 */
/* 306de: 00e20412 */
/* 104de: 00fe3960 */
/* 106de: 00e25be0 */
LINEF_STATIC VOID fix_chpos(P(intptr_t) pfix, P(int16_t) ifx)
PP(intptr_t pfix;)
PP(int16_t ifx;)
{
	register int16_t cpos, coffset;

	cpos = LWGET(pfix);
	coffset = (cpos >> 8) & 0x00ff;
	cpos &= 0x00ff;
	if (ifx && cpos == 80)
		cpos = gl_width;
	else
		cpos *= (ifx) ? gl_wchar : gl_hchar;
	cpos += (coffset > 128) ? (coffset - 256) : coffset;
	LWSET(pfix, cpos);
}


/************************************************************************
 * AES #114 - rsrc_obfix - Resource object fix
 *
 * rs_obfix
 ************************************************************************/
/* 306de: 00e2047c */
/* 104de: 00fe39c2 */
/* 106de: 00e25c4a */
int16_t rs_obfix(P(LPTREE) tree, P(int16_t) curob)
PP(LPTREE tree;)
PP(int16_t curob;)
{
	register int16_t i, val;
	register intptr_t p;

	/* set X,Y,W,H with fixch, use val to alternate TRUEs and FALSEs */
	p = OB_X(curob);

	val = TRUE;
	for (i = 0; i < 4; i++)
	{
		fix_chpos(p + (intptr_t) (2 * i), val);
		val = !val;
	}
#ifndef __ALCYON__
	/* BUG: missing return */
	return TRUE;
#endif
}


/* 306de: 00e204d0 */
/* 104de: 00fe3a0c */
/* 106de: 00e25c9e */
char *rs_str(P(int16_t) stnum)
PP(int16_t stnum;)
{
	VOIDPTR ad_string;

	rs_gaddr(ad_sysglo, R_STRING, stnum, &ad_string);
	LSTCPY(D.g_loc1, ad_string);
	return D.g_loc1;
}


/* 306de: 00e2050a */
/* 104de: 00fe3a3e */
/* 106de: 00e25cd8 */
LINEF_STATIC intptr_t get_sub(P(int16_t) rsindex, P(int16_t) rtype, P(int16_t) rsize)
PP(int16_t rsindex;)
PP(int16_t rtype;)
PP(int16_t rsize;)
{
	uint16_t offset;

	offset = LWGET((intptr_t)rs_hdr + LW(rtype * 2));
	/* get base of objects and then index in  */
	return (intptr_t)rs_hdr + LW(offset) + LW(rsize * rsindex);
}


/*
 *	return address of given type and index, INTERNAL ROUTINE
 */
/* 306de: 00e20538 */
/* 104de: 00fe3a6a */
LINEF_STATIC intptr_t get_addr(P(uint16_t) rstype, P(uint16_t) rsindex)
PP(register uint16_t rstype;)
PP(register uint16_t rsindex;)
{
	register intptr_t psubstruct;
	register int16_t size;
	register int16_t rt;
	int16_t valid;
	uint16_t junk;

	UNUSED(junk);
	
	valid = TRUE;
	switch (rstype)
	{
	case R_TREE:
#ifdef __ALCYON__
		junk = LW(rsindex * 4);
		return (LLGET(LLGET(APP_LOPNAME) + junk));
#else
		return (LLGET(LLGET(APP_LOPNAME) + LW(rsindex * 4)));
#endif
	case R_OBJECT:
		rt = RT_OB;
		size = sizeof(OBJECT);
		break;
	case R_TEDINFO:
	case R_TEPTEXT:
		rt = RT_TEDINFO;
		size = sizeof(TEDINFO);
		break;
	case R_ICONBLK:
	case R_IBPMASK:
		rt = RT_ICONBLK;
		size = sizeof(ICONBLK);
		break;
	case R_BITBLK:
	case R_BIPDATA:
		rt = RT_BITBLK;
		size = sizeof(BITBLK);
		break;
	case R_OBSPEC:
		psubstruct = get_addr(R_OBJECT, rsindex);
		return (ROB_SPEC);
	case R_TEPTMPLT:
	case R_TEPVALID:
		psubstruct = get_addr(R_TEDINFO, rsindex);
		if (rstype == R_TEPTMPLT)
			return RTE_PTMPLT;
		else
			return RTE_PVALID;
	case R_IBPDATA:
	case R_IBPTEXT:
		psubstruct = get_addr(R_ICONBLK, rsindex);
		if (rstype == R_IBPDATA)
			return RIB_PDATA;
		else
			return RIB_PTEXT;
	case R_STRING:
		return (LLGET(get_sub(rsindex, RT_FREESTR, sizeof(int32_t))));
	case R_IMAGEDATA:
		return (LLGET(get_sub(rsindex, RT_FREEIMG, sizeof(int32_t))));
	case R_FRSTR:
		rt = RT_FREESTR;
		size = sizeof(intptr_t);
		break;
	case R_FRIMG:
		rt = RT_FREEIMG;
		size = sizeof(intptr_t);
		break;
	default:
		valid = FALSE;
		break;
	}
	if (valid)
		return (get_sub(rsindex, rt, size));
	else
		return (-1L);
}


/* 306de: 00e2066e */
/* 104de: 00fe3b8e */
/* 106de: 00e25e3c */
LINEF_STATIC VOID fix_trindex(NOTHING)
{
	register int16_t ii;
	register int32_t ptreebase;

	ptreebase = get_sub(R_TREE, RT_TRINDEX, sizeof(int32_t));
	LLSET(APP_LOPNAME, ptreebase);

	for (ii = NUM_TREE - 1; ii >= 0; ii--)
		fix_long(ptreebase + LW(ii * 4));
}


/*
 * Fix up the objects including color icons
 */
/* 306de: 00e206cc */
/* 104de: 00fe3be0 */
/* 106de: 00e25e9a */
LINEF_STATIC VOID fix_objects(NOTHING)
{
	register int16_t ii;
	register int16_t obtype;
	register intptr_t psubstruct;
	
	for (ii = NUM_OBS - 1; ii >= 0; ii--)
	{
		psubstruct = get_addr(R_OBJECT, ii);
		rs_obfix(psubstruct, 0);
		obtype = (LWGET(ROB_TYPE) & 0x00ff);

		if (obtype != G_BOX && obtype != G_IBOX && obtype != G_BOXCHAR
			)
			fix_long(ROB_SPEC);
	}
}


/* 306de: 00e20736 */
/* 104de: 00fe3c3c */
/* 106de: 00e25f04 */
LINEF_STATIC VOID fix_tedinfo(NOTHING)
{
	register int16_t ii, i;
	register int32_t psubstruct;
	int32_t tl[2], ls[2];

	for (ii = NUM_TI - 1; ii >= 0; ii--)
	{
		psubstruct = get_addr(R_TEDINFO, ii);
		tl[0] = tl[1] = 0x0L;
		if (fix_ptr(R_TEPTEXT, ii))
		{
			tl[0] = RTE_TXTLEN;
			ls[0] = RTE_PTEXT;
		}
		if (fix_ptr(R_TEPTMPLT, ii))
		{
			tl[1] = RTE_TMPLEN;
			ls[1] = RTE_PTMPLT;
		}
		for (i = 0; i < 2; i++)
		{
			if (tl[i])
				LWSET(tl[i], strlen((const char *)LLGET(ls[i])) + 1);
		}
		fix_ptr(R_TEPVALID, ii);
	}
}


/* 306de: 00e20804 */
/* 104de: 00fe3cf8 */
/* 106de: 00e25fd2 */
LINEF_STATIC VOID fix_nptrs(P(int16_t) cnt, P(int16_t) type)
PP(int16_t cnt;)
PP(int16_t type;)
{
	register int16_t i;

	for (i = cnt; i >= 0; i--)
		fix_long(get_addr(type, i));
}


/* 306de: 00e20832 */
/* 104de: 00fe3d1c */
/* 106de: 00e26000 */
int16_t fix_ptr(P(int16_t) type, P(int16_t) index)
PP(int16_t type;)
PP(int16_t index;)
{
	return fix_long(get_addr(type, index));
}


/* 306de: 00e20848 */
/* 104de: 00fe3d2e */
/* 106de: 00e26016 */
LINEF_STATIC int16_t fix_long(P(intptr_t) plong)
PP(register intptr_t plong;)
{
	register intptr_t lngval;

	lngval = LLGET(plong);
	if (lngval != -1L)
	{
		LLSET(plong, (intptr_t)rs_hdr + lngval);
		return TRUE;
	} else
		return FALSE;
}


/*
 *	Set global addresses that are used by the resource library sub-
 *	routines
 */
VOID rs_sglobe(P(intptr_t) pglobal)
PP(intptr_t pglobal;)
{
	rs_global = pglobal;
	rs_hdr = (RSHDR *)LLGET(APP_LO1RESV);
}


/*
 * AES #111 - rsrc_free - Resource free
 *
 *	Free the memory associated with a particular resource load.
 */
/* 306de: 00e208a0 */
/* 104de: 00fe3d7c */
/* 106de: 00e2606e */
int16_t rs_free(P(intptr_t) pglobal)
PP(intptr_t pglobal;)
{
	rs_global = pglobal;
	dos_free((VOIDPTR)LLGET(APP_LO1RESV));

	return !DOS_ERR;
}


/*
 * AES #112 - rsrc_gaddr - Resource get address
 *
 *	Get a particular ADDRess out of a resource file that has been
 *	loaded into memory.
 */
/* 306de: 00e208d4 */
/* 104de: 00fe3daa */
/* 106de: 00e260a2 */
int16_t rs_gaddr(P(intptr_t) pglobal, P(uint16_t) rtype, P(uint16_t) rindex, P(VOIDPTR *) rsaddr)
PP(intptr_t pglobal;)
PP(uint16_t rtype;)
PP(uint16_t rindex;)
PP(register VOIDPTR *rsaddr;)
{
	rs_sglobe(pglobal);

	*rsaddr = (VOIDPTR *)get_addr(rtype, rindex);
	return *rsaddr != (VOIDPTR *)-1L;
}


/*
 * AES #113 - rsrc_saddr - Resource store address
 *
 *	Set a particular ADDRess in a resource file that has been
 *	loaded into memory.
 */
/* 306de: 00e2090a */
/* 104de: 00fe3dd6 */
/* 106de: 00e260d8 */
int16_t rs_saddr(P(intptr_t) pglobal, P(uint16_t) rtype, P(uint16_t) rindex, P(VOIDPTR ) rsaddr)
PP(intptr_t pglobal;)
PP(uint16_t rtype;)
PP(uint16_t rindex;)
PP(VOIDPTR rsaddr;)
{
	register intptr_t psubstruct;

	rs_sglobe(pglobal);

	psubstruct = get_addr(rtype, rindex);
	if (psubstruct != -1L)
	{
		LLSET(psubstruct, rsaddr);
		return (TRUE);
	} else
		return (FALSE);
}


/*
 *	Read resource file into memory and fix everything up except the
 *	x,y,w,h, parts which depend upon a GSX open workstation.  In the
 *	case of the GEM resource file this workstation will not have
 *	been loaded into memory yet.
 */
/* 306de: 00e20946 */
/* 104de: 00fe3e06 */
/* 106de: 00e26114 */
LINEF_STATIC int16_t rs_readit(P(intptr_t) pglobal, P(const char *) rsfname)
PP(intptr_t pglobal;)
PP(const char *rsfname;)
{
	register uint16_t rslsize;
	register uint16_t fd, ret;
	char rspath[128];

	/* make sure its there  */
	LSTCPY(rspath, rsfname);
	if (!sh_find(rspath, NULL))
		return (FALSE);
	/* init global      */
	rs_global = pglobal;
	/* open then file and read the header    */
	fd = dos_open(rspath, RMODE_RD);
	if (!DOS_ERR)
		dos_read(fd, HDR_LENGTH, ADDR(&hdr_buff[0]));

	/* read in resource and interpret it   */
	if (!DOS_ERR)
	{
		/* get size of resource */

		rslsize = hdr_buff[RS_SIZE];

		/* allocate memory  */
		rs_hdr = (RSHDR *)dos_alloc((int32_t) rslsize);

		if (!DOS_ERR)
		{
			/* read it all in */
			dos_lseek(fd, SMODE, 0x0L);
			dos_read(fd, (size_t)rslsize, rs_hdr);
			if (!DOS_ERR)
				do_rsfix((intptr_t) rs_hdr, (uint16_t) rslsize);	/* do all the fixups    */
		}
	}

	ret = !DOS_ERR;
	dos_close(fd);
	return (ret);
}


/*
 * do all the fixups. rs_hdr must be initialized
 */
/* 306de: 00e20a2a */
/* 104de: 00fe3ec2 */
/* 106de: 00e261f8 */
VOID do_rsfix(P(intptr_t) hdr, P(int16_t) size)
PP(intptr_t hdr;)
PP(int16_t size;)
{
	register int16_t ibcnt;

	LLSET(APP_LO1RESV, hdr);
	LWSET(APP_LO2RESV, size);
	/* xfer RT_TRINDEX to global and turn all offsets from base of file into pointers */

	fix_trindex();
	fix_tedinfo();
	ibcnt = NUM_IB - 1;
	fix_nptrs(ibcnt, R_IBPMASK);
	fix_nptrs(ibcnt, R_IBPDATA);
	fix_nptrs(ibcnt, R_IBPTEXT);
	fix_nptrs(NUM_BB - 1, R_BIPDATA);
	fix_nptrs(NUM_FRSTR - 1, R_FRSTR);
	fix_nptrs(NUM_FRIMG - 1, R_FRIMG);
}


/*
 *	Fix up objects separately so that we can read GEM resource before we
 *	do an open workstation, then once we know the character sizes we
 *	can fix up the objects accordingly.
 */

VOID rs_fixit(P(intptr_t) pglobal)
PP(intptr_t pglobal;)
{
	rs_sglobe(pglobal);
	fix_objects();
}


/*
 * AES #110 - rsrc_load - Resource load
 *	RS_LOAD		mega resource load
 */
/* 306de: 00e20b00 */
/* 104de: 00fe3f7a */
/* 106de: 00e262ce */
int16_t rs_load(P(intptr_t) pglobal, P(const char *) rsfname)
PP(register intptr_t pglobal;)
PP(const char *rsfname;)
{
	register int16_t ret;

	ret = rs_readit(pglobal, rsfname);
	if (ret)
		rs_fixit(pglobal);
	return ret;
}
