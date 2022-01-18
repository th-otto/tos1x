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
