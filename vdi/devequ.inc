/*
 *********************************  devequ.s  **********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/31 12:04:31 $
 * =============================================================================
 *
 *******************************************************************************
 */

/*
 * Offsets into SCREENDEF structure
 */
/* device description string */
#define DEVNAME			0
/* device id number */
#define DEVID			4
/* # of planes (bits per pixel) */
#define DEVPLANES		6
/* # of bytes from 1 scan to next */
#define DEVLINEWRAP		8
/* current horizontal resolution */
#define DEVXREZ			10
/* current vertical resolution */
#define DEVYREZ			12
/* width of one pixel in microns */
#define DEVXSIZE		14
/* height of one pixel in microns */
#define DEVYSIZE		16
/* scrn form 0 ST, 1 stndrd, 2 pix */
#define DEVFORMID		18
/* points to the default font */
#define DEVFNTPTR		20
/* # of pens available */
#define DEVMAXPEN		24
/* color cpability flag */
#define DEVCOLFLAG		26
/* palette size (0  contiguous) */
#define DEVPALSIZE		28
/* lookup table supported flag */
#define DEVLOOKUPTABLE		30
/* drawing primitives done in sofwr */
#define DEVSOFTROUTINES 	32
/* hardware assisted drawing primitives */
#define DEVHARDROUTINES		36
/* current routines being used */
#define DEVCURROUTINES		40
/* video base adr for dev (can be NULL) */
#define DEVVIDADR		44

/* VT52 cell output routines */
#define V_CELL			0
/* VT52 screen up routine */
#define V_SCRUP			4
/* VT52 screen down routine */
#define V_SCRDN			8
/* VT52 screen blank routine */
#define V_BLANK			12
/* blit routines */
#define V_BLAST			16
/* monospace font blit routines */
#define V_MONO			20
/* rectangle draw routines */
#define V_RECT			24
/* vertical line draw routines */
#define V_VLINE			28
/* horizontal line draw routines */
#define V_HLINE			32
/* text blit routines */
#define V_TEXT			36


/* means we're in device dep mode */
#define DEVICEDEP		0
/* flag for standard format */
#define STANDARD		1
/* flag for interlieved planes */
#define INTERLEAVED		2
/* flag for pixel packed */
#define PIXPACKED		3
