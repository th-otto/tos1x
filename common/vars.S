/*
 * common variables
 *
 * This file is used when linking a single module,
 * to get the same addresses as when linking the whole ROM.
 *
 * It is now also used when linking the final ROM, when
 * you want to create an exact binary image of an official
 * ROM version. This is because, due to the way the linker works,
 * it is impossible to get the same order of symbols in the bss section.
 *
 * This file is for version 1.x only.
 */

#include "config.h"
#include "../bdos/bdosdefs.h"
#include "../bios/biosdefs.h"
#include "../aes/aesdefs.h"
#include "../vdi/vdidefs.h"
#include "../vdi/lineaequ.inc"
#include "../desk/deskdefs.h"

#define V(name,t,size) \
	xdef name \
name: ds.t size
#define S(t,size) ds.t size

#define BYTE(name) V(name,b,1)
#define INT(name) V(name,w,1)
#define LONG(name) V(name,l,1)
#define PTR(name) V(name,l,1)

#define GRECT(name) V(name,w,4)
#define TEDINFO(name) V(name,b,28)
#define MFDB(name) V(name,b,20)


	bss

	ds.b 2048       /* the system variables go here */

	ds.b 64         /* some variables stored here for rainbow effect */

	V(gem_env,b,12)

/* save area for trap13/14. */
	V(save_beg,b,238)
	V(_trap_save_area,b,0)         /* End of Save storage */

#if TOSVERSION >= 0x104
	V(oshdr,b,6+64)
#endif

#if TOSVERSION >= 0x106
	V(cookies,l,NCOOKIES*2)
#endif

	xdef __sbss
__sbss:	ds.b 0 /* end of "base" BSS; start of the BSS area that is zeroed by BIOS */

	PTR(savepc)
	PTR(execpath)
	PTR(execname)
	V(execdta,b,44)
	V(execfname,b,32)

	V(_pbdef,b,30)

	INT(fd_retry)
	V(_fd_wp,b,NUMFLOPPIES)
	V(_fd_latch,b,NUMFLOPPIES)
	V(_fd_lastacc,l,NUMFLOPPIES)
	INT(fd_motoron)
	INT(fd_desel)
	INT(fd_dev)
	INT(fd_track)
	INT(fd_sect)
	INT(fd_side)
	INT(fd_scount)
	PTR(fd_buffer)
	PTR(fd_dmaend)
	INT(fd_spt)
	INT(fd_interlv)
	INT(fd_virgin)

	LONG(lastacstm)

	INT(fd_deferr)
	INT(fd_curerr)

	V(flopsregs,l,9)

	V(dsb,b,4*NUMFLOPPIES)
	
#if MSTECLK
	V(rtcbufa,b,13)
	V(rtcbufb,b,13)
#endif

#if TOSVERSION >= 0x104
	INT(baudrate)
#endif
	V(rs232ibuf,b,SERIAL_BUFSIZE)
	V(rs232obuf,b,SERIAL_BUFSIZE)
	V(ikbdbuf,b,SERIAL_BUFSIZE)
	V(midibuf,b,128)

	V(rs232iorec,b,2*14+6)

	V(ikbdiorec,b,14)

	V(midiiorec,b,14)

	V(_kbdvecs,b,38)

	V(kbdbuf,b,7)
	V(mousebuf,b,5)
	V(relmbuf,b,3)
	V(clockbuf,b,6)
	V(joybuf,b,3)
    even

	LONG(iclkrtime)

	LONG(iclkwtime)
	
	V(iclkbuf,b,6)      /* buffer for writing time packet to IKBD */

	V(buttonbuf,b,3)
	
	BYTE(_shifty)

	V(_curkeytbl,l,3)

	V(initmbuf,b,17)

	BYTE(kb_key_last)
	BYTE(kb_ticks)
	BYTE(kb_delay)

	BYTE(kb_initial)
	BYTE(kb_repeat)

	LONG(lst_timeout)

	INT(_tim_c_sieve)

	PTR(_sndtable)

	BYTE(_snddelay)

	BYTE(_sndtmp)

	INT(_prtconfig)

	INT(iclk_ready)
	ds.b 2

	PTR(biosav)
	ds.b 4
	INT(savesr)

	V(fstack,w,1034+2)

	PTR(old_tik)
	PTR(old_2)

