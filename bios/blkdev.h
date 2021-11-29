#include "bpb.h"

#define GEOMETRY struct _geometry
GEOMETRY        /* disk parameter block */
{
	int16_t tracks;		/* number of tracks */
    int16_t sides;      /* number of sides */
    int16_t spc;		/* number of sectors per "cylinder" */
    int16_t spt;        /* number of sectors per track */
    int16_t hidden;     /* number of hidden/reserved sectors */
};

/*
 * beware: although an internal BIOS structure,
 * it is also used by the DESKTOP
 */
#define BLKDEV struct _blkdev
BLKDEV {
	BPB bpb;
    GEOMETRY geometry;
    uint8_t serial[3];
#if TOSVERSION >= 0x200
    uint8_t serial2[4];
#endif
};

/* Extended FAT12/FAT16 bootsector */
struct fat16_bs {
  /*   0 */  uint8_t bra[2];
  /*   2 */  uint8_t loader[6];
  /*   8 */  uint8_t serial[3];
  /*   b */  uint8_t bps[2];    /* bytes per sector */
  /*   d */  uint8_t spc;       /* sectors per cluster */
  /*   e */  uint8_t res[2];    /* number of reserved sectors */
  /*  10 */  uint8_t fat;       /* number of FATs */
  /*  11 */  uint8_t dir[2];    /* number of DIR root entries */
  /*  13 */  uint8_t sec[2];    /* total number of sectors */
  /*  15 */  uint8_t media;     /* media descriptor */
  /*  16 */  uint8_t spf[2];    /* sectors per FAT */
  /*  18 */  uint8_t spt[2];    /* sectors per track */
  /*  1a */  uint8_t sides[2];  /* number of sides */
  /*  1c */  uint8_t hid[4];    /* number of hidden sectors (earlier: 2 bytes) */
  /*  20 */  uint8_t sec2[4];   /* total number of sectors (if not in sec) */
  /*  24 */  uint8_t ldn;       /* logical drive number */
  /*  25 */  uint8_t dirty;     /* dirty filesystem flags */
  /*  26 */  uint8_t ext;       /* extended signature */
  /*  27 */  uint8_t serial2[4]; /* extended serial number */
  /*  2b */  uint8_t label[11]; /* volume label */
  /*  36 */  uint8_t fstype[8]; /* file system type */
  /*  3e */  uint8_t data[0x1c0];
  /* 1fe */  uint8_t cksum[2];
};

extern BLKDEV blkdev[NUMFLOPPIES];

