#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"
#include "gsxdef.h"
#include "gsxextrn.h"

#if TOSVERSION >= 0x400

static SCREENDEF const devSTLow  = {
			    "ST LOW", 2, 4, 160, 320,
			    200, 278, 278, INTERLEAVED, &ram8x8,
			    16, 1, 4096, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

static SCREENDEF const devSTMed  = {
			    "ST MEDIUM", 3, 2, 160, 640,
			    200, 278, 556, INTERLEAVED, &ram8x8,
			    4, 1, 4096, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

static SCREENDEF const devSTHigh = {
			    "ST HIGH", 4, 1, 80, 640,
			    400, 278, 278, INTERLEAVED, &ram8x16,
			    2, 1, 4096, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

static SCREENDEF const devTTLow  = {
			    "TT LOW", 9, 8, 320, 320,
			    480, 556, 278, INTERLEAVED, &ram8x16,
			    256, 1, 4096, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

static SCREENDEF const devTTMed  = {
			    "TT MEDIUM", 6, 4, 320, 640,
			    480, 278, 278, INTERLEAVED, &ram8x16,
			    16, 1, 4096, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

static SCREENDEF const devTTHigh = {
			    "TT HIGH", 8, 1, 160, 1280,
			    960, 278, 278, INTERLEAVED, &ram8x16,
			    2, 1, 2, 0, STSoftList,
			    STHardList, STSoftList, NULL
			};


#if VIDEL_SUPPORT
static SCREENDEF const dev512x400x32  = {
			    "MATRIX", 12, 32, 2048, 512,
			    400, 278, 278, PIXPACKED, &ram8x16,
			    256, 1, 0, 0, PixSoftList,
			    PixHardList, PixSoftList, (char *)0xFEC00800L
			};

static SCREENDEF const dev640x480x16  = {
			    "XGA 640x480", 11, 16, 1280, 640, 
			    480, 278, 278, PIXPACKED, &ram8x16,
			    256, 1, 0, 0, SPPixSoftList,
			    SPPixHardList, SPPixSoftList, NULL
			};

static SCREENDEF const dev8Bit   = {
			    "640x480x8 pixel packed", 10, 8, 640, 640,
			    480, 278, 278, PIXPACKED, &ram8x16,
			    256, 1, 0, 1, PixSoftList,
			    PixHardList, PixSoftList, NULL
			};
#endif

static SCREENDEF const _dev640x480x8 = {
			    "640x480x8 interleaved", 13, 8, 640, 640,
			    480, 278, 278, INTERLEAVED, &ram8x16,
			    256, 1, 4096, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

#if VIDEL_SUPPORT
static SCREENDEF const dev320x200x16 = {
			    "XGA 320x200", 14, 16, 640, 320, 
			    200, 278, 278, PIXPACKED, &ram8x8,
			    256, 1, 0, 0, SPPixSoftList,
			    SPPixHardList, SPPixSoftList, NULL
			};
#endif

static SCREENDEF const _dev320x200x8 = {
			    "320x200x8 interleaved", 16, 8, 320, 320,
			    200, 278, 278, INTERLEAVED, &ram8x8,
			    256, 1, 0, 1, STSoftList,
			    STHardList, STSoftList, NULL
			};

const SCREENDEF *const devices[] = {
			&devSTLow, &devSTMed, &devSTHigh,
			&devTTLow, &devTTMed, &devTTHigh,
#if VIDEL_SUPPORT
			&dev512x400x32,
			&dev640x480x16,
			&dev8Bit,
#endif
			&_dev640x480x8,
#if VIDEL_SUPPORT
			&dev320x200x16,
#endif
			&_dev320x200x8,
			NULL	
	    };

#endif
