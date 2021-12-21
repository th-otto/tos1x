/***************************************************************************
 *                                                                          
 *                                 O S I F . H                              
 *                                 -----------                              
 *      Copyright 1982,1983 by Digital Research Inc. All rights reserved.   
 *                                                                          
 *      Edits:                                                              
 *      7-Mar-84  sw    Fix for 68K
 *      28-Feb-84 whf   Add C_STAT for ttyinraw()
 *      5-Jan-84 whf    Moved MAXCCBS to channel.c                          
 *      29-Dec-83 whf   Added F_TRUNC for tclose()                          
 *      12-Dec-83 whf   Change from "CPM.H" to "OSIF.H"                     
 *      9-Dec-83 whf    Handle PCDOS differences                            
 *      3-Nov-83 whf    Add multi-sector i/o                                
 *      19-Oct-83 whf   Add QUEUE handling info                             
 *      6-Oct-83 whf    Redefine reserved area in fcb for parsefn() return  
 *      25-June-83 sw   Add user number to file "fd" structure.             
 *      7-Dec-84 jsl    DOS 2.0 68k support
 *      23-Jul-85 sjs   Make __OSIF call trap for GEMDOS
 *      31-July-85 scc  Correct JSL's GEMDOS support.
 *                                                                          
 *      This file contains O.S. specific definitions for the                
 *      DRI CLEAR/C Run Time Library.                                       
 *      This file is intended only for inclusion with those functions       
 *      dealing directly with the O.S. interface, as well as any function   
 *      which has hardware dependent code (byte storage order, for          
 *      instance).                                                          
 *                                                                          
 ****************************************************************************/

#ifndef __OSIF_H__
#define __OSIF_H__ 1

/*
 *      "machine.h": to determine what kind of machine you want to run on.
 */

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

#define PCDOS   1       /* IBM PC DOS */
#define GEMDOS  1       /* GEM DOS */
#define CPM     0       /* CP/M version 2.2 */

#define I8086   0       /* Intel 8086/8088 */
#define DRC     0               /* Digital Research C Compiler */

/****   Unused DEFINEs:      ****/ 
/*      #ifdef UNdefined        */

                        /*** Processor ***/
#define MC68000 1       /* Motorola 68000 */
#define VAX     0       /* DEC VAX */
#define PDP11   0       /* DEC PDP-11 */
#define Z8000   0       /* Zilog Z8000 */

                        /*** Operating System ***/
#define CPM68K  1       /* CP/M 68000 ver 2.2 */
#define CCPM    0       /* Concurrent (multi-tasking) */
#define CPM3    0       /* CP/M version 3.x (Concurrent & Plus) */
#define CPM4    0       /* CP/M version 4.x (Portable Concurrent) */
#define UNIX    0       /* UNIX */
#define VMS     0       /* DEC VMS */

                        /*** Compiler ***/
#define ALCYON  1       /* Alcyon C Compiler */

/* #endif               */ 
/************************/


/****************************************************************************
 *      CP/M FCB definition
 ****************************************************************************/
#if CPM                                         /****************************/
struct  fcbtab                                  /****************************/
{                                               /*                          */
        char    drive;                          /* Disk drive field [0]     */
        char    fname[8];                       /* File name [1-8]          */
        char    ftype[3];                       /* File type [9-11]         */
        char    extent;                         /* Current extent number[12]*/
        char    s1,s2;                          /* "system reserved" [13-14]*/
        char    reccnt;                         /* Record counter [15]      */
        char    fpasswd[8];                     /* Parsefn passwd area[16-23]*/
        char    fuser;                          /* Parsefn user# area [24]  */
        char    resvd[7];                       /* More "system reserved"   */
        long    record;                         /* Note -- we overlap [32-36]*/
                                                /* current record field to  */
                                                /* make this useful.        */
};                                              /****************************/
#endif                                          /****************************/

/****************************************************************************
 *      PC-DOS FCB definition
 ****************************************************************************/
#if PCDOS                                       /****************************/
struct  fcbtab {                                /****************************/
        char    drive;                          /* Disk drive field [0]     */
        char    fname[8];                       /* File name [1-8]          */
        char    ftype[3];                       /* File type [9-11]         */
        int     fcb_curblk;                     /* Curr 128 byte blk [12-13]*/
        int     fcb_lrecsiz;                    /* Logical record size[14-15]*/
        long    fcb_filsiz;                     /* Num bytes in file [16-19]*/
        int     fcb_date;                       /* Last updated [20-21]     */
        char    fcb_resvd[10];                  /* System reserved [22-31]  */
        char    fcb_currec;                     /* Rel Rec# within curblk[32]*/
        long    record;                         /* Rel Rec# from bgn file   */
                                                /* [33-36] depends on lrecsiz*/
};                                              /****************************/
#endif                                          /****************************/
                                                /*                          */
