/* ###
 * IP: GHIDRA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//Uses overriding references and the symbolic propogator to resolve LineF calls from TOS ROMS
//@author Thorsten Otto
//@category Analysis.68000
import java.io.*;
import java.util.*;
import java.util.Map.Entry;
import java.util.function.Predicate;

import generic.jar.ResourceFile;
import ghidra.app.cmd.function.ApplyFunctionDataTypesCmd;
import ghidra.app.cmd.memory.AddUninitializedMemoryBlockCmd;
import ghidra.app.plugin.core.analysis.AutoAnalysisManager;
import ghidra.app.plugin.core.analysis.ConstantPropagationContextEvaluator;
import ghidra.app.script.GhidraScript;
import ghidra.app.services.DataTypeManagerService;
import ghidra.framework.Application;
import ghidra.program.model.address.*;
import ghidra.program.model.data.*;
import ghidra.program.model.lang.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.mem.MemoryAccessException;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.pcode.PcodeOp;
import ghidra.program.model.pcode.Varnode;
import ghidra.program.model.symbol.*;
import ghidra.program.disassemble.Disassembler;
import ghidra.program.util.SymbolicPropogator;
import ghidra.program.util.ContextEvaluator;
import ghidra.program.util.VarnodeContext;
import ghidra.util.Msg;
import ghidra.util.exception.CancelledException;
import ghidra.util.task.TaskMonitor;
import ghidra.util.exception.NotFoundException;

/**
 * This script will resolve system calls for Atari TOS/MiNT binaries.
 */
public class TOSLineFfix extends GhidraScript {

	//the type of overriding reference to apply 
	private RefType overrideType;

	//the calling convention to use for system calls (must be defined in the appropriate .cspec file)
	private String callingConvention;

	private Program program;
	private Language language;
	private Disassembler disassembler;
	private AddressSetView view;
	private Listing listing;
	private DataType uint_type;
	
	private int getopcode(Address addr) throws Exception {
		int opcode = 0;
		try {
			opcode = program.getMemory().getShort(addr) & 0xffff;
		} catch (Exception e) {
			throw e;
		}
		return opcode;
	}

	private Address getaddr(Address addr) throws Exception {
		int val = 0;
		try {
			val = program.getMemory().getInt(addr);
		} catch (Exception e) {
			throw e;
		}
		return toAddr(val);
	}

	@Override
	protected void run() throws Exception {

		program = currentProgram;
		language = program.getLanguage();
		listing = program.getListing();
		disassembler = Disassembler.getDisassembler(program, monitor, null);
		view = null;
		
		if (!(language.getLanguageID().toString().equals("68000:BE:32:default")) &&
		    !(language.getLanguageID().toString().equals("68000:BE:32:mshort"))) {
			popup("This script is intended for Atari binaries, not" + language.getLanguageID().toString());
			return;
		}

		overrideType = RefType.CALL_OVERRIDE_UNCONDITIONAL;
		callingConvention = "__stdcall";
		uint_type = new UnsignedShortDataType();
		
		Map<Integer, String> traptable = getLinefTrapTable();
		Symbol lineftab = null;
		List<Symbol> lineftablist = program.getSymbolTable().getGlobalSymbols("lineftab");
		if (lineftablist != null)
		{
			lineftab = lineftablist.get(0);
		}
		if (lineftab == null)
		{
			printf("lineftab not found, calls won't be translated\n");
		} else
		{
			printf("lineftab at %s\n", lineftab.getAddress().toString());
			// Register lineftabReg = program.getProgramContext().getRegister("LINEFTAB");
			// lineftabReg.setValue(lineftab.getAddress().getOffset());
		}
		Address addr = toAddr(0xfd8fc4); /* 0xfd933e ini_dlongs in german version */
		Address end = toAddr(0xfeeb6a); /* 0xfd9362 linefhandler in french version */
		int callcount = 0;
		int retcount = 0;
		while (addr.getOffset() < end.getOffset()) {
			Address next;
			next = addr.add(2);
			int opcode = getopcode(addr);
			if ((opcode & 0xf000) == 0xf000) {
				// printf("lineftrap: %s %s\n", addr.toString(), Integer.toHexString(opcode));
				listing.clearCodeUnits(addr, addr.add(1), true);
				if (opcode < 0xfa00)
				{
					int offset = opcode & 0xfff;
					disassembler.disassemble(addr, view, false);
					if ((opcode & 1) == 0)
					{
						callcount++;
						String funcName = traptable.get(opcode);
						if (funcName != null)
						{
							// printf("linefcall: %s %s\n", addr.toString(), funcName);
							if (lineftab != null)
							{
								Address calladdr = getaddr(lineftab.getAddress().add(offset));
								Function callee = program.getFunctionManager().getFunctionAt(calladdr);
								if (callee == null)
								{
									callee = createFunction(calladdr, funcName);
									callee.setCallingConvention(callingConvention);
									printf("created function %s at %s\n", funcName, calladdr.toString());
								}
								Reference ref = program.getReferenceManager().addMemoryReference(addr,
									calladdr, overrideType, SourceType.USER_DEFINED, Reference.MNEMONIC);
								//overriding references must be primary to be active
								program.getReferenceManager().setPrimary(ref, true);
								Instruction inst = listing.getInstructionAt(addr);
								for (PcodeOp op : inst.getPcode()) {
										printf("op: %s %d\n", addr.toString(), op.getOpcode());
									if (op.getOpcode() == PcodeOp.CALL)
									{
										Varnode node = new Varnode(calladdr, 4);
										// op.setOpcode(PcodeOp.CALL);
										op.removeInput(0);
										op.setInput(node, 0);
										// printf("%s -> %s\n", addr.toString(), node.getAddress().toString());
									}
								}
							}
						}
					} else
					{
						retcount++;
					}
				} else
				{
					listing.createData(addr, uint_type, 2);
				}
			} else
			{
				next = listing.getCodeUnitAfter(addr).getMinAddress();
			}
			addr = next;
		}
		printf("%d LineF calls and %d return codes patched\n", callcount, retcount);
	}

