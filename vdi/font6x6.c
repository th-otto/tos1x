/*
 ******************* Revision Control System *****************************
 *
 * $Author: lozben $
 * =======================================================================
 *
 * $Date: 91/01/03 15:08:55 $
 * =======================================================================
 *
 * Revision 3.0  91/01/03  15:08:55  lozben
 * New generation VDI
 * 
 * Revision 2.1  89/02/21  17:20:19  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  87/11/20  15:15:03  lozben
 * Initial revision
 * 
 *************************************************************************
 */

#include "vdi.h"
#include "fontdef.h"
#include "gsxextrn.h"


extern int16_t const off_first[];
extern int16_t const dat_first[];


struct font_head const f6x6 = {
    1,					/*   int16_t  font_id		*/
    8,					/*   int16_t  point		*/
   "6x6 system font",	/*   char  name[32]		*/
    0,					/*   uint16_t first_ade		*/
    255,				/*   uint16_t last_ade		*/
    4,					/*   uint16_t top			*/
    4,					/*   uint16_t ascent		*/
    3,					/*   uint16_t half			*/
    1,					/*   uint16_t descent		*/
    1,					/*   uint16_t bottom		*/
    5,					/*   uint16_t max_char_width	*/
    6,					/*   uint16_t max_cell_width	*/
    0,					/*   uint16_t left_offset		*/
    3,					/*   uint16_t right_offset		*/
    1,					/*   uint16_t thicken		*/
    1,					/*   uint16_t ul_size		*/
    0x5555,				/*   uint16_t lighten		*/
    0xAAAA,				/*   uint16_t skew			*/
    STDFORM | MONOSPACE,		/*   uint16_t flags		*/
    0,					/*   uint8_t *hor_table		*/
    (const uint16_t *)off_first,			/*   uint16_t *off_table		*/
    (const uint16_t *)dat_first,			/*   uint16_t *dat_table		*/
    192,				/*   uint16_t form_width		*/
    6,					/*   uint16_t form_height		*/
    0,					/*   uint16_t *next_font		*/
    0					/*   uint16_t next_seg		*/
};



int16_t const off_first[257] =
{
	0x0000,0x0006,0x000C,0x0012,0x0018,0x001E,0x0024,0x002A,
	0x0030,0x0036,0x003C,0x0042,0x0048,0x004E,0x0054,0x005A,
	0x0060,0x0066,0x006C,0x0072,0x0078,0x007E,0x0084,0x008A,
	0x0090,0x0096,0x009C,0x00A2,0x00A8,0x00AE,0x00B4,0x00BA,
	0x00C0,0x00C6,0x00CC,0x00D2,0x00D8,0x00DE,0x00E4,0x00EA,
	0x00F0,0x00F6,0x00FC,0x0102,0x0108,0x010E,0x0114,0x011A,
	0x0120,0x0126,0x012C,0x0132,0x0138,0x013E,0x0144,0x014A,
	0x0150,0x0156,0x015C,0x0162,0x0168,0x016E,0x0174,0x017A,
	0x0180,0x0186,0x018C,0x0192,0x0198,0x019E,0x01A4,0x01AA,
	0x01B0,0x01B6,0x01BC,0x01C2,0x01C8,0x01CE,0x01D4,0x01DA,
	0x01E0,0x01E6,0x01EC,0x01F2,0x01F8,0x01FE,0x0204,0x020A,
	0x0210,0x0216,0x021C,0x0222,0x0228,0x022E,0x0234,0x023A,
	0x0240,0x0246,0x024C,0x0252,0x0258,0x025E,0x0264,0x026A,
	0x0270,0x0276,0x027C,0x0282,0x0288,0x028E,0x0294,0x029A,
	0x02A0,0x02A6,0x02AC,0x02B2,0x02B8,0x02BE,0x02C4,0x02CA,
	0x02D0,0x02D6,0x02DC,0x02E2,0x02E8,0x02EE,0x02F4,0x02FA,
	0x0300,0x0306,0x030C,0x0312,0x0318,0x031E,0x0324,0x032A,
	0x0330,0x0336,0x033C,0x0342,0x0348,0x034E,0x0354,0x035A,
	0x0360,0x0366,0x036C,0x0372,0x0378,0x037E,0x0384,0x038A,
	0x0390,0x0396,0x039C,0x03A2,0x03A8,0x03AE,0x03B4,0x03BA,
	0x03C0,0x03C6,0x03CC,0x03D2,0x03D8,0x03DE,0x03E4,0x03EA,
	0x03F0,0x03F6,0x03FC,0x0402,0x0408,0x040E,0x0414,0x041A,
	0x0420,0x0426,0x042C,0x0432,0x0438,0x043E,0x0444,0x044A,
	0x0450,0x0456,0x045C,0x0462,0x0468,0x046E,0x0474,0x047A,
	0x0480,0x0486,0x048C,0x0492,0x0498,0x049E,0x04A4,0x04AA,
	0x04B0,0x04B6,0x04BC,0x04C2,0x04C8,0x04CE,0x04D4,0x04DA,
	0x04E0,0x04E6,0x04EC,0x04F2,0x04F8,0x04FE,0x0504,0x050A,
	0x0510,0x0516,0x051C,0x0522,0x0528,0x052E,0x0534,0x053A,
	0x0540,0x0546,0x054C,0x0552,0x0558,0x055E,0x0564,0x056A,
	0x0570,0x0576,0x057C,0x0582,0x0588,0x058E,0x0594,0x059A,
	0x05A0,0x05A6,0x05AC,0x05B2,0x05B8,0x05BE,0x05C4,0x05CA,
	0x05D0,0x05D6,0x05DC,0x05E2,0x05E8,0x05EE,0x05F4,0x05FA,
	0x0600
};


/* 206de: 00e33086 */
/* 306de: 00e36cce */
/* 306us: 00e36c9e */
int16_t const dat_first[576] =
{
#include "fonts/6x6/system.c"
};