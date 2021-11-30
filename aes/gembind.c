/*	GEMBIND.C		5/30/90 - 5/31/90	Derek Mui	*/
/*	Translate back from assembly code dated 4/26/90			*/
/*	O.K			6/25/90			D.Mui		*/
/*	Release acc wait at appl_exit	7/13/90		D.Mui		*/
/*	Remove appl_init and appl_exit	4/3/91		D.Mui		*/
/*	Add mouse restore	5/8/91			D.Mui		*/
/*	Remove mouse restore	6/14/91			D.Mui		*/
/*	Add ob_sysvar		7/7/92			D.Mui		*/
/*	Change binding for wm_get	7/8/92		D.Mui		*/
/*	Add sub menu functions		7/8/92		D.Mui		*/

#include "aes.h"
#include "gemlib.h"
#include "crysbind.h"
#include "taddr.h"
#include "gemrsc.h"


/* int16_t gl_dspcnt; */ /* unused */

VOIDPTR ad_rso;

extern VOIDPTR maddr; /* hmpf */

uint16_t crysbind PROTO((int16_t opcode, intptr_t pglobal, uint16_t *int_in, int16_t *int_out, VOIDPTR *addr_in));


#define CONTROL LLGET(pcrys_blk)
#define GLOBAL LLGET(pcrys_blk+4)
#define INT_IN LLGET(pcrys_blk+8)
#define INT_OUT LLGET(pcrys_blk+12)
#define ADDR_IN LLGET(pcrys_blk+16)
#define ADDR_OUT LLGET(pcrys_blk+20)


