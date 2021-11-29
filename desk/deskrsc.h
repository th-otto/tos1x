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
#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG) | (OS_COUNTRY == CTRY_CZ)
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
#if OS_COUNTRY == CTRY_PL
#include "../desk/rsc/104/deskpl.h"
#endif
#endif /* TOSVERSION == 0x104 */


extern char const More[];
extern char const Endfile[];
extern char const Cart[]; /* unused; taken from desktop.inf instead */
extern char const Cpystr[];
extern char const Delstr[];
extern char const Fileinfo[];
extern char const Foldinfo[];
extern char const Movestr[];
extern char const Readerror[];
extern char const Cantopen[];
extern char const Nomem[];
extern char const Cachetxt[];
extern char const Blttxt[];
extern char const Nconflict[];
extern char const Rname[];
extern char const Crenstr[];
extern char const Mrenstr[];
extern char const Istr[];
extern char const Isels[];
extern char const Isel[];
extern char const Istrs[];
extern char const Device[];
extern char const Sinf[];
extern char const Litem[];
