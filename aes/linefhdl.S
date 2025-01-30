#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

/*
 * The LineF handler is used to save code in the 192k ROM version.
 * It is used in two ways:
 * - if the opcode has bit #0 set, the remainder of the opcode
 *   is a register mask for a movem instruction from the epilogue
 * - otherwise, it is an offset to the jmp table for functions to call
 *
 * The register mask was shifted 2 bits to the right, so it does
 * not conflict with the linef opcode itself ($Fxxx). This works,
 * because
 * - a7 can never occur in such a mask
 * - a6 is the framepointer, and also will never occur in the mask
 * - d0 (which would be indicated by bit #0) is a scratch register,
 *      and never occurs in the mask
 * - d1-d2, which are shifted out, are also scratch registers,
 *      and never occur in the mask
 */
#if LINEF_HACK

/* 104de: 00fe7882 */

	xdef linefhandler
linefhandler:
		move.w    (a7)+,d2	/* fetch sr */
		movea.l   (a7)+,a0	/* fetch caller pc */
		move.w    (a0)+,d1	/* fetch opcode */
		btst      #0,d1
		bne.s     linefh1
		move.w    d2,sr
		move.l    a0,-(a7)
		andi.w    #$0FFF,d1
		movea.l   #lineftab,a0
		movea.l   0(a0,d1.w),a0
		jmp       (a0)
linefh1:
		andi.w    #$0FFE,d1	/* were any registers saved? */
		beq.s     linefh2	/* -> no */
		lsl.w     #2,d1		/* correct the mask */
		ori.w     #$0700,sr /* block interrupts since we might be called from the timer interrupt */
		lea.l     movinst+2(pc),a0
		move.w    d1,(a0)
		/* if any registers were saved, the epilogue would contain a tst.l (a7)+ instruction */
		addq.l    #4,a7
movinst:
		dc.w $4cdf,0		/* movem.l (a7)+,noregs */
linefh2:
		move.w    d2,sr		/* restore interrupts */
		unlk      a6		/* perform the unlk that was removed from epilogue */
		rts					/* perform the rts that was removed from epilogue */
		
		xdef lineftab
