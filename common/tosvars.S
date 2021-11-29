/*
 * tosvars.S - TOS System variables
 *
 * Copyright (c) 2005-2013 by the EmuTOS development team.
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 *
 */

        xdef  _proc_lives
        xdef  _proc_dregs
        xdef  _proc_aregs
        xdef  _proc_enum
        xdef  _proc_usp
        xdef  _proc_stk

        xdef  _etv_timer
        xdef  _etv_critic
        xdef  _etv_term
        xdef  _etv_xtra
        xdef  _memvalid
        xdef  memctrl
        xdef  resvalid
        xdef  resvector
        xdef  _phystop
        xdef  _membot
        xdef  _memtop
        xdef  _memval2
        xdef  _flock
        xdef  _seekrate
        xdef  _timer_ms
        xdef  _fverify
        xdef  _bootdev
        xdef  _palmode
        xdef  _defshiftmod
        xdef  _sshiftmod
        xdef  _v_bas_ad
        xdef  _vblsem
        xdef  _nvbls
        xdef  _vblqueue
        xdef  _colorptr
        xdef  _screenpt
        xdef  _vbclock
        xdef  _frclock
        xdef  _hdv_init
        xdef  _swv_vec
        xdef  _hdv_bpb
        xdef  _hdv_rw
        xdef  _hdv_boot
        xdef  _hdv_mediach
        xdef  _cmdload
        xdef  _conterm
        xdef  _themd
        xdef  ____md
        xdef  _savptr
        xdef  _nflops
        xdef  con_state
        xdef  _save_row
        xdef  sav_context
        xdef  _bufl
        xdef  _hz_200
        xdef  the_env
        xdef  _drvbits
        xdef  _dskbufp
        xdef  _autopath
        xdef  _vbl_list
        xdef  _dumpflg
        xdef  _sysbase
        xdef  _shell_p
        xdef  _end_os
        xdef  _exec_os
        xdef  _scr_dmp
        xdef  _prt_stat
        xdef  _prt_vec
        xdef  _aux_stat
        xdef  _aux_vec
        xdef  _pun_ptr
        xdef  _memval3
        xdef  _bconstat_vec
        xdef  _bconin_vec
        xdef  _bcostat_vec
        xdef  _bconout_vec
        xdef  _longframe
        xdef  _p_cookies
        xdef  _ramtop
        xdef  _ramvalid
        xdef  _bell_hook
        xdef  _kcl_hook

#include "tosvars.inc"

		xdef sysvars_start
sysvars_start equ _etv_timer

/*        org 0x5b4 */

/*        ds.b $24c */
        
/*        org 0x800 */


/* =========================================================================== */
/* ==== End ================================================================== */
/* =========================================================================== */

