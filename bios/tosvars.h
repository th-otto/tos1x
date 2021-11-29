/*
 * tosvars.h - name of low-memory variables
 *
 * Copyright (C) 2001-2016 The EmuTOS development team
 *
 * Authors:
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

/*
 * Put in this file only the low-mem vars actually used by
 * C code.
 */

#ifndef TOSVARS_H
#define TOSVARS_H

extern int32_t proc_lives;
extern int32_t proc_dregs[];
extern int32_t proc_aregs[];
extern int32_t proc_enum;
extern int32_t proc_usp;
extern int16_t proc_stk[];

extern int32_t memvalid;
extern int32_t memval2;
extern int32_t memval3;
extern int8_t conterm;

extern int16_t cmdload;

extern VOIDPTR v_bas_ad;

extern int16_t *colorptr;
extern VOIDPTR screenpt;
extern int8_t sshiftmod;
extern int8_t defshiftmod;

extern uint8_t *phystop;

extern int16_t timer_ms;

extern volatile int32_t hz_200;
extern VOIDPTR dskbufp;
extern volatile int16_t flock;
extern int16_t nflops;
extern int32_t drvbits;
extern int16_t bootdev;
extern int16_t fverify;
extern int16_t seekrate;
extern volatile int16_t dumpflg; /* may be set by keyboard interrupt handler Alt-Help */
extern int16_t nvbls;
extern volatile int16_t vblsem;
extern int32_t vbl_list[];
extern int32_t *vblqueue;
extern volatile int32_t frclock;
extern int32_t *p_cookies;
extern int16_t save_row;     /* saved row in escape Y command */


extern int32_t sysbase;
extern VOID os_entry PROTO((NOTHING)) __NORETURN;
extern int32_t os_beg;
extern int32_t os_date;
extern uint16_t os_dosdate;
extern int16_t os_conf;
extern VOID (*exec_os) PROTO((NOTHING)) __NORETURN;
extern uint8_t *end_os;

extern uint8_t *membot;
extern uint8_t *memtop;

#define FASTRAM_START ((uint8_t *)0x01000000)
extern uint8_t *ramtop;     /* top of fastram */
#define RAMVALID_MAGIC 0x1357BD13
extern int32_t ramvalid;     /* indicates if fastram is present */

extern int32_t os_magic;     /* if == 0x87654321, means that GEM is present */

extern int32_t savptr;

extern int16_t (*prt_stat) PROTO((NOTHING));
extern int16_t (*prt_vec) PROTO((int16_t, int16_t));
extern VOID (*aux_stat) PROTO((NOTHING));
extern VOID (*aux_vec) PROTO((int16_t, int16_t));
extern VOID (*scr_dmp) PROTO((NOTHING));

/* indirect BIOS vectors */

extern int32_t (*bconstat_vec[]) PROTO((NOTHING));
extern int32_t (*bconin_vec[]) PROTO((NOTHING));
extern int32_t (*bconout_vec[]) PROTO((int16_t, int16_t));
extern int32_t (*bcostat_vec[]) PROTO((NOTHING));

extern int32_t (*hdv_rw) PROTO((int16_t rw, VOIDPTR buf, int16_t cnt, int16_t recnr, int16_t dev, int32_t lrecnr));
extern int32_t (*hdv_bpb) PROTO((int16_t dev));
extern int32_t (*hdv_mediach) PROTO((int16_t dev));
extern int32_t (*hdv_boot) PROTO((NOTHING));
extern VOID (*hdv_init) PROTO((NOTHING));

extern VOID (*bell_hook) PROTO((NOTHING));
extern VOID (*kcl_hook) PROTO((NOTHING));

extern VOID (*etv_timer) PROTO((int16_t ms));
extern int32_t (*etv_critic) PROTO((int16_t err, int16_t dev));
extern VOID (*etv_term) PROTO((NOTHING));

#if 0
/*
 * only for reference: functions can't be called directly from C,
 * nor can they point to C routines
 */
struct kbdvecs
{
    VOIDPTR kbdvec;      /* Keyboard Input */
    VOIDPTR midivec;     /* MIDI Input */
    VOIDPTR vkbderr;     /* IKBD Error */
    VOIDPTR vmiderr;     /* MIDI Error */
    VOIDPTR statvec;     /* IKBD Status */
    VOIDPTR mousevec;    /* IKBD Mouse */
    VOIDPTR clockvec;    /* IKBD Clock */
    VOIDPTR joyvec;      /* IKBD Joystick */
    VOIDPTR midisys;     /* Main MIDI Vector */
    VOIDPTR ikbdsys;     /* Main IKBD Vector */
};
extern struct kbdvecs kbdvecs;
#endif

#endif /* TOSVARS_H */
