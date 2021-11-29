/*      DESKSTOR.C              6/12/89 - 6/13/89       Derek Mui       */
/*      Take out some variable  6/28/89 - 9/13/89       D.Mui           */
/*      Take out strXXX.h       7/7/92                  D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"

char dr[32];							/* drives flag          */
BOOLEAN p_timedate;						/* preserve time and date   */
int16_t d_nrows;						/* number of rows used by show  */
int16_t d_level;						/* window path level        */
char *d_path;							/* window path buffer       */
int16_t pxyarray[10];					/* input point array        */ /* unused */
int16_t d_xywh[18];						/* disk icon pline points   */
int16_t f_xywh[18];						/* file icon pline points   */
OBJECT *background;						/* desktop object address   */
int16_t maxicon;						/* max number of desktop icons  */
BOOLEAN i_status;						/* current status TURE or FALSE */ /* unused */
intptr_t gh_buffer;						/* ghost icon outline buffer address */
IDTYPE *backid;							/* background icon type definition  */
DTA dtabuf;								/* dta buffer   */

/*
 * Variables for the desktop.inf file
 */
uint16_t windspec;						/* window pattern   */

/************************************************/

char path1[PATHLEN];					/* utility path     */
char path2[PATHLEN];
char *path3;
char inf_path[PATHLEN];					/* store the inf path   */
char comtail[PATHLEN];					/* comtail tail buffer */
DESKWIN *winhead;						/* head of window list      */
GRECT fobj;								/* file object  */
char const getall[] = "*.*";
char const bckslsh[] = "\\";
char const curall[] = ".\\*.*";
char const baklvl[] = ".\\..";
char const wildext[] = "A:\\*.*";
char const wilds[] = "\\*.*";
char const noext[] = "*.";
char const Nostr[] = "";
char const infdata[] = "DESKTOP.INF";
char const infpath[] = "C:\\DESKTOP.INF";
char const Nextline[] = "\012\015";
