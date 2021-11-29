#include "desktop.h"

#define NEED_STRINGS

#if OS_COUNTRY == CTRY_US
#include "rsc/104/strus.h"
#endif

#if OS_COUNTRY == CTRY_UK
#include "rsc/104/strus.h"
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG)
#include "rsc/104/strde.h"
#endif

#if (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_SF)
#include "rsc/104/strfr.h"
#endif

#if OS_COUNTRY == CTRY_ES
#include "rsc/104/stres.h"
#endif

#if OS_COUNTRY == CTRY_IT
#include "rsc/104/strit.h"
#endif

#if OS_COUNTRY == CTRY_SE
#include "rsc/104/strse.h"
#endif

#if OS_COUNTRY == CTRY_TR
#include "rsc/104/strtr.h"
#endif

#if OS_COUNTRY == CTRY_FI
#include "rsc/104/strfi.h"
#endif

#if OS_COUNTRY == CTRY_NO
#include "rsc/104/strno.h"
#endif

#if OS_COUNTRY == CTRY_DK
#include "rsc/104/strdk.h"
#endif

#if OS_COUNTRY == CTRY_PL
#include "rsc/104/strpl.h"
#endif

#if OS_COUNTRY == CTRY_CZ
#include "rsc/104/strcz.h"
#endif
