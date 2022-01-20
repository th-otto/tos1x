/*
 * Defaults which patches should be applied.
 *
 * You can either edit the settings below, or
 * (better) create a file common/localcnf.h instead
 * with your preferred settings
 */
 
/*
 * TP_01: KILL_RESET: Omit RESET instruction for RAM-TOS on older ST's
 */
#ifndef TP_01
#define TP_01 (RAMVERSION)
#endif

/*
 * TP_02: COLOR_60HZ: Switch to 60Hz on color monitors
 */
#ifndef TP_02
#define TP_02 0
#endif

/*
 * TP_04: MEM_INIT: Clear memory from $100-$400
 * Clear the memory starting at $100 instead of $400 on reset,
 * to remove any junk.
 * This patch is disabled if the RAMRESET patch is also active.
 */
#ifndef TP_04
#define TP_04 0
#endif

/*
 * TP_05: SHELL_P: Clear _shell_p
 * Clear the _shell_p system variable on reset.
 */
#ifndef TP_05
#define TP_05 1
#endif

/*
 * TP_06: MSTE_CACHE_ON: Turn on 16Mhz for Mega-STE
 * Turns on 16 MHz and cache on Mega-STE already when booting
 */
#ifndef TP_06
#define TP_06 0
#endif

/*
 * TP_07: SET_STEP: Set steprate for floppy drives A: and B:
 * 0 = 6 ms
 * 1 = 12 ms
 * 2 = 2 ms
 * 3 = 3 ms
 */
#ifndef TP_07
#define TP_07 0
#define STEP_RATE 3
#endif

/*
 * TP_13: BOOT_DEV: Fix boot device error (see ST-Computer 1/90)
 */
#ifndef TP_13
#define TP_13 1
#endif

/*
 * TP_14: CT_HD: Boot function for c't "Billigloesung"
 */
#ifndef TP_14
#define TP_14 0
#endif

/*
 * TP_15: STACK_POINTER: Fix stack pointer in autoexec
 * Fixes a bug in the autoexec routine (see ST-Computer 1/90)
 */
#ifndef TP_15
#define TP_15 1
#endif

/*
 * TP_16: PILZE: Alternative image for bombs
 * Replaces the Atari bomb images with the original mushrooms
 * 0: Original bombs
 * 1: Mushrooms
 * 2: Atari logo
 * 3: Pfeifenkopf
 * 4: Stinkefinger
 * 5: Skull
 */
#ifndef TP_16
#define TP_16 0
#endif

/*
 * TP_17: LOCK_CLOCK: Lock Mega-ST clock
 *
 * Prevents the hardware clock from being set by TOS.
 * A separate program is then needed to update it.
 */
#ifndef TP_17
#define TP_17 0
#endif

/*
 * TP_18: IGNORE_BLITTER: Ignore the blitter
 *
 * The blitter will be disavowed and ignored by TOS
 * (e.g. for hardware speeder)
 */
#ifndef TP_18
#define TP_18 0
#endif

/*
 * TP_19: FASTPRN: Fast printer routines for the parallel port
 *
 * Output, Input- and wait functions will be replaced.
 * Corresponds to FASTPRN.PRG from Ecki from the c't magazine.
 */
#ifndef TP_19
#define TP_19 1
#endif

/*
 * TP_20: TIMEOUT: Set printer timeout
 *
 * Original value is 30 seconds. Minimum value is 5 seconds.
 * Does not work with the Atari Laser Printer.
 */
#ifndef TP_20
#define TP_20 1
#endif
#ifndef PRNTIMEOUT
#define PRNTIMEOUT 30
#endif

/*
 * TP_21: SET_CONTERM: Set conterm
 *
 * Bit 2 set: bell on CNTRL-G
 * Bit 1 set: key repeat on
 * Bit 0 set: key click on
 */
#ifndef TP_21
#define TP_21 0
#endif
#ifndef CONTERM
#define CONTERM 6
#endif

/*
 * TP_23: FASTLOAD: Set fastload-bit for floppy reads
 *
 * Produces errors with some drives, take care!
 * (see ST-Computer 1/90)
 */
#ifndef TP_23
#define TP_23 0
#endif

/*
 * TP_24: SKIP_B: Skip the search for drive B:
 *
 * This allows faster booting. Do not use that
 * when 2 drives are connected. The virtual drive
 * B: will still be present on the desktop.
 */