/* 206de: 00e1686c */
/* 306de: 00e1a2d2 */
uint16_t crysbind(P(int16_t) opcode, P(intptr_t) pglobal, P(uint16_t *) int_in, P(int16_t *) int_out, P(VOIDPTR *) addr_in)
PP(int16_t opcode;)
PP(register intptr_t pglobal;)
#if BINEXACT & (AESVERSION < 0x330)
PP(uint16_t *int_in;)
PP(int16_t *int_out;)
PP(VOIDPTR *addr_in;)
#else
PP(register uint16_t *int_in;)
PP(register int16_t *int_out;)
PP(register VOIDPTR *addr_in;)
#endif
{
	intptr_t tmparm;
	intptr_t lbuparm;
	intptr_t lmaddr;
	LPTREE tree;
	register int16_t ret;
	MFORM *mform;
	int16_t i, offset;

	ret = TRUE;

	UNUSED(lmaddr);
	UNUSED(offset);
	UNUSED(i);
	UNUSED(mform);
	
	switch (opcode)
	{
	/* Application Manager  */
	case APPL_INIT:
		LLSET(pglobal, (((long)AESVERSION) << 16) | 1);
		LWSET(pglobal + 4, rlr->p_pid);
		LWSET(pglobal + 20, gl_nplanes);
		LLSET(pglobal + 22, &D);
		LWSET(pglobal + 26, gl_bvdisk);
		LWSET(pglobal + 28, gl_bvhard);
		return rlr->p_pid;
		break;
	case APPL_READ:
		/* BUG: ignores the return value of ap_rdwr() */
		ap_rdwr(AQRD, AP_RWID, AP_LENGTH, AP_PBUFF);
		break;
	case APPL_WRITE:
		/* BUG: ignores the return value of ap_rdwr() */
		ap_rdwr(AQWRT, AP_RWID, AP_LENGTH, AP_PBUFF);
		break;
	case APPL_FIND:
		ret = ap_find(AP_PNAME);
		break;
	case APPL_TPLAY:
		ap_tplay((intptr_t)AP_TBUFFER, AP_TLENGTH, AP_TSCALE);
		break;
	case APPL_TRECORD:
		ret = ap_trecd((intptr_t)AP_TBUFFER, AP_TLENGTH);
		break;
	case APPL_BVSET:
		ret = ap_bvset(AP_BVDISK, AP_BVHARD);
		break;
	case APPL_EXIT:
		ap_exit();
		break;

	/* Event Manager */
	case EVNT_KEYBD:
		ret = ev_keybd();
		break;
	case EVNT_BUTTON:
		ret = ev_button(B_CLICKS, B_MASK, B_STATE, &EV_MX);
		break;
	case EVNT_MOUSE:
		ret = ev_mouse((MOBLK *)&MO_FLAGS, &EV_MX);
		break;
	case EVNT_MESAG:
		ret = ev_mesag(ME_PBUFF);
		break;
	case EVNT_TIMER:
#if BINEXACT
		ret = ev_timer(T_HICOUNT, T_LOCOUNT); /* WTF, ugly hack that works for big-endian only */
#else
		ret = ev_timer(HW(T_HICOUNT) | LW(T_LOCOUNT));
#endif
		break;
	case EVNT_MULTI:
		if (MU_FLAGS & MU_TIMER)
			tmparm = HW(MT_HICOUNT) + LW(MT_LOCOUNT);
#if !BINEXACT
		else
			tmparm = 0; /* BUG: using undefined value */
#endif
		lbuparm = HW(MB_CLICKS) | LW((MB_MASK << 8) | MB_STATE);
		ret = ev_multi(MU_FLAGS, (MOBLK *)&MMO1_FLAGS, (MOBLK *)&MMO2_FLAGS, tmparm, lbuparm, MME_PBUFF, &EV_MX);
		break;
	case EVNT_DCLICK:
		ret = ev_dclick(EV_DCRATE, EV_DCSETIT);
		break;

	/* Menu Manager */
	case MENU_BAR:
		mn_bar((LPTREE)MM_ITREE, SHOW_IT);
		break;
	case MENU_ICHECK:
		do_chg((LPTREE)MM_ITREE, ITEM_NUM, CHECKED, CHECK_IT, FALSE, FALSE);
		break;
	case MENU_IENABLE:
		do_chg((LPTREE)MM_ITREE, (ITEM_NUM & 0x7FFF), DISABLED, !ENABLE_IT, ((ITEM_NUM & 0x8000) != 0x0), FALSE);
		break;
	case MENU_TNORMAL:
		do_chg((LPTREE)MM_ITREE, TITLE_NUM, SELECTED, !NORMAL_IT, TRUE, TRUE);
		break;
	case MENU_TEXT:
/*
 * AES #34 - menu_text - Replaces the text of a menu item.
 */
		tree = (LPTREE)MM_ITREE;
		LSTCPY((VOIDPTR)LLGET(OB_SPEC(ITEM_NUM)), MM_PTEXT);
		break;
	case MENU_REGISTER:
		ret = mn_register(MM_PID, MM_PSTR);
		break;
	
	/* Object Manager   */
	case OBJC_ADD:
		ob_add((LPTREE)OB_TREE, OB_PARENT, OB_CHILD);
		break;
	case OBJC_DELETE:
		ob_delete((LPTREE)OB_TREE, OB_DELOB);
		break;
	case OBJC_DRAW:
		gsx_sclip((GRECT *)&OB_XCLIP);
		ob_draw((LPTREE)OB_TREE, OB_DRAWOB, OB_DEPTH);
		break;
	case OBJC_FIND:
		ret = ob_find((LPTREE)OB_TREE, OB_STARTOB, OB_DEPTH, OB_MX, OB_MY);
		break;
	case OBJC_OFFSET:
		ob_offset((LPTREE)OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF);
		break;
	case OBJC_ORDER:
		ob_order((LPTREE)OB_TREE, OB_OBJ, OB_NEWPOS);
		break;
	case OBJC_EDIT:
		OB_ODX = OB_IDX;
		ret = ob_edit((LPTREE)OB_TREE, OB_OBJ, OB_CHAR, &OB_ODX, OB_KIND);
		break;
	case OBJC_CHANGE:
		gsx_sclip((GRECT *)&OB_XCLIP);
		ob_change((LPTREE)OB_TREE, OB_DRAWOB, OB_NEWSTATE, OB_REDRAW);
		break;

	/* Form Manager */
	case FORM_DO:
		ret = fm_do((LPTREE)FM_FORM, FM_START);
		break;	
	case FORM_DIAL:
		fm_dial(FM_TYPE, (GRECT *)&FM_IX, (GRECT *)&FM_X);
		break;
	case FORM_ALERT:
		ret = fm_alert(FM_DEFBUT, FM_ASTRING);
		break;
	case FORM_ERROR:
		ret = fm_error(FM_ERRNUM);
		break;
	case FORM_CENTER:
		ob_center((LPTREE)FM_FORM, (GRECT *)&FM_XC);
		break;
	case FORM_KEYBD:
		gsx_sclip(&gl_rfull);
		FM_OCHAR = FM_ICHAR;
		FM_ONXTOB = FM_INXTOB;
		ret = fm_keybd((LPTREE)FM_FORM, FM_OBJ, &FM_OCHAR, &FM_ONXTOB);
		break;
	case FORM_BUTTON:
		gsx_sclip(&gl_rfull);
		ret = fm_button((LPTREE)FM_FORM, FM_OBJ, FM_CLKS, &FM_ONXTOB);
		break;
	
	/* Graphics Manager */
	case GRAF_RUBBOX:
		gr_rubbox(GR_I1, GR_I2, GR_I3, GR_I4, &GR_O1, &GR_O2);
		break;
	case GRAF_DRAGBOX:
		gr_dragbox(GR_I1, GR_I2, GR_I3, GR_I4, (GRECT *)&GR_I5, &GR_O1, &GR_O2);
		break;
	case GRAF_MBOX:
		gr_movebox(GR_I1, GR_I2, GR_I3, GR_I4, GR_I5, GR_I6);
		break;
	case GRAF_GROWBOX:
		gr_growbox((GRECT *)&GR_I1, (GRECT *)&GR_I5);
		break;
	case GRAF_SHRINKBOX:
		gr_shrinkbox((GRECT *)&GR_I1, (GRECT *)&GR_I5);
		break;
	case GRAF_WATCHBOX:
		ret = gr_watchbox(GR_TREE, GR_OBJ, GR_INSTATE, GR_OUTSTATE);
		break;
	case GRAF_SLIDEBOX:
		ret = gr_slidebox((LPTREE)GR_TREE, GR_PARENT, GR_OBJ, GR_ISVERT);
		break;
	case GRAF_HANDLE:
/*
 * AES #77 - graf_handle - Obtain the VDI handle of the AES workstation. 
 */
		GR_WCHAR = gl_wchar;
		GR_HCHAR = gl_hchar;
		GR_WBOX = gl_wbox;
		GR_HBOX = gl_hbox;
		ret = gl_handle;
		break;
	case GRAF_MOUSE:
		if (maddr)
		{
			ctlmouse(FALSE);
			maddr = (VOIDPTR)1;
		}
		/* gr_mouse */
		if (GR_MNUMBER > USER_DEF)
		{
			if (GR_MNUMBER == M_OFF)
				gsx_moff();
			else if (GR_MNUMBER == M_ON)
				gsx_mon();
		} else
		{
			VOIDPTR grmaddr;
			
			if (GR_MNUMBER != USER_DEF)			/* set new mouse form   */
			{
				/* BUG: gsx_mfset will crash if this fails because number is out of range... */
				rs_gaddr(ad_sysglo, R_BIPDATA, MICE0 + GR_MNUMBER, &grmaddr);
				grmaddr = (MFORM *)LLGET((intptr_t)grmaddr);
			} else
			{
				grmaddr = (MFORM *)LLGET((intptr_t)GR_MADDR);
			}

			gsx_mfset(grmaddr);
		}
		if (maddr)
			ctlmouse(TRUE);
		break;
	case GRAF_MKSTATE:
		ret = gr_mkstate(&GR_MX, &GR_MY, &GR_MSTATE, &GR_KSTATE);
		/* BUG: the asm version of gr_mkstate returns garbage,
		   and the call should always return TRUE */
		break;
	
	/* Scrap Manager */
	case SCRP_READ:
		sc_read(SC_PATH);
		break;
	case SCRP_WRITE:
		sc_write(SC_PATH);
		break;
	
	/* File Selector Manager */
	case FSEL_INPUT:
		ret = fs_input(FS_IPATH, FS_ISEL, &FS_BUTTON, ad_fsel);
		break;
	case FSEL_EXINPUT:
		ret = fs_input(FS_IPATH, FS_ISEL, &FS_BUTTON, FS_LABEL);
		break;

	/* Window Manager */
	case WIND_CREATE:
		ret = wm_create(WM_KIND, (GRECT *)&WM_WX);
		break;
	case WIND_OPEN:
		wm_open(WM_HANDLE, (GRECT *)&WM_WX);
		break;
	case WIND_CLOSE:
		wm_close(WM_HANDLE);
		break;
	case WIND_DELETE:
		wm_delete(WM_HANDLE);
		break;

	case WIND_GET:
		/* BUG: ignores return value */
		wm_get(WM_HANDLE, WM_WFIELD, &WM_OX);
		break;
	case WIND_SET:
		wm_set(WM_HANDLE, WM_WFIELD, (int16_t *)&WM_IX); /* BUG: ignores return value */
		break;
	case WIND_FIND:
		ret = wm_find(WM_MX, WM_MY);
		break;
	case WIND_UPDATE:
		/* BUG: ignores return value */
		wm_update(WM_BEGUP);
		break;
	case WIND_CALC:
		wm_calc(WM_WCTYPE, WM_WCKIND, WM_WCIX, WM_WCIY, WM_WCIW, WM_WCIH, &WM_WCOX, &WM_WCOY, &WM_WCOW, &WM_WCOH);
		break;
	case WIND_NEW:
		/* BUG: ignores return value */
		wm_new();
		break;

	/* Resource Manager */
	case RSRC_LOAD:
		ret = rs_load(pglobal, RS_PFNAME);
		break;
	case RSRC_FREE:
		ret = rs_free(pglobal);
		break;
	case RSRC_GADDR:
		ret = rs_gaddr(pglobal, RS_TYPE, RS_INDEX, &ad_rso);
		break;
	case RSRC_SADDR:
		ret = rs_saddr(pglobal, RS_TYPE, RS_INDEX, RS_INADDR);
		break;
	case RSRC_OBFIX:
		ret = rs_obfix((LPTREE)RS_TREE, RS_OBJ);
		break;
	
	/* Shell Manager */
	case SHEL_READ:
		ret = sh_read(SH_PCMD, SH_PTAIL);
		break;
	case SHEL_WRITE:
		ret = sh_write(SH_DOEX, SH_ISGR, SH_ISCR, SH_PCMD, SH_PTAIL);
		break;
	case SHEL_GET:
		ret = sh_get(SH_PBUFFER, SH_LEN);
		break;
	case SHEL_PUT:
		ret = sh_put(SH_PDATA, SH_LEN);
		break;
	case SHEL_FIND:
		ret = sh_find(SH_PATH, NULL);
		break;
	case SHEL_ENVRN:
		ret = sh_envrn(SH_PATH, SH_SRCH);
		break;

	default:
		fm_show(ALRTNOFUNC, NULL, 1); /* why not use no_aes here? */
		ret = -1;
		break;
	}
	return ret;
}


