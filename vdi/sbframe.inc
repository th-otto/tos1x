/*       FRAME PARAMETERS */

#ifndef FRAME_LEN

#define FRAME_LEN 76

B_WD		equ	-76	/* width of block in pixels */
B_HT		equ	-74	/* height of block in pixels */

PLANE_CT	equ	-72	/* number of consequitive planes to blt */

FG_COL		equ	-70	/* foreground color (logic op tab index:hi bit) */
BG_COL		equ	-68	/* background color (logic op tab index:lo bit) */
OP_TAB		equ	-66	/* logic ops for all fore and background combos */

S_XMIN		equ	-62	/* minimum X: source */
S_YMIN		equ	-60	/* minimum Y: source */
S_FORM		equ	-58	/* source form base address */
S_NXWD		equ	-54	/* offset to next word in line  (in bytes) */
S_NXLN		equ	-52	/* offset to next line in plane (in bytes) */
S_NXPL		equ	-50	/* offset to next plane from start of this plane */

D_XMIN		equ	-48	/* minimum X: destination */
D_YMIN		equ	-46	/* minimum Y: destination */
D_FORM		equ	-44	/* destination form base address */
D_NXWD		equ	-40	/* offset to next word in line  (in bytes) */
D_NXLN		equ	-38	/* offset to next line in plane (in bytes) */
D_NXPL		equ	-36	/* offset to next plane from start of this plane */

P_ADDR		equ	-34	/* address of pattern buffer   (0:no pattern) */
P_NXLN		equ	-30	/* offset to next line in pattern  (in bytes) */
P_NXPL		equ	-28	/* offset to next plane in pattern (in bytes) */
P_MASK		equ	-26	/* pattern index mask */

/***					    ***
 ***   these parameters are internally set  ***
 ***					    ***/

P_INDX		equ	-24	/* initial pattern index */

S_ADDR		equ	-22	/* initial source address */
S_XMAX		equ	-18	/* maximum X: source */
S_YMAX		equ	-16	/* maximum Y: source */

D_ADDR		equ	-14	/* initial destination address */
D_XMAX		equ	-10	/* maximum X: destination */
D_YMAX		equ	-8	/* maximum Y: destination */

INNER_CT	equ	-6	/* blt inner loop initial count */
DST_WR		equ	-4	/* destination form wrap (in bytes) */
SRC_WR		equ	-2	/* source form wrap (in bytes) */

#endif