	private Map<Integer, String> getLinefTrapTable() {
		Map<Integer, String> traptable = new HashMap<>();
		traptable.put(0xF000, "gsx_1code");
		traptable.put(0xF004, "bb_fill");
		traptable.put(0xF008, "gsx_tcalc");
		traptable.put(0xF00C, "rc_copy");
		traptable.put(0xF010, "gr_just");
		traptable.put(0xF014, "gsx_tblt");
		traptable.put(0xF018, "gsx_blt");
		traptable.put(0xF01C, "gr_rect");
		traptable.put(0xF020, "gsx_attr");
		traptable.put(0xF024, "gr_gtext");
		traptable.put(0xF028, "r_set");
		traptable.put(0xF02C, "gsx_moff");
		traptable.put(0xF030, "gr_inside");
		traptable.put(0xF034, "gsx_box");
		traptable.put(0xF038, "gsx_mon");
		traptable.put(0xF03C, "r_get");
		traptable.put(0xF040, "avst_clip");
		traptable.put(0xF044, "gsx_xline");
		traptable.put(0xF048, "av_pline");
		traptable.put(0xF04C, "gsx2");
		traptable.put(0xF050, "gsx_bxpts");
		traptable.put(0xF054, "gsx_fix");
		traptable.put(0xF058, "avro_cpyfm");
		traptable.put(0xF05C, "avrt_cpyfm");
		traptable.put(0xF060, "avr_trnfm");
		traptable.put(0xF064, "gsx_ncode");
		traptable.put(0xF068, "avst_height");
		traptable.put(0xF06C, "avsl_width");
		traptable.put(0xF070, "avr_recfl");
		traptable.put(0xF074, "ch_width");
		traptable.put(0xF078, "ch_height");
		traptable.put(0xF07C, "LBWMOV");
		traptable.put(0xF080, "min");
		traptable.put(0xF084, "objc_find");
		traptable.put(0xF088, "act_chkobj");
		traptable.put(0xF08C, "evnt_multi");
		traptable.put(0xF090, "app_mtoi");
		traptable.put(0xF094, "do_wredraw");
		traptable.put(0xF098, "graf_mouse");
		traptable.put(0xF09C, "gsx_pline");
		traptable.put(0xF0A0, "gr_plns");
		traptable.put(0xF0A4, "gr_isdown");
		traptable.put(0xF0A8, "gr_extent");
		traptable.put(0xF0AC, "gr_obalign");
		traptable.put(0xF0B0, "gsx_sclip");
		traptable.put(0xF0B4, "graf_mkstate");
		traptable.put(0xF0B8, "rc_constrain");
		traptable.put(0xF0BC, "gr_bwait");
		traptable.put(0xF0C0, "wind_find");
		traptable.put(0xF0C4, "win_find");
		traptable.put(0xF0C8, "gr_obfind");
		traptable.put(0xF0CC, "act_chg");
		traptable.put(0xF0D0, "i_find");
		traptable.put(0xF0D4, "rc_intersect");
		traptable.put(0xF0D8, "objc_change");
		traptable.put(0xF0DC, "rc_union");
		traptable.put(0xF0E0, "act_allchg");
		traptable.put(0xF0E4, "graf_rubbox");
		traptable.put(0xF0E8, "gr_accobs");
		traptable.put(0xF0EC, "gr_drgplns");
		traptable.put(0xF0F0, "move_drvicon");
		traptable.put(0xF0F4, "evnt_button");
		traptable.put(0xF0F8, "hex_dig");
		traptable.put(0xF0FC, "uhex_dig");
		traptable.put(0xF100, "scan_2");
		traptable.put(0xF104, "escan_str");
		traptable.put(0xF108, "rsrc_gaddr");
		traptable.put(0xF10C, "LBCOPY");
		traptable.put(0xF110, "gsx_trans");
		traptable.put(0xF114, "xstrpcpy");
		traptable.put(0xF118, "dos_open");
		traptable.put(0xF11C, "dos_create");
		traptable.put(0xF120, "rom_ram");
		traptable.put(0xF124, "movs");
		traptable.put(0xF128, "max");
		traptable.put(0xF12C, "dos_alloc");
		traptable.put(0xF130, "LWCOPY");
		traptable.put(0xF134, "app_tran");
		traptable.put(0xF138, "shel_get");
		traptable.put(0xF13C, "isdrive");
		traptable.put(0xF140, "app_getfh");
		traptable.put(0xF144, "dos_read");
		traptable.put(0xF148, "dos_close");
		traptable.put(0xF14C, "cart_init");
		traptable.put(0xF150, "app_alloc");
		traptable.put(0xF154, "inf_xdesk");
		traptable.put(0xF158, "app_rdicon");
		traptable.put(0xF15C, "bfill");
		traptable.put(0xF160, "save_2");
		traptable.put(0xF164, "app_reverse");
		traptable.put(0xF168, "save_sstr");
		traptable.put(0xF16C, "shel_put");
		traptable.put(0xF170, "set_infpath");
		traptable.put(0xF174, "dos_error");
		traptable.put(0xF178, "rest_infpath");
		traptable.put(0xF17C, "dos_write");
		traptable.put(0xF180, "win_ontop");
		traptable.put(0xF184, "up_1win");
		traptable.put(0xF188, "dos_gdrv");
		traptable.put(0xF18C, "dos_gdir");
		traptable.put(0xF190, "set_defdrv");
		traptable.put(0xF194, "dos_chdir");
		traptable.put(0xF198, "dos_sdrv");
		traptable.put(0xF19C, "obj_wfree");
		traptable.put(0xF1A0, "trp14");
		traptable.put(0xF1A4, "obj_ialloc");
		traptable.put(0xF1A8, "ap_bvset");
		traptable.put(0xF1AC, "wildcmp");
		traptable.put(0xF1B0, "form_center");
		traptable.put(0xF1B4, "objc_draw");
		traptable.put(0xF1B8, "desk_wait");
		traptable.put(0xF1BC, "fm_draw");
		traptable.put(0xF1C0, "show_hide");
		traptable.put(0xF1C4, "form_do");
		traptable.put(0xF1C8, "ob_change");
		traptable.put(0xF1CC, "form_dial");
		traptable.put(0xF1D0, "objc_offset");
		traptable.put(0xF1D4, "xstrpcat");
		traptable.put(0xF1D8, "fmt_str");
		traptable.put(0xF1DC, "form_error");
		traptable.put(0xF1E0, "dos_delete");
		traptable.put(0xF1E4, "get_fname");
		traptable.put(0xF1E8, "inf_sset");
		traptable.put(0xF1EC, "do_namecon");
		traptable.put(0xF1F0, "inf_what");
		traptable.put(0xF1F4, "fs_ssget");
		traptable.put(0xF1F8, "streq");
		traptable.put(0xF1FC, "unfmt_str");
		traptable.put(0xF200, "del_fname");
		traptable.put(0xF204, "add_fname");
		traptable.put(0xF208, "fun_alert");
		traptable.put(0xF20C, "d_dofdel");
		traptable.put(0xF210, "dos_set");
		traptable.put(0xF214, "dos_sdta");
		traptable.put(0xF218, "dos_sfirst");
		traptable.put(0xF21C, "dos_rmdir");
		traptable.put(0xF220, "merge_str");
		traptable.put(0xF224, "drawfld");
		traptable.put(0xF228, "sub_path");
		traptable.put(0xF22C, "add_path");
		traptable.put(0xF230, "dos_mkdir");
		traptable.put(0xF234, "d_dofcopy");
		traptable.put(0xF238, "dos_snext");
		traptable.put(0xF23C, "strlen");
		traptable.put(0xF240, "ret_path");
		traptable.put(0xF244, "dos_avail");
		traptable.put(0xF248, "d_doop");
		traptable.put(0xF24C, "dos_free");
		traptable.put(0xF250, "do_finish");
		traptable.put(0xF254, "fn_init");
		traptable.put(0xF258, "pn_init");
		traptable.put(0xF25C, "fpd_elist");
		traptable.put(0xF260, "fl_free");
		traptable.put(0xF264, "pn_alloc");
		traptable.put(0xF268, "fpd_bldspec");
		traptable.put(0xF26C, "pn_free");
		traptable.put(0xF270, "strchk");
		traptable.put(0xF274, "scasb");
		traptable.put(0xF278, "pn_fcomp");
		traptable.put(0xF27C, "pn_comp");
		traptable.put(0xF280, "cart_sfirst");
		traptable.put(0xF284, "fn_alloc");
		traptable.put(0xF288, "cart_snext");
		traptable.put(0xF28C, "fn_free");
		traptable.put(0xF290, "pn_sort");
		traptable.put(0xF294, "form_alert");
		traptable.put(0xF298, "appl_write");
		traptable.put(0xF29C, "win_ith");
		traptable.put(0xF2A0, "pn_folder");
		traptable.put(0xF2A4, "desk_verify");
		traptable.put(0xF2A8, "win_sinfo");
		traptable.put(0xF2AC, "wind_set");
		traptable.put(0xF2B0, "wind_get");
		traptable.put(0xF2B4, "send_msg");
		traptable.put(0xF2B8, "par_chk");
		traptable.put(0xF2BC, "dir_op");
		traptable.put(0xF2C0, "get_spec");
		traptable.put(0xF2C4, "fun_op");
		traptable.put(0xF2C8, "fun_file2win");
		traptable.put(0xF2CC, "desk_clear");
		traptable.put(0xF2D0, "app_afind");
		traptable.put(0xF2D4, "fun_wdst");
		traptable.put(0xF2D8, "pn_open");
		traptable.put(0xF2DC, "pn_close");
		traptable.put(0xF2E0, "fun_f2any");
		traptable.put(0xF2E4, "win_isel");
		traptable.put(0xF2E8, "ini_str");
		traptable.put(0xF2EC, "pro_cmd");
		traptable.put(0xF2F0, "pro_run");
		traptable.put(0xF2F4, "desk1_drag");
		traptable.put(0xF2F8, "fun_win2desk");
		traptable.put(0xF2FC, "fun_desk2win");
		traptable.put(0xF300, "fun_d2desk");
		traptable.put(0xF304, "rsrc_free");
		traptable.put(0xF308, "mn_clsda");
		traptable.put(0xF30C, "ap_rdwr");
		traptable.put(0xF310, "all_run");
		traptable.put(0xF314, "dsptch");
		traptable.put(0xF318, "ev_multi");
		traptable.put(0xF31C, "ev_button");
		traptable.put(0xF320, "ev_dclick");
		traptable.put(0xF324, "fm_do");
		traptable.put(0xF328, "fm_dial");
		traptable.put(0xF32C, "fm_alert");
		traptable.put(0xF330, "fm_error");
		traptable.put(0xF334, "ob_center");
		traptable.put(0xF338, "rs_gaddr");
		traptable.put(0xF33C, "gsx_mfset");
		traptable.put(0xF340, "gr_rubbox");
		traptable.put(0xF344, "gr_mkstate");
		traptable.put(0xF348, "gr_growbox");
		traptable.put(0xF34C, "gr_shrinkbox");
		traptable.put(0xF350, "do_chg");
		traptable.put(0xF354, "mn_bar");
		traptable.put(0xF358, "ob_offset");
		traptable.put(0xF35C, "ob_order");
		traptable.put(0xF360, "ob_find");
		traptable.put(0xF364, "ob_add");
		traptable.put(0xF368, "ob_draw");
		traptable.put(0xF36C, "rs_free");
		traptable.put(0xF370, "sh_write");
		traptable.put(0xF374, "sh_get");
		traptable.put(0xF378, "sh_put");
		traptable.put(0xF37C, "wm_close");
		traptable.put(0xF380, "wm_delete");
		traptable.put(0xF384, "wm_find");
		traptable.put(0xF388, "wm_update");
		traptable.put(0xF38C, "wm_create");
		traptable.put(0xF390, "wm_open");
		traptable.put(0xF394, "wm_get");
		traptable.put(0xF398, "wm_set");
		traptable.put(0xF39C, "wm_calc");
		traptable.put(0xF3A0, "my_itoa");
		traptable.put(0xF3A4, "fmt_date");
		traptable.put(0xF3A8, "fmt_time");
		traptable.put(0xF3AC, "bldstring");
		traptable.put(0xF3B0, "gsx_gclip");
		traptable.put(0xF3B4, "dr_fnode");
		traptable.put(0xF3B8, "inf_show");
		traptable.put(0xF3BC, "inf_setsize");
		traptable.put(0xF3C0, "inf_dttmsz");
		traptable.put(0xF3C4, "inf_fldset");
		traptable.put(0xF3C8, "dos_rename");
		traptable.put(0xF3CC, "dos_chmod");
		traptable.put(0xF3D0, "inf_fifo");
		traptable.put(0xF3D4, "inf_finish");
		traptable.put(0xF3D8, "dos_space");
		traptable.put(0xF3DC, "dos_label");
		traptable.put(0xF3E0, "inf_gindex");
		traptable.put(0xF3E4, "app_restype");
		traptable.put(0xF3E8, "toupper");
		traptable.put(0xF3EC, "app_free");
		traptable.put(0xF3F0, "objc_add");
		traptable.put(0xF3F4, "pro_exec");
		traptable.put(0xF3F8, "do_wopen");
		traptable.put(0xF3FC, "shel_write");
		traptable.put(0xF400, "LSTCPY");
		traptable.put(0xF404, "win_bldview");
		traptable.put(0xF408, "do_xyfix");
		traptable.put(0xF40C, "get_xywh");
		traptable.put(0xF410, "graf_growbox");
		traptable.put(0xF414, "wind_open");
		traptable.put(0xF418, "wind_close");
		traptable.put(0xF41C, "graf_shrinkbox");
		traptable.put(0xF420, "rc_equal");
		traptable.put(0xF424, "win_sname");
		traptable.put(0xF428, "win_top");
		traptable.put(0xF42C, "pro_chdir");
		traptable.put(0xF430, "opn_appl");
		traptable.put(0xF434, "win_alloc");
		traptable.put(0xF438, "pro_chroot");
		traptable.put(0xF43C, "do_diropen");
		traptable.put(0xF440, "win_free");
		traptable.put(0xF444, "fpd_parse");
		traptable.put(0xF448, "do_aopen");
		traptable.put(0xF44C, "do_fopen");
		traptable.put(0xF450, "do_dopen");
		traptable.put(0xF454, "inf_file");
		traptable.put(0xF458, "inf_folder");
		traptable.put(0xF45C, "inf_disk");
		traptable.put(0xF460, "win_iname");
		traptable.put(0xF464, "zoom_closed");
		traptable.put(0xF468, "true_closewnd");
		traptable.put(0xF46C, "w_setpath");
		traptable.put(0xF470, "trp13");
		traptable.put(0xF474, "eralert");
		traptable.put(0xF478, "fpd_ofind");
		traptable.put(0xF47C, "menu_ienable");
		traptable.put(0xF480, "men_list");
		traptable.put(0xF484, "open_item");
		traptable.put(0xF488, "show_item");
		traptable.put(0xF48C, "newfolder");
		traptable.put(0xF490, "close_window");
		traptable.put(0xF494, "do_format");
		traptable.put(0xF498, "menu_icheck");
		traptable.put(0xF49C, "win_view");
		traptable.put(0xF4A0, "ins_disk");
		traptable.put(0xF4A4, "app_blddesk");
		traptable.put(0xF4A8, "ins_app");
		traptable.put(0xF4AC, "win_bdall");
		traptable.put(0xF4B0, "win_shwall");
		traptable.put(0xF4B4, "desk_pref");
		traptable.put(0xF4B8, "cnx_put");
		traptable.put(0xF4BC, "save_inf");
		traptable.put(0xF4C0, "av_hardcopy");
		traptable.put(0xF4C4, "act_bsclick");
		traptable.put(0xF4C8, "act_bdown");
		traptable.put(0xF4CC, "fun_ddrag");
		traptable.put(0xF4D0, "do_filemenu");
		traptable.put(0xF4D4, "men_update");
		traptable.put(0xF4D8, "do_deskmenu");
		traptable.put(0xF4DC, "do_viewmenu");
		traptable.put(0xF4E0, "win_srtall");
		traptable.put(0xF4E4, "do_optnmenu");
		traptable.put(0xF4E8, "menu_tnormal");
		traptable.put(0xF4EC, "hd_menu");
		traptable.put(0xF4F0, "w_full");
		traptable.put(0xF4F4, "win_arrow");
		traptable.put(0xF4F8, "win_slide");
		traptable.put(0xF4FC, "evnt_dclick");
		traptable.put(0xF500, "ap_init");
		traptable.put(0xF504, "wind_update");
		traptable.put(0xF508, "wind_calc");
		traptable.put(0xF50C, "rsrc_init");
		traptable.put(0xF510, "ini_tree");
		traptable.put(0xF514, "read_inf");
		traptable.put(0xF518, "ap_exit");
		traptable.put(0xF51C, "win_start");
		traptable.put(0xF520, "fpd_start");
		traptable.put(0xF524, "menu_bar");
		traptable.put(0xF528, "cnx_get");
		traptable.put(0xF52C, "hd_msg");
		traptable.put(0xF530, "hd_keybd");
		traptable.put(0xF534, "hd_button");
		traptable.put(0xF538, "obj_init");
		traptable.put(0xF53C, "obj_walloc");
		traptable.put(0xF540, "wind_create");
		traptable.put(0xF544, "wind_delete");
		traptable.put(0xF548, "objc_order");
		traptable.put(0xF54C, "win_cnt");
		traptable.put(0xF550, "win_ocalc");
		traptable.put(0xF554, "win_icalc");
		traptable.put(0xF558, "mul_div");
		traptable.put(0xF55C, "bb_screen");
		traptable.put(0xF560, "win_blt");
		traptable.put(0xF564, "frm_f564");
		traptable.put(0xF568, "frm_f568");
		traptable.put(0xF56C, "frm_f56c");
		traptable.put(0xF570, "xbios");
		traptable.put(0xF574, "frm_f574");
		traptable.put(0xF578, "bios");
		traptable.put(0xF57C, "frm_f57c");
		traptable.put(0xF580, "frm_f580");
		traptable.put(0xF584, "frm_f584");
		traptable.put(0xF588, "frm_f588");
		traptable.put(0xF58C, "err_trap");
		traptable.put(0xF590, "frm_swp68");
		traptable.put(0xF594, "sh_draw");
		traptable.put(0xF598, "signal");
		traptable.put(0xF59C, "ev_block");
		traptable.put(0xF5A0, "fpdnm");
		traptable.put(0xF5A4, "ev_timer");
		traptable.put(0xF5A8, "forkq");
		traptable.put(0xF5AC, "cli");
		traptable.put(0xF5B0, "sti");
		traptable.put(0xF5B4, "get_evb");
		traptable.put(0xF5B8, "aqueue");
		traptable.put(0xF5BC, "adelay");
		traptable.put(0xF5C0, "amutex");
		traptable.put(0xF5C4, "akbin");
		traptable.put(0xF5C8, "amouse");
		traptable.put(0xF5CC, "abutton");
		traptable.put(0xF5D0, "takeoff");
		traptable.put(0xF5D4, "ap_find");
		traptable.put(0xF5D8, "ap_tplay");
		traptable.put(0xF5DC, "ap_trecd");
		traptable.put(0xF5E0, "ev_keybd");
		traptable.put(0xF5E4, "ev_mouse");
		traptable.put(0xF5E8, "ev_mesag");
		traptable.put(0xF5EC, "mn_register");
		traptable.put(0xF5F0, "ob_delete");
		traptable.put(0xF5F4, "ob_edit");
		traptable.put(0xF5F8, "fm_keybd");
		traptable.put(0xF5FC, "fm_button");
		traptable.put(0xF600, "gr_dragbox");
		traptable.put(0xF604, "gr_movebox");
		traptable.put(0xF608, "gr_watchbox");
		traptable.put(0xF60C, "gr_slidebox");
		traptable.put(0xF610, "sc_read");
		traptable.put(0xF614, "sc_write");
		traptable.put(0xF618, "fs_input");
		traptable.put(0xF61C, "rs_load");
		traptable.put(0xF620, "rs_saddr");
		traptable.put(0xF624, "rs_obfix");
		traptable.put(0xF628, "sh_read");
		traptable.put(0xF62C, "sh_find");
		traptable.put(0xF630, "sh_envrn");
		traptable.put(0xF634, "fm_show");
		traptable.put(0xF638, "crysbind");
		traptable.put(0xF63C, "xif");
		traptable.put(0xF640, "supret");
		traptable.put(0xF644, "cre_aproc");
		traptable.put(0xF648, "pgmld");
		traptable.put(0xF64C, "pstart");
		traptable.put(0xF650, "ld_cartacc");
		traptable.put(0xF654, "sndcli");
		traptable.put(0xF658, "pinit");
		traptable.put(0xF65C, "ap_sendmsg");
		traptable.put(0xF660, "w_bldactive");
		traptable.put(0xF664, "w_getsize");
		traptable.put(0xF668, "gr_rubwind");
		traptable.put(0xF66C, "ct_msgup");
		traptable.put(0xF670, "hctl_window");
		traptable.put(0xF674, "inside");
		traptable.put(0xF678, "mn_do");
		traptable.put(0xF67C, "set_ctrl");
		traptable.put(0xF680, "set_mown");
		traptable.put(0xF684, "w_setactive");
		traptable.put(0xF688, "hctl_button");
		traptable.put(0xF68C, "hctl_rect");
		traptable.put(0xF690, "disp_act");
		traptable.put(0xF694, "chkkbd");
		traptable.put(0xF698, "savestate");
		traptable.put(0xF69C, "mwait_act");
		traptable.put(0xF6A0, "forker");
		traptable.put(0xF6A4, "schedule");
		traptable.put(0xF6A8, "switchto");
		traptable.put(0xF6AC, "iasync");
		traptable.put(0xF6B0, "mwait");
		traptable.put(0xF6B4, "aret");
		traptable.put(0xF6B8, "ev_rets");
		traptable.put(0xF6BC, "dq");
		traptable.put(0xF6C0, "downorup");
		traptable.put(0xF6C4, "ev_mchk");
		traptable.put(0xF6C8, "acancel");
		traptable.put(0xF6CC, "evremove");
		traptable.put(0xF6D0, "tak_flag");
		traptable.put(0xF6D4, "zombie");
		traptable.put(0xF6D8, "evinsert");
		traptable.put(0xF6DC, "fm_strbrk");
		traptable.put(0xF6E0, "ob_setxywh");
		traptable.put(0xF6E4, "fm_parse");
		traptable.put(0xF6E8, "fm_build");
		traptable.put(0xF6EC, "bb_save");
		traptable.put(0xF6F0, "bb_restore");
		traptable.put(0xF6F4, "get_ctrl");
		traptable.put(0xF6F8, "get_mown");
		traptable.put(0xF6FC, "ct_chgown");
		traptable.put(0xF700, "find_obj");
		traptable.put(0xF704, "ob_fs");
		traptable.put(0xF708, "get_par");
		traptable.put(0xF70C, "take_ownership");
		traptable.put(0xF710, "fq");
		traptable.put(0xF714, "fm_inifld");
		traptable.put(0xF718, "bellout");
		traptable.put(0xF71C, "w_drawdesk");
		traptable.put(0xF720, "w_update");
		traptable.put(0xF724, "rs_str");
		traptable.put(0xF728, "ins_char");
		traptable.put(0xF72C, "fs_back");
		traptable.put(0xF730, "chrout");
		traptable.put(0xF734, "fs_sset");
		traptable.put(0xF738, "fs_1scroll");
		traptable.put(0xF73C, "fs_sel");
		traptable.put(0xF740, "fs_format");
		traptable.put(0xF744, "ob_actxywh");
		traptable.put(0xF748, "fs_active");
		traptable.put(0xF74C, "gsx_mxmy");
		traptable.put(0xF750, "fs_pspec");
		traptable.put(0xF754, "fs_newdir");
		traptable.put(0xF758, "fs_sget");
		traptable.put(0xF75C, "fs_nscroll");
		traptable.put(0xF760, "gr_setup");
		traptable.put(0xF764, "gr_scale");
		traptable.put(0xF768, "gsx_xcbox");
		traptable.put(0xF76C, "gsx_xbox");
		traptable.put(0xF770, "gr_draw");
		traptable.put(0xF774, "gr_stilldn");
		traptable.put(0xF778, "gr_clamp");
		traptable.put(0xF77C, "gr_wait");
		traptable.put(0xF780, "gr_xor");
		traptable.put(0xF784, "gr_stepcalc");
		traptable.put(0xF788, "ob_relxywh");
		traptable.put(0xF78C, "gsx_wsopen");
		traptable.put(0xF790, "gsx_start");
		traptable.put(0xF794, "gsx_setmb");
		traptable.put(0xF798, "gsx_escapes");
		traptable.put(0xF79C, "gsx_resetmb");
		traptable.put(0xF7A0, "av_opnwk");
		traptable.put(0xF7A4, "bb_set");
		traptable.put(0xF7A8, "i_ptr");
		traptable.put(0xF7AC, "m_lptr2");
		traptable.put(0xF7B0, "i_ptsout");
		traptable.put(0xF7B4, "i_intin");
		traptable.put(0xF7B8, "i_intout");
		traptable.put(0xF7BC, "i_ptsin");
		traptable.put(0xF7C0, "i_lptr1");
		traptable.put(0xF7C4, "i_ptr2");
		traptable.put(0xF7C8, "ini_dlongs");
		traptable.put(0xF7CC, "hcli");
		traptable.put(0xF7D0, "takecpm");
		traptable.put(0xF7D4, "hsti");
		traptable.put(0xF7D8, "ictlmgr");
		traptable.put(0xF7DC, "pred_dinf");
		traptable.put(0xF7E0, "ldaccs");
		traptable.put(0xF7E4, "gsx_init");
		traptable.put(0xF7E8, "takeerr");
		traptable.put(0xF7EC, "sh_tographic");
		traptable.put(0xF7F0, "gsx_tick");
		traptable.put(0xF7F4, "rs_fixit");
		traptable.put(0xF7F8, "wm_start");
		traptable.put(0xF7FC, "fs_start");
		traptable.put(0xF800, "sh_main");
		traptable.put(0xF804, "gsx_mfree");
		traptable.put(0xF808, "giveerr");
		traptable.put(0xF80C, "free_accs");
		traptable.put(0xF810, "gsx_wsclose");
		traptable.put(0xF814, "givecpm");
		traptable.put(0xF818, "post_mouse");
		traptable.put(0xF81C, "post_button");
		traptable.put(0xF820, "post_keybd");
		traptable.put(0xF824, "nq");
		traptable.put(0xF828, "mowner");
		traptable.put(0xF82C, "b_delay");
		traptable.put(0xF830, "inorout");
		traptable.put(0xF834, "menu_sr");
		traptable.put(0xF838, "rect_change");
		traptable.put(0xF83C, "gsx_button");
		traptable.put(0xF840, "menu_set");
		traptable.put(0xF844, "menu_down");
		traptable.put(0xF848, "gsx_cline");
		traptable.put(0xF84C, "p_nameit");
		traptable.put(0xF850, "pxl_rect");
		traptable.put(0xF854, "instr");
		traptable.put(0xF858, "find_pos");
		traptable.put(0xF85C, "ob_getsp");
		traptable.put(0xF860, "ob_format");
		traptable.put(0xF864, "ob_stfn");
		traptable.put(0xF868, "curfld");
		traptable.put(0xF86C, "ob_delit");
		traptable.put(0xF870, "check");
		traptable.put(0xF874, "scan_to_end");
		traptable.put(0xF878, "far_call");
		traptable.put(0xF87C, "ob_sst");
		traptable.put(0xF880, "gsx_chkclip");
		traptable.put(0xF884, "gr_crack");
		traptable.put(0xF888, "gr_box");
		traptable.put(0xF88C, "gr_gicon");
		traptable.put(0xF890, "ob_user");
		traptable.put(0xF894, "everyobj");
		traptable.put(0xF898, "get_prev");
		traptable.put(0xF89C, "just_draw");
		traptable.put(0xF8A0, "fapd");
		traptable.put(0xF8A4, "setdsss");
		traptable.put(0xF8A8, "strscn");
		traptable.put(0xF8AC, "getpd");
		traptable.put(0xF8B0, "psetup");
		traptable.put(0xF8B4, "doq");
		traptable.put(0xF8B8, "do_rsfix");
		traptable.put(0xF8BC, "fix_chpos");
		traptable.put(0xF8C0, "get_addr");
		traptable.put(0xF8C4, "get_sub");
		traptable.put(0xF8C8, "fix_long");
		traptable.put(0xF8CC, "fix_ptr");
		traptable.put(0xF8D0, "LSTRLEN");
		traptable.put(0xF8D4, "rs_sglobe");
		traptable.put(0xF8D8, "dos_lseek");
		traptable.put(0xF8DC, "fix_trindex");
		traptable.put(0xF8E0, "fix_tedinfo");
		traptable.put(0xF8E4, "fix_nptrs");
		traptable.put(0xF8E8, "fix_objects");
		traptable.put(0xF8EC, "rs_readit");
		traptable.put(0xF8F0, "sh_strupr");
		traptable.put(0xF8F4, "dos_exec");
		traptable.put(0xF8F8, "retake");
		traptable.put(0xF8FC, "gsx_graphic");
		traptable.put(0xF900, "gsx_malloc");
		traptable.put(0xF904, "ratinit");
		traptable.put(0xF908, "ratexit");
		traptable.put(0xF90C, "sh_name");
		traptable.put(0xF910, "sh_path");
		traptable.put(0xF914, "sh_toalpha");
		traptable.put(0xF918, "cart_exec");
		traptable.put(0xF91C, "desk_alloc");
		traptable.put(0xF920, "deskmain");
		traptable.put(0xF924, "desk_free");
		traptable.put(0xF928, "sh_xxx");
		traptable.put(0xF92C, "f92c_show");
		traptable.put(0xF930, "f930_show");
		traptable.put(0xF934, "f934_show");
		traptable.put(0xF938, "f938_frm");
		traptable.put(0xF93C, "w_getxptr");
		traptable.put(0xF940, "w_obadd");
		traptable.put(0xF944, "w_adjust");
		traptable.put(0xF948, "do_walk");
		traptable.put(0xF94C, "w_cpwalk");
		traptable.put(0xF950, "w_hvassign");
		traptable.put(0xF954, "w_barcalc");
		traptable.put(0xF958, "w_nilit");
		traptable.put(0xF95C, "w_bldbar");
		traptable.put(0xF960, "w_union");
		traptable.put(0xF964, "w_mvfix");
		traptable.put(0xF968, "w_redraw");
		traptable.put(0xF96C, "w_setsize");
		traptable.put(0xF970, "w_move");
		traptable.put(0xF974, "or_start");
		traptable.put(0xF978, "get_orect");
		traptable.put(0xF97C, "w_setup");
		traptable.put(0xF980, "draw_change");
		traptable.put(0xF984, "wm_opcl");
		traptable.put(0xF988, "w_owns");
		traptable.put(0xF98C, "gsx_mret");
		traptable.put(0xF990, "w_strchg");
		traptable.put(0xF994, "unsync");
		traptable.put(0xF998, "mkpiece");
		traptable.put(0xF99C, "brkrct");
		traptable.put(0xF9A0, "trap");
		traptable.put(0xF9A4, "f9a4_show");
		traptable.put(0xF9A8, "f9a8_show");
		traptable.put(0xF9AC, "rawcon");
		traptable.put(0xF9B0, "f9b0_show");
		traptable.put(0xF9B4, "f9b4_show");
		traptable.put(0xF9B8, "f9b8_show");
		traptable.put(0xF9BC, "f9bc_show");
		traptable.put(0xF9C0, "f9c0_show");
		traptable.put(0xF9C4, "f9c4_show");
		traptable.put(0xF9C8, "cart_alloc");
		traptable.put(0xF9CC, "cart_find");
		return traptable;
	}
	
	/**
	 * Checks whether an m68k instruction is a GEMDOS call
	 * @param inst instruction to check
	 * @return true precisely when the instruction is a system call
	 */
	private int checkTrapInstruction(Instruction inst) {
		int retVal = -1;
		for (PcodeOp op : inst.getPcode()) {
			if (op.getOpcode() == PcodeOp.CALLOTHER) {
				int index = (int) op.getInput(0).getOffset();
				if (language.getUserDefinedOpName(index).equals("__m68k_trap")) {
					int klass = (int) op.getInput(1).getOffset();
					if (klass == 1 || klass == 13 || klass == 14) {
						retVal = klass;
					}
				}
			}
		}
		return retVal;
	}
}
