/* ==== CPU Exception Vectors ================================================ */

_buserror       equ $008
_addrerror      equ $00c
_illinst        equ $010
_zerodiv        equ $014
_chk2           equ $018
_trapcc         equ $01c
_privvio        equ $020
_tracetrap      equ $024
_lineatrap      equ $028
_lineftrap      equ $02c
_coprovio       equ $034
_cpunordered    equ $0c0
_cpinexact      equ $0c4
_cpdivzero      equ $0c8
_cpunderflow    equ $0cc
_cpoperror      equ $0d0

/* ==== Auto-Vector Interrupts =============================================== */

_lvl1vec        equ $064       /* Level 1 Int Autovector (TT VME) */
_lvl2vec        equ $068       /* Level 2 Int Autovector (HBL) */
_lvl3vec        equ $06c       /* Level 3 Int Autovector (TT VME) */
_lvl4vec        equ $070       /* Level 4 Int Autovector (VBL) */
_lvl5vec        equ $074       /* Level 5 Int Autovector (SCC) */
_lvl6vec        equ $078       /* Level 6 Int Autovector (MFP) */
_lvl7vec        equ $07c       /* Level 7 Int Autovector (NMI) */

/* ==== Trap Instruction Vectors ============================================= */

_trap0vec       equ $080
_trap1vec       equ $084       /* Trap #1 (GemDOS) */
_trap2vec       equ $088       /* Trap #2 (AES/VDI) */
_trap3vec       equ $08c
_trap4vec       equ $090
_trap5vec       equ $094
_trap6vec       equ $098
_trap7vec       equ $09c
_trap8vec       equ $0a0
_trap9vec       equ $0a4
_trap10vec      equ $0a8
_trap11vec      equ $0ac
_trap12vec      equ $0b0
_trap13vec      equ $0b4       /* Trap #13 (BIOS) */
_trap14vec      equ $0b8       /* Trap #14 (XBIOS) */
_trap15vec      equ $0bc

/* ==== Math Coprocessor Vectors ============================================= */

FPBRUC          equ $0c0       /* Branch or Set on Unordered Condition */
FPIE            equ $0c4       /* Inexact Result */
FPDIVZ          equ $0c8       /* Divide by Zero */
FPUNDER         equ $0cc       /* Underflow */
FPOE            equ $0d0       /* Operand Error */
FPOVER          equ $0d4       /* Overflow */
FPNAN           equ $0d8       /* Signaling NAN */
FPUNSUP         equ $0dc       /* Unimplemented data type (040/060) */

/* ==== PMMU Coprocessor Vectors (68851/Internal) ============================ */

MMUCFG          equ $0e0       /* MMU Configuration Error */
MMUILL          equ $0e4       /* MC68851, Illegal Operation, not used by MC68030 */
MMUACC          equ $0e8       /* MC68851, Access level violation, not used by MC68030 */

/* ==== Miscellaneous Vectors ================================================ */

UNIMPEA         equ $0f0       /* Unimplemented Effective Address (060) */
UNIMPII         equ $0f4       /* Unimplemented Integer Instruction (060) */

/* ==== User Assigned Interrupt Vectors ====================================== */

STMFP0          equ $100       /* Centronics busy */
STMFP1          equ $104       /* Printer Acknowledge (RS-232 DCD on ST) */
STMFP2          equ $108       /* Midi Interrupt (RS-232 CTS on ST) */
STMFP3          equ $10c       /* DSP Interrupt (Falcon) / Blitter done (MSTE) */
STMFP4          equ $110       /* Timer D (USART timer) */
STMFP5          equ $114       /* Timer C (200hz Clock) */
STMFP6          equ $118       /* Keyboard/MIDI (ACIA) */
STMFP7          equ $11c       /* FDC/HDC/SCSI/IDE */
STMFP8          equ $120       /* Timer B (HBL) */
STMFP9          equ $124       /* Send Error */
STMFP10         equ $128       /* Send buffer empty */
STMFP11         equ $12c       /* Receive error */
STMFP12         equ $130       /* Receive buffer full */
STMFP13         equ $134       /* Timer A (STe sound) */
STMFP14         equ $138       /* RS-232 Ring detect */
STMFP15         equ $13c       /* GPI7 - Monochrome Detect */
TTMFP0          equ $140       /* GPI 0 */
TTMFP1          equ $144       /* GPI 1 */
TTMFP2          equ $148       /* SCC-DMA Controller */
TTMFP3          equ $14c       /* Ring Indicator SCC B */
TTMFP4          equ $150       /* Timer D (RS232 baud rate generator) */
TTMFP5          equ $154       /* Timer C (SCC TRxCB) */
TTMFP6          equ $158       /* (Reserved) GPI 4 */
TTMFP7          equ $15c       /* SCSI DMA Controller */
TTMFP8          equ $160       /* Timer B */
TTMFP9          equ $164       /* Send Error */
TTMFP10         equ $168       /* Send buffer empty */
TTMFP11         equ $16c       /* Receive error */
TTMFP12         equ $170       /* Receive buffer full */
TTMFP13         equ $174       /* Timer A */
TTMFP14         equ $178       /* TT Clock (MC146818A) */
TTMFP15         equ $17c       /* TT-SCSI Drive Controller NCR 5380 */

