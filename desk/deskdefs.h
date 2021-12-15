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
#define NUM_WOBS 255
/*
 * number of reserved items
 */
#define NUM_ROBS 1
/*
 * total number of items in various arrays
 */
#define NUM_SOBS (NUM_ROBS + NUM_WOBS + NUM_WNODES)