/*
 * disk_buffer plus pad for equated arrays
 * BEWARE: portions also used by VDI (the "overlay area")
 */
#include "../vdi/vdivar.S"

	LONG(_fd_mediach)
	LONG(_rseed)

	BYTE(_prtbdev)
	even
	V(_pbpar,b,30)
	V(_osmem,w,LENOSM)

	BYTE(_prtboch)
	even

	INT(_osmptr)

	INT(_prtbbval)

	V(_glbcolumn,w,3)

	INT(_oscnt)
	INT(_msec)
	V(_ram8x8,b,90)

	BYTE(_prtbflg)
	even
	
	ds.b 1024 /* unused */

	V(_supstk,w,SUPSIZ)
	V(_drivechange,b,NUMFLOPPIES)

	BYTE(_prtbdmask)
	even
	
	INT(_prtbwidth)

	V(_bakbuf,l,3)
	V(_fill,b,3)
	even

	V(_blkdev,b,32*NUMFLOPPIES)
	INT(_time)

	INT(_prtbbytes)
	LONG(_rwerr)

	BYTE(_prtbilow)
	even

	BYTE(_prtbihigh)
	even

	V(_prtboval,w,4)

	V(_secbuf,b,4*SECTOR_SIZE)

	INT(_curflop)

	INT(_prtbrval)
	INT(_prtbwords)
	V(_prtbval,w,16)
	PTR(_prtbstrt)
	V(_dirtbl,l,NCURDIR)

	V(_pmd,l,3)
	INT(_prtbplanes)
	V(_root,l,MAXQUICK)

	ds.b 60 /* unused? */

	INT(_prtbtcol)
	INT(_prtboffset)

	PTR(_prtbp2)
	V(_errbuf,l,3)
	BYTE(_prtbacol)
	even
	V(_prtbmaxval,w,16)
	BYTE(_prtbeps)
	even
	INT(_prtbchunk)
	V(_prtbobuf,b,8)

	V(_virt_work,b,180+MU_PLANES*16*2)

	V(_fd_err,w,NUMFLOPPIES)
	V(_diruse,b,NCURDIR)
	PTR(_prtbp1)
	V(_sft,b,OPNFILES*10-6*10)
	V(_drvtbl,l,BLKDEVNUM)
	V(_glbkbchar,l,3*KBBUFSZ)

	INT(_osmlen)
	INT(_prtbheight)

	INT(_drvsel)

	BYTE(_prtbmed)
	even
	BYTE(_prtbmono)
	even
	INT(_prtbgval)
	PTR(_prtbend)
	V(_prtbmval,w,4)
	BYTE(_prtbempty)
	even
	INT(_prtblines)
	LONG(_uptime)
	BYTE(_prtbprez)
	even
	BYTE(_prtbodd)
	even
	V(_prtbminval,w,16)
	INT(_prtbdots)
	INT(_prtbpmsk)
	INT(_prtbomask)
	INT(_prtbbits)
	INT(_errdrv)

	PTR(_run)

	INT(_prtbidx)
	V(_ram8x16,b,90)
	INT(_prtbinvert)

	V(_buptr,l,3)
	BYTE(_prtblow)
	even
	BYTE(_prtbamon)
	even
	INT(_date)
	BYTE(_prtbbol)
	even
	INT(_prtbink)
	V(_bcbx,b,4*20) /* 4*sizeof(BCB) */
	V(_beptr,l,3)

/* This label is referenced by the OSHEADER */
	xdef _endvdibss
_endvdibss: ds.b 0

