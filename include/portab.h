/************************************************************************/
/*      PORTAB.H        Pointless redefinitions of C syntax.            */
/*              Copyright 1985 Atari Corp.                              */
/*                                                                      */
/*      WARNING: Use of this file may make your code incompatible with  */
/*               C compilers throughout the civilized world.            */
/************************************************************************/

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

/*
 *      Standard type definitions
 */
#define BYTE    char                            /* Signed byte             */
#define BOOLEAN int                                     /* 2 valued (true/false)   */
#define WORD    short                           /* Signed word (16 bits)   */
#define UWORD   unsigned short          /* unsigned word           */

#define LONG    long                            /* signed long (32 bits)   */
#define ULONG   long                            /* Unsigned long           */

#define REG     register                        /* register variable       */

#ifdef __ALCYON__
#define UBYTE   char                            /* Unsigned byte           */
#endif

#ifndef UBYTE
#define UBYTE   unsigned char                   /* Unsigned byte           */
#endif

/****************************************************************************/
/*      Miscellaneous Definitions:                                          */
/****************************************************************************/
#define FAILURE (-1)                    /*      Function failure return val */
#define SUCCESS (0)                     /*      Function success return val */
#define YES     1                       /*      "TRUE"                      */
#define NO      0                       /*      "FALSE"                     */
#define FOREVER for(;;)                 /*      Infinite loop declaration   */

#ifndef TRUE
#define TRUE    (1)                     /*      Function TRUE  value        */
#define FALSE   (0)                     /*      Function FALSE value        */
#endif