/*
 *	Routine that copies input parameters into local buffers,
 *	calls the appropriate routine via a case statement, copies
 *	return parameters from local buffers, and returns to the
 *	routine.
 */

VOID xif(P(intptr_t) pcrys_blk)
PP(intptr_t pcrys_blk;)
{
	uint16_t control[C_SIZE];
	uint16_t int_in[I_SIZE];
	int16_t int_out[O_SIZE];
	VOIDPTR addr_in[AI_SIZE];

	LWCOPY(ADDR(control), (VOIDPTR)CONTROL, C_SIZE);

	if (IN_LEN)
		LWCOPY(ADDR(int_in), (VOIDPTR)INT_IN, IN_LEN);

	if (AIN_LEN)
		LWCOPY(ADDR(addr_in), (VOIDPTR)ADDR_IN, AIN_LEN * (sizeof(VOIDPTR) / 2));

	int_out[0] = crysbind(OP_CODE, GLOBAL, int_in, int_out, addr_in);
	
	/*
	 * long standing BUG: nobody sets OUT_LEN here, so this depends
	 * on the language binding used.
	 * It should be AES however which tells how many output parameters were supplied,
	 * just like VDI does.
	 */
	if (OUT_LEN)
		LWCOPY((VOIDPTR)INT_OUT, int_out, OUT_LEN);

	/*
	 * rsrc_gaddr() is the only function that returns an address parameter
	 */
	if (OP_CODE == RSRC_GADDR)
		LLSET(ADDR_OUT, ad_rso);
}
