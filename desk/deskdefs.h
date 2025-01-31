#define PATHLEN		128
#define NAMELEN     14

/*
 * number of windows desktop can handle
 */
#define	NUM_WNODES		4

#ifndef BINEXACT
#define BINEXACT 1
#endif

#define NUM_FNODES 400
#define NUM_PNODES (NUM_WNODES + 1)

/*
 * number of items in a folder window
 */
#if TOSVERSION >= 0x104
#define NUM_WOBS 254
#else
#define NUM_WOBS 127
#endif

/*
 * number of reserved items
 */
#define NUM_ROBS 2
/*
 * total number of items in various arrays
 */
#define NUM_SOBS (NUM_ROBS + NUM_WOBS + NUM_WNODES)

/*
 * US version seems to have used slightly older version of showfile()
 */
#define OLD_SFCODE (OS_COUNTRY == CTRY_US)