/* start AES+DESKTOP */

	PTR(retsava)
	PTR(_xxaddr)
	INT(_gl_restype)
	INT(_gl_rschange)
	INT(_gl_nextrez)
	V(ustak,l,33)
	INT(_diskin)
	V(srsave,w,1)
	V(savsr,w,1)
	V(psetsr,w,1)
	V(dspstk,l,161)
	LONG(_crit_err)
	LONG(_SAV2TRP)
	LONG(_savsup)
	PTR(_drawaddr)
	PTR(drawsp)
	PTR(_drawstk)
	LONG(_aesldivr)
	LONG(errsave)
	ds.b 1024
	V(errstk,l,257)
	ds.b 2
	PTR(_ad_rso)
	INT(_ml_ocnt)
	PTR(_ml_mnhold)
	GRECT(_ml_ctrl)
	PTR(_ml_pmown)
	PTR(_ml_pkown)
	V(pblock,l,5)
	PTR(_drwaddr)
	PTR(_tikaddr)
	PTR(gstksave)
	PTR(tstksave)
	PTR(_tiksav)
	LONG(_NUM_TICK)
	LONG(_CMP_TICK)
	V(gstack,l,24)
	V(tstack,l,24)
#if OLD_SFCODE | (OS_COUNTRY != CTRY_FR)
	INT(_sf_key)
	INT(_sf_col)
	INT(_sf_line)
	PTR(xbiosaret)
	PTR(biosaret)
#else
	INT(_sf_key)
	ds.w 1 /* unused */
	INT(_sf_line)
	ds.l 1 /* unused */
#endif
	PTR(trp13aret)
	PTR(trp14aret)
	INT(_gl_xclip)
	INT(_gl_wclip)
	V(_intin,w,128)
	V(_pglobal,w,15)
	V(_gl_ctwait,w,5) /* MOBLK */
	V(_gl_mkrect,b,12)  /* ORECT */
	PTR(_gl_rbuf)
	INT(_sh_dodef)
	INT(_sh_isgem)
	PTR(_gl_awind)
	PTR(_cart_dta)
	PTR(_fc_ted)
	INT(_gl_hbox)
	INT(_gl_yclip)
	V(_intout,w,10)
	INT(_gl_tcolor)
	GRECT(_gl_rmenu)
	PTR(_sys_adacc)
	INT(_gl_rlen)
	PTR(_ad_fstree)
	INT(_pr_mclick)
	LONG(_gl_mnpid) /* BUG: should be int */
	V(_W_TREE,b,24*NUM_WIN)  /* OBJECT[NUM_WIN] */
	INT(_gl_wschar)
	LONG(_elinkoff)
	PTR(_cda)
	PTR(_rs_global)
	PTR(_ad_sysglo)
	INT(_gl_width)
	INT(_gl_font)
	V(_infpath,b,122)
	PTR(_gl_cowner)
	INT(_sh_doexec)
#if !OLD_SFCODE
	INT(_sf_eof)
#endif
	INT(_gl_patt)
	GRECT(_gl_rscreen)
	GRECT(_gl_rfull)
	V(_appl_msg,w,8)
	V(_ptsin,w,20)
	INT(_DOS_ERR)
	V(_W_ACTIVE,b,24*MAXOBJ)  /* OBJECT[MAXOBJ] */
	INT(_gl_newroot)
	PTR(_cart_ptr)
	V(_ptsout,w,10)
	INT(_gl_btrue)
	INT(_gl_hptschar)
	INT(_gl_hsptschar)
	INT(_gl_wbox)
	PTR(_gl_kowner)
	INT(_INTER_WSPACE)
	V(_wind_msg,w,8)
	INT(_gl_fis)
	V(_wind_spb,b,10)    /* sizeof(SPB) */
	INT(_mclick)
	PTR(_gl_mowner)
	V(_gl_tmp1,b,40)
	PTR(_gl_mntree)
	INT(_sh_gem)
	PTR(_gl_wtree)
	GRECT(_gl_rzero)
	INT(_infdrv)
	PTR(_ctl_pd)
	GRECT(_ctrl)
	V(_gl_tmp2,b,40)
	V(_gl_dta,b,50)      /* DTA; actually 6 bytes too large */
	INT(_gl_nrows)
	INT(_ajunk)
	INT(_sf_inptr)
	MFDB(_gl_src)
	INT(_INTER_HSPACE)
	INT(_gl_dabase)
	INT(_havedesk)
	V(_gl_adacc,l,MAX_ACCS)
	INT(_gl_wtop)
	MFDB(_gl_dst)
	INT(_fph)
	GRECT(_gl_rfs)
#if !OLD_SFCODE
	INT(_sf_bufsize)
