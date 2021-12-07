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

	V(oshdr,b,6+64)

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
	INT(fd_spt)
	INT(fd_interlv)
	INT(fd_virgin)
	PTR(fd_secmap)

	LONG(lastacstm)

	INT(fd_deferr)
	INT(fd_curerr)


	V(flopsregs,l,9)

	V(dsb,b,4*NUMFLOPPIES)
	
#if MSTECLK
	V(rtcbufa,b,13)
	V(rtcbufb,b,13)
#endif

	INT(baudrate)
	V(rs232ibuf,b,SERIAL_BUFSIZE)
	V(rs232obuf,b,SERIAL_BUFSIZE)
	V(rs232iorec,b,2*14+6)

	V(ikbdiorec,b,14)
	V(ikbdbuf,b,SERIAL_BUFSIZE)

	V(midiiorec,b,14)
	V(midibuf,b,128)

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

	LONG(_rseed)

	BYTE(_prtbdev)
	even

	BYTE(_prtboch)
	even

	INT(_prtbbval)

	BYTE(_prtbflg)
	even
	
	BYTE(_prtbdmask)
	even
	
	V(_prtboval,w,4)
	LONG(_fd_mediach)
	
	INT(_prtbwidth)

	V(_drivechange,b,NUMFLOPPIES)
	INT(_prtbbytes)

	BYTE(_prtbilow)
	even
	BYTE(_prtbihigh)
	even

	INT(_curflop)

	INT(_prtbwords)
	PTR(_prtbstrt)
	PTR(_prtbp2)
	INT(_prtbchunk)

	PTR(_prtbp1)
	INT(_prtbgval)
	PTR(_prtbend)
	INT(_prtbpmsk)
	INT(_prtbidx)
	INT(_prtbinvert)
	INT(_prtbink)
	INT(_width)
	INT(_prtbrval)
	V(_pbpar,b,30)

	V(_blkdev,b,32*NUMFLOPPIES)
	INT(_height)
	V(_prtbval,w,16)

	INT(_prtbplanes)
	INT(_prtboffset)

	INT(_prtbtcol)

	BYTE(_prtbacol)
	even
	V(_prtbmaxval,w,16)
	BYTE(_prtbeps)
	even
	V(_prtbobuf,b,8)
	V(_fd_err,w,NUMFLOPPIES)
	INT(_prtbheight)
	V(_prtbmval,w,4)
	BYTE(_prtbmono)
	even
	BYTE(_prtbmed)
	even
	BYTE(_prtbempty)
	even
	INT(_prtblines)
	INT(_prtbbits)
	INT(_prtbomask)
	INT(_prtbdots)
	BYTE(_prtbodd)
	even
	V(_prtbminval,w,16)
	BYTE(_prtbprez)
	even
	BYTE(_prtbamon)
	even
	BYTE(_prtblow)
	even
	BYTE(_prtbbol)
	even

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

	INT(_msec)

	ds.b 1024 /* unused */

	V(_supstk,w,SUPSIZ)

	INT(_time)

	V(_root,l,MAXQUICK)

	ds.b 60 /* unused? */

	V(_glbkbchar,l,3*KBBUFSZ)

	PTR(_ofdlist)

	V(_glbcolumn,w,3)
	INT(_rrecno)

	INT(_rwrtflg)

	V(_virt_work,b,180+MU_PLANES*16*2)

	PTR(_rdm)
	INT(_dirlock)

	V(_ofdbuf,b,70*80)
	LONG(_ldivr)

	INT(_oscnt)

	V(_ram8x8,b,90)

	LONG(_rwerr)
	V(_pmd,l,3)
	V(_sft,b,OPNFILES*10-6*10)

	PTR(_run)

	V(_ram8x16,b,90)
    
	V(_fill,b,3)
	even

	V(_bakbuf,l,3)

	V(_secbuf,b,4*SECTOR_SIZE)

	BYTE(_osuser)
	PTR(_dirrec)
	V(_dirtbl,l,NCURDIR)
	V(_errbuf,l,3)
	V(_diruse,b,NCURDIR)
	V(_drvtbl,l,BLKDEVNUM)
	INT(_drvsel)
	LONG(_uptime)
	INT(_errdrv)

	V(_ospd,b,256)
	V(_buptr,l,3)

	INT(_date)
	V(_bcbx,b,4*20) /* 4*sizeof(BCB) */
	V(_beptr,l,3)