/* ==== Start of Exception related variables ================================= */

_proc_lives     equ $380       /* validates system crash page, if 0x12345678 */
_proc_dregs     equ $384       /* saved registers d0-d7 */
_proc_aregs     equ $3a4       /* saved registers a0-a7 */
_proc_enum      equ $3c4       /* vector number of crash exception */
_proc_usp       equ $3c8       /* saved user stackpointer */
_proc_stk       equ $3cc       /* 16 words from exception stack */

/* ==== Start of System variables ============================================ */

_etv_timer      equ $400      /* GEM event timer vector */
_etv_critic     equ $404      /* GEM critical error handler */
_etv_term       equ $408      /* GEM program termination vector */
_etv_xtra       equ $40c      /* GEM additional vectors (unused) */
_memvalid       equ $420      /* memory conf valid, if 0x752019f3 */
memctrl         equ $424      /* copy of contents of 0xffff8001 */
resvalid        equ $426      /* validates resvector, if 0x31415926 */
resvector       equ $42a      /* reset vector */
_phystop        equ $42e      /* physical top of RAM */
_membot         equ $432      /* start of TPA (user memory) */
_memtop         equ $436      /* end of TPA (user memory) */
_memval2        equ $43a      /* validates memcntrl/memconf, if 0x237698aa */
_flock          equ $43e      /* if != 0, VBL floppy routine is disabled */
_seekrate       equ $440      /* floppy seek rate */
_timer_ms       equ $442      /* time between timer calls in ms */
_fverify        equ $444      /* if != 0, verify floppy writes */
_bootdev        equ $446      /* default boot drive */
_palmode        equ $448      /* 0 = NTSC, else PAL */
_defshiftmod    equ $44a      /* default video resolution */
_sshiftmod      equ $44c      /* copy of contents of 0xffff8260 */
_v_bas_ad       equ $44e      /* screen base address */
_vblsem         equ $452      /* if > 0, the VBL routine is executed */
_nvbls          equ $454      /* number of VBL routines */
_vblqueue       equ $456      /* pointer to list of VBL routines */
_colorptr       equ $45a      /* pointer to color palette to be loaded */
_screenpt       equ $45e      /* pointer to video RAM for next VBL */
_vbclock        equ $462      /* number of VBL routines executed */
_frclock        equ $466      /* number of VBL routines processed */
_hdv_init       equ $46a      /* vector for hard disk initialization */
_swv_vec        equ $46e      /* vector for resolution change */
_hdv_bpb        equ $472      /* vector for getbpb for harddisk */
_hdv_rw         equ $476      /* vector for read/write for harddisk */
_hdv_boot       equ $47a      /* vector for hard disk boot */
_hdv_mediach    equ $47e      /* vector for hard disk media change */
_cmdload        equ $482      /* if not 0, load command.prg after boot */
_conterm        equ $484      /* attribute vector for console output */
trp14ret        equ $486      /* return address for trap #14 (unused) */
criticret       equ $48a      /* return address for critical error hndlr */
_themd          equ $48e      /* first memory descriptor block */
____md          equ $49e      /* space for additional memory descriptor */
_savptr         equ $4a2      /* pointer to BIOS save register block */
_nflops         equ $4a6      /* number of connected floppy drives */
con_state       equ $4a8      /* vector for screen output */
_save_row       equ $4ac      /* temporary storage for cursor line pos. */
sav_context     equ $4ae      /* ptr to save area for exception processing */
_bufl           equ $4b2      /* pointers to buffer ctrl blocks for GEMDOS */
_hz_200         equ $4ba      /* counter for 200 Hz system clock */
the_env         equ $4be      /* pointer to default environment string */
_drvbits        equ $4c2      /* bit allocation for physical drives */
_dskbufp        equ $4c6      /* pointer to disk buffer */
_autopath       equ $4ca      /* pointer to auto-execute path */
_vbl_list       equ $4ce      /* pointers to 8 VBl routines */
_dumpflg        equ $4ee      /* flag for screen dump */
_prtabt         equ $4f0      /* printer abort flag */
_sysbase        equ $4f2      /* pointer to start of OS */
_shell_p        equ $4f6      /* pointer to shell */
_end_os         equ $4fa      /* pointer to end of OS */
_exec_os        equ $4fe      /* pointer to entry point of OS */