#ifndef TP_24
#define TP_24 0
#endif

/*
 * TP_26: KILL_BOOT: Prevent execution of floppy boot sector
 */
#ifndef TP_26
#define TP_26 0
#endif

/*
 * TP_27: NORM_BOOT: Normal boot
 *
 * Similar to above, but prevents execution of floppy bootsector
 * only if system was already booted from harddisk. This was
 * normal behaviour until TOS 1.4.
 */
#ifndef TP_27
#define TP_27 0
#endif

/*
 * TP_28: VDIFIX: New v_opnvwk() function
 *
 * Replace v_opnvwk() by a new function to fix a bug.
 * Same functionality as VDIFIX.PRG autofolder program.
 */
#ifndef TP_28
#define TP_28 1
#endif

/*
 * TP_29: M_SHRINK: Mshrink fix
 *
 * Fixes a bug in Mshrink that can destroy the memory lists
 */
#ifndef TP_29
#define TP_29 1
#endif

/*
 * TP_30: DRAW_BOXES: Turn off grow- and shrinkboxes
 */
#ifndef TP_30
#define TP_30 0
#endif

/*
 * TP_31: MS_DOS: Correct MS-DOS Format
 *
 * Writes $EB34904E into the first bytes of the boot sector
 * when formatting floppy discs
 */
#ifndef TP_31
#define TP_31 0
#endif

/*
 * TP_34: NEC_P6: Change printer line spacing
 *
 * Changes the line spacing for hardcopy. Enables use
 * of hardcopies for NEC-P6, as well as EPSON printers
 * (see ST-Computer 10/90)
 */
#ifndef TP_34
#define TP_34 0
#endif

/*
 * TP_36: INFO_TXT: Set custom info text
 *
 * This string will be displayed in place of the hyphens in the About dialog
 * (29 characters max., ASCII only)
 */
#ifndef TP_36
#define TP_36 "-----------------------------"
#endif

/*
 * TP_37: ICONS: Set custom desktop icons
 * TP_37_1: floppy
 * TP_37_2: folder
 * TP_37_3: trashcan
 * TP_37_4: program
 * TP_37_5: file
 *
 * These must set to a filename of an 32x32 monochrome ICO
 * (windows icon) file in the icons folder.
 * example: #define TP_37_1 "../tospatch/data/icons/floppy.ico"
 */

/*
 * TP_38: ICONS: Set custom mouse cursors
 * TP_38_0: Arrow
 * TP_38_1: Text cursor
 * TP_38_2: Busy bee
 * TP_38_3: Point hand
 * TP_38_4: Flat hand
 * TP_38_5: Thin cross
 * TP_38_6: Thick cross
 * TP_38_7: Outline cross
 *
 * These must set to a filename of an 16x16 monochrome CUR
 * (windows cursor) file in the mform folder.
 * example: #define TP_38_0 "../tospatch/data/mform/mform0.cur"
 */

/*
 * TP_39: MOUSE: Set custom alert icons
 * TP_39_1: Note icon
 * TP_39_2: Question icon
 * TP_39_3: Stop icon
 *
 * These must set to a filename of an 32x32 monochrome ICO
 * (windows icon) file in the icons folder.
 * example: #define TP_39_1 "../tospatch/data/icons/note.ico"
 */

/*
 * TP_43: HD_WAIT: Harddisk waiter
 *
 * 0: do not use
 * 1: Version 1
 *    Unknown routine that may only work with 1 harddisk.
 *    Can be aborted by pressing ALTERNATE.
 *    Only tested with Megafile
 * 2: Version 2
 *    Simple version that just waits for 12sec
 *    This should work in any case.
 *    Can be aborted by pressing any key.
 * 3: Version 3
 *    New version written by EWK, can wait for any ACSI device.
 *    Can be aborted by pressing Shift-Shift.
 *
 * TP_44: HD_WAITTIME: Waiting time in seconds
 * TP_45: HD_WAITDEVICE: Device to wait for,
 *        for version 3
 */
#ifndef HD_WAIT
#define HD_WAIT 0
#endif
#ifndef HD_WAITTIME
#define HD_WAITTIME 12
#endif
#ifndef HD_WAITDEVICE
#define HD_WAITDEVICE 0
#endif

/*
 * TP_64: IDE_BOOT: Try to boot from IDE first
 * Uses ide autoboot patch from czietz (https://github.com/czietz/ideboot)
 */