/* This label is referenced by the OSHEADER */
	xdef _endvdibss
_endvdibss: ds.b 0

/* start AES+DESKTOP */

	ds.b 2
	PTR(retsava)
	INT(_gl_restype)
	INT(_gl_rschange)
	V(ustak,l,33)
	INT(_diskin)
	V(_aautopath,b,CMDLEN)
	V(x00622c,b,CMDLEN) /* g_dir maybe */
	V(x0062ac,b,CMDLEN) /* g_path maybe */

	V(x00632c,b,16)
	V(x00633c,b,16)
	V(x00634c,b,122)

	INT(x0063c6)

	V(srsave,w,1)
	V(savsr,w,1)
	V(psetsr,w,1)
	V(dspstk,l,161)
	
	LONG(retaddr)
	LONG(tr_retsave)
	
	LONG(_crit_err)
	LONG(savestk)
	LONG(_SAV2TRP)
	LONG(_savsup)
	PTR(_drawaddr)
	PTR(drawsp)
	LONG(_aesldivr)
	LONG(errsave)
	V(errstk,l,257)
	PTR(_ml_mnhold)
	GRECT(_ml_ctrl)
	PTR(_ml_pmown)
	PTR(_ml_pkown)
	
	ds.b 2
	
	PTR(_ad_rso)

	ds.b 86
	
	V(pblock,l,5)
	PTR(_drwaddr)
	PTR(_tikaddr)
	PTR(gstksave)
	PTR(tstksave)
	PTR(_tiksav)
	LONG(_NUM_TICK)
	LONG(_CMP_TICK)
	LONG(_TICKS)
	V(gstack,l,24)
	V(tstack,l,24)
	INT(_w_inc)
	INT(_bar_max)
	
	ds.b 26
	
	PTR(_maddr)
	V(mform,w,37)
	
	ds.b 8
	
	V(_intout,w,10)
	V(_ptsout,w,10)
	GRECT(_ctrl)
	
	ds.b 50
	
	INT(_gl_dabase)
	V(_gl_adacc,l,MAX_ACCS)

	ds.b 12
	
	INT(_xrat)
	INT(_yrat)
	INT(_gl_hchar)
	INT(_gl_naccs)

	ds.b 2
	
	INT(_gl_dacnt)
	INT(_gl_fakemsg)
	INT(_gl_bdelay)
	V(_gl_pacc,l,MAX_ACCS)
	PTR(_ad_hgmice)

	ds.b 58
	
	V(_bi,b,14)      /* BITBLK */

	ds.b 4
	
	INT(_gl_bclick)

	ds.b 4
	
	INT(_gl_handle)
	PTR(_ad_armice)
	INT(_gl_dclick)
	PTR(_ad_fsel)

	ds.b 32
	
	PTR(_ad_shcmd)

	ds.b 4
	
	INT(_gl_height)

	ds.b 30
	
	INT(_gl_recd)
	INT(_gl_bdesired)
	INT(_gl_apid)

	PTR(_ad_path)
	PTR(old_bcode)
	INT(_gl_hclip)
	INT(_gl_bvhard)
	PTR(_ad_shtail)
	PTR(_ad_stdesk)

	ds.b 4
	
	INT(_gl_wchar)
	PTR(_ad_windspb)
	INT(_gl_bvdisk)
	INT(_gl_bpend)
	INT(_gl_mode)
	PTR(_ad_intin)
	INT(_gl_hschar)
	INT(_sh_iscart)

	ds.b 36
	
	INT(_gl_moff)
	GRECT(_gl_rcenter)
	INT(_gl_graphic)
	INT(_gl_lcolor)
	PTR(old_mcode)
	INT(_gl_ticktime)
	INT(_gl_nplanes)
	LONG(_gl_mlen)
	INT(_DOS_AX)
	INT(_gl_mask)
	INT(_gl_ncols)

	ds.b 2
	
	PTR(_ad_envrn)
	V(_desk_pid,w,MAX_ACCS)

	ds.b 6

	GRECT(_gl_rmnactv)

	ds.b 4

	PTR(_gl_awind)

	ds.b 4
	
	PTR(_gl_rbuf)
	V(_gl_mkrect,b,12)  /* ORECT */
	V(_gl_ctwait,w,5) /* MOBLK */
	V(_pglobal,w,15)
	INT(_gl_wclip)
	V(_g_autoboot,b,CMDLEN)
	INT(_sh_isgem)
	INT(_gl_xclip)

	ds.b 4
	
	INT(_gl_rlen)
	INT(_gl_yclip)
	INT(_gl_hbox)
	PTR(_sys_adacc)
	GRECT(_gl_rmenu)
	INT(_gl_tcolor)

	ds.b 192
	
	LONG(_gl_mnpid) /* BUG: should be int */
	INT(_pr_mclick)
	INT(_g_wsend)

	INT(_gl_wschar)
	PTR(_rs_global)
	INT(_gl_play)
	LONG(_elinkoff)
	PTR(_gl_cowner)
	INT(_gl_font)
	PTR(_gl_pglue)
	INT(_sh_doexec)
	INT(_gl_width)
	PTR(_ad_sysglo)
	GRECT(_gl_rfull)
	INT(_gl_patt)

	ds.b 2
	
	V(_appl_msg,w,8)
	INT(_ml_ocnt)
	GRECT(_gl_rscreen)

	ds.b 12
	
	INT(_gl_btrue)

	ds.b 16
	
	PTR(_gl_kowner)
	INT(_gl_hsptschar)
	INT(_gl_hptschar)
	INT(_gl_wbox)
	PTR(_gl_mntree)
	PTR(_gl_mowner)

	ds.b 6
	
	V(_wind_spb,b,10)    /* sizeof(SPB) */
	GRECT(_gl_rzero)
	INT(_gl_mouse)

	ds.b 2
	
	INT(_gl_nrows)
	INT(_tmpmoff)

	ds.b 6
	
	INT(_autoexec)
	INT(_gl_wtop)

	ds.b 6
	
	INT(_pr_xrat)
	INT(_pr_button)
	
	V(x007098,w,4*4)
	
	INT(_gl_wsptschar)
	INT(_gl_wptschar)
	PTR(_drawstk)
	INT(_pr_yrat)
	INT(_gl_kstate)
	
	ds.b 28

	INT(_tbutton)
	
	ds.b 6
	
	INT(_fpcnt)
	V(_gl_ws,w,57)   /* workout */

	ds.b 2
	
	V(_intin,w,128)
	PTR(_cda)

	ds.b 456
	
	INT(_DOS_ERR)
	V(_ptsin,w,20)
	INT(_fph)
	PTR(_dlr)
	PTR(_drl)

	V(_D,b,13092) /* sizeof(THEGLO) */

	PTR(_eul)
	INT(x00a786)
	PTR(_thedesk)
	INT(_fpt)
	PTR(_nrl)
	PTR(_rlr)
	PTR(_rul)
	V(_evx,b,28) /* sizeof(EVB) */
	PTR(_g_buffer)
	PTR(_lp_mid)
	PTR(_zlr)
	INT(_g_flag)
	INT(_sh_gem)
	INT(_mclick)
	INT(_gl_fis)
	INT(_no_aes)
	PTR(_ctl_pd)
	MFDB(_gl_src)

	ds.b 8
	
	MFDB(_gl_dst)

	ds.b 4
	
	MFDB(_gl_tmp)

	ds.b 2
	
	INT(_er_num)
	INT(_curpid)
	BYTE(_indisp)
	even
	BYTE(_infork)
	even
	INT(_kstate)

	ds.b 4
	
	V(_contrl,w,12)