_scr_dmp        equ $502      /* pointer to screen dump routine */
_prt_stat       equ $506      /* pointer to prv_lsto */
_prt_vec        equ $50a      /* pointer to prv_lst */
_aux_stat       equ $50e      /* pointer to prv_auxo */
_aux_vec        equ $512      /* pointer to prv_aux */
_pun_ptr        equ $516      /* if AHDI, pointer to pun_info */
_memval3        equ $51a      /* memory conf valid if = $5555aaaa */
_bconstat_vec   equ $51e      /* 8 pointers to input-status routines */
_bconin_vec     equ $53e      /* 8 pointers to input routines */
_bcostat_vec    equ $55e      /* 8 pointers to output-status routines */
_bconout_vec    equ $57e      /* 8 pointers to output routines */
_longframe      equ $59e      /* if not 0, then not 68000 - use long stack frames */
_p_cookies      equ $5a0      /* pointer to cookie jar */
_ramtop         equ $5a4      /* pointer to end of FastRam */
_ramvalid       equ $5a8      /* validates ramtop if $1357BD13 */
_bell_hook      equ $5ac      /* pointer to routine for system bell */
_kcl_hook       equ $5b0      /* pointer to routine for system keyclick */

LcdPShadow      equ $889      /* STBook: shadow of LcdPowerControl ($FFFF827F) */


MFP_REGS        equ $fffffa01
/* parallel port output - write */
MFP_LPT         equ MFP_REGS+0
/* general purpose - input */
MFP_GPIP        equ MFP_REGS+0
/* active edge register */
MFP_AER         equ MFP_REGS+2
/* data direction register */
MFP_DDR         equ MFP_REGS+4
/* interrupt enable register A */
MFP_IERA        equ MFP_REGS+6
/* interrupt enable register B */
MFP_IERB        equ MFP_REGS+8
/* interrupt pending register A */
MFP_IPRA        equ MFP_REGS+10
/* interrupt pending register B */
MFP_IPRB        equ MFP_REGS+12
/* interrupt in-service register A */
MFP_ISRA        equ MFP_REGS+14
/* interrupt in-service register B */
MFP_ISRB        equ MFP_REGS+16
/* interrupt mask register A */
MFP_IMRA        equ MFP_REGS+18
/* interrupt mask register B */
MFP_IMRB        equ MFP_REGS+20
/* vector register */
MFP_VR          equ MFP_REGS+22
/* timer A control register */
MFP_TACR        equ MFP_REGS+24
/* timer B control register */
MFP_TBCR        equ MFP_REGS+26
/* timer C+D control register */
MFP_TCDCR       equ MFP_REGS+28
/* timer A data register */
MFP_TADR        equ MFP_REGS+30
/* timer B data register */
MFP_TBDR        equ MFP_REGS+32
/* timer C data register */
MFP_TCDR        equ MFP_REGS+34
/* timer D data register */
MFP_TDDR        equ MFP_REGS+36
/* synchronous character register */
MFP_SCR         equ MFP_REGS+38
/* USART control register */
MFP_UCR         equ MFP_REGS+40
/* receiver status register */
MFP_RSR         equ MFP_REGS+42
/* transmitter status register */
MFP_TSR         equ MFP_REGS+44
/* USART data register */
MFP_UDR         equ MFP_REGS+46

TTMFP_REGS      equ $fffffa81

NVRAM_ADDR_REG  equ $ffff8961
NVRAM_DATA_REG  equ $ffff8963

#define DMA_DATA $ffff8604
#define DMA_CTRL $ffff8606

psgsel    equ $FFFF8800
psgrd     equ $FFFF8800
psgwr     equ $FFFF8802
