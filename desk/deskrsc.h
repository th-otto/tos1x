/*
 * Must include the specific resource header file;
 * the layout is actually different.
 * We can use the same header files for 1.04, 1.06 & 1.62, though.
 */
#if (TOSVERSION == 0x104) | (TOSVERSION == 0x106) | (TOSVERSION == 0x162)
#if OS_COUNTRY == CTRY_US
#include "../desk/rsc/104/deskus.h"
#include "../desk/rsc/104/strus.h"
#endif
#if OS_COUNTRY == CTRY_UK
#include "../desk/rsc/104/deskuk.h"
#include "../desk/rsc/104/strus.h"
#endif
#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG)
#include "../desk/rsc/104/deskde.h"
#include "../desk/rsc/104/strde.h"
#endif
#if (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_SF)
#include "../desk/rsc/104/deskfr.h"
#include "../desk/rsc/104/strfr.h"
#endif
#if OS_COUNTRY == CTRY_ES
#include "../desk/rsc/104/deskes.h"
#include "../desk/rsc/104/stres.h"
#endif
#if OS_COUNTRY == CTRY_IT
#include "../desk/rsc/104/deskit.h"
#include "../desk/rsc/104/strit.h"
#endif
#if OS_COUNTRY == CTRY_SE
#include "../desk/rsc/104/deskse.h"
#include "../desk/rsc/104/strse.h"
#endif
#if OS_COUNTRY == CTRY_TR
#include "../desk/rsc/104/desktr.h"
#include "../desk/rsc/104/strtr.h"
#endif
#if OS_COUNTRY == CTRY_FI
#include "../desk/rsc/104/deskfi.h"
#include "../desk/rsc/104/strfi.h"
#endif
#if OS_COUNTRY == CTRY_NO
#include "../desk/rsc/104/deskno.h"
#include "../desk/rsc/104/strno.h"
#endif
#if OS_COUNTRY == CTRY_DK
#include "../desk/rsc/104/deskdk.h"
#include "../desk/rsc/104/strdk.h"
#endif
#if OS_COUNTRY == CTRY_PL
#include "../desk/rsc/104/deskpl.h"
#include "../desk/rsc/104/strpl.h"
#endif
#if (OS_COUNTRY == CTRY_CZ)
#include "../desk/rsc/104/deskcz.h"
#include "../desk/rsc/104/strcz.h"
#endif
#endif /* TOSVERSION == 0x104 */