/* XXX */

	ds.b 8

	INT(_mtrans)
	INT(_tmpmon)
	INT(_button)


#if 0
	INT(_d_dir)
	PTR(_slr)
	PTR(_lp_end)
	INT(_gl_dabox)

	V(_fsname,b,40)
	V(_fcopy,b,40)
	PTR(_pathcopy)
	INT(_defdrv)
	
	V(fspec,b,8)
	INT(mydev)
	PTR(oldgetbpb)
	PTR(oldmediach)
	PTR(oldrwabs)
	ds.l 1 /* unused */
	PTR(trp13aret)
	PTR(trp14aret)
	GRECT(_fobj)
	INT(_xprint)
	INT(_m_st)
	V(_temp,b,50) /* unused */
	V(_rets,w,6) /* unused */
	V(_desk_acc,l,MAX_ACCS)
	V(_ib,b,34)      /* ICONBLK */
	PTR(_ad_fsnames)
	PTR(_ad_select)
	TEDINFO(_gl_aname)
	PTR(_ad_pfile) /* unused */
	PTR(_ad_fpath)
	INT(_gl_apid)
	TEDINFO(_gl_ainfo)
	INT(_gl_dcindex)
	INT(_q_change)
	PTR(_gh_buffer)
	INT(_back_up)
	PTR(_ad_fsdta)
	V(_dr,b,32)
	V(_gl_cmform,w,37) /* MFORM */
	INT(_f_rename)
	PTR(_background)
	V(_hdr_buff,w,18)   /* RSHDR */
	INT(_d_maxcolor)
	INT(_d_level)
	INT(_f_abort)
	INT(_f_level)
	V(_path1,b,PATHLEN)
	V(_path2,b,PATHLEN)
	INT(_d_display)
	INT(_w_walkflag)
	PTR(_winhead)
	PTR(_path3)
	PTR(_gl_newdesk)
	INT(_wasclr)
	V(_inf_path,b,PATHLEN)
	PTR(_cart_dta)
	PTR(_ad_title)
	INT(_p_timedate)
	V(_mentable,b,MAXMENU)
	even
	PTR(_ad_fstree)
	V(_gl_omform,w,37) /* MFORM */
 	V(_W_TREE,b,24*NUM_WIN)  /* OBJECT[NUM_WIN] */
	PTR(_iconmem)
	V(_comtail,b,PATHLEN)
	INT(_font_save)
	INT(_fs_first)
	PTR(_newbuff)
	V(_restable,b,6)
	PTR(_cart_ptr)
	INT(_fs_count)
	INT(_gl_newroot)
	LONG(_fs_fnum)
	INT(_maxicon)
	INT(_x_index)
	LONG(_numfiles)
	V(_wind_msg,w,8)
	PTR(_gl_wtree)
	INT(_gemsize)
	PTR(_lp_start)
	INT(_s_stofit)
	INT(_infsize)
	INT(_numicon)
	INT(_sh_up) /* unused */
	V(_filestr,b,NAMELEN)
	INT(_windspec)
	PTR(_gl_store)
	INT(_fs_topptr)
	INT(_d_nrows)
	INT(_desksiz)
	PTR(_deskptr)
	INT(_o_status)
	TEDINFO(_edblk)
	GRECT(_gl_rfs)
	PTR(_rs_hdr)
	PTR(_o_win)
	PTR(_backid)
	PTR(_fixdst)
	PTR(_infptr)
	PTR(_pxpath)
	PTR(_fixsrc)
	PTR(_gemptr)
	INT(_apsize)

	INT(_x_status)
	LONG(_tolsize)
	INT(_m_cpu)
	INT(_nogem)
	INT(_gl_mx)
	INT(_gl_my)
	PTR(_cpbox)
	INT(_i_status) /* unused */
	INT(_x_cur)
	PTR(_x_win)
	PTR(_dpd)
 	V(_W_ACTIVE,b,24*MAXOBJ)  /* OBJECT[MAXOBJ] */
	V(_dtabuf,b,44+4)
	V(_pxyarray,w,10) /* unused */
	V(_q_path,b,40) /* unused */
	
	LONG(_numdirs)
	PTR(_q_addr)
	PTR(_d_path)
	INT(_rename)
	INT(_opcode)
	INT(_o_item)
	INT(_d_exit)
	
	ds.b 16 /* unused? */
	
	INT(_nodesk)
	INT(_srcbuf)
	INT(_srclen)
	INT(_dstbuf)
	INT(_dstlen)
	INT(_o_type)
	V(_d_xywh,w,18)
	V(_f_xywh,w,18)
	INT(_x_type)
#endif
	
/* end AES+DESKTOP */

/* This label is referenced by the GEM_MUPB structure */
	xdef _endgembss
_endgembss:	ds.b 0

/* This label is referenced by the BIOS initialization */
	xdef __ebss
__ebss:	ds.b 0
	ds.b 0
