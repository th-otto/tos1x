/*
 * Defaults which patches should be applied.
 *
 * You can either edit the settings below, or
 * (better) create a file common/localcnf.h instead
 * with your preferred settings
 */
 
/*
 * TP_05: SHELL_P: Clear _shell_p
 * Clear the _shell_p system variable on reset.
 */
#ifndef TP_05
#define TP_05 1
#endif

/*
 * TP_13: BOOT_DEV: Fix boot device error (see ST-Computer 1/90)
 */
#ifndef TP_13
#define TP_13 1
#endif

/*
 * TP_15: STACK_POINTER: Fix stack pointer in autoexec
 * Fixes a bug in the autoexec routine (see ST-Computer 1/90)
 */
#ifndef TP_15
#define TP_15 1
#endif

/*
 * TP_64: IDE_BOOT: Try to boot from IDE first
 * Uses ide autoboot patch from czietz (https://github.com/czietz/ideboot)
 */
#ifndef TP_64
#define TP_64 0
#endif

/*
 * TP_69: TIME_SAVE: Read system time from keyboard processor
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
#define TP_70 0
#endif

/*
 * TP_71: RSCONF2: Do not send startbit when setting baudrate
 */
#ifndef TP_71
#define TP_71 0
#endif
