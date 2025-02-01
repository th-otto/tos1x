/*
 * Must include the specific resource header file;
 * the layout is actually different.
 * We can use the same header files for 1.04, 1.06 & 1.62, though.
 */
#if (TOSVERSION == 0x104) | (TOSVERSION == 0x106) | (TOSVERSION == 0x162)
#if OS_COUNTRY == CTRY_US
#include "../desk/rsc/104/deskus.h"
#endif
#if OS_COUNTRY == CTRY_UK
#include "../desk/rsc/104/deskuk.h"
#endif
#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG)
#include "../desk/rsc/104/deskde.h"
#endif
#if (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_SF)
#include "../desk/rsc/104/deskfr.h"
#endif
#if OS_COUNTRY == CTRY_ES
#include "../desk/rsc/104/deskes.h"
#endif
#if OS_COUNTRY == CTRY_IT
#include "../desk/rsc/104/deskit.h"
#endif
#if OS_COUNTRY == CTRY_SE
#include "../desk/rsc/104/deskse.h"
#endif
#if OS_COUNTRY == CTRY_TR
#include "../desk/rsc/104/desktr.h"
#endif
#if OS_COUNTRY == CTRY_FI
#include "../desk/rsc/104/deskfi.h"
#endif
#if OS_COUNTRY == CTRY_NO
#include "../desk/rsc/104/deskno.h"
#endif
#if OS_COUNTRY == CTRY_DK
#include "../desk/rsc/104/deskdk.h"
#endif
#if OS_COUNTRY == CTRY_NL
#include "../desk/rsc/104/desknl.h"
#endif
#if OS_COUNTRY == CTRY_PL
#include "../desk/rsc/104/deskpl.h"
#endif
#if (OS_COUNTRY == CTRY_CZ)
#include "../desk/rsc/104/deskcz.h"
#endif
#endif /* TOSVERSION == 0x104 */

#if (TOSVERSION == 0x100)
/*
 * We can use the same header file for all languages.
 */
#include "../desk/rsc/100/deskus.h"

/*
 * icons, supposed to be in the resource file,
 * but loaded separately
 */
#define IDISK     0
#define IDIR      1
#define ITRASHCAN 2
#define IPRG      3
#define IFILE     4

#endif /* TOSVERSION == 0x100 */