#endif
	INT(_gl_wptschar)
	INT(_gl_wsptschar)
	INT(_xrat)
	INT(_yrat)
	INT(_pr_button)
	INT(_pr_xrat)
	INT(_havefmt)
	PTR(_drl)
	PTR(_dlr)
	INT(_pr_yrat)
	TEDINFO(_edblk)
	PTR(_rs_hdr)
	INT(_havegem)
	BYTE(_xforkq)
	even
	MFDB(_gl_tmp)
	V(_D,b,10774) /* sizeof(THEGLO) */
	ds.l 1 /* unused */
	INT(_gl_hchar)
	INT(_f_maxlevel)
	PTR(_eul)
	BYTE(_indisp)
	even
	INT(_curpid)
	INT(_gl_naccs)
	INT(_gl_dacnt)
	INT(_gl_dabox)
	V(_desk_global,w,15)
	PTR(_thedesk)
	PTR(_ad_hgmice)
	BYTE(_infork)
	even
	INT(_fpt)
	V(_gl_pacc,l,MAX_ACCS)
	INT(_gl_bdelay)
	INT(_gl_fakemsg)
	V(_desk_acc,l,MAX_ACCS)
	PTR(_fc_cmd)
	V(_fmt_global,w,15)
	V(_gem_global,w,15)
	PTR(_nrl)
	INT(_kstate)
	INT(_gl_bclick)
	PTR(_ad_fsnames)
	V(_bi,b,14)      /* BITBLK */
	V(_ib,b,34)      /* ICONBLK */
	PTR(_ad_armice)
	INT(_gl_handle)
	INT(_gl_dclick)
	V(_romdata,b,6*6)
	INT(_gl_height)
	INT(_gl_apid)
	PTR(_rlr)
	INT(_gl_bdesired)
	INT(_gl_recd)
	INT(_gl_dcindex)
	PTR(_ad_shcmd)
	PTR(_ad_pfile)
	TEDINFO(_gl_aname)
	TEDINFO(_gl_ainfo)
	INT(_gl_hclip)
	V(_contrl,w,12)
	INT(_ADD_HEIGHT)
	PTR(_g_fslist)
	PTR(_old_bcode)
	PTR(_ad_path)
	V(_evx,b,28) /* sizeof(EVB) */
	PTR(_ad_stdesk)
	PTR(_rul)
	INT(_gl_bvhard)
	PTR(_ad_shtail)
	PTR(_g_buffer)
	INT(_gl_wchar)
	INT(_f_level)
	INT(_mtrans)
	PTR(_ad_fsdta)
	INT(_sh_special)
	PTR(_ad_windspb)
	INT(_gl_hschar)
	PTR(_ad_intin)
	INT(_gl_mode)
	PTR(_zlr)
	INT(_gl_bpend)
	INT(_gl_bvdisk)
	ds.w 4 /* unused */
	PTR(_g_wlist)
	GRECT(_gl_rcenter)
	INT(_gl_moff)
	V(_hdr_buff,w,18)   /* RSHDR */
	V(_gl_ws,w,57)   /* workout */
	INT(_gl_lcolor)
	INT(_fpcnt)
	INT(_button)
	INT(_gl_graphic)
	INT(_fc_x)
	INT(_fc_y)
	INT(_gl_ncols)
	INT(_gl_nplanes)
	INT(_gl_mask)
	INT(_DOS_AX)
	INT(_gl_ticktime)
	INT(_ADD_WIDTH)
	PTR(_old_mcode)
	LONG(_gl_mlen)
	PTR(_ad_envrn)
	GRECT(_gl_rmnactv)
	V(_desk_pid,w,MAX_ACCS)
	INT(_xa0ba)
	INT(_wasclr)
	INT(_w_walkflag)
	PTR(_gl_newdesk)
	PTR(_fc_tree)
	
	ds.b 52 /* unused */
#if OLD_SFCODE | (OS_COUNTRY == CTRY_FR)
	ds.b 4 /* unused */
#endif

/* end AES+DESKTOP */

/* This label is referenced by the GEM_MUPB structure */
	xdef _endgembss
_endgembss:	ds.b 0
