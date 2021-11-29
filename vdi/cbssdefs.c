/*
*******************************  cbssdefs.c  **********************************
*
*
* =============================================================================
* $Author: lozben $	$Date: 91/07/29 11:44:43 $
* =============================================================================
*
* Revision 3.1  91/07/29  11:44:43  lozben
* Declared vdivars structure and a pointer to it and another pointer
* that point to one of the structures elements.
* 
* Revision 3.0  91/01/03  15:06:26  lozben
* New generation VDI
* 
* Revision 2.1  89/02/21  17:18:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
*/

#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"

/*
 * Storage declarations for C structures
 */
ATTRIBUTE virt_work;			/* attribute areas for workstations */
#if !LINEA_HACK
VDIVARS	vdivars;
#endif
#if TOSVERSION >= 0x400
int16_t *lineAVars = &vdivars.v_planes; /* accessed by asm code only */
VDIVARS	*la = &vdivars; /* accessed by C code only */
#endif
