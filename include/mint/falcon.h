/* bit settings for Falcon videomodes */
#define VIDEL_VALID    0x01ff           /* the only bits allowed in a videomode */
#define VIDEL_VERTICAL 0x0100           /* if set, use interlace (TV), double line (VGA) */
#define VIDEL_COMPAT   0x0080           /* ST-compatible if set */
#define VIDEL_OVERSCAN 0x0040           /* overscan if set (not used with VGA) */
#define VIDEL_PAL      0x0020           /* PAL if set; otherwise NTSC */
#define VIDEL_VGA      0x0010           /* VGA if set; otherwise TV */
#define VIDEL_80COL    0x0008           /* 80-column mode if set; otherwise 40 */
#define VIDEL_BPPMASK  0x0007           /* mask for bits/pixel encoding */
#define VIDEL_1BPP          0               /* 2 colours */
#define VIDEL_2BPP          1               /* 4 colours */
#define VIDEL_4BPP          2               /* 16 colours */
#define VIDEL_8BPP          3               /* 256 colours */
#define VIDEL_TRUECOLOR     4               /* 65536 colours */


