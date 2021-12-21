/****************************************************************************/
/*									    */
/*		    L o n g j u m p   H e a d e r   F i l e		    */
/*		    ---------------------------------------		    */
/*									    */
/*	Copyright 1982,83 by Digital Research.  All rights reserved.	    */
/*									    */
/*	Long jumps are implemented as follows:  			    */
/*									    */
/*		1).	Routine "setjmp" is called to setup a special 	    */
/*			buffer for return.  The return address, stack 	    */
/*			pointer and frame pointer are saved.  This allows   */
/*			the calling program to do the proper number of 	    */
/*			"pops".		    				    */
/*									    */
/*		2).	At some later time, the procedure "longjmp" is	    */
/*			called.  The programmer sees a return from the	    */
/*			previous "setjmp" as the result.		    */
/*									    */
/*	Calling sequence:						    */
/*									    */
/*		#include	<setjmp.h>	(definitions)		    */
/*		jmp_buf	 env;	(define a buffer for saved stuff)	    */
/*									    */
/*		setjmp(env);						    */
/*	a:								    */
/*									    */
/*		longjmp(env,val);					    */
/*									    */
/*	Setjmp returns a WORD of 0 on first call, and "val" on the 	    */
/*	subsequent "longjmp" call.  The longjmp call causes execution to    */
/*	resume at "a:" above.						    */
/*									    */
/****************************************************************************/

#ifndef __SETJMP_H__
#define __SETJMP_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

typedef	long	jmp_buf[13];

int setjmp PROTO((jmp_buf env));
VOID longjmp PROTO((jmp_buf env, int val));

#endif /* __SETJMP_H__ */
