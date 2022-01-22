TIMEFIX v1.3
 - fixes GEMDOS time/date globals and IKBD (for TOS 1.04)

Copyright (c) 2020, RP Instruments
Author: Arpad Beszedes (contact: arpadbeszedes_at_yahoo.com)
Distributed under the MIT License, see LICENSE.TXT for details.

*** Version history ***
   1.0: Etv patch, uninstall option
   1.1: GEMDOS time setting intercept
   1.2: New GEMDOS functions: $816, $817, $818
   1.3: Fix to IKBD

*** Overview ***
Welcome to TIMEFIX! This software features several fixes to the
(rather confusing) real-time clock functionality in ATARI TOS.
Note, that this is a patch for TOS version 1.04, and it will work
only with that! Attempt to use it in other versions will result
in bombs (the demonstration executable TFIXDEMO.PRG is safe to
use with any TOS version as it checks for TIMEFIX installation).

Features (for details, see the corresponding sections below):
- implements a new Y2K compatible internal clock with 1 sec
accuracy, leap year handling, 256 years warranty and day of
the week feature
- adds new GEMDOS functions to read and set internal clock
- fixes years to be Y2K compatible in the XBIOS-based time
functions for IKBD
- fixes the Steinberg CUBASE (TM) bug that prevents the correct
time keeping in GEMDOS while running

Files:

API\RPTIME.H
 - C include header files with prototypes of extended GEMDOS functions

API\RPI.LIB
 - static library with standard function call arguments to access
extended GEMDOS functions from C

DEMO\TFIXDEMO.C
 - C source code of TIMEFIX demonstration program and date/time
setting utility

DEMO\RPTIME.H
 - copy of API\RPTIME.H

DEMO\RPI.LIB
 - copy of API\RPI.LIB

DEMO\TFIXDEMO.LNK
 - HiSoft Lattice C (TM) linker file for building the
demonstration program
 
DEMO\TFIXDEMO.PRG
 - Executable TIMEFIX demonstration program and date/time
setting utility

TFIXUNIN.PRG
 - TIMEFIX uninstallation tool

TIMEFIX.PRG
 - TIMEFIX resident program (to be copied to AUTO folder)
 
LICENSE.TXT
 - License and distribution terms
 
README.TXT
 - This file

*** Installation and uninstallation ***
TIMEFIX is a resident program that intercepts several GEMDOS and
XBIOS trap calls, hence it should be installed by putting the file
TIMEFIX.PRG into the AUTO folder. It uses about 1.4KB when installed.
Upon startup, TIMEFIX will initialize its internal date and time
variables from GEMDOS, and this will be used to adjust the IKBD clock
as well.

To uninstall the software, execute TFIXUNIN.PRG (note, that this will
only restore the original system vectors but the resident RAM area
will not be freed).

*** New internal clock ***
The basic operation of TIMEFIX is the following. It hooks up to the
TOS system timer vector (etv) daisy chain, which is invoked 50
times per second. It then maintains a similar internal clock to
the basic GEMDOS clock, but it adds the following features:
- 1-byte span for the years which is Y2K compatible, and starts
from 1980 (highest year is thus 2235). GEMDOS uses values 0-119.
- 1 second resoluation instead of 2-seconds of GEMDOS
- Correct leap year handling
- Day of the week feature (accessible via the API)

On every tick, it will update the internal clock and after each second
TIMEFIX updates the GEMDOS internal date/time variables.

*** New GEMDOS functions and API ***
The following new GEMDOS functions are available through standard
GEMDOS Trap #1 calls (parameters are passed on stack and the
return value is in D0). C function prototypes and the static linkable
library are available in the folder API. Correct working of these
are checked using HiSoft assembly and C development tools.

1. Rsettime

Description: sets date and time in the internal clock by
copying the data in the parameters to the internal structure.

Opcode: $816

C syntax: 
void Rsettime(RPT* rpt);

The parameter 'rpi' is a pointer to a 6-byte data structure that
holds the date and time information in the following order and
data ranges:

typedef struct {
	unsigned char year;   /* 0-255, 0 means 1980 */
	unsigned char month;  /* 1-12 */
	unsigned char day;    /* 1-[28,29,30,31] depending on month */
	unsigned char hour;   /* 0-24 */
	unsigned char min;    /* 0-59 */
	unsigned char sec;    /* 0-59 */
} RPT;