#define SECSIZ          512                     /* size of CP/M sector      */
                                                /*   to obtain nsecs on err */
                                                /****************************/

/***************************************************************************
 *                                                                          
 *      Channel Control Block (CCB)                                         
 *                                                                          
 *      One CCB is allocated (statically) for each of the 16 possible open  
 *      files under C (including STDIN, STDOUT, STDERR).  Permanent data    
 *      regarding the channel is kept here.                                 
 *                                                                          
 *                                                                          
 ****************************************************************************/

struct  ccb                             /************************************/
{                                       /*                                  */
        short   flags;                  /*sw    Flags byte                  */
        short   chan;                   /*      Channel number being used   */
        short   dosfd;                  /*jsl   Dos 2.0 file descriptor     */
        long    offset;                 /*      File offset word (bytes)    */
        struct fcbtab fcb;              /*      File FCB (may have TTY info)*/
#if CPM
        short   user;                   /*sw    User #                      */
        long    sector;                 /*      Sector currently in buffer  */
        char    buffer[SECSIZ];         /*      Read/write buffer           */
#endif
};                                      /************************************/

extern  struct  ccb     _fds[]; /*  */  /*      Declare storage             */
#define FD struct ccb                   /*      FD Type definition          */
#define NULLFD ((FD *)0)                /*      NULLPTR for FD              */
                                        /************************************/
/*      Flags word bit definitions                                          */
                                        /************************************/
#define OPENED  0x01                    /*      Channel is OPEN             */
#define ISTTY   0x02                    /*      Channel open to TTY         */
#define ISREAD  0x04                    /*      Channel can be read from    */
#define ISWRITE 0x08                    /*      Channel can  written to     */
#define ISASCII 0x10                    /*      ASCII file attached         */
#define ATEOF   0x20                    /*      End of file encountered     */
#define DIRTY   0x40                    /*      Buffer needs writing        */
#define ISSPTTY 0x80                    /*      Special tty info            */
#define ISAUX   0x100                   /*sw    Auxiliary device            */
#define ISQUE   0x0200                  /*whf   Queue device                */
#define ISLPT   0

/*      CCB manipulation macros         *************************************/
#define _getccb(i) (&_fds[i])           /*      Get CCB addr                */


/***************************************************************************
 *                                                                          
 *              O S I F   F u n c t i o n   D e f i n i t i o n s           
 *              -------------------------------------------------           
 *                                                                          
 *      Following are OSIF function definitions used by the C runtime       
 *      library.                                                            
 *                                                                          
 ****************************************************************************/

                                                /****************************/
#if CPM68K
#if PCDOS
#define __OSIF(fn,arg) gemdos((fn), (long)(arg))  /* GEMDOS does it this way  */
#else
#define __OSIF(fn,arg) __BDOS((fn),(long)(arg)) /* CPM68K does it this way  */
#endif
#else
#define __OSIF(fn,arg) __BDOS((fn),(arg))       /* DRC does it this way     */
#endif
#if CPM                                         /****************************/
#define EXIT     0                              /* Exit to BDOS             */
#define CONIN    1                              /* direct echoing con input */
#define CONOUT   2                              /* Direct console output    */
#define LSTOUT   5                              /* Direct list device output*/
#define CONIO    6                              /* Direct console I/O       */
#define C_WRITESTR      9                       /* Console string output    */
#define CONBUF  10                              /* Read console buffer      */
#define C_STAT          11                      /* Get console status       */
#define S_BDOSVER       12                      /* Get System BDOS Ver Num  */
#define OPEN    15                              /* OPEN a disk file         */
#define CLOSE   16                              /* Close a disk file        */
#define SEARCHF 17                              /* Search for first         */
#define SEARCHN 18                              /* Search for next          */
#define DELETE  19                              /* Delete a disk file       */
#define CREATE  22                              /* Create a disk file       */
#define F_RENAME        23                      /* Rename a disk file       */
#define SETDMA  26                              /* Set DMA address          */
#define USER    32                              /*sw Get / set user number  */
#define B_READ  33                              /* Read Random record       */
#define B_WRITE 34                              /* Write Random record      */
#define FILSIZ  35                              /* Compute File Size        */
#define F_MULTISEC      44                      /* Set Multi-Sector Count   */
#define P_CHAIN         47                      /* Program Chain            */
#define SETVEC  61                              /* Set exception vector     */
#define N_NETSTAT       68                      /* Get Network Status       */
#define F_TRUNC 99                              /* Truncate file function   */
#define S_OSVER         163                     /* Get OS Version Number    */
#endif                                          /****************************/

