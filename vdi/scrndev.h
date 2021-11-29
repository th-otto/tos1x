/*
 ********************************  scrndev.h  **********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/31 12:04:31 $
 * =============================================================================
 *
 *******************************************************************************
 */

#ifndef _SCRNDEV_H_
#define _SCRNDEV_H_

#include "fontdef.h"

typedef struct screendef {
    const char *name;               /* device identification (name)          */
    int16_t     devId;              /* device id number                      */
    int16_t     planes;             /* # of planes (bits per pixel)          */
    int16_t     lineWrap;           /* # of bytes from 1 scan to next        */
    int16_t     xRez;               /* current horizontal resolution         */
    int16_t     yRez;               /* current vertical resolution           */
    int16_t     xSize;              /* width of one pixel in microns         */
    int16_t     ySize;              /* height of one pixel in microns        */
    int16_t     formId;             /* scrn form LITERLEAVED, PIXPACKED ...  */
    FONT_HEAD *fntPtr;              /* points to the default font            */
    int16_t     maxPen;             /* # of pens available                   */
    int16_t     colFlag;            /* color capability flag                 */
    int16_t     palSize;            /* palette size (0 = contiguous)         */
    int16_t     lookupTable;        /* lookup table supported                */
    VOID (**softRoutines) PROTO((NOTHING)); /* drawing primitives done in software   */
    VOID (**hardRoutines) PROTO((NOTHING)); /* hardware assisted drawing primitives  */
    VOID (**curRoutines) PROTO((NOTHING));  /* current routines being used           */
    char        *vidAdr;            /* video base address                    */
} SCREENDEF;


#define V_CELL          0           /* VT52 cell output routines            */
#define V_SCRUP         1           /* VT52 screen up routine               */
#define V_SCRDN         2           /* VT52 screen down routine             */
#define V_BLANK         3           /* VT52 screen blank routine            */
#define V_BLAST         4           /* blit routines                        */
#define V_MONO          5           /* monospace font blit routines         */
#define V_RECT          6           /* rectangle draw routines              */
#define V_VLINE         7           /* vertical line draw routines          */
#define V_HLINE         8           /* horizontal line draw routines        */
#define V_TEXT          9           /* text blit routines                   */
#if TOSVERSION >= 0x400
#define V_VQCOLOR       10          /* color inquire routines               */
#define V_VSCOLOR       11          /* color set routines                   */
#define V_INIT          12          /* init routine called upon openwk      */
#define V_SHOWCUR       13          /* display cursor                       */
#define V_HIDECUR       14          /* replace cursor with old background   */
#define V_NEGCELL       15          /* negate alpha cursor                  */
#define V_MOVEACUR      16          /* move alpha cur to new X,Y (D0, D1)   */
#define V_ABLINE        17          /* arbitrary line routine               */
#define V_HABLINE       18          /* horizontal line routine setup        */
#define V_RECTFILL      19          /* routine to do rectangle fill         */
#define V_PUTPIX        20          /* output pixel value to the screen     */
#define V_GETPIX        21          /* get pixel value at (X,Y) of screen   */
#endif

#define DEVICEDEP       0           /* means we're in device dep mode       */
#define STANDARD        1           /* flag for standard format             */
#define INTERLEAVED     2           /* flag for interleaved planes          */
#define PIXPACKED       3           /* flag for pixel packed                */

#endif
