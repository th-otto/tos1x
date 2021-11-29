#include "bios.h"

/*
 * sound data...
 *
 *
 * format:
 *
 *      sound data usually is found in byte pairs, the first of which is the command
 *      and the second is the argument.  However, some commands take on more than
 *      1 argument
 *
 *      cmd     function        argument(s)
 *      00      load reg0       data0
 *      01      load reg1       data0
 *      02      load reg2       data0
 *      03      load reg3       data0
 *      04      load reg4       data0
 *      05      load reg5       data0
 *      06      load reg6       data0
 *      07      load reg7       data0   note: b7 & b6 forced set for all data to r...
 *      08      load reg8       data0
 *      09      load reg9       data0
 *      0A      load reg10      data0
 *      0B      load reg11      data0
 *      0C      load reg12      data0
 *      0D      load reg13      data0
 *
 *
 *      80      init temp w/    data0
 *
 *      81      loop defined
 *              by 3 args       data0 as register to load using temp
 *                              data1 as increment/decrement (signed) of temp
 *                              data2 as loop terminator value of temp
 *
 *      82-FF   set delay
 *              timer           data0 is # of counts till next update
 *                                      note: if data0 = 0, sound is terminated
 *
 *
 *
 */

uint8_t const bellsnd[] = {
  0, 0x34,    /* channel A pitch */
  1, 0,
  2, 0,       /* no channel B */
  3, 0,
  4, 0,       /* no channel C */
  5, 0,
  6, 0,       /* no noise */
  7, 0xFE,    /* no sound or noise except channel A */
  8, 0x10,    /* channel A amplitude */
  9, 0,
  10, 0,
  11, 0,      /* envelope */
  12, 16,
  13, 9,
  0xFF, 0,    /* stop sound */
};

uint8_t const clicksnd[] = {
  0, 0x3B,
  1, 0,
  2, 0,
  3, 0,
  4, 0,
  5, 0,
  6, 0,
#if (TOSVERSION >= 0x200) | !BINEXACT
  9, 0,
  10, 0,
#endif
  7, 0xFE,
  8, 16,
  13, 3,
  11, 0x80,
  12, 1,
  0xFF, 0,
};