Return value: none
 
Assember binding:
	move.l	rpt,-(sp)	; Offset 2
	move.w	#$816,-(sp)	; Offset 0
	trap	#1		; GEMDOS
	addq.l	#6,sp		; Correct stack

2. Rgettime

Description: returns the pointer to the internal clock structure.

Opcode: $817

C syntax: 
RPT* Rgettime();

Return value: address of the data structure according to the above.

Assember binding:
	move.w	#$817,-(sp)	; Offset 0
	trap	#1		; GEMDOS
	addq.l	#2,sp		; Correct stack

3. Rdayweek

Description: returns the correct day of the week according to
the internal clock structure.

Opcode: $818

C syntax: 
short Rdayweek();

Return value: 0-6 where 0 means Sunday

Assember binding:
	move.w	#$818,-(sp)	; Offset 0
	trap	#1		; GEMDOS
	addq.l	#2,sp		; Correct stack

In addition, the C API implements function Rcheck to check for
the installation of TIMEFIX.

C syntax: 
int Rcheck();

Return value: 0 if TIMEFIX is installed

Do not attempt calling any of the above functions before checking
Rcheck first!

If you want to perform a similar check from assembly, the following
simple code will do the job:

patc	equ	$1814		; Etv patch address
rpit	dc.b	'RPIT'		; Magic string
	move.l	(patc).l,a0	; Get Etv function in the daisy chain
	move.l	-8(a0),d0	; Magic string is right before the entry
	sub.l	(rpit).l,d0	; if result is 0, TIMEFIX is installed

*** Fixes to IKBD clock ***
The IKBD clock can (in theory) maintain the real time clock with 1 second
accuracy and using the year field in two BCD digits (ie. 00-99).
This is independent of the GEMDOS real time clock.
The XBIOS functions Settime (opcode 22) and Gettime (opcode 23) are
designed to write and read date and time information from the IKBD using
the standard TOS date and time format. However, these functions are not
Y2K compatible, and any year passed other than 0-19 (1980-1999) will result
in a corrupted year.

TIMEFIX intercepts XBIOS calls to these functions and adjusts the input
paremeter and result if possible. In particular:
- if the input year is between 1980-1999 it will be passed unchanged
- if the input year is between 2000-2047 it will be adjusted to cancel
the effect of the bug, and also the result will be corrected.
Note, that this way, only the values between 00-47 and 80-99 will be
used in the IKBD, the remaining values are not available (OK, if you
are reading this before 2048 and leave your computer on, it will
keep the correct year until 2079 :-)

*** Steinberg CUBASE fix ***
All Steinberg CUBASE (TM) versions for Atari (such as 1, 2 and 3)
include the following bug. To maintain the internal timing, Cubase low
level system (the MROS) uses the 50Hz TOS system timer vector.
However, due to a bug in the installed timer handoff vector, it will
not pass correctly the timer tick value on the stack. The result is
that it will mess up the standard GEMDOS internal date and time variables.
It will appear if the time is passing about 12x faster, and this means that
no real time clocks can be used (such as using LEDPANEL), and the timestamps
of created files will be incorrect while CUBASE is running.

TIMEFIX maintains its own internal clock, which overwrites the values
of GEMDOS internal variable every second, hence fixes their corrupted
values.

*** Demonstration program and date/time setting utility *** 
Folder DEMO contains a small program which demonstrates the functions
of TIMEFIX. TFIXDEMO.PRG shows the current times in real time of
GEMDOS, IKBD and TIMEFIX internal clock along with day of the week
(if installed). The program can also be used to set the correct time
and date information in all clocks available simultaneously.

The usage is straightforward: Esc can be used to exit the program,
and 'd' and 't' must be pressed to access the date and time setting
features, respectively. If no value (or incorrect one) is given, the
current value will be used. To cancel the setting operation, press
Esc after entering the values. 

The utility program is compileable using HiSoft Lattice C 5.
For convenience, the Lattice linker command file is supplied.

Note, that this utility can be used on any TOS version, not only 1.04.
Of course, in this case, TIMEFIX features will not be available.

Enjoy!

*** End of file. Date: 2020.12.26 16:30 ***