#ifndef TP_64
#define TP_64 0
#endif

/*
 * TP_69: TIME_SAVE: Read system time from keyboard processor,
 * if reading the RTC fails
 * (see ST-Computer 1/90)
 */
#ifndef TP_69
#define TP_69 0
#endif

/*
 * TP_70: RSCONF1: Fix rsconf bug
 * (from TOS14FIX.PRG, ST-Computer 1/90).
 * Only needed for 1.04; in 1.06 this has been fixed
 */
#ifndef TP_70
#define TP_70 1
#endif

/*
 * TP_71: RSCONF2: Do not send startbit when setting baudrate
 */
#ifndef TP_71
#define TP_71 1
#endif

/*
 * TP_72: POOLFIX: Make POOLFIX3 obsolete
 * Only needed for 1.04/1.06; in 1.62 this has been fixed
 */
#ifndef TP_72
#define TP_72 1
#endif

/*
 * TP_73: TOSFIX: Correct AES path (from TOS14FIX.PRG, ST computer 1/90).
 * Only needed for 1.04; in 1.06 this has been fixed
 */
#ifndef TP_73
#define TP_73 1
#endif

/*
 * TP_74: STE_FIX: Fix the desktop resolution change bug.
 * Only needed for 1.06; in 1.62 this has been fixed again.
 */
#ifndef TP_74
#define TP_74 1
#endif

/*
 * TP75: SPEEDER: The following patch prevents the effect that when using Hypercache,
 * Turbo 16 etc. with activated cache the floppy routines of the
 * TOS always generate a timeout if the motor is not yet running.
 * This effect should be particularly known to NEC 1037 (A) owners.
 * The patch only increases the timeout values, so it also runs
 * without hypercache etc. and / or NEC floppy ...
 * Now the delay can be set instead of $ 40000 / $ 60000 as the default
 * gain weight. Simply set .SPEED towards the MAXIMUM relative acceleration
 * of a normal ST (8 MHz), e.g. .SPEED = 2 for 16MHz accelerator.
 * Only relevant for 1.04; in 1.06 the hz_200 timer is used.
 */
#ifndef TP_75
#define TP_75 0
#define SPEED 2    /* Enter the maximum acceleration factor here */
#endif

/*
 * TP_76: ALARM: ST-Computer 10/90
 * The mega clock no longer adjusts the alarm register.
 *
 * Warning: Does _NOT_ work with the c't clock patch!
 */
#ifndef TP_76
#define TP_76 0
#endif

/*
 * TP_77: CT_CLOCK: Integration of the c't clock in TOS. You can then use the clock directly with the XBIOS
 * (also with the GEMDOS of course ...)
 * Patch by Stefan Toennes
 *
 * >>> Warning: Does _NOT_ work with the other clock patches!
 */
#ifndef TP_77
#define TP_77 0
#endif

/*
 * TP_78: CORRECT_DAY:
 * Settime() calculates the day of the week and correctly sets it in the mega-clock.
 * Atari always set the weekday to Sunday. 
 *
 * >>> Warning: Does _NOT_ work with the c't clock patch!
 */
#ifndef TP_78
#define TP_78 0
#endif

/*
 * TP_79: HC_960:
 * 960 dpi hard copy by default.
 */
#ifndef TP_79
#define TP_79 0
#endif

/*
 * TP_80: CHANGE_BAUD:
 * Baud rates 120 or 80, instead of 75 and 50.
 */
#ifndef TP_80
#define TP_80 0
#endif

/*
 * TP_81: OVERSCANFIX:
 * Karsten Isakovic (implementiert durch MRF):
 * Patch, which now also allows screen widths that are not divisible by 16.
 * Otherwise there is garbage when scrolling ... Necessary for overscan. 
 */
#ifndef TP_81
#define TP_81 0
#endif

/*
 * TP_82: NEW_SZ:
 * Convert û to IBM-·. Damit wird kein Pesata, sondern ein Beta-"·"
 * ausgegeben. Dies sieht nun mal auf den meisten Nadeldruckern besser aus.
 * Dies wirkt natÅrlich nur bei Texten, welche mit dem gepachten TOS eingegeben
 * werden. In den alten steht ja noch das û drin.
 *
 * HUCKY: Makes problems with script ... Therefore as a comment.
 */
#ifndef TP_82
#define TP_82 0
#endif