lineftab: ds.b 0

		dc.l _gsx_1code           ; F000
		dc.l _bb_fill             ; F004
		dc.l _gsx_tcalc           ; F008
		dc.l _rc_copy             ; F00C
		dc.l _gr_just             ; F010
		dc.l _gsx_tblt            ; F014
		dc.l _gsx_blt             ; F018
		dc.l _gr_rect             ; F01C
		dc.l _gsx_attr            ; F020
		dc.l _gr_gtext            ; F024
		dc.l _r_set               ; F028
		dc.l _gsx_moff            ; F02C
		dc.l _gr_inside           ; F030
		dc.l _gsx_box             ; F034
		dc.l _gsx_mon             ; F038
		dc.l _r_get               ; F03C
		dc.l _avst_clip           ; F040
		dc.l _gsx_xline           ; F044
		dc.l _av_pline            ; F048
		dc.l _gsx2                ; F04C
		dc.l _gsx_bxpts           ; F050
		dc.l _gsx_fix             ; F054
		dc.l _avro_cpyfm          ; F058
		dc.l _avrt_cpyfm          ; F05C
		dc.l _avr_trnfm           ; F060
		dc.l _gsx_ncode           ; F064
		dc.l _avst_height         ; F068
		dc.l _avsl_width          ; F06C
		dc.l _avr_recfl           ; F070
		dc.l _ch_width            ; F074
		dc.l _ch_height           ; F078
		dc.l _LBWMOV              ; F07C
		dc.l _min                 ; F080
		dc.l _objc_find           ; F084
		dc.l _act_chkobj          ; F088
		dc.l _evnt_multi          ; F08C
		dc.l _app_mtoi            ; F090
		dc.l _do_wredraw          ; F094
		dc.l _graf_mouse          ; F098
		dc.l _gsx_pline           ; F09C
		dc.l _gr_plns             ; F0A0
		dc.l _gr_isdown           ; F0A4
		dc.l _gr_extent           ; F0A8
		dc.l _gr_obalign          ; F0AC
		dc.l _gsx_sclip           ; F0B0
		dc.l _graf_mkstate        ; F0B4
		dc.l _rc_constrain        ; F0B8
		dc.l _gr_bwait            ; F0BC
		dc.l _wind_find           ; F0C0
		dc.l _win_find            ; F0C4
		dc.l _gr_obfind           ; F0C8
		dc.l _act_chg             ; F0CC
		dc.l _i_find              ; F0D0
		dc.l _rc_intersect        ; F0D4
		dc.l _objc_change         ; F0D8
		dc.l _rc_union            ; F0DC
		dc.l _act_allchg          ; F0E0
		dc.l _graf_rubbox         ; F0E4
		dc.l _gr_accobs           ; F0E8
		dc.l _gr_drgplns          ; F0EC
		dc.l _move_drvicon        ; F0F0
		dc.l _evnt_button         ; F0F4
		dc.l _hex_dig             ; F0F8
		dc.l _uhex_dig            ; F0FC
		dc.l _scan_2              ; F100
		dc.l _escan_str           ; F104
		dc.l _rsrc_gaddr          ; F108
		dc.l _LBCOPY              ; F10C
		dc.l _gsx_trans           ; F110
		dc.l _xstrpcpy            ; F114
		dc.l _dos_open            ; F118
		dc.l _dos_create          ; F11C
		dc.l _rom_ram             ; F120
		dc.l _movs                ; F124
		dc.l _max                 ; F128
		dc.l _dos_alloc           ; F12C
		dc.l _LWCOPY              ; F130
		dc.l _app_tran            ; F134
		dc.l _shel_get            ; F138
		dc.l _isdrive             ; F13C
		dc.l _app_getfh           ; F140
		dc.l _dos_read            ; F144
		dc.l _dos_close           ; F148
		dc.l _cart_init           ; F14C
		dc.l _app_alloc           ; F150
		dc.l _inf_xdesk           ; F154
		dc.l _app_rdicon          ; F158
		dc.l _bfill               ; F15C
		dc.l _save_2              ; F160
		dc.l _app_reverse         ; F164
		dc.l _save_sstr           ; F168
		dc.l _shel_put            ; F16C
		dc.l _set_infpath         ; F170
		dc.l _dos_error           ; F174
		dc.l _rest_infpath        ; F178
		dc.l _dos_write           ; F17C
		dc.l _win_ontop           ; F180
		dc.l _up_1win             ; F184
		dc.l _dos_gdrv            ; F188
		dc.l _dos_gdir            ; F18C
		dc.l _set_defdrv          ; F190
		dc.l _dos_chdir           ; F194
		dc.l _dos_sdrv            ; F198
		dc.l _obj_wfree           ; F19C
		dc.l _trp14               ; F1A0
		dc.l _obj_ialloc          ; F1A4
		dc.l _ap_bvset            ; F1A8
		dc.l _wildcmp             ; F1AC
		dc.l _form_center         ; F1B0
		dc.l _objc_draw           ; F1B4
		dc.l _desk_wait           ; F1B8
		dc.l _fm_draw             ; F1BC
		dc.l _show_hide           ; F1C0
		dc.l _form_do             ; F1C4
		dc.l _ob_change           ; F1C8
		dc.l _form_dial           ; F1CC
		dc.l _objc_offset         ; F1D0
		dc.l _xstrpcat            ; F1D4
		dc.l _fmt_str             ; F1D8
		dc.l _form_error          ; F1DC
		dc.l _dos_delete          ; F1E0
		dc.l _get_fname           ; F1E4
		dc.l _inf_sset            ; F1E8
		dc.l _do_namecon          ; F1EC
		dc.l _inf_what            ; F1F0
		dc.l _fs_ssget            ; F1F4
		dc.l _streq               ; F1F8
		dc.l _unfmt_str           ; F1FC
		dc.l _del_fname           ; F200
		dc.l _add_fname           ; F204
		dc.l _fun_alert           ; F208
		dc.l _d_dofdel            ; F20C
		dc.l _dos_set             ; F210
		dc.l _dos_sdta            ; F214
		dc.l _dos_sfirst          ; F218
		dc.l _dos_rmdir           ; F21C
		dc.l _merge_str           ; F220
		dc.l _drawfld             ; F224
		dc.l _sub_path            ; F228
		dc.l _add_path            ; F22C
		dc.l _dos_mkdir           ; F230
		dc.l _d_dofcopy           ; F234
		dc.l _dos_snext           ; F238
		dc.l _strlen              ; F23C
		dc.l _ret_path            ; F240           
		dc.l _dos_avail           ; F244
		dc.l _d_doop              ; F248
		dc.l _dos_free            ; F24C
		dc.l _do_finish           ; F250
		dc.l _fn_init             ; F254
		dc.l _pn_init             ; F258
		dc.l _fpd_elist           ; F25C
		dc.l _fl_free             ; F260
		dc.l _pn_alloc            ; F264
		dc.l _fpd_bldspec         ; F268
		dc.l _pn_free             ; F26C
		dc.l _strchk              ; F270
		dc.l _scasb               ; F274
		dc.l _pn_fcomp            ; F278
		dc.l _pn_comp             ; F27C
		dc.l _cart_sfirst         ; F280
		dc.l _fn_alloc            ; F284
		dc.l _cart_snext          ; F288
		dc.l _fn_free             ; F28C
		dc.l _pn_sort             ; F290
		dc.l _form_alert          ; F294
		dc.l _appl_write          ; F298
		dc.l _win_ith             ; F29C
		dc.l _pn_folder           ; F2A0
		dc.l _desk_verify         ; F2A4
		dc.l _win_sinfo           ; F2A8
		dc.l _wind_set            ; F2AC
		dc.l _wind_get            ; F2B0
		dc.l _send_msg            ; F2B4
		dc.l _par_chk             ; F2B8
		dc.l _dir_op              ; F2BC
		dc.l _get_spec            ; F2C0
		dc.l _fun_op              ; F2C4
		dc.l _fun_file2win        ; F2C8
		dc.l _desk_clear          ; F2CC
		dc.l _app_afind           ; F2D0
		dc.l _fun_wdst            ; F2D4
		dc.l _pn_open             ; F2D8
		dc.l _pn_close            ; F2DC
		dc.l _fun_f2any           ; F2E0
		dc.l _win_isel            ; F2E4
		dc.l _ini_str             ; F2E8
		dc.l _pro_cmd             ; F2EC
		dc.l _pro_run             ; F2F0
		dc.l _desk1_drag          ; F2F4
		dc.l _fun_win2desk        ; F2F8
		dc.l _fun_desk2win        ; F2FC
		dc.l _fun_d2desk          ; F300
		dc.l _rsrc_free           ; F304
		dc.l _mn_clsda            ; F308
		dc.l _ap_rdwr             ; F30C
		dc.l _all_run             ; F310
		dc.l _dsptch              ; F314
		dc.l _ev_multi            ; F318
		dc.l _ev_button           ; F31C
		dc.l _ev_dclick           ; F320
		dc.l _fm_do               ; F324
		dc.l _fm_dial             ; F328
		dc.l  _fm_alert           ; F32C
		dc.l _fm_error            ; F330
		dc.l _ob_center           ; F334
		dc.l _rs_gaddr            ; F338
		dc.l _gsx_mfset           ; F33C
		dc.l _gr_rubbox           ; F340
		dc.l _gr_mkstate          ; F344
		dc.l _gr_growbox          ; F348
		dc.l _gr_shrinkbox        ; F34C
		dc.l _do_chg              ; F350
		dc.l _mn_bar              ; F354
		dc.l _ob_offset           ; F358
		dc.l _ob_order            ; F35C
		dc.l _ob_find             ; F360
		dc.l _ob_add              ; F364
		dc.l _ob_draw             ; F368
		dc.l _rs_free             ; F36C
		dc.l _sh_write            ; F370
		dc.l _sh_get              ; F374
		dc.l _sh_put              ; F378
		dc.l _wm_close            ; F37C
		dc.l _wm_delete           ; F380
		dc.l _wm_find             ; F384
		dc.l _wm_update           ; F388
		dc.l _wm_create           ; F38C
		dc.l _wm_open             ; F390
		dc.l _wm_get              ; F394
		dc.l _wm_set              ; F398
		dc.l _wm_calc             ; F39C
		dc.l _my_itoa             ; F3A0
		dc.l _fmt_date            ; F3A4
		dc.l _fmt_time            ; F3A8
		dc.l _bldstring           ; F3AC
		dc.l _gsx_gclip           ; F3B0
		dc.l _dr_fnode            ; F3B4
		dc.l _inf_show            ; F3B8
		dc.l _inf_setsize         ; F3BC
		dc.l _inf_dttmsz          ; F3C0
		dc.l _inf_fldset          ; F3C4
		dc.l _dos_rename          ; F3C8
		dc.l _dos_chmod           ; F3CC
		dc.l _inf_fifo            ; F3D0
		dc.l _inf_finish          ; F3D4
		dc.l _dos_space           ; F3D8
		dc.l _dos_label           ; F3DC
		dc.l _inf_gindex          ; F3E0
		dc.l _app_reschange       ; F3E4
		dc.l _toupper             ; F3E8
		dc.l _app_free            ; F3EC
		dc.l _objc_add            ; F3F0
		dc.l _pro_exec            ; F3F4
		dc.l _do_wopen            ; F3F8
		dc.l _shel_write          ; F3FC
		dc.l _LSTCPY              ; F400
		dc.l _win_bldview         ; F404
		dc.l _do_xyfix            ; F408
		dc.l _get_xywh            ; F40C
		dc.l _graf_growbox        ; F410
		dc.l _wind_open           ; F414
		dc.l _wind_close          ; F418
		dc.l _graf_shrinkbox      ; F41C
		dc.l _rc_equal            ; F420
		dc.l _win_sname           ; F424
		dc.l _win_top             ; F428
		dc.l _pro_chdir           ; F42C
		dc.l _opn_appl            ; F430
		dc.l _win_alloc           ; F434
		dc.l _pro_chroot          ; F438
		dc.l _do_diropen          ; F43C
		dc.l _win_free            ; F440
		dc.l _fpd_parse           ; F444
		dc.l _do_aopen            ; F448
		dc.l _do_fopen            ; F44C
		dc.l _do_dopen            ; F450
		dc.l _inf_file            ; F454
		dc.l _inf_folder          ; F458
		dc.l _inf_disk            ; F45C
		dc.l _win_iname           ; F460
		dc.l _zoom_closed         ; F464
		dc.l _true_closewnd       ; F468
		dc.l _w_setpath           ; F46C
		dc.l _trp13               ; F470
		dc.l _eralert             ; F474
		dc.l _fpd_ofind           ; F478
		dc.l _menu_ienable        ; F47C
		dc.l _men_list            ; F480
		dc.l _open_item           ; F484
		dc.l _show_item           ; F488
		dc.l _newfolder           ; F48C
		dc.l _close_window        ; F490
		dc.l _do_format           ; F494
		dc.l _menu_icheck         ; F498
		dc.l _win_view            ; F49C
		dc.l _ins_disk            ; F4A0
		dc.l _app_blddesk         ; F4A4
		dc.l _ins_app             ; F4A8
		dc.l _win_bdall           ; F4AC
		dc.l _win_shwall          ; F4B0
		dc.l _desk_pref           ; F4B4
		dc.l _cnx_put             ; F4B8
		dc.l _save_inf            ; F4BC
		dc.l _av_hardcopy         ; F4C0
		dc.l _act_bsclick         ; F4C4
		dc.l _act_bdown           ; F4C8
		dc.l _fun_ddrag           ; F4CC
		dc.l _do_filemenu         ; F4D0
		dc.l _men_update          ; F4D4
		dc.l _do_deskmenu         ; F4D8
		dc.l _do_viewmenu         ; F4DC
		dc.l _win_srtall          ; F4E0
		dc.l _do_optnmenu         ; F4E4
		dc.l _menu_tnormal        ; F4E8
		dc.l _hd_menu             ; F4EC
		dc.l _do_wfull            ; F4F0
		dc.l _win_arrow           ; F4F4
		dc.l _win_slide           ; F4F8
		dc.l _evnt_dclick         ; F4FC
		dc.l _ap_init             ; F500
		dc.l _wind_update         ; F504
		dc.l _wind_calc           ; F508
		dc.l _rsrc_init           ; F50C
		dc.l _ini_tree            ; F510
		dc.l _read_inf            ; F514
		dc.l _ap_exit             ; F518
		dc.l _win_start           ; F51C
		dc.l _fpd_start           ; F520
		dc.l _menu_bar            ; F524
		dc.l _cnx_get             ; F528
		dc.l _hd_msg              ; F52C
		dc.l _hd_keybd            ; F530
		dc.l _hd_button           ; F534
		dc.l _obj_init            ; F538
		dc.l _obj_walloc          ; F53C
		dc.l _wind_create         ; F540
		dc.l _wind_delete         ; F544
		dc.l _objc_order          ; F548
		dc.l _win_cnt             ; F54C
		dc.l _win_ocalc           ; F550
		dc.l _win_icalc           ; F554
		dc.l _mul_div             ; F558
		dc.l _bb_screen           ; F55C
		dc.l _win_blt             ; F560
		dc.l _fc_init             ; F564
		dc.l _fc_do               ; F568
		dc.l _fc_bar              ; F56C
		dc.l _xbios               ; F570
		dc.l _do1_alert           ; F574
		dc.l _bios                ; F578
		dc.l _fc_clfix            ; F57C
		dc.l _fc_draw             ; F580
		dc.l _fc_alloc            ; F584
		dc.l _fc_rwtracks         ; F588
		dc.l _err_trap            ; F58C
		dc.l _fc_swp68            ; F590
		dc.l _sh_draw             ; F594
		dc.l _signal              ; F598
		dc.l _ev_block            ; F59C
		dc.l _fpdnm               ; F5A0
		dc.l _ev_timer            ; F5A4
		dc.l _forkq               ; F5A8
		dc.l _cli                 ; F5AC
		dc.l _sti                 ; F5B0
		dc.l _get_evb             ; F5B4
		dc.l _aqueue              ; F5B8
		dc.l _adelay              ; F5BC
		dc.l _amutex              ; F5C0
		dc.l _akbin               ; F5C4
		dc.l _amouse              ; F5C8
		dc.l _abutton             ; F5CC
		dc.l _takeoff             ; F5D0
		dc.l _ap_find             ; F5D4
		dc.l _ap_tplay            ; F5D8
		dc.l _ap_trecd            ; F5DC
		dc.l _ev_keybd            ; F5E0
		dc.l _ev_mouse            ; F5E4
		dc.l _ev_mesag            ; F5E8
		dc.l _mn_register         ; F5EC
		dc.l _ob_delete           ; F5F0
		dc.l _ob_edit             ; F5F4
		dc.l _fm_keybd            ; F5F8
		dc.l _fm_button           ; F5FC
		dc.l _gr_dragbox          ; F600
		dc.l _gr_movebox          ; F604
		dc.l _gr_watchbox         ; F608
		dc.l _gr_slidebox         ; F60C
		dc.l _sc_read             ; F610
		dc.l _sc_write            ; F614
		dc.l _fs_input            ; F618
		dc.l _rs_load             ; F61C
		dc.l _rs_saddr            ; F620
		dc.l _rs_obfix            ; F624
		dc.l _sh_read             ; F628
		dc.l _sh_find             ; F62C
		dc.l _sh_envrn            ; F630
		dc.l _fm_show             ; F634
		dc.l _crysbind            ; F638
		dc.l _xif                 ; F63C
		dc.l _supret              ; F640
		dc.l _cre_aproc           ; F644
		dc.l _pgmld               ; F648
		dc.l _pstart              ; F64C
		dc.l _ld_cartacc          ; F650
		dc.l _sndcli              ; F654
		dc.l _pinit               ; F658
		dc.l _ap_sendmsg          ; F65C
		dc.l _w_bldactive         ; F660
		dc.l _w_getsize           ; F664
		dc.l _gr_rubwind          ; F668
		dc.l _ct_msgup            ; F66C
		dc.l _hctl_window         ; F670
		dc.l _inside              ; F674
		dc.l _mn_do               ; F678
		dc.l _set_ctrl            ; F67C
		dc.l _set_mown            ; F680
		dc.l _w_setactive         ; F684
		dc.l _hctl_button         ; F688
		dc.l _hctl_rect           ; F68C
		dc.l _disp_act            ; F690
		dc.l _chkkbd              ; F694
		dc.l _savestate           ; F698
		dc.l _mwait_act           ; F69C
		dc.l _forker              ; F6A0
		dc.l _schedule            ; F6A4
		dc.l _switchto            ; F6A8
		dc.l _iasync              ; F6AC
		dc.l _mwait               ; F6B0
		dc.l _aret                ; F6B4
		dc.l _ev_rets             ; F6B8
		dc.l _dq                  ; F6BC
		dc.l _downorup            ; F6C0
		dc.l _ev_mchk             ; F6C4
		dc.l _acancel             ; F6C8
		dc.l _evremove            ; F6CC
		dc.l _tak_flag            ; F6D0
		dc.l _zombie              ; F6D4
		dc.l _evinsert            ; F6D8
		dc.l _fm_strbrk           ; F6DC
		dc.l _ob_setxywh          ; F6E0
		dc.l _fm_parse            ; F6E4
		dc.l _fm_build            ; F6E8
		dc.l _bb_save             ; F6EC
		dc.l _bb_restore          ; F6F0
		dc.l _get_ctrl            ; F6F4
		dc.l _get_mown            ; F6F8
		dc.l _ct_chgown           ; F6FC
		dc.l _find_obj            ; F700
		dc.l _ob_fs               ; F704
		dc.l _get_par             ; F708
		dc.l _take_ownership      ; F70C
		dc.l _fq                  ; F710
		dc.l _fm_inifld           ; F714
		dc.l _bellout             ; F718
		dc.l _w_drawdesk          ; F71C
		dc.l _w_update            ; F720
		dc.l _rs_str              ; F724
		dc.l _ins_char            ; F728
		dc.l _fs_back             ; F72C
		dc.l _chrout              ; F730
		dc.l _fs_sset             ; F734
		dc.l _fs_1scroll          ; F738
		dc.l _fs_sel              ; F73C
		dc.l _fs_format           ; F740
		dc.l _ob_actxywh          ; F744
		dc.l _fs_active           ; F748
		dc.l _gsx_mxmy            ; F74C
		dc.l _fs_pspec            ; F750
		dc.l _fs_newdir           ; F754
		dc.l _fs_sget             ; F758
		dc.l _fs_nscroll          ; F75C
		dc.l _gr_setup            ; F760
		dc.l _gr_scale            ; F764
		dc.l _gsx_xcbox           ; F768
		dc.l _gsx_xbox            ; F76C
		dc.l _gr_draw             ; F770
		dc.l _gr_stilldn          ; F774
		dc.l _gr_clamp            ; F778
		dc.l _gr_wait             ; F77C
		dc.l _gr_xor              ; F780
		dc.l _gr_stepcalc         ; F784
		dc.l _ob_relxywh          ; F788
		dc.l _gsx_wsopen          ; F78C
		dc.l _gsx_start           ; F790
		dc.l _gsx_setmb           ; F794
		dc.l _gsx_escapes         ; F798
		dc.l _gsx_resetmb         ; F79C
		dc.l _av_opnwk            ; F7A0
		dc.l _bb_set              ; F7A4
		dc.l _i_ptr               ; F7A8
		dc.l _m_lptr2             ; F7AC
		dc.l _i_ptsout            ; F7B0
		dc.l _i_intin             ; F7B4
		dc.l _i_intout            ; F7B8
		dc.l _i_ptsin             ; F7BC
		dc.l _i_lptr1             ; F7C0
		dc.l _i_ptr2              ; F7C4
		dc.l _ini_dlongs          ; F7C8
		dc.l _hcli                ; F7CC
		dc.l _takecpm             ; F7D0
		dc.l _hsti                ; F7D4
		dc.l _ictlmgr             ; F7D8
		dc.l _pred_dinf           ; F7DC
		dc.l _ldaccs              ; F7E0
		dc.l _gsx_init            ; F7E4
		dc.l _takeerr             ; F7E8
		dc.l _sh_tographic        ; F7EC
		dc.l _gsx_tick            ; F7F0
		dc.l _rs_fixit            ; F7F4
		dc.l _wm_start            ; F7F8
		dc.l _fs_start            ; F7FC
		dc.l _sh_main             ; F800
		dc.l _gsx_mfree           ; F804
		dc.l _giveerr             ; F808
		dc.l _free_accs           ; F80C
		dc.l _gsx_wsclose         ; F810
		dc.l _givecpm             ; F814
		dc.l _post_mouse          ; F818
		dc.l _post_button         ; F81C
		dc.l _post_keybd          ; F820
		dc.l _nq                  ; F824
		dc.l _mowner              ; F828
		dc.l _b_delay             ; F82C
		dc.l _inorout             ; F830
		dc.l _menu_sr             ; F834
		dc.l _rect_change         ; F838
		dc.l _gsx_button          ; F83C
		dc.l _menu_set            ; F840
		dc.l _menu_down           ; F844
		dc.l _gsx_cline           ; F848
		dc.l _p_nameit            ; F84C
		dc.l _pxl_rect            ; F850
		dc.l _instr               ; F854
		dc.l _find_pos            ; F858
		dc.l _ob_getsp            ; F85C
		dc.l _ob_format           ; F860
		dc.l _ob_stfn             ; F864
		dc.l _curfld              ; F868
		dc.l _ob_delit            ; F86C
		dc.l _check               ; F870
		dc.l _scan_to_end         ; F874
		dc.l _far_call            ; F878
		dc.l _ob_sst              ; F87C
		dc.l _gsx_chkclip         ; F880
		dc.l _gr_crack            ; F884
		dc.l _gr_box              ; F888
		dc.l _gr_gicon            ; F88C
		dc.l _ob_user             ; F890
		dc.l _everyobj            ; F894
		dc.l _get_prev            ; F898
		dc.l _just_draw           ; F89C
		dc.l _fapd                ; F8A0
		dc.l _setdsss             ; F8A4
		dc.l _strscn              ; F8A8
		dc.l _getpd               ; F8AC
		dc.l _psetup              ; F8B0
		dc.l _doq                 ; F8B4
		dc.l _do_rsfix            ; F8B8
		dc.l _fix_chpos           ; F8BC
		dc.l _get_addr            ; F8C0
		dc.l _get_sub             ; F8C4
		dc.l _fix_long            ; F8C8
		dc.l _fix_ptr             ; F8CC
		dc.l _LSTRLEN             ; F8D0
		dc.l _rs_sglobe           ; F8D4
		dc.l _dos_lseek           ; F8D8
		dc.l _fix_trindex         ; F8DC
		dc.l _fix_tedinfo         ; F8E0
		dc.l _fix_nptrs           ; F8E4
		dc.l _fix_objects         ; F8E8
		dc.l _rs_readit           ; F8EC
		dc.l _sh_fixtail          ; F8F0
		dc.l _dos_exec            ; F8F4
		dc.l _retake              ; F8F8
		dc.l _gsx_graphic         ; F8FC
		dc.l _gsx_malloc          ; F900
		dc.l _ratinit             ; F904
		dc.l _ratexit             ; F908
		dc.l _sh_name             ; F90C
		dc.l _sh_path             ; F910
		dc.l _sh_toalpha          ; F914
		dc.l _cart_exec           ; F918
		dc.l _desk_alloc          ; F91C
		dc.l _deskmain            ; F920
		dc.l _desk_free           ; F924
		dc.l _sh_rom              ; F928
		dc.l _sh_type             ; F92C
		dc.l _sh_print            ; F930
		dc.l _sh_format           ; F934
		dc.l _sh_copy             ; F938
		dc.l _w_getxptr           ; F93C
		dc.l _w_obadd             ; F940
		dc.l _w_adjust            ; F944
		dc.l _do_walk             ; F948
		dc.l _w_cpwalk            ; F94C
		dc.l _w_hvassign          ; F950
		dc.l _w_barcalc           ; F954
		dc.l _w_nilit             ; F958
		dc.l _w_bldbar            ; F95C
		dc.l _w_union             ; F960
		dc.l _w_mvfix             ; F964
		dc.l _w_redraw            ; F968
		dc.l _w_setsize           ; F96C
		dc.l _w_move              ; F970
		dc.l _or_start            ; F974
		dc.l _get_orect           ; F978
		dc.l _w_setup             ; F97C
		dc.l _draw_change         ; F980
		dc.l _wm_opcl             ; F984
		dc.l _w_owns              ; F988
		dc.l _gsx_mret            ; F98C
		dc.l _w_strchg            ; F990
		dc.l _unsync              ; F994
		dc.l _mkpiece             ; F998
		dc.l _brkrct              ; F99C
		dc.l _trap                ; F9A0
		dc.l _showfile            ; F9A4
		dc.l _sf_disp             ; F9A8
		dc.l _rawcon              ; F9AC
		dc.l _sf_putc             ; F9B0
		dc.l _sf_getc             ; F9B4
		dc.l _sf_page             ; F9B8
		dc.l _sf_more             ; F9BC
		dc.l _sf_newline          ; F9C0
		dc.l _cconws              ; F9C4
		dc.l _cart_alloc          ; F9C8
		dc.l _cart_find           ; F9CC

/* unused space */
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.w 0
		
#endif