#if PCDOS                                       /****************************/
/* steal one from cpm */
#define SETVEC  61                              /* Set exception vector     */
#define EXIT     0                              /* Exit to BDOS             */
#define CONIN    1                              /* direct echoing con input */
#define CONOUT   2                              /* Direct console output    */
#define LSTOUT   5                              /* Direct list device output*/
#define CONIO    6                              /* Direct console I/O       */
#define C_WRITESTR      9                       /* Console string output    */
#define CONBUF  10                              /* Read console buffer      */
#define C_STAT          11                      /* Get console status       */
#define OPEN    15                              /* OPEN a disk file         */
#define CLOSE   16                              /* Close a disk file        */
#define SEARCHF 17                              /* Search for first         */
#define SEARCHN 18                              /* Search for next          */
#define DELETE  19                              /* Delete a disk file       */
#define CREATE  22                              /* Create a disk file       */
#define F_RENAME        23                      /* Rename a disk file       */
#define SETDMA  26                              /* Set DMA address          */
#define B_READ  33                              /* Read Random record       */
#define B_WRITE 34                              /* Write Random record      */
#define FILSIZ  35                              /* Compute File Size        */

extern long gemdos PROTO ((short code, ...));
extern long __BDOS PROTO ((short code, long arg));

#endif

#if GEMDOS
#define Fcreate(a,b) gemdos(0x3c,a,b)
#define Fsfirst(a,b) gemdos(0x4e,a,b)             /* GEMDOS: <= 0: FAILURE    */
#define Fsnext() gemdos(0x4f)                     /*         == 0: SUCCESS    */
#define Fopen(a,b) gemdos(0x3d,a,b)
#define Fclose(a) gemdos(0x3e,a)
#define Fdelete(a) gemdos(0x41,a)
#define Fseek(a,b,c) gemdos(0x42,a,b,c)
#define Fread(a,b,c) gemdos(0x3f,a,b,c)
#define Fwrite(a,b,c) gemdos(0x40,a,b,c)
#define Frename(a,b) gemdos(0x56,0,a,b)
#define Crawcin() gemdos(7)
extern long gemdos PROTO ((short code, ...));
extern long bios PROTO ((short code, ...));
extern long xbios PROTO ((short code, ...));
#endif

/****************************************************************************/
/* Other CP/M definitions                                                   */
/****************************************************************************/
#define TERM    "CON:"                          /* Console file name        */
#define LIST    "LST:"                          /* List device file name    */
#define EOFCHAR 0x1a                            /* End of file character-^Z */
                                                /****************************/

/****************************************************************************/
/*      Hardware dependencies                                               */
/****************************************************************************/
                                                /****************************/
#if MC68000 | Z8000                             /* 68K or Z8000             */
#define HILO 1                                  /* used when bytes stored   */
#else                                           /*                          */
#define HILO 0                                  /* used when bytes stored   */
#endif                                          /*                          */
                                                /*                          */
#if HILO                                        /* Hi/Lo storage used in    */
struct long_struct{                             /*   68K                    */
        char lbhihi;                            /* Use this for accessing   */
        char lbhilo;                            /*   ordered bytes in 32 bit*/
        char lblohi;                            /*   long qtys.             */
        char lblolo;                            /*                          */
};                                              /*                          */
struct word_struct{                             /* Use this for accessing   */
        short lwhi;                             /*   ordered words in 32 bit*/
        short lwlo;                             /*   long qtys.             */
};                                              /*                          */
#else                                           /****************************/
struct long_struct{                             /* Lo/Hi storage use on     */
        char lblolo;                            /*   PDP-11, VAX, 8086,...  */
        char lblohi;                            /*                          */
        char lbhilo;                            /*                          */
        char lbhihi;                            /*                          */
};                                              /*                          */
struct word_struct{                             /*                          */
        short lwlo;                             /*                          */
        short lwhi;                             /*                          */
};                                              /*                          */
#endif                                          /****************************/

/*************************** end of osif.h **********************************/

#endif /* __OSIF_H__ */
