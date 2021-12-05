/* direct imports from AES: */
#undef MFORM
#include "../aes/struct88.h"
#undef MFORM

extern PD *rlr; /* WTF */

#if AESVERSION >= 0x330
/* import from AES :( */
extern BOOLEAN do_once;
#endif


VOID dsptch PROTO((NOTHING));
VOID wm_new PROTO((NOTHING));
int16_t ap_init PROTO((intptr_t pglobal));
int16_t ap_exit PROTO((NOTHING));
int16_t fs_input PROTO((char *path, char *selec, int16_t *button, const char *label));
VOID rs_sglobe PROTO((intptr_t pglobal));
int16_t rs_load PROTO((intptr_t pglobal, const char *name));
int16_t rs_free PROTO((intptr_t pglobal));
int16_t rs_obfix PROTO((LPTREE tree, int16_t obj));
int16_t mn_popup PROTO((int16_t pid, MENU *menu, int16_t x, int16_t y, MENU *mdata));
int16_t mn_istart PROTO((int16_t pid, int16_t code, OBJECT *mtree, int16_t mmenu, int16_t start));
VOID ob_gclip PROTO((LPTREE tree, int16_t which, int16_t *x, int16_t *y, int16_t *rx, int16_t *ry, int16_t *w, int16_t *h));
VOID gr_mouse PROTO((int16_t style, MFORM *grmaddr));
